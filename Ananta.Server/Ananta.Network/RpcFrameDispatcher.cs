using System.Buffers.Binary;
using Ananta.SDK.Network;
using Ananta.SDK.Logging;
using Ananta.SDK.Rpc;

namespace Ananta.Server.Network;

/// <summary>Decodes the small outer RPC frame envelope shared by login, gate and game sockets.</summary>
internal static class RpcFrameDispatcher
{
    internal static async Task DispatchAsync(
        RpcRouter router,
        TcpSession session,
        Frame frame,
        CancellationToken cancellationToken)
    {
        // Heartbeat request -> heartbeat reply.
        if (frame.Mode == 0x04)
        {
            var heartbeat = frame.Payload.Length == 8 ? frame.Payload : new byte[8];
            await session.SendFrameAsync(0x03, heartbeat, cancellationToken);
            return;
        }

        if (frame.Mode == 0x03 && frame.Payload.Length == 8)
            return;

        // Client received an invoke that it does not implement. Acknowledge it instead of
        // letting an optional compatibility RPC break the whole session.
        if (frame.Mode == 0x08 && frame.Payload.Length >= 9)
        {
            RuntimeLogs.RawFrame(session.Log.Scope, "C2S", frame.Mode, frame.Payload, "CLIENT_UNIMPLEMENTED_INVOKE");
            var methodId = BinaryPrimitives.ReadUInt32LittleEndian(frame.Payload.AsSpan(1, 4));
            var invokeId = BinaryPrimitives.ReadInt32LittleEndian(frame.Payload.AsSpan(5, 4));
            await session.ReturnAsync(methodId, invokeId, 0, Array.Empty<byte>(), cancellationToken);
            return;
        }

        if (frame.Mode == 0x09)
        {
            await router.DispatchAsync(session, frame, cancellationToken);
            return;
        }

        RuntimeLogs.RawFrame(session.Log.Scope, "C2S", frame.Mode, frame.Payload, "IGNORED_FRAME_MODE");
        session.Log.Warn($"ignored frame mode={frame.Mode} payload={frame.Payload.Length}");
    }
}
