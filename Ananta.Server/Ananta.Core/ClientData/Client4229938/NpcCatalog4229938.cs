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
    uint InteractSettingId,
    uint Camp = 0,
    string Category = "citizen");

internal static class NpcCatalog4229938
{
    private static readonly Lazy<Dictionary<uint, NpcCatalogEntry4229938>> Cache = new(Load);

    internal static bool TryGet(uint id, out NpcCatalogEntry4229938 entry)
        => Cache.Value.TryGetValue(id, out entry!);

    internal static IReadOnlyCollection<NpcCatalogEntry4229938> All => Cache.Value.Values;

    internal static List<NpcCatalogEntry4229938> Search(string? query, string? category, int limit = 150)
    {
        var q = query?.Trim();
        var cat = category?.Trim().ToLowerInvariant();
        var hasQuery = !string.IsNullOrWhiteSpace(q);
        var hasCat = !string.IsNullOrWhiteSpace(cat) && cat != "all";

        uint queryId = 0;
        if (hasQuery) uint.TryParse(q, out queryId);

        var list = new List<NpcCatalogEntry4229938>();
        foreach (var entry in Cache.Value.Values)
        {
            if (hasCat && !string.Equals(entry.Category, cat, StringComparison.OrdinalIgnoreCase))
                continue;

            if (hasQuery)
            {
                if (queryId != 0 && entry.Id == queryId)
                {
                    list.Add(entry);
                    if (list.Count >= limit) break;
                    continue;
                }
                if (!entry.Name.Contains(q!, StringComparison.OrdinalIgnoreCase) &&
                    !entry.Id.ToString().Contains(q!))
                    continue;
            }

            list.Add(entry);
            if (list.Count >= limit) break;
        }
        return list;
    }

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

            var camp = UInt32(row, "Camp");
            var enemyClass = UInt32(row, "EnemyClassType");
            var isAnimal = (row.TryGetProperty("AnimalGamePlay", out var ag) && ag.ValueKind == JsonValueKind.True) ||
                           name.Contains("鸭") || name.Contains("电台") || name.Contains("猫") || name.Contains("鸽") || name.Contains("鸟") || name.Contains("犬");
            string category;
            if (isAnimal || camp == 11)
                category = "animal";
            else if (camp is 0 or 26 || enemyClass > 0 || name.Contains("帮") || name.Contains("怪") || name.Contains("Boss") || name.Contains("哨兵") || name.Contains("斗士") || name.Contains("无赖") || name.Contains("狂飙") || name.Contains("狂战士") || name.Contains("史莱姆"))
                category = "monster";
            else if (camp is 16 or 17 or 18 or 19 or 24 || name.Contains("警") || name.Contains("守卫") || name.Contains("保镖") || name.Contains("巡卫") || name.Contains("安保"))
                category = "police";
            else if (camp == 1 || name.Contains("Seymour") || name.Contains("Taffy") || name.Contains("Bansy") || name.Contains("Garm") || name.Contains("Rin") || name.Contains("HotDog"))
                category = "ally";
            else
                category = "citizen";

            result[id] = new(id, name, model, persona, animSetTag,
                UInt32(row, "Action"), UInt32(row, "ActionGroupId"),
                UInt32(row, "AI"), UInt32(row, "InteractSetting"),
                camp, category);
        }
        return result;
    }
}
