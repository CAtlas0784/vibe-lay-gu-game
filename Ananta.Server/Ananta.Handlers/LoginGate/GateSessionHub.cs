using Ananta.SDK.Network;

namespace Ananta.Server.Handlers.LoginGate;

/// <summary>
/// Tracks the authenticated Gate socket. IMasterToClient is routed to ServerMark.Gate
/// in client build 4229938, so server-pushed master RPCs must use this session, not Game.
/// </summary>
internal sealed class GateSessionHub
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
