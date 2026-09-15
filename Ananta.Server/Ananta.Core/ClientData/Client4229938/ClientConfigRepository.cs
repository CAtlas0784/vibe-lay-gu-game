using System.Text.Json;
using Ananta.Server.Configuration;
using Ananta.Server.Protocol.Client4229938;
using Ananta.Server.RpcTypes.Client4229938;

namespace Ananta.Server.ClientData.Client4229938;

/// <summary>
/// Reads authored client data directly from the extracted JSON configuration files.
///
/// There is no generated character/switch catalog in the source tree. If you need to understand
/// why a character or animation is available, inspect FightSpiritConfig.json /
/// SwitchSpiritConfig.json in the configured client-data directory.
/// </summary>
internal static class ClientConfigRepository
{
    // This exact 4229938 client/VFS capture fails to resolve the streaming animation hashes for
    // these generic switch timelines. Prefer another authored row when available; do not globally
    // disable streaming animation for every cutscene.
    private static readonly HashSet<string> KnownBrokenLocalStreamingSwitchTimelines4229938 = new(StringComparer.Ordinal)
    {
        "SwitchChar_common_09",
        "SwitchChar_common_14",
    };

    private static ClientData Data => Cache.Value;

    internal static IReadOnlyList<CharacterCatalogEntry> Characters() => Data.Characters;

    internal static IReadOnlyList<uint> UnlockSystemIds() => Data.UnlockSystemIds;

    internal static IReadOnlyList<uint> InstalledPhoneAppIds() => Data.InstalledPhoneAppIds;

    internal static IReadOnlyList<uint> SelectableFashionIds() => Data.SelectableFashionIds;

    internal static IReadOnlyList<uint> DefaultFashionIds(uint templateId)
        => Data.DefaultFashionIdsBySpirit.TryGetValue(templateId, out var ids) ? ids : Array.Empty<uint>();

    internal static (Vec3 Position, float Facing) EntryPlacement(uint switchShowId)
        => Data.SwitchRows.TryGetValue(switchShowId, out var row)
            ? (row.Position, row.Facing)
            : (Profile.WorldSpawn, Profile.WorldFacing);

    internal static IReadOnlyList<uint> SwitchAnimations(uint templateId)
        => Data.SwitchIdsBySpirit.TryGetValue(templateId, out var ids) ? ids : Data.CommonSwitchIds;

    internal static IReadOnlyList<uint> EntryAnimations(uint templateId)
        => Data.EntryIdsBySpirit.TryGetValue(templateId, out var ids) ? ids : Data.CommonEntryIds;

    internal static uint RandomEntryAnimation(uint templateId)
    {
        var ids = EntryAnimations(templateId);
        if (ids.Count == 0)
            throw new InvalidOperationException($"No world-entry animations for spirit {templateId} in SwitchSpiritConfig.json.");

        // Entry presentation must agree with the configured world spawn. Prefer the nearest authored
        // row that does not require external agents and whose streaming animation is present in this
        // 4229938 client capture. This replaces the old random cross-map entry selection.
        var candidates = ids
            .Where(id => Data.SwitchRows.ContainsKey(id))
            .Select(id => Data.SwitchRows[id])
            .Where(row => row.AgentIds.Count == 0)
            .Where(row => !KnownBrokenLocalStreamingSwitchTimelines4229938.Contains(row.Timeline))
            .Select(row =>
            {
                var dx = (double)row.Position.X - Profile.WorldSpawn.X;
                var dz = (double)row.Position.Z - Profile.WorldSpawn.Z;
                return new { row.Id, Distance = Math.Sqrt(dx * dx + dz * dz), row.Weight };
            })
            .OrderBy(x => x.Distance)
            .ThenByDescending(x => x.Weight)
            .ThenBy(x => x.Id)
            .ToArray();

        return candidates.Length > 0 ? candidates[0].Id : ids[0];
    }

    internal static SwitchAnimationChoice RandomSwitchAnimation(uint templateId, uint previousSwitchShowId, Vec3 position)
    {
        var ids = SwitchAnimations(templateId);
        if (ids.Count == 0)
            throw new InvalidOperationException($"No SwitchSpiritConfig animations for spirit {templateId}.");

        // Generic server switching cannot satisfy authored companion-agent rows. Those rows carry
        // AgentId entries that stock SwitchTeleport expects the server to spawn before landing.
        var candidateRows = ids
            .Where(id => Data.SwitchRows.ContainsKey(id))
            .Select(id => Data.SwitchRows[id])
            .Where(row => row.AgentIds.Count == 0)
            .ToArray();

        var preferredRows = candidateRows
            .Where(row => !KnownBrokenLocalStreamingSwitchTimelines4229938.Contains(row.Timeline))
            .ToArray();
        if (preferredRows.Length == 0)
            preferredRows = candidateRows;

        var usableRows = preferredRows
            .Select(row =>
            {
                var dx = (double)row.Position.X - position.X;
                var dz = (double)row.Position.Z - position.Z;
                return new SwitchAnimationCandidate(
                    row.Id,
                    row.Timeline,
                    row.Weight > 0f && float.IsFinite(row.Weight) ? row.Weight : 1f,
                    Math.Sqrt(dx * dx + dz * dz));
            })
            .OrderBy(x => x.AnchorDistance)
            .ThenByDescending(x => x.Weight)
            .ThenBy(x => x.Id)
            .ToArray();
        if (usableRows.Length == 0)
            throw new InvalidOperationException($"No usable SwitchSpiritConfig rows for spirit {templateId}.");

        string? previousTimeline = null;
        if (previousSwitchShowId != 0 && Data.SwitchRows.TryGetValue(previousSwitchShowId, out var previousRow))
            previousTimeline = previousRow.Timeline;

        // SwitchSpiritConfig rows are spatially authored. Randomly choosing a timeline first can bind a
        // current position to an animation whose authored anchor is kilometers away. Pick the nearest
        // compatible row; only avoid an immediate timeline repeat when an almost-equally-near alternative
        // exists, so anti-repeat never wins over spatial validity.
        var selected = usableRows[0];
        if (PrivateServerConfigStore.Current.Gameplay.SwitchAnimations.AvoidImmediateRepeat &&
            previousTimeline is not null)
        {
            var maxAlternativeDistance = selected.AnchorDistance + 150d;
            var alternative = usableRows.FirstOrDefault(x =>
                x.AnchorDistance <= maxAlternativeDistance &&
                !string.Equals(x.Timeline, previousTimeline, StringComparison.Ordinal));
            if (alternative is not null)
                selected = alternative;
        }

        return new SwitchAnimationChoice(
            selected.Id,
            selected.Timeline,
            selected.Weight,
            (float)selected.AnchorDistance,
            usableRows.Select(x => x.Timeline).Distinct(StringComparer.Ordinal).Count(),
            usableRows.Length,
            previousTimeline);
    }

    private static readonly Lazy<ClientData> Cache = new(Load);

    private static ClientData Load()
    {
        var cfg = PrivateServerConfigStore.Current;
        var root = PrivateServerConfigStore.ResolveProjectPath(cfg.Paths.ClientConfigs);

        var fightSpirits = ReadRecords(Path.Combine(root, "FightSpiritConfig.json"));
        var switches = ReadRecords(Path.Combine(root, "SwitchSpiritConfig.json"));
        var unlockSystems = ReadRecords(Path.Combine(root, "SystemUnlockConfig.json"));
        var fashions = ReadRecords(Path.Combine(root, "FashionConfig.json"));
        var mobileApps = ReadRecords(Path.Combine(root, "MobileMenuSGuiConfig.json"));
        var roster = cfg.Content.Roster;
        var excluded = roster.ExcludedTemplateIds.ToHashSet();

        var characters = fightSpirits
            .Select(ParseCharacterSource)
            .Where(x => x.HasValue)
            .Select(x => x.GetValueOrDefault())
            .Where(x => x.TemplateId >= roster.TemplateIdMin && x.TemplateId < roster.TemplateIdMaxExclusive)
            .Where(x => !excluded.Contains(x.TemplateId))
            .Where(x => x.IconId > 0 && x.IconId != roster.GenericPlaceholderIconId)
            .OrderBy(x => x.TemplateId)
            .Select((x, index) => new CharacterCatalogEntry(
                x.TemplateId,
                roster.UnitIdBase + (ulong)index,
                x.Name,
                x.IconId))
            .ToArray();

        if (characters.Length == 0)
            throw new InvalidDataException("FightSpiritConfig.json produced an empty playable roster.");
        if (characters[0].TemplateId != cfg.Player.InitialSpiritTemplateId)
            throw new InvalidDataException(
                $"Playable roster begins with {characters[0].TemplateId}, expected initial spirit {cfg.Player.InitialSpiritTemplateId}.");

        var switchRows = switches
            .Select(ParseSwitchRow)
            .Where(x => x is not null)
            .Select(x => x!)
            .Where(x => x.SwitchType == cfg.Gameplay.SwitchAnimations.SwitchType)
            .Where(x => x.RaidId == cfg.World.RaidId)
            .Where(x => !x.Invalid && x.Weight > 0f && !string.IsNullOrWhiteSpace(x.Timeline))
            .ToDictionary(x => x.Id);

        if (switchRows.Count == 0)
            throw new InvalidDataException("SwitchSpiritConfig.json has no usable rows for the configured raid/switch type.");

        uint[] IdsFor(uint templateId, bool entryOnly)
        {
            var prefix = cfg.Gameplay.SwitchAnimations.CommonTimelinePrefix;
            var rows = switchRows.Values.Where(x => !entryOnly || !x.LoginInvalid);
            var common = rows.Where(x =>
                x.Timeline.StartsWith(prefix, StringComparison.Ordinal) &&
                !x.ForbidFightSpiritIds.Contains(templateId) &&
                (x.FightSpiritIds.Count == 0 && x.FirstSwitchSpiritIds.Count == 0 ||
                 x.FightSpiritIds.Contains(templateId) || x.FirstSwitchSpiritIds.Contains(templateId)));
            var unique = rows.Where(x =>
                !x.Timeline.StartsWith(prefix, StringComparison.Ordinal) &&
                (x.FightSpiritIds.Contains(templateId) || x.FirstSwitchSpiritIds.Contains(templateId)));
            return common.Concat(unique).Select(x => x.Id).Distinct().ToArray();
        }

        var switchIdsBySpirit = characters.ToDictionary(x => x.TemplateId, x => IdsFor(x.TemplateId, false));
        var entryIdsBySpirit = characters.ToDictionary(x => x.TemplateId, x => IdsFor(x.TemplateId, true));
        foreach (var character in characters)
        {
            if (switchIdsBySpirit[character.TemplateId].Length == 0)
                throw new InvalidDataException($"No switch animations for character {character.TemplateId} ({character.Name}).");
        }

        var commonSwitchIds = switchRows.Values
            .Where(x => x.Timeline.StartsWith(cfg.Gameplay.SwitchAnimations.CommonTimelinePrefix, StringComparison.Ordinal))
            .Select(x => x.Id).ToArray();
        var commonEntryIds = switchRows.Values
            .Where(x => !x.LoginInvalid && x.Timeline.StartsWith(cfg.Gameplay.SwitchAnimations.CommonTimelinePrefix, StringComparison.Ordinal))
            .Select(x => x.Id).ToArray();

        var excludedUnlocks = cfg.Content.ExcludedUnlockSystems.ToHashSet();
        var unlockSystemIds = unlockSystems
            .Select(x => TryUInt32(x, "Id", out var id) ? id : 0u)
            .Where(id => id != 0 && !excludedUnlocks.Contains(id))
            .Distinct()
            .OrderBy(id => id)
            .ToArray();

        var installedPhoneAppIds = mobileApps
            .Where(x => cfg.Content.IncludePhoneBottomApps || !TryBool(x, "IsBottom"))
            .Select(x => TryUInt32(x, "Id", out var id) ? id : 0u)
            .Where(id => id != 0)
            .Distinct()
            .OrderBy(id => id)
            .ToArray();

        var selectableFashionIds = fashions
            .Select(x => TryUInt32(x, "Id", out var id) ? id : 0u)
            .Where(id => id != 0)
            .Distinct()
            .OrderBy(id => id)
            .ToArray();

        var defaultFashionIdsBySpirit = fashions
            .Where(x => TryBool(x, "IsDefault"))
            .Select(x => new
            {
                FashionId = TryUInt32(x, "Id", out var fashionId) ? fashionId : 0u,
                SpiritId = TryUInt32(x, "BelongSpiritId", out var spiritId) ? spiritId : 0u,
            })
            .Where(x => x.FashionId != 0 && x.SpiritId != 0)
            .GroupBy(x => x.SpiritId)
            .ToDictionary(g => g.Key, g => g.Select(x => x.FashionId).Distinct().OrderBy(id => id).ToArray());

        Console.WriteLine(
            $"[CLIENT-CONFIG] build={cfg.Client.Version} characters={characters.Length} switchRows={switchRows.Count} " +
            $"source={root}");

        return new ClientData(
            characters, switchRows, switchIdsBySpirit, entryIdsBySpirit, commonSwitchIds, commonEntryIds,
            unlockSystemIds, installedPhoneAppIds, selectableFashionIds, defaultFashionIdsBySpirit);
    }

    private static JsonElement[] ReadRecords(string path)
    {
        if (!File.Exists(path))
            throw new FileNotFoundException($"Required client config is missing: {path}");
        using var doc = JsonDocument.Parse(File.ReadAllText(path));
        if (!doc.RootElement.TryGetProperty("records", out var records) || records.ValueKind != JsonValueKind.Array)
            throw new InvalidDataException($"Client config does not contain a 'records' array: {path}");
        return records.EnumerateArray().Select(x => x.Clone()).ToArray();
    }

    private static CharacterSource? ParseCharacterSource(JsonElement value)
    {
        if (!TryUInt32(value, "Id", out var id)) return null;
        var name = TryString(value, "Name") ?? string.Empty;
        TryUInt32(value, "SHeadIconID", out var iconId);
        return new CharacterSource(id, name, iconId);
    }

    private static SwitchRow? ParseSwitchRow(JsonElement value)
    {
        if (!TryUInt32(value, "Id", out var id)) return null;
        var timeline = TryString(value, "TimeLine") ?? string.Empty;
        TryInt32(value, "SwitchType", out var switchType);
        TryUInt32(value, "RaidId", out var raidId);
        TrySingle(value, "Weight", out var weight);
        var invalid = TryBool(value, "Invalid");
        var loginInvalid = TryBool(value, "LoginInvalid");
        var position = ReadPosition(value, "Position", Profile.WorldSpawn);
        var facing = TrySingle(value, "TimeLineAngleY", out var angle) ? angle : Profile.WorldFacing;
        return new SwitchRow(
            id, timeline, weight, switchType, raidId, invalid, loginInvalid, position, facing,
            ReadUInt32Array(value, "FightSpiritId"),
            ReadUInt32Array(value, "FirstSwitchSpiritId"),
            ReadUInt32Array(value, "ForbidFightSpiritId"),
            ReadUInt32Array(value, "AgentId"));
    }

    private static Vec3 ReadPosition(JsonElement value, string name, Vec3 fallback)
    {
        if (!value.TryGetProperty(name, out var item) || item.ValueKind != JsonValueKind.Array)
            return fallback;
        var values = item.EnumerateArray().Take(3).Select(x => x.TryGetSingle(out var n) ? n : float.NaN).ToArray();
        return values.Length == 3 && values.All(float.IsFinite) ? new Vec3(values[0], values[1], values[2]) : fallback;
    }

    private static HashSet<uint> ReadUInt32Array(JsonElement value, string name)
    {
        if (!value.TryGetProperty(name, out var item) || item.ValueKind != JsonValueKind.Array)
            return new HashSet<uint>();
        return item.EnumerateArray().Where(x => x.TryGetUInt32(out _)).Select(x => x.GetUInt32()).ToHashSet();
    }

    private static bool TryUInt32(JsonElement value, string name, out uint result)
    {
        result = default;
        return value.TryGetProperty(name, out var item) && item.TryGetUInt32(out result);
    }

    private static bool TryInt32(JsonElement value, string name, out int result)
    {
        result = default;
        return value.TryGetProperty(name, out var item) && item.TryGetInt32(out result);
    }

    private static bool TrySingle(JsonElement value, string name, out float result)
    {
        result = default;
        return value.TryGetProperty(name, out var item) && item.TryGetSingle(out result);
    }
    private static string? TryString(JsonElement value, string name)
        => value.TryGetProperty(name, out var item) && item.ValueKind == JsonValueKind.String ? item.GetString() : null;
    private static bool TryBool(JsonElement value, string name)
    {
        if (!value.TryGetProperty(name, out var item)) return false;
        return item.ValueKind switch
        {
            JsonValueKind.True => true,
            JsonValueKind.False => false,
            _ => false,
        };
    }

    private sealed record ClientData(
        CharacterCatalogEntry[] Characters,
        Dictionary<uint, SwitchRow> SwitchRows,
        Dictionary<uint, uint[]> SwitchIdsBySpirit,
        Dictionary<uint, uint[]> EntryIdsBySpirit,
        uint[] CommonSwitchIds,
        uint[] CommonEntryIds,
        uint[] UnlockSystemIds,
        uint[] InstalledPhoneAppIds,
        uint[] SelectableFashionIds,
        Dictionary<uint, uint[]> DefaultFashionIdsBySpirit);

    private readonly record struct CharacterSource(uint TemplateId, string Name, uint IconId);
    private sealed record SwitchRow(
        uint Id,
        string Timeline,
        float Weight,
        int SwitchType,
        uint RaidId,
        bool Invalid,
        bool LoginInvalid,
        Vec3 Position,
        float Facing,
        HashSet<uint> FightSpiritIds,
        HashSet<uint> FirstSwitchSpiritIds,
        HashSet<uint> ForbidFightSpiritIds,
        HashSet<uint> AgentIds);
    private sealed record SwitchAnimationCandidate(uint Id, string Timeline, float Weight, double AnchorDistance);
}

internal sealed record CharacterCatalogEntry(uint TemplateId, ulong UnitId, string Name, uint IconId);
internal sealed record SwitchAnimationChoice(
    uint Id, string Timeline, float Weight, float AnchorDistance, int TimelinePool, int RowPool, string? PreviousTimeline);
