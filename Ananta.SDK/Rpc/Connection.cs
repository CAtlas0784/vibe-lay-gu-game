using Ananta.SDK.Logging;
using Ananta.SDK.Network;
using Ananta.SDK.Serialization;

namespace Ananta.SDK.Rpc;

/// <summary>
/// Small handler-facing wrapper around TcpSession. Prefer typed Return/Notify overloads;
/// Raw methods exist only for packets whose contract has not been described yet.
/// </summary>
public sealed class Connection
{
    private readonly TcpSession _session;
    private readonly CancellationToken _token;

    internal Connection(TcpSession session, CancellationToken token)
    {
        _session = session;
        _token = token;
    }

    public ServerLogger Log => _session.Log;
    public TcpSession Session => _session;

    public Task ReturnEmptyOkAsync(UxRpcMessage request)
        => ReturnEmptyAsync(request);

    public Task ReturnEmptyAsync(UxRpcMessage request, int error = 0)
        => request.IsInvoke
            ? _session.ReturnAsync(request.MethodId, request.InvokeId, error, Array.Empty<byte>(), _token)
            : Task.CompletedTask;

    public Task ReturnAsync<T>(UxRpcMessage request, T body, int error = 0)
    {
        if (!request.IsInvoke) return Task.CompletedTask;
        var bytes = UxSerializer.Serialize(body);
        var send = _session.ReturnAsync(request.MethodId, request.InvokeId, error, bytes, _token);
        RuntimeLogs.Decoded(_session.Log.Scope, "S2C", request.MethodId, typeof(T), body);
        return send;
    }

    public Task ReturnRawAsync(UxRpcMessage request, byte[] body, int error = 0)
        => request.IsInvoke
            ? _session.ReturnAsync(request.MethodId, request.InvokeId, error, body, _token)
            : Task.CompletedTask;

    public Task NotifyAsync<T>(uint methodId, T body)
    {
        var bytes = UxSerializer.Serialize(body);
        var send = _session.NotifyAsync(methodId, bytes, _token);
        RuntimeLogs.Decoded(_session.Log.Scope, "S2C", methodId, typeof(T), body);
        return send;
    }

    public Task NotifyRawAsync(uint methodId, byte[] body)
        => _session.NotifyAsync(methodId, body, _token);
}
