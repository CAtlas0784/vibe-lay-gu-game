namespace Ananta.SDK.Configuration;

public sealed record ServerEndpoint(string Host, int Port)
{
    public override string ToString() => $"{Host}:{Port}";
}
