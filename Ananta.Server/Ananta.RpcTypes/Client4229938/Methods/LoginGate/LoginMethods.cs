using Ananta.SDK.Serialization;

namespace Ananta.Server.RpcTypes.Client4229938.Methods.LoginGate;

[UxContract(Inline = true)]
internal sealed class PatchCheckResult
{
    public int patchVersion;
    public List<uint> patches = [];
}

[UxContract]
internal sealed class CheckAccountResult
{
    // Field set and order must match the 4229938 client CheckAccountResult
    // (UX.Game, dump TypeDefIndex 32261): the reflection serializer emits
    // fields by declaration order and the client rejects the response unless
    // its `code` field lands on the wire position it expects (it must read 200).
    public string unisdk_login_json = string.Empty;
    public string Token = string.Empty;
    public string UserName = string.Empty;
    public int Aid;
    public bool NeedRealNameTip;
    public bool NeedRoleEnter;
    public bool RealNameVerified;
    public int HostId;
    public int code;
    public int subcode;
    public string msg = string.Empty;
}

[UxContract(Inline = true)]
internal sealed class EnterGameResult
{
    public int aid;
    public ulong playerPid;
    public GateServerInfo gate = new();
}

[UxContract]
internal sealed class GateServerInfo
{
    public int aid;
    public ulong playerPid;
    public string host = string.Empty;
    public int port;
    public string loginToken = string.Empty;
    public int serverId;
    public string accountId = string.Empty;
}

[UxContract]
internal sealed class GameServerInfo
{
    public string host = string.Empty;
    public int port;
    public string gameToken = string.Empty;
}
