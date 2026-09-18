using Ananta.SDK.Serialization;
using Auto = Ananta.Server.RpcTypes.Client4229938.Auto;

namespace Ananta.Server.RpcTypes.Client4229938.Methods.Game;

/// <summary>Exact build-4229938 backpack delta used for separate firearm ammunition.</summary>
[UxContract(Inline = true)]
internal sealed class SyncBackpackItemChanged4229938
{
    [UxCollection(Count = UxCountEncoding.Int7, ItemObjectEncoding = UxObjectEncoding.Complex)]
    public List<Auto.PlayerPackItem> addItemList = [];

    [UxCollection(Count = UxCountEncoding.Int7, ItemObjectEncoding = UxObjectEncoding.Complex)]
    public List<Auto.PlayerPackItem> updateItemList = [];

    [UxCollection(Count = UxCountEncoding.Int7, ItemObjectEncoding = UxObjectEncoding.Complex)]
    public List<Auto.PlayerPackItem> deleteItemList = [];
}

/// <summary>Authoritative wallet totals. The client stores these verbatim and refreshes the HUD.</summary>
[UxContract(Inline = true)]
internal sealed class SyncMoney4229938
{
    public double money;
    public double gold;
    public double bindingGold;
}

/// <summary>Visual-only money grant used for the drop/reward popup (no client state change).</summary>
[UxContract(Inline = true)]
internal sealed class SyncMoneyAdd4229938
{
    public double value;
    public int reason;
    public bool silence;
}

/// <summary>
/// One drawn entry of <c>SyncGachaDrawInfo</c>. The client resolves every id through
/// <c>GachaPoolContentConfig</c> for the artwork/name, so only the row id and the three flags travel.
/// </summary>
[UxContract(Inline = true)]
internal sealed class GachaDrawDetail4229938
{
    public uint PoolContentId;
    public bool IsGrandPrize;
    public bool IsConverted;
    public bool IsNew;
}

/// <summary>
/// Result push for <c>AskDrawGacha</c>: the reply itself carries no rewards, the client only plays the
/// animation from this notify (GameToClientImpl.SyncGachaDrawInfo -> GachaManager.ShowGachaResult).
/// </summary>
[UxContract(Inline = true)]
internal sealed class SyncGachaDrawInfo4229938
{
    [UxCollection(Count = UxCountEncoding.Int7, ItemObjectEncoding = UxObjectEncoding.Struct)]
    public List<GachaDrawDetail4229938> drawDetails = [];

    public bool isGrandPrizeWithAllFillers;
}
