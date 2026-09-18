using System.Collections.Concurrent;
using System.Text.Json;
using Ananta.SDK.Network;

namespace Ananta.Server.Gameplay.Traffic;

public sealed class CityTrafficEngine
{
    public static CityTrafficEngine Instance { get; } = new();

    private ITrafficVehicleDriver? _driver;
    private Func<IEnumerable<TcpSession>>? _sessionProvider;

    private readonly ConcurrentDictionary<ulong, SimulatedVehicle> _simulatedVehicles = new();
    private RoadNetworkFile? _roadNetwork;
    private TrafficSignalFile? _signalData;
    private readonly Dictionary<int, RoadLaneData> _laneLookup = new();

    private CancellationTokenSource? _cts;
    private Task? _simulationLoopTask;

    // Traffic Configuration
    public bool Enabled { get; set; } = true;
    public int TargetDensity { get; set; } = 20;
    public float SpeedScale { get; set; } = 1.0f;
    public float MinSpawnDistance { get; set; } = 50f;
    public float MaxSpawnDistance { get; set; } = 160f;
    public float DespawnDistance { get; set; } = 220f;

    // Pool of verified vehicle configs with full models and multi-seat support (no damaged/wrecked models)
    private static readonly uint[] TrafficVehiclePool =
    [
        81001001, // Sunset Skywing (Sedan)
        81001002, // Korou RV6 (SUV)
        81001003, // Kazama Voyage (Sedan)
        81000007, // Sunset GT-X Specter (Sports Car)
        81004001, // Kazama CRN6 (Taxi)
        81004027, // Kazama Sandstorm (Police Cruiser)
    ];

    private readonly Random _rng = new();

    public void NotifyVehicleBoarding(ulong entityId)
    {
        if (_simulatedVehicles.TryRemove(entityId, out var v))
        {
            v.HijackedByPlayer = true;
            Console.WriteLine($"[TRAFFIC] Vehicle entity={entityId} boarded by player. Detached from traffic loop.");
        }
    }

    public sealed class SimulatedVehicle
    {
        public ulong EntityId { get; set; }
        public uint ConfigId { get; set; }
        public int CurrentLaneId { get; set; }
        public float DistanceOnLane { get; set; }
        public float Speed { get; set; }
        public float X { get; set; }
        public float Y { get; set; }
        public float Z { get; set; }
        public float Yaw { get; set; }
        public DateTime CreatedAt { get; set; }
        public bool HijackedByPlayer { get; set; }
    }

    public void Initialize(string clientDataPath, ITrafficVehicleDriver driver, Func<IEnumerable<TcpSession>> sessionProvider)
    {
        _driver = driver;
        _sessionProvider = sessionProvider;

        var roadPath = Path.Combine(clientDataPath, "World", "RoadNetwork.json");
        if (File.Exists(roadPath))
        {
            try
            {
                Console.WriteLine($"[TRAFFIC] Loading road network from: {roadPath}...");
                var json = File.ReadAllText(roadPath);
                _roadNetwork = JsonSerializer.Deserialize<RoadNetworkFile>(json);
                if (_roadNetwork is not null)
                {
                    foreach (var lane in _roadNetwork.Lanes)
                    {
                        lane.Precompute();
                        _laneLookup[lane.Id] = lane;
                    }
                    Console.WriteLine($"[TRAFFIC] Road network loaded: {_roadNetwork.Lanes.Count} lanes precomputed across {_roadNetwork.SpatialGrid.Count} spatial cells.");
                }
            }
            catch (Exception ex)
            {
                Console.WriteLine($"[TRAFFIC] Failed to load road network: {ex.Message}");
            }
        }
        else
        {
            Console.WriteLine($"[TRAFFIC] RoadNetwork.json not found at: {roadPath}");
        }

        var signalPath = Path.Combine(clientDataPath, "World", "TrafficSignals.json");
        if (File.Exists(signalPath))
        {
            try
            {
                var sJson = File.ReadAllText(signalPath);
                _signalData = JsonSerializer.Deserialize<TrafficSignalFile>(sJson);
                Console.WriteLine($"[TRAFFIC] Loaded {_signalData?.Lights.Count ?? 0} traffic signals from {signalPath}.");
            }
            catch (Exception ex)
            {
                Console.WriteLine($"[TRAFFIC] Error loading traffic signals: {ex.Message}");
            }
        }

        Start();
    }

    public void Start()
    {
        if (_simulationLoopTask is not null && !_simulationLoopTask.IsCompleted)
            return;

        _cts = new CancellationTokenSource();
        _simulationLoopTask = Task.Run(() => SimulationLoopAsync(_cts.Token));
        Console.WriteLine("[TRAFFIC] Autonomous City Traffic Engine started.");
    }

    public void Stop()
    {
        _cts?.Cancel();
    }

    private async Task SimulationLoopAsync(CancellationToken token)
    {
        const int tickIntervalMs = 100; // 10 ticks per second for smooth client replication
        const float dt = tickIntervalMs / 1000f;

        while (!token.IsCancellationRequested)
        {
            try
            {
                if (Enabled && _driver is not null && _sessionProvider is not null && _roadNetwork is not null)
                {
                    var sessions = _sessionProvider().ToList();
                    foreach (var session in sessions)
                    {
                        await TickSessionTrafficAsync(session, dt);
                    }
                }
            }
            catch (Exception ex)
            {
                // Engine tick exception guard
                Console.WriteLine($"[TRAFFIC-ERROR] Loop exception: {ex.Message}");
            }

            try
            {
                await Task.Delay(tickIntervalMs, token);
            }
            catch (OperationCanceledException)
            {
                break;
            }
        }
    }

    private async Task TickSessionTrafficAsync(TcpSession session, float dt)
    {
        if (_driver is null || _roadNetwork is null)
            return;

        var (hasPlayer, px, py, pz, pyaw, raidId) = _driver.GetPlayerPosition(session);
        if (!hasPlayer || !float.IsFinite(px) || !float.IsFinite(pz))
            return;

        // 1. Move and update existing simulated vehicles
        var vehicleEntries = _simulatedVehicles.Values.ToList();
        foreach (var v in vehicleEntries)
        {
            if (v.HijackedByPlayer)
                continue;

            // Check if player has boarded or driven this vehicle
            if (_driver.IsVehiclePlayerControlled(v.EntityId))
            {
                v.HijackedByPlayer = true;
                _simulatedVehicles.TryRemove(v.EntityId, out _);
                Console.WriteLine($"[TRAFFIC] Player took control of traffic vehicle entity={v.EntityId}!");
                continue;
            }

            // Distance to player
            var dx = v.X - px;
            var dz = v.Z - pz;
            var distSq = dx * dx + dz * dz;

            if (distSq > DespawnDistance * DespawnDistance)
            {
                // Despawn far away vehicle
                _simulatedVehicles.TryRemove(v.EntityId, out _);
                await _driver.DestroyTrafficVehicleAsync(session, v.EntityId);
                continue;
            }

            // Advance vehicle along lane
            if (!_laneLookup.TryGetValue(v.CurrentLaneId, out var currentLane) || currentLane.TotalLength <= 0.1f)
            {
                _simulatedVehicles.TryRemove(v.EntityId, out _);
                await _driver.DestroyTrafficVehicleAsync(session, v.EntityId);
                continue;
            }

            // 1. Car-Following: Check if there is another vehicle ahead on the same lane
            var effectiveSpeed = v.Speed;
            SimulatedVehicle? leadingVehicle = null;
            var minGap = float.MaxValue;

            foreach (var other in vehicleEntries)
            {
                if (other.EntityId == v.EntityId || other.HijackedByPlayer)
                    continue;

                if (other.CurrentLaneId == v.CurrentLaneId && other.DistanceOnLane > v.DistanceOnLane)
                {
                    var gap = other.DistanceOnLane - v.DistanceOnLane;
                    if (gap < minGap)
                    {
                        minGap = gap;
                        leadingVehicle = other;
                    }
                }
            }

            if (leadingVehicle is not null)
            {
                if (minGap < 5f)
                {
                    // Emergency stop to prevent rear-end collision
                    effectiveSpeed = 0f;
                }
                else if (minGap < 14f)
                {
                    // Smooth deceleration matching leader
                    effectiveSpeed = MathF.Min(effectiveSpeed, leadingVehicle.Speed * ((minGap - 4f) / 10f));
                }
            }

            // 2. Traffic Light check: if approaching a red signal, decelerate/stop
            if (effectiveSpeed > 0f && IsTrafficLightRedForVehicle(v.X, v.Y, v.Z, v.Yaw))
            {
                effectiveSpeed = MathF.Max(0f, effectiveSpeed - 6f * dt);
            }

            v.DistanceOnLane += effectiveSpeed * SpeedScale * dt;

            // Check if vehicle reached the end of the lane
            if (v.DistanceOnLane >= currentLane.TotalLength)
            {
                if (currentLane.Next.Count > 0)
                {
                    // Pick next connected lane
                    var nextLaneId = currentLane.Next[_rng.Next(currentLane.Next.Count)];
                    if (_laneLookup.TryGetValue(nextLaneId, out var nextLane))
                    {
                        v.CurrentLaneId = nextLaneId;
                        v.DistanceOnLane = 0f;
                        v.Speed = nextLane.Speed > 0 ? nextLane.Speed : currentLane.Speed;
                        currentLane = nextLane;
                    }
                    else
                    {
                        // Unresolved next lane -> despawn
                        _simulatedVehicles.TryRemove(v.EntityId, out _);
                        await _driver.DestroyTrafficVehicleAsync(session, v.EntityId);
                        continue;
                    }
                }
                else
                {
                    // Dead end -> despawn
                    _simulatedVehicles.TryRemove(v.EntityId, out _);
                    await _driver.DestroyTrafficVehicleAsync(session, v.EntityId);
                    continue;
                }
            }

            // Calculate new spline position & velocity
            var (nx, ny, nz, nyaw, vx, vz) = currentLane.Evaluate(v.DistanceOnLane, effectiveSpeed * SpeedScale);
            v.X = nx;
            v.Y = ny;
            v.Z = nz;
            v.Yaw = nyaw;

            // Send smooth SyncVehicleMove to client
            await _driver.SendVehicleMoveAsync(session, v.EntityId, nx, ny, nz, nyaw, vx, vz);
        }

        // 2. Spawn new vehicles if below target density
        var activeCount = _simulatedVehicles.Count;
        if (activeCount < TargetDensity)
        {
            await TrySpawnTrafficVehicleAroundPlayerAsync(session, px, py, pz, pyaw);
        }
    }

    private async Task<bool> TrySpawnTrafficVehicleAroundPlayerAsync(
        TcpSession session, float px, float py, float pz, float pyaw)
    {
        if (_driver is null || _roadNetwork is null)
            return false;

        // Query spatial cells around player
        var grid = _roadNetwork.SpatialGrid;
        var gridSize = _roadNetwork.Metadata.GridSize;
        var centerCx = (int)MathF.Floor(px / gridSize);
        var centerCz = (int)MathF.Floor(pz / gridSize);

        var candidateLanes = new List<RoadLaneData>();
        var minSq = MinSpawnDistance * MinSpawnDistance;
        var maxSq = MaxSpawnDistance * MaxSpawnDistance;

        // Search 3x3 surrounding cells (~300m range)
        for (var cx = centerCx - 2; cx <= centerCx + 2; cx++)
        {
            for (var cz = centerCz - 2; cz <= centerCz + 2; cz++)
            {
                var ckey = $"{cx}_{cz}";
                if (grid.TryGetValue(ckey, out var laneIds))
                {
                    foreach (var lId in laneIds)
                    {
                        if (_laneLookup.TryGetValue(lId, out var lane) && lane.TotalLength > 10f)
                        {
                            var laneStart = lane.Pts[0];
                            var ldx = laneStart[0] - px;
                            var ldz = laneStart[2] - pz;
                            var dSq = ldx * ldx + ldz * ldz;
                            if (dSq >= minSq && dSq <= maxSq)
                            {
                                candidateLanes.Add(lane);
                            }
                        }
                    }
                }
            }
        }

        if (candidateLanes.Count == 0)
            return false;

        // Pick a random lane from candidates
        var chosenLane = candidateLanes[_rng.Next(candidateLanes.Count)];

        // Check if there is already a vehicle near the start of this lane
        foreach (var existing in _simulatedVehicles.Values)
        {
            if (existing.CurrentLaneId == chosenLane.Id && existing.DistanceOnLane < 20f)
                return false; // Lane entry occupied
        }

        // Evaluate spawn coordinates at start of lane
        var (sx, sy, sz, syaw, _, _) = chosenLane.Evaluate(0f, 0f);

        // Pick vehicle config
        var configId = TrafficVehiclePool[_rng.Next(TrafficVehiclePool.Length)];

        var (ok, entityId) = await _driver.SpawnTrafficVehicleAsync(session, configId, sx, sy, sz, syaw);
        if (!ok || entityId == 0)
            return false;

        var simVehicle = new SimulatedVehicle
        {
            EntityId = entityId,
            ConfigId = configId,
            CurrentLaneId = chosenLane.Id,
            DistanceOnLane = 0f,
            Speed = chosenLane.Speed > 0f ? chosenLane.Speed : 11.11f,
            X = sx,
            Y = sy,
            Z = sz,
            Yaw = syaw,
            CreatedAt = DateTime.UtcNow,
            HijackedByPlayer = false
        };

        _simulatedVehicles[entityId] = simVehicle;
        return true;
    }

    public async Task<int> SpawnWaveAheadAsync(TcpSession session, int count = 5)
    {
        if (_driver is null || _roadNetwork is null)
            return 0;

        var (hasPlayer, px, py, pz, pyaw, _) = _driver.GetPlayerPosition(session);
        if (!hasPlayer)
            return 0;

        var spawned = 0;
        for (var i = 0; i < count; i++)
        {
            if (await TrySpawnTrafficVehicleAroundPlayerAsync(session, px, py, pz, pyaw))
                spawned++;
        }
        return spawned;
    }

    public async Task ClearAllTrafficAsync(TcpSession session)
    {
        if (_driver is null)
            return;

        var ids = _simulatedVehicles.Keys.ToList();
        _simulatedVehicles.Clear();

        foreach (var id in ids)
        {
            await _driver.DestroyTrafficVehicleAsync(session, id);
        }

        Console.WriteLine($"[TRAFFIC] Cleared {ids.Count} traffic vehicles.");
    }

    private bool IsTrafficLightRedForVehicle(float vx, float vy, float vz, float vyaw)
    {
        if (_signalData is null || _signalData.Lights.Count == 0)
            return false;

        var cycleSecond = (DateTime.UtcNow.Ticks / TimeSpan.TicksPerSecond) % 30; // 30s cycle

        foreach (var light in _signalData.Lights)
        {
            if (light.Pos.Count < 3) continue;
            var ldx = light.Pos[0] - vx;
            var ldz = light.Pos[2] - vz;
            var distSq = ldx * ldx + ldz * ldz;

            // Approaching intersection light within 6m to 24m
            if (distSq >= 6f * 6f && distSq <= 24f * 24f)
            {
                var isPhaseA = (light.Zbr % 2) == 0;
                var isRed = isPhaseA ? (cycleSecond >= 14) : (cycleSecond < 15 || cycleSecond == 29);

                if (isRed)
                    return true;
            }
        }

        return false;
    }

    public TrafficStatus GetStatus() => new()
    {
        Enabled = Enabled,
        TargetDensity = TargetDensity,
        SpeedScale = SpeedScale,
        ActiveVehicles = _simulatedVehicles.Count,
        TotalRoadLanes = _roadNetwork?.Lanes.Count ?? 0,
        TotalSpatialCells = _roadNetwork?.SpatialGrid.Count ?? 0
    };
}

public sealed class TrafficStatus
{
    public bool Enabled { get; set; }
    public int TargetDensity { get; set; }
    public float SpeedScale { get; set; }
    public int ActiveVehicles { get; set; }
    public int TotalRoadLanes { get; set; }
    public int TotalSpatialCells { get; set; }
}
