using Ananta.SDK.Logging;
using Ananta.SDK.Network;

namespace Ananta.SDK.Rpc;

public sealed class RpcRouter
{
    private readonly Dictionary<uint, IRpcHandler> _invokeHandlers = new();
    private readonly Dictionary<uint, INotifyHandler> _notifyHandlers = new();
    private readonly ServerLogger _log;
    private readonly Dictionary<uint, string> _methodNames = new();
    private Func<RpcContext, Task>? _unknownInvokeHandler;
    private Func<RpcContext, Task>? _unknownNotifyHandler;

    public RpcRouter(string scope) => _log = new ServerLogger($"router:{scope}");

    public RpcRouter Name(uint methodId, string name)
    {
        // MethodId dump contains a few aliases with the same numeric id. Keep the first
        // canonical name instead of letting a later *_0 alias make logs harder to read.
        _methodNames.TryAdd(methodId, name);
        RpcMethodNames.Register(methodId, name);
        return this;
    }

    private string Display(uint methodId)
        => _methodNames.TryGetValue(methodId, out var name) ? $"{name} [0x{methodId:X8}]" : $"0x{methodId:X8}";

    /// <summary>
    /// Build-specific compatibility fallback for invokes that are known to the client but do not
    /// yet have a semantic private-server implementation.  The callback must return a body that
    /// matches the exact return reader for that client build; this avoids the old zero-byte/nil
    /// fallback which crashes strict generated Lua/C# callbacks.
    /// </summary>
    public RpcRouter OnUnknownInvoke(Func<RpcContext, Task> handler)
    {
        _unknownInvokeHandler = handler ?? throw new ArgumentNullException(nameof(handler));
        return this;
    }

    public RpcRouter OnUnknownNotify(Func<RpcContext, Task> handler)
    {
        _unknownNotifyHandler = handler ?? throw new ArgumentNullException(nameof(handler));
        return this;
    }

    public RpcRouter Add(IRpcHandler handler)
    {
        if (!_invokeHandlers.TryAdd(handler.MethodId, handler))
            throw new InvalidOperationException($"Duplicate invoke handler for {Display(handler.MethodId)}");
        return this;
    }

    public RpcRouter Add(INotifyHandler handler)
    {
        if (!_notifyHandlers.TryAdd(handler.MethodId, handler))
            throw new InvalidOperationException($"Duplicate notify handler for {Display(handler.MethodId)}");
        return this;
    }

    public async Task DispatchAsync(TcpSession session, Frame frame, CancellationToken token)
    {
        RpcPacket packet;
        try
        {
            packet = RpcPacketReader.Parse(frame.Payload);
        }
        catch
        {
            RuntimeLogs.RawFrame(session.Log.Scope, "C2S", frame.Mode, frame.Payload, "RPC_PARSE_FAILED");
            throw;
        }

        var ctx = new RpcContext(session, packet, token);
        RuntimeLogs.Incoming(
            session.Log.Scope,
            packet.Kind == RpcPacketKind.Invoke ? RpcPacketKindView.Invoke :
            packet.Kind == RpcPacketKind.Notify ? RpcPacketKindView.Notify : RpcPacketKindView.Return,
            packet.MethodId, packet.InvokeId, packet.Body);

        try
        {
            if (packet.Kind == RpcPacketKind.Invoke)
            {
                session.Log.Info($"-> rpc {Display(packet.MethodId)} #{packet.InvokeId} {packet.Body.Length}b");
                if (_invokeHandlers.TryGetValue(packet.MethodId, out var handler))
                {
                    await handler.HandleAsync(ctx);
                    return;
                }

                if (_unknownInvokeHandler is not null)
                {
                    await _unknownInvokeHandler(ctx);
                    return;
                }

                session.Log.Warn($"unknown rpc {Display(packet.MethodId)} -> empty OK");
                await ctx.ReturnEmptyOkAsync();
                return;
            }

            if (packet.Kind == RpcPacketKind.Notify)
            {
                session.Log.Info($"-> ntf {Display(packet.MethodId)} {packet.Body.Length}b");
                if (_notifyHandlers.TryGetValue(packet.MethodId, out var handler))
                {
                    await handler.HandleAsync(ctx);
                    return;
                }

                if (_unknownNotifyHandler is not null)
                {
                    await _unknownNotifyHandler(ctx);
                    return;
                }

                session.Log.Warn($"unknown ntf {Display(packet.MethodId)} ignored");
                return;
            }

            session.Log.Warn($"Unknown rpc packet raw={Convert.ToHexString(frame.Payload)}");
        }
        catch (Exception ex)
        {
            session.Log.Error($"handler failed method={Display(packet.MethodId)}", ex);
            if (packet.Kind == RpcPacketKind.Invoke)
            {
                if (_unknownInvokeHandler is not null)
                    await _unknownInvokeHandler(ctx);
                else
                    await ctx.ReturnEmptyOkAsync();
            }
        }
    }
}
