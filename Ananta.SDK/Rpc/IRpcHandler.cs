namespace Ananta.SDK.Rpc;

public interface IRpcHandler
{
    uint MethodId { get; }
    Task HandleAsync(RpcContext ctx);
}
