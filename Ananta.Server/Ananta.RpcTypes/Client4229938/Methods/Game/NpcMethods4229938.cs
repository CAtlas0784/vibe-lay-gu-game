using Ananta.SDK.Serialization;
using Auto = Ananta.Server.RpcTypes.Client4229938.Auto;
using SceneMethods = Ananta.Server.RpcTypes.Client4229938.Methods.GameScene;

namespace Ananta.Server.RpcTypes.Client4229938.Methods.Game;

// IGameSceneToClient positional arguments; both nested values are native structs.
[UxContract(Inline = true)]
internal sealed class SyncNpcBelongings4229938
{
    public ulong Id;
    public List<NpcBelongingItem4229938> Items = [];
    public uint DebugAgentId; // BelongingDebugInfo.AgentId
}

[UxContract(Inline = true)]
internal sealed class NpcBelongingItem4229938
{
    public ulong InstanceId;
    public uint ConfigId;
    public float Hp;
    public uint State;
}

[UxContract(Inline = true)]
internal sealed class SyncNpcBelongingUsage4229938
{
    public ulong Id;
    public List<uint> UsageIds = [];
}

// RPCSerializeAuto.lua WriteClientNpcPoiActionData (4229938).
[UxContract]
internal sealed class ClientNpcPoiActionData4229938
{
    public ulong Id;
    public uint SPoiActionId;
    public uint CPoiActionId;
    public bool IsActive;
    public float PlayPoiSpeed;
}

// Complex argument, with ClientBaseEntityData's static-NPC discriminator.
// SpawnNPC2's ClientStaticNpcInitData uses CustomFlagType=2, not onlyFields.
// Field order: lua/LuaGen/AutoGen/RPCSerializeAuto.lua WriteClientStaticNpcInitData.
[UxContract(TypeMark = 2)]
internal sealed class ClientStaticNpcInitData4229938
{
    public ulong StaticNpcInfoId;
    public uint NpcFormworkId;
    public uint AgentPersonaId;
    public uint SPoiActionId;
    public uint CPoiActionId;
    public uint UrbanDiversityId;
    public bool IgnoreAllStim;
    public bool TaskRelated;
    public bool EnableHack;
    public int NpcPid;
    public NpcAgentSyncClientInfo4229938? AgentSyncClientInfo;
    public uint LookAtDecisionRulesId;
    public bool ForceGo;
    public byte SourceType;
    public uint MartialArtistGossipConfigID;
    public ulong Id;
    public SceneMethods.UxVector3 Position;
    public float Facing;
    public SceneMethods.UxVector3 EulerAngles;
}

// Full current-build AOI projection for an NPC AgentUnit. This contract is
// consumed by UnitsManager.SyncAgentEnterAOI and initializes the BaseUnit
// modules that own animation and physical reactions.
// Field order: RPCSerializeAuto.lua WriteRaidBattleUnitAgent (build 4229938).
[UxContract]
internal sealed class RaidBattleUnitAgent4229938
{
    public int SkillId;
    public int HSummonIndex;
    public int SpoonAgentId;
    public uint SuitId;
    [UxCollection(Count = UxCountEncoding.Int7)]
    public List<uint> FashionIdList = [];
    public ulong ParentId;
    public uint SpoonIndex;
    public uint AutoBackIndex;
    public ulong VehicleId;
    public int VehicleIndex;
    public ulong SourceWeaponId;
    public bool IsBorn;
    public bool BattleAiS;
    public NpcAgentSyncClientInfo4229938 AgentSyncClientInfo = new();
    public uint WeaponId;
    public byte SpawnType;
    public byte AnimateCullingMode;
    public NpcLinkAIAgentInfo4229938 AIAgentInfo = new();
    public ulong Id;
    public uint TemplateId;
    public SceneMethods.UxVector3 Position;
    public float FacingDirection;
    public ulong OwnerId;
    public ulong ManagedPid;
    public byte MoveId;
    public uint NavTags;
    public Auto.MoveActionGroundData GroundData = new();
}

// WriteAgentSyncClientInfo order for 4229938. Do not copy the old build's
// metroLineId/metroCarriageId layout: POI/platform fields replaced that section.
[UxContract]
internal sealed class NpcAgentSyncClientInfo4229938
{
    public bool NeedFTF180DegreeInteract;
    public bool PlayerFTF180DegreeInteract;
    public uint IndoorId;
    public ulong chairId;
    public ulong gadgetId;
    public bool forbidAetherAI;
    public bool isApproachNpc;
    public bool TriggerLeaveEvent;
    public int approachDistance;
    public int LeaveDistance;
    public string? petPerformData = "";
    public List<int> stimIDList = [];
    public uint randomModelCfgId;
    public int layer;
    public float gpsOffsetY;
    public bool isTemp;
    public List<uint> spawnEffectId = [];
    public uint hideEffectId;
    public uint actionId;
    public uint actionGroupId;
    public uint initPoiActionId;
    public bool useDefaultPoiOnReturn;
    public List<uint> returnPoiActionIds = [];
    public NpcAdhereMovingPlatformInfo4229938? AdherePlatformInfo;
    public uint AgentDataSetsActivityCfgId;
    public uint GameplaySignalId;
    public string treeName = "";
    public int sitIndex;
    public List<uint> indoorList = [];
    public List<int> roomIds = [];
    public byte forbidStimulateType;
    public byte agentStimType;
    public byte beHitType;
    public int SpoonAgentId;
    public bool isAttackInSafeMode;
    public bool FeiSuo;
    public uint FashionSuitId;
    public bool CanBeExaminedByPolice;
    public bool IgnoreWanted;
    public bool BeAttackIgnorePolicePunish;
    public uint InteractId;
    public uint AISetting;
    public NpcLinkAIAgentInfo4229938 AIAgentInfo = new();
    public bool HackerBetray;
}

[UxContract]
internal sealed class NpcAdhereMovingPlatformInfo4229938
{
    public byte PlatformType;
    public bool IsScene;
    public ulong PlatformId;
    public uint PartId;
    public ulong PlatformEid;
}

[UxContract]
internal sealed class NpcLinkAIAgentInfo4229938
{
    public ulong Uid;
    public uint FightSpiritId;
    public NpcLinkAIFashionInfo4229938? Fashion;
    public string? Nickname;
    public uint NameId;
    public uint AvatarImageId;
    public uint VehicleId;
}

[UxContract]
internal sealed class NpcLinkAIFashionInfo4229938
{
    public uint SuitId;
    public Auto.OtherPlayerSpiritWearFashionsInfo WearInfo = new();
}
