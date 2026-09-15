using Ananta.SDK.Network;
using Ananta.SDK.Rpc;
using Ananta.Server.Protocol.Client4229938;
using Ananta.Server.RpcTypes.Client4229938.Auto;
using Ananta.Server.RpcTypes.Client4229938.Methods.Game;

namespace Ananta.Server.Handlers.Game;

internal sealed partial class GameRouter
{
    [Handler(MethodId.AskDrawGacha, HandlerPacketKind.Invoke)]
    private async Task AskDrawGacha(Connection conn, UxRpcMessage msg)
    {
        var args = msg.GetArgs<AskDrawGachaArgs>();
        uint poolId = args.gachaPoolId == 0 ? 1001u : args.gachaPoolId;
        uint count = args.drawCount == 0 ? 1u : args.drawCount;

        conn.Session.Log.Info($"[GACHA] AskDrawGacha: poolId={poolId} count={count} autoEx={args.isAutoExchange}");

        var sync = new SyncGachaDrawInfo
        {
            isGrandPrizeWithAllFillers = false,
            drawDetails = new List<GachaDrawDetail>()
        };

        for (uint i = 0; i < count; i++)
        {
            sync.drawDetails.Add(new GachaDrawDetail
            {
                PoolContentId = poolId,
                IsGrandPrize = (i == count - 1),
                IsConverted = false,
                IsNew = true
            });
        }

        await conn.NotifyAsync(MethodId.SyncGachaDrawInfo, sync);

        var gachaInfos = new PlayerGachaInfos();
        gachaInfos.PoolInfos[poolId] = new PlayerGachaPoolInfo
        {
            DrawCount = count
        };
        gachaInfos.GroupInfos[poolId] = new PlayerGachaGroupInfo
        {
            TotalDrawCount = count
        };
        gachaInfos.PityInfos[poolId] = new PlayerGachaPityInfo
        {
            TotalDrawCount = count,
            DrawsSinceLastReset = count % 80
        };

        await conn.ReturnAsync(msg, gachaInfos);
    }

    [Handler(MethodId.AskClaimGachaMilestone, HandlerPacketKind.Invoke)]
    private Task AskClaimGachaMilestone(Connection conn, UxRpcMessage msg)
    {
        var args = msg.GetArgs<AskClaimGachaMilestoneArgs>();
        conn.Session.Log.Info($"[GACHA] AskClaimGachaMilestone: groupId={args.groupId} count={args.milestoneCount}");
        return conn.ReturnEmptyOkAsync(msg);
    }

    [Handler(MethodId.AskChaosMasterGacha, HandlerPacketKind.Invoke)]
    private Task AskChaosMasterGacha(Connection conn, UxRpcMessage msg)
    {
        conn.Session.Log.Info("[GACHA] AskChaosMasterGacha invoke");
        return conn.ReturnAsync(msg, new List<uint>());
    }
}
