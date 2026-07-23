# Minimal Combat Foundation

Version: 1.1 — Cursed Castle Guard animation integration
Last updated: 2026-07-23

## Purpose and player experience

This foundation turns the existing readable Player attack poses into deterministic damage without moving Health ownership into animation or UI. The Player should feel fast and precise: the normal dual-dagger thrust deals one point, Dash Attack deals two, and neither can repeatedly damage the same target during one animation. The Cursed Castle Guard creates the first evade-and-punish decision through a slower raised-sword telegraph and committed heavy cut.

All damage values and timings in this document are prototype hypotheses pending manual playtest. They are not a finalized balance curve.

## Composition and ownership

```text
Actor
├── HealthComponent       bounded current/max Health and guarded died signal
├── HurtboxComponent      hostile-contact acceptance and Health forwarding
└── HitboxComponent       active damage, faction, attack id, per-target memory
```

- `HealthComponent` remains the only Health data authority. HUD nodes observe signals and never calculate or store gameplay Health.
- `HitboxComponent` owns damage, faction, active state, attack id, and one-hit-per-target memory. Starting a new attack id clears only that attack's target memory.
- `HurtboxComponent` rejects disabled, dead, inactive, self-faction, and same-faction contacts before forwarding accepted damage.
- Presentation/state owners decide when a Hitbox is active. Hitbox/Hurtbox components do not select animations or AI states.

## Named 2D collision layers

| Bit | Name | Use |
| --- | --- | --- |
| 1 | World | floors, platforms, and walls |
| 2 | PlayerBody | Player `CharacterBody2D` |
| 3 | EnemyBody | enemy `CharacterBody2D` |
| 4 | PlayerHurtbox | receives hostile enemy hitboxes |
| 5 | EnemyHurtbox | receives hostile Player hitboxes |
| 6 | PlayerHitbox | Player Attack and Dash Attack |
| 7 | EnemyHitbox | Castle Guard sword |
| 8 | Detection | AI perception areas |

Body collision and damage collision are intentionally separate. Player/enemy body contact may block movement but never mutates Health.

## Player attack integration

The Player keeps two distinct forward rectangles under `CombatRoot`, mirrored as a unit when `AnimatedSprite2D.flip_h` changes.

| Action | Damage | Active frames | Shape intent |
| --- | ---: | --- | --- |
| `attack` | 1 | `attack_02`, `attack_03` | narrow dual-dagger thrust |
| `dash_attack` | 2 | `dash_attack_03`, `dash_attack_04` | longer narrow forward thrust |

Each accepted Attack, chained Attack, direct Dash Attack, or Dash-to-Attack transition receives one new attack id. Frame changes open/close the matching Hitbox; action cancellation, completion, Player death, or transition closes both. Movement, stamina cost, attack buffering, Dash timing, and animation FPS are unchanged.

## Cursed Castle Guard sword integration

The sword Hitbox deals one point and is active only on `attack_03` and `attack_04`. The corresponding art is a downward-forward one-handed heavy cut, not a thrust. Custom SpriteFrames duration ratios make those two frames total 0.10 seconds. The preceding raised-sword/loaded frames total 0.35 seconds and the final low-blade recovery frame lasts 0.45 seconds. Hurt and Death immediately close the sword Hitbox. Death presentation has no damage, ghost, or persistent corpse collision; its animation completion remains the cleanup boundary.

## Signals

- `HitboxComponent.hit_confirmed(target, damage, attack_id)` reports an accepted unique target.
- `HitboxComponent.active_changed(active)` supports test/debug presentation.
- `HurtboxComponent.hit_received(damage, source_position, attack_id)` lets an actor react without owning damage calculation.
- Existing `HealthComponent.health_changed` and `HealthComponent.died` remain the public Health contract.
- Player forwards accepted hurtbox contacts through `damage_received`; no Player Hurt state or invulnerability was added in this milestone.

## Edge cases and failure states

- Repeated overlap during one attack id is ignored.
- Re-enabling a Hitbox with a new attack id permits a new hit.
- Same-faction contact, body contact, disabled Hurtboxes, inactive Hitboxes, invalid/non-positive damage, and post-death damage do nothing.
- A dying Castle Guard closes Hitbox/Hurtbox before playing Death, preventing late sword or corpse damage.
- There is no invulnerability timer yet. Separate attacks can damage on separate attack ids as designed.

## Explicit exclusions

No critical hits, attributes, armor formula, status effects, Player Hurt state, invulnerability frames, combo tree, enemy drops, enemy Health HUD, ranged damage, Boss logic, or production encounter balancing is delivered here.
