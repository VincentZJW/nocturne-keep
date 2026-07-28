# Chapter I Enemy and Boss Art Rework — QA Evidence

## QA result

**PASS (automatic integration and runtime evidence); manual art-direction acceptance remains with the user.**

Scope is Chapter I only. Chapter II was not modified.

## Audited roster

| Role | Gameplay scene | Sprite node | Main location |
|---|---|---|---|
| Castle Guard | `chapters/chapter_01_ravenmourn_outskirts/scenes/enemies/castle_guard.tscn` | `VisualRoot/AnimatedSprite2D` | `World/Encounters/TutorialEncounter01/Enemies/TutorialGuard01` and later groups |
| Cursed Shield Guard | `shared/scenes/enemies/cursed_shield_guard.tscn` | `VisualRoot/AnimatedSprite2D` | `World/Encounters/TutorialEncounter05/Enemies/TutorialShieldGuard01` and later groups |
| Decayed Spearman | `chapters/chapter_01_ravenmourn_outskirts/scenes/enemies/decayed_spearman.tscn` | `VisualRoot/AnimatedSprite2D` | `World/Encounters/ForestEncounter01/Enemies/ForestSpearman01` and later groups |
| Fallen Crossbowman | `shared/scenes/enemies/fallen_crossbowman.tscn` | `VisualRoot/AnimatedSprite2D` | `World/Encounters/ForestEncounter02/Enemies/ForestCrossbowman01` and later groups |
| Gargoyle Sentinel | `shared/scenes/enemies/gargoyle_sentinel.tscn` | `VisualRoot/AnimatedSprite2D` | `World/Encounters/ForestEncounter03/Enemies/ForestGargoyle01` and later groups |
| Fallen Gate Knight | `chapters/chapter_01_ravenmourn_outskirts/scenes/boss/fallen_gate_knight.tscn` | `VisualRoot/AnimatedSprite2D` | `World/CastleEntranceArea/FallenGateKnight` |

## Concept versus formal sprite

| Role | Concept | Formal representative | Preserved identifiers | Status |
|---|---|---|---|---|
| Castle Guard | `assets/enemies/castle_guard/concept_art/castle_guard_concept.png` | `sprites/idle/idle_01.png` | closed helm, rust sword, torn tabard | PASS |
| Shield Guard | `assets/enemies/cursed_shield_guard/concept_art/cursed_shield_guard_concept.png` | `sprites/idle/idle_01.png` | broad plate, structured heater shield, break state | PASS |
| Spearman | `assets/enemies/decayed_spearman/concept_art/decayed_spearman_concept.png` | `sprites/attack_thrust/attack_thrust_04.png` | nasal helm, long haft and spearhead | PASS |
| Crossbowman | `assets/enemies/fallen_crossbowman/concept_art/fallen_crossbowman_concept.png` | `sprites/shoot/shoot_02.png` | light armor, crossbow stock, quiver | PASS |
| Gargoyle | `assets/enemies/gargoyle_sentinel/concept_art/gargoyle_sentinel_concept.png` | `sprites/hover/hover_01.png` | horned stone head, wings, claws | PASS |
| Gate Knight | `assets/boss/fallen_gate_knight/concept_art/fallen_gate_knight_phase_01_concept.png` + `fallen_gate_knight_phase_02_concept.png` | `sprites/idle_shielded/idle_shielded_01.png` | crowned tower shield, full greatsword, independent two-handed Phase 2 | PASS v3 |

Paths in the table are relative to `res://chapters/chapter_01_ravenmourn_outskirts/`.

## Animation acceptance

| Role | Runtime animations | Frames | Newly redrawn | Quality status |
|---|---|---:|---|---|
| Castle Guard | idle, walk, attack, hurt, death | 24 | yes | PASS |
| Shield Guard | shielded/unshielded idle, walk, attack, hurt, death; block; guard_break | 55 | yes | PASS |
| Spearman | idle, walk, attack_thrust, hurt, death | 25 | yes | PASS |
| Crossbowman | idle, walk, aim, shoot, reload, hurt, death | 30 | yes | PASS |
| Gargoyle | dormant, wake, hover, dive_windup, dive, ground_stun, return_to_air, hurt, death_fall, death_shatter | 41 | yes | PASS |
| Gate Knight | 20 phase-aware movement, turn, defense, attack, transition, hurt and death families | 96 | yes | PASS |

Total: **271 new formal runtime frames**. Attack phase art remains mapped to the existing gameplay timing contracts rather than adding unsupported AI states.

## Old asset replacement

| Old resource | State | New resource | Still used in Main |
|---|---|---|---|
| former Castle Guard flat animation folders | archived at `reference/deprecated_v1/sprites/` | `castle_guard/sprites/` | no |
| former shared Shield Guard sprite/effect folders | archived in Chapter I role directory | `cursed_shield_guard/sprites/` + `effects/` | no |
| former Spearman flat animation folders | archived | `decayed_spearman/sprites/` | no |
| former shared Crossbowman folders | archived | `fallen_crossbowman/sprites/` | no |
| former shared Gargoyle folders | archived | `gargoyle_sentinel/sprites/` | no |
| former Gate Knight flat animation/shield folders | archived | `fallen_gate_knight/sprites/` + `effects/` | no |

The automated resource test rejects any runtime texture containing `deprecated` and verifies an archive total of 290 historical PNGs.

## Screenshot evidence

- `01–06_*_concept_old_new.png`: concept, archived v1 and formal v2 comparison boards.
- `07–12_*_sprite_preview.png`: nearest-neighbour formal idle/action previews.
- `13_chapter_01_formal_roster_overview.png`: all six formal silhouettes.
- `14–23_*_main_*.png`: actual MainBootstrap Chapter I ordinary-enemy idle/action evidence.
- `24_fallen_gate_knight_main_phase_1.png`
- `25_fallen_gate_knight_main_shield_break.png`
- `26_fallen_gate_knight_main_phase_2.png`
- `27_fallen_gate_knight_main_heavy_active.png`
- `28_fallen_gate_knight_main_death.png`

## Main / F5 test route

`project.godot` uses `res://scenes/bootstrap/main_bootstrap.tscn`. For direct inspection in a debug build, enable Chapter I debug start with spawn `dark_forest_tutorial_spawn`, or play the normal opening route. Move right through the tutorial and forest to see Guard → Shield Guard → Spearman/Crossbowman → Gargoyle; continue to the castle bridge for the Fallen Gate Knight's shielded and unshielded phases.

## Automated results

- Art integrity: PASS — 6 roles, 271 formal frames, 290 archived frames, 6 saved Main references.
- Existing asset validators: PASS — 24 Castle Guard frames; 124 variety frames; 206 Gargoyle/Boss action frames + 4 shield overlays. The Gate Knight v3 resource contains 41 animations / 165 frames.
- Gameplay regression: PASS — enemy variety, 18-group/34-enemy Main integration, Boss shield/phase/room reset.

The focused Gate Knight v3 concepts, shield stages and nine current MainBootstrap captures are indexed at `docs/qa/fallen_gate_knight_art_v3/README.md`.
- Main capture: PASS — actual `MainBootstrap` route, 6 roles, 15 runtime captures.
- Godot 4.7.1 import/parse: PASS; no red parser/resource errors.

## Manual acceptance focus

Confirm at native gameplay scale that the limited palettes and compact 64×64 material clusters meet the desired polish, especially the Guard's sword action and Gargoyle's stone fragment death. These are not functional failures; they are the most subjective art-direction checkpoints.
