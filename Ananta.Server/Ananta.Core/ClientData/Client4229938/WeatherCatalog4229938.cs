using System.Text.Json;
using Ananta.Server.Configuration;

namespace Ananta.Server.ClientData.Client4229938;

internal sealed record WeatherEntry4229938(uint Id, string Name);

/// <summary>Weather catalog from WeatherConfig.json (5 entries in this build).</summary>
internal static class WeatherCatalog4229938
{
    private static readonly Lazy<IReadOnlyList<WeatherEntry4229938>> Cache = new(Load);

    internal static IReadOnlyList<WeatherEntry4229938> All => Cache.Value;

    private static IReadOnlyList<WeatherEntry4229938> Load()
    {
        var root = PrivateServerConfigStore.ResolveProjectPath(PrivateServerConfigStore.Current.Paths.ClientConfigs);
        var path = Path.Combine(root, "WeatherConfig.json");
        if (!File.Exists(path))
            return [];
        using var doc = JsonDocument.Parse(File.ReadAllText(path));
        var result = new List<WeatherEntry4229938>();
        if (!doc.RootElement.TryGetProperty("records", out var records) || records.ValueKind != JsonValueKind.Array)
            return result;
        foreach (var row in records.EnumerateArray())
        {
            if (!row.TryGetProperty("Id", out var id) || !id.TryGetUInt32(out var weatherId) || weatherId == 0)
                continue;
            var name = row.TryGetProperty("Name", out var n) && n.ValueKind == JsonValueKind.String
                ? n.GetString() ?? string.Empty : string.Empty;
            result.Add(new WeatherEntry4229938(weatherId, string.IsNullOrWhiteSpace(name) ? $"Weather {weatherId}" : name));
        }
        return result.OrderBy(w => w.Id).ToList();
    }
}
