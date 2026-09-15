using Ananta.SDK.Serialization;

namespace Ananta.Server.RpcTypes.Client4229938.Methods.GameScene;

[UxContract(Inline = true)]
internal sealed class BuffViewData
{
    public uint InstanceId;
    public uint Id;
    public ulong ReleaserId;
    public double ExpireTime;
    public uint Tier = 1;
    public bool Permanent = true;
    public ulong DestructibleId;
}

[UxContract(Inline = true)]
internal sealed class SyncUnitBuffList
{
    public ulong entityId;
    public List<BuffViewData> buffs = [];
}

[UxContract(Inline = true)]
internal sealed class SyncUnitAddBuff
{
    public ulong entityId;
    public BuffViewData buff = new();
}

[UxContract(Inline = true)]
internal sealed class SyncUnitRemoveBuff
{
    public ulong entityId;
    public uint buffInstanceId;
}

[UxContract(Inline = true)]
internal sealed class AskAddClientBuff
{
    public ulong unitId;
    public uint buffId;
}

[UxContract(Inline = true)]
internal sealed class AskRemoveClientBuff
{
    public ulong unitId;
    public uint buffId;
}

[UxContract(Inline = true)]
internal sealed class AskFeiSuoSuccess
{
    public int feiSuoId;
}
