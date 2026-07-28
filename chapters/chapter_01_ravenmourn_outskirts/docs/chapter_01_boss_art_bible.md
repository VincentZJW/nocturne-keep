# Fallen Gate Knight Boss Art Bible

Version: 3.0
Last updated: 2026-07-28

## Role and story

The Fallen Gate Knight is Ravenmourn's ruined threshold made animate: the last royal knight ordered to hold the gate and moat bridge. Seven years after the Empty Bell, awareness is gone but the final command remains. His dying recognition — “The bell… knows you.” — gives the fight a tragic, oath-bound character rather than a demonic one.

He must read as a chapter-ending military monument, never an enlarged Cursed Shield Guard. The 96×96 authored canvas, crowned gate-spire helm, asymmetrical layered plate, raven-gate crest, tapered tower shield, broad greatsword and torn blood-dark cape establish a unique silhouette.

## Phase 1 — the oath

- Shield-led, upright and immovable silhouette.
- Tapered tower shield has a peaked crown, layered rim, thickness, five rivets and the Ravenmourn crowned-raven crest; it is not a rectangle.
- Greatsword remains a complete weapon behind/beside the shield: leather grip, gold pommel/crossguard, broad silver blade, fuller, chipped tip.
- Enclosed crown helm uses a narrow cold-blue soul-fire slit.
- Pauldrons, cuirass ribs, waist crest, tassets, greaves and boots use separate material bands so the body remains readable behind the shield.
- Cape is substantially intact but torn and dried-blood dark.

## Permanent shield condition

| Shield state | Runtime ratio | Art contract |
|---|---:|---|
| 100% intact | ≥80% | complete crest/rim/rivets |
| damaged | 50–79% | four visible cracks and first edge notch |
| critical | 1–49% | eight cracks, broken rim sections, split crest and restrained soul leak |
| broken | 0% | no defensive shield mass; fragments only during the authored break |

`VisualRoot/ShieldDamageOverlay` follows the authoritative Shield signal. The stage cannot heal visually or return after break. Normal hits retain a restrained metal response; the shield-break frames add finite metal fragments, pale impact lines and cold-blue leakage without hiding the body.

## Phase 2 — the command without a shield

Phase 2 is independently redrawn, not Phase 1 minus one Sprite:

- the shield is absent permanently;
- the shattered left pauldron exposes bone/curse structure and cold-blue seams;
- both arms meet the greatsword grip;
- torso and helmet pitch forward;
- the cape is shorter, split and more violently torn;
- crown/visor cracks and soul fire become more legible;
- the greatsword gains cold-blue fissures and clock/gate accents;
- the silhouette changes from broad defensive mass to tall two-handed sword pressure.

## Formal production assets

- Concepts: `assets/boss/fallen_gate_knight/concept_art/`
- Formal frames: `assets/boss/fallen_gate_knight/sprites/<animation>/`
- Shield/impact effects: `assets/boss/fallen_gate_knight/effects/`
- Runtime preview: `assets/boss/fallen_gate_knight/animations/fallen_gate_knight_v3_runtime_preview.png`
- Runtime SpriteFrames: `resources/boss/fallen_gate_knight_sprite_frames.tres`
- Previous production frames: `assets/boss/fallen_gate_knight/reference/deprecated_v2/fallen_gate_knight_runtime_v2_frames.tar.gz`

All runtime frames are 96×96 RGBA PNG, nearest-neighbor, lossless, no mipmaps. The saved Boss scene and Main instance use the formal SpriteFrames path; archives have no runtime reference.

## Animation contract

The stable 20 Gameplay families keep their prior frame counts and timing. Twenty-one supplemental production/reference families divide anticipation, active and recovery art without changing AI or damage timing. The combined formal resource contains 41 animations / 165 frames.

| Phase | Stable Gameplay families | Supplemental authored families |
|---|---|---|
| Phase 1 | idle/walk/turn shielded, shield_block, shield_bash, sword_slash, heavy_overhead, hurt_shielded, shield_break | dormant, intro, approach_shielded, shield_hit, bash/slash/thrust/heavy windup-active-recovery, light_hit, hurt, death_start |
| Transition | phase_transition | permanent fragment and soul-leak states |
| Phase 2 | idle/walk/turn unshielded, combo_slash_1/2, charge_thrust, jump_smash, shockwave_strike, hurt_unshielded, death | combo_slash, stagger |

Every action keeps full body structure and a complete sword through anticipation, active and recovery frames. Horizontal flip remains the only left/right variant; visual, FacingRoot and Hitboxes continue to flip together.

## Concept deliverables

- `fallen_gate_knight_phase_01_concept.png`
- `fallen_gate_knight_phase_02_concept.png`
- `fallen_gate_knight_phase_comparison.png`
- `fallen_gate_knight_shield_design.png`
- `fallen_gate_knight_shield_damage_states.png`
- `fallen_gate_knight_greatsword_design.png`
- `fallen_gate_knight_attack_pose_sheet.png`

## Prohibited shortcuts

- No scaled normal-enemy body.
- No rectangle shield or one-pixel line sword.
- No Phase 2 created by hiding a shield or applying red modulation.
- No effect-only active frame that erases body/weapon structure.
- No Player ghost/death language.
- No runtime reference to `reference/deprecated_*`.
