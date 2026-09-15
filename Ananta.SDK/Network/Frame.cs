namespace Ananta.SDK.Network;

public readonly record struct Frame(byte Mode, byte[] Payload);
