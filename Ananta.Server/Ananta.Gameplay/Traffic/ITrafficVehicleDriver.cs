using Ananta.SDK.Network;

namespace Ananta.Server.Gameplay.Traffic;

public interface ITrafficVehicleDriver
{
    Task<(bool Ok, ulong EntityId)> SpawnTrafficVehicleAsync(
        TcpSession session, uint configId, float x, float y, float z, float yaw);

    Task DestroyTrafficVehicleAsync(
        TcpSession session, ulong entityId);

    Task SendVehicleMoveAsync(
        TcpSession session, ulong entityId, float x, float y, float z, float yaw, float vx, float vz);

    bool IsVehiclePlayerControlled(ulong entityId);

    (bool HasPlayer, float X, float Y, float Z, float Yaw, uint RaidId) GetPlayerPosition(TcpSession session);
}
