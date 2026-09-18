using Ananta.SDK.Network;
using Ananta.SDK.Serialization;
using Ananta.Server.ClientData.Client4229938;
using Ananta.Server.Configuration;
using Ananta.Server.Protocol.Client4229938;
using GameMethods = Ananta.Server.RpcTypes.Client4229938.Methods.Game;

namespace Ananta.Server.Handlers.Game;

/// <summary>
/// Debug-panel armory operations: install any armory weapon into any spirit editable wheel
/// slot (1..15) and republish the proven weapon-detail / fight-style / switch shapes.
/// </summary>
internal sealed partial class GameRouter
{
    internal static async Task<(bool Ok, string Message)> PanelEquipWeaponAsync(
        TcpSession session, uint? spiritIdOption, int slotIndex, uint? templateIdOption, ulong? instanceIdOption)
    {
        var state = GetStateIfExists(session);
        if (state is null)
            return (false, "no live game session (is the client in the world?)");

        var spiritId = spiritIdOption is uint requested && requested != 0
            ? requested
            : state.ActiveSpiritTemplateId;
        if (!ClientConfigRepository.Characters().Any(character => character.TemplateId == spiritId))
            return (false, $"spirit {spiritId} is not in the roster");
        if (!IsEditableWeaponSlot(slotIndex))
            return (false, "slotIndex must be 1..15 (slot 0 is the authored fists slot)");

        ulong instanceId;
        if (instanceIdOption is ulong requestedInstance && requestedInstance != 0)
        {
            instanceId = requestedInstance;
        }
        else if (templateIdOption is uint templateId && templateId != 0)
        {
            var match = CombatCatalogRepository.AccountWeapons.FirstOrDefault(weapon => weapon.TemplateId == templateId);
            if (match is null)
                return (false, $"template {templateId} is not an armory weapon (see GET /api/catalog/weapons)");
            instanceId = match.InstanceId;
        }
        else
        {
            return (false, "provide templateId or instanceId");
        }

        var target = CombatCatalogRepository.Weapon(spiritId, instanceId);
        if (target is null)
            return (false, $"weapon instance {instanceId} has no runtime view for spirit {spiritId}");

        if (state.ArmoryWeaponsAnnounced.Add(instanceId))
        {
            await session.NotifyAsync(MethodId.SyncArmoryAddWeapon,
                UxSerializer.Serialize(RuntimePayloadFactory.WeaponData(target)), CancellationToken.None);
            session.Log.Info($"[ARMORY] announce-to-client weapon={target.TemplateId}/{instanceId}");
        }

        var slots = WeaponSlotIds(state, spiritId);
        var existingIndex = slots.IndexOf(instanceId);
        if (existingIndex >= 0 && existingIndex != slotIndex)
            (slots[existingIndex], slots[slotIndex]) = (slots[slotIndex], slots[existingIndex]);
        else
            slots[slotIndex] = instanceId;

        await PublishPanelWeaponSlotsAsync(session, state, spiritId, $"panel-equip:{instanceId}@{slotIndex}");
        session.Log.Info($"[ARMORY] panel equip spirit={spiritId} slot={slotIndex} weapon={target.TemplateId}/{instanceId} name={target.Name}");
        return (true, $"spirit {spiritId} slot {slotIndex} = {target.Name} ({target.TemplateId})");
    }

    private static async Task PublishPanelWeaponSlotsAsync(TcpSession session, WorldEntryState state, uint spiritId, string operation)
    {
        var slots = WeaponSlotIds(state, spiritId);
        var isActive = spiritId == state.ActiveSpiritTemplateId;
        var currentWeaponId = isActive
            ? state.ActiveWeaponInstanceId
            : state.LastWeaponBySpirit.GetValueOrDefault(spiritId);
        if (currentWeaponId == 0 || !slots.Contains(currentWeaponId))
            currentWeaponId = slots.FirstOrDefault(id => id != 0);
        if (currentWeaponId == 0)
            currentWeaponId = CombatCodec.Loadout(spiritId).DefaultWeapon.InstanceId;

        var unitId = isActive
            ? state.ActiveSpiritUnitId
            : ClientConfigRepository.Characters().First(x => x.TemplateId == spiritId).UnitId;
        var currentWeapon = CombatCatalogRepository.Weapon(spiritId, currentWeaponId)
            ?? throw new InvalidDataException($"Missing runtime view for spirit {spiritId}, weapon {currentWeaponId}.");
        var currentChanged = isActive && state.ActiveWeaponInstanceId != currentWeaponId;
        var style = ResolveWeaponStyle(state, currentWeapon);

        state.LastWeaponBySpirit[spiritId] = currentWeaponId;
        if (isActive)
        {
            state.ActiveWeaponInstanceId = currentWeaponId;
            state.ActiveFightStyleId = style.Id;
            state.ActiveSkillId = 0;
            state.RestoreResourcesAfterActiveSkill = false;
            state.ActiveClientSkillInstanceId = 0;
            state.ActiveSkillStartedTicks = 0;
        }

        var snapshot = CombatCodec.SpiritWeaponSnapshot(unitId, spiritId, currentWeaponId, WeaponSlotDefinitions(state, spiritId));
        foreach (var detail in snapshot.WeaponSlots)
        {
            if (detail is null)
                continue;
            if (CombatCatalogRepository.Weapon(spiritId, detail.InstanceId) is not { } definition)
                continue;
            detail.FightStyleId = ResolveWeaponStyle(state, definition).Id;
            detail.MagazineAmmo = EnsureMagazine4229938(state, definition);
            detail.Durability = CurrentDurability4229938(state, definition, detail.MagazineAmmo);
            detail.BulletDatas.BulletId = EnsureBullet4229938(state, definition);
        }
        await session.NotifyAsync(MethodId.SyncSpiritWeaponDetail, UxSerializer.Serialize(snapshot), CancellationToken.None);

        foreach (var detail in snapshot.WeaponSlots.Where(x => x is not null).Select(x => x!))
        {
            await session.NotifyAsync(MethodId.SyncWeaponFightStyleChange, UxSerializer.Serialize(
                new GameMethods.SyncWeaponFightStyleChange
                {
                    weaponInstanceId = detail.InstanceId,
                    fightStyleId = detail.FightStyleId,
                }), CancellationToken.None);
        }
        await session.NotifyAsync(MethodId.SyncSpiritLastUsedWeapon, UxSerializer.Serialize(
            CombatCodec.SpiritLastUsedWeapon(spiritId, currentWeaponId)), CancellationToken.None);

        if (!currentChanged)
            return;

        await session.NotifyAsync(MethodId.SyncSpiritSwitchWeaponAction, UxSerializer.Serialize(
            CombatCodec.SpiritSwitchWeapon(unitId, currentWeaponId)), CancellationToken.None);
        await session.NotifyAsync(MethodId.SyncPlayerAllSkillChargeData, UxSerializer.Serialize(
            CombatCodec.AllSkillCharges(unitId, currentWeapon, style)), CancellationToken.None);
        foreach (var (resourceId, maximum) in CombatCodec.AllResourceMaximums)
        {
            await session.NotifyAsync(MethodId.SyncFightResource, UxSerializer.Serialize(
                CombatCodec.FightResource(unitId, resourceId, maximum)), CancellationToken.None);
            await session.NotifyAsync(MethodId.SyncFightResourceFreeState, UxSerializer.Serialize(
                CombatCodec.FightResourceFreeState(unitId, resourceId, true)), CancellationToken.None);
        }
        await session.NotifyAsync(MethodId.SyncChangeCommonSkill, UxSerializer.Serialize(CombatCodec.CommonBinding(unitId, style)), CancellationToken.None);
        await session.NotifyAsync(MethodId.SyncChangeHeavyAttack, UxSerializer.Serialize(CombatCodec.HeavyAttackBinding(unitId, style)), CancellationToken.None);
        await session.NotifyAsync(MethodId.SyncChangeDodgeSkill, UxSerializer.Serialize(CombatCodec.DodgeBinding(unitId, style)), CancellationToken.None);
        await session.NotifyAsync(MethodId.SyncChangeControlSkill, UxSerializer.Serialize(CombatCodec.ControlBinding(unitId, style)), CancellationToken.None);
        await session.NotifyAsync(MethodId.SyncChangeActiveSkill, UxSerializer.Serialize(CombatCodec.ActiveBinding(unitId, currentWeapon, style)), CancellationToken.None);
        await session.NotifyAsync(MethodId.SyncChangeUniqueSkill, UxSerializer.Serialize(CombatCodec.UniqueBinding(unitId, currentWeapon, style)), CancellationToken.None);
        session.Log.Info($"[ARMORY] panel {operation} spirit={spiritId} active={isActive} current={currentWeaponId} style={style.Id}");
    }
}
