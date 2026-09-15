using System.Text;
using System.Text.Json;

namespace Ananta.SDK.Logging;

/// <summary>
/// Process-wide runtime logs shared by the SDK and server.
/// Run-All.ps1 supplies one run id so C# and the Node proxy append to the same console files.
/// </summary>
public static class RuntimeLogs
{
    private static readonly object FileLock = new();
    private static readonly JsonSerializerOptions JsonOptions = new()
    {
        IncludeFields = true,
        WriteIndented = false,
        MaxDepth = 8,
    };

    private static bool _initialized;
    private static bool _consoleEnabled;
    private static bool _packetEnabled;
    private static bool _includeHex;
    private static bool _includeDecoded;
    private static int _maxBodyBytes;
    private static string? _consoleLatest;
    private static string? _consoleArchive;
    private static string? _packetLatest;
    private static string? _packetArchive;
    private static TextWriter? _originalOut;
    private static TextWriter? _originalError;
    private static bool _bootstrapConsoleHidden;

    public static void Initialize(
        string logDirectory,
        string? runId,
        bool consoleEnabled,
        bool packetEnabled,
        bool includeHex,
        bool includeDecoded,
        int maxBodyBytes)
    {
        if (_initialized) return;

        Directory.CreateDirectory(logDirectory);
        runId = string.IsNullOrWhiteSpace(runId)
            ? DateTime.Now.ToString("yyyyMMdd-HHmmss")
            : runId;

        _consoleEnabled = consoleEnabled;
        _packetEnabled = packetEnabled;
        _includeHex = includeHex;
        _includeDecoded = includeDecoded;
        _maxBodyBytes = Math.Max(0, maxBodyBytes);

        _consoleLatest = Environment.GetEnvironmentVariable("Ananta_CONSOLE_LOG_LATEST")
            ?? Path.Combine(logDirectory, "console-latest.log");
        _consoleArchive = Environment.GetEnvironmentVariable("Ananta_CONSOLE_LOG_ARCHIVE")
            ?? Path.Combine(logDirectory, $"console-{runId}.log");
        _packetLatest = Environment.GetEnvironmentVariable("Ananta_PACKET_LOG_LATEST")
            ?? Path.Combine(logDirectory, "packets-latest.log");
        _packetArchive = Environment.GetEnvironmentVariable("Ananta_PACKET_LOG_ARCHIVE")
            ?? Path.Combine(logDirectory, $"packets-{runId}.log");

        // When launched without Run-All, create a fresh latest/archive pair here.
        if (Environment.GetEnvironmentVariable("Ananta_LOGS_PREPARED") != "1")
        {
            if (_consoleEnabled)
            {
                PrepareFile(_consoleLatest);
                PrepareFile(_consoleArchive);
            }
            if (_packetEnabled)
            {
                PrepareFile(_packetLatest);
                PrepareFile(_packetArchive);
            }
        }

        _initialized = true;

        if (_consoleEnabled)
        {
            _originalOut = Console.Out;
            _originalError = Console.Error;
            _bootstrapConsoleHidden = Environment.GetEnvironmentVariable("Ananta_HIDE_BOOT_LOG") == "1";
            if (_bootstrapConsoleHidden)
            {
                // Run-All already cleared the launcher window. Keep startup diagnostics in the
                // normal console log files without repainting the interactive console.
                Console.SetOut(new MirrorOnlyTextWriter(_originalOut.Encoding, AppendConsole));
                Console.SetError(new MirrorOnlyTextWriter(_originalError.Encoding, AppendConsole));
            }
            else
            {
                Console.SetOut(new TeeTextWriter(_originalOut, AppendConsole));
                Console.SetError(new TeeTextWriter(_originalError, AppendConsole));
            }
        }
    }

    /// <summary>Restore normal runtime console output after boot diagnostics have completed.</summary>
    public static void EndBootstrapQuietMode()
    {
        if (!_initialized || !_consoleEnabled || !_bootstrapConsoleHidden || _originalOut is null || _originalError is null)
            return;

        Console.SetOut(new TeeTextWriter(_originalOut, AppendConsole));
        Console.SetError(new TeeTextWriter(_originalError, AppendConsole));
        _bootstrapConsoleHidden = false;
    }

    public static void Incoming(string scope, RpcPacketKindView kind, uint methodId, int invokeId, ReadOnlySpan<byte> body)
        => WritePacket(scope, "C2S", kind.ToString().ToUpperInvariant(), methodId, invokeId, null, body);

    public static void OutgoingNotify(string scope, uint methodId, ReadOnlySpan<byte> body)
        => WritePacket(scope, "S2C", "NOTIFY", methodId, 0, null, body);

    public static void OutgoingReturn(string scope, uint methodId, int invokeId, int error, ReadOnlySpan<byte> body)
        => WritePacket(scope, "S2C", "RETURN", methodId, invokeId, error, body);

    public static void RawFrame(string scope, string direction, byte mode, ReadOnlySpan<byte> payload, string note)
    {
        if (!_initialized || !_packetEnabled) return;
        AppendPacket($"{Timestamp()} [{scope}] {direction} FRAME mode=0x{mode:X2} note={note} payload={payload.Length}b");
        if (!_includeHex || payload.Length == 0) return;
        var count = _maxBodyBytes == 0 ? payload.Length : Math.Min(payload.Length, _maxBodyBytes);
        foreach (var line in HexDump(payload[..count]))
            AppendPacket($"    {line}");
        if (count < payload.Length)
            AppendPacket($"    ... truncated {payload.Length - count} bytes (logging.packets.maxBodyBytes={_maxBodyBytes})");
    }

    public static void Decoded(string scope, string direction, uint methodId, Type contractType, object? value)
    {
        if (!_initialized || !_packetEnabled || !_includeDecoded) return;
        string json;
        try
        {
            json = JsonSerializer.Serialize(value, contractType, JsonOptions);
        }
        catch (Exception ex)
        {
            json = $"<decode-log-failed {ex.GetType().Name}: {ex.Message}>";
        }

        AppendPacket($"{Timestamp()} [{scope}] {direction} DECODED {RpcMethodNames.Display(methodId)} type={contractType.Name} {json}");
    }

    private static void WritePacket(
        string scope,
        string direction,
        string kind,
        uint methodId,
        int invokeId,
        int? error,
        ReadOnlySpan<byte> body)
    {
        if (!_initialized || !_packetEnabled) return;

        var invoke = invokeId != 0 ? $" invoke={invokeId}" : string.Empty;
        var err = error.HasValue ? $" error={error.Value}" : string.Empty;
        AppendPacket($"{Timestamp()} [{scope}] {direction} {kind} {RpcMethodNames.Display(methodId)}{invoke}{err} body={body.Length}b");

        if (!_includeHex || body.Length == 0) return;
        var count = _maxBodyBytes == 0 ? body.Length : Math.Min(body.Length, _maxBodyBytes);
        foreach (var line in HexDump(body[..count]))
            AppendPacket($"    {line}");
        if (count < body.Length)
            AppendPacket($"    ... truncated {body.Length - count} bytes (logging.packets.maxBodyBytes={_maxBodyBytes})");
    }

    private static List<string> HexDump(ReadOnlySpan<byte> body)
    {
        const int width = 16;
        var lines = new List<string>((body.Length + width - 1) / width);
        for (var offset = 0; offset < body.Length; offset += width)
        {
            var len = Math.Min(width, body.Length - offset);
            var slice = body.Slice(offset, len);
            var hex = new StringBuilder(width * 3);
            var ascii = new StringBuilder(width);
            for (var i = 0; i < width; i++)
            {
                if (i < len)
                {
                    var b = slice[i];
                    hex.Append(b.ToString("X2")).Append(' ');
                    ascii.Append(b is >= 32 and <= 126 ? (char)b : '.');
                }
                else
                {
                    hex.Append("   ");
                    ascii.Append(' ');
                }
            }
            lines.Add($"{offset:X8}  {hex}|{ascii}|");
        }
        return lines;
    }

    private static string Timestamp() => DateTime.Now.ToString("yyyy-MM-dd HH:mm:ss.fff");

    private static void AppendConsole(string text)
    {
        if (!_initialized || !_consoleEnabled || string.IsNullOrEmpty(text)) return;
        AppendToPair(_consoleLatest, _consoleArchive, text);
    }

    private static void AppendPacket(string line)
        => AppendToPair(_packetLatest, _packetArchive, line + Environment.NewLine);

    private static void AppendToPair(string? latest, string? archive, string text)
    {
        lock (FileLock)
        {
            if (!string.IsNullOrWhiteSpace(latest)) AppendText(latest, text);
            if (!string.IsNullOrWhiteSpace(archive) && !string.Equals(latest, archive, StringComparison.OrdinalIgnoreCase))
                AppendText(archive, text);
        }
    }

    private static void AppendText(string path, string text)
    {
        Directory.CreateDirectory(Path.GetDirectoryName(Path.GetFullPath(path))!);
        using var stream = new FileStream(path, FileMode.Append, FileAccess.Write, FileShare.ReadWrite | FileShare.Delete);
        using var writer = new StreamWriter(stream, new UTF8Encoding(false));
        writer.Write(text);
    }

    private static void PrepareFile(string? path)
    {
        if (string.IsNullOrWhiteSpace(path)) return;
        Directory.CreateDirectory(Path.GetDirectoryName(Path.GetFullPath(path))!);
        File.WriteAllText(path, string.Empty, new UTF8Encoding(false));
    }

    private sealed class MirrorOnlyTextWriter(Encoding encoding, Action<string> mirror) : TextWriter
    {
        public override Encoding Encoding => encoding;

        public override void Write(char value) => mirror(value.ToString());

        public override void Write(string? value)
        {
            if (!string.IsNullOrEmpty(value)) mirror(value);
        }

        public override void WriteLine(string? value)
            => mirror((value ?? string.Empty) + Environment.NewLine);

        public override void WriteLine() => mirror(Environment.NewLine);
    }

    private sealed class TeeTextWriter(TextWriter original, Action<string> mirror) : TextWriter
    {
        public override Encoding Encoding => original.Encoding;

        public override void Write(char value)
        {
            original.Write(value);
            mirror(value.ToString());
        }

        public override void Write(string? value)
        {
            original.Write(value);
            if (!string.IsNullOrEmpty(value)) mirror(value);
        }

        public override void WriteLine(string? value)
        {
            original.WriteLine(value);
            mirror((value ?? string.Empty) + Environment.NewLine);
        }

        public override void WriteLine()
        {
            original.WriteLine();
            mirror(Environment.NewLine);
        }
    }
}

/// <summary>Small SDK-only view so the logging layer does not depend on RPC implementation types.</summary>
public enum RpcPacketKindView
{
    Invoke,
    Notify,
    Return,
}

/// <summary>Global names populated by RpcRouter.Name; outgoing packets can therefore log symbolic MethodId names too.</summary>
public static class RpcMethodNames
{
    private static readonly object Lock = new();
    private static readonly Dictionary<uint, string> Names = new();

    public static void Register(uint methodId, string name)
    {
        lock (Lock)
            Names.TryAdd(methodId, name);
    }

    public static string Display(uint methodId)
    {
        lock (Lock)
            return Names.TryGetValue(methodId, out var name)
                ? $"{name} [0x{methodId:X8}]"
                : $"0x{methodId:X8}";
    }
}
