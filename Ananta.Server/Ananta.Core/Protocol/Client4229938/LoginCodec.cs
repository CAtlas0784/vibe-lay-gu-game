using System.Security.Cryptography;
using System.Text;
using System.Text.Json;
using GameMethods = Ananta.Server.RpcTypes.Client4229938.Methods.Game;
using LoginMethods = Ananta.Server.RpcTypes.Client4229938.Methods.LoginGate;

namespace Ananta.Server.Protocol.Client4229938;

/// <summary>
/// Typed login/gate payload factories. No serializer calls live here: handlers pass these DTOs to ReturnAsync/NotifyAsync.
/// </summary>
internal static class LoginCodec
{
    internal static LoginMethods.PatchCheckResult PatchCheck()
        // NOTE (2026-09-09): advertising patchVersion=1 loops the client
        // (it polls RequestPatchesCheckDataFromLogin until patch DATA arrives
        // via RequestPatchesFromLogin, whose payload format is still unknown).
        // Keep 0 until the real patch-data response is reverse-engineered.
        => new();

    internal static LoginMethods.CheckAccountResult CheckAccount()
    {
        var deviceId = Convert.ToHexString(MD5.HashData(Encoding.UTF8.GetBytes(Profile.AccountId)));
        // Do not use an anonymous object here for device-id aliases.
        // System.Text.Json treats property names case-insensitively while building
        // anonymous-type metadata, so having both `deviceid` and `deviceId` makes
        // CheckAccount throw before a response body can be serialized.
        // A dictionary keeps the exact wire keys and avoids that collision.
        var loginJson = JsonSerializer.Serialize(new Dictionary<string, object?>
        {
            ["deviceid"] = deviceId,
            ["device_id"] = deviceId,
            ["udid"] = deviceId,
            ["unisdk_device_id"] = deviceId,
            ["code"] = 200,
            ["subcode"] = 0,
            ["msg"] = "ok",
            ["uid"] = Profile.AccountId,
            ["sdkuid"] = Profile.AccountId,
            ["user_id"] = Profile.AccountId,
            ["aid"] = Profile.Aid,
            ["pid"] = Profile.PlayerPid,
            ["player_id"] = Profile.PlayerPid.ToString(),
            ["role_id"] = Profile.PlayerPid.ToString(),
            ["role_name"] = Profile.DisplayName,
            ["server_id"] = Profile.ServerId.ToString(),
            ["host_id"] = Profile.ServerId,
            ["username"] = Profile.UserName,
            ["account"] = Profile.AccountId,
            ["platform"] = "pc",
            ["token"] = Profile.LoginToken,
            ["access_token"] = Profile.LoginToken,
            ["ext_access_token"] = Profile.LoginToken,
            ["sessionid"] = Profile.LoginToken,
            ["login_ticket"] = Profile.LoginToken,
            ["realname_status"] = 1,
            ["realname_verify_status"] = 1,
            ["mobile_bind_status"] = 1
        });

        return new LoginMethods.CheckAccountResult
        {
            unisdk_login_json = loginJson,
            Token = Profile.LoginToken,
            UserName = Profile.UserName,
            Aid = Profile.Aid,
            NeedRealNameTip = false,
            NeedRoleEnter = false,
            RealNameVerified = true,
            HostId = Profile.ServerId,
            code = 200,
            subcode = 0,
            msg = "ok"
        };
    }

    internal static LoginMethods.EnterGameResult EnterGame(string gateHost, int gatePort)
        => new()
        {
            aid = Profile.Aid,
            playerPid = Profile.PlayerPid,
            gate = new LoginMethods.GateServerInfo
            {
                aid = Profile.Aid,
                playerPid = Profile.PlayerPid,
                host = gateHost,
                port = gatePort,
                loginToken = Profile.LoginToken,
                serverId = Profile.ServerId,
                accountId = Profile.AccountId
            }
        };

    internal static GameMethods.ServerTime ServerTime(double? clientUnixTime = null)
    {
        var serverUnixTime = DateTimeOffset.UtcNow.ToUnixTimeMilliseconds() / 1000.0;
        return new GameMethods.ServerTime
        {
            clientUnixTime = clientUnixTime ?? serverUnixTime,
            serverUnixTime = serverUnixTime
        };
    }

    internal static LoginMethods.GameServerInfo GameServerInfo(string host, int port)
        => new() { host = host, port = port, gameToken = Profile.GameToken };
}
