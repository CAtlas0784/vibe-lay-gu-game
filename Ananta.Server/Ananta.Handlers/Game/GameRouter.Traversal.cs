using Ananta.SDK.Rpc;
using Ananta.Server.Handlers;
using Ananta.Server.Gameplay;
using Ananta.Server.Protocol.Client4229938;

namespace Ananta.Server.Handlers.Game;

/// <summary>Protagonist traversal/web buff handling. Buff ids come from private-server.json.</summary>
internal sealed partial class GameRouter
{
    static bool IsActiveProtagonist(WorldEntryState state, ulong unitId = 0)
        => WebTraversal.IsProtagonist(state.ActiveSpiritTemplateId)
           && (unitId == 0 || unitId == state.ActiveSpiritUnitId);

    async Task EnsureFeiSuoActionBuff(RpcContext ctx)
    {
        var state = GetWorldState(ctx);
        if (!IsActiveProtagonist(state))
            return;
        if (state.ActiveFeiSuoBuffInstanceId != 0)
            return;

        var instanceId = state.NextBuffInstanceId++;
        state.ActiveFeiSuoBuffInstanceId = instanceId;
        state.ActiveFeiSuoBuffUnitId = state.ActiveSpiritUnitId;
        await ctx.NotifyAsync(MethodId.SyncUnitAddBuff,
            WorldCodec.UnitAddBuff(state.ActiveSpiritUnitId, WebTraversal.FeiSuoBuff, instanceId));
    }

    async Task OnEnterFeiSuoCrouch(RpcContext ctx)
    {
        var state = GetWorldState(ctx);
        if (!IsActiveProtagonist(state))
        {
            ctx.Session.Log.Info($"[WEB] feisuo-enter ignored template={state.ActiveSpiritTemplateId} protagonist=false");
            return;
        }
        await PublishInitialCapabilityBuffs(ctx);
        await EnsureFeiSuoActionBuff(ctx);
        ctx.Session.Log.Info($"[WEB] feisuo-enter ack=true transient={WebTraversal.FeiSuoBuff}");
    }

    async Task OnFeiSuoSuccess(RpcContext ctx, int feiSuoId)
    {
        var state = GetWorldState(ctx);
        if (!IsActiveProtagonist(state))
        {
            ctx.Session.Log.Info($"[WEB] feisuo-success ignored template={state.ActiveSpiritTemplateId} protagonist=false");
            return;
        }
        await EnsureFeiSuoActionBuff(ctx);
        ctx.Session.Log.Info($"[WEB] feisuo-success id={feiSuoId} transient={WebTraversal.FeiSuoBuff}");
    }

    async Task OnLeaveFeiSuoCrouch(RpcContext ctx)
    {
        var state = GetWorldState(ctx);
        if (state.ActiveFeiSuoBuffInstanceId == 0)
            return;

        var instanceId = state.ActiveFeiSuoBuffInstanceId;
        var unitId = state.ActiveFeiSuoBuffUnitId != 0
            ? state.ActiveFeiSuoBuffUnitId
            : state.ActiveSpiritUnitId;
        state.ActiveFeiSuoBuffInstanceId = 0;
        state.ActiveFeiSuoBuffUnitId = 0;
        await ctx.NotifyAsync(MethodId.SyncUnitRemoveBuff,
            WorldCodec.UnitRemoveBuff(unitId, instanceId));
        ctx.Session.Log.Info($"[WEB] feisuo-leave transient-removed instance={instanceId}");
    }

    async Task OnClientBuffAdd(RpcContext ctx, ulong unitId, uint buffId)
    {
        var state = GetWorldState(ctx);
        if (WebTraversal.IsWebBuff(buffId) && !IsActiveProtagonist(state, unitId))
        {
            ctx.Session.Log.Info($"[WEB] client-buff-add denied unit={unitId} template={state.ActiveSpiritTemplateId} buff={buffId} protagonist=false");
            return;
        }
        // SwingBuff/WallRushBuff are action states, not unlocks. The 4229938 client requests them
        // when an action starts and removes them when it ends. Track one exact instance per unit/buff
        // so repeated client requests refresh the state instead of stacking permanent super-armor.
        if (WebTraversal.IsClientLifecycleBuff(buffId))
        {
            var key = (unitId, buffId);
            if (state.ActiveClientWebBuffInstances.Remove(key, out var previousInstanceId))
                await ctx.NotifyAsync(MethodId.SyncUnitRemoveBuff, WorldCodec.UnitRemoveBuff(unitId, previousInstanceId));

            var lifecycleInstanceId = state.NextBuffInstanceId++;
            state.ActiveClientWebBuffInstances[key] = lifecycleInstanceId;
            await ctx.NotifyAsync(MethodId.SyncUnitAddBuff,
                WorldCodec.UnitAddBuff(unitId, buffId, lifecycleInstanceId));
            ctx.Session.Log.Info($"[WEB] lifecycle-add unit={unitId} buff={buffId} instance={lifecycleInstanceId} refreshed={previousInstanceId != 0}");
            return;
        }

        var instanceId = state.NextBuffInstanceId++;
        await ctx.NotifyAsync(MethodId.SyncUnitAddBuff, WorldCodec.UnitAddBuff(unitId, buffId, instanceId));
        if (buffId == WebTraversal.FeiSuoBuff)
        {
            state.ActiveFeiSuoBuffInstanceId = instanceId;
            state.ActiveFeiSuoBuffUnitId = unitId;
        }

        if (buffId == WebTraversal.FeiSuoBuff || WebTraversal.IsProtected(buffId))
            ctx.Session.Log.Info($"[WEB] client-buff-add unit={unitId} buff={buffId} instance={instanceId}");
    }

    async Task OnClientBuffRemove(RpcContext ctx, ulong unitId, uint buffId)
    {
        var state = GetWorldState(ctx);
        if (WebTraversal.IsWebBuff(buffId) && !IsActiveProtagonist(state, unitId))
            return;
        if (WebTraversal.IsClientLifecycleBuff(buffId))
        {
            var key = (unitId, buffId);
            if (state.ActiveClientWebBuffInstances.Remove(key, out var lifecycleInstanceId))
            {
                await ctx.NotifyAsync(MethodId.SyncUnitRemoveBuff,
                    WorldCodec.UnitRemoveBuff(unitId, lifecycleInstanceId));
                ctx.Session.Log.Info($"[WEB] lifecycle-remove unit={unitId} buff={buffId} instance={lifecycleInstanceId}");
            }
            return;
        }

        if (buffId == WebTraversal.FeiSuoBuff)
        {
            if (state.ActiveFeiSuoBuffInstanceId != 0)
            {
                var instanceId = state.ActiveFeiSuoBuffInstanceId;
                var transientUnitId = state.ActiveFeiSuoBuffUnitId != 0
                    ? state.ActiveFeiSuoBuffUnitId
                    : unitId;
                state.ActiveFeiSuoBuffInstanceId = 0;
                state.ActiveFeiSuoBuffUnitId = 0;
                await ctx.NotifyAsync(MethodId.SyncUnitRemoveBuff,
                    WorldCodec.UnitRemoveBuff(transientUnitId, instanceId));
                ctx.Session.Log.Info($"[WEB] client-buff-remove transient={buffId} instance={instanceId}");
            }

            // Client 4229938 reports grapple teardown by buff *id*, not by instance.
            // Locally that teardown can consume the configured resident grapple gate as well as the short-lived
            // action copy.  This is especially visible on the female protagonist: the first grapple
            // succeeds, then no second client-buff-add is emitted. Re-arm one untracked resident gate
            // after teardown for either protagonist. It is deliberately NOT stored as
            // ActiveFeiSuoBuffInstanceId; that slot is reserved for the next action copy only.
            await Task.Delay(WebTraversal.GrappleRearmDelayMs);
            if (IsActiveProtagonist(state, unitId))
            {
                var residentInstanceId = state.NextBuffInstanceId++;
                await ctx.NotifyAsync(MethodId.SyncUnitAddBuff,
                    WorldCodec.UnitAddBuff(unitId, WebTraversal.FeiSuoBuff, residentInstanceId));
                ctx.Session.Log.Info($"[WEB] persistent-gate-reassert unit={unitId} buff={WebTraversal.FeiSuoBuff} instance={residentInstanceId}");
            }
            return;
        }

        if (!WebTraversal.IsProtected(buffId))
            return;

        await ctx.NotifyAsync(MethodId.SyncUnitAddBuff, WorldCodec.UnitAddBuff(unitId, buffId, state.NextBuffInstanceId++));
        ctx.Session.Log.Info($"[WEB] protected-buff-reassert unit={unitId} buff={buffId}");
    }
    async Task ClearClientWebLifecycleBuffs(RpcContext ctx, ulong unitId, string phase)
    {
        var state = GetWorldState(ctx);
        var active = state.ActiveClientWebBuffInstances
            .Where(x => x.Key.UnitId == unitId)
            .ToArray();
        foreach (var item in active)
        {
            state.ActiveClientWebBuffInstances.Remove(item.Key);
            await ctx.NotifyAsync(MethodId.SyncUnitRemoveBuff,
                WorldCodec.UnitRemoveBuff(unitId, item.Value));
        }
        if (active.Length > 0)
            ctx.Session.Log.Info($"[WEB] lifecycle-clear phase={phase} unit={unitId} count={active.Length}");
    }

}
