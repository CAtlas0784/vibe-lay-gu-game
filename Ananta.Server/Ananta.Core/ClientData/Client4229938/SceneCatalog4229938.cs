using System.Text.Json;
using Ananta.Server.Configuration;

namespace Ananta.Server.ClientData.Client4229938;

internal sealed record ScenePresetEntry4229938(
    string Key, string Label, uint RaidId, ulong InstanceId, uint UniverseId,
    float X, float Y, float Z, float Facing);

/// <summary>
/// Scene ("raid") preset catalog built from the game dumps:
/// RaidConfig.json (raid → SceneId = instance id, Multiverse = universe id) and
/// MapentranceConfig.json (entrance → RaidId + Coordinate/MapTeleportPos + facing).
/// Verified: Nova raid 23300888 → scene/instance 20001222, Lingyun 23300999 → 20001223.
/// </summary>
internal static class SceneCatalog4229938
{
    private static readonly Lazy<IReadOnlyList<ScenePresetEntry4229938>> Cache = new(Load);

    internal static IReadOnlyList<ScenePresetEntry4229938> Presets => Cache.Value;

    internal static bool TryGetByRaid(uint raidId, out ScenePresetEntry4229938 preset)
    {
        foreach (var p in Cache.Value)
        {
            if (p.RaidId != raidId)
                continue;
            preset = p;
            return true;
        }
        preset = null!;
        return false;
    }

    private static IReadOnlyList<ScenePresetEntry4229938> Load()
    {
        var root = PrivateServerConfigStore.ResolveProjectPath(PrivateServerConfigStore.Current.Paths.ClientConfigs);
        var raids = LoadRecords(Path.Combine(root, "RaidConfig.json"));
        var entrances = LoadRecords(Path.Combine(root, "MapentranceConfig.json"));

        var raidById = new Dictionary<uint, JsonElement>();
        foreach (var row in raids)
        {
            if (row.TryGetProperty("Id", out var id) && id.TryGetUInt32(out var raidId) && raidId != 0)
                raidById[raidId] = row;
        }

        uint defaultUniverse;
        try { defaultUniverse = PrivateServerConfigStore.Current.World.UniverseId; }
        catch { defaultUniverse = 76000888; }

        var result = new List<ScenePresetEntry4229938>();
        foreach (var row in entrances)
        {
            if (!row.TryGetProperty("Id", out var idNode) || !idNode.TryGetUInt32(out var entranceId))
                continue;
            if (!row.TryGetProperty("RaidId", out var raidNode) || !raidNode.TryGetUInt32(out var raidId) || raidId == 0)
                continue;
            var coords = row.TryGetProperty("MapTeleportPos", out var tp) && tp.ValueKind == JsonValueKind.Array && tp.GetArrayLength() >= 3
                ? tp
                : row.TryGetProperty("Coordinate", out var c) && c.ValueKind == JsonValueKind.Array && c.GetArrayLength() >= 3 ? c : default;
            if (coords.ValueKind != JsonValueKind.Array)
                continue;
            var xyz = coords.EnumerateArray().Take(3).ToArray();
            if (xyz.Any(e => e.ValueKind != JsonValueKind.Number))
                continue;
            float x = (float)xyz[0].GetDouble(), y = (float)xyz[1].GetDouble(), z = (float)xyz[2].GetDouble();
            if (!float.IsFinite(x) || !float.IsFinite(y) || !float.IsFinite(z))
                continue;
            float facing = row.TryGetProperty("EntranceFacing", out var f) && f.ValueKind == JsonValueKind.Number
                ? (float)f.GetDouble() : 0f;

            ulong instanceId = 0;
            uint universeId = defaultUniverse;
            if (raidById.TryGetValue(raidId, out var raid))
            {
                if (raid.TryGetProperty("SceneId", out var s) && s.TryGetUInt64(out var sceneId) && sceneId != 0)
                    instanceId = sceneId;
                if (raid.TryGetProperty("Multiverse", out var m) && m.TryGetUInt32(out var multi) && multi != 0)
                    universeId = multi;
            }
            if (instanceId == 0)
                continue;

            var name = row.TryGetProperty("Name", out var n) && n.ValueKind == JsonValueKind.String
                ? n.GetString() ?? string.Empty : string.Empty;
            if (string.IsNullOrWhiteSpace(name))
                name = $"Entrance {entranceId}";
            result.Add(new ScenePresetEntry4229938(
                $"entrance-{entranceId}", $"{name} (raid {raidId})",
                raidId, instanceId, universeId, x, y, z, facing));
        }

        result.Sort((a, b)
            => a.RaidId != b.RaidId ? a.RaidId.CompareTo(b.RaidId) : string.Compare(a.Label, b.Label, StringComparison.Ordinal));
        return result;
    }

    private static List<JsonElement> LoadRecords(string path)
    {
        using var doc = JsonDocument.Parse(File.ReadAllText(path));
        if (!doc.RootElement.TryGetProperty("records", out var records) || records.ValueKind != JsonValueKind.Array)
            throw new InvalidDataException($"Config does not contain records: {path}");
        // Clone: the document is disposed on return.
        return records.EnumerateArray().Select(e => e.Clone()).ToList();
    }
}
