using Ananta.SDK.Rpc;
using Ananta.Server.Protocol.Client4229938;
using Ananta.Server.RpcTypes.Client4229938;
using GameMethods = Ananta.Server.RpcTypes.Client4229938.Methods.Game;
using SceneMethods = Ananta.Server.RpcTypes.Client4229938.Methods.GameScene;

namespace Ananta.Server.Handlers.Game;

/// <summary>Only RPC endpoints used by the maintained 4229938 private-server feature set.</summary>
internal sealed partial class GameRouter
{
    [Handler(MethodId.LoginGame, HandlerPacketKind.Notify)]
    private Task LoginGame(Connection conn, UxRpcMessage msg)
        => SendInitialGameState(msg.Context);

    [Handler(MethodId.RequestGameSceneData, HandlerPacketKind.Notify)]
    private Task RequestGameSceneData(Connection conn, UxRpcMessage msg)
        => SendEnterSceneIfNeeded(msg.Context);

    [Handler(MethodId.GetServerTimeGame)]
    private async Task GetServerTime(Connection conn, UxRpcMessage msg)
    {
        if (msg.IsInvoke)
        {
            await conn.ReturnEmptyOkAsync(msg);
            return;
        }
        var args = msg.GetArgs<GameMethods.GetServerTime>();
        await conn.NotifyAsync(MethodId.SendServerTimeGame, LoginCodec.ServerTime(args.clientUnixTime));
    }

    [Handler(MethodId.AskAllSpiritPanelData, HandlerPacketKind.Invoke)]
    private Task AskAllSpiritPanelData(Connection conn, UxRpcMessage msg)
        => conn.ReturnAsync(msg, RuntimePayloadFactory.MinimalAllSpiritPanelData4229938());

    [Handler(MethodId.GetSpriteToken, HandlerPacketKind.Invoke)]
    private Task GetSpriteToken4229938(Connection conn, UxRpcMessage msg)
        => conn.ReturnAsync(msg, new GameMethods.SpriteToken4229938
        {
            Token = string.Empty,
            ExpireTimeStamp = 0
        });

    [Handler(MethodId.CheckPSOPermissions, HandlerPacketKind.Invoke)]
    private Task CheckPsoPermissions(Connection conn, UxRpcMessage msg)
        => conn.ReturnAsync(msg, false);

    [Handler(MethodId.AskSetGamePause, HandlerPacketKind.Invoke)]
    private async Task AskSetGamePause(Connection conn, UxRpcMessage msg)
    {
        var args = msg.GetArgs<SceneMethods.AskSetGamePause>();
        await conn.ReturnEmptyOkAsync(msg);
        await conn.NotifyAsync(MethodId.SyncGamePause, new SceneMethods.SyncGamePause { pause = args.value });
    }

    [Handler(MethodId.AskLoadSceneCompleted, HandlerPacketKind.Notify)]
    private Task AskLoadSceneCompleted(Connection conn, UxRpcMessage msg)
    {
        var args = msg.GetArgs<SceneMethods.AskLoadSceneCompleted>();
        return OnLoadSceneCompleted(msg.Context, args.sceneId, args.sessionId);
    }

    [Handler(MethodId.AskLoadGameResCompleted, HandlerPacketKind.Notify)]
    private Task AskLoadGameResCompleted(Connection conn, UxRpcMessage msg)
    {
        var args = msg.GetArgs<SceneMethods.AskLoadGameResCompleted>();
        return OnLoadGameResourcesCompleted(msg.Context, args.sceneId);
    }

    [Handler(MethodId.AskLoadingFinished, HandlerPacketKind.Invoke)]
    private async Task AskLoadingFinished(Connection conn, UxRpcMessage msg)
    {
        var args = msg.GetArgs<SceneMethods.AskLoadingFinished>();
        await conn.ReturnEmptyOkAsync(msg);
        await OnLoadingFinished(msg.Context, args.sceneId, args.sessionId);
    }

    [Handler(MethodId.AskLoadedInSameScene, HandlerPacketKind.Notify)]
    private Task AskLoadedInSameScene(Connection conn, UxRpcMessage msg)
        => OnLoadedInSameScene(msg.Context);

    [Handler(MethodId.AskTeleport, HandlerPacketKind.Invoke)]
    private async Task AskTeleport(Connection conn, UxRpcMessage msg)
    {
        var args = msg.GetArgs<SceneMethods.AskTeleportArgs>();
        if (conn.Session.Items.TryGetValue(WorldStateKey, out var raw) && raw is WorldEntryState state)
        {
            lock (state.SyncRoot)
            {
                state.PendingTeleportPosition = new Vec3(args.option.position.X, args.option.position.Y, args.option.position.Z);
                state.PendingTeleportFacing = args.option.facing;
                state.PendingTeleportId = args.option.teleportId;
                state.LastReportedPlayerPosition = state.PendingTeleportPosition;
                state.LastReportedPlayerRotation = new Vec3(0f, args.option.facing, 0f);
                state.HasLastReportedPlayerTransform = true;
            }
        }
        await conn.ReturnEmptyOkAsync(msg);
        var sync = new SceneMethods.SyncPreTeleportOption { option = args.option };
        await conn.NotifyAsync(MethodId.SyncPreTeleportOption, sync);
    }

    [Handler(MethodId.ReportPreTeleportFinish, HandlerPacketKind.Invoke)]
    private async Task ReportPreTeleportFinish(Connection conn, UxRpcMessage msg)
    {
        await conn.ReturnEmptyOkAsync(msg);

        if (conn.Session.Items.TryGetValue(WorldStateKey, out var raw) && raw is WorldEntryState state)
        {
            Vec3 targetPos;
            float targetFacing;
            ulong teleportId;
            ulong unitId;
            lock (state.SyncRoot)
            {
                targetPos = state.PendingTeleportPosition;
                targetFacing = state.PendingTeleportFacing;
                teleportId = state.PendingTeleportId;
                unitId = state.ActiveSpiritUnitId;
            }

            var sync = new SceneMethods.SyncTeleport
            {
                option = new SceneMethods.TeleportOption
                {
                    teleportId = teleportId,
                    Position = new SceneMethods.UxVector3(targetPos.X, targetPos.Y, targetPos.Z),
                    Facing = targetFacing,
                    IsSwitchScene = false,
                    WaitTaskResource = false,
                    MapEntranceId = 0
                }
            };
            await conn.NotifyAsync(MethodId.SyncTeleport, sync);

            if (unitId != 0)
            {
                await conn.NotifyAsync(MethodId.SyncUnitPositionAndFacing,
                    WorldCodec.PositionAndFacing(unitId, targetPos, targetFacing));
            }
        }
    }

    [Handler(MethodId.ReportPostTeleportFinish, HandlerPacketKind.Notify)]
    private Task ReportPostTeleportFinish(Connection conn, UxRpcMessage msg)
        => Task.CompletedTask;

    [Handler(MethodId.AskPlayerChangePositionByScenePortal, HandlerPacketKind.Invoke)]
    private Task AskPlayerChangePositionByScenePortal(Connection conn, UxRpcMessage msg)
        => conn.ReturnEmptyOkAsync(msg);

    [Handler(MethodId.AskPublicSwitchToPublicScene, HandlerPacketKind.Invoke)]
    private async Task AskPublicSwitchToPublicScene(Connection conn, UxRpcMessage msg)
    {
        var args = msg.GetArgs<SceneMethods.AskPublicSwitchToPublicSceneArgs>();
        await conn.ReturnEmptyOkAsync(msg);

        uint raidId = args.raidid;
        ulong instanceId = raidId == 23300999 ? 20001223UL : 20001222UL;
        uint universeId = 76000888;
        Vec3 pos = raidId == 23300999 ? new Vec3(-4719.8f, 168.5f, -2844.7f) : new Vec3(2588.66f, 269.0f, -637.28f);

        await SwitchSceneDirectAsync(conn.Session, raidId, instanceId, universeId, pos, 0f, isAirport: true);
    }

    [Handler(MethodId.AskGadgetDoorTransfer, HandlerPacketKind.Notify)]
    private Task AskGadgetDoorTransfer(Connection conn, UxRpcMessage msg)
        => HandleAirportOrTeleportAsync(conn.Session);

    [Handler(MethodId.AskSwitchSpirit)]
    private async Task AskSwitchSpirit(Connection conn, UxRpcMessage msg)
    {
        var args = msg.GetArgs<SceneMethods.AskSwitchSpirit>();
        await conn.ReturnEmptyOkAsync(msg);
        await OnSwitchSpirit(msg.Context, args.spiritId);
    }

    [Handler(MethodId.AskSwitchWeapon, HandlerPacketKind.Notify)]
    private Task AskSwitchWeapon(Connection conn, UxRpcMessage msg)
    {
        var args = msg.GetArgs<SceneMethods.AskSwitchWeapon>();
        return OnSwitchWeapon(msg.Context, args.index);
    }

    [Handler(MethodId.AskSwitchFightStyle, HandlerPacketKind.Invoke)]
    private async Task AskSwitchFightStyle(Connection conn, UxRpcMessage msg)
    {
        var args = msg.GetArgs<GameMethods.AskSwitchFightStyle>();
        await conn.ReturnEmptyOkAsync(msg);
        await OnSwitchFightStyle(msg.Context, args.spiritId, args.fightStyleTypeId, args.fightStyleId);
    }

    [Handler(MethodId.AskSetWeaponFightStyle, HandlerPacketKind.Invoke)]
    private async Task AskSetWeaponFightStyle(Connection conn, UxRpcMessage msg)
    {
        var args = msg.GetArgs<GameMethods.AskSetWeaponFightStyle>();
        await conn.ReturnEmptyOkAsync(msg);
        await OnSetWeaponFightStyle(msg.Context, args.weaponInstanceId, args.fightStyleId);
    }

    [Handler(MethodId.AskLoadWeaponToSlot, HandlerPacketKind.Invoke)]
    private async Task AskLoadWeaponToSlot(Connection conn, UxRpcMessage msg)
    {
        var args = msg.GetArgs<GameMethods.AskLoadWeaponToSlot>();
        await conn.ReturnEmptyOkAsync(msg);
        await OnLoadWeaponToSlot(msg.Context, args.spiritId, args.weaponId, args.slotIndex);
    }

    [Handler(MethodId.AskDepositSpiritWeapon, HandlerPacketKind.Invoke)]
    private async Task AskDepositSpiritWeapon(Connection conn, UxRpcMessage msg)
    {
        var args = msg.GetArgs<GameMethods.AskDepositSpiritWeapon>();
        await conn.ReturnEmptyOkAsync(msg);
        await OnDepositSpiritWeapon(msg.Context, args.spiritId, args.slotIndex);
    }

    [Handler(MethodId.AskExchangeWeaponSlot, HandlerPacketKind.Invoke)]
    private async Task AskExchangeWeaponSlot(Connection conn, UxRpcMessage msg)
    {
        var args = msg.GetArgs<GameMethods.AskExchangeWeaponSlot>();
        await conn.ReturnEmptyOkAsync(msg);
        await OnExchangeWeaponSlot(msg.Context, args.fromSpirit, args.fromIndex, args.toSpirit, args.toIndex);
    }

    [Handler(MethodId.AskSetWeaponSkins)]
    private Task AskSetWeaponSkins(Connection conn, UxRpcMessage msg)
        => conn.ReturnEmptyOkAsync(msg);

    [Handler(MethodId.AskSyncWeaponSkinToSpirits)]
    private Task AskSyncWeaponSkinToSpirits(Connection conn, UxRpcMessage msg)
        => conn.ReturnEmptyOkAsync(msg);

    [Handler(MethodId.AskAddClientBuff)]
    private async Task AskAddClientBuff(Connection conn, UxRpcMessage msg)
    {
        var args = msg.GetArgs<SceneMethods.AskAddClientBuff>();
        await conn.ReturnEmptyOkAsync(msg);
        await OnClientBuffAdd(msg.Context, args.unitId, args.buffId);
    }

    [Handler(MethodId.AskRemoveClientBuff)]
    private async Task AskRemoveClientBuff(Connection conn, UxRpcMessage msg)
    {
        var args = msg.GetArgs<SceneMethods.AskRemoveClientBuff>();
        await conn.ReturnEmptyOkAsync(msg);
        await OnClientBuffRemove(msg.Context, args.unitId, args.buffId);
    }

    [Handler(MethodId.AskEnterFeiSuoCrouch, HandlerPacketKind.Notify)]
    private Task AskEnterFeiSuoCrouch(Connection conn, UxRpcMessage msg)
        => OnEnterFeiSuoCrouch(msg.Context);

    [Handler(MethodId.AskFeiSuoSuccess, HandlerPacketKind.Invoke)]
    private async Task AskFeiSuoSuccess(Connection conn, UxRpcMessage msg)
    {
        var args = msg.GetArgs<SceneMethods.AskFeiSuoSuccess>();
        await OnFeiSuoSuccess(msg.Context, args.feiSuoId);
        await conn.ReturnEmptyOkAsync(msg);
    }

    [Handler(MethodId.AskLeaveFeiSuoCrouch, HandlerPacketKind.Notify)]
    private Task AskLeaveFeiSuoCrouch(Connection conn, UxRpcMessage msg)
        => OnLeaveFeiSuoCrouch(msg.Context);

    [Handler(MethodId.AskClientUseCommonSkill, HandlerPacketKind.Invoke)]
    [Handler(MethodId.AskUseSkill, HandlerPacketKind.Invoke)]
    private Task AskUseSkill(Connection conn, UxRpcMessage msg)
    {
        var args = msg.GetArgs<SceneMethods.AskUseSkill>();
        return OnClientUseSkill(msg.Context, args.data);
    }

    [Handler(MethodId.AskSkillUseWeaponDurability, HandlerPacketKind.Notify)]
    private Task AskSkillUseWeaponDurability(Connection conn, UxRpcMessage msg)
    {
        var args = msg.GetArgs<SceneMethods.AskSkillUseWeaponDurability>();
        return OnSkillUseWeaponDurability(msg.Context, args.skillid, args.triggerindex);
    }

    [Handler(MethodId.AskWeaponEquipBullets, HandlerPacketKind.Invoke)]
    private async Task AskWeaponEquipBullets(Connection conn, UxRpcMessage msg)
    {
        var args = msg.GetArgs<SceneMethods.AskWeaponEquipBullets>();
        await conn.ReturnEmptyOkAsync(msg);
        await OnWeaponEquipBullets(msg.Context, args.weaponinstanceid, args.bulletid);
    }

    [Handler(MethodId.ReportSkillEnd, HandlerPacketKind.Notify)]
    private Task ReportSkillEnd(Connection conn, UxRpcMessage msg)
    {
        var args = msg.GetArgs<SceneMethods.ReportSkillEnd>();
        return OnReportSkillEnd(msg.Context, args);
    }

    [Handler(MethodId.AskMultipleSkillHit2, HandlerPacketKind.Notify)]
    private Task AskMultipleSkillHit2(Connection conn, UxRpcMessage msg)
    {
        var args = msg.GetArgs<SceneMethods.AskMultipleSkillHit2>();
        return OnSkillHit(msg.Context, args.skillHitData);
    }

    [Handler(MethodId.AskInterruptSkillExecute, HandlerPacketKind.Invoke)]
    [Handler(MethodId.AskInterruptSkillExecuteStiff, HandlerPacketKind.Invoke)]
    [Handler(MethodId.AskSkillExecuteEnd, HandlerPacketKind.Invoke)]
    [Handler(MethodId.AskSkillExecute, HandlerPacketKind.Invoke)]
    private static Task AcceptCombatInvoke(Connection conn, UxRpcMessage msg)
        => conn.ReturnEmptyOkAsync(msg);

    [Handler(MethodId.AskSkillDestructibleCreate, HandlerPacketKind.Invoke)]
    private static Task AskSkillDestructibleCreate(Connection conn, UxRpcMessage msg)
        => conn.ReturnAsync(msg, 0UL);

    [Handler(MethodId.AskReportLogicAgentSyncData)]
    [Handler(MethodId.AskUnitMoveActionSimple, HandlerPacketKind.Notify)]
    [Handler(MethodId.AskUnitMoveActionSimpleWithGround, HandlerPacketKind.Notify)]
    [Handler(MethodId.AskUnitMoveActionWithGround, HandlerPacketKind.Notify)]
    [Handler(MethodId.AskUnitMoveAction, HandlerPacketKind.Notify)]
    private async Task MovementReport(Connection conn, UxRpcMessage msg)
    {
        IEnumerable<SceneMethods.LogicAgentSyncData>? samples = msg.MethodId switch
        {
            MethodId.AskReportLogicAgentSyncData => msg.GetArgs<SceneMethods.AskReportLogicAgentSyncData>().list,
            MethodId.AskUnitMoveActionSimple => msg.GetArgs<SceneMethods.AskUnitMoveActionSimple>().actions.Select(x =>
                new SceneMethods.LogicAgentSyncData { AgentId = x.UnitId, Position = x.Pos, Rotation = x.Rot }),
            MethodId.AskUnitMoveActionSimpleWithGround => msg.GetArgs<SceneMethods.AskUnitMoveActionSimpleWithGround>().actions.Select(x =>
                new SceneMethods.LogicAgentSyncData { AgentId = x.UnitId, Position = x.Pos, Rotation = x.Rot }),
            MethodId.AskUnitMoveAction => msg.GetArgs<SceneMethods.AskUnitMoveAction>().actions.Select(x =>
                new SceneMethods.LogicAgentSyncData { AgentId = x.UnitId, Position = x.Pos, Rotation = x.Rot }),
            MethodId.AskUnitMoveActionWithGround => msg.GetArgs<SceneMethods.AskUnitMoveActionWithGround>().actions.Select(x =>
                new SceneMethods.LogicAgentSyncData { AgentId = x.UnitId, Position = x.Pos, Rotation = x.Rot }),
            _ => null
        };

        await conn.ReturnEmptyOkAsync(msg);
        await OnMovementReport(msg.Context, samples);
    }

    [Handler(MethodId.AskSetSpiritFashionsWithSource, HandlerPacketKind.Invoke)]
    private Task AskSetSpiritFashionsWithSource(Connection conn, UxRpcMessage msg)
        => HandleAskSetSpiritFashionsWithSourceAsync(conn, msg);

    [Handler(MethodId.AskSetSpiritFashions, HandlerPacketKind.Invoke)]
    private Task AskSetSpiritFashions(Connection conn, UxRpcMessage msg)
        => HandleAskSetSpiritFashionsAsync(conn, msg);

    [Handler(MethodId.AskModifySpiritWearFashionsOnlyWearWithSource, HandlerPacketKind.Invoke)]
    private Task AskModifySpiritWearFashionsOnlyWearWithSource(Connection conn, UxRpcMessage msg)
        => HandleAskModifySpiritWearFashionsOnlyWearWithSourceAsync(conn, msg);

    [Handler(MethodId.AskModifySpiritWearFashionsOnlyWear, HandlerPacketKind.Invoke)]
    private Task AskModifySpiritWearFashionsOnlyWear(Connection conn, UxRpcMessage msg)
        => HandleAskModifySpiritWearFashionsOnlyWearAsync(conn, msg);

    [Handler(MethodId.AskModifySpiritWearFashionsWithSource, HandlerPacketKind.Invoke)]
    private Task AskModifySpiritWearFashionsWithSource(Connection conn, UxRpcMessage msg)
        => HandleAskModifySpiritWearFashionsWithSourceAsync(conn, msg);

    [Handler(MethodId.AskModifySpiritWearFashionEditInfosWithSource, HandlerPacketKind.Invoke)]
    private Task AskModifySpiritWearFashionEditInfosWithSource(Connection conn, UxRpcMessage msg)
        => HandleAskModifySpiritWearFashionEditInfosWithSourceAsync(conn, msg);

    [Handler(MethodId.AskModifySpiritWearFashionEditInfos, HandlerPacketKind.Invoke)]
    private Task AskModifySpiritWearFashionEditInfos(Connection conn, UxRpcMessage msg)
        => HandleAskModifySpiritWearFashionEditInfosAsync(conn, msg);

    [Handler(MethodId.AskSetSpiritWearFashionHiddenPartsWithSource, HandlerPacketKind.Invoke)]
    private Task AskSetSpiritWearFashionHiddenPartsWithSource(Connection conn, UxRpcMessage msg)
        => HandleAskSetSpiritWearFashionHiddenPartsWithSourceAsync(conn, msg);

    [Handler(MethodId.AskSetSpiritWearFashionHiddenParts, HandlerPacketKind.Invoke)]
    private Task AskSetSpiritWearFashionHiddenParts(Connection conn, UxRpcMessage msg)
        => HandleAskSetSpiritWearFashionHiddenPartsAsync(conn, msg);

    [Handler(MethodId.AskOpenOrCloseFashionPanel, HandlerPacketKind.Invoke)]
    [Handler(MethodId.AskUnlockFashionColoringSlot, HandlerPacketKind.Invoke)]
    [Handler(MethodId.AskUnlockFashionSuitSlot, HandlerPacketKind.Invoke)]
    [Handler(MethodId.AskApplyFashionColoringSchemeInf, HandlerPacketKind.Invoke)]
    [Handler(MethodId.AskSetFashionColoringSchemeInfos, HandlerPacketKind.Invoke)]
    [Handler(MethodId.AskFavoriteFashions, HandlerPacketKind.Invoke)]
    [Handler(MethodId.AskFavoriteFashionSuits, HandlerPacketKind.Invoke)]
    [Handler(MethodId.AskReadFashions, HandlerPacketKind.Invoke)]
    [Handler(MethodId.AskReadFashionSuits, HandlerPacketKind.Invoke)]
    [Handler(MethodId.AskSetSpiritFashionVariantPreference, HandlerPacketKind.Invoke)]
    [Handler(MethodId.AskTradeRecycleFashion, HandlerPacketKind.Invoke)]
    [Handler(MethodId.AskClearSwitchInFashionCache, HandlerPacketKind.Invoke)]
    private static Task AcceptFashionInvoke(Connection conn, UxRpcMessage msg)
        => conn.ReturnEmptyOkAsync(msg);

    [Handler(MethodId.AskRecommendGetTopWearFashionTag, HandlerPacketKind.Invoke)]
    private static Task AskRecommendGetTopWearFashionTag(Connection conn, UxRpcMessage msg)
        => conn.ReturnAsync(msg, 0u);

    [Handler(MethodId.AskActivityCancelRedPoint, HandlerPacketKind.Invoke)]
    private static Task AskActivityCancelRedPoint(Connection conn, UxRpcMessage msg)
        => conn.ReturnEmptyOkAsync(msg);

    // Story & Quest Task Handlers
    [Handler(MethodId.AskAcceptTask, HandlerPacketKind.Invoke)]
    private static Task AskAcceptTask(Connection conn, UxRpcMessage msg)
    {
        conn.Log.Info("[TASK] AskAcceptTask accepted");
        return conn.ReturnEmptyOkAsync(msg);
    }

    [Handler(MethodId.AskAcceptAndSetCurrentTask, HandlerPacketKind.Invoke)]
    private static Task AskAcceptAndSetCurrentTask(Connection conn, UxRpcMessage msg)
    {
        conn.Log.Info("[TASK] AskAcceptAndSetCurrentTask accepted");
        return conn.ReturnEmptyOkAsync(msg);
    }

    [Handler(MethodId.AskSubmitTask, HandlerPacketKind.Invoke)]
    private static Task AskSubmitTask(Connection conn, UxRpcMessage msg)
    {
        conn.Log.Info("[TASK] AskSubmitTask accepted");
        return conn.ReturnEmptyOkAsync(msg);
    }
}

