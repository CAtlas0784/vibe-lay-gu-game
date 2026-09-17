using Ananta.SDK.Network;
using Ananta.SDK.Serialization;
using Ananta.Server.ClientData.Client4229938;
using Ananta.Server.Configuration;
using Ananta.Server.Protocol.Client4229938;
using Ananta.Server.RpcTypes.Client4229938;
using GameMethods = Ananta.Server.RpcTypes.Client4229938.Methods.Game;
using SceneMethods = Ananta.Server.RpcTypes.Client4229938.Methods.GameScene;

namespace Ananta.Server.Handlers.Game;

public sealed record AdminNpcSpawnItem(uint NpcFormworkId, uint PoiActionId);

internal sealed partial class GameRouter
{
    private static long s_nextStaticNpcId = 8_300_000_000_000_000_000L;
    private static long s_nextNpcBelongingId = 8_310_000_000_000_000_000L;

    internal static Task<(bool Ok, string Message, ulong[] Ids)> SpawnStaticNpcAsync(
        TcpSession session, uint npcFormworkId, uint poiActionId)
        => SpawnStaticNpcsAsync(session, [new(npcFormworkId, poiActionId)], 1.5f, 1.5f, 10);

    internal static async Task<(bool Ok, string Message, ulong[] Ids)> SpawnStaticNpcsAsync(
        TcpSession session, IReadOnlyList<AdminNpcSpawnItem> items, float xSpacing, float zSpacing, int maxPerRow)
    {
        if (items.Count < 1)
            return (false, "provide at least one NPC item", []);
        if (!float.IsFinite(xSpacing) || xSpacing < 0f || !float.IsFinite(zSpacing) || zSpacing < 0f)
            return (false, "NPC X/Z spacing must be finite non-negative numbers", []);
        if (maxPerRow < 1)
            return (false, "maximum NPCs per row must be at least 1", []);
        // Validate the entire batch before sending any NPCs.
        foreach (var item in items)
        {
            if (item is null || item.NpcFormworkId > int.MaxValue || !NpcCatalog4229938.TryGet(item.NpcFormworkId, out _))
                return (false, $"unknown NPC formwork {item?.NpcFormworkId}; expected an AgentConfig Id", []);
            if (item.PoiActionId != 0 && !PoiActionCatalog4229938.TryGet(item.PoiActionId, out _))
                return (false, $"unknown NPC POI action {item.PoiActionId}", []);
        }

        var state = GetStateIfExists(session);
        if (state is null)
            return (false, "no player world state", []);
        Vec3 near;
        float facing;
        lock (state.SyncRoot)
        {
            if (!state.Ready || !state.HasLastReportedPlayerTransform || state.PendingTeleportId != 0)
                return (false, "wait until the player is ready in the scene with a known position", []);
            near = state.LastReportedPlayerPosition;
            facing = state.LastReportedPlayerRotation.Y;
        }
        if (!float.IsFinite(near.X) || !float.IsFinite(near.Y) || !float.IsFinite(near.Z) || !float.IsFinite(facing))
            return (false, "player transform is not finite", []);

        var ids = new List<ulong>();
        var yaw = facing * MathF.PI / 180f;
        var npcFacing = (facing + 180f) % 360f;
        if (npcFacing > 180f)
            npcFacing -= 360f;
        try
        {
            // The static-NPC lifecycle creates the logical agent and its pedestrian data.
            await SendAetherInitForNpcAsync(session);
            for (var i = 0; i < items.Count; i++)
            {
                var item = items[i];
                session.Log.Info($"[{i}] Spawn npc formwork: {item.NpcFormworkId}. poi: {item.PoiActionId}");
                var id = unchecked((ulong)Interlocked.Increment(ref s_nextStaticNpcId));
                // Begin directly in front of the player, then lay out a
                // player-relative grid with the requested number of NPCs per row.
                var forward = 3f + (i / maxPerRow) * zSpacing;
                var right = (i % maxPerRow) * xSpacing;
                NpcCatalog4229938.TryGet(item.NpcFormworkId, out var npc);
                PoiActionCatalog4229938.TryGet(item.PoiActionId, out var poi);
                var mainActionId = poi?.SelectMainAction(id) ?? 0;
                var position = new SceneMethods.UxVector3(
                    near.X + MathF.Sin(yaw) * forward + MathF.Cos(yaw) * right,
                    near.Y,
                    near.Z + MathF.Cos(yaw) * forward - MathF.Sin(yaw) * right);
                var agentSyncClientInfo = CreateStaticNpcSyncInfo(item, npc, poi, mainActionId);
                // A standalone battle projection omits persona and static pedestrian POI
                // state. Let AddAetherAIStaticNpc create the complete logical entity;
                // ForceGo requests the full character without replacing that lifecycle.
                await session.NotifyAsync(MethodId.SyncAetherAIStaticNpcAddData,
                    UxSerializer.Serialize(new GameMethods.ClientStaticNpcInitData4229938
                    {
                        StaticNpcInfoId = item.NpcFormworkId,
                        NpcFormworkId = item.NpcFormworkId,
                        AgentPersonaId = npc.AgentPersonaId,
                        SPoiActionId = 0,
                        CPoiActionId = item.PoiActionId,
                        UrbanDiversityId = 88888000,
                        IgnoreAllStim = false,
                        TaskRelated = false,
                        NpcPid = (int)item.NpcFormworkId,
                        AgentSyncClientInfo = agentSyncClientInfo,
                        ForceGo = true,
                        SourceType = 1, // UX.Game.StaticNpcSourceType.Spoon (4229938).
                        Id = id,
                        Position = position,
                        Facing = npcFacing,
                        EulerAngles = new SceneMethods.UxVector3(0, npcFacing, 0),
                    }), CancellationToken.None);
                ids.Add(id);
                lock (state.SyncRoot)
                    state.StaticNpcPreparedPlotEvents[id] = 0;
                // Static creation registers the logical entity and its sync module,
                // but does not assign a simulation owner. Without this notification,
                // LogicAgentModule.ApplyMasterPolicy(false) disables the full-model
                // state machine after the ECS-to-GO POI handoff.
                await session.NotifyAsync(MethodId.SyncManagedLogicAgent,
                    UxSerializer.Serialize(WorldCodec.ManagedLogicAgent(id, Profile.PlayerPid, 0)), CancellationToken.None);
                if (poi is { UsageId: not 0 })
                {
                    // The usage loader requires owned items before it can bind them.
                    // Inventory is cached on AgentData; usage is retained by the ECS
                    // handle and transferred by ECSToGOBelongingTransition.
                    await session.NotifyAsync(MethodId.SyncAgentBelongings,
                        UxSerializer.Serialize(new GameMethods.SyncNpcBelongings4229938
                        {
                            Id = id,
                            Items = poi.BelongingSceneItems.Select(configId => new GameMethods.NpcBelongingItem4229938
                            {
                                InstanceId = unchecked((ulong)Interlocked.Increment(ref s_nextNpcBelongingId)),
                                ConfigId = configId,
                            }).ToList(),
                            DebugAgentId = item.NpcFormworkId,
                        }), CancellationToken.None);
                    await session.NotifyAsync(MethodId.SyncAgentUseBelongingChanged,
                        UxSerializer.Serialize(new GameMethods.SyncNpcBelongingUsage4229938
                        {
                            Id = id,
                            UsageIds = [poi.UsageId],
                        }), CancellationToken.None);
                    session.Log.Info($"[NPC] POI_BELONGINGS_SENT entity={id} poi={poi.Id} usage={poi.UsageId} items={string.Join(',', poi.BelongingSceneItems)}");
                }
                // Store the active POI in the logical POI module at normal playback speed.
                // Do not periodically replay it: reactions must be able to interrupt it.
                if (item.PoiActionId != 0)
                    await session.NotifyAsync(MethodId.IGameSceneToClient_SyncAgentPlayPOIAction,
                        UxSerializer.Serialize(new GameMethods.ClientNpcPoiActionData4229938
                        {
                            Id = id,
                            CPoiActionId = item.PoiActionId,
                            IsActive = true,
                            PlayPoiSpeed = 1f,
                        }), CancellationToken.None);
                session.Log.Info($"[NPC] STATIC_PEDESTRIAN_SPAWN_SENT formwork={item.NpcFormworkId} model={npc.GeneralModelId} persona={npc.AgentPersonaId} poiAction={item.PoiActionId} action={mainActionId}/{poi?.MainActionGroup ?? 0} behaviorActionConfig={npc.BehaviorActionConfigId} activityConfig={agentSyncClientInfo.AgentDataSetsActivityCfgId} ai={npc.AiSettingId} entity={id} managedPid={Profile.PlayerPid} spoon={agentSyncClientInfo.SpoonAgentId} forceGo=true ignoreStim=false poiSpeed=1 fashion={agentSyncClientInfo.FashionSuitId} pos={position.X},{position.Y},{position.Z} playerPos={near}");
            }
        }
        catch (Exception ex)
        {
            return (false, $"sent {ids.Count}/{items.Count} NPCs before send failed: {ex.Message}", ids.ToArray());
        }
        return (true, $"sent spawn for {ids.Count} static NPC(s) in front of you", ids.ToArray());
    }

    private static async Task SendAetherInitForNpcAsync(TcpSession session)
    {
        var settings = PrivateServerConfigStore.Current.Gameplay.Vehicles;
        var activeRaidId = GetStateIfExists(session)?.ActiveRaidId ?? Profile.RaidId;
        var hasZoneGraph = activeRaidId == PrivateServerConfigStore.Current.World.RaidId;
        await session.NotifyAsync(MethodId.SyncAetherAIInitDatas, UxSerializer.Serialize(new SceneMethods.AetherAIInitData
        {
            RaidId = activeRaidId,
            HasZoneGraph = hasZoneGraph,
            ZoneStorageDataHandle = hasZoneGraph ? settings.ZoneStorageDataHandle : 0,
            Intersections = [],
        }), CancellationToken.None);
        session.Log.Info($"[AETHER] init sent raid={activeRaidId} zoneGraph={hasZoneGraph} intersections=empty");
    }

    internal static GameMethods.NpcAgentSyncClientInfo4229938 CreateStaticNpcSyncInfo(
        AdminNpcSpawnItem item, NpcCatalogEntry4229938 npc,
        PoiActionCatalogEntry4229938? poi, uint mainActionId)
    {
        return new GameMethods.NpcAgentSyncClientInfo4229938
        {
            stimIDList = new List<int>(),
            CanBeExaminedByPolice = true,
            indoorList = new(),
            roomIds = new List<int>(),
            SpoonAgentId = (int)item.NpcFormworkId,
            treeName = "PedBase",
            petPerformData = "",
            spawnEffectId = new List<uint>(),
            randomModelCfgId = 0,
            LeaveDistance = 10000,
            approachDistance = 10000,
            FashionSuitId = 11190001,
            actionId = mainActionId,
            actionGroupId = poi?.MainActionGroup ?? 0,
            initPoiActionId = item.PoiActionId,
            useDefaultPoiOnReturn = item.PoiActionId != 0,
            returnPoiActionIds = item.PoiActionId == 0 ? [] : [item.PoiActionId],
            AgentDataSetsActivityCfgId = 0,
            InteractId = npc.InteractSettingId,
            AISetting = npc.AiSettingId,
            beHitType = 1, // Civilian hit reaction without combat damage.
            agentStimType = 0,
            forbidStimulateType = 0,
            isAttackInSafeMode = true,
        };
    }
}
