using Ananta.SDK.Serialization;
using Auto = Ananta.Server.RpcTypes.Client4229938.Auto;
using SceneMethods = Ananta.Server.RpcTypes.Client4229938.Methods.GameScene;

namespace Ananta.Server.RpcTypes.Client4229938.Methods.Game;

[UxContract(Inline = true)]
internal sealed class AskSetSpiritFashionsWithSource
{
    public uint spiritOrInstanceId;
    public short source;
    public SpiritWearFashionsInfo spiritWearFashionsInfo = new();
}

[UxContract(Inline = true)]
internal sealed class AskSetSpiritFashions
{
    public uint spiritId;
    public SpiritWearFashionsInfo spiritWearFashionsInfo = new();
}

[UxContract(Inline = true)]
internal sealed class SyncSetSpiritFashions
{
    public uint spiritId;
    public short source;
    public SpiritWearFashionsInfo spiritWearFashionsInfo = new();
}

[UxContract]
internal sealed class SpiritWearFashionsInfo
{
    public uint FunctionSuitId;
    public WearSourceInfo WearSourceInfo;
    public bool IsTryWear;

    [UxCollection(Count = UxCountEncoding.Int32)]
    public List<WearFashionInfo> WearFashionInfoList = [];

    [UxCollection(Count = UxCountEncoding.Int32)]
    public List<WearFashionEditInfo>? WearFashionEditInfoList = [];

    public byte HiddenParts;
    public byte EditedHiddenParts;
}

[UxContract(Inline = true)]
internal struct WearSourceInfo
{
    public short Source;
    public uint SourceId;
}

[UxContract]
internal sealed class WearFashionInfo
{
    public uint FashionId;
}

[UxContract]
internal sealed class WearFashionEditInfo
{
    public uint FashionId;
    public float Scale;
    public SceneMethods.UxVector3 Rotation;
    public SceneMethods.UxVector3 Offset;
}

[UxContract(Inline = true)]
internal sealed class AskOpenOrCloseFashionPanel
{
    public bool isOpen;
    public int reason;
}

[UxContract(Inline = true)]
internal sealed class AskModifySpiritWearFashionsOnlyWearWithSource
{
    public uint spiritOrInstanceId;
    public short source;
    [UxCollection(Count = UxCountEncoding.Int32)]
    public List<uint> unwearFashionIdList = [];
    [UxCollection(Count = UxCountEncoding.Int32)]
    public List<WearFashionInfo> wearFashionInfoList = [];
}

[UxContract(Inline = true)]
internal sealed class ModifySpiritWearFashionsOnlyWearResponse
{
    [UxCollection(Count = UxCountEncoding.Int32)]
    public List<uint> unwearFashionIdList = [];
    [UxCollection(Count = UxCountEncoding.Int32)]
    public List<WearFashionInfo> wearFashionInfoList = [];
}

[UxContract(Inline = true)]
internal sealed class AskModifySpiritWearFashionsOnlyWear
{
    public uint spiritId;
    [UxCollection(Count = UxCountEncoding.Int32)]
    public List<uint> unwearFashionIdList = [];
    [UxCollection(Count = UxCountEncoding.Int32)]
    public List<WearFashionInfo> wearFashionInfoList = [];
}

[UxContract(Inline = true)]
internal sealed class AskModifySpiritWearFashionsWithSource
{
    public uint spiritOrInstanceId;
    public short source;
    [UxCollection(Count = UxCountEncoding.Int32)]
    public List<uint> unwearFashionIdList = [];
    [UxCollection(Count = UxCountEncoding.Int32)]
    public List<WearFashionInfo> wearFashionInfoList = [];
    [UxCollection(Count = UxCountEncoding.Int32)]
    public List<uint> uneditWearFashionIdList = [];
    [UxCollection(Count = UxCountEncoding.Int32)]
    public List<WearFashionEditInfo> editWearFashionEditInfoList = [];
}

[UxContract(Inline = true)]
internal sealed class ModifySpiritWearFashionResult
{
    [UxCollection(Count = UxCountEncoding.Int32)]
    public List<uint> R0 = [];
    [UxCollection(Count = UxCountEncoding.Int32)]
    public List<WearFashionInfo> R1 = [];
    [UxCollection(Count = UxCountEncoding.Int32)]
    public List<uint> R2 = [];
    [UxCollection(Count = UxCountEncoding.Int32)]
    public List<WearFashionEditInfo> R3 = [];
}

[UxContract(Inline = true)]
internal sealed class AskModifySpiritWearFashionEditInfosWithSource
{
    public uint spiritOrInstanceId;
    public short source;
    [UxCollection(Count = UxCountEncoding.Int32)]
    public List<uint> uneditWearFashionIdList = [];
    [UxCollection(Count = UxCountEncoding.Int32)]
    public List<WearFashionEditInfo> editWearFashionEditInfoList = [];
}

[UxContract(Inline = true)]
internal sealed class ModifySpiritWearFashionEditInfosResponse
{
    [UxCollection(Count = UxCountEncoding.Int32)]
    public List<uint> uneditWearFashionIdList = [];
    [UxCollection(Count = UxCountEncoding.Int32)]
    public List<WearFashionEditInfo> editWearFashionEditInfoList = [];
}

[UxContract(Inline = true)]
internal sealed class AskModifySpiritWearFashionEditInfos
{
    public uint spiritId;
    [UxCollection(Count = UxCountEncoding.Int32)]
    public List<uint> uneditWearFashionIdList = [];
    [UxCollection(Count = UxCountEncoding.Int32)]
    public List<WearFashionEditInfo> editWearFashionEditInfoList = [];
}

[UxContract(Inline = true)]
internal sealed class AskSetSpiritWearFashionHiddenPartsWithSource
{
    public uint spiritOrInstanceId;
    public short source;
    public byte hiddenParts;
}

[UxContract(Inline = true)]
internal sealed class AskSetSpiritWearFashionHiddenParts
{
    public uint spiritId;
    public byte hiddenParts;
}

[UxContract(Inline = true)]
internal sealed class AskUnlockFashionColoringSlot
{
    public uint fashionId;
    public byte unlockSlotCount;
}

[UxContract(Inline = true)]
internal sealed class AskUnlockFashionSuitSlot
{
    public uint spiritId;
    public byte unlockSlotCount;
}

[UxContract(Inline = true)]
internal sealed class AskFavoriteFashions
{
    [UxCollection(Count = UxCountEncoding.Int32)]
    public List<uint> unfavoriteFashionIdList = [];
    [UxCollection(Count = UxCountEncoding.Int32)]
    public List<uint> favoriteFashionIdList = [];
}

[UxContract(Inline = true)]
internal sealed class AskFavoriteFashionSuits
{
    [UxCollection(Count = UxCountEncoding.Int32)]
    public List<uint> unfavoriteFashionSuitIdList = [];
    [UxCollection(Count = UxCountEncoding.Int32)]
    public List<uint> favoriteFashionSuitIdList = [];
}

[UxContract(Inline = true)]
internal sealed class AskReadFashions
{
    [UxCollection(Count = UxCountEncoding.Int32)]
    public List<uint> fashionIdList = [];
}

[UxContract(Inline = true)]
internal sealed class AskReadFashionSuits
{
    [UxCollection(Count = UxCountEncoding.Int32)]
    public List<uint> fashionSuitIdList = [];
}

[UxContract(Inline = true)]
internal sealed class AskSetSpiritFashionVariantPreference
{
    public uint spiritId;
    public uint mainFashionId;
    public uint variantFashionId;
}

/// <summary>Server -> client SyncPlayerAllSpirits: top-level List7Bit&lt;SpiritInfo&gt;.</summary>
[UxContract(Inline = true)]
internal sealed class SyncPlayerAllSpirits
{
    [UxCollection(Count = UxCountEncoding.Int7, ItemObjectEncoding = UxObjectEncoding.Complex)]
    public List<Auto.SpiritInfo> spirits = [];
}

[UxContract]
internal sealed class SpiritViewData
{
    public Auto.SpiritInfo SpiritInfo = new();
}

/// <summary>
/// Incremental roster hydration. The build's handler ignores reason and adds/replaces one view entry,
/// avoiding a single oversized SyncPlayerAllSpirits payload with every character loadout embedded.
/// </summary>
[UxContract(Inline = true)]
internal sealed class SyncPlayerAddNewSpirit
{
    public SpiritViewData spirit = new();
    public int reason;
}

/// <summary>Return body of AskAllSpiritPanelData: top-level List7Bit&lt;SpiritPanelData&gt;.</summary>
[UxContract(Inline = true)]
internal sealed class AskAllSpiritPanelDataResult
{
    [UxCollection(Count = UxCountEncoding.Int7, ItemObjectEncoding = UxObjectEncoding.Complex)]
    public List<Auto.SpiritPanelData> spirits = [];
}
