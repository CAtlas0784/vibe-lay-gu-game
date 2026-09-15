using Ananta.SDK.Serialization;

namespace Ananta.Server.Protocol.Client4229938;

/// <summary>
/// Writer for the 4229938 story channel (SyncStoryCoreServerInfo, 68629349) used by
/// the vehicle ride story (S011). Ported from the proven 4091149 codec; command framing
/// (Create=3, Delete=4, ConfirmRpc=2, Enable=6, Validate=9) and payload tags
/// (Bool=5, Int=12, ULong=44) verified against the current dump.cs story classes.
/// 4229938 delta applied: CreateClientNodeServerCommand gained StoryboardGuid
/// (dump TypeDefIndex 69592) — sent as EMPTY string: the Lua writer marks the
/// field non-nullable, so a null marker (0x00) corrupts the whole Create parse
/// client-side and the S011 node is never built (F-enter: 缺少S011PlayerNet节点).
/// Base fields (RpcId, HasRpcId) trail each command, matching the proven layout.
/// </summary>
internal static class StoryS011Codec4229938
{
    internal const string RootType = "StoryServer.Story.World.S011.S011PlayerNet";
    internal const string EnterChildType = "StoryServer.Story.World.S011.SVehicleEnterBoardingNet";
    internal const string ExitChildType = "StoryServer.Story.World.S011.SVehicleExitBoardingNet";

    private static readonly string[] RootMessengers =
    [
        "S011PlayerNetEnterVehicleRequest",
        "S011PlayerNetExitVehicleRequest",
        "S011PlayerNetForceEnterVehicleRequest",
        "S011PlayerNetForceExitVehicleRequest",
        "S011PlayerNetEnterVehicleIndoorRequest",
        "S011PlayerNetExitVehicleIndoorRequest",
        "S011PlayerNetForceShiftSeatRequest",
    ];

    /// <summary>Atomic S011 root bootstrap: Create + Validate + Enable + ConfirmRpc.</summary>
    internal static byte[] BuildRootBootstrap(uint rootNid, long confirmRpcId)
    {
        var w = new UxWriter();
        ListHeader(w, 4);

        Create(w, rootNid, RootType);
        Validate(w, rootNid, messengers: RootMessengers);
        EnableEmpty(w, rootNid);
        ConfirmRpc(w, confirmRpcId);
        return w.ToArray();
    }

    /// <summary>Enter child bootstrap with its three replicables and phase messenger.</summary>
    internal static byte[] BuildEnterChildBootstrap(uint childNid, ulong vehicleId, byte seat)
    {
        var w = new UxWriter();
        ListHeader(w, 3);

        Create(w, childNid, EnterChildType);
        Validate(w, childNid,
            replicables: ["vehicleEntityId", "seatIndex", "requisitionFailed"],
            messengers: ["MsgrChangePhaseRequest"]);

        var enable = new UxWriter();
        ListHeader(enable, 3);
        NamedPayload(enable, "vehicleEntityId", b => { PayloadTag(b, 44); b.U64(vehicleId); });
        NamedPayload(enable, "seatIndex", b => { PayloadTag(b, 12); b.I32(seat); });
        NamedPayload(enable, "requisitionFailed", b => { PayloadTag(b, 5); b.Bool(false); });
        Enable(w, childNid, enable.ToArray());
        return w.ToArray();
    }

    /// <summary>Exit child bootstrap with its four replicables and phase messenger.</summary>
    internal static byte[] BuildExitChildBootstrap(uint childNid, ulong vehicleId, byte seat, bool stopBeforeLeave)
    {
        var w = new UxWriter();
        ListHeader(w, 3);

        Create(w, childNid, ExitChildType);
        Validate(w, childNid,
            replicables: ["vehicleEntityId", "seatIndex", "StopBeforeLeave", "IsEscortExit"],
            messengers: ["MsgrChangePhaseRequest"]);

        var enable = new UxWriter();
        ListHeader(enable, 4);
        NamedPayload(enable, "vehicleEntityId", b => { PayloadTag(b, 44); b.U64(vehicleId); });
        NamedPayload(enable, "seatIndex", b => { PayloadTag(b, 12); b.I32(seat); });
        NamedPayload(enable, "StopBeforeLeave", b => { PayloadTag(b, 5); b.Bool(stopBeforeLeave); });
        NamedPayload(enable, "IsEscortExit", b => { PayloadTag(b, 5); b.Bool(false); });
        Enable(w, childNid, enable.ToArray());
        return w.ToArray();
    }

    /// <summary>ConfirmRpc(tag 2) with the cumulative committed id.</summary>
    internal static byte[] BuildConfirmRpc(long confirmRpcId)
    {
        var w = new UxWriter();
        ListHeader(w, 1);
        ConfirmRpc(w, confirmRpcId);
        return w.ToArray();
    }

    /// <summary>DeleteClientNode(tag 4) for a finished boarding child.</summary>
    internal static byte[] BuildDeleteNode(uint nid)
    {
        var w = new UxWriter();
        ListHeader(w, 1);
        w.U8(4);   // DeleteClientNodeCommand
        w.U32(nid);
        w.I64(0);  // RpcId
        w.Bool(false);
        return w.ToArray();
    }

    private static void Create(UxWriter w, uint nid, string type)
    {
        w.U8(3);   // CreateClientNodeServerCommand
        w.U32(nid);
        w.UxString(type);
        w.UxString(string.Empty); // StoryboardGuid: none for server-made nodes (empty, NOT null)
        w.Bool(false); // Sync
        w.I64(0);      // RpcId
        w.Bool(false); // HasRpcId
    }

    private static void Validate(UxWriter w, uint nid, string[]? observables = null, string[]? replicables = null, string[]? messengers = null, string[]? syncReplicables = null)
    {
        w.U8(9);   // ValidateClientNodeServerCommand
        w.U32(nid);
        StringList(w, observables);
        StringList(w, replicables);
        StringList(w, messengers);
        StringList(w, syncReplicables);
        w.I64(0);
        w.Bool(false);
    }

    private static void EnableEmpty(UxWriter w, uint nid)
    {
        w.U8(6);   // EnableClientNodeCommand
        w.U32(nid);
        w.U8(0);   // Observables: null
        w.U8(0);   // Replicables: null
        w.U8(0);   // SyncReplicables: null
        w.I64(0);
        w.Bool(false);
    }

    private static void Enable(UxWriter w, uint nid, byte[] replicablesBody)
    {
        w.U8(6);
        w.U32(nid);
        w.U8(0);   // Observables: null
        w.Raw(replicablesBody);
        w.U8(0);   // SyncReplicables: null
        w.I64(0);
        w.Bool(false);
    }

    private static void ConfirmRpc(UxWriter w, long confirmRpcId)
    {
        w.U8(2);   // ConfirmRpcServerCommand
        w.I64(confirmRpcId);
        w.I64(0);  // RpcId
        w.Bool(false);
    }

    private static void PayloadTag(UxWriter w, byte tag) => w.U8(tag);

    /// <summary>NamedPayload complex: FF + Name + complex payload (tag byte + fields).</summary>
    private static void NamedPayload(UxWriter w, string name, Action<UxWriter> writePayload)
    {
        w.U8(0xFF);
        w.UxString(name);
        writePayload(w);
    }

    private static void StringList(UxWriter w, string[]? values)
    {
        if (values is null) { w.U8(0); return; }
        w.U8(0xFF);
        WriteCount(w, values.Length);
        foreach (var v in values) w.UxString(v);
    }

    private static void ListHeader(UxWriter w, int count)
    {
        w.U8(0xFF);
        WriteCount(w, count);
    }

    // UxWriter.Int7 already applies the +1 wire bias (reader returns v-1).
    private static void WriteCount(UxWriter w, int count) => w.Int7(count);
}
