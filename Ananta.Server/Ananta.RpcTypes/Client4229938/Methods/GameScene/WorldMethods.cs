using Ananta.SDK.Serialization;

namespace Ananta.Server.RpcTypes.Client4229938.Methods.GameScene;

[UxContract(Inline = true)]
internal struct UxVector3
{
    public float X;
    public float Y;
    public float Z;

    public UxVector3(float x, float y, float z) { X = x; Y = y; Z = z; }
}

[UxContract(Inline = true)]
internal sealed class SyncLogicAgentEnter { public ulong agentId; }

[UxContract(Inline = true)]
internal sealed class SyncLogicAgentLeave { public ulong agentId; }

[UxContract(Inline = true)]
internal sealed class SyncManagedLogicAgent
{
    public ulong agentId;
    public ulong pid;
    public byte moveId;
}

[UxContract(Inline = true)]
internal sealed class SyncPlayerCurrentSpirit
{
    public ulong playerPid;
    public uint templateId;
    public ulong spiritId;
    public bool isAgentSwitch;
}

[UxContract(Inline = true)]
internal sealed class SyncSwitchSpiritConfigId
{
    // 4229938 IGameSceneToClient.SyncSwitchSpiritConfigId(uint, UXVector3, List<ulong>).
    // The third field is mandatory even when the switch has no spawned helper agents.
    public uint configId;
    public UxVector3 position;
    [UxCollection(Count = UxCountEncoding.Int7)]
    public List<ulong> spawnedAgentIds = [];
}

/// <summary>PreSwitchSpiritData is an inline struct: there is no leading complex marker.</summary>
[UxContract(Inline = true)]
internal sealed class SyncPreSwitchSpirit
{
    public uint configId;
    public uint newTemplateId;
    public UxVector3 position;
}

[UxContract(Inline = true)]
internal sealed class SyncSceneLoadCompleted { public ulong sceneId; }

[UxContract(Inline = true)]
internal sealed class SyncGamePause { public bool pause; }

[UxContract(Inline = true)]
internal sealed class AskSetGamePause
{
    public bool value;
    public byte reason;
}

/// <summary>Client -> GameScene AskSwitchSpirit(uint spiritId).</summary>
[UxContract(Inline = true)]
internal sealed class AskSwitchSpirit
{
    public uint spiritId;
}

[UxContract(Inline = true)]
internal sealed class AskSwitchSpiritComplete
{
    public uint switchSpiritId;
}

[UxContract(Inline = true)]
internal sealed class SyncEntityActionGroup
{
    public ulong unitId;
    public uint actionGroupId;
}

[UxContract(Inline = true)]
internal sealed class SyncChangeSkill
{
    public ulong spiritId;
    public uint skillId;
    public float duration;
}

[UxContract(Inline = true)]
internal sealed class SyncUnitStates
{
    public ulong unitId;
    public List<uint>? states = [];
    public uint effectFreezeState;
}

[UxContract(Inline = true)]
internal sealed class SyncRemoveUnitState
{
    public ulong unitId;
    public uint state;
    public byte reason = 1;
    public uint sourceId;
}

[UxContract(Inline = true)]
internal sealed class SyncPlayerLoadRate
{
    public ulong playerPid;
    public double rate;
}

[UxContract(Inline = true)]
internal sealed class SyncUnitPositionP
{
    public ulong unitId;
    public UxVector3 position;
    public float facing;
    public byte moveId;
    public byte setPositionType;
}

[UxContract(Inline = true)]
internal sealed class SyncAllSpiritCombatPower
{
    [UxCollection(Count = UxCountEncoding.Int7)]
    public Dictionary<uint, float> combatPower = [];
}

// Client -> GameScene loading barrier messages.
[UxContract(Inline = true)]
internal sealed class AskLoadSceneCompleted
{
    public ulong sceneId;
    public ulong sessionId;
}

[UxContract(Inline = true)]
internal sealed class AskLoadGameResCompleted
{
    public ulong sceneId;
}

[UxContract(Inline = true)]
internal sealed class AskLoadingFinished
{
    public ulong sceneId;
    public ulong sessionId;
}

// Client -> GameScene movement report: List7Bit<LogicAgentSyncData>.
[UxContract(Inline = true)]
internal sealed class AskReportLogicAgentSyncData
{
    public List<LogicAgentSyncData> list = [];
}

[UxContract(Inline = true)]
internal sealed class LogicAgentSyncData
{
    public ulong AgentId;
    public UxVector3 Position;
    public UxVector3 Rotation;
}


// Client movement contracts from RPCSerializeAuto.lua (build 4229938).
[UxContract(Inline = true)]
internal struct SimpleMoveActionData
{
    public ulong UnitId;
    public UxVector3 Pos;
    public UxVector3 Rot;
    public byte MoveId;
}

[UxContract]
internal sealed class MoveActionGroundData
{
    public byte MoveGroundType;
    public ulong MoveGroundId;
    public byte MetaInfo;
    public UxVector3 LocalPos;
}

[UxContract(Inline = true)]
internal struct SimpleMoveActionDataWithGround
{
    public ulong UnitId;
    public UxVector3 Pos;
    public UxVector3 Rot;
    public byte MoveId;
    public MoveActionGroundData? GroundData;
}

[UxContract(Inline = true)]
internal struct MoveActionData
{
    public ulong UnitId;
    public UxVector3 Pos;
    public UxVector3 Rot;
    public byte MoveId;
    public byte MoveTime;
    public bool IsCritical;
    [UxCollection(Count = UxCountEncoding.Int7)] public List<byte>? ActionData;
    [UxCollection(Count = UxCountEncoding.Int7)] public List<byte>? EffectData;
}

[UxContract(Inline = true)]
internal struct MoveActionDataWithGround
{
    public ulong UnitId;
    public UxVector3 Pos;
    public UxVector3 Rot;
    public byte MoveId;
    public byte MoveTime;
    public MoveActionGroundData? GroundData;
    public bool IsCritical;
    [UxCollection(Count = UxCountEncoding.Int7)] public List<byte>? ActionData;
    [UxCollection(Count = UxCountEncoding.Int7)] public List<byte>? EffectData;
}

[UxContract(Inline = true)]
internal sealed class AskUnitMoveActionSimple
{
    [UxCollection(Count = UxCountEncoding.Int7, ItemObjectEncoding = UxObjectEncoding.Struct)]
    public List<SimpleMoveActionData> actions = [];
}

[UxContract(Inline = true)]
internal sealed class AskUnitMoveActionSimpleWithGround
{
    [UxCollection(Count = UxCountEncoding.Int7, ItemObjectEncoding = UxObjectEncoding.Struct)]
    public List<SimpleMoveActionDataWithGround> actions = [];
}

[UxContract(Inline = true)]
internal sealed class AskUnitMoveAction
{
    [UxCollection(Count = UxCountEncoding.Int7, ItemObjectEncoding = UxObjectEncoding.Struct)]
    public List<MoveActionData> actions = [];
    public uint clientLocalTime;
}

[UxContract(Inline = true)]
internal sealed class AskUnitMoveActionWithGround
{
    [UxCollection(Count = UxCountEncoding.Int7, ItemObjectEncoding = UxObjectEncoding.Struct)]
    public List<MoveActionDataWithGround> actions = [];
    public uint clientLocalTime;
}

// Full SyncUnitPositionAndFacing tuple. The last two complex values are always null on our path;
// keeping named null-only placeholders documents the 4229938 wire instead of writing marker bytes by hand.
[UxContract]
internal sealed class MoveGroundInfoNullOnly { }

[UxContract]
internal sealed class LoadingInfoNullOnly { }

[UxContract(Inline = true)]
internal sealed class SyncUnitPositionAndFacing
{
    public ulong unitId;
    public UxVector3 position;
    public float facing;
    public byte moveId;
    public bool continueMove;
    public byte setPositionType;
    public MoveGroundInfoNullOnly? moveGroundInfo;
    public LoadingInfoNullOnly? loadingInfo;
}

// Teleport & Scene Switch contracts (build 4229938).
[UxContract]
internal sealed class PreTeleportOption
{
    public uint configId;
    public ulong teleportId;
    public bool ForceClear;
    public uint TimeLineDration;
    public UxVector3 position;
    public float facing;
    public string beforeResName = string.Empty;
    public bool customBeforeTrans;
    public UxVector3 beforePosition;
    public UxVector3 beforeRot;
    public string loadingResName = string.Empty;
    public string afterResName = string.Empty;
    public bool customAfterTrans;
    public UxVector3 afterPosition;
    public UxVector3 afterRot;
    public string extParams = string.Empty;
}

[UxContract(Inline = true)]
internal sealed class AskTeleportArgs
{
    public PreTeleportOption option = new();
}

[UxContract(Inline = true)]
internal sealed class AskPlayerChangePositionByScenePortalArgs
{
    public uint bonfireuniqueid;
}

[UxContract]
internal sealed class TeleportOption
{
    public ulong teleportId;
    public UxVector3 Position;
    public float Facing;
    public bool IsSwitchScene;
    public bool WaitTaskResource;
    public uint MapEntranceId;
}

[UxContract(Inline = true)]
internal sealed class SyncTeleport
{
    public TeleportOption option = new();
}

[UxContract(Inline = true)]
internal sealed class SyncPreTeleportOption
{
    public PreTeleportOption option = new();
}

[UxContract(Inline = true)]
internal sealed class AskPublicSwitchToPublicSceneArgs
{
    public uint raidid;
    public bool delay;
    public uint mapentranceid;
}

