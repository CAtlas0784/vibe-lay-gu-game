using System.Buffers.Binary;
using System.Text;

namespace Ananta.SDK.Serialization;

public sealed class UxReader
{
    private readonly byte[] _data;
    private int _pos;

    public UxReader(byte[] data) => _data = data;
    public int Position => _pos;
    public int Remaining => _data.Length - _pos;

    public byte U8() => _data[_pos++];
    public bool Bool() => U8() != 0;

    public short I16()
    {
        var v = BinaryPrimitives.ReadInt16LittleEndian(_data.AsSpan(_pos, 2));
        _pos += 2;
        return v;
    }

    public ushort U16()
    {
        var v = BinaryPrimitives.ReadUInt16LittleEndian(_data.AsSpan(_pos, 2));
        _pos += 2;
        return v;
    }

    public int I32()
    {
        var v = BinaryPrimitives.ReadInt32LittleEndian(_data.AsSpan(_pos, 4));
        _pos += 4;
        return v;
    }

    public uint U32()
    {
        var v = BinaryPrimitives.ReadUInt32LittleEndian(_data.AsSpan(_pos, 4));
        _pos += 4;
        return v;
    }

    public long I64()
    {
        var v = BinaryPrimitives.ReadInt64LittleEndian(_data.AsSpan(_pos, 8));
        _pos += 8;
        return v;
    }

    public ulong U64()
    {
        var v = BinaryPrimitives.ReadUInt64LittleEndian(_data.AsSpan(_pos, 8));
        _pos += 8;
        return v;
    }

    public float F32()
    {
        var v = BitConverter.ToSingle(_data, _pos);
        _pos += 4;
        return v;
    }

    public double F64()
    {
        var v = BitConverter.ToDouble(_data, _pos);
        _pos += 8;
        return v;
    }

    public int Int7() => Math.Max(0, ReadVarInt() - 1);

    public string UxString() => UxStringNullable() ?? string.Empty;

    public string? UxStringNullable()
    {
        var lenPlus = ReadVarInt();
        if (lenPlus == 0) return null;
        var len = Math.Max(0, lenPlus - 1);
        if (len > Remaining) throw new InvalidDataException($"UX string length {len} exceeds remaining {Remaining} bytes.");
        var s = Encoding.UTF8.GetString(_data, _pos, len);
        _pos += len;
        return s;
    }

    public byte[] Bytes(int count)
    {
        if (count < 0 || count > Remaining)
            throw new InvalidDataException($"UX buffer length {count} exceeds remaining {Remaining} bytes.");
        var result = _data.AsSpan(_pos, count).ToArray();
        _pos += count;
        return result;
    }

    private int ReadVarInt()
    {
        var shift = 0;
        var result = 0;
        while (_pos < _data.Length)
        {
            var b = _data[_pos++];
            result |= (b & 0x7F) << shift;
            if ((b & 0x80) == 0) break;
            shift += 7;
        }
        return result;
    }
}
