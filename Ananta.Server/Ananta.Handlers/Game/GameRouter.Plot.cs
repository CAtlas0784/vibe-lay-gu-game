using Ananta.SDK.Rpc;
using Ananta.Server.Protocol.Client4229938;
using SceneMethods = Ananta.Server.RpcTypes.Client4229938.Methods.GameScene;

namespace Ananta.Server.Handlers.Game;

internal sealed partial class GameRouter
{
    [Handler(MethodId.AskPreparePlotEvent, HandlerPacketKind.Notify)]
    private Task AskPreparePlotEvent(Connection conn, UxRpcMessage msg)
    {
        if (msg.Body.Length != SceneMethods.AskPreparePlotEventArgs4229938.WireSize
            || !msg.TryGetArgs<SceneMethods.AskPreparePlotEventArgs4229938>(out var args)
            || args is null || !HasFinitePosition(args.Source.Source)
            || !HasFinitePosition(args.Source.Source2))
        {
            conn.Log.Warn($"[PLOT] AskPreparePlotEvent invalid payload bytes={msg.Body.Length}");
            return Task.CompletedTask;
        }

        conn.Log.Info($"[PLOT] AskPreparePlotEvent event={args.EventId} agent={args.AgentEntityId} "
            + $"response={args.ResponseId} source=[{FormatPlotTarget(args.Source.Source)}] "
            + $"source2=[{FormatPlotTarget(args.Source.Source2)}]");
        var state = GetStateIfExists(conn.Session);
        if (state is not null)
            lock (state.SyncRoot)
                if (state.StaticNpcPreparedPlotEvents.ContainsKey(args.AgentEntityId))
                    state.StaticNpcPreparedPlotEvents[args.AgentEntityId] = args.EventId;
        return Task.CompletedTask;
    }

    [Handler(MethodId.AskEndPreparePlotEvent, HandlerPacketKind.Notify)]
    private Task AskEndPreparePlotEvent(Connection conn, UxRpcMessage msg)
    {
        if (msg.Body.Length != SceneMethods.AskEndPreparePlotEventArgs4229938.WireSize
            || !msg.TryGetArgs<SceneMethods.AskEndPreparePlotEventArgs4229938>(out var args)
            || args is null)
        {
            conn.Log.Warn($"[PLOT] AskEndPreparePlotEvent invalid payload bytes={msg.Body.Length}");
            return Task.CompletedTask;
        }

        conn.Log.Info($"[PLOT] AskEndPreparePlotEvent event={args.EventId} agent={args.AgentEntityId}");
        TryCompleteStaticNpcPlot(GetStateIfExists(conn.Session), args.AgentEntityId, args.EventId);
        return Task.CompletedTask;
    }

    [Handler(MethodId.AskTriggerPlotEvent, HandlerPacketKind.Notify)]
    private Task AskTriggerPlotEvent(Connection conn, UxRpcMessage msg)
    {
        if (msg.Body.Length != SceneMethods.AskTriggerPlotEventArgs4229938.WireSize
            || !msg.TryGetArgs<SceneMethods.AskTriggerPlotEventArgs4229938>(out var args)
            || args is null || !HasFinitePosition(args.Parameter.Source)
            || !HasFinitePosition(args.Parameter.Source2))
        {
            conn.Log.Warn($"[PLOT] AskTriggerPlotEvent invalid payload bytes={msg.Body.Length}");
            return Task.CompletedTask;
        }

        conn.Log.Info($"[PLOT] AskTriggerPlotEvent event={args.EventId} agent={args.AgentEntityId} "
            + $"source=[{FormatPlotTarget(args.Parameter.Source)}] source2=[{FormatPlotTarget(args.Parameter.Source2)}] "
            + $"clientDmemOverrideCfgId={args.ClientDmemOverrideCfgId}");
        // The native response has finished and entered its server-reaction phase.
        // These ambient NPCs have no plot continuation. Explicitly close it so
        // SelectStimOnline no longer uses the completed event's priority floor.
        if (TryCompleteStaticNpcPlot(GetStateIfExists(conn.Session), args.AgentEntityId, args.EventId))
        {
            conn.Log.Info($"[PLOT] AMBIENT_RESPONSE_FINISHED agent={args.AgentEntityId} event={args.EventId} currentEvent=0");
            return conn.NotifyAsync(MethodId.SyncPlotCurrentEvent,
                new SceneMethods.SyncPlotCurrentEvent4229938 { AgentEntityId = args.AgentEntityId });
        }
        return Task.CompletedTask;
    }

    internal static bool TryCompleteStaticNpcPlot(WorldEntryState? state, ulong agentId, uint eventId)
    {
        if (state is null || eventId == 0) return false;
        lock (state.SyncRoot)
        {
            if (!state.StaticNpcPreparedPlotEvents.TryGetValue(agentId, out var pending) || pending != eventId)
                return false;
            state.StaticNpcPreparedPlotEvents[agentId] = 0;
            return true;
        }
    }

    private static bool HasFinitePosition(SceneMethods.PlotEventTarget4229938 target)
        => float.IsFinite(target.Position.X) && float.IsFinite(target.Position.Y) && float.IsFinite(target.Position.Z);

    private static string FormatPlotTarget(SceneMethods.PlotEventTarget4229938 target)
        => $"id={target.Id} type={target.Type} pos=({target.Position.X:F2},{target.Position.Y:F2},{target.Position.Z:F2})";
}
