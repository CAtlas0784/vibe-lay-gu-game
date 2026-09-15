using Ananta.SDK.Serialization;

namespace Ananta.Server.RpcTypes.Client4229938.Methods.Game;

[UxContract(Inline = true)]
internal sealed class AskSwitchFightStyle
{
    public uint spiritId;
    public uint fightStyleTypeId;
    public uint fightStyleId;
}

[UxContract(Inline = true)]
internal sealed class AskSetWeaponFightStyle
{
    public ulong weaponInstanceId;
    public uint fightStyleId;
}

[UxContract(Inline = true)]
internal sealed class SyncWeaponFightStyleChange
{
    public ulong weaponInstanceId;
    public uint fightStyleId;
}

[UxContract(Inline = true)]
internal sealed class AskLoadWeaponToSlot
{
    public uint spiritId;
    public ulong weaponId;
    public int slotIndex;
}

[UxContract(Inline = true)]
internal sealed class AskDepositSpiritWeapon
{
    public uint spiritId;
    public int slotIndex;
}

[UxContract(Inline = true)]
internal sealed class AskExchangeWeaponSlot
{
    public uint fromSpirit;
    public int fromIndex;
    public uint toSpirit;
    public int toIndex;
}
