using Ananta.SDK.Network;
using Ananta.SDK.Rpc;
using Ananta.SDK.Serialization;
using Ananta.Server.Configuration;
using Ananta.Server.Protocol.Client4229938;
using Ananta.Server.RpcTypes.Client4229938;
using SceneMethods = Ananta.Server.RpcTypes.Client4229938.Methods.GameScene;

namespace Ananta.Server.Handlers.Game;

/// <summary>
/// S011 vehicle boarding story channel (build 4229938). Ported from the proven
/// Server_V2 flow: the client only offers the F-enter prompt and drives the
/// enter/exit animation phases once the S011 root node exists; without the root
/// bootstrap, pressing F near a spawned vehicle sends nothing.
/// Flow: root bootstrap (once per session) → client S011PlayerNetEnterVehicleRequest →
/// enter child + controller + status 2 → phase 2 (status 3) → phase 3 (status 4,
/// seated) → exit request → exit child + status 5 → phase 1 (status 0, done).
/// Vehicle records live in the shared static SummonedVehicles registry (extended
/// with seat state); the boarding transaction itself is per-session.
/// Lock order everywhere: story state, then SummonedVehiclesSync.
/// </summary>
internal sealed partial class GameRouter
{
    private const string VehicleStoryKey = "client4229938-vehicle-story";
    private const uint VehicleStoryRootNid = 1;
    private const uint VehicleStoryEnterNid = 2;
    private const uint VehicleStoryExitNid = 3;

    internal sealed class VehicleStoryState
    {
        internal object SyncRoot { get; } = new();
        internal bool RootSent;
        internal bool SeenAnyRpc;
        internal long HighestConfirmedRpcId = -1;
        internal SortedSet<long> PendingRpcIds { get; } = new();
        internal HashSet<long> CommittedRpcIds { get; } = new();
        internal ulong EnterVehicleId;
        internal byte EnterSeat;
        internal bool ExitInProgress;
        internal ulong CurrentVehicleId;
        internal int CurrentSeat = -1;
        internal ulong BoardingUnitId;
    }

    internal static VehicleStoryState GetVehicleStoryState(TcpSession session)
    {
        if (session.Items.TryGetValue(VehicleStoryKey, out var raw) && raw is VehicleStoryState existing)
            return existing;
        var created = new VehicleStoryState();
        session.Items[VehicleStoryKey] = created;
        return created;
    }

    internal static WorldEntryState? GetVehicleWorldState(TcpSession session)
        => session.Items.TryGetValue(WorldStateKey, out var raw) && raw is WorldEntryState existing
            ? existing
            : null;

    internal static (ulong VehicleId, int Seat) VehicleSeatSnapshot(TcpSession session)
    {
        var story = GetVehicleStoryState(session);
        lock (story.SyncRoot)
            return (story.CurrentVehicleId, story.CurrentSeat);
    }

    internal static async Task EnsureVehicleStoryRoot(RpcContext ctx)
    {
        if (!PrivateServerConfigStore.Current.Gameplay.Vehicles.Enabled)
            return;
        var story = GetVehicleStoryState(ctx.Session);
        long confirm;
        lock (story.SyncRoot)
        {
            if (story.RootSent)
                return;
            story.RootSent = true;
            story.BoardingUnitId = GetVehicleWorldState(ctx.Session)?.ActiveSpiritUnitId
                ?? Profile.InitialUnitId;
            confirm = story.SeenAnyRpc ? Math.Max(0, story.HighestConfirmedRpcId) : -1;
        }
        await ctx.NotifyAsync(MethodId.SyncStoryCoreServerInfo,
            StoryS011Codec4229938.BuildRootBootstrap(VehicleStoryRootNid, confirm));
        ctx.Session.Log.Info($"[VEHICLE-STORY] S011 root ready nid={VehicleStoryRootNid} confirm={confirm}");
    }

    internal static void ResetVehicleStoryForEntity(TcpSession session, ulong entityId)
    {
        var story = GetVehicleStoryState(session);
        lock (story.SyncRoot)
        {
            if (story.CurrentVehicleId == entityId)
            {
                story.CurrentVehicleId = 0;
                story.CurrentSeat = -1;
            }
            if (story.EnterVehicleId == entityId)
                story.EnterVehicleId = 0;
            story.ExitInProgress = false;
        }
    }

    /// <summary>
    /// Fresh scene load (login / airport travel): the client builds a new story
    /// instance and drops all server-made nodes, so the S011 root must be sent
    /// again by the post-load finalization. Called from OnLoadingFinished for each
    /// accepted generation, next to the garage/aether one-shot resets. The early
    /// root pushed on the pre-load story hello (if any) is harmless — the client
    /// discards it with the old story instance.
    /// </summary>
    internal static void ResetVehicleStory(TcpSession session)
    {
        var story = GetVehicleStoryState(session);
        lock (story.SyncRoot)
        {
            story.RootSent = false;
            story.SeenAnyRpc = false;
            story.HighestConfirmedRpcId = -1;
            story.PendingRpcIds.Clear();
            story.CommittedRpcIds.Clear();
            story.EnterVehicleId = 0;
            story.EnterSeat = 0;
            story.ExitInProgress = false;
            story.CurrentVehicleId = 0;
            story.CurrentSeat = -1;
        }
    }

    [Handler(MethodId.SyncStoryCoreClientInfo, HandlerPacketKind.Notify)]
    private async Task SyncStoryCoreClientInfo(Connection conn, UxRpcMessage msg)
    {
        await EnsureVehicleStoryRoot(msg.Context);
        var story = GetVehicleStoryState(msg.Context.Session);
        lock (story.SyncRoot)
            story.BoardingUnitId = GetVehicleWorldState(msg.Context.Session)?.ActiveSpiritUnitId
                ?? Profile.InitialUnitId;

        var commands = StoryVehicleCodec4229938.Parse(msg.Body, out var full);
        if (!full)
            conn.Log.Warn($"[VEHICLE-STORY] partial parse commands={commands.Count} bytes={msg.Body.Length} hex={BitConverter.ToString(msg.Body)}");
        foreach (var summary in commands)
        {
            // Non-heartbeat story traffic is rare; log it so new flows are visible.
            if (summary.Name != "Rpc3" || summary.RpcId < 0)
                conn.Log.Info($"[VEHICLE-STORY] cmd mark={summary.TypeMark} nid={summary.Nid} name={summary.Name} rpc={summary.RpcId} payload={summary.PayloadKind} vehicle={summary.PayloadVehicleId} seats=[{(summary.PayloadSeatIndices is null ? "" : string.Join(",", summary.PayloadSeatIndices))}] bool={summary.PayloadBool} int={summary.PayloadInt}");
        }

        foreach (var cmd in commands)
        {
            var duplicateCommitted = false;
            long duplicateConfirm = -1;
            if (cmd.HasRpcId && cmd.RpcId >= 0)
            {
                lock (story.SyncRoot)
                {
                    story.SeenAnyRpc = true;
                    if (cmd.RpcId <= story.HighestConfirmedRpcId)
                    {
                        duplicateCommitted = true;
                        duplicateConfirm = story.HighestConfirmedRpcId;
                    }
                    else
                    {
                        story.PendingRpcIds.Add(cmd.RpcId);
                    }
                }
            }

            if (duplicateCommitted)
            {
                await SendStoryAsync(conn.Session, StoryS011Codec4229938.BuildConfirmRpc(duplicateConfirm));
                continue;
            }

            if (cmd.TypeMark is 3 or 6)
            {
                await ConfirmVehicleStoryRpc(conn, story, cmd.HasRpcId ? cmd.RpcId : null);
                continue;
            }

            if (cmd.Name == "S011PlayerNetEnterVehicleRequest" && cmd.PayloadKind == "S011EnterVehicleRequest")
                await BeginVehicleEnter(conn, story, cmd);
            else if (cmd.Name == "S011PlayerNetExitVehicleRequest" && cmd.PayloadKind == "Bool")
                await BeginVehicleExit(conn, story, cmd.PayloadBool ?? true);
            else if (cmd.Nid == VehicleStoryEnterNid && cmd.Name == "MsgrChangePhaseRequest" && cmd.PayloadKind is "Byte" or "Int")
                await AdvanceVehicleEnter(conn, story, (int)(cmd.PayloadInt ?? 0));
            else if (cmd.Nid == VehicleStoryExitNid && cmd.Name == "MsgrChangePhaseRequest" && cmd.PayloadKind is "Byte" or "Int")
                await AdvanceVehicleExit(conn, story, (int)(cmd.PayloadInt ?? 0));

            await ConfirmVehicleStoryRpc(conn, story, cmd.HasRpcId ? cmd.RpcId : null);
        }
    }

    private async Task BeginVehicleEnter(Connection conn, VehicleStoryState story, StoryClientCommand4229938 cmd)
    {
        var vehicleId = cmd.PayloadVehicleId ?? 0;
        var seat = cmd.PayloadSeatIndices is { Count: > 0 } ? cmd.PayloadSeatIndices[0] : (byte)0;
        var pid = Profile.PlayerPid;
        ulong unitId;
        var ok = false;
        var lazyRegistered = false;
        lock (story.SyncRoot)
        {
            unitId = story.BoardingUnitId != 0 ? story.BoardingUnitId : Profile.InitialUnitId;
            lock (SummonedVehiclesSync)
            {
                // GM-console cars are spawned client-locally with client-side ids the
                // server has never seen: adopt them on first enter attempt instead of
                // leaving the client stuck with a hidden prompt. Seat layout is grown
                // from the requested index; real counts arrive via SyncSpawnVehicle.
                if (vehicleId != 0 && !SummonedVehicles.ContainsKey(vehicleId))
                {
                    SummonedVehicles[vehicleId] = new SummonedVehicle
                    {
                        SeatCount = (int)Math.Min(16, Math.Max(2, (int)seat + 1)),
                        Interactable = true,
                    };
                    lazyRegistered = true;
                }
                if (vehicleId != 0 && story.CurrentVehicleId == 0
                    && story.EnterVehicleId == 0 && !story.ExitInProgress
                    && SummonedVehicles.TryGetValue(vehicleId, out var vehicle) && vehicle.Interactable
                    && seat < vehicle.SeatCount
                    && !vehicle.SeatReservations.ContainsKey(seat) && !vehicle.SeatOccupants.ContainsKey(seat))
                {
                    vehicle.SeatReservations[seat] = pid;
                    story.EnterVehicleId = vehicleId;
                    story.EnterSeat = seat;
                    vehicle.ControllerPid = pid;
                    ok = true;
                }
            }
        }

        if (!ok)
        {
            conn.Log.Warn($"[VEHICLE-STORY] enter rejected vehicle={vehicleId} seat={seat}");
            return;
        }

        await SendStoryAsync(conn.Session, StoryS011Codec4229938.BuildEnterChildBootstrap(VehicleStoryEnterNid, vehicleId, seat));
        await conn.NotifyAsync(MethodId.SyncChangeVehicleController, new SceneMethods.SyncChangeVehicleController
        { VehicleInstanceId = vehicleId, ControllerPid = pid });
        await SendVehicleBoardingStatus(conn, unitId, vehicleId, seat, 2);
        conn.Log.Info($"[VEHICLE-STORY] enter begin vehicle={vehicleId} seat={seat} unit={unitId} status=2 lazy={lazyRegistered}");
    }

    private async Task AdvanceVehicleEnter(Connection conn, VehicleStoryState story, int phase)
    {
        ulong vehicleId;
        byte seat;
        ulong unitId;
        lock (story.SyncRoot)
        {
            vehicleId = story.EnterVehicleId;
            seat = story.EnterSeat;
            unitId = story.BoardingUnitId != 0 ? story.BoardingUnitId : Profile.InitialUnitId;
        }
        if (vehicleId == 0)
            return;
        switch (phase)
        {
            case 0:
            case 1:
                return;
            case 2:
            {
                var committed = false;
                lock (SummonedVehiclesSync)
                {
                    if (SummonedVehicles.TryGetValue(vehicleId, out var vehicle)
                        && vehicle.SeatReservations.TryGetValue(seat, out var owner) && owner == Profile.PlayerPid
                        && !vehicle.SeatOccupants.ContainsKey(seat))
                    {
                        vehicle.SeatReservations.Remove(seat);
                        vehicle.SeatOccupants[seat] = Profile.PlayerPid;
                        committed = true;
                    }
                }
                if (!committed)
                {
                    conn.Log.Warn($"[VEHICLE-STORY] enter phase=2 commit failed vehicle={vehicleId} seat={seat}");
                    return;
                }
                await SendVehicleBoardingStatus(conn, unitId, vehicleId, seat, 3);
                conn.Log.Info($"[VEHICLE-STORY] enter phase=2 vehicle={vehicleId} seat={seat} status=3");
                return;
            }
            case 3:
                await SendVehicleBoardingStatus(conn, unitId, vehicleId, seat, 4);
                await SendStoryAsync(conn.Session, StoryS011Codec4229938.BuildDeleteNode(VehicleStoryEnterNid));
                lock (story.SyncRoot)
                {
                    story.CurrentVehicleId = vehicleId;
                    story.CurrentSeat = seat;
                    story.EnterVehicleId = 0;
                    lock (SummonedVehiclesSync)
                    {
                        if (SummonedVehicles.TryGetValue(vehicleId, out var v))
                            v.ControllerPid = Profile.PlayerPid;
                    }
                }
                conn.Log.Info($"[VEHICLE-STORY] enter complete vehicle={vehicleId} seat={seat} status=4");
                return;
            case 4:
                await SendVehicleBoardingStatus(conn, unitId, vehicleId, 0, 0);
                await conn.NotifyAsync(MethodId.SyncChangeVehicleController, new SceneMethods.SyncChangeVehicleController
                { VehicleInstanceId = vehicleId, ControllerPid = 0 });
                await SendStoryAsync(conn.Session, StoryS011Codec4229938.BuildDeleteNode(VehicleStoryEnterNid));
                lock (story.SyncRoot)
                {
                    story.EnterVehicleId = 0;
                    lock (SummonedVehiclesSync)
                    {
                        if (SummonedVehicles.TryGetValue(vehicleId, out var v))
                        {
                            if (v.SeatReservations.TryGetValue(seat, out var reservedBy) && reservedBy == Profile.PlayerPid)
                                v.SeatReservations.Remove(seat);
                            if (v.SeatOccupants.TryGetValue(seat, out var occupiedBy) && occupiedBy == Profile.PlayerPid)
                                v.SeatOccupants.Remove(seat);
                            v.ControllerPid = 0;
                        }
                    }
                }
                conn.Log.Info($"[VEHICLE-STORY] enter cancelled vehicle={vehicleId}");
                return;
        }
    }

    private async Task BeginVehicleExit(Connection conn, VehicleStoryState story, bool stopBeforeLeave)
    {
        ulong vehicleId;
        byte seat;
        ulong unitId;
        lock (story.SyncRoot)
        {
            vehicleId = story.CurrentVehicleId;
            seat = (byte)Math.Max(0, story.CurrentSeat);
            unitId = story.BoardingUnitId != 0 ? story.BoardingUnitId : Profile.InitialUnitId;
            if (vehicleId == 0 || story.ExitInProgress)
                return;
            story.ExitInProgress = true;
        }
        await SendStoryAsync(conn.Session, StoryS011Codec4229938.BuildExitChildBootstrap(VehicleStoryExitNid, vehicleId, seat, stopBeforeLeave));
        await SendVehicleBoardingStatus(conn, unitId, vehicleId, seat, 5);
        conn.Log.Info($"[VEHICLE-STORY] exit begin vehicle={vehicleId} seat={seat} status=5");
    }

    private async Task AdvanceVehicleExit(Connection conn, VehicleStoryState story, int phase)
    {
        ulong vehicleId;
        byte seat;
        ulong unitId;
        lock (story.SyncRoot)
        {
            vehicleId = story.CurrentVehicleId;
            seat = (byte)Math.Max(0, story.CurrentSeat);
            unitId = story.BoardingUnitId != 0 ? story.BoardingUnitId : Profile.InitialUnitId;
        }
        if (vehicleId == 0)
            return;
        if (phase == 0)
            return;
        if (phase == 1)
        {
            await SendVehicleBoardingStatus(conn, unitId, vehicleId, 0, 0);
            await conn.NotifyAsync(MethodId.SyncChangeVehicleController, new SceneMethods.SyncChangeVehicleController
            { VehicleInstanceId = vehicleId, ControllerPid = 0 });
            await SendStoryAsync(conn.Session, StoryS011Codec4229938.BuildDeleteNode(VehicleStoryExitNid));
            lock (story.SyncRoot)
            {
                story.CurrentVehicleId = 0;
                story.CurrentSeat = -1;
                story.ExitInProgress = false;
                lock (SummonedVehiclesSync)
                {
                    if (SummonedVehicles.TryGetValue(vehicleId, out var v))
                    {
                        if (v.SeatOccupants.TryGetValue(seat, out var occupiedBy) && occupiedBy == Profile.PlayerPid)
                            v.SeatOccupants.Remove(seat);
                        if (v.SeatReservations.TryGetValue(seat, out var reservedBy) && reservedBy == Profile.PlayerPid)
                            v.SeatReservations.Remove(seat);
                        v.ControllerPid = 0;
                        v.Interactable = true;
                    }
                }
            }
            conn.Log.Info($"[VEHICLE-STORY] exit complete vehicle={vehicleId} status=0");
        }
        else if (phase == 2)
        {
            await SendVehicleBoardingStatus(conn, unitId, vehicleId, seat, 4);
            await SendStoryAsync(conn.Session, StoryS011Codec4229938.BuildDeleteNode(VehicleStoryExitNid));
            lock (story.SyncRoot)
                story.ExitInProgress = false;
            conn.Log.Info($"[VEHICLE-STORY] exit cancelled vehicle={vehicleId} status=4");
        }
    }

    [Handler(MethodId.AskClaimVehicleSeat, HandlerPacketKind.Invoke)]
    private async Task AskClaimVehicleSeatStory(Connection conn, UxRpcMessage msg)
    {
        if (!msg.TryGetArgs<SceneMethods.AskClaimVehicleSeatArgs>(out var args) || args is null)
        {
            conn.Log.Warn($"[VEHICLE] AskClaimVehicleSeat undecodable bytes={msg.Body.Length}");
            await conn.ReturnEmptyOkAsync(msg);
            return;
        }
        var story = GetVehicleStoryState(msg.Context.Session);
        byte selected = 0;
        var valid = false;
        lock (story.SyncRoot)
        {
            lock (SummonedVehiclesSync)
            {
                if (story.EnterVehicleId == args.VehicleEntityId
                    && SummonedVehicles.TryGetValue(args.VehicleEntityId, out var vehicle))
                {
                    foreach (var seat in args.SeatIndices)
                    {
                        var reservedByOther = vehicle.SeatReservations.TryGetValue(seat, out var reservedBy) && reservedBy != Profile.PlayerPid;
                        var occupiedByOther = vehicle.SeatOccupants.TryGetValue(seat, out var occupiedBy) && occupiedBy != Profile.PlayerPid;
                        if (seat < vehicle.SeatCount && !reservedByOther && !occupiedByOther)
                        {
                            selected = seat;
                            valid = true;
                            break;
                        }
                    }
                    if (valid)
                    {
                        var oldSeat = story.EnterSeat;
                        if (vehicle.SeatReservations.TryGetValue(oldSeat, out var oldOwner) && oldOwner == Profile.PlayerPid)
                            vehicle.SeatReservations.Remove(oldSeat);
                        vehicle.SeatReservations[selected] = Profile.PlayerPid;
                        story.EnterSeat = selected;
                    }
                }
            }
        }
        if (!valid)
        {
            await conn.ReturnEmptyAsync(msg, 1);
            return;
        }
        await conn.ReturnAsync(msg, selected);
        conn.Log.Info($"[VEHICLE-STORY] seat claim vehicle={args.VehicleEntityId} seat={selected}");
    }

    private Task SendVehicleBoardingStatus(Connection conn, ulong unitId, ulong vehicleId, byte seat, byte status)
        => conn.NotifyAsync(MethodId.SyncUnitVehicleStatus, new SceneMethods.NewClientBoardingInfo
        {
            EntityId = unitId,
            Status = status,
            VehicleUId = vehicleId,
            SeatIndex = seat,
            ExtInfo = null,
        });

    /// <summary>
    /// Server-forced enter (debug panel path): seats the player without any client
    /// F-press. Mirrors the enter-complete leg — move-to-seat, controller, boarding
    /// status seated, start/state-change/finish drive-state notifies — plus an S011
    /// enter child so the story side agrees, deleted right after like a phase-3 commit.
    /// </summary>
    internal static async Task<(bool Ok, string Message)> ForceEnterVehicleAsync(TcpSession session, ulong entityId = 0)
    {
        var story = GetVehicleStoryState(session);
        var unitId = GetVehicleWorldState(session)?.ActiveSpiritUnitId ?? Profile.InitialUnitId;
        var pid = Profile.PlayerPid;
        ulong vehicleId = entityId != 0 ? entityId : LastSummonedEntity();
        const byte seat = 0;
        lock (story.SyncRoot)
        {
            lock (SummonedVehiclesSync)
            {
                if (vehicleId == 0 || !SummonedVehicles.TryGetValue(vehicleId, out var vehicle))
                    return (false, "no spawned vehicle (spawn one first)");
                if (story.CurrentVehicleId != 0)
                    return (false, $"already in vehicle {story.CurrentVehicleId} (exit first)");
                if (!vehicle.Interactable || vehicle.SeatOccupants.ContainsKey(seat))
                    return (false, "vehicle is not enterable right now");
                vehicle.SeatReservations.Remove(seat);
                vehicle.SeatOccupants[seat] = pid;
                vehicle.ControllerPid = pid;
                story.CurrentVehicleId = vehicleId;
                story.CurrentSeat = seat;
                story.EnterVehicleId = 0;
            }
        }
        var drive = new SceneMethods.PlayerVehicleDriveStateInfo
        {
            Pid = pid, EnterOrLeave = true, VehicleEntityId = vehicleId, SeatIndex = seat,
            IfForce = true, OpenDoorTypeId = 0, OpenDoorActionSpeed = 0, OpenDoorActionClipLength = 0,
        };
        try
        {
            var ct = CancellationToken.None;
            await session.NotifyAsync(MethodId.SyncChangeVehicleInteractable, UxSerializer.Serialize(
                new SceneMethods.SyncChangeVehicleInteractable { VehicleInstanceId = vehicleId, Interactable = false }), ct);
            await session.NotifyAsync(MethodId.SyncPlayerMoveToDriveSeat, UxSerializer.Serialize(
                new SceneMethods.SyncPlayerMoveToDriveSeat { Pid = pid, VehicleEntityId = vehicleId }), ct);
            await session.NotifyAsync(MethodId.SyncUnitVehicleStatus, UxSerializer.Serialize(
                new SceneMethods.NewClientBoardingInfo { EntityId = unitId, Status = 4, VehicleUId = vehicleId, SeatIndex = seat, ExtInfo = null }), ct);
            await session.NotifyAsync(MethodId.SyncPlayerStartEnterOrExitVehicl, UxSerializer.Serialize(drive), ct);
            await session.NotifyAsync(MethodId.SyncPlayerVehicleStateChange, UxSerializer.Serialize(drive), ct);
            await session.NotifyAsync(MethodId.SyncChangeVehicleController, UxSerializer.Serialize(
                new SceneMethods.SyncChangeVehicleController { VehicleInstanceId = vehicleId, ControllerPid = pid }), ct);
            await session.NotifyAsync(MethodId.SyncPlayerFinishEnterOrExitVehic, UxSerializer.Serialize(drive), ct);
            await SendStoryAsync(session, StoryS011Codec4229938.BuildEnterChildBootstrap(VehicleStoryEnterNid, vehicleId, seat));
            await SendStoryAsync(session, StoryS011Codec4229938.BuildDeleteNode(VehicleStoryEnterNid));
            session.Log.Info($"[VEHICLE-STORY] force enter vehicle={vehicleId} seat={seat} unit={unitId} status=4");
            return (true, $"seated in vehicle {vehicleId} (seat 0) — drive with normal keys, exit with F or the Exit button");
        }
        catch (Exception ex)
        {
            return (false, $"enter failed: {ex.Message}");
        }
    }

    /// <summary>Server-forced exit (debug panel path).</summary>
    internal static async Task<(bool Ok, string Message)> ForceExitVehicleAsync(TcpSession session)
    {
        var story = GetVehicleStoryState(session);
        var unitId = GetVehicleWorldState(session)?.ActiveSpiritUnitId ?? Profile.InitialUnitId;
        ulong vehicleId;
        lock (story.SyncRoot)
        {
            vehicleId = story.CurrentVehicleId;
            if (vehicleId == 0)
                return (false, "not in a vehicle");
        }
        try
        {
            var ct = CancellationToken.None;
            await session.NotifyAsync(MethodId.SyncPlayerExitVehicle, UxSerializer.Serialize(
                new SceneMethods.SyncPlayerExitVehicle { VehicleEntityId = vehicleId, Force = true, StopBeforeLeave = true }), ct);
            await session.NotifyAsync(MethodId.SyncUnitVehicleStatus, UxSerializer.Serialize(
                new SceneMethods.NewClientBoardingInfo { EntityId = unitId, Status = 0, VehicleUId = vehicleId, SeatIndex = 0, ExtInfo = null }), ct);
            await session.NotifyAsync(MethodId.SyncChangeVehicleController, UxSerializer.Serialize(
                new SceneMethods.SyncChangeVehicleController { VehicleInstanceId = vehicleId, ControllerPid = 0 }), ct);
            await session.NotifyAsync(MethodId.SyncChangeVehicleInteractable, UxSerializer.Serialize(
                new SceneMethods.SyncChangeVehicleInteractable { VehicleInstanceId = vehicleId, Interactable = true }), ct);
            await SendStoryAsync(session, StoryS011Codec4229938.BuildDeleteNode(VehicleStoryEnterNid));
            await SendStoryAsync(session, StoryS011Codec4229938.BuildDeleteNode(VehicleStoryExitNid));
            lock (story.SyncRoot)
            {
                story.CurrentVehicleId = 0;
                story.CurrentSeat = -1;
                story.EnterVehicleId = 0;
                story.ExitInProgress = false;
                lock (SummonedVehiclesSync)
                {
                    if (SummonedVehicles.TryGetValue(vehicleId, out var v))
                    {
                        v.SeatOccupants.Clear();
                        v.SeatReservations.Clear();
                        v.ControllerPid = 0;
                        v.Interactable = true;
                    }
                }
            }
            session.Log.Info($"[VEHICLE-STORY] force exit vehicle={vehicleId}");
            return (true, $"exited vehicle {vehicleId}");
        }
        catch (Exception ex)
        {
            return (false, $"exit failed: {ex.Message}");
        }
    }

    private async Task ConfirmVehicleStoryRpc(Connection conn, VehicleStoryState story, long? commitRpcId)
    {
        long highest;
        lock (story.SyncRoot)
        {
            if (commitRpcId is long id && id >= 0)
                story.CommittedRpcIds.Add(id);
            highest = story.HighestConfirmedRpcId;
            while (story.PendingRpcIds.Count > 0)
            {
                var next = highest + 1;
                if (next >= 0 && story.CommittedRpcIds.Contains(next))
                {
                    highest = next;
                    story.PendingRpcIds.Remove(next);
                    story.CommittedRpcIds.Remove(next);
                }
                else break;
            }
            if (highest <= story.HighestConfirmedRpcId)
                return;
            story.HighestConfirmedRpcId = highest;
        }
        await SendStoryAsync(conn.Session, StoryS011Codec4229938.BuildConfirmRpc(highest));
    }

    private static Task SendStoryAsync(TcpSession session, byte[] payload)
        => session.NotifyAsync(MethodId.SyncStoryCoreServerInfo, payload, CancellationToken.None);
}
