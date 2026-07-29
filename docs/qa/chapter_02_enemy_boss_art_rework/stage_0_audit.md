# Chapter II Enemy / Boss Art Rework — Stage 0 Audit

Date: 2026-07-29

Scope: read-only runtime/art audit plus documentation baseline

Result: **AUDIT PASS / ART ACCEPTANCE FAIL — rework required; no formal art replaced in Stage 0**

## 1. Runtime authority

| Item | Authoritative path / node |
|---|---|
| F5 Main | `res://scenes/bootstrap/main_bootstrap.tscn` |
| Chapter II formal level | `res://chapters/chapter_02_silent_court/scenes/level/silent_court.tscn` |
| Three-floor implementation | one saved `SilentCourt` world composed from room scenes under `scenes/rooms/`; floors are separated by authored spawn/transition coordinates, not three replacement main scenes |
| Runtime enemy parent | `SilentCourt/GameplayWorld/Enemies` |
| Authored enemy spawns | `SilentCourt/EnemySpawnPoints/<Encounter spawn>`; `Chapter02EncounterRuntime` instances the selected PackedScene into the runtime parent |
| Boss instance | `SilentCourt/GameplayWorld/BossArea/HollowDuchess` |
| Boss visual | `HollowDuchess/VisualRoot/AnimatedSprite2D` |
| Independent ordinary-enemy room | `res://chapters/chapter_02_silent_court/scenes/tests/phase_2_enemy_prototype_room.tscn` |
| Independent Boss room | `res://chapters/chapter_02_silent_court/scenes/tests/hollow_duchess_test_room.tscn` |

`project.godot` still points F5 to Bootstrap. Stage 0 did not replace it with a test scene.

## 2. Formal roster and Main references

| Character | Formal scene | Script | Data Resource | SpriteFrames | Saved Main count |
|---|---|---|---|---|---:|
| Hollow Retainer | `scenes/enemies/hollow_retainer.tscn` | `scripts/enemies/silent_court_ground_enemy.gd` | `resources/enemies/hollow_retainer_data.tres` | `assets/enemies/hollow_retainer/animations/hollow_retainer_sprite_frames.tres` | 12 |
| Court Halberdier | `scenes/enemies/court_halberdier.tscn` | `scripts/enemies/silent_court_ground_enemy.gd` | `resources/enemies/court_halberdier_data.tres` | `assets/enemies/court_halberdier/animations/court_halberdier_sprite_frames.tres` | 8 |
| Mourning Armor | `scenes/enemies/mourning_armor.tscn` | `scripts/enemies/silent_court_ground_enemy.gd` + `mourning_armor_hit_policy.gd` | `resources/enemies/mourning_armor_data.tres` | `assets/enemies/mourning_armor/animations/mourning_armor_sprite_frames.tres` | 5 |
| Blood-Candle Acolyte | `scenes/enemies/blood_candle_acolyte.tscn` | `scripts/enemies/silent_court_ground_enemy.gd` | `resources/enemies/blood_candle_acolyte_data.tres` | `assets/enemies/blood_candle_acolyte/animations/blood_candle_acolyte_sprite_frames.tres` | 4 |
| Hanging Stalker | `scenes/enemies/hanging_stalker.tscn` | `scripts/enemies/hanging_stalker.gd` | `resources/enemies/hanging_stalker_data.tres` | `assets/enemies/hanging_stalker/animations/hanging_stalker_sprite_frames.tres` | 4 |
| Hollow Duchess | `scenes/boss/hollow_duchess.tscn` | `scripts/boss/hollow_duchess.gd` | `resources/boss/hollow_duchess_data.tres` | P1, transition and P2 resources listed below | 1 |

All relative paths above are under `res://chapters/chapter_02_silent_court/`. The formal level also intentionally reuses four `FallenCrossbowman` and one `GargoyleSentinel` from `res://shared/`; they are not Chapter II-specific rework targets.

The Main level has direct PackedScene references for all five Chapter II enemies and the Boss. Enemy spawn nodes override encounter ID, role, position and platform bounds, but not SpriteFrames or character-art resources. The saved Duchess instance overrides only position. Therefore replacing the authoritative scene/SpriteFrames chain in later stages will reach formal F5 encounters without editing 33 separate instances.

## 3. Current ordinary-enemy asset inventory

All current ordinary-enemy production cells are 64×64 transparent PNGs and all formal `AnimatedSprite2D` nodes request nearest filtering. Each role has exactly one approximately 1.1–1.3 KB SVG concept board built from large rectangles/polygons. These files document combat labels but do not meet the requested high-quality concept standard.

| Character | Current animations / frames | Current PNG count | Missing or insufficient against target |
|---|---:|---:|---|
| Hollow Retainer | 7 / 32 | 32 | no service/bow idle, retreat, turn, split stab phases, split combo hits/recovery, light hit or stagger; smallsword reads as a pale line and uniform as a narrow block |
| Court Halberdier | 9 / 39 | 39 | no distinct guard idle/approach, split attack phases, light hit or stagger; halberd head and dual-hand grip are not preserved at gameplay scale |
| Mourning Armor | 10 / 45 | 45 | no dormant, heavy-specific walk, split overhead phases, poise hit or two-part empty-armor death; mass is mainly rectangular scale rather than articulated funerary plate |
| Blood-Candle Acolyte | 7 / 31 | 31 | no prayer idle, turn, split cast phases, ember cast, three-part buff, light hit/stagger or candle extinguish; flame is a small static mark and robe lacks layered ritual construction |
| Hanging Stalker | 9 / 37 | 37 | no hidden/track/detach/land/short-chase/turn/stagger or separate air/ground death; inverted anatomy reads as a compact hanging block rather than a court hunter |

Current runtime animation names and exact counts/FPS were read from the saved `.tres` files, not inferred from filenames. The existing deterministic sources are `generate_phase_2_enemy_assets.gd` and `build_phase_2_sprite_frames.gd`; their animation dictionaries exactly match the limited sets above. Later stages must replace or supersede these sources so regeneration cannot restore legacy block art.

## 4. Current Duchess implementation

### Resource chain

- Phase 1 SpriteFrames: `assets/boss/hollow_duchess/animations/hollow_duchess_sprite_frames.tres` — 20 animations / 100 frames, 96×96.
- Dedicated transition SpriteFrames: `assets/boss/hollow_duchess/phase_transition/hollow_duchess_transformation_sprite_frames.tres` — one 5-frame animation at 1.15 FPS.
- Phase 2 SpriteFrames: `assets/boss/hollow_duchess/phase_02_unmasked/hollow_duchess_unmasked_sprite_frames.tres` — 20 animations / 100 frames, 96×96.
- Current concept: `assets/boss/hollow_duchess/concept_art/hollow_duchess_concept.svg` — one 2.5 KB rectangle/pixel mock-up, not separate P1/P2/equipment studies.
- Current effects: `effects/phantom_dancer.png` and `effects/rapier_glint.png`.
- Current weapons are painted into every character frame; there is no standalone authoritative rapier or blade-fan source.

### Current phase routing

`hollow_duchess.gd` caches the Phase 1 SpriteFrames, swaps to the 5-frame transition set on `PhaseTransition`, applies Phase 2 SpriteFrames at the configured 2.75-second reveal point and completes the gameplay transition at 4.40 seconds. The Phase 2 Resource contains the same 20 public animation names as Phase 1 so the existing state machine can continue calling `idle`, `turn`, `rapier_thrust_*`, `fan_slash_*`, `riposte`, `double_lunge`, `phantom_dance`, `final_waltz`, `stagger`, `light_hit` and `death`.

This separation is technically real, but its art result is not sufficient: Phase 1 is a compact rectangular gown with a square porcelain face and line-like rapier; Phase 2 is primarily a crimson/dark recolour with short lateral spine lines. The saved Main evidence does not show the required elongated limbs, void torso, torn layered dress, faceless head, bone-stiletto rapier or skeletal fan. The 5-frame transition assets are isolated symbols/poses rather than a continuous anatomy-preserving transformation.

### Animation gap

- Phase 1 lacks distinct `dormant`, back-facing intro, intro turn, dialogue idle, approach/retreat, explicit sidestep cut, hurt and transition-start art families.
- Phase 2 reuses Phase 1 public names and frame counts rather than authoring the requested P2-specific reveal, distorted movement, dedicated P2 attacks and four-step death.
- Current afterimage is one static `phantom_dancer.png`; it cannot preserve phase-specific mask/faceless head, dress, limbs and weapon poses.
- Current death is one 7-frame family per phase and the recorded Main frame ends as a simple block-like remnant, not back-fan collapse, mask failure, body fold and dissolution.

The dedicated Duchess prompt is adopted as the detailed acceptance standard for Stages 2A–2D. Stage 0 makes no AI, health, poise, damage, cadence, hitbox or phase-threshold change; the current 220 HP / 60 P1 poise / 80 P2 poise data remains authoritative.

## 5. Existing visual evidence reviewed

The audit visually inspected the formal Main captures rather than accepting test names as proof:

- Ordinary enemies: `docs/qa/chapter_02_phase_2_enemies/main_*.png`.
- Boss Phase 1, transformation, Phase 2, attacks and death: `docs/qa/chapter_02_hollow_duchess/*.png`.

The old automated reports prove resource loading and gameplay sequencing, not art quality. At native Main scale the ordinary roster has limited material detail and weak role separation; the Duchess phases fail the new silhouette/anatomy/equipment bar. These images remain baseline evidence and are not overwritten by Stage 0.

## 6. Legacy handling and reference audit

- Current formal resources remain live until their own approved stage has generated, integrated and passed replacements. Stage 0 deletes nothing.
- Later stages archive superseded sources under each character's `reference/deprecated_<version>/` directory before changing the formal paths.
- `.import` files and `.godot` cache are reproducible metadata, not archival art.
- Current runtime references outside the asset roots are limited to the formal enemy/Boss scenes, Duchess presentation/phantom scenes, deterministic builders/generators and design docs. No alternate legacy SpriteFrames path was found in the saved Main scene.
- The asset root is currently singular `assets/boss/hollow_duchess/`. It remains authoritative during this rework to avoid an unrelated directory migration.

## 7. Main test routes and current limitation

- Formal ordinary-enemy route: set Chapter II and use `CH2_FLOOR_1_START`, `CH2_FLOOR_2_START` or `CH2_FLOOR_3_START`, then press F5 through Bootstrap.
- Formal Boss route: Chapter II + `CH2_BOSS`, then press F5 to exercise entrance, dialogue, Phase 1, transition, Phase 2, death, reliquary and Chapter III handoff.
- `CH2_ENEMY_ART_TRIAL` does not currently exist in `chapter_02_start_profile.tres`. The independent `phase_2_enemy_prototype_room.tscn` contains all five roles, but it cannot replace formal Main evidence. A unified debug start may be added only in an approved implementation stage.

## 8. Stage decision

| Stage 0 requirement | Status | Evidence |
|---|---|---|
| Audit all five formal enemies | PASS | saved scenes, data, SpriteFrames, Main spawn counts and visual captures read |
| Audit Duchess P1/transition/P2 | PASS | formal scene, script, config, three SpriteFrames resources and Main captures read |
| Identify old resources/references | PASS | authoritative paths, generators, scene bindings, shared references and lack of art overrides recorded |
| Produce per-character rework list | PASS | this report + `chapter_02_enemy_boss_art_bible.md` |
| Establish Art Bible | PASS | palette, silhouette, material, animation, directory and acceptance rules established |
| Replace art | NOT AUTHORIZED | reserved for Stages 1A–2D |
| Final Chapter II art acceptance | FAIL / NOT STARTED | every formal character still uses the audited legacy art |

**第二章人物重制尚未通过最终验收。** The next authorized unit is Stage 1A — Hollow Retainer — and it still requires explicit approval.

## 9. Exact Stage 0 verification

| Command / check | Actual result |
|---|---|
| Exact Godot `--version` | `4.7.1.stable.official.a13da4feb` |
| headless editor import/parse | exit 0; no parser, missing-resource or duplicate-UID error |
| five-role prototype room smoke | exit 0; no red runtime error |
| Hollow Duchess test room smoke | exit 0; no red runtime error |
| saved `silent_court.tscn` smoke | exit 0; existing non-fatal two-instance ObjectDB cleanup warning |
| `test_phase_2_enemy_prototypes.gd` | PASS, `enemies=5 assets=original combat=validated` |
| `test_hollow_duchess_boss.gd` | PASS, seven attacks × ten cycles, Phase 2 reached |
| `test_hollow_duchess_main_integration.gd` | PASS, formal Boss/entrance/presentation/HUD/reliquary/mirror links; existing one-instance cleanup warning |
| formal Bootstrap/F5-equivalent startup | exit 0; normal opening cinematic selected |

These checks prove that the Stage 0 documentation did not break the current game. They do **not** approve the audited legacy art.
