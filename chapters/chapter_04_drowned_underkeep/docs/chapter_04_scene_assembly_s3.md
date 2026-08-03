# Chapter IV S3 Formal Scene Assembly / 第四章 S3 正式场景装配

- Chapter: `Chapter IV: Drowned Underkeep / 第四章：沉没下堡`
- Milestone: `CH4-S3`
- Status: **FORMAL 17-AREA ROUTE ASSEMBLED AND MAIN-INTEGRATED**
- Main authority: `res://scenes/bootstrap/main_bootstrap.tscn`
- Chapter scene: `res://chapters/chapter_04_drowned_underkeep/scenes/level/drowned_underkeep.tscn`
- Saved room manifest: `res://chapters/chapter_04_drowned_underkeep/resources/rooms/chapter_04_room_manifest_s3.json`

## 1. S3 scope and stop boundary

S3 turns the accepted S0 route, S1 art direction and S2 environment kit into a real room-based chapter route. It delivers saved room scenes, collision, transitions, camera bounds, spawn points, two checkpoints, semantic future-Encounter slots, MainBootstrap routing and graphical QA. It does **not** populate the locked 46-enemy/20-Encounter manifest, alter enemy or Boss behavior, implement Ormund's formal room activation, or build Chapter V.

The previous `chapter_04_character_trial.tscn` remains an independent character/AI regression tool. It is intentionally no longer instanced by the formal Chapter IV level.

## 2. Runtime architecture

```text
DrownedUnderkeep
├── RoomHost                         # exactly one formal room at a time
├── ChapterRuntime                   # persistent Player, HUD, respawn services
├── ActiveRespawn
└── RoomTransitionController         # fade, room swap, spawn, camera, checkpoint
```

Each formal room owns:

```text
Chapter04Room
├── Background           z = -100
├── Architecture         z = -70
├── RearProps            z = -40
├── RearWater            z = -20
├── Gameplay             z = 0, authoritative collision
├── FrontWaterLip        z = 13, four-pixel foot overlap only
├── FutureEncounterSpawns
├── SpawnPoints           EntryWest / EntryEast / Inspection
└── Transitions           saved west/east destination contract
```

The Player remains at global `z_index = 12`. Fixed architecture and rear water cannot cover the actor body. All formal Sprite consumers use nearest filtering and integer placement.

## 3. Formal route

| # | Room ID | Saved scene | Function | S3 geometry identity |
|---:|---|---|---|---|
| 00 | `CH4_AREA_00` | `ch4_00_drowned_threshold.tscn` | Transition | Chapel limestone, intake arch, first prison gate |
| 01 | `CH4_AREA_01` | `ch4_01_flooded_intake.tscn` | Combat tutorial shell | Intake arches, shallow channel, 60px catwalk |
| 02 | `CH4_AREA_02` | `ch4_02_rusted_cellblock.tscn` | Institution | Repeating intact/bent/open cells and upper walk |
| 03 | `CH4_AREA_03` | `ch4_03_broken_chainway.tscn` | Traversal combat | Supported five-step climb and broken chain spans |
| 04 | `CH4_AREA_04` | `ch4_04_harpoon_watch_gallery.tscn` | Vertical exam | Reachable 60px/124px firing galleries |
| 05 | `CH4_AREA_05` | `ch4_05_cistern_of_the_changed.tscn` | Ecology arena | Corrupted regulator, drains and low islands |
| 06 | `CH4_AREA_06` | `ch4_06_dry_gaolers_cell.tscn` | Safe checkpoint | Dry floor, ledger, keys, supplies and open cell |
| 07 | `CH4_AREA_07` | `ch4_07_leech_sluice.tscn` | Ambush corridor | Low drain mouths, sediment and uninterrupted lane |
| 08 | `CH4_AREA_08` | `ch4_08_gaolers_workshop.tscn` | Elite staging | Supported execution dais, tools and hanging restraint |
| 09 | `CH4_AREA_09` | `ch4_09_soul_cage_registry.tscn` | Mixed vertical truth room | Ordered cage bays, ledger desk and archive ledges |
| 10 | `CH4_AREA_10` | `ch4_10_floodgate_engine_hall.tscn` | Machinery climax | Monumental wheel, gear train and maintenance decks |
| 11 | `CH4_AREA_11` | `ch4_11_final_lock_approach.tscn` | Final combat exam shell | Diminishing isolation gates and distant soul lock |
| 12 | `CH4_AREA_12` | `ch4_12_last_gaol_checkpoint.tscn` | Pre-Boss checkpoint | Dry key station and Boss-gate silhouette |
| 13 | `CH4_AREA_13` | `ch4_13_soul_lock_antechamber.tscn` | Boss staging | Symmetrical empty cages and layered soul lock |
| 14 | `CH4_AREA_14` | `ch4_14_core_of_drowned_gaol.tscn` | Boss arena geometry | 1400px clear flat centre, crown and three lock recesses |
| 15 | `CH4_AREA_15` | `ch4_15_broken_soul_reservoir.tscn` | Reward/revelation | Broken reservoir, released cages and silver memory water |
| 16 | `CH4_AREA_16` | `ch4_16_hall_of_drowned_memories.tscn` | Chapter V transition | Ruined present reflected as intact royal corridor |

## 4. Traversal, collision and checkpoint contract

- Every room floor has an exact visual/collision top at `y = 620` and a Player baseline at `y = 592`.
- Mandatory platform elevations do not exceed the locked 124px staged-route envelope. Wider combat/ranged ledges are 128–256px; stepping stones are 64–96px.
- Platforms use real supported S2 assets and matching `StaticBody2D` rectangles; decorative architecture has no phantom collision.
- West/east exits are saved `Area2D` boundaries using the Player body mask. A 0.18s fade locks input and grants temporary transition invulnerability.
- Formal checkpoints are `DRY_GAOLER_CELL` (Area 06) and `LAST_GAOL` (Area 12). Room entry also provides a safe local respawn anchor so a death never targets an unloaded room.
- Area 16 has no Chapter V exit. It remains a sealed formal placeholder until Chapter V production is approved.

## 5. Future Encounter handoff

Combat rooms contain the locked ordinary-enemy count as semantic `GroundSlotXX` markers and reachable platform markers with `platform_ranged`/`platform_heavy` metadata. They are authoring anchors only: `formal_encounters_populated = false` in the manifest. S4 must persist the fixed-seed 40446 allocation and may not reroll at runtime.

Area 14 contains `BossSlot` and a `boss_arena_clear_width = 1400` contract. The existing Ormund scene and character trial remain independently tested, but formal Boss activation/HUD integration is deliberately deferred to the approved Boss/Encounter integration milestone.

## 6. Main/F5 test route

Set the chapter debug target to `CHAPTER_04_DROWNED_UNDERKEEP`. `CH4_START` opens Area 00. Existing compatibility starts map to the formal route:

- `CH4_HUMANOID_COMBAT` → Area 01;
- `CH4_CREATURE_COMBAT` → Area 05;
- `CH4_ELITE_TRIAL` → Area 08;
- `CH4_BOSS_PHASE_01` / `CH4_BOSS_PHASE_02` → Area 14 geometry.

All `CH4_AREA_00` through `CH4_AREA_16` are also exposed by the Chapter IV start profile for direct F5 QA. Walk through the right boundary to advance and the left boundary to return. Main owns the newest room scenes through `Chapter04RoomTransitionController.ROOM_SCENES`; there are no Inspector overrides or old threshold/CharacterTrial references in the formal level.

## 7. Completion boundary

S3 is complete for environment scene assembly, route traversal, collisions, spawn/checkpoint semantics, camera and Main integration. It is not the completion of Chapter IV gameplay: enemy Encounter population, ordinary combat pacing, formal Ormund activation/HUD/reward flow and the eventual Chapter V handoff remain future approved milestones.
