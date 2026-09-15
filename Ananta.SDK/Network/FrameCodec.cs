using System.Buffers.Binary;
using System.Net.Sockets;

namespace Ananta.SDK.Network;

public static class FrameCodec
{
    // Public/plain overload retained for handshake/debug compatibility.
    public static Task<Frame?> ReadFrameAsync(NetworkStream stream, CancellationToken token)
        => ReadFrameAsync(stream, null, token);

    internal static async Task<Frame?> ReadFrameAsync(NetworkStream stream, UxChaCha8? cryptor, CancellationToken token)
    {
        // UXStreamSocket decrypts the first five bytes (length + mode) as one
        // continuous stream, then decrypts the payload with the SAME cryptor state.
        var head = new byte[5];
        if (!await ReadExactAsync(stream, head, token)) return null;
        var rawHead = Convert.ToHexString(head);
        cryptor?.XorInPlace(head);

        var payloadLength = BinaryPrimitives.ReadInt32LittleEndian(head.AsSpan(0, 4));
        if (payloadLength < 0 || payloadLength > 8 * 1024 * 1024)
        {
            // Raw bytes kept on purpose: a frame sent before the peer installed
            // its cryptor arrives as plaintext and fails this check.
            Console.Error.WriteLine($"[FRAME-DBG] rawHead={rawHead} decryptedLen={payloadLength} mode={head[4]}");
            throw new InvalidDataException($"Bad frame payload length after decrypt: {payloadLength}");
        }

        var payload = new byte[payloadLength];
        if (payloadLength != 0)
        {
            if (!await ReadExactAsync(stream, payload, token)) return null;
            var rawPayloadHead = Convert.ToHexString(payload.AsSpan(0, Math.Min(16, payload.Length)));
            cryptor?.XorInPlace(payload);
            Console.Error.WriteLine($"[FRAME-DBG] ok len={payloadLength} mode={head[4]} rawPayloadHead={rawPayloadHead} decHead={Convert.ToHexString(head)}");
        }

        return new Frame(head[4], payload);
    }

    // Public/plain overload retained for the plaintext handshake reply.
    public static Task WriteFrameAsync(NetworkStream stream, byte mode, ReadOnlyMemory<byte> payload, CancellationToken token)
        => WriteFrameAsync(stream, mode, payload, null, token);

    internal static async Task WriteFrameAsync(
        NetworkStream stream,
        byte mode,
        ReadOnlyMemory<byte> payload,
        UxChaCha8? cryptor,
        CancellationToken token)
    {
        // Client Send() constructs [LE payloadLength][mode][payload] and, once
        // CryptorWrite exists, encrypts that full range in one continuous call.
        var frame = new byte[5 + payload.Length];
        BinaryPrimitives.WriteInt32LittleEndian(frame.AsSpan(0, 4), payload.Length);
        frame[4] = mode;
        payload.Span.CopyTo(frame.AsSpan(5));

        cryptor?.XorInPlace(frame);

        await stream.WriteAsync(frame, token);
        await stream.FlushAsync(token);
    }

    private static async Task<bool> ReadExactAsync(NetworkStream stream, byte[] buffer, CancellationToken token)
    {
        var offset = 0;
        while (offset < buffer.Length)
        {
            var read = await stream.ReadAsync(buffer.AsMemory(offset, buffer.Length - offset), token);
            if (read == 0) return false;
            offset += read;
        }
        return true;
    }
}
