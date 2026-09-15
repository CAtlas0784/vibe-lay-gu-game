using System.Collections.Generic;
using Ananta.SDK.Serialization;

namespace Ananta.Server.RpcTypes.Client4229938.Methods.Game;

/// <summary>
/// Metro/Train runtime data structures for CBT 4229938.
/// Matching ReadMetroClientInfo and ReadMetroCarriageGadgetInfos from GameAssembly.
/// </summary>
[UxContract]
public sealed class MetroClientInfo
{
    public int Id { get; set; }
    public uint LineId { get; set; }
    public float ElapsedTime { get; set; }
    public bool IsFinalTrain { get; set; }
}

[UxContract]
public sealed class MetroCarriageGadgetInfos
{
    public List<ulong> InnerGadgetIds { get; set; } = [];
    public List<ulong> OuterGadgetIds { get; set; } = [];
}
