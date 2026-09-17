using System.Text.Json;
using Ananta.Server.Configuration;

namespace Ananta.Server.ClientData.Client4229938;

internal sealed record PoiActionCatalogEntry4229938(uint Id, uint MainActionGroup, uint[] MainActions)
{
    internal uint UsageId { get; init; }
    internal uint[] BelongingSceneItems { get; init; } = [];
    internal uint SelectMainAction(ulong entityId)
        => MainActions.Length == 0 ? 0 : MainActions[(int)(entityId % (ulong)MainActions.Length)];
}

internal static class PoiActionCatalog4229938
{
    private static readonly Lazy<Dictionary<uint, PoiActionCatalogEntry4229938>> Cache = new(Load);

    internal static bool TryGet(uint id, out PoiActionCatalogEntry4229938 entry)
        => Cache.Value.TryGetValue(id, out entry!);

    private static Dictionary<uint, PoiActionCatalogEntry4229938> Load()
    {
        var root = PrivateServerConfigStore.ResolveProjectPath(PrivateServerConfigStore.Current.Paths.ClientConfigs);
        var path = Path.Combine(root, "UrbanDiversityPOIActionConfig.json");
        using var doc = JsonDocument.Parse(File.ReadAllText(path));
        if (!doc.RootElement.TryGetProperty("records", out var records) || records.ValueKind != JsonValueKind.Array)
            throw new InvalidDataException($"UrbanDiversityPOIActionConfig does not contain records: {path}");

        var result = new Dictionary<uint, PoiActionCatalogEntry4229938>();
        using var usagesDoc = JsonDocument.Parse(File.ReadAllText(Path.Combine(root, "BelongingBelongingUsageConfig.json")));
        var usages = usagesDoc.RootElement.GetProperty("records").EnumerateArray()
            .ToDictionary(row => row.GetProperty("Id").GetUInt32());
        foreach (var row in records.EnumerateArray())
        {
            if (!row.TryGetProperty("Id", out var idNode) || !idNode.TryGetUInt32(out var id) || id == 0)
                continue;
            var actionGroup = row.TryGetProperty("MainActionGroup", out var groupNode) && groupNode.TryGetUInt32(out var group)
                ? group
                : 0;
            var actions = row.TryGetProperty("MainActions", out var actionsNode) && actionsNode.ValueKind == JsonValueKind.Array
                ? actionsNode.EnumerateArray()
                    .Select(node => node.TryGetUInt32(out var action) ? action : 0)
                    .Where(action => action != 0)
                    .ToArray()
                : [];
            var usageId = row.TryGetProperty("UsageId", out var usageNode) ? usageNode.GetUInt32() : 0;
            uint[] belongingItems = [];
            if (usageId != 0)
            {
                if (!usages.TryGetValue(usageId, out var usage))
                    throw new InvalidDataException($"POI {id} refers to missing belonging usage {usageId}");
                belongingItems = usage.GetProperty("BelongingSceneItem").EnumerateArray()
                    .Select(node => node.GetUInt32()).Where(item => item != 0).Distinct().ToArray();
                // Type-based usages choose from the NPC's inventory. For standalone
                // admin NPCs, seed the usage's configured representative item.
                if (belongingItems.Length == 0 && usage.GetProperty("BelongingType").GetArrayLength() != 0)
                {
                    var slotItem = usage.GetProperty("SlotSceneItem").GetUInt32();
                    if (slotItem != 0) belongingItems = [slotItem];
                }
            }
            result[id] = new(id, actionGroup, actions) { UsageId = usageId, BelongingSceneItems = belongingItems };
        }
        return result;
    }
}
