using Ananta.SDK.Rpc;
using Ananta.Server.RpcTypes.Client4229938;
using Ananta.Server.Protocol.Client4229938;
using SceneMethods = Ananta.Server.RpcTypes.Client4229938.Methods.GameScene;

namespace Ananta.Server.Handlers.Game;

/// <summary>Client movement reports and live transform tracking.</summary>
internal sealed partial class GameRouter
{
    async Task OnMovementReport(RpcContext ctx, IEnumerable<SceneMethods.LogicAgentSyncData>? samples)
    {
        var state = GetWorldState(ctx);

        // All build-4229938 movement RPCs are projected into the same transform shape by the endpoint.
        // Walk the whole batch so the newest action wins instead of keeping the oldest position.
        if (samples is not null)
        {
            foreach (var item in samples)
            {
                var isActive = item.AgentId == state.ActiveSpiritUnitId;
                var isPendingTarget = state.PendingSwitchUnitId != 0 && item.AgentId == state.PendingSwitchUnitId;
                var isPendingOld = state.PendingSwitchOldUnitId != 0 && item.AgentId == state.PendingSwitchOldUnitId;
                if (!isActive && !isPendingTarget && !isPendingOld)
                    continue;

                var p = item.Position;
                var r = item.Rotation;
                if (float.IsFinite(p.X) && float.IsFinite(p.Y) && float.IsFinite(p.Z) &&
                    float.IsFinite(r.X) && float.IsFinite(r.Y) && float.IsFinite(r.Z))
                {
                    state.LastReportedPlayerPosition = new Vec3(p.X, p.Y, p.Z);
                    state.LastReportedPlayerRotation = new Vec3(r.X, r.Y, r.Z);
                    state.HasLastReportedPlayerTransform = true;
                    state.RecordPositionCheckpoint(state.LastReportedPlayerPosition, state.LastReportedPlayerRotation.Y);

                    // V5.7 safe-entry mode: movement is a pure client->server transform report.
                    // Do not use the first movement edge to reintroduce the same AOI/DynamicGo/social
                    // notification burst that was removed from AskLoadingFinished. The V3 4229938
                    // stable capture remained playable with no post-load server world-content push.
                    // World-content streaming will be re-enabled incrementally only after the crash
                    // boundary is proven stable.
                }
            }
        }

        if (state.FirstMovementSeen)
            return;

        // Do not consume the first-movement edge before AskLoadingFinished has committed Ready.
        // Build 4229938 can report a transform while the loading overlay is still closing; a later
        // real gameplay movement must still be able to trigger the pause-only stability release.
        if (!state.Ready)
        {
            ctx.Session.Log.Warn("[MOVE] movement arrived before world ready; pause-only stability release remains armed");
            return;
        }

        state.FirstMovementSeen = true;
        ctx.Session.Log.Info($"[MOVE] client-agent-traffic rpc={ctx.MethodId} bytes={ctx.Body.Length} liveTransform={state.HasLastReportedPlayerTransform} logicProjection={state.WorldEntryLogicProjectionPublishedGeneration} currentMetadata={state.WorldEntryCurrentMetadataPublishedGeneration}");

        // The supplied v7 guide keeps actor creation/presentation client-owned on initial entry.
        // PlayerInfo + the same-ID projection already contain the build-local roster/fashion data,
        // so do NOT replay SyncSetSpiritFashions/weapon snapshots for the initial actor. The only
        // server feature intentionally layered on after GameplayReady is the requested safe web kit.
        var unitId = state.ActiveSpiritUnitId != 0 ? state.ActiveSpiritUnitId : Profile.InitialUnitId;
        var templateId = state.ActiveSpiritTemplateId != 0 ? state.ActiveSpiritTemplateId : Profile.InitialSpiritTemplateId;

        if (!state.CombatProfilePublished)
        {
            var weapon = CombatCodec.Weapon(templateId, state.ActiveWeaponInstanceId)
                ?? CombatCodec.DefaultWeapon(templateId);
            var style = ResolveWeaponStyle(state, weapon);
            state.ActiveWeaponInstanceId = weapon.InstanceId;
            state.ActiveFightStyleId = style.Id;
            state.LastWeaponBySpirit[templateId] = weapon.InstanceId;

            await PublishWeaponSnapshot(ctx, unitId, templateId, weapon.InstanceId);
            await ctx.NotifyAsync(MethodId.SyncSpiritSwitchWeaponAction,
                CombatCodec.SpiritSwitchWeapon(unitId, weapon.InstanceId));
            await PublishSelectedWeaponProfile(ctx, unitId, templateId, weapon, style);
        }

        if (!state.AllBuildBuffsPublished)
        {
            await PublishSafeRuntimeBuffSnapshot4229938(ctx, unitId, templateId, "first-gameplay-movement");
            state.AllBuildBuffsPublished = true;
        }

        // Same edge: populate the phone/garage vehicle list automatically.
        await PublishGarageAsync(ctx);

        await ctx.NotifyAsync(MethodId.SyncGamePause, WorldCodec.GamePause(false));
        state.MovementCapabilityPublished = true;
        state.FreeRoamReleased = true;
        ctx.Session.Log.Info($"[GAMEPLAY-V7] first-movement post-load-buffs unit={unitId} template={templateId} combatProfile=true safeBuffs=true pause=false catalogBulk=false");
    }
}
