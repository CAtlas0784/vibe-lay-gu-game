using Ananta.Server.Configuration;
using Ananta.Server.RpcTypes.Client4229938;

namespace Ananta.Server.Protocol.Client4229938;

/// <summary>
/// Compatibility facade used by the build-4229938 codecs.
/// Editable values come from config/private-server.json; do not add new gameplay settings here.
/// </summary>
internal static class Profile
{
    private static PrivateServerConfig Config => PrivateServerConfigStore.Current;

    internal static int ClientVersion => Config.Client.Version;
    internal static int Aid => Config.Client.Aid;
    internal static ulong PlayerPid => Config.Player.Pid;
    internal static ulong InitialUnitId => Config.Player.InitialUnitId;
    internal static uint InitialSpiritTemplateId => Config.Player.InitialSpiritTemplateId;
    internal static uint RaidId => Config.World.RaidId;
    internal static ulong SceneInstanceId => Config.World.SceneInstanceId;
    internal static uint UniverseId => Config.World.UniverseId;
    internal static int ServerId => Config.Client.ServerId;

    internal static string AccountId => Config.Player.AccountId;
    internal static string UserName => Config.Player.UserName;
    internal static string DisplayName => Config.Player.DisplayName;
    internal static string LoginToken => Config.Player.LoginToken;
    internal static string GameToken => Config.Player.GameToken;

    internal static bool WorldEntryOpeningEnabled => Config.World.EntryOpeningEnabled;
    internal static Vec3 WorldSpawn => Config.World.Spawn.ToVec3();
    internal static float WorldFacing => Config.World.Facing;
}

