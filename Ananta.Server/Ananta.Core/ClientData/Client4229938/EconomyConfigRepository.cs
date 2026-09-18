using System.Text.Json;
using Ananta.Server.Configuration;

namespace Ananta.Server.ClientData.Client4229938;

/// <summary>
/// Client economy tables (backpack items, mall commodities, drops, gacha pools/contents/tier rules)
/// imported from the 4229938 config dump into <c>paths.clientConfigs</c>.
///
/// Unlike ClientConfigRepository these tables are optional: a missing or malformed file only disables
/// the matching feature (mall purchase / gacha draw) instead of refusing to start, because the rest of
/// the server must keep working when a dump is incomplete.
/// </summary>
internal static class EconomyConfigRepository
{
    private static readonly Lazy<Data> Cache = new(Load);

    /// <summary>Forces the (optional) tables to load so the startup log reports what was imported.</summary>
    internal static void Warmup()
        => _ = Cache.Value;

    internal static bool TryMallCommodity(uint id, out MallCommodity commodity)
        => Cache.Value.Mall.TryGetValue(id, out commodity!);

    internal static bool TryDrop(uint id, out DropRow drop)
        => Cache.Value.Drops.TryGetValue(id, out drop!);

    internal static bool TryPool(uint id, out GachaPool pool)
        => Cache.Value.Pools.TryGetValue(id, out pool!);

    internal static bool TryTierRule(uint id, out GachaTierRule rule)
        => Cache.Value.TierRules.TryGetValue(id, out rule!);

    internal static bool TryTradeItem(uint id, out TradeItem item)
        => Cache.Value.TradeItems.TryGetValue(id, out item!);

    /// <summary>
    /// Backpack items this build actually ships (<c>ConsumableConfig</c>). The client resolves a pack
    /// item's name, icon and bag page through the same table and silently drops rows it cannot find
    /// (CommonItemManager_Package.SetPackItem), so a grant has to be checked against it before it is
    /// pushed; item ids are 36xxxxxx and never overlap weapons (98xxxxxx), fashion (111xxxxx),
    /// suits (1119xxxx) or vehicles (81xxxxxx).
    /// </summary>
    internal static bool TryConsumableItem(uint id, out ConsumableItem item)
        => Cache.Value.Items.TryGetValue(id, out item!);

    /// <summary>False when the table was not imported; grants then fall back to no validation.</summary>
    internal static bool HasConsumableItems => Cache.Value.Items.Count > 0;

    internal static IReadOnlyCollection<ConsumableItem> ConsumableItems => Cache.Value.Items.Values;

    /// <summary>Id-or-name lookup for the debug panel: matches on any id digit and on a name substring.</summary>
    internal static IReadOnlyList<ConsumableItem> SearchConsumableItems(string? query, int limit)
    {
        IEnumerable<ConsumableItem> matches = Cache.Value.Items.Values;
        if (!string.IsNullOrWhiteSpace(query))
        {
            var text = query.Trim();
            matches = matches.Where(x =>
                x.Id.ToString().Contains(text, StringComparison.Ordinal) ||
                x.Name.Contains(text, StringComparison.OrdinalIgnoreCase));
        }

        return matches.OrderBy(x => x.Id).Take(limit).ToArray();
    }

    internal static IReadOnlyList<GachaContent> PoolContents(uint poolId)
        => Cache.Value.ContentsByPool.TryGetValue(poolId, out var contents) ? contents : [];

    /// <summary>
    /// Wardrobe pieces a fashion suit is made of (<c>FashionSuitConfig.FashionIdList</c>). The client
    /// answers "do I own this suit?" by asking about every piece (MallManager.CheckFashionSuitOwned),
    /// so both the shelf check and the purchase need the suit -&gt; pieces mapping.
    /// </summary>
    internal static bool TryFashionSuit(uint suitId, out uint[] fashionIds)
        => Cache.Value.FashionSuits.TryGetValue(suitId, out fashionIds!);

    /// <summary>
    /// Wardrobe pieces the direct-sale shelves stock. They have to stay locked in the login payload:
    /// their commodities are authored <c>OwnedCanNotBuy</c>, and MallManager.IsCommodityBuyable() reads
    /// that flag as "hide the button once the player owns it" - a free unlock therefore greys the row
    /// out permanently instead of selling it.
    /// </summary>
    internal static IReadOnlySet<uint> MallSoldFashionIds => Cache.Value.MallSoldFashions;

    /// <summary>Vehicle counterpart of <see cref="MallSoldFashionIds"/> (ApplyCarManager.CheckPlayerAlreadyHasVehicle).</summary>
    internal static IReadOnlySet<uint> MallSoldVehicleIds => Cache.Value.MallSoldVehicles;

    // MallCommodityConfig.Type: 0 stocks a wardrobe suit, 1 a vehicle, 2 a fashion suit that retail
    // only trades through the order book, 5/6/7 plain item rows.
    internal const uint CommodityTypeFashion4229938 = 0u;
    internal const uint CommodityTypeVehicle4229938 = 1u;

    // The direct-sale group of MallConfig (Tab.Main = 2): sub-tabs Outfits (2/1), Vehicles (2/3),
    // 14 and 15. Only these shelves are held back from the free unlock; every other tab keeps
    // shipping unlocked goods because nothing there is sold on ownership.
    private static readonly uint[] DirectSaleMallIds4229938 = [2u, 3u, 14u, 15u];

    /// <summary>One backpack item row. SubType selects the client's bag page via ConsumableTypeConfig.</summary>
    internal sealed record ConsumableItem(uint Id, string Name, uint SubType, uint Quality);

    /// <summary>One mall shelf row. Price is the list price, DiscountPrice the current charge (0 = none).</summary>
    internal sealed record MallCommodity(
        uint Id,
        uint MallId,
        uint Type,
        uint BindId,
        uint ConsumeItemId,
        double Price,
        double DiscountPrice,
        uint DropId,
        uint LimitNum,
        IReadOnlyList<uint> CommodityBindIds)
    {
        internal double UnitPrice => DiscountPrice > 0 ? DiscountPrice : Price;

        /// <summary>
        /// Suit ids the client derives ownership from: MallManager.GetCommodityBindId() picks one entry
        /// of <c>CommodityBindId</c> (index 2 for male spirits, index 1 otherwise), so the whole list has
        /// to be honoured to cover both sexes. The row's own <c>BindId</c> is deliberately left out - the
        /// client never consults it for ownership.
        /// </summary>
        internal IEnumerable<uint> OwnershipBindIds
        {
            get
            {
                foreach (var bindId in CommodityBindIds)
                {
                    if (bindId != 0)
                        yield return bindId;
                }
            }
        }
    }

    /// <summary>
    /// One drop row. <paramref name="Guaranteed"/> items are always granted, <paramref name="Ranged"/>
    /// picks one entry and a random count in [Min, Max], <paramref name="Weighted"/> picks one entry by
    /// relative weight (Item3 carries fractional weights, so they are doubles).
    /// </summary>
    internal sealed record DropRow(
        uint Id,
        double Money,
        double BindingGold,
        IReadOnlyList<(uint Id, uint Count)> Guaranteed,
        IReadOnlyList<(uint Id, uint Min, uint Max)> Ranged,
        IReadOnlyList<(uint Id, double Weight)> Weighted)
    {
        internal bool IsEmpty => Guaranteed.Count == 0 && Ranged.Count == 0 && Weighted.Count == 0
                                 && Money == 0 && BindingGold == 0;
    }

    internal sealed record GachaPool(
        uint Id,
        bool IsDrop,
        uint MoneyId,
        uint CommodityId,
        uint GrandTierRuleId,
        IReadOnlyList<(uint DrawCount, uint Cost)> Costs)
    {
        /// <summary>Authored cost for the requested draw count, falling back to per-draw cost × count.</summary>
        internal double CostFor(uint drawCount)
        {
            foreach (var (count, cost) in Costs)
            {
                if (count == drawCount)
                    return cost;
            }

            foreach (var (count, cost) in Costs)
            {
                if (count == 1)
                    return cost * drawCount;
            }

            return Costs.Count > 0 ? Costs[0].Cost : 0;
        }
    }

    internal sealed record GachaContent(
        uint Id,
        uint PoolId,
        uint TierRarity,
        uint DropId,
        double Weight,
        uint Quantity,
        uint Quality,
        uint DuplicateReturnDropId,
        uint DuplicateReturnCount)
    {
        /// <summary>SS-tier row: the UI plays the extra grand-prize video for these draws.</summary>
        internal bool IsGrandPrize => TierRarity >= 4 || Quality >= 5;
    }

    /// <summary>
    /// Pity ramp for one tier rule. <paramref name="RuleType"/> 1 pools ramp their grand-prize chance
    /// from <paramref name="BaseProbability"/> by <paramref name="ProbabilityIncrement"/> every draw
    /// once <paramref name="RampStartDraw"/> is reached and guarantee it at <paramref name="PityThreshold"/>.
    /// <paramref name="RuleType"/> 0 pools instead pick a tier from the cumulative
    /// <paramref name="GrandPrizeProbability"/> table (scale 100000) with no pity at all.
    /// </summary>
    internal sealed record GachaTierRule(
        uint Id,
        uint RuleType,
        uint PityThreshold,
        uint RampStartDraw,
        uint BaseProbability,
        uint ProbabilityIncrement,
        IReadOnlyList<uint> GrandPrizeProbability);

    /// <summary>
    /// One trading-post row. <paramref name="ItemType"/> 0 hands out <paramref name="ItemId"/> as an
    /// ordinary backpack item, 1 unlocks the wardrobe piece <paramref name="FashionId"/>, 3 is a
    /// household collectible (also <paramref name="ItemId"/>) and 2 is a fashion suit that retail only
    /// trades through the order book.
    /// </summary>
    internal sealed record TradeItem(
        uint Id,
        uint ItemType,
        uint ItemId,
        uint Tab,
        uint FashionId,
        uint FashionSuitId,
        uint MinPrice,
        uint MaxPrice,
        IReadOnlyList<uint> BucketRanges)
    {
        /// <summary>Cheapest price the row is offered at - the floor of its authored bucket ranges.</summary>
        internal uint MarketPrice
        {
            get
            {
                if (MinPrice > 0)
                    return MinPrice;

                foreach (var bucket in BucketRanges)
                {
                    if (bucket > 0)
                        return bucket;
                }

                return 0;
            }
        }
    }

    private sealed class Data
    {
        internal Dictionary<uint, ConsumableItem> Items { get; init; } = [];
        internal Dictionary<uint, MallCommodity> Mall { get; init; } = [];
        internal Dictionary<uint, DropRow> Drops { get; init; } = [];
        internal Dictionary<uint, GachaPool> Pools { get; init; } = [];
        internal Dictionary<uint, GachaTierRule> TierRules { get; init; } = [];
        internal Dictionary<uint, List<GachaContent>> ContentsByPool { get; init; } = [];
        internal Dictionary<uint, TradeItem> TradeItems { get; init; } = [];
        internal Dictionary<uint, uint[]> FashionSuits { get; init; } = [];
        internal IReadOnlySet<uint> MallSoldFashions { get; init; } = new HashSet<uint>();
        internal IReadOnlySet<uint> MallSoldVehicles { get; init; } = new HashSet<uint>();
    }

    private static Data Load()
    {
        var cfg = PrivateServerConfigStore.Current;
        var root = PrivateServerConfigStore.ResolveProjectPath(cfg.Paths.ClientConfigs);
        var warnings = new List<string>();

        var mall = new Dictionary<uint, MallCommodity>();
        foreach (var row in ReadRecords(Path.Combine(root, "MallCommodityConfig.json"), warnings))
        {
            if (!TryUInt32(row, "Id", out var id) || id == 0)
                continue;

            TryUInt32(row, "BelongMallId", out var mallId);
            TryUInt32(row, "Type", out var type);
            TryUInt32(row, "BindId", out var bindId);
            TryUInt32(row, "ConsumeItemId", out var consumeItemId);
            TryDouble(row, "Price", out var price);
            TryDouble(row, "DiscountPrice", out var discountPrice);
            TryUInt32(row, "DropId", out var dropId);
            TryUInt32(row, "LimitNum", out var limitNum);

            mall[id] = new MallCommodity(
                id, mallId, type, bindId, consumeItemId, price, discountPrice, dropId, limitNum,
                ReadUInt32Array(row, "CommodityBindId"));
        }

        var items = new Dictionary<uint, ConsumableItem>();
        foreach (var row in ReadRecords(Path.Combine(root, "ConsumableConfig.json"), warnings))
        {
            if (!TryUInt32(row, "Id", out var itemId) || itemId == 0)
                continue;

            TryUInt32(row, "SubType", out var subType);
            TryUInt32(row, "Quality", out var quality);
            items[itemId] = new ConsumableItem(itemId, ReadString(row, "Name"), subType, quality);
        }

        var drops = new Dictionary<uint, DropRow>();
        foreach (var row in ReadRecords(Path.Combine(root, "DropConfig.json"), warnings))
        {
            if (!TryUInt32(row, "Id", out var id) || id == 0)
                continue;

            TryDouble(row, "Money", out var money);
            TryDouble(row, "BindingGold", out var bindingGold);

            drops[id] = new DropRow(
                id, money, bindingGold, ReadItemList(row, "Item1"), ReadItemRangeList(row, "Item2"),
                ReadItemWeightList(row, "Item3"));
        }

        var pools = new Dictionary<uint, GachaPool>();
        foreach (var row in ReadRecords(Path.Combine(root, "GachaPoolConfig.json"), warnings))
        {
            if (!TryUInt32(row, "Id", out var id) || id == 0)
                continue;

            TryUInt32(row, "MoneyId", out var moneyId);
            TryUInt32(row, "CommodityId", out var commodityId);
            TryUInt32(row, "SS_TierRuleId", out var grandTierRuleId);

            pools[id] = new GachaPool(
                id, ReadBool(row, "isDrop"), moneyId, commodityId, grandTierRuleId, ReadCostList(row, "CostCount"));
        }

        var tierRules = new Dictionary<uint, GachaTierRule>();
        foreach (var row in ReadRecords(Path.Combine(root, "GachaPoolTierRuleConfig.json"), warnings))
        {
            if (!TryUInt32(row, "Id", out var id) || id == 0)
                continue;

            TryUInt32(row, "RuleType", out var ruleType);
            TryUInt32(row, "PityThreshold", out var pityThreshold);
            TryUInt32(row, "RampStartDraw", out var rampStartDraw);
            TryUInt32(row, "BaseProbability", out var baseProbability);
            TryUInt32(row, "ProbabilityIncrement", out var probabilityIncrement);
            tierRules[id] = new GachaTierRule(
                id, ruleType, pityThreshold, rampStartDraw, baseProbability, probabilityIncrement,
                ReadUInt32Array(row, "GrandPrizeProbability"));
        }

        var contentsByPool = new Dictionary<uint, List<GachaContent>>();
        foreach (var row in ReadRecords(Path.Combine(root, "GachaPoolContentConfig.json"), warnings))
        {
            if (!TryUInt32(row, "Id", out var id) || id == 0)
                continue;
            if (!TryUInt32(row, "PoolId", out var poolId) || poolId == 0)
                continue;

            TryUInt32(row, "PoolTierRarity", out var tierRarity);
            TryUInt32(row, "dropId", out var dropId);
            TryDouble(row, "weight", out var weight);
            TryUInt32(row, "Quantity", out var quantity);
            TryUInt32(row, "Quality", out var quality);
            TryUInt32(row, "duplicateReturnDropId", out var duplicateDropId);
            TryUInt32(row, "duplicateReturnCount", out var duplicateCount);

            if (!contentsByPool.TryGetValue(poolId, out var list))
            {
                list = [];
                contentsByPool[poolId] = list;
            }

            list.Add(new GachaContent(
                id, poolId, tierRarity, dropId, weight < 0 ? 0 : weight, quantity, quality,
                duplicateDropId, duplicateCount));
        }

        var tradeItems = new Dictionary<uint, TradeItem>();
        foreach (var row in ReadRecords(Path.Combine(root, "TradeItemConfig.json"), warnings))
        {
            if (!TryUInt32(row, "Id", out var id) || id == 0)
                continue;

            TryUInt32(row, "ItemType", out var itemType);
            TryUInt32(row, "ItemId", out var itemId);
            TryUInt32(row, "Tab", out var tab);
            TryUInt32(row, "FashionId", out var fashionId);
            TryUInt32(row, "FashionSuitId", out var fashionSuitId);
            TryUInt32(row, "MinPrice", out var minPrice);
            TryUInt32(row, "MaxPrice", out var maxPrice);

            tradeItems[id] = new TradeItem(
                id, itemType, itemId, tab, fashionId, fashionSuitId, minPrice, maxPrice,
                ReadUInt32Array(row, "BucketRanges"));
        }

        var fashionSuits = new Dictionary<uint, uint[]>();
        foreach (var row in ReadRecords(Path.Combine(root, "FashionSuitConfig.json"), warnings))
        {
            if (!TryUInt32(row, "Id", out var id) || id == 0)
                continue;

            var pieces = ReadUInt32Array(row, "FashionIdList").Where(x => x != 0).Distinct().ToArray();
            if (pieces.Length > 0)
                fashionSuits[id] = pieces;
        }

        // Everything the direct-sale shelves stock has to stay unowned at login, otherwise the client
        // hides the buy button behind its own "already owned" rule. See MallSoldFashionIds.
        var mallSoldFashions = new HashSet<uint>();
        var mallSoldVehicles = new HashSet<uint>();
        foreach (var commodity in mall.Values)
        {
            if (Array.IndexOf(DirectSaleMallIds4229938, commodity.MallId) < 0)
                continue;

            foreach (var bindId in commodity.OwnershipBindIds)
            {
                if (commodity.Type == CommodityTypeFashion4229938
                    && fashionSuits.TryGetValue(bindId, out var pieces))
                {
                    mallSoldFashions.UnionWith(pieces);
                }
                else if (commodity.Type == CommodityTypeVehicle4229938)
                {
                    mallSoldVehicles.Add(bindId);
                }
            }
        }

        foreach (var message in warnings)
            Console.WriteLine($"[ECONOMY] {message}");

        Console.WriteLine(
            $"[ECONOMY] items={items.Count} mall={mall.Count} drops={drops.Count} pools={pools.Count} " +
            $"gachaContents={contentsByPool.Values.Sum(x => x.Count)} tierRules={tierRules.Count} " +
            $"tradeItems={tradeItems.Count} fashionSuits={fashionSuits.Count} " +
            $"directSaleFashions={mallSoldFashions.Count} directSaleVehicles={mallSoldVehicles.Count} " +
            $"source={root}");

        return new Data
        {
            Items = items,
            Mall = mall,
            Drops = drops,
            Pools = pools,
            TierRules = tierRules,
            ContentsByPool = contentsByPool,
            TradeItems = tradeItems,
            FashionSuits = fashionSuits,
            MallSoldFashions = mallSoldFashions,
            MallSoldVehicles = mallSoldVehicles,
        };
    }

    private static JsonElement[] ReadRecords(string path, List<string> warnings)
    {
        if (!File.Exists(path))
        {
            warnings.Add($"optional client config is missing: {path}");
            return [];
        }

        try
        {
            using var doc = JsonDocument.Parse(File.ReadAllText(path));
            if (!doc.RootElement.TryGetProperty("records", out var records) || records.ValueKind != JsonValueKind.Array)
            {
                warnings.Add($"client config has no 'records' array: {path}");
                return [];
            }

            return records.EnumerateArray().Select(x => x.Clone()).ToArray();
        }
        catch (Exception ex)
        {
            warnings.Add($"client config failed to parse ({ex.GetType().Name}: {ex.Message}): {path}");
            return [];
        }
    }

    // Dump records may carry fully qualified keys ("LT.ConfigGen.IFoo.Id"), so match on the leaf name.
    private static bool TryProperty(JsonElement row, string name, out JsonElement value)
    {
        if (row.TryGetProperty(name, out value))
            return true;

        foreach (var property in row.EnumerateObject())
        {
            if (property.Name.AsSpan()[(property.Name.LastIndexOf('.') + 1)..].SequenceEqual(name))
            {
                value = property.Value;
                return true;
            }
        }

        value = default;
        return false;
    }

    private static bool TryUInt32(JsonElement row, string name, out uint result)
    {
        result = 0;
        return TryProperty(row, name, out var value) && value.TryGetUInt32(out result);
    }

    private static bool TryDouble(JsonElement row, string name, out double result)
    {
        result = 0;
        return TryProperty(row, name, out var value) && value.TryGetDouble(out result);
    }

    private static bool ReadBool(JsonElement row, string name)
        => TryProperty(row, name, out var value) && value.ValueKind == JsonValueKind.True;

    private static string ReadString(JsonElement row, string name)
        => TryProperty(row, name, out var value) && value.ValueKind == JsonValueKind.String
            ? value.GetString() ?? string.Empty
            : string.Empty;

    private static IReadOnlyList<uint> ReadUInt32Array(JsonElement row, string name)
    {
        if (!TryProperty(row, name, out var value) || value.ValueKind != JsonValueKind.Array)
            return [];

        return value.EnumerateArray()
            .Where(x => x.TryGetUInt32(out _))
            .Select(x => x.GetUInt32())
            .ToArray();
    }

    // Item1: [{ "id1": 36211010, "count": 10 }, ...] - every entry is granted.
    private static IReadOnlyList<(uint Id, uint Count)> ReadItemList(JsonElement row, string name)
    {
        if (!TryProperty(row, name, out var value) || value.ValueKind != JsonValueKind.Array)
            return [];

        var result = new List<(uint, uint)>();
        foreach (var entry in value.EnumerateArray())
        {
            if (!TryUInt32(entry, "id1", out var id) || id == 0)
                continue;

            TryUInt32(entry, "count", out var count);
            result.Add((id, count == 0 ? 1u : count));
        }

        return result;
    }

    // Item2: [{ "id2": .., "min": .., "max": .. }] - one entry is chosen and rolled inside [min, max].
    private static IReadOnlyList<(uint Id, uint Min, uint Max)> ReadItemRangeList(JsonElement row, string name)
    {
        if (!TryProperty(row, name, out var value) || value.ValueKind != JsonValueKind.Array)
            return [];

        var result = new List<(uint, uint, uint)>();
        foreach (var entry in value.EnumerateArray())
        {
            if (!TryUInt32(entry, "id2", out var id) || id == 0)
                continue;

            TryUInt32(entry, "min", out var min);
            TryUInt32(entry, "max", out var max);
            if (max < min)
                max = min;
            result.Add((id, min, max));
        }

        return result;
    }

    // Item3: [{ "id3": .., "count": 0.00075 }] - 'count' is a relative probability weight.
    private static IReadOnlyList<(uint Id, double Weight)> ReadItemWeightList(JsonElement row, string name)
    {
        if (!TryProperty(row, name, out var value) || value.ValueKind != JsonValueKind.Array)
            return [];

        var result = new List<(uint, double)>();
        foreach (var entry in value.EnumerateArray())
        {
            if (!TryUInt32(entry, "id3", out var id) || id == 0)
                continue;

            TryDouble(entry, "count", out var weight);
            if (weight <= 0)
                continue;
            result.Add((id, weight));
        }

        return result;
    }

    // CostCount: [{ "drawCount": 1, "cost": 100 }, ...]
    private static IReadOnlyList<(uint DrawCount, uint Cost)> ReadCostList(JsonElement row, string name)
    {
        if (!TryProperty(row, name, out var value) || value.ValueKind != JsonValueKind.Array)
            return [];

        var result = new List<(uint, uint)>();
        foreach (var entry in value.EnumerateArray())
        {
            if (!TryUInt32(entry, "drawCount", out var drawCount) || drawCount == 0)
                continue;

            TryUInt32(entry, "cost", out var cost);
            result.Add((drawCount, cost));
        }

        return result;
    }
}
