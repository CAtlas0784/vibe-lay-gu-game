using Ananta.SDK.Serialization;
using Ananta.Server.RpcTypes.Client4229938.Auto;

namespace Ananta.Server.RpcTypes.Client4229938.Methods.Game;

[UxContract(Inline = true)]
internal sealed class AskDrawGachaArgs
{
    public uint gachaPoolId;
    public uint drawCount;
    public bool isAutoExchange;
}

[UxContract(Inline = true)]
internal struct GachaDrawDetail
{
    public uint PoolContentId;
    public bool IsGrandPrize;
    public bool IsConverted;
    public bool IsNew;
}

[UxContract(Inline = true)]
internal sealed class SyncGachaDrawInfo
{
    [UxCollection(Count = UxCountEncoding.Int7, ItemObjectEncoding = UxObjectEncoding.Struct)]
    public List<GachaDrawDetail> drawDetails = [];
    public bool isGrandPrizeWithAllFillers;
}

[UxContract(Inline = true)]
internal sealed class AskClaimGachaMilestoneArgs
{
    public uint groupId;
    public uint milestoneCount;
}

[UxContract(Inline = true)]
internal sealed class AskGachaDrawRecordsArgs
{
    public uint poolId;
    public uint pageIndex;
}
