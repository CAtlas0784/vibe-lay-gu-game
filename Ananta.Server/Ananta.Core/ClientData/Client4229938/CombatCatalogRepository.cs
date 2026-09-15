using System.Text.Json;
using Ananta.Server.Configuration;

namespace Ananta.Server.ClientData.Client4229938;

/// <summary>
/// Build-4229938 combat catalog reconstructed from the unmodified extracted client tables.
/// It is the single source of truth for weapon slots, weapon-specific fight styles and skill bindings.
/// </summary>
internal static class CombatCatalogRepository
{
    private static CombatCatalog Data => Cache.Value;
    private static readonly Lazy<CombatCatalog> Cache = new(Load);

    internal static CombatLoadout Loadout(uint spiritTemplateId)
        => Data.Loadouts.TryGetValue(spiritTemplateId, out var value)
            ? value
            : throw new KeyNotFoundException($"No combat loadout for spirit {spiritTemplateId}.");

    internal static CombatWeaponDefinition? Weapon(ulong instanceId)
        => Data.AccountWeaponsByInstance.TryGetValue(instanceId, out var value) ? value : null;

    internal static CombatWeaponDefinition? Weapon(uint spiritTemplateId, ulong instanceId)
        => Data.WeaponsBySpiritAndInstance.TryGetValue((spiritTemplateId, instanceId), out var value) ? value : null;

    internal static IReadOnlyList<CombatWeaponDefinition> AccountWeapons => Data.AccountWeapons;

    internal static CombatStyleDefinition? Style(uint styleId)
        => Data.Styles.TryGetValue(styleId, out var value) ? value : null;

    internal static IReadOnlyList<uint> UnlockedStyleIds => Data.UnlockedStyleIds;

    internal static float ResourceMaximum(uint resourceId, float fallback)
        => Data.ResourceMaximums.TryGetValue(resourceId, out var value) ? value : fallback;

    internal static IReadOnlyDictionary<uint, float> ResourceMaximums => Data.ResourceMaximums;

    internal static IReadOnlyList<uint> AmmoTemplateIds => Data.AmmoTemplateIds;

    internal static uint SkillCastTag(uint skillId)
        => Data.SkillCastTags.GetValueOrDefault(skillId);

    internal static bool IsKnownSkill(uint skillId)
        => skillId != 0 && Data.SkillCastTags.ContainsKey(skillId);

    internal static bool IsNativeShootSkill(uint skillId)
        => SkillCastTag(skillId) is 10u or 19u;

    internal static bool IsStyleCompatible(CombatWeaponDefinition weapon, CombatStyleDefinition style)
    {
        // Stock WeaponArmoryPanelStore only treats a martial art as adaptive when its
        // FightSkillType exactly matches SceneitemConfig.FightSkillType. ActionType is the
        // animation/action-set selected BY that martial art; it is not a compatibility gate.
        // FIX24J2 incorrectly compared ActionType and therefore accepted one style, then restored
        // every other perfectly valid style from the same category.
        if (style.SpiritIds.Count > 0 && !style.SpiritIds.Contains(weapon.SpiritTemplateId))
            return false;
        return weapon.WeaponFightSkillTypeId != 0 &&
               style.FightSkillTypeId == weapon.WeaponFightSkillTypeId;
    }

    internal static bool StyleMatchesType(uint styleId, uint typeId)
        => Data.Styles.TryGetValue(styleId, out var style) &&
           (style.FightSkillTypeId == typeId || Data.DefaultStyleByType.GetValueOrDefault(typeId) == styleId);

    private static CombatCatalog Load()
    {
        var config = PrivateServerConfigStore.Current;
        var root = PrivateServerConfigStore.ResolveProjectPath(config.Paths.ClientConfigs);
        var spiritRows = ReadRecords(Path.Combine(root, "FightSpiritConfig.json"));
        var styleRows = ReadRecords(Path.Combine(root, "FightSkillConfig.json"));
        var styleTypeRows = ReadRecords(Path.Combine(root, "FightSkillFightSkillTypeConfig.json"));
        var weaponRows = ReadRecords(Path.Combine(root, "SceneitemConfig.json"));
        var legacyWeaponRows = ReadRecords(Path.Combine(root, "WeaponConfig.json"));
        var weaponShootRows = ReadRecords(Path.Combine(root, "WeaponShootConfig.json"));
        var skillRows = ReadRecords(Path.Combine(root, "SkillConfig.json"));
        var jumpRows = ReadRecords(Path.Combine(root, "SkillJumpConfig.json"));
        var jumpGroupRows = ReadRecords(Path.Combine(root, "SkillJumpGroupConfig.json"));
        var genericJumpRows = ReadRecords(Path.Combine(root, "SkillJumpGenericConfig.json"));
        var resourceRows = ReadRecords(Path.Combine(root, "SkillResourcesConfig.json"));

        var skillMetadata = skillRows
            .Select(ParseSkillMetadata)
            .Where(x => x is not null)
            .Select(x => x!)
            .ToDictionary(x => x.Id);
        var jumpTargets = jumpRows
            .Where(x => TryUInt32(x, "Id", out _) && TryUInt32(x, "Skillid", out _))
            .ToDictionary(x => x.GetProperty("Id").GetUInt32(), x => x.GetProperty("Skillid").GetUInt32());
        var jumpRowsById = jumpRows
            .Where(x => TryUInt32(x, "Id", out _))
            .ToDictionary(x => x.GetProperty("Id").GetUInt32());
        var jumpIdsByGroup = jumpGroupRows
            .Where(x => TryUInt32(x, "Id", out _))
            .ToDictionary(x => x.GetProperty("Id").GetUInt32(), x => ReadUInt32Array(x, "SkillJumpIds"));
        var groupByGenericId = genericJumpRows
            .Where(x => TryUInt32(x, "Id", out _) && TryUInt32(x, "SkillJumpGroupId", out _))
            .ToDictionary(x => x.GetProperty("Id").GetUInt32(), x => x.GetProperty("SkillJumpGroupId").GetUInt32());
        var genericJumpTargets = jumpRowsById.ToDictionary(
            x => x.Key,
            x =>
            {
                if (!TryUInt32(x.Value, "SkillGenericId", out var genericId) || genericId == 0 ||
                    !groupByGenericId.TryGetValue(genericId, out var groupId) ||
                    !jumpIdsByGroup.TryGetValue(groupId, out var groupJumpIds))
                    return Array.Empty<uint>();
                return groupJumpIds
                    .Select(jumpId => jumpTargets.GetValueOrDefault(jumpId))
                    .Where(skillId => skillId != 0)
                    .Distinct()
                    .ToArray();
            });

        var styles = styleRows
            .Select(row => ParseStyle(row, skillMetadata, jumpTargets, genericJumpTargets))
            .Where(x => x is not null)
            .Select(x => x!)
            .ToDictionary(x => x.Id);
        var defaultStyleByType = styleTypeRows
            .Where(x => TryUInt32(x, "Id", out _) && TryUInt32(x, "DefaultFightSkill", out _))
            .ToDictionary(x => x.GetProperty("Id").GetUInt32(), x => x.GetProperty("DefaultFightSkill").GetUInt32());
        var shootById = weaponShootRows
            .Where(x => TryUInt32(x, "Id", out _))
            .ToDictionary(
                x => x.GetProperty("Id").GetUInt32(),
                x => new WeaponShootSource(
                    TryBool(x, "IsShootWeapon"),
                    TryBool(x, "SeparateBullets"),
                    ReadUInt32Array(x, "BulletId")
                        .Concat(ReadUInt32Array(x, "AppropriateBullets"))
                        .Where(id => id != 0)
                        .Distinct()
                        .ToArray(),
                    TryUInt32(x, "ReloadSkill", out var reloadSkill) ? reloadSkill : 0u));
        var legacyById = legacyWeaponRows
            .Where(x => TryUInt32(x, "Id", out _))
            .ToDictionary(
                x => x.GetProperty("Id").GetUInt32(),
                x => new LegacyWeaponSource(
                    TryUInt32(x, "WeaponBelong", out var owner) ? owner : 0u,
                    TryUInt32(x, "FightSkillType", out var fightSkillType) ? fightSkillType : 0u,
                    TryUInt32(x, "FixedFightSkill", out var fixedFightSkill) ? fixedFightSkill : 0u));
        var weapons = weaponRows
            .Select(row => ParseWeaponSource(row, shootById, legacyById))
            .Where(x => x is not null)
            .Select(x => x!)
            .ToDictionary(x => x.TemplateId);
        var spiritCombat = spiritRows
            .Where(x => TryUInt32(x, "Id", out _))
            .ToDictionary(
                x => x.GetProperty("Id").GetUInt32(),
                x => new SpiritCombatSource(
                    ReadUInt32Array(x, "InitFightSkillSetting"),
                    TryUInt32(x, "FistSceneItem", out var fistId) ? fistId : 0u,
                    TryUInt32(x, "PrivateSceneItem", out var privateId) ? privateId : 0u,
                    ReadUInt32Array(x, "SceneItemGeneralSlotInitialization"),
                    ReadStringArray(x, "WeaponSlot")));

        uint EffectiveFightSkillType(WeaponSource weapon)
        {
            if (weapon.FightSkillTypeId != 0)
                return weapon.FightSkillTypeId;
            if (weapon.FixedFightStyleId != 0 &&
                styles.TryGetValue(weapon.FixedFightStyleId, out var fixedStyle) &&
                fixedStyle.FightSkillTypeId != 0)
                return fixedStyle.FightSkillTypeId;

            // A few signature/prototype rows (notably Bansy's build-4229938 scene item) ship with
            // FightSkillType=0 and a hidden prototype FixedFightSkill whose own type is also zero.
            // Infer only signature weapons from the character's authored attachment slot; never apply
            // this heuristic to generic props in the shared armory.
            if (weapon.OwnerSpiritId != 0 && spiritCombat.TryGetValue(weapon.OwnerSpiritId, out var ownerCombat))
            {
                var slots = ownerCombat.WeaponSlotNames;
                if (slots.Any(x => x.Contains("forearm", StringComparison.OrdinalIgnoreCase)))
                    return 39020004u;
                if (slots.Any(x => x.Contains("handr", StringComparison.OrdinalIgnoreCase) ||
                                   x.Contains("weapon_r", StringComparison.OrdinalIgnoreCase)))
                    return 39020301u;
            }
            return 0u;
        }

        bool IsNativeCombatStyle(CombatStyleDefinition? style)
            => style is not null && style.CommonSkill != 0 && style.HeavyCommonSkill != 0 &&
               style.ActiveSkill != 0 && style.UniqueSkill != 0;
        bool IsArmoryWeapon(WeaponSource weapon)
            => weapon.WheelIconId != 0 &&
               (weapon.FightSkillTypeId != 0 || weapon.FixedFightStyleId != 0);
        bool IsWheelWeapon(WeaponSource weapon)
            => IsArmoryWeapon(weapon) && !weapon.NotEnterRoulette &&
               (weapon.FightSkillTypeId != 0 ||
                (weapon.FixedFightStyleId != 0 &&
                 IsNativeCombatStyle(styles.GetValueOrDefault(weapon.FixedFightStyleId))));
        WeaponSource? ByLegacyId(uint legacyId)
            => weapons.Values
                .Where(x => x.LegacyWeaponId == legacyId && IsArmoryWeapon(x))
                .OrderBy(x => x.TemplateId >= 80300000u)
                .ThenBy(x => x.TemplateId)
                .FirstOrDefault();
        WeaponSource? ResolveConfiguredWeapon(uint id)
            => weapons.TryGetValue(id, out var direct) && IsWheelWeapon(direct) ? direct : ByLegacyId(id);

        var configuredWeapon = ResolveConfiguredWeapon(config.Gameplay.Combat.Weapon.TemplateId)
            ?? throw new InvalidDataException(
                $"Configured weapon {config.Gameplay.Combat.Weapon.TemplateId} is absent from SceneitemConfig.json (including OldWeaponId mapping).");
        var fallbackFists = weapons.TryGetValue(80003412u, out var fists) ? fists : configuredWeapon;
        var characters = ClientConfigRepository.Characters();
        var loadouts = new Dictionary<uint, CombatLoadout>();
        var weaponsBySpiritAndInstance = new Dictionary<(uint SpiritId, ulong InstanceId), CombatWeaponDefinition>();
        var firstInstanceBase = checked(config.Gameplay.Combat.Weapon.InstanceId - 1UL);
        var accountWeaponSources = weapons.Values
            .Where(IsArmoryWeapon)
            .OrderBy(x => x.TemplateId)
            .ToArray();
        var accountInstanceByTemplate = accountWeaponSources
            .Select((source, index) => (source.TemplateId, InstanceId: checked(firstInstanceBase + (ulong)index)))
            .ToDictionary(x => x.TemplateId, x => x.InstanceId);

        for (var characterIndex = 0; characterIndex < characters.Count; characterIndex++)
        {
            var character = characters[characterIndex];
            var spiritId = character.TemplateId;
            spiritCombat.TryGetValue(spiritId, out var authored);
            authored ??= new SpiritCombatSource([], 0, 0, [], []);
            var initialStyles = authored.InitialStyleIds;
            var abilityFallbackStyle = initialStyles
                .Select(id => styles.GetValueOrDefault(id))
                .FirstOrDefault(IsCompleteAbilityStyle)
                ?? styles.Values
                    .Where(x => x.SpiritIds.Contains(spiritId))
                    .OrderByDescending(AbilityCompleteness)
                    .ThenBy(x => x.Id)
                    .FirstOrDefault(IsCompleteAbilityStyle)
                ?? styles.GetValueOrDefault(39000011u)
                ?? styles.Values
                    .Where(x => x.SpiritIds.Count == 0)
                    .OrderByDescending(AbilityCompleteness)
                    .ThenBy(x => x.Id)
                    .First(IsCompleteAbilityStyle);
            var fistWeapon = weapons.TryGetValue(authored.FistSceneItemId, out var authoredFists) && IsWheelWeapon(authoredFists)
                ? authoredFists
                : fallbackFists;

            // Ownership is account-wide. Build a character-specific runtime view for every shared
            // account instance so any armory weapon can be installed in any character's 16 slots.
            // The instance id is derived only from the Sceneitem template, never from the character.
            foreach (var source in accountWeaponSources)
            {
                // A handful of private scene items only author a style for their original owner.
                // They still belong to the shared account armory; on another character, use that
                // character's complete ability style so the weapon remains executable instead of
                // producing an empty attack/ability binding.
                var effectiveType = EffectiveFightSkillType(source);
                var style = ResolveStyle(source, effectiveType, spiritId, initialStyles, styles, defaultStyleByType, config)
                    ?? ResolveAuthoredAccountStyle(source, effectiveType, styles, defaultStyleByType)
                    ?? abilityFallbackStyle;
                var instanceId = accountInstanceByTemplate[source.TemplateId];
                weaponsBySpiritAndInstance.Add(
                    (spiritId, instanceId),
                    new CombatWeaponDefinition(
                        spiritId,
                        source.TemplateId,
                        instanceId,
                        source.Name,
                        source.Durability,
                        source.MagazineAmmo,
                        source.BulletIds.FirstOrDefault(),
                        source.BulletIds,
                        source.IsShootWeapon,
                        source.SeparateBullets,
                        source.ReloadSkillId,
                        source.OwnerSpiritId != 0,
                        effectiveType != 0 ? effectiveType : style.FightSkillTypeId,
                        style,
                        abilityFallbackStyle));
            }

            // Personal wheel = authored personal equipment only. Slot 0 is fists, then signature
            // weapon(s) and authored general initialization. The remaining positions stay nil instead
            // of being padded with random account weapons. All 634 authored weapons live in the shared
            // armory and can still be installed manually into an empty slot.
            var personalSources = new List<WeaponSource> { fistWeapon };
            if (weapons.TryGetValue(authored.PrivateSceneItemId, out var privateWeapon) && IsArmoryWeapon(privateWeapon))
                personalSources.Add(privateWeapon);
            personalSources.AddRange(weapons.Values
                .Where(x => x.OwnerSpiritId == spiritId && IsArmoryWeapon(x))
                .OrderBy(x => x.TemplateId));
            personalSources.AddRange(authored.GeneralSceneItemIds
                .Select(id => weapons.GetValueOrDefault(id))
                .Where(x => x is not null && IsArmoryWeapon(x))
                .Select(x => x!));

            var resolvedPersonal = personalSources
                .DistinctBy(x => x.TemplateId)
                .Select(x => (Weapon: x, Style: ResolveStyle(x, EffectiveFightSkillType(x), spiritId, initialStyles, styles, defaultStyleByType, config)))
                .Where(x => x.Style is not null)
                .Take(16)
                .ToArray();
            if (resolvedPersonal.Length == 0)
                throw new InvalidDataException($"No personal combat weapon resolved for spirit {spiritId}.");

            var personalWeapons = resolvedPersonal
                .Select(x => weaponsBySpiritAndInstance[(spiritId, accountInstanceByTemplate[x.Weapon.TemplateId])])
                .ToList();
            var personalSlots = new CombatWeaponDefinition?[16];
            for (var i = 0; i < personalWeapons.Count && i < personalSlots.Length; i++)
                personalSlots[i] = personalWeapons[i];

            var signatureWeapon = personalWeapons.FirstOrDefault(x => x.IsPrivate && x.TemplateId != fistWeapon.TemplateId);
            var authoredGeneral = authored.GeneralSceneItemIds
                .Select(id => personalWeapons.FirstOrDefault(x => x.TemplateId == id))
                .FirstOrDefault(x => x is not null);
            var defaultWeapon = signatureWeapon ?? authoredGeneral ?? personalWeapons[0];
            // FightStyleManager indexes the server map by the WEAPON fight-style category.
            // Do not key this by FightSkillConfig.FightSkillType: special authored defaults can
            // deliberately use a style whose own type differs from the Sceneitem category.
            var styleByType = resolvedPersonal
                // FixedFightSkill is resolved directly from SceneitemConfig and must not pollute
                // the per-spirit category map used by other, non-fixed weapons of the same type.
                .Where(x => x.Weapon.FixedFightStyleId == 0)
                .Select(x => (TypeId: EffectiveFightSkillType(x.Weapon), Style: x.Style!))
                .Where(x => x.TypeId != 0)
                .GroupBy(x => x.TypeId)
                .ToDictionary(x => x.Key, x => x.First().Style.Id);
            loadouts.Add(spiritId, new CombatLoadout(spiritId, personalWeapons, personalSlots, defaultWeapon, styleByType));
        }

        // Unlock every authored style. IsShowInArmony remains a client-side presentation filter,
        // while hidden/private character styles must still be executable by their weapon slots.
        var unlockedStyleIds = styles.Values
            .Select(x => x.Id)
            .OrderBy(x => x)
            .ToArray();
        var resourceMaximums = resourceRows
            .Where(x => TryUInt32(x, "Id", out _) && TrySingle(x, "Max", out _))
            .ToDictionary(x => x.GetProperty("Id").GetUInt32(), x => x.GetProperty("Max").GetSingle());

        // Shared-armory metadata must be authored from the weapon itself, not from the initial
        // protagonist's character-specific view. Otherwise ordinary fist weapons inherit Void Claw
        // and signature weapons such as Garm's bat lose their owner-only DK9 style in the inventory UI.
        var accountWeapons = accountWeaponSources
            .Select(source =>
            {
                var instanceId = accountInstanceByTemplate[source.TemplateId];
                if (source.OwnerSpiritId != 0 &&
                    weaponsBySpiritAndInstance.TryGetValue((source.OwnerSpiritId, instanceId), out var ownerView))
                    return ownerView;

                var seed = weaponsBySpiritAndInstance.GetValueOrDefault((config.Player.InitialSpiritTemplateId, instanceId))
                    ?? weaponsBySpiritAndInstance.First(x => x.Key.InstanceId == instanceId).Value;
                var effectiveType = EffectiveFightSkillType(source);
                var authoredStyle = ResolveAuthoredAccountStyle(source, effectiveType, styles, defaultStyleByType);
                return authoredStyle is null
                    ? seed
                    : seed with
                    {
                        WeaponFightSkillTypeId = effectiveType != 0 ? effectiveType : authoredStyle.FightSkillTypeId,
                        Style = authoredStyle
                    };
            })
            .ToArray();
        var accountWeaponsByInstance = accountWeapons.ToDictionary(x => x.InstanceId);

        foreach (var loadout in loadouts.Values.OrderBy(x => x.SpiritTemplateId))
        {
            foreach (var signature in loadout.Weapons.Where(x => x.IsPrivate && x.TemplateId != 80003412u))
                Console.WriteLine($"[SIGNATURE-STYLE] spirit={loadout.SpiritTemplateId} weapon={signature.TemplateId}/{signature.InstanceId} type={signature.WeaponFightSkillTypeId} style={signature.Style.Id}:{signature.Style.Name} action={signature.Style.ActionType}");
        }

        Console.WriteLine(
            $"[COMBAT-CATALOG] build={config.Client.Version} loadouts={loadouts.Count} " +
            $"accountWeapons={accountWeapons.Length} personalWeapons={loadouts.Values.Sum(x => x.Weapons.Count)} " +
            $"signatureSpirits={loadouts.Values.Count(x => x.Weapons.Any(w => w.IsPrivate && w.TemplateId != 80003412u))} " +
            $"perSpiritViews={weaponsBySpiritAndInstance.Count} styles={styles.Count} unlocked={unlockedStyleIds.Length} source={root}");
        return new CombatCatalog(
            loadouts,
            accountWeapons,
            accountWeaponsByInstance,
            weaponsBySpiritAndInstance,
            styles,
            defaultStyleByType,
            unlockedStyleIds,
            resourceMaximums,
            skillMetadata.ToDictionary(x => x.Key, x => x.Value.CastTypeTag),
            accountWeaponSources.SelectMany(x => x.BulletIds).Where(x => x != 0).Distinct().OrderBy(x => x).ToArray());
    }

    private static CombatStyleDefinition? ResolveStyle(
        WeaponSource weapon,
        uint effectiveFightSkillTypeId,
        uint spiritId,
        IReadOnlyList<uint> initialStyleIds,
        IReadOnlyDictionary<uint, CombatStyleDefinition> styles,
        IReadOnlyDictionary<uint, uint> defaultStyleByType,
        PrivateServerConfig config)
    {
        bool SpiritCompatible(CombatStyleDefinition style)
            => style.SpiritIds.Count == 0 || style.SpiritIds.Contains(spiritId);
        bool TypeCompatible(CombatStyleDefinition style)
            => SpiritCompatible(style) &&
               (effectiveFightSkillTypeId == 0 || style.FightSkillTypeId == effectiveFightSkillTypeId);
        bool AuthoredTypeCompatible(CombatStyleDefinition style)
            => TypeCompatible(style) ||
               (defaultStyleByType.TryGetValue(effectiveFightSkillTypeId, out var authoredDefault) && authoredDefault == style.Id);
        // Stock build 4229938 makes SceneitemConfig.FixedFightSkill authoritative: both the Lua
        // WeaponManager and FightStyleManager return it before consulting the per-character/default
        // category. Keep the exact authored fixed row even when FightSkillType is zero; substituting a
        // guessed generic style is what produced the wrong signature/prototype martial arts.
        if (weapon.FixedFightStyleId != 0 &&
            styles.TryGetValue(weapon.FixedFightStyleId, out var fixedStyle))
            return fixedStyle;
        foreach (var styleId in initialStyleIds)
        {
            if (styles.TryGetValue(styleId, out var initialStyle) &&
                SpiritCompatible(initialStyle) && AuthoredTypeCompatible(initialStyle))
                return initialStyle;
        }
        if (spiritId == config.Player.InitialSpiritTemplateId &&
            styles.TryGetValue(config.Gameplay.Combat.FightStyleId, out var configuredStyle) && TypeCompatible(configuredStyle))
            return configuredStyle;
        var characterStyle = styles.Values
            .Where(x => x.SpiritIds.Contains(spiritId) && AuthoredTypeCompatible(x))
            .OrderBy(x => x.Id)
            .FirstOrDefault();
        if (characterStyle is not null)
            return characterStyle;
        if (defaultStyleByType.TryGetValue(effectiveFightSkillTypeId, out var defaultStyleId) &&
            styles.TryGetValue(defaultStyleId, out var defaultStyle) && SpiritCompatible(defaultStyle))
            return defaultStyle;
        return styles.Values.Where(TypeCompatible).OrderBy(x => x.Id).FirstOrDefault();
    }

    private static CombatStyleDefinition? ResolveAuthoredAccountStyle(
        WeaponSource weapon,
        uint effectiveFightSkillTypeId,
        IReadOnlyDictionary<uint, CombatStyleDefinition> styles,
        IReadOnlyDictionary<uint, uint> defaultStyleByType)
    {
        if (weapon.FixedFightStyleId != 0 &&
            styles.TryGetValue(weapon.FixedFightStyleId, out var fixedStyle) &&
            fixedStyle.FightSkillTypeId != 0 &&
            (effectiveFightSkillTypeId == 0 || fixedStyle.FightSkillTypeId == effectiveFightSkillTypeId ||
             defaultStyleByType.GetValueOrDefault(effectiveFightSkillTypeId) == fixedStyle.Id))
            return fixedStyle;
        return defaultStyleByType.TryGetValue(effectiveFightSkillTypeId, out var defaultStyleId) &&
               styles.TryGetValue(defaultStyleId, out var defaultStyle)
            ? defaultStyle
            : null;
    }

    private static bool IsCompleteAbilityStyle(CombatStyleDefinition? style)
        => style is not null && style.ActiveSkill != 0 && style.UniqueSkill != 0;

    private static int AbilityCompleteness(CombatStyleDefinition style)
        => (style.ActiveSkill != 0 ? 2 : 0) + (style.UniqueSkill != 0 ? 4 : 0) +
           (style.CommonSkill != 0 ? 1 : 0);

    private static CombatStyleDefinition? ParseStyle(
        JsonElement value,
        IReadOnlyDictionary<uint, SkillMetadata> skills,
        IReadOnlyDictionary<uint, uint> jumpTargets,
        IReadOnlyDictionary<uint, uint[]> genericJumpTargets)
    {
        if (!TryUInt32(value, "Id", out var id) || !TryUInt32(value, "FightSkillType", out var typeId))
            return null;

        uint Skill(string name) => TryUInt32(value, name, out var skillId) ? skillId : 0u;
        var rootSkills = new uint[]
        {
            Skill("CommonSkill"), Skill("PressinCommonSkill"), Skill("HeavyCommonSkill"),
            Skill("ControlPowerSkill"), Skill("DodgeSkill"), Skill("DodgeAttackSkill"), Skill("GousuoSkill"),
            Skill("JumpSkill"), Skill("JumpAttackSkill"), Skill("ActiveSkill"), Skill("UpActiveSkill"),
            Skill("LongPressActiveSkill"), Skill("UniqueSkill"), Skill("UpUniqueSkill"),
            Skill("LongPressUniqueSkill"), Skill("SwitchSkill")
        };
        var allowed = rootSkills.Where(x => x != 0).ToHashSet();
        var queue = new Queue<uint>(allowed);
        while (queue.TryDequeue(out var skillId))
        {
            if (!skills.TryGetValue(skillId, out var metadata))
                continue;
            // SkillJumpId contains timed/input transitions while SkillReplace contains conditional
            // variants (distance, stance, buffs and several charged-attack stages). Both arrays hold
            // SkillJumpConfig ids and therefore must be resolved through SkillJumpConfig.Skillid.
            foreach (var next in metadata.RelatedSkills
                         .Concat(metadata.TransitionIds.Select(transitionId => jumpTargets.GetValueOrDefault(transitionId)))
                         .Concat(metadata.TransitionIds.SelectMany(
                             transitionId => genericJumpTargets.GetValueOrDefault(transitionId) ?? [])))
            {
                if (next != 0 && allowed.Add(next))
                    queue.Enqueue(next);
            }
        }

        float Cooldown(uint skillId)
            => skills.TryGetValue(skillId, out var metadata) ? metadata.Cooldown : 0f;
        uint First(params uint[] values) => values.FirstOrDefault(x => x != 0);
        uint FirstTagged(uint tag, params uint[] values)
            => values.FirstOrDefault(x => x != 0 && skills.GetValueOrDefault(x)?.CastTypeTag == tag);
        var activeRoots = new[] { Skill("ActiveSkill"), Skill("UpActiveSkill"), Skill("LongPressActiveSkill") };
        var uniqueRoots = new[] { Skill("UniqueSkill"), Skill("UpUniqueSkill"), Skill("LongPressUniqueSkill") };
        var active = FirstTagged(6u, activeRoots);
        if (active == 0) active = First(activeRoots);
        var unique = First(uniqueRoots);
        // Gun Fu and a few other authored styles store an ultimate in a long-press field.
        if (unique == 0) unique = FirstTagged(7u, rootSkills);

        return new CombatStyleDefinition(
            id,
            TryString(value, "Name") ?? $"Style {id}",
            typeId,
            TryUInt32(value, "ActionType", out var actionType) ? actionType : 0u,
            ReadUInt32Array(value, "SpiritId").ToHashSet(),
            TryBool(value, "IsShowInArmony"),
            Skill("CommonSkill"),
            Skill("PressinCommonSkill"),
            Skill("HeavyCommonSkill"),
            Skill("ControlPowerSkill"),
            Skill("DodgeSkill"),
            Skill("DodgeAttackSkill"),
            Skill("GousuoSkill"),
            active,
            unique,
            Skill("SwitchSkill"),
            allowed,
            allowed.ToDictionary(x => x, Cooldown),
            allowed.ToDictionary(
                x => x,
                x => skills.TryGetValue(x, out var metadata) ? metadata.MaximumCharges : 0u));
    }

    private static SkillMetadata? ParseSkillMetadata(JsonElement value)
    {
        if (!TryUInt32(value, "Id", out var id))
            return null;
        // ClientConfig declares Cooldown as a float period and CooldownTime as an integer use/stock
        // count. Treating CooldownTime as seconds gives charge/combo attacks (Cooldown=0,
        // CooldownTime=1) an artificial one-second cooldown and breaks their release transitions.
        var cooldown = TrySingle(value, "Cooldown", out var seconds) && seconds > 0f ? seconds : 0f;
        var maximumCharges = TryUInt32(value, "CooldownTime", out var configuredCharges)
            ? configuredCharges
            : 0u;
        return new SkillMetadata(
            id,
            cooldown,
            cooldown > 0f ? Math.Max(1u, maximumCharges) : 0u,
            TryUInt32(value, "SkillCastTypeTag", out var castTypeTag) ? castTypeTag : 0u,
            ReadUInt32Array(value, "SkillJumpId")
                .Concat(ReadUInt32Array(value, "SkillReplace"))
                .Distinct()
                .ToArray(),
            ReadUInt32Array(value, "ComboSkillId")
                .Concat(ReadUInt32Array(value, "ConnectedCdSkills"))
                .Distinct()
                .ToArray());
    }

    private static WeaponSource? ParseWeaponSource(
        JsonElement value,
        IReadOnlyDictionary<uint, WeaponShootSource> shootById,
        IReadOnlyDictionary<uint, LegacyWeaponSource> legacyById)
    {
        if (!TryUInt32(value, "Id", out var id))
            return null;
        TryUInt32(value, "OldWeaponId", out var legacyWeaponId);
        var legacy = legacyWeaponId != 0 ? legacyById.GetValueOrDefault(legacyWeaponId) : null;
        TryUInt32(value, "WeaponBelong", out var owner);
        if (owner == 0)
            owner = legacy?.OwnerSpiritId ?? 0u;
        TryUInt32(value, "FightSkillType", out var styleType);
        if (styleType == 0)
            styleType = legacy?.FightSkillTypeId ?? 0u;
        TryUInt32(value, "FixedFightSkill", out var fixedStyle);
        if (fixedStyle == 0)
            fixedStyle = legacy?.FixedFightStyleId ?? 0u;
        TryUInt32(value, "ShootId", out var shootId);
        TryUInt32(value, "SWeaponWheelsIconId", out var wheelIconId);
        TryInt32(value, "Durability", out var durability);
        TryInt32(value, "BulletNum", out var magazineAmmo);
        var shoot = shootById.GetValueOrDefault(shootId) ?? new WeaponShootSource(false, false, [], 0);
        return new WeaponSource(
            id,
            TryString(value, "Name") ?? $"Weapon {id}",
            legacyWeaponId,
            owner,
            styleType,
            fixedStyle,
            durability,
            magazineAmmo,
            shoot.BulletIds,
            shoot.IsShootWeapon,
            shoot.SeparateBullets,
            shoot.ReloadSkillId,
            wheelIconId,
            TryBool(value, "NotEnterRoulette"));
    }

    private static JsonElement[] ReadRecords(string path)
    {
        if (!File.Exists(path))
            throw new FileNotFoundException($"Required combat config is missing: {path}");
        using var document = JsonDocument.Parse(File.ReadAllText(path));
        if (!document.RootElement.TryGetProperty("records", out var records) || records.ValueKind != JsonValueKind.Array)
            throw new InvalidDataException($"Combat config does not contain a records array: {path}");
        return records.EnumerateArray().Select(x => x.Clone()).ToArray();
    }

    private static uint[] ReadUInt32Array(JsonElement value, string name)
    {
        if (!value.TryGetProperty(name, out var item) || item.ValueKind != JsonValueKind.Array)
            return [];
        return item.EnumerateArray().Where(x => x.TryGetUInt32(out _)).Select(x => x.GetUInt32()).ToArray();
    }

    private static string[] ReadStringArray(JsonElement value, string name)
    {
        if (!value.TryGetProperty(name, out var item) || item.ValueKind != JsonValueKind.Array)
            return [];
        return item.EnumerateArray()
            .Where(x => x.ValueKind == JsonValueKind.String)
            .Select(x => x.GetString())
            .Where(x => !string.IsNullOrWhiteSpace(x))
            .Select(x => x!)
            .ToArray();
    }

    private static bool TryUInt32(JsonElement value, string name, out uint result)
    {
        result = default;
        return value.TryGetProperty(name, out var item) && item.TryGetUInt32(out result);
    }

    private static bool TryInt32(JsonElement value, string name, out int result)
    {
        result = default;
        return value.TryGetProperty(name, out var item) && item.TryGetInt32(out result);
    }

    private static bool TrySingle(JsonElement value, string name, out float result)
    {
        result = default;
        return value.TryGetProperty(name, out var item) && item.TryGetSingle(out result);
    }

    private static string? TryString(JsonElement value, string name)
        => value.TryGetProperty(name, out var item) && item.ValueKind == JsonValueKind.String ? item.GetString() : null;

    private static bool TryBool(JsonElement value, string name)
        => value.TryGetProperty(name, out var item) && item.ValueKind == JsonValueKind.True;

    private sealed record CombatCatalog(
        Dictionary<uint, CombatLoadout> Loadouts,
        CombatWeaponDefinition[] AccountWeapons,
        Dictionary<ulong, CombatWeaponDefinition> AccountWeaponsByInstance,
        Dictionary<(uint SpiritId, ulong InstanceId), CombatWeaponDefinition> WeaponsBySpiritAndInstance,
        Dictionary<uint, CombatStyleDefinition> Styles,
        Dictionary<uint, uint> DefaultStyleByType,
        uint[] UnlockedStyleIds,
        Dictionary<uint, float> ResourceMaximums,
        Dictionary<uint, uint> SkillCastTags,
        uint[] AmmoTemplateIds);

    private sealed record WeaponSource(
        uint TemplateId,
        string Name,
        uint LegacyWeaponId,
        uint OwnerSpiritId,
        uint FightSkillTypeId,
        uint FixedFightStyleId,
        int Durability,
        int MagazineAmmo,
        uint[] BulletIds,
        bool IsShootWeapon,
        bool SeparateBullets,
        uint ReloadSkillId,
        uint WheelIconId,
        bool NotEnterRoulette);

    private sealed record WeaponShootSource(
        bool IsShootWeapon,
        bool SeparateBullets,
        uint[] BulletIds,
        uint ReloadSkillId);

    private sealed record LegacyWeaponSource(
        uint OwnerSpiritId,
        uint FightSkillTypeId,
        uint FixedFightStyleId);

    private sealed record SpiritCombatSource(
        uint[] InitialStyleIds,
        uint FistSceneItemId,
        uint PrivateSceneItemId,
        uint[] GeneralSceneItemIds,
        string[] WeaponSlotNames);

    private sealed record SkillMetadata(
        uint Id,
        float Cooldown,
        uint MaximumCharges,
        uint CastTypeTag,
        uint[] TransitionIds,
        uint[] RelatedSkills);
}

internal sealed record CombatLoadout(
    uint SpiritTemplateId,
    IReadOnlyList<CombatWeaponDefinition> Weapons,
    IReadOnlyList<CombatWeaponDefinition?> Slots,
    CombatWeaponDefinition DefaultWeapon,
    IReadOnlyDictionary<uint, uint> StyleByType)
{
    internal CombatWeaponDefinition? WeaponAt(int index)
        => index >= 0 && index < Slots.Count ? Slots[index] : null;

    internal CombatWeaponDefinition? Weapon(ulong instanceId)
        => Weapons.FirstOrDefault(x => x.InstanceId == instanceId);
}

internal sealed record CombatWeaponDefinition(
    uint SpiritTemplateId,
    uint TemplateId,
    ulong InstanceId,
    string Name,
    int Durability,
    int MagazineAmmo,
    uint BulletId,
    IReadOnlyList<uint> BulletIds,
    bool IsShootWeapon,
    bool SeparateBullets,
    uint ReloadSkillId,
    bool IsPrivate,
    uint WeaponFightSkillTypeId,
    CombatStyleDefinition Style,
    CombatStyleDefinition AbilityFallbackStyle)
{
    internal uint ActiveSkill(CombatStyleDefinition selectedStyle)
        => selectedStyle.ActiveSkill != 0 ? selectedStyle.ActiveSkill : AbilityFallbackStyle.ActiveSkill;

    internal uint UniqueSkill(CombatStyleDefinition selectedStyle)
        => selectedStyle.UniqueSkill != 0 ? selectedStyle.UniqueSkill : AbilityFallbackStyle.UniqueSkill;

    internal bool AllowsSkill(CombatStyleDefinition selectedStyle, uint skillId)
        => selectedStyle.AllowedSkillIds.Contains(skillId) ||
           AbilityFallbackStyle.AllowedSkillIds.Contains(skillId) ||
           (IsShootWeapon && CombatCatalogRepository.IsNativeShootSkill(skillId)) ||
           // Build 4229938 executes many stance/charge/conditional subskills from the native
           // SkillJumpGraphAsset. Those graph nodes are not exported in the JSON config set, so an
           // exact server-side reconstruction of AllowedSkillIds is necessarily incomplete. Trust
           // the unmodified stock client for graph membership and reject only ids absent from the
           // build's own SkillConfig. This keeps style selection authoritative while allowing every
           // native subskill the selected martial art can actually emit.
           CombatCatalogRepository.IsKnownSkill(skillId);

    internal int InitialMagazineAmmo
        => !IsShootWeapon || MagazineAmmo < 0 || SeparateBullets || Durability < 0
            ? MagazineAmmo
            : Math.Min(MagazineAmmo, Durability);

    // Separate-ammo guns use Durability as the loaded-ammo value in the shared Armory UI,
    // while ordinary guns use it as total remaining ammo (magazine + reserve).
    internal int InitialClientDurability
        => IsShootWeapon && SeparateBullets ? InitialMagazineAmmo : Durability;

    internal bool IsReloadSkill(uint skillId)
        => IsShootWeapon && (skillId == ReloadSkillId || CombatCatalogRepository.SkillCastTag(skillId) == 19u);

    internal bool IsShotSkill(uint skillId)
        => IsShootWeapon && CombatCatalogRepository.SkillCastTag(skillId) == 10u;

    internal IEnumerable<uint> EffectiveSkillIds(CombatStyleDefinition selectedStyle)
        => selectedStyle.AllowedSkillIds.Concat(AbilityFallbackStyle.AllowedSkillIds).Distinct();

    internal float Cooldown(CombatStyleDefinition selectedStyle, uint skillId, float fallback = 1f)
        => selectedStyle.SkillCooldowns.TryGetValue(skillId, out var selected) && selected > 0f
            ? selected
            : AbilityFallbackStyle.Cooldown(skillId, fallback);

    internal uint MaximumCharges(CombatStyleDefinition selectedStyle, uint skillId)
        => selectedStyle.SkillMaximumCharges.TryGetValue(skillId, out var selected) && selected > 0
            ? selected
            : AbilityFallbackStyle.MaximumCharges(skillId);
}

internal sealed record CombatStyleDefinition(
    uint Id,
    string Name,
    uint FightSkillTypeId,
    uint ActionType,
    IReadOnlySet<uint> SpiritIds,
    bool ShowInArmory,
    uint CommonSkill,
    uint PressCommonSkill,
    uint HeavyCommonSkill,
    uint ControlSkill,
    uint DodgeSkill,
    uint DodgeAttackSkill,
    uint GrappleAttackSkill,
    uint ActiveSkill,
    uint UniqueSkill,
    uint SwitchSkill,
    IReadOnlySet<uint> AllowedSkillIds,
    IReadOnlyDictionary<uint, float> SkillCooldowns,
    IReadOnlyDictionary<uint, uint> SkillMaximumCharges)
{
    internal float Cooldown(uint skillId, float fallback = 1f)
        => SkillCooldowns.TryGetValue(skillId, out var value) && value > 0f ? value : fallback;

    internal uint MaximumCharges(uint skillId)
        => SkillMaximumCharges.TryGetValue(skillId, out var value) ? value : 0u;
}
