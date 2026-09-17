using Ananta.SDK.Rpc;
using Ananta.Server.Protocol.Client4229938;
using Ananta.Server.Handlers.LoginGate;

namespace Ananta.Server.Handlers.Game;

/// <summary>
/// Build 4229938 private-server surface: world entry, direct character switching,
/// combat, traversal/buffs, vehicles and movement. Everything else falls back to typed-neutral RPC replies.
/// </summary>
internal sealed partial class GameRouter
{
    internal const string WorldStateKey = "client4229938-world";
    private readonly GateSessionHub? _gateSessions;

    internal GameRouter(GateSessionHub? gateSessions = null) => _gateSessions = gateSessions;

    private static readonly HashSet<uint> Enabled4229938MethodIds = new()
    {
        // Login / world-entry barriers.
        MethodId.LoginGame,
        MethodId.RequestGameSceneData,
        MethodId.GetServerTimeGame,
        MethodId.GetSpriteToken,
        MethodId.CheckPSOPermissions,
        MethodId.AskSetGamePause,
        MethodId.AskLoadSceneCompleted,
        MethodId.AskLoadGameResCompleted,
        MethodId.AskLoadingFinished,
        MethodId.AskLoadedInSameScene,

        // Roster + direct character switching.
        MethodId.AskAllSpiritPanelData,
        MethodId.AskSwitchSpirit,

        // Combat / weapon sandbox.
        MethodId.AskSwitchWeapon,
        MethodId.AskSwitchFightStyle,
        MethodId.AskSetWeaponFightStyle,
        MethodId.AskLoadWeaponToSlot,
        MethodId.AskDepositSpiritWeapon,
        MethodId.AskExchangeWeaponSlot,
        MethodId.AskClientUseCommonSkill,
        MethodId.AskUseSkill,
        MethodId.AskSkillUseWeaponDurability,
        MethodId.AskWeaponEquipBullets,
        MethodId.AskSetWeaponSkins,
        MethodId.AskSyncWeaponSkinToSpirits,
        MethodId.ReportSkillEnd,
        MethodId.AskMultipleSkillHit2,
        MethodId.AskInterruptSkillExecute,
        MethodId.AskInterruptSkillExecuteStiff,
        MethodId.AskSkillExecuteEnd,
        MethodId.AskSkillExecute,
        MethodId.AskSkillDestructibleCreate,

        // Client-decided traversal/web buffs.
        MethodId.AskAddClientBuff,
        MethodId.AskRemoveClientBuff,
        MethodId.AskEnterFeiSuoCrouch,
        MethodId.AskFeiSuoSuccess,
        MethodId.AskLeaveFeiSuoCrouch,

        // Live transform tracking.
        MethodId.AskReportLogicAgentSyncData,
        MethodId.AskUnitMoveActionSimple,
        MethodId.AskUnitMoveActionSimpleWithGround,
        MethodId.AskUnitMoveActionWithGround,
        MethodId.AskUnitMoveAction,

        // Vehicles: summon + owned fleet + client-driven drive loop + S011 boarding story.
        MethodId.AskSummonVehicle,
        MethodId.AskGetUnlockedVehicles,
        MethodId.SyncStoryCoreClientInfo,
        MethodId.AskClaimVehicleSeat,
        MethodId.AskReleaseVehicleSeat,
        MethodId.AskChangeCanMoveToDriveSeat,
        MethodId.AskPlayerStartEnterOrExitVehicle,
        MethodId.AskPlayerFinishEnterOrExitVehicle,
        MethodId.AskVehicleMove,
        MethodId.AskVehicleStartMove,
        MethodId.AskVehicleStopMove,
        MethodId.AskVehicleHorn,
        MethodId.AskEnterVehicleIndoor,
        MethodId.AskExitVehicleIndoor,
        MethodId.ReportDrivingVehicle,
        MethodId.AskKillVehicle,
        MethodId.VehicleDriveStateChange,
        MethodId.AskChangeGoVehicleDriveState,
        MethodId.AskVehicleDeadEnd,
        MethodId.AskVehicleNitro,
        MethodId.AskVehicleStuck,
        MethodId.AskVehicleHit,
        MethodId.AskVehicleHitEnd,

        // GM console (ALT+F1): C2S invokes, server records real ids.
        MethodId.GmSpawnVehicle,
        MethodId.GmAddEnemyWithPosition,
        MethodId.GmAddEnemy,
        MethodId.GmAddEnemyByPlayer,
        MethodId.GmTeleportXYZ,
        MethodId.DavinciCode,
        MethodId.GmDaVinciCode,

        // Time of day: client-driven UI (accept + remember) + debug-panel slider push.
        MethodId.AskPassingTime,
        MethodId.GmPassingTime,
        MethodId.GmSetTime,
        MethodId.GmFixRaidTime,
        MethodId.ChangePersonalTimeSetting,
        MethodId.AddPersonalTimeSetting,
        MethodId.GmSetWeather,
        MethodId.GmSetWeatherParam,

        // Fast travel, teleport, and scene transfers.
        MethodId.AskTeleport,
        MethodId.ReportPreTeleportFinish,
        MethodId.ReportPostTeleportFinish,
        MethodId.AskGadgetDoorTransfer,
        MethodId.AskPlayerChangePositionByScenePortal,
        MethodId.AskPublicSwitchToPublicScene,

        // Gacha system.
        MethodId.AskDrawGacha,
        MethodId.AskClaimGachaMilestone,
        MethodId.AskChaosMasterGacha,

        // Shop and Marketplace.
        MethodId.AskNpcShopCommodityInfo,
        MethodId.AskReadCommodities,
        MethodId.AskBuyCommodity,
        MethodId.AskBuyCommodities,
        MethodId.AskBuyCommodityToBag,
        MethodId.AskBuyCommoditiesToBag,

        // Activities.
        MethodId.AskActivityCancelRedPoint,

        // Wardrobe & Fashion dressing.
        MethodId.AskSetSpiritFashionsWithSource,
        MethodId.AskSetSpiritFashions,
        MethodId.AskModifySpiritWearFashionsOnlyWearWithSource,
        MethodId.AskModifySpiritWearFashionsOnlyWear,
        MethodId.AskModifySpiritWearFashionsWithSource,
        MethodId.AskModifySpiritWearFashionEditInfosWithSource,
        MethodId.AskModifySpiritWearFashionEditInfos,
        MethodId.AskSetSpiritWearFashionHiddenPartsWithSource,
        MethodId.AskSetSpiritWearFashionHiddenParts,
        MethodId.AskOpenOrCloseFashionPanel,
        MethodId.AskUnlockFashionColoringSlot,
        MethodId.AskUnlockFashionSuitSlot,
        MethodId.AskApplyFashionColoringSchemeInf,
        MethodId.AskSetFashionColoringSchemeInfos,
        MethodId.AskFavoriteFashions,
        MethodId.AskFavoriteFashionSuits,
        MethodId.AskReadFashions,
        MethodId.AskReadFashionSuits,
        MethodId.AskSetSpiritFashionVariantPreference,
        MethodId.AskTradeRecycleFashion,
        MethodId.AskClearSwitchInFashionCache,
        MethodId.AskRecommendGetTopWearFashionTag,

        // Autonomous driving & Vehicle pathfinder.
        MethodId.AskVehicleStartAutonomousDriving,
        MethodId.AskVehicleStopAutonomousDriving,
        MethodId.AskVehicleChangeAutonomousDrivingTarget,
        MethodId.AskVehicleCancelAutonomousDrivingTarget,
        MethodId.AskVehicleNavigationPathPoints,
        MethodId.AskVehicleNavigationPathLength,
        MethodId.AskVehicleNavigationPathLengthList,

        // Metro / Subway system.
        MethodId.AskGetAllMetroInfos,
        MethodId.AskMetroGadgetIds,
        MethodId.AskPlayerOnMetro,
        MethodId.AskOnMetroEnterStation,
        MethodId.AskOnMetroExitStation,
        MethodId.AskPlayerLeaveMetro,

        // Story & Quests.
        MethodId.AskAcceptTask,
        MethodId.AskAcceptAndSetCurrentTask,
        MethodId.AskSubmitTask,

        // Time App, Mobile Phone Skins & Interaction Actions.
        MethodId.AskTimePanelInfo,
        MethodId.AskSetMobileSkinPart,
        MethodId.AskResetMobileSkinPart,
        MethodId.AskInstallMobileApp,
        MethodId.AskCancelInteractionActionRedPoint,

        // Taffy Moto / Monowheel traversal.
        MethodId.AskTaffyMotoEnterRush,
        MethodId.AskTaffyMotoLeaveRush,
        MethodId.OnTafeiMotorColliding,
        MethodId.AskGetOffMotor,
    };

    internal RpcRouter Build()
    {
        var router = new RpcRouter("game");
        MethodId.RegisterKnownNames(router);
        _ = AttributedHandlerRegistry.RegisterSelected(router, this, Enabled4229938MethodIds);
        router.OnUnknownInvoke(DefaultUnknownInvoke4229938);
        router.OnUnknownNotify(DefaultUnknownNotify4229938);
        return router;
    }
}
