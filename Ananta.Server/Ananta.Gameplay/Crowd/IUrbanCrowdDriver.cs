using Ananta.SDK.Network;

namespace Ananta.Server.Gameplay.Crowd;

public interface IUrbanCrowdDriver
{
    Task<(bool Ok, ulong[] EntityIds)> SpawnCrowdPedestriansAsync(
        TcpSession session, uint npcFormworkId, uint poiActionId, float x, float y, float z, float facing);

    (bool HasPlayer, float X, float Y, float Z, float Yaw, uint RaidId) GetPlayerPosition(TcpSession session);
}
