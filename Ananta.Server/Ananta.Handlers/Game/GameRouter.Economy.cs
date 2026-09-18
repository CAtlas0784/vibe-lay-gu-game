using Ananta.SDK.Logging;
using Ananta.SDK.Network;
using Ananta.SDK.Rpc;
using Ananta.SDK.Serialization;
using Ananta.Server.ClientData.Client4229938;
using Ananta.Server.Protocol.Client4229938;
using Auto = Ananta.Server.RpcTypes.Client4229938.Auto;
using GameMethods = Ananta.Server.RpcTypes.Client4229938.Methods.Game;

namespace Ananta.Server.Handlers.Game;

/// <summary>
/// Shared economy plumbing for build 4229938 mall purchases and gacha draws: currency/wallet mapping,
/// backpack grants, the pushes the client expects, and the snapshot that lets money and items survive
/// a re-login. Retail keeps all of this in its account database; here the session state is the single
/// authority and PlayerProgressStore mirrors it to one JSON file per player.
/// </summary>
internal sealed partial class GameRouter
{
    private const uint CurrencyRewardGold4229938 = 36920001u;
    private const uint CurrencyRewardMoney4229938 = 36920002u;
    private const uint CurrencyRewardBindingGold4229938 = 36920003u;

    private static long _gmItemSeq = 920000000000L;

    internal readonly record struct ItemGrant4229938(uint TemplateId, uint Count, bool IsBind);

    /// <summary>A pending economy mutation: what to take away, what to add, how the wallet moves.</summary>
    private sealed class EconomyChanges4229938
    {
        internal Dictionary<uint, uint> Consumed { get; } = [];
        internal Dictionary<uint, ItemGrant4229938> Granted { get; } = [];
        internal double MoneyDelta { get; set; }
        internal double GoldDelta { get; set; }
        internal double BindingGoldDelta { get; set; }
    }

    /// <summary>Loads the saved character economy into the session state at login.</summary>
    internal static void RestorePlayerProgress4229938(WorldEntryState state, ServerLogger log)
    {
        lock (state.SyncRoot)
        {
            if (state.ProgressRestored)
                return;
        }

        PlayerProgressStore.LoadInto(state.Progress, log);

        lock (state.SyncRoot)
        {
            state.ProgressRestored = true;
            state.WalletMoney = state.Progress.Money;
            state.WalletGold = state.Progress.Gold;
            state.WalletBindingGold = state.Progress.BindingGold;

            state.GmBackpackItems.Clear();
            foreach (var item in state.Progress.Items)
            {
                if (EconomyConfigRepository.HasConsumableItems &&
                    !EconomyConfigRepository.TryConsumableItem(item.TemplateId, out _))
                {
                    log.Warn(
                        $"[GM] dropping saved backpack item templateId={item.TemplateId} count={item.Count}: " +
                        "not in ConsumableConfig for this build");
                    continue;
                }

                var uniqueId = item.UniqueId;
                if (uniqueId == 0)
                    uniqueId = NextGmItemUniqueId4229938();
                else
                    ReserveGmItemUniqueId4229938(uniqueId);

                state.GmBackpackItems[item.TemplateId] = RuntimePayloadFactory.GmPackItem4229938(
                    item.TemplateId, item.Count, item.IsBind, uniqueId);
            }
        }
    }

    private static ulong NextGmItemUniqueId4229938()
        => (ulong)Interlocked.Increment(ref _gmItemSeq);

    private static void ReserveGmItemUniqueId4229938(ulong uniqueId)
    {
        if (uniqueId > long.MaxValue)
            return;

        while (true)
        {
            var current = Interlocked.Read(ref _gmItemSeq);
            if (uniqueId <= (ulong)current)
                return;

            if (Interlocked.CompareExchange(ref _gmItemSeq, (long)uniqueId, current) == current)
                return;
        }
    }

    /// <summary>
    /// Charges a price in currency units. Wallet currencies debit the wallet,
    /// everything else debits the granted stack.
    /// </summary>
    private static void ChargeCurrency4229938(
        WorldEntryState state,
        EconomyChanges4229938 changes,
        uint currencyItemId,
        double amount,
        ServerLogger log,
        string context)
    {
        if (currencyItemId == 0 || amount <= 0)
            return;

        switch (currencyItemId)
        {
            case CurrencyRewardMoney4229938:
                changes.MoneyDelta -= amount;
                return;
            case CurrencyRewardGold4229938:
                changes.GoldDelta -= amount;
                return;
            case CurrencyRewardBindingGold4229938:
                changes.BindingGoldDelta -= amount;
                return;
        }

        uint available;
        lock (state.SyncRoot)
            available = state.GmBackpackItems.TryGetValue(currencyItemId, out var stack) ? stack.Count : 0u;

        var taken = Math.Min(amount, available);
        if (taken < amount)
            log.Warn($"[ECONOMY] {context}: missing {currencyItemId} to pay {amount} with (have {available}), granting remainder");

        if (taken <= 0)
            return;

        var count = (uint)Math.Min(taken, uint.MaxValue);
        changes.Consumed[currencyItemId] = changes.Consumed.TryGetValue(currencyItemId, out var previous)
            ? SaturatingAdd4229938(previous, count)
            : count;
    }

    /// <summary>Rolls one drop row into changes.</summary>
    private static void GrantDrop4229938(
        EconomyChanges4229938 changes,
        EconomyConfigRepository.DropRow drop,
        uint rolls,
        string context,
        ServerLogger log)
    {
        if (rolls == 0)
            return;

        if (drop.Money != 0)
            changes.MoneyDelta += drop.Money * rolls;
        if (drop.BindingGold != 0)
            changes.BindingGoldDelta += drop.BindingGold * rolls;

        foreach (var (id, count) in drop.Guaranteed)
            AddGrant4229938(changes, id, SaturatingMultiply4229938(count, rolls), isBind: false);

        for (var roll = 0u; roll < rolls; roll++)
        {
            if (drop.Ranged.Count > 0)
            {
                var (id, min, max) = drop.Ranged[Random.Shared.Next(drop.Ranged.Count)];
                AddGrant4229938(changes, id, RollCount4229938(min, max), isBind: false);
            }

            if (drop.Weighted.Count > 0)
            {
                var index = PickWeightedIndex4229938(drop.Weighted.Count, i => drop.Weighted[i].Weight);
                if (index >= 0)
                    AddGrant4229938(changes, drop.Weighted[index].Id, 1, isBind: false);
            }
        }

        log.Info(
            $"[ECONOMY] {context}: drop={drop.Id} rolls={rolls} money={drop.Money * rolls} " +
            $"bindingGold={drop.BindingGold * rolls} guaranteed={drop.Guaranteed.Count} " +
            $"ranged={drop.Ranged.Count} weighted={drop.Weighted.Count}");
    }

    private static void AddGrant4229938(EconomyChanges4229938 changes, uint templateId, uint count, bool isBind)
    {
        if (templateId == 0 || count == 0)
            return;

        if (changes.Granted.TryGetValue(templateId, out var existing))
        {
            changes.Granted[templateId] = existing with
            {
                Count = SaturatingAdd4229938(existing.Count, count),
                IsBind = existing.IsBind || isBind,
            };
            return;
        }

        changes.Granted[templateId] = new ItemGrant4229938(templateId, count, isBind);
    }

    private static Task<string> ApplyEconomy4229938Async(
        Connection conn,
        WorldEntryState state,
        EconomyChanges4229938 changes,
        string context)
        => ApplyEconomy4229938Async(conn.Session, conn.Log, state, changes, context);

    private static async Task<string> ApplyEconomy4229938Async(
        TcpSession session,
        ServerLogger log,
        WorldEntryState state,
        EconomyChanges4229938 changes,
        string context)
    {
        var adds = new List<Auto.PlayerPackItem>();
        var updates = new List<Auto.PlayerPackItem>();
        var deletes = new List<Auto.PlayerPackItem>();
        double money;
        double gold;
        double bindingGold;

        lock (state.SyncRoot)
        {
            var templates = new HashSet<uint>(changes.Consumed.Keys);
            foreach (var templateId in changes.Granted.Keys)
                templates.Add(templateId);

            foreach (var templateId in templates)
            {
                changes.Consumed.TryGetValue(templateId, out var consumed);
                changes.Granted.TryGetValue(templateId, out var grant);

                if (state.GmBackpackItems.TryGetValue(templateId, out var stack))
                {
                    var remaining = stack.Count > consumed ? stack.Count - consumed : 0u;
                    var final = SaturatingAdd4229938(remaining, grant.Count);

                    if (final == 0)
                    {
                        state.GmBackpackItems.Remove(templateId);
                        deletes.Add(stack);
                        continue;
                    }

                    stack.Count = final;
                    stack.IsBind = stack.IsBind || grant.IsBind;
                    updates.Add(stack);
                    continue;
                }

                if (grant.Count == 0)
                    continue;

                var item = RuntimePayloadFactory.GmPackItem4229938(
                    grant.TemplateId, grant.Count, grant.IsBind, NextGmItemUniqueId4229938());
                state.GmBackpackItems[templateId] = item;
                adds.Add(item);
            }

            money = state.WalletMoney + changes.MoneyDelta;
            gold = state.WalletGold + changes.GoldDelta;
            bindingGold = state.WalletBindingGold + changes.BindingGoldDelta;

            if (money < 0 || gold < 0 || bindingGold < 0)
            {
                log.Warn(
                    $"[ECONOMY] {context}: wallet went negative " +
                    $"(money={money} gold={gold} bindingGold={bindingGold}), clamped to zero");
                money = Math.Max(money, 0);
                gold = Math.Max(gold, 0);
                bindingGold = Math.Max(bindingGold, 0);
            }

            state.WalletMoney = money;
            state.WalletGold = gold;
            state.WalletBindingGold = bindingGold;
        }

        if (changes.MoneyDelta != 0 || changes.GoldDelta != 0 || changes.BindingGoldDelta != 0)
        {
            await NotifySession4229938Async(session, MethodId.SyncMoney, new GameMethods.SyncMoney4229938
            {
                money = money,
                gold = gold,
                bindingGold = bindingGold,
            });

            if (changes.MoneyDelta > 0)
            {
                await NotifySession4229938Async(session, MethodId.SyncMoneyAdd, new GameMethods.SyncMoneyAdd4229938
                {
                    value = changes.MoneyDelta,
                    reason = 0,
                    silence = false,
                });
            }
        }

        if (adds.Count > 0 || updates.Count > 0 || deletes.Count > 0)
        {
            await NotifySession4229938Async(session, MethodId.SyncBackpackItemChanged, new GameMethods.SyncBackpackItemChanged4229938
            {
                addItemList = adds,
                updateItemList = updates,
                deleteItemList = deletes,
            });
        }

        PlayerProgressStore.Save(state, log);
        return $"wallet=({money},{gold},{bindingGold}) add={adds.Count} update={updates.Count} delete={deletes.Count}";
    }

    private static async Task NotifySession4229938Async<T>(TcpSession session, uint methodId, T body)
    {
        var bytes = UxSerializer.Serialize(body);
        RuntimeLogs.Decoded(session.Log.Scope, "S2C", methodId, typeof(T), body);
        await session.NotifyAsync(methodId, bytes, CancellationToken.None);
    }

    /// <summary>
    /// Debug panel: hands out a backpack stack through the mall pipeline, syncing SyncBackpackItemChanged.
    /// </summary>
    internal static async Task<(bool Ok, string Message)> PanelGiveItemAsync(
        TcpSession session,
        uint templateId,
        uint count,
        bool isBind)
    {
        var state = GetStateIfExists(session);
        if (state is null)
            return (false, "no live game session (is the client in the world?)");
        if (templateId == 0)
            return (false, "missing templateId");
        if (!TryResolveGmItem4229938(templateId, out var name))
            return (false, $"Item Id {templateId} not found in ConsumableConfig{DescribeItemNamespace4229938(templateId)}");

        if (count == 0)
            count = 1;

        var changes = new EconomyChanges4229938();
        changes.Granted[templateId] = new ItemGrant4229938(templateId, count, isBind);
        var summary = await ApplyEconomy4229938Async(
            session, session.Log, state, changes, $"panel give-item {templateId}x{count}");

        uint total;
        lock (state.SyncRoot)
            total = state.GmBackpackItems.TryGetValue(templateId, out var stack) ? stack.Count : 0u;

        session.Log.Info($"[PANEL] give-item id={templateId} name={name} count={count} bind={isBind} total={total} {summary}");
        return (true, $"Granted {name} (Id={templateId}) x{count}, backpack now has {total}; {summary}");
    }

    internal static uint SaturatingAdd4229938(uint left, uint right)
        => left > uint.MaxValue - right ? uint.MaxValue : left + right;

    private static uint SaturatingMultiply4229938(uint value, uint factor)
        => factor == 0 ? 0u : (value > uint.MaxValue / factor ? uint.MaxValue : value * factor);

    private static uint RollCount4229938(uint min, uint max)
    {
        if (max < min)
            (min, max) = (max, min);

        return max == min ? min : (uint)Random.Shared.NextInt64(min, (long)max + 1);
    }

    private static int PickWeightedIndex4229938(int count, Func<int, double> weightAt)
    {
        var total = 0d;
        for (var i = 0; i < count; i++)
        {
            var weight = weightAt(i);
            if (weight > 0)
                total += weight;
        }

        if (total <= 0)
            return -1;

        var roll = Random.Shared.NextDouble() * total;
        for (var i = 0; i < count; i++)
        {
            var weight = weightAt(i);
            if (weight <= 0)
                continue;

            roll -= weight;
            if (roll <= 0)
                return i;
        }

        return count - 1;
    }

    private readonly record struct EconomyRequest4229938(uint Id, uint Count, bool Flag);

    private static EconomyRequest4229938 ParseEconomyRequest4229938(byte[] body)
        => new(
            body.Length >= 4 ? BitConverter.ToUInt32(body, 0) : 0u,
            body.Length >= 8 ? BitConverter.ToUInt32(body, 4) : 0u,
            body.Length > 8 && body[8] != 0);

    private static bool TryResolveGmItem4229938(uint templateId, out string name)
    {
        name = string.Empty;
        if (!EconomyConfigRepository.HasConsumableItems)
            return true;

        if (!EconomyConfigRepository.TryConsumableItem(templateId, out var item))
            return false;

        name = item.Name;
        return true;
    }

    private static string DescribeItemNamespace4229938(uint templateId) => templateId switch
    {
        >= 36000000u and < 37000000u => " (36xxxxxx Item ID exists in range but not in rows)",
        >= 98000000u and < 99000000u => " (Weapon ID, please equip via Armory Wheel)",
        >= 81000000u and < 82000000u => " (Vehicle ID)",
        >= 11190000u and < 11200000u => " (Fashion Suit ID)",
        >= 11100000u and < 11190000u => " (Fashion Piece ID)",
        _ => " (Unknown Item ID range)",
    };
}
