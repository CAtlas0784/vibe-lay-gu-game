namespace Ananta.SDK.Rpc;

public interface INotifyHandler
{
    uint MethodId { get; }
    Task HandleAsync(RpcContext ctx);
}
