using Ananta.SDK.Rpc;
using Ananta.Server.Configuration;
using Ananta.Server.Protocol.Client4229938;
using Ananta.Server.RpcTypes.Client4229938;
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
    private async Task GmTeleportXYZ(Connection conn, UxRpcMessage msg)
    {
        var args = msg.GetArgs<SceneMethods.GmTeleportXYZ>();
        var state = GetWorldState(msg.Context);
        var targetY = args.Y;
        if (targetY <= 10f)
        {
            targetY = (state != null && state.LastReportedPlayerPosition.Y > 10f)
                ? state.LastReportedPlayerPosition.Y
                : 274.6f;
        }
        var targetPos = new Vec3(args.X, targetY, args.Z);
        var facing = args.Facing;
        var unitId = state?.ActiveSpiritUnitId ?? Profile.InitialUnitId;

        if (state != null)
        {
            state.LastReportedPlayerPosition = targetPos;
            state.PendingTeleportPosition = targetPos;
            state.PendingTeleportFacing = facing;
            state.PendingTeleportId = 1;
        }

        var sync = new SceneMethods.SyncTeleport
        {
            option = new SceneMethods.TeleportOption
            {
                teleportId = 1,
                Position = new SceneMethods.UxVector3(targetPos.X, targetPos.Y, targetPos.Z),
                Facing = facing,
                IsSwitchScene = false,
                WaitTaskResource = false,
                MapEntranceId = 0
            }
        };
        await conn.NotifyAsync(MethodId.SyncTeleport, sync);
        if (unitId != 0)
        {
            await conn.NotifyAsync(MethodId.SyncUnitPositionAndFacing,
                WorldCodec.PositionAndFacing(unitId, targetPos, facing));
        }

        conn.Log.Info($"[GM] teleport to=({targetPos.X:F1},{targetPos.Y:F1},{targetPos.Z:F1}) facing={facing:F1}");
        await conn.ReturnEmptyOkAsync(msg);
    }

    [Handler(MethodId.DavinciCode, HandlerPacketKind.Notify)]
    private static void DavinciCode(Connection conn, UxRpcMessage msg)
    {
        conn.Log.Info("[SECURITY] DavinciCode notify absorbed");
    }

    [Handler(MethodId.GmDaVinciCode, HandlerPacketKind.Invoke)]
    private static Task GmDaVinciCode(Connection conn, UxRpcMessage msg)
    {
        conn.Log.Info("[SECURITY] GmDaVinciCode invoke absorbed");
        return conn.ReturnEmptyOkAsync(msg);
    }
}
