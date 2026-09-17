# NetEase Unity / UX-RPC Protocol & World Entry Handoff Reference

This document defines the packet framing, protocol conventions, and runtime handoff transactions required to successfully enter the world, switch characters, and manage gameplay state in Project Mugen / Ananta CBT 4229938.

---

## 1. Frame Structure & Encryption

The client communicates over TCP using binary packets:
- **Frame Header**: 4-byte payload length (big-endian).
- **Packet Structure**:
  - `Header`: Packet Kind (`Invoke = 1`, `Return = 2`, `Notify = 3`) + Method ID (u32) + Sequence ID (u32).
  - `Payload`: Binary serialized according to `RPCSerializeAuto.lua` / Il2Cpp `TypeSerializer`.
- **Encryption**: UxChaCha8 stream cipher. Disabled or transparently negotiated during local private server handshakes.

---

## 2. The Strict 4-Step World Entry Handoff (V7 Protocol)

When `Game_LoginGame` or `Game_RequestGameSceneData` is received, the server MUST NOT send presentation, buffs, or combat deltas until the canonical 4-step world entry transaction finishes:

```text
Step 1: SyncLogicAgentEnter (Unit ID)
Step 2: SyncManagedLogicAgent (Unit ID, Player Pid, 0)
Step 3: SyncRaidBattleUnitSpirit (AOI / Position / Facing / Template)
Step 4: SyncPlayerCurrentSpirit (Player Pid, Template ID, Unit ID, isAgentSwitch: false)
```

### Loading Synchronization Sequence:
1. Server sends `SyncEnterScene`.
2. Client loads assets and sends `AskLoadSceneCompleted(sceneId, sessionId)`.
3. Server executes the 4-step handoff above.
4. Client sends `AskLoadingFinished(sceneId, sessionId)`.
5. Server sends `SyncSceneLoadCompleted(sceneId)` as the **first and only** response.
6. Once the client receives `SyncSceneLoadCompleted`, gameplay control is enabled!

---

## 3. Character Switching & Position Persistence

When switching spirits via `AskSwitchSpirit`:
1. Server saves current position & rotation from movement reports.
2. Server executes spirit swap without despawning or moving the actor.
3. Sends `SyncPlayerCurrentSpirit(pid, newTemplateId, newUnitId, isAgentSwitch: true)`.
4. The client plays the switch animation while preserving coordinate continuity.

---

## 4. Web Traversal (Spider-Man Traversal Buffs)

Ananta traversal mechanics (web swinging, wall-running, parkour) rely on persistent buff states applied to the player unit:
- `PersistentGrappleBuffId`: `52853760`
- `SharedBuffIds`: `[52607001, 52606154, 52606102, 52606124, 52853760, 52601457, 52601458, 52601459, 52800600, 52959514, 52959516, 52606105, 52605817]`
- When entering combat or traversal, server notifies `AskAddClientBuff` with these IDs.
