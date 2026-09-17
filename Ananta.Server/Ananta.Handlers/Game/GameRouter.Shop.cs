using Ananta.SDK.Network;
using Ananta.SDK.Rpc;
using Ananta.Server.Protocol.Client4229938;

namespace Ananta.Server.Handlers.Game;

internal sealed partial class GameRouter
{
    [Handler(MethodId.AskNpcShopCommodityInfo, HandlerPacketKind.Invoke)]
    private Task AskNpcShopCommodityInfo(Connection conn, UxRpcMessage msg)
    {
        conn.Log.Info("[SHOP] AskNpcShopCommodityInfo invoke");
        return conn.ReturnEmptyOkAsync(msg);
    }

    [Handler(MethodId.AskReadCommodities, HandlerPacketKind.Invoke)]
    private Task AskReadCommodities(Connection conn, UxRpcMessage msg)
    {
        conn.Log.Info("[SHOP] AskReadCommodities invoke");
        return conn.ReturnEmptyOkAsync(msg);
    }

    [Handler(MethodId.AskBuyCommodity, HandlerPacketKind.Invoke)]
    private Task AskBuyCommodity(Connection conn, UxRpcMessage msg)
    {
        conn.Log.Info("[SHOP] AskBuyCommodity invoke");
        return conn.ReturnEmptyOkAsync(msg);
    }

    [Handler(MethodId.AskBuyCommodities, HandlerPacketKind.Invoke)]
    private Task AskBuyCommodities(Connection conn, UxRpcMessage msg)
    {
        conn.Log.Info("[SHOP] AskBuyCommodities invoke");
        return conn.ReturnEmptyOkAsync(msg);
    }

    [Handler(MethodId.AskBuyCommodityToBag, HandlerPacketKind.Invoke)]
    private Task AskBuyCommodityToBag(Connection conn, UxRpcMessage msg)
    {
        conn.Log.Info("[SHOP] AskBuyCommodityToBag invoke");
        return conn.ReturnEmptyOkAsync(msg);
    }

    [Handler(MethodId.AskBuyCommoditiesToBag, HandlerPacketKind.Invoke)]
    private Task AskBuyCommoditiesToBag(Connection conn, UxRpcMessage msg)
    {
        conn.Log.Info("[SHOP] AskBuyCommoditiesToBag invoke");
        return conn.ReturnEmptyOkAsync(msg);
    }
}
