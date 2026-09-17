using Ananta.SDK.Serialization;

namespace Ananta.Server.RpcTypes.Client4229938.Methods.GameScene;

// IGameSceneToClient.SyncPlotCurrentEvent(ulong, uint, ClientActionTarget).
// EventId=0 closes the client's current stimulus/plot reaction.
[UxContract(Inline = true)]
internal sealed class SyncPlotCurrentEvent4229938
{
    public ulong AgentEntityId;
    public uint EventId;
    public PlotEventTarget4229938 Source = new();
}

// ClientToGameSceneDelegate.AskPreparePlotEvent_Serializer (4229938).
[UxContract(Inline = true)]
internal sealed class AskPreparePlotEventArgs4229938
{
    internal const int WireSize = 58;
    public uint EventId;
    public ulong AgentEntityId;
    public uint ResponseId;
    public StimEventParameter4229938 Source = new();
}

// ClientToGameSceneDelegate.AskEndPreparePlotEvent_Serializer (4229938).
[UxContract(Inline = true)]
internal sealed class AskEndPreparePlotEventArgs4229938
{
    internal const int WireSize = 12;
    public uint EventId;
    public ulong AgentEntityId;
}

// ClientToGameSceneDelegate.AskTriggerPlotEvent_Serializer (4229938).
// Both StimEventParameter and its targets are structs, without object markers.
[UxContract(Inline = true)]
internal sealed class AskTriggerPlotEventArgs4229938
{
    internal const int WireSize = 58;
    public uint EventId;
    public ulong AgentEntityId;
    public StimEventParameter4229938 Parameter = new();
    public uint ClientDmemOverrideCfgId;
}

[UxContract(Inline = true)]
internal sealed class StimEventParameter4229938
{
    public PlotEventTarget4229938 Source = new();
    public PlotEventTarget4229938 Source2 = new();
}

[UxContract(Inline = true)]
internal sealed class PlotEventTarget4229938
{
    public ulong Id;
    public UxVector3 Position;
    public byte Type;
}
