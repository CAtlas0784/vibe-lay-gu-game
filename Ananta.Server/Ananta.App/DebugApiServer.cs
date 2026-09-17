using System.Net;
using System.Text;
using System.Text.Json;
using Ananta.SDK.Network;
using Ananta.SDK.Serialization;
using Ananta.Server.ClientData.Client4229938;
using Ananta.Server.Configuration;
using Ananta.Server.Handlers.Game;
using Ananta.Server.Protocol.Client4229938;
using Ananta.Server.RpcTypes.Client4229938;
using SceneMethods = Ananta.Server.RpcTypes.Client4229938.Methods.GameScene;

namespace Ananta.Server.App;

/// <summary>
/// Localhost-only HTTP debug server: serves the embedded debug panel (GET /)
/// plus the JSON API for it. Optional: enable via config "debug".
/// Never exposed outside 127.0.0.1 by default.
/// </summary>
internal sealed class DebugApiServer(PrivateServerConfig config, GameSessionHub hub) : IDisposable
{
    private static readonly JsonSerializerOptions JsonOptions = new()
    {
        PropertyNamingPolicy = JsonNamingPolicy.CamelCase,
        WriteIndented = false,
    };

    private static readonly Lazy<byte[]> PanelHtml = new(() =>
    {
        using var stream = typeof(DebugApiServer).Assembly
            .GetManifestResourceStream("Ananta.App.DebugPanel.index.html")
            ?? throw new InvalidOperationException("Embedded debug panel is missing (Ananta.App.DebugPanel.index.html).");
        using var ms = new MemoryStream();
        stream.CopyTo(ms);
        return ms.ToArray();
    });

    private readonly HttpListener _listener = new();
    private readonly CancellationTokenSource _cts = new();
    private Task? _loop;

    internal void Start()
    {
        var prefix = $"http://{config.Debug.Host}:{config.Debug.Port}/";
        _listener.Prefixes.Add(prefix);
        _listener.Start();
        _loop = LoopAsync(_cts.Token);
        Console.WriteLine($"[DEBUG-API] panel+api on {prefix}");
    }

    internal void Stop()
    {
        try { _cts.Cancel(); } catch { }
        try { _listener.Stop(); } catch { }
        try { _listener.Close(); } catch { }
    }

    public void Dispose() => Stop();

    private async Task LoopAsync(CancellationToken token)
    {
        while (!token.IsCancellationRequested)
        {
            HttpListenerContext ctx;
            try
            {
                ctx = await _listener.GetContextAsync().WaitAsync(token);
            }
            catch (OperationCanceledException)
            {
                break;
            }
            catch (HttpListenerException)
            {
                break;
            }
            catch (Exception ex)
            {
                Console.WriteLine($"[DEBUG-API] accept failed: {ex.Message}");
                continue;
            }

            _ = HandleAsync(ctx, token);
        }
    }

    private async Task HandleAsync(HttpListenerContext ctx, CancellationToken token)
    {
        try
        {
            var path = ctx.Request.Url?.AbsolutePath ?? "/";
            var method = ctx.Request.HttpMethod.ToUpperInvariant();

            if (method == "GET" && (path == "/" || path == "/index.html"))
                await WriteHtmlAsync(ctx, token);
            else if (method == "GET" && path == "/api/status")
                await WriteJsonAsync(ctx, Status(), token);
            else if (method == "GET" && path == "/api/fleet")
                await WriteJsonAsync(ctx, Fleet(), token);
            else if (method == "POST" && path == "/api/garage/resync")
                await WriteJsonAsync(ctx, await GarageResyncAsync(token), token);
            else if (method == "POST" && path == "/api/garage/unlock-all")
                await WriteJsonAsync(ctx, await GarageUnlockAllAsync(token), token);
            else if (method == "POST" && path == "/api/player/teleport")
                await WriteJsonAsync(ctx, await TeleportAsync(await ReadBodyAsync(ctx.Request, token), token), token);
            else if (method == "POST" && path == "/api/vehicle/spawn")
                await WriteJsonAsync(ctx, await VehicleSpawnAsync(await ReadBodyAsync(ctx.Request, token), token), token);
            else if (method == "POST" && path == "/api/vehicle/to-me")
                await WriteJsonAsync(ctx, await VehicleToMeAsync(await ReadBodyAsync(ctx.Request, token), token), token);
            else if (method == "POST" && path == "/api/vehicle/goto")
                await WriteJsonAsync(ctx, await VehicleGotoAsync(await ReadBodyAsync(ctx.Request, token), token), token);
            else if (method == "POST" && path == "/api/vehicle/remove")
                await WriteJsonAsync(ctx, await VehicleRemoveAsync(await ReadBodyAsync(ctx.Request, token), token), token);
            else if (method == "POST" && path == "/api/vehicle/enter")
                await WriteJsonAsync(ctx, await VehicleEnterAsync(await ReadBodyAsync(ctx.Request, token), token), token);
            else if (method == "POST" && path == "/api/vehicle/exit")
                await WriteJsonAsync(ctx, await VehicleExitAsync(token), token);
            else if (method == "GET" && path == "/api/time")
                await WriteJsonAsync(ctx, TimeStatus(), token);
            else if (method == "POST" && path == "/api/time/set")
                await WriteJsonAsync(ctx, await TimeSetAsync(await ReadBodyAsync(ctx.Request, token), token), token);
            else if (method == "POST" && path == "/api/weather/set")
                await WriteJsonAsync(ctx, await WeatherSetAsync(await ReadBodyAsync(ctx.Request, token), token), token);
            else if (method == "POST" && path == "/api/weather/fog")
                await WriteJsonAsync(ctx, await WeatherFogAsync(await ReadBodyAsync(ctx.Request, token), token), token);
            else if (method == "POST" && path == "/api/world/switch-scene")
                await WriteJsonAsync(ctx, await SwitchSceneAsync(await ReadBodyAsync(ctx.Request, token), token), token);
            else if (method == "POST" && path == "/api/unstuck/blackscreen")
                await WriteJsonAsync(ctx, await UnstuckBlackScreenAsync(token), token);
            else if (method == "POST" && path == "/api/player/rollback-10s")
                await WriteJsonAsync(ctx, await RollbackPositionAsync(token), token);
            else if (method == "POST" && path == "/api/player/toggle-clothes")
                await WriteJsonAsync(ctx, await ToggleClothesAsync(token), token);
            else if (method == "POST" && path == "/api/enemy/spawn")
                await WriteJsonAsync(ctx, await SpawnEnemyAsync(await ReadBodyAsync(ctx.Request, token), token), token);
            else if (method == "POST" && path == "/api/cutscene/play")
                await WriteJsonAsync(ctx, await PlayCutsceneAsync(await ReadBodyAsync(ctx.Request, token), token), token);
            else if (method == "POST" && path == "/api/timeline/play")
                await WriteJsonAsync(ctx, await PlayTimelineAsync(await ReadBodyAsync(ctx.Request, token), token), token);
            else if (method == "POST" && path == "/api/minigame/launch")
                await WriteJsonAsync(ctx, await LaunchMinigameAsync(await ReadBodyAsync(ctx.Request, token), token), token);
            else if (method == "GET" && path == "/api/cutscene/catalog")
                await WriteJsonAsync(ctx, CutsceneCatalog(), token);
            else if (method == "POST" && path == "/api/npc/spawn")
                await WriteJsonAsync(ctx, await NpcSpawnAsync(await ReadBodyAsync(ctx.Request, token), token), token);
            else if (method == "GET" && path == "/api/scenes")
                await WriteJsonAsync(ctx, Scenes(), token);
            else if (method == "GET" && path == "/api/npc/catalog")
                await WriteJsonAsync(ctx, NpcCatalog(ctx.Request), token);
            else
                await WriteJsonAsync(ctx, new { ok = false, error = "unknown route" }, token, 404);
        }
        catch (Exception ex)
        {
            try { await WriteJsonAsync(ctx, new { ok = false, error = ex.Message }, token, 500); } catch { }
        }
    }

    private object Status()
    {
        var session = hub.Current;
        if (session is null)
            return new { online = false };

        var pid = Profile.PlayerPid;
        Vec3 pos = Profile.WorldSpawn;
        Vec3 rot = new(0f, Profile.WorldFacing, 0f);
        var hasFix = false;
        var ready = false;
        var activeUnit = Profile.InitialUnitId;

        uint activeRaid = Profile.RaidId;
        ulong activeInstance = Profile.SceneInstanceId;
        uint activeUniverse = Profile.UniverseId;

        if (session.Items.TryGetValue(GameRouter.WorldStateKey, out var raw) && raw is WorldEntryState state)
        {
            lock (state.SyncRoot)
            {
                pos = state.LastReportedPlayerPosition;
                rot = state.LastReportedPlayerRotation;
                hasFix = state.HasLastReportedPlayerTransform;
                ready = state.Ready;
                if (state.ActiveSpiritUnitId != 0)
                    activeUnit = state.ActiveSpiritUnitId;
                activeRaid = state.ActiveRaidId;
                activeInstance = state.ActiveInstanceId;
                activeUniverse = state.ActiveUniverseId;
            }
        }

        var summoned = GameRouter.SummonedSnapshot()
            .Select(v => new { entityId = v.EntityId, configId = v.ConfigId, x = v.X, y = v.Y, z = v.Z, yaw = v.Yaw, hasFix = v.HasFix })
            .ToList();
        var (inVehicle, inSeat) = GameRouter.VehicleSeatSnapshot(session);
        var (hour, minute, fix, hasTime) = ReadSessionTime(session);

        return new
        {
            online = true,
            pid,
            ready,
            activeUnit,
            world = new { raidId = activeRaid, instanceId = activeInstance, universeId = activeUniverse },
            player = new { x = pos.X, y = pos.Y, z = pos.Z, yaw = rot.Y, hasFix },
            spawn = new { x = Profile.WorldSpawn.X, y = Profile.WorldSpawn.Y, z = Profile.WorldSpawn.Z },
            summoned,
            inVehicle,
            inSeat,
            fleetCount = config.Gameplay.Vehicles.FleetIds.Length,
            hour,
            minute,
            fix,
            hasTime,
        };
    }

    private object Fleet()
    {
        return VehicleCatalog.All
            .Select(v => new { id = v.Id, name = v.Name, cat = v.Category })
            .ToList();
    }

    /// <summary>
    /// Full vehicle catalog (other team's list, 2026-09-09): id + display name + category.
    /// Includes broken/undrivable entries (marked in the name) — spawn is warn-and-allow,
    /// the client has the final say. Single source for the panel dropdowns.
    /// </summary>
    private static class VehicleCatalog
    {
        internal sealed record Entry(uint Id, string Name, string Category);

        internal static readonly Entry[] All =
        [
            new(81000002, "Korou Transporter M - Isuzu Elf Tow Truck with a hook [Broken cabin and no wheels]", "truck"),
            new(81000004, "MM Inferno 3000 - Firetruck", "truck"),
            new(81000005, "Erebos Black Box - Mercedes Actros (Seymours Truck)", "truck"),
            new(81000006, "Test_Toilet - Invisible drivable vehicle", "special"),
            new(81000007, "Sunset GT X Specter (Coupe)", "sport"),
            new(81000008, "Sunset GT X Specter (Coupe)", "sport"),
            new(81000009, "Test_Yacht - Flat Rectangle", "water"),
            new(81000010, "Shikage Speed Tour s200 - Speedboat", "water"),
            new(81001001, "Sunset Skywing - Default Sedan", "regular"),
            new(81001002, "Korou RV6 - Subaru Legacy Wagon Gen 5", "regular"),
            new(81001003, "Kazama Voyage - Toyota HiAce H300 (6gen)", "van"),
            new(81001005, "Kazama Sandstorm 70 Classic - Toyota Land Cruiser 70 Stock [Old Model]", "suv"),
            new(81001006, "Kazama CRN6 - Toyota Comfort", "regular"),
            new(81001007, "Kazama Grace - Toyota Corolla E170 (11gen) [Unfinished New Model]", "regular"),
            new(81001008, "Sunset Flyer - Honta Fit (Gen 2) [Unfinished New Model]", "regular"),
            new(81001009, "Kazama Elegance - Toyota Crown (14-15gen)", "regular"),
            new(81001010, "Aico Prisma C5 - Audi A6 (C8)", "regular"),
            new(81001011, "Sunset NEO:E - 3door Hatchback EV", "regular"),
            new(81001012, "Erebos Cygnus C380 - Mercedes GL", "regular"),
            new(81001013, "Smove S3 - Mazda 3 BM (3gen)", "regular"),
            new(81001014, "Stahlwerk Speedster S - Volkswagen Golf Gen 8", "regular"),
            new(81001015, "Stahlwerk Prosper - Volkswagen Passat B8", "regular"),
            new(81001016, "Kazama Venture - Toyota Prius 5", "regular"),
            new(81001017, "Pulse Type 3 - Tesla Model 3", "regular"),
            new(81001018, "Sunset Skyward - Sedan, Looks like Audi A5", "regular"),
            new(81001019, "Kazama Traveller 3 - Toyota RAV4", "suv"),
            new(81001020, "Kazama Prestige - Toyota HiAce  Gen 6 [Unfinished Model]", "van"),
            new(81001021, "Terra Nimbus S5 (Tengyun Stellaride) - Small Sedan [Unfinished Model]", "van"),
            new(81001022, "Stalwerk Prosper T2 - Volkswagen Passat B2 Sedan", "regular"),
            new(81001023, "Starway Journey (Chronix Voyage) - Subaru Levorg", "regular"),
            new(81001024, "Erebos T38 Enterprise - Mercedes V-Class (Vito) Gen 3 (W447)", "van"),
            new(81001026, "Tengyun CloudSweet (腾云·云朵糖) - Changan Lumin", "regular"),
            new(81001027, "Pulse Type E = Tesla Model Y", "regular"),
            new(81001028, "Erebos Orion E32 L - Mercedes C-Class V206 (Gen 5)", "regular"),
            new(81001029, "Belkraft Ting(霆) 6 GT - BMW i4 G26", "sport"),
            new(81001030, "Sovereign SV6 - Cadillac CT6 (Gen 1)", "regular"),
            new(81001031, "Xiaosu XS 009 - Xiaomi SkyNomad N90", "regular"),
            new(81001032, "Stalwerk SurgeRise - Volkswagen Polo 4 Sedan", "regular"),
            new(81001034, "Belrkaft ??? - BMW iX3 (2020)", "suv"),
            new(81001038, "??? ??? - Unfinished SUV", "suv"),
            new(81002001, "Sunset GT-7 - Honda Integra Type R Gen 3", "sport"),
            new(81002002, "Specter GTR-S55 Convertible - Nissan GTR R35 Convertible [Low-Poly Model]", "sport"),
            new(81002006, "Smove SR-5 - Mazda Miata MX-5 ND", "sport"),
            new(81002007, "PICO Boxer Cat R - Mini Cooper S Convertible", "sport"),
            new(81002008, "Rowden Cerberus - 67 Ford Mustang Restomod", "sport"),
            new(81002009, "Sunset Selena - Toyota 2000GT-ish Sportscar", "sport"),
            new(81002010, "Korou VeloWing SRX - Subaru WRX STI VA", "regular"),
            new(81002011, "Merse RZ-91 Solstice - Porsche 911 (992) Targa", "sport"),
            new(81002012, "Erebos Sirius 89 Lodestar - Mercedes S-Class W223", "regular"),
            new(81002013, "Kazama Senpu - Toyota GR86", "sport"),
            new(81002014, "Smove Night Child S7 - Mazda RX7,8,9", "sport"),
            new(81002015, "Merse RZ-91 Solstice - Porsche 911 (930)", "sport"),
            new(81002016, "Korou VeloWing SRX “Morning Star” - Subaru WRX STI Bodykit", "regular"),
            new(81002017, "Rowden Cerberus GKREW - 67 Ford Mustang Restomod", "sport"),
            new(81002018, "Belkraft Ting 4 Forged Edition (贝凯夫·霆 4 锻造版) - BMW M2 G87", "sport"),
            new(81002019, "Aico Darkside CC (奥柯·暗面 CC) - Audi TT", "sport"),
            new(81002021, "Rowden Cerberus Mad Boar Kai (洛顿·“狂猪改”) - 67 Ford Mustang Restomod", "sport"),
            new(81003001, "ReiForce Traveler W7 - Suzuki Wagon R Gen 6", "regular"),
            new(81003002, "Kazama Seaway - Toyota HiAce Gen 5", "van"),
            new(81003003, "ReiForce Lightway - Suzuki Carry Gen 7", "regular"),
            new(81003004, "Kazama Sandstorm 70 Classic - Toyota Land Cruiser 70 Stock", "suv"),
            new(81003005, "Kazama Sandstrom 70 Custom - Toyota Land Cruiser 70 Offroad Spec", "suv"),
            new(81003006, "ReiForce Dee - Suzuki Every Gen 6", "regular"),
            new(81003007, "Steeds F750 - Invisible Model, but should be a Van", "special"),
            new(81003008, "Reiforce Jim - Suzuki Jimmy", "suv"),
            new(81003009, "Kazama Express Van (Masked Malice Livery) - Toyota Quick Delivery", "van"),
            new(81003010, "Kazama Sandstorm 70 (Enemy Ver., 2 seats) - Toyota Land Cruiser 70", "suv"),
            new(81003011, "Kazama Sandstorm 70 (Enemy Ver., 4 seats) - Toyota Land Cruiser 70", "suv"),
            new(81003012, "Kazama Wasteland (Enemy Ver.) - Toyota Hilux Gen 3", "suv"),
            new(81003013, "Kazama Sandstrom 200 - Toyota Land Cruiser 1958 (2024)", "suv"),
            new(81003014, "ReiForce Kaka - Toyota WiLL Vi", "regular"),
            new(81003015, "Shikage Rampage - Yamaha YFZ450 (Quad)", "moto"),
            new(81003016, "Kazama Kanu - Toyota Hilux Gen 5", "suv"),
            new(81003017, "Korou Titan - Isuzu VehiCross", "suv"),
            new(81003018, "Warlen Frontier - Jeep Wrangler", "suv"),
            new(81003019, "Linx Squirrel - Wuling Hongguang Mini", "regular"),
            new(81003020, "Linx Carrier - Wuling Light", "regular"),
            new(81003021, "Erebos W63 Titan - Mercedes G63", "suv"),
            new(81003022, "ReiForce Cat Express - Suzuki Carry Gen 7", "regular"),
            new(81003023, "Warren Longhorn 1500 (沃伦·长角 1500) - Invisible F350-ish Pickup Truck", "special"),
            new(81003024, "Warlen Frontier Mad Boar Kai - Jeep Wrangler", "suv"),
            new(81004001, "Kazama CRN6 Taxi - Toyota Comfort Taxi (Undrivable)", "regular"),
            new(81004002, "Kazama Elegance NCCA - Toyota Crown (14-15gen) Police", "regular"),
            new(81004003, "MM RockBreaker 5 - MAN TGS Dump Truck", "truck"),
            new(81004004, "Kazama NT-Comfort - Toyota Sienta JPN Taxi (Undrivable)", "regular"),
            new(81004005, "MM M300T - MAN TGS Cement Mixer Truck", "truck"),
            new(81004006, "MM M300T - MAN TGS Dump Truck", "truck"),
            new(81004007, "MM M300 (With pivot-fixed container trailer) - MAN TGS Hauling Truck", "truck"),
            new(81004008, "MM M300 (With pivot-fixed container trailer) - MAN TGS Hauling Truck", "truck"),
            new(81004009, "MM M300 (With pivot-fixed container trailer) - MAN TGS Hauling Truck", "truck"),
            new(81004010, "MM M300 (With pivot-fixed tanker trailer) - MAN TGS Hauling Truck", "truck"),
            new(81004011, "Kazama Seaway EMS - Toyota HiAce Gen 5 Ambulance", "van"),
            new(81004012, "MM Trust 350 - Forklift", "truck"),
            new(81004013, "Korou MT600 - Bus", "van"),
            new(81004014, "MM Inferno 3000 - Firetruck (on cbt2 had dirty water)", "truck"),
            new(81004015, "Kazama CRN6 Taxi - Toyota Comfort Taxi (Undrivable)", "regular"),
            new(81004016, "Kazama Elegant NCCA - Toyota Crown (14-15gen) Police [Labeled as Kazama CRN6-P]", "regular"),
            new(81004017, "Korou Transporter M - Isuzu Elf Stripped", "truck"),
            new(81004018, "Korou Transporter M - Isuzu Elf Flatbed", "truck"),
            new(81004019, "Korou Transporter M - Isuzu Elf Flatbed Tow Truck", "truck"),
            new(81004020, "Korou Transporter M - Isuzu Elf Tow Truck with a Hook", "truck"),
            new(81004021, "Fusion Rhino S - Ramp Buggy", "sport"),
            new(81004022, "Korou Transporter MS - Isuzu Elf Cargo Truck", "truck"),
            new(81004023, "MM Nether Reaper - MAN TGS", "truck"),
            new(81004024, "Korou Transporter L - Isuzu Elf Livestock Truck", "truck"),
            new(81004025, "Korou Transporter MP - Isuzu Elf Refrigerator Truck", "truck"),
            new(81004026, "Kazama Elegance NCCA-P - Toyota Crown (14-15gen) (Unmarked Police)", "regular"),
            new(81004027, "Kazama Sandstorm 200 NCCA - Toyota Land Cruiser 1958 (2024) Police", "suv"),
            new(81004028, "Shikage Freeman800 NCCA - Honda NT1100", "moto"),
            new(81004029, "MM WL 500 - Wheel Loader", "truck"),
            new(81004031, "Korou Transporter M Municipal - Isuzu Elf Water Truck", "truck"),
            new(81004032, "Korou Transporter M Municipal - Isuzu Elf Garbage Truck", "truck"),
            new(81004033, "Kazama Traveller 3 Road Patrol - Toyota RAV4", "suv"),
            new(81004035, "MM EX M300 - Excavator", "truck"),
            new(81004036, "Terra SF660 - Bus", "van"),
            new(81004038, "Starway Journey (Chronix Voyage) Taxi - Subaru Levorg [Unfinished model, broken texture, undrivable]", "regular"),
            new(81004039, "MM W800 - Massey Fergusson MF8700 (Tractor)", "truck"),
            new(81004040, "Korou Transporter M - Isuzu Elf Advertisement Truck", "truck"),
            new(81004041, "Erebos T35 Armored - Mercedes Vito Сash-in-transit Van", "van"),
            new(81004042, "Korou Transporter FT - Isuzu Elf Firetruck", "truck"),
            new(81004043, "Erebos Black Box - Mercedes Actros (Seymours Truck)", "truck"),
            new(81004044, "Dodo Delivery Bot T_DeliveryCar", "special"),
            new(81005001, "Kazama CE68 - Toyota Sprinter/Corolla AE86 Trueno Hatchback", "regular"),
            new(81005002, "Sunset GT X Specter (Coupe)", "sport"),
            new(81005003, "Sunset GT X Spider (Сonvertible)", "sport"),
            new(81005004, "Kazama Wasteland - Toyota Hilux Gen 3", "suv"),
            new(81005005, "Erebos Sirius 55 XL - Mercedes Ocean Drive", "regular"),
            new(81005006, "Fusion Rhino S2 - Ramp Buggy", "sport"),
            new(81005007, "Veloce Quicksilver - Lamborghini Murcielago", "sport"),
            new(81005008, "Hoyne Bridgemont Aether - Rolls-Royce Phantom", "sport"),
            new(81005009, "Pallas Solaris - Ferrari FXXK+F90", "sport"),
            new(81005013, "Sunset ??? - Acura NSX", "sport"),
            new(81006001, "Reed Ranger - NCCA Helicopter", "air"),
            new(81006002, "Belkraft Roast 1200 - BMW R100", "moto"),
            new(81006003, "Shikage Aero - Scooter", "moto"),
            new(81006005, "Shikage WaveS200 - Speedboat", "water"),
            new(81006006, "Shikage Cat Express - Delivery Scooter (no livery)", "moto"),
            new(81006007, "Belkraft Ironclad (Enemy Bike) - BMW R18", "moto"),
            new(81006008, "Shikage Sky Shark - Jet Ski", "water"),
            new(81006009, "Sunset M125-T - Cargo Tricycle no roof", "moto"),
            new(81006010, "Shikage Freeman800 - Honda NT1100", "moto"),
            new(81006011, "Sunset M125 - Honda CBX1000", "moto"),
            new(81006012, "Sunset M125 Gale Riders - Honda CBX1000 Bosozoku", "moto"),
            new(81006013, "Shikage SL550 - Dirtbike", "moto"),
            new(81006015, "Henc Jiu TB01 - Invisible Bicycle", "special"),
            new(81006016, "Shikage Badger MK1 - Kart", "moto"),
            new(81006017, "木浆船 - Wooden Paddle Boat", "water"),
            new(81006018, "Sunset M125-T - Cargo Tricycle with roof", "moto"),
            new(81006019, "Accardi Speedy(速越) - Ducati Superleggera V4", "moto"),
            new(81006020, "FG Vision Aric - Flying Car", "air"),
            new(81006021, "Nautilus 02 (鹦鹉螺02) - Submersible", "water"),
            new(81006022, "Spade Ruifeng S8 (黑桃·锐风 S8) - Highway Bicycle", "moto"),
            new(81006023, "FG Vision Oracle - Self-Driving Limo", "regular"),
            new(81006025, "Henc Jiu Tricycle (恒久·三轮车) - Pedal Cargo Tricycle", "moto"),
            new(81006027, "Henc Jiu Rent Bicycle (恒久·共享单车)", "moto"),
            new(81006028, "SHIKAGE Badger MK2 - Bumper Car", "moto"),
            new(81006029, "Hovercraft", "water"),
            new(81006030, "Tricycle with broken model", "moto"),
            new(81006101, "Belkraft Roast 1200 - BMW R100", "moto"),
            new(81007001, "Korou RV6 - Subaru Legacy Wagon Gen 5", "regular"),
            new(81007002, "Pico Boxer Cat R - Mini Cooper S Convertible", "sport"),
            new(81007003, "Sunset GT7 - Honda Integra Type R Gen 3", "sport"),
            new(81007004, "Kazama Wasteland (Dirty) - Toyota Hilux Gen3", "suv"),
            new(81007005, "Starway Journey (Chronix Voyage) Taxi - Subaru Levorg [Unfinished model, broken texture, drivable]", "regular"),
            new(81007006, "Korou ??? - Double Decker Bus", "van"),
            new(81007007, "Reed Ranger - NCCA Helicopter", "air"),
            new(81007008, "Coffin (棺材)", "special"),
            new(81007009, "Motus Shannon MK.VI (Freelander Yeti MK2) - Milk Van", "van"),
            new(81007011, "Pico Boxer Cat R - Mini Cooper S Convertible", "sport"),
            new(81007012, "MM Inferno 3000 - Firetruck", "truck"),
            new(81007013, "Motus Hercules - Scania G-Series (pivot-locked trailer with broken texture)", "truck"),
            new(81007014, "Henc Jiu TB01 - Rent Bicycle", "moto"),
            new(81007015, "Kazama Sandstrom 200 (Dirty) - Toyota Land Cruiser 1958 (2024)", "suv"),
            new(81007016, "Shikage Aero - Scooter", "moto"),
            new(81007017, "Kazama Express Van (Masked Malice Livery) - Toyota Quick Delivery", "van"),
            new(81007018, "Sunset GT-7 - Honda Integra Type R Gen 3", "sport"),
            new(81007019, "ReiForce Traveler W7 - Suzuki Wagon R Gen 6", "regular"),
            new(81007020, "Monster Car (Old broken model)", "sport"),
            new(81007021, "ReiForce Traveler W7 - Suzuki Wagon R Gen 6", "regular"),
            new(81007022, "Sunset Flyer - Honta Fit (Gen 2) [Unfinished New Model]", "regular"),
            new(81007023, "Monster Car (Old broken model)", "sport"),
            new(81007024, "ReiForce Lightway - Suzuki Carry Gen 7", "regular"),
            new(81007025, "Kazama CRN6 Taxi - Toyota Comfort Taxi (Drivable)", "regular"),
            new(81007027, "Sunset GT X Spider (Сonvertible)", "sport"),
            new(81007028, "Kazama Sandstorm 70 Classic - Toyota Land Cruiser 70 Stock", "suv"),
            new(81007029, "Kazama CRN6 Police - Toyota Comfort Police", "regular"),
            new(81007032, "Sunset Skywing - Default Sedan", "regular"),
            new(81007033, "Sunset GT-7 - Honda Integra Type R Gen 3", "sport"),
            new(81007035, "Blinking Invisible Truck", "special"),
            new(81007036, "Blinking Invisible Truck", "special"),
            new(81007040, "ReiForce Dee - Suzuki Every Gen 6 [Broken Windshield Texture]", "regular"),
            new(81007041, "ReiForce Traveler W7 - Suzuki Wagon R Gen 6 [Low-poly, Broken Camera]", "regular"),
            new(81007042, "Blinking Invisible Truck", "special"),
            new(81007043, "Kazama CRN6 Taxi - Toyota Comfort Taxi", "regular"),
            new(81007044, "Kazama CRN6 NCCA - Toyota Comfort Police", "regular"),
            new(81007045, "Xuenong Heavy-Duty Truck (雪浓·重卡) [Broken]", "truck"),
            new(81007053, "MM M500 - MAN TGS Hauling Truck", "truck"),
            new(81007054, "Sunset GT X Specter (Coupe)", "sport"),
            new(81007055, "MM M500 - MAN TGS Hauling Truck", "truck"),
            new(81007060, "Reiforce Lingtu (?) - Suzuki Carry Gen 7", "sport"),
            new(81007063, "Kazama Express Van (Masked Malice Livery) - Toyota Quick Delivery", "van"),
            new(81007064, "Specter GT X SPIDER - Nissan GTR R35 Roofless [Low-poly]", "sport"),
            new(81007066, "Sunset GT X Specter (Coupe)", "sport"),
            new(81007068, "Erebos Sirius 55 XL - Mercedes Ocean Drive [Broken Model]", "regular"),
            new(81007069, "Kazama CE68 - Toyota Sprinter/Corolla AE86 Trueno Hatchback", "regular"),
            new(81007071, "Rowden Cerberus - 67 Ford Mustang Restomod", "sport"),
            new(81007072, "Smove SR-5 - Mazda Miata MX-5 ND", "sport"),
            new(81007073, "Kazama Voyage - Toyota HiAce H300 (6gen)", "van"),
            new(81007074, "Kazama CRN6 - Toyota Comfort", "regular"),
            new(81007075, "Motus Hercules - Scania G-Series with container trailer", "truck"),
            new(81007076, "ReiForce Dee - Suzuki Every Gen 6 [Pile of cash in opened trunk]", "regular"),
            new(81007077, "Sunset Flyer - Honta Fit (Gen 2) [Unfinished New Model]", "regular"),
            new(81007078, "Kazama Elegant NCCA - Toyota Crown (14-15gen) Police", "regular"),
            new(81007079, "Korou Transporter MS - Isuzu Elf Cargo Truck", "truck"),
            new(81007080, "Kazama Sandstorm 70 (Enemy Ver., 2 seats) - Toyota Land Cruiser 70", "suv"),
            new(81007082, "Pico Boxer Cat R (Beated texture) - Mini Cooper S Convertible", "sport"),
            new(81007083, "Kazama Voyage - Toyota HiAce H300 (6gen)", "van"),
            new(81007084, "Sunset Flyer - Honta Fit (Gen 2) [Unfinished New Model]", "regular"),
            new(81007085, "Erebos Sirius 55 XL - Mercedes Ocean Drive [Broken Model]", "regular"),
            new(81007086, "Sunset GT X Specter (Coupe)", "sport"),
            new(81007087, "Smove SR-5 - Mazda Miata MX-5 ND", "sport"),
            new(81007088, "Korou·Transporter MP - Isuzu Elf Refrigerator Truck", "truck"),
            new(81007089, "Shikage Aero - Scooter", "moto"),
            new(81007090, "Kazama CRN6 - Toyota Comfort", "regular"),
            new(81007091, "Korou Transporter MS - Isuzu Elf Cargo Truck [Vault Security Livery]", "truck"),
            new(81007092, "Korou Transporter MS - Isuzu Elf Cargo Truck", "truck"),
            new(81007093, "Kazama Sandstrom 200 - Toyota Land Cruiser 1958 (2024) [Broken Model]", "suv"),
            new(81007094, "MM Inferno 3000 - Firetruck", "truck"),
            new(81007095, "Motus Shannon MK.VI (Freelander Yeti MK2) - Milk Van", "van"),
            new(81007096, "Sunset Skywing Crash Tested - Default Sedan", "regular"),
            new(81007097, "Kazama Sandstorm 70 (Enemy Ver., 2 seats) - Toyota Land Cruiser 70", "suv"),
            new(81007098, "Kazama CRN6 - Toyota Comfort", "regular"),
            new(81007099, "Belkraft Ironclad (Enemy Bike) - BMW R18", "moto"),
            new(81007100, "Sunset M125-T - Cargo Tricycle no roof", "moto"),
            new(81007101, "Shikage Aero - Scooter", "moto"),
            new(81007102, "MM M500 - MAN TGS [from trailer, wide, immovable]", "truck"),
            new(81007103, "Shikage Speed Tour S200 on a trailer - Speedboat", "water"),
            new(81007104, "Shikage Freeman800 - Honda NT1100", "moto"),
        ];
    }

    /// <summary>
    /// Pushes the FULL catalog (all entries incl. broken/unverified) as the owned
    /// fleet. Explicit button-only action; the default auto-publish/resync stays on
    /// the verified set (config fleetIds).
    /// </summary>
    private async Task<object> GarageUnlockAllAsync(CancellationToken token)
    {
        var session = hub.Current;
        if (session is null)
            return new { ok = false, error = "no live game session (is the client in the world?)" };

        var body = new SceneMethods.AskGetUnlockedVehiclesResult
        {
            Vehicles = VehicleCatalog.All.Select(v => new SceneMethods.PlayerVehicleClientDetail
            {
                Id = v.Id,
                Parts = [],
                SuitId = 0,
                IsPersistent = true,
            }).ToList(),
        };
        var bytes = UxSerializer.Serialize(body);
        await session.NotifyAsync(MethodId.SyncAllUnlockedVehicles, bytes, token);
        session.Log.Info($"[DEBUG-API] garage UNLOCK-ALL pushed ({body.Vehicles.Count} vehicles, incl. unverified)");
        return new { ok = true, count = body.Vehicles.Count, verified = false };
    }

    private async Task<object> GarageResyncAsync(CancellationToken token)
    {
        var session = hub.Current;
        if (session is null)
            return new { ok = false, error = "no live game session (is the client in the world?)" };

        var body = new SceneMethods.AskGetUnlockedVehiclesResult
        {
            Vehicles = config.Gameplay.Vehicles.FleetIds.Select(id => new SceneMethods.PlayerVehicleClientDetail
            {
                Id = id,
                Parts = [],
                SuitId = 0,
                IsPersistent = true,
            }).ToList(),
        };
        var bytes = UxSerializer.Serialize(body);
        await session.NotifyAsync(MethodId.SyncAllUnlockedVehicles, bytes, token);
        session.Log.Info($"[DEBUG-API] garage resync pushed ({body.Vehicles.Count} vehicles)");
        return new { ok = true, count = body.Vehicles.Count };
    }

    private async Task<object> TeleportAsync(string json, CancellationToken token)
    {
        var session = hub.Current;
        if (session is null)
            return new { ok = false, error = "no live game session (is the client in the world?)" };

        float x, y, z, facing;
        try
        {
            using var doc = JsonDocument.Parse(string.IsNullOrWhiteSpace(json) ? "{}" : json);
            var root = doc.RootElement;
            x = root.TryGetProperty("x", out var px) ? (float)px.GetDouble() : throw new InvalidDataException("missing numeric 'x'");
            y = root.TryGetProperty("y", out var py) ? (float)py.GetDouble() : throw new InvalidDataException("missing numeric 'y'");
            z = root.TryGetProperty("z", out var pz) ? (float)pz.GetDouble() : throw new InvalidDataException("missing numeric 'z'");
            facing = root.TryGetProperty("facing", out var pf) ? (float)pf.GetDouble() : Profile.WorldFacing;
            if (!float.IsFinite(x) || !float.IsFinite(y) || !float.IsFinite(z) || !float.IsFinite(facing))
                throw new InvalidDataException("coordinates must be finite numbers");
        }
        catch (Exception ex)
        {
            return new { ok = false, error = $"bad request: {ex.Message}" };
        }

        ulong unitId = Profile.InitialUnitId;
        if (session.Items.TryGetValue(GameRouter.WorldStateKey, out var raw) && raw is WorldEntryState state)
        {
            lock (state.SyncRoot)
            {
                if (state.ActiveSpiritUnitId != 0)
                    unitId = state.ActiveSpiritUnitId;
                state.LastReportedPlayerPosition = new Vec3(x, y, z);
                state.LastReportedPlayerRotation = new Vec3(0f, facing, 0f);
                state.HasLastReportedPlayerTransform = true;
            }
        }

        return await SendPlayerTeleportAsync(session, unitId, x, y, z, facing, "teleport", token);
    }

    private static object Scenes()
    {
        return new
        {
            presets = SceneCatalog4229938.Presets.Select(p => new
            {
                key = p.Key,
                label = p.Label,
                raidId = p.RaidId,
                instanceId = p.InstanceId,
                universeId = p.UniverseId,
                x = p.X,
                y = p.Y,
                z = p.Z,
                facing = p.Facing,
            }).ToList()
        };
    }

    private static object NpcCatalog(HttpListenerRequest req)
    {
        var q = req.QueryString["q"];
        var cat = req.QueryString["cat"];
        int limit = 150;
        if (int.TryParse(req.QueryString["limit"], out var l) && l > 0)
            limit = Math.Clamp(l, 1, 300);

        var entries = NpcCatalog4229938.Search(q, cat, limit);

        return new
        {
            categories = new[]
            {
                new { id = "all", label = "🌟 All (ทั้งหมด)" },
                new { id = "monster", label = "⚔️ Monsters & Bosses (มอนสเตอร์/บอส)" },
                new { id = "citizen", label = "🚶 Citizens (ชาวเมือง/ประชาชน)" },
                new { id = "police", label = "👮 Police & Security (ตำรวจ/ยาม)" },
                new { id = "animal", label = "🐱 Animals & Pets (สัตว์/เป็ด/แมว)" },
                new { id = "ally", label = "🤝 Allies & Story (พันธมิตร/ตัวละคร)" },
            },
            poiActions = new[]
            {
                new { id = 0, name = "🧍 Auto / None (ไม่ระบุท่า)" },
                new { id = 2, name = "🧍 Idle (ยืนนิ่ง)" },
                new { id = 1, name = "🚶 Walk (เดิน)" },
                new { id = 4, name = "🏃 Run (วิ่ง)" },
                new { id = 11, name = "📱 Phone / Camera (คุยโทรศัพท์/ถ่ายรูป)" },
                new { id = 10, name = "🧱 Lean on Wall (พิงกำแพง)" },
                new { id = 12, name = "🪑 Formal Sit (นั่งเก้าอี้เรียบร้อย)" },
                new { id = 13, name = "🪑 Relaxed Sit (นั่งเก้าอี้ผ่อนคลาย)" },
                new { id = 15, name = "💬 Sit & Talk (นั่งคุย)" },
                new { id = 6, name = "👏 Clapping (ปรบมือ)" },
                new { id = 5, name = "👀 Spectating (ยืนมุงดู)" },
                new { id = 3, name = "😱 Scared / Panicking (ตกใจกลัว)" },
                new { id = 8, name = "🥤 Vending Machine (กดตู้ขายน้ำ)" }
            },
            items = entries.Select(e => new
            {
                id = e.Id,
                name = string.IsNullOrWhiteSpace(e.Name) ? $"Agent_{e.Id}" : e.Name,
                category = e.Category,
                model = e.GeneralModelId,
                camp = e.Camp,
                defaultPoi = e.Category == "monster" ? 0 : 2
            }).ToList()
        };
    }

    private sealed class NpcSpawnRequest
    {
        public List<AdminNpcSpawnItem>? Items { get; set; }
        public float XSpacing { get; set; } = 1.5f;
        public float ZSpacing { get; set; } = 1.5f;
        public int MaxPerRow { get; set; } = 10;
    }

    private async Task<object> NpcSpawnAsync(string json, CancellationToken token)
    {
        var session = hub.Current;
        if (session is null)
            return new { ok = false, message = "no live game session (is the client in the world?)" };

        NpcSpawnRequest? cmd;
        try
        {
            cmd = JsonSerializer.Deserialize<NpcSpawnRequest>(json, JsonOptions);
        }
        catch (Exception ex)
        {
            return new { ok = false, message = "bad request: " + ex.Message };
        }

        if (cmd?.Items is not { Count: >= 1 } || cmd.Items.Any(i => i is null || i.NpcFormworkId == 0)
            || !float.IsFinite(cmd.XSpacing) || cmd.XSpacing < 0f || !float.IsFinite(cmd.ZSpacing) || cmd.ZSpacing < 0f)
        {
            return new { ok = false, message = "provide at least one item with a non-zero npcFormworkId, finite non-negative X/Z spacing, and maxPerRow of at least 1" };
        }
        if (cmd.MaxPerRow < 1)
            return new { ok = false, message = "maxPerRow must be at least 1" };

        var result = await GameRouter.SpawnStaticNpcsAsync(session, cmd.Items, cmd.XSpacing, cmd.ZSpacing, cmd.MaxPerRow);
        return new { ok = result.Ok, message = result.Message, ids = result.Ids.Select(id => id.ToString()).ToArray() };
    }

    private async Task<object> SwitchSceneAsync(string json, CancellationToken token)
    {
        var session = hub.Current;
        if (session is null)
            return new { ok = false, error = "no live game session (is the client in the world?)" };

        uint raidId = 23300999;
        ulong instanceId = 20001223;
        uint universeId = 76000888;
        float x = -4719.8f, y = 168.5f, z = -2844.7f, facing = 0f;

        try
        {
            using var doc = JsonDocument.Parse(string.IsNullOrWhiteSpace(json) ? "{}" : json);
            var root = doc.RootElement;
            if (root.TryGetProperty("preset", out var pp) && pp.ValueKind == JsonValueKind.String)
            {
                var key = pp.GetString();
                var preset = SceneCatalog4229938.Presets.FirstOrDefault(p =>
                    string.Equals(p.Key, key, StringComparison.OrdinalIgnoreCase));
                if (preset != null)
                {
                    raidId = preset.RaidId;
                    instanceId = preset.InstanceId;
                    universeId = preset.UniverseId;
                    x = preset.X;
                    y = preset.Y;
                    z = preset.Z;
                    facing = preset.Facing;
                }
            }
            if (root.TryGetProperty("raidId", out var pr) || root.TryGetProperty("raid", out pr))
                raidId = pr.GetUInt32();
            if (root.TryGetProperty("instanceId", out var pi) || root.TryGetProperty("instance", out pi))
                instanceId = pi.GetUInt64();
            if (root.TryGetProperty("universeId", out var pu) || root.TryGetProperty("universe", out pu))
                universeId = pu.GetUInt32();
            if (root.TryGetProperty("x", out var px))
                x = (float)px.GetDouble();
            if (root.TryGetProperty("y", out var py))
                y = (float)py.GetDouble();
            if (root.TryGetProperty("z", out var pz))
                z = (float)pz.GetDouble();
            if (root.TryGetProperty("facing", out var pf))
                facing = (float)pf.GetDouble();
        }
        catch (Exception ex)
        {
            return new { ok = false, error = $"bad request: {ex.Message}" };
        }

        var result = await GameRouter.SwitchSceneDirectAsync(session, raidId, instanceId, universeId, new Vec3(x, y, z), facing);
        return result.Ok
            ? new { ok = true, message = result.Message, raidId, instanceId, universeId, x, y, z, facing }
            : new { ok = false, error = result.Message };
    }

    private async Task<object> VehicleGotoAsync(string json, CancellationToken token)
    {
        var session = hub.Current;
        if (session is null)
            return new { ok = false, error = "no live game session (is the client in the world?)" };

        ulong entityId;
        try
        {
            using var doc = JsonDocument.Parse(string.IsNullOrWhiteSpace(json) ? "{}" : json);
            if (!doc.RootElement.TryGetProperty("entityId", out var pe) || (entityId = pe.GetUInt64()) == 0)
                return new { ok = false, error = "missing numeric 'entityId'" };
        }
        catch (Exception ex)
        {
            return new { ok = false, error = $"bad request: {ex.Message}" };
        }

        var target = GameRouter.SummonedSnapshot().FirstOrDefault(v => v.EntityId == entityId);
        if (target.EntityId == 0 || !target.HasFix)
            return new { ok = false, error = $"no live coordinates for entityId {entityId} (not tracked or never moved)" };

        // Land behind the vehicle so the player does not spawn inside it.
        var yawRad = target.Yaw * (float)Math.PI / 180f;
        var x = target.X - (float)Math.Sin(yawRad) * 3f;
        var z = target.Z - (float)Math.Cos(yawRad) * 3f;
        var y = target.Y + 0.5f;

        ulong unitId = Profile.InitialUnitId;
        if (session.Items.TryGetValue(GameRouter.WorldStateKey, out var raw) && raw is WorldEntryState state)
        {
            lock (state.SyncRoot)
            {
                if (state.ActiveSpiritUnitId != 0)
                    unitId = state.ActiveSpiritUnitId;
            }
        }

        return await SendPlayerTeleportAsync(session, unitId, x, y, z, target.Yaw, $"goto vehicle {entityId}", token);
    }

    private static async Task<object> SendPlayerTeleportAsync(TcpSession session, ulong unitId, float x, float y, float z, float facing, string reason, CancellationToken token)
    {
        if (session.Items.TryGetValue(GameRouter.WorldStateKey, out var raw) && raw is WorldEntryState state)
        {
            lock (state.SyncRoot)
            {
                state.LastReportedPlayerPosition = new Vec3(x, y, z);
                state.LastReportedPlayerRotation = new Vec3(0f, facing, 0f);
                state.HasLastReportedPlayerTransform = true;
            }
        }

        var bytes = UxSerializer.Serialize(WorldCodec.PositionAndFacing(unitId, new Vec3(x, y, z), facing));
        await session.NotifyAsync(MethodId.SyncUnitPositionAndFacing, bytes, token);
        session.Log.Info($"[DEBUG-API] {reason} unit={unitId} to=({x:F1},{y:F1},{z:F1}) facing={facing:F1}");
        return new { ok = true, x, y, z, facing };
    }

    private async Task<object> VehicleSpawnAsync(string json, CancellationToken token)
    {
        var session = hub.Current;
        if (session is null)
            return new { ok = false, error = "no live game session (is the client in the world?)" };

        var fleet = config.Gameplay.Vehicles.FleetIds;
        uint configId = fleet.Length > 0 ? fleet[0] : 81001001;
        var distance = 6.0f;
        try
        {
            using var doc = JsonDocument.Parse(string.IsNullOrWhiteSpace(json) ? "{}" : json);
            var root = doc.RootElement;
            if (root.TryGetProperty("configId", out var pc) && pc.GetUInt32() != 0)
                configId = pc.GetUInt32();
            if (root.TryGetProperty("distance", out var pd))
                distance = (float)pd.GetDouble();
            if (!float.IsFinite(distance) || distance < 2f || distance > 60f)
                return new { ok = false, error = "distance must be 2..60" };
        }
        catch (Exception ex)
        {
            return new { ok = false, error = $"bad request: {ex.Message}" };
        }

        Vec3 pos = Profile.WorldSpawn;
        var yawDeg = Profile.WorldFacing;
        if (session.Items.TryGetValue(GameRouter.WorldStateKey, out var raw) && raw is WorldEntryState state)
        {
            lock (state.SyncRoot)
            {
                pos = state.LastReportedPlayerPosition;
                yawDeg = state.LastReportedPlayerRotation.Y;
            }
        }
        if (!float.IsFinite(yawDeg))
            yawDeg = Profile.WorldFacing;

        var result = await GameRouter.SpawnDirectAsync(session, configId, pos, yawDeg, rightOffset: distance, sourceType: 2, reason: "debug-panel");
        if (!result.Ok)
            return new { ok = false, error = result.Message };
        return new { ok = true, entityId = result.EntityId, configId, x = result.SpawnPos.X, y = result.SpawnPos.Y, z = result.SpawnPos.Z };
    }

    private async Task<object> VehicleToMeAsync(string json, CancellationToken token)
    {
        var session = hub.Current;
        if (session is null)
            return new { ok = false, error = "no live game session (is the client in the world?)" };

        ulong entityId;
        try
        {
            using var doc = JsonDocument.Parse(string.IsNullOrWhiteSpace(json) ? "{}" : json);
            if (!doc.RootElement.TryGetProperty("entityId", out var pe) || (entityId = pe.GetUInt64()) == 0)
                return new { ok = false, error = "missing numeric 'entityId'" };
        }
        catch (Exception ex)
        {
            return new { ok = false, error = $"bad request: {ex.Message}" };
        }

        if (!GameRouter.SummonedSnapshot().Any(v => v.EntityId == entityId))
            return new { ok = false, error = $"unknown entityId {entityId} (not summoned via server)" };

        Vec3 pos = Profile.WorldSpawn;
        var yawDeg = Profile.WorldFacing;
        if (session.Items.TryGetValue(GameRouter.WorldStateKey, out var raw) && raw is WorldEntryState state)
        {
            lock (state.SyncRoot)
            {
                pos = state.LastReportedPlayerPosition;
                yawDeg = state.LastReportedPlayerRotation.Y;
            }
        }
        if (!float.IsFinite(yawDeg))
            yawDeg = Profile.WorldFacing;

        var yawRad = yawDeg * (float)Math.PI / 180f;
        var sx = pos.X + (float)Math.Sin(yawRad) * 3f;
        var sz = pos.Z + (float)Math.Cos(yawRad) * 3f;
        var sy = pos.Y + 0.5f;

        var body = new SceneMethods.SyncTeleportVehicle
        {
            EntityId = entityId,
            Position = new SceneMethods.UxVector3(sx, sy, sz),
            Rotation = new SceneMethods.UxVector3(0f, yawDeg, 0f),
            Velocity = 0f,
            Reset = true,
            MoveToken = 0,
        };
        var bytes = UxSerializer.Serialize(body);
        await session.NotifyAsync(MethodId.SyncTeleportVehicle, bytes, token);
        session.Log.Info($"[DEBUG-API] vehicle to-me entity={entityId} at=({sx:F1},{sy:F1},{sz:F1})");
        return new { ok = true, entityId, x = sx, y = sy, z = sz };
    }

    private async Task<object> VehicleRemoveAsync(string json, CancellationToken token)
    {
        var session = hub.Current;
        if (session is null)
            return new { ok = false, error = "no live game session (is the client in the world?)" };

        ulong entityId;
        try
        {
            using var doc = JsonDocument.Parse(string.IsNullOrWhiteSpace(json) ? "{}" : json);
            if (!doc.RootElement.TryGetProperty("entityId", out var pe) || (entityId = pe.GetUInt64()) == 0)
                return new { ok = false, error = "missing numeric 'entityId'" };
        }
        catch (Exception ex)
        {
            return new { ok = false, error = $"bad request: {ex.Message}" };
        }

        await GameRouter.DestroyDirectAsync(session, entityId, "debug-panel");
        return new { ok = true, entityId };
    }

    private async Task<object> VehicleEnterAsync(string json, CancellationToken token)
    {
        var session = hub.Current;
        if (session is null)
            return new { ok = false, error = "no live game session (is the client in the world?)" };

        ulong entityId = 0;
        try
        {
            using var doc = JsonDocument.Parse(string.IsNullOrWhiteSpace(json) ? "{}" : json);
            if (doc.RootElement.TryGetProperty("entityId", out var pe))
                entityId = pe.GetUInt64();
        }
        catch (Exception ex)
        {
            return new { ok = false, error = $"bad request: {ex.Message}" };
        }

        var result = await GameRouter.ForceEnterVehicleAsync(session, entityId);
        return result.Ok
            ? new { ok = true, message = result.Message }
            : new { ok = false, error = result.Message };
    }

    private async Task<object> VehicleExitAsync(CancellationToken token)
    {
        var session = hub.Current;
        if (session is null)
            return new { ok = false, error = "no live game session (is the client in the world?)" };

        var result = await GameRouter.ForceExitVehicleAsync(session);
        return result.Ok
            ? new { ok = true, message = result.Message }
            : new { ok = false, error = result.Message };
    }

    private object TimeStatus()
    {
        var session = hub.Current;
        if (session is null)
            return new { online = false };
        var (hour, minute, fix, hasTime) = ReadSessionTime(session);
        return new { online = true, hour, minute, fix, hasTime };
    }

    private static (uint Hour, uint Minute, bool Fix, bool HasTime) ReadSessionTime(TcpSession session)
    {
        var state = GameRouter.GetStateIfExists(session);
        if (state is null)
            return (12, 0, true, false);
        lock (state.SyncRoot)
            return (state.TimeHour, state.TimeMinute, state.TimeFixed, state.HasExplicitTime);
    }

    private async Task<object> TimeSetAsync(string json, CancellationToken token)
    {
        var session = hub.Current;
        if (session is null)
            return new { ok = false, error = "no live game session (is the client in the world?)" };

        uint hour = 12, minute = 0, transition = 5;
        var fix = true;
        try
        {
            using var doc = JsonDocument.Parse(string.IsNullOrWhiteSpace(json) ? "{}" : json);
            var root = doc.RootElement;
            if (root.TryGetProperty("hour", out var ph))
                hour = ph.GetUInt32();
            if (root.TryGetProperty("minute", out var pm))
                minute = pm.GetUInt32();
            if (root.TryGetProperty("transition", out var pt))
                transition = pt.GetUInt32();
            if (root.TryGetProperty("fix", out var pf) && (pf.ValueKind == JsonValueKind.True || pf.ValueKind == JsonValueKind.False))
                fix = pf.GetBoolean();
            if (hour > 23 || minute > 59)
                return new { ok = false, error = "hour must be 0..23 and minute 0..59" };
        }
        catch (Exception ex)
        {
            return new { ok = false, error = $"bad request: {ex.Message}" };
        }

        var state = GameRouter.GetStateIfExists(session);
        if (state is null)
            return new { ok = false, error = "no live game session (is the client in the world?)" };
        lock (state.SyncRoot)
        {
            state.TimeHour = hour;
            state.TimeMinute = minute;
            state.TimeFixed = fix;
            state.TimeTransitionSeconds = transition;
            state.HasExplicitTime = true;
        }
        await GameRouter.PushSessionTimeAsync(session);
        session.Log.Info($"[DEBUG-API] time set {hour:D2}:{minute:D2} fix={fix} transition={transition}s");
        return new { ok = true, hour, minute, fix };
    }

    private async Task<object> WeatherSetAsync(string json, CancellationToken token)
    {
        var session = hub.Current;
        if (session is null)
            return new { ok = false, error = "no live game session (is the client in the world?)" };

        uint weatherId = 1, transition = 5;
        try
        {
            using var doc = JsonDocument.Parse(string.IsNullOrWhiteSpace(json) ? "{}" : json);
            var root = doc.RootElement;
            if (root.TryGetProperty("weatherId", out var pw))
                weatherId = pw.GetUInt32();
            if (root.TryGetProperty("transition", out var pt))
                transition = pt.GetUInt32();
        }
        catch (Exception ex)
        {
            return new { ok = false, error = $"bad request: {ex.Message}" };
        }

        var state = GameRouter.GetStateIfExists(session);
        if (state is null)
            return new { ok = false, error = "no live game session (is the client in the world?)" };
        lock (state.SyncRoot)
        {
            state.WeatherId = weatherId;
            state.WeatherTransitionSeconds = transition;
            state.HasExplicitWeather = true;
        }
        await GameRouter.PushSessionWeatherAsync(session);
        var cmd = $"CMD:SET_WEATHER:{weatherId}";
        await session.NotifyAsync(MethodId.SyncNotice, UxSerializer.Serialize(cmd), token);
        session.Log.Info($"[DEBUG-API] weather set id={weatherId} transition={transition}s");
        return new { ok = true, weatherId, transition };
    }

    private async Task<object> WeatherFogAsync(string json, CancellationToken token)
    {
        var session = hub.Current;
        if (session is null)
            return new { ok = false, error = "no live game session (is the client in the world?)" };

        float density = 0.08f;
        try
        {
            using var doc = JsonDocument.Parse(string.IsNullOrWhiteSpace(json) ? "{}" : json);
            var root = doc.RootElement;
            if (root.TryGetProperty("density", out var pd))
                density = pd.GetSingle();
        }
        catch (Exception ex)
        {
            return new { ok = false, error = $"bad request: {ex.Message}" };
        }

        var cmd = $"CMD:SET_FOG:{density.ToString(System.Globalization.CultureInfo.InvariantCulture)}";
        await session.NotifyAsync(MethodId.SyncNotice, UxSerializer.Serialize(cmd), token);

        session.Log.Info($"[DEBUG-API] fog set density={density}");
        return new { ok = true, density };
    }

    private async Task<object> UnstuckBlackScreenAsync(CancellationToken token)
    {
        var session = hub.Current;
        if (session is null)
            return new { ok = false, error = "no live game session (is the client in the world?)" };

        // 1. Send CMD:UNSTUCK_BLACKSCREEN via SyncNotice to clear transition & restore input
        var cmd = "CMD:UNSTUCK_BLACKSCREEN";
        var cmdBytes = UxSerializer.Serialize(cmd);
        await session.NotifyAsync(MethodId.SyncNotice, cmdBytes, token);

        // 2. Perform a slight nudge teleport (+0.5m Y) to reset physics and camera
        var state = GameRouter.GetStateIfExists(session);
        if (state is not null)
        {
            var pos = state.LastReportedPlayerPosition;
            var yaw = state.LastReportedPlayerRotation.Y;
            var nudgePos = new Vec3(pos.X, pos.Y + 0.5f, pos.Z);

            var syncTeleport = new SceneMethods.SyncTeleport
            {
                option = new SceneMethods.TeleportOption
                {
                    teleportId = 1,
                    Position = new SceneMethods.UxVector3(nudgePos.X, nudgePos.Y, nudgePos.Z),
                    Facing = yaw,
                    IsSwitchScene = false,
                    WaitTaskResource = false,
                    MapEntranceId = 0
                }
            };
            await session.NotifyAsync(MethodId.SyncTeleport, UxSerializer.Serialize(syncTeleport), token);

            var unitId = state.ActiveSpiritUnitId != 0 ? state.ActiveSpiritUnitId : Profile.InitialUnitId;
            var syncUnitPos = WorldCodec.PositionAndFacing(unitId, nudgePos, yaw);
            await session.NotifyAsync(MethodId.SyncUnitPositionAndFacing, UxSerializer.Serialize(syncUnitPos), token);
        }

        session.Log.Info("[DEBUG-API] unstuck black screen executed");
        return new { ok = true, message = "black screen transition cleared and player unstuck" };
    }

    private async Task<object> RollbackPositionAsync(CancellationToken token)
    {
        var session = hub.Current;
        if (session is null)
            return new { ok = false, error = "no live game session (is the client in the world?)" };

        var state = GameRouter.GetStateIfExists(session);
        if (state is null)
            return new { ok = false, error = "no world state" };

        var checkpoint = state.TryGetCheckpointSecondsAgo(10.0);
        if (checkpoint is null)
            return new { ok = false, error = "no position history recorded yet (move around first)" };

        var pos = checkpoint.Position;
        var facing = checkpoint.Facing;

        lock (state.SyncRoot)
        {
            state.LastReportedPlayerPosition = pos;
            state.LastReportedPlayerRotation = new Vec3(0f, facing, 0f);
            state.HasLastReportedPlayerTransform = true;
        }

        var syncTeleport = new SceneMethods.SyncTeleport
        {
            option = new SceneMethods.TeleportOption
            {
                teleportId = 1,
                Position = new SceneMethods.UxVector3(pos.X, pos.Y, pos.Z),
                Facing = facing,
                IsSwitchScene = false,
                WaitTaskResource = false,
                MapEntranceId = 0
            }
        };
        await session.NotifyAsync(MethodId.SyncTeleport, UxSerializer.Serialize(syncTeleport), token);

        var rollbackUnitId = state.ActiveSpiritUnitId != 0 ? state.ActiveSpiritUnitId : Profile.InitialUnitId;
        var rollbackUnitPos = WorldCodec.PositionAndFacing(rollbackUnitId, pos, facing);
        await session.NotifyAsync(MethodId.SyncUnitPositionAndFacing, UxSerializer.Serialize(rollbackUnitPos), token);

        session.Log.Info($"[DEBUG-API] rolled back player 10s to=({pos.X:F1},{pos.Y:F1},{pos.Z:F1}) timestamp={checkpoint.Timestamp:O}");
        return new { ok = true, x = pos.X, y = pos.Y, z = pos.Z, facing, timestamp = checkpoint.Timestamp };
    }

    private async Task<object> SpawnEnemyAsync(string json, CancellationToken token)
    {
        var session = hub.Current;
        if (session is null)
            return new { ok = false, error = "no live game session (is the client in the world?)" };

        uint enemyId = 100101;
        int camp = 2;
        int count = 1;

        try
        {
            using var doc = JsonDocument.Parse(string.IsNullOrWhiteSpace(json) ? "{}" : json);
            var root = doc.RootElement;
            if (root.TryGetProperty("enemyId", out var pe)) enemyId = pe.GetUInt32();
            if (root.TryGetProperty("camp", out var pc)) camp = pc.GetInt32();
            if (root.TryGetProperty("count", out var pn)) count = pn.GetInt32();
        }
        catch (Exception ex)
        {
            return new { ok = false, error = $"bad request: {ex.Message}" };
        }

        var cmd = $"CMD:SPAWN_ENEMY:{enemyId}:{camp}:{count}";
        await session.NotifyAsync(MethodId.SyncNotice, UxSerializer.Serialize(cmd), token);

        session.Log.Info($"[DEBUG-API] spawn enemy id={enemyId} camp={camp} count={count}");
        return new { ok = true, enemyId, camp, count };
    }

    private async Task<object> PlayCutsceneAsync(string json, CancellationToken token)
    {
        var session = hub.Current;
        if (session is null)
            return new { ok = false, error = "no live game session (is the client in the world?)" };

        string cutsceneId = "24100064";
        try
        {
            using var doc = JsonDocument.Parse(string.IsNullOrWhiteSpace(json) ? "{}" : json);
            var root = doc.RootElement;
            if (root.TryGetProperty("id", out var pi)) cutsceneId = pi.GetString() ?? pi.GetRawText();
        }
        catch (Exception ex)
        {
            return new { ok = false, error = $"bad request: {ex.Message}" };
        }

        var cmd = $"CMD:PLAY_CUTSCENE:{cutsceneId}";
        await session.NotifyAsync(MethodId.SyncNotice, UxSerializer.Serialize(cmd), token);

        session.Log.Info($"[DEBUG-API] play cutscene/video id={cutsceneId}");
        return new { ok = true, id = cutsceneId };
    }

    private sealed record TimelineItem(string id, uint configId, string name, string category, float x = 0, float y = 0, float z = 0);

    private static readonly TimelineItem[] AllTimelines =
    [
        // Story & Quests
        new("TL_SEYM_010_Q010_S01", 2030u, "Seymour Story Quest: Chapter 1 S01 (黑客与发布会 - แฮกเกอร์กับงานแถลงข่าว)", "story", 3418.28f, 295.23f, 1415.67f),
        new("TL_TAF_010_Q010_S04", 0u, "Taffy Story Quest: Chapter 1 S04 (เควสต์เนื้อเรื่องทาฟี่)", "story"),
        new("TL_HEISTJ", 0u, "Bank Heist Cinematics Part J (ฉากภารกิจปล้นธนาคาร J)", "story"),
        new("TL_HEISTZ", 0u, "Bank Heist Cinematics Part Z (ฉากภารกิจปล้นธนาคาร Z)", "story"),
        new("TL_TGS_MQ_S02", 0u, "Tokyo Game Show Main Quest S02 (ฉากเปิดตัวงาน TGS)", "story"),
        new("TL_SQ_020_Q005_S02", 0u, "Side Quest Special Cinematic (เควสต์ย่อย 020 S02)", "story"),
        new("TL_Bernard", 0u, "Bernard Character Cinematic (คัทซีนเบอร์นาร์ด)", "story"),
        new("TL_Erin_mm_hunhun", 0u, "Erin vs Thugs Street Scene (เอรินปะทะกลุ่มอันธพาล)", "story"),
        new("xsb_phase3_part3", 0u, "Boss Encounter Phase 3 Part 3 (คัทซีนบอสเฟส 3)", "story"),

        // Character Entrances & Customs
        new("SwitchChar_tafei_01", 48u, "Taffy Skyscraper Apartment (ทาฟี่ โดดจากตึกอพาร์ตเมนต์)", "character", 1613.81f, 21.96f, 1565.65f),
        new("SwitchChar_dila_03", 62u, "Dila Combat Rooftop Action (ดิลา แอ็กชันคอมแบทบนดาดฟ้า)", "character", 484.28f, 15.03f, 2018.23f),
        new("SwitchChar_saimo_05", 100u, "Seymour Skyline Overview (เซย์มัวร์ ชมวิวตึกระฟ้าสไตล์คูล)", "character", 2198.68f, 92.08f, 1807.14f),
        new("SwitchChar_lixi_04", 59u, "Richie Motorcycle Battle (ริชชี่ ซิ่งมอเตอร์ไซค์สู้แก๊งสเตอร์)", "character", 1647.65f, 0f, 1578.67f),
        new("SwitchChar_nanzhujue_02", 61u, "Male MC Sports Car Arrival (พระเอก นั่งสปอร์ตคาร์มาส่ง)", "character", 3142.67f, 0f, 2522.78f),
        new("SwitchChar_nanzhujue_03", 115u, "Male MC Rolls-Royce Arrival (พระเอก ก้าวลงจาก Rolls-Royce)", "character", 2468.71f, -0.1f, 1371.11f),
        new("SwitchChar_character_2", 82u, "Taffy Park Bench Nap (ทาฟี่ นอนหลับบนม้านั่งสวนสาธารณะ)", "character", 403.61f, 0f, 2117.54f),
        new("SwitchChar_character_3", 83u, "Aileen at Maid Cafe (ไอลีน สนทนากับเมดในคาเฟ่)", "character", 2086.22f, -0.11f, 2362.25f),
        new("SwitchChar_character_4", 84u, "Bansy Street Graffiti (แบนซี พ่นสเปรย์กราฟิตี้ข้างถนน)", "character", 522.15f, 0f, 2083.76f),
        new("SwitchChar_character_6", 85u, "Dila Scrolling Phone on Bench (ดิลา นั่งเล่นโทรศัพท์มือถือ)", "character", 395.99f, 0f, 2111.99f),
        new("SwitchChar_character_7", 86u, "Enomi Drinking Milk (เอโนมิ ยืนดื่มนมกล่อง)", "character", 1606.63f, -0.1f, 1222.73f),
        new("SwitchChar_character_13", 89u, "Garm Baseball Batting (การ์ม ซ้อมหวดลูกเบสบอลสุดเท่)", "character", 2862.36f, -0.67f, 2761.5f),
        new("SwitchChar_character_14", 94u, "Richie Catching Criminal (ริชชี่ บุกจับคนร้ายคาหนังคาเขา)", "character", 3913.1f, -0.14f, 626.1f),
        new("SwitchChar_character_16", 90u, "MC Receiving Street Flyer (พระเอก รับใบปลิวจากคนแจก)", "character", 2597.6f, 0.14f, 1156.3f),
        new("SwitchChar_character_22", 113u, "Lykaia Peeling Apple in Mansion (ไลคาเอีย ปอกแอปเปิ้ลในคฤหาสน์หรู)", "character", 3204.52f, 104.46f, 959.45f),
        new("SwitchChar_character_23", 114u, "Baijing High-Speed Overtake (ไป๋จิ้ง ซิ่งรถแซงโค้งความเร็วสูง)", "character", 3008.4f, -0.1f, 1614.91f),
        new("SwitchChar_character_19", 302u, "Richie Official PV Cinematic (ริชชี่ ช็อตไฮไลท์จากเทรลเลอร์ PV)", "character", 3008.4f, -0.1f, 1614.91f),
        new("SwitchChar_character_20", 303u, "Continuous One-Shot Camera (มุมกล้อง Long-Take ช็อตเดียวจบ)", "character", 3008.4f, -0.1f, 1614.91f),
        new("SwitchChar_common_01", 1u, "Cherry Blossom Ave Passenger Drop (ไลคาเอีย ขับรถมาส่งที่ถนนซากุระ)", "character", 3008.4f, -0.1f, 1614.91f),
        new("SwitchChar_common_07", 44u, "Taffy Driving Sports Car (ทาฟี่ ขับรถซิ่งบนถนนใหญ่)", "character", 3008.4f, -0.1f, 1614.91f),
        new("SwitchChar_common_09", 49u, "Exiting City Taxi (เปิดประตูก้าวลงจากรถแท็กซี่)", "character", 3008.3f, 0f, 1616.5f),
        new("SwitchChar_common_27", 87u, "Street Basketball Game (ดังก์บาสเกตบอลสตรีท)", "character", 410.72f, 0f, 2108.59f),

        // Urban Life & Interactive
        new("SwitchChar_common_04", 4u, "Exiting Mahjong Parlor (เดินออกจากร้านไพ่นกกระจอก)", "urban", 1031.7f, 0f, 1888.7f),
        new("SwitchChar_common_21", 63u, "Exiting Store & Stretching (เดินออกจากร้านพร้อมบิดขี้เกียจ)", "urban", 1030.2f, 0f, 1889.73f),
        new("SwitchChar_common_22", 96u, "Exiting Store Fist Pump (เดินออกจากร้านพร้อมชูกำปั้นมั่นใจ)", "urban", 2062.63f, 0f, 2459f),
        new("SwitchChar_common_23", 106u, "Exiting Restaurant Patting Belly (เดินออกจากร้านอาหารลูบท้องอิ่ม)", "urban", 3074.69f, 0f, 2185.89f),
        new("SwitchChar_common_24", 97u, "Walking & Hanging up Scam Call (คุยโทรศัพท์สายหลอกลวงแล้วส่ายหัวตัดสาย)", "urban", 1727f, 9.64f, 1968f),
        new("SwitchChar_common_10", 28u, "Cyberpunk Nightclub Dancing 1 (แดนซ์ในผับไซเบอร์พังก์ 1)", "urban", 2875.39f, 0.02f, 2203.92f),
        new("SwitchChar_common_11", 31u, "Wild Cyberpunk Nightclub Dancing 2 (แดนซ์ในผับไซเบอร์พังก์ 2)", "urban", 558.19f, -21.14f, 1933.61f),
        new("SwitchChar_common_14", 54u, "Petting Street Cat (นั่งยองๆ ลูบหัวแมวจรจัด)", "urban", 2832.1f, 0.05f, 1880.63f),
        new("SwitchChar_common_15", 55u, "Walking the Dog (พาสุนัขเดินเล่นรอบเมือง)", "urban", 2809.91f, 0.07f, 1940.67f),
        new("SwitchChar_common_16", 57u, "Taking Landscape Photos (ยกกล้องถ่ายรูปวิวทิวทัศน์เมือง)", "urban", 589f, 0f, 1937.8f),
        new("SwitchChar_common_17", 60u, "Street Smartphone Selfie (หยิบมือถือขึ้นมาถ่ายรูปเซลฟี่)", "urban", 706.56f, 3.41f, 2097.07f),
        new("SwitchChar_common_18", 107u, "Photo with Citizen Fan (ถ่ายรูปร่วมกับแฟนคลับชาวเมือง)", "urban", 1229.34f, 0f, 1237.58f),
        new("SwitchChar_common_26", 105u, "Polite Photo with NPC (ถ่ายรูปคู่กับ NPC อย่างสุภาพ)", "urban", 1889.75f, 0f, 2211.68f),
        new("SwitchChar_common_19", 56u, "Tossing Can in Trash Bin (โยนกระป๋องลงถังขยะลงเป๊ะ)", "urban", 1717.25f, 0.08f, 2271.25f),
        new("SwitchChar_common_25", 99u, "Tossing Can in Trash Bin Missed (โยนกระป๋องไม่ลงถังขยะ)", "urban", 1717.25f, 0.08f, 2271.25f),
        new("SwitchChar_character_1", 88u, "Buying Drink at Vending Machine (หยอดเหรียญกดตู้เครื่องดื่ม)", "urban", 3010.08f, 0f, 1656.21f),
        new("SwitchChar_common_20", 81u, "Defeat Gang & Escape (ถล่มแก๊งข้างถนนแล้วกระโดดหนี)", "urban", 3984.66f, -0.14f, 636.22f),
        new("SwitchChar_common_20a", 111u, "Defeat Gold Gang & Escape (ถล่มแก๊งทองดำแล้วสปีดหนี)", "urban", 3984.66f, -0.14f, 636.22f),
        new("SwitchChar_common_20b", 112u, "Defeat TV-Head Gang & Escape (ถล่มแก๊งหัวทีวีแล้วสเก็ตหนี)", "urban", 3984.66f, -0.14f, 636.22f),

        // Transit & World Transitions
        new("loading_plane01", 0u, "Airport Airplane Takeoff Cinematic (คัทซีนเครื่องบินขึ้นจากสนามบิน)", "transit"),
        new("loading_plane02", 0u, "Airport Airplane Landing Cinematic (คัทซีนเครื่องบินร่อนลงจอด)", "transit"),
        new("loading_metro_end_1", 0u, "Subway Metro Train Arrival (คัทซีนรถไฟใต้ดินเทียบชานชาลา)", "transit"),
        new("Loading_bus_end", 0u, "Metropolis City Bus Arrival (คัทซีนรถเมล์เทศบาลเทียบป้าย)", "transit"),
        new("loading_elevator02", 0u, "Skyscraper Glass Elevator (คัทซีนลิฟต์แก้วตึกระฟ้าความเร็วสูง)", "transit"),
        new("loading_indoor_in01", 0u, "Cinematic Building Entry A (คัทซีนเดินเข้าอาคารแบบสมจริง A)", "transit"),
        new("loading_indoor_out01", 0u, "Cinematic Building Exit A (คัทซีนเดินออกจากอาคารสู่ถนนใหญ่ A)", "transit"),
    ];

    private async Task<object> PlayTimelineAsync(string json, CancellationToken token)
    {
        var session = hub.Current;
        if (session is null)
            return new { ok = false, error = "no live game session (is the client in the world?)" };

        string timeline = "TL_SEYM_010_Q010_S01";
        uint explicitConfigId = 0;
        try
        {
            using var doc = JsonDocument.Parse(string.IsNullOrWhiteSpace(json) ? "{}" : json);
            var root = doc.RootElement;
            if (root.TryGetProperty("name", out var pn)) timeline = pn.GetString() ?? pn.GetRawText();
            else if (root.TryGetProperty("id", out var pi)) timeline = pi.GetString() ?? pi.GetRawText();
            if (root.TryGetProperty("configId", out var pc)) explicitConfigId = pc.GetUInt32();
        }
        catch (Exception ex)
        {
            return new { ok = false, error = $"bad request: {ex.Message}" };
        }

        var match = Array.Find(AllTimelines, t => t.id.Equals(timeline, StringComparison.OrdinalIgnoreCase));
        uint configId = explicitConfigId != 0 ? explicitConfigId : (match?.configId ?? 0);

        // 1. If configured in SwitchSpiritConfig, dispatch native SwitchSpiritConfigId RPC
        if (configId != 0)
        {
            var state = GameRouter.GetStateIfExists(session);
            var pos = (match is not null && (match.x != 0 || match.y != 0 || match.z != 0))
                ? new Vec3(match.x, match.y, match.z)
                : (state is not null && state.HasLastReportedPlayerTransform ? state.LastReportedPlayerPosition : new Vec3(0, 0, 0));

            var payload = WorldCodec.SwitchSpiritConfigId(configId, pos);
            await session.NotifyAsync(MethodId.SyncSwitchSpiritConfigId, UxSerializer.Serialize(payload), token);
            session.Log.Info($"[DEBUG-API] sent native SwitchSpiritConfigId configId={configId} timeline={timeline}");
        }

        // 2. Dispatch Lua Fastpatch notice
        var cmd = $"CMD:PLAY_TIMELINE:{timeline}";
        await session.NotifyAsync(MethodId.SyncNotice, UxSerializer.Serialize(cmd), token);

        session.Log.Info($"[DEBUG-API] play realtime timeline={timeline} configId={configId}");
        return new { ok = true, timeline, configId };
    }

    private async Task<object> ToggleClothesAsync(CancellationToken token)
    {
        var session = hub.Current;
        if (session is null)
            return new { ok = false, error = "no live game session (is the client in the world?)" };

        var cmd = "CMD:TOGGLE_CLOTHES";
        await session.NotifyAsync(MethodId.SyncNotice, UxSerializer.Serialize(cmd), token);

        session.Log.Info("[DEBUG-API] toggle clothes dispatched");
        return new { ok = true };
    }

    private static object CutsceneCatalog()
    {
        return new
        {
            ok = true,
            items = AllTimelines
        };
    }

    private async Task<object> LaunchMinigameAsync(string json, CancellationToken token)
    {
        var session = hub.Current;
        if (session is null)
            return new { ok = false, error = "no live game session (is the client in the world?)" };

        var cmd = "CMD:LAUNCH_MINIGAME:FIGHTER";
        await session.NotifyAsync(MethodId.SyncNotice, UxSerializer.Serialize(cmd), token);

        session.Log.Info("[DEBUG-API] launch arcade minigame fighter dispatched");
        return new { ok = true, game = "FIGHTER" };
    }

    private static async Task<string> ReadBodyAsync(HttpListenerRequest request, CancellationToken token)
    {
        if (!request.HasEntityBody)
            return string.Empty;
        using var reader = new StreamReader(request.InputStream, request.ContentEncoding);
        return await reader.ReadToEndAsync(token);
    }

    private static async Task WriteHtmlAsync(HttpListenerContext ctx, CancellationToken token)
    {
        var bytes = PanelHtml.Value;
        ctx.Response.StatusCode = 200;
        ctx.Response.ContentType = "text/html; charset=utf-8";
        ctx.Response.ContentLength64 = bytes.Length;
        await ctx.Response.OutputStream.WriteAsync(bytes, token);
        ctx.Response.Close();
    }

    private static async Task WriteJsonAsync(HttpListenerContext ctx, object payload, CancellationToken token, int status = 200)
    {
        var bytes = Encoding.UTF8.GetBytes(JsonSerializer.Serialize(payload, JsonOptions));
        ctx.Response.StatusCode = status;
        ctx.Response.ContentType = "application/json; charset=utf-8";
        ctx.Response.ContentLength64 = bytes.Length;
        await ctx.Response.OutputStream.WriteAsync(bytes, token);
        ctx.Response.Close();
    }
}
