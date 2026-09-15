using Ananta.SDK.Serialization;
using Auto = Ananta.Server.RpcTypes.Client4229938.Auto;

namespace Ananta.Server.RpcTypes.Client4229938.Methods.GameScene;

[UxContract(Inline = true)]
internal sealed class SyncUnitHp { public ulong unitId; public float hp; }

[UxContract(Inline = true)]
internal sealed class SyncAttachBattleModule { public ulong unitId; }

[UxContract(Inline = true)]
internal sealed class SyncFightResource { public ulong unitId; public uint resourceId; public float value; }

[UxContract(Inline = true)]
internal sealed class SyncFightResourceFreeState { public ulong unitId; public uint resourceId; public bool isFree; }

[UxContract(Inline = true)]
internal sealed class SyncSpiritLastUsedWeapon { public uint templateId; public ulong weaponInstanceId; }

[UxContract(Inline = true)]
internal sealed class SyncSpiritUnitUrbanAttrs
{
    public ulong unitId;
    public List<int> abilities = [];
}

[UxContract(Inline = true)]
internal sealed class SyncUnitAttrs
{
    public ulong unitId;

    [UxCollection(Count = UxCountEncoding.Int32)]
    public Dictionary<uint, float> attrs = [];
}

[UxContract]
internal sealed class PlayerFightStyleUnlockChangeInfo
{
    public PlayerInfoFightStyle playerInfoFightStyle = new();

    [UxCollection(Count = UxCountEncoding.Int7)]
    public Dictionary<uint, bool> addOrUpdateUnlockInfo = [];
}

[UxContract]
internal sealed class PlayerInfoFightStyle
{
    [UxCollection(Count = UxCountEncoding.Int32)]
    public Dictionary<uint, bool> fightStyles = [];
}

[UxContract]
internal sealed class SpiritFightTypeChangeAction
{
    public uint templateId;
    public SpiritFightStyleInfo fullInfo = new();

    [UxCollection(Count = UxCountEncoding.Int7)]
    public Dictionary<uint, uint> addOrUpdateInfo = [];
}

[UxContract]
internal sealed class SpiritFightStyleInfo
{
    [UxCollection(Count = UxCountEncoding.Int32)]
    public Dictionary<uint, uint> fightStyleInfo = [];
}

[UxContract(Inline = true)]
internal sealed class SyncPlayerAllSkillChargeData
{
    public ulong unitId;

    [UxCollection(Count = UxCountEncoding.Int7)]
    public Dictionary<uint, ChargeData> charges = [];
}

[UxContract]
internal sealed class ChargeData
{
    public uint current;
    public float readyRatio;
    public float period;
    public uint max;
    public double timestamp;
}

[UxContract]
internal sealed class SpiritSwitchWeaponAction
{
    public ulong spiritUid;
    public ulong weaponInstanceId;
    public byte reason;
}

/// <summary>
/// Scene weapon snapshot used by SyncSpiritWeaponDetail. Unlike the persistent WeaponData stored in
/// PlayerInfo, WeaponDetail has five scene-source fields in front of the common weapon payload.
/// </summary>
[UxContract]
internal sealed class WeaponDetail
{
    public int SourceAgentSpoonId;
    public ulong SourceAgentId;
    public ulong SourceSceneItemId;
    public bool IsLocked;
    public ulong SourceSceneItemTaskUId;
    public uint TemplateId;
    public int Durability;
    public ulong InstanceId;
    public uint EventId;
    public double ReceivedTimeStamp;
    public uint OperatorFlags;
    public string? SpecialLabel;
    public Auto.WeaponDataFlags WeaponFlags = new();
    public float SceneItemHp;
    public int StackCount;
    public Auto.WeaponBulletDatas BulletDatas = new();
    [UxCollection(Count = UxCountEncoding.Int32, ItemObjectEncoding = UxObjectEncoding.Complex)]
    public List<Auto.WeaponDecorationDatas> Decorations = [];
    public uint FightStyleId;
    public int MagazineAmmo;
    public ulong BindPid;
    public bool IsPlayerLocked;
    // Exact 4229938 RPCSerializeAuto.lua tail. Omitting these four fields shifts the next
    // WeaponDetail in SpiritWeaponDetail and eventually makes the client deserialize BulletDatas as null.
    [UxCollection(Count = UxCountEncoding.Int32, ItemObjectEncoding = UxObjectEncoding.Complex)]
    public List<Auto.WeaponEnchantSlot> EnchantSlots = [];
    public uint NonDirectionalEnchantCount;
    public uint DirectionalEnchantCountSinceLastNonDir;
    public uint LockedDirectionalEnhancementId;
}

[UxContract]
internal sealed class WeaponWheelData
{
    public uint WheelId;
    public uint EventId;
    [UxCollection(Count = UxCountEncoding.Int7, ItemObjectEncoding = UxObjectEncoding.Complex)]
    public List<WeaponDetail?> WeaponSlots = [];
    public int LockMaxSlotCounts;
}

/// <summary>
/// Atomic client WeaponManager hydration. The client must receive this before a switch action:
/// SyncSpiritSwitchWeaponAction only selects an instance already present in CurrWeaponSlots.
/// </summary>
[UxContract]
internal sealed class SpiritWeaponDetail
{
    public uint SpiritTid;
    public ulong SpiritUid;
    public ulong CurrentWeaponUid;
    [UxCollection(Count = UxCountEncoding.Int7, ItemObjectEncoding = UxObjectEncoding.Complex)]
    public List<WeaponDetail?> WeaponSlots = [];
    public WeaponDetail? CurrentTempWeapon;
    public WeaponWheelData? TempWeaponSlots;
    [UxCollection(Count = UxCountEncoding.Int7, ValueObjectEncoding = UxObjectEncoding.Complex)]
    public Dictionary<int, WeaponDetail> VirtualWeaponSlots = [];
}

// Client -> GameScene AskSwitchWeapon(int index), zero-based.
[UxContract(Inline = true)]
internal sealed class AskSwitchWeapon { public int index; }

[UxContract(Inline = true)]
internal sealed class SyncBreakSkill { public ulong unitId; }

// Client -> GameScene AskUseSkill / AskClientUseCommonSkill.
[UxContract(Inline = true)]
internal sealed class AskUseSkill
{
    public SkillUseData data = new();
}

[UxContract]
internal sealed class SkillUseData
{
    public ulong Releaser;
    public UxVector3 Location;
    public float Facing;
    public ulong TargetId;
    public int UnitPartIndex;
    public ulong TargetDestructibleId;
    public ulong AttachDestructibleId;
    public uint SkillId;
    public int SkillInstanceId;
}

[UxContract(Inline = true)]
internal sealed class ReportSkillEnd
{
    public ulong unitId;
    public int skillId;
    public uint newSkillId;
    public bool isBreak;
}

[UxContract(Inline = true)]
internal sealed class AskMultipleSkillHit2
{
    public SkillHitData skillHitData = new();
}

[UxContract]
internal sealed class SkillHitData
{
    public ulong ReleaserId;
    public int Id;
    public uint SkillId;
    public int TriggerIndex;
    public ulong TriggerInstanceId;
    public int Stage;
    public ulong HitTarget;
    public ulong AttachedDestructibleId;
    public UxVector3 ClientHitPosition;
    public UxVector3 ClientHitPosNormalDir;
    public byte SkillHitType;
    public int HitMaterial;
    public UxVector3 HitCenter;
    public uint StiffId;
    public float StiffTime;
    public uint HurtEffectId;
    public float FirmHurt;
    public int ShieldDefendIndex;
    public uint ShieldId;
    public bool IsBackHit;
    public bool IsReflected;
    public float HitDistance;
    public bool IsBehindBarrier;
}

[UxContract(Inline = true)]
internal sealed class AskSkillUseWeaponDurability
{
    public int skillid;
    public int triggerindex;
}

[UxContract(Inline = true)]
internal sealed class AskWeaponEquipBullets
{
    public ulong weaponinstanceid;
    public uint bulletid;
}

[UxContract]
internal sealed class SpiritWeaponDurabilityChangedAction
{
    public uint SpiritTid;
    public ulong SpiritUid;
    public ulong WeaponInstanceId;
    public int Durability;
    public int MagazineAmmo;
    public uint CurrentBulletId;
    public int StackCount;
}
