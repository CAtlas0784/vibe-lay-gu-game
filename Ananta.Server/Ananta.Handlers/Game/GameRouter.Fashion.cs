using Ananta.SDK.Network;
using Ananta.SDK.Rpc;
using Ananta.SDK.Serialization;
using Ananta.Server.ClientData.Client4229938;
using Ananta.Server.Protocol.Client4229938;
using Ananta.Server.RpcTypes.Client4229938;
using GameMethods = Ananta.Server.RpcTypes.Client4229938.Methods.Game;

namespace Ananta.Server.Handlers.Game;

/// <summary>
/// Wardrobe & Fashion dressing engine for client 4229938.
/// Handles dressing, customizing, and equipping fashion items and persists worn state per spirit.
/// </summary>
internal sealed partial class GameRouter
{
    private async Task HandleAskSetSpiritFashionsWithSourceAsync(Connection conn, UxRpcMessage msg)
    {
        var args = msg.GetArgs<GameMethods.AskSetSpiritFashionsWithSource>();
        var state = GetWorldState(msg.Context);
        var spiritId = args.spiritOrInstanceId;
        if (spiritId == 0) spiritId = state.ActiveSpiritTemplateId;

        state.CustomWornFashionsBySpirit[spiritId] = args.spiritWearFashionsInfo;

        await conn.ReturnEmptyOkAsync(msg);

        // Notify client of updated worn fashion
        await conn.NotifyAsync(MethodId.SyncSetSpiritFashions, new GameMethods.SyncSetSpiritFashions
        {
            spiritId = spiritId,
            source = args.source,
            spiritWearFashionsInfo = args.spiritWearFashionsInfo,
        });

        conn.Session.Log.Info($"[FASHION] AskSetSpiritFashionsWithSource: spirit={spiritId} source={args.source} items={args.spiritWearFashionsInfo.WearFashionInfoList.Count}");
    }

    private async Task HandleAskSetSpiritFashionsAsync(Connection conn, UxRpcMessage msg)
    {
        var args = msg.GetArgs<GameMethods.AskSetSpiritFashions>();
        var state = GetWorldState(msg.Context);
        var spiritId = args.spiritId;
        if (spiritId == 0) spiritId = state.ActiveSpiritTemplateId;

        state.CustomWornFashionsBySpirit[spiritId] = args.spiritWearFashionsInfo;

        await conn.ReturnEmptyOkAsync(msg);

        await conn.NotifyAsync(MethodId.SyncSetSpiritFashions, new GameMethods.SyncSetSpiritFashions
        {
            spiritId = spiritId,
            source = 0,
            spiritWearFashionsInfo = args.spiritWearFashionsInfo,
        });

        conn.Session.Log.Info($"[FASHION] AskSetSpiritFashions: spirit={spiritId} items={args.spiritWearFashionsInfo.WearFashionInfoList.Count}");
    }

    private async Task HandleAskModifySpiritWearFashionsOnlyWearWithSourceAsync(Connection conn, UxRpcMessage msg)
    {
        var args = msg.GetArgs<GameMethods.AskModifySpiritWearFashionsOnlyWearWithSource>();
        var state = GetWorldState(msg.Context);
        var spiritId = args.spiritOrInstanceId;
        if (spiritId == 0) spiritId = state.ActiveSpiritTemplateId;

        var currentWear = GetOrCreateSpiritWear(state, spiritId);
        ApplyFashionWearDiff(currentWear, args.unwearFashionIdList, args.wearFashionInfoList);

        var response = new GameMethods.ModifySpiritWearFashionsOnlyWearResponse
        {
            unwearFashionIdList = args.unwearFashionIdList,
            wearFashionInfoList = args.wearFashionInfoList,
        };
        await conn.ReturnAsync(msg, response);

        await conn.NotifyAsync(MethodId.SyncSetSpiritFashions, new GameMethods.SyncSetSpiritFashions
        {
            spiritId = spiritId,
            source = args.source,
            spiritWearFashionsInfo = currentWear,
        });

        conn.Session.Log.Info($"[FASHION] ModifySpiritWearFashionsOnlyWearWithSource: spirit={spiritId} unwear={args.unwearFashionIdList.Count} wear={args.wearFashionInfoList.Count}");
    }

    private async Task HandleAskModifySpiritWearFashionsOnlyWearAsync(Connection conn, UxRpcMessage msg)
    {
        var args = msg.GetArgs<GameMethods.AskModifySpiritWearFashionsOnlyWear>();
        var state = GetWorldState(msg.Context);
        var spiritId = args.spiritId;
        if (spiritId == 0) spiritId = state.ActiveSpiritTemplateId;

        var currentWear = GetOrCreateSpiritWear(state, spiritId);
        ApplyFashionWearDiff(currentWear, args.unwearFashionIdList, args.wearFashionInfoList);

        var response = new GameMethods.ModifySpiritWearFashionsOnlyWearResponse
        {
            unwearFashionIdList = args.unwearFashionIdList,
            wearFashionInfoList = args.wearFashionInfoList,
        };
        await conn.ReturnAsync(msg, response);

        await conn.NotifyAsync(MethodId.SyncSetSpiritFashions, new GameMethods.SyncSetSpiritFashions
        {
            spiritId = spiritId,
            source = 0,
            spiritWearFashionsInfo = currentWear,
        });

        conn.Session.Log.Info($"[FASHION] ModifySpiritWearFashionsOnlyWear: spirit={spiritId} unwear={args.unwearFashionIdList.Count} wear={args.wearFashionInfoList.Count}");
    }

    private async Task HandleAskModifySpiritWearFashionsWithSourceAsync(Connection conn, UxRpcMessage msg)
    {
        var args = msg.GetArgs<GameMethods.AskModifySpiritWearFashionsWithSource>();
        var state = GetWorldState(msg.Context);
        var spiritId = args.spiritOrInstanceId;
        if (spiritId == 0) spiritId = state.ActiveSpiritTemplateId;

        var currentWear = GetOrCreateSpiritWear(state, spiritId);
        ApplyFashionWearDiff(currentWear, args.unwearFashionIdList, args.wearFashionInfoList);
        ApplyFashionEditDiff(currentWear, args.uneditWearFashionIdList, args.editWearFashionEditInfoList);

        var result = new GameMethods.ModifySpiritWearFashionResult
        {
            R0 = args.unwearFashionIdList,
            R1 = args.wearFashionInfoList,
            R2 = args.uneditWearFashionIdList,
            R3 = args.editWearFashionEditInfoList,
        };
        await conn.ReturnAsync(msg, result);

        await conn.NotifyAsync(MethodId.SyncSetSpiritFashions, new GameMethods.SyncSetSpiritFashions
        {
            spiritId = spiritId,
            source = args.source,
            spiritWearFashionsInfo = currentWear,
        });

        conn.Session.Log.Info($"[FASHION] ModifySpiritWearFashionsWithSource: spirit={spiritId}");
    }

    private async Task HandleAskModifySpiritWearFashionEditInfosWithSourceAsync(Connection conn, UxRpcMessage msg)
    {
        var args = msg.GetArgs<GameMethods.AskModifySpiritWearFashionEditInfosWithSource>();
        var state = GetWorldState(msg.Context);
        var spiritId = args.spiritOrInstanceId;
        if (spiritId == 0) spiritId = state.ActiveSpiritTemplateId;

        var currentWear = GetOrCreateSpiritWear(state, spiritId);
        ApplyFashionEditDiff(currentWear, args.uneditWearFashionIdList, args.editWearFashionEditInfoList);

        var response = new GameMethods.ModifySpiritWearFashionEditInfosResponse
        {
            uneditWearFashionIdList = args.uneditWearFashionIdList,
            editWearFashionEditInfoList = args.editWearFashionEditInfoList,
        };
        await conn.ReturnAsync(msg, response);

        await conn.NotifyAsync(MethodId.SyncSetSpiritFashions, new GameMethods.SyncSetSpiritFashions
        {
            spiritId = spiritId,
            source = args.source,
            spiritWearFashionsInfo = currentWear,
        });
    }

    private async Task HandleAskModifySpiritWearFashionEditInfosAsync(Connection conn, UxRpcMessage msg)
    {
        var args = msg.GetArgs<GameMethods.AskModifySpiritWearFashionEditInfos>();
        var state = GetWorldState(msg.Context);
        var spiritId = args.spiritId;
        if (spiritId == 0) spiritId = state.ActiveSpiritTemplateId;

        var currentWear = GetOrCreateSpiritWear(state, spiritId);
        ApplyFashionEditDiff(currentWear, args.uneditWearFashionIdList, args.editWearFashionEditInfoList);

        var response = new GameMethods.ModifySpiritWearFashionEditInfosResponse
        {
            uneditWearFashionIdList = args.uneditWearFashionIdList,
            editWearFashionEditInfoList = args.editWearFashionEditInfoList,
        };
        await conn.ReturnAsync(msg, response);

        await conn.NotifyAsync(MethodId.SyncSetSpiritFashions, new GameMethods.SyncSetSpiritFashions
        {
            spiritId = spiritId,
            source = 0,
            spiritWearFashionsInfo = currentWear,
        });
    }

    private async Task HandleAskSetSpiritWearFashionHiddenPartsWithSourceAsync(Connection conn, UxRpcMessage msg)
    {
        var args = msg.GetArgs<GameMethods.AskSetSpiritWearFashionHiddenPartsWithSource>();
        var state = GetWorldState(msg.Context);
        var spiritId = args.spiritOrInstanceId;
        if (spiritId == 0) spiritId = state.ActiveSpiritTemplateId;

        var currentWear = GetOrCreateSpiritWear(state, spiritId);
        currentWear.HiddenParts = args.hiddenParts;

        await conn.ReturnEmptyOkAsync(msg);

        await conn.NotifyAsync(MethodId.SyncSetSpiritFashions, new GameMethods.SyncSetSpiritFashions
        {
            spiritId = spiritId,
            source = args.source,
            spiritWearFashionsInfo = currentWear,
        });
    }

    private async Task HandleAskSetSpiritWearFashionHiddenPartsAsync(Connection conn, UxRpcMessage msg)
    {
        var args = msg.GetArgs<GameMethods.AskSetSpiritWearFashionHiddenParts>();
        var state = GetWorldState(msg.Context);
        var spiritId = args.spiritId;
        if (spiritId == 0) spiritId = state.ActiveSpiritTemplateId;

        var currentWear = GetOrCreateSpiritWear(state, spiritId);
        currentWear.HiddenParts = args.hiddenParts;

        await conn.ReturnEmptyOkAsync(msg);

        await conn.NotifyAsync(MethodId.SyncSetSpiritFashions, new GameMethods.SyncSetSpiritFashions
        {
            spiritId = spiritId,
            source = 0,
            spiritWearFashionsInfo = currentWear,
        });
    }

    private static GameMethods.SpiritWearFashionsInfo GetOrCreateSpiritWear(WorldEntryState state, uint spiritId)
    {
        if (!state.CustomWornFashionsBySpirit.TryGetValue(spiritId, out var currentWear))
        {
            var defaultIds = ClientConfigRepository.DefaultFashionIds(spiritId);
            currentWear = RuntimePayloadFactory.WearFashionsForGameMethods(defaultIds);
            state.CustomWornFashionsBySpirit[spiritId] = currentWear;
        }
        return currentWear;
    }

    private static void ApplyFashionWearDiff(
        GameMethods.SpiritWearFashionsInfo wear,
        List<uint> unwearIds,
        List<GameMethods.WearFashionInfo> newWear)
    {
        if (unwearIds.Count > 0)
        {
            var unwearSet = unwearIds.ToHashSet();
            wear.WearFashionInfoList.RemoveAll(x => unwearSet.Contains(x.FashionId));
        }

        foreach (var item in newWear)
        {
            if (!wear.WearFashionInfoList.Any(x => x.FashionId == item.FashionId))
            {
                wear.WearFashionInfoList.Add(item);
            }
        }
    }

    private static void ApplyFashionEditDiff(
        GameMethods.SpiritWearFashionsInfo wear,
        List<uint> uneditIds,
        List<GameMethods.WearFashionEditInfo> newEdits)
    {
        wear.WearFashionEditInfoList ??= [];

        if (uneditIds.Count > 0)
        {
            var uneditSet = uneditIds.ToHashSet();
            wear.WearFashionEditInfoList.RemoveAll(x => uneditSet.Contains(x.FashionId));
        }

        foreach (var item in newEdits)
        {
            var existingIndex = wear.WearFashionEditInfoList.FindIndex(x => x.FashionId == item.FashionId);
            if (existingIndex >= 0)
            {
                wear.WearFashionEditInfoList[existingIndex] = item;
            }
            else
            {
                wear.WearFashionEditInfoList.Add(item);
            }
        }
    }
}
