using Ananta.SDK.Network;
using Ananta.SDK.Serialization;
using Ananta.Server.Gameplay.Crowd;
using Ananta.Server.Gameplay.Traffic;
using Ananta.Server.Protocol.Client4229938;
using Ananta.Server.RpcTypes.Client4229938;
using SceneMethods = Ananta.Server.RpcTypes.Client4229938.Methods.GameScene;

namespace Ananta.Server.Handlers.Game;

internal sealed class TrafficAndCrowdDriver : ITrafficVehicleDriver, IUrbanCrowdDriver
{
    public static TrafficAndCrowdDriver Instance { get; } = new();

    public async Task<(bool Ok, ulong EntityId)> SpawnTrafficVehicleAsync(
        TcpSession session, uint configId, float x, float y, float z, float yaw)
    {
        var result = await GameRouter.SpawnDirectAsync(
            session, configId, new Vec3(x, y, z), yaw, rightOffset: 0f, sourceType: 2, reason: "city-traffic");
        return (result.Ok, result.EntityId);
    }

    public async Task DestroyTrafficVehicleAsync(TcpSession session, ulong entityId)
    {
        await GameRouter.DestroyDirectAsync(session, entityId, "traffic-despawn");
    }

    private readonly System.Collections.Concurrent.ConcurrentDictionary<ulong, int> _moveTokens = new();

    public async Task SendVehicleMoveAsync(
        TcpSession session, ulong entityId, float x, float y, float z, float yaw, float vx, float vz)
    {
        var token = _moveTokens.AddOrUpdate(entityId, 1, (_, cur) => unchecked(cur + 1));
        var moveData = new SceneMethods.RaidVehicleSyncData
        {
            Id = entityId,
            Position = new SceneMethods.UxVector3(x, y, z),
            FacingDirection = yaw,
            EulerAngles = new SceneMethods.UxVector3(0f, yaw, 0f),
            Velocity = new SceneMethods.UxVector3(vx, 0f, vz),
            Bits = [1, 0, 0, 0],
            MoveToken = token,
        };
        await session.NotifyAsync(MethodId.SyncVehicleMove, UxSerializer.Serialize(moveData), CancellationToken.None);
        GameRouter.TrackVehicleMove(entityId, x, y, z, yaw);
    }

    public bool IsVehiclePlayerControlled(ulong entityId)
    {
        return GameRouter.TryGetSummoned(entityId, out var summoned) && summoned?.ControllerPid != 0;
    }

    public (bool HasPlayer, float X, float Y, float Z, float Yaw, uint RaidId) GetPlayerPosition(TcpSession session)
    {
        var state = GameRouter.GetStateIfExists(session);
        if (state is null)
            return (false, 0, 0, 0, 0, 0);

        lock (state.SyncRoot)
        {
            if (!state.Ready || !state.HasLastReportedPlayerTransform)
                return (false, 0, 0, 0, 0, 0);

            var pos = state.LastReportedPlayerPosition;
            var rot = state.LastReportedPlayerRotation;
            return (true, pos.X, pos.Y, pos.Z, rot.Y, state.ActiveRaidId);
        }
    }

    public async Task<(bool Ok, ulong[] EntityIds)> SpawnCrowdPedestriansAsync(
        TcpSession session, uint npcFormworkId, uint poiActionId, float x, float y, float z, float facing)
    {
        var result = await GameRouter.SpawnStaticNpcAtAsync(session, npcFormworkId, poiActionId, x, y, z, facing);
        return (result.Ok, result.Ids);
    }

    public async Task DespawnCrowdPedestrianAsync(TcpSession session, ulong entityId)
    {
        await session.NotifyAsync(MethodId.SyncLogicAgentLeave,
            UxSerializer.Serialize(WorldCodec.LogicAgentLeave(entityId)), CancellationToken.None);
        session.Log.Info($"[CROWD] despawn pedestrian entity={entityId}");
    }

    public async Task SendPedestrianMoveAsync(
        TcpSession session, ulong entityId, float x, float y, float z, float facing, byte moveId)
    {
        var packet = WorldCodec.PositionAndFacing(
            entityId, new Vec3(x, y, z), facing, WorldCodec.SetPositionType.Gm, continueMove: true, moveId: moveId);
        await session.NotifyAsync(MethodId.SyncUnitPositionAndFacing, UxSerializer.Serialize(packet), CancellationToken.None);
    }
}
