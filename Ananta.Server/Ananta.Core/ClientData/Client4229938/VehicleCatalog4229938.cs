using System.Text.Json;
using Ananta.Server.Configuration;

namespace Ananta.Server.ClientData.Client4229938;

internal sealed record VehicleCatalogEntry4229938(uint Id, string Name, string Model, int SeatCount, string SpoonName);

/// <summary>
/// Build-4229938 vehicle catalog, read from VehicleConfig.json in the configured
/// client-data directory (field names verified against ConfigDump_v3 + lua writers).
/// </summary>
internal static class VehicleCatalog4229938
{
    private static readonly Lazy<Dictionary<uint, VehicleCatalogEntry4229938>> Cache = new(Load);

    internal static bool TryGet(uint id, out VehicleCatalogEntry4229938 entry)
        => Cache.Value.TryGetValue(id, out entry!);

    /// <summary>Every build-local vehicle that can be materialized (prefab + 1..16 seats).</summary>
    internal static IReadOnlyList<VehicleCatalogEntry4229938> AllSummonable => Cache.Value.Values
        .Where(v => !string.IsNullOrWhiteSpace(v.Model) && v.SeatCount is >= 1 and <= 16)
        .OrderBy(v => v.Id)
        .ToArray();

    private static Dictionary<uint, VehicleCatalogEntry4229938> Load()
    {
        var root = PrivateServerConfigStore.ResolveProjectPath(PrivateServerConfigStore.Current.Paths.ClientConfigs);
        var path = Path.Combine(root, "VehicleConfig.json");
        using var doc = JsonDocument.Parse(File.ReadAllText(path));
        if (!doc.RootElement.TryGetProperty("records", out var records) || records.ValueKind != JsonValueKind.Array)
            throw new InvalidDataException($"VehicleConfig does not contain records: {path}");
        var result = new Dictionary<uint, VehicleCatalogEntry4229938>();
        foreach (var row in records.EnumerateArray())
        {
            if (!row.TryGetProperty("Id", out var idNode) || !idNode.TryGetUInt32(out var id) || id == 0)
                continue;
            static string Str(JsonElement row, string name)
                => row.TryGetProperty(name, out var n) && n.ValueKind == JsonValueKind.String ? n.GetString() ?? string.Empty : string.Empty;
            var seats = row.TryGetProperty("VehicleSeatNum", out var s) && s.TryGetInt32(out var seatCount) ? seatCount : 0;
            result[id] = new VehicleCatalogEntry4229938(id, Str(row, "VehicleName"), Str(row, "GeneralModel"), seats, Str(row, "VehicleSpoonName"));
        }
        return result;
    }
}
