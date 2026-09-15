using Ananta.Server.Configuration;

namespace Ananta.Server.Gameplay;

/// <summary>
/// Protagonist traversal policy.
/// All editable ids live in config/private-server.json under gameplay.webTraversal.
/// This class only answers gameplay questions for the handlers.
/// </summary>
internal static class WebTraversal
{
    private static WebTraversalSettings Settings => PrivateServerConfigStore.Current.Gameplay.WebTraversal;

    internal static uint MaleProtagonistId => Settings.MaleProtagonistId;
    internal static uint FemaleProtagonistId => Settings.FemaleProtagonistId;
    internal static uint FeiSuoBuff => Settings.PersistentGrappleBuffId;

    // Build 4229938 web traversal split:
    // - Swing/WallRush are client-owned action lifecycle buffs and must NOT be permanent in the login snapshot.
    // - GrappleDiveDamage is a safe, long-lived capability modifier and can be part of the resident kit.
    internal const uint SwingBuff4229938 = 52_853_761;
    internal const uint WallRushBuff4229938 = 52_853_762;
    internal const uint GrappleDiveDamageBuff4229938 = 52_959_114;
    private static readonly uint[] ClientLifecycleBuffs4229938 = [SwingBuff4229938, WallRushBuff4229938];
    private static readonly uint[] ResidentBuildWebBuffs4229938 = [GrappleDiveDamageBuff4229938];

    internal static int GrappleRearmDelayMs => Settings.GrappleRearmDelayMs;
    internal static IReadOnlyList<uint> ForbidStates => Settings.ForbidStateIds;

    internal static IReadOnlyList<uint> InitialCapabilityBuffIds
        => Combine(Settings.SharedBuffIds, new uint[] { Settings.PersistentGrappleBuffId }, Settings.MaleExtraBuffIds, ResidentBuildWebBuffs4229938);

    internal static IReadOnlyList<uint> FemaleCapabilityBuffIds
        => Combine(Settings.SharedBuffIds, new uint[] { Settings.PersistentGrappleBuffId }, Settings.FemaleExtraBuffIds, ResidentBuildWebBuffs4229938);

    internal static bool IsProtagonist(uint templateId)
        => true;

    internal static IReadOnlyList<uint> CapabilityBuffIds(uint templateId)
    {
        if (templateId == Settings.FemaleProtagonistId)
            return FemaleCapabilityBuffIds;
        return InitialCapabilityBuffIds;
    }

    internal static bool IsClientLifecycleBuff(uint buffId)
        => ClientLifecycleBuffs4229938.Contains(buffId);

    internal static bool IsProtected(uint buffId)
        => Settings.SharedBuffIds.Contains(buffId)
           || Settings.MaleExtraBuffIds.Contains(buffId)
           || Settings.FemaleExtraBuffIds.Contains(buffId)
           || ResidentBuildWebBuffs4229938.Contains(buffId);

    internal static bool IsWebBuff(uint buffId)
        => buffId == Settings.PersistentGrappleBuffId || IsProtected(buffId) || IsClientLifecycleBuff(buffId);

    private static uint[] Combine(params IReadOnlyCollection<uint>[] groups)
        => groups.SelectMany(x => x).Distinct().ToArray();
}
