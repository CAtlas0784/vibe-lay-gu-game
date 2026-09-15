namespace Ananta.SDK.Logging;

public sealed class ServerLogger
{
    private static readonly object ConsoleLock = new();
    public string Scope { get; }

    public ServerLogger(string scope) => Scope = CompactScope(scope);

    public void Info(string message) => Write(" ", message, PickInfoColor(message));
    public void Warn(string message) => Write("!", message, ConsoleColor.Yellow);
    public void Error(string message, Exception? ex = null)
        => Write("X", ex is null ? message : $"{message}: {ex.GetType().Name}: {ex.Message}", ConsoleColor.Red);

    private void Write(string level, string message, ConsoleColor color)
    {
        lock (ConsoleLock)
        {
            var previous = Console.ForegroundColor;
            try
            {
                Console.ForegroundColor = color;
                Console.WriteLine($"[{DateTime.Now:HH:mm:ss}] [{Scope}] {level} {message}");
            }
            finally
            {
                Console.ForegroundColor = previous;
            }
        }
    }

    private static ConsoleColor PickInfoColor(string message)
    {
        // Wire direction is the most common thing you scan while debugging.
        if (message.Contains("-> rpc", StringComparison.Ordinal) ||
            message.Contains("-> ntf", StringComparison.Ordinal))
            return ConsoleColor.Cyan;
        if (message.Contains("<- ret", StringComparison.Ordinal))
            return ConsoleColor.Green;

        // High-level gameplay categories.
        if (message.Contains("[SWITCH]", StringComparison.Ordinal)) return ConsoleColor.Magenta;
        if (message.Contains("[WEB]", StringComparison.Ordinal)) return ConsoleColor.Cyan;
        if (message.Contains("[CAPABILITY]", StringComparison.Ordinal)) return ConsoleColor.DarkCyan;
        if (message.Contains("[COMBAT]", StringComparison.Ordinal)) return ConsoleColor.DarkYellow;
        if (message.Contains("[WORLD]", StringComparison.Ordinal)) return ConsoleColor.Blue;
        if (message.Contains("[PLAYER]", StringComparison.Ordinal)) return ConsoleColor.Green;
        if (message.Contains("[MOVE]", StringComparison.Ordinal)) return ConsoleColor.Gray;
        if (message.Contains("[PAUSE]", StringComparison.Ordinal)) return ConsoleColor.DarkYellow;

        // Connection lifecycle.
        if (message.TrimStart().StartsWith("+", StringComparison.Ordinal)) return ConsoleColor.Green;
        if (message.TrimStart().StartsWith("-", StringComparison.Ordinal)) return ConsoleColor.DarkGray;

        return ConsoleColor.Gray;
    }

    private static string CompactScope(string scope)
    {
        var suffix = string.Empty;
        var colon = scope.IndexOf(':');
        if (colon >= 0)
        {
            suffix = scope[colon..];
            scope = scope[..colon];
        }

        return scope switch
        {
            "login-0" => "L0" + suffix,
            "login-1" => "L1" + suffix,
            "game" => "G" + suffix,
            "router" => "R" + suffix,
            _ when scope.StartsWith("router") => "R" + suffix,
            _ => scope + suffix,
        };
    }
}
