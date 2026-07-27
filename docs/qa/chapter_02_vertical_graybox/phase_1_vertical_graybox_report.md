# Chapter II Phase 1 Vertical Graybox QA

Date: 2026-07-27

Engine: Godot 4.7.1 Standard (`a13da4feb`), GL Compatibility, Apple M4 OpenGL/Metal

Configured F5 scene: `res://scenes/bootstrap/main_bootstrap.tscn`

Chapter II target: `res://chapters/chapter_02_silent_court/scenes/level/silent_court.tscn`

## Main / Bootstrap evidence

The graphical QA harness enables the saved Chapter II Debug profile, loads the configured `MainBootstrap` scene, waits for the production `SilentCourtLevel`, then captures six representative positions from that composed scene. It does not instance separate room copies.

```text
/Users/vincentz/Downloads/Godot.app/Contents/MacOS/Godot --path . --script chapters/chapter_02_silent_court/scripts/tools/capture_chapter_02_vertical_qa.gd
CH2_VERTICAL_MAIN_QA: PASS captures=6
```

Formal graphical F5-equivalent smoke retained the default route:

```text
/Users/vincentz/Downloads/Godot.app/Contents/MacOS/Godot --path . --quit-after 240
MAIN BOOTSTRAP | FORMAL NEW GAME | res://scenes/cinematics/opening_cinematic.tscn
```

## Physical full-route traversal

The production Player crossed the actual composed Chapter II room scenes using `CharacterBody2D` physics and existing Input Map actions. The driver does not set Player coordinates. It crossed all eight room seams, triggered Ground Dash, double jump and Air Dash, and captured all nine rooms.

```text
/Users/vincentz/Downloads/Godot.app/Contents/MacOS/Godot --path . chapters/chapter_02_silent_court/scenes/level/silent_court.tscn -- --recapture-ch2-graybox-fast
CH2_GRAYBOX_F5_TRAVERSAL: PASS duration=146.02s screenshots=9
```

Two early traversal attempts correctly found blocking vertical faces in Grey Banner and Last Banquet Hall. Both were rebuilt as continuous ascending/descending stair profiles; only the third and final successful run produced the retained nine-room evidence.

## Screenshot evidence

| View | SHA-256 |
| --- | --- |
| `01_grey_banner_upper_corridor.png` | `a140ca0c6d19238c12a88ecb8c1f0c2cd898b0b3ab979b16bb489334bb2146c1` |
| `02_banquet_double_level.png` | `bfb09a139b08839d96e2754f0b1abe2466709bb50ee02f10235a2919bb18c91f` |
| `03_chapel_three_tiers.png` | `0e3a76e207dbc8eb14b5359eb3b0cfa19049d379756bd6a734dd88727073d7a8` |
| `04_servant_passage_levels.png` | `67e9c188a2c2fe4904c009e655a301f058a4f05f8a4de99f839473d3b51c772d` |
| `05_antechamber_boss_buffer.png` | `6911380939acfa31bc8a10ba5a69612ec5797ae47b01b2f0567ae11f5f7128d0` |
| `06_ballroom_flat_lane.png` | `1be64d566ed0c13ded747c01eda048cfca045fb99c110d64a7f074619e4f1a86` |

The companion `res://docs/qa/chapter_02_graybox/room_01_...` through `room_09_...` images are the final sequential physics traversal captures.

## Automated verification

- Room builder: PASS, nine deterministic PackedScenes regenerated.
- Chapter II contract: PASS, nine rooms, six safe Debug spawns, fifteen future encounter anchors, one Player and one HUD; zero enemies.
- Geometry contract: PASS, visible platform/stair arrays match collision node counts; all tier deltas are at most 120 px; Ballroom has no upper geometry.
- Full deterministic suite: `47` tests, `0` failures.
- Exact-engine import/parse and formal graphical F5 smoke: exit 0 with no parser, missing-resource, invalid-UID or red runtime error.

## Manual acceptance still required

- Player feel on each optional Gallery jump and preferred double-jump/Air-Dash route.
- Final art readability, stair-tile silhouette and later enemy combat footing.
- Doors, checkpoints, encounters, enemies and Hollow Duchess remain intentionally inert/absent in Phase 1.
