# Chapter III Enemy Distribution Specification

Version: B0–B5 formal authoring baseline

Date: 2026-07-30

Authoring seed: `31372026`

## Runtime contract

Chapter III keeps the vestibule, Boss checkpoint, Boss antechamber, Boss sanctum,
post-Boss reliquary and underkeep descent free of normal enemies. The first formal
combat room is `CH3_NAVE_ENTRY`, immediately after the safe vestibule.

The nine combat-room definitions are saved under
`res://chapters/chapter_03_chapel_of_thirteen_echoes/resources/encounters/`.
They are authored Resources, not runtime-random spawn tables. The generator may be
rerun during development with seed `31372026`, but formal play only loads the saved
result.

Each room is loaded independently by `Chapter03RoomTransitionController`. Only the
current room exists under `RoomHost`. Within that room, enemies begin with process,
physics processing and AI disabled. Crossing an EncounterGroup `ActivationArea`
enables exactly that group; enemies never pursue through a room transition and no
group respawns infinitely.

## Formal roster

| Enemy | Count | Spawn role |
|---|---:|---|
| Bellchain Penitent / 钟链忏者 | 22 | `ground_light` |
| Censer Executioner / 香炉行刑者 | 8 | `ground_heavy` |
| Silent Chorister / 无声唱诗灵 | 12 | `platform_ranged` |
| Stained-Glass Seraph / 彩窗圣骸 | 10 | `air_anchor` |
| Confessional Wraith / 忏悔亡魂 | 10 | `confessional_spawn` |
| Thirteenth Scribe / 十三响司录者 | 10 | `platform_ranged` |
| **Total** | **72** | Boss and Boss summons excluded |

## Room and encounter allocation

| Scene / room id | Groups | Bellchain | Executioner | Chorister | Seraph | Wraith | Scribe | Total |
|---|---:|---:|---:|---:|---:|---:|---:|---:|
| `CH3_NAVE_ENTRY` | 2 | 2 | 0 | 1 | 0 | 1 | 0 | 4 |
| `CH3_MAIN_NAVE_FRONT` | 2 | 4 | 0 | 2 | 1 | 0 | 1 | 8 |
| `CH3_MAIN_NAVE_REAR` | 2 | 3 | 1 | 1 | 1 | 1 | 1 | 8 |
| `CH3_CONFESSIONALS` | 2 | 2 | 0 | 1 | 0 | 4 | 1 | 8 |
| `CH3_CHOIR_GALLERY` | 3 | 2 | 1 | 3 | 1 | 0 | 2 | 9 |
| `CH3_STAINED_GLASS_HALL` | 2 | 2 | 0 | 1 | 4 | 0 | 1 | 8 |
| `CH3_ARCHIVE_RELIQUARY` | 2 | 2 | 1 | 1 | 0 | 1 | 3 | 8 |
| `CH3_BLOOD_CANDLE_CHAPEL` | 2 | 3 | 2 | 1 | 1 | 1 | 0 | 8 |
| `CH3_PRE_BOSS_COMBAT` | 3 | 2 | 3 | 1 | 2 | 2 | 1 | 11 |
| **Total** | **20** | **22** | **8** | **12** | **10** | **10** | **10** | **72** |

The prompt's example allocation totaled nine Wraiths and eleven Scribes despite its
authoritative 10/10 roster. The saved pre-Boss third group therefore uses one Wraith
in place of the extra Scribe. This is the only composition correction; every room
total and the 72-enemy total remain unchanged.

## Placement rules

- Bellchain Penitents use the ground route and broad patrol bounds.
- Censer Executioners use ground-heavy positions only; they never spawn on the
  narrow ranged platforms.
- Silent Choristers and Thirteenth Scribes receive reachable 192-pixel platforms.
  An upper platform also receives a 96-pixel intermediate step so the player can
  reach it with normal Chapter III traversal.
- Stained-Glass Seraphs start at a fixed high `air_anchor`, with clear ground below.
- Confessional Wraiths use rear/side ambush positions, never a ranged-platform role.
- Each group contains one to four enemies. A room may contain multiple groups, but
  crossing one activation zone never wakes the following room or every room at once.

## Opening encounter

`CH3_VESTIBULE` remains a safe title and transition space. Entering
`CH3_NAVE_ENTRY` reveals two Bellchain Penitents and one platform Silent Chorister.
The rear Confessional Wraith is isolated in the second ActivationArea and wakes only
after the player advances. This provides the requested `3 + 1` staged opening.

## Debug starts

Formal MainBootstrap debug targets:

- `CH3_START`
- `CH3_OPENING_ENCOUNTER`
- `CH3_MAIN_NAVE`
- `CH3_CONFESSIONALS`
- `CH3_CHOIR_GALLERY`
- `CH3_STAINED_GLASS_HALL`
- `CH3_ARCHIVE`
- `CH3_BLOOD_CANDLE_ZONE`
- `CH3_PRE_BOSS_COMBAT`

All targets instantiate the normal shared Player, HUD, equipment and Chapter III
route. They do not bypass `MainBootstrap` with a standalone combat scene.

## Verification boundary

Automated tests prove authored totals, role compatibility, safe-room exclusions,
fixed seed, activation/process gating, route registration and debug starts. Main QA
captures prove the saved scenes render through the formal Bootstrap path. Encounter
fairness, combat cadence and the subjective pressure curve remain manual playtest
items and should not be inferred from headless results alone.
