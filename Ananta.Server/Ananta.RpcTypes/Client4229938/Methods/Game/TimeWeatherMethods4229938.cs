using Ananta.SDK.Serialization;

namespace Ananta.Server.RpcTypes.Client4229938.Methods.Game;

/// <summary>
/// Time/weather wire contracts for client 4229938.
/// S2C shapes from lua (SyncPlayerWeather reader) and the proto dump
/// (SyncPlayerCurrentTime request + RaidTimeAndWeatherChangeReason enum, Gm=0);
/// C2S arg shapes from ClientToGameDelegate.lua serializers.
/// </summary>
[UxContract(Inline = true)]
internal sealed class SyncPlayerCurrentTime4229938
{
    public uint realTime;
    public uint raidDaySeconds;
    public bool fix;
    public bool isPause;
    public uint transitionSecond;
    public int reason;
    public int nodeId;
}

/// <summary>Server notify: SyncPlayerWeather (68712141). lua reader: 3× u32, no marker.</summary>
[UxContract(Inline = true)]
internal sealed class SyncPlayerWeather4229938
{
    public uint weatherTypeId;
    public uint nextWeatherTypeId;
    public uint transitionSecond;
}

/// <summary>Client invoke: AskPassingTime (63465040) / GmPassingTime (65392342).</summary>
[UxContract(Inline = true)]
internal sealed class PassingTimeArgs4229938
{
    public uint hour;
    public uint minute;
}

/// <summary>Client invoke: GmSetTime (65373939).</summary>
[UxContract(Inline = true)]
internal sealed class GmSetTimeArgs4229938
{
    public uint hour;
    public uint minute;
    public uint transition;
}

/// <summary>Client invoke: GmFixRaidTime (65145300).</summary>
[UxContract(Inline = true)]
internal sealed class GmFixRaidTimeArgs4229938
{
    public uint hour;
    public uint minute;
    public bool clear;
}

/// <summary>Personal time slot (WritePersonalTimeSetting order).</summary>
[UxContract]
internal sealed class PersonalTimeSetting4229938
{
    public string Label = string.Empty;
    public uint Hour;
    public uint Minute;
}

/// <summary>Client invoke: ChangePersonalTimeSetting (63153182).</summary>
[UxContract(Inline = true)]
internal sealed class ChangePersonalTimeSettingArgs4229938
{
    public int index;
    public PersonalTimeSetting4229938? info;
}

/// <summary>Client invoke: GmSetWeather (65142873).</summary>
[UxContract(Inline = true)]
internal sealed class GmSetWeatherArgs4229938
{
    public uint weatherId;
}

/// <summary>Client invoke: GmSetWeatherParam (65715648).</summary>
[UxContract(Inline = true)]
internal sealed class GmSetWeatherParamArgs4229938
{
    public uint weatherParamId;
}

/// <summary>Server return: AskTimePanelInfo (63323227).</summary>
[UxContract]
internal sealed class TimePanelInfo4229938
{
    [UxCollection(Count = UxCountEncoding.Int7, ItemObjectEncoding = UxObjectEncoding.Complex)]
    public List<PersonalTimeSetting4229938> PersonalTimeSettings = new();
}

/// <summary>Client invoke: AddPersonalTimeSetting (63617533).</summary>
[UxContract(Inline = true)]
internal sealed class AddPersonalTimeSettingArgs4229938
{
    public PersonalTimeSetting4229938? info;
}

/// <summary>Client invoke: AskSetMobileSkinPart (63575641).</summary>
[UxContract(Inline = true)]
internal sealed class AskSetMobileSkinPartArgs4229938
{
    public uint wallpaper;
    public uint decoration;
    public uint pendant;
}

/// <summary>Client invoke: AskInstallMobileApp (63567675).</summary>
[UxContract(Inline = true)]
internal sealed class AskInstallMobileAppArgs4229938
{
    public uint appId;
}

/// <summary>Client invoke: AskCancelInteractionActionRedPoint (63584158).</summary>
[UxContract(Inline = true)]
internal sealed class AskCancelInteractionActionRedPointArgs4229938
{
    public uint actionId;
}

