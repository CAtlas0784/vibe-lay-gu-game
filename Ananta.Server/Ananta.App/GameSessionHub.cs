using Ananta.SDK.Network;

namespace Ananta.Server.App;

internal sealed class GameSessionHub
{
    private TcpSession? _current;
    private long _lastSeenTicks;

    internal TcpSession? Current => Volatile.Read(ref _current);
    internal DateTimeOffset? LastSeenUtc
    {
        get
        {
            var ticks = Interlocked.Read(ref _lastSeenTicks);
            return ticks == 0 ? null : new DateTimeOffset(ticks, TimeSpan.Zero);
        }
    }

    internal void Touch(TcpSession session)
    {
        Volatile.Write(ref _current, session);
        Interlocked.Exchange(ref _lastSeenTicks, DateTimeOffset.UtcNow.Ticks);
    }
}
