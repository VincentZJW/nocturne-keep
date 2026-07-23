# Minimal Combat Foundation

Version: 1.3 — Hurt feedback, five-point sword, and encounter activation
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
- `HurtboxComponent` rejects disabled, invulnerable, dead, inactive, self-faction, and same-faction contacts before forwarding accepted damage.
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

### Concrete layer and mask matrix

| Node | Layer | Mask | Result |
| --- | --- | --- | --- |
| Main floors/platforms/walls | World (1) | World (1) in Main | solid environment |
| Player body | PlayerBody (2) | World + EnemyBody (1 + 4 = 5) | collides with terrain and enemy bodies |
| Castle Guard body | EnemyBody (4) | World + PlayerBody (1 + 2 = 3) | collides with terrain and Player, never deals damage |
| Player Hurtbox | PlayerHurtbox (8) | EnemyHitbox (64) | accepts active hostile sword areas only |
| Guard Hurtbox | EnemyHurtbox (16) | PlayerHitbox (32) | accepts active Player Attack/Dash Attack only |
| Player Attack hitboxes | PlayerHitbox (32) | EnemyHurtbox (16) | never hit the Player or allied sources |
| Guard sword Hitbox | EnemyHitbox (64) | PlayerHurtbox (8) | never hits Guard Hurtboxes or bodies |
| Guard DetectionArea | Detection (128) | PlayerBody (2) | target acquisition only, no damage |

## Player attack integration

The Player keeps two distinct forward rectangles under `CombatRoot`, mirrored as a unit when `AnimatedSprite2D.flip_h` changes.

| Action | Damage | Active frames | Shape intent |
| --- | ---: | --- | --- |
| `attack` | 1 | `attack_02`, `attack_03` | narrow dual-dagger thrust |
| `dash_attack` | 2 | `dash_attack_03`, `dash_attack_04` | longer narrow forward thrust |

Each accepted Attack, chained Attack, direct Dash Attack, or Dash-to-Attack transition receives one new attack id. Frame changes open/close the matching Hitbox; action cancellation, completion, Player death, or transition closes both. Movement, stamina cost, attack buffering, Dash timing, and animation FPS are unchanged.

## Cursed Castle Guard sword integration

The sword Hitbox deals five points and is active only on `attack_03` and `attack_04`. `resources/enemies/castle_guard_config.tres` is the single production tuning authority; the AI and debug views read that value rather than duplicating a literal. The corresponding art is a downward-forward one-handed heavy cut, not a thrust. Custom SpriteFrames duration ratios make those two frames total 0.10 seconds. The preceding raised-sword/loaded frames total 0.35 seconds and the final low-blade recovery frame lasts 0.45 seconds. One attack id can damage the Player once, then the Player's 0.50-second grace window rejects other sources. Hurt and Death immediately close the sword Hitbox. Death presentation has no damage, ghost, or persistent corpse collision; animation completion emits the presentation boundary and frees the enemy node.

## Main and isolated test composition

The F5 scene `res://scenes/main/main.tscn` composes five instances of the same reusable `castle_guard.tscn` under four `Main/World/Encounters` groups. Group sizes are 1/1/1/2 and saved Guard positions are `(500, 610)`, `(1030, 610)`, `(1500, 610)`, `(2070, 610)`, and `(2310, 610)`. Every group owns one Player-only ActivationArea; inactive Guard AI and detection are paused until first entry, after which activation remains latched for the scene run. The 2600-pixel floor is only about 2.03 1280-pixel screens, so five enemies are used instead of the suggested six to eight for a 3–5-screen map.

Main's optional enemy debug panel reports each group's activation, engaged/alive/attacking counts and each Guard's Health, state, target, sword window, position, and actual damage. `res://scenes/tools/combat_test_room.tscn` remains an independent one-enemy laboratory with world-space combat guides and Reset.

## Signals

- `HitboxComponent.hit_confirmed(target, damage, attack_id)` reports an accepted unique target.
- `HitboxComponent.active_changed(active)` supports test/debug presentation.
- `HurtboxComponent.hit_received(damage, source_position, attack_id)` lets an actor react without owning damage calculation.
- `HurtboxComponent.invulnerability_changed(invulnerable)` reports the Player-owned grace window without involving HUD.
- Existing `HealthComponent.health_changed` and `HealthComponent.died` remain the public Health contract.
- Player forwards contacts through `damage_received`; `PlayerHurtController` emits Hurt start/finish and a reserved audio request while `Player` owns state and collision movement.

## Edge cases and failure states

- Repeated overlap during one attack id is ignored.
- Re-enabling a Hitbox with a new attack id permits a new hit.
- Same-faction contact, body contact, disabled Hurtboxes, inactive Hitboxes, invalid/non-positive damage, and post-death damage do nothing.
- A dying Castle Guard closes Hitbox/Hurtbox before playing Death, preventing late sword or corpse damage.
- The first accepted non-lethal hit sets invulnerability synchronously, so another enemy contacting in the same physics frame is rejected. Death cancels Hurt presentation and respawn clears all Hurt timers/modulation/camera offset.

## Explicit exclusions

No critical hits, attributes, armor formula, status effects, combo tree, enemy drops, enemy Health HUD, ranged damage, Boss logic, random spawning, or production encounter balancing is delivered here.
