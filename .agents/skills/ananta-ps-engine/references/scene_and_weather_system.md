# Scene Switching, Weather Engine, and Map Warp Reference

This document covers the mechanics for world region ("raid") switching, atmospheric/weather control, and the 2-click pin & warp map interaction.

---

## 1. Scene ("Raid") Switching (`SceneCatalog4229938.cs`)

Ananta's open world is partitioned into distinct sub-regions, instances, and raids defined in `RaidConfig.json` and `MapentranceConfig.json`:

### Triad ID Architecture
Every scene transition requires three authoritative identifiers:
1. **`raidId`**: The specific map/dungeon region (e.g. `23300888` for Main City, `23300999` for Longqi Mountain).
2. **`instanceId`**: The active scene instance (e.g. `20001222`, `20001223`).
3. **`universeId`**: The overarching world universe context (standard: `76000888`).

### Dynamic Presets
The server parses all valid map entrances dynamically into `SceneCatalog4229938.Presets`:
- **Main City Center**: `raid: 23300888`, `x: 3142.7`, `y: 0`, `z: 2522.8`
- **Airport District**: `raid: 23300888`, `x: -4468.3`, `y: -6.2`, `z: -2597.5`
- **Longqi Ancient Temple**: `raid: 23300999`, `x: -4306.0`, `y: 156.8`, `z: -3240.8`
- **Longqi Tea Plantation**: `raid: 23300999`, `x: -4818.4`, `y: 192.3`, `z: -2690.1`

When a switch is requested, the server sends `SyncSceneLoadCompleted` and teleports the player's managed spirit into the new instance.

---

## 2. Weather & Atmospheric Control (`WeatherCatalog4229938.cs`)

Ananta features an advanced hybrid weather pipeline combining server RPC state with client shader/particle overrides:

### Standard Weather States (`WeatherCatalog4229938`)
| ID | Weather Name | Environment Visuals |
| :---: | :--- | :--- |
| **`1`** | **☀️ Sunny (晴天)** | Clear sky, bright sunlight, natural shadows. |
| **`2`** | **⛅ Cloudy (多云)** | Overcast clouds, diffused indirect lighting. |
| **`3`** | **🌧️ Rain (小雨)** | Light precipitation, road puddle reflections. |
| **`4`** | **⛈️ Storm (暴风雨)** | Heavy rain, thunderstorm lighting, active wind vectors. |
| **`5`** | **🌤️ Afterrain (雨后)** | High-clarity atmosphere, wet asphalt specular glimmers. |

### Hybrid GPU Rain & Volumetric Fog
To guarantee visual effects render immediately without waiting for client transition cycles:
- **`CMD:SET_WEATHER:<id>`**: Dispatched via `SyncNotice` to activate client-side GPU particle rain (`SetGPURainActive`).
- **`CMD:SET_FOG:<density>`**: Direct override for Unity's Volumetric Exponential Fog density (e.g. `0.08` for heavy fog, `0.00` for crystal clear).

---

## 3. 2-Click Pin & Warp Map Interaction

### Problem with Standard Teleport
In default CBT clients, clicking on the mini-map or full map frequently triggered coordinate conversion errors, causing players to teleport to $(0, 0, 0)$ (ocean fall or out-of-bounds void).

### The 2-Click Pin & Warp Pattern
1. **Click 1**: Left-clicking anywhere on the map drops a navigation pin and notifies the player: `"Pin set! Click again to Warp"`.
2. **Click 2**: Clicking directly on the set pin executes the warp to those precise world coordinates and automatically dismisses the map screen.
3. **Zero-Coordinate Safety Interceptor**: Both client proxy and server packet handlers intercept any destination vector matching $(0, 0, 0)$ or invalid NaN/Infinity coordinates, protecting the player from void death.
