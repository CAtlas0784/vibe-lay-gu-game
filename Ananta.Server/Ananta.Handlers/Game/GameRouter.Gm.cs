using Ananta.SDK.Rpc;
using Ananta.Server.Protocol.Client4229938;
using SceneMethods = Ananta.Server.RpcTypes.Client4229938.Methods.GameScene;

namespace Ananta.Server.Handlers.Game;

/// <summary>
/// Private-server GM surface (build 4229938): the in-game GM console (ALT+F1) sends these
/// C2S invokes. Strategy is return-real-ids-first: the client spawns GM entities locally
/// (GM invoke call sites ignore the return), the server records the ids so the debug
/// panel can manage them. If a command proves to wait for a server broadcast, the push
/// (SyncLogicVehicleEnter etc.) gets added for that command.
/// </summary>
internal sealed partial class GameRouter
{
    private static long _gmEntitySeq = 320000000000L;
    private static long _gmEnemySeq = 330000000000L;

    [Handler(MethodId.GmSpawnVehicle, HandlerPacketKind.Invoke)]
    private Task GmSpawnVehicle(Connection conn, UxRpcMessage msg)
    {
        var args = msg.GetArgs<SceneMethods.GmSpawnVehicle>();
        var entityId = (ulong)Interlocked.Increment(ref _gmEntitySeq);
        RegisterSummoned(entityId, args.TemplateId, args.Position.X, args.Position.Y, args.Position.Z, args.Facing);
        conn.Log.Info($"[GM] spawn vehicle cfg={args.TemplateId} suit={args.SuitId} own={args.LoadOwnVehicle} spoon='{args.SpoonName}' at=({args.Position.X:F1},{args.Position.Y:F1},{args.Position.Z:F1}) -> entity={entityId}");
        return conn.ReturnAsync(msg, entityId);
    }

    [Handler(MethodId.GmAddEnemyWithPosition, HandlerPacketKind.Invoke)]
    private Task GmAddEnemyWithPosition(Connection conn, UxRpcMessage msg)
    {
        var args = msg.GetArgs<SceneMethods.GmAddEnemyWithPosition>();
        var entityId = (ulong)Interlocked.Increment(ref _gmEnemySeq);
        conn.Log.Info($"[GM] add enemy id={args.EnemyId} camp={args.Camp} nav={args.NavTagType} at=({args.Position.X:F1},{args.Position.Y:F1},{args.Position.Z:F1}) -> entity={entityId}");
        return conn.ReturnAsync(msg, entityId);
    }

    [Handler(MethodId.GmAddEnemy, HandlerPacketKind.Invoke)]
    private Task GmAddEnemy(Connection conn, UxRpcMessage msg)
    {
        var args = msg.GetArgs<SceneMethods.GmAddEnemy>();
        var entityId = (ulong)Interlocked.Increment(ref _gmEnemySeq);
        conn.Log.Info($"[GM] add enemy id={args.EnemyId} camp={args.Camp} tree='{args.TreeName}' -> entity={entityId}");
        return conn.ReturnAsync(msg, entityId);
    }

    [Handler(MethodId.GmAddEnemyByPlayer, HandlerPacketKind.Invoke)]
    private Task GmAddEnemyByPlayer(Connection conn, UxRpcMessage msg)
    {
        var args = msg.GetArgs<SceneMethods.GmAddEnemyByPlayer>();
        var entityId = (ulong)Interlocked.Increment(ref _gmEnemySeq);
        conn.Log.Info($"[GM] add enemy by player id={args.EnemyId} camp={args.Camp} -> entity={entityId}");
        return conn.ReturnAsync(msg, entityId);
    }

    [Handler(MethodId.GmTeleportXYZ, HandlerPacketKind.Invoke)]
    private Task GmTeleportXYZ(Connection conn, UxRpcMessage msg)
    {
        var args = msg.GetArgs<SceneMethods.GmTeleportXYZ>();
        conn.Log.Info($"[GM] teleport to=({args.X:F1},{args.Y:F1},{args.Z:F1}) facing={args.Facing:F1} (client-side, accepted)");
        return conn.ReturnEmptyOkAsync(msg);
    }

    [Handler(MethodId.DavinciCode, HandlerPacketKind.Notify)]
    private static void DavinciCode(Connection conn, UxRpcMessage msg)
    {
        conn.Log.Info("[SECURITY] DavinciCode notify absorbed");
    }
}
