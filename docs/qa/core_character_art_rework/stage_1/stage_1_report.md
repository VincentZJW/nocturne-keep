# Core Character Art Rework — Stage 1 Report

Date: 2026-07-28

Engine: Godot Engine 4.7.1 Standard (`a13da4feb`)

Scope: Player concept, production pixel art, animation presentation and Main integration only

## Result

Stage 1 is implemented. The shared Player now uses an adult 57 px visible Night Warden body at 98.28% of the Chapter I Castle Guard reference, three complete weapon-specific 30-animation frame sets, eight matching Prologue revival poses and the shared hooded ghost. Gameplay collisions, movement, attack reach, damage, camera and stamina remain unchanged.

Candle Warden work was not started.

## Deliverables

| Area | Evidence |
| --- | --- |
| Concept masters | `res://shared/assets/player/concept_art/night_warden_turnaround_master.png`; `night_warden_action_weapon_master.png` |
| Ten concept crops | `res://shared/assets/player/concept_art/night_warden_*` |
| Veilbound runtime | `res://shared/assets/player/animations/veilbound/` |
| Ravenfang runtime | `res://shared/assets/player/animations/ravenfang/` |
| Crimson Masque runtime | `res://shared/assets/player/animations/crimson_masque/` |
| Prologue revival | `res://shared/assets/player/revival/` |
| Effects | `res://shared/assets/player/effects/` |
| Weapon references | `res://shared/assets/player/weapons/` |
| Runtime resources | the three existing Player SpriteFrames `.tres` resources |
| Contact sheet | `res://docs/qa/core_character_art_rework/stage_1/night_warden_stage_1_contact_sheet.png` |
| Main captures | nine `main_player_*.png` files in this directory |

Concept prompt direction: original medieval-gothic adult hooded assassin; black pointed hood and hidden face; damaged short cape; layered leather and dark-steel light armor; long mobile legs; cold blue-gray/old silver palette with restrained rust-red/amber accents; three orthographically consistent dagger families; clean turnaround, scale, silhouette and action-pose presentation; no likeness to an existing commercial character.

## Runtime integration

- Formal Player: `res://scenes/player/player.tscn`.
- Visual authority: `Player/VisualRoot/AnimatedSprite2D`.
- Animation authority: `Player/AnimationController`.
- Equipment authority: `Player/VisualRoot/WeaponVisual`; active full-frame swaps now point to the shared Stage 1 roots.
- Prologue story art: `VeilboundCatacomb/World/Player/RevivalPlayerArt` now draws the eight formal unarmed textures.
- Main/F5 authority remains `res://scenes/bootstrap/main_bootstrap.tscn`; formal new game still routes to `res://scenes/cinematics/opening_cinematic.tscn`.

## Verification

All commands used `/Users/vincentz/Downloads/Godot.app/Contents/MacOS/Godot`.

| Check | Result |
| --- | --- |
| Stage 1 generator | PASS: three styles, 30 animations, 10 concepts, 8 revival poses |
| Headless editor import | PASS; no parser/missing-resource/invalid-UID error |
| Three SpriteFrames builders | PASS; 30 animations each |
| `test_player_stage_1_art.gd` | PASS: concepts=10, revival=8, resources=3, collisions preserved |
| `test_player_animation_system.gd` | PASS; shared y=60 baseline and segmented Dash contracts |
| `test_m1_player_movement.gd` | PASS |
| `test_m15_player_actions.gd` | PASS |
| `test_fast_attack.gd` | PASS |
| Prologue flow | PASS: formal F5 route, 30 bilingual lines, skip, daggers, door, Main spawn |
| Ravenfang Boss pressure | PASS: damage/cadence/resource path regression |
| Crimson Masque weapon | PASS: data, frames, damage and dedup |
| Player scene smoke | PASS |
| Animation preview smoke | PASS |
| Formal Main/F5 smoke | PASS: Bootstrap selected Opening; exit 0 |
| Main graphical capture | PASS: nine images through Bootstrap-routed Chapter I |
| Chapter I formal composition | PASS: 34 enemies, checkpoints and Boss epilogue unchanged |
| Chapter II formal composition | PASS: nine rooms, 38 enemies, one Player and one HUD |
| Chapter III acceptance composition | PASS: six roles and one shared Main Player route |

## Preserved contracts

- Body collision 24×52; Hurtbox 22×50.
- Normal/Dash Attack shapes 42×14 and 58×16.
- No Player stat, movement, dash, attack timing, damage, Health, stamina or camera adjustment.
- No enemy, Boss, chapter environment, dialogue or progression change.

## Known limits

- The expanded animation preview creates the additional buttons dynamically; Stage 2 should visually review its denser layout.
- `ready_idle`, `walk`, `turn`, `start_move`, `stop_move`, `jump_rise`, `jump_apex`, `hurt_light` and `hurt_heavy` are available production presentation contracts but are not all selected by current gameplay state logic.
- Historical frame trees remain present but unreferenced. Their physical deletion is deferred until Stage 2 proves all formal routes and weapon swaps visually.
- Automated tests prove contracts and resource integrity. Native-scale readability, animation weight and weapon-hand alignment still require the user's Stage 2 visual acceptance.
- `test_main_bootstrap_flow.gd` and `test_silent_court_graybox.gd` retain the two ObjectDB shutdown warnings already recorded by Stage 0; both pass and the formal windowed F5 run has no red Output/Debugger diagnostic.

## Next gate

Stage 2: Player strong visual QA across Prologue, Chapter I, Chapter II and representative Chapter III scenes. Do not begin Candle Warden Stage 3 until Stage 2 is explicitly approved and completed.
