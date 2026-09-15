using System.Buffers.Binary;

namespace Ananta.SDK.Rpc;

public static class RpcPacketWriter
{
    public static byte[] WriteNotify(uint methodId, ReadOnlySpan<byte> body)
    {
        var buffer = new byte[5 + body.Length];
        buffer[0] = 0x03;
        BinaryPrimitives.WriteUInt32LittleEndian(buffer.AsSpan(1, 4), methodId);
        body.CopyTo(buffer.AsSpan(5));
        return buffer;
    }

    public static byte[] WriteReturn(uint methodId, int invokeId, int err, ReadOnlySpan<byte> body)
    {
        var buffer = new byte[13 + body.Length];
        buffer[0] = 0x02;
        BinaryPrimitives.WriteUInt32LittleEndian(buffer.AsSpan(1, 4), methodId);
        BinaryPrimitives.WriteInt32LittleEndian(buffer.AsSpan(5, 4), invokeId);
        BinaryPrimitives.WriteInt32LittleEndian(buffer.AsSpan(9, 4), err);
        body.CopyTo(buffer.AsSpan(13));
        return buffer;
    }
}
