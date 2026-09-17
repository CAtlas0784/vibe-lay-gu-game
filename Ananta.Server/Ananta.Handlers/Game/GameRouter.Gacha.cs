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

        var fiveStarSpirits = new uint[] { 15020992, 15020991, 15020997, 15021024, 15021025 };
        var fourStarSpirits = new uint[] { 15020989, 15020990, 15021016, 15021017, 15021020, 15021021, 15021022, 15021023 };
        var topWeapons = new uint[] { 98003001, 98003023, 98003131, 98003184, 98003185 };

        var sync = new SyncGachaDrawInfo
        {
            isGrandPrizeWithAllFillers = false,
            drawDetails = new List<GachaDrawDetail>()
        };

        var records = new List<GachaDrawRecord>();
        var rng = Random.Shared;

        for (uint i = 0; i < count; i++)
        {
            bool isGuaranteedFiveStar = (count >= 10 && i == count - 1) || (rng.Next(100) < 15);
            bool isFourStar = !isGuaranteedFiveStar && (rng.Next(100) < 45);

            uint prizeId;
            if (isGuaranteedFiveStar)
            {
                prizeId = fiveStarSpirits[rng.Next(fiveStarSpirits.Length)];
            }
            else if (isFourStar)
            {
                prizeId = fourStarSpirits[rng.Next(fourStarSpirits.Length)];
            }
            else
            {
                prizeId = topWeapons[rng.Next(topWeapons.Length)];
            }

            sync.drawDetails.Add(new GachaDrawDetail
            {
                PoolContentId = prizeId,
                IsGrandPrize = isGuaranteedFiveStar,
                IsConverted = false,
                IsNew = true
            });

            records.Add(new GachaDrawRecord
            {
                GachaId = poolId,
                PoolContentId = prizeId,
                DropId = prizeId,
                DrawTimeUnix = DateTimeOffset.UtcNow.ToUnixTimeSeconds()
            });
        }

        await conn.NotifyAsync(MethodId.SyncGachaDrawInfo, sync);

        var gachaInfos = new PlayerGachaInfos();
        var poolInfo = new PlayerGachaPoolInfo
        {
            DrawCount = count,
            DrawRecords = records
        };
        gachaInfos.PoolInfos[poolId] = poolInfo;
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
