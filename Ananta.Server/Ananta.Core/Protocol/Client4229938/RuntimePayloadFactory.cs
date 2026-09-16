using Ananta.Server.ClientData.Client4229938;
using Ananta.Server.Configuration;
using Ananta.Server.RpcTypes.Client4229938;
using Auto = Ananta.Server.RpcTypes.Client4229938.Auto;
using GameMethods = Ananta.Server.RpcTypes.Client4229938.Methods.Game;

namespace Ananta.Server.Protocol.Client4229938;

/// <summary>
/// Builds the large build-4229938 RPC payloads directly from human config + extracted client JSON.
/// Nothing here reads generated .bin files: every packet is a normal RpcTypes object serialized by UxSerializer.
/// </summary>
internal static class RuntimePayloadFactory
{
    private static PrivateServerConfig Config => PrivateServerConfigStore.Current;

    internal static Auto.PlayerClientInfo MinimalPlayerInfo4229938()
    {
        // Keep only identity plus the actor-facing roster required to materialize the controlled
        // spirit. Economy/social/apps/tasks and the unrelated account armory stay absent.
        var root = new Auto.PlayerClientInfo();
        root.InfoLogin.Aid = Config.Client.Aid;
        root.InfoLogin.Pid = Config.Player.Pid;
        root.InfoLogin.AccountId = Config.Player.AccountId;
        root.InfoLogin.Name = Config.Player.DisplayName;
        root.InfoLogin.Level = 1;
        root.InfoLogin.Sex = 1;
        root.InfoLogin.UseSystemName = false;
        root.InfoLogin.UniverseId = Config.Player.LoginUniverseId;

        // World-entry cannot advertise a concrete WeaponTemplateId in SyncEnterScene while the
        // login roster contains zero weapon instances. 4229938 preloads the local actor from the
        // PlayerInfo spirit/armory stores before AskLoadSceneCompleted; an empty wheel makes that
        // actor profile internally inconsistent and leaves the client waiting on presentation data.
        // Keep only the weapon instances actually referenced by the 32 owned spirit wheels.
        var spirits = ClientConfigRepository.Characters().Select(MinimalActorCharacterSpirit4229938).ToList();

        root.InfoSpirit.Spirits = spirits;
        root.InfoSpirit.ActiveSpirit = Config.Player.InitialSpiritTemplateId;
        root.InfoSpirit.InfoPokemon.FastFightSquad = [Config.Player.InitialUnitId];
        // Unlock all 670 weapons across the entire armory for all characters
        root.InfoSpirit.InfoArmory.Weapons = CombatCodec.ArmoryWeapons().ToList();

        // Unlock all fight styles and martial arts
        foreach (var styleId in CombatCatalogRepository.UnlockedStyleIds)
            root.InfoSpirit.InfoFightStyle.FightStyleIsUnLocked[styleId] = true;

        // Install all phone apps (Camera, Time, Settings, etc.)
        root.InfoSpirit.InstalledApps = ClientConfigRepository.InstalledPhoneAppIds().ToList();

        // Unlock all phone customizations / styles (wallpapers, decorations, pendants)
        root.InfoSpirit.AvailableSkinParts = Enumerable.Range(1, 200).Select(i => (uint)i).ToList();

        root.InfoMinor.Level = 1;
        root.InfoMinor.MatchInfo.DeviceLevel = 1;
        root.InfoMinor.MatchInfo.CurLinkDeviceLevel = 1;

        // Provide the vehicle fleet so the client-side DriveManager recognises available vehicles.
        if (Config.Gameplay.Vehicles.Enabled && Config.Gameplay.Vehicles.FleetIds.Length > 0)
        {
            root.InfoMinor.VehicleInfo = new Auto.PlayerVehicleInfo
            {
                UnlockedVehicles = Config.Gameplay.Vehicles.FleetIds.Select(fleetId => new Auto.PlayerVehicleDetail
                {
                    Id = fleetId,
                    UnlockTime = 1,
                    SuitId = 0,
                    Parts = [],
                }).ToList(),
                RequisitionVehicleCount = Config.Gameplay.Vehicles.FleetIds.Length,
                ParkingVehicleId = 0,
            };
        }
        // Seed phone contacts so the quick-call summon contacts exist without progression.
        // The client matches contacts to PhoneContactConfig by phone number:
        // 142857 = "Call vehicle" (owned-car list -> AskSummonVehicle),
        // 206337 = "Express Depot" (milk/taxi car).
        var summonContacts = new (string Remark, string Number)[]
        {
            (string.Empty, "142857"),
            (string.Empty, "206337"),
        };
        foreach (var character in ClientConfigRepository.Characters())
        {
            root.InfoMinor.PlayerPhoneInfo.SpiritPhoneInfos[character.TemplateId] = new Auto.PhoneInfos
            {
                ContactList = summonContacts.Select(c => new Auto.PhoneContact
                {
                    Remark = c.Remark,
                    PhoneNumber = c.Number,
                }).ToList(),
                ContactGroupList = [],
                CallRecordList = [],
                ContactOutgoingCallTimesDict = new Dictionary<string, uint>(),
            };
        }

        // Event-condition progress so the quick-call contacts count as unlocked.
        // Module 3 = UX.Game.EventConditionImplModule.PhoneContact (IL2CPP metadata
        // declaration order); finished ids 1/2 = PhoneContactUnlockConfig rows for
        // contacts 111111111 (Call vehicle) / 111111112 (Express Depot).
        // Without them the client plays LockDialogId (busy) instead of the summon dialog.
        var phoneProgress = new Auto.ModuleEventProgressInfoBySpirit
        {
            EventProgressInfoDict = new Dictionary<uint, Auto.EventProgressInfo>(),
            FinishedTemplateIdList = [1, 2],
        };
        var phoneModule = new Auto.ModuleEventProgressInfo
        {
            ProgressInfoDict = new Dictionary<uint, Auto.ModuleEventProgressInfoBySpirit>
            {
                [0] = phoneProgress,
            },
        };
        foreach (var character in ClientConfigRepository.Characters())
            phoneModule.ProgressInfoDict[character.TemplateId] = phoneProgress;
        root.InfoMinor.ModuleEventProgressInfoDict[3] = phoneModule;

        // The v7 guide only constrains ActiveSpirit/actor identity; it does not require the rest of
        // PlayerInfo to be zero. Keep build-local SystemUnlock metadata so the stock 4229938 HUD,
        // map and input UI do not treat the account as a pre-tutorial profile. No semantic handlers
        // are re-enabled by publishing these client-owned unlock ids.
        root.InfoMinor.PlayerInfoGuide.UnlockSystems = ClientConfigRepository.UnlockSystemIds().ToList();
        root.InfoMinor.PlayerFashionsInfo = MinimalPlayerFashions4229938();

        // Unlock all character poses and interaction actions
        for (uint i = 1; i <= 200; i++)
        {
            root.InfoMinor.PlayerInteractionActionInfo.UnlockActionItemDict[i] = new Auto.PlayerInteractionActionItem
            {
                CfgId = i,
                UnlockTime = 1,
                ShowRedPoint = false,
            };
        }

        // Unlock all housing properties
        var houseIds = new uint[] { 11200000, 1001, 1002, 1003, 1004, 1005, 10001, 10002 };
        foreach (var hid in houseIds)
        {
            root.InfoMinor.housesInfo.HouseInfoList.Add(new Auto.HouseActiveInfo
            {
                HouseId = hid,
                Version = 1,
                FurnitureIndex = 1,
                SocialInfo = new Auto.HouseSocialInfo
                {
                    PromoImageUrl = string.Empty,
                    WelcomeText = "Private Server House",
                }
            });
        }

        return root;
    }

    internal static Auto.EnterSceneInfo EnterScene(uint switchShowId)
    {
        var placement = ClientConfigRepository.EntryPlacement(switchShowId);
        return EnterScene(
            Config.World.RaidId,
            Config.World.SceneInstanceId,
            Config.World.UniverseId,
            Config.Player.InitialUnitId,
            Config.Player.InitialSpiritTemplateId,
            placement.Position,
            placement.Facing,
            switchShowId,
            isSwitchSpiritShow: true);
    }

    internal static Auto.EnterSceneInfo EnterScene(
        uint raidId,
        ulong instanceId,
        uint universeId,
        ulong unitId,
        uint templateId,
        Vec3 position,
        float facing,
        uint switchShowId = 0,
        bool isSwitchSpiritShow = false,
        uint sectorControlId = 0)
        => new()
        {
            PlayerSessionId = Config.Player.Pid,
            RaidId = raidId,
            InstanceId = instanceId,
            Position = Vector(position),
            Facing = facing,
            SceneSpoonNames = [],
            SceneSpoonMd5s = [],
            Spirits =
            [
                new Auto.SpiritInitData
                {
                    Id = unitId,
                    TemplateId = templateId,
                    IsActive = true,
                    // Proven v7 single-CreateHero entry contract: initial actor identity only.
                    // Weapon/fashion/runtime presentation is hydrated only after world-entry finalization.
                    WeaponTemplateId = 0,
                    WeaponSkinId = 0,
                }
            ],
            GridInfo = new Auto.ServerSimpleGridInfo
            {
                MinX = 0,
                MinZ = 0,
                MaxX = 300000,
                MaxZ = 300000,
            },
            MatchGameId = 0,
            SwitchShowId = switchShowId,
            IsSwitchSpiritShow = isSwitchSpiritShow,
            UniverseId = universeId,
            SectorControlId = sectorControlId,
            LoadingType = new Auto.LoadingTypeInfo
            {
                Type = 0,
                Members = [],
                Ripple = false,
            },
            LinkSimpleInfo = new Auto.LinkSimpleInfo
            {
                Id = 0,
                Mode = 0,
                DeviceLevel = 1,
                Tag = 0,
                PublicEventId = 0,
                LastPublicEventTime = 0,
                HostPid = 0,
            },
            DataLayerIndices = [],
            Seamless = false,
            TombIslandIds = [],
        };

    internal static Auto.RaidBattleUnitSpirit ExistingUnitProjection(uint switchShowId)
    {
        var placement = ClientConfigRepository.EntryPlacement(switchShowId);
        return ExistingUnitProjection(
            Config.Player.InitialUnitId,
            Config.Player.InitialSpiritTemplateId,
            placement.Position,
            placement.Facing);
    }

    internal static Auto.RaidBattleUnitSpirit ExistingUnitProjection(
        ulong unitId,
        uint templateId,
        Vec3 position,
        float facing)
    {
        // Initial world-entry uses the same BaseUnit created by native CreateHero. ManagedPid is
        // presentation/remote-management metadata on this AOI projection and must stay zero; the
        // actual local authority is established by SyncManagedLogicAgent(unitId, playerPid, 0).
        var projection = CharacterUnitProjection(
            unitId, templateId, position, facing, ClientConfigRepository.DefaultFashionIds(templateId));
        projection.ManagedPid = 0;
        return projection;
    }

    internal static Auto.RaidBattleUnitSpirit CharacterUnitProjection(
        uint templateId,
        Vec3 position,
        float facing)
    {
        var character = ClientConfigRepository.Characters().FirstOrDefault(x => x.TemplateId == templateId)
            ?? throw new InvalidOperationException($"Character {templateId} is not present in FightSpiritConfig roster.");
        return CharacterUnitProjection(
            character.UnitId,
            character.TemplateId,
            position,
            facing,
            ClientConfigRepository.DefaultFashionIds(templateId));
    }

    internal static GameMethods.SyncSetSpiritFashions CharacterFashions(uint templateId)
    {
        var wear = WearFashionsForGameMethods(ClientConfigRepository.DefaultFashionIds(templateId));
        return new GameMethods.SyncSetSpiritFashions
        {
            spiritId = templateId,
            source = 0,
            spiritWearFashionsInfo = wear,
        };
    }

    internal static GameMethods.AskAllSpiritPanelDataResult MinimalAllSpiritPanelData4229938()
        => new()
        {
            spirits = ClientConfigRepository.Characters().Select(character => new Auto.SpiritPanelData
            {
                FightSpiritId = character.TemplateId,
                MaxHp = 1f,
                Dam = 0f,
                DefDeduct = 0f,
            }).ToList()
        };

    private static Auto.RaidBattleUnitSpirit CharacterUnitProjection(
        ulong unitId,
        uint templateId,
        Vec3 position,
        float facing,
        IReadOnlyList<uint> fashionIds)
    {
        return new Auto.RaidBattleUnitSpirit
        {
            SpiritWearFashionsInfo = new Auto.OtherPlayerSpiritWearFashionsInfo
            {
                WearFashionColoringInfoDict = new Dictionary<uint, Auto.FashionColoringInfo>(),
                WearFashionInfoList = fashionIds.Select(id => new Auto.WearFashionInfo { FashionId = id }).ToList(),
                WearFashionEditInfoList = [],
                HiddenParts = 0,
                EditedHiddenParts = 0,
            },
            Begging = false,
            IsBot = false,
            Id = unitId,
            TemplateId = templateId,
            Position = Vector(position),
            FacingDirection = facing,
            OwnerId = Config.Player.Pid,
            // Build 4229938 uses ManagedPid while constructing the BaseUnit to decide whether
            // the projected spirit belongs to the local player. Leaving this at zero creates
            // switch targets as IsMe=false and the stock handoff never completes.
            ManagedPid = Config.Player.Pid,
            MoveId = 0,
            NavTags = 0,
            GroundData = new Auto.MoveActionGroundData
            {
                MoveGroundType = 0,
                MoveGroundId = 0,
                MetaInfo = 0,
                LocalPos = new Auto.UXVector3(),
            },
        };
    }

    private static Auto.SpiritInfo MinimalActorCharacterSpirit4229938(CharacterCatalogEntry character)
    {
        var loadout = CombatCatalogRepository.Loadout(character.TemplateId);
        var spirit = new Auto.SpiritInfo
        {
            Id = character.UnitId,
            TemplateId = character.TemplateId,
            PossessTime = 1,
            HpRate = 1f,
            EverSwitched = character.TemplateId != Config.Player.InitialSpiritTemplateId,
            Blocked = false,
            LastUsedWeaponInstanceId = loadout.DefaultWeapon.InstanceId,
            WeaponSlots = loadout.Slots
                .Select(weapon => weapon is null ? null! : WeaponData(weapon))
                .ToList(),
        };

        // Fight-style metadata is required to interpret the equipped weapon's authored action set.
        // Do not seed the old server's synthetic SpiritAbilities/urban job/combat graph here.
        foreach (var (typeId, styleId) in loadout.StyleByType)
            spirit.SpiritFightStyle.FightStyleInfo[typeId] = styleId;
        return spirit;
    }

    internal const uint InitialAmmoReserve4229938 = 9999u;

    internal static Auto.PlayerPackItem AmmoPackItem(uint templateId, uint count = InitialAmmoReserve4229938)
        => new()
        {
            UniqueId = 910000000000UL + templateId,
            TemplateId = templateId,
            Count = count,
            IsNew = false,
            ExpiryTime = 0,
            RemindState = 0,
            Quality = 0,
            Tags = 0,
            IsBind = false,
            Components = null,
            CDFinishTime = 0,
        };

    internal static Auto.WeaponData WeaponData(CombatWeaponDefinition weapon)
        => new()
        {
            TemplateId = weapon.TemplateId,
            Durability = weapon.InitialClientDurability,
            InstanceId = weapon.InstanceId,
            EventId = 0,
            ReceivedTimeStamp = 0,
            OperatorFlags = 0,
            SpecialLabel = null,
            SceneItemHp = 1f,
            StackCount = 1,
            FightStyleId = weapon.Style.Id,
            MagazineAmmo = weapon.InitialMagazineAmmo,
            BulletDatas = new Auto.WeaponBulletDatas { BulletId = weapon.BulletId },
            BindPid = Config.Player.Pid,
            IsPlayerLocked = false,
        };

    private static Auto.PlayerFashionsInfo MinimalPlayerFashions4229938()
    {
        var result = new Auto.PlayerFashionsInfo
        {
            DefaultSpiritIsInitDefaultFashion = true,
            ColoringCollectionScore = 100,
        };

        foreach (var fashionId in ClientConfigRepository.SelectableFashionIds())
        {
            result.FashionInfoDict[fashionId] = new Auto.FashionInfo
            {
                FashionId = fashionId,
                ExpiredTime = 0,
                GainTime = 1,
                Status = 1,
                ApplyColoringSchemeId = 0,
                UnlockColoringSlotCount = 10,
                ColoringSchemeTopNMaxCollectionScore = 100,
                OwnedCount = 1,
            };
        }

        foreach (var character in ClientConfigRepository.Characters())
        {
            var defaultIds = ClientConfigRepository.DefaultFashionIds(character.TemplateId);
            result.SpiritFashionsInfoDict[character.TemplateId] = new Auto.SpiritFashionsInfo
            {
                SpiritId = character.TemplateId,
                SpiritWearFashionsInfo = WearFashions(defaultIds),
                SpiritPrevWearFashionsInfo = null,
                FirstGainSuitIdList = [],
                ActiveClientTryWearSource = 0,
                UnlockSuitSlotCount = 10,
            };
        }
        return result;
    }

    private static Auto.SpiritWearFashionsInfo WearFashions(IReadOnlyList<uint> ids)
        => new()
        {
            FunctionSuitId = 0,
            WearSourceInfo = new Auto.WearSourceInfo { Source = 0, SourceId = 0 },
            IsTryWear = false,
            WearFashionInfoList = ids.Select(id => new Auto.WearFashionInfo { FashionId = id }).ToList(),
            WearFashionEditInfoList = [],
            HiddenParts = 0,
            EditedHiddenParts = 0,
        };

    internal static GameMethods.SpiritWearFashionsInfo WearFashionsForGameMethods(IReadOnlyList<uint> ids)
        => new()
        {
            FunctionSuitId = 0,
            WearSourceInfo = new GameMethods.WearSourceInfo { Source = 0, SourceId = 0 },
            IsTryWear = false,
            WearFashionInfoList = ids.Select(id => new GameMethods.WearFashionInfo { FashionId = id }).ToList(),
            WearFashionEditInfoList = [],
            HiddenParts = 0,
            EditedHiddenParts = 0,
        };

    private static Auto.UXVector3 Vector(Vec3 value)
        => new() { X = value.X, Y = value.Y, Z = value.Z };
}
