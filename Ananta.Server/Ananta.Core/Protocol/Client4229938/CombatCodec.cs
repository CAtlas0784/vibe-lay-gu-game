using Ananta.Server.ClientData.Client4229938;
using Ananta.Server.Configuration;
using Auto = Ananta.Server.RpcTypes.Client4229938.Auto;
using SceneMethods = Ananta.Server.RpcTypes.Client4229938.Methods.GameScene;

namespace Ananta.Server.Protocol.Client4229938;

/// <summary>
/// Typed factories for combat RPCs. Weapon/style/skill values come from the extracted build-4229938
/// client tables; private-server.json only supplies private-server balance and identity values.
/// </summary>
internal static class CombatCodec
{
    private static CombatSettings Settings => PrivateServerConfigStore.Current.Gameplay.Combat;

    internal static float MaxHp => Settings.MaxHp;
    internal static uint UltimateResourceId => Settings.Resource.Id;
    internal static float UltimateResourceMax
        => CombatCatalogRepository.ResourceMaximum(UltimateResourceId, Settings.Resource.Max);
    internal static IReadOnlyDictionary<uint, float> AllResourceMaximums
        => CombatCatalogRepository.ResourceMaximums;

    internal static CombatLoadout Loadout(uint templateId)
        => CombatCatalogRepository.Loadout(templateId);

    internal static CombatWeaponDefinition DefaultWeapon(uint templateId)
        => Loadout(templateId).DefaultWeapon;

    internal static CombatWeaponDefinition? Weapon(uint templateId, ulong instanceId)
        => CombatCatalogRepository.Weapon(templateId, instanceId);

    internal static CombatWeaponDefinition? WeaponAt(uint templateId, int index)
        => Loadout(templateId).WeaponAt(index);

    internal static SceneMethods.PlayerFightStyleUnlockChangeInfo FightStyleUnlock()
    {
        var values = CombatCatalogRepository.UnlockedStyleIds.ToDictionary(x => x, _ => true);
        return new SceneMethods.PlayerFightStyleUnlockChangeInfo
        {
            playerInfoFightStyle = new SceneMethods.PlayerInfoFightStyle
            {
                fightStyles = values.ToDictionary(x => x.Key, x => x.Value)
            },
            addOrUpdateUnlockInfo = values
        };
    }

    internal static SceneMethods.SpiritFightTypeChangeAction FightStyleAction(uint templateId)
        => FightStyleAction(templateId, Array.Empty<KeyValuePair<uint, uint>>());

    internal static SceneMethods.SpiritFightTypeChangeAction FightStyleAction(
        uint templateId,
        IEnumerable<KeyValuePair<uint, uint>> overrides)
    {
        var styleByType = Loadout(templateId).StyleByType.ToDictionary(x => x.Key, x => x.Value);
        foreach (var (typeId, styleId) in overrides)
            styleByType[typeId] = styleId;
        return new SceneMethods.SpiritFightTypeChangeAction
        {
            templateId = templateId,
            fullInfo = new SceneMethods.SpiritFightStyleInfo
            {
                fightStyleInfo = styleByType.ToDictionary(x => x.Key, x => x.Value)
            },
            addOrUpdateInfo = styleByType
        };
    }

    internal static SceneMethods.SyncChangeSkill CommonBinding(ulong unitId, CombatStyleDefinition style)
        => WorldCodec.SkillBinding(unitId, style.CommonSkill);

    internal static SceneMethods.SyncChangeSkill HeavyAttackBinding(ulong unitId, CombatStyleDefinition style)
        => WorldCodec.SkillBinding(unitId, style.HeavyCommonSkill);

    internal static SceneMethods.SyncChangeSkill DodgeBinding(ulong unitId, CombatStyleDefinition style)
        => WorldCodec.SkillBinding(unitId, style.DodgeSkill);

    internal static SceneMethods.SyncChangeSkill ControlBinding(ulong unitId, CombatStyleDefinition style)
        => WorldCodec.SkillBinding(unitId, style.ControlSkill);

    internal static SceneMethods.SyncChangeSkill ActiveBinding(
        ulong unitId,
        CombatWeaponDefinition weapon,
        CombatStyleDefinition style)
        => WorldCodec.SkillBinding(unitId, weapon.ActiveSkill(style));

    internal static SceneMethods.SyncChangeSkill UniqueBinding(
        ulong unitId,
        CombatWeaponDefinition weapon,
        CombatStyleDefinition style)
        => WorldCodec.SkillBinding(unitId, weapon.UniqueSkill(style));

    internal static SceneMethods.SyncPlayerAllSkillChargeData AllSkillCharges(
        ulong unitId,
        CombatWeaponDefinition weapon,
        CombatStyleDefinition style)
    {
        var body = new SceneMethods.SyncPlayerAllSkillChargeData { unitId = unitId };

        void Full(uint skillId)
        {
            if (skillId == 0 || body.charges.ContainsKey(skillId))
                return;
            var period = weapon.Cooldown(style, skillId, 0f);
            var maximum = weapon.MaximumCharges(style, skillId);
            // A zero Cooldown means the skill is input/animation driven, not charge-count driven.
            // Publishing ChargeData for such skills makes the client consume an invented stock and
            // interferes with click/hold/release transitions in SkillJumpConfig.
            if (period <= 0f || maximum == 0)
                return;
            body.charges[skillId] = new SceneMethods.ChargeData
            {
                current = maximum,
                readyRatio = 1f,
                period = period,
                max = maximum,
                timestamp = 0d
            };
        }

        foreach (var skillId in weapon.EffectiveSkillIds(style))
            Full(skillId);
        Full(weapon.ActiveSkill(style));
        Full(weapon.UniqueSkill(style));
        return body;
    }

    internal static SceneMethods.SyncAttachBattleModule AttachBattleModule(ulong unitId)
        => new() { unitId = unitId };

    internal static SceneMethods.SyncFightResource FightResource(ulong unitId, uint resourceId, float value)
        => new() { unitId = unitId, resourceId = resourceId, value = value };

    internal static SceneMethods.SyncFightResourceFreeState FightResourceFreeState(ulong unitId, uint resourceId, bool isFree)
        => new() { unitId = unitId, resourceId = resourceId, isFree = isFree };

    internal static SceneMethods.SyncUnitHp UnitHp(ulong unitId, float hp)
        => new() { unitId = unitId, hp = hp };

    internal static SceneMethods.SyncSpiritUnitUrbanAttrs UrbanAttrs(ulong unitId)
        => new() { unitId = unitId, abilities = Settings.DefaultUrbanAbilities.ToList() };

    internal static SceneMethods.SyncUnitAttrs UnitAttrs(ulong unitId, float maxHp)
        => new()
        {
            unitId = unitId,
            attrs = new Dictionary<uint, float>
            {
                [1] = maxHp,
                [2] = Settings.Attack,
                [7] = Settings.Defense,
                [10] = Settings.MoveSpeedMultiplier
            }
        };

    internal static SceneMethods.SyncSpiritLastUsedWeapon SpiritLastUsedWeapon(uint templateId, ulong weaponInstanceId)
        => new() { templateId = templateId, weaponInstanceId = weaponInstanceId };

    internal static SceneMethods.SpiritSwitchWeaponAction SpiritSwitchWeapon(ulong unitId, ulong weaponInstanceId)
        => new() { spiritUid = unitId, weaponInstanceId = weaponInstanceId, reason = 0 };

    internal static IReadOnlyList<Auto.WeaponData> ArmoryWeapons()
        => CombatCatalogRepository.AccountWeapons.Select(RuntimePayloadFactory.WeaponData).ToArray();

    internal static SceneMethods.SpiritWeaponDetail SpiritWeaponSnapshot(
        ulong unitId,
        uint templateId,
        ulong currentWeaponInstanceId,
        IReadOnlyList<CombatWeaponDefinition?>? slotWeapons = null)
    {
        var loadout = Loadout(templateId);
        slotWeapons ??= loadout.Slots;
        if (!slotWeapons.Any(x => x?.InstanceId == currentWeaponInstanceId))
            currentWeaponInstanceId = slotWeapons.FirstOrDefault(x => x is not null)?.InstanceId ?? loadout.DefaultWeapon.InstanceId;

        return new SceneMethods.SpiritWeaponDetail
        {
            SpiritTid = templateId,
            SpiritUid = unitId,
            CurrentWeaponUid = currentWeaponInstanceId,
            WeaponSlots = slotWeapons.Select(weapon => weapon is null ? null : WeaponDetail(weapon)).ToList(),
            CurrentTempWeapon = null,
            TempWeaponSlots = null,
            VirtualWeaponSlots = []
        };
    }

    private static SceneMethods.WeaponDetail WeaponDetail(CombatWeaponDefinition weapon)
        => new()
        {
            SourceAgentSpoonId = 0,
            SourceAgentId = 0,
            SourceSceneItemId = 0,
            IsLocked = false,
            SourceSceneItemTaskUId = 0,
            TemplateId = weapon.TemplateId,
            Durability = weapon.InitialClientDurability,
            InstanceId = weapon.InstanceId,
            EventId = 0,
            ReceivedTimeStamp = 0d,
            OperatorFlags = 0,
            SpecialLabel = null,
            SceneItemHp = 1f,
            StackCount = 1,
            FightStyleId = weapon.Style.Id,
            MagazineAmmo = weapon.InitialMagazineAmmo,
            BulletDatas = new Auto.WeaponBulletDatas { BulletId = weapon.BulletId },
            BindPid = PrivateServerConfigStore.Current.Player.Pid,
            IsPlayerLocked = false
        };

    internal static SceneMethods.SpiritWeaponDurabilityChangedAction WeaponDurabilityChanged(
        uint spiritTemplateId, ulong spiritUnitId, CombatWeaponDefinition weapon, int durability, int magazineAmmo, uint bulletId)
        => new()
        {
            SpiritTid = spiritTemplateId,
            SpiritUid = spiritUnitId,
            WeaponInstanceId = weapon.InstanceId,
            Durability = durability,
            MagazineAmmo = magazineAmmo,
            CurrentBulletId = bulletId,
            StackCount = 1,
        };

    internal static bool IsKnownSkill(
        uint templateId,
        ulong weaponInstanceId,
        uint skillId)
    {
        var weapon = Weapon(templateId, weaponInstanceId) ?? DefaultWeapon(templateId);
        return weapon.AllowsSkill(weapon.Style, skillId);
    }

    internal static SceneMethods.SyncBreakSkill BreakSkill(ulong unitId)
        => new() { unitId = unitId };
}
