# Ananta NPC & Monster Entity System Reference

This document details the unified Agent architecture for Project Mugen / Ananta CBT (Client 4229938), covering NPC civilians, hostile enemies/bosses, animals, and POI actions.

---

## 1. Unified Agent Concept (`AgentConfig.json`)

In Ananta (NetEase L50 engine), all living non-player entities in the world—whether they are street pedestrians, patrolling police officers, stray cats, or colossal bosses—share the exact same underlying entity model defined in `AgentConfig.json` (9,347 records).

### Camp Classification (Factions)
The engine separates entity behaviors and combat hostility primarily using the `Camp` integer:

| Camp | Category | Description & Examples | Default Behavior |
| :---: | :--- | :--- | :--- |
| **`0`, `26`** | **⚔️ Monsters & Enemies** | Hostile gangsters (谜面帮), thugs, mech bikers (狂飙引擎), TV-heads (电视脑), mutant bosses, and slime creatures. | Hostile, targets Player on sight, combat AI active. |
| **`2`** | **🚶 Citizens & Civilians** | Urban civilians, students, workers, passersby (e.g. Nanami McIntyre [40130709], Liam Brown [40130001], Fujiwara Kazuma [4065053]). | Neutral, wanders or plays idle/social POI animations. |
| **`11`** | **🐱 Animals & Mascots** | Domestic animals and quirky world mascots (e.g. Chaos Radio Duck [4065051], Squirrel Radio [4065052], Cats [40120100], Ducks [40120325], Pigeons [40120319]). | Ambient animal behaviors, flees or wanders, non-combatant. |
| **`1`** | **🤝 Allies & Story Companions** | Friendly NPCs, party members in narrative mode, quest givers. | Friendly to player, non-targetable by basic attacks. |
| **`16..25`** | **👮 Police & Security** | Baton patrol officers, shield riot guards, armed security enforcers. | Neutral/Law enforcement, attacks hostile gang factions. |

---

## 2. POI Actions & Animation System (`UrbanDiversityPOIActionConfig.json`)

NPCs and non-hostile entities can be spawned with specific Points of Interest (POI) action IDs that dictate their visual posture and interaction animation:

| POI ID | Animation / Action Name | Description & Usage |
| :---: | :--- | :--- |
| **`0`** | `Auto / Default` | No specific POI; uses entity's default idle or combat stance. Ideal for monsters. |
| **`1`** | `走路 (Walk)` | Natural urban walking locomotion. |
| **`2`** | `idle (Idle Stand)` | Standard standing idle pose. Ideal for street citizens and guards. |
| **`3`** | `受惊 (Scared / Panic)` | Panic/frightened posture with hands raised. |
| **`4`** | `跑步 (Run)` | Jogging/running locomotion. |
| **`5`** | `围观 (Spectate)` | Standing and curiously watching an event / crowd gathering. |
| **`6`** | `站姿_通用_鼓掌 (Clap)` | Standing and applauding / cheering. |
| **`8`** | `使用售货机 (Vending Machine)` | Interaction with drinks/vending machines. |
| **`10`** | `站姿_通用_靠墙休息 (Lean Wall)` | Relaxed posture leaning back against a wall or lamp post. |
| **`11`** | `停驻拍照打电话 (Phone / Photo)` | Holding smartphone up to ear or taking photos. |
| **`12`** | `正式坐闲置 (Formal Sit)` | Sitting upright formally (on bench or chair). |
| **`13`** | `放松坐闲置 (Relaxed Sit)` | Casual sitting posture with relaxed limbs. |
| **`15`** | `坐着交谈 (Sit & Talk)` | Sitting while gesturing and talking to nearby companions. |

---

## 3. Server-Side Spawning Pipeline (`GameRouter.Npc.cs`)

When spawning an agent via `/api/npc/spawn`, the server executes the following pipeline:

1. **Transform Calculation**:
   - Computes player forward vector from player's current yaw rotation.
   - Places the entity batch in an offset grid in front of the player (e.g. 5m forward, distributed with configurable X and Z spacing).
   - Facing angle is rotated $180^\circ$ relative to player so spawned agents face toward the player.

2. **Catalog Validation**:
   - `NpcCatalog4229938.TryGet(npcFormworkId, out var npc)` ensures the ID exists in `AgentConfig.json`.
   - Resolves model ID (`GeneralModelId`), anim set tag (`AnimStereotype` / `BattleAnimType`), and persona ID.

3. **Packet Transmission Sequence**:
   - **`SyncLogicAgentEnter`**: Instantiates entity ID, archetype, position (`Vec3`), rotation (`Vec3`), and base logic state.
   - **`SyncManagedLogicAgent`**: Attaches AI controller, perception component, and behavior action group.
   - **`SyncRaidBattleUnitSpirit`**: Links 3D visual model prefab and combat component asset.
   - **`SyncNpcPoiAction`** (if POI ID > 0): Triggers POI animation cycle.
