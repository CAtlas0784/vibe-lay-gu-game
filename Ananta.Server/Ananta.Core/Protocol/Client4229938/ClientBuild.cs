namespace Ananta.Server.Protocol.Client4229938;

/// <summary>
/// Identifies the client ABI implemented by this protocol folder.
/// This is not a private-server setting: supporting another build requires another protocol implementation.
/// Trunk 4229938/4221361/4226719 keeps the 4229938 RPC ids verbatim (verified against the
/// 4229938 ServerMessageProcId dump), so the protocol folder continues to serve it.
/// </summary>
internal static class ClientBuild
{
    internal const int Version = 4229938;
}
