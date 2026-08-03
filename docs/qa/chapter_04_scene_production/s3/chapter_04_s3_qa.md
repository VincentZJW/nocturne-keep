# Chapter IV S3 QA / 第四章 S3 正式路线验收

## Automated result

| Gate | Result | Evidence |
|---|---|---|
| 17 saved rooms load | PASS | `test_chapter_04_formal_route_s3.gd`: `rooms=17` |
| Formal asset use | PASS | 664 nearest-filter Sprite references; all resolve beneath the Chapter IV asset root |
| Collision baseline | PASS | All 17 floor tops at y=620; platform widths/elevations validated |
| Route transitions | PASS | 17 ordered room IDs, correct one/two exit contracts, Main controller swaps all rooms |
| Spawn and camera | PASS | `EntryWest`, `EntryEast`, `Inspection` and per-room Camera limits validated |
| Checkpoints | PASS | `DRY_GAOLER_CELL`, `LAST_GAOL` |
| S3 scope | PASS | No ordinary `EnemyCombatant` is instanced; CharacterTrial is separate |
| MainBootstrap | PASS | F5 registry resolves formal `drowned_underkeep.tscn`; all rooms exercised |
| Existing Chapter IV enemy art/runtime | PASS | Eight roles instantiate and retain complete animation/combat resources |
| Existing Ormund runtime | PASS | 47 animations, 560 HP and Phase transition regression unchanged |
| Output / Debugger | PASS | Focused import, route, Main, enemy and Boss tests emit no red script/resource error |

## Exact commands

```text
/Users/vincentz/Downloads/Godot.app/Contents/MacOS/Godot --headless --path . --script res://chapters/chapter_04_drowned_underkeep/scripts/tools/build_chapter_04_formal_rooms_s3.gd
/Users/vincentz/Downloads/Godot.app/Contents/MacOS/Godot --headless --path . --import
/Users/vincentz/Downloads/Godot.app/Contents/MacOS/Godot --headless --path . --script res://chapters/chapter_04_drowned_underkeep/tests/scenes/test_chapter_04_formal_route_s3.gd
/Users/vincentz/Downloads/Godot.app/Contents/MacOS/Godot --headless --path . --script res://chapters/chapter_04_drowned_underkeep/tests/scenes/test_chapter_04_main_route_s3.gd
/Users/vincentz/Downloads/Godot.app/Contents/MacOS/Godot --headless --path . --script res://chapters/chapter_04_drowned_underkeep/tests/characters/test_chapter_04_enemy_runtime.gd
/Users/vincentz/Downloads/Godot.app/Contents/MacOS/Godot --headless --path . --script res://chapters/chapter_04_drowned_underkeep/tests/characters/test_soul_gaoler_ormund_runtime.gd
/Users/vincentz/Downloads/Godot.app/Contents/MacOS/Godot --headless --path . --script res://chapters/chapter_04_drowned_underkeep/tests/characters/test_chapter_04_main_integration.gd
/Users/vincentz/Downloads/Godot.app/Contents/MacOS/Godot --path . --script res://chapters/chapter_04_drowned_underkeep/scripts/tests/capture_chapter_04_formal_route_s3.gd
```

## Main/F5 visual evidence

All 17 images were produced through `main_bootstrap.tscn`, not by opening room scenes directly:

- `main/00_drowned_threshold_main.png`
- `main/01_flooded_intake_main.png`
- `main/02_rusted_cellblock_main.png`
- `main/03_broken_chainway_main.png`
- `main/04_harpoon_watch_gallery_main.png`
- `main/05_cistern_of_the_changed_main.png`
- `main/06_dry_gaolers_cell_main.png`
- `main/07_leech_sluice_main.png`
- `main/08_gaolers_workshop_main.png`
- `main/09_soul_cage_registry_main.png`
- `main/10_floodgate_engine_hall_main.png`
- `main/11_final_lock_approach_main.png`
- `main/12_last_gaol_checkpoint_main.png`
- `main/13_soul_lock_antechamber_main.png`
- `main/14_core_of_drowned_gaol_main.png`
- `main/15_broken_soul_reservoir_main.png`
- `main/16_hall_of_drowned_memories_main.png`

## Manual acceptance boundary

The user should evaluate spatial rhythm, room-to-room visual distinction, platform feel and whether the S2 modular language is sufficiently rich at gameplay scale. Enemy density/fairness and Boss arena combat cannot be accepted in S3 because formal Encounter population is deliberately not present yet.
