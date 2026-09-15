using System.Buffers.Binary;
using System.Numerics;

namespace Ananta.SDK.Network;

/// <summary>
/// Exact stream cipher used by the 4229938 UXNetwork client.
/// It is ChaCha8-shaped, but the four sigma constants are client-specific.
/// </summary>
internal sealed class UxChaCha8
{
    // GameAssembly.dll 4229938 / UXChaCha8Impl::.ctor
    // NOTE: these deliberately differ from standard "expand 32-byte k".
    private const uint Sigma0 = 0x60707865;
    private const uint Sigma1 = 0x3321646e;
    private const uint Sigma2 = 0x79622d32;
    private const uint Sigma3 = 0x6b206e74;

    private readonly uint[] _state = new uint[16];
    private readonly byte[] _keystream = new byte[64];
    private int _keystreamPos = 64;

    public UxChaCha8(ReadOnlySpan<byte> key, ReadOnlySpan<byte> nonce)
    {
        if (key.Length != 32)
            throw new ArgumentException("UXChaCha8 key must be 32 bytes.", nameof(key));
        if (nonce.Length != 12)
            throw new ArgumentException("UXChaCha8 nonce must be 12 bytes.", nameof(nonce));

        _state[0] = Sigma0;
        _state[1] = Sigma1;
        _state[2] = Sigma2;
        _state[3] = Sigma3;

        for (var i = 0; i < 8; i++)
            _state[4 + i] = BinaryPrimitives.ReadUInt32LittleEndian(key.Slice(i * 4, 4));

        // Client constructor sets word 12 to zero and uses a 96-bit nonce.
        _state[12] = 0;
        _state[13] = BinaryPrimitives.ReadUInt32LittleEndian(nonce.Slice(0, 4));
        _state[14] = BinaryPrimitives.ReadUInt32LittleEndian(nonce.Slice(4, 4));
        _state[15] = BinaryPrimitives.ReadUInt32LittleEndian(nonce.Slice(8, 4));
    }

    public void XorInPlace(Span<byte> data)
    {
        var offset = 0;
        while (offset < data.Length)
        {
            if (_keystreamPos == 64)
            {
                GenerateBlock();
                _keystreamPos = 0;
            }

            var take = Math.Min(64 - _keystreamPos, data.Length - offset);
            for (var i = 0; i < take; i++)
                data[offset + i] ^= _keystream[_keystreamPos + i];

            offset += take;
            _keystreamPos += take;
        }
    }

    private void GenerateBlock()
    {
        Span<uint> x = stackalloc uint[16];
        _state.AsSpan().CopyTo(x);

        // UXChaCha8 is 8 rounds = four column+diagonal double-rounds.
        for (var i = 0; i < 4; i++)
        {
            QuarterRound(ref x[0], ref x[4], ref x[8], ref x[12]);
            QuarterRound(ref x[1], ref x[5], ref x[9], ref x[13]);
            QuarterRound(ref x[2], ref x[6], ref x[10], ref x[14]);
            QuarterRound(ref x[3], ref x[7], ref x[11], ref x[15]);

            QuarterRound(ref x[0], ref x[5], ref x[10], ref x[15]);
            QuarterRound(ref x[1], ref x[6], ref x[11], ref x[12]);
            QuarterRound(ref x[2], ref x[7], ref x[8], ref x[13]);
            QuarterRound(ref x[3], ref x[4], ref x[9], ref x[14]);
        }

        for (var i = 0; i < 16; i++)
            BinaryPrimitives.WriteUInt32LittleEndian(_keystream.AsSpan(i * 4, 4), unchecked(x[i] + _state[i]));

        // Client increments only the 32-bit block counter (state[12]).
        _state[12] = unchecked(_state[12] + 1);
    }

    private static void QuarterRound(ref uint a, ref uint b, ref uint c, ref uint d)
    {
        a = unchecked(a + b);
        d ^= a;
        d = BitOperations.RotateLeft(d, 16);

        c = unchecked(c + d);
        b ^= c;
        b = BitOperations.RotateLeft(b, 12);

        a = unchecked(a + b);
        d ^= a;
        d = BitOperations.RotateLeft(d, 8);

        c = unchecked(c + d);
        b ^= c;
        b = BitOperations.RotateLeft(b, 7);
    }
}
