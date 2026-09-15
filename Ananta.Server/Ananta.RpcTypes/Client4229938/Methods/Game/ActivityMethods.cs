using Ananta.SDK.Serialization;

namespace Ananta.Server.RpcTypes.Client4229938.Methods.Game;

[UxContract]
internal sealed class BaseActivityInfo
{
    public uint CfgId;
    public uint StartTime;
    public uint EndTime;
}

[UxContract]
internal sealed class ActivityData
{
    public uint CfgId;
    public bool ShowRedPoint;
    public bool IsOutOfDate;
}

[UxContract(Inline = true)]
internal struct AwardActivityItem
{
    public BaseActivityInfo BaseActivityInfo;
    public ActivityData ActivityData;
}

[UxContract(Inline = true)]
internal sealed class SyncAllActivities
{
    [UxCollection(Count = UxCountEncoding.Int7, ItemObjectEncoding = UxObjectEncoding.Struct)]
    public List<AwardActivityItem> activities = [];
}

[UxContract(Inline = true)]
internal sealed class AskActivityCancelRedPointArgs
{
    public uint id;
}
