# Debug API & Web Management Panel Reference

This document details the architecture and REST API of the embedded Debug Panel (`DebugApiServer.cs`) and WebUI (`index.html`).

---

## 1. Architecture Overview

The Debug API server is an embedded HTTP daemon running on `http://127.0.0.1:5809/`:
- **Self-Contained**: The web frontend (`index.html`) is embedded directly as an assembly resource inside `Ananta.App.dll`.
- **Zero-Dependency**: No external web server (Nginx/Apache/Node) is needed for debug operations.
- **Localhost Restricted**: Bound exclusively to loopback `127.0.0.1` for safety.

---

## 2. Complete REST API Specifications

### `GET /api/status`
Returns live state of the connected game session.
```json
{
  "online": true,
  "player": { "x": 3142.7, "y": 0.0, "z": 2522.8, "yaw": 85.5 },
  "spawn": { "x": 3142.7, "y": 0.0, "z": 2522.8 },
  "ready": true,
  "activeUnit": 1001
}
```

### `GET /api/npc/catalog?cat={category}&q={query}&limit={limit}`
Queries the unified Agent database (`AgentConfig.json`) across 9,347 entities.
- **Parameters**:
  - `cat`: `"all"` | `"monster"` | `"citizen"` | `"police"` | `"animal"` | `"ally"`
  - `q`: Free-text search term (matches Chinese name, English name, or numeric ID)
  - `limit`: Number of records (default `150`, max `300`)
- **Response**:
  ```json
  {
    "categories": [ { "id": "monster", "label": "⚔️ Monsters & Bosses" }, ... ],
    "poiActions": [ { "id": 2, "name": "🧍 Idle" }, { "id": 1, "name": "🚶 Walk" }, ... ],
    "items": [
      {
        "id": 40900579,
        "name": "谜面帮哨兵 (Enigma Gang Sentry)",
        "category": "monster",
        "model": 86971020,
        "camp": 26,
        "defaultPoi": 0
      }
    ]
  }
  ```

### `POST /api/npc/spawn`
Spawns a batch of NPCs or monsters in a player-relative grid.
- **Request Payload**:
  ```json
  {
    "items": [
      { "npcFormworkId": 40900579, "poiActionId": 0 },
      { "npcFormworkId": 40130709, "poiActionId": 2 }
    ],
    "xSpacing": 1.5,
    "zSpacing": 1.5,
    "maxPerRow": 10
  }
  ```

### `GET /api/scenes`
Returns dynamically parsed scene and raid entrance presets from `RaidConfig.json` and `MapentranceConfig.json`.

### `POST /api/world/switch-scene`
Executes an authoritative world transition.
- **Payload**: `{ "preset": "longqi_temple" }` or custom `{ "raidId": 23300999, "instanceId": 20001223, "universeId": 76000888, "x": -4306.0, "y": 156.8, "z": -3240.8, "facing": 133 }`.

### `POST /api/player/teleport`
Instantly teleports the player's active character.
- **Payload**: `{ "x": 100.0, "y": 20.0, "z": -50.0, "facing": 90.0 }`.

### `POST /api/weather/set` & `POST /api/weather/fog`
- **Weather Payload**: `{ "weatherId": 3 }` (1: Sunny, 2: Cloudy, 3: Rain, 4: Storm, 5: Afterrain).
- **Fog Payload**: `{ "density": 0.08 }` (0.00 to 0.15).

### `POST /api/player/toggle-clothes`
Toggles visibility of `SkinnedMeshRenderer` clothing meshes without hiding body geometry.

### `POST /api/player/unstuck` & `POST /api/player/rollback-10s`
- **Unstuck**: Clears animation controller locks and restores player input.
- **Rollback**: Restores position from a rolling 10-second coordinate buffer.
