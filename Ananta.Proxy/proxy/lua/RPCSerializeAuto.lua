-- Original chunk: @Lua\LuaGen\AutoGen\RPCSerializeAuto.lua
-- Decompiled from: 00066_RPCSerializeAuto.lua_d50f7d6c3f88.luajit

local Auto = uv0
local SerializeObjectMarkNull = 0
local SerializeObjectMarkCommon = 255
local Base = require("LX6/Service/RPCSerializeBase")

function Auto.WriteAIDebugParameter(writer, val)
	Base.WritePrimitive(writer, val.Id, writer.WriteUInt64, 0)
	writer:WriteString(val.BtName, false, "AIDebugParameter.BtName", 0)
	writer:WriteString(val.BtMD5, false, "AIDebugParameter.BtMD5", 0)
	Base.WritePrimitive(writer, val.ForceDrive, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.Tick, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.Paused, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.EntityType, writer.WriteByte, 0)
	Base.WriteList7Bit(writer, val.Nodes, Base.WriteComplexWrap(Auto.WriteAINodeData, "AINodeData", false), nil, "Nodes", false, 0, nil)
	Base.WriteList7Bit(writer, val.Variables, Base.WriteStructWrap(Auto.WriteAISharedVariableInfo, "Variables"), nil, "Variables", false, 0, nil)
	Base.WriteStruct(writer, val.Event, Auto.WriteAINodeEvent, "Event")
end

function Auto.WriteAIInterrogationFinishOptions(writer, val)
	writer:WriteString(val.SessionID, false, "AIInterrogationFinishOptions.SessionID", RpcLengthLimits.AIInterrogationFinishOptions_SessionID)
end

function Auto.WriteAIInterrogationSettlement(writer, val)
	Base.WritePrimitive(writer, val.CaseId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, Base.CheckEnum(val.State, 41, 0), writer.WriteByte, 0)
end

function Auto.WriteAIInterrogationStartInfo(writer, val)
	Base.WritePrimitive(writer, val.CaseId, writer.WriteUInt64, 0)
end

function Auto.WriteAINodeData(writer, val)
	Base.WritePrimitive(writer, val.TaskId, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.TaskIndex, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.Reevaluate, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.Interrupted, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, Base.CheckEnum(val.ExecutionStatus, 89, 0), writer.WriteByte, 0)
	writer:WriteString(val.ErrorMessage, true, "AINodeData.ErrorMessage", 0)
	writer:WriteString(val.InfoMessage, true, "AINodeData.InfoMessage", 0)
end

function Auto.WriteAINodeEvent(writer, val)
	Base.WritePrimitive(writer, Base.CheckEnum(val.Type, 90, 0), writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.TaskId, writer.WriteInt32, 0)
end

function Auto.WriteAISessionBasicInfo(writer, val)
	Base.WritePrimitive(writer, val.Id, writer.WriteUInt32, 0)
	writer:WriteString(val.ConstData, false, "AISessionBasicInfo.ConstData", RpcLengthLimits.AISessionBasicInfo_ConstData)
	writer:WriteString(val.MutableData, false, "AISessionBasicInfo.MutableData", RpcLengthLimits.AISessionBasicInfo_MutableData)
	Base.WritePrimitive(writer, val.CreateTime, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.UpdateTime, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.MaxMessageId, writer.WriteUInt32, 0)
end

function Auto.WriteAISessionMessageInfo(writer, val)
	Base.WritePrimitive(writer, val.Id, writer.WriteUInt32, 0)
	writer:WriteString(val.ConstData, false, "AISessionMessageInfo.ConstData", RpcLengthLimits.AISessionMessageInfo_ConstData)
	writer:WriteString(val.MutableData, false, "AISessionMessageInfo.MutableData", RpcLengthLimits.AISessionMessageInfo_MutableData)
	Base.WritePrimitive(writer, val.CreateTime, writer.WriteUInt32, 0)
end

function Auto.WriteAISharedVariableInfo(writer, val)
	writer:WriteString(val.Key, false, "AISharedVariableInfo.Key", 0)
	writer:WriteString(val.Value, false, "AISharedVariableInfo.Value", 0)
end

function Auto.WriteAbortDialogInfo(writer, val)
	Base.WritePrimitive(writer, val.dialog_id, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.type, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.task_id, writer.WriteUInt32, 0)
	writer:WriteString(val.task_type, false, "AbortDialogInfo.task_type", RpcLengthLimits.AbortDialogInfo_task_type)
	Base.WritePrimitive(writer, val.break_dialog_id, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.break_type, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.break_task_id, writer.WriteUInt32, 0)
	writer:WriteString(val.break_task_type, false, "AbortDialogInfo.break_task_type", RpcLengthLimits.AbortDialogInfo_break_task_type)
	writer:WriteString(val.note, false, "AbortDialogInfo.note", RpcLengthLimits.AbortDialogInfo_note)
end

function Auto.WriteAcceptedTruckOrderInfo(writer, val)
	Base.WriteList7Bit(writer, val.Orders, Base.WriteComplexWrap(Auto.WriteTruckJobOrderWrap, "TruckJobOrderWrap", false), nil, "Orders", false, 0, nil)
	Base.WriteDict7Bit(writer, val.EventToAgent, writer.WriteUInt32, writer.WriteUInt64, 0, "EventToAgent", false, 0)
end

function Auto.WriteAccumulateSignInActivityCommonInfo(writer, val)
	Base.WriteList7Bit(writer, val.Rewards, writer.WriteUInt32, 0, "Rewards", false, 0, nil)
	Base.WriteList7Bit(writer, val.DisplayReward, writer.WriteUInt32, 0, "DisplayReward", false, 0, nil)
	Base.WriteList7Bit(writer, val.BgImage, writer.WriteUInt32, 0, "BgImage", false, 0, nil)
	Base.WritePrimitive(writer, val.CfgId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.StartTime, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.EndTime, writer.WriteUInt32, 0)
end

function Auto.WriteAccumulateSignInActivityData(writer, val)
	Base.WriteList(writer, val.SignInList, Base.WriteComplexWrap(Auto.WriteAccumulateSignInData, "AccumulateSignInData", false), nil, "SignInList", false, 0, nil)
	Base.WritePrimitive(writer, val.CfgId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.ShowRedPoint, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.IsOutOfDate, writer.WriteBoolean, false)
end

function Auto.WriteAccumulateSignInData(writer, val)
	Base.WritePrimitive(writer, val.SignInTime, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.IsGot, writer.WriteBoolean, false)
end

function Auto.WriteAchievementDetail(writer, val)
	Base.WritePrimitive(writer, val.AchieveTime, writer.WriteDouble, 0)
	Base.WritePrimitive(writer, val.Status, writer.WriteByte, 0)
end

function Auto.WriteActivityDataBase(writer, val)
	Base.WritePrimitive(writer, val.CfgId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.ShowRedPoint, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.IsOutOfDate, writer.WriteBoolean, false)
end

function Auto.WriteAddPlacedFurnitureInfo(writer, val)
	Base.WritePrimitive(writer, val.ParentPlacedInstanceId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.FurnitureId, writer.WriteUInt32, 0)
	Base.WriteStruct(writer, val.Position, Auto.WriteUXVector3, "Position")
	Base.WriteStruct(writer, val.Rotation, Auto.WriteUXVector3, "Rotation")
end

function Auto.WriteAdhereMovingPlatformInfo(writer, val)
	Base.WritePrimitive(writer, Base.CheckEnum(val.PlatformType, 91, 0), writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.IsScene, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.PlatformId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.PartId, writer.WriteUInt32, 0)
end

function Auto.WriteAdvancedAvoidanceParams(writer, val)
	Base.WritePrimitive(writer, val.AvoidAethers, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.AvoidNpcs, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.AvoidEnemies, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.AvoidGoVehicles, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.AvoidEcsVehicles, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.AvoidRoadBoundary, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.AvoidStaticObstacle, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.AvoidSwitchLane, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.AvoidAllowStayBetweenLanes, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.TargetArriveMaxAvoidRadius, writer.WriteSingle, 0)
end

function Auto.WriteAdvancedChaseParameters(writer, val)
	Base.WritePrimitive(writer, val.TargetUid, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, Base.CheckEnum(val.TargetType, 92, 0), writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.AvoidEcsVehicles, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.AvoidGoVehicles, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.AvoidAethers, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.AvoidNpcs, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.RamRange, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.RamMinOffsetZ, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.RamMaxOffsetZ, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.RamProbability, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.RamDecisionInterval, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.CruiseSpeed, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.DummySpeedRatio, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.Ratio, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, Base.CheckEnum(val.SpeedOverrideType, 93, 0), writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.Token, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.taskAIConfigId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.defaultSpeed, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.drivingFlags, writer.WriteInt32, 1)
	Base.WritePrimitive(writer, val.initSpeed, writer.WriteSingle, 0)
	Base.WriteList7Bit(writer, val.initTaskAIBuffList, Base.WriteStructWrap(Auto.WriteTaskVehicleBuffInitInfo, "initTaskAIBuffList"), nil, "initTaskAIBuffList", true, 0, nil)
	Base.WriteStruct(writer, val.commonParameters, Auto.WriteVehicleAICommonParameters, "commonParameters")
end

function Auto.WriteAdvancedCruiseAdaptorParams(writer, val)
	Base.WritePrimitive(writer, val.TargetUid, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.checkClose, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.checkFar, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.closeRange, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.farawayRange, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.accelerateScale, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.decelerateScale, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.minSpeed, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.maxSpeed, writer.WriteSingle, 0)
end

function Auto.WriteAdvancedCruiseParameters(writer, val)
	Base.WritePrimitive(writer, val.Count, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, Base.CheckEnum(val.CruiseType, 94, 0), writer.WriteByte, 0)
	Base.WriteList7Bit(writer, val.TargetPointList, Base.WriteStructWrap(Auto.WriteUXVector3, "TargetPointList"), nil, "TargetPointList", false, 0, nil)
	Base.WritePrimitive(writer, val.SummonVehicle, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.ConfigFlags, writer.WriteByte, 1)
	Base.WritePrimitive(writer, val.AdaptSpeedToTargetDistance, writer.WriteBoolean, false)
	Base.WriteComplex(writer, val.MissionParams, Auto.WriteAdvancedMissionParams, "MissionParams", false)
	Base.WriteComplex(writer, val.AvoidanceParams, Auto.WriteAdvancedAvoidanceParams, "AvoidanceParams", false)
	Base.WriteComplex(writer, val.CruiseAdaptorParams, Auto.WriteAdvancedCruiseAdaptorParams, "CruiseAdaptorParams", false)
	Base.WriteComplex(writer, val.OtherCruiseParams, Auto.WriteAdvancedOtherCruiseParams, "OtherCruiseParams", false)
	Base.WritePrimitive(writer, val.Token, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.taskAIConfigId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.defaultSpeed, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.drivingFlags, writer.WriteInt32, 1)
	Base.WritePrimitive(writer, val.initSpeed, writer.WriteSingle, 0)
	Base.WriteList7Bit(writer, val.initTaskAIBuffList, Base.WriteStructWrap(Auto.WriteTaskVehicleBuffInitInfo, "initTaskAIBuffList"), nil, "initTaskAIBuffList", true, 0, nil)
	Base.WriteStruct(writer, val.commonParameters, Auto.WriteVehicleAICommonParameters, "commonParameters")
end

function Auto.WriteAdvancedDrivingParams(writer, val)
	Base.WritePrimitive(writer, val.DriveReverse, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.NotAllowThreePointTurn, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.AdjustCruiseSpeedBasedOnRoadSpeed, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.ObeyTrafficLights, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.TrafficLightGreenChannel, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.NotAllowMoveReverse, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.ArriveNearestRoadToDestination, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.NotAllowTurnSlowdown, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.TurnSlowSpeedTemplateId, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.EnableHybridAIControl, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.HybridInputDeadZone, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.HybridReturnToAIDelay, writer.WriteSingle, 0)
end

function Auto.WriteAdvancedFollowRecordingParameters(writer, val)
	Base.WriteList7Bit(writer, val.RecordingSegments, Base.WriteStructWrap(Auto.WriteAdvancedFollowRecordingSegment, "RecordingSegments"), nil, "RecordingSegments", false, 0, nil)
	Base.WriteComplex(writer, val.RouteParams, Auto.WriteAdvancedFollowRouteParams, "RouteParams", false)
	Base.WritePrimitive(writer, val.AdaptSpeedToTargetDistance, writer.WriteBoolean, false)
	Base.WriteComplex(writer, val.CruiseAdaptorParams, Auto.WriteAdvancedCruiseAdaptorParams, "CruiseAdaptorParams", false)
	Base.WritePrimitive(writer, val.Token, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.taskAIConfigId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.defaultSpeed, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.drivingFlags, writer.WriteInt32, 1)
	Base.WritePrimitive(writer, val.initSpeed, writer.WriteSingle, 0)
	Base.WriteList7Bit(writer, val.initTaskAIBuffList, Base.WriteStructWrap(Auto.WriteTaskVehicleBuffInitInfo, "initTaskAIBuffList"), nil, "initTaskAIBuffList", true, 0, nil)
	Base.WriteStruct(writer, val.commonParameters, Auto.WriteVehicleAICommonParameters, "commonParameters")
end

function Auto.WriteAdvancedFollowRecordingSegment(writer, val)
	writer:WriteString(val.RecordingName, false, "AdvancedFollowRecordingSegment.RecordingName", 0)
	Base.WritePrimitive(writer, val.Progress, writer.WriteSingle, 0)
end

function Auto.WriteAdvancedFollowRouteParams(writer, val)
	Base.WritePrimitive(writer, val.Mode, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.TargetSpeed, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.TargetArriveDist, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.TargetArriveMaxAccel, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, Base.CheckEnum(val.VirtualGroundMoveType, 95, 0), writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.DummySpeedRatio, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.DummyLookAheadDistance, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.DefaultWidth, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.LeftBoundary, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.RightBoundary, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.NotAllowThreePointTurn, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.AvoidGoVehicles, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.AvoidEcsVehicles, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.AvoidAethers, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.AvoidNpcs, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.AvoidRoadBoundary, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.AvoidStaticObstacle, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.TargetArriveMaxAvoidRadius, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.EnableChaosRacing, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.ChaosSteerDeadZoneDeg, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.NotAllowTurnSlowdown, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.TurnSlowSpeedTemplateId, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.StartFromNextAndNearestPoint, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.Ratio, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, Base.CheckEnum(val.SpeedOverrideType, 93, 0), writer.WriteByte, 0)
end

function Auto.WriteAdvancedMissionParams(writer, val)
	Base.WritePrimitive(writer, val.Ratio, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.CruiseSpeed, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, Base.CheckEnum(val.SpeedOverrideType, 93, 0), writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.TargetArriveDist, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.TargetArriveMaxAccel, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.NavMeshFallbackDist, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, Base.CheckEnum(val.VirtualGroundMoveType, 95, 0), writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.DummySpeedRatio, writer.WriteSingle, 0)
	Base.WriteComplex(writer, val.DrivingParams, Auto.WriteAdvancedDrivingParams, "DrivingParams", false)
end

function Auto.WriteAdvancedOtherCruiseParams(writer, val)
	Base.WritePrimitive(writer, val.UseNewSpeedController, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.UseNewAvoidance, writer.WriteBoolean, false)
end

function Auto.WriteAetherAIInitData(writer, val)
	Base.WritePrimitive(writer, val.RaidId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.HasZoneGraph, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.ZoneStorageDataHandle, writer.WriteInt32, 0)
	Base.WriteList7Bit(writer, val.Intersections, Base.WriteComplexWrap(Auto.WriteClientTrafficIntersectionInitInfo, "ClientTrafficIntersectionInitInfo", true), nil, "Intersections", true, 0, nil)
	Base.WriteList7Bit(writer, val.Vehicles, Base.WriteComplexWrap(Auto.WriteClientVehicleInitData, "ClientVehicleInitData", true), nil, "Vehicles", true, 0, nil)
	Base.WriteList7Bit(writer, val.StaticVehicles, Base.WriteComplexWrap(Auto.WriteClientStaticVehicleInitData, "ClientStaticVehicleInitData", true), nil, "StaticVehicles", true, 0, nil)
end

function Auto.WriteAgentBeHitTypeData(writer, val)
	Base.WritePrimitive(writer, Base.CheckEnum(val.type, 96, 0), writer.WriteByte, 0)
end

function Auto.WriteAgentCharacterComponent(writer, val)
	Base.WritePrimitive(writer, val.Portrait, writer.WriteUInt32, 0)
end

function Auto.WriteAgentCommandData(writer, val)
	Base.WritePrimitive(writer, Base.CheckEnum(val.DataSource, 97, 0), writer.WriteInt16, 0)
end

function Auto.WriteAgentConditionData(writer, val)
end

function Auto.WriteAgentCrimeData(writer, val)
	Base.WriteList7Bit(writer, val.CrimeRecord, writer.WriteUInt32, 0, "CrimeRecord", true, 0, nil)
	Base.WriteList7Bit(writer, val.DefaultItems, writer.WriteUInt32, 0, "DefaultItems", true, 0, nil)
	Base.WriteList7Bit(writer, val.DefaultDrugs, writer.WriteUInt32, 0, "DefaultDrugs", true, 0, nil)
	Base.WritePrimitive(writer, val.Alcohol, writer.WriteInt32, 0)
end

function Auto.WriteAgentDestructibleData(writer, val)
	Base.WritePrimitive(writer, val.AgentId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.SceneItemCfgId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.ReleaserId, writer.WriteUInt64, 0)
	Base.WriteStruct(writer, val.Position, Auto.WriteUXVector3, "Position")
	Base.WriteStruct(writer, val.Facing, Auto.WriteUXVector3, "Facing")
	Base.WritePrimitive(writer, val.LivingTime, writer.WriteSingle, 0)
end

function Auto.WriteAgentFormationData(writer, val)
	Base.WritePrimitive(writer, val.row, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.col, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.colSpacing, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.rowSpacing, writer.WriteSingle, 0)
end

function Auto.WriteAgentPlotDestroyConfig(writer, val)
	Base.WritePrimitive(writer, Base.CheckEnum(val.Type, 98, 0), writer.WriteByte, 0)
	Base.WriteList7Bit(writer, val.RunAwayPositionList, Base.WriteStructWrap(Auto.WriteUXVector3, "RunAwayPositionList"), nil, "RunAwayPositionList", true, 0, nil)
	Base.WritePrimitive(writer, val.Distance, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.Speed, writer.WriteSingle, 0)
end

function Auto.WriteAgentPoliceExamAOIData(writer, val)
	Base.WritePrimitive(writer, val.FineTimes, writer.WriteUInt32, 0)
	Base.WriteDict7Bit(writer, val.Fines, writer.WriteUInt32, writer.WriteBoolean, false, "Fines", false, 0)
end

function Auto.WriteAgentPropertyData(writer, val)
end

function Auto.WriteAgentPropertyDataAiRegion(writer, val)
	Base.WritePrimitive(writer, val.CubeAreaId, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.IsEnable, writer.WriteBoolean, false)
end

function Auto.WriteAgentPropertyDataAttachNpcToGadgetState(writer, val)
	Base.WritePrimitive(writer, val.IsAttach, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.GadgetUniqueId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.TargetGadgetComponentId, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.ResetPos, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.NodeId, writer.WriteInt32, 0)
end

function Auto.WriteAgentPropertyDataBool(writer, val)
	Base.WritePrimitive(writer, val.V, writer.WriteBoolean, false)
end

function Auto.WriteAgentPropertyDataCurIdleAction(writer, val)
	Base.WritePrimitive(writer, val.GroupId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.ActionId, writer.WriteUInt32, 0)
end

function Auto.WriteAgentPropertyDataEnableInteract(writer, val)
	Base.WritePrimitive(writer, val.IsAllBan, writer.WriteBoolean, false)
	Base.WriteList7Bit(writer, val.BanInteractList, writer.WriteInt32, 0, "BanInteractList", false, 0, nil)
end

function Auto.WriteAgentPropertyDataGadgetFollowNpcState(writer, val)
	Base.WritePrimitive(writer, val.CreatorUniqueId, writer.WriteUInt64, 0)
	writer:WriteString(val.NpcBoneName, false, "AgentPropertyDataGadgetFollowNpcState.NpcBoneName", 0)
end

function Auto.WriteAgentPropertyDataInteractIcon(writer, val)
	Base.WriteList7Bit(writer, val.Items, Base.WriteComplexWrap(Auto.WriteInteractIconItem, "InteractIconItem", false), nil, "Items", false, 0, nil)
end

function Auto.WriteAgentPropertyDataInviteRideNpcInteract(writer, val)
	Base.WriteList7Bit(writer, val.InviteRideNpcInteractList, Base.WriteComplexWrap(Auto.WriteInviteRideNpcInteractItem, "InviteRideNpcInteractItem", false), nil, "InviteRideNpcInteractList", false, 0, nil)
end

function Auto.WriteAgentPropertyDataMakeNPCRagdollState(writer, val)
	Base.WritePrimitive(writer, val.CanGetup, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, Base.CheckEnum(val.Mode, 99, 0), writer.WriteByte, 0)
end

function Auto.WriteAgentPropertyDataNpcABPVarState(writer, val)
	Base.WritePrimitive(writer, val.IsPlayer, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.AgentSpoonId, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.IsRagDoll, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.Magnitude, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.DirectionX, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.DirectionY, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.DirectionZ, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.IsCanUp, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.ForceBone, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.IsUseConfig, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.ConfigId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, Base.CheckEnum(val.VariableType, 100, 0), writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.IntValue, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.BoolValue, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.FloatValue, writer.WriteSingle, 0)
end

function Auto.WriteAgentPropertyDataNpcPlayEffectState(writer, val)
	Base.WriteList7Bit(writer, val.Effects, Base.WriteComplexWrap(Auto.WriteNpcEffectEntry, "NpcEffectEntry", false), nil, "Effects", false, 0, nil)
end

function Auto.WriteAgentPropertyDataNpcSuit(writer, val)
	Base.WritePrimitive(writer, val.SuitId, writer.WriteUInt32, 0)
	Base.WriteList7Bit(writer, val.FashionIdList, writer.WriteUInt32, 0, "FashionIdList", true, 0, nil)
end

function Auto.WriteAgentPropertyDataOperateSoundState(writer, val)
	Base.WritePrimitive(writer, val.SoundId, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.OperateType, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.NodeId, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.operateNodeId, writer.WriteInt32, 0)
end

function Auto.WriteAgentPropertyDataRecoverNpcStimulateState(writer, val)
	Base.WritePrimitive(writer, val.IsAll, writer.WriteBoolean, false)
	Base.WriteList7Bit(writer, val.StimulateIds, writer.WriteUInt32, 0, "StimulateIds", false, 0, nil)
end

function Auto.WriteAgentPropertyDataSendPhotoNpcChangeMessageState(writer, val)
	Base.WritePrimitive(writer, val.AgentSpoonId, writer.WriteInt32, 0)
	Base.WriteStruct(writer, val.Center, Auto.WriteUXVector3, "Center")
	Base.WritePrimitive(writer, val.Height, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.Radius, writer.WriteSingle, 0)
end

function Auto.WriteAgentPropertyDataSlimeChangeState(writer, val)
	Base.WritePrimitive(writer, val.SlimeTargetState, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.SimulateAgentId, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.ParticleSize, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.Alpha, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.TransitionTime, writer.WriteSingle, 0)
end

function Auto.WriteAgentPropertyDataString(writer, val)
	writer:WriteString(val.V, false, "AgentPropertyDataString.V", 0)
end

function Auto.WriteAgentPropertyDataTargetNpcColliderLayerState(writer, val)
	Base.WritePrimitive(writer, val.IncludeColliderLayer, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.ExcludeColliderLayer, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.AutoRevertAfterDestroy, writer.WriteBoolean, false)
end

function Auto.WriteAgentPropertyDataTaskNpcTagState(writer, val)
	writer:WriteString(val.NpcTag, false, "AgentPropertyDataTaskNpcTagState.NpcTag", 0)
	Base.WritePrimitive(writer, val.IsAdd, writer.WriteBoolean, false)
end

function Auto.WriteAgentPropertyDataTaskShortcutOpenState(writer, val)
	writer:WriteString(val.KeyId, false, "AgentPropertyDataTaskShortcutOpenState.KeyId", 0)
	Base.WritePrimitive(writer, val.CfgId, writer.WriteUInt32, 0)
end

function Auto.WriteAgentPropertyDataUint(writer, val)
	Base.WritePrimitive(writer, val.V, writer.WriteUInt32, 0)
end

function Auto.WriteAgentQueryDetailInfo(writer, val)
	writer:WriteString(val.AgentSpawnType, false, "AgentQueryDetailInfo.AgentSpawnType", 0)
	writer:WriteString(val.AgentActiveBehavior, true, "AgentQueryDetailInfo.AgentActiveBehavior", 0)
	Base.WritePrimitive(writer, val.UseForwardGroup, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.ForceFullAoi, writer.WriteBoolean, false)
end

function Auto.WriteAgentSyncClientInfo(writer, val)
	Base.WritePrimitive(writer, val.NeedFTF180DegreeInteract, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.PlayerFTF180DegreeInteract, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.IndoorId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.chairId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.gadgetId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.forbidAetherAI, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.isApproachNpc, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.TriggerLeaveEvent, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.approachDistance, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.LeaveDistance, writer.WriteInt32, 0)
	writer:WriteString(val.petPerformData, true, "AgentSyncClientInfo.petPerformData", 0)
	Base.WriteList7Bit(writer, val.stimIDList, writer.WriteInt32, 0, "stimIDList", true, 0, nil)
	Base.WritePrimitive(writer, val.randomModelCfgId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.layer, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.gpsOffsetY, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.isTemp, writer.WriteBoolean, false)
	Base.WriteList7Bit(writer, val.spawnEffectId, writer.WriteUInt32, 0, "spawnEffectId", true, 0, nil)
	Base.WritePrimitive(writer, val.hideEffectId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.actionId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.actionGroupId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.initPoiActionId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.useDefaultPoiOnReturn, writer.WriteBoolean, false)
	Base.WriteList7Bit(writer, val.returnPoiActionIds, writer.WriteUInt32, 0, "returnPoiActionIds", true, 0, nil)
	Base.WritePrimitive(writer, val.metroLineId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.metroCarriageId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.AgentDataSetsActivityCfgId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.GameplaySignalId, writer.WriteUInt32, 0)
	writer:WriteString(val.treeName, false, "AgentSyncClientInfo.treeName", 0)
	Base.WritePrimitive(writer, val.sitIndex, writer.WriteInt32, 0)
	Base.WriteList7Bit(writer, val.indoorList, writer.WriteUInt32, 0, "indoorList", true, 0, nil)
	Base.WriteList7Bit(writer, val.roomIds, writer.WriteInt32, 0, "roomIds", true, 0, nil)
	Base.WritePrimitive(writer, Base.CheckEnum(val.forbidStimulateType, 101, 0), writer.WriteByte, 0)
	Base.WritePrimitive(writer, Base.CheckEnum(val.agentStimType, 102, 0), writer.WriteByte, 0)
	Base.WritePrimitive(writer, Base.CheckEnum(val.beHitType, 96, 0), writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.SpoonAgentId, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.isAttackInSafeMode, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.FeiSuo, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.FashionSuitId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.CanBeExaminedByPolice, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.IgnoreWanted, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.BeAttackIgnorePolicePunish, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.InteractId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.AISetting, writer.WriteUInt32, 0)
	Base.WriteComplex(writer, val.AIAgentInfo, Auto.WriteLinkAIAgentInfo, "AIAgentInfo", false)
	Base.WritePrimitive(writer, val.HackerBetray, writer.WriteBoolean, false)
end

function Auto.WriteAllCountryDailyGamePlayRankData(writer, val)
	Base.WriteDict7Bit(writer, val.CountryRankDataDict, writer.WriteUInt32, Base.WriteComplexWrap(Auto.WriteDailyGamePlayRankData, "DailyGamePlayRankData", false), nil, "CountryRankDataDict", false, 0)
end

function Auto.WriteAllCountryDailyGamePlayRecommendData(writer, val)
	Base.WriteDict7Bit(writer, val.CountryRecommendDataDict, writer.WriteUInt32, Base.WriteComplexWrap(Auto.WriteDailyGamePlayRecommendData, "DailyGamePlayRecommendData", false), nil, "CountryRecommendDataDict", false, 0)
end

function Auto.WriteAnimalClientInfo(writer, val)
	Base.WritePrimitive(writer, val.Id, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.Favor, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.FavorLevel, writer.WriteUInt32, 0)
	writer:WriteString(val.NickName, true, "AnimalClientInfo.NickName", 0)
	Base.WritePrimitive(writer, val.Unlock, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.Interacted, writer.WriteBoolean, false)
end

function Auto.WriteAnimationCommandData(writer, val)
	Base.WriteStruct(writer, val.Target, Auto.WriteClientActionTarget, "Target")
	Base.WritePrimitive(writer, val.AnimId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.SelectedActionIndex, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.Speed, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.UseRemapping, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.CycleNum, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, Base.CheckEnum(val.RemappingLeg, 103, 0), writer.WriteByte, 0)
	Base.WriteStruct(writer, val.StartPosition, Auto.WriteUXVector3, "StartPosition")
	Base.WriteStruct(writer, val.StartDirection, Auto.WriteUXVector3, "StartDirection")
	Base.WritePrimitive(writer, val.AutoRemapping, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, Base.CheckEnum(val.AutoRemappingMoveType, 104, 0), writer.WriteByte, 0)
	Base.WritePrimitive(writer, Base.CheckEnum(val.DataSource, 97, 0), writer.WriteInt16, 0)
end

function Auto.WriteAreaColliderParams(writer, val)
	Base.WriteStruct(writer, val.BoxAreaParams, Auto.WriteBoxAreaParams, "BoxAreaParams")
end

function Auto.WriteAttachmentEntrySyncInfo(writer, val)
	Base.WritePrimitive(writer, val.EntryId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.SceneItemUid, writer.WriteUInt64, 0)
end

function Auto.WriteAttachmentFullSyncInfo(writer, val)
	Base.WritePrimitive(writer, val.UnitId, writer.WriteUInt64, 0)
	Base.WriteList7Bit(writer, val.Slots, Base.WriteComplexWrap(Auto.WriteAttachmentSlotSyncInfo, "AttachmentSlotSyncInfo", false), nil, "Slots", false, 0, nil)
end

function Auto.WriteAttachmentSlotSyncInfo(writer, val)
	Base.WritePrimitive(writer, val.SlotId, writer.WriteUInt32, 0)
	Base.WriteList7Bit(writer, val.Entries, Base.WriteComplexWrap(Auto.WriteAttachmentEntrySyncInfo, "AttachmentEntrySyncInfo", false), nil, "Entries", false, 0, nil)
end

function Auto.WriteAvoidDangerMoveCommandData(writer, val)
	Base.WriteStruct(writer, val.Target, Auto.WriteClientActionTarget, "Target")
	Base.WritePrimitive(writer, val.DangerRadius, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.DangerDuration, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.UpdatePosTolerance, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.DangerDirRefreshLaneTime, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.DangerDirHalfAngle, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.SpecificMethod, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.Speed, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.RunChasingDistance, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.LookBackType, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.StopOnCrosswalk, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.EnableOffLaneAttach, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.OffLaneAttachSearchRadius, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.OffLaneMaxAttachPathLength, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.OffLaneMaxAttachPathRatio, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.OffLaneDirectAttachHeightTolerance, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.OffLaneAttachArriveDistance, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, Base.CheckEnum(val.DataSource, 97, 0), writer.WriteInt16, 0)
end

function Auto.WriteAvoidDangerMoveViaTrafficLaneCommandData(writer, val)
	Base.WriteStruct(writer, val.Target, Auto.WriteClientActionTarget, "Target")
	Base.WritePrimitive(writer, val.DangerRadius, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.DangerDuration, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.UpdatePosTolerance, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.SpecificMethod, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.Speed, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.RunChasingDistance, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.TrafficSearchRadius, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.PedFallbackSearchRadius, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.FallbackToPed, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.LaneCommitDuration, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.RepathCooldown, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, Base.CheckEnum(val.DataSource, 97, 0), writer.WriteInt16, 0)
end

function Auto.WriteAvoidVehicleMoveCommandData(writer, val)
	Base.WritePrimitive(writer, val.Vehicle, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.ExitWaitTime, writer.WriteSingle, 0)
	Base.WriteStruct(writer, val.Target, Auto.WriteClientActionTarget, "Target")
	Base.WritePrimitive(writer, val.ArriveDistance, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.SpecificMethod, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.DirectionTolerance, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.TryMatchStep, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.KeepUpdateTargetPosition, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.RunChasingDistance, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.KeepMovingAction, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.Speed, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.MoveActionId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.MoveActionGroup, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, Base.CheckEnum(val.DataSource, 97, 0), writer.WriteInt16, 0)
end

function Auto.WriteBBQChopstickState(writer, val)
	Base.WriteStruct(writer, val.Position, Auto.WriteUXVector3, "Position")
	Base.WritePrimitive(writer, val.HoldingMeatId, writer.WriteUInt32, 0)
end

function Auto.WriteBBQGameEndInfo(writer, val)
	Base.WriteDict7Bit(writer, val.FinalScores, writer.WriteInt32, writer.WriteInt32, 0, "FinalScores", false, 0)
	Base.WritePrimitive(writer, val.WinnerSeatIndex, writer.WriteInt32, 0)
end

function Auto.WriteBBQMeatInfo(writer, val)
	Base.WritePrimitive(writer, val.MeatId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.MeatType, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.IsOnGrill, writer.WriteBoolean, false)
	Base.WriteStruct(writer, val.GrillPosition, Auto.WriteUXVector3, "GrillPosition")
	Base.WritePrimitive(writer, val.CurrentSideUp, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.HoldingSeatIndex, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.Side0CookTime, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.Side1CookTime, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, Base.CheckEnum(val.Side0CookedLevel, 105, 0), writer.WriteByte, 0)
	Base.WritePrimitive(writer, Base.CheckEnum(val.Side1CookedLevel, 105, 0), writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.Side0Score, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.Side1Score, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.IsBurnt, writer.WriteBoolean, false)
end

function Auto.WriteBBQMeatScoreResult(writer, val)
	Base.WritePrimitive(writer, val.MeatId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.Side0Score, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.Side1Score, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.TotalMeatScore, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, Base.CheckEnum(val.Side0CookedLevel, 105, 0), writer.WriteByte, 0)
	Base.WritePrimitive(writer, Base.CheckEnum(val.Side1CookedLevel, 105, 0), writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.IsBurnt, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.PlayerNewTotalScore, writer.WriteInt32, 0)
end

function Auto.WriteBBQParticipantInfo(writer, val)
	Base.WritePrimitive(writer, val.Score, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.HoldingMeatId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.Pid, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.NpcCultivationId, writer.WriteUInt32, 0)
	Base.WriteComplex(writer, val.AIAgentInfo, Auto.WriteLinkAIAgentInfo, "AIAgentInfo", true)
	Base.WritePrimitive(writer, val.AgentInstanceId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.VehicleInstanceId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.SeatIndex, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.IsReady, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.IsPlayAgain, writer.WriteBoolean, false)
end

function Auto.WriteBBQZoneInfo(writer, val)
	Base.WritePrimitive(writer, val.GameDurationSeconds, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.GameEndTime, writer.WriteDouble, 0)
	Base.WriteList7Bit(writer, val.Meats, Base.WriteComplexWrap(Auto.WriteBBQMeatInfo, "BBQMeatInfo", false), nil, "Meats", false, 0, nil)
	Base.WriteDict7Bit(writer, val.PlayerScores, writer.WriteInt32, writer.WriteInt32, 0, "PlayerScores", false, 0)
	writer:WriteString(val.ZoneSessionId, false, "BBQZoneInfo.ZoneSessionId", 0)
	Base.WritePrimitive(writer, val.GadgetUId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.TaskId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, Base.CheckEnum(val.StartReason, 106, 0), writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.GameTypeRandom, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, Base.CheckEnum(val.SyncReason, 107, 0), writer.WriteByte, 0)
	Base.WritePrimitive(writer, Base.CheckEnum(val.ZoneType, 108, 0), writer.WriteByte, 0)
	Base.WritePrimitive(writer, Base.CheckEnum(val.ZoneState, 109, 0), writer.WriteByte, 0)
	Base.WriteList7Bit(writer, val.ParticipantInfos, Base.WriteComplexWrap(Auto.WriteGameGroundParticipantInfo, "GameGroundParticipantInfo", true), nil, "ParticipantInfos", true, 0, nil)
	Base.WriteStruct(writer, val.CountDownInfo, Auto.WriteGameGroundZoneCountDownInfo, "CountDownInfo")
end

function Auto.WriteBBehaviorSeqParamInfo(writer, val)
	writer:WriteString(val.SmartObjectTemplate, true, "BBehaviorSeqParamInfo.SmartObjectTemplate", 0)
	Base.WritePrimitive(writer, val.BsId, writer.WriteUInt32, 0)
	Base.WriteStruct(writer, val.Position, Auto.WriteUXVector3, "Position")
	Base.WritePrimitive(writer, val.Angle, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.BindJiGuanId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.SitIndex, writer.WriteInt32, 0)
end

function Auto.WriteBVBBattleAgentStatistics(writer, val)
	Base.WritePrimitive(writer, val.AgentId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.Damage, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.BeDamaged, writer.WriteSingle, 0)
end

function Auto.WriteBVBBonus(writer, val)
	Base.WritePrimitive(writer, val.Basic, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.WinBonus, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.StreakLength, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.StreakBonus, writer.WriteUInt32, 0)
end

function Auto.WriteBVBBuffCandidate(writer, val)
	Base.WritePrimitive(writer, val.ChaosBuffId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.Cost, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.Selected, writer.WriteBoolean, false)
end

function Auto.WriteBVBBuffData(writer, val)
	Base.WritePrimitive(writer, val.ChaosBuffId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.Level, writer.WriteUInt32, 0)
end

function Auto.WriteBVBPlayerBasicInfo(writer, val)
	Base.WritePrimitive(writer, Base.CheckEnum(val.PlayerType, 110, 0), writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.PlayerId, writer.WriteUInt64, 0)
	Base.WriteList7Bit(writer, val.Pokemons, writer.WriteUInt32, 0, "Pokemons", false, 0, nil)
	Base.WritePrimitive(writer, val.NpcId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, Base.CheckEnum(val.BVBCamp, 82, 0), writer.WriteByte, 0)
end

function Auto.WriteBVBPlayerData(writer, val)
	Base.WriteList7Bit(writer, val.Pokemons, Base.WriteComplexWrap(Auto.WriteFightPokemon, "FightPokemon", false), nil, "Pokemons", false, 0, nil)
	Base.WriteList7Bit(writer, val.TagInfos, Base.WriteComplexWrap(Auto.WriteChaosTagInfo, "ChaosTagInfo", false), nil, "TagInfos", false, 0, nil)
	Base.WriteList7Bit(writer, val.ChaosBuffs, Base.WriteComplexWrap(Auto.WriteBVBBuffData, "BVBBuffData", false), nil, "ChaosBuffs", false, 0, nil)
end

function Auto.WriteBadgeInfo(writer, val)
	Base.WritePrimitive(writer, val.TemplateId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.Active, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.DropSend, writer.WriteBoolean, false)
end

function Auto.WriteBalloonParticipantInfo(writer, val)
	Base.WritePrimitive(writer, val.Pid, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.NpcCultivationId, writer.WriteUInt32, 0)
	Base.WriteComplex(writer, val.AIAgentInfo, Auto.WriteLinkAIAgentInfo, "AIAgentInfo", true)
	Base.WritePrimitive(writer, val.AgentInstanceId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.VehicleInstanceId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.SeatIndex, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.IsReady, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.IsPlayAgain, writer.WriteBoolean, false)
end

function Auto.WriteBalloonZoneInfo(writer, val)
	Base.WritePrimitive(writer, val.TargetModelId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.TargetSceneItemCfgId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.Score, writer.WriteInt32, 0)
	Base.WriteList7Bit(writer, val.BalloonInstanceIdList, writer.WriteUInt64, 0, "BalloonInstanceIdList", false, 0, nil)
	writer:WriteString(val.ZoneSessionId, false, "BalloonZoneInfo.ZoneSessionId", 0)
	Base.WritePrimitive(writer, val.GadgetUId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.TaskId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, Base.CheckEnum(val.StartReason, 106, 0), writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.GameTypeRandom, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, Base.CheckEnum(val.SyncReason, 107, 0), writer.WriteByte, 0)
	Base.WritePrimitive(writer, Base.CheckEnum(val.ZoneType, 108, 0), writer.WriteByte, 0)
	Base.WritePrimitive(writer, Base.CheckEnum(val.ZoneState, 109, 0), writer.WriteByte, 0)
	Base.WriteList7Bit(writer, val.ParticipantInfos, Base.WriteComplexWrap(Auto.WriteGameGroundParticipantInfo, "GameGroundParticipantInfo", true), nil, "ParticipantInfos", true, 0, nil)
	Base.WriteStruct(writer, val.CountDownInfo, Auto.WriteGameGroundZoneCountDownInfo, "CountDownInfo")
end

function Auto.WriteBartenderCustomerNormalInfo(writer, val)
	Base.WritePrimitive(writer, val.LastVisitTime, writer.WriteUInt32, 0)
end

function Auto.WriteBartenderCustomerSuperInfo(writer, val)
	Base.WritePrimitive(writer, val.VisitCount, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.LastVisitTime, writer.WriteUInt32, 0)
end

function Auto.WriteBartenderCustomerSyncInfo(writer, val)
	Base.WritePrimitive(writer, val.Id, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, Base.CheckEnum(val.Type, 111, 1), writer.WriteByte, 1)
end

function Auto.WriteBartenderElementInfos(writer, val)
	Base.WriteDict(writer, val.ElementId2StockOzDict, writer.WriteUInt32, writer.WriteSingle, 0, "ElementId2StockOzDict", false, 0)
end

function Auto.WriteBartenderGameInfos(writer, val)
	Base.WriteDict(writer, val.CustomerSuperDict, writer.WriteUInt32, Base.WriteComplexWrap(Auto.WriteBartenderCustomerSuperInfo, "BartenderCustomerSuperInfo", false), nil, "CustomerSuperDict", false, 0)
	Base.WriteDict(writer, val.CustomerNormalDict, writer.WriteUInt32, Base.WriteComplexWrap(Auto.WriteBartenderCustomerNormalInfo, "BartenderCustomerNormalInfo", false), nil, "CustomerNormalDict", false, 0)
end

function Auto.WriteBasicClubInfo(writer, val)
	Base.WritePrimitive(writer, val.ClubId, writer.WriteUInt64, 0)
	writer:WriteString(val.Name, false, "BasicClubInfo.Name", 0)
	Base.WritePrimitive(writer, val.IconCfgId, writer.WriteUInt32, 0)
end

function Auto.WriteBasketBallEnergyEventInfo(writer, val)
	Base.WritePrimitive(writer, val.EventId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.Energy, writer.WriteUInt32, 0)
end

function Auto.WriteBasketBallEventInfo(writer, val)
	Base.WritePrimitive(writer, val.EventId, writer.WriteUInt32, 0)
	Base.WriteList7Bit(writer, val.OffensePids, writer.WriteUInt64, 0, "OffensePids", false, 0, nil)
	Base.WriteList7Bit(writer, val.DefensePids, writer.WriteUInt64, 0, "DefensePids", false, 0, nil)
	Base.WritePrimitive(writer, val.TimeStamp, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.NewTimeStamp, writer.WriteDouble, 0)
	Base.WritePrimitive(writer, val.CurRound, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.AiOwnerPid, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.robotAIAgentId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, Base.CheckEnum(val.ExitStatus, 112, 0), writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.robotUid, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, Base.CheckEnum(val.EndReason, 113, 0), writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.FreeShotBasketballSceneItemId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.IsOffenseHoldingBall, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.ReconnectPlayerId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.IsPrePickupExchange, writer.WriteBoolean, false)
end

function Auto.WriteBasketBallFoulEventInfo(writer, val)
	Base.WritePrimitive(writer, val.FoulType, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.ShooterUid, writer.WriteUInt64, 0)
end

function Auto.WriteBasketBallScoreInfo(writer, val)
	Base.WritePrimitive(writer, val.Score, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.StealCount, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.BlockCount, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.Hit3Count, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.HitCount, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.ShootCount, writer.WriteUInt32, 0)
end

function Auto.WriteBasketBallStateEventInfo(writer, val)
	Base.WritePrimitive(writer, val.EventId, writer.WriteUInt32, 0)
end

function Auto.WriteBasketBallZoneInfo(writer, val)
	Base.WriteDict7Bit(writer, val.ScoreInfoDic, writer.WriteUInt64, Base.WriteComplexWrap(Auto.WriteBasketBallScoreInfo, "BasketBallScoreInfo", false), nil, "ScoreInfoDic", false, 0)
	Base.WritePrimitive(writer, val.BasketballSceneItemId, writer.WriteUInt64, 0)
	writer:WriteString(val.ZoneSessionId, false, "BasketBallZoneInfo.ZoneSessionId", 0)
	Base.WritePrimitive(writer, val.GadgetUId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.TaskId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, Base.CheckEnum(val.StartReason, 106, 0), writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.GameTypeRandom, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, Base.CheckEnum(val.SyncReason, 107, 0), writer.WriteByte, 0)
	Base.WritePrimitive(writer, Base.CheckEnum(val.ZoneType, 108, 0), writer.WriteByte, 0)
	Base.WritePrimitive(writer, Base.CheckEnum(val.ZoneState, 109, 0), writer.WriteByte, 0)
	Base.WriteList7Bit(writer, val.ParticipantInfos, Base.WriteComplexWrap(Auto.WriteGameGroundParticipantInfo, "GameGroundParticipantInfo", true), nil, "ParticipantInfos", true, 0, nil)
	Base.WriteStruct(writer, val.CountDownInfo, Auto.WriteGameGroundZoneCountDownInfo, "CountDownInfo")
end

function Auto.WriteBasketballAskOperatorParam(writer, val)
	Base.WritePrimitive(writer, Base.CheckEnum(val.OperatorType, 114, 0), writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.BallUid, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.ActiveUid, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.PassiveUid, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.BallState, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.BallOwnerID, writer.WriteUInt64, 0)
	Base.WriteComplex(writer, val.DelayParam, Auto.WriteBasketballSyncDelayActionSpecialParam, "DelayParam", true)
	Base.WriteComplex(writer, val.ShootParam, Auto.WriteBasketballSyncShootSpecialParam, "ShootParam", true)
	Base.WriteComplex(writer, val.ConfrontationParam, Auto.WriteBasketballConfrontationParam, "ConfrontationParam", true)
	Base.WriteComplex(writer, val.ScoreEventParam, Auto.WriteBasketballScoreEventParam, "ScoreEventParam", true)
	Base.WriteComplex(writer, val.BlockEventParam, Auto.WriteBasketballBlockEventParam, "BlockEventParam", true)
	Base.WriteComplex(writer, val.StealEventParam, Auto.WriteBasketballStealEventParam, "StealEventParam", true)
	Base.WriteComplex(writer, val.FreeStyleParam, Auto.WriteBasketballFreeStyleParam, "FreeStyleParam", true)
	Base.WriteComplex(writer, val.PassParam, Auto.WriteBasketballPassParam, "PassParam", true)
	Base.WriteComplex(writer, val.PickupEventParam, Auto.WriteBasketballPickupEventParam, "PickupEventParam", true)
end

function Auto.WriteBasketballBlockEventParam(writer, val)
	Base.WritePrimitive(writer, val.inPerfectZone, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.changeTrusteeToMe, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.extraParam, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.distance, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.angle, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.distanceToRim, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.progress, writer.WriteSingle, 0)
end

function Auto.WriteBasketballConfrontationParam(writer, val)
	Base.WritePrimitive(writer, val.param1, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.param2, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.param3, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.confrontationResult, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.distance, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.angle, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.distanceToRim, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.pid1, writer.WriteUInt64, 0)
	Base.WriteStruct(writer, val.pos1, Auto.WriteUXVector3, "pos1")
	Base.WriteStruct(writer, val.forward1, Auto.WriteUXVector3, "forward1")
	Base.WritePrimitive(writer, val.pid2, writer.WriteUInt64, 0)
	Base.WriteStruct(writer, val.pos2, Auto.WriteUXVector3, "pos2")
	Base.WriteStruct(writer, val.forward2, Auto.WriteUXVector3, "forward2")
end

function Auto.WriteBasketballDefenderSnapshot(writer, val)
	Base.WritePrimitive(writer, val.UnitId, writer.WriteUInt64, 0)
	Base.WriteStruct(writer, val.Pos, Auto.WriteUXVector3, "Pos")
	Base.WriteStruct(writer, val.Forward, Auto.WriteUXVector3, "Forward")
	Base.WritePrimitive(writer, val.Distance, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.Angle, writer.WriteSingle, 0)
end

function Auto.WriteBasketballFreeStyleParam(writer, val)
	Base.WritePrimitive(writer, val.distance, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.angle, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.distanceToRim, writer.WriteSingle, 0)
end

function Auto.WriteBasketballPassParam(writer, val)
	Base.WriteStruct(writer, val.PasserPos, Auto.WriteUXVector3, "PasserPos")
	Base.WriteStruct(writer, val.PasserForward, Auto.WriteUXVector3, "PasserForward")
	Base.WriteStruct(writer, val.ReceiverPos, Auto.WriteUXVector3, "ReceiverPos")
	Base.WriteStruct(writer, val.ReceiverForward, Auto.WriteUXVector3, "ReceiverForward")
	Base.WritePrimitive(writer, val.PasserToReceiverDistance, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.PasserToReceiverAngle, writer.WriteSingle, 0)
	Base.WriteList7Bit(writer, val.PasserDefenders, Base.WriteComplexWrap(Auto.WriteBasketballDefenderSnapshot, "BasketballDefenderSnapshot", false), nil, "PasserDefenders", false, RpcLengthLimits.BasketballPassParam_PasserDefenders, nil)
	Base.WriteList7Bit(writer, val.ReceiverDefenders, Base.WriteComplexWrap(Auto.WriteBasketballDefenderSnapshot, "BasketballDefenderSnapshot", false), nil, "ReceiverDefenders", false, RpcLengthLimits.BasketballPassParam_ReceiverDefenders, nil)
	Base.WritePrimitive(writer, val.PassToken, writer.WriteUInt64, 0)
end

function Auto.WriteBasketballPickupEventParam(writer, val)
	Base.WritePrimitive(writer, Base.CheckEnum(val.Type, 115, 0), writer.WriteByte, 0)
	Base.WriteStruct(writer, val.RebounderPos, Auto.WriteUXVector3, "RebounderPos")
	Base.WriteStruct(writer, val.RebounderForward, Auto.WriteUXVector3, "RebounderForward")
	Base.WriteStruct(writer, val.BallPos, Auto.WriteUXVector3, "BallPos")
	Base.WriteStruct(writer, val.BallLandingPos, Auto.WriteUXVector3, "BallLandingPos")
	Base.WriteStruct(writer, val.BallVelocity, Auto.WriteUXVector3, "BallVelocity")
	Base.WritePrimitive(writer, val.ShootTokenForRebound, writer.WriteUInt64, 0)
end

function Auto.WriteBasketballScoreEventParam(writer, val)
	Base.WritePrimitive(writer, val.param1, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.param2, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.param3, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.ShootToken, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.isAIUnit, writer.WriteBoolean, false)
end

function Auto.WriteBasketballStealEventParam(writer, val)
	Base.WritePrimitive(writer, val.changeTrusteeToMe, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.extraParam, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.distance, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.angle, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.distanceToRim, writer.WriteSingle, 0)
	Base.WriteStruct(writer, val.InterceptorPos, Auto.WriteUXVector3, "InterceptorPos")
	Base.WriteStruct(writer, val.InterceptorForward, Auto.WriteUXVector3, "InterceptorForward")
	Base.WriteStruct(writer, val.BallStartPos, Auto.WriteUXVector3, "BallStartPos")
	Base.WriteStruct(writer, val.BallEndPos, Auto.WriteUXVector3, "BallEndPos")
	Base.WriteStruct(writer, val.BallCurrentPos, Auto.WriteUXVector3, "BallCurrentPos")
	Base.WriteStruct(writer, val.BallVelocity, Auto.WriteUXVector3, "BallVelocity")
	Base.WriteList7Bit(writer, val.BallTrajectory, Base.WriteStructWrap(Auto.WriteUXVector3, "BallTrajectory"), nil, "BallTrajectory", false, RpcLengthLimits.BasketballStealEventParam_BallTrajectory, nil)
	Base.WritePrimitive(writer, val.PassToken, writer.WriteUInt64, 0)
end

function Auto.WriteBasketballSyncDelayActionSpecialParam(writer, val)
	Base.WritePrimitive(writer, val.delay, writer.WriteSingle, 0)
end

function Auto.WriteBasketballSyncOperatorParam(writer, val)
	Base.WritePrimitive(writer, Base.CheckEnum(val.OperatorType, 114, 0), writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.BallUid, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.ActiveUid, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.PassiveUid, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.BallState, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.IsSuccess, writer.WriteBoolean, false)
	Base.WriteComplex(writer, val.DelayParam, Auto.WriteBasketballSyncDelayActionSpecialParam, "DelayParam", true)
	Base.WriteComplex(writer, val.ShootParam, Auto.WriteBasketballSyncShootSpecialParam, "ShootParam", true)
	Base.WriteComplex(writer, val.ConfrontationParam, Auto.WriteBasketballConfrontationParam, "ConfrontationParam", true)
	Base.WriteComplex(writer, val.ScoreEventParam, Auto.WriteBasketballScoreEventParam, "ScoreEventParam", true)
	Base.WriteComplex(writer, val.BlockEventParam, Auto.WriteBasketballBlockEventParam, "BlockEventParam", true)
	Base.WriteComplex(writer, val.StealEventParam, Auto.WriteBasketballStealEventParam, "StealEventParam", true)
	Base.WriteComplex(writer, val.FreeStyleParam, Auto.WriteBasketballFreeStyleParam, "FreeStyleParam", true)
	Base.WriteComplex(writer, val.PassParam, Auto.WriteBasketballPassParam, "PassParam", true)
	Base.WriteComplex(writer, val.PickupEventParam, Auto.WriteBasketballPickupEventParam, "PickupEventParam", true)
	Base.WritePrimitive(writer, val.token, writer.WriteUInt64, 0)
end

function Auto.WriteBasketballSyncOwnerInfo(writer, val)
	Base.WriteDict7Bit(writer, val.full, writer.WriteUInt64, writer.WriteUInt64, 0, "full", true, 0)
	Base.WriteDict7Bit(writer, val.addOrUpdate, writer.WriteUInt64, writer.WriteUInt64, 0, "addOrUpdate", true, 0)
	Base.WriteList7Bit(writer, val.remove, writer.WriteUInt64, 0, "remove", true, 0, nil)
end

function Auto.WriteBasketballSyncShootSpecialParam(writer, val)
	Base.WriteStruct(writer, val.startPos, Auto.WriteUXVector3, "startPos")
	Base.WriteStruct(writer, val.finalPos, Auto.WriteUXVector3, "finalPos")
	Base.WriteStruct(writer, val.shootVelocity, Auto.WriteUXVector3, "shootVelocity")
	Base.WritePrimitive(writer, val.moveTime, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.IsInGreenBox, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.ShootType, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.Distance, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.Defender, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.DefenderDistance, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.DefenderAngle, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.ScoreNum, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.ShootToken, writer.WriteUInt64, 0)
end

function Auto.WriteBattleMoveDataBase(writer, val)
	Base.WritePrimitive(writer, val.UnitId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, Base.CheckEnum(val.MoveType, 116, 0), writer.WriteInt64, 0)
	Base.WritePrimitive(writer, val.MoveId, writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.CloseIK, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.InstanceId, writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.BlockCloseCapsuleCollision, writer.WriteBoolean, false)
end

function Auto.WriteBattleMoveTowardPointData(writer, val)
	Base.WritePrimitive(writer, val.EntityId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.TargetId, writer.WriteUInt64, 0)
	Base.WriteStruct(writer, val.Center, Auto.WriteUXVector3, "Center")
	Base.WritePrimitive(writer, Base.CheckEnum(val.BattleMoveActionType, 84, 0), writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.ActionId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.MoveId, writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.MoveRotateSpeed, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.MoveTime, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.MinMoveTime, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.ReportOnStop, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.InstanceId, writer.WriteByte, 0)
end

function Auto.WriteBattleMoveTowardUnitData(writer, val)
	Base.WritePrimitive(writer, val.EntityId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.TargetId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, Base.CheckEnum(val.BattleMoveActionType, 84, 0), writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.ActionId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.MoveId, writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.MoveRotateSpeed, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.MoveTime, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.MinMoveTime, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.ReportOnStop, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.InstanceId, writer.WriteByte, 0)
end

function Auto.WriteBattleStatisticInfos(writer, val)
	Base.WritePrimitive(writer, val.KillCount, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.DeadCount, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.HeadShotCount, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.Damage, writer.WriteDouble, 0)
	Base.WritePrimitive(writer, val.BeDamaged, writer.WriteDouble, 0)
	Base.WritePrimitive(writer, val.Heal, writer.WriteDouble, 0)
	Base.WritePrimitive(writer, val.BeHealed, writer.WriteDouble, 0)
	Base.WritePrimitive(writer, val.VehicleDistance, writer.WriteDouble, 0)
end

function Auto.WriteBegBehaviorData(writer, val)
	Base.WritePrimitive(writer, val.StartTime, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.PoseStartTime, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.LastUpdateTime, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.Spot, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.begStyle, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.NpcGatherRate, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.NpcGatherLimit, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.DialogId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.RewardMean, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.RewardVariance, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.TotalReward, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.Exp, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.TotalAttractedNpc, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.TotalRewardFromPlayer, writer.WriteUInt32, 0)
	Base.WriteList7Bit(writer, val.NpcIds, writer.WriteUInt32, 0, "NpcIds", false, 0, nil)
	Base.WritePrimitive(writer, val.IsPromoted, writer.WriteBoolean, false)
end

function Auto.WriteBeggarAiPaintingUploadUrl(writer, val)
	writer:WriteString(val.PresignedUrl, false, "BeggarAiPaintingUploadUrl.PresignedUrl", 0)
	writer:WriteString(val.ObjectKey, false, "BeggarAiPaintingUploadUrl.ObjectKey", 0)
	Base.WritePrimitive(writer, val.ExpireTimeStamp, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.ImageIndex, writer.WriteUInt32, 0)
end

function Auto.WriteBehaviorSeqCommand(writer, val)
	Base.WritePrimitive(writer, Base.CheckEnum(val.Type, 117, 0), writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.CommandIndex, writer.WriteInt32, 0)
end

function Auto.WriteBehaviorSequenceBehaviorCommandPayload(writer, val)
	Base.WritePrimitive(writer, val.BehaviorId, writer.WriteUInt32, 0)
end

function Auto.WriteBehaviorSequenceMoveCommandPayload(writer, val)
	Base.WriteStruct(writer, val.Position, Auto.WriteUXVector3, "Position")
	Base.WritePrimitive(writer, val.Angle, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.Kind, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.ActionId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.OverrideActionGroup, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.ActionGroupId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.MoveType, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.CircleMoveRadius, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.useEndRotate, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.rotateSpeed, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.moveSpeed, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.Timeout, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.ArrivalOverried, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.ArrivalRangeType, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.ArrivalRange, writer.WriteSingle, 0)
end

function Auto.WriteBehaviorTaskCommandData(writer, val)
	Base.WritePrimitive(writer, val.BehaviorId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, Base.CheckEnum(val.DataSource, 97, 0), writer.WriteInt16, 0)
end

function Auto.WriteBehaviorTreeCommandData(writer, val)
	writer:WriteString(val.BehaviorTree, false, "BehaviorTreeCommandData.BehaviorTree", 0)
	Base.WritePrimitive(writer, Base.CheckEnum(val.DataSource, 97, 0), writer.WriteInt16, 0)
end

function Auto.WriteBeiDoraInfo(writer, val)
	Base.WritePrimitive(writer, val.PlayerIndex, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.BeiDoraPlayerIndex, writer.WriteInt32, 0)
	Base.WriteList7Bit(writer, val.BeiDoras, writer.WriteInt32, 0, "BeiDoras", false, 0, nil)
	Base.WriteStruct(writer, val.HandData, Auto.WritePlayerHandData, "HandData")
	Base.WritePrimitive(writer, val.RemainTurnTime, writer.WriteInt32, 0)
	Base.WriteList7Bit(writer, val.Operations, Base.WriteStructWrap(Auto.WriteOutTurnOperation, "Operations"), nil, "Operations", false, 0, nil)
	Base.WriteStruct(writer, val.MahjongSetData, Auto.WriteMahjongSetData, "MahjongSetData")
end

function Auto.WriteBelongItemInfo(writer, val)
	Base.WritePrimitive(writer, val.InstanceId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.ConfigId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, Base.CheckEnum(val.BelongingItemState, 118, 0), writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.OwnerId, writer.WriteUInt64, 0)
	Base.WriteStruct(writer, val.Position, Auto.WriteUXVector3, "Position")
	Base.WritePrimitive(writer, val.Facing, writer.WriteSingle, 0)
end

function Auto.WriteBelongingDebugInfo(writer, val)
	Base.WritePrimitive(writer, val.AgentId, writer.WriteUInt32, 0)
end

function Auto.WriteBestNpcInfo(writer, val)
	Base.WritePrimitive(writer, val.Id, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.Favor, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.Index, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.ShowFavorLevel, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.ShowFavorTime, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.InteractDays, writer.WriteUInt32, 0)
end

function Auto.WriteBillInfo(writer, val)
	Base.WritePrimitive(writer, val.Id, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.Pid, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.Aid, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.OrderTime, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.ShipTime, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.ChargeId, writer.WriteUInt32, 0)
	writer:WriteString(val.GoodsId, false, "BillInfo.GoodsId", 0)
	writer:WriteString(val.SN, false, "BillInfo.SN", 0)
	writer:WriteString(val.ConsumeSN, false, "BillInfo.ConsumeSN", 0)
	writer:WriteString(val.PayChannel, false, "BillInfo.PayChannel", 0)
	writer:WriteString(val.AppChannel, false, "BillInfo.AppChannel", 0)
	writer:WriteString(val.PayMethod, false, "BillInfo.PayMethod", 0)
	writer:WriteString(val.Platform, false, "BillInfo.Platform", 0)
	writer:WriteString(val.Udid, false, "BillInfo.Udid", 0)
	Base.WritePrimitive(writer, val.GoodsCount, writer.WriteInt32, 0)
	writer:WriteString(val.PayMoney, false, "BillInfo.PayMoney", 0)
	writer:WriteString(val.FreeMoney, false, "BillInfo.FreeMoney", 0)
	writer:WriteString(val.PayCurrency, false, "BillInfo.PayCurrency", 0)
	Base.WritePrimitive(writer, val.Deduct, writer.WriteInt32, 0)
	writer:WriteString(val.DeductPercent, false, "BillInfo.DeductPercent", 0)
	Base.WritePrimitive(writer, val.FreeYuanBao, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.PayYuanBao, writer.WriteInt32, 0)
end

function Auto.WriteBirdGroupData(writer, val)
	Base.WritePrimitive(writer, val.Id, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, Base.CheckEnum(val.State, 119, 0), writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.StateStartTime, writer.WriteUInt32, 0)
end

function Auto.WriteBoolPayload(writer, val)
	Base.WritePrimitive(writer, val.V, writer.WriteBoolean, false)
end

function Auto.WriteBotPerceptionReportData(writer, val)
	Base.WritePrimitive(writer, val.botId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.targetId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.isSeen, writer.WriteBoolean, false)
end

function Auto.WriteBowlingClientInfo(writer, val)
	Base.WritePrimitive(writer, val.Type, writer.WriteInt32, 0)
	writer:WriteString(val.Data, false, "BowlingClientInfo.Data", RpcLengthLimits.BowlingClientInfo_Data)
end

function Auto.WriteBowlingParticipantInfo(writer, val)
	Base.WritePrimitive(writer, val.Pid, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.NpcCultivationId, writer.WriteUInt32, 0)
	Base.WriteComplex(writer, val.AIAgentInfo, Auto.WriteLinkAIAgentInfo, "AIAgentInfo", true)
	Base.WritePrimitive(writer, val.AgentInstanceId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.VehicleInstanceId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.SeatIndex, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.IsReady, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.IsPlayAgain, writer.WriteBoolean, false)
end

function Auto.WriteBowlingParticipantScoreInfo(writer, val)
	Base.WriteList7Bit(writer, val.ThrowScores, writer.WriteInt32, 0, "ThrowScores", false, 0, nil)
	Base.WriteList7Bit(writer, val.FrameScores, writer.WriteInt32, 0, "FrameScores", false, 0, nil)
end

function Auto.WriteBowlingScoreInfo(writer, val)
	Base.WriteDict7Bit(writer, val.BowlingScoreDict, writer.WriteInt32, Base.WriteComplexWrap(Auto.WriteBowlingParticipantScoreInfo, "BowlingParticipantScoreInfo", false), nil, "BowlingScoreDict", false, 0)
	Base.WritePrimitive(writer, val.Winner, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.SurrenderPid, writer.WriteUInt64, 0)
end

function Auto.WriteBowlingSettleData(writer, val)
	Base.WritePrimitive(writer, val.Score, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.Rank, writer.WriteUInt32, 0)
end

function Auto.WriteBowlingZoneInfo(writer, val)
	Base.WritePrimitive(writer, Base.CheckEnum(val.GameType, 66, 0), writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.CurrentRound, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.CurrentSubRound, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.CurrentTurn, writer.WriteInt32, 0)
	Base.WriteComplex(writer, val.ScoreInfo, Auto.WriteBowlingScoreInfo, "ScoreInfo", false)
	Base.WriteList7Bit(writer, val.BowlingPinSceneItemIdList, writer.WriteUInt64, 0, "BowlingPinSceneItemIdList", false, 0, nil)
	Base.WriteList7Bit(writer, val.BowlingBallSceneItemIdList, writer.WriteUInt64, 0, "BowlingBallSceneItemIdList", false, 0, nil)
	writer:WriteString(val.ZoneSessionId, false, "BowlingZoneInfo.ZoneSessionId", 0)
	Base.WritePrimitive(writer, val.GadgetUId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.TaskId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, Base.CheckEnum(val.StartReason, 106, 0), writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.GameTypeRandom, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, Base.CheckEnum(val.SyncReason, 107, 0), writer.WriteByte, 0)
	Base.WritePrimitive(writer, Base.CheckEnum(val.ZoneType, 108, 0), writer.WriteByte, 0)
	Base.WritePrimitive(writer, Base.CheckEnum(val.ZoneState, 109, 0), writer.WriteByte, 0)
	Base.WriteList7Bit(writer, val.ParticipantInfos, Base.WriteComplexWrap(Auto.WriteGameGroundParticipantInfo, "GameGroundParticipantInfo", true), nil, "ParticipantInfos", true, 0, nil)
	Base.WriteStruct(writer, val.CountDownInfo, Auto.WriteGameGroundZoneCountDownInfo, "CountDownInfo")
end

function Auto.WriteBoxAreaParams(writer, val)
	Base.WriteStruct(writer, val.Center, Auto.WriteUXVector3, "Center")
	Base.WriteStruct(writer, val.Extents, Auto.WriteUXVector3, "Extents")
	Base.WriteStruct(writer, val.InversedRotation, Auto.WriteSerializeQuaternion, "InversedRotation")
end

function Auto.WriteBuffLibraryEntryInfo(writer, val)
	Base.WritePrimitive(writer, val.EntryId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.LibraryCfgId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.SpiritTemplateId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.TotalDurationMs, writer.WriteInt64, 0)
	Base.WritePrimitive(writer, val.ConsumedMs, writer.WriteInt64, 0)
	writer:WriteString(val.SourceTag, true, "BuffLibraryEntryInfo.SourceTag", 0)
end

function Auto.WriteBuffViewData(writer, val)
	Base.WritePrimitive(writer, val.InstanceId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.Id, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.ReleaserId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.ExpireTime, writer.WriteDouble, 0)
	Base.WritePrimitive(writer, val.Tier, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.Permanent, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.DestructibleId, writer.WriteUInt64, 0)
end

function Auto.WriteBuyFoodInfo(writer, val)
	Base.WritePrimitive(writer, val.RestaurantId, writer.WriteUInt32, 0)
	Base.WriteList7Bit(writer, val.FoodIdList, writer.WriteUInt32, 0, "FoodIdList", false, RpcLengthLimits.BuyFoodInfo_FoodIdList, nil)
	Base.WritePrimitive(writer, val.CompanionNpcId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.Date, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.NPCTreat, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.MealTime, writer.WriteUInt32, 0)
end

function Auto.WriteByteAngle(writer, val)
	Base.WritePrimitive(writer, val.Value, writer.WriteByte, 0)
end

function Auto.WriteBytePayload(writer, val)
	Base.WritePrimitive(writer, val.V, writer.WriteByte, 0)
end

function Auto.WriteBytesPayload(writer, val)
	Base.WriteList7Bit(writer, val.V, writer.WriteByte, 0, "V", false, RpcLengthLimits.BytesPayload_V, nil)
end

function Auto.WriteCanSeeTargetConditionData(writer, val)
	Base.WriteStruct(writer, val.Target, Auto.WriteClientActionTarget, "Target")
	Base.WritePrimitive(writer, val.Distance, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.HalfAngle, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.UseHead, writer.WriteBoolean, false)
end

function Auto.WriteCarShopParkingInfo(writer, val)
	Base.WritePrimitive(writer, val.VehicleEntityId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.CarshopId, writer.WriteUInt32, 0)
end

function Auto.WriteCargoInfo(writer, val)
	Base.WritePrimitive(writer, val.CargoId, writer.WriteUInt32, 0)
	Base.WriteComplex(writer, val.StartPos, Auto.WriteTruckPosInfo, "StartPos", false)
	Base.WritePrimitive(writer, val.Integrity, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.IsCargoNear, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.UniqueId, writer.WriteUInt64, 0)
end

function Auto.WriteCentripetalVelocityData(writer, val)
	Base.WriteStruct(writer, val.Center, Auto.WriteUXVector3, "Center")
	Base.WritePrimitive(writer, val.Speed, writer.WriteSingle, 0)
end

function Auto.WriteChallengeRecord(writer, val)
	Base.WritePrimitive(writer, val.ChallengeId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.HighestLevel, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.ReceivedRewardLevel, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.BestScore, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.CurrentScore, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.CurrentRewardLevel, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.CurrentIsNewRewardLevel, writer.WriteBoolean, false)
	Base.WriteDict(writer, val.BestStatisticalData, writer.WriteInt32, writer.WriteDouble, 0, "BestStatisticalData", false, 0)
	Base.WriteDict(writer, val.CurrentStatisticalData, writer.WriteInt32, writer.WriteDouble, 0, "CurrentStatisticalData", false, 0)
end

function Auto.WriteChallengeResult(writer, val)
	Base.WriteComplex(writer, val.ChallengeRecord, Auto.WriteNewChallengeRecord, "ChallengeRecord", false)
	Base.WritePrimitive(writer, val.CurrentRewardLevel, writer.WriteUInt32, 0)
	Base.WriteComplex(writer, val.RewardInfo, Auto.WriteRewardInfo, "RewardInfo", false)
end

function Auto.WriteChangePlacedFurnitureInfo(writer, val)
	Base.WritePrimitive(writer, val.PlacedInstanceId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.IsChangeParentNode, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.ParentPlacedInstanceId, writer.WriteUInt64, 0)
	Base.WriteStruct(writer, val.Position, Auto.WriteUXVector3, "Position")
	Base.WriteStruct(writer, val.Rotation, Auto.WriteUXVector3, "Rotation")
end

function Auto.WriteChaosTagInfo(writer, val)
	Base.WritePrimitive(writer, val.TagId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.TagLevel, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.TagExp, writer.WriteUInt32, 0)
end

function Auto.WriteCharacterBelongingItem(writer, val)
	Base.WritePrimitive(writer, val.InstanceId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.ConfigId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.Hp, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.State, writer.WriteUInt32, 0)
end

function Auto.WriteChargeClientInfo(writer, val)
	Base.WriteList7Bit(writer, val.ChargedIds, writer.WriteUInt32, 0, "ChargedIds", false, 0, nil)
end

function Auto.WriteChargeData(writer, val)
	Base.WritePrimitive(writer, val.CurrentCharges, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.CurrentPercentage, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.ChargePeriod, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.MaxCharges, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.Timestamp, writer.WriteDouble, 0)
end

function Auto.WriteChargeDeliveryResult(writer, val)
	writer:WriteString(val.SN, false, "ChargeDeliveryResult.SN", 0)
	writer:WriteString(val.PayChannel, false, "ChargeDeliveryResult.PayChannel", 0)
	writer:WriteString(val.ConsumeSN, false, "ChargeDeliveryResult.ConsumeSN", 0)
	Base.WritePrimitive(writer, val.ChargeId, writer.WriteUInt32, 0)
	writer:WriteString(val.GoodsId, false, "ChargeDeliveryResult.GoodsId", 0)
	Base.WritePrimitive(writer, val.Gold, writer.WriteDouble, 0)
	Base.WritePrimitive(writer, val.FreeGold, writer.WriteDouble, 0)
	Base.WriteComplex(writer, val.FirstExtraRewardInfo, Auto.WriteRewardInfo, "FirstExtraRewardInfo", true)
end

function Auto.WriteChaseParameters(writer, val)
	Base.WritePrimitive(writer, Base.CheckEnum(val.TargetType, 92, 0), writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.TargetUid, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.MaxSpeed, writer.WriteSingle, 0)
	writer:WriteString(val.chaseFormationName, false, "ChaseParameters.chaseFormationName", 0)
	Base.WritePrimitive(writer, val.enterChaseFormationDistance, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.exitChaseFormationDistance, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.targetSlowdownDistanceMaxThreshold, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.targetSlowdownDistanceMinThreshold, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.targetSlowdownSpeedThreshold, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.throttleRatioWhenTargetSlowDown, writer.WriteSingle, 0)
	Base.WriteStruct(writer, val.vehicleRamMove, Auto.WriteVehicleRamMove, "vehicleRamMove")
	Base.WriteStruct(writer, val.vehicleBlockMove, Auto.WriteVehicleBlockMove, "vehicleBlockMove")
	Base.WritePrimitive(writer, val.enableDelayTarget, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.minClosetDistanceUpdateTargetTime, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.maxClosetDistanceUpdateTargetTime, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.straightLineDistanceInCloseDistance, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.straightLineDistanceInPursue, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.useWatchDogLikeChase, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.Token, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.taskAIConfigId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.defaultSpeed, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.drivingFlags, writer.WriteInt32, 1)
	Base.WritePrimitive(writer, val.initSpeed, writer.WriteSingle, 0)
	Base.WriteList7Bit(writer, val.initTaskAIBuffList, Base.WriteStructWrap(Auto.WriteTaskVehicleBuffInitInfo, "initTaskAIBuffList"), nil, "initTaskAIBuffList", true, 0, nil)
	Base.WriteStruct(writer, val.commonParameters, Auto.WriteVehicleAICommonParameters, "commonParameters")
end

function Auto.WriteChatGroupClient(writer, val)
	Base.WritePrimitive(writer, val.Id, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.CreateTime, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.Owner, writer.WriteUInt64, 0)
	Base.WriteList7Bit(writer, val.Members, writer.WriteUInt64, 0, "Members", false, 0, nil)
	writer:WriteString(val.Name, true, "ChatGroupClient.Name", 0)
	Base.WritePrimitive(writer, val.RejectMsg, writer.WriteBoolean, false)
end

function Auto.WriteChatHint(writer, val)
	Base.WriteComplex(writer, val.NameCard, Auto.WriteNameCard, "NameCard", false)
	Base.WritePrimitive(writer, val.Count, writer.WriteInt32, 0)
end

function Auto.WriteChatInfoList(writer, val)
	Base.WriteList(writer, val.ChatList, Base.WriteComplexWrap(Auto.WriteNpcChatItem, "NpcChatItem", false), nil, "ChatList", false, 0, nil)
	Base.WritePrimitive(writer, val.Gameplay, writer.WriteUInt32, 0)
end

function Auto.WriteChatMessage(writer, val)
	Base.WritePrimitive(writer, val.MessageId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, Base.CheckEnum(val.Channel, 11, 0), writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.Pid, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.Receiver, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.Time, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.IsAudio, writer.WriteBoolean, false)
	writer:WriteString(val.Content, true, "ChatMessage.Content", 0)
	Base.WritePrimitive(writer, val.SystemMessageId, writer.WriteInt32, 0)
end

function Auto.WriteChatMessagesBlob(writer, val)
	Base.WriteList7Bit(writer, val.Messages, Base.WriteComplexWrap(Auto.WriteChatMessage, "ChatMessage", false), nil, "Messages", false, 0, nil)
end

function Auto.WriteChatWheelItem(writer, val)
	Base.WritePrimitive(writer, val.Id, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, Base.CheckEnum(val.Type, 120, 0), writer.WriteByte, 0)
end

function Auto.WriteCheckAccountResult(writer, val)
	writer:WriteString(val.unisdk_login_json, true, "CheckAccountResult.unisdk_login_json", 0)
	writer:WriteString(val.Token, false, "CheckAccountResult.Token", 0)
	writer:WriteString(val.UserName, true, "CheckAccountResult.UserName", 0)
	Base.WritePrimitive(writer, val.Aid, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.NeedRealNameTip, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.NeedRoleEnter, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.RealNameVerified, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.HostId, writer.WriteInt32, 0)
	writer:WriteString(val.OpenIdUrl, true, "CheckAccountResult.OpenIdUrl", 0)
	Base.WritePrimitive(writer, val.code, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.subcode, writer.WriteInt32, 0)
	writer:WriteString(val.msg, true, "CheckAccountResult.msg", 0)
end

function Auto.WriteCheckAgentDistanceInfo(writer, val)
	Base.WriteList7Bit(writer, val.Distance, writer.WriteInt32, 0, "Distance", false, 0, nil)
end

function Auto.WriteCheckAnimStateConditionData(writer, val)
	Base.WritePrimitive(writer, val.NpcAnimState, writer.WriteInt32, 0)
end

function Auto.WriteCheckPointAction(writer, val)
	Base.WritePrimitive(writer, val.wayPointIndex, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.opType, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.duration, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.aetherActionId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.conversationId, writer.WriteUInt32, 0)
	Base.WriteList7Bit(writer, val.dialogueSpeakers, Base.WriteStringWrap(true, "dialogueSpeakers", 0), nil, "dialogueSpeakers", true, 0, nil)
	Base.WriteList7Bit(writer, val.dialogueBindUnits, writer.WriteUInt64, 0, "dialogueBindUnits", true, 0, nil)
	Base.WritePrimitive(writer, val.wayLeaderDontWait, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, Base.CheckEnum(val.targetPace, 104, 0), writer.WriteByte, 0)
	Base.WriteStruct(writer, val.finalDirection, Auto.WriteUXVector3, "finalDirection")
	Base.WritePrimitive(writer, val.wayPointFacing, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.facingToUnit, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.gameplaySignal, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.actionSetStateId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.startAnimTagId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.stopAnimTagId, writer.WriteUInt32, 0)
end

function Auto.WriteCheckPointPathMoveCommandData(writer, val)
	Base.WriteList7Bit(writer, val.WayPoints, Base.WriteStructWrap(Auto.WriteUXVector3, "WayPoints"), nil, "WayPoints", false, 0, nil)
	Base.WriteList7Bit(writer, val.CheckPointActions, Base.WriteComplexWrap(Auto.WriteCheckPointAction, "CheckPointAction", false), nil, "CheckPointActions", false, 0, nil)
	Base.WritePrimitive(writer, Base.CheckEnum(val.SpecificMethod, 104, 0), writer.WriteByte, 0)
	Base.WritePrimitive(writer, Base.CheckEnum(val.StartPace, 104, 0), writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.StartPaceDuration, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.AnimationSetId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.KeepMovingAction, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.Speed, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.MoveActionId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.MoveActionGroupId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.NotOnGround, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.TryUseRootMotion, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, Base.CheckEnum(val.DataSource, 97, 0), writer.WriteInt16, 0)
end

function Auto.WriteCheckerEQSResInfo(writer, val)
	Base.WritePrimitive(writer, val.Uid, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.Res, writer.WriteBoolean, false)
end

function Auto.WriteChefDishScoreInfo(writer, val)
	Base.WritePrimitive(writer, val.StoveId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.RecipeId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.ProgressScore, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.FireScore, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.SeasoningScore, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.IngredientScore, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.FinalScore, writer.WriteSingle, 0)
end

function Auto.WriteChefGenerateOrderResult(writer, val)
	Base.WritePrimitive(writer, val.ItemSufficient, writer.WriteBoolean, false)
	Base.WriteList7Bit(writer, val.PredictRecipeSequence, writer.WriteUInt32, 0, "PredictRecipeSequence", false, 0, nil)
end

function Auto.WriteChefIngredientProgress(writer, val)
	Base.WritePrimitive(writer, val.Progress, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.LastTickTime, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.PutTime, writer.WriteUInt32, 0)
	Base.WriteDict7Bit(writer, val.FireLevelDurations, writer.WriteByte, writer.WriteUInt32, 0, "FireLevelDurations", false, 0)
end

function Auto.WriteChefManagementZoneInfo(writer, val)
	Base.WriteList7Bit(writer, val.PredictRecipeSequence, writer.WriteUInt32, 0, "PredictRecipeSequence", false, 0, nil)
	Base.WriteList7Bit(writer, val.ChefInventory, Base.WriteComplexWrap(Auto.WritePlayerPackItem, "PlayerPackItem", false), nil, "ChefInventory", false, 0, nil)
	Base.WriteList7Bit(writer, val.RealOrders, Base.WriteComplexWrap(Auto.WriteChefRealOrderInfo, "ChefRealOrderInfo", true), nil, "RealOrders", true, 0, nil)
	Base.WriteComplex(writer, val.FinalSettlement, Auto.WriteChefOrderSettlement, "FinalSettlement", true)
	Base.WritePrimitive(writer, Base.CheckEnum(val.GameType, 121, 0), writer.WriteByte, 0)
	Base.WriteDict7Bit(writer, val.Stove2Info, writer.WriteUInt64, Base.WriteComplexWrap(Auto.WriteChefStoveInfo, "ChefStoveInfo", false), nil, "Stove2Info", false, 0)
	Base.WriteDict7Bit(writer, val.ChefNpcInfos, writer.WriteUInt32, Base.WriteComplexWrap(Auto.WriteChefNpcInfo, "ChefNpcInfo", false), nil, "ChefNpcInfos", false, 0)
	writer:WriteString(val.ZoneSessionId, false, "ChefManagementZoneInfo.ZoneSessionId", 0)
	Base.WritePrimitive(writer, val.GadgetUId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.TaskId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, Base.CheckEnum(val.StartReason, 106, 0), writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.GameTypeRandom, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, Base.CheckEnum(val.SyncReason, 107, 0), writer.WriteByte, 0)
	Base.WritePrimitive(writer, Base.CheckEnum(val.ZoneType, 108, 0), writer.WriteByte, 0)
	Base.WritePrimitive(writer, Base.CheckEnum(val.ZoneState, 109, 0), writer.WriteByte, 0)
	Base.WriteList7Bit(writer, val.ParticipantInfos, Base.WriteComplexWrap(Auto.WriteGameGroundParticipantInfo, "GameGroundParticipantInfo", true), nil, "ParticipantInfos", true, 0, nil)
	Base.WriteStruct(writer, val.CountDownInfo, Auto.WriteGameGroundZoneCountDownInfo, "CountDownInfo")
end

function Auto.WriteChefNpcInfo(writer, val)
	Base.WriteList7Bit(writer, val.WorkInfos, Base.WriteComplexWrap(Auto.WriteChefNpcWorkInfo, "ChefNpcWorkInfo", false), nil, "WorkInfos", false, 0, nil)
end

function Auto.WriteChefNpcWorkInfo(writer, val)
	Base.WritePrimitive(writer, val.WorkId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.WorkTime, writer.WriteUInt32, 0)
end

function Auto.WriteChefOrderRecipe(writer, val)
	Base.WritePrimitive(writer, val.RecipeId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, Base.CheckEnum(val.State, 122, 0), writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.FinalScore, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.ServeTime, writer.WriteUInt32, 0)
end

function Auto.WriteChefOrderSettlement(writer, val)
	Base.WritePrimitive(writer, val.Cost, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.Income, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.Profit, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.Exp, writer.WriteUInt32, 0)
end

function Auto.WriteChefParticipantInfo(writer, val)
	Base.WritePrimitive(writer, val.Pid, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.NpcCultivationId, writer.WriteUInt32, 0)
	Base.WriteComplex(writer, val.AIAgentInfo, Auto.WriteLinkAIAgentInfo, "AIAgentInfo", true)
	Base.WritePrimitive(writer, val.AgentInstanceId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.VehicleInstanceId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.SeatIndex, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.IsReady, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.IsPlayAgain, writer.WriteBoolean, false)
end

function Auto.WriteChefRealOrderInfo(writer, val)
	Base.WriteList7Bit(writer, val.RecipeUniqueIds, writer.WriteUInt64, 0, "RecipeUniqueIds", false, 0, nil)
	Base.WriteDict7Bit(writer, val.Recipes, writer.WriteUInt64, Base.WriteComplexWrap(Auto.WriteChefOrderRecipe, "ChefOrderRecipe", false), nil, "Recipes", false, 0)
	Base.WritePrimitive(writer, val.CreateTime, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.Satisfaction, writer.WriteSingle, 0)
end

function Auto.WriteChefRecipeInfo(writer, val)
	Base.WritePrimitive(writer, val.Unlock, writer.WriteBoolean, false)
end

function Auto.WriteChefStoveInfo(writer, val)
	Base.WritePrimitive(writer, val.RecipeId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, Base.CheckEnum(val.FireLevel, 62, 0), writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.Leave, writer.WriteBoolean, false)
	Base.WriteDict7Bit(writer, val.Ingredient2Progress, writer.WriteUInt32, Base.WriteComplexWrap(Auto.WriteChefIngredientProgress, "ChefIngredientProgress", false), nil, "Ingredient2Progress", false, 0)
	Base.WriteDict7Bit(writer, val.Seasonings, writer.WriteUInt32, writer.WriteUInt32, 0, "Seasonings", false, 0)
	Base.WritePrimitive(writer, val.Temperature, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.SyncTime, writer.WriteUInt32, 0)
end

function Auto.WriteChefUnlockInfo(writer, val)
	Base.WriteDict7Bit(writer, val.RecipeDict, writer.WriteUInt32, Base.WriteComplexWrap(Auto.WriteChefRecipeInfo, "ChefRecipeInfo", false), nil, "RecipeDict", true, 0)
end

function Auto.WriteChefZoneInfo(writer, val)
	Base.WritePrimitive(writer, Base.CheckEnum(val.GameType, 121, 0), writer.WriteByte, 0)
	Base.WriteDict7Bit(writer, val.Stove2Info, writer.WriteUInt64, Base.WriteComplexWrap(Auto.WriteChefStoveInfo, "ChefStoveInfo", false), nil, "Stove2Info", false, 0)
	Base.WriteDict7Bit(writer, val.ChefNpcInfos, writer.WriteUInt32, Base.WriteComplexWrap(Auto.WriteChefNpcInfo, "ChefNpcInfo", false), nil, "ChefNpcInfos", false, 0)
	writer:WriteString(val.ZoneSessionId, false, "ChefZoneInfo.ZoneSessionId", 0)
	Base.WritePrimitive(writer, val.GadgetUId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.TaskId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, Base.CheckEnum(val.StartReason, 106, 0), writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.GameTypeRandom, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, Base.CheckEnum(val.SyncReason, 107, 0), writer.WriteByte, 0)
	Base.WritePrimitive(writer, Base.CheckEnum(val.ZoneType, 108, 0), writer.WriteByte, 0)
	Base.WritePrimitive(writer, Base.CheckEnum(val.ZoneState, 109, 0), writer.WriteByte, 0)
	Base.WriteList7Bit(writer, val.ParticipantInfos, Base.WriteComplexWrap(Auto.WriteGameGroundParticipantInfo, "GameGroundParticipantInfo", true), nil, "ParticipantInfos", true, 0, nil)
	Base.WriteStruct(writer, val.CountDownInfo, Auto.WriteGameGroundZoneCountDownInfo, "CountDownInfo")
end

function Auto.WriteChineseChessFlipMove(writer, val)
	Base.WritePrimitive(writer, val.MoveIndex, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.PlayerPid, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.IsFlip, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.Col, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.Row, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.FromCol, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.FromRow, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.ToCol, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.ToRow, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.FlippedChessId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.CapturedChessId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.CapturedScore, writer.WriteInt32, 0)
end

function Auto.WriteChineseChessFlipParticipantInfo(writer, val)
	Base.WritePrimitive(writer, val.IsRed, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.Pid, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.NpcCultivationId, writer.WriteUInt32, 0)
	Base.WriteComplex(writer, val.AIAgentInfo, Auto.WriteLinkAIAgentInfo, "AIAgentInfo", true)
	Base.WritePrimitive(writer, val.AgentInstanceId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.VehicleInstanceId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.SeatIndex, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.IsReady, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.IsPlayAgain, writer.WriteBoolean, false)
end

function Auto.WriteChineseChessFlipScoreInfo(writer, val)
	Base.WriteList7Bit(writer, val.Moves, Base.WriteComplexWrap(Auto.WriteChineseChessFlipMove, "ChineseChessFlipMove", false), nil, "Moves", false, 0, nil)
	Base.WritePrimitive(writer, val.CurrentMoveIndex, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.Winner, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, Base.CheckEnum(val.OverReason, 123, 0), writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.PendingUndoFromPid, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.PendingTieFromPid, writer.WriteUInt64, 0)
	Base.WriteDict7Bit(writer, val.UndoCountByPid, writer.WriteUInt64, writer.WriteUInt32, 0, "UndoCountByPid", false, 0)
	Base.WritePrimitive(writer, val.RedHP, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.BlackHP, writer.WriteInt32, 0)
	Base.WriteList7Bit(writer, val.ChessIds, writer.WriteInt32, 0, "ChessIds", false, 0, nil)
	Base.WriteList7Bit(writer, val.FlipIds, writer.WriteInt32, 0, "FlipIds", false, 0, nil)
	Base.WriteList7Bit(writer, val.RevealedMask, writer.WriteBoolean, false, "RevealedMask", false, 0, nil)
end

function Auto.WriteChineseChessFlipZoneInfo(writer, val)
	Base.WritePrimitive(writer, Base.CheckEnum(val.GameType, 124, 0), writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.CurrentRound, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.CurrentTurn, writer.WriteInt32, 0)
	Base.WriteComplex(writer, val.ScoreInfo, Auto.WriteChineseChessFlipScoreInfo, "ScoreInfo", false)
	writer:WriteString(val.ZoneSessionId, false, "ChineseChessFlipZoneInfo.ZoneSessionId", 0)
	Base.WritePrimitive(writer, val.GadgetUId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.TaskId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, Base.CheckEnum(val.StartReason, 106, 0), writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.GameTypeRandom, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, Base.CheckEnum(val.SyncReason, 107, 0), writer.WriteByte, 0)
	Base.WritePrimitive(writer, Base.CheckEnum(val.ZoneType, 108, 0), writer.WriteByte, 0)
	Base.WritePrimitive(writer, Base.CheckEnum(val.ZoneState, 109, 0), writer.WriteByte, 0)
	Base.WriteList7Bit(writer, val.ParticipantInfos, Base.WriteComplexWrap(Auto.WriteGameGroundParticipantInfo, "GameGroundParticipantInfo", true), nil, "ParticipantInfos", true, 0, nil)
	Base.WriteStruct(writer, val.CountDownInfo, Auto.WriteGameGroundZoneCountDownInfo, "CountDownInfo")
end

function Auto.WriteChineseChessMove(writer, val)
	Base.WritePrimitive(writer, val.MoveIndex, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.PlayerPid, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.FromX, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.FromY, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.ToX, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.ToY, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.CapturedChessId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.IsCheck, writer.WriteBoolean, false)
end

function Auto.WriteChineseChessParticipantInfo(writer, val)
	Base.WritePrimitive(writer, val.IsRed, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.Pid, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.NpcCultivationId, writer.WriteUInt32, 0)
	Base.WriteComplex(writer, val.AIAgentInfo, Auto.WriteLinkAIAgentInfo, "AIAgentInfo", true)
	Base.WritePrimitive(writer, val.AgentInstanceId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.VehicleInstanceId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.SeatIndex, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.IsReady, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.IsPlayAgain, writer.WriteBoolean, false)
end

function Auto.WriteChineseChessScoreInfo(writer, val)
	Base.WriteList7Bit(writer, val.Moves, Base.WriteComplexWrap(Auto.WriteChineseChessMove, "ChineseChessMove", false), nil, "Moves", false, 0, nil)
	Base.WritePrimitive(writer, val.CurrentMoveIndex, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.Winner, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, Base.CheckEnum(val.OverReason, 123, 0), writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.PendingUndoFromPid, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.PendingTieFromPid, writer.WriteUInt64, 0)
	Base.WriteDict7Bit(writer, val.UndoCountByPid, writer.WriteUInt64, writer.WriteUInt32, 0, "UndoCountByPid", false, 0)
end

function Auto.WriteChineseChessZoneInfo(writer, val)
	Base.WritePrimitive(writer, Base.CheckEnum(val.GameType, 124, 0), writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.CurrentRound, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.CurrentTurn, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.EndGameId, writer.WriteUInt32, 0)
	Base.WriteComplex(writer, val.ScoreInfo, Auto.WriteChineseChessScoreInfo, "ScoreInfo", false)
	writer:WriteString(val.ZoneSessionId, false, "ChineseChessZoneInfo.ZoneSessionId", 0)
	Base.WritePrimitive(writer, val.GadgetUId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.TaskId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, Base.CheckEnum(val.StartReason, 106, 0), writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.GameTypeRandom, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, Base.CheckEnum(val.SyncReason, 107, 0), writer.WriteByte, 0)
	Base.WritePrimitive(writer, Base.CheckEnum(val.ZoneType, 108, 0), writer.WriteByte, 0)
	Base.WritePrimitive(writer, Base.CheckEnum(val.ZoneState, 109, 0), writer.WriteByte, 0)
	Base.WriteList7Bit(writer, val.ParticipantInfos, Base.WriteComplexWrap(Auto.WriteGameGroundParticipantInfo, "GameGroundParticipantInfo", true), nil, "ParticipantInfos", true, 0, nil)
	Base.WriteStruct(writer, val.CountDownInfo, Auto.WriteGameGroundZoneCountDownInfo, "CountDownInfo")
end

function Auto.WriteCinemaMultiTicketInfo(writer, val)
	Base.WritePrimitive(writer, val.LocationId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.CinemaId, writer.WriteUInt32, 0)
end

function Auto.WriteCinemaTicketInfo(writer, val)
	Base.WritePrimitive(writer, val.LocationId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.CinemaId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.MovieId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.CompanionNpcId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.CinemaNpcId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.InviteNpcId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.IsDate, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, Base.CheckEnum(val.CommentType, 125, 0), writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.StartTime, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.EndTime, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, Base.CheckEnum(val.State, 126, 0), writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.IsTask, writer.WriteBoolean, false)
end

function Auto.WriteClawDateClientInfo(writer, val)
	Base.WritePrimitive(writer, val.HideNpcId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.FailTimes, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.FavorToyId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.DateNpcId, writer.WriteUInt32, 0)
end

function Auto.WriteClawSettlementInfo(writer, val)
	Base.WritePrimitive(writer, val.ClawToyId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.NpcId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.Date, writer.WriteBoolean, false)
end

function Auto.WriteClearWorldBattleOtherPlayer(writer, val)
	Base.WritePrimitive(writer, val.Pid, writer.WriteUInt64, 0)
	Base.WriteStruct(writer, val.Position, Auto.WriteUXVector3, "Position")
end

function Auto.WriteClientActionTarget(writer, val)
	Base.WritePrimitive(writer, val.Id, writer.WriteUInt64, 0)
	Base.WriteStruct(writer, val.Position, Auto.WriteUXVector3, "Position")
	Base.WritePrimitive(writer, Base.CheckEnum(val.Type, 127, 0), writer.WriteByte, 0)
end

function Auto.WriteClientActivityInfo(writer, val)
	Base.WriteComplex(writer, val.BaseActivityInfo, Auto.WriteCommonActivityInfo, "BaseActivityInfo", false)
	Base.WriteComplex(writer, val.ActivityData, Auto.WriteActivityDataBase, "ActivityData", false)
end

function Auto.WriteClientAgentBubbleConfig(writer, val)
	Base.WritePrimitive(writer, val.BubbleId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, Base.CheckEnum(val.TriggerPolicy, 128, 0), writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.Priority, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.Cooldown, writer.WriteSingle, 0)
end

function Auto.WriteClientAgentBubbleConfigs(writer, val)
	Base.WritePrimitive(writer, val.EntityId, writer.WriteUInt64, 0)
	Base.WriteStruct(writer, val.SensorRange, Auto.WriteClientAgentBubbleSensorRange, "SensorRange")
	Base.WriteList7Bit(writer, val.Configs, Base.WriteStructWrap(Auto.WriteClientAgentBubbleConfig, "Configs"), nil, "Configs", false, 0, nil)
end

function Auto.WriteClientAgentBubbleSensorRange(writer, val)
	Base.WritePrimitive(writer, val.HeightDiff, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.RadiusSq, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.ExpandRadiusSq, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.LeftAngleBorder, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.RightAngleBorder, writer.WriteSingle, 0)
end

function Auto.WriteClientBoardingInfo(writer, val)
	Base.WritePrimitive(writer, val.EntityId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.VehicleUId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.SeatIndex, writer.WriteByte, 0)
	Base.WriteStruct(writer, val.PositionOffset, Auto.WriteUXVector3, "PositionOffset")
	Base.WriteStruct(writer, val.RotationOffset, Auto.WriteUXVector3, "RotationOffset")
	Base.WritePrimitive(writer, val.CanBeEjected, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.UseSpecificAction, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.ActionGroup, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.ActionId, writer.WriteUInt32, 0)
end

function Auto.WriteClientClubTaskInfo(writer, val)
	Base.WritePrimitive(writer, val.WeeklyTime, writer.WriteUInt32, 0)
	Base.WriteDict7Bit(writer, val.TaskDict, writer.WriteUInt32, Base.WriteComplexWrap(Auto.WriteClubTaskInfo, "ClubTaskInfo", false), nil, "TaskDict", false, 0)
end

function Auto.WriteClientCommandData(writer, val)
	writer:WriteString(val.Name, false, "ClientCommandData.Name", 0)
	writer:WriteString(val.Sign, false, "ClientCommandData.Sign", 0)
	writer:WriteString(val.Comment, true, "ClientCommandData.Comment", 0)
end

function Auto.WriteClientCompetitionSeasonInfo(writer, val)
	Base.WriteComplex(writer, val.CommonSeasonInfo, Auto.WriteCommonCompetitionSeasonInfo, "CommonSeasonInfo", false)
	Base.WriteComplex(writer, val.SeasonInfo, Auto.WriteCompetitionSeasonInfo, "SeasonInfo", true)
end

function Auto.WriteClientCrowdInitData(writer, val)
	Base.WritePrimitive(writer, val.NpcFormworkId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.AgentPersonaId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.UrbanDiversityConfigId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.DesiredSpeed, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.ActionId, writer.WriteUInt16, 0)
	Base.WritePrimitive(writer, Base.CheckEnum(val.TargetLocationReason, 129, 0), writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.FashionSuitId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.Id, writer.WriteUInt64, 0)
	Base.WriteStruct(writer, val.Position, Auto.WriteUXVector3, "Position")
	Base.WritePrimitive(writer, val.Facing, writer.WriteSingle, 0)
	Base.WriteStruct(writer, val.EulerAngles, Auto.WriteUXVector3, "EulerAngles")
end

function Auto.WriteClientCustomData(writer, val)
	Base.WritePrimitive(writer, val.Type, writer.WriteInt32, 0)
	Base.WriteList7Bit(writer, val.ParametersDouble, writer.WriteDouble, 0, "ParametersDouble", true, 0, nil)
	Base.WriteList7Bit(writer, val.ParametersULong, writer.WriteUInt64, 0, "ParametersULong", true, 0, nil)
	Base.WriteList7Bit(writer, val.ParametersUInt, writer.WriteUInt32, 0, "ParametersUInt", true, 0, nil)
	Base.WriteList7Bit(writer, val.ParametersVector3, Base.WriteStructWrap(Auto.WriteUXVector3, "ParametersVector3"), nil, "ParametersVector3", true, 0, nil)
	Base.WritePrimitive(writer, val.ExpireTime, writer.WriteDouble, 0)
end

function Auto.WriteClientCustomRoomBriefInfo(writer, val)
	Base.WritePrimitive(writer, val.RoomId, writer.WriteUInt64, 0)
	writer:WriteString(val.Name, false, "ClientCustomRoomBriefInfo.Name", RpcLengthLimits.ClientCustomRoomBriefInfo_Name)
	Base.WritePrimitive(writer, Base.CheckEnum(val.Type, 130, 1), writer.WriteByte, 1)
	Base.WritePrimitive(writer, Base.CheckEnum(val.Status, 131, 0), writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.HasPassword, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.OwnerPid, writer.WriteUInt64, 0)
	writer:WriteString(val.OwnerName, false, "ClientCustomRoomBriefInfo.OwnerName", RpcLengthLimits.ClientCustomRoomBriefInfo_OwnerName)
	Base.WritePrimitive(writer, val.CurrentMembers, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.MaxMembers, writer.WriteInt32, 0)
	Base.WriteDict7Bit(writer, val.Tags, writer.WriteInt16, writer.WriteUInt32, 0, "Tags", false, RpcLengthLimits.ClientCustomRoomBriefInfo_Tags)
	Base.WritePrimitive(writer, val.CurrentStatusOverTime, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.FriendOnly, writer.WriteBoolean, false)
end

function Auto.WriteClientCustomRoomInfo(writer, val)
	Base.WritePrimitive(writer, val.RoomId, writer.WriteUInt64, 0)
	writer:WriteString(val.Name, false, "ClientCustomRoomInfo.Name", 0)
	Base.WritePrimitive(writer, Base.CheckEnum(val.Type, 130, 1), writer.WriteByte, 1)
	Base.WritePrimitive(writer, Base.CheckEnum(val.Status, 131, 0), writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.CurrentStatusOverTime, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.HasPassword, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.OwnerPid, writer.WriteUInt64, 0)
	Base.WriteList(writer, val.Members, Base.WriteComplexWrap(Auto.WriteClientCustomRoomMemberInfo, "ClientCustomRoomMemberInfo", false), nil, "Members", false, 0, nil)
	Base.WritePrimitive(writer, val.MaxMembers, writer.WriteInt32, 0)
	Base.WriteDict(writer, val.Tags, writer.WriteInt16, writer.WriteUInt32, 0, "Tags", false, 0)
	Base.WritePrimitive(writer, val.OwnerLeaveDisband, writer.WriteBoolean, false)
	Base.WriteComplex(writer, val.PartyInfo, Auto.WritePartyRoomInfo, "PartyInfo", true)
end

function Auto.WriteClientCustomRoomMemberInfo(writer, val)
	Base.WritePrimitive(writer, val.Pid, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.IsReady, writer.WriteBoolean, false)
	Base.WriteComplex(writer, val.PlayerInfo, Auto.WritePlayerBasicInfoVO, "PlayerInfo", false)
end

function Auto.WriteClientDangerAreaData(writer, val)
	Base.WritePrimitive(writer, val.Id, writer.WriteUInt64, 0)
	Base.WriteStruct(writer, val.Center, Auto.WriteUXVector3, "Center")
	Base.WriteStruct(writer, val.Extents, Auto.WriteUXVector3, "Extents")
	Base.WritePrimitive(writer, val.Duration, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.RemoveRadiusSq, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.IsOBB, writer.WriteBoolean, false)
	Base.WriteStruct(writer, val.OBBExtents, Auto.WriteUXVector3, "OBBExtents")
	Base.WriteStruct(writer, val.InverseRotation, Auto.WriteUXVector3, "InverseRotation")
	Base.WritePrimitive(writer, val.Radius, writer.WriteSingle, 0)
end

function Auto.WriteClientDetectEventData(writer, val)
	Base.WritePrimitive(writer, val.detectorPid, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.detectedPid, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.detectValue, writer.WriteInt32, 0)
	Base.WriteStruct(writer, val.Position, Auto.WriteUXVector3, "Position")
end

function Auto.WriteClientDeviceInfo(writer, val)
	writer:WriteString(val.DeviceModel, true, "ClientDeviceInfo.DeviceModel", RpcLengthLimits.ClientDeviceInfo_DeviceModel)
	writer:WriteString(val.OsName, true, "ClientDeviceInfo.OsName", RpcLengthLimits.ClientDeviceInfo_OsName)
	writer:WriteString(val.OsVersion, true, "ClientDeviceInfo.OsVersion", RpcLengthLimits.ClientDeviceInfo_OsVersion)
	writer:WriteString(val.Udid, true, "ClientDeviceInfo.Udid", RpcLengthLimits.ClientDeviceInfo_Udid)
	writer:WriteString(val.AppVersion, true, "ClientDeviceInfo.AppVersion", RpcLengthLimits.ClientDeviceInfo_AppVersion)
	Base.WritePrimitive(writer, val.DeviceHeight, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.DeviceWidth, writer.WriteInt32, 0)
	writer:WriteString(val.Network, true, "ClientDeviceInfo.Network", RpcLengthLimits.ClientDeviceInfo_Network)
	writer:WriteString(val.Ipv6, true, "ClientDeviceInfo.Ipv6", RpcLengthLimits.ClientDeviceInfo_Ipv6)
	writer:WriteString(val.AppChannel, true, "ClientDeviceInfo.AppChannel", RpcLengthLimits.ClientDeviceInfo_AppChannel)
	writer:WriteString(val.Transid, true, "ClientDeviceInfo.Transid", RpcLengthLimits.ClientDeviceInfo_Transid)
	writer:WriteString(val.UnisdkDeviceId, true, "ClientDeviceInfo.UnisdkDeviceId", RpcLengthLimits.ClientDeviceInfo_UnisdkDeviceId)
	Base.WritePrimitive(writer, val.IsEmulator, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.IsRoot, writer.WriteBoolean, false)
	writer:WriteString(val.Imei, true, "ClientDeviceInfo.Imei", RpcLengthLimits.ClientDeviceInfo_Imei)
	writer:WriteString(val.Location, true, "ClientDeviceInfo.Location", RpcLengthLimits.ClientDeviceInfo_Location)
	writer:WriteString(val.CountryCode, true, "ClientDeviceInfo.CountryCode", RpcLengthLimits.ClientDeviceInfo_CountryCode)
	writer:WriteString(val.LocalIp, true, "ClientDeviceInfo.LocalIp", RpcLengthLimits.ClientDeviceInfo_LocalIp)
	writer:WriteString(val.OldAccountId, true, "ClientDeviceInfo.OldAccountId", RpcLengthLimits.ClientDeviceInfo_OldAccountId)
	writer:WriteString(val.MacAddr, true, "ClientDeviceInfo.MacAddr", RpcLengthLimits.ClientDeviceInfo_MacAddr)
	writer:WriteString(val.GpuName, true, "ClientDeviceInfo.GpuName", RpcLengthLimits.ClientDeviceInfo_GpuName)
	writer:WriteString(val.CpuName, true, "ClientDeviceInfo.CpuName", RpcLengthLimits.ClientDeviceInfo_CpuName)
	writer:WriteString(val.HardDriveSn, true, "ClientDeviceInfo.HardDriveSn", RpcLengthLimits.ClientDeviceInfo_HardDriveSn)
	Base.WritePrimitive(writer, val.TotalMemory, writer.WriteInt64, 0)
	Base.WritePrimitive(writer, val.ResolutionHeight, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.ResolutionWidth, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.FullScreen, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, Base.CheckEnum(val.DeviceLevel, 42, 0), writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.DisplayLevel, writer.WriteInt32, 0)
	writer:WriteString(val.Joystick, true, "ClientDeviceInfo.Joystick", RpcLengthLimits.ClientDeviceInfo_Joystick)
	Base.WritePrimitive(writer, val.characterQualityLevel, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.vehicleQualityLevel, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.link_device_level, writer.WriteInt32, 0)
	Base.WriteList(writer, val.bundles, writer.WriteUInt32, 0, "bundles", false, RpcLengthLimits.ClientDeviceInfo_bundles, nil)
end

function Auto.WriteClientFinishedTruckOrderView(writer, val)
	Base.WritePrimitive(writer, val.TodayTotalIncome, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.TodayRewardPoint, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.TotalActivityPointRewards, writer.WriteInt32, 0)
	Base.WriteList7Bit(writer, val.FinishedOrders, Base.WriteComplexWrap(Auto.WriteTruckJobOrderWrap, "TruckJobOrderWrap", false), nil, "FinishedOrders", false, 0, nil)
end

function Auto.WriteClientFormationMember(writer, val)
	Base.WritePrimitive(writer, val.InstanceId, writer.WriteUInt64, 0)
	Base.WriteStruct(writer, val.Offset, Auto.WriteUXVector3, "Offset")
end

function Auto.WriteClientFormationStructureUpdate(writer, val)
	Base.WritePrimitive(writer, val.Id, writer.WriteUInt64, 0)
	Base.WriteStruct(writer, val.Position, Auto.WriteUXVector3, "Position")
	Base.WritePrimitive(writer, val.Facing, writer.WriteSingle, 0)
	Base.WriteStruct(writer, val.EulerAngles, Auto.WriteUXVector3, "EulerAngles")
	Base.WritePrimitive(writer, Base.CheckEnum(val.TraceType, 104, 0), writer.WriteByte, 0)
	Base.WriteList7Bit(writer, val.Members, Base.WriteComplexWrap(Auto.WriteClientFormationMember, "ClientFormationMember", false), nil, "Members", false, 0, nil)
end

function Auto.WriteClientIntersectionDebugData(writer, val)
	Base.WritePrimitive(writer, val.Id, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.ZoneIndex, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.PeriodCount, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.CurrentPeriodIndex, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.NextPeriodIndex, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, Base.CheckEnum(val.CurrentState, 132, 0), writer.WriteByte, 0)
	Base.WriteStruct(writer, val.Position, Auto.WriteUXVector3, "Position")
	Base.WriteList7Bit(writer, val.LaneHandlesOpen, writer.WriteInt32, 0, "LaneHandlesOpen", false, 0, nil)
	Base.WriteList7Bit(writer, val.LaneVehicleCountDebugData, Base.WriteComplexWrap(Auto.WriteClientLaneVehicleCountDebugData, "ClientLaneVehicleCountDebugData", false), nil, "LaneVehicleCountDebugData", false, 0, nil)
end

function Auto.WriteClientLaneVehicleCountDebugData(writer, val)
	Base.WritePrimitive(writer, val.PedLane, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.LaneHandle, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.Count, writer.WriteInt32, 0)
end

function Auto.WriteClientMetroNpcInitData(writer, val)
	Base.WritePrimitive(writer, val.NpcFormworkId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.MetroInstanceId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.MetroCarriageIndex, writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.SPoiActionId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.CPoiActionId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.Id, writer.WriteUInt64, 0)
	Base.WriteStruct(writer, val.Position, Auto.WriteUXVector3, "Position")
	Base.WritePrimitive(writer, val.Facing, writer.WriteSingle, 0)
	Base.WriteStruct(writer, val.EulerAngles, Auto.WriteUXVector3, "EulerAngles")
end

function Auto.WriteClientNpcChatData(writer, val)
	Base.WritePrimitive(writer, val.TemplateId, writer.WriteUInt32, 0)
	Base.WriteList7Bit(writer, val.InviteChatList, Base.WriteComplexWrap(Auto.WriteNpcChatItem, "NpcChatItem", false), nil, "InviteChatList", false, 0, nil)
	Base.WriteList7Bit(writer, val.DialogChatList, Base.WriteComplexWrap(Auto.WriteNpcChatItem, "NpcChatItem", false), nil, "DialogChatList", false, 0, nil)
	Base.WriteDict7Bit(writer, val.NpcChatListDict, writer.WriteUInt32, Base.WriteComplexWrap(Auto.WriteChatInfoList, "ChatInfoList", false), nil, "NpcChatListDict", false, 0)
	Base.WriteDict7Bit(writer, val.DialogChatListDict, writer.WriteUInt32, Base.WriteComplexWrap(Auto.WriteChatInfoList, "ChatInfoList", false), nil, "DialogChatListDict", false, 0)
end

function Auto.WriteClientNpcDebugDensityStatistics(writer, val)
	Base.WritePrimitive(writer, val.PedArea, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.NonScaleExceptedPedNum, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.ExceptedPedNum, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.ActualPedNum, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.ExceptedStaticNum, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.ActualStaticNum, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.ActualVehicleNpcNum, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.ActualMetroNpcNum, writer.WriteSingle, 0)
end

function Auto.WriteClientNpcGroupChatData(writer, val)
	Base.WritePrimitive(writer, val.TemplateId, writer.WriteUInt32, 0)
	Base.WriteList7Bit(writer, val.InviteChatList, Base.WriteComplexWrap(Auto.WriteNpcChatItem, "NpcChatItem", false), nil, "InviteChatList", false, 0, nil)
	Base.WriteList7Bit(writer, val.DialogChatList, Base.WriteComplexWrap(Auto.WriteNpcChatItem, "NpcChatItem", false), nil, "DialogChatList", false, 0, nil)
	Base.WriteList7Bit(writer, val.Members, writer.WriteUInt32, 0, "Members", false, 0, nil)
	Base.WriteDict7Bit(writer, val.NpcChatListDict, writer.WriteUInt32, Base.WriteComplexWrap(Auto.WriteChatInfoList, "ChatInfoList", false), nil, "NpcChatListDict", false, 0)
	Base.WriteDict7Bit(writer, val.DialogChatListDict, writer.WriteUInt32, Base.WriteComplexWrap(Auto.WriteChatInfoList, "ChatInfoList", false), nil, "DialogChatListDict", false, 0)
end

function Auto.WriteClientNpcPlayAnimationData(writer, val)
	Base.WritePrimitive(writer, val.Id, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.PoiActionId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.StartTime, writer.WriteDouble, 0)
end

function Auto.WriteClientNpcPoiActionData(writer, val)
	Base.WritePrimitive(writer, val.Id, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.SPoiActionId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.CPoiActionId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.IsActive, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.PlayPoiSpeed, writer.WriteSingle, 0)
end

function Auto.WriteClientNpcTeleportData(writer, val)
	Base.WritePrimitive(writer, val.Id, writer.WriteUInt64, 0)
	Base.WriteStruct(writer, val.Position, Auto.WriteUXVector3, "Position")
	Base.WriteStruct(writer, val.Rotation, Auto.WriteUXVector3, "Rotation")
	Base.WritePrimitive(writer, Base.CheckEnum(val.DataSource, 97, 0), writer.WriteInt16, 0)
end

function Auto.WriteClientPedData(writer, val)
	Base.WritePrimitive(writer, val.Id, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.NpcFormworkId, writer.WriteUInt32, 0)
	Base.WriteStruct(writer, val.Position, Auto.WriteUXVector3, "Position")
	Base.WritePrimitive(writer, val.ActionId, writer.WriteInt32, 0)
end

function Auto.WriteClientPlayerRankingSummary(writer, val)
	Base.WritePrimitive(writer, val.RankConfigId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.Score, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.Rank, writer.WriteInt32, 0)
	Base.WriteStruct(writer, val.TierDetail, Auto.WriteTierDetail, "TierDetail")
end

function Auto.WriteClientQualitySetting(writer, val)
	writer:WriteString(val.setting, false, "ClientQualitySetting.setting", RpcLengthLimits.ClientQualitySetting_setting)
end

function Auto.WriteClientRankWarZoneInfo(writer, val)
	Base.WritePrimitive(writer, val.CurrentZoneId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.PendingZoneId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.PendingEffectCycle, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.SwitchedCount, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.MaxSwitch, writer.WriteUInt32, 0)
end

function Auto.WriteClientRankingEntry(writer, val)
	Base.WritePrimitive(writer, val.PlayerId, writer.WriteUInt64, 0)
	writer:WriteString(val.Name, false, "ClientRankingEntry.Name", 0)
	Base.WritePrimitive(writer, val.Score, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.Rank, writer.WriteInt32, 0)
	Base.WriteStruct(writer, val.TierDetail, Auto.WriteTierDetail, "TierDetail")
	Base.WritePrimitive(writer, val.IsRobot, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.VehicleConfigId, writer.WriteUInt32, 0)
end

function Auto.WriteClientRankingTopResult(writer, val)
	Base.WritePrimitive(writer, val.RankConfigId, writer.WriteUInt32, 0)
	Base.WriteStruct(writer, val.Slot, Auto.WriteClientSubRankSlot, "Slot")
	Base.WriteList7Bit(writer, val.Entries, Base.WriteComplexWrap(Auto.WriteClientRankingEntry, "ClientRankingEntry", false), nil, "Entries", false, RpcLengthLimits.ClientRankingTopResult_Entries, nil)
	Base.WritePrimitive(writer, val.NextCycleTime, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.TotalCount, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.MyZoneId, writer.WriteUInt32, 0)
end

function Auto.WriteClientStaticNpcInitData(writer, val)
	Base.WritePrimitive(writer, val.StaticNpcInfoId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.NpcFormworkId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.AgentPersonaId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.SPoiActionId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.CPoiActionId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.UrbanDiversityId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.IgnoreAllStim, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.TaskRelated, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.EnableHack, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.NpcPid, writer.WriteInt32, 0)
	Base.WriteComplex(writer, val.AgentSyncClientInfo, Auto.WriteAgentSyncClientInfo, "AgentSyncClientInfo", true)
	Base.WritePrimitive(writer, val.LookAtDecisionRulesId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.ForceGo, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, Base.CheckEnum(val.SourceType, 133, 0), writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.Id, writer.WriteUInt64, 0)
	Base.WriteStruct(writer, val.Position, Auto.WriteUXVector3, "Position")
	Base.WritePrimitive(writer, val.Facing, writer.WriteSingle, 0)
	Base.WriteStruct(writer, val.EulerAngles, Auto.WriteUXVector3, "EulerAngles")
end

function Auto.WriteClientStaticVehicleDebugData(writer, val)
	Base.WritePrimitive(writer, val.Id, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, Base.CheckEnum(val.SourceType, 134, 1), writer.WriteByte, 1)
	Base.WritePrimitive(writer, val.VehicleConfigId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.ColorConfigId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.IsResident, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.ForceShow, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.SpawnNpc, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.VehicleSpoonId, writer.WriteInt32, 0)
	Base.WriteList7Bit(writer, val.FineIdList, writer.WriteUInt32, 0, "FineIdList", false, 0, nil)
	Base.WritePrimitive(writer, val.GridIndexX, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.GridIndexY, writer.WriteInt32, 0)
end

function Auto.WriteClientStaticVehicleInitData(writer, val)
	Base.WritePrimitive(writer, val.VehicleConfigId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.ColorConfigId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.DamageStatusId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.Timestamp, writer.WriteDouble, 0)
	Base.WritePrimitive(writer, val.NotDrive, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.RotationX, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.RotationY, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.RotationZ, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.RotationW, writer.WriteSingle, 0)
	Base.WriteList7Bit(writer, val.Parts, Base.WriteStructWrap(Auto.WriteVehicleClientPart, "Parts"), nil, "Parts", true, 0, nil)
	Base.WritePrimitive(writer, val.SuitId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.DustRatio, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.Id, writer.WriteUInt64, 0)
	Base.WriteStruct(writer, val.Position, Auto.WriteUXVector3, "Position")
	Base.WritePrimitive(writer, val.Facing, writer.WriteSingle, 0)
	Base.WriteStruct(writer, val.EulerAngles, Auto.WriteUXVector3, "EulerAngles")
end

function Auto.WriteClientSubRankSlot(writer, val)
	Base.WritePrimitive(writer, Base.CheckEnum(val.Dim, 135, 0), writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.Value, writer.WriteUInt32, 0)
end

function Auto.WriteClientTeamInfo(writer, val)
	Base.WritePrimitive(writer, val.TeamId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.LeaderPid, writer.WriteUInt64, 0)
	Base.WriteList7Bit(writer, val.Members, Base.WriteComplexWrap(Auto.WritePlayerBasicInfoVO, "PlayerBasicInfoVO", false), nil, "Members", false, 0, nil)
	Base.WriteComplex(writer, val.Setting, Auto.WriteTeamSetting, "Setting", false)
	Base.WriteList7Bit(writer, val.MemberOrder, writer.WriteUInt64, 0, "MemberOrder", false, 0, nil)
end

function Auto.WriteClientTeamMemberSyncInfo(writer, val)
	Base.WritePrimitive(writer, val.MemberOrder, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.VehicleTemplateId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.SeatIndex, writer.WriteInt32, 0)
	Base.WriteComplex(writer, val.PlayerBasicInfo, Auto.WritePlayerBasicInfoVO, "PlayerBasicInfo", true)
	Base.WritePrimitive(writer, val.SpiritId, writer.WriteUInt32, 0)
	Base.WriteComplex(writer, val.SpiritWearFashionInfo, Auto.WriteOtherPlayerSpiritWearFashionsInfo, "SpiritWearFashionInfo", true)
	Base.WriteComplex(writer, val.LinkPlanningBoardMemberInfo, Auto.WriteLinkPlanningBoardMemberInfo, "LinkPlanningBoardMemberInfo", true)
	Base.WritePrimitive(writer, val.InMatchGame, writer.WriteBoolean, false)
	Base.WriteComplex(writer, val.TrackGPS, Auto.WriteTeamTrackGPS, "TrackGPS", true)
end

function Auto.WriteClientTierDetailInfo(writer, val)
	Base.WritePrimitive(writer, val.TierConfigId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.CurrentBigTierId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.CurrentSmallTierId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.Score, writer.WriteUInt32, 0)
end

function Auto.WriteClientTrafficIntersectionInitInfo(writer, val)
	Base.WritePrimitive(writer, val.InstanceId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.ZoneIndex, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, Base.CheckEnum(val.CurrentState, 132, 0), writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.CurrentPeriodIndex, writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.NextPeriodIndex, writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.RailPeriodIndex, writer.WriteByte, 0)
end

function Auto.WriteClientTrafficIntersectionPeriodUpdateInfo(writer, val)
	Base.WritePrimitive(writer, val.IntersectionIndex, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, Base.CheckEnum(val.CurrentState, 132, 0), writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.CurrentPeriodIndex, writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.NextPeriodIndex, writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.RailPeriodIndex, writer.WriteByte, 0)
end

function Auto.WriteClientTruckOrderView(writer, val)
	Base.WriteList7Bit(writer, val.Orders, Base.WriteComplexWrap(Auto.WriteTruckJobOrderWrap, "TruckJobOrderWrap", false), nil, "Orders", false, 0, nil)
	Base.WritePrimitive(writer, val.RewardPointSum, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.CustomerSatisfactionAverage, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.CurrentOrderId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.TruckGuideClicked, writer.WriteBoolean, false)
	Base.WriteDict7Bit(writer, val.EventIdToAgent, writer.WriteUInt32, writer.WriteUInt64, 0, "EventIdToAgent", false, 0)
	Base.WritePrimitive(writer, val.AutoAccept, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.DefaultVehicleId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.TotalIncome, writer.WriteInt32, 0)
end

function Auto.WriteClientTuiteComment(writer, val)
	Base.WritePrimitive(writer, val.Id, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.CfgId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.PublishTime, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.IsCollect, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.IsLike, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.LikeCount, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.ViewCount, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.CommentCount, writer.WriteInt32, 0)
	writer:WriteString(val.Content, true, "ClientTuiteComment.Content", 0)
	Base.WriteStruct(writer, val.RoleInfo, Auto.WriteClientTuiteRoleInfo, "RoleInfo")
end

function Auto.WriteClientTuiteInfo(writer, val)
	Base.WritePrimitive(writer, val.CfgId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.PublishTime, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.IsCollect, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.IsLike, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.IsFollow, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.HasTimeline, writer.WriteBoolean, false)
	Base.WriteComplex(writer, val.TimelineData, Auto.WriteTuiteTimelineData, "TimelineData", true)
	Base.WritePrimitive(writer, val.LikeCount, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.ViewCount, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.CommentCount, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.DropId, writer.WriteUInt32, 0)
	writer:WriteString(val.OssKey, true, "ClientTuiteInfo.OssKey", 0)
end

function Auto.WriteClientTuiteRoleInfo(writer, val)
	Base.WritePrimitive(writer, val.Pid, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.ShortPid, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.RoleId, writer.WriteUInt32, 0)
	writer:WriteString(val.Name, true, "ClientTuiteRoleInfo.Name", 0)
	Base.WritePrimitive(writer, val.AvatarId, writer.WriteUInt32, 0)
end

function Auto.WriteClientVehicleBuffData(writer, val)
	Base.WritePrimitive(writer, val.InstanceId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.BuffConfigId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.EffectChangeEndTime, writer.WriteDouble, 0)
	Base.WritePrimitive(writer, val.ExpireTime, writer.WriteDouble, 0)
end

function Auto.WriteClientVehicleData(writer, val)
	Base.WritePrimitive(writer, val.Id, writer.WriteInt32, 0)
	Base.WriteStruct(writer, val.Position, Auto.WriteUXVector3, "Position")
	Base.WritePrimitive(writer, val.ActionId, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.LaneHandle, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.DistanceAlongLane, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.NextLaneHandle, writer.WriteInt32, 0)
end

function Auto.WriteClientVehicleDebugData(writer, val)
	Base.WritePrimitive(writer, val.Id, writer.WriteUInt64, 0)
	writer:WriteString(val.VehicleLogicType, false, "ClientVehicleDebugData.VehicleLogicType", 0)
	writer:WriteString(val.CurrentVehicleStatus, false, "ClientVehicleDebugData.CurrentVehicleStatus", 0)
	Base.WritePrimitive(writer, val.CurrentLaneHandle, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.NextLaneHandle, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.DistanceToAvoid, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.NextVehicleId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.NextMergingVehicleId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.NextSplittingVehicleId, writer.WriteUInt64, 0)
	Base.WriteList7Bit(writer, val.FindIdList, writer.WriteUInt32, 0, "FindIdList", false, 0, nil)
end

function Auto.WriteClientVehicleInitData(writer, val)
	Base.WritePrimitive(writer, val.VehicleConfigId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.VehicleColorId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.VehicleLightState, writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.LaneHandle, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.DistanceAlongLane, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.NextVehicleId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.Timestamp, writer.WriteDouble, 0)
	Base.WritePrimitive(writer, Base.CheckEnum(val.ControlType, 136, 0), writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.Speed, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.DustRatio, writer.WriteSingle, 0)
	Base.WriteList7Bit(writer, val.Parts, Base.WriteStructWrap(Auto.WriteVehicleClientPart, "Parts"), nil, "Parts", true, 0, nil)
	Base.WritePrimitive(writer, val.SuitId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.Id, writer.WriteUInt64, 0)
	Base.WriteStruct(writer, val.Position, Auto.WriteUXVector3, "Position")
	Base.WritePrimitive(writer, val.Facing, writer.WriteSingle, 0)
	Base.WriteStruct(writer, val.EulerAngles, Auto.WriteUXVector3, "EulerAngles")
end

function Auto.WriteClientVehicleLaneChangeData(writer, val)
	Base.WriteStruct(writer, val.VehicleLaneData, Auto.WriteClientVehicleLaneData, "VehicleLaneData")
	Base.WritePrimitive(writer, val.LaneHandleInitial, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.LaneHandleFinal, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.BeginDistanceAloneLaneInitial, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.BeginDistanceAloneLaneFinal, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.EndDistanceAlongLaneFinal, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.DistanceBetweenLanes, writer.WriteSingle, 0)
end

function Auto.WriteClientVehicleLaneData(writer, val)
	Base.WritePrimitive(writer, val.Id, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.LaneHandle, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.DistanceAlongLane, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.Status, writer.WriteByte, 0)
end

function Auto.WriteClientVehicleLaneDebugData(writer, val)
	Base.WritePrimitive(writer, val.LaneHandle, writer.WriteInt32, 0)
	Base.WriteStruct(writer, val.Position, Auto.WriteUXVector3, "Position")
	Base.WritePrimitive(writer, val.LaneLength, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.SpaceAvailable, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.NumVehicleOnLane, writer.WriteInt32, 0)
end

function Auto.WriteClientVehicleNpcInitData(writer, val)
	Base.WritePrimitive(writer, val.Id, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.NpcFormworkId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.BindVehicleId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.SeatIndex, writer.WriteByte, 0)
end

function Auto.WriteClientVehiclePartStatus(writer, val)
	Base.WritePrimitive(writer, Base.CheckEnum(val.PartType, 77, 1), writer.WriteByte, 1)
	Base.WritePrimitive(writer, val.OpenOrClose, writer.WriteBoolean, false)
end

function Auto.WriteClientZoneGraphPathPoint(writer, val)
	Base.WriteStruct(writer, val.Position, Auto.WriteUXVector3, "Position")
	Base.WriteStruct(writer, val.Facing, Auto.WriteByteAngle, "Facing")
end

function Auto.WriteCloseVehicleDoorCommandData(writer, val)
	Base.WritePrimitive(writer, val.VehicleId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.SeatIndex, writer.WriteByte, 0)
	Base.WriteList7Bit(writer, val.Distances, Base.WriteStructWrap(Auto.WriteRangeMoveType, "Distances"), nil, "Distances", false, 0, nil)
	Base.WritePrimitive(writer, Base.CheckEnum(val.DataSource, 97, 0), writer.WriteInt16, 0)
end

function Auto.WriteClubInfo(writer, val)
	Base.WritePrimitive(writer, val.Id, writer.WriteUInt64, 0)
	writer:WriteString(val.Name, true, "ClubInfo.Name", 0)
	Base.WritePrimitive(writer, val.IconCfgId, writer.WriteUInt32, 0)
	writer:WriteString(val.Declaration, true, "ClubInfo.Declaration", 0)
	Base.WritePrimitive(writer, val.Activity, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.Owner, writer.WriteUInt64, 0)
	Base.WriteList7Bit(writer, val.Members, Base.WriteComplexWrap(Auto.WriteClubMember, "ClubMember", false), nil, "Members", false, 0, nil)
	Base.WriteComplex(writer, val.Setting, Auto.WriteClubSetting, "Setting", false)
	Base.WriteList7Bit(writer, val.WeeklyContributionList, Base.WriteComplexWrap(Auto.WriteClubWeeklyContribution, "ClubWeeklyContribution", false), nil, "WeeklyContributionList", false, 0, nil)
	Base.WriteList7Bit(writer, val.SeasonalContributionList, Base.WriteComplexWrap(Auto.WriteClubSeasonalContribution, "ClubSeasonalContribution", false), nil, "SeasonalContributionList", false, 0, nil)
end

function Auto.WriteClubMember(writer, val)
	Base.WritePrimitive(writer, val.Pid, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.LastLoginTime, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.LastLogoutTime, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, Base.CheckEnum(val.ClubJob, 23, 0), writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.JoinTime, writer.WriteUInt32, 0)
end

function Auto.WriteClubMemberContribution(writer, val)
	Base.WritePrimitive(writer, val.Activity, writer.WriteUInt32, 0)
	Base.WriteDict7Bit(writer, val.TaskDict, writer.WriteUInt32, Base.WriteComplexWrap(Auto.WriteClubTaskInfo, "ClubTaskInfo", false), nil, "TaskDict", false, 0)
	Base.WriteList7Bit(writer, val.RewardGotIds, writer.WriteUInt32, 0, "RewardGotIds", false, 0, nil)
end

function Auto.WriteClubSeasonalContribution(writer, val)
	Base.WritePrimitive(writer, val.StartTime, writer.WriteUInt32, 0)
	Base.WriteDict7Bit(writer, val.MemberContributions, writer.WriteUInt64, writer.WriteInt32, 0, "MemberContributions", false, 0)
end

function Auto.WriteClubSetting(writer, val)
	Base.WritePrimitive(writer, val.AutoJoin, writer.WriteBoolean, false)
end

function Auto.WriteClubTaskInfo(writer, val)
	Base.WritePrimitive(writer, val.TaskId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.Count, writer.WriteUInt32, 0)
end

function Auto.WriteClubWeeklyContribution(writer, val)
	Base.WritePrimitive(writer, val.StartTime, writer.WriteUInt32, 0)
	Base.WriteDict7Bit(writer, val.MemberContributions, writer.WriteUInt64, Base.WriteComplexWrap(Auto.WriteClubMemberContribution, "ClubMemberContribution", false), nil, "MemberContributions", false, 0)
	Base.WritePrimitive(writer, val.SettledTime, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.WeeklyActivity, writer.WriteUInt32, 0)
end

function Auto.WriteCommonActivityInfo(writer, val)
	Base.WritePrimitive(writer, val.CfgId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.StartTime, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.EndTime, writer.WriteUInt32, 0)
end

function Auto.WriteCommonCommandData(writer, val)
	Base.WritePrimitive(writer, Base.CheckEnum(val.DataSource, 97, 0), writer.WriteInt16, 0)
end

function Auto.WriteCommonCompetitionSeasonInfo(writer, val)
	Base.WritePrimitive(writer, val.CfgId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.StartTime, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.EndTime, writer.WriteUInt32, 0)
end

function Auto.WriteCompetitionSeasonChallengeInfo(writer, val)
	Base.WritePrimitive(writer, val.ChallengeCfgId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.HistoryHighestStars, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.LastStars, writer.WriteInt32, 0)
end

function Auto.WriteCompetitionSeasonGamePlayInfo(writer, val)
	Base.WritePrimitive(writer, val.GamePlayCfgId, writer.WriteUInt32, 0)
	Base.WriteDict(writer, val.ChallengeDict, writer.WriteUInt32, Base.WriteComplexWrap(Auto.WriteCompetitionSeasonChallengeInfo, "CompetitionSeasonChallengeInfo", false), nil, "ChallengeDict", false, 0)
	Base.WritePrimitive(writer, val.Stars, writer.WriteInt32, 0)
end

function Auto.WriteCompetitionSeasonInfo(writer, val)
	Base.WritePrimitive(writer, val.CfgId, writer.WriteUInt32, 0)
	Base.WriteDict(writer, val.GameplayDict, writer.WriteUInt32, Base.WriteComplexWrap(Auto.WriteCompetitionSeasonGamePlayInfo, "CompetitionSeasonGamePlayInfo", false), nil, "GameplayDict", false, 0)
	Base.WriteList(writer, val.AwardList, writer.WriteUInt32, 0, "AwardList", false, 0, nil)
	Base.WritePrimitive(writer, val.IsFinish, writer.WriteBoolean, false)
end

function Auto.WriteCompoundResultInfo(writer, val)
	Base.WritePrimitive(writer, val.CompoundId, writer.WriteUInt32, 0)
	Base.WriteComplex(writer, val.Rewards, Auto.WriteRewardInfo, "Rewards", false)
	Base.WritePrimitive(writer, val.RemainingCount, writer.WriteInt32, 0)
end

function Auto.WriteCompoundStationClientInfo(writer, val)
	Base.WritePrimitive(writer, val.Level, writer.WriteUInt32, 0)
end

function Auto.WriteCompoundUseClientInfo(writer, val)
	Base.WritePrimitive(writer, val.UsedCount, writer.WriteUInt32, 0)
end

function Auto.WriteComputerDetailInfo(writer, val)
	Base.WritePrimitive(writer, val.CfgId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.FirstOpenTime, writer.WriteUInt32, 0)
	Base.WriteList(writer, val.DeleteFiles, writer.WriteUInt32, 0, "DeleteFiles", false, 0, nil)
	Base.WriteList(writer, val.DeleteEmails, writer.WriteUInt32, 0, "DeleteEmails", false, 0, nil)
end

function Auto.WriteComputerEmail(writer, val)
	Base.WritePrimitive(writer, val.CfgId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.IsRead, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.UnlockTime, writer.WriteUInt32, 0)
end

function Auto.WriteComputerFile(writer, val)
	Base.WritePrimitive(writer, val.CfgId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.UnlockTime, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.IsRead, writer.WriteBoolean, false)
end

function Auto.WriteComputerUnlockInfo(writer, val)
	Base.WriteDict7Bit(writer, val.UnlockEmails, writer.WriteUInt32, Base.WriteComplexWrap(Auto.WriteComputerEmail, "ComputerEmail", false), nil, "UnlockEmails", true, 0)
	Base.WriteDict7Bit(writer, val.UnlockFiles, writer.WriteUInt32, Base.WriteComplexWrap(Auto.WriteComputerFile, "ComputerFile", false), nil, "UnlockFiles", true, 0)
	Base.WriteDict7Bit(writer, val.ComputerInfos, writer.WriteUInt32, Base.WriteComplexWrap(Auto.WriteComputerDetailInfo, "ComputerDetailInfo", false), nil, "ComputerInfos", true, 0)
end

function Auto.WriteConfirmRpcCommand(writer, val)
	Base.WritePrimitive(writer, val.ConfirmRpcId, writer.WriteInt64, 0)
	Base.WritePrimitive(writer, val.RpcId, writer.WriteInt64, 0)
	Base.WritePrimitive(writer, val.HasRpcId, writer.WriteBoolean, false)
end

function Auto.WriteConfirmRpcServerCommand(writer, val)
	Base.WritePrimitive(writer, val.ConfirmRpcId, writer.WriteInt64, 0)
	Base.WritePrimitive(writer, val.RpcId, writer.WriteInt64, 0)
	Base.WritePrimitive(writer, val.HasRpcId, writer.WriteBoolean, false)
end

function Auto.WriteControlFlowData(writer, val)
	Base.WritePrimitive(writer, val.PortId, writer.WriteInt32, 0)
end

function Auto.WriteControlFlowDataBoolean(writer, val)
	Base.WritePrimitive(writer, val.V, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.PortId, writer.WriteInt32, 0)
end

function Auto.WriteControlFlowDataCustom(writer, val)
	Base.WriteComplex(writer, val.V, Auto.WriteControlFlowData, "V", false)
	Base.WritePrimitive(writer, Base.CheckEnum(val.Type, 137, 0), writer.WriteByte, 0)
end

function Auto.WriteControlFlowDataDebug(writer, val)
	Base.WritePrimitive(writer, val.Index, writer.WriteInt32, 0)
	Base.WriteList7Bit(writer, val.CurrentNodeIds, writer.WriteInt32, 0, "CurrentNodeIds", false, 0, nil)
	Base.WriteList7Bit(writer, val.CompleteNodeIds, writer.WriteInt32, 0, "CompleteNodeIds", false, 0, nil)
	Base.WriteDict7Bit(writer, val.ErrorNodeIds, writer.WriteInt32, Base.WriteStringWrap(false, "ErrorNodeIds", 0), nil, "ErrorNodeIds", false, 0)
	Base.WriteDict7Bit(writer, val.ResultNodeIds, writer.WriteInt32, Base.WriteStringWrap(false, "ResultNodeIds", 0), nil, "ResultNodeIds", false, 0)
end

function Auto.WriteControlFlowDataDouble(writer, val)
	Base.WritePrimitive(writer, val.V, writer.WriteDouble, 0)
	Base.WritePrimitive(writer, val.PortId, writer.WriteInt32, 0)
end

function Auto.WriteControlFlowDataFloat(writer, val)
	Base.WritePrimitive(writer, val.V, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.PortId, writer.WriteInt32, 0)
end

function Auto.WriteControlFlowDataInteger(writer, val)
	Base.WritePrimitive(writer, val.V, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.PortId, writer.WriteInt32, 0)
end

function Auto.WriteControlFlowDataString(writer, val)
	writer:WriteString(val.V, false, "ControlFlowDataString.V", RpcLengthLimits.ControlFlowDataString_V)
	Base.WritePrimitive(writer, val.PortId, writer.WriteInt32, 0)
end

function Auto.WriteControlFlowDataUInteger(writer, val)
	Base.WritePrimitive(writer, val.V, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.PortId, writer.WriteInt32, 0)
end

function Auto.WriteControlFlowDataUlong(writer, val)
	Base.WritePrimitive(writer, val.V, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.PortId, writer.WriteInt32, 0)
end

function Auto.WriteControlFlowDataUnit(writer, val)
	Base.WritePrimitive(writer, val.V, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.PortId, writer.WriteInt32, 0)
end

function Auto.WriteControlFlowDataVector(writer, val)
	Base.WriteStruct(writer, val.V, Auto.WriteUXVector3, "V")
	Base.WritePrimitive(writer, val.PortId, writer.WriteInt32, 0)
end

function Auto.WriteControlFlowDataVehicle(writer, val)
	Base.WritePrimitive(writer, val.V, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.PortId, writer.WriteInt32, 0)
end

function Auto.WriteControlFlowDebugSpoonData(writer, val)
	Base.WritePrimitive(writer, Base.CheckEnum(val.SpoonType, 138, 0), writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.taskId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.eventId, writer.WriteUInt32, 0)
	Base.WriteList7Bit(writer, val.raidMd5, Base.WriteStringWrap(false, "raidMd5", 0), nil, "raidMd5", false, 0, nil)
	writer:WriteString(val.md5, true, "ControlFlowDebugSpoonData.md5", 0)
	writer:WriteString(val.eventMd5, true, "ControlFlowDebugSpoonData.eventMd5", 0)
	Base.WritePrimitive(writer, val.plateUId, writer.WriteUInt64, 0)
end

function Auto.WriteControlFlowDestructible(writer, val)
	Base.WritePrimitive(writer, val.V, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.PortId, writer.WriteInt32, 0)
end

function Auto.WriteCreateClientNodeServerCommand(writer, val)
	Base.WritePrimitive(writer, val.Nid, writer.WriteUInt32, 0)
	writer:WriteString(val.Type, false, "CreateClientNodeServerCommand.Type", 0)
	Base.WritePrimitive(writer, val.Sync, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.RpcId, writer.WriteInt64, 0)
	Base.WritePrimitive(writer, val.HasRpcId, writer.WriteBoolean, false)
end

function Auto.WriteCreateRoleInitInfo(writer, val)
	Base.WritePrimitive(writer, Base.CheckEnum(val.Sex, 139, 0), writer.WriteByte, 0)
	writer:WriteString(val.Name, false, "CreateRoleInitInfo.Name", RpcLengthLimits.CreateRoleInitInfo_Name)
	Base.WriteList7Bit(writer, val.Config, writer.WriteByte, 0, "Config", false, RpcLengthLimits.CreateRoleInitInfo_Config, nil)
	Base.WritePrimitive(writer, val.UseSystemName, writer.WriteBoolean, false)
end

function Auto.WriteCreationEnterLeave(writer, val)
	Base.WritePrimitive(writer, val.TargetId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.CreationId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, Base.CheckEnum(val.EventType, 140, 0), writer.WriteByte, 0)
end

function Auto.WriteCreationHitData(writer, val)
	Base.WritePrimitive(writer, val.CreationId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.TargetId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.TargetDestructible, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.ShieldDefendIndex, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.HurtStiffId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.StiffTime, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.HurtEffectId, writer.WriteUInt32, 0)
end

function Auto.WriteCreationMoveData(writer, val)
	Base.WritePrimitive(writer, val.CreationId, writer.WriteUInt64, 0)
	Base.WriteStruct(writer, val.Position, Auto.WriteUXVector3, "Position")
	Base.WriteStruct(writer, val.Rotation, Auto.WriteUXVector3, "Rotation")
end

function Auto.WriteCreditInfo(writer, val)
	Base.WritePrimitive(writer, val.Credit, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.Level, writer.WriteUInt32, 0)
	Base.WriteDict(writer, val.ClaimedLevelRewards, writer.WriteUInt32, writer.WriteBoolean, false, "ClaimedLevelRewards", false, 0)
end

function Auto.WriteCruiseParameters(writer, val)
	Base.WriteList7Bit(writer, val.TargetPointList, Base.WriteStructWrap(Auto.WriteUXVector3, "TargetPointList"), nil, "TargetPointList", false, 0, nil)
	Base.WritePrimitive(writer, Base.CheckEnum(val.CruiseType, 94, 0), writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.Count, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.configFlags, writer.WriteByte, 1)
	Base.WritePrimitive(writer, val.pathFindFlags, writer.WriteByte, 0)
	Base.WritePrimitive(writer, Base.CheckEnum(val.TargetType, 92, 0), writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.TargetUid, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.checkClose, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.checkFar, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.closeRange, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.farawayRange, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.accelerateScale, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.decelerateScale, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.minSpeed, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.maxSpeed, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.ArrivalDistance, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.AdaptSpeedToTargetDistance, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.Token, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.taskAIConfigId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.defaultSpeed, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.drivingFlags, writer.WriteInt32, 1)
	Base.WritePrimitive(writer, val.initSpeed, writer.WriteSingle, 0)
	Base.WriteList7Bit(writer, val.initTaskAIBuffList, Base.WriteStructWrap(Auto.WriteTaskVehicleBuffInitInfo, "initTaskAIBuffList"), nil, "initTaskAIBuffList", true, 0, nil)
	Base.WriteStruct(writer, val.commonParameters, Auto.WriteVehicleAICommonParameters, "commonParameters")
end

function Auto.WriteCubeAreaInfo(writer, val)
	Base.WriteStruct(writer, val.CenterPos, Auto.WriteUXVector3, "CenterPos")
	Base.WritePrimitive(writer, val.XMagnitude, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.ZMagnitude, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.YSize, writer.WriteSingle, 0)
	Base.WriteStruct(writer, val.XNormalized, Auto.WriteUXVector3, "XNormalized")
	Base.WriteStruct(writer, val.ZNormalized, Auto.WriteUXVector3, "ZNormalized")
end

function Auto.WriteCubeCoord(writer, val)
	Base.WritePrimitive(writer, val.q, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.r, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.s, writer.WriteInt32, 0)
end

function Auto.WriteCustomCommonData(writer, val)
	Base.WritePrimitive(writer, val.Type, writer.WriteInt32, 0)
	writer:WriteString(val.StringData, false, "CustomCommonData.StringData", RpcLengthLimits.CustomCommonData_StringData)
	Base.WriteBuffer(writer, val.BinaryData, "BinaryData", false, RpcLengthLimits.CustomCommonData_BinaryData, nil)
end

function Auto.WriteCustomRoomCreateParam(writer, val)
	writer:WriteString(val.Name, false, "CustomRoomCreateParam.Name", RpcLengthLimits.CustomRoomCreateParam_Name)
	Base.WritePrimitive(writer, Base.CheckEnum(val.Type, 130, 1), writer.WriteByte, 1)
	writer:WriteString(val.Password, true, "CustomRoomCreateParam.Password", RpcLengthLimits.CustomRoomCreateParam_Password)
	Base.WritePrimitive(writer, val.MaxMembers, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.OwnerLeaveDisband, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.FriendOnly, writer.WriteBoolean, false)
	Base.WriteComplex(writer, val.PartyInfo, Auto.WritePartySettingInfo, "PartyInfo", true)
end

function Auto.WriteCustomRoomSearchParam(writer, val)
	Base.WritePrimitive(writer, Base.CheckEnum(val.Type, 130, 1), writer.WriteByte, 1)
	Base.WriteDict7Bit(writer, val.TagFilters, writer.WriteInt16, writer.WriteUInt32, 0, "TagFilters", false, RpcLengthLimits.CustomRoomSearchParam_TagFilters)
	Base.WritePrimitive(writer, val.Page, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.PageSize, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.RequestAll, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.FriendOnly, writer.WriteBoolean, false)
end

function Auto.WriteCustomRoomSettingParam(writer, val)
	writer:WriteString(val.Name, true, "CustomRoomSettingParam.Name", RpcLengthLimits.CustomRoomSettingParam_Name)
	writer:WriteString(val.Password, true, "CustomRoomSettingParam.Password", RpcLengthLimits.CustomRoomSettingParam_Password)
	Base.WriteComplex(writer, val.PartySetting, Auto.WritePartyRoomSettingParam, "PartySetting", true)
end

function Auto.WriteDSBuffData(writer, val)
	Base.WritePrimitive(writer, val.BuffId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.StartTime, writer.WriteDouble, 0)
	Base.WritePrimitive(writer, val.EndTime, writer.WriteDouble, 0)
end

function Auto.WriteDSDamageData(writer, val)
	Base.WriteList7Bit(writer, val.SpiritDatas, Base.WriteComplexWrap(Auto.WriteDSSpiritDamageData, "DSSpiritDamageData", false), nil, "SpiritDatas", false, 0, nil)
	Base.WriteList7Bit(writer, val.ElementDatas, Base.WriteComplexWrap(Auto.WriteDSElementDamageData, "DSElementDamageData", false), nil, "ElementDatas", false, 0, nil)
end

function Auto.WriteDSElementDamageData(writer, val)
	Base.WritePrimitive(writer, val.ElementId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.StartTime, writer.WriteDouble, 0)
	Base.WritePrimitive(writer, val.EndTime, writer.WriteDouble, 0)
	Base.WritePrimitive(writer, val.Damage, writer.WriteSingle, 0)
end

function Auto.WriteDSSkillHitDamageData(writer, val)
	Base.WritePrimitive(writer, val.HitTime, writer.WriteDouble, 0)
	Base.WritePrimitive(writer, val.SkillId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.SpiritId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.TriggerIndex, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.Damage, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.IsCritical, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.Error, writer.WriteUInt32, 0)
	Base.WriteList7Bit(writer, val.Attrs, writer.WriteSingle, 0, "Attrs", false, 0, nil)
	Base.WriteList7Bit(writer, val.Buffs, writer.WriteUInt32, 0, "Buffs", false, 0, nil)
end

function Auto.WriteDSSkillHitDataList(writer, val)
	Base.WritePrimitive(writer, val.SKillId, writer.WriteUInt32, 0)
	Base.WriteList7Bit(writer, val.SkillDamageList, Base.WriteComplexWrap(Auto.WriteDSSkillHitDamageData, "DSSkillHitDamageData", false), nil, "SkillDamageList", false, 0, nil)
end

function Auto.WriteDSSpiritDamageData(writer, val)
	Base.WritePrimitive(writer, val.SpiritId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.TotalDamage, writer.WriteSingle, 0)
	Base.WriteDict7Bit(writer, val.SkillDamageRecords, writer.WriteInt32, Base.WriteComplexWrap(Auto.WriteDSSkillHitDataList, "DSSkillHitDataList", false), nil, "SkillDamageRecords", false, 0)
	Base.WriteDict7Bit(writer, val.BuffRecords, writer.WriteUInt32, Base.WriteComplexWrap(Auto.WriteDSBuffData, "DSBuffData", false), nil, "BuffRecords", false, 0)
end

function Auto.WriteDailyGamePlayRankData(writer, val)
	Base.WritePrimitive(writer, val.StartTime, writer.WriteUInt32, 0)
	Base.WriteDict7Bit(writer, val.GamePlayRankListDict, writer.WriteUInt32, Base.WriteComplexWrap(Auto.WriteInspireHubGamePlayRankList, "InspireHubGamePlayRankList", false), nil, "GamePlayRankListDict", false, 0)
end

function Auto.WriteDailyGamePlayRecommendData(writer, val)
	Base.WritePrimitive(writer, val.StartTime, writer.WriteUInt32, 0)
	Base.WriteList7Bit(writer, val.GamePlayList, Base.WriteComplexWrap(Auto.WriteInspireHubGamePlayInfo, "InspireHubGamePlayInfo", false), nil, "GamePlayList", false, 0, nil)
end

function Auto.WriteDailyHackerCounts(writer, val)
	Base.WritePrimitive(writer, val.Money, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.Fan, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.Tetris, writer.WriteInt32, 0)
end

function Auto.WriteDamageData(writer, val)
	Base.WritePrimitive(writer, val.SourceAmount, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, Base.CheckEnum(val.FromType, 141, 1), writer.WriteByte, 1)
	Base.WritePrimitive(writer, val.SourceTemplateId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.SkillId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.CreationId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.TriggerIndex, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.BuffId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.SpecialEffects, writer.WriteInt16, 0)
	Base.WriteStruct(writer, val.ClientHitPosition, Auto.WriteUXVector3, "ClientHitPosition")
	Base.WritePrimitive(writer, val.ElementType, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.HitIndex, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.PoiseBasicValue, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.HpDecreased, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.Amount, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.ShieldDecreased, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.ShieldIndex, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.ShieldId, writer.WriteUInt32, 0)
end

function Auto.WriteDancePlayResult(writer, val)
	Base.WritePrimitive(writer, val.StayElapsedTime, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.PlayElapsedTime, writer.WriteUInt32, 0)
end

function Auto.WriteDartParticipantInfo(writer, val)
	Base.WritePrimitive(writer, val.DartId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.Pid, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.NpcCultivationId, writer.WriteUInt32, 0)
	Base.WriteComplex(writer, val.AIAgentInfo, Auto.WriteLinkAIAgentInfo, "AIAgentInfo", true)
	Base.WritePrimitive(writer, val.AgentInstanceId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.VehicleInstanceId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.SeatIndex, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.IsReady, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.IsPlayAgain, writer.WriteBoolean, false)
end

function Auto.WriteDartScoreInfo(writer, val)
	Base.WritePrimitive(writer, val.CurrentRound, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.CurrentTurn, writer.WriteInt32, 0)
	Base.WriteDict7Bit(writer, val.ParticipantScoreDic, writer.WriteInt32, writer.WriteInt32, 0, "ParticipantScoreDic", true, 0)
	Base.WriteDict7Bit(writer, val.ParticipantRoundTotalScoreDic, writer.WriteInt32, writer.WriteInt32, 0, "ParticipantRoundTotalScoreDic", true, 0)
	Base.WritePrimitive(writer, val.CurrentTurnTotalScore, writer.WriteInt32, 0)
	Base.WriteList7Bit(writer, val.CurrentTurnTotalPos, Base.WriteStructWrap(Auto.WriteUXVector3, "CurrentTurnTotalPos"), nil, "CurrentTurnTotalPos", false, 0, nil)
	Base.WriteList7Bit(writer, val.CurrentTurnTotalScoreLs, writer.WriteInt32, 0, "CurrentTurnTotalScoreLs", false, 0, nil)
	Base.WritePrimitive(writer, val.CurrentScoreIndex, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.CurrentScore, writer.WriteInt32, 0)
	Base.WriteStruct(writer, val.CurrentScorePos, Auto.WriteUXVector3, "CurrentScorePos")
	Base.WritePrimitive(writer, val.Winner, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.IsPlayerLeave, writer.WriteBoolean, false)
end

function Auto.WriteDartSettleData(writer, val)
	Base.WritePrimitive(writer, val.Score, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.Rank, writer.WriteUInt32, 0)
end

function Auto.WriteDartZoneInfo(writer, val)
	Base.WritePrimitive(writer, Base.CheckEnum(val.GameType, 85, 0), writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.CurrentRound, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.CurrentTurn, writer.WriteInt32, 0)
	Base.WriteComplex(writer, val.ScoreInfo, Auto.WriteDartScoreInfo, "ScoreInfo", false)
	writer:WriteString(val.ZoneSessionId, false, "DartZoneInfo.ZoneSessionId", 0)
	Base.WritePrimitive(writer, val.GadgetUId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.TaskId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, Base.CheckEnum(val.StartReason, 106, 0), writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.GameTypeRandom, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, Base.CheckEnum(val.SyncReason, 107, 0), writer.WriteByte, 0)
	Base.WritePrimitive(writer, Base.CheckEnum(val.ZoneType, 108, 0), writer.WriteByte, 0)
	Base.WritePrimitive(writer, Base.CheckEnum(val.ZoneState, 109, 0), writer.WriteByte, 0)
	Base.WriteList7Bit(writer, val.ParticipantInfos, Base.WriteComplexWrap(Auto.WriteGameGroundParticipantInfo, "GameGroundParticipantInfo", true), nil, "ParticipantInfos", true, 0, nil)
	Base.WriteStruct(writer, val.CountDownInfo, Auto.WriteGameGroundZoneCountDownInfo, "CountDownInfo")
end

function Auto.WriteDataLayerIndic(writer, val)
	Base.WritePrimitive(writer, Base.CheckEnum(val.Mode, 142, 0), writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.SceneBaseIndic, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.UniverseBaseIndic, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.RaidBaseIndic, writer.WriteInt32, 0)
	Base.WriteList7Bit(writer, val.ResourceIndices, writer.WriteInt32, 0, "ResourceIndices", true, 0, nil)
end

function Auto.WriteDebugBattleElementData(writer, val)
	Base.WritePrimitive(writer, val.ElementId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.Damage, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.Count, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.DamageMin, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.DamageMax, writer.WriteSingle, 0)
end

function Auto.WriteDebugBattleSpiritData(writer, val)
	Base.WritePrimitive(writer, val.SpiritId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.TotalDamage, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.FightStateTime, writer.WriteDouble, 0)
	Base.WritePrimitive(writer, val.FightBeginTime, writer.WriteDouble, 0)
	Base.WritePrimitive(writer, val.ActiveTime, writer.WriteDouble, 0)
	Base.WritePrimitive(writer, val.ActiveBeginTime, writer.WriteDouble, 0)
	Base.WriteDict7Bit(writer, val.SkillDamages, writer.WriteUInt32, writer.WriteSingle, 0, "SkillDamages", false, 0)
	Base.WriteDict7Bit(writer, val.SkillCounts, writer.WriteUInt32, writer.WriteInt32, 0, "SkillCounts", false, 0)
	Base.WriteDict7Bit(writer, val.SkillDamageCounts, writer.WriteUInt32, writer.WriteInt32, 0, "SkillDamageCounts", false, 0)
	Base.WriteDict7Bit(writer, val.SkillDamagesMin, writer.WriteUInt32, writer.WriteSingle, 0, "SkillDamagesMin", false, 0)
	Base.WriteDict7Bit(writer, val.SkillDamagesMax, writer.WriteUInt32, writer.WriteSingle, 0, "SkillDamagesMax", false, 0)
	Base.WriteDict7Bit(writer, val.ExtraBuffDamages, writer.WriteUInt32, writer.WriteSingle, 0, "ExtraBuffDamages", false, 0)
	Base.WriteDict7Bit(writer, val.BuffTimes, writer.WriteUInt32, writer.WriteDouble, 0, "BuffTimes", false, 0)
	Base.WriteDict7Bit(writer, val.BuffBeginTimes, writer.WriteUInt32, writer.WriteDouble, 0, "BuffBeginTimes", false, 0)
	Base.WriteDict7Bit(writer, val.BuffRefCounts, writer.WriteUInt32, writer.WriteInt32, 0, "BuffRefCounts", false, 0)
end

function Auto.WriteDebugBattleStatistics(writer, val)
	Base.WritePrimitive(writer, val.Now, writer.WriteDouble, 0)
	Base.WriteList7Bit(writer, val.Spirits, Base.WriteComplexWrap(Auto.WriteDebugBattleSpiritData, "DebugBattleSpiritData", false), nil, "Spirits", false, 0, nil)
	Base.WriteList7Bit(writer, val.Elements, Base.WriteComplexWrap(Auto.WriteDebugBattleElementData, "DebugBattleElementData", false), nil, "Elements", false, 0, nil)
end

function Auto.WriteDebugFileDescription(writer, val)
	writer:WriteString(val.FullPath, true, "DebugFileDescription.FullPath", 0)
	writer:WriteString(val.Name, true, "DebugFileDescription.Name", 0)
	Base.WritePrimitive(writer, val.IsDirectory, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.Size, writer.WriteInt64, 0)
	Base.WritePrimitive(writer, val.CreateTime, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.WriteTime, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.AccessTime, writer.WriteUInt32, 0)
end

function Auto.WriteDebugFileResult(writer, val)
	Base.WriteComplex(writer, val.PersistentDataPath, Auto.WriteDebugFileDescription, "PersistentDataPath", false)
	Base.WriteComplex(writer, val.TemporaryCachePath, Auto.WriteDebugFileDescription, "TemporaryCachePath", false)
	Base.WriteComplex(writer, val.StreamingAssetsPath, Auto.WriteDebugFileDescription, "StreamingAssetsPath", false)
	Base.WriteComplex(writer, val.DataPath, Auto.WriteDebugFileDescription, "DataPath", false)
	Base.WriteComplex(writer, val.ConsoleLogPath, Auto.WriteDebugFileDescription, "ConsoleLogPath", false)
	Base.WriteComplex(writer, val.VirtualFileSystem, Auto.WriteDebugFileDescription, "VirtualFileSystem", false)
end

function Auto.WriteDebugNpcBvbSelectPokemonData(writer, val)
	Base.WritePrimitive(writer, val.TemplateId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.q, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.r, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.s, writer.WriteInt32, 0)
end

function Auto.WriteDeleteClientNodeCommand(writer, val)
	Base.WritePrimitive(writer, val.Nid, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.RpcId, writer.WriteInt64, 0)
	Base.WritePrimitive(writer, val.HasRpcId, writer.WriteBoolean, false)
end

function Auto.WriteDeliveryGadgetInfo(writer, val)
	Base.WritePrimitive(writer, val.PathId, writer.WriteInt32, 0)
	Base.WriteStruct(writer, val.Pos, Auto.WriteUXVector3, "Pos")
	Base.WriteStruct(writer, val.Rot, Auto.WriteUXVector3, "Rot")
end

function Auto.WriteDeriveCreationData(writer, val)
	Base.WritePrimitive(writer, val.CreationId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.DeriveId, writer.WriteUInt32, 0)
	Base.WriteStruct(writer, val.Position, Auto.WriteUXVector3, "Position")
	Base.WritePrimitive(writer, val.Facing, writer.WriteSingle, 0)
end

function Auto.WriteDestructibleBrokenInfo(writer, val)
	Base.WritePrimitive(writer, val.InstanceId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.Stage, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, Base.CheckEnum(val.BrokenType, 143, 0), writer.WriteByte, 0)
	Base.WriteStruct(writer, val.Position, Auto.WriteUXVector3, "Position")
	Base.WriteStruct(writer, val.Facing, Auto.WriteUXVector3, "Facing")
end

function Auto.WriteDestructibleGridAOIIncrease(writer, val)
	Base.WriteStruct(writer, val.PlayerStandardIndex, Auto.WriteGridIndex, "PlayerStandardIndex")
	Base.WriteList7Bit(writer, val.addInfos, Base.WriteComplexWrap(Auto.WriteDestructibleInfo, "DestructibleInfo", true), nil, "addInfos", true, 0, nil)
	Base.WriteList7Bit(writer, val.indexList, Base.WriteStructWrap(Auto.WriteGridIndex, "indexList"), nil, "indexList", true, 0, nil)
	Base.WriteList7Bit(writer, val.addUniqueIds, writer.WriteUInt64, 0, "addUniqueIds", true, 0, nil)
	Base.WriteList7Bit(writer, val.removeIds, writer.WriteUInt64, 0, "removeIds", true, 0, nil)
	Base.WritePrimitive(writer, Base.CheckEnum(val.reason, 144, 0), writer.WriteByte, 0)
end

function Auto.WriteDestructibleHitTypeList(writer, val)
	Base.WriteList7Bit(writer, val.HitTypes, writer.WriteByte, 0, "HitTypes", false, RpcLengthLimits.DestructibleHitTypeList_HitTypes, nil)
end

function Auto.WriteDestructibleInfo(writer, val)
	Base.WritePrimitive(writer, val.InstanceId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.UniqueId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.CfgId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.PathId, writer.WriteInt32, 0)
	Base.WriteStruct(writer, val.Position, Auto.WriteUXVector3, "Position")
	Base.WriteStruct(writer, val.Facing, Auto.WriteUXVector3, "Facing")
	Base.WritePrimitive(writer, val.iScale, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.NavId, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.ForceLod0, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.BindPid, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.Hp, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, Base.CheckEnum(val.State, 145, 0), writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.BreakStage, writer.WriteUInt32, 0)
	Base.WriteList7Bit(writer, val.OccupantInfos, Base.WriteStructWrap(Auto.WriteSceneDeviceOccupantInfo, "OccupantInfos"), nil, "OccupantInfos", true, 0, nil)
	Base.WritePrimitive(writer, val.DropWeaponId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.StackCount, writer.WriteInt32, 0)
	Base.WriteList7Bit(writer, val.EffectIds, writer.WriteInt32, 0, "EffectIds", true, 0, nil)
	Base.WritePrimitive(writer, val.NoSleep, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.ReleaserId, writer.WriteUInt64, 0)
	Base.WriteComplex(writer, val.SkillInfo, Auto.WriteSkillDestructibleInfo, "SkillInfo", true)
end

function Auto.WriteDestructibleSyncBinInfo(writer, val)
	Base.WritePrimitive(writer, val.Id, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.HostPlayerID, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.LocalTime, writer.WriteUInt32, 0)
	Base.WriteList7Bit(writer, val.CompressSceneItemData, writer.WriteByte, 0, "CompressSceneItemData", true, RpcLengthLimits.DestructibleSyncBinInfo_CompressSceneItemData, val.CompressSceneItemDataLength)
end

function Auto.WriteDestructionBindCommandData(writer, val)
	Base.WritePrimitive(writer, val.SceneItemInstanceId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, Base.CheckEnum(val.MovementMethod, 104, 0), writer.WriteByte, 0)
	Base.WritePrimitive(writer, Base.CheckEnum(val.DataSource, 97, 0), writer.WriteInt16, 0)
end

function Auto.WriteDestructionUnBindCommandData(writer, val)
	Base.WritePrimitive(writer, Base.CheckEnum(val.DataSource, 97, 0), writer.WriteInt16, 0)
end

function Auto.WriteDialogAreaInfo(writer, val)
	Base.WriteList7Bit(writer, val.VertexPoints, Base.WriteStructWrap(Auto.WriteUXVector3, "VertexPoints"), nil, "VertexPoints", true, 0, nil)
	Base.WriteStruct(writer, val.CenterPos, Auto.WriteUXVector3, "CenterPos")
	Base.WritePrimitive(writer, val.SphereRadius, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.XMagnitude, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.YMagnitude, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.ZMagnitude, writer.WriteSingle, 0)
end

function Auto.WriteDialogParameter(writer, val)
	Base.WritePrimitive(writer, Base.CheckEnum(val.Reason, 146, 0), writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.NpcTemplateId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.NpcInstanceId, writer.WriteUInt64, 0)
	Base.WriteStruct(writer, val.AgentPosition, Auto.WriteUXVector3, "AgentPosition")
	Base.WritePrimitive(writer, val.BlackContinue, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.FromTaskId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.FromEventId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.FromClient, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.DialogCameraSpawnId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.SpoonNodeId, writer.WriteInt32, 0)
	Base.WriteDict7Bit(writer, val.Speaker2NpcInstanceId, Base.WriteStringWrap(false, "Speaker2NpcInstanceId", RpcLengthLimits.DialogParameter_Speaker2NpcInstanceId_String), writer.WriteUInt64, 0, "Speaker2NpcInstanceId", false, RpcLengthLimits.DialogParameter_Speaker2NpcInstanceId)
	Base.WritePrimitive(writer, val.DialogPriority, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.StopWhenTaskEnd, writer.WriteBoolean, false)
end

function Auto.WriteDirectLocationDetectEventData(writer, val)
	Base.WritePrimitive(writer, val.EnemyId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.DetectEventId, writer.WriteUInt32, 0)
end

function Auto.WriteDisableBadgeInfos(writer, val)
	Base.WriteDict(writer, val.DisableBadgeInfoList, writer.WriteUInt32, Base.WriteComplexWrap(Auto.WriteDisableBadgeReasons, "DisableBadgeReasons", false), nil, "DisableBadgeInfoList", false, 0)
end

function Auto.WriteDisableBadgeReasons(writer, val)
	Base.WriteList(writer, val.ReasonList, writer.WriteInt32, 0, "ReasonList", false, 0, nil)
end

function Auto.WriteDisableClientNodeCommand(writer, val)
	Base.WritePrimitive(writer, val.Nid, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.RpcId, writer.WriteInt64, 0)
	Base.WritePrimitive(writer, val.HasRpcId, writer.WriteBoolean, false)
end

function Auto.WriteDiscardOperationInfo(writer, val)
	Base.WritePrimitive(writer, val.PlayerIndex, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.CurrentTurnPlayerIndex, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.IsRichiing, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.DiscardingLastDraw, writer.WriteBoolean, false)
	Base.WriteStruct(writer, val.Tile, Auto.WriteTile, "Tile")
	Base.WritePrimitive(writer, val.RemainTurnTime, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.Zhenting, writer.WriteBoolean, false)
	Base.WriteList7Bit(writer, val.Operations, Base.WriteStructWrap(Auto.WriteOutTurnOperation, "Operations"), nil, "Operations", false, 0, nil)
	Base.WriteList7Bit(writer, val.HandTiles, Base.WriteStructWrap(Auto.WriteTile, "HandTiles"), nil, "HandTiles", false, 0, nil)
	Base.WriteList7Bit(writer, val.Rivers, Base.WriteStructWrap(Auto.WriteRiverData, "Rivers"), nil, "Rivers", false, 0, nil)
end

function Auto.WriteDiscardTileInfo(writer, val)
	Base.WritePrimitive(writer, val.PlayerIndex, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.IsRichiing, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.DiscardingLastDraw, writer.WriteBoolean, false)
	Base.WriteStruct(writer, val.Tile, Auto.WriteTile, "Tile")
	Base.WritePrimitive(writer, val.RemainTurnTime, writer.WriteInt32, 0)
end

function Auto.WriteDivinerCustomerInfo(writer, val)
	Base.WritePrimitive(writer, val.AgentId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.AgentCfgId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.DemandId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.PersonalityId, writer.WriteUInt32, 0)
	writer:WriteString(val.AgentName, false, "DivinerCustomerInfo.AgentName", 0)
	writer:WriteString(val.SessionId, false, "DivinerCustomerInfo.SessionId", 0)
	Base.WritePrimitive(writer, val.Attitude, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.BranchId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.Persuasion, writer.WriteUInt32, 0)
	writer:WriteString(val.Target, false, "DivinerCustomerInfo.Target", 0)
	Base.WritePrimitive(writer, val.Success_Persuasion, writer.WriteUInt32, 0)
	writer:WriteString(val.Endings, false, "DivinerCustomerInfo.Endings", 0)
	Base.WritePrimitive(writer, val.Stage, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.IsInGame, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.Faction, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.AppealTimeEnd, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.PersuadeTimeEnd, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.EndReason, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.Result, writer.WriteInt32, 0)
	Base.WriteList7Bit(writer, val.Clues, writer.WriteUInt32, 0, "Clues", false, 0, nil)
	Base.WritePrimitive(writer, val.EventType, writer.WriteInt32, 0)
	writer:WriteString(val.EventDesc, false, "DivinerCustomerInfo.EventDesc", 0)
	Base.WritePrimitive(writer, val.Patience, writer.WriteInt32, 0)
end

function Auto.WriteDivinerLiveChatNpcChatInfo(writer, val)
	Base.WritePrimitive(writer, val.NpcId, writer.WriteUInt32, 0)
	writer:WriteString(val.NpcNickname, true, "DivinerLiveChatNpcChatInfo.NpcNickname", 0)
	Base.WritePrimitive(writer, val.NpcType, writer.WriteUInt32, 0)
	writer:WriteString(val.Message, true, "DivinerLiveChatNpcChatInfo.Message", 0)
	Base.WritePrimitive(writer, val.ActionType, writer.WriteUInt32, 0)
end

function Auto.WriteDivinerPersuasionResult(writer, val)
	Base.WritePrimitive(writer, val.AgentId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.Stage, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.Result, writer.WriteInt32, 0)
	writer:WriteString(val.Msg, false, "DivinerPersuasionResult.Msg", 0)
	Base.WritePrimitive(writer, val.ClueId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.Attitude, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.Persuasion, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.EndReason, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.EventType, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.Patience, writer.WriteInt32, 0)
end

function Auto.WriteDoorClientInfo(writer, val)
	Base.WritePrimitive(writer, val.OpenAngle, writer.WriteSingle, 0)
end

function Auto.WriteDoorModuleSyncInfo(writer, val)
	Base.WritePrimitive(writer, Base.CheckEnum(val.LockState, 147, 0), writer.WriteByte, 0)
	Base.WritePrimitive(writer, Base.CheckEnum(val.ProximityState, 148, 0), writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.ProximityStartTime, writer.WriteUInt32, 0)
	Base.WriteList7Bit(writer, val.ClientInfos, Base.WriteComplexWrap(Auto.WriteDoorClientInfo, "DoorClientInfo", false), nil, "ClientInfos", false, 0, nil)
end

function Auto.WriteDoublePayload(writer, val)
	Base.WritePrimitive(writer, val.V, writer.WriteDouble, 0)
end

function Auto.WriteDrawTileInfo(writer, val)
	Base.WritePrimitive(writer, val.PlayerIndex, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.DrawPlayerIndex, writer.WriteInt32, 0)
	Base.WriteStruct(writer, val.Tile, Auto.WriteTile, "Tile")
	Base.WritePrimitive(writer, val.RemainTurnTime, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.Zhenting, writer.WriteBoolean, false)
	Base.WriteList7Bit(writer, val.Operations, Base.WriteStructWrap(Auto.WriteInTurnOperation, "Operations"), nil, "Operations", false, 0, nil)
	Base.WriteStruct(writer, val.MahjongSetData, Auto.WriteMahjongSetData, "MahjongSetData")
end

function Auto.WriteDrillShelfCell(writer, val)
	Base.WritePrimitive(writer, val.Row, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.Col, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, Base.CheckEnum(val.Reward, 149, 0), writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.Drilled, writer.WriteBoolean, false)
end

function Auto.WriteDrillShelfSyncInfo(writer, val)
	Base.WritePrimitive(writer, val.Row, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.Col, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.DrillTimes, writer.WriteInt32, 0)
	Base.WriteList7Bit(writer, val.Cells, Base.WriteComplexWrap(Auto.WriteDrillShelfCell, "DrillShelfCell", false), nil, "Cells", false, 0, nil)
end

function Auto.WriteDrivingBehaviorRecord(writer, val)
	Base.WritePrimitive(writer, val.TimeStamp, writer.WriteSingle, 0)
	Base.WriteStruct(writer, val.Position, Auto.WriteUXVector3, "Position")
	Base.WritePrimitive(writer, val.RotationX, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.RotationY, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.RotationZ, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.RotationW, writer.WriteSingle, 0)
	Base.WriteStruct(writer, val.EulerAngles, Auto.WriteUXVector3, "EulerAngles")
	Base.WriteStruct(writer, val.Velocity, Auto.WriteUXVector3, "Velocity")
	Base.WriteStruct(writer, val.AngVelocity, Auto.WriteUXVector3, "AngVelocity")
	Base.WritePrimitive(writer, val.SteerInput, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.ThrottleInput, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.BrakeInput, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.HandbrakeInput, writer.WriteSingle, 0)
end

function Auto.WriteDrivingBehaviorRecords(writer, val)
	Base.WritePrimitive(writer, val.VehicleConfigId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, Base.CheckEnum(val.ControlType, 150, 0), writer.WriteByte, 0)
	Base.WriteList7Bit(writer, val.Records, Base.WriteComplexWrap(Auto.WriteDrivingBehaviorRecord, "DrivingBehaviorRecord", false), nil, "Records", false, RpcLengthLimits.DrivingBehaviorRecords_Records, nil)
	Base.WritePrimitive(writer, val.TaskId, writer.WriteUInt32, 0)
end

function Auto.WriteDropBelongingData(writer, val)
	Base.WritePrimitive(writer, val.BelongingId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.OwnerId, writer.WriteUInt64, 0)
	Base.WriteStruct(writer, val.Position, Auto.WriteUXVector3, "Position")
end

function Auto.WriteDropLimitInfo(writer, val)
	Base.WritePrimitive(writer, val.Count, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.FinishTime, writer.WriteUInt32, 0)
end

function Auto.WriteDynamicDestructibleData(writer, val)
	Base.WritePrimitive(writer, val.SceneItemCfgId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.ReleaserId, writer.WriteUInt64, 0)
	Base.WriteStruct(writer, val.Position, Auto.WriteUXVector3, "Position")
	Base.WriteStruct(writer, val.Facing, Auto.WriteUXVector3, "Facing")
	Base.WritePrimitive(writer, val.LivingTime, writer.WriteSingle, 0)
end

function Auto.WriteDynamicDestructibleInfo(writer, val)
	Base.WritePrimitive(writer, val.CreateAgentInstanceId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.MergeAgentInstanceId, writer.WriteUInt64, 0)
	Base.WriteComplex(writer, val.VehicleInfo, Auto.WriteVehicleDestructibleInfo, "VehicleInfo", true)
	Base.WriteComplex(writer, val.AdherePlatformInfo, Auto.WriteAdhereMovingPlatformInfo, "AdherePlatformInfo", true)
	Base.WritePrimitive(writer, val.InstanceId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.UniqueId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.CfgId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.PathId, writer.WriteInt32, 0)
	Base.WriteStruct(writer, val.Position, Auto.WriteUXVector3, "Position")
	Base.WriteStruct(writer, val.Facing, Auto.WriteUXVector3, "Facing")
	Base.WritePrimitive(writer, val.iScale, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.NavId, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.ForceLod0, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.BindPid, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.Hp, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, Base.CheckEnum(val.State, 145, 0), writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.BreakStage, writer.WriteUInt32, 0)
	Base.WriteList7Bit(writer, val.OccupantInfos, Base.WriteStructWrap(Auto.WriteSceneDeviceOccupantInfo, "OccupantInfos"), nil, "OccupantInfos", true, 0, nil)
	Base.WritePrimitive(writer, val.DropWeaponId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.StackCount, writer.WriteInt32, 0)
	Base.WriteList7Bit(writer, val.EffectIds, writer.WriteInt32, 0, "EffectIds", true, 0, nil)
	Base.WritePrimitive(writer, val.NoSleep, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.ReleaserId, writer.WriteUInt64, 0)
	Base.WriteComplex(writer, val.SkillInfo, Auto.WriteSkillDestructibleInfo, "SkillInfo", true)
end

function Auto.WriteDynamicGoFullInfo(writer, val)
	Base.WritePrimitive(writer, val.id, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.navIndex, writer.WriteUInt32, 0)
	Base.WriteStruct(writer, val.position, Auto.WriteUXVector3, "position")
	Base.WriteStruct(writer, val.angles, Auto.WriteUXVector3, "angles")
	Base.WritePrimitive(writer, val.isRegular, writer.WriteBoolean, false)
	Base.WriteStruct(writer, val.scale, Auto.WriteUXVector3, "scale")
	writer:WriteString(val.prefabPath, false, "DynamicGoFullInfo.prefabPath", 0)
	Base.WritePrimitive(writer, val.isStatic, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.blockSize, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.isDefaultInactive, writer.WriteBoolean, false)
end

function Auto.WriteDynamicPlateInfo(writer, val)
	Base.WriteDict7Bit(writer, val.DynamicAgentDic, writer.WriteInt32, writer.WriteUInt64, 0, "DynamicAgentDic", true, 0)
	Base.WriteDict7Bit(writer, val.DynamicVehicleDic, writer.WriteInt32, writer.WriteUInt64, 0, "DynamicVehicleDic", true, 0)
	Base.WritePrimitive(writer, val.UniqueId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.GraphId, writer.WriteInt32, 0)
	Base.WriteStruct(writer, val.Position, Auto.WriteUXVector3, "Position")
	Base.WriteStruct(writer, val.Rotation, Auto.WriteUXVector3, "Rotation")
	Base.WriteDict7Bit(writer, val.GadgetDic, writer.WriteInt32, writer.WriteUInt64, 0, "GadgetDic", true, 0)
	Base.WriteDict7Bit(writer, val.DestructibleDic, writer.WriteInt32, writer.WriteUInt64, 0, "DestructibleDic", true, 0)
	Base.WriteDict7Bit(writer, val.AgentDic, writer.WriteInt32, writer.WriteInt32, 0, "AgentDic", true, 0)
	Base.WriteDict7Bit(writer, val.VehicleDic, writer.WriteInt32, writer.WriteInt32, 0, "VehicleDic", true, 0)
	Base.WriteDict7Bit(writer, val.StaticNpcDic, writer.WriteInt32, writer.WriteInt32, 0, "StaticNpcDic", true, 0)
	Base.WritePrimitive(writer, val.FavorNpcActivityId, writer.WriteUInt32, 0)
end

function Auto.WriteECSStimInfo(writer, val)
	Base.WritePrimitive(writer, val.AgentId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.DMOverrideId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.ECSResponseId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.StimDirectionId, writer.WriteInt32, 0)
end

function Auto.WriteEQSPosInfo(writer, val)
	Base.WritePrimitive(writer, val.Uid, writer.WriteUInt64, 0)
	Base.WriteStruct(writer, val.Position, Auto.WriteUXVector3, "Position")
end

function Auto.WriteEcsArchetypeInfo(writer, val)
	writer:WriteString(val.Key, true, "EcsArchetypeInfo.Key", 0)
	Base.WritePrimitive(writer, val.EntityCount, writer.WriteInt32, 0)
	Base.WriteList(writer, val.ComponentTypes, Base.WriteStringWrap(true, "ComponentTypes", 0), nil, "ComponentTypes", true, 0, nil)
end

function Auto.WriteEcsComponentInfo(writer, val)
	writer:WriteString(val.TypeName, true, "EcsComponentInfo.TypeName", 0)
	Base.WritePrimitive(writer, val.Category, writer.WriteInt32, 0)
end

function Auto.WriteEcsEntityDetail(writer, val)
	Base.WritePrimitive(writer, val.Index, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.Version, writer.WriteInt32, 0)
	Base.WriteList(writer, val.Components, Base.WriteComplexWrap(Auto.WriteEcsComponentInfo, "EcsComponentInfo", true), nil, "Components", true, 0, nil)
end

function Auto.WriteEcsEntityInfo(writer, val)
	Base.WritePrimitive(writer, val.Index, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.Version, writer.WriteInt32, 0)
end

function Auto.WriteEcsWorldInfo(writer, val)
	writer:WriteString(val.Name, true, "EcsWorldInfo.Name", 0)
	Base.WritePrimitive(writer, val.EntityCount, writer.WriteInt32, 0)
end

function Auto.WriteEdictDebugInfo(writer, val)
	Base.WritePrimitive(writer, val.isShort, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.ownerId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.giveTime, writer.WriteDouble, 0)
	Base.WritePrimitive(writer, val.canGiveTime, writer.WriteDouble, 0)
	Base.WritePrimitive(writer, val.needRemove, writer.WriteBoolean, false)
end

function Auto.WriteEffectSyncData(writer, val)
	Base.WriteList7Bit(writer, val.Bytes, writer.WriteByte, 0, "Bytes", false, RpcLengthLimits.EffectSyncData_Bytes, nil)
end

function Auto.WriteEggGameSettleData(writer, val)
	Base.WritePrimitive(writer, val.PassCount, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.IsInGame, writer.WriteBoolean, false)
end

function Auto.WriteEmojiData(writer, val)
	writer:WriteString(val.Id, false, "EmojiData.Id", RpcLengthLimits.EmojiData_Id)
	Base.WritePrimitive(writer, val.Count, writer.WriteUInt32, 0)
end

function Auto.WriteEmptyPayload(writer, val)
end

function Auto.WriteEnableClientNodeCommand(writer, val)
	Base.WritePrimitive(writer, val.Nid, writer.WriteUInt32, 0)
	Base.WriteList7Bit(writer, val.Observables, Base.WriteComplexWrap(Auto.WriteNamedPayload, "NamedPayload", true), nil, "Observables", true, 0, nil)
	Base.WriteList7Bit(writer, val.Replicables, Base.WriteComplexWrap(Auto.WriteNamedPayload, "NamedPayload", true), nil, "Replicables", true, 0, nil)
	Base.WriteList7Bit(writer, val.SyncReplicables, Base.WriteComplexWrap(Auto.WriteNamedPayload, "NamedPayload", true), nil, "SyncReplicables", true, 0, nil)
	Base.WritePrimitive(writer, val.RpcId, writer.WriteInt64, 0)
	Base.WritePrimitive(writer, val.HasRpcId, writer.WriteBoolean, false)
end

function Auto.WriteEndItemDropInfo(writer, val)
	Base.WritePrimitive(writer, val.enemyInstanceId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.bindItemsIndex, writer.WriteInt32, 0)
	Base.WriteStruct(writer, val.itemRotation, Auto.WriteUXVector3, "itemRotation")
	Base.WriteStruct(writer, val.itemPosition, Auto.WriteUXVector3, "itemPosition")
end

function Auto.WriteEnemyDieInfo(writer, val)
	Base.WritePrimitive(writer, val.HasDieAnimation, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.HasDieEffect, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.DieEffectId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.DelayDestroyDistance, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.LastHitHurtEffect, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.DeadlySkillId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.Killer, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.HasPlayedDeathSkill, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.WeaponDropDestructibleId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, Base.CheckEnum(val.DieType, 151, 0), writer.WriteInt16, 0)
	Base.WritePrimitive(writer, val.WeaponId, writer.WriteUInt32, 0)
end

function Auto.WriteEnemyItemDropInfo(writer, val)
	Base.WritePrimitive(writer, val.BindItemsIndex, writer.WriteInt32, 0)
	Base.WriteStruct(writer, val.Rotation, Auto.WriteUXVector3, "Rotation")
	Base.WriteStruct(writer, val.Position, Auto.WriteUXVector3, "Position")
	Base.WritePrimitive(writer, Base.CheckEnum(val.DropState, 152, 0), writer.WriteByte, 0)
end

function Auto.WriteEnemyMoveFinishData(writer, val)
	Base.WritePrimitive(writer, val.EnemyId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.InstanceId, writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.IsFailure, writer.WriteBoolean, false)
end

function Auto.WriteEnemyStandInfo(writer, val)
	Base.WritePrimitive(writer, val.EnemyId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.CircleNum, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.IsArrived, writer.WriteBoolean, false)
end

function Auto.WriteEnemyWeaponState(writer, val)
	Base.WritePrimitive(writer, val.Pid, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.IsHoldingWeapon, writer.WriteBoolean, false)
end

function Auto.WriteEnterGameData(writer, val)
	Base.WritePrimitive(writer, val.Aid, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.Pid, writer.WriteUInt64, 0)
	Base.WriteComplex(writer, val.Token, Auto.WriteTokenInfo, "Token", false)
end

function Auto.WriteEnterSceneInfo(writer, val)
	Base.WritePrimitive(writer, val.PlayerSessionId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.RaidId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.InstanceId, writer.WriteUInt64, 0)
	Base.WriteStruct(writer, val.Position, Auto.WriteUXVector3, "Position")
	Base.WritePrimitive(writer, val.Facing, writer.WriteSingle, 0)
	Base.WriteList7Bit(writer, val.SpoonLevels, Base.WriteStringWrap(false, "SpoonLevels", 0), nil, "SpoonLevels", false, 0, nil)
	Base.WriteList7Bit(writer, val.SpoonMd5s, Base.WriteStringWrap(false, "SpoonMd5s", 0), nil, "SpoonMd5s", false, 0, nil)
	Base.WriteList7Bit(writer, val.SceneSpoonNames, Base.WriteStringWrap(true, "SceneSpoonNames", 0), nil, "SceneSpoonNames", true, 0, nil)
	Base.WriteList7Bit(writer, val.SceneSpoonMd5s, Base.WriteStringWrap(true, "SceneSpoonMd5s", 0), nil, "SceneSpoonMd5s", true, 0, nil)
	Base.WriteList7Bit(writer, val.Spirits, Base.WriteStructWrap(Auto.WriteSpiritInitData, "Spirits"), nil, "Spirits", false, 0, nil)
	Base.WriteStruct(writer, val.GridInfo, Auto.WriteServerSimpleGridInfo, "GridInfo")
	Base.WritePrimitive(writer, val.MatchGameId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.SwitchShowId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.IsSwitchSpiritShow, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.UniverseId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.SectorControlId, writer.WriteUInt32, 0)
	Base.WriteComplex(writer, val.LoadingType, Auto.WriteLoadingTypeInfo, "LoadingType", false)
	Base.WriteComplex(writer, val.LinkSimpleInfo, Auto.WriteLinkSimpleInfo, "LinkSimpleInfo", false)
	Base.WriteList7Bit(writer, val.DataLayerIndices, Base.WriteComplexWrap(Auto.WriteDataLayerIndic, "DataLayerIndic", false), nil, "DataLayerIndices", false, 0, nil)
	Base.WritePrimitive(writer, val.Seamless, writer.WriteBoolean, false)
end

function Auto.WriteEventIdInfo(writer, val)
	Base.WritePrimitive(writer, val.Id, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.NpcId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, Base.CheckEnum(val.EventType, 153, 0), writer.WriteByte, 0)
end

function Auto.WriteEventPanelInfo(writer, val)
	Base.WriteList7Bit(writer, val.EventsInfo, Base.WriteComplexWrap(Auto.WriteTaskEventInfo, "TaskEventInfo", false), nil, "EventsInfo", false, 0, nil)
	Base.WriteList7Bit(writer, val.SubmitEventList, writer.WriteUInt32, 0, "SubmitEventList", false, 0, nil)
	Base.WriteList7Bit(writer, val.EventViewInfoList, Base.WriteComplexWrap(Auto.WriteEventSpoonViewInfo, "EventSpoonViewInfo", false), nil, "EventViewInfoList", false, 0, nil)
end

function Auto.WriteEventProgress(writer, val)
	Base.WritePrimitive(writer, val.Value, writer.WriteUInt32, 0)
end

function Auto.WriteEventProgressInfo(writer, val)
	Base.WriteList(writer, val.EventProgressDict, Base.WriteStructWrap(Auto.WriteEventProgress, "EventProgressDict"), nil, "EventProgressDict", false, 0, nil)
	Base.WritePrimitive(writer, val.Value, writer.WriteUInt32, 0)
end

function Auto.WriteEventSpoonViewInfo(writer, val)
	Base.WritePrimitive(writer, val.EventId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.RaidId, writer.WriteUInt32, 0)
	writer:WriteString(val.SpoonMd5, false, "EventSpoonViewInfo.SpoonMd5", 0)
end

function Auto.WriteExternalControlParamDto(writer, val)
	Base.WritePrimitive(writer, val.EnableStimResponse, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.EnableInteractionUi, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.EnableStationaryPointReturning, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.AnimLookAtIkType, writer.WriteInt32, 0)
end

function Auto.WriteExtraStateConfirmInfo(writer, val)
	Base.WritePrimitive(writer, val.stageId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.confirm, writer.WriteBoolean, false)
end

function Auto.WriteExtractionMark(writer, val)
	Base.WriteStruct(writer, val.Position, Auto.WriteUXVector3, "Position")
end

function Auto.WriteExtractionSettleData(writer, val)
	Base.WritePrimitive(writer, val.BringOutItemTotalPrice, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, Base.CheckEnum(val.Reason, 154, 0), writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.ExtractionPointId, writer.WriteUInt32, 0)
end

function Auto.WriteExtractionShooterBagInfo(writer, val)
	Base.WritePrimitive(writer, val.BagId, writer.WriteUInt32, 0)
	Base.WriteList(writer, val.ItemInfoList, Base.WriteComplexWrap(Auto.WriteExtractionShooterItemInfo, "ExtractionShooterItemInfo", false), nil, "ItemInfoList", false, 0, nil)
end

function Auto.WriteExtractionShooterBringOutBudget(writer, val)
	Base.WritePrimitive(writer, val.Amount, writer.WriteUInt32, 0)
	Base.WriteDict(writer, val.SetTracks, writer.WriteUInt32, writer.WriteUInt32, 0, "SetTracks", false, 0)
end

function Auto.WriteExtractionShooterContainerGMInfo(writer, val)
	Base.WritePrimitive(writer, val.InstanceId, writer.WriteUInt64, 0)
	Base.WriteComplex(writer, val.Info, Auto.WriteExtractionShooterContainerInfo, "Info", true)
	Base.WriteStruct(writer, val.Pos, Auto.WriteUXVector3, "Pos")
end

function Auto.WriteExtractionShooterContainerInfo(writer, val)
	Base.WritePrimitive(writer, val.CfgId, writer.WriteUInt32, 0)
	Base.WriteList7Bit(writer, val.ItemList, Base.WriteComplexWrap(Auto.WriteExtractionShooterContainerItemInfo, "ExtractionShooterContainerItemInfo", true), nil, "ItemList", true, 0, nil)
end

function Auto.WriteExtractionShooterContainerItemInfo(writer, val)
	Base.WriteDict(writer, val.Pid2SearchFinishTimeDict, writer.WriteUInt64, writer.WriteUInt32, 0, "Pid2SearchFinishTimeDict", false, 0)
	Base.WritePrimitive(writer, val.Id, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.StackCount, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.CellX, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.CellY, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.IsRotated, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.IsLocked, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.BindPid, writer.WriteUInt64, 0)
end

function Auto.WriteExtractionShooterEvacuationPlaceInfo(writer, val)
	Base.WriteStruct(writer, val.Position, Auto.WriteUXVector3, "Position")
	Base.WritePrimitive(writer, Base.CheckEnum(val.State, 155, 0), writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.ShowAtTime, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.DisappearAtTime, writer.WriteUInt32, 0)
	Base.WriteStruct(writer, val.InnerRoomShape, Auto.WriteExtractionShooterRoomShapeInfo, "InnerRoomShape")
end

function Auto.WriteExtractionShooterGunContainerItemInfo(writer, val)
	Base.WriteComplex(writer, val.WeaponData, Auto.WriteWeaponData, "WeaponData", false)
	Base.WriteDict(writer, val.Pid2SearchFinishTimeDict, writer.WriteUInt64, writer.WriteUInt32, 0, "Pid2SearchFinishTimeDict", false, 0)
	Base.WritePrimitive(writer, val.Id, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.StackCount, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.CellX, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.CellY, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.IsRotated, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.IsLocked, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.BindPid, writer.WriteUInt64, 0)
end

function Auto.WriteExtractionShooterGunItemInfo(writer, val)
	Base.WriteComplex(writer, val.WeaponData, Auto.WriteWeaponData, "WeaponData", false)
	Base.WritePrimitive(writer, val.Id, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.StackCount, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.CellX, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.CellY, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.IsRotated, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.IsLocked, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.BindPid, writer.WriteUInt64, 0)
end

function Auto.WriteExtractionShooterItemInfo(writer, val)
	Base.WritePrimitive(writer, val.Id, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.StackCount, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.CellX, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.CellY, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.IsRotated, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.IsLocked, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.BindPid, writer.WriteUInt64, 0)
end

function Auto.WriteExtractionShooterRoomShapeInfo(writer, val)
	Base.WriteStruct(writer, val.Center, Auto.WriteUXVector3, "Center")
	Base.WriteStruct(writer, val.HalfExtents, Auto.WriteUXVector3, "HalfExtents")
	Base.WriteStruct(writer, val.XDir, Auto.WriteUXVector3, "XDir")
	Base.WriteStruct(writer, val.ZDir, Auto.WriteUXVector3, "ZDir")
end

function Auto.WriteExtractionShooterSellItemInfo(writer, val)
	Base.WritePrimitive(writer, val.BagConfigId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.CellX, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.CellY, writer.WriteUInt32, 0)
end

function Auto.WriteExtractionShooterShieldContainerItemInfo(writer, val)
	Base.WritePrimitive(writer, val.ShieldValue, writer.WriteSingle, 0)
	Base.WriteDict(writer, val.Pid2SearchFinishTimeDict, writer.WriteUInt64, writer.WriteUInt32, 0, "Pid2SearchFinishTimeDict", false, 0)
	Base.WritePrimitive(writer, val.Id, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.StackCount, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.CellX, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.CellY, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.IsRotated, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.IsLocked, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.BindPid, writer.WriteUInt64, 0)
end

function Auto.WriteExtractionShooterShieldItemInfo(writer, val)
	Base.WritePrimitive(writer, val.ShieldValue, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.Id, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.StackCount, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.CellX, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.CellY, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.IsRotated, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.IsLocked, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.BindPid, writer.WriteUInt64, 0)
end

function Auto.WriteExtractionShooterSlotGroupInfo(writer, val)
	Base.WritePrimitive(writer, val.BagId, writer.WriteUInt32, 0)
	Base.WriteList(writer, val.ItemInfoList, Base.WriteComplexWrap(Auto.WriteExtractionShooterItemInfo, "ExtractionShooterItemInfo", false), nil, "ItemInfoList", false, 0, nil)
	Base.WritePrimitive(writer, val.AddUnlockedCount, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.AddMaxCapacity, writer.WriteUInt32, 0)
end

function Auto.WriteFaceToCommandData(writer, val)
	Base.WriteStruct(writer, val.Target, Auto.WriteClientActionTarget, "Target")
	Base.WritePrimitive(writer, val.Tolerance, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, Base.CheckEnum(val.DataSource, 97, 0), writer.WriteInt16, 0)
end

function Auto.WriteFactionChangeInfo(writer, val)
	Base.WritePrimitive(writer, val.FactionId, writer.WriteUInt32, 0)
	Base.WriteComplex(writer, val.NewInfo, Auto.WriteFactionInfo, "NewInfo", false)
	Base.WriteComplex(writer, val.OldInfo, Auto.WriteFactionInfo, "OldInfo", false)
end

function Auto.WriteFactionInfo(writer, val)
	Base.WritePrimitive(writer, val.Disposition, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.DispositionLevel, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.Influence, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.InteractionCount, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.GreetCount, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.IsUnlock, writer.WriteBoolean, false)
end

function Auto.WriteFanBoxDropInfo(writer, val)
	Base.WritePrimitive(writer, val.AwardScore, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.LastUpdateTime, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.WeekDropCount, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.DropCount, writer.WriteUInt32, 0)
end

function Auto.WriteFarmerDailyRecord(writer, val)
	Base.WritePrimitive(writer, val.Income, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.Transactions, writer.WriteUInt32, 0)
end

function Auto.WriteFarmerIncomeView(writer, val)
	Base.WritePrimitive(writer, val.Wallet, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.TotalEarned, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.ThisWeekSoldCount, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.LastWithdrawAmount, writer.WriteUInt32, 0)
	Base.WriteList7Bit(writer, val.ThisWeekDailyRecords, Base.WriteComplexWrap(Auto.WriteFarmerDailyRecord, "FarmerDailyRecord", false), nil, "ThisWeekDailyRecords", false, 0, nil)
	Base.WritePrimitive(writer, val.ThisWeekEarned, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.LastWeekEarned, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.LastWeekSoldCount, writer.WriteUInt32, 0)
	Base.WriteList7Bit(writer, val.LastWeekDailyRecords, Base.WriteComplexWrap(Auto.WriteFarmerDailyRecord, "FarmerDailyRecord", false), nil, "LastWeekDailyRecords", false, 0, nil)
end

function Auto.WriteFarmerOrderInfo(writer, val)
	Base.WritePrimitive(writer, Base.CheckEnum(val.State, 156, 0), writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.ExpireTime, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.EventId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, Base.CheckEnum(val.EndReason, 157, 0), writer.WriteByte, 0)
end

function Auto.WriteFarmerShopSlot(writer, val)
	Base.WritePrimitive(writer, val.ItemId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.Count, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.Price, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.PlacedTime, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.LastSettleTime, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.Quality, writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.Tags, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.SoldCount, writer.WriteUInt32, 0)
end

function Auto.WriteFarmerSowInfo(writer, val)
	Base.WritePrimitive(writer, val.LandId, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.CorpId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.ConsumableId, writer.WriteUInt32, 0)
end

function Auto.WriteFashionColoringInfo(writer, val)
	Base.WriteDict(writer, val.ColoringType2ColorIdDict, writer.WriteByte, writer.WriteUInt32, 0, "ColoringType2ColorIdDict", false, RpcLengthLimits.FashionColoringInfo_ColoringType2ColorIdDict)
end

function Auto.WriteFashionColoringSchemeInfo(writer, val)
	Base.WritePrimitive(writer, val.FashionId, writer.WriteUInt32, 0)
	Base.WriteDict7Bit(writer, val.FashionColoringSchemeInfoDict, writer.WriteByte, Base.WriteComplexWrap(Auto.WriteFashionColoringInfo, "FashionColoringInfo", false), nil, "FashionColoringSchemeInfoDict", false, RpcLengthLimits.FashionColoringSchemeInfo_FashionColoringSchemeInfoDict)
end

function Auto.WriteFashionCustomSuitSchemeInfo(writer, val)
	writer:WriteString(val.SchemeName, true, "FashionCustomSuitSchemeInfo.SchemeName", RpcLengthLimits.FashionCustomSuitSchemeInfo_SchemeName)
	Base.WritePrimitive(writer, val.JoinRandomPool, writer.WriteBoolean, false)
	Base.WriteList(writer, val.WearFashionInfoList, Base.WriteComplexWrap(Auto.WriteWearFashionInfo, "WearFashionInfo", false), nil, "WearFashionInfoList", false, RpcLengthLimits.BaseWearFashionsInfo_WearFashionInfoList, nil)
	Base.WriteList(writer, val.WearFashionEditInfoList, Base.WriteComplexWrap(Auto.WriteWearFashionEditInfo, "WearFashionEditInfo", true), nil, "WearFashionEditInfoList", true, RpcLengthLimits.BaseWearFashionsInfo_WearFashionEditInfoList, nil)
	Base.WritePrimitive(writer, val.HiddenParts, writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.EditedHiddenParts, writer.WriteByte, 0)
end

function Auto.WriteFashionFunctionSuitSchemeInfo(writer, val)
	Base.WriteList(writer, val.WearFashionInfoList, Base.WriteComplexWrap(Auto.WriteWearFashionInfo, "WearFashionInfo", false), nil, "WearFashionInfoList", false, RpcLengthLimits.BaseWearFashionsInfo_WearFashionInfoList, nil)
	Base.WriteList(writer, val.WearFashionEditInfoList, Base.WriteComplexWrap(Auto.WriteWearFashionEditInfo, "WearFashionEditInfo", true), nil, "WearFashionEditInfoList", true, RpcLengthLimits.BaseWearFashionsInfo_WearFashionEditInfoList, nil)
	Base.WritePrimitive(writer, val.HiddenParts, writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.EditedHiddenParts, writer.WriteByte, 0)
end

function Auto.WriteFashionInfo(writer, val)
	Base.WritePrimitive(writer, val.FashionId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.ExpiredTime, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.GainTime, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.Status, writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.ApplyColoringSchemeId, writer.WriteByte, 0)
	Base.WriteDict(writer, val.ColoringSchemeInfoDict, writer.WriteByte, Base.WriteComplexWrap(Auto.WriteFashionColoringInfo, "FashionColoringInfo", false), nil, "ColoringSchemeInfoDict", false, 0)
	Base.WritePrimitive(writer, val.UnlockColoringSlotCount, writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.ColoringSchemeTopNMaxCollectionScore, writer.WriteUInt32, 0)
end

function Auto.WriteFavorInteractCommandData(writer, val)
	Base.WritePrimitive(writer, val.PlayerId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.SingleInteractType, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.MultiInteractType, writer.WriteUInt32, 0)
	Base.WriteStruct(writer, val.MainPos, Auto.WriteUXVector3, "MainPos")
	Base.WriteStruct(writer, val.MainDir, Auto.WriteUXVector3, "MainDir")
	Base.WriteStruct(writer, val.CoPos, Auto.WriteUXVector3, "CoPos")
	Base.WriteStruct(writer, val.CoDir, Auto.WriteUXVector3, "CoDir")
	Base.WritePrimitive(writer, val.IsPlayer, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.IsMain, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.IsHold, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, Base.CheckEnum(val.DataSource, 97, 0), writer.WriteInt16, 0)
end

function Auto.WriteFavorNpcBusyInfo(writer, val)
	Base.WritePrimitive(writer, Base.CheckEnum(val.SpawnType, 158, 0), writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.EventId, writer.WriteUInt32, 0)
end

function Auto.WriteFavorNpcPosInfo(writer, val)
	Base.WritePrimitive(writer, val.RaidId, writer.WriteUInt32, 0)
	Base.WriteStruct(writer, val.Position, Auto.WriteUXVector3, "Position")
end

function Auto.WriteFerrisWheelCabinDoorData(writer, val)
	Base.WritePrimitive(writer, val.CabinIndex, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, Base.CheckEnum(val.DoorState, 61, 0), writer.WriteByte, 0)
end

function Auto.WriteFerrisWheelStateData(writer, val)
	Base.WritePrimitive(writer, val.CabinOneAngle, writer.WriteDouble, 0)
	Base.WritePrimitive(writer, val.StateStartTime, writer.WriteDouble, 0)
	Base.WritePrimitive(writer, Base.CheckEnum(val.SpeedState, 159, 0), writer.WriteByte, 0)
end

function Auto.WriteFightGamePlayerSimpleInfo(writer, val)
	Base.WritePrimitive(writer, val.WithAi, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.Pid, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.IsObserver, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.Is1P, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.IsMaster, writer.WriteBoolean, false)
	Base.WriteComplex(writer, val.PlayerUnitInfo, Auto.WriteFightGameUnitInfo, "PlayerUnitInfo", true)
	Base.WriteComplex(writer, val.AiUnitInfo, Auto.WriteFightGameUnitInfo, "AiUnitInfo", true)
end

function Auto.WriteFightGameResult(writer, val)
	Base.WritePrimitive(writer, val.WinnerIndex, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.RoundLeft, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.WaitEndTime, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.IsWithAi, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.IsAiWin, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.IsPlayerWin, writer.WriteBoolean, false)
end

function Auto.WriteFightGameStateInfo(writer, val)
	Base.WritePrimitive(writer, val.Pid, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.PosX, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.PosY, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, Base.CheckEnum(val.Face, 160, 1), writer.WriteByte, 1)
	Base.WritePrimitive(writer, val.Hp, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.AngryValue, writer.WriteInt32, 0)
end

function Auto.WriteFightGameUnitInfo(writer, val)
	Base.WritePrimitive(writer, val.IsAi, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.RoleId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.Index, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.IsReady, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.DeadCount, writer.WriteInt32, 0)
	writer:WriteString(val.CurrentAction, false, "FightGameUnitInfo.CurrentAction", 0)
	Base.WriteComplex(writer, val.State, Auto.WriteFightGameStateInfo, "State", false)
end

function Auto.WriteFightGroupDebugInfo(writer, val)
	Base.WritePrimitive(writer, val.configId, writer.WriteUInt32, 0)
	Base.WriteList7Bit(writer, val.uIds, writer.WriteUInt64, 0, "uIds", false, 0, nil)
	Base.WriteList7Bit(writer, val.normalEdicts, Base.WriteStructWrap(Auto.WriteEdictDebugInfo, "normalEdicts"), nil, "normalEdicts", false, 0, nil)
	Base.WriteList7Bit(writer, val.extraEdicts, Base.WriteStructWrap(Auto.WriteEdictDebugInfo, "extraEdicts"), nil, "extraEdicts", false, 0, nil)
end

function Auto.WriteFightPokemon(writer, val)
	Base.WritePrimitive(writer, val.IsIllusory, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.IsActive, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.PokemonId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.TemplateId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.Body, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.Camp, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.Weapon, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.UnitId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.IsAlive, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.MaxHp, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.Dam, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.Def, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.BlockRate, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.SpecialAttRate, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.AttackSpeed, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.EnergyRecovery, writer.WriteSingle, 0)
	Base.WriteStruct(writer, val.CubeCoord, Auto.WriteCubeCoord, "CubeCoord")
	Base.WritePrimitive(writer, val.BornFacing, writer.WriteSingle, 0)
end

function Auto.WriteFindPathResult(writer, val)
	Base.WriteList7Bit(writer, val.Points, Base.WriteStructWrap(Auto.WriteUXVector3, "Points"), nil, "Points", false, 0, nil)
	Base.WriteList7Bit(writer, val.Flags, writer.WriteByte, 0, "Flags", false, 0, nil)
end

function Auto.WriteFireworkBuyInfo(writer, val)
	Base.WritePrimitive(writer, val.FireworkId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.PlanId, writer.WriteUInt32, 0)
end

function Auto.WriteFireworkPlanInfo(writer, val)
	Base.WritePrimitive(writer, val.PlanId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.NewUnlock, writer.WriteBoolean, false)
end

function Auto.WriteFireworkStoreInfo(writer, val)
	Base.WriteList7Bit(writer, val.PlanInfos, Base.WriteComplexWrap(Auto.WriteFireworkPlanInfo, "FireworkPlanInfo", false), nil, "PlanInfos", false, RpcLengthLimits.FireworkStoreInfo_PlanInfos, nil)
end

function Auto.WriteFishInfo(writer, val)
	Base.WritePrimitive(writer, val.UniqueId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.TemplateId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.Weight, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.Length, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.IsPlaced, writer.WriteBoolean, false)
end

function Auto.WriteFishingFishRewardInfo(writer, val)
	Base.WritePrimitive(writer, val.FishConfigId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.Weight, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.Length, writer.WriteSingle, 0)
end

function Auto.WriteFishingGearInfo(writer, val)
	Base.WritePrimitive(writer, val.UniqueId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.TemplateId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.RemainingDurability, writer.WriteUInt32, 0)
end

function Auto.WriteFishingSpotFishClientInfo(writer, val)
	Base.WritePrimitive(writer, val.Id, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.FishConfigId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.Weight, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.Length, writer.WriteSingle, 0)
end

function Auto.WriteFishingSpotFullSyncInfo(writer, val)
	Base.WritePrimitive(writer, val.FishGroupId, writer.WriteUInt32, 0)
	Base.WriteList7Bit(writer, val.Fishes, Base.WriteComplexWrap(Auto.WriteFishingSpotFishClientInfo, "FishingSpotFishClientInfo", false), nil, "Fishes", false, 0, nil)
	Base.WritePrimitive(writer, val.LastRefreshTime, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.LastResetTime, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.MaxCount, writer.WriteUInt32, 0)
end

function Auto.WriteFloat3(writer, val)
	Base.WritePrimitive(writer, val.x, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.y, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.z, writer.WriteSingle, 0)
end

function Auto.WriteFloatPayload(writer, val)
	Base.WritePrimitive(writer, val.V, writer.WriteSingle, 0)
end

function Auto.WriteFloatingMoveData(writer, val)
	Base.WritePrimitive(writer, val.moveTime, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.speed, writer.WriteSingle, 0)
	Base.WriteStruct(writer, val.targetPos, Auto.WriteUXVector3, "targetPos")
	Base.WritePrimitive(writer, val.speedCurveId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.targetId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.UnitId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, Base.CheckEnum(val.MoveType, 116, 0), writer.WriteInt64, 0)
	Base.WritePrimitive(writer, val.MoveId, writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.CloseIK, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.InstanceId, writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.BlockCloseCapsuleCollision, writer.WriteBoolean, false)
end

function Auto.WriteFocusOnCommandData(writer, val)
	Base.WriteStruct(writer, val.Target, Auto.WriteClientActionTarget, "Target")
	Base.WritePrimitive(writer, val.FocusLevel, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.FocusTime, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.Tolerance, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, Base.CheckEnum(val.DataSource, 97, 0), writer.WriteInt16, 0)
end

function Auto.WriteFollowCommandData(writer, val)
	Base.WritePrimitive(writer, val.ComfortRange, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.TowardTarget, writer.WriteBoolean, false)
	Base.WriteList7Bit(writer, val.Distances, Base.WriteStructWrap(Auto.WriteRangeMoveType, "Distances"), nil, "Distances", false, 0, nil)
	Base.WriteStruct(writer, val.FollowEqs, Auto.WriteFollowEQS, "FollowEqs")
	Base.WritePrimitive(writer, val.NavigationTolerance, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.SelfNavigationTolerance, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.FailedWhenNavigationFailed, writer.WriteBoolean, false)
	Base.WriteStruct(writer, val.Target, Auto.WriteClientActionTarget, "Target")
	Base.WritePrimitive(writer, val.ArriveDistance, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.SpecificMethod, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.DirectionTolerance, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.TryMatchStep, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.KeepUpdateTargetPosition, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.RunChasingDistance, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.KeepMovingAction, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.Speed, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.MoveActionId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.MoveActionGroup, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, Base.CheckEnum(val.DataSource, 97, 0), writer.WriteInt16, 0)
end

function Auto.WriteFollowEQS(writer, val)
	writer:WriteString(val.checker, true, "FollowEQS.checker", 0)
	writer:WriteString(val.preQuery, true, "FollowEQS.preQuery", 0)
	writer:WriteString(val.query, true, "FollowEQS.query", 0)
end

function Auto.WriteFollowRecordingParameters(writer, val)
	Base.WritePrimitive(writer, val.PathId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, Base.CheckEnum(val.FollowType, 161, 0), writer.WriteByte, 0)
	writer:WriteString(val.recordingFileName, false, "FollowRecordingParameters.recordingFileName", 0)
	Base.WritePrimitive(writer, Base.CheckEnum(val.TargetType, 92, 0), writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.TargetUid, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.Step, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.MinSpeed, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.MaxSpeed, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.FarAwayCheck, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.FarAwayThrehold, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.CloseToCheck, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.CloseToThrehold, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.StartFromNextAndNearestPoint, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.AdjustTime, writer.WriteSingle, 0)
	Base.WriteStruct(writer, val.PathOffset, Auto.WriteUXVector3, "PathOffset")
	Base.WritePrimitive(writer, val.guideMinDistance, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.guideMaxDistance, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.guideMinSpeedThreshold, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.guideMaxSpeedThreshold, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.Token, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.taskAIConfigId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.defaultSpeed, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.drivingFlags, writer.WriteInt32, 1)
	Base.WritePrimitive(writer, val.initSpeed, writer.WriteSingle, 0)
	Base.WriteList7Bit(writer, val.initTaskAIBuffList, Base.WriteStructWrap(Auto.WriteTaskVehicleBuffInitInfo, "initTaskAIBuffList"), nil, "initTaskAIBuffList", true, 0, nil)
	Base.WriteStruct(writer, val.commonParameters, Auto.WriteVehicleAICommonParameters, "commonParameters")
end

function Auto.WriteFormationPlayerSlot(writer, val)
	Base.WritePrimitive(writer, val.Row, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.Col, writer.WriteInt32, 0)
end

function Auto.WriteFriendSimpleData(writer, val)
	Base.WritePrimitive(writer, val.IsRejectAllFriendApply, writer.WriteBoolean, false)
	Base.WriteList7Bit(writer, val.BlackList, writer.WriteUInt64, 0, "BlackList", false, 0, nil)
	Base.WriteList7Bit(writer, val.FriendRelationList, Base.WriteComplexWrap(Auto.WriteRelationVO, "RelationVO", false), nil, "FriendRelationList", false, 0, nil)
	Base.WriteList7Bit(writer, val.SpecialList, writer.WriteUInt64, 0, "SpecialList", false, 0, nil)
end

function Auto.WriteFryChestnutParticipantInfo(writer, val)
	Base.WritePrimitive(writer, val.Pid, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.NpcCultivationId, writer.WriteUInt32, 0)
	Base.WriteComplex(writer, val.AIAgentInfo, Auto.WriteLinkAIAgentInfo, "AIAgentInfo", true)
	Base.WritePrimitive(writer, val.AgentInstanceId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.VehicleInstanceId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.SeatIndex, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.IsReady, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.IsPlayAgain, writer.WriteBoolean, false)
end

function Auto.WriteFurnitureInfo(writer, val)
	Base.WritePrimitive(writer, val.FurnitureId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.Count, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.PlacedCount, writer.WriteUInt32, 0)
end

function Auto.WriteGachaDrawItemDetail(writer, val)
	Base.WritePrimitive(writer, val.PoolContentId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.IsGrandPrize, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.IsConverted, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.IsNew, writer.WriteBoolean, false)
end

function Auto.WriteGadgetClientDropLimitInfo(writer, val)
	Base.WritePrimitive(writer, val.GadgetUid, writer.WriteUInt64, 0)
	Base.WriteDict7Bit(writer, val.DropLimitId2FinishTime, writer.WriteUInt32, writer.WriteUInt32, 0, "DropLimitId2FinishTime", false, 0)
end

function Auto.WriteGadgetDropLimitIdList(writer, val)
	Base.WriteList7Bit(writer, val.DropLimitIds, writer.WriteUInt32, 0, "DropLimitIds", false, 0, nil)
end

function Auto.WriteGadgetEntityInfo(writer, val)
	Base.WritePrimitive(writer, val.InstanceId, writer.WriteUInt64, 0)
	Base.WriteStruct(writer, val.Position, Auto.WriteUXVector3, "Position")
	Base.WriteStruct(writer, val.Facing, Auto.WriteUXVector3, "Facing")
	Base.WritePrimitive(writer, val.NavId, writer.WriteInt32, 0)
	Base.WriteList7Bit(writer, val.ChildNavIds, writer.WriteInt32, 0, "ChildNavIds", true, 0, nil)
	Base.WritePrimitive(writer, val.ForceLod0, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.IsTask, writer.WriteBoolean, false)
	Base.WriteDict7Bit(writer, val.CommonStateInfoDic, writer.WriteInt32, writer.WriteInt32, 0, "CommonStateInfoDic", true, 0)
	Base.WriteDict7Bit(writer, val.CommonValueInfoDic, writer.WriteInt32, Base.WriteStringWrap(false, "CommonValueInfoDic", 0), nil, "CommonValueInfoDic", true, 0)
	Base.WriteDict7Bit(writer, val.PersonalValueInfoDic, writer.WriteUInt64, Base.WriteComplexWrap(Auto.WriteSceneDevicePersonalValueInfo, "SceneDevicePersonalValueInfo", false), nil, "PersonalValueInfoDic", true, 0)
	Base.WriteDict7Bit(writer, val.StateCheckIndexDic, writer.WriteInt32, writer.WriteInt32, 0, "StateCheckIndexDic", true, 0)
	Base.WriteDict7Bit(writer, val.ValueCheckIndexDic, writer.WriteInt32, writer.WriteInt32, 0, "ValueCheckIndexDic", true, 0)
	Base.WriteList7Bit(writer, val.OccupantInfos, Base.WriteStructWrap(Auto.WriteSceneDeviceOccupantInfo, "OccupantInfos"), nil, "OccupantInfos", true, 0, nil)
	Base.WritePrimitive(writer, val.LinkOccupiedId, writer.WriteUInt32, 0)
	Base.WriteDict7Bit(writer, val.SymbiosisGadgets, writer.WriteUInt64, writer.WriteUInt64, 0, "SymbiosisGadgets", true, 0)
	Base.WriteComplex(writer, val.Pack, Auto.WritePackedGadgetInfo, "Pack", false)
	Base.WriteComplex(writer, val.MobilePlatformInfo, Auto.WriteMobilePlatformSyncInfo, "MobilePlatformInfo", true)
	Base.WriteComplex(writer, val.AdherePlatformInfo, Auto.WriteAdhereMovingPlatformInfo, "AdherePlatformInfo", true)
	Base.WriteComplex(writer, val.DoorModuleInfo, Auto.WriteDoorModuleSyncInfo, "DoorModuleInfo", true)
	Base.WriteComplex(writer, val.DrillShelfInfo, Auto.WriteDrillShelfSyncInfo, "DrillShelfInfo", true)
	Base.WriteComplex(writer, val.HangingInfo, Auto.WriteSceneDeviceHangingInfo, "HangingInfo", true)
end

function Auto.WriteGadgetExtraSyncInfo(writer, val)
	Base.WriteList7Bit(writer, val.DropLimit, Base.WriteComplexWrap(Auto.WriteGadgetClientDropLimitInfo, "GadgetClientDropLimitInfo", true), nil, "DropLimit", true, 0, nil)
end

function Auto.WriteGadgetGridAOIIncrease(writer, val)
	Base.WriteStruct(writer, val.PlayerStandardIndex, Auto.WriteGridIndex, "PlayerStandardIndex")
	Base.WriteList7Bit(writer, val.addInfos, Base.WriteComplexWrap(Auto.WriteGadgetEntityInfo, "GadgetEntityInfo", true), nil, "addInfos", true, 0, nil)
	Base.WriteList7Bit(writer, val.indexList, Base.WriteStructWrap(Auto.WriteGridIndex, "indexList"), nil, "indexList", true, 0, nil)
	Base.WriteList7Bit(writer, val.addUniqueIds, writer.WriteUInt64, 0, "addUniqueIds", true, 0, nil)
	Base.WriteList7Bit(writer, val.removeIds, writer.WriteUInt64, 0, "removeIds", true, 0, nil)
	Base.WriteList7Bit(writer, val.activeIds, writer.WriteUInt64, 0, "activeIds", true, 0, nil)
	Base.WriteList7Bit(writer, val.inactiveIds, writer.WriteUInt64, 0, "inactiveIds", true, 0, nil)
	Base.WritePrimitive(writer, Base.CheckEnum(val.reason, 144, 0), writer.WriteByte, 0)
end

function Auto.WriteGadgetPackSyncInfo(writer, val)
	Base.WritePrimitive(writer, val.InstanceId, writer.WriteUInt64, 0)
	Base.WriteComplex(writer, val.PackedInfo, Auto.WritePackedGadgetInfo, "PackedInfo", false)
end

function Auto.WriteGadgetRecordItemStuntJump(writer, val)
	Base.WritePrimitive(writer, val.FightSpiritId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.BestStuntJumpDistance, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.BestStuntJumpHeight, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.RemainingCount, writer.WriteInt32, 0)
end

function Auto.WriteGadgetSyncInfo(writer, val)
	Base.WritePrimitive(writer, val.Id, writer.WriteUInt64, 0)
	Base.WriteStruct(writer, val.Position, Auto.WriteUXVector3, "Position")
	Base.WriteStruct(writer, val.Facing, Auto.WriteUXVector3, "Facing")
end

function Auto.WriteGameColorInfo(writer, val)
	Base.WritePrimitive(writer, val.gameId, writer.WriteUInt32, 0)
	Base.WriteList7Bit(writer, val.playersDuty, Base.WriteComplexWrap(Auto.WriteGameDutyInfo, "GameDutyInfo", false), nil, "playersDuty", false, 0, nil)
end

function Auto.WriteGameDutyInfo(writer, val)
	Base.WritePrimitive(writer, val.Pid, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.DutyId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.Index, writer.WriteUInt32, 0)
end

function Auto.WriteGameEndInfo(writer, val)
	Base.WriteList7Bit(writer, val.PlayerNames, Base.WriteStringWrap(false, "PlayerNames", 0), nil, "PlayerNames", false, 0, nil)
	Base.WriteList7Bit(writer, val.Points, writer.WriteInt32, 0, "Points", false, 0, nil)
	Base.WriteList7Bit(writer, val.Places, writer.WriteInt32, 0, "Places", false, 0, nil)
	Base.WritePrimitive(writer, Base.CheckEnum(val.Reason, 162, 0), writer.WriteByte, 0)
end

function Auto.WriteGameFeatureValue(writer, val)
	Base.WritePrimitive(writer, val.Enabled, writer.WriteBoolean, false)
	Base.WriteList(writer, val.Ids, writer.WriteUInt64, 0, "Ids", false, 0, nil)
end

function Auto.WriteGameGroundParticipantInfo(writer, val)
	Base.WritePrimitive(writer, val.Pid, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.NpcCultivationId, writer.WriteUInt32, 0)
	Base.WriteComplex(writer, val.AIAgentInfo, Auto.WriteLinkAIAgentInfo, "AIAgentInfo", true)
	Base.WritePrimitive(writer, val.AgentInstanceId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.VehicleInstanceId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.SeatIndex, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.IsReady, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.IsPlayAgain, writer.WriteBoolean, false)
end

function Auto.WriteGameGroundZoneCountDownInfo(writer, val)
	Base.WritePrimitive(writer, val.PrepareCountDownEndTime, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.DisplayCountDownEndTime, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.GameTimeCountDownStartTime, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.GameTimeCountDownEndTime, writer.WriteUInt32, 0)
end

function Auto.WriteGameGroundZoneIdentifier(writer, val)
	Base.WritePrimitive(writer, val.GadgetUId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.TaskId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, Base.CheckEnum(val.ZoneType, 108, 0), writer.WriteByte, 0)
end

function Auto.WriteGameGroundZoneInfo(writer, val)
	writer:WriteString(val.ZoneSessionId, false, "GameGroundZoneInfo.ZoneSessionId", 0)
	Base.WritePrimitive(writer, val.GadgetUId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.TaskId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, Base.CheckEnum(val.StartReason, 106, 0), writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.GameTypeRandom, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, Base.CheckEnum(val.SyncReason, 107, 0), writer.WriteByte, 0)
	Base.WritePrimitive(writer, Base.CheckEnum(val.ZoneType, 108, 0), writer.WriteByte, 0)
	Base.WritePrimitive(writer, Base.CheckEnum(val.ZoneState, 109, 0), writer.WriteByte, 0)
	Base.WriteList7Bit(writer, val.ParticipantInfos, Base.WriteComplexWrap(Auto.WriteGameGroundParticipantInfo, "GameGroundParticipantInfo", true), nil, "ParticipantInfos", true, 0, nil)
	Base.WriteStruct(writer, val.CountDownInfo, Auto.WriteGameGroundZoneCountDownInfo, "CountDownInfo")
end

function Auto.WriteGamePrepareInfo(writer, val)
	Base.WritePrimitive(writer, val.PlayerIndex, writer.WriteInt32, 0)
	Base.WriteList7Bit(writer, val.Points, writer.WriteInt32, 0, "Points", false, 0, nil)
	Base.WriteList7Bit(writer, val.PlayerNames, Base.WriteStringWrap(false, "PlayerNames", 0), nil, "PlayerNames", false, 0, nil)
	Base.WriteList7Bit(writer, val.NpcMahjongIds, writer.WriteUInt32, 0, "NpcMahjongIds", false, 0, nil)
	Base.WriteList7Bit(writer, val.NpcCultivationIds, writer.WriteUInt32, 0, "NpcCultivationIds", false, 0, nil)
	Base.WriteStruct(writer, val.GameSetting, Auto.WriteSimpleGameSetting, "GameSetting")
end

function Auto.WriteGameServerInfo(writer, val)
	writer:WriteString(val.ClientListenIp, false, "GameServerInfo.ClientListenIp", 0)
	Base.WritePrimitive(writer, val.ClientListenPort, writer.WriteInt32, 0)
	writer:WriteString(val.Token, false, "GameServerInfo.Token", 0)
end

function Auto.WriteGangBossFullDetails(writer, val)
	Base.WriteComplex(writer, val.full, Auto.WritePlayerInfoJobGangBoss, "full", false)
	Base.WritePrimitive(writer, val.CurrentBattleAgentCount, writer.WriteInt32, 0)
end

function Auto.WriteGangMembersInfos(writer, val)
	Base.WritePrimitive(writer, val.TemplateId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.IsUnlock, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.NextReviveTimeStamp, writer.WriteDouble, 0)
	Base.WritePrimitive(writer, val.InstanceId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.HpPercent, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.IsDead, writer.WriteBoolean, false)
end

function Auto.WriteGetInVehicleCommandData(writer, val)
	Base.WritePrimitive(writer, val.VehicleId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.SeatIndex, writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.HasDoorInteract, writer.WriteBoolean, false)
	Base.WriteList7Bit(writer, val.Distances, Base.WriteStructWrap(Auto.WriteRangeMoveType, "Distances"), nil, "Distances", true, 0, nil)
	Base.WritePrimitive(writer, Base.CheckEnum(val.DataSource, 97, 0), writer.WriteInt16, 0)
end

function Auto.WriteGetOutVehicleCommandData(writer, val)
	Base.WritePrimitive(writer, Base.CheckEnum(val.DataSource, 97, 0), writer.WriteInt16, 0)
end

function Auto.WriteGetSitUpCommandData(writer, val)
	Base.WritePrimitive(writer, Base.CheckEnum(val.DataSource, 97, 0), writer.WriteInt16, 0)
end

function Auto.WriteGlueParticipantInfo(writer, val)
	Base.WritePrimitive(writer, val.Pid, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.NpcCultivationId, writer.WriteUInt32, 0)
	Base.WriteComplex(writer, val.AIAgentInfo, Auto.WriteLinkAIAgentInfo, "AIAgentInfo", true)
	Base.WritePrimitive(writer, val.AgentInstanceId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.VehicleInstanceId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.SeatIndex, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.IsReady, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.IsPlayAgain, writer.WriteBoolean, false)
end

function Auto.WriteGlueZoneInfo(writer, val)
	writer:WriteString(val.ZoneSessionId, false, "GlueZoneInfo.ZoneSessionId", 0)
	Base.WritePrimitive(writer, val.GadgetUId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.TaskId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, Base.CheckEnum(val.StartReason, 106, 0), writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.GameTypeRandom, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, Base.CheckEnum(val.SyncReason, 107, 0), writer.WriteByte, 0)
	Base.WritePrimitive(writer, Base.CheckEnum(val.ZoneType, 108, 0), writer.WriteByte, 0)
	Base.WritePrimitive(writer, Base.CheckEnum(val.ZoneState, 109, 0), writer.WriteByte, 0)
	Base.WriteList7Bit(writer, val.ParticipantInfos, Base.WriteComplexWrap(Auto.WriteGameGroundParticipantInfo, "GameGroundParticipantInfo", true), nil, "ParticipantInfos", true, 0, nil)
	Base.WriteStruct(writer, val.CountDownInfo, Auto.WriteGameGroundZoneCountDownInfo, "CountDownInfo")
end

function Auto.WriteGmBehaviorKV(writer, val)
	writer:WriteString(val.Key, false, "GmBehaviorKV.Key", 0)
	writer:WriteString(val.Value, false, "GmBehaviorKV.Value", 0)
end

function Auto.WriteGmCreateNpcOptionData(writer, val)
	Base.WritePrimitive(writer, val.ActionId, writer.WriteUInt32, 0)
end

function Auto.WriteGmCreatePedData(writer, val)
	Base.WritePrimitive(writer, val.AgentId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.UrbanDiversityId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.Personality, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.SexType, writer.WriteUInt32, 0)
	Base.WriteList7Bit(writer, val.Usages, writer.WriteUInt32, 0, "Usages", true, 0, nil)
	Base.WriteList7Bit(writer, val.Crimes, writer.WriteUInt32, 0, "Crimes", true, 0, nil)
end

function Auto.WriteGmEnemyStrategyInfo(writer, val)
	Base.WriteList7Bit(writer, val.SkillIds, writer.WriteUInt32, 0, "SkillIds", false, 0, nil)
end

function Auto.WriteGmLockTargetRadius(writer, val)
	writer:WriteString(val.AiName, false, "GmLockTargetRadius.AiName", 0)
	Base.WritePrimitive(writer, val.Radius, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.BackRadius, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.LookUpAngle, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.LookDownAngle, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.EyeHeight, writer.WriteSingle, 0)
end

function Auto.WriteGmQueryObjectRoot(writer, val)
	Base.WritePrimitive(writer, val.Id, writer.WriteInt32, 0)
	writer:WriteString(val.Name, true, "GmQueryObjectRoot.Name", 0)
	Base.WritePrimitive(writer, val.IsActive, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.IsStatic, writer.WriteBoolean, false)
	writer:WriteString(val.Position, true, "GmQueryObjectRoot.Position", 0)
	writer:WriteString(val.LocalPosition, true, "GmQueryObjectRoot.LocalPosition", 0)
	writer:WriteString(val.Rotation, true, "GmQueryObjectRoot.Rotation", 0)
	writer:WriteString(val.LocalRotation, true, "GmQueryObjectRoot.LocalRotation", 0)
	writer:WriteString(val.Scale, true, "GmQueryObjectRoot.Scale", 0)
	writer:WriteString(val.LocalScale, true, "GmQueryObjectRoot.LocalScale", 0)
	writer:WriteString(val.Path, true, "GmQueryObjectRoot.Path", 0)
	writer:WriteString(val.Layer, true, "GmQueryObjectRoot.Layer", 0)
	Base.WriteList(writer, val.Components, Base.WriteComplexWrap(Auto.WriteQueryComponentInfo, "QueryComponentInfo", true), nil, "Components", true, 0, nil)
end

function Auto.WriteGmQuerySceneInfo(writer, val)
	writer:WriteString(val.Name, true, "GmQuerySceneInfo.Name", 0)
	Base.WriteList(writer, val.Objects, Base.WriteComplexWrap(Auto.WriteGmQuerySceneObjectInfo, "GmQuerySceneObjectInfo", false), nil, "Objects", false, 0, nil)
end

function Auto.WriteGmQuerySceneObjectInfo(writer, val)
	Base.WritePrimitive(writer, val.Id, writer.WriteInt32, 0)
	writer:WriteString(val.Name, true, "GmQuerySceneObjectInfo.Name", 0)
	Base.WritePrimitive(writer, val.IsActive, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.Leaf, writer.WriteBoolean, false)
end

function Auto.WriteGomokuBoardCap(writer, val)
	Base.WritePrimitive(writer, val.x, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.y, writer.WriteUInt32, 0)
end

function Auto.WriteGomokuBoardRow(writer, val)
	Base.WriteList7Bit(writer, val.PieceBoardRow, writer.WriteByte, 0, "PieceBoardRow", false, 0, nil)
end

function Auto.WriteGomokuParticipantInfo(writer, val)
	Base.WritePrimitive(writer, val.Pid, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.NpcCultivationId, writer.WriteUInt32, 0)
	Base.WriteComplex(writer, val.AIAgentInfo, Auto.WriteLinkAIAgentInfo, "AIAgentInfo", true)
	Base.WritePrimitive(writer, val.AgentInstanceId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.VehicleInstanceId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.SeatIndex, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.IsReady, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.IsPlayAgain, writer.WriteBoolean, false)
end

function Auto.WriteGomokuParticipantScoreInfo(writer, val)
	Base.WriteList7Bit(writer, val.RecordInfo, Base.WriteComplexWrap(Auto.WriteGomokuPiece, "GomokuPiece", false), nil, "RecordInfo", false, 0, nil)
	Base.WriteDict7Bit(writer, val.GomokuSkillInfo, writer.WriteUInt32, Base.WriteComplexWrap(Auto.WriteGomokuSkill, "GomokuSkill", false), nil, "GomokuSkillInfo", false, 0)
end

function Auto.WriteGomokuPiece(writer, val)
	Base.WritePrimitive(writer, val.X, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.Y, writer.WriteUInt32, 0)
end

function Auto.WriteGomokuScoreInfo(writer, val)
	Base.WriteList7Bit(writer, val.PieceBoard, Base.WriteComplexWrap(Auto.WriteGomokuBoardRow, "GomokuBoardRow", false), nil, "PieceBoard", false, 0, nil)
	Base.WriteList7Bit(writer, val.CapList, Base.WriteComplexWrap(Auto.WriteGomokuBoardCap, "GomokuBoardCap", false), nil, "CapList", false, 0, nil)
	Base.WriteDict7Bit(writer, val.GomokuParticipantDict, writer.WriteInt32, Base.WriteComplexWrap(Auto.WriteGomokuParticipantScoreInfo, "GomokuParticipantScoreInfo", false), nil, "GomokuParticipantDict", false, 0)
	Base.WritePrimitive(writer, val.Winner, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.CanUseSkill, writer.WriteBoolean, false)
end

function Auto.WriteGomokuSettleData(writer, val)
	Base.WritePrimitive(writer, val.Rank, writer.WriteUInt32, 0)
end

function Auto.WriteGomokuSkill(writer, val)
	Base.WritePrimitive(writer, val.LastestCastRound, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.IsCasting, writer.WriteBoolean, false)
end

function Auto.WriteGomokuSkillExtraParam(writer, val)
	Base.WritePrimitive(writer, val.x, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.y, writer.WriteUInt32, 0)
end

function Auto.WriteGomokuZoneInfo(writer, val)
	Base.WritePrimitive(writer, Base.CheckEnum(val.GameType, 163, 0), writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.CurrentRound, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.CurrentTurn, writer.WriteInt32, 0)
	Base.WriteComplex(writer, val.ScoreInfo, Auto.WriteGomokuScoreInfo, "ScoreInfo", false)
	writer:WriteString(val.ZoneSessionId, false, "GomokuZoneInfo.ZoneSessionId", 0)
	Base.WritePrimitive(writer, val.GadgetUId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.TaskId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, Base.CheckEnum(val.StartReason, 106, 0), writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.GameTypeRandom, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, Base.CheckEnum(val.SyncReason, 107, 0), writer.WriteByte, 0)
	Base.WritePrimitive(writer, Base.CheckEnum(val.ZoneType, 108, 0), writer.WriteByte, 0)
	Base.WritePrimitive(writer, Base.CheckEnum(val.ZoneState, 109, 0), writer.WriteByte, 0)
	Base.WriteList7Bit(writer, val.ParticipantInfos, Base.WriteComplexWrap(Auto.WriteGameGroundParticipantInfo, "GameGroundParticipantInfo", true), nil, "ParticipantInfos", true, 0, nil)
	Base.WriteStruct(writer, val.CountDownInfo, Auto.WriteGameGroundZoneCountDownInfo, "CountDownInfo")
end

function Auto.WriteGridAOIDecrease(writer, val)
	Base.WriteList7Bit(writer, val.SectorIdList, writer.WriteInt32, 0, "SectorIdList", true, 0, nil)
	Base.WriteList7Bit(writer, val.StandardIndexList, Base.WriteStructWrap(Auto.WriteGridIndex, "StandardIndexList"), nil, "StandardIndexList", false, 0, nil)
	Base.WriteList7Bit(writer, val.ExceptIds, writer.WriteUInt64, 0, "ExceptIds", false, 0, nil)
end

function Auto.WriteGridIndex(writer, val)
	Base.WritePrimitive(writer, val.X, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.Z, writer.WriteInt32, 0)
end

function Auto.WriteGymPlayResult(writer, val)
	Base.WritePrimitive(writer, val.Level, writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.ExerciseId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.Score, writer.WriteSingle, 0)
end

function Auto.WriteHUDRecommendInfo(writer, val)
	Base.WritePrimitive(writer, val.ConfigId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.ExpireTime, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.Read, writer.WriteBoolean, false)
end

function Auto.WriteHackerBatteryCurrentAndTotalCount(writer, val)
	Base.WritePrimitive(writer, val.BatteryTotalCount, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.BatteryCurrentCount, writer.WriteUInt32, 0)
end

function Auto.WriteHackerPostInfo(writer, val)
	Base.WritePrimitive(writer, val.Id, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, Base.CheckEnum(val.State, 164, 0), writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.HaveRead, writer.WriteBoolean, false)
end

function Auto.WriteHideAndSeekSettleData(writer, val)
	Base.WritePrimitive(writer, val.SurvivalDuration, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.CaptureCount, writer.WriteUInt32, 0)
end

function Auto.WriteHitPredictData(writer, val)
	Base.WritePrimitive(writer, val.TargetId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.HitPredictId, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.PredictorId, writer.WriteUInt64, 0)
end

function Auto.WriteHitSomethingCommandData(writer, val)
	Base.WritePrimitive(writer, val.HitForce, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.HitRadius, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.HitPart, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.SecondHitPart, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.HitLayer, writer.WriteInt32, 0)
	Base.WriteStruct(writer, val.HitTiming, Auto.WritePlotMinMaxRange, "HitTiming")
	Base.WriteStruct(writer, val.Target, Auto.WriteClientActionTarget, "Target")
	Base.WritePrimitive(writer, val.AnimId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.SelectedActionIndex, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.Speed, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.UseRemapping, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.CycleNum, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, Base.CheckEnum(val.RemappingLeg, 103, 0), writer.WriteByte, 0)
	Base.WriteStruct(writer, val.StartPosition, Auto.WriteUXVector3, "StartPosition")
	Base.WriteStruct(writer, val.StartDirection, Auto.WriteUXVector3, "StartDirection")
	Base.WritePrimitive(writer, val.AutoRemapping, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, Base.CheckEnum(val.AutoRemappingMoveType, 104, 0), writer.WriteByte, 0)
	Base.WritePrimitive(writer, Base.CheckEnum(val.DataSource, 97, 0), writer.WriteInt16, 0)
end

function Auto.WriteHouseAddFurnitureResult(writer, val)
	Base.WriteComplex(writer, val.PlacedFurnitureInfo, Auto.WritePlacedFurnitureInfo, "PlacedFurnitureInfo", true)
	Base.WriteComplex(writer, val.ShowcaseData, Auto.WriteHouseFashionShowcaseData, "ShowcaseData", true)
end

function Auto.WriteHouseFashionShowcaseData(writer, val)
	Base.WritePrimitive(writer, val.FurnitureId, writer.WriteUInt32, 0)
	Base.WriteDict(writer, val.Models, writer.WriteUInt32, Base.WriteComplexWrap(Auto.WriteHouseFashionShowcaseModel, "HouseFashionShowcaseModel", false), nil, "Models", false, 0)
end

function Auto.WriteHouseFashionShowcaseModel(writer, val)
	Base.WritePrimitive(writer, val.FashionInstanceId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.ShowcaseId, writer.WriteUInt32, 0)
	Base.WriteComplex(writer, val.FashionData, Auto.WriteSpiritWearFashionsInfo, "FashionData", false)
end

function Auto.WriteHouseFenestrationData(writer, val)
	Base.WritePrimitive(writer, val.Type, writer.WriteUInt32, 0)
	Base.WriteStruct(writer, val.CenterWS, Auto.WriteUXVector3, "CenterWS")
	Base.WriteStruct(writer, val.DirectionWS, Auto.WriteUXVector3, "DirectionWS")
	Base.WritePrimitive(writer, val.PrefabID, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.PlacedInstanceId, writer.WriteUInt64, 0)
	Base.WriteStruct(writer, val.Edge, Auto.WriteUXVector2Int, "Edge")
	Base.WritePrimitive(writer, val.GadgetInstanceId, writer.WriteUInt64, 0)
end

function Auto.WriteHouseFloorsData(writer, val)
	Base.WriteDict(writer, val.Floors, writer.WriteUInt64, Base.WriteComplexWrap(Auto.WriteHouseWallFloorValue, "HouseWallFloorValue", false), nil, "Floors", false, 0)
end

function Auto.WriteHouseFurnitureGadgetMapping(writer, val)
	Base.WriteDict7Bit(writer, val.placedID2GadgetInstanceID, writer.WriteUInt64, writer.WriteUInt64, 0, "placedID2GadgetInstanceID", false, RpcLengthLimits.HouseFurnitureGadgetMapping_placedID2GadgetInstanceID)
end

function Auto.WriteHouseFurnitureModification(writer, val)
	Base.WritePrimitive(writer, val.floor, writer.WriteUInt32, 0)
	Base.WriteList7Bit(writer, val.AddPlacedFurnitureInfos, Base.WriteStructWrap(Auto.WriteAddPlacedFurnitureInfo, "AddPlacedFurnitureInfos"), nil, "AddPlacedFurnitureInfos", true, RpcLengthLimits.HouseFurnitureModification_AddPlacedFurnitureInfos, nil)
	Base.WriteList7Bit(writer, val.ChangePlacedFurnitureInfos, Base.WriteStructWrap(Auto.WriteChangePlacedFurnitureInfo, "ChangePlacedFurnitureInfos"), nil, "ChangePlacedFurnitureInfos", true, RpcLengthLimits.HouseFurnitureModification_ChangePlacedFurnitureInfos, nil)
	Base.WriteList7Bit(writer, val.RemovePlacedInstanceIds, writer.WriteUInt64, 0, "RemovePlacedInstanceIds", true, RpcLengthLimits.HouseFurnitureModification_RemovePlacedInstanceIds, nil)
end

function Auto.WriteHouseFurnitureModificationResult(writer, val)
	Base.WriteList7Bit(writer, val.PlacedFurnitureInfos, Base.WriteComplexWrap(Auto.WritePlacedFurnitureInfo, "PlacedFurnitureInfo", true), nil, "PlacedFurnitureInfos", true, 0, nil)
	Base.WriteDict7Bit(writer, val.ShowcaseDict, writer.WriteUInt64, Base.WriteComplexWrap(Auto.WriteHouseFashionShowcaseData, "HouseFashionShowcaseData", false), nil, "ShowcaseDict", true, RpcLengthLimits.HouseFurnitureModificationResult_ShowcaseDict)
end

function Auto.WriteHouseFurniturePlacementStatistics(writer, val)
	Base.WriteDict(writer, val.FurniturePlacedCountDict, writer.WriteUInt32, writer.WriteUInt32, 0, "FurniturePlacedCountDict", false, 0)
	Base.WriteDict(writer, val.SubTypePlacedCountDict, writer.WriteUInt32, writer.WriteUInt32, 0, "SubTypePlacedCountDict", false, 0)
end

function Auto.WriteHouseInfo(writer, val)
	Base.WritePrimitive(writer, val.HouseId, writer.WriteUInt32, 0)
	Base.WriteDict(writer, val.ParkingSpaceVehicleIdDict, writer.WriteInt32, writer.WriteUInt32, 0, "ParkingSpaceVehicleIdDict", false, 0)
	Base.WriteDict(writer, val.FloorBuildInfoDict, writer.WriteUInt32, Base.WriteComplexWrap(Auto.WriteIndoorBuildInfo, "IndoorBuildInfo", false), nil, "FloorBuildInfoDict", false, 0)
	Base.WritePrimitive(writer, val.CurPlacedFurnitureInstanceId, writer.WriteUInt64, 0)
	Base.WriteComplex(writer, val.WallInfo, Auto.WriteHouseWallInfo, "WallInfo", false)
	Base.WriteComplex(writer, val.Configuration, Auto.WritePlayerSingleHouseConfiguration, "Configuration", false)
	Base.WriteDict(writer, val.FashionShowcaseDict, writer.WriteUInt64, Base.WriteComplexWrap(Auto.WriteHouseFashionShowcaseData, "HouseFashionShowcaseData", false), nil, "FashionShowcaseDict", false, 0)
	Base.WriteComplex(writer, val.PlacementStatistics, Auto.WriteHouseFurniturePlacementStatistics, "PlacementStatistics", false)
end

function Auto.WriteHouseModification(writer, val)
	Base.WriteList7Bit(writer, val.FurnitureModification, Base.WriteStructWrap(Auto.WriteHouseFurnitureModification, "FurnitureModification"), nil, "FurnitureModification", true, RpcLengthLimits.HouseModification_FurnitureModification, nil)
	Base.WriteComplex(writer, val.WallModification, Auto.WriteHouseWallModification, "WallModification", true)
end

function Auto.WriteHouseModificationResult(writer, val)
	Base.WriteComplex(writer, val.Wall, Auto.WriteHouseWallModificationResult, "Wall", true)
	Base.WriteComplex(writer, val.Furniture, Auto.WriteHouseFurnitureModificationResult, "Furniture", true)
end

function Auto.WriteHouseMoveParkingSpaceInfo(writer, val)
	Base.WritePrimitive(writer, val.VehicleId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.HouseId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.ParkingSpaceIndex, writer.WriteInt32, 0)
end

function Auto.WriteHouseParkingEntityBinding(writer, val)
	Base.WritePrimitive(writer, val.VehicleId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.EntityId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.ParkingSpaceIndex, writer.WriteInt32, 0)
end

function Auto.WriteHouseParkingInfo(writer, val)
	Base.WritePrimitive(writer, val.HouseId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.VehicleId, writer.WriteUInt32, 0)
end

function Auto.WriteHouseShowcaseSwitchResult(writer, val)
	Base.WritePrimitive(writer, val.ModelIndex, writer.WriteUInt32, 0)
	Base.WriteComplex(writer, val.FashionInfo, Auto.WriteSpiritWearFashionsInfo, "FashionInfo", false)
end

function Auto.WriteHouseVehicleParkingInfo(writer, val)
	Base.WritePrimitive(writer, val.HouseId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.VehicleId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.ParkingSpaceIndex, writer.WriteInt32, 0)
end

function Auto.WriteHouseWallEdgeEntry(writer, val)
	Base.WritePrimitive(writer, val.From, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.To, writer.WriteInt32, 0)
	Base.WriteStruct(writer, val.Data, Auto.WriteHouseWallEdgeValue, "Data")
end

function Auto.WriteHouseWallEdgeTexData(writer, val)
	Base.WritePrimitive(writer, val.Left, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.Right, writer.WriteUInt32, 0)
end

function Auto.WriteHouseWallEdgeValue(writer, val)
	Base.WritePrimitive(writer, val.Tag, writer.WriteUInt32, 0)
	Base.WriteComplex(writer, val.Tex, Auto.WriteHouseWallEdgeTexData, "Tex", true)
end

function Auto.WriteHouseWallFloorKey(writer, val)
	Base.WritePrimitive(writer, val.X, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.Y, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.FloorLevel, writer.WriteUInt32, 0)
end

function Auto.WriteHouseWallFloorMaskData(writer, val)
	Base.WritePrimitive(writer, val.HypoTenuseMaskA, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.HypoTenuseMaskB, writer.WriteUInt32, 0)
end

function Auto.WriteHouseWallFloorModEntry(writer, val)
	Base.WriteStruct(writer, val.Key, Auto.WriteHouseWallFloorKey, "Key")
	Base.WriteStruct(writer, val.Value, Auto.WriteHouseWallFloorValue, "Value")
end

function Auto.WriteHouseWallFloorTexData(writer, val)
	Base.WritePrimitive(writer, val.Top, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.Bottom, writer.WriteUInt32, 0)
end

function Auto.WriteHouseWallFloorValue(writer, val)
	Base.WriteComplex(writer, val.Mask, Auto.WriteHouseWallFloorMaskData, "Mask", true)
	Base.WriteComplex(writer, val.Tex, Auto.WriteHouseWallFloorTexData, "Tex", true)
end

function Auto.WriteHouseWallInfo(writer, val)
	Base.WriteDict(writer, val.Nodes, writer.WriteInt32, Base.WriteComplexWrap(Auto.WriteUXVector3, "UXVector3", false), nil, "Nodes", false, 0)
	Base.WriteDict(writer, val.Edges, writer.WriteUInt64, Base.WriteComplexWrap(Auto.WriteHouseWallEdgeValue, "HouseWallEdgeValue", false), nil, "Edges", false, 0)
	Base.WriteDict(writer, val.Floors, Base.WriteStringWrap(false, "Floors", 0), Base.WriteComplexWrap(Auto.WriteHouseWallFloorValue, "HouseWallFloorValue", false), nil, "Floors", false, 0)
	Base.WriteDict(writer, val.FenestrationDict, writer.WriteUInt64, Base.WriteComplexWrap(Auto.WriteHouseFenestrationData, "HouseFenestrationData", false), nil, "FenestrationDict", false, 0)
	Base.WriteDict(writer, val.FloorsByLevel, writer.WriteInt32, Base.WriteComplexWrap(Auto.WriteHouseFloorsData, "HouseFloorsData", false), nil, "FloorsByLevel", false, 0)
end

function Auto.WriteHouseWallModification(writer, val)
	Base.WriteList7Bit(writer, val.DelNodeList, writer.WriteInt32, 0, "DelNodeList", true, RpcLengthLimits.HouseWallModification_DelNodeList, nil)
	Base.WriteList7Bit(writer, val.AddNodeList, Base.WriteStructWrap(Auto.WriteHouseWallNodeEntry, "AddNodeList"), nil, "AddNodeList", true, RpcLengthLimits.HouseWallModification_AddNodeList, nil)
	Base.WriteList7Bit(writer, val.ModNodeList, Base.WriteStructWrap(Auto.WriteHouseWallNodeEntry, "ModNodeList"), nil, "ModNodeList", true, RpcLengthLimits.HouseWallModification_ModNodeList, nil)
	Base.WriteList7Bit(writer, val.DelEdgeList, writer.WriteUInt64, 0, "DelEdgeList", true, RpcLengthLimits.HouseWallModification_DelEdgeList, nil)
	Base.WriteList7Bit(writer, val.AddEdgeList, Base.WriteStructWrap(Auto.WriteHouseWallEdgeEntry, "AddEdgeList"), nil, "AddEdgeList", true, RpcLengthLimits.HouseWallModification_AddEdgeList, nil)
	Base.WriteList7Bit(writer, val.ModEdgeList, Base.WriteStructWrap(Auto.WriteHouseWallEdgeEntry, "ModEdgeList"), nil, "ModEdgeList", true, RpcLengthLimits.HouseWallModification_ModEdgeList, nil)
	Base.WriteList7Bit(writer, val.DelFloorList, Base.WriteStructWrap(Auto.WriteHouseWallFloorKey, "DelFloorList"), nil, "DelFloorList", true, RpcLengthLimits.HouseWallModification_DelFloorList, nil)
	Base.WriteList7Bit(writer, val.AddFloorList, Base.WriteStructWrap(Auto.WriteHouseWallFloorModEntry, "AddFloorList"), nil, "AddFloorList", true, RpcLengthLimits.HouseWallModification_AddFloorList, nil)
	Base.WriteList7Bit(writer, val.ModFloorList, Base.WriteStructWrap(Auto.WriteHouseWallFloorModEntry, "ModFloorList"), nil, "ModFloorList", true, RpcLengthLimits.HouseWallModification_ModFloorList, nil)
	Base.WriteList7Bit(writer, val.DelFenestrationList, writer.WriteUInt64, 0, "DelFenestrationList", true, RpcLengthLimits.HouseWallModification_DelFenestrationList, nil)
	Base.WriteList7Bit(writer, val.AddFenestrationList, Base.WriteComplexWrap(Auto.WriteHouseFenestrationData, "HouseFenestrationData", true), nil, "AddFenestrationList", true, RpcLengthLimits.HouseWallModification_AddFenestrationList, nil)
	Base.WriteList7Bit(writer, val.ModFenestrationList, Base.WriteComplexWrap(Auto.WriteHouseFenestrationData, "HouseFenestrationData", true), nil, "ModFenestrationList", true, RpcLengthLimits.HouseWallModification_ModFenestrationList, nil)
end

function Auto.WriteHouseWallModificationResult(writer, val)
	Base.WriteList7Bit(writer, val.AddedFenestrations, Base.WriteComplexWrap(Auto.WriteHouseFenestrationData, "HouseFenestrationData", true), nil, "AddedFenestrations", true, 0, nil)
end

function Auto.WriteHouseWallNodeEntry(writer, val)
	Base.WritePrimitive(writer, val.NodeId, writer.WriteInt32, 0)
	Base.WriteStruct(writer, val.Position, Auto.WriteUXVector3, "Position")
end

function Auto.WriteHousesInfo(writer, val)
	Base.WriteList(writer, val.HouseInfoList, Base.WriteComplexWrap(Auto.WriteHouseInfo, "HouseInfo", false), nil, "HouseInfoList", false, 0, nil)
	Base.WriteList(writer, val.NotParkingSpaceVehicleIdList, writer.WriteUInt32, 0, "NotParkingSpaceVehicleIdList", false, 0, nil)
	Base.WriteDict(writer, val.FurnitureInfoDict, writer.WriteUInt32, Base.WriteComplexWrap(Auto.WriteFurnitureInfo, "FurnitureInfo", false), nil, "FurnitureInfoDict", false, 0)
	Base.WriteComplex(writer, val.Configuration, Auto.WritePlayerHouseConfiguration, "Configuration", false)
	Base.WritePrimitive(writer, val.NextFashionInstanceId, writer.WriteUInt32, 0)
end

function Auto.WriteIKMotionCommandData(writer, val)
	Base.WritePrimitive(writer, val.IKTargetBone, writer.WriteInt32, 0)
	Base.WriteStruct(writer, val.Target, Auto.WriteClientActionTarget, "Target")
	Base.WritePrimitive(writer, val.AnimId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.SelectedActionIndex, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.Speed, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.UseRemapping, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.CycleNum, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, Base.CheckEnum(val.RemappingLeg, 103, 0), writer.WriteByte, 0)
	Base.WriteStruct(writer, val.StartPosition, Auto.WriteUXVector3, "StartPosition")
	Base.WriteStruct(writer, val.StartDirection, Auto.WriteUXVector3, "StartDirection")
	Base.WritePrimitive(writer, val.AutoRemapping, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, Base.CheckEnum(val.AutoRemappingMoveType, 104, 0), writer.WriteByte, 0)
	Base.WritePrimitive(writer, Base.CheckEnum(val.DataSource, 97, 0), writer.WriteInt16, 0)
end

function Auto.WriteImSimpleData(writer, val)
	Base.WriteList7Bit(writer, val.ChatGroupList, Base.WriteComplexWrap(Auto.WriteChatGroupClient, "ChatGroupClient", false), nil, "ChatGroupList", false, 0, nil)
	Base.WritePrimitive(writer, val.MuteEndTime, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.SoftMuteEndTime, writer.WriteUInt32, 0)
	Base.WriteList7Bit(writer, val.FavoriteEmojiList, Base.WriteStringWrap(false, "FavoriteEmojiList", 0), nil, "FavoriteEmojiList", false, 0, nil)
end

function Auto.WriteImageModerationResult(writer, val)
	writer:WriteString(val.ObjectKey, false, "ImageModerationResult.ObjectKey", 0)
	Base.WritePrimitive(writer, val.Pass, writer.WriteBoolean, false)
end

function Auto.WriteInTurnOperation(writer, val)
	Base.WritePrimitive(writer, Base.CheckEnum(val.Type, 165, 0), writer.WriteByte, 0)
	Base.WriteStruct(writer, val.Tile, Auto.WriteTile, "Tile")
	Base.WriteStruct(writer, val.Meld, Auto.WriteOpenMeld, "Meld")
	Base.WriteList7Bit(writer, val.RichiAvailableTiles, Base.WriteStructWrap(Auto.WriteTile, "RichiAvailableTiles"), nil, "RichiAvailableTiles", false, 0, nil)
end

function Auto.WriteIndoorBuildInfo(writer, val)
	Base.WriteComplex(writer, val.Root, Auto.WritePlacedFurnitureInfo, "Root", false)
end

function Auto.WriteInspireHubGamePlayInfo(writer, val)
	Base.WritePrimitive(writer, val.CfgId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.Weight, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.Category, writer.WriteUInt32, 0)
end

function Auto.WriteInspireHubGamePlayRankData(writer, val)
	Base.WritePrimitive(writer, val.CfgId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.Score, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.BaseScore, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.AdditionalScore, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.Category, writer.WriteUInt32, 0)
end

function Auto.WriteInspireHubGamePlayRankList(writer, val)
	Base.WritePrimitive(writer, val.RankType, writer.WriteUInt32, 0)
	Base.WriteList7Bit(writer, val.RankList, Base.WriteComplexWrap(Auto.WriteInspireHubGamePlayRankData, "InspireHubGamePlayRankData", false), nil, "RankList", false, 0, nil)
end

function Auto.WriteIntList(writer, val)
	Base.WriteList(writer, val.Value, writer.WriteInt32, 0, "Value", false, 0, nil)
end

function Auto.WriteIntPayload(writer, val)
	Base.WritePrimitive(writer, val.V, writer.WriteInt32, 0)
end

function Auto.WriteInteractCmdData(writer, val)
	Base.WritePrimitive(writer, val.CmdType, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.sender, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.receiver, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.broadCastType, writer.WriteInt32, 0)
	Base.WriteList7Bit(writer, val.CommandData, writer.WriteByte, 0, "CommandData", true, RpcLengthLimits.InteractCmdData_CommandData, val.CommandDataLen)
	writer:WriteString(val.stringParam1, true, "InteractCmdData.stringParam1", RpcLengthLimits.InteractCmdData_stringParam1)
	writer:WriteString(val.stringParam2, true, "InteractCmdData.stringParam2", RpcLengthLimits.InteractCmdData_stringParam2)
end

function Auto.WriteInteractCommandData(writer, val)
	Base.WriteStruct(writer, val.Target, Auto.WriteClientActionTarget, "Target")
	Base.WritePrimitive(writer, val.InteractType, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, Base.CheckEnum(val.DataSource, 97, 0), writer.WriteInt16, 0)
end

function Auto.WriteInteractIconItem(writer, val)
	Base.WritePrimitive(writer, val.InteractingId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.Index, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.EventId, writer.WriteUInt32, 0)
end

function Auto.WriteInterrogationInterruptInfo(writer, val)
	Base.WritePrimitive(writer, val.CaseId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.InterruptReason, writer.WriteUInt32, 0)
end

function Auto.WriteInterrogationResults(writer, val)
	Base.WriteComplex(writer, val.aiResult, Auto.WriteAIInterrogationSettlement, "aiResult", true)
end

function Auto.WriteInviteRideNpcInteractItem(writer, val)
	Base.WritePrimitive(writer, val.Index, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.Sprite, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.LabelId, writer.WriteUInt32, 0)
end

function Auto.WriteItemCountInfo(writer, val)
	Base.WritePrimitive(writer, val.TemplateId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.Count, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.Quality, writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.Tags, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.IsBind, writer.WriteBoolean, false)
end

function Auto.WriteItemCountLimitInfo(writer, val)
	Base.WritePrimitive(writer, val.ItemId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.Count, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.NextRefreshTime, writer.WriteUInt32, 0)
end

function Auto.WriteItemDestructibleData(writer, val)
	Base.WritePrimitive(writer, val.WorldLifeGameInstanceId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.FishGroupId, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.SceneItemCfgId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.ReleaserId, writer.WriteUInt64, 0)
	Base.WriteStruct(writer, val.Position, Auto.WriteUXVector3, "Position")
	Base.WriteStruct(writer, val.Facing, Auto.WriteUXVector3, "Facing")
	Base.WritePrimitive(writer, val.LivingTime, writer.WriteSingle, 0)
end

function Auto.WriteItemShortcutInfo(writer, val)
	Base.WritePrimitive(writer, val.UniqueId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.TemplateId, writer.WriteUInt32, 0)
end

function Auto.WriteKTVMusicClientInfo(writer, val)
	Base.WritePrimitive(writer, val.MusicId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.HighScore, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.MaxCombo, writer.WriteUInt32, 0)
end

function Auto.WriteKTVMusicInfoListResult(writer, val)
	Base.WriteList7Bit(writer, val.MusicInfos, Base.WriteComplexWrap(Auto.WriteKTVMusicClientInfo, "KTVMusicClientInfo", false), nil, "MusicInfos", false, 0, nil)
end

function Auto.WriteKTVMusicResultInfo(writer, val)
	Base.WritePrimitive(writer, val.TicketId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.MusicId, writer.WriteUInt32, 0)
	Base.WriteList7Bit(writer, val.RecordInfo, writer.WriteUInt32, 0, "RecordInfo", false, RpcLengthLimits.KTVMusicResultInfo_RecordInfo, nil)
	Base.WritePrimitive(writer, val.HoldBeats, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.Score, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.MaxCombo, writer.WriteUInt32, 0)
end

function Auto.WriteKTVPackageTicket(writer, val)
	Base.WritePrimitive(writer, val.TicketId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.RemainCount, writer.WriteUInt32, 0)
end

function Auto.WriteKongInfo(writer, val)
	Base.WritePrimitive(writer, val.PlayerIndex, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.KongPlayerIndex, writer.WriteInt32, 0)
	Base.WriteStruct(writer, val.HandData, Auto.WritePlayerHandData, "HandData")
	Base.WritePrimitive(writer, val.RemainTurnTime, writer.WriteInt32, 0)
	Base.WriteList7Bit(writer, val.Operations, Base.WriteStructWrap(Auto.WriteOutTurnOperation, "Operations"), nil, "Operations", false, 0, nil)
	Base.WriteStruct(writer, val.MahjongSetData, Auto.WriteMahjongSetData, "MahjongSetData")
end

function Auto.WriteLandInfo(writer, val)
	Base.WritePrimitive(writer, val.LandId, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.CorpId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.SourceGrowState, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.TargetGrowState, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.LastWaterTime, writer.WriteDouble, 0)
	Base.WritePrimitive(writer, val.CurrentProductCount, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.LastReapTime, writer.WriteDouble, 0)
end

function Auto.WriteLeadingWayMoveCommandData(writer, val)
	Base.WritePrimitive(writer, val.PartnerId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.IsDirector, writer.WriteBoolean, false)
	Base.WriteList7Bit(writer, val.WayPoints, Base.WriteStructWrap(Auto.WriteUXVector3, "WayPoints"), nil, "WayPoints", false, 0, nil)
	Base.WriteList7Bit(writer, val.CheckPointActions, Base.WriteComplexWrap(Auto.WriteCheckPointAction, "CheckPointAction", false), nil, "CheckPointActions", false, 0, nil)
	Base.WritePrimitive(writer, Base.CheckEnum(val.MoveMethod, 104, 0), writer.WriteByte, 0)
	Base.WritePrimitive(writer, Base.CheckEnum(val.StartPace, 104, 0), writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.StartPaceDuration, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.AnimationSetId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.KeepMovingAction, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.Speed, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.MoveActionId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.MoveActionGroupId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.NotOnGround, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.TryUseRootMotion, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.LeadingBreakTurn, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.IsLeadingWay, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.DontLimitExtraMove, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.DontLimitBasicMove, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.WaitingDialogId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.MinDialogDuration, writer.WriteSingle, 0)
	Base.WriteList7Bit(writer, val.LeadingWayUrgings, Base.WriteStructWrap(Auto.WriteLeadingWayUrging, "LeadingWayUrgings"), nil, "LeadingWayUrgings", true, 0, nil)
	Base.WritePrimitive(writer, val.LeadingWayCfgId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, Base.CheckEnum(val.DataSource, 97, 0), writer.WriteInt16, 0)
end

function Auto.WriteLeadingWayUrging(writer, val)
	Base.WritePrimitive(writer, val.dialogId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.distance, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.minDuration, writer.WriteSingle, 0)
end

function Auto.WriteLifeScheduleClientMessage(writer, val)
	Base.WritePrimitive(writer, Base.CheckEnum(val.Op, 166, 0), writer.WriteByte, 0)
	Base.WritePrimitive(writer, Base.CheckEnum(val.Event, 167, 0), writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.PlayerId, writer.WriteUInt64, 0)
	writer:WriteString(val.Reason, true, "LifeScheduleClientMessage.Reason", RpcLengthLimits.LifeScheduleClientMessage_Reason)
	Base.WritePrimitive(writer, val.ActivityId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.WorldEventType, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.CorrelationId, writer.WriteUInt64, 0)
end

function Auto.WriteLifeScheduleDebugPayload(writer, val)
	writer:WriteString(val.Json, false, "LifeScheduleDebugPayload.Json", RpcLengthLimits.LifeScheduleDebugPayload_Json)
end

function Auto.WriteLifeScheduleHostEventMessage(writer, val)
	Base.WritePrimitive(writer, Base.CheckEnum(val.Event, 168, 0), writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.ActivityId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.CorrelationId, writer.WriteUInt64, 0)
end

function Auto.WriteLifeScheduleServerMessage(writer, val)
	Base.WritePrimitive(writer, Base.CheckEnum(val.NewState, 169, 0), writer.WriteInt16, 0)
	Base.WritePrimitive(writer, Base.CheckEnum(val.CauseEvent, 167, 0), writer.WriteByte, 0)
	writer:WriteString(val.Reason, true, "LifeScheduleServerMessage.Reason", RpcLengthLimits.LifeScheduleServerMessage_Reason)
	Base.WriteComplex(writer, val.ExtCtrlParam, Auto.WriteExternalControlParamDto, "ExtCtrlParam", true)
	Base.WritePrimitive(writer, val.CorrelationId, writer.WriteUInt64, 0)
end

function Auto.WriteLiftInteractBanInfo(writer, val)
	Base.WritePrimitive(writer, Base.CheckEnum(val.Type, 170, 0), writer.WriteByte, 0)
	Base.WriteList7Bit(writer, val.SpecificLevelList, writer.WriteInt32, 0, "SpecificLevelList", true, 0, nil)
end

function Auto.WriteLinkAIAgentInfo(writer, val)
	Base.WritePrimitive(writer, val.Uid, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.FightSpiritId, writer.WriteUInt32, 0)
	Base.WriteComplex(writer, val.Fashion, Auto.WriteLinkAIFashionInfo, "Fashion", true)
	writer:WriteString(val.Nickname, true, "LinkAIAgentInfo.Nickname", 0)
	Base.WritePrimitive(writer, val.NameId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.AvatarImageId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.VehicleId, writer.WriteUInt32, 0)
end

function Auto.WriteLinkAIFashionInfo(writer, val)
	Base.WritePrimitive(writer, val.SuitId, writer.WriteUInt32, 0)
	Base.WriteComplex(writer, val.WearInfo, Auto.WriteOtherPlayerSpiritWearFashionsInfo, "WearInfo", false)
end

function Auto.WriteLinkInfoClient(writer, val)
	Base.WritePrimitive(writer, val.Id, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, Base.CheckEnum(val.Mode, 9, 0), writer.WriteByte, 0)
	Base.WritePrimitive(writer, Base.CheckEnum(val.DeviceLevel, 39, 1), writer.WriteByte, 1)
	Base.WritePrimitive(writer, Base.CheckEnum(val.Tag, 21, 0), writer.WriteByte, 0)
	Base.WriteList7Bit(writer, val.Members, Base.WriteComplexWrap(Auto.WritePlayerBasicInfoVO, "PlayerBasicInfoVO", false), nil, "Members", false, 0, nil)
	Base.WriteList7Bit(writer, val.ReservePids, writer.WriteUInt64, 0, "ReservePids", false, 0, nil)
	Base.WritePrimitive(writer, val.Capacity, writer.WriteUInt32, 0)
end

function Auto.WriteLinkMemberInfo(writer, val)
	Base.WritePrimitive(writer, val.Pid, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.Index, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.JoinTime, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.IsPSNPlayer, writer.WriteBoolean, false)
end

function Auto.WriteLinkPlanningBoardMemberInfo(writer, val)
	Base.WriteDict(writer, val.MemberKeyCounts, writer.WriteUInt32, writer.WriteUInt32, 0, "MemberKeyCounts", true, 0)
	Base.WriteComplex(writer, val.TeamSettingsInfo, Auto.WriteLinkPlanningBoardTeamSettingsInfo, "TeamSettingsInfo", true)
	Base.WriteDict(writer, val.MultiPlayerIdStates, writer.WriteUInt32, writer.WriteByte, 0, "MultiPlayerIdStates", true, 0)
end

function Auto.WriteLinkPlanningBoardTeamSettingsInfo(writer, val)
	Base.WritePrimitive(writer, val.TeamLeaderSelectMultiPlayerId, writer.WriteUInt32, 0)
	Base.WriteDict(writer, val.ClientCustomDatas, writer.WriteByte, writer.WriteUInt32, 0, "ClientCustomDatas", true, RpcLengthLimits.LinkPlanningBoardTeamSettingsInfo_ClientCustomDatas)
end

function Auto.WriteLinkSimpleInfo(writer, val)
	Base.WritePrimitive(writer, val.Id, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, Base.CheckEnum(val.Mode, 9, 0), writer.WriteByte, 0)
	Base.WritePrimitive(writer, Base.CheckEnum(val.DeviceLevel, 39, 1), writer.WriteByte, 1)
	Base.WritePrimitive(writer, Base.CheckEnum(val.Tag, 21, 0), writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.PublicEventId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.LastPublicEventTime, writer.WriteUInt32, 0)
end

function Auto.WriteLinkedTimelineInfo(writer, val)
	Base.WritePrimitive(writer, val.TimelineId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, Base.CheckEnum(val.State, 171, 1), writer.WriteByte, 1)
	Base.WritePrimitive(writer, val.PlayType, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.Progress, writer.WriteDouble, 0)
end

function Auto.WriteLiveHouseQueryInfo(writer, val)
	Base.WritePrimitive(writer, val.FirstPlay, writer.WriteBoolean, false)
end

function Auto.WriteLoadingTextInfo(writer, val)
	Base.WritePrimitive(writer, val.TemplateId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.LeftTimes, writer.WriteUInt32, 0)
end

function Auto.WriteLoadingTypeInfo(writer, val)
	Base.WritePrimitive(writer, Base.CheckEnum(val.Type, 172, 0), writer.WriteByte, 0)
	Base.WriteList(writer, val.Members, writer.WriteUInt64, 0, "Members", true, 0, nil)
	Base.WritePrimitive(writer, val.Ripple, writer.WriteBoolean, false)
end

function Auto.WriteLogicAgentCommandReportData(writer, val)
	Base.WritePrimitive(writer, val.AgentId, writer.WriteUInt64, 0)
	Base.WriteList7Bit(writer, val.Data, writer.WriteByte, 0, "Data", true, RpcLengthLimits.LogicAgentCommandReportData_Data, val.Length)
	Base.WritePrimitive(writer, val.Layer, writer.WriteByte, 0)
	Base.WritePrimitive(writer, Base.CheckEnum(val.StateLayer, 173, 0), writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.Type, writer.WriteInt32, 0)
end

function Auto.WriteLogicAgentCommandSuccessData(writer, val)
	Base.WritePrimitive(writer, val.AgentId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.CommandId, writer.WriteInt32, 0)
end

function Auto.WriteLogicAgentSyncData(writer, val)
	Base.WritePrimitive(writer, val.AgentId, writer.WriteUInt64, 0)
	Base.WriteStruct(writer, val.Position, Auto.WriteUXVector3, "Position")
	Base.WriteStruct(writer, val.Rotation, Auto.WriteUXVector3, "Rotation")
end

function Auto.WriteLogicItemInfo(writer, val)
	Base.WritePrimitive(writer, val.InstanceId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.SceneItemCfgId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.EntityType, writer.WriteByte, 0)
	Base.WriteList7Bit(writer, val.EffectIds, writer.WriteInt32, 0, "EffectIds", true, 0, nil)
	Base.WriteComplex(writer, val.SpecialState, Auto.WriteLogicItemSpecialStateInfo, "SpecialState", true)
	Base.WriteComplex(writer, val.HangingInfo, Auto.WriteSceneDeviceHangingInfo, "HangingInfo", true)
	Base.WritePrimitive(writer, val.NpcChatConfigId, writer.WriteInt32, 0)
end

function Auto.WriteLogicItemSpecialStateInfo(writer, val)
	Base.WritePrimitive(writer, val.UmbrellaOpen, writer.WriteBoolean, false)
end

function Auto.WriteLogicVehicleClientInfo(writer, val)
	Base.WritePrimitive(writer, val.EntityId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.VehicleConfigId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, Base.CheckEnum(val.CreateSourceType, 174, 0), writer.WriteByte, 0)
	Base.WriteList7Bit(writer, val.Parts, Base.WriteStructWrap(Auto.WriteVehicleClientPart, "Parts"), nil, "Parts", true, 0, nil)
	Base.WritePrimitive(writer, val.SuitId, writer.WriteUInt32, 0)
	writer:WriteString(val.LicensePlate, true, "LogicVehicleClientInfo.LicensePlate", 0)
	Base.WritePrimitive(writer, val.Interactable, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.MoveToken, writer.WriteInt32, 0)
	Base.WriteStruct(writer, val.Position, Auto.WriteUXVector3, "Position")
	Base.WriteStruct(writer, val.EulerAngles, Auto.WriteUXVector3, "EulerAngles")
end

function Auto.WriteLogicVehicleUnitDebugData(writer, val)
	Base.WritePrimitive(writer, val.Id, writer.WriteUInt64, 0)
	Base.WriteList7Bit(writer, val.FineId, writer.WriteUInt32, 0, "FineId", false, 0, nil)
	Base.WriteStruct(writer, val.Position, Auto.WriteUXVector3, "Position")
end

function Auto.WriteLoginPartyInfo(writer, val)
	Base.WritePrimitive(writer, val.PartyId, writer.WriteUInt32, 0)
	Base.WriteList7Bit(writer, val.InviteNPCIds, writer.WriteUInt32, 0, "InviteNPCIds", true, 0, nil)
	Base.WritePrimitive(writer, val.Popularity, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.LikeCount, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.GiftCount, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.Duration, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.PrepareOverTime, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.PartyOverTime, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.LotteryStartTime, writer.WriteUInt32, 0)
	Base.WriteList7Bit(writer, val.LotteryResults, Base.WriteComplexWrap(Auto.WriteLotteryDrawResult, "LotteryDrawResult", true), nil, "LotteryResults", true, 0, nil)
end

function Auto.WriteLongPayload(writer, val)
	Base.WritePrimitive(writer, val.V, writer.WriteInt64, 0)
end

function Auto.WriteLookAtCommandData(writer, val)
	Base.WriteStruct(writer, val.Target, Auto.WriteClientActionTarget, "Target")
	Base.WritePrimitive(writer, val.IsOn, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.TargetType, writer.WriteInt32, 0)
	Base.WriteStruct(writer, val.TargetPosition, Auto.WriteUXVector3, "TargetPosition")
	Base.WritePrimitive(writer, val.IsKeep, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.IsFinishOnEnd, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.Duration, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.IKPriority, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.LookAtIKType, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.AgentTargetPart, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, Base.CheckEnum(val.DataSource, 97, 0), writer.WriteInt16, 0)
end

function Auto.WriteLookAtPositionData(writer, val)
	Base.WriteStruct(writer, val.Position, Auto.WriteUXVector3, "Position")
	Base.WritePrimitive(writer, val.Speed, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.ActionId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.IsImmediate, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.Uid, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.MaxTime, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.ActionUid, writer.WriteUInt32, 0)
end

function Auto.WriteLookAtTargetData(writer, val)
	Base.WritePrimitive(writer, val.ActionId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.Speed, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.IsImmediate, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.Uid, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.MaxTime, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.ActionUid, writer.WriteUInt32, 0)
end

function Auto.WriteLotteryDrawResult(writer, val)
	Base.WritePrimitive(writer, val.Pid, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.ItemId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.Count, writer.WriteUInt32, 0)
end

function Auto.WriteMahjongGameInfo(writer, val)
	Base.WritePrimitive(writer, Base.CheckEnum(val.GameState, 175, 0), writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.Round, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.Remainders, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.Banker, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.Turn, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.LastTurn, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.LastMoPaiSeatIndex, writer.WriteInt32, 0)
	Base.WriteList7Bit(writer, val.SeatInfos, Base.WriteComplexWrap(Auto.WriteSeatInfo, "SeatInfo", true), nil, "SeatInfos", true, 0, nil)
	Base.WriteList7Bit(writer, val.HuPais, Base.WriteStructWrap(Auto.WriteMjPaiInfo, "HuPais"), nil, "HuPais", true, 0, nil)
	Base.WriteList7Bit(writer, val.DoraIndicatorLs, Base.WriteStructWrap(Auto.WriteMjPaiInfo, "DoraIndicatorLs"), nil, "DoraIndicatorLs", true, 0, nil)
	Base.WriteList7Bit(writer, val.DoraLs, Base.WriteStructWrap(Auto.WriteMjPaiInfo, "DoraLs"), nil, "DoraLs", true, 0, nil)
	Base.WriteList7Bit(writer, val.UraDoraIndicatorLs, Base.WriteStructWrap(Auto.WriteMjPaiInfo, "UraDoraIndicatorLs"), nil, "UraDoraIndicatorLs", true, 0, nil)
	Base.WriteList7Bit(writer, val.UraDoraLs, Base.WriteStructWrap(Auto.WriteMjPaiInfo, "UraDoraLs"), nil, "UraDoraLs", true, 0, nil)
end

function Auto.WriteMahjongPlayerInfo(writer, val)
	Base.WritePrimitive(writer, val.Pid, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.AgentInstanceId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.Aid, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.Level, writer.WriteUInt32, 0)
	writer:WriteString(val.Name, false, "MahjongPlayerInfo.Name", 0)
	Base.WriteComplex(writer, val.PzHeadInfo, Auto.WritePersonalZoneHeadInfo, "PzHeadInfo", true)
	Base.WritePrimitive(writer, val.Score, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.SeatIndex, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.NpcMahjongId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.NpcCultivationId, writer.WriteUInt32, 0)
end

function Auto.WriteMahjongRoomInfo(writer, val)
	Base.WritePrimitive(writer, val.MahjongServerId, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.RoomId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, Base.CheckEnum(val.RoomType, 13, 0), writer.WriteByte, 0)
	Base.WritePrimitive(writer, Base.CheckEnum(val.State, 176, 0), writer.WriteByte, 0)
	Base.WriteList7Bit(writer, val.PlayerInfos, Base.WriteComplexWrap(Auto.WriteMahjongPlayerInfo, "MahjongPlayerInfo", true), nil, "PlayerInfos", true, 0, nil)
	Base.WriteList7Bit(writer, val.HasReady, writer.WriteBoolean, false, "HasReady", false, 0, nil)
	Base.WritePrimitive(writer, val.RoomOwnerSeatIndex, writer.WriteInt32, 0)
end

function Auto.WriteMahjongSetData(writer, val)
	Base.WritePrimitive(writer, val.TilesDrawn, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.DoraTurned, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.LingShangDrawn, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.TilesRemain, writer.WriteInt32, 0)
	Base.WriteList7Bit(writer, val.DoraIndicators, Base.WriteStructWrap(Auto.WriteTile, "DoraIndicators"), nil, "DoraIndicators", false, 0, nil)
	Base.WritePrimitive(writer, val.TotalTiles, writer.WriteInt32, 0)
end

function Auto.WriteMahjongWorldBattleRoomInfo(writer, val)
	Base.WritePrimitive(writer, val.GadgetId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.OwnerPid, writer.WriteUInt64, 0)
	Base.WriteList7Bit(writer, val.Players, Base.WriteComplexWrap(Auto.WriteMahjongWorldBattleRoomPlayerInfo, "MahjongWorldBattleRoomPlayerInfo", false), nil, "Players", false, 0, nil)
end

function Auto.WriteMahjongWorldBattleRoomPlayerInfo(writer, val)
	Base.WritePrimitive(writer, val.Pid, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.Duty, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.Ready, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.IsOwner, writer.WriteBoolean, false)
end

function Auto.WriteMaidTeaChoiceInfo(writer, val)
	Base.WriteList7Bit(writer, val.Choices, writer.WriteInt32, 0, "Choices", false, RpcLengthLimits.MaidTeaChoiceInfo_Choices, nil)
end

function Auto.WriteMaidTeaMemeberInfo(writer, val)
	Base.WritePrimitive(writer, val.VisitTimes, writer.WriteUInt32, 0)
	Base.WriteList7Bit(writer, val.UnlockDrinks, writer.WriteUInt32, 0, "UnlockDrinks", false, 0, nil)
end

function Auto.WriteMailAttachment(writer, val)
	Base.WriteList(writer, val.Items, Base.WriteComplexWrap(Auto.WriteItemCountInfo, "ItemCountInfo", true), nil, "Items", true, 0, nil)
	Base.WritePrimitive(writer, val.UnbindMoney, writer.WriteDouble, 0)
	Base.WritePrimitive(writer, val.BindGold, writer.WriteDouble, 0)
	Base.WritePrimitive(writer, val.PayGold, writer.WriteDouble, 0)
	Base.WritePrimitive(writer, val.FreeGold, writer.WriteDouble, 0)
	Base.WritePrimitive(writer, val.Exp, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.Popularity, writer.WriteSingle, 0)
	Base.WriteDict(writer, val.JobExpInfo, writer.WriteUInt32, writer.WriteUInt32, 0, "JobExpInfo", true, 0)
	Base.WriteDict(writer, val.FanInfo, writer.WriteUInt32, writer.WriteInt32, 0, "FanInfo", true, 0)
	Base.WriteDict(writer, val.FactionDispositionInfo, writer.WriteUInt32, writer.WriteInt32, 0, "FactionDispositionInfo", true, 0)
	Base.WriteDict(writer, val.FactionInfluenceInfo, writer.WriteUInt32, writer.WriteInt32, 0, "FactionInfluenceInfo", true, 0)
	Base.WriteDict(writer, val.AbilityExpInfo, writer.WriteUInt32, writer.WriteUInt32, 0, "AbilityExpInfo", true, 0)
	Base.WriteComplex(writer, val.SpiritTalentExpInfo, Auto.WriteSpiritTalentExpInfo, "SpiritTalentExpInfo", true)
	Base.WritePrimitive(writer, val.CommonSpiritTalentExp, writer.WriteUInt32, 0)
	Base.WriteList(writer, val.WeaponList, writer.WriteUInt32, 0, "WeaponList", true, 0, nil)
	Base.WriteDict(writer, val.BattlePassExpInfo, writer.WriteUInt32, writer.WriteUInt32, 0, "BattlePassExpInfo", true, 0)
	Base.WriteDict(writer, val.ExtractionShooterInfo, writer.WriteUInt32, writer.WriteUInt32, 0, "ExtractionShooterInfo", true, 0)
	Base.WriteList(writer, val.RumorIds, writer.WriteUInt32, 0, "RumorIds", true, 0, nil)
	Base.WriteDict(writer, val.SeasonProgressInfo, writer.WriteUInt32, writer.WriteUInt32, 0, "SeasonProgressInfo", true, 0)
	Base.WriteList(writer, val.FishingFishRewards, Base.WriteComplexWrap(Auto.WriteFishingFishRewardInfo, "FishingFishRewardInfo", true), nil, "FishingFishRewards", true, 0, nil)
	Base.WriteList(writer, val.FishingGearRewards, writer.WriteUInt32, 0, "FishingGearRewards", true, 0, nil)
end

function Auto.WriteMailHead(writer, val)
	Base.WritePrimitive(writer, val.Id, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.MailId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.CreateTime, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.ExpireTime, writer.WriteUInt32, 0)
	writer:WriteString(val.Title, true, "MailHead.Title", 0)
	Base.WriteList7Bit(writer, val.TitleParams, Base.WriteComplexWrap(Auto.WriteMailParameter, "MailParameter", true), nil, "TitleParams", true, 0, nil)
	writer:WriteString(val.SenderName, true, "MailHead.SenderName", 0)
	Base.WritePrimitive(writer, val.IsGlobal, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.HasItem, writer.WriteBoolean, false)
	Base.WriteComplex(writer, val.Attachment, Auto.WriteSimpleMailAttchment, "Attachment", true)
	Base.WritePrimitive(writer, val.IsFavorite, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.IsRetrieved, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.Tab, writer.WriteInt32, 0)
end

function Auto.WriteMailInfo(writer, val)
	Base.WritePrimitive(writer, val.Id, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, Base.CheckEnum(val.Reason, 22, 0), writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.CreateTime, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.IsGlobal, writer.WriteBoolean, false)
	writer:WriteString(val.SenderName, true, "MailInfo.SenderName", 0)
	writer:WriteString(val.Title, true, "MailInfo.Title", 0)
	Base.WriteList(writer, val.TitleParams, Base.WriteComplexWrap(Auto.WriteMailParameter, "MailParameter", true), nil, "TitleParams", true, 0, nil)
	writer:WriteString(val.Content, true, "MailInfo.Content", 0)
	Base.WriteList(writer, val.ContentParams, Base.WriteComplexWrap(Auto.WriteMailParameter, "MailParameter", true), nil, "ContentParams", true, 0, nil)
	Base.WritePrimitive(writer, val.RewardTemplateId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.MailId, writer.WriteUInt32, 0)
	writer:WriteString(val.JsonAttachment, true, "MailInfo.JsonAttachment", 0)
	Base.WriteComplex(writer, val.Attachment, Auto.WriteMailAttachment, "Attachment", true)
	Base.WritePrimitive(writer, val.HasAttachment, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.Tag, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.IsRetrieved, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.IsFavorite, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.GlobalMailVersion, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.ReceiveTime, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.ExpireTime, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.IsExpireTimeAt, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.ExpireTimeOffline, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.IncludePlayerAfterSend, writer.WriteBoolean, false)
	Base.WriteList(writer, val.Platforms, writer.WriteInt32, 0, "Platforms", true, 0, nil)
end

function Auto.WriteMailParameter(writer, val)
	Base.WritePrimitive(writer, Base.CheckEnum(val.ParamType, 177, 0), writer.WriteByte, 0)
	writer:WriteString(val.Data, false, "MailParameter.Data", 0)
end

function Auto.WriteMallCartBuyItem(writer, val)
	Base.WritePrimitive(writer, val.CommodityId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.Count, writer.WriteUInt32, 0)
end

function Auto.WriteMallCartItemInfo(writer, val)
	Base.WritePrimitive(writer, val.CommodityId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.Count, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.AddTime, writer.WriteUInt32, 0)
end

function Auto.WriteMallCommodityInfo(writer, val)
	Base.WritePrimitive(writer, val.BoughtCount, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.NextRefreshTime, writer.WriteUInt32, 0)
end

function Auto.WriteMallInfo(writer, val)
	Base.WriteDict(writer, val.CommodityInfoDict, writer.WriteUInt32, Base.WriteComplexWrap(Auto.WriteMallCommodityInfo, "MallCommodityInfo", false), nil, "CommodityInfoDict", false, 0)
	Base.WriteComplex(writer, val.PlayerMonthlyPassInfo, Auto.WritePlayerMonthlyPassInfo, "PlayerMonthlyPassInfo", false)
	Base.WriteList(writer, val.CartItemList, Base.WriteComplexWrap(Auto.WriteMallCartItemInfo, "MallCartItemInfo", false), nil, "CartItemList", false, 0, nil)
end

function Auto.WriteMapPin(writer, val)
	Base.WritePrimitive(writer, val.RaidId, writer.WriteUInt32, 0)
	Base.WriteStruct(writer, val.Position, Auto.WriteUXVector3, "Position")
	Base.WritePrimitive(writer, val.Type, writer.WriteByte, 0)
end

function Auto.WriteMartialArtistSlotInfo(writer, val)
	Base.WriteDict(writer, val.Slots, writer.WriteUInt32, writer.WriteUInt32, 0, "Slots", false, 0)
end

function Auto.WriteMassCustomArea(writer, val)
	Base.WritePrimitive(writer, val.Uid, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.Hide, writer.WriteBoolean, false)
	Base.WriteList7Bit(writer, val.Points, Base.WriteStructWrap(Auto.WriteUXVector3, "Points"), nil, "Points", true, 0, nil)
	Base.WritePrimitive(writer, val.HideType, writer.WriteInt32, 0)
end

function Auto.WriteMassTrafficSpawnArea(writer, val)
	Base.WriteList(writer, val.SpawnLaneSelector, Base.WriteStructWrap(Auto.WriteSpawnLaneSelector, "SpawnLaneSelector"), nil, "SpawnLaneSelector", false, 0, nil)
	Base.WritePrimitive(writer, val.Uid, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.UseCustomizedSeed, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.Seed, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.UseIntervalBetweenLanes, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.MinSpawnInterval, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.MaxSpawnInterval, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.SpawnVehicleContinuously, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.FilledWithVehicleAtStart, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.RemoveVehicleWhenOutOfArea, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.UseSameVelocityConfig, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.MinVehicleSpeed, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.MaxVehicleSpeed, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.UseCustomizedVehicle, writer.WriteBoolean, false)
end

function Auto.WriteMassTrafficSpawnAreaManager(writer, val)
	Base.WritePrimitive(writer, val.ClearAllNormalVehicles, writer.WriteBoolean, false)
	Base.WriteList(writer, val.TrafficSpawnAreas, Base.WriteStructWrap(Auto.WriteSpawnAreaSelector, "TrafficSpawnAreas"), nil, "TrafficSpawnAreas", false, 0, nil)
end

function Auto.WriteMatchPlayerSettleData(writer, val)
	Base.WritePrimitive(writer, val.Pid, writer.WriteUInt64, 0)
	writer:WriteString(val.Name, false, "MatchPlayerSettleData.Name", 0)
	Base.WritePrimitive(writer, val.SpiritId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.VehicleId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.ElapsedTime, writer.WriteDouble, 0)
	Base.WritePrimitive(writer, val.AutoLeaveTime, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, Base.CheckEnum(val.Result, 178, 0), writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.gameId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.ForceQuit, writer.WriteBoolean, false)
	Base.WriteComplex(writer, val.rewardSettleData, Auto.WriteRewardSettleData, "rewardSettleData", true)
	Base.WriteComplex(writer, val.raidSettleData, Auto.WriteRaidSettleData, "raidSettleData", true)
	Base.WriteComplex(writer, val.raceSettleData, Auto.WriteRaceSettleData, "raceSettleData", true)
	Base.WriteComplex(writer, val.extractionSettleData, Auto.WriteExtractionSettleData, "extractionSettleData", true)
	Base.WriteComplex(writer, val.BattleStatisticInfos, Auto.WriteBattleStatisticInfos, "BattleStatisticInfos", true)
	Base.WriteComplex(writer, val.DartSettleData, Auto.WriteDartSettleData, "DartSettleData", true)
	Base.WriteComplex(writer, val.BowlingSettleData, Auto.WriteBowlingSettleData, "BowlingSettleData", true)
	Base.WriteComplex(writer, val.GomokuSettleData, Auto.WriteGomokuSettleData, "GomokuSettleData", true)
	Base.WriteComplex(writer, val.TierDetailSettleData, Auto.WriteTierDetailSettleData, "TierDetailSettleData", true)
	Base.WriteComplex(writer, val.EggGameSettleData, Auto.WriteEggGameSettleData, "EggGameSettleData", true)
	Base.WriteComplex(writer, val.HideAndSeekSettleData, Auto.WriteHideAndSeekSettleData, "HideAndSeekSettleData", true)
end

function Auto.WriteMatchPrepareInfo(writer, val)
	Base.WritePrimitive(writer, val.VehicleId, writer.WriteUInt32, 0)
	Base.WriteComplex(writer, val.Fashion, Auto.WriteOtherPlayerSpiritWearFashionsInfo, "Fashion", true)
	Base.WritePrimitive(writer, val.SpiritId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.PoseId, writer.WriteUInt32, 0)
	Base.WriteList(writer, val.VehicleParts, Base.WriteStructWrap(Auto.WriteVehicleClientPart, "VehicleParts"), nil, "VehicleParts", true, RpcLengthLimits.MatchPrepareInfo_VehicleParts, nil)
	Base.WritePrimitive(writer, val.SuitId, writer.WriteUInt32, 0)
	Base.WriteDict(writer, val.MemberKeyCounts, writer.WriteUInt32, writer.WriteUInt32, 0, "MemberKeyCounts", true, RpcLengthLimits.MatchPrepareInfo_MemberKeyCounts)
	Base.WriteDict(writer, val.LinkPlanningBoardPutInKeys, writer.WriteUInt32, writer.WriteUInt32, 0, "LinkPlanningBoardPutInKeys", true, RpcLengthLimits.MatchPrepareInfo_LinkPlanningBoardPutInKeys)
	Base.WritePrimitive(writer, val.SelectedGameplayAttributeId, writer.WriteUInt32, 0)
end

function Auto.WriteMatchPrepareRoom(writer, val)
	Base.WriteList(writer, val.MatchRooms, writer.WriteUInt64, 0, "MatchRooms", false, 0, nil)
	Base.WriteList(writer, val.StageConfirmMembers, writer.WriteUInt64, 0, "StageConfirmMembers", false, 0, nil)
	Base.WriteList(writer, val.ConfirmMembers, writer.WriteUInt64, 0, "ConfirmMembers", false, 0, nil)
	Base.WriteList(writer, val.ReadyMembers, writer.WriteUInt64, 0, "ReadyMembers", false, 0, nil)
	Base.WritePrimitive(writer, val.ConfirmStartTime, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.PrepareStartTime, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.GameStartTime, writer.WriteUInt32, 0)
	Base.WriteDict(writer, val.PrepareInfos, writer.WriteUInt64, Base.WriteComplexWrap(Auto.WriteMatchPrepareInfo, "MatchPrepareInfo", false), nil, "PrepareInfos", false, 0)
	Base.WritePrimitive(writer, val.MemberLeave, writer.WriteBoolean, false)
	Base.WriteDict(writer, val.PlayerSwapInfos, writer.WriteUInt64, Base.WriteComplexWrap(Auto.WriteMatchPrepareRoomPlayerSwapInfo, "MatchPrepareRoomPlayerSwapInfo", false), nil, "PlayerSwapInfos", false, 0)
	Base.WritePrimitive(writer, val.IsFreeWorldBattle, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.GadgetId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.SceneId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, Base.CheckEnum(val.State, 179, 0), writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.StageId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.StageStartTime, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.StageIndex, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.PlayCount, writer.WriteUInt32, 0)
	Base.WriteDict(writer, val.AIPlayer, writer.WriteInt32, writer.WriteUInt32, 0, "AIPlayer", true, 0)
	Base.WriteComplex(writer, val.Setting, Auto.WritePrepareRoomSetting, "Setting", false)
	Base.WritePrimitive(writer, val.Id, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.GameId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.LeaderPid, writer.WriteUInt64, 0)
	Base.WriteList(writer, val.Members, Base.WriteComplexWrap(Auto.WriteMatchRoomMemberInfo, "MatchRoomMemberInfo", false), nil, "Members", false, 0, nil)
	Base.WriteList(writer, val.AIAgentMembers, Base.WriteComplexWrap(Auto.WriteMatchRoomAIAgentInfo, "MatchRoomAIAgentInfo", false), nil, "AIAgentMembers", false, 0, nil)
	Base.WritePrimitive(writer, val.LastMemberUpdateTime, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.ByMatch, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.PSNOnly, writer.WriteBoolean, false)
end

function Auto.WriteMatchPrepareRoomDutySwapInfo(writer, val)
	Base.WritePrimitive(writer, val.SourcePid, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.SourceDuty, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.TargetPid, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.TargetDuty, writer.WriteUInt32, 0)
end

function Auto.WriteMatchPrepareRoomPlayerSwapInfo(writer, val)
	Base.WriteDict(writer, val.SwapInfos, writer.WriteUInt64, Base.WriteComplexWrap(Auto.WriteMatchPrepareRoomDutySwapInfo, "MatchPrepareRoomDutySwapInfo", false), nil, "SwapInfos", false, 0)
end

function Auto.WriteMatchRoom(writer, val)
	Base.WritePrimitive(writer, val.Id, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.GameId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.LeaderPid, writer.WriteUInt64, 0)
	Base.WriteList(writer, val.Members, Base.WriteComplexWrap(Auto.WriteMatchRoomMemberInfo, "MatchRoomMemberInfo", false), nil, "Members", false, 0, nil)
	Base.WriteList(writer, val.AIAgentMembers, Base.WriteComplexWrap(Auto.WriteMatchRoomAIAgentInfo, "MatchRoomAIAgentInfo", false), nil, "AIAgentMembers", false, 0, nil)
	Base.WritePrimitive(writer, val.LastMemberUpdateTime, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.ByMatch, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.PSNOnly, writer.WriteBoolean, false)
end

function Auto.WriteMatchRoomAIAgentInfo(writer, val)
	Base.WritePrimitive(writer, val.EntityId, writer.WriteUInt64, 0)
	Base.WriteComplex(writer, val.AgentInfo, Auto.WriteLinkAIAgentInfo, "AgentInfo", false)
end

function Auto.WriteMatchRoomMemberInfo(writer, val)
	Base.WritePrimitive(writer, val.Pid, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.MatchForbidDueTime, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.Duty, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.IsRobot, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.IsAIAgent, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, Base.CheckEnum(val.FromMode, 9, 0), writer.WriteByte, 0)
	Base.WritePrimitive(writer, Base.CheckEnum(val.DeviceLevel, 39, 1), writer.WriteByte, 1)
	Base.WritePrimitive(writer, val.FromRaidId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.FromSceneInstanceId, writer.WriteUInt64, 0)
	Base.WriteDict(writer, val.Blacklist, writer.WriteUInt64, writer.WriteBoolean, false, "Blacklist", false, 0)
	Base.WriteList(writer, val.AvaliableGameIds, writer.WriteUInt32, 0, "AvaliableGameIds", false, 0, nil)
	Base.WritePrimitive(writer, val.LinkScore, writer.WriteUInt32, 0)
	Base.WriteComplex(writer, val.LinkInfo, Auto.WritePlayerLinkInfo, "LinkInfo", false)
end

function Auto.WriteMatchTeamRoom(writer, val)
	Base.WritePrimitive(writer, val.MatchStartTime, writer.WriteUInt32, 0)
	Base.WriteComplex(writer, val.matchingFactor, Auto.WriteMatchingFactor, "matchingFactor", false)
	Base.WritePrimitive(writer, val.InMatch, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.ByTeam, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.AllowAI, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.Started, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, Base.CheckEnum(val.Tag, 180, 0), writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.Difficulty, writer.WriteUInt32, 0)
	Base.WriteList(writer, val.MatchPoolTags, writer.WriteByte, 32, "MatchPoolTags", false, 0, nil)
	Base.WritePrimitive(writer, val.Id, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.GameId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.LeaderPid, writer.WriteUInt64, 0)
	Base.WriteList(writer, val.Members, Base.WriteComplexWrap(Auto.WriteMatchRoomMemberInfo, "MatchRoomMemberInfo", false), nil, "Members", false, 0, nil)
	Base.WriteList(writer, val.AIAgentMembers, Base.WriteComplexWrap(Auto.WriteMatchRoomAIAgentInfo, "MatchRoomAIAgentInfo", false), nil, "AIAgentMembers", false, 0, nil)
	Base.WritePrimitive(writer, val.LastMemberUpdateTime, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.ByMatch, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.PSNOnly, writer.WriteBoolean, false)
end

function Auto.WriteMatchingFactor(writer, val)
	Base.WriteList(writer, val.Blacklist, writer.WriteUInt64, 0, "Blacklist", false, 0, nil)
	Base.WritePrimitive(writer, val.deviceLevelWeight, writer.WriteDouble, 0)
	Base.WritePrimitive(writer, val.Score, writer.WriteDouble, 0)
end

function Auto.WriteMeccaGrandpaBuildInfo(writer, val)
	Base.WriteList(writer, val.Slots, Base.WriteComplexWrap(Auto.WriteMeccaGrandpaSlotInfo, "MeccaGrandpaSlotInfo", false), nil, "Slots", false, 0, nil)
	Base.WritePrimitive(writer, val.IsBuilt, writer.WriteBoolean, false)
end

function Auto.WriteMeccaGrandpaPartInfo(writer, val)
	Base.WritePrimitive(writer, val.PartId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.Count, writer.WriteUInt32, 0)
end

function Auto.WriteMeccaGrandpaSlotInfo(writer, val)
	Base.WritePrimitive(writer, val.PartType, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.PartId, writer.WriteUInt32, 0)
end

function Auto.WriteMeld(writer, val)
	Base.WritePrimitive(writer, Base.CheckEnum(val.Type, 181, 0), writer.WriteByte, 0)
	Base.WriteList7Bit(writer, val.Tiles, Base.WriteStructWrap(Auto.WriteTile, "Tiles"), nil, "Tiles", false, 0, nil)
	Base.WritePrimitive(writer, val.Revealed, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.IsKong, writer.WriteBoolean, false)
end

function Auto.WriteMergeToTrafficParameters(writer, val)
	Base.WritePrimitive(writer, val.ExcludeAlley, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.CruiseSpeed, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.LateralThreshold, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.HeadingThreshold, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.Token, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.taskAIConfigId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.defaultSpeed, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.drivingFlags, writer.WriteInt32, 1)
	Base.WritePrimitive(writer, val.initSpeed, writer.WriteSingle, 0)
	Base.WriteList7Bit(writer, val.initTaskAIBuffList, Base.WriteStructWrap(Auto.WriteTaskVehicleBuffInitInfo, "initTaskAIBuffList"), nil, "initTaskAIBuffList", true, 0, nil)
	Base.WriteStruct(writer, val.commonParameters, Auto.WriteVehicleAICommonParameters, "commonParameters")
end

function Auto.WriteMessageCallbackParameter(writer, val)
	Base.WritePrimitive(writer, val.TaskId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.SpiritId, writer.WriteUInt32, 0)
end

function Auto.WriteMetroCarriageGadgetInfos(writer, val)
	Base.WriteList7Bit(writer, val.InnerGadgetIds, writer.WriteUInt64, 0, "InnerGadgetIds", false, 0, nil)
	Base.WriteList7Bit(writer, val.OuterGadgetIds, writer.WriteUInt64, 0, "OuterGadgetIds", false, 0, nil)
end

function Auto.WriteMetroClientInfo(writer, val)
	Base.WritePrimitive(writer, val.Id, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.LineId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.ElapsedTime, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.IsFinalTrain, writer.WriteBoolean, false)
end

function Auto.WriteMetroHideArea(writer, val)
	Base.WritePrimitive(writer, val.Uid, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.Hide, writer.WriteBoolean, false)
	Base.WriteStruct(writer, val.Center, Auto.WriteUXVector3, "Center")
	Base.WritePrimitive(writer, val.Radius, writer.WriteSingle, 0)
end

function Auto.WriteMetroHitData(writer, val)
	Base.WritePrimitive(writer, val.MetroId, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.TargetId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.Speed, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.HurtEffectId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.HurtStiffId, writer.WriteUInt32, 0)
end

function Auto.WriteMiniGameData(writer, val)
	Base.WriteList(writer, val.MiniGame_Bee, writer.WriteUInt32, 0, "MiniGame_Bee", false, 0, nil)
end

function Auto.WriteMjAction(writer, val)
	Base.WritePrimitive(writer, Base.CheckEnum(val.Type, 182, 0), writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.Owner, writer.WriteInt32, 0)
	Base.WriteList7Bit(writer, val.Targets, writer.WriteInt32, 0, "Targets", false, 0, nil)
	Base.WritePrimitive(writer, val.Score, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.IsZhuanYi, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.BaseFan, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, Base.CheckEnum(val.Pattern, 183, 0), writer.WriteByte, 0)
	Base.WriteList7Bit(writer, val.Patterns, writer.WriteByte, 0, "Patterns", true, 0, nil)
	Base.WriteStruct(writer, val.Pai, Auto.WriteMjPaiInfo, "Pai")
	Base.WritePrimitive(writer, val.NumOfGen, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.HuAction, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.Fan, writer.WriteInt32, 0)
end

function Auto.WriteMjCanActionInfo(writer, val)
	Base.WriteStruct(writer, val.Pai, Auto.WriteMjPaiInfo, "Pai")
	Base.WritePrimitive(writer, val.CanHu, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.CanReach, writer.WriteBoolean, false)
	Base.WriteList7Bit(writer, val.CanPeng, Base.WriteComplexWrap(Auto.WriteMjPCGActionInfo, "MjPCGActionInfo", false), nil, "CanPeng", false, 0, nil)
	Base.WriteList7Bit(writer, val.CanChi, Base.WriteComplexWrap(Auto.WriteMjPCGActionInfo, "MjPCGActionInfo", false), nil, "CanChi", false, 0, nil)
	Base.WriteList7Bit(writer, val.CanGang, Base.WriteComplexWrap(Auto.WriteMjPCGActionInfo, "MjPCGActionInfo", false), nil, "CanGang", false, 0, nil)
	Base.WritePrimitive(writer, val.CanChuPai, writer.WriteBoolean, false)
end

function Auto.WriteMjHand(writer, val)
	Base.WriteList7Bit(writer, val.Tiles, Base.WriteStructWrap(Auto.WriteMjPaiInfo, "Tiles"), nil, "Tiles", false, 0, nil)
end

function Auto.WriteMjPCGActionInfo(writer, val)
	Base.WritePrimitive(writer, val.Source, writer.WriteInt32, 0)
	Base.WriteStruct(writer, val.Pai, Auto.WriteMjPaiInfo, "Pai")
	Base.WriteList7Bit(writer, val.SelectPais, Base.WriteStructWrap(Auto.WriteMjPaiInfo, "SelectPais"), nil, "SelectPais", false, 0, nil)
	Base.WritePrimitive(writer, Base.CheckEnum(val.PCGType, 184, 0), writer.WriteByte, 0)
end

function Auto.WriteMjPaiInfo(writer, val)
	Base.WritePrimitive(writer, val.InstanceId, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.Pai, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, Base.CheckEnum(val.MType, 28, 0), writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.Red, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.Index, writer.WriteInt32, 0)
end

function Auto.WriteMjPlayerResult(writer, val)
	Base.WriteList7Bit(writer, val.Holds, Base.WriteStructWrap(Auto.WriteMjPaiInfo, "Holds"), nil, "Holds", false, 0, nil)
end

function Auto.WriteMjResult(writer, val)
	Base.WriteList7Bit(writer, val.MJActions, Base.WriteComplexWrap(Auto.WriteMjAction, "MjAction", true), nil, "MJActions", true, 0, nil)
	Base.WriteList7Bit(writer, val.MjPlayerResultList, Base.WriteComplexWrap(Auto.WriteMjPlayerResult, "MjPlayerResult", true), nil, "MjPlayerResultList", true, 0, nil)
end

function Auto.WriteMobilePlatformSyncInfo(writer, val)
	Base.WritePrimitive(writer, val.CurLevel, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.TgtLevel, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.StartTime, writer.WriteUInt32, 0)
	Base.WriteDict7Bit(writer, val.Players, writer.WriteUInt64, Base.WriteComplexWrap(Auto.WriteUXVector3, "UXVector3", false), nil, "Players", false, 0)
	Base.WriteStruct(writer, val.CurLevelPos, Auto.WriteUXVector3, "CurLevelPos")
	Base.WriteStruct(writer, val.TgtLevelPos, Auto.WriteUXVector3, "TgtLevelPos")
	Base.WriteComplex(writer, val.InteractBanInfo, Auto.WriteLiftInteractBanInfo, "InteractBanInfo", true)
	Base.WritePrimitive(writer, Base.CheckEnum(val.DoorMode, 185, 0), writer.WriteByte, 0)
end

function Auto.WriteModifySpiritWearFashionResult(writer, val)
	Base.WriteList7Bit(writer, val.R0, writer.WriteUInt32, 0, "R0", false, 0, nil)
	Base.WriteList7Bit(writer, val.R1, Base.WriteComplexWrap(Auto.WriteWearFashionInfo, "WearFashionInfo", false), nil, "R1", false, 0, nil)
	Base.WriteList7Bit(writer, val.R2, writer.WriteUInt32, 0, "R2", false, 0, nil)
	Base.WriteList7Bit(writer, val.R3, Base.WriteComplexWrap(Auto.WriteWearFashionEditInfo, "WearFashionEditInfo", false), nil, "R3", false, 0, nil)
end

function Auto.WriteModuleEventProgressInfo(writer, val)
	Base.WriteDict(writer, val.ProgressInfoDict, writer.WriteUInt32, Base.WriteComplexWrap(Auto.WriteModuleEventProgressInfoBySpirit, "ModuleEventProgressInfoBySpirit", false), nil, "ProgressInfoDict", false, 0)
end

function Auto.WriteModuleEventProgressInfoBySpirit(writer, val)
	Base.WriteDict(writer, val.EventProgressInfoDict, writer.WriteUInt32, Base.WriteComplexWrap(Auto.WriteEventProgressInfo, "EventProgressInfo", false), nil, "EventProgressInfoDict", false, 0)
	Base.WriteList(writer, val.FinishedTemplateIdList, writer.WriteUInt32, 0, "FinishedTemplateIdList", false, 0, nil)
end

function Auto.WriteMomentsNotifyClientInfo(writer, val)
	Base.WritePrimitive(writer, Base.CheckEnum(val.Type, 186, 0), writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.LikeCount, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.PostCount, writer.WriteInt32, 0)
	Base.WriteList7Bit(writer, val.NpcIds, writer.WriteUInt32, 0, "NpcIds", true, 0, nil)
	Base.WritePrimitive(writer, val.Id, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.CfgId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.HasNewLike, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.AcquireCfgId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.ActivityCfgId, writer.WriteUInt32, 0)
	writer:WriteString(val.Url, true, "MomentsNotifyClientInfo.Url", 0)
	Base.WritePrimitive(writer, val.IsStory, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.IsPinStory, writer.WriteBoolean, false)
end

function Auto.WriteMonitorTwitterBehavior(writer, val)
	Base.WritePrimitive(writer, Base.CheckEnum(val.Behavior, 71, 0), writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.Id, writer.WriteInt32, 0)
end

function Auto.WriteMonthlyPassInfo(writer, val)
	Base.WritePrimitive(writer, val.Id, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.ExpiredTime, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.LastDailyRewardTime, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.IsAutoPopup, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.CumulativeLoginDays, writer.WriteUInt32, 0)
end

function Auto.WriteMonthlyPassRewardInfo(writer, val)
	Base.WriteComplex(writer, val.BuyRewardInfo, Auto.WriteRewardInfo, "BuyRewardInfo", true)
	Base.WriteComplex(writer, val.DailyRewardInfo, Auto.WriteRewardInfo, "DailyRewardInfo", true)
	Base.WriteComplex(writer, val.CumulativeRewardInfo, Auto.WriteRewardInfo, "CumulativeRewardInfo", true)
end

function Auto.WriteMotionLookAtCommandData(writer, val)
	Base.WriteStruct(writer, val.Target, Auto.WriteClientActionTarget, "Target")
	Base.WritePrimitive(writer, val.LookAtIKType, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.CheckQuery, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, Base.CheckEnum(val.DataSource, 97, 0), writer.WriteInt16, 0)
end

function Auto.WriteMoveActionData(writer, val)
	Base.WritePrimitive(writer, val.UnitId, writer.WriteUInt64, 0)
	Base.WriteStruct(writer, val.Pos, Auto.WriteUXVector3, "Pos")
	Base.WriteStruct(writer, val.Rot, Auto.WriteUXVector3, "Rot")
	Base.WritePrimitive(writer, val.MoveId, writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.MoveTime, writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.IsCritical, writer.WriteBoolean, false)
	Base.WriteList7Bit(writer, val.ActionData, writer.WriteByte, 0, "ActionData", true, RpcLengthLimits.MoveActionData_ActionData, val.ActionDataLength)
	Base.WriteList7Bit(writer, val.EffectData, writer.WriteByte, 0, "EffectData", true, RpcLengthLimits.MoveActionData_EffectData, val.EffectDataLength)
end

function Auto.WriteMoveActionDataWithGround(writer, val)
	Base.WritePrimitive(writer, val.UnitId, writer.WriteUInt64, 0)
	Base.WriteStruct(writer, val.Pos, Auto.WriteUXVector3, "Pos")
	Base.WriteStruct(writer, val.Rot, Auto.WriteUXVector3, "Rot")
	Base.WritePrimitive(writer, val.MoveId, writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.MoveTime, writer.WriteByte, 0)
	Base.WriteComplex(writer, val.GroundData, Auto.WriteMoveActionGroundData, "GroundData", false)
	Base.WritePrimitive(writer, val.IsCritical, writer.WriteBoolean, false)
	Base.WriteList7Bit(writer, val.ActionData, writer.WriteByte, 0, "ActionData", true, RpcLengthLimits.MoveActionDataWithGround_ActionData, val.ActionDataLength)
	Base.WriteList7Bit(writer, val.EffectData, writer.WriteByte, 0, "EffectData", true, RpcLengthLimits.MoveActionDataWithGround_EffectData, val.EffectDataLength)
end

function Auto.WriteMoveActionGroundData(writer, val)
	Base.WritePrimitive(writer, Base.CheckEnum(val.MoveGroundType, 187, 0), writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.MoveGroundId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.MetaInfo, writer.WriteByte, 0)
	Base.WriteStruct(writer, val.LocalPos, Auto.WriteUXVector3, "LocalPos")
end

function Auto.WriteMoveCommandData(writer, val)
	Base.WriteStruct(writer, val.Target, Auto.WriteClientActionTarget, "Target")
	Base.WritePrimitive(writer, val.ArriveDistance, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.SpecificMethod, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.DirectionTolerance, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.TryMatchStep, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.KeepUpdateTargetPosition, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.RunChasingDistance, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.KeepMovingAction, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.Speed, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.MoveActionId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.MoveActionGroup, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, Base.CheckEnum(val.DataSource, 97, 0), writer.WriteInt16, 0)
end

function Auto.WriteMoveGhostParameter(writer, val)
	Base.WritePrimitive(writer, val.DoPreload, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.SectorRadius, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.MipMapCoeff, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.NeedCollider, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.IsMainTarget, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.CollideRadius, writer.WriteSingle, 0)
end

function Auto.WriteMoveToBorderData(writer, val)
	Base.WritePrimitive(writer, val.MaxDistance, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.UnitId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, Base.CheckEnum(val.MoveType, 116, 0), writer.WriteInt64, 0)
	Base.WritePrimitive(writer, val.MoveId, writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.CloseIK, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.InstanceId, writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.BlockCloseCapsuleCollision, writer.WriteBoolean, false)
end

function Auto.WriteMoveToCanShootPosData(writer, val)
	Base.WritePrimitive(writer, val.AngleSpace, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.DistanceSpace, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.UnitId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, Base.CheckEnum(val.MoveType, 116, 0), writer.WriteInt64, 0)
	Base.WritePrimitive(writer, val.MoveId, writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.CloseIK, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.InstanceId, writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.BlockCloseCapsuleCollision, writer.WriteBoolean, false)
end

function Auto.WriteMoveToEQSData(writer, val)
	Base.WritePrimitive(writer, val.TargetId, writer.WriteUInt64, 0)
	writer:WriteString(val.EqsName, false, "MoveToEQSData.EqsName", 0)
	writer:WriteString(val.ShelterName, false, "MoveToEQSData.ShelterName", 0)
	writer:WriteString(val.CheckerName, false, "MoveToEQSData.CheckerName", 0)
	Base.WritePrimitive(writer, val.PathTags, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.CloseObstacleAvoidance, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.StopDistance, writer.WriteSingle, 0)
	Base.WriteStruct(writer, val.Position, Auto.WriteUXVector3, "Position")
	Base.WritePrimitive(writer, val.AvoidanceId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.UnitId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, Base.CheckEnum(val.MoveType, 116, 0), writer.WriteInt64, 0)
	Base.WritePrimitive(writer, val.MoveId, writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.CloseIK, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.InstanceId, writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.BlockCloseCapsuleCollision, writer.WriteBoolean, false)
end

function Auto.WriteMoveToPosData(writer, val)
	Base.WriteList7Bit(writer, val.path, Base.WriteStructWrap(Auto.WriteUXVector3, "path"), nil, "path", false, 0, nil)
	Base.WritePrimitive(writer, val.pathTags, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.StopDistance, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.reportOnFinish, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.UseServerPath, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.CloseObstacleAvoidance, writer.WriteBoolean, false)
	Base.WriteList7Bit(writer, val.pathFlags, writer.WriteByte, 0, "pathFlags", false, 0, nil)
	Base.WritePrimitive(writer, val.IsOnWall, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.AvoidanceId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.UnitId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, Base.CheckEnum(val.MoveType, 116, 0), writer.WriteInt64, 0)
	Base.WritePrimitive(writer, val.MoveId, writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.CloseIK, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.InstanceId, writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.BlockCloseCapsuleCollision, writer.WriteBoolean, false)
end

function Auto.WriteMoveToVehicleCommandData(writer, val)
	Base.WritePrimitive(writer, val.VehicleId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.SeatIndex, writer.WriteInt32, 0)
	Base.WriteList7Bit(writer, val.Distances, Base.WriteStructWrap(Auto.WriteRangeMoveType, "Distances"), nil, "Distances", true, 0, nil)
	Base.WritePrimitive(writer, Base.CheckEnum(val.DataSource, 97, 0), writer.WriteInt16, 0)
end

function Auto.WriteMoveTowardUnitData(writer, val)
	Base.WritePrimitive(writer, val.TargetId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.ActionId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.NearDistance, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.ReportOnFinish, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.CloseObstacleAvoidance, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.CloseIngterStep, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.IsMoveAround, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.AvoidanceId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.UnitId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, Base.CheckEnum(val.MoveType, 116, 0), writer.WriteInt64, 0)
	Base.WritePrimitive(writer, val.MoveId, writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.CloseIK, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.InstanceId, writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.BlockCloseCapsuleCollision, writer.WriteBoolean, false)
end

function Auto.WriteMoveWanderingData(writer, val)
	Base.WritePrimitive(writer, val.pathTags, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.CloseObstacleAvoidance, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.MinDis, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.MaxDis, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.InRangeAngle, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.OutRangeAngle, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.MaxTime, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.MaxOnceWanderTime, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.UnitId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, Base.CheckEnum(val.MoveType, 116, 0), writer.WriteInt64, 0)
	Base.WritePrimitive(writer, val.MoveId, writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.CloseIK, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.InstanceId, writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.BlockCloseCapsuleCollision, writer.WriteBoolean, false)
end

function Auto.WriteMovingDirResInfo(writer, val)
	Base.WritePrimitive(writer, val.Uid, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, Base.CheckEnum(val.Dir, 188, 0), writer.WriteByte, 0)
end

function Auto.WriteMultiInteractCommandData(writer, val)
	Base.WritePrimitive(writer, val.AnotherAgentId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.MultiInteractType, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, Base.CheckEnum(val.DataSource, 97, 0), writer.WriteInt16, 0)
end

function Auto.WriteMultiverseStatusInfo(writer, val)
	Base.WriteDict(writer, val.MultiverseStatusDict, writer.WriteUInt32, writer.WriteByte, 0, "MultiverseStatusDict", false, 0)
	Base.WritePrimitive(writer, val.ShowLastMutiId, writer.WriteUInt32, 0)
	Base.WriteDict(writer, val.MainPageTabStatusDict, writer.WriteUInt32, writer.WriteByte, 0, "MainPageTabStatusDict", false, 0)
	Base.WriteDict(writer, val.ActivityStatusDict, writer.WriteUInt32, writer.WriteByte, 0, "ActivityStatusDict", false, 0)
	Base.WritePrimitive(writer, val.CurMutiPanelId, writer.WriteUInt32, 0)
end

function Auto.WriteMusicClientInfo(writer, val)
	Base.WritePrimitive(writer, val.MusicId, writer.WriteUInt32, 0)
	Base.WriteList7Bit(writer, val.RecordInfo, writer.WriteUInt32, 0, "RecordInfo", true, 0, nil)
	Base.WritePrimitive(writer, val.AlreadyReward, writer.WriteBoolean, false)
end

function Auto.WriteNameCard(writer, val)
	Base.WritePrimitive(writer, val.Pid, writer.WriteUInt64, 0)
	writer:WriteString(val.Name, false, "NameCard.Name", 0)
	Base.WritePrimitive(writer, val.Level, writer.WriteUInt32, 0)
end

function Auto.WriteNamedPayload(writer, val)
	writer:WriteString(val.Name, false, "NamedPayload.Name", 0)
	Base.WriteComplex(writer, val.Value, Auto.WriteStoryNetPayload, "Value", false)
end

function Auto.WriteNavigationMoveCommandData(writer, val)
	Base.WritePrimitive(writer, val.NavigationTolerance, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.SelfNavigationTolerance, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.FailedWhenNavigationFailed, writer.WriteBoolean, false)
	Base.WriteStruct(writer, val.Target, Auto.WriteClientActionTarget, "Target")
	Base.WritePrimitive(writer, val.ArriveDistance, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.SpecificMethod, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.DirectionTolerance, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.TryMatchStep, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.KeepUpdateTargetPosition, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.RunChasingDistance, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.KeepMovingAction, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.Speed, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.MoveActionId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.MoveActionGroup, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, Base.CheckEnum(val.DataSource, 97, 0), writer.WriteInt16, 0)
end

function Auto.WriteNetworkPointInfo(writer, val)
	Base.WritePrimitive(writer, val.Fu, writer.WriteInt32, 0)
	Base.WriteList7Bit(writer, val.YakuValues, Base.WriteStructWrap(Auto.WriteYakuValue, "YakuValues"), nil, "YakuValues", false, 0, nil)
	Base.WritePrimitive(writer, val.Dora, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.UraDora, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.RedDora, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.BeiDora, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.IsQTJ, writer.WriteBoolean, false)
end

function Auto.WriteNewChallengeRecord(writer, val)
	Base.WritePrimitive(writer, val.ChallengeId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.HighestLevel, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.ReceivedRewardLevel, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.CurrentIsNewRewardLevel, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.BestScore, writer.WriteSingle, 0)
	Base.WriteDict(writer, val.ParamData, writer.WriteUInt32, writer.WriteBoolean, false, "ParamData", false, 0)
end

function Auto.WriteNewClientBoardingInfo(writer, val)
	Base.WritePrimitive(writer, val.EntityId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, Base.CheckEnum(val.Status, 189, 0), writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.VehicleUId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.SeatIndex, writer.WriteByte, 0)
	Base.WriteComplex(writer, val.NpcExt, Auto.WriteNpcBoardingExtInfo, "NpcExt", true)
end

function Auto.WriteNewHotFixPatchData(writer, val)
	Base.WritePrimitive(writer, val.Version, writer.WriteInt32, 0)
	Base.WriteList7Bit(writer, val.Content, writer.WriteByte, 0, "Content", false, 0, nil)
	writer:WriteString(val.Md5, false, "NewHotFixPatchData.Md5", 0)
end

function Auto.WriteNgpushSetting(writer, val)
	Base.WritePrimitive(writer, val.DoNotDisturb, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.DoNotDisturbBegin, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.DoNotDisturbEnd, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.TagSetting, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.LastSetTagTime, writer.WriteUInt32, 0)
end

function Auto.WriteNodeSpoonOutputLinks(writer, val)
	Base.WriteList7Bit(writer, val.Links, Base.WriteComplexWrap(Auto.WriteSpoonOutputLink, "SpoonOutputLink", false), nil, "Links", false, 0, nil)
end

function Auto.WriteNpcBoardingExtInfo(writer, val)
	Base.WriteStruct(writer, val.PositionOffset, Auto.WriteUXVector3, "PositionOffset")
	Base.WriteStruct(writer, val.RotationOffset, Auto.WriteUXVector3, "RotationOffset")
	Base.WritePrimitive(writer, val.CanBeEjected, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.UseSpecificAction, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.ActionGroup, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.ActionId, writer.WriteUInt32, 0)
end

function Auto.WriteNpcCardInfo(writer, val)
	Base.WritePrimitive(writer, val.TemplateId, writer.WriteUInt32, 0)
	Base.WriteList(writer, val.UnlockedVoice, writer.WriteUInt32, 0, "UnlockedVoice", true, 0, nil)
	Base.WritePrimitive(writer, val.ActivateTimestamp, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.Favor, writer.WriteDouble, 0)
	Base.WritePrimitive(writer, val.InteractDays, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.LastInteractTime, writer.WriteUInt32, 0)
	Base.WriteList(writer, val.GroupNpcPhotoPosList, writer.WriteUInt32, 0, "GroupNpcPhotoPosList", false, 0, nil)
	Base.WriteList(writer, val.SingleNpcPhotoPosList, writer.WriteUInt32, 0, "SingleNpcPhotoPosList", false, 0, nil)
	Base.WriteList(writer, val.TodayChatPosList, writer.WriteUInt32, 0, "TodayChatPosList", false, 0, nil)
	Base.WriteList(writer, val.FirstChatPosList, writer.WriteUInt32, 0, "FirstChatPosList", false, 0, nil)
	Base.WritePrimitive(writer, val.PreferCfgId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.AcquireDropReward, writer.WriteBoolean, false)
	Base.WriteList(writer, val.ActiveGiftTags, writer.WriteUInt32, 0, "ActiveGiftTags", false, 0, nil)
	Base.WritePrimitive(writer, val.MaxFavorInHistory, writer.WriteDouble, 0)
	Base.WritePrimitive(writer, val.TodayFavorDialogCount, writer.WriteUInt32, 0)
	Base.WriteList(writer, val.InteractedStories, writer.WriteUInt32, 0, "InteractedStories", false, 0, nil)
	Base.WritePrimitive(writer, val.HasUninteractedNpcVoice, writer.WriteBoolean, false)
	Base.WriteList(writer, val.InteractedVoices, writer.WriteUInt32, 0, "InteractedVoices", false, 0, nil)
	Base.WritePrimitive(writer, val.FavorLevelReward, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.HasNoInteractedStory, writer.WriteBoolean, false)
	Base.WriteDict(writer, val.UnlockedStoryDict, writer.WriteUInt32, writer.WriteUInt32, 0, "UnlockedStoryDict", true, 0)
end

function Auto.WriteNpcChatContext(writer, val)
	Base.WritePrimitive(writer, val.BubbleId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.AcquireCfgId, writer.WriteUInt32, 0)
	Base.WriteList(writer, val.EmojiList, Base.WriteComplexWrap(Auto.WriteEmojiData, "EmojiData", false), nil, "EmojiList", false, 0, nil)
	writer:WriteString(val.Url, true, "NpcChatContext.Url", 0)
	Base.WritePrimitive(writer, val.ActivityCfgId, writer.WriteUInt32, 0)
end

function Auto.WriteNpcChatItem(writer, val)
	Base.WritePrimitive(writer, val.Timestamp, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.ChatId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.NextChatId, writer.WriteUInt32, 0)
	Base.WriteComplex(writer, val.ChatContext, Auto.WriteNpcChatContext, "ChatContext", true)
	Base.WritePrimitive(writer, val.IsRead, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.BelongNpc, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.ChatActionTriggeredTime, writer.WriteUInt32, 0)
end

function Auto.WriteNpcDetailInfo(writer, val)
	Base.WritePrimitive(writer, val.Id, writer.WriteUInt64, 0)
	Base.WriteStruct(writer, val.Position, Auto.WriteUXVector3, "Position")
	Base.WritePrimitive(writer, val.AgentId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.AgentPersonaId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, Base.CheckEnum(val.NpcType, 190, 0), writer.WriteByte, 0)
end

function Auto.WriteNpcEffectEntry(writer, val)
	Base.WritePrimitive(writer, val.EffectId, writer.WriteUInt32, 0)
end

function Auto.WriteNpcEventQueue(writer, val)
	Base.WritePrimitive(writer, val.TodayTriggeredCount, writer.WriteUInt32, 0)
	Base.WriteList(writer, val.EventIds, writer.WriteUInt32, 0, "EventIds", false, 0, nil)
end

function Auto.WriteNpcEventQueueList(writer, val)
	Base.WriteDict(writer, val.NpcQueues, writer.WriteUInt32, Base.WriteComplexWrap(Auto.WriteNpcEventQueue, "NpcEventQueue", false), nil, "NpcQueues", false, 0)
	Base.WritePrimitive(writer, val.TodayTriggeredCount, writer.WriteUInt32, 0)
	Base.WriteDict(writer, val.IdToNpcDict, writer.WriteUInt32, Base.WriteComplexWrap(Auto.WriteEventIdInfo, "EventIdInfo", false), nil, "IdToNpcDict", false, 0)
	Base.WritePrimitive(writer, val.LastTriggerTime, writer.WriteUInt32, 0)
end

function Auto.WriteNpcScheduleInfo(writer, val)
	Base.WritePrimitive(writer, val.ActivityId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.StartDaySecond, writer.WriteInt32, 0)
	Base.WriteStruct(writer, val.Position, Auto.WriteUXVector3, "Position")
	Base.WritePrimitive(writer, val.SpoonAgentId, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.EndDaySecond, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.RaidId, writer.WriteUInt32, 0)
end

function Auto.WriteNpcShareTimeInfo(writer, val)
	Base.WritePrimitive(writer, val.Id, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.FightShareDuration, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.SwitchInTime, writer.WriteUInt32, 0)
end

function Auto.WriteNpcShopCommodityView(writer, val)
	Base.WritePrimitive(writer, val.TemplateId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.Count, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.RefreshTime, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.Status, writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.Discount, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.DiscountPrice, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.MaxBuyCount, writer.WriteUInt32, 0)
end

function Auto.WriteNpcShopInfo(writer, val)
	Base.WritePrimitive(writer, val.CurrentDiscount, writer.WriteUInt32, 0)
	Base.WriteList7Bit(writer, val.CommodityInfoList, Base.WriteComplexWrap(Auto.WriteNpcShopCommodityView, "NpcShopCommodityView", false), nil, "CommodityInfoList", false, 0, nil)
	Base.WriteList7Bit(writer, val.BuybackCommodityInfoList, Base.WriteComplexWrap(Auto.WriteNpcShopCommodityView, "NpcShopCommodityView", true), nil, "BuybackCommodityInfoList", true, 0, nil)
	Base.WriteComplex(writer, val.RefreshState, Auto.WriteNpcShopRefreshState, "RefreshState", true)
end

function Auto.WriteNpcShopRefreshState(writer, val)
	Base.WritePrimitive(writer, val.SellRefreshTime, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.BuybackRefreshTime, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.ManualRefreshCountResetTime, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.SellManualRefreshCount, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.BuybackManualRefreshCount, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.SellRotationIndex, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.BuybackRotationIndex, writer.WriteUInt32, 0)
end

function Auto.WriteNpcTimeTableInfo(writer, val)
	Base.WriteComplex(writer, val.Schedule0, Auto.WriteNpcScheduleInfo, "Schedule0", false)
	Base.WriteComplex(writer, val.Schedule1, Auto.WriteNpcScheduleInfo, "Schedule1", false)
	Base.WriteComplex(writer, val.Schedule2, Auto.WriteNpcScheduleInfo, "Schedule2", false)
	Base.WriteComplex(writer, val.Schedule3, Auto.WriteNpcScheduleInfo, "Schedule3", false)
	Base.WriteComplex(writer, val.Schedule4, Auto.WriteNpcScheduleInfo, "Schedule4", false)
	Base.WritePrimitive(writer, val.CurrentSpoonAgentId, writer.WriteInt32, 0)
	Base.WriteStruct(writer, val.SpoonPosition, Auto.WriteUXVector3, "SpoonPosition")
	Base.WriteComplex(writer, val.TempSchedule, Auto.WriteNpcScheduleInfo, "TempSchedule", true)
	Base.WritePrimitive(writer, val.IsTempScheduleOnly, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.RefreshDay, writer.WriteInt64, 0)
end

function Auto.WriteNpcTrustValueInfo(writer, val)
	Base.WritePrimitive(writer, val.ProfileId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.TrustValue, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, Base.CheckEnum(val.Reason, 22, 0), writer.WriteInt32, 0)
end

function Auto.WriteNpcVehicleDriveStateInfo(writer, val)
	Base.WritePrimitive(writer, val.Uid, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.EnterOrLeave, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.VehicleEntityId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.SeatIndex, writer.WriteInt32, 0)
end

function Auto.WriteNpcVoiceDebugInfo(writer, val)
	Base.WritePrimitive(writer, val.NpcInstanceId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.VoiceLibraryId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.VoiceInstanceId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.SoundId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.DialogInstanceId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.Success, writer.WriteBoolean, false)
	writer:WriteString(val.FailureReason, false, "NpcVoiceDebugInfo.FailureReason", 0)
end

function Auto.WriteOCControllerByte9Value(writer, val)
	Base.WritePrimitive(writer, val.Value1, writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.Value2, writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.Value3, writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.Value4, writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.Value5, writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.Value6, writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.Value7, writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.Value8, writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.Value9, writer.WriteByte, 0)
end

function Auto.WriteOCGenerateInfo(writer, val)
	Base.WritePrimitive(writer, val.OCId, writer.WriteUInt64, 0)
	writer:WriteString(val.name, false, "OCGenerateInfo.name", RpcLengthLimits.OCGenerateInfo_name)
	writer:WriteString(val.gender, false, "OCGenerateInfo.gender", RpcLengthLimits.OCGenerateInfo_gender)
	writer:WriteString(val.age, true, "OCGenerateInfo.age", RpcLengthLimits.OCGenerateInfo_age)
	Base.WriteList(writer, val.labels, Base.WriteStringWrap(false, "labels", RpcLengthLimits.OCGenerateInfo_labels_String), nil, "labels", false, RpcLengthLimits.OCGenerateInfo_labels, nil)
	writer:WriteString(val.description, false, "OCGenerateInfo.description", RpcLengthLimits.OCGenerateInfo_description)
	writer:WriteString(val.story, false, "OCGenerateInfo.story", RpcLengthLimits.OCGenerateInfo_story)
	writer:WriteString(val.identity, false, "OCGenerateInfo.identity", RpcLengthLimits.OCGenerateInfo_identity)
	writer:WriteString(val.SpeechName, false, "OCGenerateInfo.SpeechName", RpcLengthLimits.OCGenerateInfo_SpeechName)
	Base.WritePrimitive(writer, val.SelectBodyTypeId, writer.WriteUInt32, 0)
	writer:WriteString(val.SpeakingStyle, true, "OCGenerateInfo.SpeakingStyle", RpcLengthLimits.OCGenerateInfo_SpeakingStyle)
	writer:WriteString(val.Relationship, true, "OCGenerateInfo.Relationship", RpcLengthLimits.OCGenerateInfo_Relationship)
	writer:WriteString(val.DialogSample, true, "OCGenerateInfo.DialogSample", RpcLengthLimits.OCGenerateInfo_DialogSample)
end

function Auto.WriteOCInfo(writer, val)
	Base.WritePrimitive(writer, val.CreateTime, writer.WriteUInt32, 0)
	Base.WriteDict(writer, val.ControllerByteValues, writer.WriteUInt16, writer.WriteByte, 0, "ControllerByteValues", false, RpcLengthLimits.OCInfo_ControllerByteValues)
	Base.WriteDict(writer, val.ControllerByte9Values, writer.WriteUInt16, Base.WriteComplexWrap(Auto.WriteOCControllerByte9Value, "OCControllerByte9Value", false), nil, "ControllerByte9Values", false, RpcLengthLimits.OCInfo_ControllerByte9Values)
	writer:WriteString(val.speech_id, false, "OCInfo.speech_id", RpcLengthLimits.OCInfo_speech_id)
	Base.WritePrimitive(writer, val.FashionOCId, writer.WriteUInt32, 0)
	Base.WriteComplex(writer, val.SpiritWearFashionsInfo, Auto.WriteSpiritWearFashionsInfo, "SpiritWearFashionsInfo", true)
	Base.WritePrimitive(writer, val.OCId, writer.WriteUInt64, 0)
	writer:WriteString(val.name, false, "OCInfo.name", RpcLengthLimits.OCGenerateInfo_name)
	writer:WriteString(val.gender, false, "OCInfo.gender", RpcLengthLimits.OCGenerateInfo_gender)
	writer:WriteString(val.age, true, "OCInfo.age", RpcLengthLimits.OCGenerateInfo_age)
	Base.WriteList(writer, val.labels, Base.WriteStringWrap(false, "labels", RpcLengthLimits.OCGenerateInfo_labels_String), nil, "labels", false, RpcLengthLimits.OCGenerateInfo_labels, nil)
	writer:WriteString(val.description, false, "OCInfo.description", RpcLengthLimits.OCGenerateInfo_description)
	writer:WriteString(val.story, false, "OCInfo.story", RpcLengthLimits.OCGenerateInfo_story)
	writer:WriteString(val.identity, false, "OCInfo.identity", RpcLengthLimits.OCGenerateInfo_identity)
	writer:WriteString(val.SpeechName, false, "OCInfo.SpeechName", RpcLengthLimits.OCGenerateInfo_SpeechName)
	Base.WritePrimitive(writer, val.SelectBodyTypeId, writer.WriteUInt32, 0)
	writer:WriteString(val.SpeakingStyle, true, "OCInfo.SpeakingStyle", RpcLengthLimits.OCGenerateInfo_SpeakingStyle)
	writer:WriteString(val.Relationship, true, "OCInfo.Relationship", RpcLengthLimits.OCGenerateInfo_Relationship)
	writer:WriteString(val.DialogSample, true, "OCInfo.DialogSample", RpcLengthLimits.OCGenerateInfo_DialogSample)
end

function Auto.WriteOCMeccaGrandpaInfo(writer, val)
	Base.WritePrimitive(writer, val.RefOCId, writer.WriteUInt64, 0)
end

function Auto.WriteOCMemoryChange(writer, val)
	Base.WritePrimitive(writer, Base.CheckEnum(val.MemorySetId, 15, 0), writer.WriteByte, 0)
	Base.WriteList7Bit(writer, val.NewEntries, Base.WriteComplexWrap(Auto.WriteOCMemoryEntry, "OCMemoryEntry", false), nil, "NewEntries", false, 0, nil)
	Base.WritePrimitive(writer, val.ProgressPercent, writer.WriteUInt32, 0)
end

function Auto.WriteOCMemoryEntry(writer, val)
	Base.WritePrimitive(writer, val.MemoryId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.UnlockTime, writer.WriteUInt32, 0)
	Base.WriteDict(writer, val.ParamsDict, writer.WriteUInt32, Base.WriteStringWrap(false, "ParamsDict", 0), nil, "ParamsDict", false, 0)
end

function Auto.WriteOCMemoryInfo(writer, val)
	Base.WriteDict(writer, val.MemorySetDataDict, writer.WriteByte, Base.WriteComplexWrap(Auto.WriteOCMemorySetData, "OCMemorySetData", false), nil, "MemorySetDataDict", false, 0)
end

function Auto.WriteOCMemorySetData(writer, val)
	Base.WriteDict(writer, val.MemoryEntryDict, writer.WriteUInt32, Base.WriteComplexWrap(Auto.WriteOCMemoryEntry, "OCMemoryEntry", false), nil, "MemoryEntryDict", false, 0)
	Base.WritePrimitive(writer, val.RecoveredMemoryWeight, writer.WriteUInt32, 0)
end

function Auto.WriteOCSpeechInfo(writer, val)
	writer:WriteString(val.SpeechName, false, "OCSpeechInfo.SpeechName", 0)
	Base.WritePrimitive(writer, val.CreateTime, writer.WriteUInt32, 0)
	writer:WriteString(val.ExternalSpeechId, false, "OCSpeechInfo.ExternalSpeechId", 0)
	Base.WriteComplex(writer, val.SoundEffectConfig, Auto.WriteSoundEffectConfig, "SoundEffectConfig", true)
end

function Auto.WriteOccupyDebugInfo(writer, val)
	Base.WritePrimitive(writer, val.OccupyId, writer.WriteUInt32, 0)
	writer:WriteString(val.Reason, true, "OccupyDebugInfo.Reason", 0)
end

function Auto.WriteOnlineSeasonChangedNotifyInfo(writer, val)
	Base.WritePrimitive(writer, val.SeasonId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.StartTime, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.EndTime, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.SchemeId, writer.WriteUInt32, 0)
end

function Auto.WriteOpenMeld(writer, val)
	Base.WriteStruct(writer, val.Meld, Auto.WriteMeld, "Meld")
	Base.WriteStruct(writer, val.Tile, Auto.WriteTile, "Tile")
	Base.WritePrimitive(writer, Base.CheckEnum(val.Side, 191, 0), writer.WriteByte, 0)
	Base.WriteStruct(writer, val.Extra, Auto.WriteTile, "Extra")
	Base.WritePrimitive(writer, val.IsAdded, writer.WriteBoolean, false)
end

function Auto.WriteOpenVehicleDoorCommandData(writer, val)
	Base.WritePrimitive(writer, val.VehicleId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.SeatIndex, writer.WriteByte, 0)
	Base.WriteList7Bit(writer, val.Distances, Base.WriteStructWrap(Auto.WriteRangeMoveType, "Distances"), nil, "Distances", false, 0, nil)
	Base.WritePrimitive(writer, Base.CheckEnum(val.DataSource, 97, 0), writer.WriteInt16, 0)
end

function Auto.WriteOperationPerformInfo(writer, val)
	Base.WritePrimitive(writer, val.PlayerIndex, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.OperationPlayerIndex, writer.WriteInt32, 0)
	Base.WriteStruct(writer, val.Operation, Auto.WriteOutTurnOperation, "Operation")
	Base.WriteStruct(writer, val.HandData, Auto.WritePlayerHandData, "HandData")
	Base.WritePrimitive(writer, val.RemainTurnTime, writer.WriteInt32, 0)
	Base.WriteList7Bit(writer, val.Rivers, Base.WriteStructWrap(Auto.WriteRiverData, "Rivers"), nil, "Rivers", false, 0, nil)
	Base.WriteStruct(writer, val.MahjongSetData, Auto.WriteMahjongSetData, "MahjongSetData")
end

function Auto.WriteOssBucketInfo(writer, val)
	writer:WriteString(val.Region, false, "OssBucketInfo.Region", 0)
	writer:WriteString(val.Endpoint, false, "OssBucketInfo.Endpoint", 0)
	writer:WriteString(val.Bucket, false, "OssBucketInfo.Bucket", 0)
end

function Auto.WriteOstrichMoveCommandData(writer, val)
	Base.WriteList7Bit(writer, val.Positions, Base.WriteStructWrap(Auto.WriteUXVector3, "Positions"), nil, "Positions", false, 0, nil)
	Base.WritePrimitive(writer, Base.CheckEnum(val.DataSource, 97, 0), writer.WriteInt16, 0)
end

function Auto.WriteOtherPlayerSpiritWearFashionsInfo(writer, val)
	Base.WriteDict(writer, val.WearFashionColoringInfoDict, writer.WriteUInt32, Base.WriteComplexWrap(Auto.WriteFashionColoringInfo, "FashionColoringInfo", false), nil, "WearFashionColoringInfoDict", true, RpcLengthLimits.OtherPlayerSpiritWearFashionsInfo_WearFashionColoringInfoDict)
	Base.WriteList(writer, val.WearFashionInfoList, Base.WriteComplexWrap(Auto.WriteWearFashionInfo, "WearFashionInfo", false), nil, "WearFashionInfoList", false, RpcLengthLimits.BaseWearFashionsInfo_WearFashionInfoList, nil)
	Base.WriteList(writer, val.WearFashionEditInfoList, Base.WriteComplexWrap(Auto.WriteWearFashionEditInfo, "WearFashionEditInfo", true), nil, "WearFashionEditInfoList", true, RpcLengthLimits.BaseWearFashionsInfo_WearFashionEditInfoList, nil)
	Base.WritePrimitive(writer, val.HiddenParts, writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.EditedHiddenParts, writer.WriteByte, 0)
end

function Auto.WriteOutTurnOperation(writer, val)
	Base.WritePrimitive(writer, Base.CheckEnum(val.Type, 192, 0), writer.WriteByte, 0)
	Base.WriteStruct(writer, val.Tile, Auto.WriteTile, "Tile")
	Base.WriteStruct(writer, val.Meld, Auto.WriteOpenMeld, "Meld")
	Base.WriteList7Bit(writer, val.ForbiddenTiles, Base.WriteStructWrap(Auto.WriteTile, "ForbiddenTiles"), nil, "ForbiddenTiles", false, 0, nil)
	Base.WriteStruct(writer, val.HandData, Auto.WritePlayerHandData, "HandData")
	Base.WritePrimitive(writer, Base.CheckEnum(val.RoundDrawType, 193, 0), writer.WriteByte, 0)
end

function Auto.WriteOwnerSyncData(writer, val)
	Base.WritePrimitive(writer, val.NetworkTick, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.attackPid, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.hurtPid, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.hurtId, writer.WriteUInt32, 0)
	Base.WriteStruct(writer, val.hitPoint, Auto.WriteUXVector3, "hitPoint")
	Base.WriteStruct(writer, val.hitCenter, Auto.WriteUXVector3, "hitCenter")
	Base.WriteStruct(writer, val.hitDirection, Auto.WriteUXVector3, "hitDirection")
	Base.WriteStruct(writer, val.colliderPos, Auto.WriteUXVector3, "colliderPos")
	Base.WriteStruct(writer, val.colliderForward, Auto.WriteUXVector3, "colliderForward")
	Base.WriteStruct(writer, val.colliderVelocity, Auto.WriteUXVector3, "colliderVelocity")
	Base.WriteStruct(writer, val.attackColliderPos, Auto.WriteUXVector3, "attackColliderPos")
	Base.WriteStruct(writer, val.attackColliderForward, Auto.WriteUXVector3, "attackColliderForward")
	Base.WriteStruct(writer, val.attackColliderVelocity, Auto.WriteUXVector3, "attackColliderVelocity")
	Base.WritePrimitive(writer, val.skillUUID, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.skillId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.triggerIndex, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.materialIndex, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.hitColliderIndex, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.creationId, writer.WriteUInt32, 0)
end

function Auto.WritePSNPlayerInfo(writer, val)
	Base.WritePrimitive(writer, val.Pid, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, Base.CheckEnum(val.IsPSNPlayer, 37, 0), writer.WriteByte, 0)
	writer:WriteString(val.OnlineId, false, "PSNPlayerInfo.OnlineId", 0)
	writer:WriteString(val.OldAuthorizationToken, false, "PSNPlayerInfo.OldAuthorizationToken", 0)
	writer:WriteString(val.AccessToken, false, "PSNPlayerInfo.AccessToken", 0)
	writer:WriteString(val.SessionId, false, "PSNPlayerInfo.SessionId", 0)
end

function Auto.WritePackedDestructibleInfo(writer, val)
	Base.WritePrimitive(writer, val.iScale, writer.WriteInt32, 0)
	Base.WriteList7Bit(writer, val.linkPath, writer.WriteInt32, 0, "linkPath", true, 0, nil)
	Base.WriteList7Bit(writer, val.linkType, writer.WriteByte, 0, "linkType", true, 0, nil)
end

function Auto.WritePackedGadgetInfo(writer, val)
	Base.WritePrimitive(writer, val.posX, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.posY, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.posZ, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.eulerX, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.eulerY, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.eulerZ, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.iScale, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.uniqueId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.pathId, writer.WriteInt32, 0)
	Base.WriteList7Bit(writer, val.spoonSpecialList, Base.WriteStructWrap(Auto.WritePackedGadgetSpecialParam, "spoonSpecialList"), nil, "spoonSpecialList", true, 0, nil)
	Base.WritePrimitive(writer, val.delayDestroy, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.startTaskId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.endTaskId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.extractionItemContainerId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.isStatic, writer.WriteBoolean, false)
end

function Auto.WritePackedGadgetSpecialParam(writer, val)
	Base.WritePrimitive(writer, val.markId, writer.WriteInt32, 0)
	writer:WriteString(val.value, true, "PackedGadgetSpecialParam.value", 0)
end

function Auto.WritePartyDanceInviteInfo(writer, val)
	Base.WritePrimitive(writer, val.InviterPid, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.InviteePid, writer.WriteUInt64, 0)
end

function Auto.WritePartyDanceParticipantInfo(writer, val)
	Base.WritePrimitive(writer, val.NpcInstanceId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, Base.CheckEnum(val.Mode, 33, 0), writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.Pid, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.NpcCultivationId, writer.WriteUInt32, 0)
	Base.WriteComplex(writer, val.AIAgentInfo, Auto.WriteLinkAIAgentInfo, "AIAgentInfo", true)
	Base.WritePrimitive(writer, val.AgentInstanceId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.VehicleInstanceId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.SeatIndex, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.IsReady, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.IsPlayAgain, writer.WriteBoolean, false)
end

function Auto.WritePartyDanceSettleInfo(writer, val)
	Base.WritePrimitive(writer, val.ZoneGadgetUId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.MySelfScore, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.PartnerScore, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.MySelfMusicScore, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.PartnerMusicScore, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.PartyScore, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.BestPartyScore, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.IsNewBest, writer.WriteBoolean, false)
end

function Auto.WritePartyDanceStartInfo(writer, val)
	Base.WritePrimitive(writer, val.ZoneGadgetUId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.MusicId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, Base.CheckEnum(val.Mode, 33, 0), writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.StartTimestamp, writer.WriteUInt32, 0)
end

function Auto.WritePartyDanceZoneInfo(writer, val)
	Base.WritePrimitive(writer, val.MusicId, writer.WriteUInt32, 0)
	writer:WriteString(val.ZoneSessionId, false, "PartyDanceZoneInfo.ZoneSessionId", 0)
	Base.WritePrimitive(writer, val.GadgetUId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.TaskId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, Base.CheckEnum(val.StartReason, 106, 0), writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.GameTypeRandom, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, Base.CheckEnum(val.SyncReason, 107, 0), writer.WriteByte, 0)
	Base.WritePrimitive(writer, Base.CheckEnum(val.ZoneType, 108, 0), writer.WriteByte, 0)
	Base.WritePrimitive(writer, Base.CheckEnum(val.ZoneState, 109, 0), writer.WriteByte, 0)
	Base.WriteList7Bit(writer, val.ParticipantInfos, Base.WriteComplexWrap(Auto.WriteGameGroundParticipantInfo, "GameGroundParticipantInfo", true), nil, "ParticipantInfos", true, 0, nil)
	Base.WriteStruct(writer, val.CountDownInfo, Auto.WriteGameGroundZoneCountDownInfo, "CountDownInfo")
end

function Auto.WritePartyMemberInfo(writer, val)
	Base.WritePrimitive(writer, val.Pid, writer.WriteUInt64, 0)
	writer:WriteString(val.Name, false, "PartyMemberInfo.Name", 0)
end

function Auto.WritePartyNPCInfo(writer, val)
	Base.WritePrimitive(writer, val.NpcId, writer.WriteUInt64, 0)
	writer:WriteString(val.NickName, false, "PartyNPCInfo.NickName", 0)
	Base.WritePrimitive(writer, val.NPCType, writer.WriteUInt32, 0)
end

function Auto.WritePartyNPCMessage(writer, val)
	Base.WritePrimitive(writer, val.Id, writer.WriteInt32, 0)
	writer:WriteString(val.Message, false, "PartyNPCMessage.Message", 0)
end

function Auto.WritePartyNpcFashionsInfo(writer, val)
	Base.WriteDict7Bit(writer, val.Rents, writer.WriteUInt32, writer.WriteUInt32, 0, "Rents", false, RpcLengthLimits.PartyNpcFashionsInfo_Rents)
end

function Auto.WritePartyOnlineSettleResult(writer, val)
	Base.WritePrimitive(writer, val.TotalScore, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.FashionScore, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.ActivityScore, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.LiveScore, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.FashionStarPid, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.SuperGamerPid, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.PopularityKingPid, writer.WriteUInt64, 0)
	Base.WriteList7Bit(writer, val.SettleList, Base.WriteComplexWrap(Auto.WritePartyPlayerSettleData, "PartyPlayerSettleData", false), nil, "SettleList", false, 0, nil)
end

function Auto.WritePartyPlayerSettleData(writer, val)
	Base.WritePrimitive(writer, val.Pid, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.FashionScore, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.TaskScore, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.GamePlayScore, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.LiveScore, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.LikeCount, writer.WriteUInt32, 0)
end

function Auto.WritePartyResponse(writer, val)
	Base.WriteList7Bit(writer, val.likeList, writer.WriteInt32, 0, "likeList", false, 0, nil)
	Base.WriteList7Bit(writer, val.giftList, writer.WriteInt32, 0, "giftList", false, 0, nil)
	Base.WritePrimitive(writer, val.Popularity, writer.WriteUInt32, 0)
	Base.WriteList7Bit(writer, val.NPCMessage, Base.WriteComplexWrap(Auto.WritePartyNPCMessage, "PartyNPCMessage", false), nil, "NPCMessage", false, 0, nil)
end

function Auto.WritePartyRoomInfo(writer, val)
	Base.WritePrimitive(writer, val.PartyConfigId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.Lottery, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.MatchLinkId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.HasGift, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.GiftItemId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.LotteryItemId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.LotteryItemCount, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.OwnerJoinLottery, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.EnableLiveBarrage, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.EnableRoomAudio, writer.WriteBoolean, false)
end

function Auto.WritePartyRoomSettingParam(writer, val)
	Base.WritePrimitive(writer, val.SetLottery, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.LotteryItemId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.LotteryItemCount, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.SetGift, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.GiftItemId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.GiftItemCount, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.OwnerJoinLottery, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.EnableLiveBarrage, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.EnableRoomAudio, writer.WriteBoolean, false)
end

function Auto.WritePartySettingInfo(writer, val)
	Base.WritePrimitive(writer, val.PartyConfigId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.MatchLinkId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.Lottery, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.LotteryItemId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.LotteryItemCount, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.HasGift, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.GiftItemId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.GiftItemCount, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.OwnerJoinLottery, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.EnableLiveBarrage, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.EnableRoomAudio, writer.WriteBoolean, false)
end

function Auto.WritePartySettleData(writer, val)
	Base.WritePrimitive(writer, val.HostPid, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.PartyId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.Popularity, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.LikeCount, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.GiftCount, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.CommentCount, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.AudienceCount, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.WinGameCount, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.TaskCount, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.InviteFriendCount, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.Drop, writer.WriteUInt32, 0)
	Base.WriteList7Bit(writer, val.LikeList, writer.WriteInt32, 0, "LikeList", false, 0, nil)
	Base.WriteList7Bit(writer, val.GiftList, writer.WriteInt32, 0, "GiftList", false, 0, nil)
	Base.WriteList7Bit(writer, val.InviteNPCList, writer.WriteUInt32, 0, "InviteNPCList", false, 0, nil)
	Base.WriteComplex(writer, val.OnlineSettleResult, Auto.WritePartyOnlineSettleResult, "OnlineSettleResult", true)
end

function Auto.WritePartyStatusInfo(writer, val)
	Base.WritePrimitive(writer, val.PartyId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.RoomId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.IsOnlineParty, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.Status, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.HostPid, writer.WriteUInt64, 0)
	Base.WriteList7Bit(writer, val.Members, Base.WriteComplexWrap(Auto.WritePartyMemberInfo, "PartyMemberInfo", true), nil, "Members", true, 0, nil)
end

function Auto.WritePatchEntry(writer, val)
	Base.WritePrimitive(writer, val.Version, writer.WriteInt32, 0)
	Base.WriteList7Bit(writer, val.Content, writer.WriteByte, 0, "Content", false, 0, nil)
	writer:WriteString(val.Md5, false, "PatchEntry.Md5", 0)
end

function Auto.WritePendingGiftEntry(writer, val)
	Base.WritePrimitive(writer, val.GiftId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.SenderPid, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.CommodityId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.BundleId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.SendTime, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.ExpireTime, writer.WriteUInt32, 0)
	writer:WriteString(val.GiftMessage, false, "PendingGiftEntry.GiftMessage", 0)
end

function Auto.WritePendingSeasonReward(writer, val)
	Base.WritePrimitive(writer, val.SeasonId, writer.WriteUInt32, 0)
	Base.WriteList(writer, val.TaskRewardDropIds, writer.WriteUInt32, 0, "TaskRewardDropIds", false, 0, nil)
	Base.WritePrimitive(writer, val.TaskRewardProgress, writer.WriteUInt32, 0)
	Base.WriteList(writer, val.LevelRewardDropIds, writer.WriteUInt32, 0, "LevelRewardDropIds", false, 0, nil)
end

function Auto.WritePersonalTeamSetting(writer, val)
	Base.WritePrimitive(writer, val.DisableTeamInviteInPersonalMode, writer.WriteBoolean, false)
end

function Auto.WritePersonalTimeSetting(writer, val)
	writer:WriteString(val.Label, false, "PersonalTimeSetting.Label", RpcLengthLimits.PersonalTimeSetting_Label)
	Base.WritePrimitive(writer, val.Hour, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.Minute, writer.WriteUInt32, 0)
end

function Auto.WritePersonalZoneAchievement(writer, val)
	Base.WritePrimitive(writer, val.AchieveId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.Index, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.CountryId, writer.WriteUInt32, 0)
end

function Auto.WritePersonalZoneFightSpiritInfo(writer, val)
	Base.WritePrimitive(writer, val.Id, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.Index, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.Level, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.FavorLevel, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.NpcCultivationId, writer.WriteUInt32, 0)
end

function Auto.WritePersonalZoneHeadExtendInfo(writer, val)
	Base.WriteComplex(writer, val.PzHeadInfo, Auto.WritePersonalZoneHeadInfo, "PzHeadInfo", false)
	Base.WriteComplex(writer, val.LinkPzHeadInfo, Auto.WritePersonalZoneHeadInfo, "LinkPzHeadInfo", false)
	Base.WriteList7Bit(writer, val.UnlockedSystemHeadList, Base.WriteComplexWrap(Auto.WritePersonalZoneItemInfo, "PersonalZoneItemInfo", false), nil, "UnlockedSystemHeadList", false, 0, nil)
end

function Auto.WritePersonalZoneHeadInfo(writer, val)
	Base.WritePrimitive(writer, Base.CheckEnum(val.HeadType, 27, 0), writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.SystemHeadId, writer.WriteUInt32, 0)
end

function Auto.WritePersonalZoneItemInfo(writer, val)
	Base.WritePrimitive(writer, val.Id, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.HadInteracted, writer.WriteBoolean, false)
end

function Auto.WritePersonalZoneSpiritInfo(writer, val)
	Base.WritePrimitive(writer, val.Id, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.Favor, writer.WriteInt32, 0)
end

function Auto.WritePhoneContact(writer, val)
	writer:WriteString(val.Remark, false, "PhoneContact.Remark", 0)
	writer:WriteString(val.PhoneNumber, false, "PhoneContact.PhoneNumber", 0)
end

function Auto.WritePhoneContactCallRecord(writer, val)
	Base.WritePrimitive(writer, val.CallTime, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, Base.CheckEnum(val.CallType, 25, 0), writer.WriteByte, 0)
	writer:WriteString(val.PhoneNumber, false, "PhoneContactCallRecord.PhoneNumber", 0)
end

function Auto.WritePhoneContactGroup(writer, val)
	writer:WriteString(val.Name, false, "PhoneContactGroup.Name", 0)
	Base.WriteList(writer, val.PhoneNumberList, Base.WriteStringWrap(false, "PhoneNumberList", 0), nil, "PhoneNumberList", false, 0, nil)
end

function Auto.WritePhoneInfos(writer, val)
	Base.WriteList(writer, val.ContactList, Base.WriteComplexWrap(Auto.WritePhoneContact, "PhoneContact", false), nil, "ContactList", false, 0, nil)
	Base.WriteList(writer, val.ContactGroupList, Base.WriteComplexWrap(Auto.WritePhoneContactGroup, "PhoneContactGroup", false), nil, "ContactGroupList", false, 0, nil)
	Base.WriteList(writer, val.CallRecordList, Base.WriteComplexWrap(Auto.WritePhoneContactCallRecord, "PhoneContactCallRecord", false), nil, "CallRecordList", false, 0, nil)
	Base.WriteDict(writer, val.ContactOutgoingCallTimesDict, Base.WriteStringWrap(false, "ContactOutgoingCallTimesDict", 0), writer.WriteUInt32, 0, "ContactOutgoingCallTimesDict", false, 0)
end

function Auto.WritePlacedFurnitureInfo(writer, val)
	Base.WritePrimitive(writer, val.FurnitureId, writer.WriteUInt32, 0)
	Base.WriteStruct(writer, val.Position, Auto.WriteUXVector3, "Position")
	Base.WriteStruct(writer, val.Rotation, Auto.WriteUXVector3, "Rotation")
	Base.WritePrimitive(writer, val.GadgetInstanceId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.PlacedInstanceId, writer.WriteUInt64, 0)
	Base.WriteDict(writer, val.ChildrenDict, writer.WriteUInt64, Base.WriteComplexWrap(Auto.WritePlacedFurnitureInfo, "PlacedFurnitureInfo", false), nil, "ChildrenDict", false, 0)
end

function Auto.WritePlanningBoardInfo(writer, val)
	Base.WriteDict(writer, val.StepId2OptionIndexDict, writer.WriteUInt32, writer.WriteByte, 0, "StepId2OptionIndexDict", false, 0)
end

function Auto.WritePlateGridAOIInfo(writer, val)
	Base.WriteList7Bit(writer, val.addInfos, Base.WriteComplexWrap(Auto.WritePlateInfo, "PlateInfo", true), nil, "addInfos", true, 0, nil)
	Base.WriteList7Bit(writer, val.removeIds, writer.WriteUInt64, 0, "removeIds", true, 0, nil)
	Base.WritePrimitive(writer, Base.CheckEnum(val.reason, 144, 0), writer.WriteByte, 0)
end

function Auto.WritePlateInfo(writer, val)
	Base.WritePrimitive(writer, val.UniqueId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.GraphId, writer.WriteInt32, 0)
	Base.WriteStruct(writer, val.Position, Auto.WriteUXVector3, "Position")
	Base.WriteStruct(writer, val.Rotation, Auto.WriteUXVector3, "Rotation")
	Base.WriteDict7Bit(writer, val.GadgetDic, writer.WriteInt32, writer.WriteUInt64, 0, "GadgetDic", true, 0)
	Base.WriteDict7Bit(writer, val.DestructibleDic, writer.WriteInt32, writer.WriteUInt64, 0, "DestructibleDic", true, 0)
	Base.WriteDict7Bit(writer, val.AgentDic, writer.WriteInt32, writer.WriteInt32, 0, "AgentDic", true, 0)
	Base.WriteDict7Bit(writer, val.VehicleDic, writer.WriteInt32, writer.WriteInt32, 0, "VehicleDic", true, 0)
	Base.WriteDict7Bit(writer, val.StaticNpcDic, writer.WriteInt32, writer.WriteInt32, 0, "StaticNpcDic", true, 0)
	Base.WritePrimitive(writer, val.FavorNpcActivityId, writer.WriteUInt32, 0)
end

function Auto.WritePlayActionData(writer, val)
	Base.WritePrimitive(writer, val.ActionId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.Uid, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.MaxTime, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.ActionUid, writer.WriteUInt32, 0)
end

function Auto.WritePlayActionWithLayerData(writer, val)
	Base.WritePrimitive(writer, val.ActionId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.Uid, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.MaxTime, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.ActionUid, writer.WriteUInt32, 0)
end

function Auto.WritePlayPoiCommandData(writer, val)
	Base.WritePrimitive(writer, val.SPoiActionId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.CPoiActionId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.IsActive, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.PlayPoiSpeed, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, Base.CheckEnum(val.DataSource, 97, 0), writer.WriteInt16, 0)
end

function Auto.WritePlayerBasicInfoVO(writer, val)
	Base.WritePrimitive(writer, val.Pid, writer.WriteUInt64, 0)
	writer:WriteString(val.Name, false, "PlayerBasicInfoVO.Name", 0)
	Base.WritePrimitive(writer, val.Level, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, Base.CheckEnum(val.Sex, 139, 0), writer.WriteByte, 0)
	Base.WriteComplex(writer, val.PzHeadInfo, Auto.WritePersonalZoneHeadInfo, "PzHeadInfo", false)
	Base.WriteComplex(writer, val.LinkPzHeadInfo, Auto.WritePersonalZoneHeadInfo, "LinkPzHeadInfo", false)
	Base.WritePrimitive(writer, val.LastLogoutTime, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.LastDetachTime, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.RaidId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, Base.CheckEnum(val.OnlineState, 194, 0), writer.WriteByte, 0)
	Base.WritePrimitive(writer, Base.CheckEnum(val.LinkMode, 9, 0), writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.LinkIndex, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.SyncRate, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.InRoom, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.InMatch, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.TeamId, writer.WriteUInt64, 0)
	writer:WriteString(val.AppChannel, false, "PlayerBasicInfoVO.AppChannel", 0)
	writer:WriteString(val.Signature, true, "PlayerBasicInfoVO.Signature", 0)
	Base.WritePrimitive(writer, val.Birthday, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.Background, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.Credit, writer.WriteUInt32, 0)
	Base.WriteComplex(writer, val.TierInfo, Auto.WritePlayerTierInfo, "TierInfo", true)
end

function Auto.WritePlayerBattlePassInfo(writer, val)
	Base.WritePrimitive(writer, val.BattlePassId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.Level, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.Exp, writer.WriteUInt32, 0)
	Base.WriteDict(writer, val.ClaimedLevelRewards, writer.WriteUInt32, writer.WriteByte, 0, "ClaimedLevelRewards", false, 0)
	Base.WritePrimitive(writer, Base.CheckEnum(val.PassType, 195, 0), writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.UnClaimedWeeklyExp, writer.WriteUInt32, 0)
	Base.WriteDict(writer, val.ChallengeTaskStates, writer.WriteUInt32, writer.WriteByte, 1, "ChallengeTaskStates", false, 0)
	Base.WritePrimitive(writer, val.WeeklyExpGained, writer.WriteUInt32, 0)
	Base.WriteDict(writer, val.WeeklyTaskCompletionCounts, writer.WriteUInt32, writer.WriteUInt32, 0, "WeeklyTaskCompletionCounts", false, 0)
end

function Auto.WritePlayerBattlePassInfos(writer, val)
	Base.WritePrimitive(writer, val.CurrentSeasonalBattlePassId, writer.WriteUInt32, 0)
	Base.WriteDict(writer, val.BattlePassInfoDict, writer.WriteUInt32, Base.WriteComplexWrap(Auto.WritePlayerBattlePassInfo, "PlayerBattlePassInfo", false), nil, "BattlePassInfoDict", false, 0)
	Base.WritePrimitive(writer, val.LastWeeklyRefresherTime, writer.WriteUInt32, 0)
end

function Auto.WritePlayerBeLikeInfo(writer, val)
	Base.WritePrimitive(writer, val.Pid, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.TimeStamp, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.MultiPlayerId, writer.WriteUInt32, 0)
end

function Auto.WritePlayerBeggarPaintScore(writer, val)
	Base.WritePrimitive(writer, val.SubjectRecognition, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.StrokeDedication, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.ColorExpression, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.CreativityBonus, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.TotalScore, writer.WriteSingle, 0)
end

function Auto.WritePlayerBuffLibraryEntry(writer, val)
	Base.WritePrimitive(writer, val.EntryId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.LibraryCfgId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.StartTimeMs, writer.WriteInt64, 0)
	Base.WritePrimitive(writer, val.TotalDurationMs, writer.WriteInt64, 0)
	Base.WritePrimitive(writer, val.ConsumedMs, writer.WriteInt64, 0)
	Base.WritePrimitive(writer, val.LastTickAnchorMs, writer.WriteInt64, 0)
	writer:WriteString(val.SourceTag, true, "PlayerBuffLibraryEntry.SourceTag", 0)
end

function Auto.WritePlayerCityPediaInfos(writer, val)
	Base.WriteDict(writer, val.CityPediaStatusDict, writer.WriteUInt32, writer.WriteByte, 0, "CityPediaStatusDict", false, 0)
	Base.WriteComplex(writer, val.CreditInfo, Auto.WriteCreditInfo, "CreditInfo", false)
end

function Auto.WritePlayerClientInfo(writer, val)
	Base.WriteBuffer7Bit(writer, val.Config, "Config", false, 0, nil)
	Base.WriteComplex(writer, val.InfoLogin, Auto.WritePlayerClientInfoLogin, "InfoLogin", false)
	Base.WriteComplex(writer, val.InfoItem, Auto.WritePlayerClientInfoItem, "InfoItem", false)
	Base.WriteComplex(writer, val.InfoSpirit, Auto.WritePlayerClientInfoSpirit, "InfoSpirit", false)
	Base.WriteComplex(writer, val.InfoMinor, Auto.WritePlayerClientInfoMinor, "InfoMinor", false)
	Base.WriteComplex(writer, val.InfoAchievement, Auto.WritePlayerClientInfoAchievement, "InfoAchievement", false)
end

function Auto.WritePlayerClientInfoAchievement(writer, val)
	Base.WriteDict7Bit(writer, val.SceneFogMaps, writer.WriteUInt32, Base.WriteComplexWrap(Auto.WriteSceneFogMap, "SceneFogMap", false), nil, "SceneFogMaps", true, 0)
	Base.WriteList7Bit(writer, val.SceneFogMapPoiIds, writer.WriteUInt32, 0, "SceneFogMapPoiIds", false, 0, nil)
	Base.WriteList7Bit(writer, val.UnlockedCountryList, writer.WriteUInt32, 0, "UnlockedCountryList", false, 0, nil)
	Base.WriteList7Bit(writer, val.UnlockedQuestList, writer.WriteUInt32, 0, "UnlockedQuestList", false, 0, nil)
	Base.WriteDict7Bit(writer, val.CompletedSubQuestCnt, writer.WriteUInt32, writer.WriteUInt32, 0, "CompletedSubQuestCnt", false, 0)
	Base.WriteDict7Bit(writer, val.ChallengeRecordInfo, writer.WriteUInt32, Base.WriteComplexWrap(Auto.WriteChallengeRecord, "ChallengeRecord", false), nil, "ChallengeRecordInfo", false, 0)
	Base.WriteDict7Bit(writer, val.NewChallengeRecordInfo, writer.WriteUInt32, Base.WriteComplexWrap(Auto.WriteNewChallengeRecord, "NewChallengeRecord", false), nil, "NewChallengeRecordInfo", false, 0)
	Base.WriteList7Bit(writer, val.FirstKillEnemyRecord, writer.WriteInt32, 0, "FirstKillEnemyRecord", false, 0, nil)
	Base.WriteList7Bit(writer, val.UnlockInvestigateGalleryList, writer.WriteUInt32, 0, "UnlockInvestigateGalleryList", false, 0, nil)
	Base.WritePrimitive(writer, val.InvestigateGalleryRedCnt, writer.WriteInt32, 0)
	Base.WriteDict7Bit(writer, val.CountryReputationInfo, writer.WriteUInt32, writer.WriteUInt32, 0, "CountryReputationInfo", false, 0)
	Base.WriteDict7Bit(writer, val.FactionInfoDic, writer.WriteUInt32, Base.WriteComplexWrap(Auto.WriteFactionInfo, "FactionInfo", false), nil, "FactionInfoDic", false, 0)
	Base.WriteList7Bit(writer, val.OccupiedInfluenceArea, writer.WriteUInt32, 0, "OccupiedInfluenceArea", false, 0, nil)
	Base.WriteDict7Bit(writer, val.AchievementInfos, writer.WriteUInt32, Base.WriteComplexWrap(Auto.WriteAchievementDetail, "AchievementDetail", false), nil, "AchievementInfos", false, 0)
end

function Auto.WritePlayerClientInfoAtmosphereGameplay(writer, val)
	Base.WritePrimitive(writer, val.PartTimeJobDailyRewardTimes, writer.WriteInt32, 0)
	Base.WriteList7Bit(writer, val.PartTimeJobUnlockStore, writer.WriteUInt32, 0, "PartTimeJobUnlockStore", true, 0, nil)
	Base.WriteDict7Bit(writer, val.WorldLifeDropLimit, writer.WriteUInt32, writer.WriteUInt32, 0, "WorldLifeDropLimit", false, 0)
end

function Auto.WritePlayerClientInfoGuide(writer, val)
	Base.WriteList7Bit(writer, val.FinishedGuides, writer.WriteUInt32, 0, "FinishedGuides", false, 0, nil)
	Base.WriteList7Bit(writer, val.NewGuideTeachInfos, writer.WriteUInt32, 0, "NewGuideTeachInfos", false, 0, nil)
	Base.WriteList7Bit(writer, val.RewardedGuideTeachInfos, writer.WriteUInt32, 0, "RewardedGuideTeachInfos", false, 0, nil)
	Base.WriteList7Bit(writer, val.UnlockSystems, writer.WriteUInt32, 0, "UnlockSystems", false, 0, nil)
	Base.WriteList7Bit(writer, val.TaskTitleGuideUnlockList, writer.WriteUInt16, 0, "TaskTitleGuideUnlockList", true, 0, nil)
end

function Auto.WritePlayerClientInfoItem(writer, val)
	Base.WritePrimitive(writer, val.Money, writer.WriteDouble, 0)
	Base.WritePrimitive(writer, val.Gold, writer.WriteDouble, 0)
	Base.WritePrimitive(writer, val.BindingGold, writer.WriteDouble, 0)
	Base.WritePrimitive(writer, val.FreeGold, writer.WriteDouble, 0)
	Base.WriteList7Bit(writer, val.ItemDayCounts, Base.WriteComplexWrap(Auto.WritePlayerItemDayCount, "PlayerItemDayCount", false), nil, "ItemDayCounts", false, 0, nil)
	Base.WriteList7Bit(writer, val.PackItems, Base.WriteComplexWrap(Auto.WritePlayerPackItem, "PlayerPackItem", false), nil, "PackItems", false, 0, nil)
	Base.WriteDict7Bit(writer, val.ItemShortcutDic, writer.WriteByte, Base.WriteComplexWrap(Auto.WriteItemShortcutInfo, "ItemShortcutInfo", false), nil, "ItemShortcutDic", false, 0)
	Base.WritePrimitive(writer, val.DestructibleShortcut, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.TodayGachaCount, writer.WriteUInt32, 0)
	Base.WriteDict7Bit(writer, val.GachaPoolCount, writer.WriteUInt32, writer.WriteInt32, 0, "GachaPoolCount", false, 0)
	Base.WriteList7Bit(writer, val.ItemCountLimitInfoList, Base.WriteComplexWrap(Auto.WriteItemCountLimitInfo, "ItemCountLimitInfo", false), nil, "ItemCountLimitInfoList", false, 0, nil)
	Base.WritePrimitive(writer, val.QuantumWalletStartTime, writer.WriteUInt32, 0)
	Base.WriteStruct(writer, val.PortalPosition, Auto.WriteUXVector3, "PortalPosition")
	Base.WritePrimitive(writer, val.PortalRaidId, writer.WriteUInt32, 0)
end

function Auto.WritePlayerClientInfoLogin(writer, val)
	Base.WritePrimitive(writer, val.Aid, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.Pid, writer.WriteUInt64, 0)
	writer:WriteString(val.AccountId, false, "PlayerClientInfoLogin.AccountId", 0)
	writer:WriteString(val.Name, false, "PlayerClientInfoLogin.Name", 0)
	Base.WritePrimitive(writer, val.Level, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, Base.CheckEnum(val.Sex, 139, 0), writer.WriteByte, 0)
	Base.WriteComplex(writer, val.PzHeadInfo, Auto.WritePersonalZoneHeadInfo, "PzHeadInfo", false)
	Base.WriteComplex(writer, val.LinkPzHeadInfo, Auto.WritePersonalZoneHeadInfo, "LinkPzHeadInfo", false)
	Base.WritePrimitive(writer, val.UseSystemName, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.LastLeaveClubTime, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.UniverseId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.LastChangeNameTime, writer.WriteUInt32, 0)
end

function Auto.WritePlayerClientInfoMinor(writer, val)
	Base.WritePrimitive(writer, val.Exp, writer.WriteInt64, 0)
	Base.WritePrimitive(writer, val.Fan, writer.WriteInt64, 0)
	Base.WritePrimitive(writer, val.Fan12, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.Fan123, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.YesterdayFan, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.Level, writer.WriteUInt32, 0)
	Base.WriteList7Bit(writer, val.LevelRewards, writer.WriteUInt32, 0, "LevelRewards", false, 0, nil)
	Base.WritePrimitive(writer, val.StageLv, writer.WriteUInt32, 0)
	Base.WriteDict7Bit(writer, val.ReceivedStageLvRewards, writer.WriteUInt32, writer.WriteUInt32, 0, "ReceivedStageLvRewards", false, 0)
	Base.WritePrimitive(writer, val.Questionnaire, writer.WriteInt32, 0)
	Base.WriteDict7Bit(writer, val.DropLimitCount, writer.WriteUInt32, Base.WriteComplexWrap(Auto.WriteDropLimitInfo, "DropLimitInfo", false), nil, "DropLimitCount", false, 0)
	Base.WriteComplex(writer, val.ChargeInfo, Auto.WriteChargeClientInfo, "ChargeInfo", false)
	Base.WriteDict7Bit(writer, val.MapPins, writer.WriteUInt64, Base.WriteComplexWrap(Auto.WriteMapPin, "MapPin", false), nil, "MapPins", false, 0)
	Base.WriteComplex(writer, val.MiniGame, Auto.WriteMiniGameData, "MiniGame", false)
	Base.WriteComplex(writer, val.PlayerInfoGuide, Auto.WritePlayerClientInfoGuide, "PlayerInfoGuide", false)
	Base.WriteComplex(writer, val.InfoNpcCultivation, Auto.WritePlayerClientInfoNpcCultivation, "InfoNpcCultivation", false)
	Base.WriteComplex(writer, val.InfoNpcProfile, Auto.WritePlayerClientInfoNpcProfile, "InfoNpcProfile", false)
	Base.WriteComplex(writer, val.PlayerInfoAtmosphereGameplay, Auto.WritePlayerClientInfoAtmosphereGameplay, "PlayerInfoAtmosphereGameplay", false)
	Base.WriteComplex(writer, val.PlayerFashionsInfo, Auto.WritePlayerFashionsInfo, "PlayerFashionsInfo", false)
	Base.WriteComplex(writer, val.PlayerRadioSongsData, Auto.WritePlayerRadioSongsData, "PlayerRadioSongsData", false)
	Base.WriteComplex(writer, val.housesInfo, Auto.WriteHousesInfo, "housesInfo", false)
	Base.WriteComplex(writer, val.PlayerPhoneInfo, Auto.WritePlayerPhoneClientInfo, "PlayerPhoneInfo", false)
	Base.WriteDict7Bit(writer, val.ModuleEventProgressInfoDict, writer.WriteByte, Base.WriteComplexWrap(Auto.WriteModuleEventProgressInfo, "ModuleEventProgressInfo", false), nil, "ModuleEventProgressInfoDict", false, 0)
	Base.WriteDict7Bit(writer, val.UniverseModuleEventProgressInfoDict, writer.WriteByte, Base.WriteComplexWrap(Auto.WriteModuleEventProgressInfo, "ModuleEventProgressInfo", false), nil, "UniverseModuleEventProgressInfoDict", false, 0)
	Base.WriteDict7Bit(writer, val.LoadingTexts, writer.WriteUInt32, Base.WriteComplexWrap(Auto.WriteLoadingTextInfo, "LoadingTextInfo", false), nil, "LoadingTexts", false, 0)
	Base.WriteDict7Bit(writer, val.Badges, writer.WriteUInt32, Base.WriteComplexWrap(Auto.WriteBadgeInfo, "BadgeInfo", false), nil, "Badges", false, 0)
	Base.WriteList7Bit(writer, val.GroupChats, Base.WriteComplexWrap(Auto.WriteSpiritGroupChatInfo, "SpiritGroupChatInfo", false), nil, "GroupChats", false, 0, nil)
	Base.WriteComplex(writer, val.VehicleInfo, Auto.WritePlayerVehicleInfo, "VehicleInfo", false)
	Base.WriteComplex(writer, val.MatchInfo, Auto.WritePlayerMatchInfo, "MatchInfo", false)
	Base.WriteComplex(writer, val.PopularityInfoNew, Auto.WritePlayerInfoPopularity, "PopularityInfoNew", false)
	Base.WriteComplex(writer, val.ComputerUnlockInfo, Auto.WriteComputerUnlockInfo, "ComputerUnlockInfo", false)
	Base.WriteComplex(writer, val.PlayerInteractionActionInfo, Auto.WritePlayerInteractionActionInfo, "PlayerInteractionActionInfo", false)
	Base.WriteComplex(writer, val.PlayerCityPediaInfos, Auto.WritePlayerCityPediaInfos, "PlayerCityPediaInfos", false)
	Base.WritePrimitive(writer, val.DebugReserveGpuDumps, writer.WriteBoolean, false)
	Base.WriteDict7Bit(writer, val.FavorNpcDailyScheduleInfos, writer.WriteUInt32, Base.WriteComplexWrap(Auto.WriteNpcTimeTableInfo, "NpcTimeTableInfo", false), nil, "FavorNpcDailyScheduleInfos", true, 0)
	Base.WriteDict7Bit(writer, val.PlayerInterActionInfo, writer.WriteUInt32, Base.WriteStringWrap(false, "PlayerInterActionInfo", 0), nil, "PlayerInterActionInfo", false, 0)
	Base.WriteComplex(writer, val.PlanningBoardInfo, Auto.WritePlanningBoardInfo, "PlanningBoardInfo", false)
	Base.WriteComplex(writer, val.MallInfo, Auto.WriteMallInfo, "MallInfo", false)
	Base.WriteComplex(writer, val.PlayerLinkPlanningBoardInfo, Auto.WritePlayerLinkPlanningBoardInfo, "PlayerLinkPlanningBoardInfo", false)
	Base.WriteComplex(writer, val.PlayerGachaInfos, Auto.WritePlayerGachaInfos, "PlayerGachaInfos", false)
	Base.WriteComplex(writer, val.PlayerInspireHubInfo, Auto.WritePlayerClientInspireHubInfo, "PlayerInspireHubInfo", false)
	Base.WriteComplex(writer, val.PlayerExtractionShooterInfo, Auto.WritePlayerExtractionShooterInfo, "PlayerExtractionShooterInfo", false)
	Base.WriteComplex(writer, val.PlayerOCInfo, Auto.WritePlayerOCInfo, "PlayerOCInfo", false)
	Base.WriteComplex(writer, val.PlayerTuiteInfo, Auto.WritePlayerTuiteClientInfo, "PlayerTuiteInfo", false)
	Base.WriteComplex(writer, val.playerMartialArtistInfo, Auto.WritePlayerInfoMartialArtist, "playerMartialArtistInfo", false)
	Base.WriteDict7Bit(writer, val.GameplayTalentInfos, writer.WriteUInt32, Base.WriteComplexWrap(Auto.WriteSpiritTalentInfo, "SpiritTalentInfo", false), nil, "GameplayTalentInfos", false, 0)
	Base.WriteComplex(writer, val.InfoSubmitItem, Auto.WritePlayerClientInfoSubmitItem, "InfoSubmitItem", false)
	Base.WriteComplex(writer, val.InfoCompound, Auto.WritePlayerCompoundClientInfo, "InfoCompound", false)
	Base.WriteComplex(writer, val.InfoOnlineSeasonProgress, Auto.WritePlayerOnlineSeasonProgressClientInfo, "InfoOnlineSeasonProgress", false)
	Base.WriteComplex(writer, val.PlayerTradeInfo, Auto.WritePlayerTradeInfo, "PlayerTradeInfo", false)
	Base.WriteComplex(writer, val.PlayerGiftInfo, Auto.WritePlayerGiftInfo, "PlayerGiftInfo", false)
	Base.WriteComplex(writer, val.PlayerClubTaskInfo, Auto.WriteClientClubTaskInfo, "PlayerClubTaskInfo", false)
	Base.WriteDict7Bit(writer, val.HUDRecommendDict, writer.WriteUInt32, Base.WriteComplexWrap(Auto.WriteHUDRecommendInfo, "HUDRecommendInfo", false), nil, "HUDRecommendDict", false, 0)
	Base.WriteComplex(writer, val.ChefUnlockInfo, Auto.WriteChefUnlockInfo, "ChefUnlockInfo", false)
	Base.WriteComplex(writer, val.FishingInfo, Auto.WritePlayerFishingInfo, "FishingInfo", false)
	Base.WriteComplex(writer, val.SettingInfo, Auto.WritePlayerSettingInfo, "SettingInfo", false)
	Base.WriteComplex(writer, val.InstrumentInfo, Auto.WritePlayerInstrumentInfo, "InstrumentInfo", false)
	Base.WriteComplex(writer, val.PlayerMeccaGrandpaPartsInfo, Auto.WritePlayerMeccaGrandpaPartsInfo, "PlayerMeccaGrandpaPartsInfo", false)
	Base.WriteComplex(writer, val.PlayerWeaponSkinInfo, Auto.WritePlayerWeaponSkinInfo, "PlayerWeaponSkinInfo", false)
	Base.WriteDict7Bit(writer, val.GadgetDropLimitInfo, writer.WriteUInt32, writer.WriteUInt32, 0, "GadgetDropLimitInfo", false, 0)
	Base.WriteComplex(writer, val.PlayerScenarioInfos, Auto.WritePlayerScenarioInfos, "PlayerScenarioInfos", false)
	Base.WriteComplex(writer, val.PlayerLikeInfo, Auto.WritePlayerLikeInfo, "PlayerLikeInfo", false)
end

function Auto.WritePlayerClientInfoNpcCultivation(writer, val)
	Base.WriteList7Bit(writer, val.NpcCardInfos, Base.WriteComplexWrap(Auto.WriteNpcCardInfo, "NpcCardInfo", false), nil, "NpcCardInfos", false, 0, nil)
	Base.WriteList7Bit(writer, val.LockedCardInfos, Base.WriteComplexWrap(Auto.WriteNpcCardInfo, "NpcCardInfo", false), nil, "LockedCardInfos", false, 0, nil)
	Base.WriteList7Bit(writer, val.NpcChats, Base.WriteComplexWrap(Auto.WriteClientNpcChatData, "ClientNpcChatData", false), nil, "NpcChats", false, 0, nil)
	Base.WriteList7Bit(writer, val.NpcGroupChats, Base.WriteComplexWrap(Auto.WriteClientNpcGroupChatData, "ClientNpcGroupChatData", false), nil, "NpcGroupChats", false, 0, nil)
	Base.WritePrimitive(writer, val.AvailableGiftSendCount, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.InteractPoint, writer.WriteUInt32, 0)
	Base.WriteComplex(writer, val.NpcEventQueueList, Auto.WriteNpcEventQueueList, "NpcEventQueueList", false)
	Base.WriteDict7Bit(writer, val.ChatGroupRenameDict, writer.WriteUInt32, writer.WriteUInt32, 0, "ChatGroupRenameDict", false, 0)
end

function Auto.WritePlayerClientInfoNpcProfile(writer, val)
	Base.WriteDict7Bit(writer, val.NpcProfiles, writer.WriteUInt32, Base.WriteComplexWrap(Auto.WriteTrustNpcInfo, "TrustNpcInfo", false), nil, "NpcProfiles", false, 0)
	Base.WriteList7Bit(writer, val.ProgressRewards, writer.WriteUInt32, 0, "ProgressRewards", false, 0, nil)
end

function Auto.WritePlayerClientInfoPolice(writer, val)
	Base.WritePrimitive(writer, val.TodayCompleteMissionCnt, writer.WriteUInt32, 0)
end

function Auto.WritePlayerClientInfoSpirit(writer, val)
	Base.WriteList7Bit(writer, val.Spirits, Base.WriteComplexWrap(Auto.WriteSpiritInfo, "SpiritInfo", false), nil, "Spirits", false, 0, nil)
	Base.WriteComplex(writer, val.InfoPokemon, Auto.WritePlayerInfoPokemon, "InfoPokemon", false)
	Base.WriteList7Bit(writer, val.AvailableSkinParts, writer.WriteUInt32, 0, "AvailableSkinParts", false, 0, nil)
	Base.WriteComplex(writer, val.InfoArmory, Auto.WritePlayerInfoArmory, "InfoArmory", false)
	Base.WritePrimitive(writer, val.ActiveSpirit, writer.WriteUInt32, 0)
	Base.WriteDict7Bit(writer, val.DisableBadgeInfosDict, writer.WriteUInt32, Base.WriteComplexWrap(Auto.WriteDisableBadgeInfos, "DisableBadgeInfos", false), nil, "DisableBadgeInfosDict", false, 0)
	Base.WriteComplex(writer, val.InfoFightStyle, Auto.WritePlayerInfoFightStyle, "InfoFightStyle", false)
	Base.WritePrimitive(writer, val.CommonSpiritTalentExp, writer.WriteUInt32, 0)
	Base.WriteComplex(writer, val.InfoPolice, Auto.WritePlayerClientInfoPolice, "InfoPolice", false)
	Base.WritePrimitive(writer, val.SexTransitionLastTime, writer.WriteUInt32, 0)
	Base.WriteList7Bit(writer, val.InstalledApps, writer.WriteUInt32, 0, "InstalledApps", false, 0, nil)
end

function Auto.WritePlayerClientInfoSubmitItem(writer, val)
	Base.WriteDict7Bit(writer, val.SubmitItemDataDict, writer.WriteUInt32, Base.WriteComplexWrap(Auto.WriteSubmitItemData, "SubmitItemData", false), nil, "SubmitItemDataDict", false, 0)
end

function Auto.WritePlayerClientInspireHubInfo(writer, val)
	Base.WriteDict7Bit(writer, val.TodayGamePlayJoinCountDict, writer.WriteUInt32, writer.WriteInt32, 0, "TodayGamePlayJoinCountDict", false, 0)
end

function Auto.WritePlayerCompoundClientInfo(writer, val)
	Base.WriteDict7Bit(writer, val.StationDataDict, writer.WriteUInt32, Base.WriteComplexWrap(Auto.WriteCompoundStationClientInfo, "CompoundStationClientInfo", false), nil, "StationDataDict", false, 0)
	Base.WriteDict7Bit(writer, val.UseRecords, writer.WriteUInt32, Base.WriteComplexWrap(Auto.WriteCompoundUseClientInfo, "CompoundUseClientInfo", false), nil, "UseRecords", false, 0)
end

function Auto.WritePlayerDieInfo(writer, val)
	Base.WritePrimitive(writer, Base.CheckEnum(val.Type, 151, 0), writer.WriteInt16, 0)
	Base.WritePrimitive(writer, val.SourceTemplateId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.SourceCreationId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.IsMatchGameComplete, writer.WriteBoolean, false)
end

function Auto.WritePlayerExtractionShooterInfo(writer, val)
	Base.WriteDict(writer, val.Bags, writer.WriteUInt32, Base.WriteComplexWrap(Auto.WriteExtractionShooterBagInfo, "ExtractionShooterBagInfo", false), nil, "Bags", false, 0)
	Base.WritePrimitive(writer, val.TokenCount, writer.WriteUInt32, 0)
	Base.WriteDict(writer, val.SlotGroups, writer.WriteUInt32, Base.WriteComplexWrap(Auto.WriteExtractionShooterSlotGroupInfo, "ExtractionShooterSlotGroupInfo", false), nil, "SlotGroups", false, 0)
	Base.WriteDict(writer, val.UnlockedExpansionIds, writer.WriteUInt32, writer.WriteBoolean, false, "UnlockedExpansionIds", false, 0)
	Base.WriteDict(writer, val.UnlockedBagIds, writer.WriteUInt32, writer.WriteBoolean, false, "UnlockedBagIds", false, 0)
	Base.WriteComplex(writer, val.BringOutBudget, Auto.WriteExtractionShooterBringOutBudget, "BringOutBudget", false)
end

function Auto.WritePlayerFashionsInfo(writer, val)
	Base.WriteDict(writer, val.SpiritFashionsInfoDict, writer.WriteUInt32, Base.WriteComplexWrap(Auto.WriteSpiritFashionsInfo, "SpiritFashionsInfo", false), nil, "SpiritFashionsInfoDict", false, 0)
	Base.WriteDict(writer, val.FashionInfoDict, writer.WriteUInt32, Base.WriteComplexWrap(Auto.WriteFashionInfo, "FashionInfo", false), nil, "FashionInfoDict", false, 0)
	Base.WriteList(writer, val.FavoriteFashionIdList, writer.WriteUInt32, 0, "FavoriteFashionIdList", false, 0, nil)
	Base.WriteList(writer, val.FavoriteFashionSuitIdList, writer.WriteUInt32, 0, "FavoriteFashionSuitIdList", false, 0, nil)
	Base.WritePrimitive(writer, val.DefaultSpiritIsInitDefaultFashion, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.ColoringCollectionScore, writer.WriteUInt32, 0)
end

function Auto.WritePlayerFightStyleUnLockChangeInfo(writer, val)
	Base.WriteComplex(writer, val.playerInfoFightStyle, Auto.WritePlayerInfoFightStyle, "playerInfoFightStyle", true)
	Base.WriteDict7Bit(writer, val.addOrUpdateUnlockInfo, writer.WriteUInt32, writer.WriteBoolean, false, "addOrUpdateUnlockInfo", true, 0)
end

function Auto.WritePlayerFishingGameplayInfo(writer, val)
	Base.WriteDict(writer, val.SpotPools, writer.WriteUInt32, Base.WriteComplexWrap(Auto.WritePlayerFishingSpotPool, "PlayerFishingSpotPool", false), nil, "SpotPools", false, 0)
	Base.WriteDict(writer, val.SpotLastRefreshTime, writer.WriteUInt32, writer.WriteUInt32, 0, "SpotLastRefreshTime", false, 0)
	Base.WriteDict(writer, val.SpotLastResetTime, writer.WriteUInt32, writer.WriteUInt32, 0, "SpotLastResetTime", false, 0)
end

function Auto.WritePlayerFishingInfo(writer, val)
	Base.WriteDict(writer, val.GearDict, writer.WriteUInt32, Base.WriteComplexWrap(Auto.WriteFishingGearInfo, "FishingGearInfo", false), nil, "GearDict", false, 0)
	Base.WriteDict(writer, val.ConsumableFishDict, writer.WriteUInt32, Base.WriteComplexWrap(Auto.WriteFishInfo, "FishInfo", false), nil, "ConsumableFishDict", false, 0)
	Base.WriteDict(writer, val.OrnamentalFishDict, writer.WriteUInt32, Base.WriteComplexWrap(Auto.WriteFishInfo, "FishInfo", false), nil, "OrnamentalFishDict", false, 0)
	Base.WritePrimitive(writer, val.NextUniqueId, writer.WriteUInt32, 0)
	Base.WriteComplex(writer, val.GameplayInfo, Auto.WritePlayerFishingGameplayInfo, "GameplayInfo", false)
end

function Auto.WritePlayerFishingSpotFish(writer, val)
	Base.WritePrimitive(writer, val.Id, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.FishConfigId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.SpawnTime, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.Weight, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.Length, writer.WriteSingle, 0)
end

function Auto.WritePlayerFishingSpotPool(writer, val)
	Base.WriteDict(writer, val.Fishes, writer.WriteUInt32, Base.WriteComplexWrap(Auto.WritePlayerFishingSpotFish, "PlayerFishingSpotFish", false), nil, "Fishes", false, 0)
end

function Auto.WritePlayerGachaGroupInfo(writer, val)
	Base.WritePrimitive(writer, val.TotalDrawCount, writer.WriteUInt32, 0)
	Base.WriteDict(writer, val.ClaimedMilestoneCounts, writer.WriteUInt32, writer.WriteBoolean, false, "ClaimedMilestoneCounts", false, 0)
end

function Auto.WritePlayerGachaInfos(writer, val)
	Base.WriteDict(writer, val.PoolInfos, writer.WriteUInt32, Base.WriteComplexWrap(Auto.WritePlayerGachaPoolInfo, "PlayerGachaPoolInfo", false), nil, "PoolInfos", false, 0)
	Base.WriteDict(writer, val.GroupInfos, writer.WriteUInt32, Base.WriteComplexWrap(Auto.WritePlayerGachaGroupInfo, "PlayerGachaGroupInfo", false), nil, "GroupInfos", false, 0)
	Base.WriteDict(writer, val.PityInfos, writer.WriteUInt32, Base.WriteComplexWrap(Auto.WritePlayerGachaPityInfo, "PlayerGachaPityInfo", false), nil, "PityInfos", false, 0)
end

function Auto.WritePlayerGachaPityInfo(writer, val)
	Base.WritePrimitive(writer, val.DrawsSinceLastReset, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.TotalDrawCount, writer.WriteUInt32, 0)
end

function Auto.WritePlayerGachaPoolInfo(writer, val)
	Base.WritePrimitive(writer, val.DrawCount, writer.WriteUInt32, 0)
	Base.WriteDict(writer, val.WonItemIds, writer.WriteUInt32, writer.WriteBoolean, false, "WonItemIds", false, 0)
end

function Auto.WritePlayerGameInfo(writer, val)
	Base.WritePrimitive(writer, val.MultiPlayerId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, Base.CheckEnum(val.State, 196, 0), writer.WriteByte, 0)
end

function Auto.WritePlayerGiftInfo(writer, val)
	Base.WriteList(writer, val.PendingGifts, Base.WriteComplexWrap(Auto.WritePendingGiftEntry, "PendingGiftEntry", false), nil, "PendingGifts", false, 0, nil)
	Base.WritePrimitive(writer, val.IsGiftOwnedInitialized, writer.WriteBoolean, false)
end

function Auto.WritePlayerGuitarInfo(writer, val)
	Base.WriteList(writer, val.ChordIds, writer.WriteInt32, 0, "ChordIds", false, RpcLengthLimits.PlayerGuitarInfo_ChordIds, nil)
	Base.WritePrimitive(writer, val.rhythmA, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.rhythmB, writer.WriteInt32, 0)
end

function Auto.WritePlayerHandData(writer, val)
	Base.WriteList7Bit(writer, val.HandTiles, Base.WriteStructWrap(Auto.WriteTile, "HandTiles"), nil, "HandTiles", false, 0, nil)
	Base.WriteList7Bit(writer, val.OpenMelds, Base.WriteStructWrap(Auto.WriteOpenMeld, "OpenMelds"), nil, "OpenMelds", false, 0, nil)
end

function Auto.WritePlayerHotSpringInfo(writer, val)
	Base.WritePrimitive(writer, val.StartTime, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.EndTime, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.CompanionNpc, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.Used, writer.WriteBoolean, false)
end

function Auto.WritePlayerHouseCameraConfiguration(writer, val)
	Base.WritePrimitive(writer, val.MoveSpeed, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.SpinSpeed, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.ZoomSpeed, writer.WriteSingle, 0)
end

function Auto.WritePlayerHouseConfiguration(writer, val)
	Base.WriteComplex(writer, val.Camera, Auto.WritePlayerHouseCameraConfiguration, "Camera", false)
end

function Auto.WritePlayerInfoArmory(writer, val)
	Base.WriteList(writer, val.Weapons, Base.WriteComplexWrap(Auto.WriteWeaponData, "WeaponData", false), nil, "Weapons", false, 0, nil)
end

function Auto.WritePlayerInfoBadge(writer, val)
	Base.WriteDict(writer, val.Badges, writer.WriteUInt32, Base.WriteComplexWrap(Auto.WriteBadgeInfo, "BadgeInfo", false), nil, "Badges", false, 0)
	Base.WriteDict(writer, val.HistoryBadges, writer.WriteUInt32, Base.WriteComplexWrap(Auto.WriteBadgeInfo, "BadgeInfo", false), nil, "HistoryBadges", false, 0)
end

function Auto.WritePlayerInfoFightStyle(writer, val)
	Base.WriteDict(writer, val.FightStyleIsUnLocked, writer.WriteUInt32, writer.WriteBoolean, false, "FightStyleIsUnLocked", false, 0)
end

function Auto.WritePlayerInfoGameGroundChineseChess(writer, val)
	Base.WriteDict(writer, val.DroppedEndGameIdSet, writer.WriteUInt32, writer.WriteBoolean, false, "DroppedEndGameIdSet", false, 0)
	Base.WriteDict(writer, val.DroppedDoubleAIDifficultySet, writer.WriteUInt32, writer.WriteBoolean, false, "DroppedDoubleAIDifficultySet", false, 0)
end

function Auto.WritePlayerInfoGameGroundGomoku(writer, val)
	Base.WriteDict(writer, val.DroppedEndGameIdSet, writer.WriteUInt32, writer.WriteBoolean, false, "DroppedEndGameIdSet", false, 0)
	Base.WriteDict(writer, val.DroppedDoubleAIDifficultySet, writer.WriteUInt32, writer.WriteBoolean, false, "DroppedDoubleAIDifficultySet", false, 0)
end

function Auto.WritePlayerInfoJobGangBoss(writer, val)
	Base.WriteDict(writer, val.GangMembers, writer.WriteUInt32, Base.WriteComplexWrap(Auto.WriteGangMembersInfos, "GangMembersInfos", false), nil, "GangMembers", false, 0)
end

function Auto.WritePlayerInfoJobWasher(writer, val)
	Base.WritePrimitive(writer, val.LastRefreshMissionTime, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.CurMissionIndex, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.CurMissionId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.CurMissionEventId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.CurMissionProgress, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.CurMissionStartTime, writer.WriteUInt32, 0)
	Base.WriteList(writer, val.HistoryMissionResults, Base.WriteComplexWrap(Auto.WriteWasherMissionResult, "WasherMissionResult", false), nil, "HistoryMissionResults", false, 0, nil)
	Base.WriteComplex(writer, val.CurMissionResult, Auto.WriteWasherMissionResult, "CurMissionResult", true)
	Base.WriteList(writer, val.RandomMissionHistory, Base.WriteComplexWrap(Auto.WriteWasherMissionHistoryItem, "WasherMissionHistoryItem", false), nil, "RandomMissionHistory", false, 0, nil)
	Base.WriteDict(writer, val.Spirit2HistoryMissionInfo, writer.WriteUInt32, Base.WriteComplexWrap(Auto.WriteWasherMissionHistoryInfo, "WasherMissionHistoryInfo", false), nil, "Spirit2HistoryMissionInfo", false, 0)
	Base.WritePrimitive(writer, val.HistoryMissionCnt, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.HistoryMissionMoney, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.TodayMissionMoney, writer.WriteInt32, 0)
	Base.WriteDict(writer, val.MissionDic, writer.WriteUInt32, Base.WriteComplexWrap(Auto.WriteWasherMissionHistoryItem, "WasherMissionHistoryItem", false), nil, "MissionDic", false, 0)
	Base.WritePrimitive(writer, val.CurRandomCfgId, writer.WriteUInt32, 0)
end

function Auto.WritePlayerInfoMartialArtist(writer, val)
	Base.WriteDict(writer, val.RumorBackpack, writer.WriteUInt32, writer.WriteBoolean, false, "RumorBackpack", false, 0)
	Base.WriteDict(writer, val.SlottedRumors, writer.WriteUInt32, Base.WriteComplexWrap(Auto.WriteMartialArtistSlotInfo, "MartialArtistSlotInfo", false), nil, "SlottedRumors", false, 0)
	Base.WriteDict(writer, val.FinishedWuxueId, writer.WriteUInt32, writer.WriteBoolean, false, "FinishedWuxueId", false, 0)
	Base.WriteDict(writer, val.CompletedQuests, writer.WriteUInt32, writer.WriteBoolean, false, "CompletedQuests", false, 0)
	Base.WriteDict(writer, val.UnlockedQuests, writer.WriteUInt32, writer.WriteBoolean, false, "UnlockedQuests", false, 0)
end

function Auto.WritePlayerInfoPokemon(writer, val)
	Base.WriteList(writer, val.AllPokemons, Base.WriteComplexWrap(Auto.WritePokemonEnemy, "PokemonEnemy", false), nil, "AllPokemons", false, 0, nil)
	Base.WriteList(writer, val.FastFightSquad, writer.WriteUInt64, 0, "FastFightSquad", false, 0, nil)
end

function Auto.WritePlayerInfoPopularity(writer, val)
	Base.WritePrimitive(writer, val.Popularity, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.NextPopularityUpdateTime, writer.WriteUInt32, 0)
	Base.WriteList(writer, val.HistoryPopularityList, Base.WriteComplexWrap(Auto.WritePopularityData, "PopularityData", false), nil, "HistoryPopularityList", false, 0, nil)
	Base.WriteList(writer, val.PastDaysPopularityList, Base.WriteComplexWrap(Auto.WritePopularityData, "PopularityData", false), nil, "PastDaysPopularityList", false, 0, nil)
	Base.WritePrimitive(writer, val.TotalLeftMoney, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.LastPopularityUpdateTime, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.NextYesterdayAvgPopularityUpdateTime, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.TodayCoinGet, writer.WriteUInt32, 0)
	Base.WriteList(writer, val.PastHoursCoinRewards, Base.WriteComplexWrap(Auto.WritePopularityWalletRewardData, "PopularityWalletRewardData", false), nil, "PastHoursCoinRewards", false, 0, nil)
	Base.WriteComplex(writer, val.FanBoxDropInfo, Auto.WriteFanBoxDropInfo, "FanBoxDropInfo", false)
	Base.WritePrimitive(writer, val.YesterdayCoinGet, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.YesterdayAvgPopularity, writer.WriteInt32, 0)
end

function Auto.WritePlayerInstrumentInfo(writer, val)
	Base.WriteDict(writer, val.GuitarInfos, writer.WriteUInt32, Base.WriteComplexWrap(Auto.WritePlayerGuitarInfo, "PlayerGuitarInfo", false), nil, "GuitarInfos", false, 0)
end

function Auto.WritePlayerInteractionActionInfo(writer, val)
	Base.WriteDict(writer, val.UnlockActionItemDict, writer.WriteUInt32, Base.WriteComplexWrap(Auto.WritePlayerInteractionActionItem, "PlayerInteractionActionItem", false), nil, "UnlockActionItemDict", false, 0)
	Base.WritePrimitive(writer, val.InvitedNotDisturb, writer.WriteBoolean, false)
end

function Auto.WritePlayerInteractionActionItem(writer, val)
	Base.WritePrimitive(writer, val.CfgId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.UnlockTime, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.ShowRedPoint, writer.WriteBoolean, false)
end

function Auto.WritePlayerInvestigateCountryInfo(writer, val)
	Base.WritePrimitive(writer, val.CountryId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.Reputation, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.IsShow, writer.WriteBoolean, false)
	Base.WriteList(writer, val.GalleryInfos, Base.WriteComplexWrap(Auto.WritePlayerInvestigateGalleryInfo, "PlayerInvestigateGalleryInfo", false), nil, "GalleryInfos", false, 0, nil)
end

function Auto.WritePlayerInvestigateGalleryInfo(writer, val)
	Base.WritePrimitive(writer, val.GalleryId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.UnlockTime, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.IsArchived, writer.WriteBoolean, false)
	Base.WriteStruct(writer, val.Pos, Auto.WriteUXVector3, "Pos")
	Base.WritePrimitive(writer, val.Count, writer.WriteUInt32, 0)
end

function Auto.WritePlayerItemDayCount(writer, val)
	Base.WritePrimitive(writer, val.TemplateId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.Count, writer.WriteUInt32, 0)
end

function Auto.WritePlayerLikeInfo(writer, val)
	Base.WritePrimitive(writer, val.LastResetTime, writer.WriteUInt32, 0)
	Base.WriteDict(writer, val.HomepageLikes, writer.WriteUInt64, writer.WriteBoolean, false, "HomepageLikes", false, 0)
end

function Auto.WritePlayerLinkInfo(writer, val)
	Base.WritePrimitive(writer, Base.CheckEnum(val.PlayMode, 9, 0), writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.LinkId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.Level, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.RaidId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.PublicLinkId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.PrivateLinkId, writer.WriteUInt64, 0)
end

function Auto.WritePlayerLinkPlanningBoardInfo(writer, val)
	Base.WritePrimitive(writer, val.SelectedGameplayAttributeId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.LastRaidMultiPlayerId, writer.WriteUInt32, 0)
	Base.WriteDict(writer, val.MultiPlayerIdStates, writer.WriteUInt32, writer.WriteByte, 0, "MultiPlayerIdStates", false, 0)
end

function Auto.WritePlayerLoginOption(writer, val)
	Base.WritePrimitive(writer, Base.CheckEnum(val.Mode, 9, 0), writer.WriteByte, 0)
	Base.WritePrimitive(writer, Base.CheckEnum(val.Reason, 197, 0), writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.FastPlayRaidId, writer.WriteUInt32, 0)
	Base.WriteStruct(writer, val.FastPlayPosition, Auto.WriteUXVector3, "FastPlayPosition")
	Base.WritePrimitive(writer, Base.CheckEnum(val.FromWhere, 198, 0), writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.SkipLifeId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.JumpToMainEvent, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, Base.CheckEnum(val.DeviceLevel, 42, 0), writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.DisplayLevel, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.SceneItemQuality, writer.WriteInt32, 0)
	Base.WriteList(writer, val.ClientBundles, writer.WriteUInt32, 0, "ClientBundles", false, RpcLengthLimits.PlayerLoginOption_ClientBundles, nil)
	writer:WriteString(val.SubEmail, false, "PlayerLoginOption.SubEmail", RpcLengthLimits.PlayerLoginOption_SubEmail)
end

function Auto.WritePlayerMahjongInfo(writer, val)
	Base.WritePrimitive(writer, val.Pid, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.Score, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.Rank, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.MaxRank, writer.WriteUInt32, 0)
	Base.WriteList(writer, val.RewardRank, writer.WriteUInt32, 0, "RewardRank", false, 0, nil)
	Base.WritePrimitive(writer, val.GameCount, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.WinningStreakCount, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.LosingStreakCount, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.NpcCultivationId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.NpcMahjongId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.NpcRefreshTime, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.NpcAddFavorNum, writer.WriteUInt32, 0)
end

function Auto.WritePlayerMatchInfo(writer, val)
	Base.WriteDict(writer, val.GameId2LastPlayTime, writer.WriteUInt32, writer.WriteUInt32, 0, "GameId2LastPlayTime", false, 0)
	Base.WritePrimitive(writer, val.LastInviteAllTime, writer.WriteUInt32, 0)
	Base.WriteList(writer, val.AvailablePrepareActions, writer.WriteUInt32, 0, "AvailablePrepareActions", false, 0, nil)
	Base.WritePrimitive(writer, Base.CheckEnum(val.DeviceLevel, 39, 1), writer.WriteByte, 1)
	Base.WritePrimitive(writer, Base.CheckEnum(val.CurLinkDeviceLevel, 39, 1), writer.WriteByte, 1)
	Base.WriteComplex(writer, val.playerGameInfo, Auto.WritePlayerGameInfo, "playerGameInfo", false)
end

function Auto.WritePlayerMeccaGrandpaPartsInfo(writer, val)
	Base.WriteDict(writer, val.Parts, writer.WriteUInt32, Base.WriteComplexWrap(Auto.WriteMeccaGrandpaPartInfo, "MeccaGrandpaPartInfo", false), nil, "Parts", false, 0)
	Base.WriteComplex(writer, val.BuildInfo, Auto.WriteMeccaGrandpaBuildInfo, "BuildInfo", false)
end

function Auto.WritePlayerMonthlyPassInfo(writer, val)
	Base.WriteDict(writer, val.MonthlyPassInfos, writer.WriteUInt32, Base.WriteComplexWrap(Auto.WriteMonthlyPassInfo, "MonthlyPassInfo", false), nil, "MonthlyPassInfos", false, 0)
end

function Auto.WritePlayerOCInfo(writer, val)
	Base.WriteDict(writer, val.OCInfoDict, writer.WriteUInt64, Base.WriteComplexWrap(Auto.WriteOCInfo, "OCInfo", false), nil, "OCInfoDict", false, 0)
	Base.WriteDict(writer, val.SpeechInfosDict, Base.WriteStringWrap(false, "SpeechInfosDict", 0), Base.WriteComplexWrap(Auto.WriteOCSpeechInfo, "OCSpeechInfo", false), nil, "SpeechInfosDict", false, 0)
	Base.WritePrimitive(writer, val.PreGenerateOCId, writer.WriteUInt64, 0)
	Base.WriteComplex(writer, val.MemoryInfo, Auto.WriteOCMemoryInfo, "MemoryInfo", false)
	Base.WriteComplex(writer, val.OCMeccaGrandpaInfo, Auto.WriteOCMeccaGrandpaInfo, "OCMeccaGrandpaInfo", false)
	Base.WritePrimitive(writer, val.NextFashionOCId, writer.WriteUInt32, 0)
end

function Auto.WritePlayerOnlineSeasonProgressChangeInfo(writer, val)
	Base.WriteDict7Bit(writer, val.ChangedTaskStates, writer.WriteUInt32, writer.WriteByte, 0, "ChangedTaskStates", true, 0)
	Base.WriteDict7Bit(writer, val.ChangedExtraTaskStates, writer.WriteUInt32, Base.WriteComplexWrap(Auto.WritePlayerOnlineSessonTaskExtraState, "PlayerOnlineSessonTaskExtraState", false), nil, "ChangedExtraTaskStates", true, 0)
	Base.WritePrimitive(writer, val.SeasonId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.SeasonProgress, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.SeasonLevel, writer.WriteUInt32, 0)
	Base.WriteList7Bit(writer, val.ClaimedLevelRewards, writer.WriteUInt32, 0, "ClaimedLevelRewards", true, 0, nil)
	Base.WriteList7Bit(writer, val.PendingSeasonRewards, Base.WriteComplexWrap(Auto.WritePendingSeasonReward, "PendingSeasonReward", true), nil, "PendingSeasonRewards", true, 0, nil)
	Base.WritePrimitive(writer, val.IsSeasonUnlocked, writer.WriteBoolean, false)
end

function Auto.WritePlayerOnlineSeasonProgressClientInfo(writer, val)
	Base.WritePrimitive(writer, val.CurrentSeasonId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.IsSeasonUnlocked, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.SeasonProgress, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.SeasonLevel, writer.WriteUInt32, 0)
	Base.WriteList7Bit(writer, val.ClaimedLevelRewards, writer.WriteUInt32, 0, "ClaimedLevelRewards", false, 0, nil)
	Base.WriteDict7Bit(writer, val.TaskStates, writer.WriteUInt32, writer.WriteByte, 0, "TaskStates", false, 0)
	Base.WriteDict7Bit(writer, val.ExtraTaskStates, writer.WriteUInt32, Base.WriteComplexWrap(Auto.WritePlayerOnlineSessonTaskExtraState, "PlayerOnlineSessonTaskExtraState", false), nil, "ExtraTaskStates", false, 0)
	Base.WriteList7Bit(writer, val.PendingSeasonRewards, Base.WriteComplexWrap(Auto.WritePendingSeasonReward, "PendingSeasonReward", false), nil, "PendingSeasonRewards", false, 0, nil)
end

function Auto.WritePlayerOnlineSessonTaskExtraState(writer, val)
	Base.WritePrimitive(writer, val.CompleteCount, writer.WriteUInt32, 0)
end

function Auto.WritePlayerPackItem(writer, val)
	Base.WritePrimitive(writer, val.UniqueId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.TemplateId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.Count, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.IsNew, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.ExpiryTime, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, Base.CheckEnum(val.RemindState, 199, 0), writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.Quality, writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.Tags, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.IsBind, writer.WriteBoolean, false)
	Base.WriteDict(writer, val.Components, writer.WriteByte, Base.WriteComplexWrap(Auto.WritePlayerPackItemComponent, "PlayerPackItemComponent", false), nil, "Components", false, 0)
	Base.WritePrimitive(writer, val.CDFinishTime, writer.WriteUInt32, 0)
end

function Auto.WritePlayerPackItemComponent(writer, val)
end

function Auto.WritePlayerPartyInfo(writer, val)
	Base.WritePrimitive(writer, val.PartyTimes, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.ContinuousPartyTimes, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.lastPartyTime, writer.WriteUInt32, 0)
	Base.WriteList(writer, val.PartyNPC, writer.WriteUInt32, 0, "PartyNPC", false, 0, nil)
end

function Auto.WritePlayerPersonalZoneInfo(writer, val)
	writer:WriteString(val.RoleName, false, "PlayerPersonalZoneInfo.RoleName", 0)
	writer:WriteString(val.Signature, true, "PlayerPersonalZoneInfo.Signature", 0)
	Base.WritePrimitive(writer, val.Birthday, writer.WriteUInt32, 0)
	Base.WriteList7Bit(writer, val.BestNpcFriends, Base.WriteComplexWrap(Auto.WritePersonalZoneSpiritInfo, "PersonalZoneSpiritInfo", false), nil, "BestNpcFriends", false, 0, nil)
	Base.WritePrimitive(writer, val.Background, writer.WriteUInt32, 0)
end

function Auto.WritePlayerPhoneClientInfo(writer, val)
	Base.WriteDict7Bit(writer, val.SpiritPhoneInfos, writer.WriteUInt32, Base.WriteComplexWrap(Auto.WritePhoneInfos, "PhoneInfos", false), nil, "SpiritPhoneInfos", false, 0)
	Base.WriteList7Bit(writer, val.DownLoadAppIds, writer.WriteUInt32, 0, "DownLoadAppIds", false, 0, nil)
	Base.WriteList7Bit(writer, val.TempDisabledContactIds, writer.WriteUInt32, 0, "TempDisabledContactIds", false, 0, nil)
end

function Auto.WritePlayerPublicInfo(writer, val)
	Base.WritePrimitive(writer, val.Pid, writer.WriteUInt64, 0)
	Base.WriteComplex(writer, val.ScenarioInfo, Auto.WritePlayerScenarioPublicInfo, "ScenarioInfo", true)
end

function Auto.WritePlayerRacingCompetitionGroupInfo(writer, val)
	Base.WriteList7Bit(writer, val.UnlockCompetitionTypes, writer.WriteUInt32, 0, "UnlockCompetitionTypes", true, 0, nil)
	Base.WriteDict7Bit(writer, val.CompetitionGroupInfos, writer.WriteUInt32, Base.WriteComplexWrap(Auto.WriteRacingCompetitionGroupInfo, "RacingCompetitionGroupInfo", false), nil, "CompetitionGroupInfos", true, 0)
	Base.WriteDict7Bit(writer, val.CompetitionHistoryInfos, writer.WriteUInt32, Base.WriteComplexWrap(Auto.WriteRacingCompetitionInfo, "RacingCompetitionInfo", false), nil, "CompetitionHistoryInfos", true, 0)
	Base.WritePrimitive(writer, val.CompetitionPoint, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.CompetitionStar, writer.WriteInt32, 0)
	Base.WriteDict7Bit(writer, val.MemberCompetitionPoint, writer.WriteUInt32, writer.WriteUInt32, 0, "MemberCompetitionPoint", true, 0)
end

function Auto.WritePlayerRadioSongsData(writer, val)
	Base.WriteDict(writer, val.SongInfoDict, writer.WriteUInt32, writer.WriteBoolean, false, "SongInfoDict", false, 0)
end

function Auto.WritePlayerScenarioInfo(writer, val)
	writer:WriteString(val.SceneName, false, "PlayerScenarioInfo.SceneName", RpcLengthLimits.PlayerScenarioInfo_SceneName)
	Base.WriteComplex(writer, val.PublicInfo, Auto.WritePlayerScenarioPublicInfo, "PublicInfo", true)
end

function Auto.WritePlayerScenarioInfos(writer, val)
	Base.WritePrimitive(writer, val.CurSlot, writer.WriteUInt32, 0)
	Base.WriteDict(writer, val.PlayerScenarioInfoDict, writer.WriteUInt32, Base.WriteComplexWrap(Auto.WritePlayerScenarioInfo, "PlayerScenarioInfo", false), nil, "PlayerScenarioInfoDict", false, 0)
end

function Auto.WritePlayerScenarioPublicInfo(writer, val)
	Base.WritePrimitive(writer, val.SceneId, writer.WriteUInt32, 0)
	writer:WriteString(val.Thumbnail, false, "PlayerScenarioPublicInfo.Thumbnail", RpcLengthLimits.PlayerScenarioPublicInfo_Thumbnail)
	Base.WriteStruct(writer, val.Position, Auto.WriteUXVector3, "Position")
	Base.WriteStruct(writer, val.Rotation, Auto.WriteUXVector3, "Rotation")
	Base.WritePrimitive(writer, val.FieldOfView, writer.WriteUInt32, 0)
	Base.WriteList(writer, val.Vehicles, Base.WriteComplexWrap(Auto.WritePlayerScenarioVehicle, "PlayerScenarioVehicle", false), nil, "Vehicles", false, RpcLengthLimits.PlayerScenarioPublicInfo_Vehicles, nil)
	Base.WriteList(writer, val.Spirits, Base.WriteComplexWrap(Auto.WritePlayerScenarioSpirit, "PlayerScenarioSpirit", false), nil, "Spirits", false, RpcLengthLimits.PlayerScenarioPublicInfo_Spirits, nil)
end

function Auto.WritePlayerScenarioSpirit(writer, val)
	Base.WritePrimitive(writer, val.SpiritId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.SchemeIndex, writer.WriteByte, 0)
	Base.WriteComplex(writer, val.CustomFashionInfo, Auto.WriteFashionCustomSuitSchemeInfo, "CustomFashionInfo", true)
	Base.WritePrimitive(writer, val.ActionType, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.ActionGroup, writer.WriteUInt32, 0)
	writer:WriteString(val.IKType, false, "PlayerScenarioSpirit.IKType", RpcLengthLimits.PlayerScenarioSpirit_IKType)
	Base.WriteStruct(writer, val.Position, Auto.WriteUXVector3, "Position")
	Base.WriteStruct(writer, val.Rotation, Auto.WriteUXVector3, "Rotation")
	Base.WriteComplex(writer, val.FashionInfo, Auto.WriteSpiritWearFashionsInfo, "FashionInfo", true)
end

function Auto.WritePlayerScenarioVehicle(writer, val)
	Base.WritePrimitive(writer, val.VehicleId, writer.WriteUInt32, 0)
	Base.WriteStruct(writer, val.Position, Auto.WriteUXVector3, "Position")
	Base.WriteStruct(writer, val.Rotation, Auto.WriteUXVector3, "Rotation")
end

function Auto.WritePlayerSettingInfo(writer, val)
	Base.WriteDict(writer, val.SettingDict, writer.WriteUInt32, Base.WriteComplexWrap(Auto.WritePlayerSettingValue, "PlayerSettingValue", false), nil, "SettingDict", false, 0)
end

function Auto.WritePlayerSettingValue(writer, val)
	Base.WritePrimitive(writer, val.NumberValue, writer.WriteDouble, 0)
	writer:WriteString(val.StringValue, true, "PlayerSettingValue.StringValue", RpcLengthLimits.PlayerSettingValue_StringValue)
end

function Auto.WritePlayerSingleHouseConfiguration(writer, val)
	Base.WriteComplex(writer, val.Camera, Auto.WritePlayerHouseCameraConfiguration, "Camera", false)
end

function Auto.WritePlayerTierInfo(writer, val)
	Base.WriteDict(writer, val.Tiers, writer.WriteUInt32, Base.WriteComplexWrap(Auto.WriteTierDetail, "TierDetail", false), nil, "Tiers", false, 0)
	Base.WritePrimitive(writer, val.SeasonId, writer.WriteUInt32, 0)
end

function Auto.WritePlayerTradeInfo(writer, val)
	Base.WriteList(writer, val.ActiveOrders, Base.WriteComplexWrap(Auto.WriteTradeOrderRef, "TradeOrderRef", false), nil, "ActiveOrders", false, 0, nil)
	Base.WritePrimitive(writer, val.TradeBanExpireTime, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.LastListTime, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.LastCancelTime, writer.WriteUInt32, 0)
end

function Auto.WritePlayerTuiteClientInfo(writer, val)
	Base.WriteList7Bit(writer, val.TuiteList, Base.WriteStructWrap(Auto.WriteClientTuiteInfo, "TuiteList"), nil, "TuiteList", false, 0, nil)
end

function Auto.WritePlayerVehicleClientDetail(writer, val)
	Base.WritePrimitive(writer, val.Id, writer.WriteUInt32, 0)
	Base.WriteList7Bit(writer, val.Parts, Base.WriteStructWrap(Auto.WriteVehicleClientPart, "Parts"), nil, "Parts", true, 0, nil)
	Base.WritePrimitive(writer, val.SuitId, writer.WriteUInt32, 0)
end

function Auto.WritePlayerVehicleDetail(writer, val)
	Base.WritePrimitive(writer, val.Id, writer.WriteUInt32, 0)
	Base.WriteList(writer, val.Parts, Base.WriteComplexWrap(Auto.WritePlayerVehiclePartInfo, "PlayerVehiclePartInfo", false), nil, "Parts", false, 0, nil)
	Base.WritePrimitive(writer, val.UnlockTime, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.SuitId, writer.WriteUInt32, 0)
end

function Auto.WritePlayerVehicleDriveStateInfo(writer, val)
	Base.WritePrimitive(writer, val.Pid, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.EnterOrLeave, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.VehicleEntityId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.SeatIndex, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.IfForce, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.OpenDoorTypeId, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.OpenDoorActionSpeed, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.OpenDoorActionClipLength, writer.WriteInt32, 0)
end

function Auto.WritePlayerVehicleInfo(writer, val)
	Base.WriteList(writer, val.UnlockedVehicles, Base.WriteComplexWrap(Auto.WritePlayerVehicleDetail, "PlayerVehicleDetail", false), nil, "UnlockedVehicles", false, 0, nil)
	Base.WritePrimitive(writer, val.RequisitionVehicleCount, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.ParkingVehicleId, writer.WriteUInt32, 0)
end

function Auto.WritePlayerVehiclePartInfo(writer, val)
	Base.WritePrimitive(writer, val.VehiclePartId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.VehiclePartTag, writer.WriteUInt32, 0)
end

function Auto.WritePlayerWeaponSkinInfo(writer, val)
	Base.WriteDict(writer, val.SpiritWeaponSkinDict, writer.WriteUInt32, Base.WriteComplexWrap(Auto.WriteSpiritWeaponSkinInfo, "SpiritWeaponSkinInfo", false), nil, "SpiritWeaponSkinDict", false, 0)
	Base.WriteDict(writer, val.OwnedSkinIds, writer.WriteUInt32, writer.WriteBoolean, false, "OwnedSkinIds", false, 0)
end

function Auto.WritePlotMinMaxRange(writer, val)
	Base.WritePrimitive(writer, val.min, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.max, writer.WriteSingle, 0)
end

function Auto.WritePointInteractInfo(writer, val)
	Base.WritePrimitive(writer, val.NodeId, writer.WriteInt32, 0)
	Base.WriteStruct(writer, val.Pos, Auto.WriteUXVector3, "Pos")
	Base.WritePrimitive(writer, val.Index, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.Sprite, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.LabelId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.UseIndicate, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.DoNotFocusCamera, writer.WriteBoolean, false)
	Base.WriteStruct(writer, val.PlayerAction, Auto.WritePointInteractPlayerAction, "PlayerAction")
end

function Auto.WritePointInteractPlayerAction(writer, val)
	Base.WritePrimitive(writer, Base.CheckEnum(val.CommonInteractType, 200, 0), writer.WriteByte, 0)
	Base.WritePrimitive(writer, Base.CheckEnum(val.InteractPosType, 201, 0), writer.WriteByte, 0)
	Base.WriteStruct(writer, val.InteractPos, Auto.WriteUXVector3, "InteractPos")
	Base.WriteStruct(writer, val.InteractPosForward, Auto.WriteUXVector3, "InteractPosForward")
	Base.WritePrimitive(writer, val.InteractRadius, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.InteractLoopTime, writer.WriteSingle, 0)
	Base.WriteStruct(writer, val.InteractIkPos, Auto.WriteUXVector3, "InteractIkPos")
	Base.WriteStruct(writer, val.InteractIkPosForward, Auto.WriteUXVector3, "InteractIkPosForward")
	Base.WritePrimitive(writer, val.ChairType, writer.WriteInt32, 0)
end

function Auto.WritePointTransfer(writer, val)
	Base.WritePrimitive(writer, val.From, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.To, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.Amount, writer.WriteInt32, 0)
end

function Auto.WritePointTransferInfo(writer, val)
	Base.WriteList7Bit(writer, val.PlayerNames, Base.WriteStringWrap(false, "PlayerNames", 0), nil, "PlayerNames", false, 0, nil)
	Base.WriteList7Bit(writer, val.Points, writer.WriteInt32, 0, "Points", false, 0, nil)
	Base.WriteList7Bit(writer, val.PointTransfers, Base.WriteStructWrap(Auto.WritePointTransfer, "PointTransfers"), nil, "PointTransfers", false, 0, nil)
end

function Auto.WritePokemonEnemy(writer, val)
	Base.WritePrimitive(writer, val.Id, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.Body, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.Camp, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.Weapon, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.LimboChaId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.AcquireTime, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.IsLocked, writer.WriteBoolean, false)
end

function Auto.WritePoliceCaseInfo(writer, val)
	Base.WritePrimitive(writer, val.Time, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.NpcId, writer.WriteUInt32, 0)
	Base.WriteList(writer, val.Fines, writer.WriteUInt32, 0, "Fines", false, 0, nil)
	Base.WritePrimitive(writer, val.Sentence, writer.WriteInt32, 0)
	Base.WriteList(writer, val.Drops, writer.WriteUInt32, 0, "Drops", false, 0, nil)
	Base.WritePrimitive(writer, val.RewardTaken, writer.WriteBoolean, false)
	Base.WriteList(writer, val.BonusDrops, writer.WriteUInt32, 0, "BonusDrops", false, 0, nil)
	Base.WritePrimitive(writer, val.Id, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.IsFakePerson, writer.WriteBoolean, false)
	Base.WriteComplex(writer, val.InterrogationInfo, Auto.WritePoliceCaseInterrogationInfo, "InterrogationInfo", false)
	Base.WritePrimitive(writer, Base.CheckEnum(val.NpcImprisonStatus, 202, 0), writer.WriteByte, 0)
	Base.WriteList(writer, val.FinedCrimes, writer.WriteUInt32, 0, "FinedCrimes", false, 0, nil)
	Base.WriteList(writer, val.NoCheckCrimeList, writer.WriteUInt32, 0, "NoCheckCrimeList", false, 0, nil)
	Base.WriteList(writer, val.NoIssuedBonusDrops, writer.WriteUInt32, 0, "NoIssuedBonusDrops", false, 0, nil)
	Base.WritePrimitive(writer, val.HasUnlockClue, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, Base.CheckEnum(val.SourceType, 203, 0), writer.WriteByte, 0)
	Base.WriteList(writer, val.CrimeDefaultItems, writer.WriteUInt32, 0, "CrimeDefaultItems", false, 0, nil)
end

function Auto.WritePoliceCaseInterrogationInfo(writer, val)
	Base.WritePrimitive(writer, val.State, writer.WriteByte, 0)
	Base.WriteComplex(writer, val.NpcInfo, Auto.WritePoliceCaseNpcInterrogationInfo, "NpcInfo", false)
end

function Auto.WritePoliceCaseInterrogationRPSCardsInfo(writer, val)
	Base.WriteList(writer, val.Cards, Base.WriteStructWrap(Auto.WritePoliceRPSCardInfo, "Cards"), nil, "Cards", false, 0, nil)
end

function Auto.WritePoliceCaseNpcInterrogationInfo(writer, val)
	Base.WriteComplex(writer, val.RPSInfo, Auto.WritePoliceCaseNpcInterrogationRPS, "RPSInfo", true)
end

function Auto.WritePoliceCaseNpcInterrogationRPS(writer, val)
	Base.WriteComplex(writer, val.Cards, Auto.WritePoliceCaseInterrogationRPSCardsInfo, "Cards", false)
end

function Auto.WritePoliceChargingSkillInfo(writer, val)
	Base.WritePrimitive(writer, val.ChargingSkillId, writer.WriteUInt32, 0)
	Base.WriteStruct(writer, val.Position, Auto.WriteUXVector3, "Position")
	Base.WritePrimitive(writer, val.Facing, writer.WriteSingle, 0)
end

function Auto.WritePoliceDispatchExtraInfo(writer, val)
	Base.WritePrimitive(writer, val.PrisonerId, writer.WriteUInt64, 0)
end

function Auto.WritePoliceDispatchInfo(writer, val)
	Base.WritePrimitive(writer, val.Id, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.NextAvailableTime, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.IsTemp, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.TempEventId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.TodayArrestSupportTimes, writer.WriteUInt32, 0)
end

function Auto.WritePoliceDutyBasicInfo(writer, val)
	Base.WritePrimitive(writer, val.DailyViolationCount, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.LeaveDueTime, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.LastViolationUpdateTime, writer.WriteUInt32, 0)
	Base.WriteComplex(writer, val.ServiceData, Auto.WritePoliceServiceData, "ServiceData", false)
	Base.WriteComplex(writer, val.WeeklyServiceData, Auto.WritePoliceServiceData, "WeeklyServiceData", false)
	Base.WriteDict(writer, val.ViolationCdInfos, writer.WriteUInt32, writer.WriteUInt32, 0, "ViolationCdInfos", false, 0)
end

function Auto.WritePoliceFakeClueAgentInfo(writer, val)
	Base.WritePrimitive(writer, val.AgentId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.IsRead, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.ProvideClueTime, writer.WriteUInt32, 0)
end

function Auto.WritePoliceFakeFileInfo(writer, val)
	Base.WriteDict(writer, val.UnlockFileInfoDict, writer.WriteUInt32, Base.WriteComplexWrap(Auto.WriteSinglePoliceFakeFileInfo, "SinglePoliceFakeFileInfo", false), nil, "UnlockFileInfoDict", false, 0)
	Base.WriteList(writer, val.HistoryClueAgentInfoList, Base.WriteComplexWrap(Auto.WritePoliceFakeClueAgentInfo, "PoliceFakeClueAgentInfo", false), nil, "HistoryClueAgentInfoList", false, 0, nil)
end

function Auto.WritePoliceRPSBattleInfo(writer, val)
	Base.WritePrimitive(writer, val.Round, writer.WriteInt32, 0)
	Base.WriteComplex(writer, val.Player, Auto.WritePoliceRPSUnitBattleInfo, "Player", false)
	Base.WriteComplex(writer, val.Npc, Auto.WritePoliceRPSUnitBattleInfo, "Npc", false)
end

function Auto.WritePoliceRPSCardExpInfo(writer, val)
	Base.WritePrimitive(writer, val.CardType, writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.Exp, writer.WriteUInt32, 0)
end

function Auto.WritePoliceRPSCardInfo(writer, val)
	Base.WritePrimitive(writer, val.CardType, writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.StarLevel, writer.WriteByte, 0)
end

function Auto.WritePoliceRPSUnitBattleInfo(writer, val)
	Base.WritePrimitive(writer, val.HP, writer.WriteInt32, 0)
	Base.WriteList7Bit(writer, val.Cards, Base.WriteStructWrap(Auto.WritePoliceRPSCardInfo, "Cards"), nil, "Cards", false, 0, nil)
end

function Auto.WritePoliceServiceData(writer, val)
	Base.WritePrimitive(writer, val.DispatchTimes, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.PatrolTimes, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.ArrestTimes, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.FineCount, writer.WriteUInt32, 0)
	Base.WriteList(writer, val.TotalDrops, writer.WriteUInt32, 0, "TotalDrops", false, 0, nil)
	Base.WritePrimitive(writer, val.LastUpdateTime, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.CarFineCount, writer.WriteUInt32, 0)
end

function Auto.WritePoliceVehicleSpawnClientInfo(writer, val)
	Base.WritePrimitive(writer, val.Id, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.VehicleId, writer.WriteUInt32, 0)
	Base.WriteStruct(writer, val.Position, Auto.WriteUXVector3, "Position")
	Base.WritePrimitive(writer, val.Facing, writer.WriteSingle, 0)
	Base.WriteStruct(writer, val.EulerAngles, Auto.WriteUXVector3, "EulerAngles")
end

function Auto.WritePoliceVehicleSpawnConfigInfo(writer, val)
	Base.WritePrimitive(writer, val.ChaseRange, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.ChaseDirectlyRange, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.ApprehendRange, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.NavConfigId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.ChaseDirectlyConfigId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.PatrolSpeed, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.ChaseSpeed, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.ChaseDirectlySpeed, writer.WriteSingle, 0)
end

function Auto.WritePoliceViolationInfo(writer, val)
	Base.WritePrimitive(writer, val.Time, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.Id, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.LeaveDueTime, writer.WriteUInt32, 0)
end

function Auto.WritePopularityData(writer, val)
	Base.WritePrimitive(writer, val.Time, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.Value, writer.WriteInt32, 0)
end

function Auto.WritePopularityWalletRewardData(writer, val)
	Base.WritePrimitive(writer, val.Date, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.Reward, writer.WriteUInt32, 0)
end

function Auto.WritePosServerEffectData(writer, val)
	Base.WriteStruct(writer, val.Pos, Auto.WriteUXVector3, "Pos")
	Base.WriteStruct(writer, val.Rotation, Auto.WriteUXVector3, "Rotation")
	Base.WriteStruct(writer, val.Scale, Auto.WriteUXVector3, "Scale")
	Base.WritePrimitive(writer, val.EffectId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.InstanceId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.LogicEndTime, writer.WriteDouble, 0)
	Base.WritePrimitive(writer, val.ReleaserId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.ClientDestructibleId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.Duration, writer.WriteSingle, 0)
end

function Auto.WritePossiblePlayerData(writer, val)
	Base.WritePrimitive(writer, val.Pid, writer.WriteUInt64, 0)
	writer:WriteString(val.Name, false, "PossiblePlayerData.Name", 0)
	writer:WriteString(val.RaidName, true, "PossiblePlayerData.RaidName", 0)
end

function Auto.WritePostPlayerCommentClientInfo(writer, val)
	writer:WriteString(val.Comment, false, "PostPlayerCommentClientInfo.Comment", 0)
	Base.WritePrimitive(writer, val.CommentId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.IsFinish, writer.WriteBoolean, false)
end

function Auto.WritePostSimpleClientInfo(writer, val)
	Base.WritePrimitive(writer, val.Id, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, Base.CheckEnum(val.PostType, 204, 0), writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.PostConfigId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.Date, writer.WriteUInt32, 0)
	writer:WriteString(val.ImageUrl, true, "PostSimpleClientInfo.ImageUrl", 0)
	Base.WritePrimitive(writer, val.Approved, writer.WriteBoolean, false)
	writer:WriteString(val.Title, true, "PostSimpleClientInfo.Title", 0)
	Base.WritePrimitive(writer, val.Likes, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.Liked, writer.WriteBoolean, false)
	Base.WriteList7Bit(writer, val.LikeNpcs, writer.WriteUInt32, 0, "LikeNpcs", true, 0, nil)
	Base.WriteList7Bit(writer, val.Comments, writer.WriteUInt32, 0, "Comments", true, 0, nil)
	Base.WriteList7Bit(writer, val.PlayerComments, Base.WriteComplexWrap(Auto.WritePostPlayerCommentClientInfo, "PostPlayerCommentClientInfo", true), nil, "PlayerComments", true, 0, nil)
	Base.WritePrimitive(writer, val.IsRead, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.HasNewLike, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.AcquireCfgId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.ActivityCfgId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.IsStory, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.IsPinStory, writer.WriteBoolean, false)
end

function Auto.WritePreSwitchSpiritData(writer, val)
	Base.WritePrimitive(writer, val.SwitchSpiritConfigId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.NewSpiritConfigId, writer.WriteUInt32, 0)
	Base.WriteStruct(writer, val.Position, Auto.WriteUXVector3, "Position")
end

function Auto.WritePreTeleportOption(writer, val)
	Base.WritePrimitive(writer, val.configId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.teleportId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.ForceClear, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.TimeLineDration, writer.WriteUInt32, 0)
	Base.WriteStruct(writer, val.position, Auto.WriteUXVector3, "position")
	Base.WritePrimitive(writer, val.facing, writer.WriteSingle, 0)
	writer:WriteString(val.beforeResName, false, "PreTeleportOption.beforeResName", RpcLengthLimits.PreTeleportOption_beforeResName)
	Base.WritePrimitive(writer, val.customBeforeTrans, writer.WriteBoolean, false)
	Base.WriteStruct(writer, val.beforePosition, Auto.WriteUXVector3, "beforePosition")
	Base.WriteStruct(writer, val.beforeRot, Auto.WriteUXVector3, "beforeRot")
	writer:WriteString(val.loadingResName, false, "PreTeleportOption.loadingResName", RpcLengthLimits.PreTeleportOption_loadingResName)
	writer:WriteString(val.afterResName, false, "PreTeleportOption.afterResName", RpcLengthLimits.PreTeleportOption_afterResName)
	Base.WritePrimitive(writer, val.customAfterTrans, writer.WriteBoolean, false)
	Base.WriteStruct(writer, val.afterPosition, Auto.WriteUXVector3, "afterPosition")
	Base.WriteStruct(writer, val.afterRot, Auto.WriteUXVector3, "afterRot")
	Base.WritePrimitive(writer, val.afterWayPointId, writer.WriteInt32, 0)
	writer:WriteString(val.extParams, false, "PreTeleportOption.extParams", RpcLengthLimits.PreTeleportOption_extParams)
end

function Auto.WritePrepareRoomClient(writer, val)
	Base.WritePrimitive(writer, val.Id, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.GameId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.LeaderPid, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.PSNOnly, writer.WriteBoolean, false)
	Base.WriteList7Bit(writer, val.Members, Base.WriteComplexWrap(Auto.WriteMatchRoomMemberInfo, "MatchRoomMemberInfo", false), nil, "Members", false, 0, nil)
	Base.WriteList7Bit(writer, val.AIAgentMembers, Base.WriteComplexWrap(Auto.WriteMatchRoomAIAgentInfo, "MatchRoomAIAgentInfo", false), nil, "AIAgentMembers", false, 0, nil)
	Base.WriteList7Bit(writer, val.StageConfirmMembers, writer.WriteUInt64, 0, "StageConfirmMembers", false, 0, nil)
	Base.WriteDict7Bit(writer, val.PrepareInfos, writer.WriteUInt64, Base.WriteComplexWrap(Auto.WriteMatchPrepareInfo, "MatchPrepareInfo", false), nil, "PrepareInfos", false, 0)
	Base.WriteDict7Bit(writer, val.PlayerSwapInfos, writer.WriteUInt64, Base.WriteComplexWrap(Auto.WriteMatchPrepareRoomPlayerSwapInfo, "MatchPrepareRoomPlayerSwapInfo", false), nil, "PlayerSwapInfos", false, 0)
	Base.WritePrimitive(writer, Base.CheckEnum(val.State, 179, 0), writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.StageId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.StageStartTime, writer.WriteUInt32, 0)
	Base.WriteComplex(writer, val.Setting, Auto.WritePrepareRoomSetting, "Setting", false)
end

function Auto.WritePrepareRoomSetting(writer, val)
	Base.WritePrimitive(writer, val.AllowNonLeaderInvite, writer.WriteBoolean, false)
end

function Auto.WritePublicEventInfo(writer, val)
	Base.WritePrimitive(writer, val.CfgId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.EndTime, writer.WriteUInt32, 0)
end

function Auto.WriteQueryComponentInfo(writer, val)
	Base.WritePrimitive(writer, val.IsActive, writer.WriteBoolean, false)
	writer:WriteString(val.Name, false, "QueryComponentInfo.Name", 0)
	Base.WritePrimitive(writer, val.Script, writer.WriteBoolean, false)
end

function Auto.WriteQueryFieldInfo(writer, val)
	writer:WriteString(val.Name, true, "QueryFieldInfo.Name", 0)
	writer:WriteString(val.Value, true, "QueryFieldInfo.Value", 0)
	writer:WriteString(val.FieldType, true, "QueryFieldInfo.FieldType", 0)
	writer:WriteString(val.SelfType, true, "QueryFieldInfo.SelfType", 0)
	writer:WriteString(val.Exception, true, "QueryFieldInfo.Exception", 0)
	Base.WritePrimitive(writer, val.CanWrite, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.Leaf, writer.WriteBoolean, false)
end

function Auto.WriteQueryGameObjectFilter(writer, val)
	Base.WriteList(writer, val.Path, writer.WriteInt32, 0, "Path", true, 0, nil)
	writer:WriteString(val.Name, true, "QueryGameObjectFilter.Name", 0)
end

function Auto.WriteRPSInterrogationSelectResult(writer, val)
	Base.WriteStruct(writer, val.PlayerCard, Auto.WritePoliceRPSCardInfo, "PlayerCard")
	Base.WriteStruct(writer, val.NpcCard, Auto.WritePoliceRPSCardInfo, "NpcCard")
	Base.WritePrimitive(writer, Base.CheckEnum(val.RoundResult, 205, 1), writer.WriteByte, 1)
	Base.WritePrimitive(writer, val.PlayerHP, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.NpcHP, writer.WriteInt32, 0)
	Base.WriteComplex(writer, val.Settlement, Auto.WriteRPSInterrogationSettlementInfo, "Settlement", true)
	Base.WriteList7Bit(writer, val.RefreshedCards, Base.WriteStructWrap(Auto.WritePoliceRPSCardInfo, "RefreshedCards"), nil, "RefreshedCards", true, 0, nil)
end

function Auto.WriteRPSInterrogationSettlementInfo(writer, val)
	Base.WritePrimitive(writer, val.CaseId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, Base.CheckEnum(val.State, 41, 0), writer.WriteByte, 0)
end

function Auto.WriteRPSInterrogationStartInfo(writer, val)
	Base.WritePrimitive(writer, val.CaseId, writer.WriteUInt64, 0)
	Base.WriteComplex(writer, val.BattleInfo, Auto.WritePoliceRPSBattleInfo, "BattleInfo", false)
end

function Auto.WriteRaceSettleData(writer, val)
end

function Auto.WriteRacingCompetitionGroupInfo(writer, val)
	Base.WriteList(writer, val.CompetitionTrackInfos, Base.WriteComplexWrap(Auto.WriteRacingCompetitionInfo, "RacingCompetitionInfo", false), nil, "CompetitionTrackInfos", false, 0, nil)
end

function Auto.WriteRacingCompetitionInfo(writer, val)
	Base.WritePrimitive(writer, val.TrackId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.VehicleId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.CostTime, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.Rank, writer.WriteUInt16, 0)
	Base.WritePrimitive(writer, val.Star, writer.WriteUInt16, 0)
	Base.WritePrimitive(writer, val.BestRank, writer.WriteUInt16, 0)
	Base.WritePrimitive(writer, val.BestLapTime, writer.WriteUInt64, 0)
end

function Auto.WriteRacingParameters(writer, val)
	writer:WriteString(val.raceName, false, "RacingParameters.raceName", 0)
	Base.WritePrimitive(writer, val.routeId, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.discourageRatio, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.discourageCD, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.checkDiscourageLength, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.checkDiscourageWidth, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.checkDiscourageMinDeltaSpeed, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.checkDiscourageMaxDeltaSpeed, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.swayUnitTime, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.swayTime, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.Token, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.taskAIConfigId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.defaultSpeed, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.drivingFlags, writer.WriteInt32, 1)
	Base.WritePrimitive(writer, val.initSpeed, writer.WriteSingle, 0)
	Base.WriteList7Bit(writer, val.initTaskAIBuffList, Base.WriteStructWrap(Auto.WriteTaskVehicleBuffInitInfo, "initTaskAIBuffList"), nil, "initTaskAIBuffList", true, 0, nil)
	Base.WriteStruct(writer, val.commonParameters, Auto.WriteVehicleAICommonParameters, "commonParameters")
end

function Auto.WriteRacingParticipantInfo(writer, val)
	Base.WritePrimitive(writer, val.AiVehicleCfgId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.CheckPointIndex, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.Lap, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.RacingTotalTimeMilli, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.Pid, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.NpcCultivationId, writer.WriteUInt32, 0)
	Base.WriteComplex(writer, val.AIAgentInfo, Auto.WriteLinkAIAgentInfo, "AIAgentInfo", true)
	Base.WritePrimitive(writer, val.AgentInstanceId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.VehicleInstanceId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.SeatIndex, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.IsReady, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.IsPlayAgain, writer.WriteBoolean, false)
end

function Auto.WriteRacingResultData(writer, val)
	Base.WritePrimitive(writer, val.SeatIndex, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.Pid, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.AIVehicle, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.FinishTime, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.TotalTime, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.BestLapTime, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.IsBest, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.Rank, writer.WriteInt32, 0)
end

function Auto.WriteRacingZoneInfo(writer, val)
	Base.WritePrimitive(writer, val.CfgId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.StartTime, writer.WriteUInt32, 0)
	Base.WriteDict7Bit(writer, val.AIVehicleInfos, writer.WriteUInt64, writer.WriteUInt32, 0, "AIVehicleInfos", true, 0)
	Base.WriteList7Bit(writer, val.ResultData, Base.WriteComplexWrap(Auto.WriteRacingResultData, "RacingResultData", true), nil, "ResultData", true, 0, nil)
	writer:WriteString(val.ZoneSessionId, false, "RacingZoneInfo.ZoneSessionId", 0)
	Base.WritePrimitive(writer, val.GadgetUId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.TaskId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, Base.CheckEnum(val.StartReason, 106, 0), writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.GameTypeRandom, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, Base.CheckEnum(val.SyncReason, 107, 0), writer.WriteByte, 0)
	Base.WritePrimitive(writer, Base.CheckEnum(val.ZoneType, 108, 0), writer.WriteByte, 0)
	Base.WritePrimitive(writer, Base.CheckEnum(val.ZoneState, 109, 0), writer.WriteByte, 0)
	Base.WriteList7Bit(writer, val.ParticipantInfos, Base.WriteComplexWrap(Auto.WriteGameGroundParticipantInfo, "GameGroundParticipantInfo", true), nil, "ParticipantInfos", true, 0, nil)
	Base.WriteStruct(writer, val.CountDownInfo, Auto.WriteGameGroundZoneCountDownInfo, "CountDownInfo")
end

function Auto.WriteRadioRandomContent(writer, val)
	Base.WritePrimitive(writer, Base.CheckEnum(val.ContentType, 206, 0), writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.ContentId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.StartContentId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.EndContentId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, Base.CheckEnum(val.MarkType, 207, 1), writer.WriteByte, 1)
end

function Auto.WriteRadioSyncInfo(writer, val)
	Base.WritePrimitive(writer, Base.CheckEnum(val.EventType, 208, 1), writer.WriteByte, 1)
	Base.WritePrimitive(writer, val.VehicleId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.RadioIndex, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.SongIndex, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.SoundId, writer.WriteUInt32, 0)
	writer:WriteString(val.CloudSongId, false, "RadioSyncInfo.CloudSongId", RpcLengthLimits.RadioSyncInfo_CloudSongId)
	Base.WritePrimitive(writer, val.Volume, writer.WriteSingle, 0)
	Base.WriteComplex(writer, val.RandomContent, Auto.WriteRadioRandomContent, "RandomContent", true)
end

function Auto.WriteRaidBattleData(writer, val)
	Base.WritePrimitive(writer, val.EnterRaidTime, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.BattleTime, writer.WriteDouble, 0)
	Base.WriteList7Bit(writer, val.SpiritBattleDatas, Base.WriteComplexWrap(Auto.WriteSpiritBattleData, "SpiritBattleData", false), nil, "SpiritBattleDatas", false, 0, nil)
	Base.WritePrimitive(writer, val.ElementEffectCount, writer.WriteUInt32, 0)
end

function Auto.WriteRaidBattleUnitAgent(writer, val)
	Base.WritePrimitive(writer, val.SkillId, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.HSummonIndex, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.SpoonAgentId, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.SuitId, writer.WriteUInt32, 0)
	Base.WriteList7Bit(writer, val.FashionIdList, writer.WriteUInt32, 0, "FashionIdList", true, 0, nil)
	Base.WritePrimitive(writer, val.ParentId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.SpoonIndex, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.AutoBackIndex, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.VehicleId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.VehicleIndex, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.SourceWeaponId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.IsBorn, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.BattleAiS, writer.WriteBoolean, false)
	Base.WriteComplex(writer, val.agentSyncClientInfo, Auto.WriteAgentSyncClientInfo, "agentSyncClientInfo", true)
	Base.WritePrimitive(writer, val.WeaponId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, Base.CheckEnum(val.SpawnType, 158, 0), writer.WriteByte, 0)
	Base.WritePrimitive(writer, Base.CheckEnum(val.AnimateCullingMode, 209, 0), writer.WriteByte, 0)
	Base.WriteComplex(writer, val.AIAgentInfo, Auto.WriteLinkAIAgentInfo, "AIAgentInfo", true)
	Base.WritePrimitive(writer, val.Id, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.TemplateId, writer.WriteUInt32, 0)
	Base.WriteStruct(writer, val.Position, Auto.WriteUXVector3, "Position")
	Base.WritePrimitive(writer, val.FacingDirection, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.OwnerId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.ManagedPid, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.MoveId, writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.NavTags, writer.WriteUInt32, 0)
	Base.WriteComplex(writer, val.GroundData, Auto.WriteMoveActionGroundData, "GroundData", true)
end

function Auto.WriteRaidBattleUnitBase(writer, val)
	Base.WritePrimitive(writer, val.Id, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.TemplateId, writer.WriteUInt32, 0)
	Base.WriteStruct(writer, val.Position, Auto.WriteUXVector3, "Position")
	Base.WritePrimitive(writer, val.FacingDirection, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.OwnerId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.ManagedPid, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.MoveId, writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.NavTags, writer.WriteUInt32, 0)
	Base.WriteComplex(writer, val.GroundData, Auto.WriteMoveActionGroundData, "GroundData", true)
end

function Auto.WriteRaidBattleUnitSpirit(writer, val)
	Base.WriteComplex(writer, val.SpiritWearFashionsInfo, Auto.WriteOtherPlayerSpiritWearFashionsInfo, "SpiritWearFashionsInfo", true)
	Base.WritePrimitive(writer, val.Begging, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.IsBot, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.Id, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.TemplateId, writer.WriteUInt32, 0)
	Base.WriteStruct(writer, val.Position, Auto.WriteUXVector3, "Position")
	Base.WritePrimitive(writer, val.FacingDirection, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.OwnerId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.ManagedPid, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.MoveId, writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.NavTags, writer.WriteUInt32, 0)
	Base.WriteComplex(writer, val.GroundData, Auto.WriteMoveActionGroundData, "GroundData", true)
end

function Auto.WriteRaidCleaningInfo(writer, val)
	Base.WritePrimitive(writer, val.CleaningProcess, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.TaskId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.StartTime, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.TotalSecond, writer.WriteUInt32, 0)
end

function Auto.WriteRaidGamePlayInfo(writer, val)
	Base.WriteDict7Bit(writer, val.RecordValueInfo, writer.WriteUInt32, Base.WriteComplexWrap(Auto.WriteRaidGamePlayRecordValueInfo, "RaidGamePlayRecordValueInfo", false), nil, "RecordValueInfo", true, 0)
end

function Auto.WriteRaidGamePlayRecordValueInfo(writer, val)
	Base.WriteDict7Bit(writer, val.DoubleValueDic, writer.WriteUInt32, writer.WriteDouble, 0, "DoubleValueDic", false, 0)
end

function Auto.WriteRaidSettleData(writer, val)
	Base.WritePrimitive(writer, val.CanNextGame, writer.WriteBoolean, false)
	Base.WriteList(writer, val.AchievedEventIds, writer.WriteUInt32, 0, "AchievedEventIds", false, 0, nil)
	Base.WriteDict(writer, val.WeaponKillCounts, writer.WriteUInt32, writer.WriteUInt32, 0, "WeaponKillCounts", false, 0)
end

function Auto.WriteRaidVehicleGpsInfo(writer, val)
	Base.WritePrimitive(writer, val.BelongPid, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.TargetRaidId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, Base.CheckEnum(val.Type, 210, 0), writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.TargetInstanceId, writer.WriteUInt64, 0)
	Base.WriteStruct(writer, val.TargetPosition, Auto.WriteUXVector3, "TargetPosition")
end

function Auto.WriteRaidVehicleSeatInfo(writer, val)
	Base.WritePrimitive(writer, val.EntityId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.SeatIndex, writer.WriteByte, 0)
	Base.WritePrimitive(writer, Base.CheckEnum(val.SeatState, 211, 0), writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.DestroyRelated, writer.WriteBoolean, false)
end

function Auto.WriteRaidVehicleSyncData(writer, val)
	Base.WritePrimitive(writer, val.Id, writer.WriteUInt64, 0)
	Base.WriteStruct(writer, val.Position, Auto.WriteUXVector3, "Position")
	Base.WritePrimitive(writer, val.facingDirection, writer.WriteSingle, 0)
	Base.WriteStruct(writer, val.EulerAngles, Auto.WriteUXVector3, "EulerAngles")
	Base.WriteStruct(writer, val.Velocity, Auto.WriteUXVector3, "Velocity")
	Base.WriteList7Bit(writer, val.Bits, writer.WriteByte, 0, "Bits", false, RpcLengthLimits.RaidVehicleSyncData_Bits, nil)
	Base.WritePrimitive(writer, val.MoveToken, writer.WriteInt32, 0)
end

function Auto.WriteRamParameters(writer, val)
	Base.WritePrimitive(writer, val.TargetUid, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.StraightLineDistance, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.UseContinuousRam, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.Token, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.taskAIConfigId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.defaultSpeed, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.drivingFlags, writer.WriteInt32, 1)
	Base.WritePrimitive(writer, val.initSpeed, writer.WriteSingle, 0)
	Base.WriteList7Bit(writer, val.initTaskAIBuffList, Base.WriteStructWrap(Auto.WriteTaskVehicleBuffInitInfo, "initTaskAIBuffList"), nil, "initTaskAIBuffList", true, 0, nil)
	Base.WriteStruct(writer, val.commonParameters, Auto.WriteVehicleAICommonParameters, "commonParameters")
end

function Auto.WriteRangeMoveType(writer, val)
	Base.WritePrimitive(writer, val.MinDistance, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.MaxDistance, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, Base.CheckEnum(val.Method, 104, 0), writer.WriteByte, 0)
end

function Auto.WriteRankQueryOptions(writer, val)
	Base.WritePrimitive(writer, val.CycleId, writer.WriteUInt32, 0)
	Base.WriteStruct(writer, val.Slot, Auto.WriteClientSubRankSlot, "Slot")
	Base.WritePrimitive(writer, val.Start, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.Limit, writer.WriteUInt32, 0)
end

function Auto.WriteRayCast4DResInfo(writer, val)
	Base.WritePrimitive(writer, val.Uid, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.ResultFront, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.ResultBack, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.ResultLeft, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.ResultRight, writer.WriteBoolean, false)
end

function Auto.WriteReactTraitFreeConditionData(writer, val)
end

function Auto.WriteRecommendClubInfo(writer, val)
	Base.WritePrimitive(writer, val.Id, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.MemberCount, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.MaxCount, writer.WriteUInt32, 0)
	writer:WriteString(val.Name, false, "RecommendClubInfo.Name", 0)
	Base.WritePrimitive(writer, val.IconCfgId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.Level, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.Applied, writer.WriteBoolean, false)
end

function Auto.WriteReconnectCommand(writer, val)
	Base.WritePrimitive(writer, val.RpcId, writer.WriteInt64, 0)
	Base.WritePrimitive(writer, val.HasRpcId, writer.WriteBoolean, false)
end

function Auto.WriteRelationVO(writer, val)
	Base.WritePrimitive(writer, val.Pid, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.Both, writer.WriteBoolean, false)
	writer:WriteString(val.RemarkName, true, "RelationVO.RemarkName", 0)
	Base.WritePrimitive(writer, val.AddFriendTime, writer.WriteUInt32, 0)
end

function Auto.WriteReportBehaviorSeqCommandEndInfo(writer, val)
	Base.WritePrimitive(writer, val.Uid, writer.WriteUInt64, 0)
	writer:WriteString(val.SmartObjectTemplate, true, "ReportBehaviorSeqCommandEndInfo.SmartObjectTemplate", RpcLengthLimits.ReportBehaviorSeqCommandEndInfo_SmartObjectTemplate)
	Base.WritePrimitive(writer, val.PointIndex, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.CommandIndex, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, Base.CheckEnum(val.Type, 73, 0), writer.WriteByte, 0)
	Base.WriteStruct(writer, val.Cmd, Auto.WriteBehaviorSeqCommand, "Cmd")
end

function Auto.WriteReportBehaviorSeqStartInfo(writer, val)
	Base.WritePrimitive(writer, val.Uid, writer.WriteUInt64, 0)
	writer:WriteString(val.SmartObjectTemplate, true, "ReportBehaviorSeqStartInfo.SmartObjectTemplate", RpcLengthLimits.ReportBehaviorSeqStartInfo_SmartObjectTemplate)
	Base.WritePrimitive(writer, val.PointIndex, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.CommandIndex, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, Base.CheckEnum(val.Type, 73, 0), writer.WriteByte, 0)
	Base.WriteStruct(writer, val.Cmd, Auto.WriteBehaviorSeqCommand, "Cmd")
end

function Auto.WriteResetFashionColoringInfo(writer, val)
	Base.WriteList7Bit(writer, val.resetColoringTypeList, writer.WriteByte, 0, "resetColoringTypeList", true, 0, nil)
end

function Auto.WriteResetFashionColoringSchemeInfo(writer, val)
	Base.WritePrimitive(writer, val.FashionId, writer.WriteUInt32, 0)
	Base.WriteDict7Bit(writer, val.resetFashionColoringSchemeInfoDict, writer.WriteByte, Base.WriteComplexWrap(Auto.WriteResetFashionColoringInfo, "ResetFashionColoringInfo", false), nil, "resetFashionColoringSchemeInfoDict", true, 0)
end

function Auto.WriteRestaurantResult(writer, val)
	Base.WritePrimitive(writer, val.RestaurantId, writer.WriteUInt32, 0)
end

function Auto.WriteRewardCollectionInfo(writer, val)
	Base.WritePrimitive(writer, val.CountryId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.BlockId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.SubQuestId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.Count, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.TotalCount, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.InvestigatorGalleryId, writer.WriteUInt32, 0)
end

function Auto.WriteRewardDetail(writer, val)
	Base.WriteDict(writer, val.DropIdCnt, writer.WriteUInt32, writer.WriteUInt32, 0, "DropIdCnt", false, 0)
	Base.WritePrimitive(writer, val.ReasonTextId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.FactionMerge, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.Money, writer.WriteDouble, 0)
	Base.WritePrimitive(writer, val.Gold, writer.WriteDouble, 0)
	Base.WritePrimitive(writer, val.BindingGold, writer.WriteDouble, 0)
	Base.WritePrimitive(writer, val.FreeGold, writer.WriteDouble, 0)
	Base.WriteList(writer, val.Items, Base.WriteComplexWrap(Auto.WriteItemCountInfo, "ItemCountInfo", false), nil, "Items", false, 0, nil)
	Base.WriteList(writer, val.UrbanAbilityInfo, Base.WriteComplexWrap(Auto.WriteRewardUrbanAbilityInfo, "RewardUrbanAbilityInfo", false), nil, "UrbanAbilityInfo", false, 0, nil)
	Base.WriteList(writer, val.UrbanAbilities, writer.WriteInt32, 0, "UrbanAbilities", false, 0, nil)
	Base.WriteDict(writer, val.AbilityExpInfo, writer.WriteUInt32, writer.WriteUInt32, 0, "AbilityExpInfo", false, 0)
	Base.WriteDict(writer, val.FanInfo, writer.WriteUInt32, writer.WriteInt32, 0, "FanInfo", false, 0)
	Base.WriteDict(writer, val.FactionDispositionInfo, writer.WriteUInt32, writer.WriteInt32, 0, "FactionDispositionInfo", false, 0)
	Base.WriteDict(writer, val.FactionInfluenceInfo, writer.WriteUInt32, writer.WriteInt32, 0, "FactionInfluenceInfo", false, 0)
	Base.WriteDict(writer, val.JobExpInfo, writer.WriteUInt32, writer.WriteUInt32, 0, "JobExpInfo", false, 0)
	Base.WriteDict(writer, val.NpcFavors, writer.WriteUInt32, writer.WriteUInt32, 0, "NpcFavors", true, 0)
	Base.WriteDict(writer, val.OriginalNpcFavors, writer.WriteUInt32, writer.WriteUInt32, 0, "OriginalNpcFavors", true, 0)
	Base.WritePrimitive(writer, val.Popularity, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.EyeCoinRewardCount, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.CommonSpiritTalentExp, writer.WriteUInt32, 0)
	Base.WriteComplex(writer, val.SpiritTalentExpInfo, Auto.WriteSpiritTalentExpInfo, "SpiritTalentExpInfo", true)
	Base.WriteList(writer, val.WeaponList, writer.WriteUInt32, 0, "WeaponList", true, 0, nil)
	Base.WriteList(writer, val.RumorIds, writer.WriteUInt32, 0, "RumorIds", true, 0, nil)
	Base.WriteDict(writer, val.BattlePassExpInfo, writer.WriteUInt32, writer.WriteUInt32, 0, "BattlePassExpInfo", false, 0)
	Base.WriteDict(writer, val.ExtractionShooterInfo, writer.WriteUInt32, writer.WriteUInt32, 0, "ExtractionShooterInfo", false, 0)
	Base.WriteDict(writer, val.SeasonProgressInfo, writer.WriteUInt32, writer.WriteUInt32, 0, "SeasonProgressInfo", false, 0)
	Base.WriteList(writer, val.FishingFishRewards, Base.WriteComplexWrap(Auto.WriteFishingFishRewardInfo, "FishingFishRewardInfo", false), nil, "FishingFishRewards", false, 0, nil)
	Base.WriteList(writer, val.FishingGearRewards, writer.WriteUInt32, 0, "FishingGearRewards", false, 0, nil)
end

function Auto.WriteRewardExtraInfo(writer, val)
	Base.WritePrimitive(writer, val.RaidId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.TaskId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.EventId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.ChallengeId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.NpcCultivationId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.DropPct, writer.WriteSingle, 0)
	Base.WriteStruct(writer, val.Pos, Auto.WriteUXVector3, "Pos")
	Base.WriteList(writer, val.AchievementInfo, writer.WriteUInt32, 0, "AchievementInfo", false, 0, nil)
	Base.WriteList(writer, val.BadgeIdList, writer.WriteUInt32, 0, "BadgeIdList", false, 0, nil)
	Base.WriteComplex(writer, val.CollectionInfo, Auto.WriteRewardCollectionInfo, "CollectionInfo", false)
	Base.WriteDict(writer, val.FactionIdChange, writer.WriteUInt32, writer.WriteUInt32, 0, "FactionIdChange", true, 0)
	Base.WritePrimitive(writer, val.InspireHubGameplayId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, Base.CheckEnum(val.ForceItemBind, 212, 0), writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.FishConfigId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.FishWeight, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.FishLength, writer.WriteSingle, 0)
end

function Auto.WriteRewardInfo(writer, val)
	Base.WritePrimitive(writer, Base.CheckEnum(val.Reason, 22, 0), writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.RewardTemplate, writer.WriteUInt32, 0)
	Base.WriteList(writer, val.FirstItemInfo, writer.WriteUInt32, 0, "FirstItemInfo", false, 0, nil)
	Base.WriteComplex(writer, val.ExtraInfo, Auto.WriteRewardExtraInfo, "ExtraInfo", true)
	Base.WriteDict(writer, val.Reward, writer.WriteByte, Base.WriteComplexWrap(Auto.WriteRewardDetail, "RewardDetail", false), nil, "Reward", false, 0)
end

function Auto.WriteRewardSettleData(writer, val)
	Base.WriteComplex(writer, val.rewardInfo, Auto.WriteRewardInfo, "rewardInfo", true)
	Base.WriteComplex(writer, val.keyRewardInfo, Auto.WriteRewardInfo, "keyRewardInfo", true)
	Base.WriteComplex(writer, val.floatingRewardInfo, Auto.WriteRewardInfo, "floatingRewardInfo", true)
end

function Auto.WriteRewardUrbanAbilityInfo(writer, val)
	Base.WritePrimitive(writer, val.SpiritTemplateId, writer.WriteUInt32, 0)
	Base.WriteList(writer, val.OriginalUrbanAbilities, writer.WriteInt32, 0, "OriginalUrbanAbilities", false, 0, nil)
	Base.WriteList(writer, val.UrbanAbilities, writer.WriteInt32, 0, "UrbanAbilities", false, 0, nil)
end

function Auto.WriteRingTossParticipantInfo(writer, val)
	Base.WritePrimitive(writer, val.Pid, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.NpcCultivationId, writer.WriteUInt32, 0)
	Base.WriteComplex(writer, val.AIAgentInfo, Auto.WriteLinkAIAgentInfo, "AIAgentInfo", true)
	Base.WritePrimitive(writer, val.AgentInstanceId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.VehicleInstanceId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.SeatIndex, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.IsReady, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.IsPlayAgain, writer.WriteBoolean, false)
end

function Auto.WriteRingTossThrowResult(writer, val)
	Base.WritePrimitive(writer, val.ThrowIndex, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.RewardDropId, writer.WriteUInt32, 0)
end

function Auto.WriteRingTossZoneInfo(writer, val)
	Base.WritePrimitive(writer, Base.CheckEnum(val.GameType, 213, 0), writer.WriteByte, 0)
	Base.WriteList7Bit(writer, val.ThrowResults, Base.WriteStructWrap(Auto.WriteRingTossThrowResult, "ThrowResults"), nil, "ThrowResults", false, 0, nil)
	writer:WriteString(val.ZoneSessionId, false, "RingTossZoneInfo.ZoneSessionId", 0)
	Base.WritePrimitive(writer, val.GadgetUId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.TaskId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, Base.CheckEnum(val.StartReason, 106, 0), writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.GameTypeRandom, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, Base.CheckEnum(val.SyncReason, 107, 0), writer.WriteByte, 0)
	Base.WritePrimitive(writer, Base.CheckEnum(val.ZoneType, 108, 0), writer.WriteByte, 0)
	Base.WritePrimitive(writer, Base.CheckEnum(val.ZoneState, 109, 0), writer.WriteByte, 0)
	Base.WriteList7Bit(writer, val.ParticipantInfos, Base.WriteComplexWrap(Auto.WriteGameGroundParticipantInfo, "GameGroundParticipantInfo", true), nil, "ParticipantInfos", true, 0, nil)
	Base.WriteStruct(writer, val.CountDownInfo, Auto.WriteGameGroundZoneCountDownInfo, "CountDownInfo")
end

function Auto.WriteRiverData(writer, val)
	Base.WriteList7Bit(writer, val.River, Base.WriteStructWrap(Auto.WriteRiverTile, "River"), nil, "River", false, 0, nil)
end

function Auto.WriteRiverTile(writer, val)
	Base.WriteStruct(writer, val.Tile, Auto.WriteTile, "Tile")
	Base.WritePrimitive(writer, val.IsRichi, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.IsGone, writer.WriteBoolean, false)
end

function Auto.WriteRongInfo(writer, val)
	Base.WriteList7Bit(writer, val.RongPlayerIndices, writer.WriteInt32, 0, "RongPlayerIndices", false, 0, nil)
	Base.WriteList7Bit(writer, val.RongPlayerNames, Base.WriteStringWrap(false, "RongPlayerNames", 0), nil, "RongPlayerNames", false, 0, nil)
	Base.WriteList7Bit(writer, val.HandData, Base.WriteStructWrap(Auto.WritePlayerHandData, "HandData"), nil, "HandData", false, 0, nil)
	Base.WriteList7Bit(writer, val.AllHandData, Base.WriteStructWrap(Auto.WritePlayerHandData, "AllHandData"), nil, "AllHandData", false, 0, nil)
	Base.WriteStruct(writer, val.WinningTile, Auto.WriteTile, "WinningTile")
	Base.WriteList7Bit(writer, val.DoraIndicators, Base.WriteStructWrap(Auto.WriteTile, "DoraIndicators"), nil, "DoraIndicators", false, 0, nil)
	Base.WriteList7Bit(writer, val.UraDoraIndicators, Base.WriteStructWrap(Auto.WriteTile, "UraDoraIndicators"), nil, "UraDoraIndicators", false, 0, nil)
	Base.WriteList7Bit(writer, val.RongPlayerRichiStatus, writer.WriteBoolean, false, "RongPlayerRichiStatus", false, 0, nil)
	Base.WriteList7Bit(writer, val.RongPointInfos, Base.WriteStructWrap(Auto.WriteNetworkPointInfo, "RongPointInfos"), nil, "RongPointInfos", false, 0, nil)
	Base.WriteList7Bit(writer, val.TotalPoints, writer.WriteInt32, 0, "TotalPoints", false, 0, nil)
end

function Auto.WriteRoundDrawInfo(writer, val)
	Base.WritePrimitive(writer, Base.CheckEnum(val.RoundDrawType, 193, 0), writer.WriteByte, 0)
	Base.WriteList7Bit(writer, val.WaitingData, Base.WriteStructWrap(Auto.WriteWaitingData, "WaitingData"), nil, "WaitingData", false, 0, nil)
	Base.WriteList7Bit(writer, val.AllHandData, Base.WriteStructWrap(Auto.WritePlayerHandData, "AllHandData"), nil, "AllHandData", false, 0, nil)
end

function Auto.WriteRoundStartInfo(writer, val)
	Base.WritePrimitive(writer, val.PlayerIndex, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, Base.CheckEnum(val.Field, 214, 0), writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.Dice, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.Extra, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.RichiSticks, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.OyaPlayerIndex, writer.WriteInt32, 0)
	Base.WriteList7Bit(writer, val.Points, writer.WriteInt32, 0, "Points", false, 0, nil)
	Base.WriteList7Bit(writer, val.InitialHandTiles, Base.WriteStructWrap(Auto.WriteTile, "InitialHandTiles"), nil, "InitialHandTiles", false, 0, nil)
	Base.WriteList7Bit(writer, val.AllHandData, Base.WriteStructWrap(Auto.WritePlayerHandData, "AllHandData"), nil, "AllHandData", false, 0, nil)
	Base.WriteStruct(writer, val.MahjongSetData, Auto.WriteMahjongSetData, "MahjongSetData")
end

function Auto.WriteS001CommitCrimePayload(writer, val)
	Base.WritePrimitive(writer, val.CrimeId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.VictimId, writer.WriteUInt64, 0)
	writer:WriteString(val.Source, true, "S001CommitCrimePayload.Source", RpcLengthLimits.S001CommitCrimePayload_Source)
end

function Auto.WriteS002ArrestVehicleRequestPayload(writer, val)
	Base.WritePrimitive(writer, val.Id, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.VehicleId, writer.WriteUInt64, 0)
end

function Auto.WriteS002EnterExamRequestPayload(writer, val)
	Base.WritePrimitive(writer, val.Id, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.StartInteract, writer.WriteBoolean, false)
end

function Auto.WriteS002EscortFromRequestPayload(writer, val)
	Base.WritePrimitive(writer, val.Id, writer.WriteUInt64, 0)
end

function Auto.WriteS002EscortRequestPayload(writer, val)
	Base.WritePrimitive(writer, val.Id, writer.WriteUInt64, 0)
end

function Auto.WriteS002ExamVehicleNpcRequestPayload(writer, val)
	Base.WritePrimitive(writer, val.Id, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.VehicleId, writer.WriteUInt64, 0)
end

function Auto.WriteS002ExamVehicleRequestPayload(writer, val)
	Base.WritePrimitive(writer, val.VehicleId, writer.WriteUInt64, 0)
end

function Auto.WriteS002InteractParamsPayload(writer, val)
end

function Auto.WriteS002InteractRequestPayload(writer, val)
	Base.WritePrimitive(writer, val.InteractionId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.SectionId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.IsStandUp, writer.WriteBoolean, false)
	Base.WriteComplex(writer, val.Params, Auto.WriteS002InteractParamsPayload, "Params", true)
end

function Auto.WriteS002IssueTicketParamsPayload(writer, val)
	Base.WriteList7Bit(writer, val.FineList, writer.WriteInt32, 0, "FineList", true, RpcLengthLimits.S002IssueTicketParamsPayload_FineList, nil)
end

function Auto.WriteS002ReactionResponsePayload(writer, val)
	Base.WritePrimitive(writer, val.SectionId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.ReactionId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.EscortToWardIndex, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.EscortToHearCaseId, writer.WriteUInt64, 0)
end

function Auto.WriteS002VehicleFineClosePayload(writer, val)
	Base.WriteList7Bit(writer, val.FineList, writer.WriteUInt32, 0, "FineList", true, RpcLengthLimits.S002VehicleFineClosePayload_FineList, nil)
end

function Auto.WriteS002VehicleFineDropPayload(writer, val)
end

function Auto.WriteS002VehicleFineEndPayload(writer, val)
end

function Auto.WriteS002VehicleFineNonePayload(writer, val)
end

function Auto.WriteS002VehicleFineOpenPayload(writer, val)
	Base.WriteList7Bit(writer, val.FineIds, writer.WriteUInt32, 0, "FineIds", true, RpcLengthLimits.S002VehicleFineOpenPayload_FineIds, nil)
	Base.WriteList7Bit(writer, val.FineFlags, writer.WriteBoolean, false, "FineFlags", true, RpcLengthLimits.S002VehicleFineOpenPayload_FineFlags, nil)
end

function Auto.WriteS002VehicleFineResultPayload(writer, val)
	Base.WritePrimitive(writer, val.Success, writer.WriteBoolean, false)
end

function Auto.WriteS002VehicleNpcReactionPayload(writer, val)
	Base.WritePrimitive(writer, val.ReactionId, writer.WriteUInt32, 0)
end

function Auto.WriteS011EnterVehicleRequestPayload(writer, val)
	Base.WritePrimitive(writer, val.VehicleId, writer.WriteUInt64, 0)
	Base.WriteList7Bit(writer, val.SeatIndices, writer.WriteByte, 0, "SeatIndices", true, RpcLengthLimits.S011EnterVehicleRequestPayload_SeatIndices, nil)
end

function Auto.WriteS011VehicleAndSeatPayload(writer, val)
	Base.WritePrimitive(writer, val.VehicleId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.SeatIndex, writer.WriteByte, 0)
end

function Auto.WriteS021AnimalInteractRequestPayload(writer, val)
	Base.WritePrimitive(writer, val.Pid, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.SpoonId, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.SubType, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.InteractType, writer.WriteUInt32, 0)
end

function Auto.WriteS021InteractRequestPayload(writer, val)
	Base.WritePrimitive(writer, val.InteractId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.IsStop, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.Favor, writer.WriteInt32, 0)
end

function Auto.WriteS021ReactionResponsePayload(writer, val)
end

function Auto.WriteSceneCreationInfo(writer, val)
	Base.WritePrimitive(writer, val.Id, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.ParentId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.TargetId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.DestructibleId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.CreationId, writer.WriteUInt32, 0)
	Base.WriteStruct(writer, val.ParentPosition, Auto.WriteUXVector3, "ParentPosition")
	Base.WritePrimitive(writer, val.Rotate, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.ClientEnterOrLeave, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.SourceSkillId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.SourceDestructibleId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.GadgetId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.GadgetTransformId, writer.WriteInt32, 0)
end

function Auto.WriteSceneDeviceCheckIndexCallback(writer, val)
	Base.WritePrimitive(writer, val.CheckIndex, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.Error, writer.WriteUInt32, 0)
end

function Auto.WriteSceneDeviceHangingInfo(writer, val)
	Base.WritePrimitive(writer, val.HangingType, writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.TargetId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.Index, writer.WriteInt32, 0)
end

function Auto.WriteSceneDeviceOccupantInfo(writer, val)
	Base.WritePrimitive(writer, val.Pid, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.FightSpiritId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.AttractNpcPid, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.Index, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.IsState, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, Base.CheckEnum(val.SourceType, 215, 0), writer.WriteByte, 0)
end

function Auto.WriteSceneDevicePersonalValueInfo(writer, val)
	Base.WriteDict(writer, val.PersonalValueDic, writer.WriteInt32, Base.WriteStringWrap(false, "PersonalValueDic", 0), nil, "PersonalValueDic", false, 0)
end

function Auto.WriteSceneDeviceStateChangeInfo(writer, val)
	Base.WritePrimitive(writer, val.Id, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.StateType, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.State, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.StateCheckIndex, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.ToTask, writer.WriteBoolean, false)
end

function Auto.WriteSceneDeviceValueChangeInfo(writer, val)
	Base.WritePrimitive(writer, val.Id, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.ValueName, writer.WriteInt32, 0)
	writer:WriteString(val.Value, false, "SceneDeviceValueChangeInfo.Value", RpcLengthLimits.SceneDeviceValueChangeInfo_Value)
	Base.WritePrimitive(writer, val.ValueCheckIndex, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.ToTask, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.SetOnceOnly, writer.WriteBoolean, false)
end

function Auto.WriteSceneFogMap(writer, val)
	Base.WriteList(writer, val.FogValue, writer.WriteByte, 0, "FogValue", true, 0, nil)
	Base.WritePrimitive(writer, val.All, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.LockCnt, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.XSize, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.ZSize, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.TileSize, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.XMin, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.ZMin, writer.WriteInt32, 0)
end

function Auto.WriteSceneItemDropActionInfo(writer, val)
	Base.WritePrimitive(writer, val.hosterInstanceId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.sceneItemInstanceId, writer.WriteUInt64, 0)
	Base.WriteStruct(writer, val.hosterPosition, Auto.WriteUXVector3, "hosterPosition")
	Base.WritePrimitive(writer, val.isDestroyImmediately, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.yForce, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.zForce, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.gravity, writer.WriteSingle, 0)
end

function Auto.WriteSceneRoomChangeData(writer, val)
	Base.WritePrimitive(writer, val.Id, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.Enable, writer.WriteBoolean, false)
end

function Auto.WriteScratchParticipantInfo(writer, val)
	Base.WritePrimitive(writer, val.Pid, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.NpcCultivationId, writer.WriteUInt32, 0)
	Base.WriteComplex(writer, val.AIAgentInfo, Auto.WriteLinkAIAgentInfo, "AIAgentInfo", true)
	Base.WritePrimitive(writer, val.AgentInstanceId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.VehicleInstanceId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.SeatIndex, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.IsReady, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.IsPlayAgain, writer.WriteBoolean, false)
end

function Auto.WriteSeatInfo(writer, val)
	Base.WritePrimitive(writer, val.Score, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.HoldsCount, writer.WriteInt32, 0)
	Base.WriteList7Bit(writer, val.Holds, Base.WriteStructWrap(Auto.WriteMjPaiInfo, "Holds"), nil, "Holds", true, 0, nil)
	Base.WriteList7Bit(writer, val.Folds, Base.WriteStructWrap(Auto.WriteMjPaiInfo, "Folds"), nil, "Folds", false, 0, nil)
	Base.WriteList7Bit(writer, val.Sequence, Base.WriteComplexWrap(Auto.WriteMjPCGActionInfo, "MjPCGActionInfo", false), nil, "Sequence", false, 0, nil)
	Base.WritePrimitive(writer, val.ReachFoldCnt, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, Base.CheckEnum(val.Que, 28, 0), writer.WriteByte, 0)
	Base.WriteList7Bit(writer, val.HuanPais, Base.WriteStructWrap(Auto.WriteMjPaiInfo, "HuanPais"), nil, "HuanPais", true, 0, nil)
	Base.WriteList7Bit(writer, val.HuPais, Base.WriteStructWrap(Auto.WriteMjPaiInfo, "HuPais"), nil, "HuPais", false, 0, nil)
end

function Auto.WriteSeatInteractCommandData(writer, val)
	Base.WritePrimitive(writer, Base.CheckEnum(val.Op, 216, 0), writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.InstanceId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.SitIndex, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, Base.CheckEnum(val.DataSource, 97, 0), writer.WriteInt16, 0)
end

function Auto.WriteSelectedAnimationCommandData(writer, val)
	Base.WriteStruct(writer, val.Target, Auto.WriteClientActionTarget, "Target")
	Base.WriteList7Bit(writer, val.AnimationIds, writer.WriteUInt32, 0, "AnimationIds", false, 0, nil)
	Base.WritePrimitive(writer, Base.CheckEnum(val.BaseObject, 217, 0), writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.BaseVehicle, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.TargetType, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.Reverse, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.SelectAngleType, writer.WriteInt32, 0)
	Base.WriteList7Bit(writer, val.AngleRange, writer.WriteSingle, 0, "AngleRange", false, 0, nil)
	Base.WritePrimitive(writer, Base.CheckEnum(val.DataSource, 97, 0), writer.WriteInt16, 0)
end

function Auto.WriteSerializeMinMaxAABB(writer, val)
	Base.WriteStruct(writer, val.Min, Auto.WriteFloat3, "Min")
	Base.WriteStruct(writer, val.Max, Auto.WriteFloat3, "Max")
end

function Auto.WriteSerializeQuaternion(writer, val)
	Base.WritePrimitive(writer, val.x, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.y, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.z, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.w, writer.WriteSingle, 0)
end

function Auto.WriteServerEffectData(writer, val)
	Base.WritePrimitive(writer, val.EffectId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.InstanceId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.LogicEndTime, writer.WriteDouble, 0)
	Base.WritePrimitive(writer, val.ReleaserId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.ClientDestructibleId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.Duration, writer.WriteSingle, 0)
end

function Auto.WriteServerSimpleGridInfo(writer, val)
	Base.WritePrimitive(writer, val.MinX, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.MinZ, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.MaxX, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.MaxZ, writer.WriteInt32, 0)
end

function Auto.WriteSetEmotionData(writer, val)
	Base.WritePrimitive(writer, val.AgentId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.Emotion, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.State, writer.WriteUInt32, 0)
end

function Auto.WriteSetMessageCommand(writer, val)
	Base.WritePrimitive(writer, val.Nid, writer.WriteUInt32, 0)
	writer:WriteString(val.Name, false, "SetMessageCommand.Name", RpcLengthLimits.SetMessageCommand_Name)
	Base.WriteComplex(writer, val.Value, Auto.WriteStoryNetPayload, "Value", false)
	Base.WritePrimitive(writer, val.RpcId, writer.WriteInt64, 0)
	Base.WritePrimitive(writer, val.HasRpcId, writer.WriteBoolean, false)
end

function Auto.WriteSetMessageServerCommand(writer, val)
	Base.WritePrimitive(writer, val.Nid, writer.WriteUInt32, 0)
	writer:WriteString(val.Name, false, "SetMessageServerCommand.Name", 0)
	Base.WriteComplex(writer, val.Value, Auto.WriteStoryNetPayload, "Value", false)
	Base.WritePrimitive(writer, val.RpcId, writer.WriteInt64, 0)
	Base.WritePrimitive(writer, val.HasRpcId, writer.WriteBoolean, false)
end

function Auto.WriteSetObservableCommand(writer, val)
	Base.WritePrimitive(writer, val.Nid, writer.WriteUInt32, 0)
	writer:WriteString(val.Name, false, "SetObservableCommand.Name", RpcLengthLimits.SetObservableCommand_Name)
	Base.WriteComplex(writer, val.Value, Auto.WriteStoryNetPayload, "Value", false)
	Base.WritePrimitive(writer, val.RpcId, writer.WriteInt64, 0)
	Base.WritePrimitive(writer, val.HasRpcId, writer.WriteBoolean, false)
end

function Auto.WriteSetObservableServerCommand(writer, val)
	Base.WritePrimitive(writer, val.Nid, writer.WriteUInt32, 0)
	writer:WriteString(val.Name, false, "SetObservableServerCommand.Name", 0)
	Base.WriteComplex(writer, val.Value, Auto.WriteStoryNetPayload, "Value", false)
	Base.WritePrimitive(writer, val.RpcId, writer.WriteInt64, 0)
	Base.WritePrimitive(writer, val.HasRpcId, writer.WriteBoolean, false)
end

function Auto.WriteSevenDaysActivityCommonInfo(writer, val)
	Base.WriteList7Bit(writer, val.ProgressList, writer.WriteUInt32, 0, "ProgressList", false, 0, nil)
	Base.WriteList7Bit(writer, val.TabList, Base.WriteComplexWrap(Auto.WriteSevenDaysTabInfo, "SevenDaysTabInfo", false), nil, "TabList", false, 0, nil)
	Base.WritePrimitive(writer, val.CfgId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.StartTime, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.EndTime, writer.WriteUInt32, 0)
end

function Auto.WriteSevenDaysActivityData(writer, val)
	Base.WriteList(writer, val.ProgressAwardGotList, writer.WriteUInt32, 0, "ProgressAwardGotList", false, 0, nil)
	Base.WriteList(writer, val.TaskInfoList, Base.WriteComplexWrap(Auto.WriteSevenDaysTaskInfo, "SevenDaysTaskInfo", false), nil, "TaskInfoList", false, 0, nil)
	Base.WritePrimitive(writer, val.CfgId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.ShowRedPoint, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.IsOutOfDate, writer.WriteBoolean, false)
end

function Auto.WriteSevenDaysTabInfo(writer, val)
	Base.WritePrimitive(writer, val.TabCfgId, writer.WriteUInt32, 0)
	Base.WriteList7Bit(writer, val.TaskList, writer.WriteUInt32, 0, "TaskList", false, 0, nil)
end

function Auto.WriteSevenDaysTaskInfo(writer, val)
	Base.WritePrimitive(writer, val.Id, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.IsAwardGot, writer.WriteBoolean, false)
end

function Auto.WriteShelterMoveFinishInfo(writer, val)
	Base.WritePrimitive(writer, val.Uid, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.IsFailure, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, Base.CheckEnum(val.Type, 218, 0), writer.WriteByte, 0)
end

function Auto.WriteShelterPosInfo(writer, val)
	Base.WritePrimitive(writer, val.Uid, writer.WriteUInt64, 0)
	Base.WriteStruct(writer, val.Position, Auto.WriteUXVector3, "Position")
	Base.WritePrimitive(writer, Base.CheckEnum(val.Type, 218, 0), writer.WriteByte, 0)
end

function Auto.WriteShopBudgetSetTrack(writer, val)
	Base.WritePrimitive(writer, val.LastAddTime, writer.WriteUInt32, 0)
end

function Auto.WriteShopPurchaseBudget(writer, val)
	Base.WritePrimitive(writer, val.Amount, writer.WriteUInt32, 0)
	Base.WriteDict(writer, val.SetTracks, writer.WriteUInt32, Base.WriteComplexWrap(Auto.WriteShopBudgetSetTrack, "ShopBudgetSetTrack", false), nil, "SetTracks", false, 0)
end

function Auto.WriteShopPurchaseBudgets(writer, val)
	Base.WriteDict(writer, val.Budgets, writer.WriteUInt32, Base.WriteComplexWrap(Auto.WriteShopPurchaseBudget, "ShopPurchaseBudget", false), nil, "Budgets", false, 0)
	Base.WriteDict(writer, val.ReceivedControlIds, writer.WriteUInt32, writer.WriteBoolean, false, "ReceivedControlIds", false, 0)
end

function Auto.WriteShortChat(writer, val)
	Base.WritePrimitive(writer, val.Pid, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.Id, writer.WriteUInt32, 0)
	Base.WriteComplex(writer, val.mark, Auto.WriteShortChatMark, "mark", true)
end

function Auto.WriteShortChatMark(writer, val)
	Base.WritePrimitive(writer, Base.CheckEnum(val.Type, 219, 0), writer.WriteByte, 0)
	Base.WriteStruct(writer, val.Position, Auto.WriteUXVector3, "Position")
end

function Auto.WriteShortPayload(writer, val)
	Base.WritePrimitive(writer, val.V, writer.WriteInt16, 0)
end

function Auto.WriteShowConversationCommandData(writer, val)
	Base.WritePrimitive(writer, val.DialogueId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.LookTarget, writer.WriteBoolean, false)
	Base.WriteList7Bit(writer, val.DialogueSpeakers, Base.WriteStringWrap(false, "DialogueSpeakers", 0), nil, "DialogueSpeakers", false, 0, nil)
	Base.WriteList7Bit(writer, val.DialogueBindUnits, writer.WriteUInt64, 0, "DialogueBindUnits", false, 0, nil)
	Base.WritePrimitive(writer, val.IsRestart, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.ResumeDelay, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.IsGeneralDialog, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.ClearPreDialogueTasks, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.YawAngleLimit, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.PitchAngleLimit, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, Base.CheckEnum(val.DataSource, 97, 0), writer.WriteInt16, 0)
end

function Auto.WriteShowUIEffectNotifyParam(writer, val)
	Base.WritePrimitive(writer, val.OperatorType, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.TargetId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.TemplateId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.ShowTime, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.uParam1, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.ulParam1, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.bParam1, writer.WriteBoolean, false)
end

function Auto.WriteSimpleGameSetting(writer, val)
end

function Auto.WriteSimpleMailAttchment(writer, val)
	Base.WritePrimitive(writer, val.ItemId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.UnbindMoney, writer.WriteDouble, 0)
	Base.WritePrimitive(writer, val.BindGold, writer.WriteDouble, 0)
	Base.WritePrimitive(writer, val.PayGold, writer.WriteDouble, 0)
	Base.WritePrimitive(writer, val.FreeGold, writer.WriteDouble, 0)
	Base.WritePrimitive(writer, val.Exp, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.WeaponId, writer.WriteUInt32, 0)
end

function Auto.WriteSimpleMoveActionData(writer, val)
	Base.WritePrimitive(writer, val.UnitId, writer.WriteUInt64, 0)
	Base.WriteStruct(writer, val.Pos, Auto.WriteUXVector3, "Pos")
	Base.WriteStruct(writer, val.Rot, Auto.WriteUXVector3, "Rot")
	Base.WritePrimitive(writer, val.MoveId, writer.WriteByte, 0)
end

function Auto.WriteSimpleMoveActionDataWithGround(writer, val)
	Base.WritePrimitive(writer, val.UnitId, writer.WriteUInt64, 0)
	Base.WriteStruct(writer, val.Pos, Auto.WriteUXVector3, "Pos")
	Base.WriteStruct(writer, val.Rot, Auto.WriteUXVector3, "Rot")
	Base.WritePrimitive(writer, val.MoveId, writer.WriteByte, 0)
	Base.WriteComplex(writer, val.GroundData, Auto.WriteMoveActionGroundData, "GroundData", false)
end

function Auto.WriteSimpleUnreadMessage(writer, val)
	Base.WritePrimitive(writer, val.PostId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.CommentId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.MessageType, writer.WriteInt32, 0)
end

function Auto.WriteSinglePoliceFakeFileInfo(writer, val)
	Base.WritePrimitive(writer, val.State, writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.InterrogationTime, writer.WriteUInt32, 0)
end

function Auto.WriteSkillCreationData(writer, val)
	Base.WritePrimitive(writer, val.Id, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.ReleaserId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.TriggerIndex, writer.WriteInt32, 0)
	Base.WriteStruct(writer, val.Position, Auto.WriteUXVector3, "Position")
	Base.WritePrimitive(writer, val.Facing, writer.WriteSingle, 0)
end

function Auto.WriteSkillDestructibleData(writer, val)
	Base.WritePrimitive(writer, val.Id, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.TemplateId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.PathId, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.SceneItemCfgId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.ReleaserId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.TriggerIndex, writer.WriteInt32, 0)
	Base.WriteStruct(writer, val.Position, Auto.WriteUXVector3, "Position")
	Base.WriteStruct(writer, val.Facing, Auto.WriteUXVector3, "Facing")
end

function Auto.WriteSkillDestructibleInfo(writer, val)
	Base.WritePrimitive(writer, val.CreateSkillInstanceId, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.CreateIndex, writer.WriteInt32, 0)
end

function Auto.WriteSkillExecuteData(writer, val)
	Base.WritePrimitive(writer, val.SkillId, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.ReleaserId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.TriggerIndex, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.ParentTriggerIndex, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.TargetId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.StiffId, writer.WriteUInt32, 0)
end

function Auto.WriteSkillHitData(writer, val)
	Base.WritePrimitive(writer, val.ReleaserId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.Id, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.SkillId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.TriggerIndex, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.TriggerInstanceId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.Stage, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.HitTarget, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.AttachedDestructibleId, writer.WriteUInt64, 0)
	Base.WriteStruct(writer, val.ClientHitPosition, Auto.WriteUXVector3, "ClientHitPosition")
	Base.WriteStruct(writer, val.ClientHitPosNormalDir, Auto.WriteUXVector3, "ClientHitPosNormalDir")
	Base.WritePrimitive(writer, Base.CheckEnum(val.SkillHitType, 220, 0), writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.HitMaterial, writer.WriteInt32, 0)
	Base.WriteStruct(writer, val.HitCenter, Auto.WriteUXVector3, "HitCenter")
	Base.WritePrimitive(writer, val.StiffId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.StiffTime, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.HurtEffectId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.FirmHurt, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.ShieldDefendIndex, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.ShieldId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.IsBackHit, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.IsReflected, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.HitDistance, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.IsBehindBarrier, writer.WriteBoolean, false)
end

function Auto.WriteSkillParam(writer, val)
	Base.WritePrimitive(writer, val.entityId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.targetId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.moveId, writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.instanceId, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.select, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.targetDestructibleId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.skillId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.unitPartIndex, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.rotate, writer.WriteSingle, 0)
	Base.WriteStruct(writer, val.unitPosition, Auto.WriteUXVector3, "unitPosition")
	Base.WriteStruct(writer, val.location, Auto.WriteUXVector3, "location")
	Base.WriteStruct(writer, val.faceToPos, Auto.WriteUXVector3, "faceToPos")
	Base.WritePrimitive(writer, val.destructibleTemplateId, writer.WriteUInt32, 0)
	Base.WriteList7Bit(writer, val.DesignerPosList, Base.WriteStructWrap(Auto.WriteUXVector3, "DesignerPosList"), nil, "DesignerPosList", true, 0, nil)
	Base.WritePrimitive(writer, val.SectionRepeatTimes, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.SeqConfigID, writer.WriteUInt32, 0)
	Base.WriteStruct(writer, val.SelfMobilityPos, Auto.WriteUXVector3, "SelfMobilityPos")
	Base.WriteStruct(writer, val.TarMobilityPos, Auto.WriteUXVector3, "TarMobilityPos")
	Base.WritePrimitive(writer, val.NotInterruptMove, writer.WriteBoolean, false)
end

function Auto.WriteSkillShieldData(writer, val)
	Base.WritePrimitive(writer, val.SkillInstanceId, writer.WriteInt32, 0)
end

function Auto.WriteSkillStateData(writer, val)
	Base.WritePrimitive(writer, val.SkillInstanceId, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.ReleaserId, writer.WriteUInt64, 0)
	Base.WriteList7Bit(writer, val.StateIds, writer.WriteUInt32, 0, "StateIds", false, RpcLengthLimits.SkillStateData_StateIds, nil)
end

function Auto.WriteSkillSummonData(writer, val)
	Base.WritePrimitive(writer, val.SkillInstanceId, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.ReleaserId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.TriggerIndex, writer.WriteInt32, 0)
	Base.WriteStruct(writer, val.Position, Auto.WriteUXVector3, "Position")
	Base.WritePrimitive(writer, val.Facing, writer.WriteSingle, 0)
end

function Auto.WriteSkillTimeCurveData(writer, val)
	Base.WritePrimitive(writer, val.Id, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.ReleaserId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.TriggerIndex, writer.WriteInt32, 0)
end

function Auto.WriteSkillUseData(writer, val)
	Base.WritePrimitive(writer, val.Releaser, writer.WriteUInt64, 0)
	Base.WriteStruct(writer, val.Location, Auto.WriteUXVector3, "Location")
	Base.WritePrimitive(writer, val.Facing, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.TargetId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.UnitPartIndex, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.TargetDestructibleId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.AttachDestructibleId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.SkillId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.SkillInstanceId, writer.WriteInt32, 0)
end

function Auto.WriteSoundEffectConfig(writer, val)
	Base.WritePrimitive(writer, val.tempo, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.pitch, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.power, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.richness, writer.WriteSingle, 0)
	writer:WriteString(val.template, true, "SoundEffectConfig.template", RpcLengthLimits.SoundEffectConfig_template)
end

function Auto.WriteSpawnAreaSelector(writer, val)
	Base.WriteComplex(writer, val.SpawnArea, Auto.WriteMassTrafficSpawnArea, "SpawnArea", false)
	Base.WritePrimitive(writer, val.Selected, writer.WriteBoolean, false)
end

function Auto.WriteSpawnLaneSelector(writer, val)
	Base.WritePrimitive(writer, Base.CheckEnum(val.SpawnLaneType, 221, 0), writer.WriteByte, 0)
	Base.WriteStruct(writer, val.FirstArea, Auto.WriteAreaColliderParams, "FirstArea")
	Base.WriteStruct(writer, val.SecondArea, Auto.WriteAreaColliderParams, "SecondArea")
end

function Auto.WriteSpinOutParameters(writer, val)
	Base.WritePrimitive(writer, val.TargetUid, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.Token, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.taskAIConfigId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.defaultSpeed, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.drivingFlags, writer.WriteInt32, 1)
	Base.WritePrimitive(writer, val.initSpeed, writer.WriteSingle, 0)
	Base.WriteList7Bit(writer, val.initTaskAIBuffList, Base.WriteStructWrap(Auto.WriteTaskVehicleBuffInitInfo, "initTaskAIBuffList"), nil, "initTaskAIBuffList", true, 0, nil)
	Base.WriteStruct(writer, val.commonParameters, Auto.WriteVehicleAICommonParameters, "commonParameters")
end

function Auto.WriteSpiritAbilityInfo(writer, val)
	Base.WritePrimitive(writer, val.TemplateId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.Exp, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.NewLevel, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.ConfirmedLevel, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.Level, writer.WriteUInt32, 0)
end

function Auto.WriteSpiritAddWeaponAction(writer, val)
	Base.WritePrimitive(writer, val.SpiritTid, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.SpiritUid, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.SlotIndex, writer.WriteInt32, 0)
	Base.WriteComplex(writer, val.Weapon, Auto.WriteWeaponDetail, "Weapon", false)
end

function Auto.WriteSpiritBartenderInfo(writer, val)
	Base.WriteDict(writer, val.BartenderId2ElementInfosDict, writer.WriteUInt32, Base.WriteComplexWrap(Auto.WriteBartenderElementInfos, "BartenderElementInfos", false), nil, "BartenderId2ElementInfosDict", false, 0)
	Base.WriteDict(writer, val.BartenderId2GameInfosDict, writer.WriteUInt32, Base.WriteComplexWrap(Auto.WriteBartenderGameInfos, "BartenderGameInfos", false), nil, "BartenderId2GameInfosDict", false, 0)
end

function Auto.WriteSpiritBattleData(writer, val)
	Base.WritePrimitive(writer, val.TemplateId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.Level, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.StoneLevel, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.TotalDamage, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.HighestDamage, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.TotalHeal, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.TotalDamaged, writer.WriteUInt32, 0)
end

function Auto.WriteSpiritBattleInfo(writer, val)
	Base.WritePrimitive(writer, val.IsUniqueSkillLocked, writer.WriteBoolean, false)
	Base.WriteDict(writer, val.ConsumableCounters, writer.WriteInt32, writer.WriteSingle, 0, "ConsumableCounters", false, 0)
end

function Auto.WriteSpiritDrawViewData(writer, val)
	Base.WriteComplex(writer, val.SpiritInfo, Auto.WriteSpiritInfo, "SpiritInfo", false)
end

function Auto.WriteSpiritFashionsInfo(writer, val)
	Base.WritePrimitive(writer, val.SpiritId, writer.WriteUInt32, 0)
	Base.WriteDict(writer, val.FashionCustomSuitSchemeInfos, writer.WriteByte, Base.WriteComplexWrap(Auto.WriteFashionCustomSuitSchemeInfo, "FashionCustomSuitSchemeInfo", false), nil, "FashionCustomSuitSchemeInfos", false, 0)
	Base.WriteDict(writer, val.FashionFunctionSuitSchemeInfoDict, writer.WriteUInt32, Base.WriteComplexWrap(Auto.WriteFashionFunctionSuitSchemeInfo, "FashionFunctionSuitSchemeInfo", false), nil, "FashionFunctionSuitSchemeInfoDict", false, 0)
	Base.WriteComplex(writer, val.SpiritWearFashionsInfo, Auto.WriteSpiritWearFashionsInfo, "SpiritWearFashionsInfo", false)
	Base.WriteComplex(writer, val.SpiritPrevWearFashionsInfo, Auto.WriteSpiritWearFashionsInfo, "SpiritPrevWearFashionsInfo", true)
	Base.WriteList(writer, val.FirstGainSuitIdList, writer.WriteUInt32, 0, "FirstGainSuitIdList", true, 0, nil)
	Base.WritePrimitive(writer, val.ActiveClientTryWearSource, writer.WriteInt16, 0)
	Base.WritePrimitive(writer, val.UnlockSuitSlotCount, writer.WriteByte, 0)
	Base.WriteDict(writer, val.MainFashionId2VariantFashionIdDict, writer.WriteUInt32, writer.WriteUInt32, 0, "MainFashionId2VariantFashionIdDict", false, 0)
end

function Auto.WriteSpiritFightStyleInfo(writer, val)
	Base.WriteDict(writer, val.FightStyleInfo, writer.WriteUInt32, writer.WriteUInt32, 0, "FightStyleInfo", false, 0)
end

function Auto.WriteSpiritFightTypeChangeAction(writer, val)
	Base.WritePrimitive(writer, val.spiritId, writer.WriteUInt32, 0)
	Base.WriteComplex(writer, val.fullInfo, Auto.WriteSpiritFightStyleInfo, "fullInfo", true)
	Base.WriteDict7Bit(writer, val.addOrUpdateInfo, writer.WriteUInt32, writer.WriteUInt32, 0, "addOrUpdateInfo", true, 0)
end

function Auto.WriteSpiritGroupChatInfo(writer, val)
	Base.WritePrimitive(writer, val.Id, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.CreateTime, writer.WriteUInt32, 0)
end

function Auto.WriteSpiritHackerJobInfo(writer, val)
	writer:WriteString(val.HackerName, true, "SpiritHackerJobInfo.HackerName", 0)
	Base.WriteDict(writer, val.PostInfos, writer.WriteUInt32, Base.WriteComplexWrap(Auto.WriteHackerPostInfo, "HackerPostInfo", false), nil, "PostInfos", false, 0)
	Base.WritePrimitive(writer, val.Rank, writer.WriteUInt32, 0)
	Base.WriteComplex(writer, val.DailyCounts, Auto.WriteDailyHackerCounts, "DailyCounts", false)
end

function Auto.WriteSpiritInfo(writer, val)
	Base.WritePrimitive(writer, val.Id, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.TemplateId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.PossessTime, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.HpRate, writer.WriteSingle, 0)
	Base.WriteComplex(writer, val.SpiritUrbanSkill, Auto.WriteSpiritUrbanSkill, "SpiritUrbanSkill", false)
	Base.WriteDict(writer, val.SpiritAbilities, writer.WriteUInt32, Base.WriteComplexWrap(Auto.WriteSpiritAbilityInfo, "SpiritAbilityInfo", false), nil, "SpiritAbilities", false, 0)
	Base.WriteComplex(writer, val.SpiritJobInfo, Auto.WriteSpiritJobInfo, "SpiritJobInfo", false)
	Base.WriteDict(writer, val.PermanentAddAttributes, writer.WriteUInt32, writer.WriteSingle, 0, "PermanentAddAttributes", false, 0)
	Base.WriteComplex(writer, val.InfoBadge, Auto.WritePlayerInfoBadge, "InfoBadge", false)
	Base.WriteComplex(writer, val.MobileSkinInfo, Auto.WriteSpiritMobileSkinInfo, "MobileSkinInfo", false)
	Base.WriteList(writer, val.WeaponSlots, Base.WriteComplexWrap(Auto.WriteWeaponData, "WeaponData", false), nil, "WeaponSlots", false, 0, nil)
	Base.WritePrimitive(writer, val.EverSwitched, writer.WriteBoolean, false)
	Base.WriteComplex(writer, val.SpiritBattleInfo, Auto.WriteSpiritBattleInfo, "SpiritBattleInfo", false)
	Base.WriteComplex(writer, val.TalentInfo, Auto.WriteSpiritTalentInfo, "TalentInfo", false)
	Base.WriteComplex(writer, val.SpiritFightStyle, Auto.WriteSpiritFightStyleInfo, "SpiritFightStyle", false)
	Base.WritePrimitive(writer, val.Blocked, writer.WriteBoolean, false)
	Base.WriteComplex(writer, val.SummonAgentWheelWeaponInfo, Auto.WriteSpiritSummonAgentWheelWeaponInfo, "SummonAgentWheelWeaponInfo", false)
	Base.WriteList(writer, val.BuffLibraryEntries, Base.WriteComplexWrap(Auto.WritePlayerBuffLibraryEntry, "PlayerBuffLibraryEntry", false), nil, "BuffLibraryEntries", false, 0, nil)
	Base.WritePrimitive(writer, val.LastUsedWeaponInstanceId, writer.WriteUInt64, 0)
end

function Auto.WriteSpiritInitData(writer, val)
	Base.WritePrimitive(writer, val.Id, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.TemplateId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.IsActive, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.WeaponTemplateId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.WeaponSkinId, writer.WriteUInt32, 0)
end

function Auto.WriteSpiritJob(writer, val)
	Base.WritePrimitive(writer, val.Job, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.Exp, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.Level, writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.RegisterTime, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.UnregisterTime, writer.WriteUInt32, 0)
	Base.WriteComplex(writer, val.TalentInfo, Auto.WriteSpiritJobTalentInfo, "TalentInfo", false)
end

function Auto.WriteSpiritJobInfo(writer, val)
	Base.WritePrimitive(writer, val.CurrentJob, writer.WriteUInt32, 0)
	Base.WriteDict(writer, val.AvailableJobs, writer.WriteUInt32, Base.WriteComplexWrap(Auto.WriteSpiritJob, "SpiritJob", false), nil, "AvailableJobs", false, 0)
	Base.WriteDict(writer, val.HistoryJobs, writer.WriteUInt32, Base.WriteComplexWrap(Auto.WriteSpiritJob, "SpiritJob", false), nil, "HistoryJobs", false, 0)
end

function Auto.WriteSpiritJobTalentInfo(writer, val)
	Base.WritePrimitive(writer, val.TalentPoint, writer.WriteUInt32, 0)
	Base.WriteDict(writer, val.UnlockTalentInfoDict, writer.WriteUInt32, Base.WriteComplexWrap(Auto.WriteSpiritOrJobTalentNodeInfo, "SpiritOrJobTalentNodeInfo", false), nil, "UnlockTalentInfoDict", false, 0)
	Base.WriteDict(writer, val.TalentTreeRecordDict, writer.WriteUInt32, Base.WriteComplexWrap(Auto.WriteTalentTreeRecord, "TalentTreeRecord", false), nil, "TalentTreeRecordDict", false, 0)
end

function Auto.WriteSpiritMobileSkinInfo(writer, val)
	Base.WritePrimitive(writer, val.Wallpaper, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.Decoration, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.Pendant, writer.WriteUInt32, 0)
end

function Auto.WriteSpiritOrJobTalentNodeInfo(writer, val)
	Base.WritePrimitive(writer, val.TalentId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.Layer, writer.WriteUInt32, 0)
end

function Auto.WriteSpiritPanelData(writer, val)
	Base.WritePrimitive(writer, val.FightSpiritId, writer.WriteUInt32, 0)
	Base.WriteDict7Bit(writer, val.UrbanAttrs, writer.WriteUInt32, writer.WriteSingle, 0, "UrbanAttrs", false, 0)
	Base.WritePrimitive(writer, val.MaxHp, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.Dam, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.DefDeduct, writer.WriteSingle, 0)
	Base.WriteDict7Bit(writer, val.Attrs, writer.WriteUInt32, writer.WriteSingle, 0, "Attrs", false, 0)
end

function Auto.WriteSpiritPoliceJobInfo(writer, val)
	Base.WriteDict(writer, val.DispatchInfos, writer.WriteUInt32, Base.WriteComplexWrap(Auto.WritePoliceDispatchInfo, "PoliceDispatchInfo", false), nil, "DispatchInfos", false, 0)
	Base.WriteList(writer, val.ViolationInfos, Base.WriteComplexWrap(Auto.WritePoliceViolationInfo, "PoliceViolationInfo", false), nil, "ViolationInfos", false, 0, nil)
	Base.WriteList(writer, val.CaseInfos, Base.WriteComplexWrap(Auto.WritePoliceCaseInfo, "PoliceCaseInfo", false), nil, "CaseInfos", false, 0, nil)
	Base.WriteComplex(writer, val.DutyBasicInfo, Auto.WritePoliceDutyBasicInfo, "DutyBasicInfo", false)
	Base.WriteList(writer, val.EscortedNpcs, writer.WriteUInt64, 0, "EscortedNpcs", false, 0, nil)
	Base.WriteComplex(writer, val.PoliceFakeFileInfo, Auto.WritePoliceFakeFileInfo, "PoliceFakeFileInfo", true)
	Base.WriteDict(writer, val.PeriodInvalidVehicleFine2CountDict, writer.WriteUInt32, writer.WriteUInt32, 0, "PeriodInvalidVehicleFine2CountDict", false, 0)
	Base.WritePrimitive(writer, val.NextPeriodUpdateTime, writer.WriteUInt32, 0)
end

function Auto.WriteSpiritRemoveWeaponAction(writer, val)
	Base.WritePrimitive(writer, val.SpiritTid, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.SpiritUid, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.WeaponUid, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, Base.CheckEnum(val.Reason, 222, 0), writer.WriteByte, 0)
end

function Auto.WriteSpiritReplaceFightStyleInfo(writer, val)
	Base.WritePrimitive(writer, val.SpiritId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.OriginalFightStyleId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.ReplaceFightStyleId, writer.WriteUInt32, 0)
end

function Auto.WriteSpiritSummonAgentWheelWeaponInfo(writer, val)
	Base.WriteDict(writer, val.WheelWeaponInfos, writer.WriteUInt32, Base.WriteComplexWrap(Auto.WriteSummonAgentWheelWeaponInfo, "SummonAgentWheelWeaponInfo", false), nil, "WheelWeaponInfos", false, 0)
end

function Auto.WriteSpiritSwitchWeaponAction(writer, val)
	Base.WritePrimitive(writer, val.SpiritUid, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.WeaponInstanceId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, Base.CheckEnum(val.Reason, 223, 0), writer.WriteByte, 0)
end

function Auto.WriteSpiritTalentExpInfo(writer, val)
	Base.WritePrimitive(writer, val.SpiritId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.TalentExp, writer.WriteUInt32, 0)
end

function Auto.WriteSpiritTalentInfo(writer, val)
	Base.WritePrimitive(writer, val.Exp, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.Level, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.TalentPoint, writer.WriteUInt32, 0)
	Base.WriteDict(writer, val.UnlockTalentInfoDict, writer.WriteUInt32, Base.WriteComplexWrap(Auto.WriteSpiritOrJobTalentNodeInfo, "SpiritOrJobTalentNodeInfo", false), nil, "UnlockTalentInfoDict", false, 0)
	Base.WriteDict(writer, val.TalentTreeRecordDict, writer.WriteUInt32, Base.WriteComplexWrap(Auto.WriteTalentTreeRecord, "TalentTreeRecord", false), nil, "TalentTreeRecordDict", false, 0)
end

function Auto.WriteSpiritUpdateWeaponAction(writer, val)
	Base.WritePrimitive(writer, val.SpiritTid, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.SpiritUid, writer.WriteUInt64, 0)
	Base.WriteComplex(writer, val.Weapon, Auto.WriteWeaponDetail, "Weapon", false)
end

function Auto.WriteSpiritUrbanSkill(writer, val)
	Base.WriteList(writer, val.UrbanAbilities, writer.WriteInt32, 0, "UrbanAbilities", false, 0, nil)
end

function Auto.WriteSpiritVirtualFightStyleInfo(writer, val)
	Base.WritePrimitive(writer, val.SpiritId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.FightStyleTypeId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.FightStyleId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.EventId, writer.WriteUInt32, 0)
end

function Auto.WriteSpiritWeaponDetail(writer, val)
	Base.WritePrimitive(writer, val.SpiritTid, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.SpiritUid, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.CurrentWeaponUid, writer.WriteUInt64, 0)
	Base.WriteList7Bit(writer, val.WeaponSlots, Base.WriteComplexWrap(Auto.WriteWeaponDetail, "WeaponDetail", false), nil, "WeaponSlots", false, 0, nil)
	Base.WriteComplex(writer, val.CurrentTempWeapon, Auto.WriteWeaponDetail, "CurrentTempWeapon", true)
	Base.WriteComplex(writer, val.TempWeaponSlots, Auto.WriteWeaponWheelData, "TempWeaponSlots", true)
	Base.WriteDict7Bit(writer, val.VirtualWeaponSlots, writer.WriteInt32, Base.WriteComplexWrap(Auto.WriteWeaponDetail, "WeaponDetail", false), nil, "VirtualWeaponSlots", false, 0)
end

function Auto.WriteSpiritWeaponDurabilityChangedAction(writer, val)
	Base.WritePrimitive(writer, val.SpiritTid, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.SpiritUid, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.WeaponInstanceId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.Durability, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.MagazineAmmo, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.CurrentBulletId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.StackCount, writer.WriteInt32, 0)
end

function Auto.WriteSpiritWeaponSkinInfo(writer, val)
	Base.WriteDict(writer, val.SkinDict, writer.WriteUInt32, writer.WriteUInt32, 0, "SkinDict", false, 0)
end

function Auto.WriteSpiritWearFashionsInfo(writer, val)
	Base.WritePrimitive(writer, val.FunctionSuitId, writer.WriteUInt32, 0)
	Base.WriteStruct(writer, val.WearSourceInfo, Auto.WriteWearSourceInfo, "WearSourceInfo")
	Base.WritePrimitive(writer, val.IsTryWear, writer.WriteBoolean, false)
	Base.WriteList(writer, val.WearFashionInfoList, Base.WriteComplexWrap(Auto.WriteWearFashionInfo, "WearFashionInfo", false), nil, "WearFashionInfoList", false, RpcLengthLimits.BaseWearFashionsInfo_WearFashionInfoList, nil)
	Base.WriteList(writer, val.WearFashionEditInfoList, Base.WriteComplexWrap(Auto.WriteWearFashionEditInfo, "WearFashionEditInfo", true), nil, "WearFashionEditInfoList", true, RpcLengthLimits.BaseWearFashionsInfo_WearFashionEditInfoList, nil)
	Base.WritePrimitive(writer, val.HiddenParts, writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.EditedHiddenParts, writer.WriteByte, 0)
end

function Auto.WriteSpoonActionParam(writer, val)
	Base.WriteDict7Bit(writer, val.PortToValue, writer.WriteInt32, Base.WriteStringWrap(false, "PortToValue", RpcLengthLimits.SpoonActionParam_PortToValue_String), nil, "PortToValue", true, RpcLengthLimits.SpoonActionParam_PortToValue)
	Base.WriteStruct(writer, val.Position, Auto.WriteUXVector3, "Position")
	Base.WriteStruct(writer, val.Facing, Auto.WriteUXVector3, "Facing")
end

function Auto.WriteSpoonClientActionTriggerInfo(writer, val)
	Base.WritePrimitive(writer, val.NodeTaskId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.ContextTaskId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.EventId, writer.WriteUInt32, 0)
	Base.WriteDict7Bit(writer, val.Pid2Index, writer.WriteUInt64, writer.WriteInt32, 0, "Pid2Index", true, 0)
	Base.WritePrimitive(writer, val.PlateInstanceId, writer.WriteUInt64, 0)
end

function Auto.WriteSpoonClientData(writer, val)
	Base.WriteDict7Bit(writer, val.Enemies, writer.WriteInt32, writer.WriteUInt64, 0, "Enemies", false, 0)
	Base.WriteDict7Bit(writer, val.Npcs, writer.WriteInt32, writer.WriteUInt64, 0, "Npcs", false, 0)
	Base.WriteList7Bit(writer, val.TriggerInfos, Base.WriteComplexWrap(Auto.WriteSpoonTriggerInfo, "SpoonTriggerInfo", false), nil, "TriggerInfos", false, 0, nil)
	Base.WriteList7Bit(writer, val.SpoonRooms, Base.WriteComplexWrap(Auto.WriteSceneRoomChangeData, "SceneRoomChangeData", false), nil, "SpoonRooms", false, 0, nil)
	Base.WriteDict7Bit(writer, val.InteractiveNpcs, writer.WriteUInt32, writer.WriteBoolean, false, "InteractiveNpcs", false, 0)
end

function Auto.WriteSpoonNpcData(writer, val)
	Base.WritePrimitive(writer, val.Id, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.AgentId, writer.WriteUInt32, 0)
	Base.WriteStruct(writer, val.Position, Auto.WriteUXVector3, "Position")
	Base.WritePrimitive(writer, val.FacingDirection, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.EnterBattle, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.FashionSuitId, writer.WriteUInt32, 0)
	Base.WriteComplex(writer, val.AIAgentInfo, Auto.WriteLinkAIAgentInfo, "AIAgentInfo", true)
end

function Auto.WriteSpoonOutputLink(writer, val)
	writer:WriteString(val.Name, false, "SpoonOutputLink.Name", 0)
	Base.WriteList7Bit(writer, val.NextNodes, writer.WriteInt32, 0, "NextNodes", false, 0, nil)
end

function Auto.WriteSpoonPlateClientData(writer, val)
	Base.WritePrimitive(writer, val.PlateUId, writer.WriteUInt64, 0)
	Base.WriteList7Bit(writer, val.TriggerInfos, Base.WriteComplexWrap(Auto.WriteSpoonTriggerInfo, "SpoonTriggerInfo", false), nil, "TriggerInfos", false, 0, nil)
end

function Auto.WriteSpoonServerActionParam(writer, val)
	Base.WritePrimitive(writer, Base.CheckEnum(val.ActionType, 224, 0), writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.NodeId, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.Index, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.GraphId, writer.WriteInt32, 0)
	Base.WriteComplex(writer, val.Param, Auto.WriteSpoonActionParam, "Param", true)
	Base.WritePrimitive(writer, val.GadgetInstanceId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.TaskId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.VehicleId, writer.WriteUInt64, 0)
end

function Auto.WriteSpoonTaskClientData(writer, val)
	Base.WriteList7Bit(writer, val.TriggerInfos, Base.WriteComplexWrap(Auto.WriteSpoonTriggerInfo, "SpoonTriggerInfo", false), nil, "TriggerInfos", false, 0, nil)
	Base.WriteDict7Bit(writer, val.Enemies, writer.WriteInt32, writer.WriteUInt64, 0, "Enemies", false, 0)
	Base.WriteList7Bit(writer, val.SpoonRooms, Base.WriteComplexWrap(Auto.WriteSceneRoomChangeData, "SceneRoomChangeData", false), nil, "SpoonRooms", false, 0, nil)
	Base.WriteList7Bit(writer, val.RemovedNpcList, writer.WriteInt32, 0, "RemovedNpcList", false, 0, nil)
	Base.WriteDict7Bit(writer, val.VehicleIdDict, writer.WriteInt32, writer.WriteInt32, 0, "VehicleIdDict", false, 0)
	Base.WritePrimitive(writer, val.TaskId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.EventId, writer.WriteUInt32, 0)
end

function Auto.WriteSpoonTriggerInfo(writer, val)
	Base.WritePrimitive(writer, val.FlowIndex, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.NodeId, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.StartTime, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.NeedComplete, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.MemoryTaskId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.IsCondition, writer.WriteBoolean, false)
	Base.WriteList7Bit(writer, val.Ports, Base.WriteComplexWrap(Auto.WriteControlFlowData, "ControlFlowData", true), nil, "Ports", true, 0, nil)
	Base.WriteDict7Bit(writer, val.pid2Index, writer.WriteUInt64, writer.WriteInt32, 0, "pid2Index", true, 0)
end

function Auto.WriteSpriteToken(writer, val)
	writer:WriteString(val.Token, false, "SpriteToken.Token", 0)
	Base.WritePrimitive(writer, val.ExpireTimeStamp, writer.WriteUInt64, 0)
end

function Auto.WriteStartPatrolInfo(writer, val)
	Base.WritePrimitive(writer, val.Uid, writer.WriteUInt64, 0)
	writer:WriteString(val.FileName, false, "StartPatrolInfo.FileName", 0)
	Base.WritePrimitive(writer, val.HashCode, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.SeqIndex, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.GroupIndex, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.PointIndex, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.CommandIndex, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.Loop, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.Return, writer.WriteBoolean, false)
end

function Auto.WriteStaticDestructibleInfo(writer, val)
	Base.WritePrimitive(writer, val.GroupId, writer.WriteInt32, 0)
	Base.WriteComplex(writer, val.Pack, Auto.WritePackedDestructibleInfo, "Pack", true)
	Base.WritePrimitive(writer, val.InstanceId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.UniqueId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.CfgId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.PathId, writer.WriteInt32, 0)
	Base.WriteStruct(writer, val.Position, Auto.WriteUXVector3, "Position")
	Base.WriteStruct(writer, val.Facing, Auto.WriteUXVector3, "Facing")
	Base.WritePrimitive(writer, val.iScale, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.NavId, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.ForceLod0, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.BindPid, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.Hp, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, Base.CheckEnum(val.State, 145, 0), writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.BreakStage, writer.WriteUInt32, 0)
	Base.WriteList7Bit(writer, val.OccupantInfos, Base.WriteStructWrap(Auto.WriteSceneDeviceOccupantInfo, "OccupantInfos"), nil, "OccupantInfos", true, 0, nil)
	Base.WritePrimitive(writer, val.DropWeaponId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.StackCount, writer.WriteInt32, 0)
	Base.WriteList7Bit(writer, val.EffectIds, writer.WriteInt32, 0, "EffectIds", true, 0, nil)
	Base.WritePrimitive(writer, val.NoSleep, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.ReleaserId, writer.WriteUInt64, 0)
	Base.WriteComplex(writer, val.SkillInfo, Auto.WriteSkillDestructibleInfo, "SkillInfo", true)
end

function Auto.WriteStaticNpcGridSpawnLogDto(writer, val)
	Base.WritePrimitive(writer, val.GridX, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.GridZ, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.WasTriggered, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, Base.CheckEnum(val.GridBlockReason, 225, 0), writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.TriggerGameTime, writer.WriteDouble, 0)
	Base.WriteList7Bit(writer, val.Entries, Base.WriteComplexWrap(Auto.WriteStaticNpcSpawnLogDto, "StaticNpcSpawnLogDto", false), nil, "Entries", false, 0, nil)
end

function Auto.WriteStaticNpcSpawnLogDto(writer, val)
	Base.WritePrimitive(writer, val.Index, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.NpcId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, Base.CheckEnum(val.SourceType, 133, 0), writer.WriteByte, 0)
	Base.WritePrimitive(writer, Base.CheckEnum(val.PrefabCreateType, 226, 0), writer.WriteByte, 0)
	writer:WriteString(val.PrefabSource, false, "StaticNpcSpawnLogDto.PrefabSource", 0)
	Base.WriteStruct(writer, val.Position, Auto.WriteUXVector3, "Position")
	Base.WritePrimitive(writer, Base.CheckEnum(val.Status, 227, 0), writer.WriteByte, 0)
	Base.WritePrimitive(writer, Base.CheckEnum(val.BlockReason, 228, 0), writer.WriteByte, 0)
	writer:WriteString(val.BlockDetail, false, "StaticNpcSpawnLogDto.BlockDetail", 0)
	writer:WriteString(val.SpawnPath, false, "StaticNpcSpawnLogDto.SpawnPath", 0)
	Base.WritePrimitive(writer, val.LiveNpcInstanceId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.CdRemainingGameHours, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.CdRemainingRealSecs, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.ProbabilityValue, writer.WriteSingle, 0)
end

function Auto.WriteStimEventParameter(writer, val)
	Base.WriteStruct(writer, val.Source, Auto.WriteClientActionTarget, "Source")
	Base.WriteStruct(writer, val.Source2, Auto.WriteClientActionTarget, "Source2")
end

function Auto.WriteStopParameters(writer, val)
	Base.WritePrimitive(writer, val.StopRatio, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.useThrottleStop, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.StopHandBrake, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.StopDelayTime, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.Token, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.taskAIConfigId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.defaultSpeed, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.drivingFlags, writer.WriteInt32, 1)
	Base.WritePrimitive(writer, val.initSpeed, writer.WriteSingle, 0)
	Base.WriteList7Bit(writer, val.initTaskAIBuffList, Base.WriteStructWrap(Auto.WriteTaskVehicleBuffInitInfo, "initTaskAIBuffList"), nil, "initTaskAIBuffList", true, 0, nil)
	Base.WriteStruct(writer, val.commonParameters, Auto.WriteVehicleAICommonParameters, "commonParameters")
end

function Auto.WriteStoryClientCommand(writer, val)
	Base.WritePrimitive(writer, val.RpcId, writer.WriteInt64, 0)
	Base.WritePrimitive(writer, val.HasRpcId, writer.WriteBoolean, false)
end

function Auto.WriteStoryNetPayload(writer, val)
end

function Auto.WriteStoryServerCommand(writer, val)
	Base.WritePrimitive(writer, val.RpcId, writer.WriteInt64, 0)
	Base.WritePrimitive(writer, val.HasRpcId, writer.WriteBoolean, false)
end

function Auto.WriteStringPayload(writer, val)
	writer:WriteString(val.V, false, "StringPayload.V", RpcLengthLimits.StringPayload_V)
end

function Auto.WriteStsAssumeRole(writer, val)
	writer:WriteString(val.AccessKeyId, false, "StsAssumeRole.AccessKeyId", 0)
	writer:WriteString(val.AccessKeySecret, false, "StsAssumeRole.AccessKeySecret", 0)
	writer:WriteString(val.SecurityToken, false, "StsAssumeRole.SecurityToken", 0)
	Base.WritePrimitive(writer, val.ExpireTimeStamp, writer.WriteUInt32, 0)
	writer:WriteString(val.Region, false, "StsAssumeRole.Region", 0)
	writer:WriteString(val.Endpoint, false, "StsAssumeRole.Endpoint", 0)
	writer:WriteString(val.Prefix, false, "StsAssumeRole.Prefix", 0)
	writer:WriteString(val.Buket, false, "StsAssumeRole.Buket", 0)
end

function Auto.WriteSubmitItemData(writer, val)
	Base.WritePrimitive(writer, val.SubmittedCount, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.LastSubmitTime, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.NextResetTime, writer.WriteUInt32, 0)
end

function Auto.WriteSubmitItemES(writer, val)
	Base.WritePrimitive(writer, val.bagId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.cellX, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.cellY, writer.WriteUInt32, 0)
end

function Auto.WriteSubmitItemIdentity(writer, val)
	Base.WriteComplex(writer, val.Uid, Auto.WriteSubmitItemUlong, "Uid", true)
	Base.WriteComplex(writer, val.EsId, Auto.WriteSubmitItemES, "EsId", true)
	Base.WritePrimitive(writer, val.Count, writer.WriteUInt32, 0)
end

function Auto.WriteSubmitItemInfo(writer, val)
	Base.WriteList7Bit(writer, val.Items, Base.WriteComplexWrap(Auto.WriteSubmitSingleItemInfo, "SubmitSingleItemInfo", true), nil, "Items", true, RpcLengthLimits.SubmitItemInfo_Items, nil)
end

function Auto.WriteSubmitItemKey(writer, val)
	Base.WritePrimitive(writer, Base.CheckEnum(val.ItemType, 229, 0), writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.ConfigID, writer.WriteUInt32, 0)
end

function Auto.WriteSubmitItemUlong(writer, val)
	Base.WritePrimitive(writer, val.Value, writer.WriteUInt64, 0)
end

function Auto.WriteSubmitSingleItemInfo(writer, val)
	Base.WriteStruct(writer, val.Key, Auto.WriteSubmitItemKey, "Key")
	Base.WriteList7Bit(writer, val.Identities, Base.WriteStructWrap(Auto.WriteSubmitItemIdentity, "Identities"), nil, "Identities", true, RpcLengthLimits.SubmitSingleItemInfo_Identities, nil)
end

function Auto.WriteSummonAgentWheelWeaponInfo(writer, val)
	Base.WriteList(writer, val.Weapons, writer.WriteUInt32, 0, "Weapons", false, 0, nil)
end

function Auto.WriteSummonVehicleResult(writer, val)
	Base.WritePrimitive(writer, val.VehicleEntityId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.TaskToken, writer.WriteUInt64, 0)
end

function Auto.WriteSurroundNpcSpawnInfo(writer, val)
	Base.WriteStruct(writer, val.Position, Auto.WriteUXVector3, "Position")
	Base.WritePrimitive(writer, val.Facing, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.Pid, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.NpcFormworkId, writer.WriteUInt32, 0)
end

function Auto.WriteSyncAgentProperty(writer, val)
	Base.WriteComplex(writer, val.V, Auto.WriteAgentPropertyData, "V", false)
	Base.WritePrimitive(writer, Base.CheckEnum(val.Type, 230, 0), writer.WriteByte, 0)
end

function Auto.WriteSyncCinemaQueryInfo(writer, val)
	Base.WriteList7Bit(writer, val.HaveSeenList, writer.WriteUInt32, 0, "HaveSeenList", false, 0, nil)
	Base.WriteComplex(writer, val.TicketInfo, Auto.WriteCinemaTicketInfo, "TicketInfo", true)
	Base.WritePrimitive(writer, val.InviteNpcId, writer.WriteUInt64, 0)
	Base.WriteList7Bit(writer, val.UnlockMovies, writer.WriteUInt32, 0, "UnlockMovies", false, 0, nil)
end

function Auto.WriteSyncClientNodeCommand(writer, val)
	Base.WritePrimitive(writer, val.RpcId, writer.WriteInt64, 0)
	Base.WritePrimitive(writer, val.HasRpcId, writer.WriteBoolean, false)
end

function Auto.WriteSyncMoveActionData(writer, val)
	Base.WritePrimitive(writer, val.UnitId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.MoveTime, writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.ClientLocalTime, writer.WriteUInt32, 0)
	Base.WriteList7Bit(writer, val.ActionData, writer.WriteByte, 0, "ActionData", true, 0, nil)
	Base.WriteList7Bit(writer, val.EffectData, writer.WriteByte, 0, "EffectData", true, 0, nil)
end

function Auto.WriteSyncMoveActionDataWithGround(writer, val)
	Base.WritePrimitive(writer, val.UnitId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.MoveTime, writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.ClientLocalTime, writer.WriteUInt32, 0)
	Base.WriteComplex(writer, val.GroundData, Auto.WriteMoveActionGroundData, "GroundData", false)
	Base.WriteList7Bit(writer, val.ActionData, writer.WriteByte, 0, "ActionData", true, 0, nil)
	Base.WriteList7Bit(writer, val.EffectData, writer.WriteByte, 0, "EffectData", true, 0, nil)
end

function Auto.WriteSyncMultiCinemaQueryInfo(writer, val)
	Base.WritePrimitive(writer, val.LastestMovieId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.LastestMovieStartTime, writer.WriteUInt32, 0)
	Base.WriteComplex(writer, val.TicketInfo, Auto.WriteCinemaMultiTicketInfo, "TicketInfo", true)
end

function Auto.WriteSyncWorldBattlePlayersExtraInfo(writer, val)
	Base.WriteStruct(writer, val.Position, Auto.WriteUXVector3, "Position")
end

function Auto.WriteTalentTreeRecord(writer, val)
	Base.WritePrimitive(writer, val.SpentTalentPoint, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.ActivatedNodeCount, writer.WriteUInt32, 0)
end

function Auto.WriteTargetIsRunningConditionData(writer, val)
	Base.WriteStruct(writer, val.Target, Auto.WriteClientActionTarget, "Target")
end

function Auto.WriteTargetRayCastListResItem(writer, val)
	Base.WritePrimitive(writer, val.TargetId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.Res, writer.WriteBoolean, false)
end

function Auto.WriteTargetRayCastResInfo(writer, val)
	Base.WritePrimitive(writer, val.Uid, writer.WriteUInt64, 0)
	Base.WriteList7Bit(writer, val.Results, Base.WriteStructWrap(Auto.WriteTargetRayCastListResItem, "Results"), nil, "Results", false, RpcLengthLimits.TargetRayCastResInfo_Results, nil)
	Base.WritePrimitive(writer, val.Source, writer.WriteInt32, 0)
end

function Auto.WriteTaskDestructibleInfo(writer, val)
	Base.WritePrimitive(writer, val.PlateInlineId, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.GroupId, writer.WriteUInt64, 0)
	writer:WriteString(val.TriggerTag, true, "TaskDestructibleInfo.TriggerTag", 0)
	Base.WritePrimitive(writer, val.NpcPhoneId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.ExternalSystemLinkId, writer.WriteUInt32, 0)
	Base.WriteComplex(writer, val.AdherePlatformInfo, Auto.WriteAdhereMovingPlatformInfo, "AdherePlatformInfo", true)
	Base.WriteDict7Bit(writer, val.ExposeParams, writer.WriteInt32, Base.WriteStringWrap(false, "ExposeParams", 0), nil, "ExposeParams", true, 0)
	Base.WritePrimitive(writer, val.InstanceId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.UniqueId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.CfgId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.PathId, writer.WriteInt32, 0)
	Base.WriteStruct(writer, val.Position, Auto.WriteUXVector3, "Position")
	Base.WriteStruct(writer, val.Facing, Auto.WriteUXVector3, "Facing")
	Base.WritePrimitive(writer, val.iScale, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.NavId, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.ForceLod0, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.BindPid, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.Hp, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, Base.CheckEnum(val.State, 145, 0), writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.BreakStage, writer.WriteUInt32, 0)
	Base.WriteList7Bit(writer, val.OccupantInfos, Base.WriteStructWrap(Auto.WriteSceneDeviceOccupantInfo, "OccupantInfos"), nil, "OccupantInfos", true, 0, nil)
	Base.WritePrimitive(writer, val.DropWeaponId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.StackCount, writer.WriteInt32, 0)
	Base.WriteList7Bit(writer, val.EffectIds, writer.WriteInt32, 0, "EffectIds", true, 0, nil)
	Base.WritePrimitive(writer, val.NoSleep, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.ReleaserId, writer.WriteUInt64, 0)
	Base.WriteComplex(writer, val.SkillInfo, Auto.WriteSkillDestructibleInfo, "SkillInfo", true)
end

function Auto.WriteTaskEventInfo(writer, val)
	Base.WritePrimitive(writer, val.EventId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.TaskId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.UnlockTime, writer.WriteUInt32, 0)
	Base.WriteList(writer, val.FinishedChoiceLs, writer.WriteUInt32, 0, "FinishedChoiceLs", true, 0, nil)
	Base.WritePrimitive(writer, val.StatusData, writer.WriteByte, 0)
end

function Auto.WriteTaskMoveCommandData(writer, val)
	Base.WritePrimitive(writer, Base.CheckEnum(val.TargetType, 231, 0), writer.WriteByte, 0)
	Base.WriteStruct(writer, val.TargetObject, Auto.WriteClientActionTarget, "TargetObject")
	Base.WriteStruct(writer, val.TargetPosition, Auto.WriteUXVector3, "TargetPosition")
	Base.WritePrimitive(writer, Base.CheckEnum(val.MoveTowardType, 232, 0), writer.WriteByte, 0)
	Base.WriteStruct(writer, val.TargetDirection, Auto.WriteUXVector3, "TargetDirection")
	Base.WritePrimitive(writer, val.ArriveDistance, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.SpecificMethod, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.DirectionTolerance, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.TryMatchStep, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.RunChasingDistance, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.KeepMovingAction, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.Speed, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.MoveActionId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.MoveActionGroup, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.NoRootMotion, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.ObstacleAvoidanceSwitch, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, Base.CheckEnum(val.DataSource, 97, 0), writer.WriteInt16, 0)
end

function Auto.WriteTaskRaidRuleShowDialogParam(writer, val)
	Base.WritePrimitive(writer, val.DialogId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.TaskId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.StopWhenTaskEnd, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.StopWhenAgentDie, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.StopWhenTeleport, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.AttachDialog, writer.WriteBoolean, false)
end

function Auto.WriteTaskSpoonViewInfo(writer, val)
	writer:WriteString(val.SpoonMd5, false, "TaskSpoonViewInfo.SpoonMd5", 0)
	Base.WritePrimitive(writer, val.SpRaidId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.StartTaskId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.EndTaskId, writer.WriteUInt32, 0)
	writer:WriteString(val.Alias, true, "TaskSpoonViewInfo.Alias", 0)
	Base.WritePrimitive(writer, val.EventId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.EventStartTaskId, writer.WriteUInt32, 0)
end

function Auto.WriteTaskStateData(writer, val)
	Base.WritePrimitive(writer, Base.CheckEnum(val.State, 233, 0), writer.WriteByte, 0)
	Base.WritePrimitive(writer, Base.CheckEnum(val.Reason, 234, 0), writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.FailTextId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.CanSkip, writer.WriteBoolean, false)
end

function Auto.WriteTaskVehicleBuffInitInfo(writer, val)
	Base.WritePrimitive(writer, val.configId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.duration, writer.WriteSingle, 0)
end

function Auto.WriteTaskViewCounter(writer, val)
	Base.WritePrimitive(writer, val.Index, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.Value, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.ConfigValue, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.Parent, writer.WriteInt32, 0)
	Base.WriteList7Bit(writer, val.Child, Base.WriteComplexWrap(Auto.WriteTaskViewCounter, "TaskViewCounter", true), nil, "Child", true, 0, nil)
end

function Auto.WriteTaskViewData(writer, val)
	Base.WritePrimitive(writer, val.TaskId, writer.WriteUInt32, 0)
	Base.WriteList7Bit(writer, val.CounterValues, writer.WriteInt32, 0, "CounterValues", false, 0, nil)
	Base.WriteList7Bit(writer, val.Counters, Base.WriteComplexWrap(Auto.WriteTaskViewCounter, "TaskViewCounter", false), nil, "Counters", false, 0, nil)
	Base.WritePrimitive(writer, Base.CheckEnum(val.State, 233, 0), writer.WriteByte, 0)
	Base.WriteDict7Bit(writer, val.ActiveFunctionValue, writer.WriteByte, writer.WriteInt32, 0, "ActiveFunctionValue", true, 0)
	Base.WriteDict7Bit(writer, val.ActiveFunctionIds, writer.WriteByte, Base.WriteComplexWrap(Auto.WriteIntList, "IntList", false), nil, "ActiveFunctionIds", true, 0)
	Base.WritePrimitive(writer, val.RecoverResource, writer.WriteBoolean, false)
	Base.WriteComplex(writer, val.SpoonViewInfo, Auto.WriteTaskSpoonViewInfo, "SpoonViewInfo", true)
end

function Auto.WriteTaskWaitLoadResource(writer, val)
	Base.WriteList7Bit(writer, val.AgentSpoonIds, writer.WriteInt32, 0, "AgentSpoonIds", false, 0, nil)
	Base.WriteList7Bit(writer, val.Gadgets, writer.WriteUInt64, 0, "Gadgets", false, 0, nil)
	Base.WriteList7Bit(writer, val.SceneItems, writer.WriteUInt64, 0, "SceneItems", false, 0, nil)
	Base.WriteList7Bit(writer, val.VehicleSpoonIds, writer.WriteInt32, 0, "VehicleSpoonIds", false, 0, nil)
	Base.WriteList7Bit(writer, val.DynamicGoIds, writer.WriteInt32, 0, "DynamicGoIds", false, 0, nil)
	Base.WritePrimitive(writer, val.EntryAgentViewpointSpoonId, writer.WriteInt32, 0)
end

function Auto.WriteTaskWayPointMoveCommandData(writer, val)
	Base.WritePrimitive(writer, Base.CheckEnum(val.SpecificMethod, 104, 0), writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.KeepMovingAction, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.Speed, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.MoveActionId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.NoRootMotion, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.MoveActionGroup, writer.WriteUInt32, 0)
	Base.WriteList7Bit(writer, val.WayPoints, Base.WriteStructWrap(Auto.WriteUXVector3, "WayPoints"), nil, "WayPoints", false, 0, nil)
	Base.WritePrimitive(writer, Base.CheckEnum(val.DataSource, 97, 0), writer.WriteInt16, 0)
end

function Auto.WriteTeamSetting(writer, val)
	Base.WritePrimitive(writer, val.AllowMemberInvite, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.AutoApplyJoin, writer.WriteBoolean, false)
end

function Auto.WriteTeamTrackGPS(writer, val)
	Base.WriteStruct(writer, val.TrackPosition, Auto.WriteUXVector3, "TrackPosition")
	writer:WriteString(val.TrackGPSId, false, "TeamTrackGPS.TrackGPSId", RpcLengthLimits.TeamTrackGPS_TrackGPSId)
	Base.WritePrimitive(writer, val.TrackGPSType, writer.WriteUInt32, 0)
end

function Auto.WriteTeleportOption(writer, val)
	Base.WritePrimitive(writer, val.teleportId, writer.WriteUInt64, 0)
	Base.WriteStruct(writer, val.Position, Auto.WriteUXVector3, "Position")
	Base.WritePrimitive(writer, val.Facing, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.IsSwitchScene, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.WaitTaskResource, writer.WriteBoolean, false)
end

function Auto.WriteThreatDebugValue(writer, val)
	Base.WritePrimitive(writer, val.BaseThreat, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.FinalThreat, writer.WriteSingle, 0)
end

function Auto.WriteTierDetail(writer, val)
	Base.WritePrimitive(writer, val.TierConfigId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.CurrentBigTierId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.CurrentSmallTierId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.Points, writer.WriteUInt32, 0)
end

function Auto.WriteTierDetailSettleData(writer, val)
	Base.WritePrimitive(writer, val.Delta, writer.WriteInt32, 0)
	Base.WriteComplex(writer, val.OldTierDetailInfo, Auto.WriteClientTierDetailInfo, "OldTierDetailInfo", false)
	Base.WriteComplex(writer, val.NewTierDetailInfo, Auto.WriteClientTierDetailInfo, "NewTierDetailInfo", false)
end

function Auto.WriteTile(writer, val)
	Base.WritePrimitive(writer, Base.CheckEnum(val.Suit, 235, 0), writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.Rank, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.IsRed, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.InstanceId, writer.WriteInt32, 0)
end

function Auto.WriteTimePanelInfo(writer, val)
	Base.WriteList7Bit(writer, val.PersonalTimeSettings, Base.WriteComplexWrap(Auto.WritePersonalTimeSetting, "PersonalTimeSetting", true), nil, "PersonalTimeSettings", true, 0, nil)
end

function Auto.WriteTokenInfo(writer, val)
	Base.WritePrimitive(writer, val.Aid, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.Pid, writer.WriteUInt64, 0)
	writer:WriteString(val.Ip, false, "TokenInfo.Ip", 0)
	Base.WritePrimitive(writer, val.Port, writer.WriteInt32, 0)
	writer:WriteString(val.Token, false, "TokenInfo.Token", 0)
	Base.WritePrimitive(writer, val.GateServerId, writer.WriteInt32, 0)
	writer:WriteString(val.AccountId, false, "TokenInfo.AccountId", 0)
end

function Auto.WriteTradeBucketInfo(writer, val)
	Base.WritePrimitive(writer, val.BucketId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.OrderCount, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.Count, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.MinPrice, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.MaxPrice, writer.WriteUInt32, 0)
end

function Auto.WriteTradeOrderDetail(writer, val)
	Base.WritePrimitive(writer, val.SellerId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.BucketId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.OrderId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.TradeItemId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.Count, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.Price, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.ListTime, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.ExpireTime, writer.WriteUInt32, 0)
end

function Auto.WriteTradeOrderItem(writer, val)
	Base.WritePrimitive(writer, val.OrderId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.TradeItemId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.Count, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.Price, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.ListTime, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.ExpireTime, writer.WriteUInt32, 0)
end

function Auto.WriteTradeOrderRef(writer, val)
	Base.WritePrimitive(writer, val.OrderId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.TradeItemId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.BucketId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.Count, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.ExpireTime, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.Price, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, Base.CheckEnum(val.State, 236, 0), writer.WriteByte, 0)
end

function Auto.WriteTruckCargoSettleInfo(writer, val)
	Base.WritePrimitive(writer, val.Completeness, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.IsInGadget, writer.WriteBoolean, false)
end

function Auto.WriteTruckJobOrderAccept(writer, val)
	Base.WritePrimitive(writer, val.AcceptedEventId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.AcceptTime, writer.WriteUInt32, 0)
end

function Auto.WriteTruckJobOrderInfo(writer, val)
	Base.WriteComplex(writer, val.StartPos, Auto.WriteTruckPosInfo, "StartPos", false)
	Base.WriteComplex(writer, val.EndPos, Auto.WriteTruckPosInfo, "EndPos", false)
	Base.WritePrimitive(writer, val.CargoId, writer.WriteUInt32, 0)
	Base.WriteComplex(writer, val.DeliveryNpc, Auto.WriteTruckNpcInfo, "DeliveryNpc", false)
	Base.WritePrimitive(writer, val.IsEmergency, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.LimitAcceptSeconds, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.LimitFinishSeconds, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.EstimatedFinishSeconds, writer.WriteInt32, 0)
	Base.WriteList(writer, val.CargoInfoList, Base.WriteComplexWrap(Auto.WriteCargoInfo, "CargoInfo", false), nil, "CargoInfoList", false, 0, nil)
	Base.WritePrimitive(writer, val.BasePointReward, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.DropCoefficient, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.DropMoney, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.SpecialOrderId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.SpecialPointReward, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.AddDropCoefficient, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.ActivityIndex, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.IsHighValue, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.RandomOrderId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.IsDailyOrder, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.OrderType, writer.WriteUInt32, 0)
end

function Auto.WriteTruckJobOrderResult(writer, val)
	Base.WritePrimitive(writer, val.FinishTime, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.CargoIntegrity, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.DropId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.DropCoefficient, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.RewardPoint, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, Base.CheckEnum(val.Evaluation, 237, 0), writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.CustomerSatisfaction, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.DropMoney, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.Dropped, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.IsCargoNear, writer.WriteBoolean, false)
	Base.WriteList(writer, val.AddBuffList, writer.WriteUInt32, 0, "AddBuffList", false, 0, nil)
	Base.WriteList(writer, val.RemoveBuffList, writer.WriteUInt32, 0, "RemoveBuffList", false, 0, nil)
	Base.WritePrimitive(writer, val.OrderDeliverUpSetId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.DeliverUpset, writer.WriteUInt32, 0)
end

function Auto.WriteTruckJobOrderWrap(writer, val)
	Base.WriteComplex(writer, val.OrderInfo, Auto.WriteTruckJobOrderInfo, "OrderInfo", false)
	Base.WritePrimitive(writer, val.UniqueId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.OrderInfoStartTime, writer.WriteUInt32, 0)
	Base.WriteComplex(writer, val.AcceptInfo, Auto.WriteTruckJobOrderAccept, "AcceptInfo", true)
	Base.WriteComplex(writer, val.ResultInfo, Auto.WriteTruckJobOrderResult, "ResultInfo", true)
	Base.WritePrimitive(writer, val.CargoPickedUp, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.CargoIntegrity, writer.WriteSingle, 0)
end

function Auto.WriteTruckNpcInfo(writer, val)
	Base.WritePrimitive(writer, val.NpcId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.ConsigneeId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.RudeId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.CharacterId, writer.WriteUInt32, 0)
end

function Auto.WriteTruckPosInfo(writer, val)
	Base.WritePrimitive(writer, val.WpId, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.ConfigId, writer.WriteUInt32, 0)
	Base.WriteStruct(writer, val.Pos, Auto.WriteUXVector3, "Pos")
	Base.WriteStruct(writer, val.Rot, Auto.WriteUXVector3, "Rot")
	Base.WritePrimitive(writer, val.GadgetUId, writer.WriteUInt64, 0)
	Base.WriteList(writer, val.DeliveryGadgetInfoList, Base.WriteComplexWrap(Auto.WriteDeliveryGadgetInfo, "DeliveryGadgetInfo", false), nil, "DeliveryGadgetInfoList", false, 0, nil)
end

function Auto.WriteTrustNpcInfo(writer, val)
	Base.WritePrimitive(writer, val.ProfileId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.TrustValue, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.ActivateTime, writer.WriteUInt32, 0)
	Base.WriteList(writer, val.GotRewardList, writer.WriteUInt32, 0, "GotRewardList", false, 0, nil)
	Base.WriteList(writer, val.FinishTargetList, writer.WriteUInt32, 0, "FinishTargetList", false, 0, nil)
	Base.WritePrimitive(writer, val.IsNew, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.IsMaxTrustReward, writer.WriteBoolean, false)
	Base.WriteList(writer, val.TargetStateList, Base.WriteComplexWrap(Auto.WriteTrustNpcTargetState, "TrustNpcTargetState", false), nil, "TargetStateList", false, 0, nil)
end

function Auto.WriteTrustNpcTargetState(writer, val)
	Base.WritePrimitive(writer, val.TargetId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.IsNew, writer.WriteBoolean, false)
end

function Auto.WriteTsumoInfo(writer, val)
	Base.WritePrimitive(writer, val.TsumoPlayerIndex, writer.WriteInt32, 0)
	writer:WriteString(val.TsumoPlayerName, false, "TsumoInfo.TsumoPlayerName", 0)
	Base.WriteStruct(writer, val.TsumoHandData, Auto.WritePlayerHandData, "TsumoHandData")
	Base.WriteList7Bit(writer, val.AllHandData, Base.WriteStructWrap(Auto.WritePlayerHandData, "AllHandData"), nil, "AllHandData", false, 0, nil)
	Base.WriteStruct(writer, val.WinningTile, Auto.WriteTile, "WinningTile")
	Base.WriteList7Bit(writer, val.DoraIndicators, Base.WriteStructWrap(Auto.WriteTile, "DoraIndicators"), nil, "DoraIndicators", false, 0, nil)
	Base.WriteList7Bit(writer, val.UraDoraIndicators, Base.WriteStructWrap(Auto.WriteTile, "UraDoraIndicators"), nil, "UraDoraIndicators", false, 0, nil)
	Base.WritePrimitive(writer, val.IsRichi, writer.WriteBoolean, false)
	Base.WriteStruct(writer, val.TsumoPointInfo, Auto.WriteNetworkPointInfo, "TsumoPointInfo")
	Base.WritePrimitive(writer, val.TotalPoints, writer.WriteInt32, 0)
end

function Auto.WriteTuiteCommentListData(writer, val)
	Base.WritePrimitive(writer, val.Total, writer.WriteInt32, 0)
	Base.WriteList7Bit(writer, val.CommentList, Base.WriteStructWrap(Auto.WriteClientTuiteComment, "CommentList"), nil, "CommentList", false, 0, nil)
end

function Auto.WriteTuiteTimelineData(writer, val)
	Base.WritePrimitive(writer, val.Id, writer.WriteUInt32, 0)
	writer:WriteString(val.TimelineData, false, "TuiteTimelineData.TimelineData", 0)
end

function Auto.WriteTurnCommandData(writer, val)
	Base.WriteStruct(writer, val.Target, Auto.WriteClientActionTarget, "Target")
	Base.WritePrimitive(writer, val.DirectionTolerance, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, Base.CheckEnum(val.DataSource, 97, 0), writer.WriteInt16, 0)
end

function Auto.WriteTurnEndInfo(writer, val)
	Base.WritePrimitive(writer, val.PlayerIndex, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, Base.CheckEnum(val.ChosenOperationType, 192, 0), writer.WriteByte, 0)
	Base.WriteList7Bit(writer, val.Operations, Base.WriteStructWrap(Auto.WriteOutTurnOperation, "Operations"), nil, "Operations", false, 0, nil)
	Base.WriteList7Bit(writer, val.Points, writer.WriteInt32, 0, "Points", false, 0, nil)
	Base.WriteList7Bit(writer, val.RichiStatus, writer.WriteBoolean, false, "RichiStatus", false, 0, nil)
	Base.WritePrimitive(writer, val.RichiSticks, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.Zhenting, writer.WriteBoolean, false)
	Base.WriteStruct(writer, val.MahjongSetData, Auto.WriteMahjongSetData, "MahjongSetData")
end

function Auto.WriteTurnToPositionData(writer, val)
	Base.WriteStruct(writer, val.Position, Auto.WriteUXVector3, "Position")
	Base.WritePrimitive(writer, val.Speed, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.ActionId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.IsImmediate, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.Uid, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.MaxTime, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.ActionUid, writer.WriteUInt32, 0)
end

function Auto.WriteUAVAutoDriveCommandData(writer, val)
	Base.WriteStruct(writer, val.Destination, Auto.WriteUXVector3, "Destination")
	Base.WritePrimitive(writer, Base.CheckEnum(val.DataSource, 97, 0), writer.WriteInt16, 0)
end

function Auto.WriteUAVFollowCommandData(writer, val)
	Base.WritePrimitive(writer, val.TargetId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.ArriveDistance, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.Speed, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, Base.CheckEnum(val.DataSource, 97, 0), writer.WriteInt16, 0)
end

function Auto.WriteUAVPutDownCommandData(writer, val)
	Base.WritePrimitive(writer, Base.CheckEnum(val.DataSource, 97, 0), writer.WriteInt16, 0)
end

function Auto.WriteUAVPutUpCommandData(writer, val)
	Base.WritePrimitive(writer, Base.CheckEnum(val.DataSource, 97, 0), writer.WriteInt16, 0)
end

function Auto.WriteUIntPayload(writer, val)
	Base.WritePrimitive(writer, val.V, writer.WriteUInt32, 0)
end

function Auto.WriteULongPayload(writer, val)
	Base.WritePrimitive(writer, val.V, writer.WriteUInt64, 0)
end

function Auto.WriteUShortPayload(writer, val)
	Base.WritePrimitive(writer, val.V, writer.WriteUInt16, 0)
end

function Auto.WriteUXBoolObject(writer, val)
	Base.WritePrimitive(writer, val.Value, writer.WriteBoolean, false)
end

function Auto.WriteUXDoubleObject(writer, val)
	Base.WritePrimitive(writer, val.Value, writer.WriteDouble, 0)
end

function Auto.WriteUXIntObject(writer, val)
	Base.WritePrimitive(writer, val.Value, writer.WriteInt32, 0)
end

function Auto.WriteUXLongObject(writer, val)
	Base.WritePrimitive(writer, val.Value, writer.WriteInt64, 0)
end

function Auto.WriteUXMassHideArea(writer, val)
	Base.WritePrimitive(writer, val.Uid, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.Hide, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.HideType, writer.WriteInt32, 0)
	Base.WriteStruct(writer, val.Center, Auto.WriteUXVector3, "Center")
	Base.WriteStruct(writer, val.Extends, Auto.WriteUXVector3, "Extends")
	Base.WriteStruct(writer, val.Rotation, Auto.WriteUXVector3, "Rotation")
end

function Auto.WriteUXObject(writer, val)
end

function Auto.WriteUXStringObject(writer, val)
	writer:WriteString(val.Value, false, "UXStringObject.Value", 0)
end

function Auto.WriteUXUintObject(writer, val)
	Base.WritePrimitive(writer, val.Value, writer.WriteUInt32, 0)
end

function Auto.WriteUXUlongObject(writer, val)
	Base.WritePrimitive(writer, val.Value, writer.WriteUInt64, 0)
end

function Auto.WriteUXVector2Int(writer, val)
	Base.WritePrimitive(writer, val.X, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.Y, writer.WriteInt32, 0)
end

function Auto.WriteUXVector3List(writer, val)
	Base.WriteList7Bit(writer, val.Value, Base.WriteStructWrap(Auto.WriteUXVector3, "Value"), nil, "Value", false, 0, nil)
end

function Auto.WriteUXVector3Payload(writer, val)
	Base.WriteStruct(writer, val.V, Auto.WriteUXVector3, "V")
end

function Auto.WriteUintList(writer, val)
	Base.WriteList(writer, val.Value, writer.WriteUInt32, 0, "Value", false, 0, nil)
end

function Auto.WriteUnitInfoOnMoveGround(writer, val)
	Base.WritePrimitive(writer, Base.CheckEnum(val.MoveGroundType, 187, 0), writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.MoveGroundId, writer.WriteUInt64, 0)
	Base.WriteStruct(writer, val.LocalPos, Auto.WriteUXVector3, "LocalPos")
	Base.WriteStruct(writer, val.LocalRot, Auto.WriteUXVector3, "LocalRot")
end

function Auto.WriteUploadObjectUrl(writer, val)
	writer:WriteString(val.Url, false, "UploadObjectUrl.Url", 0)
	Base.WritePrimitive(writer, val.ExpireTimeStamp, writer.WriteUInt32, 0)
	writer:WriteString(val.ObjectKey, false, "UploadObjectUrl.ObjectKey", 0)
end

function Auto.WriteUrbanGamePlayResult(writer, val)
	Base.WritePrimitive(writer, Base.CheckEnum(val.PlayType, 238, 0), writer.WriteByte, 0)
	Base.WriteComplex(writer, val.GymPlayResult, Auto.WriteGymPlayResult, "GymPlayResult", true)
	Base.WriteComplex(writer, val.DancePlayResult, Auto.WriteDancePlayResult, "DancePlayResult", true)
	Base.WriteComplex(writer, val.RestaurantResult, Auto.WriteRestaurantResult, "RestaurantResult", true)
end

function Auto.WriteValidateClientNodeServerCommand(writer, val)
	Base.WritePrimitive(writer, val.Nid, writer.WriteUInt32, 0)
	Base.WriteList7Bit(writer, val.Observables, Base.WriteStringWrap(true, "Observables", 0), nil, "Observables", true, 0, nil)
	Base.WriteList7Bit(writer, val.Replicables, Base.WriteStringWrap(true, "Replicables", 0), nil, "Replicables", true, 0, nil)
	Base.WriteList7Bit(writer, val.Messengers, Base.WriteStringWrap(true, "Messengers", 0), nil, "Messengers", true, 0, nil)
	Base.WriteList7Bit(writer, val.SyncReplicables, Base.WriteStringWrap(true, "SyncReplicables", 0), nil, "SyncReplicables", true, 0, nil)
	Base.WritePrimitive(writer, val.RpcId, writer.WriteInt64, 0)
	Base.WritePrimitive(writer, val.HasRpcId, writer.WriteBoolean, false)
end

function Auto.WriteVehicleAICommonParameters(writer, val)
	Base.WritePrimitive(writer, val.FollowPathCheckArrivePointDistance, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.TurnSlowSpeedTemplateId, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.TurnMinAheadSpeed, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.TurnMinAheadDistance, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.TurnMaxAheadSpeed, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.TurnMaxAheadDistance, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.AheadDistanceNormalRatio, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.DummySpeedRatio, writer.WriteSingle, 0)
	Base.WriteComplex(writer, val.StuckCheckConfig, Auto.WriteVehicleStuckCheckConfig, "StuckCheckConfig", false)
	Base.WritePrimitive(writer, Base.CheckEnum(val.VirtualGroundMoveType, 95, 0), writer.WriteByte, 0)
end

function Auto.WriteVehicleAITaskParameters(writer, val)
	Base.WritePrimitive(writer, val.Token, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.taskAIConfigId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.defaultSpeed, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.drivingFlags, writer.WriteInt32, 1)
	Base.WritePrimitive(writer, val.initSpeed, writer.WriteSingle, 0)
	Base.WriteList7Bit(writer, val.initTaskAIBuffList, Base.WriteStructWrap(Auto.WriteTaskVehicleBuffInitInfo, "initTaskAIBuffList"), nil, "initTaskAIBuffList", true, 0, nil)
	Base.WriteStruct(writer, val.commonParameters, Auto.WriteVehicleAICommonParameters, "commonParameters")
end

function Auto.WriteVehicleAnimationBase(writer, val)
	Base.WritePrimitive(writer, val.EntityId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.Pid, writer.WriteUInt64, 0)
end

function Auto.WriteVehicleBlockMove(writer, val)
	Base.WritePrimitive(writer, val.weight, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.blockSpeedMultiplier, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.blockDistance, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.blockCD, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.blockWaitTime, writer.WriteSingle, 0)
end

function Auto.WriteVehicleBlockedByPlayerConditionData(writer, val)
	Base.WritePrimitive(writer, val.VehicleId, writer.WriteUInt64, 0)
end

function Auto.WriteVehicleBrokenCollisionInfo(writer, val)
	Base.WritePrimitive(writer, val.VehicleEntityId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.CurrentHp, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.MaxHp, writer.WriteSingle, 0)
end

function Auto.WriteVehicleClientInfo(writer, val)
	Base.WritePrimitive(writer, val.ControllerPid, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, Base.CheckEnum(val.CreateSourceType, 174, 0), writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.EntityId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.VehicleConfigId, writer.WriteUInt32, 0)
	Base.WriteList7Bit(writer, val.Parts, Base.WriteStructWrap(Auto.WriteVehicleClientPart, "Parts"), nil, "Parts", true, 0, nil)
	Base.WritePrimitive(writer, val.SuitId, writer.WriteUInt32, 0)
	Base.WriteStruct(writer, val.Position, Auto.WriteUXVector3, "Position")
	Base.WritePrimitive(writer, val.Facing, writer.WriteSingle, 0)
	Base.WriteStruct(writer, val.EulerAngles, Auto.WriteUXVector3, "EulerAngles")
	Base.WritePrimitive(writer, val.Velocity, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.IsStatic, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.DeformStatus, writer.WriteInt32, 0)
	Base.WriteList7Bit(writer, val.SeatInfos, Base.WriteComplexWrap(Auto.WriteRaidVehicleSeatInfo, "RaidVehicleSeatInfo", true), nil, "SeatInfos", true, 0, nil)
	Base.WritePrimitive(writer, val.SpoonId, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.IsDynamicGo, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.VehicleEnemyId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.DisableNavigation, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.Interactable, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.MoveToken, writer.WriteInt32, 0)
	writer:WriteString(val.LicensePlate, true, "VehicleClientInfo.LicensePlate", 0)
end

function Auto.WriteVehicleClientPart(writer, val)
	Base.WritePrimitive(writer, val.Type, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.ConfigId, writer.WriteUInt32, 0)
end

function Auto.WriteVehicleCollisionImpulseConditionData(writer, val)
	Base.WritePrimitive(writer, val.VehicleId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.Operation, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.RightFloat, writer.WriteSingle, 0)
end

function Auto.WriteVehicleCollisionRecord(writer, val)
	Base.WritePrimitive(writer, val.Uid, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.CfgId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.Speed, writer.WriteSingle, 0)
	Base.WriteStruct(writer, val.Pos, Auto.WriteUXVector3, "Pos")
	Base.WriteStruct(writer, val.Rot, Auto.WriteUXVector3, "Rot")
end

function Auto.WriteVehicleCollisionUploadData(writer, val)
	Base.WriteStruct(writer, val.SelfRecord, Auto.WriteVehicleCollisionRecord, "SelfRecord")
	Base.WriteStruct(writer, val.OtherRecord, Auto.WriteVehicleCollisionRecord, "OtherRecord")
	Base.WriteStruct(writer, val.CollisionPoint, Auto.WriteUXVector3, "CollisionPoint")
end

function Auto.WriteVehicleComponentStateUpdateInfo(writer, val)
	Base.WritePrimitive(writer, val.UId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, Base.CheckEnum(val.ComponentType, 239, 0), writer.WriteByte, 0)
	Base.WritePrimitive(writer, Base.CheckEnum(val.NewStatus, 240, 0), writer.WriteByte, 0)
end

function Auto.WriteVehicleContactDamageData(writer, val)
	Base.WritePrimitive(writer, val.VehicleMass, writer.WriteSingle, 0)
	Base.WriteList7Bit(writer, val.VehicleVelocities, Base.WriteStructWrap(Auto.WriteUXVector3, "VehicleVelocities"), nil, "VehicleVelocities", false, RpcLengthLimits.VehicleContactDamageData_VehicleVelocities, nil)
	Base.WriteStruct(writer, val.VehicleRelativeVelocity, Auto.WriteUXVector3, "VehicleRelativeVelocity")
	Base.WritePrimitive(writer, val.Layer, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.TouchMass, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.EnemyWeight, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.EnemyRank, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.DisableThreshold, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.OtherVehicleEntityId, writer.WriteUInt64, 0)
end

function Auto.WriteVehicleDangerZone(writer, val)
	Base.WritePrimitive(writer, val.Uid, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.AreaInstanceId, writer.WriteUInt64, 0)
	Base.WriteStruct(writer, val.Center, Auto.WriteUXVector3, "Center")
	Base.WriteStruct(writer, val.Extends, Auto.WriteUXVector3, "Extends")
	Base.WriteStruct(writer, val.Rotation, Auto.WriteUXVector3, "Rotation")
	Base.WritePrimitive(writer, val.Radius, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.Add, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.ObstacleOnly, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.RemoveRadius, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.HideType, writer.WriteInt32, 0)
end

function Auto.WriteVehicleDestructibleData(writer, val)
	Base.WriteComplex(writer, val.VehicleInfo, Auto.WriteVehicleDestructibleInfo, "VehicleInfo", false)
	Base.WritePrimitive(writer, val.SceneItemCfgId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.ReleaserId, writer.WriteUInt64, 0)
	Base.WriteStruct(writer, val.Position, Auto.WriteUXVector3, "Position")
	Base.WriteStruct(writer, val.Facing, Auto.WriteUXVector3, "Facing")
	Base.WritePrimitive(writer, val.LivingTime, writer.WriteSingle, 0)
end

function Auto.WriteVehicleDestructibleInfo(writer, val)
	Base.WritePrimitive(writer, val.VehicleCfgId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.Front, writer.WriteBoolean, false)
end

function Auto.WriteVehicleDestructiblePartStatus(writer, val)
	Base.WritePrimitive(writer, val.partID, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, Base.CheckEnum(val.dmgStatus, 240, 0), writer.WriteByte, 0)
end

function Auto.WriteVehicleDestructiblePartsDamageInfo(writer, val)
	Base.WritePrimitive(writer, val.vehicleUId, writer.WriteUInt64, 0)
	Base.WriteList7Bit(writer, val.damagedGlassList, Base.WriteComplexWrap(Auto.WriteVehicleDestructiblePartStatus, "VehicleDestructiblePartStatus", false), nil, "damagedGlassList", false, RpcLengthLimits.VehicleDestructiblePartsDamageInfo_damagedGlassList, nil)
	Base.WriteList7Bit(writer, val.damagedLightList, Base.WriteComplexWrap(Auto.WriteVehicleDestructiblePartStatus, "VehicleDestructiblePartStatus", false), nil, "damagedLightList", false, RpcLengthLimits.VehicleDestructiblePartsDamageInfo_damagedLightList, nil)
	Base.WriteList7Bit(writer, val.damagedDoorList, Base.WriteComplexWrap(Auto.WriteVehicleDestructiblePartStatus, "VehicleDestructiblePartStatus", false), nil, "damagedDoorList", false, RpcLengthLimits.VehicleDestructiblePartsDamageInfo_damagedDoorList, nil)
end

function Auto.WriteVehicleDriftParameters(writer, val)
	Base.WritePrimitive(writer, val.TotalDuration, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, Base.CheckEnum(val.DriftAction, 241, 0), writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.HandBrakeDuration, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.MaxAngle, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.Token, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.taskAIConfigId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.defaultSpeed, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.drivingFlags, writer.WriteInt32, 1)
	Base.WritePrimitive(writer, val.initSpeed, writer.WriteSingle, 0)
	Base.WriteList7Bit(writer, val.initTaskAIBuffList, Base.WriteStructWrap(Auto.WriteTaskVehicleBuffInitInfo, "initTaskAIBuffList"), nil, "initTaskAIBuffList", true, 0, nil)
	Base.WriteStruct(writer, val.commonParameters, Auto.WriteVehicleAICommonParameters, "commonParameters")
end

function Auto.WriteVehicleEscapeDebugData(writer, val)
	Base.WritePrimitive(writer, val.VehicleUid, writer.WriteUInt64, 0)
	writer:WriteString(val.Status, false, "VehicleEscapeDebugData.Status", 0)
end

function Auto.WriteVehicleForwardEventData(writer, val)
	Base.WritePrimitive(writer, val.VehicleId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.UnitPid, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.PlayerId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, Base.CheckEnum(val.EventType, 242, 0), writer.WriteByte, 0)
	Base.WriteList7Bit(writer, val.Bits, writer.WriteByte, 0, "Bits", false, RpcLengthLimits.VehicleForwardEventData_Bits, nil)
end

function Auto.WriteVehicleGoStraightParameters(writer, val)
	Base.WritePrimitive(writer, val.Duration, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.AutoStop, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.Token, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.taskAIConfigId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.defaultSpeed, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.drivingFlags, writer.WriteInt32, 1)
	Base.WritePrimitive(writer, val.initSpeed, writer.WriteSingle, 0)
	Base.WriteList7Bit(writer, val.initTaskAIBuffList, Base.WriteStructWrap(Auto.WriteTaskVehicleBuffInitInfo, "initTaskAIBuffList"), nil, "initTaskAIBuffList", true, 0, nil)
	Base.WriteStruct(writer, val.commonParameters, Auto.WriteVehicleAICommonParameters, "commonParameters")
end

function Auto.WriteVehicleHackActionParameter(writer, val)
end

function Auto.WriteVehicleHackChaseTargetParameter(writer, val)
	Base.WritePrimitive(writer, val.TargetVehicleEntityId, writer.WriteUInt64, 0)
	Base.WriteList7Bit(writer, val.BuffIdArray, writer.WriteUInt32, 0, "BuffIdArray", true, RpcLengthLimits.VehicleHackChaseTargetParameter_BuffIdArray, nil)
end

function Auto.WriteVehicleHitData(writer, val)
	Base.WritePrimitive(writer, val.VehicleId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.DriverId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.TargetId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.Speed, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.HurtEffectId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.HurtStiffId, writer.WriteUInt32, 0)
	Base.WriteStruct(writer, val.VehicleSpeed, Auto.WriteUXVector3, "VehicleSpeed")
	Base.WriteStruct(writer, val.AgentSpeed, Auto.WriteUXVector3, "AgentSpeed")
end

function Auto.WriteVehicleNavResult(writer, val)
	Base.WritePrimitive(writer, val.NavReqId, writer.WriteUInt32, 0)
	Base.WriteList7Bit(writer, val.Points, Base.WriteStructWrap(Auto.WriteUXVector3, "Points"), nil, "Points", false, 0, nil)
	Base.WriteList7Bit(writer, val.CenterPoints, Base.WriteStructWrap(Auto.WriteUXVector3, "CenterPoints"), nil, "CenterPoints", false, 0, nil)
end

function Auto.WriteVehicleNitroData(writer, val)
	Base.WritePrimitive(writer, val.VehicleId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.NitrogenValue, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.BeginOrEnd, writer.WriteBoolean, false)
end

function Auto.WriteVehiclePartAnimation(writer, val)
	Base.WritePrimitive(writer, val.UnitId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.ConfigId, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.PartIndex, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.Events, writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.Priority, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.EntityId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.Pid, writer.WriteUInt64, 0)
end

function Auto.WriteVehiclePoliceChaseParameters(writer, val)
	Base.WritePrimitive(writer, Base.CheckEnum(val.TargetType, 92, 0), writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.TargetUid, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.Token, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.taskAIConfigId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.defaultSpeed, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.drivingFlags, writer.WriteInt32, 1)
	Base.WritePrimitive(writer, val.initSpeed, writer.WriteSingle, 0)
	Base.WriteList7Bit(writer, val.initTaskAIBuffList, Base.WriteStructWrap(Auto.WriteTaskVehicleBuffInitInfo, "initTaskAIBuffList"), nil, "initTaskAIBuffList", true, 0, nil)
	Base.WriteStruct(writer, val.commonParameters, Auto.WriteVehicleAICommonParameters, "commonParameters")
end

function Auto.WriteVehicleRamMove(writer, val)
	Base.WritePrimitive(writer, val.weight, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.coldDownForOwn, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.coldDownForGroup, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.suitableAngle, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.exitDistance, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.turnTime, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.extrusionTime, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.extrusionMoveDisAtFront, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.regressTime, writer.WriteSingle, 0)
end

function Auto.WriteVehicleRequisitionCommandData(writer, val)
	Base.WritePrimitive(writer, val.VehicleId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.BorrowedSeatIndex, writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.NpcSeatIndex, writer.WriteByte, 0)
	Base.WritePrimitive(writer, Base.CheckEnum(val.DataSource, 97, 0), writer.WriteInt16, 0)
end

function Auto.WriteVehicleRequisitionFailedCommandData(writer, val)
	Base.WritePrimitive(writer, val.VehicleId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.BorrowedSeatIndex, writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.NpcSeatIndex, writer.WriteByte, 0)
	Base.WritePrimitive(writer, Base.CheckEnum(val.DataSource, 97, 0), writer.WriteInt16, 0)
end

function Auto.WriteVehicleSkillDamageData(writer, val)
	Base.WritePrimitive(writer, val.VehicleMass, writer.WriteSingle, 0)
	Base.WriteStruct(writer, val.VehicleVelocity, Auto.WriteUXVector3, "VehicleVelocity")
	Base.WritePrimitive(writer, val.HurtEffectId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.ReleaserId, writer.WriteUInt64, 0)
	Base.WriteStruct(writer, val.HitPoint, Auto.WriteUXVector3, "HitPoint")
end

function Auto.WriteVehicleSpecialPartAnimation(writer, val)
	Base.WritePrimitive(writer, Base.CheckEnum(val.PartType, 243, 0), writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.EntityId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.Pid, writer.WriteUInt64, 0)
end

function Auto.WriteVehicleStuckCheckConfig(writer, val)
	Base.WritePrimitive(writer, val.StuckLevel, writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.RelaxedStuckCheckTime, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.RelaxedStuckCheckCount, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.ModerateStuckCheckCount, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.StrictStuckCheckDistance, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.CheckGoToNextPointStuckTime, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.ResetWhenStuck, writer.WriteBoolean, false)
end

function Auto.WriteVehicleTurnParameters(writer, val)
	Base.WritePrimitive(writer, val.Duration, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, Base.CheckEnum(val.TurnAction, 244, 0), writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.AutoStop, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.Token, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.taskAIConfigId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.defaultSpeed, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.drivingFlags, writer.WriteInt32, 1)
	Base.WritePrimitive(writer, val.initSpeed, writer.WriteSingle, 0)
	Base.WriteList7Bit(writer, val.initTaskAIBuffList, Base.WriteStructWrap(Auto.WriteTaskVehicleBuffInitInfo, "initTaskAIBuffList"), nil, "initTaskAIBuffList", true, 0, nil)
	Base.WriteStruct(writer, val.commonParameters, Auto.WriteVehicleAICommonParameters, "commonParameters")
end

function Auto.WriteVehicleWeaponEquipInfo(writer, val)
	Base.WritePrimitive(writer, val.VehicleUId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.SeatIndex, writer.WriteInt32, 0)
	Base.WriteComplex(writer, val.WeaponDetail, Auto.WriteWeaponDetail, "WeaponDetail", true)
	Base.WritePrimitive(writer, val.ShouldEquip, writer.WriteBoolean, false)
end

function Auto.WriteVisibilityReportData(writer, val)
	Base.WritePrimitive(writer, val.detectorPid, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.detectedPid, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.isVisible, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.isFront, writer.WriteBoolean, false)
end

function Auto.WriteVoteInitData(writer, val)
	Base.WritePrimitive(writer, val.CreaterPid, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.StartTimeMS, writer.WriteUInt32, 0)
end

function Auto.WriteWaitingData(writer, val)
	Base.WriteList7Bit(writer, val.HandTiles, Base.WriteStructWrap(Auto.WriteTile, "HandTiles"), nil, "HandTiles", false, 0, nil)
	Base.WriteList7Bit(writer, val.WaitingTiles, Base.WriteStructWrap(Auto.WriteTile, "WaitingTiles"), nil, "WaitingTiles", false, 0, nil)
end

function Auto.WriteWasherMissionHistoryInfo(writer, val)
	Base.WritePrimitive(writer, val.HistoryMissionCnt, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.HistoryMissionMoney, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.TodayMissionMoney, writer.WriteInt32, 0)
	Base.WriteList(writer, val.HistoryMissionResults, Base.WriteComplexWrap(Auto.WriteWasherMissionResult, "WasherMissionResult", false), nil, "HistoryMissionResults", false, 0, nil)
end

function Auto.WriteWasherMissionHistoryItem(writer, val)
	Base.WritePrimitive(writer, val.Id, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.RandomCfgId, writer.WriteUInt32, 0)
end

function Auto.WriteWasherMissionResult(writer, val)
	Base.WritePrimitive(writer, val.MissionId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.EventId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.Progress, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.RewardRate, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.ProficiencyRate, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.UsingTime, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.AddMoney, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.TalentPointRate, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.RandomCfgId, writer.WriteUInt32, 0)
end

function Auto.WriteWasherParticipantInfo(writer, val)
	Base.WritePrimitive(writer, val.Pid, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.NpcCultivationId, writer.WriteUInt32, 0)
	Base.WriteComplex(writer, val.AIAgentInfo, Auto.WriteLinkAIAgentInfo, "AIAgentInfo", true)
	Base.WritePrimitive(writer, val.AgentInstanceId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.VehicleInstanceId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.SeatIndex, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.IsReady, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.IsPlayAgain, writer.WriteBoolean, false)
end

function Auto.WriteWasherZoneInfo(writer, val)
	writer:WriteString(val.ZoneSessionId, false, "WasherZoneInfo.ZoneSessionId", 0)
	Base.WritePrimitive(writer, val.GadgetUId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.TaskId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, Base.CheckEnum(val.StartReason, 106, 0), writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.GameTypeRandom, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, Base.CheckEnum(val.SyncReason, 107, 0), writer.WriteByte, 0)
	Base.WritePrimitive(writer, Base.CheckEnum(val.ZoneType, 108, 0), writer.WriteByte, 0)
	Base.WritePrimitive(writer, Base.CheckEnum(val.ZoneState, 109, 0), writer.WriteByte, 0)
	Base.WriteList7Bit(writer, val.ParticipantInfos, Base.WriteComplexWrap(Auto.WriteGameGroundParticipantInfo, "GameGroundParticipantInfo", true), nil, "ParticipantInfos", true, 0, nil)
	Base.WriteStruct(writer, val.CountDownInfo, Auto.WriteGameGroundZoneCountDownInfo, "CountDownInfo")
end

function Auto.WriteWatchingInfo(writer, val)
	Base.WritePrimitive(writer, val.Pid, writer.WriteUInt64, 0)
	Base.WriteComplex(writer, val.TaskInfo, Auto.WriteTaskViewData, "TaskInfo", true)
	Base.WriteComplex(writer, val.TaskSpoonViewInfo, Auto.WriteTaskSpoonViewInfo, "TaskSpoonViewInfo", true)
end

function Auto.WriteWeaponBulletDatas(writer, val)
	Base.WritePrimitive(writer, val.BulletId, writer.WriteUInt32, 0)
end

function Auto.WriteWeaponData(writer, val)
	Base.WritePrimitive(writer, val.TemplateId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.Durability, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.InstanceId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.EventId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.ReceivedTimeStamp, writer.WriteDouble, 0)
	Base.WritePrimitive(writer, val.OperatorFlags, writer.WriteUInt32, 0)
	writer:WriteString(val.SpecialLabel, true, "WeaponData.SpecialLabel", 0)
	Base.WriteComplex(writer, val.WeaponFlags, Auto.WriteWeaponDataFlags, "WeaponFlags", false)
	Base.WritePrimitive(writer, val.SceneItemHp, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.StackCount, writer.WriteInt32, 0)
	Base.WriteComplex(writer, val.BulletDatas, Auto.WriteWeaponBulletDatas, "BulletDatas", false)
	Base.WriteList(writer, val.Decorations, Base.WriteComplexWrap(Auto.WriteWeaponDecorationDatas, "WeaponDecorationDatas", false), nil, "Decorations", false, 0, nil)
	Base.WritePrimitive(writer, val.FightStyleId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.MagazineAmmo, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.BindPid, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.IsPlayerLocked, writer.WriteBoolean, false)
	Base.WriteList(writer, val.EnchantSlots, Base.WriteComplexWrap(Auto.WriteWeaponEnchantSlotData, "WeaponEnchantSlotData", false), nil, "EnchantSlots", false, 0, nil)
	Base.WritePrimitive(writer, val.NonDirectionalEnchantCount, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.DirectionalEnchantCountSinceLastNonDir, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.LockedDirectionalEnhancementId, writer.WriteUInt32, 0)
end

function Auto.WriteWeaponEnchantSlotData(writer, val)
	Base.WritePrimitive(writer, val.EnchantConfigId, writer.WriteUInt32, 0)
end

function Auto.WriteWeaponDataFlags(writer, val)
	Base.WritePrimitive(writer, val.IsTaskWheelWeapon, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.ShowRedDot, writer.WriteBoolean, false)
	Base.WriteList(writer, val.AdditionalEffectIds, writer.WriteInt32, 0, "AdditionalEffectIds", true, 0, nil)
end

function Auto.WriteWeaponDecorationDatas(writer, val)
	Base.WritePrimitive(writer, val.ItemId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.DecorationId, writer.WriteUInt32, 0)
end

function Auto.WriteWeaponDetail(writer, val)
	Base.WritePrimitive(writer, val.SourceAgentSpoonId, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.SourceAgentId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.SourceSceneItemId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.IsLocked, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.SourceSceneItemTaskUId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.TemplateId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.Durability, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.InstanceId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.EventId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.ReceivedTimeStamp, writer.WriteDouble, 0)
	Base.WritePrimitive(writer, val.OperatorFlags, writer.WriteUInt32, 0)
	writer:WriteString(val.SpecialLabel, true, "WeaponDetail.SpecialLabel", 0)
	Base.WriteComplex(writer, val.WeaponFlags, Auto.WriteWeaponDataFlags, "WeaponFlags", false)
	Base.WritePrimitive(writer, val.SceneItemHp, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.StackCount, writer.WriteInt32, 0)
	Base.WriteComplex(writer, val.BulletDatas, Auto.WriteWeaponBulletDatas, "BulletDatas", false)
	Base.WriteList(writer, val.Decorations, Base.WriteComplexWrap(Auto.WriteWeaponDecorationDatas, "WeaponDecorationDatas", false), nil, "Decorations", false, 0, nil)
	Base.WritePrimitive(writer, val.FightStyleId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.MagazineAmmo, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.BindPid, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.IsPlayerLocked, writer.WriteBoolean, false)
	Base.WriteList(writer, val.EnchantSlots, Base.WriteComplexWrap(Auto.WriteWeaponEnchantSlotData, "WeaponEnchantSlotData", false), nil, "EnchantSlots", false, 0, nil)
	Base.WritePrimitive(writer, val.NonDirectionalEnchantCount, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.DirectionalEnchantCountSinceLastNonDir, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.LockedDirectionalEnhancementId, writer.WriteUInt32, 0)
end

function Auto.WriteWeaponWheelData(writer, val)
	Base.WritePrimitive(writer, val.WheelId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.EventId, writer.WriteUInt32, 0)
	Base.WriteList7Bit(writer, val.WeaponSlots, Base.WriteComplexWrap(Auto.WriteWeaponDetail, "WeaponDetail", false), nil, "WeaponSlots", false, 0, nil)
	Base.WritePrimitive(writer, val.LockMaxSlotCounts, writer.WriteInt32, 0)
end

function Auto.WriteWearFashionEditInfo(writer, val)
	Base.WritePrimitive(writer, val.FashionId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.Scale, writer.WriteSingle, 0)
	Base.WriteStruct(writer, val.Rotation, Auto.WriteUXVector3, "Rotation")
	Base.WriteStruct(writer, val.Offset, Auto.WriteUXVector3, "Offset")
end

function Auto.WriteWearFashionInfo(writer, val)
	Base.WritePrimitive(writer, val.FashionId, writer.WriteUInt32, 0)
end

function Auto.WriteWearSourceInfo(writer, val)
	Base.WritePrimitive(writer, val.Source, writer.WriteInt16, 0)
	Base.WritePrimitive(writer, val.SourceId, writer.WriteUInt32, 0)
end

function Auto.WriteWebviewLoginTokenInfo(writer, val)
	writer:WriteString(val.Aid, false, "WebviewLoginTokenInfo.Aid", RpcLengthLimits.WebviewLoginTokenInfo_Aid)
	writer:WriteString(val.Username, false, "WebviewLoginTokenInfo.Username", RpcLengthLimits.WebviewLoginTokenInfo_Username)
	writer:WriteString(val.RoleId, false, "WebviewLoginTokenInfo.RoleId", RpcLengthLimits.WebviewLoginTokenInfo_RoleId)
	writer:WriteString(val.RoleName, false, "WebviewLoginTokenInfo.RoleName", RpcLengthLimits.WebviewLoginTokenInfo_RoleName)
	Base.WritePrimitive(writer, val.ServerId, writer.WriteInt32, 0)
	writer:WriteString(val.RoleIcon, false, "WebviewLoginTokenInfo.RoleIcon", RpcLengthLimits.WebviewLoginTokenInfo_RoleIcon)
	Base.WritePrimitive(writer, val.Time, writer.WriteInt32, 0)
	writer:WriteString(val.ActivityName, false, "WebviewLoginTokenInfo.ActivityName", RpcLengthLimits.WebviewLoginTokenInfo_ActivityName)
	writer:WriteString(val.PayloadJson, false, "WebviewLoginTokenInfo.PayloadJson", RpcLengthLimits.WebviewLoginTokenInfo_PayloadJson)
end

function Auto.WriteWeightedRandomItemUInt(writer, val)
	Base.WritePrimitive(writer, val.Value, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.Weight, writer.WriteUInt32, 0)
end

function Auto.WriteWildEnemyGroupInitSyncInfo(writer, val)
	Base.WritePrimitive(writer, val.Time, writer.WriteUInt32, 0)
	Base.WriteList7Bit(writer, val.EnemyInstanceIds, writer.WriteUInt64, 0, "EnemyInstanceIds", false, 0, nil)
end

function Auto.WriteWorkActionNodeInfo(writer, val)
	Base.WritePrimitive(writer, val.NodeId, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.WorkActionIndex, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.Value, writer.WriteInt32, 0)
end

function Auto.WriteWushuTournamentRoundClientInfo(writer, val)
	Base.WritePrimitive(writer, val.RoundId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.BestStars, writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.Choice, writer.WriteUInt32, 0)
end

function Auto.WriteWushuTournamentRoundSettlementInfo(writer, val)
	Base.WritePrimitive(writer, val.RoundId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.Star, writer.WriteByte, 0)
	Base.WriteList7Bit(writer, val.RewardList, writer.WriteUInt32, 0, "RewardList", false, 0, nil)
end

function Auto.WriteWushuTournamentSeasonClientInfo(writer, val)
	Base.WritePrimitive(writer, val.SeasonId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.CurrentRound, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.IsSeasonCleared, writer.WriteBoolean, false)
	Base.WriteList7Bit(writer, val.Rounds, Base.WriteComplexWrap(Auto.WriteWushuTournamentRoundClientInfo, "WushuTournamentRoundClientInfo", false), nil, "Rounds", false, 0, nil)
	Base.WritePrimitive(writer, val.LastChallengeRound, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.LastChallengeChoice, writer.WriteUInt32, 0)
end

function Auto.WriteYachtAttachedEntityInfo(writer, val)
	Base.WriteDict7Bit(writer, val.YachtGadgetHoldersByUniqueId, writer.WriteUInt64, writer.WriteUInt64, 0, "YachtGadgetHoldersByUniqueId", true, 0)
	Base.WriteDict7Bit(writer, val.GadgetsByUniqueId, writer.WriteUInt64, Base.WriteComplexWrap(Auto.WriteGadgetEntityInfo, "GadgetEntityInfo", false), nil, "GadgetsByUniqueId", true, 0)
	Base.WriteDict7Bit(writer, val.YachtDestructibleHoldersByUniqueId, writer.WriteUInt64, writer.WriteUInt64, 0, "YachtDestructibleHoldersByUniqueId", true, 0)
	Base.WriteDict7Bit(writer, val.DestructiblesByUniqueId, writer.WriteUInt64, Base.WriteComplexWrap(Auto.WriteDestructibleInfo, "DestructibleInfo", false), nil, "DestructiblesByUniqueId", true, 0)
end

function Auto.WriteYachtMoveData(writer, val)
	Base.WritePrimitive(writer, val.EntityId, writer.WriteUInt64, 0)
	Base.WriteStruct(writer, val.Position, Auto.WriteUXVector3, "Position")
end

function Auto.WriteYachtSpawnData(writer, val)
	Base.WritePrimitive(writer, val.EntityId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.OwnerId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.CreateTime, writer.WriteDouble, 0)
	Base.WriteComplex(writer, val.AttachedEntities, Auto.WriteYachtAttachedEntityInfo, "AttachedEntities", true)
end

function Auto.WriteYakuValue(writer, val)
	Base.WritePrimitive(writer, Base.CheckEnum(val.Name, 245, 0), writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.Value, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, Base.CheckEnum(val.Type, 246, 0), writer.WriteByte, 0)
end

function Auto.WriteZoneData(writer, val)
	Base.WritePrimitive(writer, val.BoundaryPointsBegin, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.BoundaryPointsEnd, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.LanesBegin, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.LanesEnd, writer.WriteInt32, 0)
	Base.WriteStruct(writer, val.Bounds, Auto.WriteSerializeMinMaxAABB, "Bounds")
	Base.WritePrimitive(writer, val.Tags, writer.WriteInt64, 0)
	Base.WritePrimitive(writer, val.UrbanDiversity, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.StationId, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.ZoneGroupHandle, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.ZoneGroupInternalNumber, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.PointsCount, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.DensityFactor, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.RoadWidth, writer.WriteSingle, 0)
end

function Auto.WriteZoneDataV2(writer, val)
	Base.WritePrimitive(writer, val.BoundaryPointsBegin, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.BoundaryPointsEnd, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.LanesBegin, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.LanesEnd, writer.WriteInt32, 0)
	Base.WriteStruct(writer, val.Bounds, Auto.WriteSerializeMinMaxAABB, "Bounds")
	Base.WritePrimitive(writer, val.Tags, writer.WriteInt64, 0)
	Base.WritePrimitive(writer, val.PointsCount, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.DensityFactor, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.RoadWidth, writer.WriteSingle, 0)
end

function Auto.WriteZoneGraphBVNode(writer, val)
	Base.WritePrimitive(writer, val.MinX, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.MinY, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.MinZ, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.MaxX, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.MaxY, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.MaxZ, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.Index, writer.WriteInt32, 0)
end

function Auto.WriteZoneGraphBVTree(writer, val)
	Base.WriteStruct(writer, val.Origin, Auto.WriteFloat3, "Origin")
	Base.WriteList(writer, val.Nodes, Base.WriteStructWrap(Auto.WriteZoneGraphBVNode, "Nodes"), nil, "Nodes", false, 0, nil)
end

function Auto.WriteZoneGraphLaneLocation(writer, val)
	Base.WriteStruct(writer, val.Position, Auto.WriteFloat3, "Position")
	Base.WriteStruct(writer, val.LanePosition, Auto.WriteFloat3, "LanePosition")
	Base.WriteStruct(writer, val.Direction, Auto.WriteFloat3, "Direction")
	Base.WriteStruct(writer, val.Tangent, Auto.WriteFloat3, "Tangent")
	Base.WriteStruct(writer, val.Up, Auto.WriteFloat3, "Up")
	Base.WritePrimitive(writer, val.LaneHandle, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.LaneSegment, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.DistanceAlongLane, writer.WriteSingle, 0)
	Base.WriteList7Bit(writer, val.ZoneIndexs, writer.WriteInt32, 0, "ZoneIndexs", true, 0, nil)
	Base.WritePrimitive(writer, val.LaneZoneIndex, writer.WriteInt32, 0)
end

function Auto.WriteZoneGraphLaneSection(writer, val)
	Base.WritePrimitive(writer, val.LaneHandle, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.StartDistanceAlongLane, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.EndDistanceAlongLane, writer.WriteSingle, 0)
end

function Auto.WriteZoneGraphLinkedLane(writer, val)
	Base.WritePrimitive(writer, val.DestLane, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.Type, writer.WriteInt64, 0)
	Base.WritePrimitive(writer, val.Flags, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.Weight, writer.WriteSingle, 0)
end

function Auto.WriteZoneGraphPathCommandData(writer, val)
	Base.WritePrimitive(writer, val.ActionId, writer.WriteUInt16, 0)
	Base.WriteList7Bit(writer, val.Points, Base.WriteStructWrap(Auto.WriteClientZoneGraphPathPoint, "Points"), nil, "Points", false, 0, nil)
	Base.WritePrimitive(writer, Base.CheckEnum(val.TargetLocationReason, 129, 0), writer.WriteByte, 0)
	Base.WritePrimitive(writer, Base.CheckEnum(val.DataSource, 97, 0), writer.WriteInt16, 0)
end

function Auto.WriteZoneGraphStorage(writer, val)
	Base.WriteList(writer, val.Zones, Base.WriteComplexWrap(Auto.WriteZoneData, "ZoneData", false), nil, "Zones", false, 0, nil)
	Base.WriteList(writer, val.Lanes, Base.WriteStructWrap(Auto.WriteZoneLaneData, "Lanes"), nil, "Lanes", false, 0, nil)
	Base.WriteList(writer, val.BoundaryPoints, Base.WriteStructWrap(Auto.WriteFloat3, "BoundaryPoints"), nil, "BoundaryPoints", false, 0, nil)
	Base.WriteList(writer, val.LanePoints, Base.WriteStructWrap(Auto.WriteFloat3, "LanePoints"), nil, "LanePoints", false, 0, nil)
	Base.WriteList(writer, val.LaneUpVectors, Base.WriteStructWrap(Auto.WriteFloat3, "LaneUpVectors"), nil, "LaneUpVectors", false, 0, nil)
	Base.WriteList(writer, val.LaneTangentVectors, Base.WriteStructWrap(Auto.WriteFloat3, "LaneTangentVectors"), nil, "LaneTangentVectors", false, 0, nil)
	Base.WriteList(writer, val.LanePointProgressions, writer.WriteSingle, 0, "LanePointProgressions", false, 0, nil)
	Base.WriteList(writer, val.LaneLinks, Base.WriteStructWrap(Auto.WriteZoneLaneLinkData, "LaneLinks"), nil, "LaneLinks", false, 0, nil)
	Base.WriteStruct(writer, val.Bounds, Auto.WriteSerializeMinMaxAABB, "Bounds")
	Base.WriteStruct(writer, val.ZoneBVTree, Auto.WriteZoneGraphBVTree, "ZoneBVTree")
	Base.WritePrimitive(writer, val.DataHandle, writer.WriteInt32, 0)
end

function Auto.WriteZoneGraphStorageV2(writer, val)
	Base.WriteList7Bit(writer, val.Zones, Base.WriteComplexWrap(Auto.WriteZoneDataV2, "ZoneDataV2", false), nil, "Zones", false, 0, nil)
	Base.WriteList7Bit(writer, val.Lanes, Base.WriteStructWrap(Auto.WriteZoneLaneData, "Lanes"), nil, "Lanes", false, 0, nil)
	Base.WriteList7Bit(writer, val.BoundaryPoints, Base.WriteStructWrap(Auto.WriteFloat3, "BoundaryPoints"), nil, "BoundaryPoints", false, 0, nil)
	Base.WriteList7Bit(writer, val.LanePoints, Base.WriteStructWrap(Auto.WriteFloat3, "LanePoints"), nil, "LanePoints", false, 0, nil)
	Base.WriteList7Bit(writer, val.LaneUpVectors, Base.WriteStructWrap(Auto.WriteFloat3, "LaneUpVectors"), nil, "LaneUpVectors", false, 0, nil)
	Base.WriteList7Bit(writer, val.LaneTangentVectors, Base.WriteStructWrap(Auto.WriteFloat3, "LaneTangentVectors"), nil, "LaneTangentVectors", false, 0, nil)
	Base.WriteList7Bit(writer, val.LanePointProgressions, writer.WriteSingle, 0, "LanePointProgressions", false, 0, nil)
	Base.WriteList7Bit(writer, val.LaneLinks, Base.WriteStructWrap(Auto.WriteZoneLaneLinkData, "LaneLinks"), nil, "LaneLinks", false, 0, nil)
	Base.WriteStruct(writer, val.Bounds, Auto.WriteSerializeMinMaxAABB, "Bounds")
	Base.WriteStruct(writer, val.ZoneBVTree, Auto.WriteZoneGraphBVTree, "ZoneBVTree")
	Base.WritePrimitive(writer, val.DataHandle, writer.WriteInt32, 0)
end

function Auto.WriteZoneGraphTagFilter(writer, val)
	Base.WriteStruct(writer, val.AnyTags, Auto.WriteZoneGraphTags, "AnyTags")
	Base.WriteStruct(writer, val.AllTags, Auto.WriteZoneGraphTags, "AllTags")
	Base.WriteStruct(writer, val.NotTags, Auto.WriteZoneGraphTags, "NotTags")
end

function Auto.WriteZoneGraphTags(writer, val)
	Base.WritePrimitive(writer, val.StaticTags, writer.WriteInt64, 0)
	Base.WritePrimitive(writer, val.DynamicTags, writer.WriteInt64, 0)
end

function Auto.WriteZoneLaneData(writer, val)
	Base.WritePrimitive(writer, val.Width, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.Tags, writer.WriteInt64, 0)
	Base.WritePrimitive(writer, val.PointsBegin, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.PointsEnd, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.LinksBegin, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.LinksEnd, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.ZoneIndex, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.StartEntryId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.EndEntryId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.CenterLaneId, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.TurnDirection, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.ConnectionType, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.SourceExtendDistance, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.DestExtendDistance, writer.WriteSingle, 0)
end

function Auto.WriteZoneLaneLinkData(writer, val)
	Base.WritePrimitive(writer, val.DestLaneIndex, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.Type, writer.WriteInt64, 0)
	Base.WritePrimitive(writer, val.Flags, writer.WriteUInt32, 0)
end

function Auto.WriteUXVector3(writer, val)
	if val.X == nil then
		print_error("[RPC] WriteUXVector3 X = nil")

		val.X = 0
	end

	if val.Y == nil then
		print_error("[RPC] WriteUXVector3 Y = nil")

		val.Y = 0
	end

	if val.Z == nil then
		print_error("[RPC] WriteUXVector3 Z = nil")

		val.Z = 0
	end

	Base.WritePrimitive(writer, val.X, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.Y, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.Z, writer.WriteSingle, 0)
end

return Auto
