using System.Collections;
using System.Collections.Concurrent;
using System.Reflection;

namespace Ananta.SDK.Serialization;

/// <summary>
/// Marks a class/struct as a UX RPC contract. Inline contracts do not emit an object marker.
/// TypeMark is used by the few polymorphic 4229938 contracts whose complex marker is a concrete
/// type discriminator (for example WeaponData uses 1 instead of the normal 0xFF marker).
/// </summary>
[AttributeUsage(AttributeTargets.Class | AttributeTargets.Struct)]
public sealed class UxContractAttribute : Attribute
{
    public bool Inline { get; set; }
    public byte TypeMark { get; set; } = 0xFF;
}

public enum UxCountEncoding
{
    Int32,
    Int7
}

public enum UxObjectEncoding
{
    Auto,
    Complex,
    Struct
}

/// <summary>Overrides object framing for one field when the same client type is used both as a struct and complex.</summary>
[AttributeUsage(AttributeTargets.Field)]
public sealed class UxObjectAttribute : Attribute
{
    public UxObjectEncoding Encoding { get; set; } = UxObjectEncoding.Auto;
}

/// <summary>Overrides list/dictionary count encoding and nested object framing.</summary>
[AttributeUsage(AttributeTargets.Field)]
public sealed class UxCollectionAttribute : Attribute
{
    public UxCountEncoding Count { get; set; } = UxCountEncoding.Int7;
    public UxObjectEncoding ItemObjectEncoding { get; set; } = UxObjectEncoding.Auto;
    public UxObjectEncoding ValueObjectEncoding { get; set; } = UxObjectEncoding.Auto;
}

/// <summary>UX byte buffers are nullable complex values with either Int32 or biased 7-bit lengths.</summary>
[AttributeUsage(AttributeTargets.Field)]
public sealed class UxBufferAttribute : Attribute
{
    public UxCountEncoding Count { get; set; } = UxCountEncoding.Int7;
}

/// <summary>
/// Reflection serializer for dump-shaped RPC DTOs. Public fields are serialized by declaration order,
/// allowing RpcTypes to be read side-by-side with RPCSerializeAuto.lua / the IL2CPP dump.
/// </summary>
public static class UxSerializer
{
    public static byte[] Serialize<T>(T value)
    {
        var writer = new UxWriter();
        WriteValue(writer, typeof(T), value, null, UxObjectEncoding.Auto);
        return writer.ToArray();
    }

    public static T Deserialize<T>(ReadOnlySpan<byte> body)
    {
        var reader = new UxReader(body.ToArray());
        var value = ReadValue(reader, typeof(T), null, UxObjectEncoding.Auto);
        return value is null ? default! : (T)value;
    }

    private static void WriteValue(
        UxWriter writer,
        Type type,
        object? value,
        FieldInfo? field,
        UxObjectEncoding objectEncoding)
    {
        if (type == typeof(byte)) { writer.U8(value is null ? (byte)0 : (byte)value); return; }
        if (type == typeof(sbyte)) { writer.U8(unchecked((byte)(value is null ? (sbyte)0 : (sbyte)value))); return; }
        if (type == typeof(bool)) { writer.Bool(value is not null && (bool)value); return; }
        if (type == typeof(short)) { writer.I16(value is null ? (short)0 : (short)value); return; }
        if (type == typeof(ushort)) { writer.U16(value is null ? (ushort)0 : (ushort)value); return; }
        if (type == typeof(int)) { writer.I32(value is null ? 0 : (int)value); return; }
        if (type == typeof(uint)) { writer.U32(value is null ? 0u : (uint)value); return; }
        if (type == typeof(long)) { writer.I64(value is null ? 0L : (long)value); return; }
        if (type == typeof(ulong)) { writer.U64(value is null ? 0UL : (ulong)value); return; }
        if (type == typeof(float)) { writer.F32(value is null ? 0f : (float)value); return; }
        if (type == typeof(double)) { writer.F64(value is null ? 0d : (double)value); return; }
        if (type == typeof(string)) { writer.UxString((string?)value); return; }

        // byte[] is a UX buffer, not a normal List<byte>.
        if (type == typeof(byte[]))
        {
            WriteBuffer(writer, (byte[]?)value, field);
            return;
        }

        if (type.IsEnum)
        {
            var underlying = Enum.GetUnderlyingType(type);
            WriteValue(
                writer,
                underlying,
                value is null ? Activator.CreateInstance(underlying) : Convert.ChangeType(value, underlying),
                field,
                UxObjectEncoding.Auto);
            return;
        }

        if (type.IsArray)
        {
            var collection = (IList?)value;
            WriteList(writer, type.GetElementType()!, collection, field);
            return;
        }

        if (type.IsGenericType)
        {
            var generic = type.GetGenericTypeDefinition();
            if (generic == typeof(List<>))
            {
                WriteList(writer, type.GetGenericArguments()[0], (IList?)value, field);
                return;
            }

            if (generic == typeof(Dictionary<,>))
            {
                WriteDictionary(writer, type, (IDictionary?)value, field);
                return;
            }
        }

        var contract = type.GetCustomAttribute<UxContractAttribute>();
        if (contract is null)
            throw new NotSupportedException($"{type.FullName} is not a UX contract. Add [UxContract].");

        var effectiveEncoding = objectEncoding;
        if (effectiveEncoding == UxObjectEncoding.Auto)
            effectiveEncoding = contract.Inline ? UxObjectEncoding.Struct : UxObjectEncoding.Complex;

        if (effectiveEncoding == UxObjectEncoding.Complex)
        {
            if (value is null) { writer.U8(0x00); return; }
            writer.U8(contract.TypeMark);
        }
        else if (value is null)
        {
            // WriteStruct(nullable=false) falls back to a zero/default value in the real client.
            value = Activator.CreateInstance(type, nonPublic: true);
        }

        foreach (var f in PublicFields(type))
        {
            var fieldEncoding = f.GetCustomAttribute<UxObjectAttribute>()?.Encoding ?? UxObjectEncoding.Auto;
            WriteValue(writer, f.FieldType, f.GetValue(value), f, fieldEncoding);
        }
    }

    private static object? ReadValue(
        UxReader reader,
        Type type,
        FieldInfo? field,
        UxObjectEncoding objectEncoding)
    {
        if (type == typeof(byte)) return reader.U8();
        if (type == typeof(sbyte)) return unchecked((sbyte)reader.U8());
        if (type == typeof(bool)) return reader.Bool();
        if (type == typeof(short)) return reader.I16();
        if (type == typeof(ushort)) return reader.U16();
        if (type == typeof(int)) return reader.I32();
        if (type == typeof(uint)) return reader.U32();
        if (type == typeof(long)) return reader.I64();
        if (type == typeof(ulong)) return reader.U64();
        if (type == typeof(float)) return reader.F32();
        if (type == typeof(double)) return reader.F64();
        if (type == typeof(string)) return reader.UxStringNullable();
        if (type == typeof(byte[])) return ReadBuffer(reader, field);

        if (type.IsEnum)
            return Enum.ToObject(type, ReadValue(reader, Enum.GetUnderlyingType(type), field, UxObjectEncoding.Auto)!);

        if (type.IsArray)
        {
            var list = ReadList(reader, type.GetElementType()!, field);
            if (list is null) return null;
            var array = Array.CreateInstance(type.GetElementType()!, list.Count);
            list.CopyTo(array, 0);
            return array;
        }

        if (type.IsGenericType)
        {
            var generic = type.GetGenericTypeDefinition();
            if (generic == typeof(List<>)) return ReadList(reader, type.GetGenericArguments()[0], field, type);
            if (generic == typeof(Dictionary<,>)) return ReadDictionary(reader, type, field);
        }

        var contract = type.GetCustomAttribute<UxContractAttribute>();
        if (contract is null)
            throw new NotSupportedException($"{type.FullName} is not a UX contract. Add [UxContract].");

        var effectiveEncoding = objectEncoding;
        if (effectiveEncoding == UxObjectEncoding.Auto)
            effectiveEncoding = contract.Inline ? UxObjectEncoding.Struct : UxObjectEncoding.Complex;

        if (effectiveEncoding == UxObjectEncoding.Complex && reader.U8() == 0x00)
            return null;

        var obj = Activator.CreateInstance(type, nonPublic: true)
                  ?? throw new InvalidOperationException($"Cannot create {type.FullName}");
        foreach (var f in PublicFields(type))
        {
            var fieldEncoding = f.GetCustomAttribute<UxObjectAttribute>()?.Encoding ?? UxObjectEncoding.Auto;
            f.SetValue(obj, ReadValue(reader, f.FieldType, f, fieldEncoding));
        }
        return obj;
    }

    private static void WriteBuffer(UxWriter writer, byte[]? data, FieldInfo? field)
    {
        if (data is null) { writer.U8(0x00); return; }
        writer.U8(0xFF);
        var encoding = field?.GetCustomAttribute<UxBufferAttribute>()?.Count ?? UxCountEncoding.Int7;
        if (encoding == UxCountEncoding.Int7) writer.Int7(data.Length); else writer.I32(data.Length);
        writer.Raw(data);
    }

    private static byte[]? ReadBuffer(UxReader reader, FieldInfo? field)
    {
        if (reader.U8() == 0x00) return null;
        var encoding = field?.GetCustomAttribute<UxBufferAttribute>()?.Count ?? UxCountEncoding.Int7;
        var count = encoding == UxCountEncoding.Int7 ? reader.Int7() : reader.I32();
        return reader.Bytes(count);
    }

    private static void WriteList(UxWriter writer, Type itemType, IList? list, FieldInfo? field)
    {
        if (list is null) { writer.U8(0x00); return; }
        writer.U8(0xFF);
        WriteCount(writer, list.Count, field);
        var itemEncoding = field?.GetCustomAttribute<UxCollectionAttribute>()?.ItemObjectEncoding ?? UxObjectEncoding.Auto;
        foreach (var item in list)
            WriteValue(writer, itemType, item, null, itemEncoding);
    }

    private static IList? ReadList(UxReader reader, Type itemType, FieldInfo? field, Type? concreteType = null)
    {
        if (reader.U8() == 0x00) return null;
        var count = ReadCount(reader, field);
        var listType = concreteType ?? typeof(List<>).MakeGenericType(itemType);
        var list = (IList)(Activator.CreateInstance(listType) ?? throw new InvalidOperationException($"Cannot create {listType}"));
        var itemEncoding = field?.GetCustomAttribute<UxCollectionAttribute>()?.ItemObjectEncoding ?? UxObjectEncoding.Auto;
        for (var i = 0; i < count; i++) list.Add(ReadValue(reader, itemType, null, itemEncoding));
        return list;
    }

    private static void WriteDictionary(UxWriter writer, Type dictType, IDictionary? dict, FieldInfo? field)
    {
        if (dict is null) { writer.U8(0x00); return; }
        writer.U8(0xFF);
        WriteCount(writer, dict.Count, field, defaultEncoding: UxCountEncoding.Int32);
        var args = dictType.GetGenericArguments();
        var valueEncoding = field?.GetCustomAttribute<UxCollectionAttribute>()?.ValueObjectEncoding ?? UxObjectEncoding.Auto;
        foreach (DictionaryEntry item in dict)
        {
            WriteValue(writer, args[0], item.Key, null, UxObjectEncoding.Auto);
            WriteValue(writer, args[1], item.Value, null, valueEncoding);
        }
    }

    private static object? ReadDictionary(UxReader reader, Type dictType, FieldInfo? field)
    {
        if (reader.U8() == 0x00) return null;
        var count = ReadCount(reader, field, defaultEncoding: UxCountEncoding.Int32);
        var dict = (IDictionary)(Activator.CreateInstance(dictType) ?? throw new InvalidOperationException($"Cannot create {dictType}"));
        var args = dictType.GetGenericArguments();
        var valueEncoding = field?.GetCustomAttribute<UxCollectionAttribute>()?.ValueObjectEncoding ?? UxObjectEncoding.Auto;
        for (var i = 0; i < count; i++)
            dict.Add(
                ReadValue(reader, args[0], null, UxObjectEncoding.Auto)!,
                ReadValue(reader, args[1], null, valueEncoding));
        return dict;
    }

    private static void WriteCount(UxWriter writer, int count, FieldInfo? field, UxCountEncoding defaultEncoding = UxCountEncoding.Int7)
    {
        var encoding = field?.GetCustomAttribute<UxCollectionAttribute>()?.Count ?? defaultEncoding;
        if (encoding == UxCountEncoding.Int7) writer.Int7(count); else writer.I32(count);
    }

    private static int ReadCount(UxReader reader, FieldInfo? field, UxCountEncoding defaultEncoding = UxCountEncoding.Int7)
    {
        var encoding = field?.GetCustomAttribute<UxCollectionAttribute>()?.Count ?? defaultEncoding;
        return encoding == UxCountEncoding.Int7 ? reader.Int7() : reader.I32();
    }

    private static readonly ConcurrentDictionary<Type, FieldInfo[]> FieldCache = new();

    private static FieldInfo[] PublicFields(Type type)
        => FieldCache.GetOrAdd(type, static t =>
            t.GetFields(BindingFlags.Instance | BindingFlags.Public)
                .OrderBy(f => f.MetadataToken)
                .ToArray());
}
