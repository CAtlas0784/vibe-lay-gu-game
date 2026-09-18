using System.Collections.Concurrent;
using System.Text.Json;
using System.Text.Json.Serialization;
using Ananta.SDK.Network;

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
    public int TargetPedestrianDensity { get; set; } = 15;
    public bool PopulateShops { get; set; } = true;

    // Verified authentic civilian, shopkeeper, barista, and bar patron NPCs
    private static readonly uint[] CitizenFormworkPool =
    [
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

    public void Start()
    {
        if (_crowdLoopTask is not null && !_crowdLoopTask.IsCompleted)
            return;

        _cts = new CancellationTokenSource();
        _crowdLoopTask = Task.Run(() => CrowdLoopAsync(_cts.Token));
        Console.WriteLine("[CROWD] Living Urban Crowd Engine started.");
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
                // Run crowd checks every 2.5 seconds (crowd spawns do not require high frequency updates)
                await Task.Delay(2500, token);
            }
            catch (OperationCanceledException)
            {
                break;
            }
        }
    }

    private async Task TickSessionCrowdAsync(TcpSession session)
    {
        if (_driver is null)
            return;

        var (hasPlayer, px, py, pz, pyaw, _) = _driver.GetPlayerPosition(session);
        if (!hasPlayer || !float.IsFinite(px) || !float.IsFinite(pz))
            return;

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

            var candidateWaypoints = new List<(float X, float Y, float Z)>();

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
                                foreach (var pt in lane.Pts)
                                {
                                    if (pt.Count < 3) continue;
                                    var ldx = pt[0] - px;
                                    var ldz = pt[2] - pz;
                                    var dSq = ldx * ldx + ldz * ldz;
                                    if (dSq >= 25f * 25f && dSq <= 80f * 80f)
                                    {
                                        candidateWaypoints.Add((pt[0], pt[1], pt[2]));
                                    }
                                }
                            }
                        }
                    }
                }
            }

            if (candidateWaypoints.Count > 0)
            {
                var wp = candidateWaypoints[_rng.Next(candidateWaypoints.Count)];
                // Ground elevation clamping: ensure sidewalk pedestrian Y is on mesh floor
                var spawnY = MathF.Abs(wp.Y - py) > 2.5f ? py : wp.Y;
                var formworkId = CitizenFormworkPool[_rng.Next(CitizenFormworkPool.Length)];
                var poiAction = AmbientPoiActions[_rng.Next(AmbientPoiActions.Length)];
                var facing = _rng.Next(0, 360);

                var (ok, ids) = await _driver.SpawnCrowdPedestriansAsync(
                    session, formworkId, poiAction, wp.X, spawnY, wp.Z, facing);

                if (ok && ids.Length > 0)
                {
                    _activeCrowd[ids[0]] = new ActiveCrowdNpc
                    {
                        EntityId = ids[0],
                        FormworkId = formworkId,
                        X = wp.X,
                        Y = spawnY,
                        Z = wp.Z,
                        SpawnedAt = DateTime.UtcNow
                    };
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
