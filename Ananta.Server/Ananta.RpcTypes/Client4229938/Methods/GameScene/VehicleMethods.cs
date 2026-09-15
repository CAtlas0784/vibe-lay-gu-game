using Ananta.SDK.Serialization;

namespace Ananta.Server.RpcTypes.Client4229938.Methods.GameScene;

/// <summary>
/// Client -&gt; GameScene AskSummonVehicle(uint32 vehicleconfigid, UXVector3 position, float facingdirection).
/// From ClientToGameSceneDelegate.lua (build 4229938).
/// </summary>
[UxContract(Inline = true)]
internal sealed class AskSummonVehicle
{
    public uint VehicleConfigId;
    public UxVector3 Position;
    public float FacingDirection;
}

/// <summary>
/// Server -&gt; client SummonVehicleResult: inline struct { ulong VehicleEntityId; ulong TaskToken; }
/// (RPCDeserializeAuto reader 674, read via Base.ReadStruct).
/// </summary>
[UxContract(Inline = true)]
internal sealed class SummonVehicleResult
{
    public ulong VehicleEntityId;
    public ulong TaskToken;
}

/// <summary>VehicleClientPart: struct reader 1618 { uint Type; uint ConfigId; }.</summary>
[UxContract(Inline = true)]
internal struct VehicleClientPart
{
    public uint Type;
    public uint ConfigId;
}

/// <summary>
/// PlayerVehicleClientDetail: complex reader 434
/// { uint Id; List7Bit&lt;struct VehicleClientPart&gt; Parts; uint SuitId; bool IsPersistent; }.
/// </summary>
[UxContract]
internal sealed class PlayerVehicleClientDetail
{
    public uint Id;
    [UxCollection(Count = UxCountEncoding.Int7, ItemObjectEncoding = UxObjectEncoding.Struct)]
    public List<VehicleClientPart> Parts = [];
    public uint SuitId;
    public bool IsPersistent;
}

/// <summary>
/// Server -&gt; client SyncLogicVehicleEnter: full world-vehicle spawn (reader: complex).
/// Field order verified against IL2CPP metadata (UX.Game.LogicVehicleClientInfo,
/// 11 fields) and Lua Auto.WriteLogicVehicleClientInfo (RPCSerializeAuto.lua).
/// </summary>
[UxContract]
internal sealed class SyncLogicVehicleEnter
{
    public ulong EntityId;
    public uint VehicleConfigId;
    /// <summary>UX.Game.VehicleCreateSourceType as byte (Invalid=0, Task=1, Summon=2, ...).</summary>
    public byte CreateSourceType;
    [UxCollection(Count = UxCountEncoding.Int7, ItemObjectEncoding = UxObjectEncoding.Struct)]
    public List<VehicleClientPart> Parts = [];
    public uint SuitId;
    public string LicensePlate = string.Empty;
    public bool Interactable;
    public int MoveToken;
    public UxVector3 Position;
    public UxVector3 EulerAngles;
    public string? VehicleSpoonName;
}

/// <summary>
/// Raid vehicle seat entry (IL2CPP UX.Game.RaidVehicleSeatInfo + V2 wire):
/// { u64 EntityId; byte SeatIndex; byte SeatState; bool DestroyRelated }.
/// </summary>
[UxContract]
internal sealed class RaidVehicleSeatInfo
{
    public ulong EntityId;
    public byte SeatIndex;
    public byte SeatState;
    public bool DestroyRelated;
}

/// <summary>
/// Server -&gt; client SyncSpawnVehicle payload (V2 field order, verified against
/// IL2CPP UX.Game.VehicleClientInfo typedef): the notify that materializes the car.
/// </summary>
[UxContract]
internal sealed class VehicleClientInfo
{
    public ulong ControllerPid;
    public byte CreateSourceType;
    public ulong EntityId;
    public uint VehicleConfigId;
    [UxCollection(Count = UxCountEncoding.Int7, ItemObjectEncoding = UxObjectEncoding.Struct)]
    public List<VehicleClientPart> Parts = [];
    public uint SuitId;
    public UxVector3 Position;
    public float Facing;
    public UxVector3 EulerAngles;
    public float Velocity;
    public bool IsStatic;
    public int DeformStatus;
    [UxCollection(Count = UxCountEncoding.Int7, ItemObjectEncoding = UxObjectEncoding.Complex)]
    public List<RaidVehicleSeatInfo> SeatInfos = [];
    public int SpoonId;
    public bool IsDynamicGo;
    public ulong VehicleEnemyId;
    public bool DisableNavigation;
    public bool Interactable;
    public int MoveToken;
    public string LicensePlate = string.Empty;
}

/// <summary>
/// Server -&gt; client SyncDestroyVehicle(entityId, destroyType, distance, dynamicGoId).
/// Signature from IL2CPP metadata (UX.Game.IGameSceneToClient).
/// </summary>
[UxContract(Inline = true)]
internal sealed class DestroyVehicle
{
    public ulong VehicleEntityId;
    public byte VehicleDestroyType;
    public int Distance;
    public int DynamicGoId;
}

/// <summary>
/// Return body of AskGetUnlockedVehicles: top-level List7Bit&lt;PlayerVehicleClientDetail&gt;
/// (midToReturnMessageReader[63272881]: ReadList7Bit + ReadComplex reader 434).
/// </summary>
[UxContract(Inline = true)]
internal sealed class AskGetUnlockedVehiclesResult
{
    [UxCollection(Count = UxCountEncoding.Int7, ItemObjectEncoding = UxObjectEncoding.Complex)]
    public List<PlayerVehicleClientDetail> Vehicles = [];
}

/// <summary>
/// Server -&gt; client SyncTeleportVehicle(entityId, position, rotation, velocity, reset, moveToken).
/// Signature from IL2CPP metadata (UX.Game.IGameSceneToClient): all primitives/inline.
/// </summary>
[UxContract(Inline = true)]
internal sealed class SyncTeleportVehicle
{
    public ulong EntityId;
    public UxVector3 Position;
    public UxVector3 Rotation;
    public float Velocity;
    public bool Reset;
    public int MoveToken;
}

/// <summary>Server -&gt; client SyncRemoveVehicle(entityId). Signature from IL2CPP metadata.</summary>
[UxContract(Inline = true)]
internal sealed class SyncRemoveVehicle
{
    public ulong EntityId;
}

/// <summary>
/// Client -&gt; GameScene AskVehicleMove payload: complex RaidVehicleSyncData
/// { u64 Id; struct UXVector3 Position; f32 facingDirection;
///   struct UXVector3 EulerAngles; struct UXVector3 Velocity;
///   List7Bit&lt;byte&gt; Bits; i32 MoveToken }.
/// (ClientToGameSceneDelegate AskVehicleMove + Auto.WriteRaidVehicleSyncData.)
/// Server only tracks Position/facing for the debug panel; simulation stays client-side.
/// </summary>
[UxContract]
internal sealed class RaidVehicleSyncData
{
    public ulong Id;
    public UxVector3 Position;
    public float FacingDirection;
    public UxVector3 EulerAngles;
    public UxVector3 Velocity;
    [UxCollection(Count = UxCountEncoding.Int7)]
    public List<byte> Bits = [];
    public int MoveToken;
}

/// <summary>
/// Server -&gt; client SyncAetherAIInitDatas: vehicle-AI subsystem init (mirrors V2).
/// Lists stay empty on a private server; the header alone unblocks DriveManager.
/// </summary>
[UxContract]
internal sealed class AetherAIInitData
{
    public uint RaidId;
    public bool HasZoneGraph;
    public int ZoneStorageDataHandle;
    [UxCollection(Count = UxCountEncoding.Int7, ItemObjectEncoding = UxObjectEncoding.Complex)]
    public List<AetherInitStub> Intersections = [];
    [UxCollection(Count = UxCountEncoding.Int7, ItemObjectEncoding = UxObjectEncoding.Complex)]
    public List<AetherInitStub> Vehicles = [];
    [UxCollection(Count = UxCountEncoding.Int7, ItemObjectEncoding = UxObjectEncoding.Complex)]
    public List<AetherInitStub> StaticVehicles = [];
}

/// <summary>Never serialized (all Aether init lists are empty); satisfies the serializer.</summary>
[UxContract]
internal sealed class AetherInitStub
{
}

/// <summary>
/// Server -> client SyncChangeVehicleInteractable(ulong vehicleInstanceId, bool interactable).
/// Inline struct (no complex marker). From RPCDeserializeAuto reader for 68943521.
/// </summary>
[UxContract(Inline = true)]
internal sealed class SyncChangeVehicleInteractable
{
    public ulong VehicleInstanceId;
    public bool Interactable;
}

/// <summary>
/// Server -> client SyncChangeVehicleController(ulong vehicleInstanceId, ulong controllerPid).
/// Inline struct. Mirrors V2 (verified against client drive lifecycle).
/// </summary>
[UxContract(Inline = true)]
internal sealed class SyncChangeVehicleController
{
    public ulong VehicleInstanceId;
    public ulong ControllerPid;
}

/// <summary>Boarding ext info: WriteBoardingExtInfo field order (V2-verified vs Lua).</summary>
[UxContract]
internal sealed class BoardingExtInfo
{
    public UxVector3 PositionOffset;
    public UxVector3 RotationOffset;
    public bool CanBeEjected;
    public bool UseSpecificAction;
    public uint ActionGroup;
    public uint ActionId;
}

/// <summary>
/// Server -> client SyncUnitVehicleStatus payload: WriteNewClientBoardingInfo order
/// { u64 EntityId; byte Status; u64 VehicleUId; byte SeatIndex; ExtInfo? }.
/// Status: 0=none, 2=enter-start, 3=enter-phase2, 4=seated, 5=exit-start.
/// </summary>
[UxContract]
internal sealed class NewClientBoardingInfo
{
    public ulong EntityId;
    public byte Status;
    public ulong VehicleUId;
    public byte SeatIndex;
    public BoardingExtInfo? ExtInfo;
}

/// <summary>Server -> client SyncPlayerMoveToDriveSeat(pid, vehicleEntityId). Inline.</summary>
[UxContract(Inline = true)]
internal sealed class SyncPlayerMoveToDriveSeat
{
    public ulong Pid;
    public ulong VehicleEntityId;
}

/// <summary>Server -> client SyncPlayerExitVehicle(vehicleEntityId, force, stopBeforeLeave). Inline.</summary>
[UxContract(Inline = true)]
internal sealed class SyncPlayerExitVehicle
{
    public ulong VehicleEntityId;
    public bool Force;
    public bool StopBeforeLeave;
}

/// <summary>
/// Drive-state struct shared by client notifies and server enter/exit notifies
/// (SyncPlayerStartEnterOrExitVehicl / SyncPlayerVehicleStateChange /
/// SyncPlayerFinishEnterOrExitVehic). V2-verified order; SeatIndex is int.
/// </summary>
[UxContract(Inline = true)]
internal sealed class PlayerVehicleDriveStateInfo
{
    public ulong Pid;
    public bool EnterOrLeave;
    public ulong VehicleEntityId;
    public int SeatIndex;
    public bool IfForce;
    public int OpenDoorTypeId;
    public int OpenDoorActionSpeed;
    public int OpenDoorActionClipLength;
}

/// <summary>Client -> server AskClaimVehicleSeat(vehicleEntityId, seatIndices). Inline.</summary>
[UxContract(Inline = true)]
internal sealed class AskClaimVehicleSeatArgs
{
    public ulong VehicleEntityId;
    [UxCollection(Count = UxCountEncoding.Int7)]
    public List<byte> SeatIndices = [];
}

/// <summary>Client -> GameScene AskVehicleStartAutonomousDriving(bool hasvalidtargetposition, UXVector3 targetposition).</summary>
[UxContract(Inline = true)]
internal sealed class AskVehicleStartAutonomousDrivingArgs
{
    public bool HasValidTargetPosition;
    public UxVector3 TargetPosition;
}

/// <summary>Client -> GameScene AskVehicleChangeAutonomousDrivingTarget(UXVector3 targetposition).</summary>
[UxContract(Inline = true)]
internal sealed class AskVehicleChangeAutonomousDrivingTargetArgs
{
    public UxVector3 TargetPosition;
}

/// <summary>Server -> client SyncVehicleAutonomousDrivingState(ulong vehicleEntityId, bool isStart).</summary>
[UxContract(Inline = true)]
internal sealed class SyncVehicleAutonomousDrivingState
{
    public ulong VehicleEntityId;
    public bool IsStart;
}

/// <summary>Server -> client SyncPlayerAutonomousDrivingState(bool isInOverrideMode, bool isAutoDrivingBlocked, bool isImmersiveModeBlocked).</summary>
[UxContract(Inline = true)]
internal sealed class SyncPlayerAutonomousDrivingState
{
    public bool IsInOverrideMode;
    public bool IsAutoDrivingBlocked;
    public bool IsImmersiveModeBlocked;
}

/// <summary>Client -> GameScene AskVehicleNavigationPathPoints</summary>
[UxContract(Inline = true)]
internal sealed class AskVehicleNavigationPathPointsArgs
{
    public uint NavReqId;
    public UxVector3 TargetPosition;
    public bool IgnoreDirection;
    public bool IgnoreAlley;
    public bool NeedCenterPoints;
    public bool UseNavmeshConnect;
    public uint NavigationProfile;
}

/// <summary>Server -> client VehicleNavigationPathPointsResult (reader 677).</summary>
[UxContract]
internal sealed class VehicleNavigationPathPointsResult
{
    public uint NavReqId;
    [UxCollection(Count = UxCountEncoding.Int7, ItemObjectEncoding = UxObjectEncoding.Struct)]
    public List<UxVector3> Points = [];
    [UxCollection(Count = UxCountEncoding.Int7, ItemObjectEncoding = UxObjectEncoding.Struct)]
    public List<UxVector3> CenterPoints = [];
}

/// <summary>Server -> client SyncCurrentTask (64450155).</summary>
[UxContract(Inline = true)]
internal sealed class SyncCurrentTaskInfo
{
    public byte Type;
    public uint TaskId;
    public uint EventId;
    public bool FirstTime;
    public byte Reason;
}

/// <summary>Server -> client SyncSceneFogMapAllUnlock (64915741).</summary>
[UxContract(Inline = true)]
internal sealed class SyncSceneFogMapAllUnlockInfo
{
    public uint SceneId;
    public bool Unlocked;
}

