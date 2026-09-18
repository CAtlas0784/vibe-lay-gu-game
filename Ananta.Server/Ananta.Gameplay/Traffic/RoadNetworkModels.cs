using System.Text.Json.Serialization;
using Ananta.SDK.Network;
using Ananta.Server.RpcTypes.Client4229938;

namespace Ananta.Server.Gameplay.Traffic;

public sealed class TrafficSignalFile
{
    [JsonPropertyName("lights")]
    public List<TrafficLightEntry> Lights { get; set; } = [];
}

public sealed class TrafficLightEntry
{
    [JsonPropertyName("handle")]
    public long Handle { get; set; }

    [JsonPropertyName("inter")]
    public int Inter { get; set; }

    [JsonPropertyName("zbr")]
    public int Zbr { get; set; }

    [JsonPropertyName("pos")]
    public List<float> Pos { get; set; } = [];

    [JsonPropertyName("fwd")]
    public List<float> Fwd { get; set; } = [];
}

public sealed class RoadNetworkFile
{
    [JsonPropertyName("metadata")]
    public RoadMetadata Metadata { get; set; } = new();

    [JsonPropertyName("spatialGrid")]
    public Dictionary<string, List<int>> SpatialGrid { get; set; } = new();

    [JsonPropertyName("lanes")]
    public List<RoadLaneData> Lanes { get; set; } = [];
}

public sealed class RoadMetadata
{
    [JsonPropertyName("totalLanes")]
    public int TotalLanes { get; set; }

    [JsonPropertyName("gridSize")]
    public float GridSize { get; set; } = 100f;

    [JsonPropertyName("totalGridCells")]
    public int TotalGridCells { get; set; }
}

public sealed class RoadLaneData
{
    [JsonPropertyName("id")]
    public int Id { get; set; }

    [JsonPropertyName("region")]
    public string Region { get; set; } = string.Empty;

    [JsonPropertyName("width")]
    public float Width { get; set; }

    [JsonPropertyName("speed")]
    public float Speed { get; set; }

    [JsonPropertyName("turn")]
    public string Turn { get; set; } = "Straight";

    [JsonPropertyName("tags")]
    public List<string> Tags { get; set; } = [];

    [JsonPropertyName("pts")]
    public List<List<float>> Pts { get; set; } = [];

    [JsonPropertyName("tangents")]
    public List<List<float>> Tangents { get; set; } = [];

    [JsonPropertyName("next")]
    public List<int> Next { get; set; } = [];

    [JsonPropertyName("adj")]
    public List<int> Adj { get; set; } = [];

    [JsonPropertyName("bbox")]
    public List<float> Bbox { get; set; } = [];

    // Pre-calculated runtime fields
    [JsonIgnore]
    public float TotalLength { get; private set; }

    [JsonIgnore]
    public float[] SegmentLengths { get; private set; } = [];

    [JsonIgnore]
    public float[] CumulativeDistances { get; private set; } = [];

    public void Precompute()
    {
        if (Pts.Count < 2)
        {
            TotalLength = 0f;
            SegmentLengths = [];
            CumulativeDistances = [0f];
            return;
        }

        SegmentLengths = new float[Pts.Count - 1];
        CumulativeDistances = new float[Pts.Count];
        CumulativeDistances[0] = 0f;
        float total = 0f;

        for (var i = 0; i < Pts.Count - 1; i++)
        {
            var p1 = Pts[i];
            var p2 = Pts[i + 1];
            var dx = p2[0] - p1[0];
            var dy = p2[1] - p1[1];
            var dz = p2[2] - p1[2];
            var segLen = MathF.Sqrt(dx * dx + dy * dy + dz * dz);
            SegmentLengths[i] = segLen;
            total += segLen;
            CumulativeDistances[i + 1] = total;
        }

        TotalLength = total;
    }

    public (float X, float Y, float Z, float Yaw, float Vx, float Vz) Evaluate(float distance, float speed)
    {
        if (Pts.Count == 0)
            return (0, 0, 0, 0, 0, 0);

        if (Pts.Count == 1 || distance <= 0f)
        {
            var p = Pts[0];
            var yaw = 0f;
            if (Tangents.Count > 0 && Tangents[0].Count >= 3)
                yaw = MathF.Atan2(Tangents[0][0], Tangents[0][2]) * (180f / MathF.PI);
            var vx = MathF.Sin(yaw * (MathF.PI / 180f)) * speed;
            var vz = MathF.Cos(yaw * (MathF.PI / 180f)) * speed;
            return (p[0], p[1], p[2], yaw, vx, vz);
        }

        if (distance >= TotalLength)
        {
            var p = Pts[^1];
            var yaw = 0f;
            if (Tangents.Count > 0 && Tangents[^1].Count >= 3)
                yaw = MathF.Atan2(Tangents[^1][0], Tangents[^1][2]) * (180f / MathF.PI);
            var vx = MathF.Sin(yaw * (MathF.PI / 180f)) * speed;
            var vz = MathF.Cos(yaw * (MathF.PI / 180f)) * speed;
            return (p[0], p[1], p[2], yaw, vx, vz);
        }

        // Binary search or linear search for segment
        var segIdx = 0;
        for (var i = 0; i < SegmentLengths.Length; i++)
        {
            if (distance <= CumulativeDistances[i + 1])
            {
                segIdx = i;
                break;
            }
        }

        var pA = Pts[segIdx];
        var pB = Pts[segIdx + 1];
        var segStart = CumulativeDistances[segIdx];
        var segLen = SegmentLengths[segIdx];
        var t = segLen > 0.001f ? (distance - segStart) / segLen : 0f;
        t = Math.Clamp(t, 0f, 1f);

        var x = pA[0] + (pB[0] - pA[0]) * t;
        var y = pA[1] + (pB[1] - pA[1]) * t;
        var z = pA[2] + (pB[2] - pA[2]) * t;

        // Yaw from segment direction
        var dx = pB[0] - pA[0];
        var dz = pB[2] - pA[2];
        var yawDeg = MathF.Atan2(dx, dz) * (180f / MathF.PI);

        var rad = yawDeg * (MathF.PI / 180f);
        var vX = MathF.Sin(rad) * speed;
        var vZ = MathF.Cos(rad) * speed;

        return (x, y, z, yawDeg, vX, vZ);
    }
}
