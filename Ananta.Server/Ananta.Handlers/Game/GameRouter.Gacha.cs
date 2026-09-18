using Ananta.SDK.Network;
using Ananta.SDK.Rpc;
using Ananta.Server.ClientData.Client4229938;
using Ananta.Server.Protocol.Client4229938;
using GameMethods = Ananta.Server.RpcTypes.Client4229938.Methods.Game;

namespace Ananta.Server.Handlers.Game;

/// <summary>
/// Gacha draws for build 4229938 (GachaManager.DoDrawGacha -> AskDrawGacha(poolId, drawCount, isAutoExchange)).
///
/// Odds follow GachaPoolTierRuleConfig: RuleType 1 pools ramp the grand-prize chance from
/// BaseProbability by ProbabilityIncrement per draw past RampStartDraw and hand out a guaranteed
/// grand prize at PityThreshold; these pools also pick the prize row itself by relative weight within
/// the "grand" or "ordinary" group. RuleType 0 pools have no pity ramp and simply pick by weight.
/// Duplicate grand prizes are converted to the row's duplicateReturn drop, which is also how the
/// client labels the result (IsConverted).
/// </summary>
internal sealed partial class GameRouter
{
    private const int GachaProbabilityScale4229938 = 100000;

    [Handler(MethodId.AskDrawGacha, HandlerPacketKind.Invoke)]
    private async Task AskDrawGacha(Connection conn, UxRpcMessage msg)
    {
        var state = GetWorldState(msg.Context);
        var request = ParseEconomyRequest4229938(msg.Body);
        var drawCount = Math.Clamp(request.Count == 0 ? 1u : request.Count, 1u, 10u);

        if (!EconomyConfigRepository.TryPool(request.Id, out var pool))
        {
            conn.Log.Warn($"[GACHA] unknown pool {request.Id} (body={Convert.ToHexString(msg.Body)})");
            await ReplyDrawGacha4229938Async(conn, msg);
            return;
        }

        var contents = EconomyConfigRepository.PoolContents(pool.Id);
        if (contents.Count == 0)
        {
            conn.Log.Warn($"[GACHA] pool {pool.Id} has no contents, nothing can be drawn");
            await ReplyDrawGacha4229938Async(conn, msg);
            return;
        }

        EconomyConfigRepository.GachaTierRule? tierRule = null;
        if (pool.GrandTierRuleId != 0 && EconomyConfigRepository.TryTierRule(pool.GrandTierRuleId, out var foundRule))
            tierRule = foundRule;

        var changes = new EconomyChanges4229938();
        ChargeCurrency4229938(
            state, changes, pool.MoneyId, pool.CostFor(drawCount), conn.Log, $"gacha {pool.Id}");

        var details = new List<GameMethods.GachaDrawDetail4229938>((int)drawCount);
        var grandCount = 0;
        var skipped = 0;

        for (var draw = 0u; draw < drawCount; draw++)
        {
            uint drawsSinceGrand;
            lock (state.SyncRoot)
            {
                state.Progress.GachaDrawsSinceGrand.TryGetValue(pool.Id, out var previous);
                drawsSinceGrand = previous + 1;
            }

            var isGrand = RollGrandPrize4229938(tierRule, drawsSinceGrand);
            var content = PickGachaContent4229938(contents, isGrand)
                          ?? PickGachaContent4229938(contents, grandOnly: null);

            if (content is null)
            {
                skipped++;
                lock (state.SyncRoot)
                    state.Progress.GachaDrawsSinceGrand[pool.Id] = drawsSinceGrand;
                continue;
            }

            isGrand = content.IsGrandPrize;
            lock (state.SyncRoot)
                state.Progress.GachaDrawsSinceGrand[pool.Id] = isGrand ? 0u : drawsSinceGrand;

            if (isGrand)
                grandCount++;

            var converted = false;
            var isNew = false;
            var dropId = content.DropId;
            var rolls = 1u;

            if (TryPrizeTemplateId4229938(content.DropId, out var prizeTemplateId))
            {
                var owned = IsItemOwned4229938(state, prizeTemplateId);
                isNew = !owned;

                if (owned && content.DuplicateReturnDropId != 0 && content.DuplicateReturnCount != 0)
                {
                    converted = true;
                    dropId = content.DuplicateReturnDropId;
                    rolls = content.DuplicateReturnCount;
                }
            }

            if (dropId != 0 && EconomyConfigRepository.TryDrop(dropId, out var drop) && !drop.IsEmpty)
                GrantDrop4229938(changes, drop, rolls, $"gacha {pool.Id} content {content.Id}", conn.Log);
            else
                conn.Log.Warn($"[GACHA] content {content.Id} grants nothing (drop={dropId})");

            details.Add(new GameMethods.GachaDrawDetail4229938
            {
                PoolContentId = content.Id,
                IsGrandPrize = isGrand,
                IsConverted = converted,
                IsNew = isNew,
            });
        }

        var summary = await ApplyEconomy4229938Async(conn, state, changes, $"gacha {pool.Id}");

        if (details.Count > 0)
        {
            await conn.NotifyAsync(MethodId.IGameToClient_SyncGachaDrawInfo, new GameMethods.SyncGachaDrawInfo4229938
            {
                drawDetails = details,
                isGrandPrizeWithAllFillers = false,
            });
        }

        conn.Log.Info(
            $"[GACHA] pool={pool.Id} system={pool.MoneyId} count={drawCount} cost={pool.CostFor(drawCount)} " +
            $"grand={grandCount} skipped={skipped} rule={tierRule?.Id ?? 0} ruleType={tierRule?.RuleType ?? 0} " +
            $"-> {summary}");

        await ReplyDrawGacha4229938Async(conn, msg);
    }

    private static bool RollGrandPrize4229938(EconomyConfigRepository.GachaTierRule? rule, uint drawsSinceGrand)
    {
        if (rule is null)
            return false;

        if (rule.PityThreshold > 0 && drawsSinceGrand >= rule.PityThreshold)
            return true;

        if (rule.RuleType != 1)
            return false;

        var probability = (double)rule.BaseProbability;
        if (rule.RampStartDraw > 0 && drawsSinceGrand > rule.RampStartDraw)
            probability += (double)(drawsSinceGrand - rule.RampStartDraw) * rule.ProbabilityIncrement;

        if (probability <= 0)
            return false;
        if (probability >= GachaProbabilityScale4229938)
            return true;

        return Random.Shared.Next(GachaProbabilityScale4229938) < probability;
    }

    private static EconomyConfigRepository.GachaContent? PickGachaContent4229938(
        IReadOnlyList<EconomyConfigRepository.GachaContent> contents,
        bool? grandOnly)
    {
        var candidates = new List<EconomyConfigRepository.GachaContent>();
        foreach (var content in contents)
        {
            if (content.Weight <= 0)
                continue;
            if (grandOnly is { } wanted && content.IsGrandPrize != wanted)
                continue;

            candidates.Add(content);
        }

        if (candidates.Count == 0)
            return null;

        var index = PickWeightedIndex4229938(candidates.Count, i => candidates[i].Weight);
        return index < 0 ? null : candidates[index];
    }

    private static bool TryPrizeTemplateId4229938(uint dropId, out uint templateId)
    {
        templateId = 0;
        if (dropId == 0 || !EconomyConfigRepository.TryDrop(dropId, out var drop))
            return false;

        if (drop.Guaranteed.Count > 0)
            templateId = drop.Guaranteed[0].Id;
        else if (drop.Ranged.Count > 0)
            templateId = drop.Ranged[0].Id;
        else if (drop.Weighted.Count > 0)
            templateId = drop.Weighted[0].Id;

        return templateId != 0;
    }

    private static bool IsItemOwned4229938(WorldEntryState state, uint templateId)
    {
        lock (state.SyncRoot)
            return state.GmBackpackItems.TryGetValue(templateId, out var stack) && stack.Count > 0;
    }

    private static Task ReplyDrawGacha4229938Async(Connection conn, UxRpcMessage msg)
    {
        if (DefaultReturnCatalog4229938.TryGet(msg.MethodId, out var body, out var shape))
        {
            conn.Log.Info($"[GACHA] reply typed-default {shape} {body.Length}b");
            return msg.Context.ReturnAsync(body);
        }

        return conn.ReturnEmptyOkAsync(msg);
    }

    [Handler(MethodId.AskClaimGachaMilestone, HandlerPacketKind.Invoke)]
    private Task AskClaimGachaMilestone(Connection conn, UxRpcMessage msg)
    {
        var args = msg.GetArgs<GameMethods.AskClaimGachaMilestoneArgs>();
        conn.Session.Log.Info($"[GACHA] AskClaimGachaMilestone: groupId={args.groupId} count={args.milestoneCount}");
        return conn.ReturnEmptyOkAsync(msg);
    }

    [Handler(MethodId.AskChaosMasterGacha, HandlerPacketKind.Invoke)]
    private Task AskChaosMasterGacha(Connection conn, UxRpcMessage msg)
    {
        conn.Session.Log.Info("[GACHA] AskChaosMasterGacha invoke");
        return conn.ReturnAsync(msg, new List<uint>());
    }
}
