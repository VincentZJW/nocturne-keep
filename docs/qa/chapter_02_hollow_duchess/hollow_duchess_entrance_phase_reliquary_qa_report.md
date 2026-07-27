# Hollow Duchess entrance, Unmasked phase and reliquary QA

All ten frames were captured at 1280×720 from the actual F5 route `MainBootstrap → SilentCourt`, with Debug chapter `CHAPTER_02_SILENT_COURT` and spawn `CH2_BOSS`. The capture command was:

`/Users/vincentz/Downloads/Godot.app/Contents/MacOS/Godot --path . --script res://chapters/chapter_02_silent_court/scripts/tests/capture_hollow_duchess_qa.gd`

Result: `HOLLOW_DUCHESS_MAIN_QA: PASS captures=10 entrance=1 intro=1 phase2=1 reliquary=1 main=res://chapters/chapter_02_silent_court/scenes/level/silent_court.tscn`. GL Compatibility used Apple M4; runtime output contained no `SCRIPT ERROR`, missing resource or red Godot error.

| Evidence | Purpose | SHA-256 |
| --- | --- | --- |
| `01_boss_entrance_wide_main.png` | CP05 safe approach and entrance silhouette | `8b58021495475efae096d03e298aa406fee2fe855fce3311601aa1b5d209ef32` |
| `02_boss_door_main.png` | monumental split door, porcelain crest, statues, candles, inscription | `358320bc7bcfb5a538504e1deee16e0154ca7932ffd9bb711d193f1a9ab69406` |
| `03_intro_dialogue_main.png` | locked first-view framing and first formal dialogue line | `12f14df4d24ea5f2784e2a42679d73d3558466aae496c116c0b4317a1297f343` |
| `04_phase_1_main.png` | porcelain-mask Phase 1 and one-bar HUD | `5595db7caf22d831e8050bc7af138de54ef4322f044f8a1ddb01d1cc75ec6c96` |
| `05_mask_crack_main.png` | 55% transition entry and mask-crack stage | `2c78f2e104de1fb0de122c50a0b186c22c3c5d8a04e44a36f5f50c6903c6b2b0` |
| `06_phase_transformation_main.png` | dark-crimson transformation presentation and porcelain shards | `de4fc9f22c9d42f0649c809ffc199b368b1234d64f136e63f0c44cbc847a8586` |
| `07_phase_2_unmasked_main.png` | independently redrawn Unmasked silhouette and Phase 2 HUD | `97484f0f82be50723a51fd063532e805d98d6bc10e4f1db5713da1982a4add2b` |
| `08_phase_2_attack_main.png` | Unmasked double-lunge attack readability | `7fc592d4076223fe7b007915f8181a5eb784204e2cef6e6ae2ec1e896ad3040f` |
| `09_duchess_reliquary_main.png` | unlocked medieval reliquary and mounted paired stilettos | `a5872b42927924fa1f21e5e2e1fcaf8980985b46f3050b82ef787ca7db0fe342` |
| `10_crimson_masque_claimed_main.png` | collected/empty cabinet and post-reward mirror sequence | `004873f91242e3ff0195c23155e2be6ea3a31951575555e77de6f9342341c2d1` |

The folder also retains the earlier Boss QA images for historical comparison; they are not relabeled as evidence from this milestone.
