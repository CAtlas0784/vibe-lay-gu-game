using Ananta.SDK.Logging;
using Ananta.Server.App;
using Ananta.Server.Configuration;
using Ananta.Server.Protocol.Client4229938;

var (config, configPath) = PrivateServerConfigLoader.Load();
PrivateServerConfigStore.Initialize(config, configPath);

// Start the console mirror before the first application log line. Run-All supplies the same
// run id/files to the Node proxy, so both processes land in one console-latest/archive pair.
RuntimeLogs.Initialize(
    PrivateServerConfigStore.ResolveProjectPath(config.Logging.Directory),
    Environment.GetEnvironmentVariable("Ananta_RUN_ID"),
    config.Logging.Console.Enabled,
    config.Logging.Packets.Enabled,
    config.Logging.Packets.IncludeHex,
    config.Logging.Packets.IncludeDecoded,
    config.Logging.Packets.MaxBodyBytes);


using var shutdown = new CancellationTokenSource();
Console.CancelKeyPress += (_, e) =>
{
    e.Cancel = true;
    shutdown.Cancel();
};

await new PrivateServerApplication(config).RunAsync(shutdown.Token);
