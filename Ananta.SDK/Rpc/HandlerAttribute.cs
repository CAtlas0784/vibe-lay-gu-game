namespace Ananta.SDK.Rpc;

public enum HandlerPacketKind
{
    Both,
    Invoke,
    Notify
}

/// <summary>
/// Declares an incoming RPC endpoint. Method ids stay build-specific constants; the dispatcher is generic.
/// By default a handler accepts both invoke and notify forms. Return helpers are safe no-ops for notifications.
/// </summary>
[AttributeUsage(AttributeTargets.Method, AllowMultiple = true, Inherited = false)]
public sealed class HandlerAttribute : Attribute
{
    public uint MethodId { get; }
    public HandlerPacketKind PacketKind { get; }

    public HandlerAttribute(uint methodId, HandlerPacketKind packetKind = HandlerPacketKind.Both)
    {
        MethodId = methodId;
        PacketKind = packetKind;
    }
}
