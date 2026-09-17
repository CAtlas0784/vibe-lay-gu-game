using Ananta.SDK.Rpc;
using Ananta.Server.ClientData.Client4229938;
using Ananta.Server.Handlers;
using Ananta.Server.Protocol.Client4229938;
using GameMethods = Ananta.Server.RpcTypes.Client4229938.Methods.Game;
using SceneMethods = Ananta.Server.RpcTypes.Client4229938.Methods.GameScene;

namespace Ananta.Server.Handlers.Game;

/// <summary>Authoritative weapon, fight-style and skill lifecycle for the current local unit.</summary>
internal sealed partial class GameRouter
{
    async Task OnClientUseSkill(RpcContext ctx, SceneMethods.SkillUseData req)
    {
        var state = GetWorldState(ctx);
        await ctx.ReturnEmptyOkAsync();

        if (!state.CombatProfilePublished)
        {
            ctx.Session.Log.Warn("[COMBAT] skill request arrived before initial combat profile");
            return;
        }

        if (req.Releaser != 0 && req.Releaser != state.ActiveSpiritUnitId)
        {
            ctx.Session.Log.Warn($"[COMBAT] reject releaser={req.Releaser} active={state.ActiveSpiritUnitId} skill={req.SkillId}");
            return;
        }

        var style = ActiveStyle(state);
        var weapon = CombatCodec.Weapon(state.ActiveSpiritTemplateId, state.ActiveWeaponInstanceId)
            ?? CombatCodec.DefaultWeapon(state.ActiveSpiritTemplateId);
        if (weapon.IsReloadSkill(req.SkillId))
            await ReloadWeapon4229938(ctx, state, weapon);
        if (!weapon.AllowsSkill(style, req.SkillId))
        {
            ctx.Session.Log.Warn($"[COMBAT] reject unknown-skill style={style.Id} weapon={state.ActiveWeaponInstanceId} skill={req.SkillId} inst={req.SkillInstanceId}");
            return;
        }

        var cooldown = weapon.Cooldown(style, req.SkillId, 0f);
        var nowTicks = Environment.TickCount64;
        if (cooldown > 0f)
        {
            if (state.SkillCooldownUntilTicks.TryGetValue(req.SkillId, out var untilTicks) && nowTicks < untilTicks)
            {
                ctx.Session.Log.Warn($"[COMBAT] reject skill={req.SkillId} cooldown remaining={untilTicks - nowTicks}ms");
                return;
            }
            state.SkillCooldownUntilTicks[req.SkillId] = nowTicks + (long)(cooldown * 1000f);
        }
        else
        {
            // Prevent rapid re-triggering of the same active or unique skill while the animation is executing
            if (state.ActiveSkillId == req.SkillId &&
                (req.SkillId == weapon.ActiveSkill(style) || req.SkillId == weapon.UniqueSkill(style)) &&
                (nowTicks - state.ActiveSkillStartedTicks) < 1200)
            {
                ctx.Session.Log.Warn($"[COMBAT] ignore rapid spam of active/unique skill={req.SkillId} elapsed={nowTicks - state.ActiveSkillStartedTicks}ms");
                return;
            }
        }

        state.CombatUseCount++;
        state.RestoreResourcesAfterActiveSkill |=
            req.SkillId == weapon.ActiveSkill(style) ||
            req.SkillId == weapon.UniqueSkill(style) ||
            weapon.Cooldown(style, req.SkillId, 0f) > 0f ||
            weapon.MaximumCharges(style, req.SkillId) > 0;
        state.ActiveSkillId = req.SkillId;
        state.ActiveClientSkillInstanceId = req.SkillInstanceId;
        state.ActiveSkillStartedTicks = Environment.TickCount64;

        if (state.CombatUseCount <= 20 || state.CombatUseCount % 50 == 0)
            ctx.Session.Log.Info($"[COMBAT] use unit={state.ActiveSpiritUnitId} weapon={state.ActiveWeaponInstanceId} style={style.Id} skill={req.SkillId} inst={req.SkillInstanceId} target={req.TargetId} nativeAction=true count={state.CombatUseCount}");
    }

    async Task OnReportSkillEnd(RpcContext ctx, SceneMethods.ReportSkillEnd report)
    {
        var state = GetWorldState(ctx);
        state.CombatEndCount++;
        var elapsed = state.ActiveSkillStartedTicks > 0
            ? Math.Max(0, Environment.TickCount64 - state.ActiveSkillStartedTicks)
            : -1;

        if (state.CombatEndCount <= 20 || state.CombatEndCount % 50 == 0)
            ctx.Session.Log.Info($"[COMBAT] end unit={report.unitId} token={report.skillId} next={report.newSkillId} break={report.isBreak} elapsedMs={elapsed} count={state.CombatEndCount}");

        var style = ActiveStyle(state);
        var weapon = CombatCodec.Weapon(state.ActiveSpiritTemplateId, state.ActiveWeaponInstanceId)
            ?? CombatCodec.DefaultWeapon(state.ActiveSpiritTemplateId);
        if (report.newSkillId != 0 && weapon.AllowsSkill(style, report.newSkillId))
        {
            // isBreak describes how the previous native action ended, not whether the authored chain
            // ended. The client reports isBreak=true + a non-zero newSkillId for ordinary rapid-click
            // combo transitions. Keep every known next skill alive and never inject cooldown/resource
            // snapshots between click, hold and release stages.
            state.ActiveSkillId = report.newSkillId;
            state.ActiveClientSkillInstanceId = 0;
            state.ActiveSkillStartedTicks = Environment.TickCount64;
            return;
        }

        var restoreResources = state.RestoreResourcesAfterActiveSkill;
        state.ActiveSkillId = 0;
        state.RestoreResourcesAfterActiveSkill = false;
        state.ActiveClientSkillInstanceId = 0;
        state.ActiveSkillStartedTicks = 0;

        // Do not immediately force full recharge here, allowing skills to respect their configured cooldowns.
        if (!restoreResources)
            return;
    }

    Task OnSkillHit(RpcContext ctx, SceneMethods.SkillHitData hit)
    {
        var state = GetWorldState(ctx);
        if (hit.ReleaserId != 0 && hit.ReleaserId != state.ActiveSpiritUnitId)
        {
            ctx.Session.Log.Warn($"[HIT] reject releaser={hit.ReleaserId} active={state.ActiveSpiritUnitId} skill={hit.SkillId}");
            return Task.CompletedTask;
        }

        var style = ActiveStyle(state);
        var weapon = CombatCodec.Weapon(state.ActiveSpiritTemplateId, state.ActiveWeaponInstanceId)
            ?? CombatCodec.DefaultWeapon(state.ActiveSpiritTemplateId);
        if (!weapon.AllowsSkill(style, hit.SkillId))
        {
            ctx.Session.Log.Warn($"[HIT] reject unknown-skill style={style.Id} skill={hit.SkillId} target={hit.HitTarget}");
            return Task.CompletedTask;
        }

        state.CombatHitCount++;
        if (state.CombatHitCount <= 20 || state.CombatHitCount % 100 == 0)
            ctx.Session.Log.Info($"[HIT] accepted unit={state.ActiveSpiritUnitId} skill={hit.SkillId} target={hit.HitTarget} stage={hit.Stage} trigger={hit.TriggerIndex}/{hit.TriggerInstanceId} material={hit.HitMaterial} reflected={hit.IsReflected} count={state.CombatHitCount}");
        return Task.CompletedTask;
    }

    async Task OnSwitchWeapon(RpcContext ctx, int index)
    {
        var state = GetWorldState(ctx);
        if (!state.Ready || state.PendingSwitchTemplateId != 0)
        {
            ctx.Session.Log.Warn($"[WEAPON] ignored index={index} ready={state.Ready} pendingSpirit={state.PendingSwitchTemplateId}");
            return;
        }

        var slotWeapons = WeaponSlotDefinitions(state, state.ActiveSpiritTemplateId);
        var weapon = index >= 0 && index < slotWeapons.Count ? slotWeapons[index] : null;
        if (weapon is null)
        {
            ctx.Session.Log.Warn($"[WEAPON] invalid index={index} template={state.ActiveSpiritTemplateId} slots={slotWeapons.Count}");
            return;
        }

        var style = ResolveWeaponStyle(state, weapon);
        if (state.ActiveSkillId != 0)
            await ctx.NotifyAsync(MethodId.SyncBreakSkill, CombatCodec.BreakSkill(state.ActiveSpiritUnitId));

        state.ActiveSkillId = 0;
        state.RestoreResourcesAfterActiveSkill = false;
        state.ActiveClientSkillInstanceId = 0;
        state.ActiveSkillStartedTicks = 0;
        state.ActiveWeaponInstanceId = weapon.InstanceId;
        state.ActiveFightStyleId = style.Id;
        state.LastWeaponBySpirit[state.ActiveSpiritTemplateId] = weapon.InstanceId;

        // Re-send the authoritative slot snapshot as a cheap self-heal if the client rebuilt its
        // WeaponManager during a scene/UI transition.
        await PublishWeaponSnapshot(ctx, state.ActiveSpiritUnitId, state.ActiveSpiritTemplateId, weapon.InstanceId);
        await ctx.NotifyAsync(MethodId.SyncSpiritSwitchWeaponAction,
            CombatCodec.SpiritSwitchWeapon(state.ActiveSpiritUnitId, weapon.InstanceId));
        await PublishSelectedWeaponProfile(ctx, state.ActiveSpiritUnitId, state.ActiveSpiritTemplateId, weapon, style);
        ctx.Session.Log.Info($"[WEAPON] switched template={state.ActiveSpiritTemplateId} unit={state.ActiveSpiritUnitId} slot={index} page={index / 8 + 1} weapon={weapon.TemplateId}/{weapon.InstanceId} name={weapon.Name} style={style.FightSkillTypeId}:{style.Id} skills={style.CommonSkill},{style.HeavyCommonSkill},{weapon.ActiveSkill(style)},{weapon.UniqueSkill(style)}");
    }

    async Task OnSwitchFightStyle(RpcContext ctx, uint spiritId, uint fightStyleTypeId, uint fightStyleId)
    {
        var state = GetWorldState(ctx);
        var style = CombatCatalogRepository.Style(fightStyleId);
        if (style is null || !CombatCatalogRepository.StyleMatchesType(fightStyleId, fightStyleTypeId) ||
            (style.SpiritIds.Count > 0 && !style.SpiritIds.Contains(spiritId)))
        {
            ctx.Session.Log.Warn($"[STYLE] rejected spirit={spiritId} type={fightStyleTypeId} style={fightStyleId}");
            return;
        }

        if (spiritId == state.ActiveSpiritTemplateId &&
            CombatCodec.Weapon(spiritId, state.ActiveWeaponInstanceId) is { } activeWeapon &&
            (activeWeapon.WeaponFightSkillTypeId == fightStyleTypeId || activeWeapon.Style.FightSkillTypeId == fightStyleTypeId) &&
            !CombatCatalogRepository.IsStyleCompatible(activeWeapon, style))
        {
            var safeStyle = ResolveWeaponStyle(state, activeWeapon);
            await ctx.NotifyAsync(MethodId.SyncSpiritFightStyleChangeAction,
                CombatCodec.FightStyleAction(spiritId, SpiritFightStyleOverrides(state, spiritId)));
            ctx.Session.Log.Warn($"[STYLE] rejected+restored model-incompatible spirit={spiritId} weapon={activeWeapon.TemplateId}/{activeWeapon.InstanceId} requested={fightStyleId} restored={safeStyle.Id} actionType={style.ActionType} baseActionType={activeWeapon.Style.ActionType}");
            return;
        }

        // The RPC carries the category being replaced. Keep exactly that key; duplicating the
        // style under FightSkillConfig.FightSkillType can overwrite an unrelated special category.
        state.SpiritStyleOverrides[(spiritId, fightStyleTypeId)] = fightStyleId;
        await ctx.NotifyAsync(MethodId.SyncSpiritFightStyleChangeAction,
            CombatCodec.FightStyleAction(spiritId, SpiritFightStyleOverrides(state, spiritId)));

        if (spiritId == state.ActiveSpiritTemplateId)
        {
            // FightStyleManager also keeps a weapon-instance style cache. Refresh the equipped
            // instances in this category so the explicit live FightStyleId follows Replace All.
            foreach (var instanceId in WeaponSlotIds(state, spiritId).Where(x => x != 0).Distinct())
            {
                if (CombatCodec.Weapon(spiritId, instanceId) is not { } slotWeapon)
                    continue;
                if (slotWeapon.WeaponFightSkillTypeId != fightStyleTypeId &&
                    slotWeapon.Style.FightSkillTypeId != fightStyleTypeId)
                    continue;
                var slotStyle = ResolveWeaponStyle(state, slotWeapon);
                await ctx.NotifyAsync(MethodId.SyncWeaponFightStyleChange,
                    new GameMethods.SyncWeaponFightStyleChange
                    {
                        weaponInstanceId = instanceId,
                        fightStyleId = slotStyle.Id
                    });
            }

            var weapon = CombatCodec.Weapon(spiritId, state.ActiveWeaponInstanceId);
            if (weapon is not null &&
                (weapon.WeaponFightSkillTypeId == fightStyleTypeId || weapon.Style.FightSkillTypeId == fightStyleTypeId))
            {
                if (state.ActiveSkillId != 0)
                    await ctx.NotifyAsync(MethodId.SyncBreakSkill, CombatCodec.BreakSkill(state.ActiveSpiritUnitId));
                state.ActiveSkillId = 0;
                state.RestoreResourcesAfterActiveSkill = false;
                state.ActiveClientSkillInstanceId = 0;
                state.ActiveSkillStartedTicks = 0;
                var effectiveStyle = ResolveWeaponStyle(state, weapon);
                state.ActiveFightStyleId = effectiveStyle.Id;
                await PublishSelectedWeaponProfile(ctx, state.ActiveSpiritUnitId, spiritId, weapon, effectiveStyle);
            }
        }
        ctx.Session.Log.Info($"[STYLE] switched spirit={spiritId} type={fightStyleTypeId} style={fightStyleId} name={style.Name}");
    }

    async Task OnSetWeaponFightStyle(RpcContext ctx, ulong weaponInstanceId, uint fightStyleId)
    {
        var state = GetWorldState(ctx);
        var weapon = CombatCatalogRepository.Weapon(state.ActiveSpiritTemplateId, weaponInstanceId)
            ?? CombatCatalogRepository.Weapon(weaponInstanceId);
        var style = CombatCatalogRepository.Style(fightStyleId);
        if (weapon is null || style is null || !CombatCatalogRepository.IsStyleCompatible(weapon, style))
        {
            if (weapon is not null)
            {
                var safeStyle = ResolveWeaponStyle(state, weapon);
                await ctx.NotifyAsync(MethodId.SyncWeaponFightStyleChange,
                    new GameMethods.SyncWeaponFightStyleChange
                    {
                        weaponInstanceId = weaponInstanceId,
                        fightStyleId = safeStyle.Id
                    });
                if (weaponInstanceId == state.ActiveWeaponInstanceId)
                    await PublishSelectedWeaponProfile(ctx, state.ActiveSpiritUnitId, state.ActiveSpiritTemplateId, weapon, safeStyle);
                ctx.Session.Log.Warn($"[STYLE] rejected+restored weapon={weapon.TemplateId}/{weaponInstanceId} requested={fightStyleId} restored={safeStyle.Id} requestedAction={style?.ActionType ?? 0} baseAction={weapon.Style.ActionType}");
            }
            else
            {
                ctx.Session.Log.Warn($"[STYLE] rejected unknown weapon={weaponInstanceId} style={fightStyleId}");
            }
            return;
        }

        state.WeaponStyleOverrides[weaponInstanceId] = fightStyleId;
        await ctx.NotifyAsync(MethodId.SyncWeaponFightStyleChange,
            new GameMethods.SyncWeaponFightStyleChange
            {
                weaponInstanceId = weaponInstanceId,
                fightStyleId = fightStyleId
            });

        if (weaponInstanceId == state.ActiveWeaponInstanceId)
        {
            if (state.ActiveSkillId != 0)
                await ctx.NotifyAsync(MethodId.SyncBreakSkill, CombatCodec.BreakSkill(state.ActiveSpiritUnitId));
            state.ActiveSkillId = 0;
            state.RestoreResourcesAfterActiveSkill = false;
            state.ActiveClientSkillInstanceId = 0;
            state.ActiveSkillStartedTicks = 0;
            state.ActiveFightStyleId = style.Id;
            await PublishSelectedWeaponProfile(ctx, state.ActiveSpiritUnitId, state.ActiveSpiritTemplateId, weapon, style);
        }
        ctx.Session.Log.Info($"[STYLE] weapon-style weapon={weaponInstanceId} style={fightStyleId} name={style.Name}");
    }

    async Task OnLoadWeaponToSlot(RpcContext ctx, uint spiritId, ulong weaponInstanceId, int slotIndex)
    {
        var state = GetWorldState(ctx);
        var slots = WeaponSlotIds(state, spiritId);
        if (!IsEditableWeaponSlot(slotIndex) ||
            CombatCatalogRepository.Weapon(weaponInstanceId) is null ||
            CombatCatalogRepository.Weapon(spiritId, weaponInstanceId) is null)
        {
            ctx.Session.Log.Warn($"[ARMORY] load rejected spirit={spiritId} weapon={weaponInstanceId} slot={slotIndex}");
            return;
        }

        var existingIndex = slots.IndexOf(weaponInstanceId);
        if (existingIndex >= 0 && existingIndex != slotIndex)
            (slots[existingIndex], slots[slotIndex]) = (slots[slotIndex], slots[existingIndex]);
        else
            slots[slotIndex] = weaponInstanceId;

        await PublishWeaponSlotsAfterMutation(ctx, spiritId, $"load:{weaponInstanceId}@{slotIndex}");
    }

    async Task OnDepositSpiritWeapon(RpcContext ctx, uint spiritId, int slotIndex)
    {
        var state = GetWorldState(ctx);
        var slots = WeaponSlotIds(state, spiritId);
        if (!IsEditableWeaponSlot(slotIndex))
        {
            ctx.Session.Log.Warn($"[ARMORY] deposit rejected spirit={spiritId} slot={slotIndex}");
            return;
        }

        // Empty wheel positions are represented by a normal complex-object null marker. Keep the
        // shared armory intact while removing the weapon only from this character's personal wheel.
        slots[slotIndex] = 0;
        await PublishWeaponSlotsAfterMutation(ctx, spiritId, $"deposit:{slotIndex}");
    }

    async Task OnExchangeWeaponSlot(
        RpcContext ctx,
        uint fromSpirit,
        int fromIndex,
        uint toSpirit,
        int toIndex)
    {
        var state = GetWorldState(ctx);
        var fromSlots = WeaponSlotIds(state, fromSpirit);
        var toSlots = WeaponSlotIds(state, toSpirit);
        if (!IsEditableWeaponSlot(fromIndex) || !IsEditableWeaponSlot(toIndex))
        {
            ctx.Session.Log.Warn($"[ARMORY] exchange rejected from={fromSpirit}:{fromIndex} to={toSpirit}:{toIndex}");
            return;
        }

        (fromSlots[fromIndex], toSlots[toIndex]) = (toSlots[toIndex], fromSlots[fromIndex]);
        await PublishWeaponSlotsAfterMutation(ctx, fromSpirit, $"exchange:{fromIndex}->{toSpirit}:{toIndex}");
        if (toSpirit != fromSpirit)
            await PublishWeaponSlotsAfterMutation(ctx, toSpirit, $"exchange:{toIndex}<-{fromSpirit}:{fromIndex}");
    }

    private async Task PublishWeaponSlotsAfterMutation(RpcContext ctx, uint spiritId, string operation)
    {
        var state = GetWorldState(ctx);
        var slots = WeaponSlotIds(state, spiritId);
        var isActive = spiritId == state.ActiveSpiritTemplateId;
        var currentWeaponId = isActive
            ? state.ActiveWeaponInstanceId
            : state.LastWeaponBySpirit.GetValueOrDefault(spiritId);
        if (currentWeaponId == 0 || !slots.Contains(currentWeaponId))
            currentWeaponId = slots.FirstOrDefault(x => x != 0);
        if (currentWeaponId == 0)
            currentWeaponId = CombatCodec.Loadout(spiritId).DefaultWeapon.InstanceId;

        var unitId = isActive
            ? state.ActiveSpiritUnitId
            : ClientConfigRepository.Characters().First(x => x.TemplateId == spiritId).UnitId;
        var currentWeapon = CombatCatalogRepository.Weapon(spiritId, currentWeaponId)
            ?? throw new InvalidDataException($"Missing runtime view for spirit {spiritId}, weapon {currentWeaponId}.");
        var currentChanged = isActive && state.ActiveWeaponInstanceId != currentWeaponId;

        if (currentChanged && state.ActiveSkillId != 0)
            await ctx.NotifyAsync(MethodId.SyncBreakSkill, CombatCodec.BreakSkill(state.ActiveSpiritUnitId));

        state.LastWeaponBySpirit[spiritId] = currentWeaponId;
        if (isActive)
        {
            state.ActiveSkillId = 0;
            state.RestoreResourcesAfterActiveSkill = false;
            state.ActiveClientSkillInstanceId = 0;
            state.ActiveSkillStartedTicks = 0;
            state.ActiveWeaponInstanceId = currentWeaponId;
            state.ActiveFightStyleId = ResolveWeaponStyle(state, currentWeapon).Id;
        }

        await PublishWeaponSnapshot(ctx, unitId, spiritId, currentWeaponId);
        await ctx.NotifyAsync(MethodId.SyncSpiritLastUsedWeapon,
            CombatCodec.SpiritLastUsedWeapon(spiritId, currentWeaponId));
        if (currentChanged)
        {
            var style = ResolveWeaponStyle(state, currentWeapon);
            await ctx.NotifyAsync(MethodId.SyncSpiritSwitchWeaponAction,
                CombatCodec.SpiritSwitchWeapon(unitId, currentWeaponId));
            await PublishSelectedWeaponProfile(ctx, unitId, spiritId, currentWeapon, style);
        }

        ctx.Session.Log.Info($"[ARMORY] slots committed operation={operation} spirit={spiritId} active={isActive} current={currentWeaponId} unique={slots.Where(x => x != 0).Distinct().Count()} slots={slots.Count}");
    }

    private static bool IsEditableWeaponSlot(int index) => index >= 0 && index < 16;

    private static List<ulong> WeaponSlotIds(WorldEntryState state, uint spiritId)
    {
        if (state.WeaponSlotsBySpirit.TryGetValue(spiritId, out var slots))
            return slots;
        var loadout = CombatCodec.Loadout(spiritId);
        slots = loadout.Slots.Select(x => x?.InstanceId ?? 0UL).ToList();
        state.WeaponSlotsBySpirit.Add(spiritId, slots);
        return slots;
    }

    private static IReadOnlyList<CombatWeaponDefinition?> WeaponSlotDefinitions(WorldEntryState state, uint spiritId)
        => WeaponSlotIds(state, spiritId)
            .Select(instanceId => instanceId == 0 ? null :
                CombatCatalogRepository.Weapon(spiritId, instanceId)
                ?? throw new InvalidDataException($"Missing runtime view for spirit {spiritId}, weapon {instanceId}."))
            .ToArray();

    Task OnSkillUseWeaponDurability(RpcContext ctx, int skillInstanceId, int triggerIndex)
    {
        var state = GetWorldState(ctx);
        if (!state.Ready)
            return Task.CompletedTask;
        var weapon = CombatCodec.Weapon(state.ActiveSpiritTemplateId, state.ActiveWeaponInstanceId)
            ?? CombatCodec.DefaultWeapon(state.ActiveSpiritTemplateId);
        if (!weapon.IsShootWeapon || weapon.MagazineAmmo == 0)
            return Task.CompletedTask;

        var current = EnsureMagazine4229938(state, weapon);
        if (current > 0)
            state.WeaponMagazineAmmo[weapon.InstanceId] = --current;

        // Separate-bullet firearms consume only the loaded magazine; their reserve is an ordinary
        // backpack item. Other firearms use Durability as total remaining ammunition, so decrement
        // total and magazine together. Infinite (-1) values stay infinite.
        var durability = CurrentDurability4229938(state, weapon, current);
        if (!weapon.SeparateBullets && durability > 0)
        {
            durability--;
            state.WeaponDurabilityAmmo[weapon.InstanceId] = durability;
        }
        else if (weapon.SeparateBullets)
        {
            durability = current;
        }

        var bulletId = EnsureBullet4229938(state, weapon);
        var reserve = weapon.SeparateBullets && bulletId != 0
            ? EnsureReserve4229938(state, bulletId)
            : NonSeparateReserve4229938(durability, current);
        ctx.Session.Log.Info($"[AMMO] shot weapon={weapon.TemplateId}/{weapon.InstanceId} token={skillInstanceId} trigger={triggerIndex} mag={current}/{weapon.MagazineAmmo} reserve={reserve} bullet={bulletId} total={durability}");
        return ctx.NotifyAsync(MethodId.SyncSpiritWeaponDurabilityChangedAction,
            CombatCodec.WeaponDurabilityChanged(state.ActiveSpiritTemplateId, state.ActiveSpiritUnitId, weapon, durability, current, bulletId));
    }

    async Task OnWeaponEquipBullets(RpcContext ctx, ulong weaponInstanceId, uint bulletId)
    {
        var state = GetWorldState(ctx);
        var weapon = CombatCatalogRepository.Weapon(state.ActiveSpiritTemplateId, weaponInstanceId)
            ?? CombatCatalogRepository.Weapon(weaponInstanceId);
        if (weapon is null || !weapon.SeparateBullets || bulletId == 0 || !weapon.BulletIds.Contains(bulletId))
        {
            ctx.Session.Log.Warn($"[AMMO] equip rejected weapon={weaponInstanceId} bullet={bulletId}");
            return;
        }
        state.WeaponBulletByInstance[weaponInstanceId] = bulletId;
        var mag = EnsureMagazine4229938(state, weapon);
        var reserve = EnsureReserve4229938(state, bulletId);
        await ctx.NotifyAsync(MethodId.SyncSpiritWeaponDurabilityChangedAction,
            CombatCodec.WeaponDurabilityChanged(state.ActiveSpiritTemplateId, state.ActiveSpiritUnitId, weapon, mag, mag, bulletId));
        ctx.Session.Log.Info($"[AMMO] bullet-selected weapon={weapon.TemplateId}/{weapon.InstanceId} bullet={bulletId} mag={mag}/{weapon.MagazineAmmo} reserve={reserve}");
    }

    private async Task ReloadWeapon4229938(RpcContext ctx, WorldEntryState state, CombatWeaponDefinition weapon)
    {
        if (!weapon.IsShootWeapon || weapon.MagazineAmmo <= 0)
            return;
        var mag = EnsureMagazine4229938(state, weapon);
        var capacity = Math.Max(0, weapon.MagazineAmmo);
        if (mag < 0 || mag >= capacity)
            return;
        var bulletId = EnsureBullet4229938(state, weapon);

        if (weapon.SeparateBullets && bulletId != 0)
        {
            var reserve = EnsureReserve4229938(state, bulletId);
            var need = (uint)Math.Max(0, capacity - mag);
            var loaded = Math.Min(need, reserve);
            if (loaded == 0)
                return;
            mag += (int)loaded;
            reserve -= loaded;
            state.WeaponMagazineAmmo[weapon.InstanceId] = mag;
            state.BackpackItemCounts[bulletId] = reserve;
            await ctx.NotifyAsync(MethodId.SyncBackpackItemChanged,
                new GameMethods.SyncBackpackItemChanged4229938
                {
                    updateItemList = [RuntimePayloadFactory.AmmoPackItem(bulletId, reserve)]
                });
            await ctx.NotifyAsync(MethodId.SyncSpiritWeaponDurabilityChangedAction,
                CombatCodec.WeaponDurabilityChanged(state.ActiveSpiritTemplateId, state.ActiveSpiritUnitId, weapon, mag, mag, bulletId));
            ctx.Session.Log.Info($"[AMMO] reload weapon={weapon.TemplateId}/{weapon.InstanceId} loaded={loaded} mag={mag}/{capacity} reserve={reserve} bullet={bulletId}");
            return;
        }

        // Non-separate firearms use Durability as total remaining ammunition. Reload moves rounds
        // from reserve into the magazine without increasing total ammo. A total of -1 is infinite.
        var durability = EnsureDurability4229938(state, weapon);
        var reserveNonSeparate = NonSeparateReserve4229938(durability, mag);
        var needed = Math.Max(0, capacity - mag);
        var loadedNonSeparate = durability < 0
            ? needed
            : Math.Min(needed, (int)reserveNonSeparate);
        if (loadedNonSeparate <= 0)
            return;
        mag += loadedNonSeparate;
        state.WeaponMagazineAmmo[weapon.InstanceId] = mag;
        await ctx.NotifyAsync(MethodId.SyncSpiritWeaponDurabilityChangedAction,
            CombatCodec.WeaponDurabilityChanged(state.ActiveSpiritTemplateId, state.ActiveSpiritUnitId, weapon, durability, mag, bulletId));
        ctx.Session.Log.Info($"[AMMO] reload weapon={weapon.TemplateId}/{weapon.InstanceId} loaded={loadedNonSeparate} mag={mag}/{capacity} reserve={NonSeparateReserve4229938(durability, mag)} bullet=inline total={durability}");
    }

    private static int EnsureMagazine4229938(WorldEntryState state, CombatWeaponDefinition weapon)
    {
        if (!state.WeaponMagazineAmmo.TryGetValue(weapon.InstanceId, out var value))
        {
            value = weapon.InitialMagazineAmmo;
            state.WeaponMagazineAmmo[weapon.InstanceId] = value;
        }
        return value;
    }

    private static int EnsureDurability4229938(WorldEntryState state, CombatWeaponDefinition weapon)
    {
        if (!weapon.IsShootWeapon)
            return weapon.Durability;
        if (weapon.SeparateBullets)
            return EnsureMagazine4229938(state, weapon);
        if (!state.WeaponDurabilityAmmo.TryGetValue(weapon.InstanceId, out var value))
        {
            value = weapon.Durability;
            state.WeaponDurabilityAmmo[weapon.InstanceId] = value;
        }
        return value;
    }

    private static int CurrentDurability4229938(WorldEntryState state, CombatWeaponDefinition weapon, int magazineAmmo)
        => weapon.IsShootWeapon && weapon.SeparateBullets
            ? magazineAmmo
            : EnsureDurability4229938(state, weapon);

    private static uint NonSeparateReserve4229938(int durability, int magazineAmmo)
        => durability < 0
            ? uint.MaxValue
            : (uint)Math.Max(0, durability - Math.Max(0, magazineAmmo));

    private static uint EnsureBullet4229938(WorldEntryState state, CombatWeaponDefinition weapon)
    {
        if (!state.WeaponBulletByInstance.TryGetValue(weapon.InstanceId, out var bulletId))
        {
            bulletId = weapon.BulletId;
            state.WeaponBulletByInstance[weapon.InstanceId] = bulletId;
        }
        return bulletId;
    }

    private static uint EnsureReserve4229938(WorldEntryState state, uint bulletId)
    {
        if (bulletId == 0)
            return 0;
        if (!state.BackpackItemCounts.TryGetValue(bulletId, out var count))
        {
            count = RuntimePayloadFactory.InitialAmmoReserve4229938;
            state.BackpackItemCounts[bulletId] = count;
        }
        return count;
    }

    async Task PublishSelectedWeaponProfile(
        RpcContext ctx,
        ulong unitId,
        uint templateId,
        CombatWeaponDefinition weapon,
        CombatStyleDefinition style)
    {
        var state = GetWorldState(ctx);
        state.CombatProfilePublished = true;

        // Switching/individually styling one weapon must never overwrite the character-wide
        // FightStyleInfo map. OnSwitchFightStyle publishes that map explicitly.
        await ctx.NotifyAsync(MethodId.SyncPlayerAllSkillChargeData,
            CombatCodec.AllSkillCharges(unitId, weapon, style));
        await PublishCombatResources(ctx, unitId);
        await PublishSkillBindings(ctx, unitId, weapon, style);
        await ctx.NotifyAsync(MethodId.SyncSpiritLastUsedWeapon,
            CombatCodec.SpiritLastUsedWeapon(templateId, weapon.InstanceId));
        ctx.Session.Log.Info($"[COMBAT] profile published unit={unitId} template={templateId} weapon={weapon.TemplateId}/{weapon.InstanceId} style={style.Id} skills={style.CommonSkill},{style.HeavyCommonSkill},{style.DodgeSkill},{style.ControlSkill},{weapon.ActiveSkill(style)},{weapon.UniqueSkill(style)}");
    }

    private static CombatStyleDefinition ResolveWeaponStyle(WorldEntryState state, CombatWeaponDefinition weapon)
    {
        if (state.WeaponStyleOverrides.TryGetValue(weapon.InstanceId, out var weaponStyleId) &&
            CombatCatalogRepository.Style(weaponStyleId) is { } weaponStyle &&
            CombatCatalogRepository.IsStyleCompatible(weapon, weaponStyle))
            return weaponStyle;
        if (state.SpiritStyleOverrides.TryGetValue((weapon.SpiritTemplateId, weapon.WeaponFightSkillTypeId), out var spiritStyleId) &&
            CombatCatalogRepository.Style(spiritStyleId) is { } spiritStyle &&
            CombatCatalogRepository.IsStyleCompatible(weapon, spiritStyle))
            return spiritStyle;
        return weapon.Style;
    }

    private static CombatStyleDefinition ActiveStyle(WorldEntryState state)
    {
        var weapon = CombatCodec.Weapon(state.ActiveSpiritTemplateId, state.ActiveWeaponInstanceId)
            ?? CombatCodec.DefaultWeapon(state.ActiveSpiritTemplateId);
        return ResolveWeaponStyle(state, weapon);
    }
}
