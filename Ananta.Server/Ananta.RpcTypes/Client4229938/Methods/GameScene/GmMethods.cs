using Ananta.SDK.Serialization;

namespace Ananta.Server.RpcTypes.Client4229938.Methods.GameScene;

/// <summary>
/// Client -&gt; GameSceneGM GmSpawnVehicle(uint32 templateid, UXVector3 position, float facing,
/// uint32 suitid, bool loadownvehicle, string spoonname).
/// From ClientToGameSceneGMDelegate.lua (build 4229938). Returns u64 entity id.
/// </summary>
[UxContract(Inline = true)]
internal sealed class GmSpawnVehicle
{
    public uint TemplateId;
    public UxVector3 Position;
    public float Facing;
    public uint SuitId;
    public bool LoadOwnVehicle;
    public string SpoonName = string.Empty;
}

/// <summary>
/// Client -&gt; GameSceneGM GmAddEnemyWithPosition(uint32 enemyid, byte camp-enum92,
/// UXVector3 position, uint32 navtagtype, bool outsideaoimove). Returns u64 entity id.
/// </summary>
[UxContract(Inline = true)]
internal sealed class GmAddEnemyWithPosition
{
    public uint EnemyId;
    public byte Camp;
    public UxVector3 Position;
    public uint NavTagType;
    public bool OutsideAoiMove;
}

/// <summary>
/// Client -&gt; GameSceneGM GmAddEnemy(uint32 enemyid, byte camp-enum92, string treename,
/// uint32 navtagtype, bool outsideaoimove). Returns u64 entity id.
/// </summary>
[UxContract(Inline = true)]
internal sealed class GmAddEnemy
{
    public uint EnemyId;
    public byte Camp;
    public string TreeName = string.Empty;
    public uint NavTagType;
    public bool OutsideAoiMove;
}

/// <summary>
/// Client -&gt; GameSceneGM GmAddEnemyByPlayer(uint32 enemyid, byte camp-enum92).
/// Returns u64 entity id.
/// </summary>
[UxContract(Inline = true)]
internal sealed class GmAddEnemyByPlayer
{
    public uint EnemyId;
    public byte Camp;
}

/// <summary>
/// Client -&gt; GameSceneGM GmTeleportXYZ(float x, float y, float z, float facing).
/// Returns void.
/// </summary>
[UxContract(Inline = true)]
internal sealed class GmTeleportXYZ
{
    public float X;
    public float Y;
    public float Z;
    public float Facing;
}
