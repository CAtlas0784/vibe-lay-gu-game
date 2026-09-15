using System.Buffers.Binary;
using System.Text;

namespace Ananta.SDK.Serialization;

public sealed class UxWriter
{
    private readonly MemoryStream _ms = new();

    public UxWriter U8(byte value) { _ms.WriteByte(value); return this; }
    public UxWriter Bool(bool value) { _ms.WriteByte(value ? (byte)1 : (byte)0); return this; }
    public UxWriter I16(short value) { Span<byte> b = stackalloc byte[2]; BinaryPrimitives.WriteInt16LittleEndian(b, value); _ms.Write(b); return this; }
    public UxWriter U16(ushort value) { Span<byte> b = stackalloc byte[2]; BinaryPrimitives.WriteUInt16LittleEndian(b, value); _ms.Write(b); return this; }
    public UxWriter I32(int value) { Span<byte> b = stackalloc byte[4]; BinaryPrimitives.WriteInt32LittleEndian(b, value); _ms.Write(b); return this; }
    public UxWriter U32(uint value) { Span<byte> b = stackalloc byte[4]; BinaryPrimitives.WriteUInt32LittleEndian(b, value); _ms.Write(b); return this; }
    public UxWriter I64(long value) { Span<byte> b = stackalloc byte[8]; BinaryPrimitives.WriteInt64LittleEndian(b, value); _ms.Write(b); return this; }
    public UxWriter U64(ulong value) { Span<byte> b = stackalloc byte[8]; BinaryPrimitives.WriteUInt64LittleEndian(b, value); _ms.Write(b); return this; }
    public UxWriter F32(float value) { var b = BitConverter.GetBytes(value); _ms.Write(b); return this; }
    public UxWriter F64(double value) { var b = BitConverter.GetBytes(value); _ms.Write(b); return this; }

    public UxWriter UxString(string? value)
    {
        if (value is null)
        {
            _ms.WriteByte(0x00);
            return this;
        }

        var utf8 = Encoding.UTF8.GetBytes(value);
        WriteVarInt(utf8.Length + 1);
        _ms.Write(utf8);
        return this;
    }

    public UxWriter Raw(ReadOnlySpan<byte> bytes) { _ms.Write(bytes); return this; }

    // Matches client UXBinaryWriter.Write7BitEncodedInt exactly: the client
    // increments the logical value before emitting the unsigned 7-bit varint.
    // Its reader decodes the varint and subtracts one.
    public UxWriter Int7(int value)
    {
        if (value < 0) throw new ArgumentOutOfRangeException(nameof(value));
        WriteVarInt(checked(value + 1));
        return this;
    }

    public byte[] ToArray() => _ms.ToArray();

    private void WriteVarInt(int value)
    {
        uint v = (uint)value;
        while (v >= 0x80)
        {
            _ms.WriteByte((byte)(v | 0x80));
            v >>= 7;
        }
        _ms.WriteByte((byte)v);
    }
}
