# Hollow Duchess Stage 2 forced-QA report

Date: 2026-07-29

Scope: `The Hollow Duchess, Seraphine / 空心公爵夫人·瑟芙琳` only

Result: **PASS — implementation complete; native-scale artistic acceptance remains user review**

## Delivered identity

- Phase 1 is the masked hostess of the final ball: tall black/oxblood layered court gown, porcelain mask, old-gold headpiece, complete court rapier and articulated blade fan.
- The 4.40-second gameplay transition retains the existing combat threshold and timing while its dedicated 39-frame art now describes freeze, candle extinction, hairline crack, mask break, head distortion, arm elongation, dress tear, back/rib expansion, weapon mutation and final reveal.
- Phase 2 is a separately drawn Unmasked form: void face with restrained crimson eyes, exposed rib structure, elongated bone limbs, shredded gown, skeletal back fan, bone-stiletto rapier and shattered-mask blade fan. It is not a tint or a Phase 1 silhouette with the mask removed.
- Formal art uses transparent 96×96 PNGs, nearest-neighbour import and stable feet/origin. Gameplay still flips the right-facing source via `AnimatedSprite2D.flip_h`.

## Forced QA matrix

| Gate | Status | Evidence |
|---|---|---|
| Phase 1 concept | PASS | `chapters/chapter_02_silent_court/assets/boss/hollow_duchess/concept_art/hollow_duchess_phase_01_concept.png` |
| Phase 2 concept | PASS | `chapters/chapter_02_silent_court/assets/boss/hollow_duchess/concept_art/hollow_duchess_phase_02_unmasked_concept.png` |
| Phase comparison/silhouette | PASS | `concept_art/hollow_duchess_phase_comparison.png`, `animations/hollow_duchess_stage_2_silhouette_preview.png` |
| Rapier/fan/Unmasked weapons | PASS | `concept_art/hollow_duchess_rapier_design.png`, `hollow_duchess_fan_blade_design.png`, `hollow_duchess_phase_02_weapons.png` |
| Mask states and transformation poses | PASS | `concept_art/hollow_duchess_mask_states.png`, `hollow_duchess_transformation_pose_sheet.png` |
| Phase 1 formal SpriteFrames | PASS | `phase_01/hollow_duchess_phase_01_sprite_frames.tres`; 143 frames |
| Full phase transformation | PASS | `phase_transition/hollow_duchess_transformation_sprite_frames.tres`; 39 frames / 11 animation families |
| Phase 2 formal SpriteFrames | PASS | `phase_02_unmasked/hollow_duchess_unmasked_sprite_frames.tres`; 180 frames |
| Attack animation compatibility | PASS | all seven gameplay attacks completed 10 forced cycles each; 70 total |
| Main integration | PASS | `MainBootstrap -> SilentCourt -> GameplayWorld/BossArea/HollowDuchess` uses the three authoritative resources without Inspector art override |
| Death/reliquary/Chapter III handoff | PASS | formal death capture, Crimson Masque pickup, mirror passage and Chapter III transition regression |
| Legacy runtime reference | PASS | live Boss scene has zero reference to old `animations/hollow_duchess_sprite_frames.tres`; old set is archived |

## Runtime assets and ownership

- Concepts: `res://chapters/chapter_02_silent_court/assets/boss/hollow_duchess/concept_art/`
- Phase 1: `res://chapters/chapter_02_silent_court/assets/boss/hollow_duchess/phase_01/`
- Transformation: `res://chapters/chapter_02_silent_court/assets/boss/hollow_duchess/phase_transition/`
- Phase 2: `res://chapters/chapter_02_silent_court/assets/boss/hollow_duchess/phase_02_unmasked/`
- Effects: `res://chapters/chapter_02_silent_court/assets/boss/hollow_duchess/effects/`
- Deprecated archive: `res://chapters/chapter_02_silent_court/assets/boss/hollow_duchess/reference/deprecated_stage1/hollow_duchess_stage1_runtime_art.tar.gz`
- Deterministic generator/builders: `generate_hollow_duchess_art_v2.gd`, `build_hollow_duchess_sprite_frames_v2.gd`

No Health, damage, poise, AI, collision, attack timing, Boss-room placement, reward or chapter-transition value changed in Stage 2.

## Main/F5 evidence

Formal graphical QA launched `res://scenes/bootstrap/main_bootstrap.tscn`, selected Chapter II and spawn `CH2_BOSS`, then used the saved `silent_court.tscn` Boss instance.

- Phase 1 identity: `docs/qa/chapter_02_enemy_boss_art_rework/stage_2/04_phase_1_main.png`
- Phase 1 rapier action: `docs/qa/chapter_02_enemy_boss_art_rework/stage_2/05_phase_1_rapier_main.png`
- Mask crack: `docs/qa/chapter_02_enemy_boss_art_rework/stage_2/06_mask_crack_main.png`
- Transformation: `docs/qa/chapter_02_enemy_boss_art_rework/stage_2/07_phase_transformation_main.png`
- Phase 2 Unmasked identity: `docs/qa/chapter_02_enemy_boss_art_rework/stage_2/08_phase_2_unmasked_main.png`
- Phase 2 attack: `docs/qa/chapter_02_enemy_boss_art_rework/stage_2/09_phase_2_attack_main.png`
- Phase 2 death: `docs/qa/chapter_02_enemy_boss_art_rework/stage_2/10_phase_2_death_main.png`
- Reliquary and reward: `docs/qa/chapter_02_enemy_boss_art_rework/stage_2/11_duchess_reliquary_main.png`, `12_crimson_masque_claimed_main.png`
- Previous Main presentation for comparison: `docs/qa/chapter_02_hollow_duchess/01_intro_main.png`, `06_phase_transition_main.png`, `07_double_waltz_main.png`

## Exact verification results

1. Exact Godot 4.7.1 art generation — PASS: `phase1=143 phase2=180 transition=39 total=362`.
2. Exact Godot 4.7.1 editor import/parse after generation — exit 0; no parser or missing-resource error after SpriteFrames construction.
3. SpriteFrames builder — PASS: `phase1=143 phase2=180 transition=39 total=362`.
4. `test_hollow_duchess_art_stage_2.gd` — PASS: nine concepts, all required animation families, frame counts, 96×96 textures, phase distinction, archive, Boss scene and Main level bindings.
5. `test_hollow_duchess_boss.gd` — PASS: seven attacks × ten cycles, 70 cycles total; Phase 2 and poise unchanged.
6. `test_hollow_duchess_full_fights.gd` — PASS: five deterministic full fights, 278 total attacks.
7. `test_hollow_duchess_main_integration.gd` — PASS: Boss, layers, entrance, presentation, checkpoint, HUD, reliquary, candles and mirror.
8. `test_hollow_duchess_presentation_phase.gd` — PASS: intro, ten-step transformation contract and Phase 2 poise.
9. `test_chapter_02_to_03_transition.gd` — PASS: death dialogue, reward, mirror passage, reload persistence and Chapter III handoff.
10. `capture_hollow_duchess_qa.gd` — graphical OpenGL/Metal PASS with 12 Main captures. The capture harness reports GLES/resource teardown diagnostics only after its PASS/forced process exit; no parser, missing-resource or gameplay runtime error occurred before teardown.
11. Independent `hollow_duchess_test_room.tscn`, saved `silent_court.tscn` and `main_bootstrap.tscn` headless smokes — exit 0. Bootstrap retained the formal Opening route.

## Manual acceptance path

Temporarily enable Chapter II debug start with `debug_start_spawn_id = &"CH2_BOSS"`, press F5, cross CP05 and trigger the Ballroom encounter. Review the Phase 1 mask/gown/rapier/fan, reduce HP to the existing 121/220 threshold, inspect the complete 4.40-second transformation, then review Phase 2 movement, double lunge, phantom/final waltz and death. Confirm Crimson Masque collection and mirror/Chapter III passage, then restore Debug Start defaults.

The automated gates prove resource integrity and gameplay preservation. Fine animation weight, native-scale material preference and final artistic approval remain manual user acceptance.
