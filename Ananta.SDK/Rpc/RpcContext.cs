using Ananta.SDK.Logging;
using Ananta.SDK.Network;
using Ananta.SDK.Serialization;

namespace Ananta.SDK.Rpc;

public sealed class RpcContext
{
    public TcpSession Session { get; }
    public RpcPacket Packet { get; }
    public CancellationToken CancellationToken { get; }

    public uint MethodId => Packet.MethodId;
    public int InvokeId => Packet.InvokeId;
    public byte[] Body => Packet.Body;

    public RpcContext(TcpSession session, RpcPacket packet, CancellationToken cancellationToken)
    {
        Session = session;
        Packet = packet;
        CancellationToken = cancellationToken;
    }

    public Task ReturnAsync(byte[] body, int err = 0)
        => Session.ReturnAsync(MethodId, InvokeId, err, body, CancellationToken);

    public Task ReturnEmptyOkAsync()
        => ReturnAsync(Array.Empty<byte>());

    public Task ReturnAsync<T>(T body, int err = 0)
    {
        var bytes = UxSerializer.Serialize(body);
        var send = ReturnAsync(bytes, err);
        RuntimeLogs.Decoded(Session.Log.Scope, "S2C", MethodId, typeof(T), body);
        return send;
    }

    public Task NotifyAsync(uint methodId, byte[] body)
        => Session.NotifyAsync(methodId, body, CancellationToken);

    public Task NotifyAsync<T>(uint methodId, T body)
    {
        var bytes = UxSerializer.Serialize(body);
        var send = NotifyAsync(methodId, bytes);
        RuntimeLogs.Decoded(Session.Log.Scope, "S2C", methodId, typeof(T), body);
        return send;
    }
}
