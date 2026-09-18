using System.Collections.Concurrent;
using System.Text.Json;
using System.Text.Json.Serialization;
using Ananta.SDK.Network;
using Ananta.Server.Protocol.Client4229938;

namespace Ananta.Server.Gameplay.Crowd;

public sealed class InteriorsFile
{
    [JsonPropertyName("metadata")]
    public InteriorMetadata Metadata { get; set; } = new();

    [JsonPropertyName("spatialGrid")]
    public Dictionary<string, List<int>> SpatialGrid { get; set; } = new();

    [JsonPropertyName("interiors")]
    public List<InteriorEntry> Interiors { get; set; } = [];
}

public sealed class InteriorMetadata
{
    [JsonPropertyName("totalInteriors")]
    public int TotalInteriors { get; set; }

    [JsonPropertyName("gridSize")]
    public float GridSize { get; set; } = 100f;
}

public sealed class InteriorEntry
{
    [JsonPropertyName("id")]
    public int Id { get; set; }

    [JsonPropertyName("name")]
    public string Name { get; set; } = string.Empty;

    [JsonPropertyName("sector")]
    public string Sector { get; set; } = string.Empty;

    [JsonPropertyName("pos")]
    public List<float> Pos { get; set; } = [];
}

public sealed class PedestrianNetworkFile
{
    [JsonPropertyName("metadata")]
    public PedestrianMetadata Metadata { get; set; } = new();

    [JsonPropertyName("spatialGrid")]
    public Dictionary<string, List<int>> SpatialGrid { get; set; } = new();

    [JsonPropertyName("lanes")]
    public List<PedestrianLaneEntry> Lanes { get; set; } = [];
}

public sealed class PedestrianMetadata
{
    [JsonPropertyName("totalLanes")]
    public int TotalLanes { get; set; }

    [JsonPropertyName("gridSize")]
    public float GridSize { get; set; } = 100f;
}

public sealed class PedestrianLaneEntry
{
    [JsonPropertyName("id")]
    public int Id { get; set; }

    [JsonPropertyName("tags")]
    public List<string> Tags { get; set; } = [];

    [JsonPropertyName("pts")]
    public List<List<float>> Pts { get; set; } = [];

    [JsonPropertyName("isCrosswalk")]
    public bool IsCrosswalk { get; set; }
}

public sealed class UrbanCrowdEngine
{
    public static UrbanCrowdEngine Instance { get; } = new();

    private IUrbanCrowdDriver? _driver;
    private Func<IEnumerable<TcpSession>>? _sessionProvider;

    private InteriorsFile? _interiorsData;
    private PedestrianNetworkFile? _pedestrianData;

    private readonly ConcurrentDictionary<int, DateTime> _populatedInteriors = new();
    private readonly ConcurrentDictionary<ulong, ActiveCrowdNpc> _activeCrowd = new();

    private CancellationTokenSource? _cts;
    private Task? _crowdLoopTask;

    public bool Enabled { get; set; } = true;
    public int TargetPedestrianDensity { get; set; } = 25;
    public bool PopulateShops { get; set; } = true;

    // Verified authentic civilian models from AgentConfig (4013xxxx)
    private static readonly uint[] CitizenFormworkPool =
    [
        40130003, // Generic Young Woman (少女)
        40130017, // Generic Young Boy (少男)
        40130020, // Generic Adult Female (成女)
        40130035, // Generic Adult Male (成男)
        40130101, // Emily Sato - Lively female shopkeeper
        40130102, // Sato Saori - Gentle female shopkeeper
        40130117, // Emma - Store greeter
        40130118, // Owen King - Store manager
        40130121, // Hunter Davis - Store clerk
        40130122, // Linda Wilson - Professional female clerk
        40130128, // Eiko Anderson - Boutique clerk
        40131542, // Yang Zhiyuan - Cafe Barista
        40131591, // Cheng Mosheng - Kiosk clerk
        40130852, // Mizuki Mei - Bar & Nightclub patron
        40650080, // Mizuki Mei - Bar patron
        40651232, // Eugene Price - Cafe patron/customer
        40969501, // Daphne Shelby - Fashion blogger pedestrian
        40968790, // Kaneko Mei - Pedestrian
    ];

    // Common idle / chatter / phone POI action IDs
    private static readonly uint[] AmbientPoiActions = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10];

    private readonly Random _rng = new();

    public sealed class ActiveCrowdNpc
    {
        public ulong EntityId { get; set; }
        public uint FormworkId { get; set; }
        public float X { get; set; }
        public float Y { get; set; }
        public float Z { get; set; }
        public float Facing { get; set; }
        public float Speed { get; set; } = 1.3f;
        public bool IsWalking { get; set; }
        public List<(float X, float Y, float Z)> Waypoints { get; } = [];
        public int CurrentWpIndex { get; set; }
        public bool WalkForwardDirection { get; set; } = true;
        public DateTime SpawnedAt { get; set; }
    }

    public void Initialize(string clientDataPath, IUrbanCrowdDriver driver, Func<IEnumerable<TcpSession>> sessionProvider)
    {
        _driver = driver;
        _sessionProvider = sessionProvider;

        var interiorsPath = Path.Combine(clientDataPath, "World", "Interiors.json");
        var pedPath = Path.Combine(clientDataPath, "World", "PedestrianNetwork.json");

        try
        {
            if (File.Exists(interiorsPath))
            {
                var json = File.ReadAllText(interiorsPath);
                _interiorsData = JsonSerializer.Deserialize<InteriorsFile>(json);
                Console.WriteLine($"[CROWD] Loaded {_interiorsData?.Interiors.Count ?? 0} shop interiors.");
            }

            if (File.Exists(pedPath))
            {
                var json = File.ReadAllText(pedPath);
                _pedestrianData = JsonSerializer.Deserialize<PedestrianNetworkFile>(json);
                Console.WriteLine($"[CROWD] Loaded {_pedestrianData?.Lanes.Count ?? 0} pedestrian sidewalk/crosswalk lanes.");
            }
        }
        catch (Exception ex)
        {
            Console.WriteLine($"[CROWD] Error loading world crowd data: {ex.Message}");
        }

        Start();
    }

    private Task? _motionLoopTask;

    public void Start()
    {
        if (_crowdLoopTask is not null && !_crowdLoopTask.IsCompleted)
            return;

        _cts = new CancellationTokenSource();
        _crowdLoopTask = Task.Run(() => CrowdLoopAsync(_cts.Token));
        _motionLoopTask = Task.Run(() => CrowdMotionLoopAsync(_cts.Token));
        Console.WriteLine("[CROWD] Living Urban Crowd Engine started (Spawn & Locomotion loops).");
    }

    public void Stop()
    {
        _cts?.Cancel();
    }

    private async Task CrowdLoopAsync(CancellationToken token)
    {
        while (!token.IsCancellationRequested)
        {
            try
            {
                if (Enabled && _driver is not null && _sessionProvider is not null)
                {
                    var sessions = _sessionProvider().ToList();
                    foreach (var session in sessions)
                    {
                        await TickSessionCrowdAsync(session);
                    }
                }
            }
            catch (Exception ex)
            {
                Console.WriteLine($"[CROWD-ERROR] Tick error: {ex.Message}");
            }

            try
            {
                await Task.Delay(2500, token);
            }
            catch (OperationCanceledException)
            {
                break;
            }
        }
    }

    private async Task CrowdMotionLoopAsync(CancellationToken token)
    {
        const int motionIntervalMs = 125; // 8 Hz locomotion push
        const float dt = motionIntervalMs / 1000f;

        while (!token.IsCancellationRequested)
        {
            try
            {
                if (Enabled && _driver is not null && _sessionProvider is not null)
                {
                    var sessions = _sessionProvider().ToList();
                    foreach (var session in sessions)
                    {
                        await TickSessionCrowdMotionAsync(session, dt);
                    }
                }
            }
            catch (Exception ex)
            {
                Console.WriteLine($"[CROWD-MOTION-ERROR] {ex.Message}");
            }

            try
            {
                await Task.Delay(motionIntervalMs, token);
            }
            catch (OperationCanceledException)
            {
                break;
            }
        }
    }

    private async Task TickSessionCrowdMotionAsync(TcpSession session, float dt)
    {
        if (_driver is null) return;
        var (hasPlayer, px, py, pz, _, _) = _driver.GetPlayerPosition(session);
        if (!hasPlayer) return;

        foreach (var npc in _activeCrowd.Values)
        {
            if (!npc.IsWalking || npc.Waypoints.Count < 2)
                continue;

            var dx = npc.X - px;
            var dz = npc.Z - pz;
            if (dx * dx + dz * dz > 90f * 90f)
                continue;

            var targetIdx = npc.CurrentWpIndex;
            if (targetIdx >= npc.Waypoints.Count)
            {
                npc.WalkForwardDirection = false;
                npc.CurrentWpIndex = Math.Max(0, npc.Waypoints.Count - 2);
                targetIdx = npc.CurrentWpIndex;
            }
            else if (targetIdx < 0)
            {
                npc.WalkForwardDirection = true;
                npc.CurrentWpIndex = Math.Min(1, npc.Waypoints.Count - 1);
                targetIdx = npc.CurrentWpIndex;
            }

            var target = npc.Waypoints[targetIdx];
            var toTargetX = target.X - npc.X;
            var toTargetZ = target.Z - npc.Z;
            var distToTarget = MathF.Sqrt(toTargetX * toTargetX + toTargetZ * toTargetZ);

            if (distToTarget < 0.6f)
            {
                npc.CurrentWpIndex += npc.WalkForwardDirection ? 1 : -1;
                continue;
            }

            var step = MathF.Min(distToTarget, npc.Speed * dt);
            var dirX = toTargetX / distToTarget;
            var dirZ = toTargetZ / distToTarget;
            npc.X += dirX * step;
            npc.Z += dirZ * step;

            var yawDeg = MathF.Atan2(dirX, dirZ) * (180f / MathF.PI);
            npc.Facing = yawDeg;

            await _driver.SendPedestrianMoveAsync(
                session, npc.EntityId, npc.X, npc.Y, npc.Z, npc.Facing, WorldCodec.MoveAction.WalkFront);
        }
    }

    private async Task TickSessionCrowdAsync(TcpSession session)
    {
        if (_driver is null)
            return;

        var (hasPlayer, px, py, pz, pyaw, _) = _driver.GetPlayerPosition(session);
        if (!hasPlayer || !float.IsFinite(px) || !float.IsFinite(pz))
            return;

        // 0. Prune distant pedestrians (> 120m) to continuously recycle population
        var toRemove = new List<ulong>();
        foreach (var npc in _activeCrowd.Values)
        {
            var dx = npc.X - px;
            var dz = npc.Z - pz;
            if (dx * dx + dz * dz > 120f * 120f)
            {
                toRemove.Add(npc.EntityId);
            }
        }

        foreach (var id in toRemove)
        {
            if (_activeCrowd.TryRemove(id, out _))
            {
                await _driver.DespawnCrowdPedestrianAsync(session, id);
            }
        }

        // Also prune distant interior records (> 100m)
        if (_interiorsData is not null && _populatedInteriors.Count > 0)
        {
            var distantShops = new List<int>();
            foreach (var (shopId, _) in _populatedInteriors)
            {
                var shop = _interiorsData.Interiors.FirstOrDefault(s => s.Id == shopId);
                if (shop is not null && shop.Pos.Count >= 3)
                {
                    var sdx = shop.Pos[0] - px;
                    var sdz = shop.Pos[2] - pz;
                    if (sdx * sdx + sdz * sdz > 100f * 100f)
                        distantShops.Add(shopId);
                }
            }
            foreach (var sId in distantShops)
                _populatedInteriors.TryRemove(sId, out _);
        }

        // 1. Populate nearby shops and cafes (within 60m)
        if (PopulateShops && _interiorsData is not null)
        {
            var grid = _interiorsData.SpatialGrid;
            var gridSize = _interiorsData.Metadata.GridSize;
            var centerCx = (int)MathF.Floor(px / gridSize);
            var centerCz = (int)MathF.Floor(pz / gridSize);

            for (var cx = centerCx - 1; cx <= centerCx + 1; cx++)
            {
                for (var cz = centerCz - 1; cz <= centerCz + 1; cz++)
                {
                    var ckey = $"{cx}_{cz}";
                    if (grid.TryGetValue(ckey, out var interiorIndices))
                    {
                        foreach (var idx in interiorIndices)
                        {
                            if (idx >= 0 && idx < _interiorsData.Interiors.Count)
                            {
                                var shop = _interiorsData.Interiors[idx];
                                if (shop.Pos.Count < 3) continue;

                                var sx = shop.Pos[0];
                                var sy = shop.Pos[1];
                                var sz = shop.Pos[2];

                                // Ground elevation clamping: align indoor floor Y with player elevation to prevent falling into void
                                if (MathF.Abs(sy - py) > 2.5f)
                                    sy = py;

                                var dx = sx - px;
                                var dz = sz - pz;
                                var distSq = dx * dx + dz * dz;

                                if (distSq <= 60f * 60f && !_populatedInteriors.ContainsKey(shop.Id))
                                {
                                    _populatedInteriors[shop.Id] = DateTime.UtcNow;

                                    // Spawn 1 shopkeeper/patron inside
                                    var formworkId = CitizenFormworkPool[_rng.Next(CitizenFormworkPool.Length)];
                                    var poiAction = AmbientPoiActions[_rng.Next(AmbientPoiActions.Length)];
                                    var facing = _rng.Next(0, 360);

                                    var (ok, ids) = await _driver.SpawnCrowdPedestriansAsync(
                                        session, formworkId, poiAction, sx, sy, sz, facing);

                                    if (ok && ids.Length > 0)
                                    {
                                        _activeCrowd[ids[0]] = new ActiveCrowdNpc
                                        {
                                            EntityId = ids[0],
                                            FormworkId = formworkId,
                                            X = sx,
                                            Y = sy,
                                            Z = sz,
                                            Facing = facing,
                                            IsWalking = false,
                                            SpawnedAt = DateTime.UtcNow
                                        };
                                        Console.WriteLine($"[CROWD] Populated shop '{shop.Name}' with citizen NPC {formworkId}!");
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }

        // 2. Sidewalk pedestrians
        if (_pedestrianData is not null && _activeCrowd.Count < TargetPedestrianDensity)
        {
            var pGrid = _pedestrianData.SpatialGrid;
            var pGridSize = _pedestrianData.Metadata.GridSize;
            var centerCx = (int)MathF.Floor(px / pGridSize);
            var centerCz = (int)MathF.Floor(pz / pGridSize);

            var candidateLanes = new List<PedestrianLaneEntry>();

            for (var cx = centerCx - 1; cx <= centerCx + 1; cx++)
            {
                for (var cz = centerCz - 1; cz <= centerCz + 1; cz++)
                {
                    var ckey = $"{cx}_{cz}";
                    if (pGrid.TryGetValue(ckey, out var laneIds))
                    {
                        foreach (var laneId in laneIds)
                        {
                            if (laneId >= 0 && laneId < _pedestrianData.Lanes.Count)
                            {
                                var lane = _pedestrianData.Lanes[laneId];
                                if (lane.Pts.Count >= 2)
                                {
                                    var pt0 = lane.Pts[0];
                                    var ldx = pt0[0] - px;
                                    var ldz = pt0[2] - pz;
                                    var dSq = ldx * ldx + ldz * ldz;
                                    if (dSq >= 20f * 20f && dSq <= 85f * 85f)
                                    {
                                        candidateLanes.Add(lane);
                                    }
                                }
                            }
                        }
                    }
                }
            }

            if (candidateLanes.Count > 0)
            {
                var chosenLane = candidateLanes[_rng.Next(candidateLanes.Count)];
                var pt0 = chosenLane.Pts[0];
                var spawnY = MathF.Abs(pt0[1] - py) > 2.5f ? py : pt0[1];
                var formworkId = CitizenFormworkPool[_rng.Next(CitizenFormworkPool.Length)];
                var isWalker = _rng.Next(100) < 60; // 60% walkers, 40% ambient idle/talkers
                var poiAction = isWalker ? 0u : AmbientPoiActions[_rng.Next(AmbientPoiActions.Length)];
                var facing = _rng.Next(0, 360);

                var (ok, ids) = await _driver.SpawnCrowdPedestriansAsync(
                    session, formworkId, poiAction, pt0[0], spawnY, pt0[2], facing);

                if (ok && ids.Length > 0)
                {
                    var npc = new ActiveCrowdNpc
                    {
                        EntityId = ids[0],
                        FormworkId = formworkId,
                        X = pt0[0],
                        Y = spawnY,
                        Z = pt0[2],
                        Facing = facing,
                        IsWalking = isWalker,
                        CurrentWpIndex = 1,
                        WalkForwardDirection = true,
                        SpawnedAt = DateTime.UtcNow
                    };

                    if (isWalker)
                    {
                        foreach (var pt in chosenLane.Pts)
                        {
                            if (pt.Count >= 3)
                                npc.Waypoints.Add((pt[0], MathF.Abs(pt[1] - py) > 2.5f ? py : pt[1], pt[2]));
                        }
                    }

                    _activeCrowd[ids[0]] = npc;
                }
            }
        }
    }

    public CrowdStatus GetStatus() => new()
    {
        Enabled = Enabled,
        TargetDensity = TargetPedestrianDensity,
        ActiveCrowdCount = _activeCrowd.Count,
        PopulatedShopsCount = _populatedInteriors.Count,
        TotalInteriors = _interiorsData?.Interiors.Count ?? 0,
        TotalPedestrianLanes = _pedestrianData?.Lanes.Count ?? 0
    };
}

public sealed class CrowdStatus
{
    public bool Enabled { get; set; }
    public int TargetDensity { get; set; }
    public int ActiveCrowdCount { get; set; }
    public int PopulatedShopsCount { get; set; }
    public int TotalInteriors { get; set; }
    public int TotalPedestrianLanes { get; set; }
}
