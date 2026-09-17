# Combat Combo & Character Switching Architecture Reference

This document explains the technical implementation of Ananta's combat mechanics and character switching router (derived from the pure DRMK architecture).

---

## 1. Combat System Architecture (`GameRouter.Combat.cs`)

### Problem in Previous Implementations
In naive server implementations, servers artificially tracked server-side skill cooldowns (e.g. `SkillCooldownUntilTicks`) and rejected skill execution packets if sent within a cooldown window. Because Ananta's combat system relies on rapid, fluid multi-hit combo animations and animation cancel windows, artificial cooldowns resulted in:
- Interrupted combo chains (player character freezes after hit 2 or 3 of a light attack combo).
- Skills refusing to fire when triggered from a dodge/dash.
- Desynchronized charge energy meters.

### The DRMK Pure Combat Solution
The DRMK model trusts the client-side animation state machine for combo continuity:
1. **Unconstrained Combo Chaining**: Remove artificial cooldown ticks on standard attacks and skills.
2. **`OnReportSkillEnd` Handling**:
   - When a skill animation or combo phase completes, the client reports `report.newSkillId`.
   - The server maintains the active skill context and avoids clearing resource snapshots mid-chain.
3. **Authoritative Resource Replenishment**:
   - Stamina, ultimate gauge, and skill charges are only replenished when the full combo sequence finishes (`restoreResources == true`).
   - This ensures continuous, uninterrupted combat combos while keeping resource states valid.

---

## 2. Character Switching Architecture (`GameRouter.Switching.cs`)

### The Floating "F" Prompt and Character Lockup Bug
When switching characters, naive implementations swapped the active character ID without formally despawning the previous character from the scene. This caused two major bugs:
1. **Ghost Unit Stalling**: The previous character remained in the scene hierarchy as a ghost entity.
2. **Floating "F" Key Interaction**: Because the previous character was an interactable NPC/companion, an "F: Switch Character" prompt hovered permanently over the active player's head.
3. **CharacterController Locking**: The newly spawned character had incomplete input authority, preventing movement, jumping, or turning.

### The Clean Switch Solution
In `GameRouter.Switching.cs`:
1. **Authoritative Despawn of Previous Character**:
   - Before bringing in the new character, the server sends `SyncLogicAgentLeave(oldUnitId)`.
   - This forces the client to clean up the previous character's GameObject, SkinnedMeshRenderers, and interaction colliders.
2. **Clean Identity Assignment**:
   - Spawns the incoming character with `isAgentSwitch: false` in `WorldCodec.CurrentSpirit`.
   - Sends `SyncGamePause(false)` to guarantee the player controller receives unhindered input focus.
3. **Instant Responsiveness**:
   - The player immediately gains 100% control over the new character (WASD, sprint, jump, attacks) with zero ghosting or floating UI elements.
