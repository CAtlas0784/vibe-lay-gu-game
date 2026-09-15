namespace Ananta.SDK.Rpc;

public enum RpcPacketKind
{
    Unknown,
    Invoke,
    Notify,
    Return
}

public sealed record RpcPacket(RpcPacketKind Kind, uint MethodId, int InvokeId, byte[] Body);
