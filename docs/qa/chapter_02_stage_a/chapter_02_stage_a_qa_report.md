# Chapter II Stage A — MainBootstrap QA evidence

Date: 2026-07-28

Engine: Godot 4.7.1 Standard, GL Compatibility, Apple M4

F5 bootstrap: `res://scenes/bootstrap/main_bootstrap.tscn`

Chapter Main: `res://chapters/chapter_02_silent_court/scenes/level/silent_court.tscn`

## Graphical route

Command:

`/Users/vincentz/Downloads/Godot.app/Contents/MacOS/Godot --path . --script res://chapters/chapter_02_silent_court/scripts/tests/capture_chapter_02_stage_a_qa.gd`

Result: `CH2_STAGE_A_MAIN_QA: PASS captures=10 layers=1 transitions=2 proximity=112 candle_frames=2 collected=1`. The script enters the exact MainBootstrap Chapter II route, performs both saved floor transitions, uses the saved Boss entrance/reliquary nodes, and activates the reliquary through its `interact` action handler.

| Evidence | Purpose | SHA-256 |
| --- | --- | --- |
| `01_floor_1_main.png` | F5 Floor 1 baseline | `18d96b2b6b6ca91fc54db027608685bc3392e00882f049c9fef03ef7861eac06` |
| `02_floor_1_to_2_landing_main.png` | Floor 1→2 landing/test point 1 | `91dc4f68b7cc9a83ecec1484df20a69ffa26dc2647d953ee6f46c38c37f9f06a` |
| `03_floor_2_to_3_landing_main.png` | Floor 2→3 landing/test point 2 | `c7dd5c63a2bbdb7e6c594f6e0e4d0d0c24be826ed71657dd8f3ee3e6055ae9f3` |
| `04_boss_entrance_fixed_main.png` | Repaired Boss entrance | `6713ebdd4fc50d7ad9eee656746b98ccd6e254bbf73acb7b4ad099617acfe053` |
| `05_player_in_front_of_boss_door_main.png` | Player fully in front of door body | `eb19308bdbf9ca5333666f23901f0c19709ab012de1c116eebdebd92307cba5f` |
| `06_player_in_front_of_reliquary_main.png` | Player fully in front of compact reliquary | `e269caa513457249c4784fcf141391e6ff6faae76794574d48d63f04a14f237b` |
| `07_reliquary_prompt_close_main.png` | Exact proximity prompt and readable crossed weapons | `b887e1c42d5d8dcb385397f98f07250c4ec18c396d1d6f03173b1bcbc7217c6f` |
| `08_candle_flame_frame_a_main.png` | Dynamic candle frame A | `b887e1c42d5d8dcb385397f98f07250c4ec18c396d1d6f03173b1bcbc7217c6f` |
| `09_candle_flame_frame_b_main.png` | Dynamic candle frame B (29,517 encoded-byte differences from A) | `01405fa8c571e4ce3e4ab01fe8705ec4a19af243f63494b7f3f4c717c19f944e` |
| `10_reliquary_collected_main.png` | Empty pedestal after E collection | `49c15154e5906517ff11d72d284cacbd124400dadc4a161215edd5a05e939e86` |

Every PNG is 1280×720. No independent concept-art file exists; the pedestal, weapons and flame frames are editable native Godot pixel-style draw assets.

## Frame-time probe

Command:

`/Users/vincentz/Downloads/Godot.app/Contents/MacOS/Godot --path . --script res://chapters/chapter_02_silent_court/scripts/tests/benchmark_chapter_02_stage_a.gd`

The probe samples real rendered Main frames across both floors, Boss presentation, Phase change, death/reward, mirror, passage and Chapter III entry. Before Stage A the repeatable scene-retirement spike was 39.014 ms for Chapter II→Passage and 22.318 ms for Passage→Chapter III. With threaded preload plus incremental leaf-first retirement, the same boundaries measured 13.082 ms and 10.952 ms; neither produced a >25 ms frame. Prepared Passage instantiation measured 0.339 ms. Phase transition max was 12.767 ms, Boss death→reliquary 12.023 ms and mirror 7.876 ms.

The harness itself quits the graphical SceneTree programmatically and Godot 4.7.1 reports generated GL texture/RID teardown diagnostics after the PASS line. Those messages occur after test completion, are not emitted during F5 gameplay, and are tracked separately from runtime script/resource errors.
