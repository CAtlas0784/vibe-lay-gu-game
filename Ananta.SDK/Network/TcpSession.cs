using System.Net.Sockets;
using System.Security.Cryptography;
using Ananta.SDK.Logging;
using Ananta.SDK.Rpc;

namespace Ananta.SDK.Network;

public sealed class TcpSession
{
    private readonly SemaphoreSlim _sendLock = new(1, 1);
    private UxChaCha8? _readCryptor;
    private UxChaCha8? _writeCryptor;

    public string Id { get; } = Guid.NewGuid().ToString("N")[..6];
    public TcpClient Client { get; }
    public NetworkStream Stream { get; }
    public ServerLogger Log { get; }
    public Dictionary<string, object> Items { get; } = new();
    public bool CryptReady => _readCryptor is not null && _writeCryptor is not null;

    public TcpSession(TcpClient client, string scope)
    {
        Client = client;
        Stream = client.GetStream();
        Log = new ServerLogger($"{scope}:{Id}");
    }

    public Task<Frame?> ReadFrameAsync(CancellationToken token)
        => FrameCodec.ReadFrameAsync(Stream, _readCryptor, token);

    public async Task SendHandshakeAsync(ReadOnlyMemory<byte> clientHandshake, CancellationToken token)
    {
        if (clientHandshake.Length < 20)
            throw new InvalidDataException($"4229938 C2S handshake is only {clientHandshake.Length} bytes");

        // C2S handshake layout: 4229938 SendHandShakeFrontEnd writes
        // magic(4) + the plain 16-byte UXAES.Generate() key at [4..20)
        // (its UXRSA.Encrypt call is patched out client-side), padded to 260.
        byte[] aesKey = clientHandshake.Slice(4, 16).ToArray();
        Log.Info($"HS raw[0..32]={Convert.ToHexString(clientHandshake.Slice(0, 32).ToArray())}");

        // Decrypted S2C handshake blob expected by TrySetupChaChaOnHandshake:
        //   [0..32)  = client's write key  => server READ key
        //   [32..64) = client's read key   => server WRITE key
        //   [64..76) = shared 96-bit nonce
        // Empirically verified against 4229938: the client encrypts its frames
        // with blob[0..32) (FrameCodec raw-head capture + keystream match).
        byte[] clientWriteKey = RandomNumberGenerator.GetBytes(32);
        byte[] clientReadKey = RandomNumberGenerator.GetBytes(32);
        byte[] streamNonce = RandomNumberGenerator.GetBytes(12);
        byte[] chaChaHead = new byte[76];
        clientWriteKey.CopyTo(chaChaHead, 0);
        clientReadKey.CopyTo(chaChaHead, 32);
        streamNonce.CopyTo(chaChaHead, 64);

        byte[] aesNonce = RandomNumberGenerator.GetBytes(12);
        byte[] cipher = new byte[76];
        byte[] tag = new byte[16];
        using (var aes = new AesGcm(aesKey, 16))
            aes.Encrypt(aesNonce, chaChaHead, cipher, tag);

        byte[] payload = new byte[368];
        BitConverter.GetBytes(1).CopyTo(payload, 0);
        BitConverter.GetBytes(10).CopyTo(payload, 4);
        aesNonce.CopyTo(payload, 8);
        cipher.CopyTo(payload, 20);
        tag.CopyTo(payload, 96);
        // payload[112..368] is the RSA-2048 signature field. The client's
        // UXRSA.Verify result branch is patched out to accept the local
        // unsigned handshake.

        await _sendLock.WaitAsync(token);
        try
        {
            // The handshake reply itself is plaintext. Encryption becomes active
            // only for the next frame in each direction.
            await FrameCodec.WriteFrameAsync(Stream, 0x01, payload, cryptor: null, token: token);
            _readCryptor = new UxChaCha8(clientWriteKey, streamNonce);
            _writeCryptor = new UxChaCha8(clientReadKey, streamNonce);
        }
        finally
        {
            _sendLock.Release();
        }

        Log.Info($"HS keys clientWrite={Convert.ToHexString(clientWriteKey)} clientRead={Convert.ToHexString(clientReadKey)} nonce={Convert.ToHexString(streamNonce)} aes={Convert.ToHexString(aesKey)}");

        Log.Info("HS ok -> UXChaCha8 enabled");
    }

    public Task SendFrameAsync(byte mode, byte[] body, CancellationToken token)
        => WriteEncryptedFrameAsync(mode, body, token);

    public Task NotifyAsync(uint methodId, byte[] body, CancellationToken token)
    {
        RuntimeLogs.OutgoingNotify(Log.Scope, methodId, body);
        return WriteEncryptedFrameAsync(0x09, RpcPacketWriter.WriteNotify(methodId, body), token);
    }

    public Task ReturnAsync(uint methodId, int invokeId, int err, byte[] body, CancellationToken token)
    {
        Log.Info($"<- ret {RpcMethodNames.Display(methodId)} #{invokeId} e={err} {body.Length}b");
        RuntimeLogs.OutgoingReturn(Log.Scope, methodId, invokeId, err, body);
        return WriteEncryptedFrameAsync(0x09, RpcPacketWriter.WriteReturn(methodId, invokeId, err, body), token);
    }

    private async Task WriteEncryptedFrameAsync(byte mode, ReadOnlyMemory<byte> body, CancellationToken token)
    {
        await _sendLock.WaitAsync(token);
        try
        {
            await FrameCodec.WriteFrameAsync(Stream, mode, body, _writeCryptor, token);
        }
        finally
        {
            _sendLock.Release();
        }
    }

    public void Close()
    {
        try { Client.Close(); } catch { }
        _sendLock.Dispose();
    }
}
