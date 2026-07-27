# Chapter II three-floor Main QA report

Date: 2026-07-27
Engine: Godot 4.7.1 Standard (`a13da4feb`), GL Compatibility, Apple M4

## Runtime authority

- `run/main_scene`: `res://scenes/bootstrap/main_bootstrap.tscn`
- Chapter scene: `res://chapters/chapter_02_silent_court/scenes/level/silent_court.tscn`
- Main player: `/root/SilentCourt/GameplayWorld/PlayerAnchorOrRuntimeActors/ChapterRuntime/Player`, absolute z=12
- Enemy parent: `/root/SilentCourt/GameplayWorld/Enemies`, absolute z=10
- Room parent: `/root/SilentCourt/GameplayWorld/Geometry/Rooms`, Y-sort disabled
- Visible collision audit ground: `GameplayWorld/Geometry/Rooms/LastBanquetHall/Geometry/MainFloor/CollisionShape2D`
- Visible collision audit enemy: `/root/SilentCourt/GameplayWorld/Enemies/EncounterE05/EncounterE05_01_HollowRetainer`
- Authored foot `(4740,612)` settled to actor origin near `(4740,583.49)`, matching the shared 28 px foot offset.

## Main rendered evidence

All images are real 1280x720 renders loaded through `MainBootstrap` with the Chapter II debug profile. No editor-only preview scene was used.

| # | Evidence | SHA-256 |
| ---: | --- | --- |
| 01 | `01_floor_1_castle_gate_interior.png` | `2b0baf7389207942766ec4331ba59266da096aad4abd39023cfc3999dc0b49b3` |
| 02 | `02_floor_1_grey_banner_corridor.png` | `ec445e346dd8a8b93ae2553739931a60f0f4b45833a428d13cbed0cd9d57c33a` |
| 03 | `03_floor_1_last_banquet_layering.png` | `ef66207f8b520f0d391e39c583e80fa73cc262d9a9d4f1f91388ecf9e474af77` |
| 04 | `04_grand_service_stair.png` | `c3a9cade58c3e971b8c5a33599355c295af4f2c40b702b552506b5596c629400` |
| 05 | `05_floor_2_royal_portrait_gallery.png` | `4ed77603b5feed297dd296ca67462a308561ead6f3568b8b7ef0ff19e5d92fe0` |
| 06 | `06_floor_2_blood_candle_chapel.png` | `c25c4d6921299ed3a1bec4890d7acb022bd1b4aac29ff26f727ee951d6a56e68` |
| 07 | `07_floor_2_servant_upper_passage.png` | `e9cc6cbceb2a128c4fcf27969cad747b45821ad38afbad0f224f0558e8b45e7f` |
| 08 | `08_servant_side_stair.png` | `f886d4c8d733b681c43adbd4b63ca538ff42041aa1ecb163434a28d0a44d7f09` |
| 09 | `09_floor_3_landing.png` | `a516872076a402d926e9913a0a406ba2e68a424e31b5e9115ab1b13c1c031070` |
| 10 | `10_floor_3_upper_court_gallery.png` | `ce300e4c152d4654ac5a10c8252f4b09fae7bd236efea913832cf37f597a3abc` |
| 11 | `11_silent_ballroom_antechamber.png` | `1cb944fee75168d018ae2b857ac642799809f5d03f193e41ff54d202b2bfb3d7` |
| 12 | `12_silent_ballroom_boss_room.png` | `8f0acc7c1a86f27eff3182f6783677940f2dfda182020289646d4355756f5749` |
| 13 | `13_visible_collision_layer_audit.png` | `99a1854df92582c022d0a69e8cf13ba3bf1eea6bb876f278751484bf8942ade0` |

## Results

- Main capture: `CH2_THREE_FLOOR_MAIN_QA: PASS captures=12 encounters=15 enemies=38`.
- Visible collision capture: `CH2_COLLISION_AUDIT: PASS`.
- Three complete physics/Input Map route runs: each reached the third-floor Boss lane in 90.90 simulated seconds, with zero route softlocks.
- All 47 deterministic project tests passed after the rebuild.
- Output contained no parser, resource, Script Error or red debugger diagnostic.

## Manual acceptance still required

The three automated route passes intentionally disable combat so they prove traversal and collision continuity, not 25–35 minute first-play pacing or encounter fairness. Human F5 play should verify combat pacing, stair feel, room readability and all live enemy encounters.
