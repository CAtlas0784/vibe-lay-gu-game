using System.Buffers.Binary;

namespace Ananta.SDK.Rpc;

public static class RpcPacketReader
{
    public static RpcPacket Parse(ReadOnlySpan<byte> payload)
    {
        if (payload.Length < 5)
            return new RpcPacket(RpcPacketKind.Unknown, 0, 0, payload.ToArray());

        var tag = payload[0];
        var methodId = BinaryPrimitives.ReadUInt32LittleEndian(payload[1..5]);

        if (tag == 0x03)
        {
            return new RpcPacket(RpcPacketKind.Notify, methodId, 0, payload[5..].ToArray());
        }

        if (tag == 0x01 && payload.Length >= 9)
        {
            var invokeId = BinaryPrimitives.ReadInt32LittleEndian(payload[5..9]);
            return new RpcPacket(RpcPacketKind.Invoke, methodId, invokeId, payload[9..].ToArray());
        }

        if (tag == 0x02 && payload.Length >= 13)
        {
            var invokeId = BinaryPrimitives.ReadInt32LittleEndian(payload[5..9]);
            return new RpcPacket(RpcPacketKind.Return, methodId, invokeId, payload[13..].ToArray());
        }

        return new RpcPacket(RpcPacketKind.Unknown, methodId, 0, payload.ToArray());
    }
}
