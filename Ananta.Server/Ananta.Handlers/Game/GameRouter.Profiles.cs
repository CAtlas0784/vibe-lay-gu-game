using Ananta.SDK.Rpc;
using Ananta.Server.Handlers;
using Ananta.Server.Gameplay;
using Ananta.Server.Protocol.Client4229938;
using Ananta.Server.ClientData.Client4229938;
using GameMethods = Ananta.Server.RpcTypes.Client4229938.Methods.Game;

namespace Ananta.Server.Handlers.Game;

/// <summary>Runtime player/combat hydration shared by world entry and character switching.</summary>
internal sealed partial class GameRouter
{


    async Task PublishSkillBindings(
        RpcContext ctx,
        ulong unitId,
        CombatWeaponDefinition weapon,
        CombatStyleDefinition style)
    {
        if (weapon.SpiritTemplateId == 15020992) // Taffy (塔菲)
        {
            // Taffy signature skills:
            // 51935209: 塔菲普攻1 (Hammer strikes)
            // 51935213: 塔菲重击 (Heavy slam)
            // 51935207: 通用闪避 (Dodge)
            // 51935230: 塔菲主动技_上车A (Taffy Monowheel Mount!)
            // 51935224: 塔菲大招 (超次元神速连打)
            await ctx.NotifyAsync(MethodId.SyncChangeCommonSkill, WorldCodec.SkillBinding(unitId, 51935209));
            await ctx.NotifyAsync(MethodId.SyncChangeHeavyAttack, WorldCodec.SkillBinding(unitId, 51935213));
            await ctx.NotifyAsync(MethodId.SyncChangeDodgeSkill, WorldCodec.SkillBinding(unitId, 51935207));
            await ctx.NotifyAsync(MethodId.SyncChangeControlSkill, CombatCodec.ControlBinding(unitId, style));
            await ctx.NotifyAsync(MethodId.SyncChangeActiveSkill, WorldCodec.SkillBinding(unitId, 51935230));
            await ctx.NotifyAsync(MethodId.SyncChangeUniqueSkill, WorldCodec.SkillBinding(unitId, 51935224));
            ctx.Session.Log.Info($"[COMBAT] bound signature Taffy Monowheel skill profile for unit={unitId}");
            return;
        }

        await ctx.NotifyAsync(MethodId.SyncChangeCommonSkill, CombatCodec.CommonBinding(unitId, style));
        await ctx.NotifyAsync(MethodId.SyncChangeHeavyAttack, CombatCodec.HeavyAttackBinding(unitId, style));
        await ctx.NotifyAsync(MethodId.SyncChangeDodgeSkill, CombatCodec.DodgeBinding(unitId, style));
        await ctx.NotifyAsync(MethodId.SyncChangeControlSkill, CombatCodec.ControlBinding(unitId, style));
        await ctx.NotifyAsync(MethodId.SyncChangeActiveSkill, CombatCodec.ActiveBinding(unitId, weapon, style));
        await ctx.NotifyAsync(MethodId.SyncChangeUniqueSkill, CombatCodec.UniqueBinding(unitId, weapon, style));
    }

    async Task PublishCombatResources(RpcContext ctx, ulong unitId)
    {
        foreach (var (resourceId, maximum) in CombatCodec.AllResourceMaximums)
        {
            await ctx.NotifyAsync(MethodId.SyncFightResource,
                CombatCodec.FightResource(unitId, resourceId, maximum));
            await ctx.NotifyAsync(MethodId.SyncFightResourceFreeState,
                CombatCodec.FightResourceFreeState(unitId, resourceId, false));
        }
    }

    private static IEnumerable<KeyValuePair<uint, uint>> SpiritFightStyleOverrides(
        WorldEntryState state,
        uint templateId)
        => state.SpiritStyleOverrides
            .Where(x => x.Key.SpiritId == templateId)
            .Select(x => new KeyValuePair<uint, uint>(x.Key.FightStyleTypeId, x.Value));

    private static uint PublishedWeaponFightStyleId(WorldEntryState state, CombatWeaponDefinition weapon)
    {
        // The armory can store category-wide and per-instance choices separately, but the live
        // combat runtime also caches FightStyleId by weapon instance. Publishing the EFFECTIVE
        // style keeps FightStyleManager.GetUnitFightStyleByTemplateAndWeapon, ActionType and the
        // native SkillJumpGraph on the same martial art. Category changes refresh this cache.
        return ResolveWeaponStyle(state, weapon).Id;
    }

    async Task PublishMinimalActorPresentation4229938(
        RpcContext ctx,
        ulong unitId,
        uint templateId,
        string reason)
    {
        var state = GetWorldState(ctx);
        var weapon = CombatCodec.DefaultWeapon(templateId);
        var style = ResolveWeaponStyle(state, weapon);

        state.ActiveWeaponInstanceId = weapon.InstanceId;
        state.ActiveFightStyleId = style.Id;
        state.LastWeaponBySpirit[templateId] = weapon.InstanceId;

        // Actor presentation is part of the ownership contract, not the legacy combat server.
        // The client already received the small referenced armory in SyncPlayerInfo; these packets
        // only bind the current model to its authored fashion/wheel/current weapon.
        var wearFashions = state.CustomWornFashionsBySpirit.TryGetValue(templateId, out var customWear)
            ? new GameMethods.SyncSetSpiritFashions
            {
                spiritId = templateId,
                source = 0,
                spiritWearFashionsInfo = customWear,
            }
            : RuntimePayloadFactory.CharacterFashions(templateId);

        await ctx.NotifyAsync(MethodId.SyncSetSpiritFashions, wearFashions);
        await PublishWeaponSnapshot(ctx, unitId, templateId, weapon.InstanceId);
        await ctx.NotifyAsync(MethodId.SyncSpiritLastUsedWeapon,
            CombatCodec.SpiritLastUsedWeapon(templateId, weapon.InstanceId));
        await ctx.NotifyAsync(MethodId.SyncSpiritSwitchWeaponAction,
            CombatCodec.SpiritSwitchWeapon(unitId, weapon.InstanceId));
        await PublishSelectedWeaponProfile(ctx, unitId, templateId, weapon, style);

        ctx.Session.Log.Info($"[ACTOR-MIN] presentation unit={unitId} template={templateId} weapon={weapon.TemplateId}/{weapon.InstanceId} style={style.Id} reason={reason} combatModules=true skills=true");
    }

    async Task PublishWeaponSnapshot(
        RpcContext ctx,
        ulong unitId,
        uint templateId,
        ulong currentWeaponInstanceId)
    {
        // Armory and character wheels are separate client stores. Publish the shared account armory
        // once, refresh this character's mutable 16-slot view, then select the current instance.
        // Sending only SyncSpiritSwitchWeaponAction leaves CurrWeaponSlots nil and produces
        // "Not Find Current Weapon" in WeaponManager.lua.
        var state = GetWorldState(ctx);
        if (!state.AccountArmoryPublished)
        {
            // Minimal V4.1 puts only the weapon instances referenced by owned spirit wheels into
            // SyncPlayerInfo.InfoSpirit.InfoArmory.Weapons. PlayerInfoSpiritData feeds that compact subset
            // directly to gWeaponManager, so no incremental account-armory replay is needed here.
            state.AccountArmoryPublished = true;
            var actorArmoryCount = ClientConfigRepository.Characters()
                .SelectMany(character => CombatCodec.Loadout(character.TemplateId).Slots)
                .Where(weapon => weapon is not null && weapon.InstanceId != 0)
                .Select(weapon => weapon!.InstanceId)
                .Distinct()
                .Count();
            ctx.Session.Log.Info($"[ARMORY-MIN] retained login actor-reference subset count={actorArmoryCount} fullAccount={CombatCatalogRepository.AccountWeapons.Count} incrementalAddReplay=false");
        }

        var snapshot = CombatCodec.SpiritWeaponSnapshot(
            unitId,
            templateId,
            currentWeaponInstanceId,
            WeaponSlotDefinitions(state, templateId));
        foreach (var weapon in snapshot.WeaponSlots)
        {
            if (weapon is null)
                continue;
            if (CombatCodec.Weapon(templateId, weapon.InstanceId) is { } definition)
            {
                weapon.FightStyleId = PublishedWeaponFightStyleId(state, definition);
                weapon.MagazineAmmo = EnsureMagazine4229938(state, definition);
                weapon.Durability = CurrentDurability4229938(state, definition, weapon.MagazineAmmo);
                weapon.BulletDatas.BulletId = EnsureBullet4229938(state, definition);
                if (definition.SeparateBullets && weapon.BulletDatas.BulletId != 0)
                    _ = EnsureReserve4229938(state, weapon.BulletDatas.BulletId);
            }
        }
        await ctx.NotifyAsync(MethodId.SyncSpiritWeaponDetail, snapshot);
        // FightStyleId is also cached in the account armory object. Reconcile each equipped weapon
        // when a character becomes current so a style that was valid for the previous model cannot
        // leak into this model's attack ActionSet.
        foreach (var detail in snapshot.WeaponSlots.Where(x => x is not null).Select(x => x!))
        {
            await ctx.NotifyAsync(MethodId.SyncWeaponFightStyleChange,
                new GameMethods.SyncWeaponFightStyleChange
                {
                    weaponInstanceId = detail.InstanceId,
                    fightStyleId = detail.FightStyleId
                });
        }
    }

    async Task PublishSafeRuntimeBuffSnapshot4229938(RpcContext ctx, ulong unitId, uint templateId, string phase)
    {
        var state = GetWorldState(ctx);
        var buffs = WebTraversal.CapabilityBuffIds(templateId);
        var firstInstanceId = state.NextBuffInstanceId;
        await ctx.NotifyAsync(MethodId.SyncUnitBuffList,
            WorldCodec.UnitBuffList(unitId, buffs, firstInstanceId));
        state.NextBuffInstanceId += (uint)buffs.Count;

        // Do NOT bulk-activate the extracted buff catalogue. It contains 4k+ records for
        // bosses, NPCs, timelines, skin replacement, ControlList and ActionGroup switches. The client
        // applies those as executable behavior, not as an "unlocked buff catalogue". In the failing
        // capture this forced actionGroup=33 on main_A104001 and later crashed ReplaceSkinAction.End.
        ctx.Session.Log.Info($"[BUFFS-MIN] {phase} unit={unitId} template={templateId} count={buffs.Count} firstInstance={firstInstanceId} bulk=false safeWebOnly=true legacyCatalogLoaded=false");
    }

    async Task PublishInitialCapabilityBuffs(RpcContext ctx)
    {
        var state = GetWorldState(ctx);
        if (state.InitialCapabilityBuffsPublished)
            return;

        state.InitialCapabilityBuffsPublished = true;

        // Keep the opening/loading barrier on the proven small traversal capability set.
        // Never activate the entire BuffConfig as one player snapshot: it contains NPC/timeline actions.
        var targetUnitId = state.ActiveSpiritUnitId != 0 ? state.ActiveSpiritUnitId : Profile.InitialUnitId;
        var firstInstanceId = state.NextBuffInstanceId;
        await ctx.NotifyAsync(MethodId.SyncUnitBuffList,
            WorldCodec.UnitBuffList(targetUnitId, WebTraversal.InitialCapabilityBuffIds, firstInstanceId));
        state.NextBuffInstanceId += (uint)WebTraversal.InitialCapabilityBuffIds.Count;
        ctx.Session.Log.Info($"[CAPABILITY] initial unit={targetUnitId} count={WebTraversal.InitialCapabilityBuffIds.Count} loadingSafe=true allBuffsDeferred=true");
    }

}
