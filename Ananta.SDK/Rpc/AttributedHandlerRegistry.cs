using System.Reflection;

namespace Ananta.SDK.Rpc;

/// <summary>Scans [Handler] methods and registers them in RpcRouter.</summary>
public static class AttributedHandlerRegistry
{
    public static RpcRouter Build(string scope, params object[] targets)
    {
        var router = new RpcRouter(scope);
        foreach (var target in targets) Register(router, target);
        return router;
    }

    public static void Register(RpcRouter router, object target)
        => RegisterCore(router, target, allowedMethodIds: null);

    /// <summary>
    /// Registers only explicitly allowed method ids. This is used by build-4229938 minimal mode so
    /// legacy feature handlers stay compiled for reference but cannot emit old-build world/story data.
    /// </summary>
    public static int RegisterSelected(RpcRouter router, object target, IReadOnlySet<uint> allowedMethodIds)
        => RegisterCore(router, target, allowedMethodIds);

    private static int RegisterCore(RpcRouter router, object target, IReadOnlySet<uint>? allowedMethodIds)
    {
        var type = target as Type ?? target.GetType();
        var instance = target is Type ? null : target;
        var registeredMethodIds = new HashSet<uint>();

        foreach (var method in type.GetMethods(BindingFlags.Instance | BindingFlags.Static | BindingFlags.Public | BindingFlags.NonPublic))
        {
            var attrs = method.GetCustomAttributes<HandlerAttribute>(inherit: false).ToArray();
            if (attrs.Length == 0) continue;
            ValidateSignature(method);

            foreach (var attr in attrs)
            {
                if (allowedMethodIds is not null && !allowedMethodIds.Contains(attr.MethodId))
                    continue;

                router.Name(attr.MethodId, $"{type.Name}.{method.Name}");
                Func<RpcContext, Task> invoke = ctx => InvokeAsync(instance, method, ctx);
                if (attr.PacketKind is HandlerPacketKind.Both or HandlerPacketKind.Invoke)
                    router.Add(new AttributedInvokeHandler(attr.MethodId, invoke));
                if (attr.PacketKind is HandlerPacketKind.Both or HandlerPacketKind.Notify)
                    router.Add(new AttributedNotifyHandler(attr.MethodId, invoke));
                registeredMethodIds.Add(attr.MethodId);
            }
        }

        return registeredMethodIds.Count;
    }

    private static void ValidateSignature(MethodInfo method)
    {
        var p = method.GetParameters();
        if (p.Length != 2 || p[0].ParameterType != typeof(Connection) || p[1].ParameterType != typeof(UxRpcMessage))
            throw new InvalidOperationException($"[Handler] {method.DeclaringType?.FullName}.{method.Name} must be (Connection, UxRpcMessage).");

        if (method.ReturnType != typeof(void) && method.ReturnType != typeof(Task) && method.ReturnType != typeof(ValueTask))
            throw new InvalidOperationException($"[Handler] {method.DeclaringType?.FullName}.{method.Name} must return void, Task or ValueTask.");
    }

    private static async Task InvokeAsync(object? instance, MethodInfo method, RpcContext ctx)
    {
        var conn = new Connection(ctx.Session, ctx.CancellationToken);
        var msg = new UxRpcMessage(ctx);
        try
        {
            var result = method.Invoke(instance, new object[] { conn, msg });
            if (result is Task task) await task;
            else if (result is ValueTask valueTask) await valueTask;
        }
        catch (TargetInvocationException ex) when (ex.InnerException is not null)
        {
            throw ex.InnerException;
        }
    }

    private sealed class AttributedInvokeHandler : IRpcHandler
    {
        private readonly Func<RpcContext, Task> _handler;
        public uint MethodId { get; }
        public AttributedInvokeHandler(uint methodId, Func<RpcContext, Task> handler) { MethodId = methodId; _handler = handler; }
        public Task HandleAsync(RpcContext ctx) => _handler(ctx);
    }

    private sealed class AttributedNotifyHandler : INotifyHandler
    {
        private readonly Func<RpcContext, Task> _handler;
        public uint MethodId { get; }
        public AttributedNotifyHandler(uint methodId, Func<RpcContext, Task> handler) { MethodId = methodId; _handler = handler; }
        public Task HandleAsync(RpcContext ctx) => _handler(ctx);
    }
}
