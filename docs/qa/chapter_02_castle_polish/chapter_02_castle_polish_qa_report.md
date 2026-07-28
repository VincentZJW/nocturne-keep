# Chapter II castle polish — MainBootstrap QA

Date: 2026-07-28

Engine: Godot 4.7.1 Standard (`a13da4feb`)

Renderer/device: GL Compatibility, Apple M4

Saved Main: `res://scenes/bootstrap/main_bootstrap.tscn` -> `res://chapters/chapter_02_silent_court/scenes/level/silent_court.tscn`

## Captured contract

The capture script enters the saved MainBootstrap through the official Chapter Debug Start service, keeps the single runtime Player/HUD/Camera, and records all six rebuilt rooms. It then requests both saved floor transitions and the formal Duchess threshold controller. The Boss evidence records the exterior door, partial fade, full blackout, relocated interior staging, first spoken line, bilingual title and combat HUD.

Result: `CHAPTER_02_CASTLE_MAIN_QA: PASS captures=19 rooms=6 threshold=fade/relocate/dialogue/title/combat reliquary=1 transitions=2`.

## Evidence hashes

All images are 1280×720 PNG.

| File | Bytes | SHA-256 |
| --- | ---: | --- |
| `01_old_armory_stilettos_main.png` | 37338 | `948a058cb2efd027f9a5318a1e74c6134e7fa4ce2f7f1336ab3c612ca17ea88d` |
| `02_old_armory_armaments_main.png` | 36306 | `c5c0d3ce3c65de6ce7415042cf8464ae080644eb7c8414ddf505df9c7a049eb4` |
| `03_last_banquet_hall_main.png` | 26357 | `e7681d8a810bdbfd1ef387a74e01743e39bcdd6d058f1011594a946194afd7c5` |
| `04_last_banquet_remnants_main.png` | 30089 | `823715741a9ee7ecb731ab41c8a3627cb41e4a3e448ea278794a7026c0d8adcd` |
| `05_royal_portrait_gallery_main.png` | 33601 | `a8ae305fa739c3d6cde5d922c4f40f97af42f60088ed8082aff4175df584d2b1` |
| `06_royal_portrait_people_main.png` | 25749 | `760ac82cd0d435079ffd559358734b7766cb884d4230038231a944583d687050` |
| `07_blood_candle_chapel_main.png` | 28738 | `fc2b84e4a90db20e5082cbbef617e73dddf14b8a1e392b4208551d1199ba6472` |
| `08_blood_candle_arches_main.png` | 28802 | `d4a3350afa7602f5856e50c80a14e89e14a4ed4d024738d7592f7144c1497dd5` |
| `09_ballroom_antechamber_main.png` | 27363 | `3798ad325b3305603fb94edc202b2df3738325872796f54c95a53e4a60f81236` |
| `10_floor_1_to_2_transition_main.png` | 25752 | `096a1c4da6ca7a5d80cc0584da04c25452d1e8479ee1a6c2b73c99a27274d1a1` |
| `11_floor_2_to_3_transition_main.png` | 34201 | `04764639ce3e1d4acade0a76ee7865bda2272ca009962c011923e8b1ed1465fe` |
| `12_boss_threshold_door_main.png` | 42916 | `a92e4ff541e4e8870dfb869c2c268e2882c459d94b7e3f2d151d2e111a1a3d7f` |
| `13_boss_fade_out_main.png` | 39281 | `f66d81e2fe1854b1a3fea9bb9ff4a86d865043b4cd717e23563a1eb3d4b853fe` |
| `14_boss_blackout_main.png` | 5320 | `84467b364c46c8b3661913ebac73f4a406de6dd715ef0286466f87e374b5180c` |
| `15_boss_room_arrival_main.png` | 24847 | `fa3e4d2f468b35f4e747fd50e73082d6530e2012664bb31a93248b849f08cc72` |
| `16_boss_cold_open_dialogue_main.png` | 34397 | `ba65a34b4992d6cb3ef385cb099d4638865feb800da3aacf4f6acb3610a698f9` |
| `17_boss_title_main.png` | 47711 | `4896e21183bedd5d5a82e21bd3902fca56c2e4e60d43f8afa57a1a72f9a35ccb` |
| `18_boss_combat_start_main.png` | 34680 | `86aad6cd4fd120001e5a2e0e34fb0b1a812813997c164319cee40dea396bc061` |
| `19_crimson_masque_reliquary_main.png` | 64828 | `89dcd8706451e3621e36aba56a2e51ded6e6833ef89a423575340456109770d0` |

## Visual review

- The Armory stilettos have separate handles, guards, tapered blades and tips; racks and armour establish the room without obscuring combat silhouettes.
- Gallery frames contain actual distinct people, not empty panels. Chapel arches are masonry sprites with doors and altar composition, not debug arcs.
- Boss exterior and interior are spatially distinct. Relocation occurs at full black; the Player returns clear of foreground pillars and both combatants fit the first-entry frame.
- Dialogue, title and combat are sequential. The combat capture shows the title dismissed and the signal-driven Boss Health/Poise HUD active. The nineteenth capture follows the actual Boss-death signal and shows the formal pedestal asset revealed in the saved reliquary.

## Diagnostic note

No script, parser, missing-resource or runtime assertion error occurred before PASS. Calling `SceneTree.quit()` from the graphical evidence harness makes Godot 4.7.1 report GL texture/RID and ObjectDB teardown diagnostics after PASS. The same known harness-only shutdown messages also occur in the pre-existing Stage A capture/benchmark; they are not produced during normal interactive F5 play and are documented rather than hidden.
