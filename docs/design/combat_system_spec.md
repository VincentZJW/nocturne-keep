# Combat System Specification

Version: 1.6 — permanent Shield Guard break feedback
Last updated: 2026-07-24

## Ownership

```text
Actor
├── HealthComponent       bounded Health and guarded died signal
├── HurtboxComponent      faction/invulnerability acceptance and Health forwarding
└── HitboxComponent       active damage, attack kind/id, one-hit target memory
```

- Health remains the sole data authority; HUD only observes signals.
- Hitbox/Hurtbox components do not select AI states or animations.
- `EnemyHitPolicyComponent` is an optional pre-damage hook. `ShieldBlockComponent` consumes frontal normal hits and converts the first frontal Dash Attack into a permanent shield break plus GuardBreak.
- `EnemyCombatant` is the narrow encounter/debug contract. The three new actors share `GroundEnemyBase`; Castle Guard retains its stable AI implementation.

## Collision layers

| Bit / value | Name | Purpose |
| --- | --- | --- |
| 1 / 1 | World | floors, platforms, walls |
| 2 / 2 | PlayerBody | Player body |
| 3 / 4 | EnemyBody | enemy bodies |
| 4 / 8 | PlayerHurtbox | receives hostile melee/projectiles |
| 5 / 16 | EnemyHurtbox | receives Player attacks |
| 6 / 32 | PlayerHitbox | normal/Dash Attack |
| 7 / 64 | EnemyHitbox | enemy melee |
| 8 / 128 | Detection | Player acquisition only |
| 9 / 256 | Projectile | ranged damage channel |

Player Hurtbox mask is `320` (`EnemyHitbox + Projectile`). Enemy Hurtboxes accept only `PlayerHitbox`. Enemy body contact and enemy-on-enemy overlap never deal damage. Crossbow bolt root ray-checks World; its child Hitbox uses Projectile→PlayerHurtbox.

## Damage and active windows

| Source | Damage | Active frames / cadence |
| --- | ---: | --- |
| Player `attack` | 1 | `attack_02/03` |
| Player `dash_attack` | 2 | `dash_attack_03/04` |
| Castle Guard sword | 5 | `attack_03/04`; 0.35 / 0.10 / 0.45 s |
| Shield Guard weapon | 8 | `attack_03/04`; 0.40 / 0.10 / 0.55 s |
| Spearman thrust | 10 | `attack_thrust_04/05`; 0.45 / 0.10 / 0.60 s |
| Crossbow bolt | 6 | one hit after 0.60 s Aim; 1.50 s Reload |

Every accepted attack receives an id and can hit one target once. Hurt/death/action cancellation closes attack windows. Hitbox monitoring changes are deferred when required by PhysicsServer, while logical activation changes immediately.

Enemy Health and damage are authored only in the shared Config resources. Saved enemy scenes do not duplicate Health maxima or attack damage on their composed components. Runtime attack windows pass the current Config value into `HitboxComponent.begin_attack()`; CrossbowBolt remains inactive until initialized from its shooter's Config.

## Enemy-specific rules

- **Shield Guard:** while intact, frontal normal Attack is blocked with feedback and no Hurt. The first frontal Dash Attack is consumed, permanently destroys the shield, and triggers a 0.70-second GuardBreak. GuardBreak cannot block/attack/chase and remains readable even while punish damage is accepted. Recovery uses shieldless Idle/Walk/Attack/Hurt/Death presentation; all later hits from every direction deal normal damage. Back hits never engage the shield policy. Blocking is directional, derived from facing and source position.
- **Spearman:** long narrow forward Hitbox and 76-pixel attack range. Below a 34-pixel minimum distance it retreats rather than producing a misleading rear/point-blank hit.
- **Crossbowman:** Aim→Shoot→Reload; it retreats inside 70 pixels and has no melee attack. Bolts persist if the shooter dies, damage once, collide with World, and expire after 3 seconds.
- **All enemies:** Hurt interrupts ordinary attacks and applies short knockback. Death stops AI, closes attack/detection/Hurtbox, plays fall/dissolve frames, emits presentation completion, and frees the node. Enemy death never creates the Player ghost.

## Main and test composition

F5 runs `res://scenes/main/main.tscn`. Its four one-shot encounter groups contain 9 enemies, sized 2/2/2/3: three Castle Guards, two Shield Guards, two Spearmen, and two Crossbowmen. One Crossbowman occupies PlatformB. Main's closable debug panel reports activation/counts and type-specific summaries via `EnemyCombatant`.

`combat_test_room.tscn` remains the one-Guard regression room. `enemy_variety_test_room.tscn` contains all four types, a high platform, toggleable Hitbox/Hurtbox display, and Reset.

## Explicit exclusions

No critical hits, armor formula, attributes, status effects, combo tree, drops, enemy Health HUD, flying/elite enemy, Boss, random spawning, or final encounter balance is delivered.
