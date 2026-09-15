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
