using Ananta.Server.RpcTypes.Client4229938;
using GameMethods = Ananta.Server.RpcTypes.Client4229938.Methods.Game;
namespace Ananta.Server.Protocol.Client4229938;

internal sealed class WorldEntryState
{
    internal object SyncRoot { get; } = new();

    internal Dictionary<uint, GameMethods.SpiritWearFashionsInfo> CustomWornFashionsBySpirit { get; } = [];

    internal bool InitialStateSent { get; set; }
    internal bool EnterSceneSent { get; set; }
    internal bool SceneLoadAckSeen { get; set; }
    internal bool GameResourcesReadySeen { get; set; }
    internal bool ControlPublished { get; set; }
    internal bool SceneCompletionSent { get; set; }
    internal bool CurrentSpiritStateSent { get; set; }
    internal bool Ready { get; set; }
    internal bool LivePlayerProfilePublished { get; set; }
    internal bool SameSceneAckSeen { get; set; }
    internal bool MovementCapabilityPublished { get; set; }
    internal bool FreeRoamReleased { get; set; }
    internal bool FirstMovementSeen { get; set; }
    internal bool GaragePublished { get; set; }
    internal bool AetherVehicleInitSent { get; set; }
    internal bool InitialCapabilityBuffsPublished { get; set; }
    internal bool AllBuildBuffsPublished { get; set; }
    internal bool InitialActorPresentationPublished { get; set; }
    internal bool CombatProfilePublished { get; set; }
    internal bool AccountArmoryPublished { get; set; }

    // Current public-world destination. Initial values come from private-server.json; airport
    // travel updates these per scene generation without mutating global configuration.
    internal uint ActiveRaidId { get; set; } = Profile.RaidId;
    internal ulong ActiveInstanceId { get; set; } = Profile.SceneInstanceId;
    internal uint ActiveUniverseId { get; set; } = Profile.UniverseId;
    internal string ActiveContentScene { get; set; } = "WorldMap_Release";
    internal bool WorldEntryIsAirportTravel { get; set; }

    // Native LoadingManager common-teleport transaction. Airport travel reuses the retail
    // AskTeleport -> SyncPreTeleportOption -> ReportPreTeleportFinish -> domain RPC ->
    // SyncTeleport -> ReportPostTeleportFinish sequence so SwitchTeleportManager cannot retain
    // a stale AcrossRaid flow after landing.
    internal ulong PendingTeleportId { get; set; }
    internal string PendingAirportRouteKey { get; set; } = string.Empty;
    internal bool PendingTeleportPreFinished { get; set; }
    internal bool PendingTeleportSyncSent { get; set; }

    // Build 4229938: one generation-bound initial-player handoff.
    // 0 = edge not claimed; -generation = claimed/in-flight; +generation = published.
    internal bool WorldEntryControlPending { get; set; }
    internal bool WorldEntryControlFinalized { get; set; }
    internal ulong WorldEntryControlUnit { get; set; }
    internal uint WorldEntryControlTemplate { get; set; }
    internal int WorldEntryControlGeneration { get; set; }
    internal int WorldEntryLoadingCompletedGeneration { get; set; }
    internal int WorldEntryOpeningEndedGeneration { get; set; }
    internal int WorldEntryControlFinalizingGeneration { get; set; }
    internal int WorldEntryLogicProjectionPublishedGeneration { get; set; }
    internal int WorldEntryCurrentMetadataPublishedGeneration { get; set; }
    internal ulong WorldEntrySceneId4229938 { get; set; }
    internal ulong WorldEntrySessionId4229938 { get; set; }
    internal Vec3 WorldEntryCreateHeroPosition { get; set; } = Profile.WorldSpawn;
    internal float WorldEntryCreateHeroFacing { get; set; } = Profile.WorldFacing;
    internal Vec3 LastReportedPlayerPosition { get; set; } = Profile.WorldSpawn;
    internal Vec3 LastReportedPlayerRotation { get; set; } = new(0f, Profile.WorldFacing, 0f);
    internal bool HasLastReportedPlayerTransform { get; set; }
    internal Vec3 PendingTeleportPosition { get; set; } = new(0f, 0f, 0f);
    internal float PendingTeleportFacing { get; set; } = 0f;


    internal uint ActiveSkillId { get; set; }
    internal bool RestoreResourcesAfterActiveSkill { get; set; }
    internal int ActiveClientSkillInstanceId { get; set; }
    internal long ActiveSkillStartedTicks { get; set; }
    internal Dictionary<ulong, uint> StaticNpcPreparedPlotEvents { get; } = new();
    internal ulong ActiveWeaponInstanceId { get; set; }
    internal uint ActiveFightStyleId { get; set; }
    internal Dictionary<uint, ulong> LastWeaponBySpirit { get; } = [];
    internal Dictionary<uint, List<ulong>> WeaponSlotsBySpirit { get; } = [];
    internal Dictionary<ulong, uint> WeaponStyleOverrides { get; } = [];
    // Persistent weapon-instance ammunition. These dictionaries intentionally survive public-scene
    // generations and character switches; a weapon switch must never refill its magazine.
    internal Dictionary<ulong, int> WeaponMagazineAmmo { get; } = [];
    // For firearms without separate backpack bullets, Durability is the remaining total ammo
    // (loaded magazine + reserve). Keep it instance-persistent for the same reason as the magazine.
    internal Dictionary<ulong, int> WeaponDurabilityAmmo { get; } = [];
    internal Dictionary<ulong, uint> WeaponBulletByInstance { get; } = [];
    internal Dictionary<int, uint> SkillByInstanceId { get; } = [];
    internal Dictionary<uint, uint> BackpackItemCounts { get; } = [];
    internal Dictionary<uint, RpcTypes.Client4229938.Auto.PlayerPackItem> GmBackpackItems { get; } = [];
    internal double WalletMoney { get; set; }
    internal double WalletGold { get; set; }
    internal double WalletBindingGold { get; set; }
    internal PlayerProgress Progress { get; } = new();
    internal bool ProgressRestored { get; set; }
    internal bool HasSessionEconomy4229938()
        => WalletMoney != 0 || WalletGold != 0 || WalletBindingGold != 0 || GmBackpackItems.Count > 0;
    internal HashSet<ulong> ArmoryWeaponsAnnounced { get; } = [];
    internal Dictionary<(uint SpiritId, uint FightStyleTypeId), uint> SpiritStyleOverrides { get; } = [];
    internal int CombatUseCount { get; set; }
    internal int CombatEndCount { get; set; }
    internal int CombatHitCount { get; set; }
    internal uint NextBuffInstanceId { get; set; } = 1200000u;
    internal uint ActiveFeiSuoBuffInstanceId { get; set; }
    internal ulong ActiveFeiSuoBuffUnitId { get; set; }
    // Exact instance ids for client-owned 4229938 traversal states (SwingBuff/WallRushBuff).
    // They are created/removed on demand and are intentionally not resident login buffs.
    internal Dictionary<(ulong UnitId, uint BuffId), uint> ActiveClientWebBuffInstances { get; } = [];
    internal ulong SceneId { get; set; }
    internal ulong ActiveSpiritUnitId { get; set; } = Profile.InitialUnitId;
    internal uint ActiveSpiritTemplateId { get; set; } = Profile.InitialSpiritTemplateId;
    internal uint WorldEntrySwitchShowId { get; set; }
    internal uint LastSwitchShowId { get; set; }
    internal int SwitchCount { get; set; }

    // Native 4229938 SwitchTeleport is a three-phase transaction. Only the current character
    // exists as the controlled actor. Every target is materialized by the same generic AOI path
    // after the client reports that the source close-up has finished.
    internal uint PendingSwitchTemplateId { get; set; }
    internal ulong PendingSwitchUnitId { get; set; }
    internal ulong PendingSwitchOldUnitId { get; set; }
    internal uint PendingSwitchShowId { get; set; }
    internal Vec3 PendingSwitchPosition { get; set; } = Profile.WorldSpawn;
    internal float PendingSwitchFacing { get; set; } = Profile.WorldFacing;
    internal bool PendingSwitchControlTransferred { get; set; }
    internal bool PendingSwitchLandingStarted { get; set; }

    // Time-of-day state (persists across scene switches; pushed on load when set).
    internal uint TimeHour { get; set; }
    internal uint TimeMinute { get; set; }
    internal bool TimeFixed { get; set; }
    internal uint TimeTransitionSeconds { get; set; }
    internal bool HasExplicitTime { get; set; }
    internal uint WeatherId { get; set; }
    internal uint WeatherTransitionSeconds { get; set; }
    internal bool HasExplicitWeather { get; set; }

    // Personal time settings and mobile customization
    internal List<GameMethods.PersonalTimeSetting4229938> PersonalTimeSettings { get; } = [];
    internal uint MobileWallpaperId { get; set; }
    internal uint MobileDecorationId { get; set; }
    internal uint MobilePendantId { get; set; }

    // 10-Second Position History Rollback Buffer (holds last 30s locally, 60s globally across reconnects)
    internal sealed record PositionCheckpoint(DateTime Timestamp, Vec3 Position, float Facing);
    private readonly LinkedList<PositionCheckpoint> _positionHistory = new();
    private DateTime _lastCheckpointTime = DateTime.MinValue;

    private static readonly LinkedList<PositionCheckpoint> s_globalPositionHistory = new();
    private static readonly object s_globalSyncRoot = new();

    internal static void RecordGlobalCheckpoint(Vec3 pos, float facing)
    {
        lock (s_globalSyncRoot)
        {
            var now = DateTime.UtcNow;
            s_globalPositionHistory.AddLast(new PositionCheckpoint(now, pos, facing));
            var cutoff = now.AddSeconds(-60);
            while (s_globalPositionHistory.Count > 0 && s_globalPositionHistory.First!.Value.Timestamp < cutoff)
            {
                s_globalPositionHistory.RemoveFirst();
            }
        }
    }

    internal static PositionCheckpoint? TryGetGlobalCheckpointSecondsAgo(double seconds = 10.0)
    {
        lock (s_globalSyncRoot)
        {
            if (s_globalPositionHistory.Count == 0)
                return null;

            var targetTime = DateTime.UtcNow.AddSeconds(-seconds);
            PositionCheckpoint? best = null;
            double bestDiff = double.MaxValue;

            foreach (var cp in s_globalPositionHistory)
            {
                var diff = Math.Abs((cp.Timestamp - targetTime).TotalSeconds);
                if (diff < bestDiff)
                {
                    bestDiff = diff;
                    best = cp;
                }
            }

            return best ?? s_globalPositionHistory.First?.Value;
        }
    }

    internal void SeedHistoryFromGlobal()
    {
        lock (SyncRoot)
        {
            lock (s_globalSyncRoot)
            {
                foreach (var cp in s_globalPositionHistory)
                {
                    _positionHistory.AddLast(cp);
                }
            }
        }
    }

    internal void RecordPositionCheckpoint(Vec3 pos, float facing)
    {
        lock (SyncRoot)
        {
            var now = DateTime.UtcNow;
            if ((now - _lastCheckpointTime).TotalMilliseconds < 500)
                return;

            _lastCheckpointTime = now;
            _positionHistory.AddLast(new PositionCheckpoint(now, pos, facing));

            var cutoff = now.AddSeconds(-30);
            while (_positionHistory.Count > 0 && _positionHistory.First!.Value.Timestamp < cutoff)
            {
                _positionHistory.RemoveFirst();
            }
        }
        RecordGlobalCheckpoint(pos, facing);
    }

    internal PositionCheckpoint? TryGetCheckpointSecondsAgo(double seconds = 10.0)
    {
        lock (SyncRoot)
        {
            if (_positionHistory.Count == 0)
                return TryGetGlobalCheckpointSecondsAgo(seconds);

            var targetTime = DateTime.UtcNow.AddSeconds(-seconds);
            PositionCheckpoint? best = null;
            double bestDiff = double.MaxValue;

            foreach (var cp in _positionHistory)
            {
                var diff = Math.Abs((cp.Timestamp - targetTime).TotalSeconds);
                if (diff < bestDiff)
                {
                    bestDiff = diff;
                    best = cp;
                }
            }

            return best ?? _positionHistory.First?.Value;
        }
    }
}
