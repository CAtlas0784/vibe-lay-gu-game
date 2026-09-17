using Ananta.SDK.Network;
using Ananta.SDK.Rpc;
using Ananta.SDK.Serialization;
using Ananta.Server.Handlers;
using Ananta.Server.Gameplay;
using Ananta.Server.Protocol.Client4229938;
using Ananta.Server.ClientData.Client4229938;
using Ananta.Server.RpcTypes.Client4229938;
using GameMethods = Ananta.Server.RpcTypes.Client4229938.Methods.Game;
using SceneMethods = Ananta.Server.RpcTypes.Client4229938.Methods.GameScene;

namespace Ananta.Server.Handlers.Game;

/// <summary>World entry and client-driven scene loading barriers.</summary>
internal sealed partial class GameRouter
{
    WorldEntryState GetWorldState(RpcContext ctx)
    {
        if (ctx.Session.Items.TryGetValue(WorldStateKey, out var raw) && raw is WorldEntryState existing)
            return existing;

        var created = new WorldEntryState();
        created.SeedHistoryFromGlobal();
        ctx.Session.Items[WorldStateKey] = created;
        return created;
    }

    void ArmWorldEntry4229938(WorldEntryState state)
    {
        lock (state.SyncRoot)
        {
            var next = state.WorldEntryControlGeneration + 1;
            if (next <= 0)
                next = 1;

            state.WorldEntryControlGeneration = next;
            state.WorldEntryControlPending = true;
            state.WorldEntryControlFinalized = false;
            state.WorldEntryControlUnit = Profile.InitialUnitId;
            state.WorldEntryControlTemplate = Profile.InitialSpiritTemplateId;
            state.WorldEntryLoadingCompletedGeneration = 0;
            state.WorldEntryOpeningEndedGeneration = 0;
            state.WorldEntryControlFinalizingGeneration = 0;
            state.WorldEntryLogicProjectionPublishedGeneration = 0;
            state.WorldEntryCurrentMetadataPublishedGeneration = 0;
            state.WorldEntrySceneId4229938 = 0;
            state.WorldEntrySessionId4229938 = 0;
            state.WorldEntryCreateHeroPosition = Profile.WorldSpawn;
            state.WorldEntryCreateHeroFacing = Profile.WorldFacing;
            state.LastReportedPlayerPosition = Profile.WorldSpawn;
            state.LastReportedPlayerRotation = new Vec3(0f, Profile.WorldFacing, 0f);
            state.HasLastReportedPlayerTransform = false;
            state.LastSwitchShowId = 0;
            state.AllBuildBuffsPublished = false;
            state.GaragePublished = false;
            state.AetherVehicleInitSent = false;
            state.InitialActorPresentationPublished = false;
            state.ActiveSpiritUnitId = Profile.InitialUnitId;
            state.ActiveSpiritTemplateId = Profile.InitialSpiritTemplateId;
            state.WorldEntryIsAirportTravel = false;
        }
    }

    async Task SendInitialGameState(RpcContext ctx)
    {
        var state = GetWorldState(ctx);
        if (state.InitialStateSent)
        {
            ctx.Session.Log.Info("[WORLD-MIN] LoginGame repeat ignored");
            return;
        }
        state.InitialStateSent = true;

        await ctx.NotifyAsync(MethodId.SendServerTimeGame, LoginCodec.ServerTime());
        await ctx.NotifyAsync(MethodId.SyncPlayerInfo, RuntimePayloadFactory.MinimalPlayerInfo4229938());
        await SendEnterSceneIfNeeded(ctx);
    }


    async Task SendEnterSceneIfNeeded(RpcContext ctx)
    {
        var state = GetWorldState(ctx);
        if (state.EnterSceneSent)
            return;

        state.EnterSceneSent = true;
        ArmWorldEntry4229938(state);
        state.WorldEntrySwitchShowId = 0;

        var rollback = WorldEntryState.TryGetGlobalCheckpointSecondsAgo(10.0);
        Vec3 spawnPos;
        float spawnFacing;
        if (rollback is not null && (DateTime.UtcNow - rollback.Timestamp).TotalSeconds < 60)
        {
            spawnPos = rollback.Position;
            spawnFacing = rollback.Facing;
            ctx.Session.Log.Info($"[RECONNECT-ROLLBACK] Reconnecting player restored to 10s prior position ({spawnPos.X:F1},{spawnPos.Y:F1},{spawnPos.Z:F1}) facing={spawnFacing:F1}");
        }
        else
        {
            spawnPos = Profile.WorldSpawn;
            spawnFacing = Profile.WorldFacing;
        }

        state.WorldEntryCreateHeroPosition = spawnPos;
        state.WorldEntryCreateHeroFacing = spawnFacing;

        // Minimal mode intentionally does not ask the client to play an authored opening Timeline.
        // Scene assets and native quest/story systems remain entirely client-owned.
        await ctx.NotifyAsync(MethodId.SyncEnterScene, RuntimePayloadFactory.EnterScene(
            Profile.RaidId,
            Profile.SceneInstanceId,
            Profile.UniverseId,
            Profile.InitialUnitId,
            Profile.InitialSpiritTemplateId,
            spawnPos,
            spawnFacing,
            switchShowId: 0,
            isSwitchSpiritShow: false));

        ctx.Session.Log.Info($"[WORLD-MIN] enter generation={state.WorldEntryControlGeneration} raid={Profile.RaidId} instance={Profile.SceneInstanceId} universe={Profile.UniverseId} unit={Profile.InitialUnitId} template={Profile.InitialSpiritTemplateId} pos=({spawnPos.X:0.##},{spawnPos.Y:0.##},{spawnPos.Z:0.##}) opening=false switchShow=0");
    }


    async Task<bool> CommitWorldEntryCreateHeroData4229938(RpcContext ctx, int generation)
    {
        var state = GetWorldState(ctx);
        ulong unitId;
        uint templateId;
        ulong playerPid;
        Vec3 createHeroPosition;
        float createHeroFacing;
        string? reject = null;

        // Port the proven v7 preflight literally: validate the complete canonical identity and
        // CreateHero transform BEFORE claiming/sending the first authority packet. A failure after
        // LogicAgentEnter would leave an orphan authority entity, so this block is fail-closed.
        lock (state.SyncRoot)
        {
            if (!state.WorldEntryControlPending || state.WorldEntryControlFinalized)
                reject = "transaction-not-pending";
            else if (generation <= 0 || generation != state.WorldEntryControlGeneration)
                reject = "generation-mismatch";
            else if (Profile.PlayerPid == 0 || state.WorldEntryControlUnit == 0 || state.WorldEntryControlTemplate == 0)
                reject = "zero-identity";
            else if (state.ActiveSpiritUnitId != state.WorldEntryControlUnit
                  || state.ActiveSpiritTemplateId != state.WorldEntryControlTemplate)
                reject = "active-identity-mismatch";
            else if (state.WorldEntryControlUnit != Profile.InitialUnitId
                  || state.WorldEntryControlTemplate != Profile.InitialSpiritTemplateId)
                reject = "profile-identity-mismatch";
            else if (!ClientConfigRepository.Characters().Any(x =>
                         x.UnitId == state.WorldEntryControlUnit &&
                         x.TemplateId == state.WorldEntryControlTemplate))
                reject = "canonical-roster-row-missing";
            else if (!float.IsFinite(state.WorldEntryCreateHeroPosition.X)
                  || !float.IsFinite(state.WorldEntryCreateHeroPosition.Y)
                  || !float.IsFinite(state.WorldEntryCreateHeroPosition.Z)
                  || !float.IsFinite(state.WorldEntryCreateHeroFacing))
                reject = "non-finite-createhero-transform";
            else if (state.WorldEntryLogicProjectionPublishedGeneration == generation
                  && state.WorldEntryCurrentMetadataPublishedGeneration == generation)
                return true;
            else if (state.WorldEntryLogicProjectionPublishedGeneration != 0
                  || state.WorldEntryCurrentMetadataPublishedGeneration != 0)
                reject = "projection-already-claimed";

            unitId = state.WorldEntryControlUnit;
            templateId = state.WorldEntryControlTemplate;
            playerPid = Profile.PlayerPid;
            createHeroPosition = state.WorldEntryCreateHeroPosition;
            createHeroFacing = state.WorldEntryCreateHeroFacing;

            if (reject is null)
            {
                // Both generation edges are claimed before any send. Partial failure remains
                // fail-closed; a duplicate callback must never replay half of the transaction.
                state.WorldEntryLogicProjectionPublishedGeneration = -generation;
                state.WorldEntryCurrentMetadataPublishedGeneration = -generation;
            }
        }

        if (reject is not null)
        {
            ctx.Session.Log.Warn($"[WORLD-V7] commit rejected generation={generation} reason={reject}");
            return false;
        }

        // Exact proven order from the supplied v7 guide. No sleep, no presentation hydration,
        // no buffs and no weapon/fashion deltas may be interleaved into this quartet.
        await ctx.NotifyAsync(MethodId.SyncLogicAgentEnter, WorldCodec.LogicAgentEnter(unitId));
        await ctx.NotifyAsync(MethodId.SyncManagedLogicAgent, WorldCodec.ManagedLogicAgent(unitId, playerPid, 0));
        await ctx.NotifyAsync(MethodId.SyncRaidBattleUnitSpirit,
            RuntimePayloadFactory.ExistingUnitProjection(unitId, templateId, createHeroPosition, createHeroFacing));

        lock (state.SyncRoot)
        {
            if (state.WorldEntryLogicProjectionPublishedGeneration == -generation)
                state.WorldEntryLogicProjectionPublishedGeneration = generation;
        }

        await ctx.NotifyAsync(MethodId.SyncPlayerCurrentSpirit,
            WorldCodec.CurrentSpirit(playerPid, templateId, unitId, isAgentSwitch: false));

        lock (state.SyncRoot)
        {
            if (state.WorldEntryCurrentMetadataPublishedGeneration == -generation)
                state.WorldEntryCurrentMetadataPublishedGeneration = generation;
            state.CurrentSpiritStateSent = true;
            state.ControlPublished = true;
        }

        ctx.Session.Log.Info($"[HANDOFF-V7] generation={generation} exact=LogicAgentEnter->ManagedLogicAgent->sameID-AOI->CurrentSpirit unit={unitId} template={templateId} presentation=false buffs=false duplicateActor=false");
        return true;
    }


    async Task OnLoadSceneCompleted(RpcContext ctx, ulong sceneId, ulong sessionId)
    {
        var state = GetWorldState(ctx);
        int generation = 0;
        string? reject = null;

        lock (state.SyncRoot)
        {
            if (sceneId == 0 || sessionId == 0)
                reject = "invalid-scene-session";
            else if (!state.WorldEntryControlPending || state.WorldEntryControlFinalized)
                reject = "transaction-not-pending";
            else if (state.WorldEntrySceneId4229938 == 0 && state.WorldEntrySessionId4229938 == 0)
            {
                state.WorldEntrySceneId4229938 = sceneId;
                state.WorldEntrySessionId4229938 = sessionId;
            }
            else if (state.WorldEntrySceneId4229938 != sceneId || state.WorldEntrySessionId4229938 != sessionId)
                reject = "correlation-mismatch";

            if (reject is null)
            {
                generation = state.WorldEntryControlGeneration;
                state.SceneLoadAckSeen = true;
                state.SceneId = sceneId;
            }
        }

        if (reject is not null)
        {
            ctx.Session.Log.Warn($"[WORLD] AskLoadSceneCompleted rejected scene={sceneId} session={sessionId} reason={reject}");
            return;
        }

        if (!await CommitWorldEntryCreateHeroData4229938(ctx, generation))
            return;

        // The confirmed handoff transaction ends with CurrentSpirit. Do not interleave roster/combat/state
        // hydration here; the client must reach AskLoadingFinished with the post-load quartet intact.
        ctx.Session.Log.Info($"[WORLD] load-edge committed generation={generation} scene={sceneId} session={sessionId} logicProjection={state.WorldEntryLogicProjectionPublishedGeneration} currentMetadata={state.WorldEntryCurrentMetadataPublishedGeneration} sceneComplete=false hydration=false");
    }

    Task OnLoadGameResourcesCompleted(RpcContext ctx, ulong sceneId)
    {
        var state = GetWorldState(ctx);
        state.GameResourcesReadySeen = true;
        if (state.SceneId == 0 && sceneId != 0)
            state.SceneId = sceneId;
        return Task.CompletedTask;
    }

    async Task OnLoadingFinished(RpcContext ctx, ulong sceneId, ulong sessionId)
    {
        var state = GetWorldState(ctx);
        int generation = 0;
        string? reject = null;

        lock (state.SyncRoot)
        {
            if (sceneId == 0 || sessionId == 0)
                reject = "invalid-scene-session";
            else if (!state.WorldEntryControlPending || state.WorldEntryControlFinalized)
                reject = state.WorldEntryControlFinalized ? "already-finalized" : "transaction-not-pending";
            else if (sceneId != state.WorldEntrySceneId4229938 || sessionId != state.WorldEntrySessionId4229938)
                reject = "correlation-mismatch";
            else
            {
                generation = state.WorldEntryControlGeneration;
                if (state.WorldEntryLogicProjectionPublishedGeneration != generation
                 || state.WorldEntryCurrentMetadataPublishedGeneration != generation)
                    reject = "v7-handoff-incomplete";
                else if (state.WorldEntryLoadingCompletedGeneration == generation)
                    return;
                else if (state.WorldEntryLoadingCompletedGeneration != 0)
                    reject = "loading-edge-already-claimed";
                else if (state.WorldEntryControlFinalizingGeneration != 0)
                    reject = "finalizer-already-claimed";
                else
                {
                    state.WorldEntryLoadingCompletedGeneration = -generation;
                    state.WorldEntryControlFinalizingGeneration = -generation;
                    state.SceneId = sceneId;
                }
            }
        }

        if (reject is not null)
        {
            ctx.Session.Log.Warn($"[WORLD-V7] AskLoadingFinished rejected scene={sceneId} session={sessionId} generation={generation} reason={reject}");
            return;
        }

        // Supplied guide invariant: SyncSceneLoadCompleted is the FIRST and ONLY S2C gameplay edge
        // of AskLoadingFinished. Do not put buffs/weapon/fashion/current before it. All optional
        // runtime hydration is deferred to the first real gameplay movement after Ready=true.
        await ctx.NotifyAsync(MethodId.SyncSceneLoadCompleted, WorldCodec.SceneLoadCompleted(sceneId));

        lock (state.SyncRoot)
        {
            state.SceneCompletionSent = true;
            if (state.WorldEntryLoadingCompletedGeneration == -generation)
                state.WorldEntryLoadingCompletedGeneration = generation;
            state.LivePlayerProfilePublished = false;
            state.CombatProfilePublished = false;
            state.AccountArmoryPublished = true; // compact referenced subset already arrived in SyncPlayerInfo
            state.FreeRoamReleased = false;
            state.MovementCapabilityPublished = false;
            state.AllBuildBuffsPublished = false;
            state.GaragePublished = false;
            state.AetherVehicleInitSent = false;
            ResetVehicleStory(ctx.Session);
            state.InitialActorPresentationPublished = false;
            state.InitialCapabilityBuffsPublished = false;
            state.WorldEntryControlPending = false;
            state.WorldEntryControlFinalized = true;
            if (state.WorldEntryControlFinalizingGeneration == -generation)
                state.WorldEntryControlFinalizingGeneration = generation;
            state.Ready = true;
            state.WorldEntryIsAirportTravel = false;
        }

        // Normal post-load finalization, deliberately after the terminal scene-ready edge.
        await ctx.NotifyAsync(MethodId.SyncGamePause, WorldCodec.GamePause(false));
        await PublishGarageAsync(ctx);
        await PublishAetherInitAsync(ctx);
        await EnsureVehicleStoryRoot(ctx);
        await PushSessionTimeAsync(ctx.Session);
        await PushSessionWeatherAsync(ctx.Session);

        var activitiesSync = new GameMethods.SyncAllActivities
        {
            activities =
            [
                new GameMethods.AwardActivityItem
                {
                    BaseActivityInfo = new GameMethods.BaseActivityInfo { CfgId = 2684, StartTime = 0, EndTime = 2000000000 },
                    ActivityData = new GameMethods.ActivityData { CfgId = 2684, ShowRedPoint = true, IsOutOfDate = false }
                },
                new GameMethods.AwardActivityItem
                {
                    BaseActivityInfo = new GameMethods.BaseActivityInfo { CfgId = 2685, StartTime = 0, EndTime = 2000000000 },
                    ActivityData = new GameMethods.ActivityData { CfgId = 2685, ShowRedPoint = true, IsOutOfDate = false }
                },
                new GameMethods.AwardActivityItem
                {
                    BaseActivityInfo = new GameMethods.BaseActivityInfo { CfgId = 2686, StartTime = 0, EndTime = 2000000000 },
                    ActivityData = new GameMethods.ActivityData { CfgId = 2686, ShowRedPoint = true, IsOutOfDate = false }
                }
            ]
        };
        await ctx.NotifyAsync(MethodId.SyncAllActivities, activitiesSync);

        // Unlock all scene fog of war on the client across all city/world scenes
        foreach (var fogSceneId in new uint[] { 1, 1001, 10001, state.ActiveRaidId })
        {
            await ctx.NotifyAsync(MethodId.SyncSceneFogMapAllUnlock, new SceneMethods.SyncSceneFogMapAllUnlockInfo
            {
                SceneId = fogSceneId,
                Unlocked = true
            });
        }

        // Initialize story task tracking
        await ctx.NotifyAsync(MethodId.SyncCurrentTask, new SceneMethods.SyncCurrentTaskInfo
        {
            Type = 1,
            TaskId = 10001,
            EventId = 0,
            FirstTime = true,
            Reason = 0
        });

        ctx.Session.Log.Info($"[WORLD-V7] ready generation={generation} scene={sceneId} session={sessionId} exactGuide=true sceneComplete=first actorPresentation=client-owned buffs=deferred-first-movement noStory=false noAOI=true");
    }


    async Task OnLoadedInSameScene(RpcContext ctx)
    {
        var state = GetWorldState(ctx);
        bool firstPresentationEdge;
        lock (state.SyncRoot)
        {
            firstPresentationEdge = !state.SameSceneAckSeen;
            state.SameSceneAckSeen = true;
            if (firstPresentationEdge && Profile.WorldEntryOpeningEnabled && state.WorldEntryControlGeneration > 0)
                state.WorldEntryOpeningEndedGeneration = state.WorldEntryControlGeneration;
        }

        // 4229938 emits AskLoadedInSameScene after every authored same-scene character switch, not
        // only once after login. SyncPlayerLoadRate is therefore an acknowledgement for EACH edge.
        // Keep the opening-generation bookkeeping one-shot, but never suppress the per-switch ack.
        await ctx.NotifyAsync(MethodId.SyncPlayerLoadRate, WorldCodec.PlayerLoadRate());
        ctx.Session.Log.Info($"[SAME-SCENE] load-rate ack=true first={firstPresentationEdge} generation={state.WorldEntryControlGeneration} pendingSwitch={state.PendingSwitchTemplateId}/{state.PendingSwitchUnitId} controlMutation=false");
    }

    internal static async Task<(bool Ok, string Message)> SwitchSceneDirectAsync(
        TcpSession session,
        uint raidId,
        ulong instanceId,
        uint universeId,
        Vec3 position,
        float facing,
        bool isAirport = false)
    {
        if (!session.Items.TryGetValue(WorldStateKey, out var raw) || raw is not WorldEntryState state)
            return (false, "no active world state for session");

        int generation;
        lock (state.SyncRoot)
        {
            var next = state.WorldEntryControlGeneration + 1;
            if (next <= 0) next = 1;
            generation = next;

            state.WorldEntryControlGeneration = next;
            state.WorldEntryControlPending = true;
            state.WorldEntryControlFinalized = false;
            state.WorldEntryControlUnit = Profile.InitialUnitId;
            state.WorldEntryControlTemplate = Profile.InitialSpiritTemplateId;
            state.WorldEntryLoadingCompletedGeneration = 0;
            state.WorldEntryOpeningEndedGeneration = 0;
            state.WorldEntryControlFinalizingGeneration = 0;
            state.WorldEntryLogicProjectionPublishedGeneration = 0;
            state.WorldEntryCurrentMetadataPublishedGeneration = 0;
            state.WorldEntrySceneId4229938 = 0;
            state.WorldEntrySessionId4229938 = 0;
            state.WorldEntryCreateHeroPosition = position;
            state.WorldEntryCreateHeroFacing = facing;
            state.LastReportedPlayerPosition = position;
            state.LastReportedPlayerRotation = new Vec3(0f, facing, 0f);
            state.HasLastReportedPlayerTransform = false;
            state.LastSwitchShowId = 0;
            state.AllBuildBuffsPublished = false;
            state.GaragePublished = false;
            state.AetherVehicleInitSent = false;
            state.InitialActorPresentationPublished = false;
            state.ActiveSpiritUnitId = Profile.InitialUnitId;
            state.ActiveSpiritTemplateId = Profile.InitialSpiritTemplateId;
            state.WorldEntryIsAirportTravel = isAirport;
            state.Ready = false;

            state.ActiveRaidId = raidId;
            state.ActiveInstanceId = instanceId;
            state.ActiveUniverseId = universeId;
        }

        var payload = RuntimePayloadFactory.EnterScene(
            raidId,
            instanceId,
            universeId,
            Profile.InitialUnitId,
            Profile.InitialSpiritTemplateId,
            position,
            facing,
            switchShowId: 0,
            isSwitchSpiritShow: false);

        var bytes = UxSerializer.Serialize(payload);
        await session.NotifyAsync(MethodId.SyncEnterScene, bytes, CancellationToken.None);
        session.Log.Info($"[WORLD] scene-switch generation={generation} raid={raidId} instance={instanceId} universe={universeId} pos=({position.X:0.##},{position.Y:0.##},{position.Z:0.##}) facing={facing:0.##} airport={isAirport}");
        return (true, $"switched to raid={raidId} instance={instanceId} universe={universeId}");
    }

    internal static async Task HandleAirportOrTeleportAsync(TcpSession session)
    {
        if (!session.Items.TryGetValue(WorldStateKey, out var raw) || raw is not WorldEntryState state)
            return;

        uint currentRaid;
        lock (state.SyncRoot)
        {
            currentRaid = state.ActiveRaidId;
        }

        if (currentRaid == 23300888)
        {
            session.Log.Info("[AIRPORT] travel: Main City (23300888) -> Longqi Village (23300999)");
            await SwitchSceneDirectAsync(
                session,
                raidId: 23300999,
                instanceId: 20001223,
                universeId: 76000888,
                position: new Vec3(-4719.8f, 168.5f, -2844.7f),
                facing: 0f,
                isAirport: true);
        }
        else
        {
            session.Log.Info($"[AIRPORT] travel: raid {currentRaid} -> Main City (23300888)");
            await SwitchSceneDirectAsync(
                session,
                raidId: 23300888,
                instanceId: 20001222,
                universeId: 76000888,
                position: new Vec3(-4468.3f, -6.15f, -2597.5f),
                facing: 85.5f,
                isAirport: true);
        }
    }
}
