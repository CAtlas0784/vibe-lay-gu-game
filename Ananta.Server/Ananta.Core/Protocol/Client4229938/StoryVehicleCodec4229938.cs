using Ananta.SDK.Serialization;

namespace Ananta.Server.Protocol.Client4229938;

/// <summary>One parsed StoryClientCommand from the C2S story channel.</summary>
internal sealed record StoryClientCommand4229938(
    byte TypeMark,
    uint Nid,
    string Name,
    long RpcId,
    bool HasRpcId,
    string? PayloadKind,
    ulong? PayloadVehicleId,
    List<byte>? PayloadSeatIndices,
    bool? PayloadBool,
    long? PayloadInt,
    ulong? PayloadULong);

/// <summary>
/// Parser for the 4229938 story channel (SyncStoryCoreClientInfo, 67130745):
/// an inline List7Bit of complex StoryClientCommand entries.
/// Command marks: ConfirmRpc 2, Message 4, SetObservable-shaped 5, reliable RpcId-only 3/6.
/// Payload marks: Bool 5, Byte 6, Int 12, S011EnterVehicleRequest 35 (NOT 36 — V2's value
/// is from another build; proven live 2026-09-09: hex ...-23-<u64>-FF-03-<seats>),
/// S011VehicleAndSeat 37, ULong 44. Shapes verified against dump.cs (StoryClientCommand base,
/// payload V fields, S011EnterVehicleRequestPayload{VehicleId, SeatIndices}, S011VehicleAndSeatPayload).
/// An unknown command or payload aborts that message's parse; the prefix is still returned.
/// </summary>
internal static class StoryVehicleCodec4229938
{
    internal static IReadOnlyList<StoryClientCommand4229938> Parse(ReadOnlySpan<byte> body, out bool fullyConsumed)
    {
        var commands = new List<StoryClientCommand4229938>();
        var reader = new UxReader(body.ToArray());
        fullyConsumed = false;

        try
        {
            // Nullable list framing: 0x00 = null, 0xFF + Int7 count + items.
            if (reader.U8() == 0x00)
            {
                fullyConsumed = true;
                return commands;
            }

            int count = reader.Int7();
            for (int i = 0; i < count; i++)
            {
                byte mark = reader.U8();
                if (mark == 0x00)
                    continue;

                switch (mark)
                {
                    case 2: // ConfirmRpcCommand { ConfirmRpcId i64, RpcId i64, HasRpcId bool }
                    {
                        long confirmRpcId = reader.I64();
                        (long rpcId, bool hasRpcId) = ParseCommandBase(reader);
                        commands.Add(new StoryClientCommand4229938(2, 0, "ConfirmRpc", rpcId, hasRpcId, "Confirm", (ulong)confirmRpcId, null, null, null, null));
                        break;
                    }

                    case 4: // MessageCommand { Nid u32, Name string, Value StoryNetPayload, RpcId, HasRpcId }
                    {
                        uint nid = reader.U32();
                        string name = reader.UxStringNullable() ?? string.Empty;
                        var payload = ParsePayload(reader);
                        (long rpcId, bool hasRpcId) = ParseCommandBase(reader);
                        commands.Add(new StoryClientCommand4229938(4, nid, name, rpcId, hasRpcId,
                            payload.Kind, payload.VehicleId, payload.SeatIndices, payload.Bool, payload.Int, payload.ULong));
                        break;
                    }

                    case 5: // { Nid u32, Name string, Value StoryNetPayload, RpcId, HasRpcId }
                    {
                        uint nid = reader.U32();
                        string name = reader.UxStringNullable() ?? string.Empty;
                        var payload = ParsePayload(reader);
                        (long rpcId, bool hasRpcId) = ParseCommandBase(reader);
                        commands.Add(new StoryClientCommand4229938(5, nid, name, rpcId, hasRpcId,
                            payload.Kind, payload.VehicleId, payload.SeatIndices, payload.Bool, payload.Int, payload.ULong));
                        break;
                    }

                    case 3:
                    case 6: // { RpcId i64, HasRpcId bool }
                    {
                        (long rpcId, bool hasRpcId) = ParseCommandBase(reader);
                        commands.Add(new StoryClientCommand4229938(mark, 0, mark == 3 ? "Rpc3" : "Rpc6", rpcId, hasRpcId, null, null, null, null, null, null));
                        break;
                    }

                    default:
                        return commands;
                }
            }

            fullyConsumed = true;
            return commands;
        }
        catch (Exception)
        {
            return commands;
        }
    }

    private static (long RpcId, bool HasRpcId) ParseCommandBase(UxReader reader)
        => (reader.I64(), reader.Bool());

    private static (string Kind, ulong? VehicleId, List<byte>? SeatIndices, bool? Bool, long? Int, ulong? ULong) ParsePayload(UxReader reader)
    {
        byte mark = reader.U8();
        switch (mark)
        {
            case 5: // BoolPayload { V bool }
                return ("Bool", null, null, reader.Bool(), null, null);
            case 6: // BytePayload { V byte } - S011 boarding phases arrive in this shape
                return ("Byte", null, null, null, reader.U8(), null);
            case 12: // IntPayload { V i32 }
                return ("Int", null, null, null, reader.I32(), null);
            case 44: // ULongPayload { V u64 }
                return ("ULong", null, null, null, null, reader.U64());
            case 35: // S011EnterVehicleRequestPayload { VehicleId u64, SeatIndices byte[]? }
            case 36: // same shape under V2's build; kept for tolerance
            {
                ulong vehicleId = reader.U64();
                List<byte>? seats = null;
                if (reader.U8() != 0x00)
                {
                    int n = reader.Int7();
                    seats = new List<byte>(n);
                    for (int i = 0; i < n; i++) seats.Add(reader.U8());
                }
                return ("S011EnterVehicleRequest", vehicleId, seats, null, null, null);
            }
            case 37: // S011VehicleAndSeatPayload { VehicleId u64, SeatIndex byte }
            {
                ulong vehicleId = reader.U64();
                byte seat = reader.U8();
                return ("S011VehicleAndSeat", vehicleId, [seat], null, null, null);
            }
            default:
                throw new InvalidDataException($"unknown StoryNetPayload type mark {mark}");
        }
    }
}
