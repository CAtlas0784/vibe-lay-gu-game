using System.Text.Json;
using Ananta.Server.Protocol.Client4229938;
using Ananta.Server.RpcTypes.Client4229938;

namespace Ananta.Server.Configuration;

/// <summary>
/// Human-editable private-server settings.
///
/// Protocol constants (RPC ids, serializer layouts, client wire types) deliberately do NOT live
/// here. Those belong to Protocol/Client4229938 and should only change when supporting a new client.
/// </summary>
public sealed class PrivateServerConfig
{
    public ClientSettings Client { get; init; } = new();
    public NetworkSettings Network { get; init; } = new();
    public PlayerSettings Player { get; init; } = new();
    public WorldSettings World { get; init; } = new();
    public ContentSettings Content { get; init; } = new();
    public GameplaySettings Gameplay { get; init; } = new();
    public UiSettings Ui { get; init; } = new();
    public LoggingSettings Logging { get; init; } = new();
    public PathSettings Paths { get; init; } = new();
    public DebugSettings Debug { get; init; } = new();

    internal void Validate()
    {
        static void Port(int value, string name)
        {
            if (value is < 1 or > 65535) throw new InvalidDataException($"{name} must be 1..65535, got {value}.");
        }

        if (Client.Version != ClientBuild.Version)
            throw new InvalidDataException($"client.version={Client.Version} is not supported by this source tree; expected {ClientBuild.Version}.");
        if (Client.ServerId <= 0) throw new InvalidDataException("client.serverId must be positive.");
        if (string.IsNullOrWhiteSpace(Client.RpcMd5)) throw new InvalidDataException("client.rpcMd5 must not be empty.");
        if (string.IsNullOrWhiteSpace(Network.BindHost) || string.IsNullOrWhiteSpace(Network.AdvertisedHost))
            throw new InvalidDataException("network.bindHost and network.advertisedHost must not be empty.");
        if (Player.Pid == 0) throw new InvalidDataException("player.pid must not be zero.");
        if (Player.InitialUnitId == 0) throw new InvalidDataException("player.initialUnitId must not be zero.");
        if (Player.InitialSpiritTemplateId == 0) throw new InvalidDataException("player.initialSpiritTemplateId must not be zero.");
        if (string.IsNullOrWhiteSpace(Player.AccountId) || string.IsNullOrWhiteSpace(Player.UserName) || string.IsNullOrWhiteSpace(Player.DisplayName))
            throw new InvalidDataException("player.accountId, player.userName and player.displayName must not be empty.");
        if (string.IsNullOrWhiteSpace(Player.LoginToken) || string.IsNullOrWhiteSpace(Player.GameToken) ||
            string.IsNullOrWhiteSpace(Player.ShareToken) || string.IsNullOrWhiteSpace(Player.FpPassToken) || string.IsNullOrWhiteSpace(Player.Skey))
            throw new InvalidDataException("player compatibility tokens must not be empty.");
        if (World.RaidId == 0 || World.SceneInstanceId == 0 || World.UniverseId == 0)
            throw new InvalidDataException("world.raidId, sceneInstanceId and universeId must not be zero.");
        if (World.Content.Enabled && string.IsNullOrWhiteSpace(Paths.WorldData))
            throw new InvalidDataException("paths.worldData must not be empty while world.content.enabled.");
        if (World.Content.Enabled && string.IsNullOrWhiteSpace(World.Content.Scene))
            throw new InvalidDataException("world.content.scene must not be empty.");
        ValidateStreamWindow(World.Content.SceneItems, "world.content.sceneItems");
        ValidateStreamWindow(World.Content.Gadgets, "world.content.gadgets");
        if (World.Content.DynamicGo.SeedAttempts is < 1 or > 60)
            throw new InvalidDataException($"world.content.dynamicGo.seedAttempts must be 1..60, got {World.Content.DynamicGo.SeedAttempts}.");

        static void ValidateStreamWindow<T>(T settings, string name) where T : class
        {
            var radius = (int)(typeof(T).GetProperty("RadiusCells")?.GetValue(settings) ?? 0);
            var unload = (int)(typeof(T).GetProperty("UnloadRadiusCells")?.GetValue(settings) ?? 0);
            var budget = (int)(typeof(T).GetProperty("LoadBudgetCells")?.GetValue(settings) ?? 0);
            if (radius is < 1 or > 8)
                throw new InvalidDataException($"{name}.radiusCells must be 1..8, got {radius}.");
            if (unload < radius || unload > radius + 8)
                throw new InvalidDataException($"{name}.unloadRadiusCells must be within radiusCells..radiusCells+8, got {unload}.");
            if (budget is < 1 or > 200)
                throw new InvalidDataException($"{name}.loadBudgetCells must be 1..200, got {budget}.");
        }
        if (Network.LoginPorts is null || Network.LoginPorts.Length != 2)
            throw new InvalidDataException("network.loginPorts must contain exactly two ports.");
        Port(Network.LoginPorts[0], "network.loginPorts[0]");
        Port(Network.LoginPorts[1], "network.loginPorts[1]");
        Port(Network.GamePort, "network.gamePort");
        Port(Network.Proxy.HttpsPort, "network.proxy.httpsPort");
        Port(Network.Proxy.HttpPort, "network.proxy.httpPort");
        Port(Network.Proxy.LoginListPort, "network.proxy.loginListPort");
        Port(Network.Proxy.LoginTcpPort, "network.proxy.loginTcpPort");
        Port(Network.Proxy.GameTcpPort, "network.proxy.gameTcpPort");
        Port(Network.Proxy.SceneSubPort, "network.proxy.sceneSubPort");
        if (string.IsNullOrWhiteSpace(Network.Proxy.UpdateHost) || string.IsNullOrWhiteSpace(Network.Proxy.CertificatePassphrase))
            throw new InvalidDataException("network.proxy.updateHost and certificatePassphrase must not be empty.");
        if (Content.Roster.UnitIdBase == 0) throw new InvalidDataException("content.roster.unitIdBase must not be zero.");
        if (Content.Roster.TemplateIdMin >= Content.Roster.TemplateIdMaxExclusive)
            throw new InvalidDataException("content.roster.templateIdMin must be less than templateIdMaxExclusive.");
        if (Gameplay.Combat.MaxHp <= 0) throw new InvalidDataException("gameplay.combat.maxHp must be positive.");
        if (Gameplay.Combat.Skills.All().Any(x => x == 0)) throw new InvalidDataException("gameplay.combat.skills contains id 0.");
        if (Gameplay.Combat.Charges.Length == 0) throw new InvalidDataException("gameplay.combat.charges must not be empty.");
        foreach (var charge in Gameplay.Combat.Charges)
        {
            _ = Gameplay.Combat.Skills.ByName(charge.Skill);
            if (charge.Max == 0 || charge.Current > charge.Max || charge.Period < 0)
                throw new InvalidDataException($"Invalid gameplay.combat.charges entry for '{charge.Skill}'.");
        }
        if (Gameplay.WebTraversal.SharedBuffIds.Length == 0)
            throw new InvalidDataException("gameplay.webTraversal.sharedBuffIds must not be empty.");
        if (!Gameplay.WebTraversal.SharedBuffIds.Contains(Gameplay.WebTraversal.PersistentGrappleBuffId))
            throw new InvalidDataException("persistentGrappleBuffId must also be present in sharedBuffIds.");
        if (Gameplay.WebTraversal.GrappleRearmDelayMs < 0)
            throw new InvalidDataException("gameplay.webTraversal.grappleRearmDelayMs must be >= 0.");
        if (Gameplay.Vehicles.Enabled)
        {
            if (Gameplay.Vehicles.FleetIds.Length == 0) throw new InvalidDataException("gameplay.vehicles.fleetIds must not be empty when vehicles are enabled.");
            if (Gameplay.Vehicles.MinimumApproachMeters <= 0 || Gameplay.Vehicles.DesiredApproachMeters < Gameplay.Vehicles.MinimumApproachMeters)
                throw new InvalidDataException("gameplay.vehicles approach distances are invalid.");
            if (Gameplay.Vehicles.SearchRadiusMeters < Gameplay.Vehicles.DesiredApproachMeters)
                throw new InvalidDataException("gameplay.vehicles.searchRadiusMeters must cover desiredApproachMeters.");
            if (string.IsNullOrWhiteSpace(Paths.ZoneGraphLanes)) throw new InvalidDataException("paths.zoneGraphLanes must not be empty while vehicles are enabled.");
        }
        if (Ui.UidLabel.Enabled && string.IsNullOrWhiteSpace(Ui.UidLabel.Text))
            throw new InvalidDataException("ui.uidLabel.text must not be empty when ui.uidLabel.enabled=true.");
        if (Ui.CutscenePanel.Enabled)
        {
            if (string.IsNullOrWhiteSpace(Ui.CutscenePanel.Host))
                throw new InvalidDataException("ui.cutscenePanel.host must not be empty when enabled.");
            Port(Ui.CutscenePanel.Port, "ui.cutscenePanel.port");
        }
        if (string.IsNullOrWhiteSpace(Logging.Directory))
            throw new InvalidDataException("logging.directory must not be empty.");
        if (Logging.Packets.MaxBodyBytes < 0)
            throw new InvalidDataException("logging.packets.maxBodyBytes must be >= 0 (0 means unlimited).");
        if (string.IsNullOrWhiteSpace(Paths.ClientConfigs))
            throw new InvalidDataException("paths.clientConfigs must not be empty.");
        if (string.IsNullOrWhiteSpace(Paths.RuntimeFastpatch))
            throw new InvalidDataException("paths.runtimeFastpatch must not be empty.");
        if (Debug.Enabled)
        {
            if (string.IsNullOrWhiteSpace(Debug.Host)) throw new InvalidDataException("debug.host must not be empty when debug is enabled.");
            Port(Debug.Port, "debug.port");
        }
    }
}

public sealed class ClientSettings
{
    public int Version { get; init; }
    public string ArtifactVersion { get; init; } = string.Empty;
    public int ServerId { get; init; }
    public int Aid { get; init; }
    public string RpcMd5 { get; init; } = string.Empty;
    public int NoMoreHotfixPatchError { get; init; }
}

public sealed class NetworkSettings
{
    public string BindHost { get; init; } = string.Empty;
    public string AdvertisedHost { get; init; } = string.Empty;
    public int[] LoginPorts { get; init; } = [];
    public int GamePort { get; init; }
    public ProxyNetworkSettings Proxy { get; init; } = new();
}

public sealed class ProxyNetworkSettings
{
    public int HttpsPort { get; init; }
    public int HttpPort { get; init; }
    public int LoginListPort { get; init; }
    public int LoginTcpPort { get; init; }
    public int GameTcpPort { get; init; }
    public int SceneSubPort { get; init; }
    public string UpdateHost { get; init; } = string.Empty;
    public string CertificatePassphrase { get; init; } = string.Empty;
}

public sealed class PlayerSettings
{
    public ulong Pid { get; init; }
    public ulong InitialUnitId { get; init; }
    public uint InitialSpiritTemplateId { get; init; }
    public string AccountId { get; init; } = string.Empty;
    public string UserName { get; init; } = string.Empty;
    public string DisplayName { get; init; } = string.Empty;
    public string LoginToken { get; init; } = string.Empty;
    public string GameToken { get; init; } = string.Empty;
    public string ShareToken { get; init; } = string.Empty;
    public string FpPassToken { get; init; } = string.Empty;
    public string Skey { get; init; } = string.Empty;
    public uint LoginUniverseId { get; init; }
}

public sealed class WorldSettings
{
    public uint RaidId { get; init; }
    public ulong SceneInstanceId { get; init; }
    public uint UniverseId { get; init; }
    public Vector3Settings Spawn { get; init; } = new();
    public float Facing { get; init; }
    public bool EntryOpeningEnabled { get; init; }
    public WorldContentSettings Content { get; init; } = new();
}

/// <summary>
/// World content streaming.  The client renders lampposts and street props from
/// its baked SceneItemBlob once the server pushes the destructible grid window;
/// gadgets (lifts, doors, vending machines) use the client build's own baked
/// GadgetBlob through SyncGadgetGridAOIDecrease; DynamicGOs are re-seeded while
/// the client finishes loading its world headers. All data comes from paths.worldData.
/// </summary>
public sealed class WorldContentSettings
{
    /// <summary>Master switch for all world-content streaming.</summary>
    public bool Enabled { get; init; } = true;

    /// <summary>Legacy primary scene name retained for config compatibility.</summary>
    public string Scene { get; init; } = "WorldMap_Release";

    /// <summary>
    /// Build-local scene data allowed to supplement the current free-roam scene.
    /// FIX23V uses only WorldMap_Release for this server/raid; SceneItems themselves are
    /// resolved from the client SceneItemBlob and do not use this list as a placement whitelist.
    /// </summary>
    public string[] ProductionScenes { get; init; } = ["WorldMap_Release"];

    public SceneItemStreamSettings SceneItems { get; init; } = new();
    public GadgetStreamSettings Gadgets { get; init; } = new();
    public DynamicGoStreamSettings DynamicGo { get; init; } = new();
}

/// <summary>Grid window for baked scene items (lampposts, props, breakables).</summary>
public sealed class SceneItemStreamSettings
{
    public bool Enabled { get; init; } = true;

    /// <summary>Window half-size in 40m cells (7x7 window at 3).</summary>
    public int RadiusCells { get; init; } = 3;

    /// <summary>Cells beyond this distance from the player are unloaded (hysteresis) when retention is disabled.</summary>
    public int UnloadRadiusCells { get; init; } = 6;

    /// <summary>Keep visited cells resident to avoid destroy/re-create races while streaming quickly.</summary>
    public bool RetainVisitedCells { get; init; } = true;

    /// <summary>When true, request every authored object in each production cell instead of applying the extracted sector filter.</summary>
    public bool LoadAllSectors { get; init; } = false;

    /// <summary>Exclude client-authored SceneItem entries whose build-local path is explicitly marked temp/test/debug.</summary>
    public bool ExcludeTestItems { get; init; } = true;

    /// <summary>Max new cells pushed per stream so the load staggers instead of hitching.</summary>
    public int LoadBudgetCells { get; init; } = 49;
}

/// <summary>Grid window for client-baked gadgets (lifts, doors, vending machines).</summary>
public sealed class GadgetStreamSettings
{
    public bool Enabled { get; init; } = true;

    public int RadiusCells { get; init; } = 3;
    public int UnloadRadiusCells { get; init; } = 6;
    public bool RetainVisitedCells { get; init; } = true;

    /// <summary>When true, request every authored gadget in each production cell instead of applying the extracted sector filter.</summary>
    public bool LoadAllSectors { get; init; } = false;

    /// <summary>Maximum new production cells sent per update. A 7x7 radius-3 window is 49 cells.</summary>
    public int LoadBudgetCells { get; init; } = 49;
}

/// <summary>DynamicGo re-seeding after gameplay-ready.</summary>
public sealed class DynamicGoStreamSettings
{
    public bool Enabled { get; init; } = true;

    /// <summary>How many times SyncDynamicGoActiveInfo is re-sent (client headers load async).</summary>
    public int SeedAttempts { get; init; } = 12;

    /// <summary>Activate every DynamicGo id found in the build-4229938 probe.</summary>
    public bool ActivateAllKnown { get; init; } = true;

    /// <summary>Force explicitly-authored test/temp/debug DynamicGo blockouts inactive.</summary>
    public bool ExcludeTestPlaceholders { get; init; } = true;
}

public sealed class Vector3Settings
{
    public float X { get; init; }
    public float Y { get; init; }
    public float Z { get; init; }
    internal Vec3 ToVec3() => new(X, Y, Z);
}

public sealed class ContentSettings
{
    public RosterSettings Roster { get; init; } = new();
    public uint[] ExcludedUnlockSystems { get; init; } = [];
    public bool IncludePhoneBottomApps { get; init; }
}

public sealed class RosterSettings
{
    public uint TemplateIdMin { get; init; }
    public uint TemplateIdMaxExclusive { get; init; }
    public uint[] ExcludedTemplateIds { get; init; } = [];
    public uint GenericPlaceholderIconId { get; init; }
    public ulong UnitIdBase { get; init; }
    public int DefaultUrbanJob { get; init; }
}

public sealed class GameplaySettings
{
    public SwitchAnimationSettings SwitchAnimations { get; init; } = new();
    public CombatSettings Combat { get; init; } = new();
    public WebTraversalSettings WebTraversal { get; init; } = new();
    public VehicleSettings Vehicles { get; init; } = new();
}

public sealed class VehicleSettings
{
    public bool Enabled { get; init; } = true;
    public uint[] FleetIds { get; init; } = [];
    public float DesiredApproachMeters { get; init; } = 32f;
    public float MinimumApproachMeters { get; init; } = 24f;
    public float SearchRadiusMeters { get; init; } = 80f;
    public int ZoneStorageDataHandle { get; init; } = -1044702623;
}

public sealed class SwitchAnimationSettings
{
    public int SwitchType { get; init; }
    public string CommonTimelinePrefix { get; init; } = string.Empty;
    public bool AvoidImmediateRepeat { get; init; }
}

public sealed class CombatSettings
{
    public float MaxHp { get; init; }
    public float Attack { get; init; }
    public float Defense { get; init; }
    public float MoveSpeedMultiplier { get; init; }
    public float PanelDamage { get; init; }
    public float PanelDefenseDeduct { get; init; }
    public uint FightStyleTypeId { get; init; }
    public uint FightStyleId { get; init; }
    public int[] DefaultUrbanAbilities { get; init; } = [];
    public WeaponSettings Weapon { get; init; } = new();
    public ResourceSettings Resource { get; init; } = new();
    public SkillSettings Skills { get; init; } = new();
    public SkillChargeSettings[] Charges { get; init; } = [];
}

public sealed class WeaponSettings
{
    public uint TemplateId { get; init; }
    public ulong InstanceId { get; init; }
}

public sealed class ResourceSettings
{
    public uint Id { get; init; }
    public float Max { get; init; }
}

public sealed class SkillSettings
{
    public uint Common { get; init; }
    public uint PressCommon { get; init; }
    public uint HeavyCommon { get; init; }
    public uint Dodge { get; init; }
    public uint DodgeAttack { get; init; }
    public uint GrappleAttack { get; init; }
    public uint Active { get; init; }
    public uint Unique { get; init; }

    internal IEnumerable<uint> All()
    {
        yield return Common;
        yield return PressCommon;
        yield return HeavyCommon;
        yield return Dodge;
        yield return DodgeAttack;
        yield return GrappleAttack;
        yield return Active;
        yield return Unique;
    }

    internal uint ByName(string name) => name.ToLowerInvariant() switch
    {
        "common" => Common,
        "presscommon" => PressCommon,
        "heavycommon" => HeavyCommon,
        "dodge" => Dodge,
        "dodgeattack" => DodgeAttack,
        "grappleattack" => GrappleAttack,
        "active" => Active,
        "unique" => Unique,
        _ => throw new InvalidDataException($"Unknown gameplay.combat.charges skill name '{name}'.")
    };
}

public sealed class SkillChargeSettings
{
    public string Skill { get; init; } = string.Empty;
    public uint Current { get; init; }
    public uint Max { get; init; }
    public float Period { get; init; }
}

public sealed class WebTraversalSettings
{
    public uint MaleProtagonistId { get; init; }
    public uint FemaleProtagonistId { get; init; }
    public uint PersistentGrappleBuffId { get; init; }
    public int GrappleRearmDelayMs { get; init; }
    public uint[] SharedBuffIds { get; init; } = [];
    public uint[] MaleExtraBuffIds { get; init; } = [];
    public uint[] FemaleExtraBuffIds { get; init; } = [];
    public uint[] ForbidStateIds { get; init; } = [];
}

public sealed class UiSettings
{
    /// <summary>White text rendered next to UID. This is the user-facing watermark setting.</summary>
    public UidLabelSettings UidLabel { get; init; } = new();
    public bool RemoveStockConfidentialLabel { get; init; }
    public CutscenePanelSettings CutscenePanel { get; init; } = new();
}

public sealed class CutscenePanelSettings
{
    public bool Enabled { get; init; } = true;
    public string Host { get; init; } = "127.0.0.1";
    public int Port { get; init; } = 17666;
}

public sealed class UidLabelSettings
{
    public bool Enabled { get; init; }
    public string Text { get; init; } = string.Empty;
}

public sealed class LoggingSettings
{
    /// <summary>Project-relative directory for console and packet logs.</summary>
    public string Directory { get; init; } = string.Empty;
    public ConsoleLoggingSettings Console { get; init; } = new();
    public PacketLoggingSettings Packets { get; init; } = new();
}

public sealed class ConsoleLoggingSettings
{
    public bool Enabled { get; init; }
}

public sealed class PacketLoggingSettings
{
    public bool Enabled { get; init; }
    public bool IncludeHex { get; init; }
    public bool IncludeDecoded { get; init; }
    /// <summary>Maximum packet body bytes written as hex; 0 means unlimited.</summary>
    public int MaxBodyBytes { get; init; }
}

public sealed class PathSettings
{
    /// <summary>Directory containing client JSON configs such as FightSpiritConfig.json.</summary>
    public string ClientConfigs { get; init; } = string.Empty;
    public string ZoneGraphLanes { get; init; } = string.Empty;

    /// <summary>Directory with extracted world data (Gadget.json, SceneItem.json,
    /// Destructible.json, gadget_cells.json, gadget_placements.json).</summary>
    public string WorldData { get; init; } = string.Empty;

    /// <summary>Disposable generated fastpatch staging directory.</summary>
    public string RuntimeFastpatch { get; init; } = ".runtime/fastpatch";
}

/// <summary>Localhost-only HTTP debug API for the Python debug panel (status, garage resync, teleport).</summary>
public sealed class DebugSettings
{
    public bool Enabled { get; init; } = true;
    public string Host { get; init; } = "127.0.0.1";
    public int Port { get; init; } = 5809;
}

internal static class PrivateServerConfigStore
{
    private static PrivateServerConfig? _current;
    private static string? _configPath;

    internal static PrivateServerConfig Current => _current
        ?? throw new InvalidOperationException("PrivateServerConfigStore.Initialize must run before protocol/gameplay code.");

    internal static string ConfigPath => _configPath
        ?? throw new InvalidOperationException("PrivateServerConfigStore.Initialize must run before path resolution.");

    private static string? _projectRoot;

    internal static string ProjectRoot => _projectRoot
        ?? throw new InvalidOperationException("PrivateServerConfigStore.Initialize must run before path resolution.");

    internal static void Initialize(PrivateServerConfig config, string configPath)
    {
        _current = config;
        _configPath = Path.GetFullPath(configPath);
        _projectRoot = FindProjectRoot(_configPath);
    }

    private static string FindProjectRoot(string configPath)
    {
        var explicitRoot = Environment.GetEnvironmentVariable("Ananta_ROOT");
        if (!string.IsNullOrWhiteSpace(explicitRoot))
            return Path.GetFullPath(explicitRoot);

        static string? SearchUp(string? start)
        {
            if (string.IsNullOrWhiteSpace(start)) return null;
            var first = new DirectoryInfo(Path.GetFullPath(start));

            // Prefer the solution root. A copied config may also exist under bin/Debug, but that
            // directory is not the project root and must not become the base for ClientData/.runtime.
            for (var current = first; current is not null; current = current.Parent)
                if (File.Exists(Path.Combine(current.FullName, "AnantaPS.sln")))
                    return current.FullName;

            // Standalone deployments may not contain the solution file. In that case a config
            // directory is the best available root marker.
            for (var current = first; current is not null; current = current.Parent)
                if (File.Exists(Path.Combine(current.FullName, "config", "private-server.json")))
                    return current.FullName;

            return null;
        }

        var fromConfig = SearchUp(Path.GetDirectoryName(configPath));
        if (fromConfig is not null) return fromConfig;
        var fromBase = SearchUp(AppContext.BaseDirectory);
        if (fromBase is not null) return fromBase;
        var fromCurrent = SearchUp(Directory.GetCurrentDirectory());
        if (fromCurrent is not null) return fromCurrent;

        throw new DirectoryNotFoundException(
            "Cannot locate the Ananta project root. Set Ananta_ROOT or launch from the project directory.");
    }

    internal static string ResolveProjectPath(string configuredPath)
        => Path.IsPathRooted(configuredPath)
            ? Path.GetFullPath(configuredPath)
            : Path.GetFullPath(Path.Combine(ProjectRoot, configuredPath));
}

internal static class PrivateServerConfigLoader
{
    private static readonly JsonSerializerOptions JsonOptions = new()
    {
        PropertyNameCaseInsensitive = true,
        ReadCommentHandling = JsonCommentHandling.Skip,
        AllowTrailingCommas = true,
        Converters = { new System.Text.Json.Serialization.JsonStringEnumConverter(System.Text.Json.JsonNamingPolicy.CamelCase) },
    };

    internal static (PrivateServerConfig Config, string Path) Load()
    {
        var explicitPath = Environment.GetEnvironmentVariable("Ananta_CONFIG");
        var candidates = new List<string>();
        if (!string.IsNullOrWhiteSpace(explicitPath)) candidates.Add(explicitPath);
        candidates.Add(Path.Combine(Directory.GetCurrentDirectory(), "config", "private-server.json"));
        candidates.Add(Path.Combine(AppContext.BaseDirectory, "config", "private-server.json"));

        var path = candidates.Select(Path.GetFullPath).FirstOrDefault(File.Exists)
            ?? throw new FileNotFoundException("Cannot find config/private-server.json. Set Ananta_CONFIG to an explicit path if needed.");

        var json = File.ReadAllText(path);
        var config = JsonSerializer.Deserialize<PrivateServerConfig>(json, JsonOptions)
            ?? throw new InvalidDataException($"Configuration file is empty: {path}");
        config.Validate();
        return (config, path);
    }
}
