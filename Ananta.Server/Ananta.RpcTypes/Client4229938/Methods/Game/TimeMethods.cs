using Ananta.SDK.Serialization;

namespace Ananta.Server.RpcTypes.Client4229938.Methods.Game;

/// <summary>Client clock sample sent by both GetServerTime and GetServerTimeGame.</summary>
[UxContract(Inline = true)]
internal sealed class GetServerTime
{
    public double clientUnixTime;
}

[UxContract(Inline = true)]
internal sealed class ServerTime
{
    public double clientUnixTime;
    public double serverUnixTime;
}
