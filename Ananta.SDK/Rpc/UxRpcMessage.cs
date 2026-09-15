using Ananta.SDK.Serialization;

using Ananta.SDK.Logging;

namespace Ananta.SDK.Rpc;

/// <summary>A parsed UX RPC message exposed to attribute handlers.</summary>
public sealed class UxRpcMessage
{
    public RpcContext Context { get; }
    public RpcPacketKind Kind => Context.Packet.Kind;
    public uint MethodId => Context.MethodId;
    public int InvokeId => Context.InvokeId;
    public byte[] Body => Context.Body;
    public bool IsInvoke => Kind == RpcPacketKind.Invoke;
    public bool IsNotify => Kind == RpcPacketKind.Notify;

    internal UxRpcMessage(RpcContext context) => Context = context;

    public T GetArgs<T>()
    {
        var value = UxSerializer.Deserialize<T>(Body);
        RuntimeLogs.Decoded(Context.Session.Log.Scope, "C2S", MethodId, typeof(T), value);
        return value;
    }

    public bool TryGetArgs<T>(out T value)
    {
        try
        {
            value = GetArgs<T>();
            return true;
        }
        catch
        {
            value = default!;
            return false;
        }
    }
}
