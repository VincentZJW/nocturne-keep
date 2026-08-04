# Chapter IV S4 Formal Encounter Population

- Status: **implemented and automated-QA verified**
- Authored seed: `40446`
- Formal Main authority: `res://scenes/bootstrap/main_bootstrap.tscn`
- Formal Chapter IV route: `res://chapters/chapter_04_drowned_underkeep/scenes/level/drowned_underkeep.tscn`
- Population scope: 10 combat rooms, 20 EncounterGroups, 46 ordinary/elite enemies

## Runtime contract

Each combat room owns a saved `Chapter04EncounterManifest` and one saved `EncounterSpawner` node. The spawner instantiates only that loaded room's two saved groups. No runtime RNG chooses type, position or facing.

The first spatial group can activate from the west and the second from the east. While a group remains active, the other group's activation area is disarmed. Clearing the active group rearms the remaining group. Enemies remain visible but have AI and process disabled until their group activates.

`simultaneous_attack_limit = 2` is persisted as encounter metadata for future scheduling. The current shared `EncounterGroup` does not yet implement an attack-token scheduler, so S4 does not claim a hard two-attacker runtime cap. S4 guarantees authored group sizes of `2 + 2` or `2 + 3` and only one active group per room.

## Formal population matrix

| Room | Group split | Enemy roster |
|---|---:|---|
| 01 Flooded Intake | 2 + 2 | Gaoler ×2, Harpooner ×1, Raider ×1 |
| 02 Rusted Cellblock | 2 + 3 | Gaoler ×2, Convict ×1, Penitent ×1, Maw ×1 |
| 03 Broken Chainway | 2 + 2 | Gaoler ×1, Harpooner ×1, Raider ×1, Toad ×1 |
| 04 Harpoon Watch Gallery | 2 + 3 | Gaoler ×1, Harpooner ×2, Penitent ×1, Raider ×1 |
| 05 Cistern of the Changed | 2 + 3 | Convict ×1, Raider ×2, Toad ×1, Maw ×1 |
| 07 Leech Sluice | 2 + 2 | Gaoler ×1, Raider ×1, Maw ×2 |
| 08 Gaoler's Workshop | 2 + 3 | Gaoler ×1, Convict ×1, Harpooner ×1, Penitent ×1, Executioner ×1 |
| 09 Soul-Cage Registry | 2 + 2 | Gaoler ×1, Convict ×1, Harpooner ×1, Penitent ×1 |
| 10 Floodgate Engine Hall | 2 + 3 | Convict ×1, Penitent ×1, Raider ×1, Toad ×2 |
| 11 Final Lock Approach | 2 + 3 | Gaoler ×1, Convict ×1, Harpooner ×1, Penitent ×1, Executioner ×1 |

## Roster totals

| Enemy type | Count |
|---|---:|
| Drowned Gaoler | 10 |
| Chainbound Convict | 6 |
| Mire Harpooner | 7 |
| Sunken Shield Penitent | 6 |
| Mirefin Raider | 7 |
| Bog Toad | 4 |
| Sewer Maw | 4 |
| Underkeep Executioner | 2 |
| **Total** | **46** |

## Elevated-start contract

Thirteen enemies have reviewed elevated starts: all seven Harpooners, two Gaolers, two Penitents, one Executioner and one Convict. Every elevated record persists a platform-bounded patrol interval and a written access route. Harpooner routes are labelled `H01` through `H07` in the saved data.

Support, checkpoint, Boss-staging, Boss, reward and chapter-transition rooms remain free of ordinary encounters: areas 00, 06, 12, 13, 14, 15 and 16. Formal Ormund activation, reward flow and Chapter V handoff remain outside S4.

## Authored resources

- Data classes: `res://chapters/chapter_04_drowned_underkeep/scripts/encounters/`
- Saved manifests: `res://chapters/chapter_04_drowned_underkeep/resources/encounters/`
- Deterministic authoring tool: `res://chapters/chapter_04_drowned_underkeep/scripts/tools/build_chapter_04_encounters_s4.gd`
- Formal saved rooms: `res://chapters/chapter_04_drowned_underkeep/scenes/rooms/`

Re-running the S3 room builder intentionally restores pre-population room files. When rebuilding from source tools, run S3 first and then the S4 encounter authoring tool.

## F5 manual acceptance route

Set the existing debug chapter start to `CHAPTER_04_DROWNED_UNDERKEEP` / `CH4_START`, then press F5. Traverse west-to-east through areas 01–05, rest in area 06, continue through areas 07–11, then verify areas 12–16 do not gain ordinary enemies. Repeat a room entry from its east transition to confirm spatial activation works in both directions.
