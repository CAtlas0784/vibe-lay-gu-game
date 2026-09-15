using Ananta.Server.RpcTypes.Client4229938;
using SceneMethods = Ananta.Server.RpcTypes.Client4229938.Methods.GameScene;

namespace Ananta.Server.Protocol.Client4229938;

/// <summary>
/// Typed factories for world/game-scene messages. The wire layout itself lives in Ananta.RpcTypes.
/// Large world/profile packets are built as RpcTypes DTOs by RuntimePayloadFactory and serialized on the fly.
/// </summary>
internal static class WorldCodec
{
    internal static SceneMethods.SyncLogicAgentEnter LogicAgentEnter(ulong agentId)
        => new() { agentId = agentId };

    internal static SceneMethods.SyncLogicAgentLeave LogicAgentLeave(ulong agentId)
        => new() { agentId = agentId };

    internal static SceneMethods.SyncManagedLogicAgent ManagedLogicAgent(ulong agentId, ulong pid, byte moveId = 0)
        => new() { agentId = agentId, pid = pid, moveId = moveId };

    internal static SceneMethods.SyncPlayerCurrentSpirit CurrentSpirit()
        => CurrentSpirit(Profile.PlayerPid, Profile.InitialSpiritTemplateId, Profile.InitialUnitId);

    internal static SceneMethods.SyncPlayerCurrentSpirit CurrentSpirit(ulong playerPid, uint templateId, ulong spiritId, bool isAgentSwitch = false)
        => new()
        {
            playerPid = playerPid,
            templateId = templateId,
            spiritId = spiritId,
            isAgentSwitch = isAgentSwitch
        };

    internal static SceneMethods.SyncSwitchSpiritConfigId SwitchSpiritConfigId(
        uint configId, Vec3 position, IReadOnlyCollection<ulong>? spawnedAgentIds = null)
        => new()
        {
            configId = configId,
            position = new SceneMethods.UxVector3(position.X, position.Y, position.Z),
            spawnedAgentIds = spawnedAgentIds?.ToList() ?? []
        };

    internal static SceneMethods.SyncPreSwitchSpirit PreSwitchSpirit(uint configId, uint newTemplateId, Vec3 position)
        => new()
        {
            configId = configId,
            newTemplateId = newTemplateId,
            position = new SceneMethods.UxVector3(position.X, position.Y, position.Z)
        };

    internal static SceneMethods.SyncPlayerLoadRate PlayerLoadRate(double rate = 1.0)
        => new() { playerPid = Profile.PlayerPid, rate = rate };

    internal static SceneMethods.SyncSceneLoadCompleted SceneLoadCompleted(ulong sceneId)
        => new() { sceneId = sceneId };

    internal static SceneMethods.SyncUnitPositionAndFacing PositionAndFacing(ulong unitId, Vec3 position, float facing, byte setPositionType = 3)
        => new()
        {
            unitId = unitId,
            position = new SceneMethods.UxVector3(position.X, position.Y, position.Z),
            facing = facing,
            moveId = 0,
            continueMove = false,
            setPositionType = setPositionType,
            moveGroundInfo = null,
            loadingInfo = null,
        };

    internal static SceneMethods.SyncUnitPositionAndFacing PositionAndFacing(Vec3 position, float facing, byte setPositionType = 3)
        => PositionAndFacing(Profile.InitialUnitId, position, facing, setPositionType);

    internal static SceneMethods.SyncUnitPositionP PositionP(ulong unitId, Vec3 position, float facing, byte setPositionType = 3)
        => new()
        {
            unitId = unitId,
            position = new SceneMethods.UxVector3(position.X, position.Y, position.Z),
            facing = facing,
            moveId = 0,
            setPositionType = setPositionType
        };

    internal static SceneMethods.SyncUnitPositionP PositionP(Vec3 position, float facing, byte setPositionType = 3)
        => PositionP(Profile.InitialUnitId, position, facing, setPositionType);

    internal static SceneMethods.SyncGamePause GamePause(bool pause)
        => new() { pause = pause };

    internal static SceneMethods.SyncEntityActionGroup EntityActionGroup(ulong unitId, uint actionGroupId = 1u)
        => new() { unitId = unitId, actionGroupId = actionGroupId };

    internal static SceneMethods.SyncAllSpiritCombatPower AllSpiritCombatPower(uint templateId, float combatPower = 1000f)
        => new() { combatPower = new Dictionary<uint, float> { [templateId] = combatPower } };

    internal static SceneMethods.SyncAllSpiritCombatPower AllSpiritCombatPower(params uint[] templateIds)
    {
        var body = new SceneMethods.SyncAllSpiritCombatPower();
        foreach (var templateId in templateIds)
            body.combatPower[templateId] = 1000f;
        return body;
    }

    internal static SceneMethods.SyncChangeSkill SkillBinding(ulong spiritId, uint skillId)
        => new()
        {
            spiritId = spiritId,
            skillId = skillId,
            duration = skillId == 0 ? 0f : 99999f
        };

    internal static SceneMethods.SyncUnitBuffList UnitBuffList(ulong unitId, IReadOnlyList<uint> buffIds, uint firstInstanceId)
    {
        var body = new SceneMethods.SyncUnitBuffList { entityId = unitId };
        // 4229938 still evaluates ExpireTime inside several client-side BuffActions even when
        // Permanent=true. ExpireTime=0 becomes a huge negative remaining time and can execute
        // teardown paths immediately. Use a real far-future unix timestamp for persistent state.
        var persistentExpiry = DateTimeOffset.UtcNow.ToUnixTimeSeconds() + 315_360_000d;
        var instanceId = firstInstanceId;
        foreach (var buffId in buffIds)
        {
            body.buffs.Add(new SceneMethods.BuffViewData
            {
                InstanceId = instanceId++,
                Id = buffId,
                ReleaserId = unitId,
                ExpireTime = persistentExpiry,
                Tier = 1,
                Permanent = true,
                DestructibleId = 0
            });
        }
        return body;
    }

    internal static SceneMethods.SyncUnitAddBuff UnitAddBuff(ulong unitId, uint buffId, uint instanceId)
        => new()
        {
            entityId = unitId,
            buff = new SceneMethods.BuffViewData
            {
                InstanceId = instanceId,
                Id = buffId,
                ReleaserId = unitId,
                ExpireTime = DateTimeOffset.UtcNow.ToUnixTimeSeconds() + 315_360_000d,
                Tier = 1,
                Permanent = true,
                DestructibleId = 0
            }
        };

    internal static SceneMethods.SyncUnitRemoveBuff UnitRemoveBuff(ulong unitId, uint buffInstanceId)
        => new() { entityId = unitId, buffInstanceId = buffInstanceId };

    internal static SceneMethods.SyncUnitStates UnitStates(ulong unitId, params uint[] states)
        => new() { unitId = unitId, states = states?.ToList(), effectFreezeState = 0 };

    internal static SceneMethods.SyncUnitStates UnitStates(params uint[] states)
        => UnitStates(Profile.InitialUnitId, states);

    internal static SceneMethods.SyncRemoveUnitState RemoveUnitState(ulong unitId, uint state)
        => new() { unitId = unitId, state = state, reason = 1, sourceId = 0 };

    internal static SceneMethods.SyncRemoveUnitState RemoveUnitState(uint state)
        => RemoveUnitState(Profile.InitialUnitId, state);
}
