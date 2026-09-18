using System.Text.Json;
using Ananta.SDK.Logging;
using Ananta.Server.Configuration;

namespace Ananta.Server.Protocol.Client4229938;

/// <summary>Wallet + backpack + gacha counters kept in memory for the lifetime of a login.</summary>
internal sealed class PlayerProgress
{
    internal double Money { get; set; }
    internal double Gold { get; set; }
    internal double BindingGold { get; set; }
    internal List<PlayerProgressItem> Items { get; } = [];
    internal Dictionary<uint, uint> GachaDrawsSinceGrand { get; } = [];
    internal HashSet<uint> Fashions { get; } = [];
    internal HashSet<uint> Vehicles { get; } = [];
    internal bool RestoredFromDisk { get; set; }
}

internal sealed record PlayerProgressItem(uint TemplateId, uint Count, bool IsBind, ulong UniqueId);

/// <summary>
/// Minimal character economy persistence for build 4229938. The retail server keeps this in the
/// account database; this private server writes one JSON snapshot per player next to
/// <c>config/private-server.json</c> and replays it through PlayerInfo at login.
/// </summary>
internal static class PlayerProgressStore
{
    private static readonly object Gate = new();
    private static readonly JsonSerializerOptions Options = new() { WriteIndented = true };

    internal static string FilePath { get; } =
        PrivateServerConfigStore.ResolveProjectPath(Path.Combine("config", "player-progress.json"));

    internal static void LoadInto(PlayerProgress progress, ServerLogger log)
    {
        var path = FilePath;
        if (!File.Exists(path))
        {
            log.Info($"[ECONOMY] no saved character economy yet ({path})");
            return;
        }

        try
        {
            SaveFile? file;
            lock (Gate)
                file = JsonSerializer.Deserialize<SaveFile>(File.ReadAllText(path));

            if (file is null)
            {
                log.Warn($"[ECONOMY] saved character economy is empty: {path}");
                return;
            }

            progress.Money = file.Money;
            progress.Gold = file.Gold;
            progress.BindingGold = file.BindingGold;
            progress.Items.Clear();
            progress.GachaDrawsSinceGrand.Clear();
            progress.Fashions.Clear();
            progress.Vehicles.Clear();

            foreach (var item in file.Items)
            {
                if (item.TemplateId == 0 || item.Count == 0)
                    continue;

                progress.Items.RemoveAll(x => x.TemplateId == item.TemplateId);
                progress.Items.Add(new PlayerProgressItem(item.TemplateId, item.Count, item.IsBind, item.UniqueId));
            }

            foreach (var (poolId, draws) in file.GachaDraws)
            {
                if (poolId != 0)
                    progress.GachaDrawsSinceGrand[poolId] = draws;
            }

            foreach (var fashionId in file.Fashions)
            {
                if (fashionId != 0)
                    progress.Fashions.Add(fashionId);
            }

            foreach (var vehicleId in file.Vehicles)
            {
                if (vehicleId != 0)
                    progress.Vehicles.Add(vehicleId);
            }

            progress.RestoredFromDisk = true;
            log.Info(
                $"[ECONOMY] restored pid={file.Pid} account={file.AccountId} " +
                $"money={progress.Money} gold={progress.Gold} bindingGold={progress.BindingGold} " +
                $"items={progress.Items.Count} gachaPools={progress.GachaDrawsSinceGrand.Count} " +
                $"fashions={progress.Fashions.Count} vehicles={progress.Vehicles.Count} ({path})");
        }
        catch (Exception ex)
        {
            log.Warn($"[ECONOMY] saved character economy could not be read ({ex.GetType().Name}: {ex.Message}): {path}");
        }
    }

    /// <summary>Snapshots the live session state (wallet, GM/granted backpack, gacha counters) to disk.</summary>
    internal static void Save(WorldEntryState state, ServerLogger log)
    {
        var file = new SaveFile
        {
            Pid = PrivateServerConfigStore.Current.Player.Pid,
            AccountId = PrivateServerConfigStore.Current.Player.AccountId,
            Money = state.WalletMoney,
            Gold = state.WalletGold,
            BindingGold = state.WalletBindingGold,
            SavedAtUtc = DateTime.UtcNow.ToString("O"),
        };

        lock (state.SyncRoot)
        {
            foreach (var stack in state.GmBackpackItems.Values)
            {
                if (stack.TemplateId == 0 || stack.Count == 0)
                    continue;

                file.Items.Add(new SaveItem
                {
                    TemplateId = stack.TemplateId,
                    Count = stack.Count,
                    IsBind = stack.IsBind,
                    UniqueId = stack.UniqueId,
                });
            }

            file.Fashions.AddRange(state.Progress.Fashions.Where(x => x != 0).OrderBy(x => x));
            file.Vehicles.AddRange(state.Progress.Vehicles.Where(x => x != 0).OrderBy(x => x));
        }

        foreach (var (poolId, draws) in state.Progress.GachaDrawsSinceGrand)
            file.GachaDraws[poolId] = draws;

        var path = FilePath;
        var temp = path + ".tmp";
        try
        {
            var directory = Path.GetDirectoryName(path);
            if (!string.IsNullOrEmpty(directory) && !Directory.Exists(directory))
                Directory.CreateDirectory(directory);

            lock (Gate)
            {
                File.WriteAllText(temp, JsonSerializer.Serialize(file, Options));
                File.Move(temp, path, overwrite: true);
            }

            log.Info(
                $"[ECONOMY] saved character economy money={file.Money} gold={file.Gold} " +
                $"bindingGold={file.BindingGold} items={file.Items.Count} " +
                $"fashions={file.Fashions.Count} vehicles={file.Vehicles.Count} -> {path}");
        }
        catch (Exception ex)
        {
            log.Warn($"[ECONOMY] character economy could not be saved ({ex.GetType().Name}: {ex.Message}): {path}");
            try
            {
                if (File.Exists(temp))
                    File.Delete(temp);
            }
            catch
            {
            }
        }
    }

    private sealed class SaveFile
    {
        public ulong Pid { get; set; }
        public string AccountId { get; set; } = string.Empty;
        public double Money { get; set; }
        public double Gold { get; set; }
        public double BindingGold { get; set; }
        public string SavedAtUtc { get; set; } = string.Empty;
        public List<SaveItem> Items { get; set; } = [];
        public Dictionary<uint, uint> GachaDraws { get; set; } = [];
        public List<uint> Fashions { get; set; } = [];
        public List<uint> Vehicles { get; set; } = [];
    }

    private sealed class SaveItem
    {
        public uint TemplateId { get; set; }
        public uint Count { get; set; }
        public bool IsBind { get; set; }
        public ulong UniqueId { get; set; }
    }
}
