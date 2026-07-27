# Chapter II Phase 2 enemy QA

Engine: Godot 4.7.1 Standard, GL Compatibility, Apple M4

Route: `MainBootstrap` → legal Debug Chapter Start → `res://chapters/chapter_02_silent_court/scenes/level/silent_court.tscn`

Result: `CH2_PHASE2_MAIN_QA: PASS captures=5`. All captures are 1280×720 and come from the production Chapter II Main composition, not the independent prototype room.

| Capture | SHA-256 | Observation |
| --- | --- | --- |
| `main_hollow_retainer.png` | `08c589f2a371018904928b909c75f8e737adc26446e32b6940907f64e089ebed` | Grey Banner acceptance instance, thin close-melee silhouette |
| `main_court_halberdier.png` | `6fc373877c36abc4cb17b008c8d0819e8e6b86d6c5d1a985a062166285334005` | long weapon silhouette and grounded mid-range spacing |
| `main_mourning_armor.png` | `35009c57d659f5731fb33c21c061a9af80f934683c5b630c71b4d037f43db746` | broad heavy silhouette; live Player HP shows actual combat contact |
| `main_hanging_stalker.png` | `d9556430f2fc66db5a9d7e945d02537d3d731eaa0776a3b8a0bbfb27f18381d0` | ceiling-hung curse-beast silhouette over Gallery lane |
| `main_blood_candle_acolyte.png` | `15d661d38045e1e38ba1c9ce8edfaf53d13d6647a3e7bc91366d6499d8ab5ed4` | Chapel ranged-support silhouette with visible blood candle |

Automated evidence:

- `CH2_PHASE2_ENEMY_PROTOTYPES_TEST: PASS enemies=5 assets=original combat=validated`
- `CH2_PHASE2_ENEMY_DAMAGE_TEST: PASS damages=7/5,10/6,14/9,8/4,9/6 dedup=ok`
- `SILENT_COURT_GRAYBOX_TEST: PASS rooms=9 spawns=6 encounters=15 prototypes=5 player=1 hud=1`
- `FULL_SUITE tests=49 failed=0`
