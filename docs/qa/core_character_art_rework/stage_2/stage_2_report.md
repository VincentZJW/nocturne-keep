# Night Warden Stage 2 Strong Visual QA Report

Date: 2026-07-28

Result: **PASS — Player visual acceptance complete; Candle Warden Stage 3 not started**

## Acceptance matrix

| Required item | Status | Evidence |
| --- | --- | --- |
| Front concept | PASS | `res://shared/assets/player/concept_art/night_warden_front_concept.png` |
| Combat-side concept | PASS | `res://shared/assets/player/concept_art/night_warden_combat_side_concept.png` |
| Back concept | PASS | `res://shared/assets/player/concept_art/night_warden_back_concept.png` |
| Black silhouette | PASS | `res://shared/assets/player/concept_art/night_warden_silhouette.png` |
| Castle Guard scale comparison | PASS | `res://shared/assets/player/concept_art/night_warden_guard_scale_comparison.png`; native Main capture `01_idle_vs_guard_native_scale.png` |
| Formal idle | PASS | `01_idle_vs_guard_native_scale.png`; visible Player/Guard height is 57/58 px and Player visual scale is `(1, 1)` |
| Run | PASS | `02_run.png` |
| Turn | PASS | `03_turn.png` |
| Jump | PASS | `04_jump_start.png`, `05_jump_apex.png` |
| Double jump | PASS | `06_double_jump.png` |
| Air Dash | PASS | `07_air_dash.png` |
| Ground Dash | PASS | `08_ground_dash.png` |
| Normal Attack 1 | PASS | `09_attack_1.png` |
| Normal Attack 2 | PASS | `010_attack_2.png` |
| Normal Attack 3 | PASS | `011_attack_3.png` |
| Dash Attack | PASS | `12_dash_attack.png` |
| Hurt | PASS | `13_hurt_light.png`, `14_hurt_heavy.png` |
| Death | PASS | `15_death_ground_and_daggers.png`; the actual death controller was triggered through lethal Health damage |
| Released ground daggers | PASS | `15_death_ground_and_daggers.png` |
| Hooded ghost rise | PASS | `16_ghost_release.png`; captured during the actual ghost pause phase |
| Veilbound adaptation | PASS | `weapon_veilbound.png` |
| Ravenfang adaptation | PASS | `weapon_ravenfang.png` |
| Crimson Masque adaptation | PASS | `weapon_crimson_masque.png` |
| Main / shared chapter integration | PASS | `20_chapter_02_shared_player.png`, `21_chapter_03_shared_player.png`, `22_prologue_revival_shared_identity.png`; Chapter I evidence is the 19-image Main sequence |
| Active old-resource cleanup | PASS | Deterministic audit reports `legacy_refs=0`; historical sources remain repository reference material but are absent from all three active SpriteFrames resources |

All relative screenshot names above resolve under `res://docs/qa/core_character_art_rework/stage_2/`.

## Visual review

- The runtime Player is not a scaled-up legacy sprite. It is authored at 64×64, occupies 57 visible pixels, uses unit node scale and sits on the shared y=60 foot baseline.
- The pointed hood, face slit, short cape, layered torso, separate legs and two complete dagger silhouettes remain readable against the dark Chapter I–III backgrounds.
- Run, turn, jump, double jump, air dash and ground dash have different body lines. Ground Dash reads as a low supported drive; Air Dash removes the planted-leg silhouette.
- The three normal attacks are distinct authored poses rather than one old attack replay: low preparation, raised/cross-body transition and forward dual-dagger extension. Dash Attack adds the longer arrow-like body line.
- Light and heavy hurt differ in lean and arm displacement. Death ends in a horizontal body, releases both daggers and then uses the shared hooded-face soul identity.
- Veilbound, Ravenfang and Crimson Masque preserve one body identity while changing blade curvature, accent and guard treatment.

## Failure found and corrected during QA

The first deterministic Stage 2 run failed because `night_warden_dual_dagger_pose_sheet.png` and `night_warden_animation_pose_sheet.png` were duplicate crops of the same master area. The generator now crops the weapon-design panel for the dual-dagger sheet and the action panel for the animation sheet. Assets were regenerated and the complete test passed afterward.

## Exact verification

Exact executable: `/Users/vincentz/Downloads/Godot.app/Contents/MacOS/Godot` (`4.7.1.stable.official.a13da4feb`).

- Stage 1 integrity: `PLAYER_STAGE_1_ART_TEST: PASS concepts=10 revival=8 resources=3 animations=30 collisions=preserved`.
- Stage 2 integrity: `PLAYER_STAGE_2_QA: PASS concepts=10 styles=3 animations=30 ratio=57/58 chapters=4 legacy_refs=0`.
- Animation controller: `PASS (16 animations, segmented Ground/Air Dash verified)`.
- Fast attack: `PASS (immediate response, single buffer, three-hit cap, 0.34s forced recovery, 0.25s Dash Attack)`.
- Death presentation: `PASS (flat body, released daggers, ghost rise/pause, cleanup)`.
- Prologue flow: `PASS (F5 route, 30 bilingual lines, skip, daggers, door, Main spawn)`.
- Chapter I composition: `PASS (18 groups, 34 mixed enemies, Boss room, HUD/respawn)`.
- Chapter II composition: `PASS rooms=9 floors=3 spawns=14 encounters=15 enemies=38 player=1 hud=1`; it retains the pre-existing two-ObjectDB shutdown warning.
- Chapter III composition: `PASS roles=6 remaining_frames=345 main=6 combination_room=1`.
- Shared Player scene, animation preview and configured F5 Bootstrap smoke all exited 0 with no red diagnostic. Formal F5 remained Opening-first at `res://scenes/bootstrap/main_bootstrap.tscn`.
- Graphical capture: 19 Chapter I/Main images plus Chapter II, Chapter III and Prologue evidence. The split per-process capture eliminated the temporary renderer-resource diagnostics from the first combined capture attempt.

## Non-blocking observations

1. Weapon-family differences are intentionally restrained at native 1×; blade curvature and accents are clearer at 2× inspection than in a wide shot.
2. The Chapter I tutorial overlay remains visible in several QA captures. It does not cover the Player but makes the evidence less presentation-clean than a dedicated photo mode.
3. The Prologue image records the authored unarmed revival identity during emergence, not the later armed full-body state; the dagger pickup transition is covered by the Prologue flow test.

These are presentation notes, not Stage 2 failures. Gameplay timing, collision shapes, movement values, damage, stamina and chapter content were not changed.

## Gate

Stage 2 is complete. The next allowed milestone is Stage 3: Candle Warden concept, formal pixel acting/gesture set, lantern-light presentation and Prologue integration. It requires a new explicit approval.
