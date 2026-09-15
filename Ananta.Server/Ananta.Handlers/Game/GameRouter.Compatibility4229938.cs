using Ananta.SDK.Rpc;
using Ananta.Server.Protocol.Client4229938;

namespace Ananta.Server.Handlers.Game;

/// <summary>
/// Build-4229938 RPC-surface compatibility.  Semantic handlers still win.  Any other Invoke uses
/// the exact generated return reader shape from the matching client Lua so callbacks receive a
/// valid default value (empty list/dict, zero primitive, empty string, or non-null empty object)
/// instead of a zero-byte body.
/// </summary>
internal sealed partial class GameRouter
{
    private Task DefaultUnknownInvoke4229938(RpcContext ctx)
    {
        if (DefaultReturnCatalog4229938.TryGet(ctx.MethodId, out var body, out var shape))
        {
            ctx.Session.Log.Warn($"[RPC4229938] unimplemented {Ananta.SDK.Logging.RpcMethodNames.Display(ctx.MethodId)} -> typed-default {shape} {body.Length}b");
            return ctx.ReturnAsync(body);
        }

        ctx.Session.Log.Warn($"[RPC4229938] no generated return reader for {Ananta.SDK.Logging.RpcMethodNames.Display(ctx.MethodId)} -> empty OK");
        return ctx.ReturnEmptyOkAsync();
    }

    private Task DefaultUnknownNotify4229938(RpcContext ctx)
    {
        // Notifies have no callback body. Accepting an unimplemented generated 4229938 notify is
        // safer than treating it as a protocol error; stateful methods get semantic handlers as
        // they are implemented, while telemetry/client-local signals remain harmless no-ops.
        ctx.Session.Log.Warn($"[RPC4229938] unimplemented notify {Ananta.SDK.Logging.RpcMethodNames.Display(ctx.MethodId)} -> accepted");
        return Task.CompletedTask;
    }

    // High-frequency/UI RPCs seen in stock 4229938 are made explicit so they no longer appear as
    // unknown traffic.  The server does not emulate production economy/social services here; it
    // returns the exact neutral value expected by the generated client callback.
    [Handler(MethodId.AskTradeGetMarketList, HandlerPacketKind.Invoke)]
    [Handler(MethodId.AskTradeGetHistoryPage, HandlerPacketKind.Invoke)]
    [Handler(MethodId.AskPlayerRankingSummary, HandlerPacketKind.Invoke)]
    [Handler(MethodId.AskPopularityPhoneFirstOpened, HandlerPacketKind.Invoke)]
    [Handler(MethodId.AskPopularityUIOpened, HandlerPacketKind.Invoke)]
    [Handler(MethodId.SyncOpenInspireHub, HandlerPacketKind.Invoke)]
    [Handler(MethodId.AskQueryInspireHubAllGamePlayRecommendData, HandlerPacketKind.Invoke)]
    [Handler(MethodId.AskQueryInspireHubAllGamePlayRankData, HandlerPacketKind.Invoke)]
    [Handler(MethodId.AskLinkInfos, HandlerPacketKind.Invoke)]
    [Handler(MethodId.GetLastMode, HandlerPacketKind.Invoke)]
    [Handler(MethodId.AskSwitchLinkMode, HandlerPacketKind.Invoke)]
    private Task KnownNeutralInvoke4229938(Connection conn, UxRpcMessage msg)
    {
        if (DefaultReturnCatalog4229938.TryGet(msg.MethodId, out var body, out var shape))
        {
            conn.Log.Info($"[RPC4229938] neutral {Ananta.SDK.Logging.RpcMethodNames.Display(msg.MethodId)} -> {shape} {body.Length}b");
            return msg.Context.ReturnAsync(body);
        }
        return conn.ReturnEmptyOkAsync(msg);
    }

    [Handler(MethodId.OnParkourStateChange, HandlerPacketKind.Invoke)]
    private Task OnParkourStateChange4229938(Connection conn, UxRpcMessage msg)
        => conn.ReturnEmptyOkAsync(msg);
}
