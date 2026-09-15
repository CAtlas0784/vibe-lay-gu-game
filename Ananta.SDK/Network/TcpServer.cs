using System.Net;
using System.Net.Sockets;
using Ananta.SDK.Logging;
using Ananta.SDK.Rpc;

namespace Ananta.SDK.Network;

public sealed class TcpServer
{
    private readonly string _scope;
    private readonly IPEndPoint _endpoint;
    private readonly RpcRouter _router;
    private readonly Func<TcpSession, Frame, CancellationToken, Task>? _customFrameHandler;
    private readonly ServerLogger _log;

    public TcpServer(string scope, string host, int port, RpcRouter router, Func<TcpSession, Frame, CancellationToken, Task>? customFrameHandler = null)
    {
        _scope = scope;
        _endpoint = new IPEndPoint(IPAddress.Parse(host), port);
        _router = router;
        _customFrameHandler = customFrameHandler;
        _log = new ServerLogger(scope);
    }

    public async Task RunAsync(CancellationToken token)
    {
        var listener = new TcpListener(_endpoint);
        listener.Start();
        _log.Info($"listening at {_endpoint}");

        while (!token.IsCancellationRequested)
        {
            var client = await listener.AcceptTcpClientAsync(token);
            _ = Task.Run(() => HandleClientAsync(client, token), token);
        }
    }

    private async Task HandleClientAsync(TcpClient client, CancellationToken token)
    {
        var session = new TcpSession(client, _scope);
        session.Log.Info($"+ {client.Client.RemoteEndPoint}");

        try
        {
            while (!token.IsCancellationRequested && client.Connected)
            {
                var frame = await session.ReadFrameAsync(token);
                if (frame is null) break;

                if (frame.Value.Mode == 0x02)
                {
                    session.Log.Info($"HS {frame.Value.Payload.Length}b");
                    await session.SendHandshakeAsync(frame.Value.Payload, token);
                    continue;
                }

                if (_customFrameHandler is not null)
                {
                    await _customFrameHandler(session, frame.Value, token);
                    continue;
                }

                await _router.DispatchAsync(session, frame.Value, token);
            }
        }
        catch (Exception ex)
        {
            session.Log.Error("session error", ex);
        }
        finally
        {
            session.Log.Info("-");
            session.Close();
        }
    }
}
