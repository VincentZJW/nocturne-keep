# Chapter II Phase 2 enemy prototype specification

Status: implemented; manual combat-feel acceptance pending

## Runtime ownership

The four grounded roles share `SilentCourtGroundEnemy`, a Chapter II-only behavior layer over `GroundEnemyBase`. It owns role selection, bounded windup/active/recovery timing, two composed Hitboxes, attack IDs, Acolyte support and role-specific Debug output. It does not duplicate Health, damage settlement, faction filtering, edge checks, gravity, Hurt or Death.

`HangingStalker` implements the distinct ceiling loop directly over `EnemyCombatant`: Hang → telegraph/direction lock → Drop → guaranteed ground Recovery → at most one Claw → Retreat → ReturnToAnchor. It has no mid-drop tracking.

All scenes compose `HealthComponent`, `HurtboxComponent`, `HitboxComponent` and `LootDropComponent`. Enemy attacks use EnemyHitbox layer 7 against PlayerHurtbox layer 4; projectiles use layer 9 and stop on World layer 1. Player attacks remain Normal 12 / Dash 24.

## Delivered roles

| Role | HP | Damage | Key fairness contract |
| --- | ---: | --- | --- |
| Hollow Retainer | 48 | stab 7; combo 5+5 | active cannot be light-reset; every action reaches Recovery |
| Court Halberdier | 72 | thrust 10; sweep 12; push 6 | 0.32s slow turn; no long thrust at contact range |
| Mourning Armor | 96 | overhead 14; bash 9; sweep 12 | front Normal ×0.75; rear full; four-point Poise with Dash=2 |
| Blood-Candle Acolyte | 60 | projectile 8; ember 4 | straight lock; short one-hit ember; one non-stacking 0.90 windup ally buff |
| Hanging Stalker | 48 | drop 9; claw 6 | 0.55s telegraph; locked drop; one-claw maximum before return |

## Assets and animation

Each role owns an editable concept SVG and deterministic 64×64 transparent PNG frames below `assets/enemies/<role>/`. `generate_phase_2_enemy_assets.gd` uses only Godot Image pixel rectangles/lines. `build_phase_2_sprite_frames.gd` creates nearest-neighbor SpriteFrames resources under each role's `animations/` directory. Asset provenance is project-original and recorded in the enemy asset README.

## Test surfaces

- Independent scenes: `scenes/enemies/*.tscn`.
- Combined F6 room: `scenes/tests/phase_2_enemy_prototype_room.tscn`.
- Main/Debug Chapter II: `SilentCourt/Phase2EnemyPrototypeShowcase`, exactly five acceptance instances.
- Automated contracts: saved scene/asset/animation values, mitigation, Poise, bounded Retainer recovery, projectile, non-stacking buff, drop direction lock, exact attack damage and per-attack target dedup.

## Deferred

Formal E01–E15 activation/population, planned 34-enemy quantities, returning shared enemies, squad rules, final art/audio, Hollow Duchess and Boss arena logic are not part of Phase 2.
