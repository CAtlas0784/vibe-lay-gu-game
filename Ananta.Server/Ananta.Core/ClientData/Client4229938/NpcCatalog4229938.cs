using System.Text.Json;
using Ananta.Server.Configuration;

namespace Ananta.Server.ClientData.Client4229938;

internal sealed record NpcCatalogEntry4229938(
    uint Id,
    string Name,
    uint GeneralModelId,
    uint AgentPersonaId,
    uint AnimSetTag,
    uint BehaviorActionConfigId,
    uint ActionGroupId,
    uint AiSettingId,
    uint InteractSettingId);

internal static class NpcCatalog4229938
{
    private static readonly Lazy<Dictionary<uint, NpcCatalogEntry4229938>> Cache = new(Load);

    internal static bool TryGet(uint id, out NpcCatalogEntry4229938 entry)
        => Cache.Value.TryGetValue(id, out entry!);

    private static Dictionary<uint, NpcCatalogEntry4229938> Load()
    {
        var root = PrivateServerConfigStore.ResolveProjectPath(PrivateServerConfigStore.Current.Paths.ClientConfigs);
        var path = Path.Combine(root, "AgentConfig.json");
        using var doc = JsonDocument.Parse(File.ReadAllText(path));
        if (!doc.RootElement.TryGetProperty("records", out var records) || records.ValueKind != JsonValueKind.Array)
            throw new InvalidDataException($"AgentConfig does not contain records: {path}");
        var result = new Dictionary<uint, NpcCatalogEntry4229938>();
        foreach (var row in records.EnumerateArray())
        {
            if (!row.TryGetProperty("Id", out var idNode) || !idNode.TryGetUInt32(out var id) || id == 0)
                continue;
            var name = row.TryGetProperty("Name", out var n) && n.ValueKind == JsonValueKind.String ? n.GetString() ?? "" : "";
            var model = row.TryGetProperty("GeneralModelId", out var m) && m.TryGetUInt32(out var modelId) ? modelId : 0;
            static uint UInt32(JsonElement source, string propertyName)
                => source.TryGetProperty(propertyName, out var node) && node.TryGetUInt32(out var value) ? value : 0;

            var sex = UInt32(row, "SexType");
            var age = UInt32(row, "Age");
            var economicLevel = UInt32(row, "EconomicLevel");
            var refined = economicLevel >= 3;
            var persona = (sex, age >= 45, refined) switch
            {
                (1, false, false) when age < 18 => 45200003u,
                (2, false, false) when age < 18 => 45200004u,
                (1, false, false) => 45200007u,
                (2, false, false) => 45200008u,
                (1, false, true) => 45200009u,
                (2, false, true) => 45200010u,
                (1, true, false) => 45200011u,
                (2, true, false) => 45200012u,
                (1, true, true) => 45200013u,
                (2, true, true) => 45200014u,
                _ => 0u,
            };
            var animSetTag = UInt32(row, "AnimStereotype");
            if (animSetTag == 0)
                animSetTag = UInt32(row, "BattleAnimType");
            result[id] = new(id, name, model, persona, animSetTag,
                UInt32(row, "Action"), UInt32(row, "ActionGroupId"),
                UInt32(row, "AI"), UInt32(row, "InteractSetting"));
        }
        return result;
    }
}
