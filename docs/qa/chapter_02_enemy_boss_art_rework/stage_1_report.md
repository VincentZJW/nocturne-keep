# Chapter II Enemy Art Rework — Stage 1A–1E QA

Date: 2026-07-29

F5 authority: `res://scenes/bootstrap/main_bootstrap.tscn`

Formal Chapter II level: `res://chapters/chapter_02_silent_court/scenes/level/silent_court.tscn`

## Result

**PASS for Stage 1 implementation and technical integration.** All five Chapter II-specific ordinary enemies now use original role-specific concepts, deterministic 64×64 formal pixel frames and expanded authoritative SpriteFrames. Main screenshots prove the saved Chapter II encounters resolve the replacement resources. Material appeal, animation weight and native-scale preference remain user-facing visual acceptance items.

| Stage | Role | Concept | Formal animations | Formal frames | Main identity/action evidence | Result |
|---|---|---:|---:|---:|---|---|
| 1A | Hollow Retainer | yes | 20 | 83 | `main_hollow_retainer_identity.png`, `main_hollow_retainer_action.png` | PASS |
| 1B | Court Halberdier | yes | 21 | 91 | `main_court_halberdier_identity.png`, `main_court_halberdier_action.png` | PASS |
| 1C | Mourning Armor | yes | 21 | 98 | `main_mourning_armor_identity.png`, `main_mourning_armor_action.png` | PASS |
| 1D | Blood-Candle Acolyte | yes | 20 | 86 | `main_blood_candle_acolyte_identity.png`, `main_blood_candle_acolyte_action.png` | PASS |
| 1E | Hanging Stalker | yes | 23 | 95 | `main_hanging_stalker_identity.png`, `main_hanging_stalker_action.png` | PASS |

## Role-specific acceptance

- **Hollow Retainer:** porcelain half-mask, high servant collar, split coat tails, pale gloves, mourning chain and complete guarded smallsword remain readable through idle, patrol, stab and combo poses.
- **Court Halberdier:** crested closed helm, crimson mantle, separated armor plates and a complete ceremonial halberd head (point, axe and rear hook) replace the former pole-line silhouette.
- **Mourning Armor:** broad articulated pauldrons, hollow crown helm, funeral veil, visible internal void/mist and weaponless armored-body attacks establish an empty funerary shell rather than a sword knight.
- **Blood-Candle Acolyte:** wax-sealed face, layered black/crimson vestments, visible hands, gold candlestick and wax/ember ritual language remain distinct from a generic mage.
- **Hanging Stalker:** rope/hook harness, folded suspension legs, pale human hunting mask, long jointed arms and two-prong claws preserve both inverted and landed anatomy without reusing gargoyle/bat language.

## Resource and compatibility checks

- Every role owns `concept_art/<role>_formal_concept.png`, `animations/<role>_stage1_preview.png`, `sprites/<animation>/*.png` and `animations/<role>_sprite_frames.tres`.
- Stage 0 runtime art was archived before replacement in each role's `reference/deprecated_stage0/<role>_stage0_runtime_art.tar.gz`.
- Existing gameplay names remain present, so no AI/timing rewrite was required. Expanded split windup/active/recovery and presentation names are available for future presentation routing.
- Formal enemy scenes still bind `VisualRoot/AnimatedSprite2D` to the same authoritative Chapter-local SpriteFrames path. The saved Chapter II level directly references those five PackedScenes and has no per-instance art override.

## Exact verification

1. Exact Godot 4.7.1 generator: PASS, five roles / 453 frames.
2. Editor import/parse: PASS, all new PNGs imported without parser, resource or UID errors.
3. SpriteFrames builder: PASS, five roles / 453 frames.
4. `test_chapter_02_enemy_art_stage_1.gd`: PASS, concepts, archives, 64×64 non-empty frames, animation counts, formal scene bindings and Main references.
5. Existing `test_phase_2_enemy_prototypes.gd`: PASS, five gameplay contracts.
6. Existing `test_phase_2_enemy_damage.gd`: PASS, damage and attack-ID dedup unchanged.
7. Independent `phase_2_enemy_prototype_room.tscn` headless smoke: exit 0.
8. Formal `silent_court.tscn` headless smoke: exit 0; retained pre-existing non-fatal `2 ObjectDB instances were leaked at exit` shutdown warning.
9. Graphical MainBootstrap capture: PASS, ten captures from the formal Chapter II world.

## Evidence directory

All Main captures are under `docs/qa/chapter_02_enemy_boss_art_rework/stage_1/`. Each role has one identity frame and one signature-action frame. The deterministic enlarged action previews are stored beside each role's SpriteFrames.

## Scope

No Player art, ordinary-enemy gameplay values, collision, hitbox timing, AI, encounter placement, Chapter I enemy/Boss resource or Hollow Duchess resource was modified. Stage 2 remains the dedicated Duchess rework and must follow the user's separate Duchess specification.
