# Chapter II stair terminal and platform-enemy QA

Date: 2026-07-27
Engine: Godot 4.7.1 Standard, GL Compatibility / Apple M4
Entry: `res://scenes/bootstrap/main_bootstrap.tscn` → `res://chapters/chapter_02_silent_court/scenes/level/silent_court.tscn`

## MainBootstrap captures

| Evidence | SHA-256 |
| --- | --- |
| `01_floor_1_terminal_wall.png` | `038fc30ad933380c843cd1f754a6bfe373f8df96b0fbdc0eff9e476572ba7549` |
| `02_floor_1_transition_entrance.png` | `3f017b38a7bb620e890c274cd1c33da74cd7e946b966bf2b27ed76406ed71e79` |
| `03_floor_2_arrival.png` | `e3732e3edafbd40b4db1973338ef94621a895827ccf763da0acdb448770be794` |
| `04_floor_2_terminal_wall.png` | `144df93dde0cf2704438b2cf32f230285cbb86b05387bc202a8bee31ec1a1052` |
| `05_floor_3_arrival.png` | `aa4a0ffc4bfed1f1c24f512e5100ec20426bb0fe2837221eb7fbd6b239609ed4` |
| `06_banquet_platform_enemy.png` | `2dca5af76cf1b4b969a67a2b551182d642be1ce1899e40b1843b14fb0df390e0` |
| `07_chapel_platform_enemies.png` | `e72c9d8ae2a4c21d68277fe4796eb712463d52042c036087bb471d84a02fcd4c` |
| `08_antechamber_platform_enemies.png` | `b9035b11a610700fb0775c9d254e640c08028d2daa942744622ccccdbf274003` |

All files are real 1280×720 viewport captures taken after loading Chapter II through MainBootstrap. Visual inspection confirms: both stairs terminate at a closed architectural wall/door; destination doors sit behind safe arrival floor; Banquet, Chapel and Antechamber show saved elevated actors; Player/enemy/terrain z-order remains readable.

## Deterministic checks

- Stair stress: 10 Floor 1→2 + 10 Floor 2→3 requests, correct destination and Camera bounds each time.
- Population: 38 total = 22 Ground + 11 Platform + 5 Ceiling/Air.
- Platform settling: all 11 platform actors active for 240 physics frames, on floor and within their authored movement bounds.
- Main graphical runner: `CH2_STAIR_PLATFORM_MAIN_QA: PASS captures=8 bootstrap=1 enemies=38 platform=11`.

Human acceptance remains required for combat fairness, player approach options and aggressive knockback cases; screenshots and deterministic tests do not replace a full manual playthrough.
