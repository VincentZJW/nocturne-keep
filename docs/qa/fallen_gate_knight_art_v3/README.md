# Fallen Gate Knight Art V3 QA

Date: 2026-07-28
Route: `MainBootstrap -> Chapter I -> boss_checkpoint -> saved FallenGateKnight instance`

## Evidence index

| File | Evidence |
|---|---|
| `01_phase_1_main.png` | intact Phase 1 silhouette in actual Main bridge room |
| `02_shield_66_main.png` | damaged shield: cracks/notch persist on the live overlay |
| `03_shield_33_main.png` | critical shield: split crest, larger cracks and soul leak |
| `04_shield_break_main.png` | shield-break action and fragments |
| `05_phase_transition_main.png` | irreversible transition frame |
| `06_phase_2_main.png` | shieldless, two-handed, exposed-curse Phase 2 |
| `07_greatsword_attack_main.png` | full greatsword active pose in Main |
| `08_death_main.png` | collapsed death frame; no ghost |
| `09_old_left_new_right_main.png` | prior production capture on left, v3 Main capture on right |

## Mandatory acceptance matrix

| Item | Status | Evidence |
|---|---|---|
| Phase 1 concept | PASS | `concept_art/fallen_gate_knight_phase_01_concept.png` |
| Phase 2 concept | PASS | `concept_art/fallen_gate_knight_phase_02_concept.png` |
| Tower shield design | PASS | `concept_art/fallen_gate_knight_shield_design.png` |
| Greatsword design | PASS | `concept_art/fallen_gate_knight_greatsword_design.png` |
| Phase 1 formal Sprite | PASS | `01_phase_1_main.png` |
| Phase 2 formal Sprite | PASS | `06_phase_2_main.png` |
| Four shield damage stages | PASS | `effects/shield_stage_00.png` through `shield_stage_03.png`; `01`–`04` Main captures |
| Phase Transition | PASS | `04_shield_break_main.png`, `05_phase_transition_main.png` |
| All attacks | PASS | 41-animation/165-frame focused test plus `07_greatsword_attack_main.png` |
| Main integration | PASS | graphical MainBootstrap capture, spawn `boss_checkpoint` |
| Old resource cleanup | PASS | v2 is a non-runtime tar archive; SpriteFrames contains zero `reference/deprecated` paths |

## Runtime references

- F5 scene: `res://scenes/bootstrap/main_bootstrap.tscn`
- Chapter scene: `res://chapters/chapter_01_ravenmourn_outskirts/scenes/level/ravenmourn_outskirts.tscn`
- Boss instance: `World/CastleEntranceArea/FallenGateKnight`
- Boss scene: `res://chapters/chapter_01_ravenmourn_outskirts/scenes/boss/fallen_gate_knight.tscn`
- Sprite node: `VisualRoot/AnimatedSprite2D`
- Shield overlay: `VisualRoot/ShieldDamageOverlay`
- SpriteFrames: `res://chapters/chapter_01_ravenmourn_outskirts/resources/boss/fallen_gate_knight_sprite_frames.tres`

The capture hides the Debug HUD but leaves the real Boss HUD, Player, bridge, gate and saved Chapter I scene visible. It uses the graphical Godot 4.7.1 Metal renderer, not a fabricated image board.
