# Combat System Specification

Version: 2.1 — Resource-driven weapons and Chapter I loot scale
Last updated: 2026-07-24

## Ownership

```text
Actor
├── HealthComponent       bounded Health and guarded died signal
├── HurtboxComponent      faction/invulnerability acceptance and Health forwarding
└── HitboxComponent       active damage, attacker source, stable kind/id, one-hit memory
```

- Health remains the sole data authority; HUD only observes signals.
- Hitbox/Hurtbox components do not select AI states or animations.
- `EnemyHitPolicyComponent` is an optional pre-damage hook. `ShieldComponent` owns independent Shield Health and routes one accepted Shield Guard hit to either Shield or Body before `HurtboxComponent` mutates Body Health.
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
| Player `attack` | equipped WeaponData (10 / 12) | `attack_02/03` |
| Player `dash_attack` | equipped WeaponData (20 / 24) | `dash_attack_03/04` |
| Castle Guard sword | 5 | `attack_03/04`; 0.35 / 0.10 / 0.45 s |
| Shield Guard weapon | 8 | `attack_03/04`; 0.40 / 0.10 / 0.55 s |
| Spearman thrust | 10 | `attack_thrust_04/05`; 0.45 / 0.10 / 0.60 s |
| Crossbow bolt | 6 | one hit after 0.60 s Aim; 1.50 s Reload |
| Gargoyle Dive | 7 | 0.45 s windup; one target once; closes on World impact |
| Boss Shield Bash | 8 | `shield_bash` core frames |
| Boss Sword / Combo | 10 | distinct shielded/unshielded slash frames |
| Boss Heavy / Jump Smash | 15 | slow overhead or landing core frames |
| Boss Charge Thrust | 12 | forward charge core frames |
| Boss Shockwave | 8 | separate long low Hitbox core frames |

Every accepted attack receives an id and can hit one target once. Reopening another active frame with the same id preserves the Hitbox target ledger; only a genuinely new attacker/id pair clears it. Player attacks carry the Player root as `attacker`, so positional policies classify the actor rather than the forward weapon volume. Hurt/death/action cancellation closes attack windows. Hitbox monitoring changes are deferred when required by PhysicsServer, while logical activation changes immediately.

Player normal Attack is a finite three-use chain of the same four-frame thrust. A 0.10–0.20-second legal window latches at most one 0.08-second input without refresh; every accepted repeat waits for the complete frame four and receives a fresh attack id. The minimum start-to-start interval is 0.32 seconds. Step three rejects another buffer and enters a mandatory 0.34-second recovery before a new step one. Early/repeated spam cannot restart frame one, skip recovery or store multiple commands. Dash Attack timing and damage are unchanged.

Enemy Health and damage are authored only in the shared Config resources. Saved enemy scenes do not duplicate Health maxima or attack damage on their composed components. Runtime attack windows pass the current Config value into `HitboxComponent.begin_attack()`; CrossbowBolt remains inactive until initialized from its shooter's Config.

## Enemy-specific rules

- **Shield Guard:** Body Health is 50 and independent Shield Health is 30. While intact, frontal normal/Dash Attack applies the equipped WeaponData value only to Shield; rear or true actor-center attacks apply it only to Body. The breaking hit never overflows to Body. One shared Hurtbox routes through `ShieldComponent`, which marks the `attacker instance id + attack_id` consumed before selecting Shield or Body. This Shield-side ledger survives break and complements the Hitbox ledger, so a later active frame cannot damage newly exposed Body. Shield states progress intact→cracked→critical→broken with independent art, metal hit feedback, and a one-time four-frame break. The break flash is shield-local at 0.05 seconds / alpha 0.30; it never modulates the whole body. Zero Shield starts a 0.65-second GuardBreak, then permanently uses shieldless Idle/Walk/Attack/Hurt/Death. Target-side crossing starts a 0.22-second Turn instead of flipping immediately, creating a real rear punish window.
- **Spearman:** long narrow forward Hitbox and 76-pixel attack range. Below a 34-pixel minimum distance it retreats rather than producing a misleading rear/point-blank hit.
- **Spearman direction:** the last 0.15 seconds of the 0.45-second windup locks facing.
- **Crossbowman:** Aim→Shoot→Reload; it retreats inside 70 pixels and has no melee attack. The last 0.18 seconds of Aim locks facing. Bolts persist if the shooter dies, damage once, collide with World, and expire after 3 seconds.
- **Gargoyle:** flight ignores grounded patrol code. Dive locks direction in its final 0.15 seconds, uses one attack id, closes on World impact, exposes a 0.65-second GroundStun, then returns to authored hover height. All three Main instances share the rebuilt stone-gargoyle SpriteFrames; AI, damage and state timing remain unchanged.
- **Fallen Gate Knight:** Body 180 and Shield 100 compose the same Health/Hurtbox/Hitbox/Shield authorities. Frontal Player weapon attacks route exclusively to Shield until permanent break without overflow; rear attacks route only to Body. `ShieldComponent` snapshots attack id/type, source, Boss position/facing and timestamp synchronously at contact, so a deferred turn cannot retroactively change rear routing. Normal hits always deal their routed damage but only trigger a 0.32-second lightweight flash cooldown; they never transition Boss state, restart Hurt or cancel windup/active attacks. Dash hits use a 0.50-second feedback cooldown and may cause only a 0.12-second reaction from Idle/Approach/Turn/Recovery; all attack states, ShieldBreak, PhaseTransition and Death remain uninterruptible. Turn response is 0.18 s reaction + 0.30 s authored turn (0.4833 s measured at 60 Hz), with a 12 px threshold and 0.12 s cooldown. Facing/Sprite/Hitbox commit together at the end. Attack recovery remains 0.42 s; damage, active frames, skills and phases are unchanged.
- **All enemies:** Hurt interrupts ordinary attacks and applies short knockback. Death stops AI, closes attack/detection/Hurtbox, plays fall/dissolve frames, emits presentation completion, and frees the node. Enemy death never creates the Player ghost.

## Main and test composition

F5 runs `res://scenes/cinematics/opening_cinematic.tscn`, which enters `res://scenes/main/main.tscn`. Main owns 18 one-shot encounter groups with 34 normal enemies, followed by a separate resettable Boss room. Its closable debug panel reports loot state and the Boss Body/Shield/reward state via typed contracts.

`combat_test_room.tscn` remains the one-Guard regression room. `enemy_variety_test_room.tscn` contains all four types, a high platform, toggleable Hitbox/Hurtbox display, and Reset.

## Explicit exclusions

No critical hits, armor formula, attributes, status effects, Player combo tree, elite, second Boss, summons, random spawning, store, upgrades or final encounter balance is delivered.
## Weapon and target-scale migration

Player Attack/Dash Attack damage now resolves from equipped `WeaponData`: Veilbound 10/20 and Ravenfang 12/24. Normal enemies use 30/50/50/40/30 HP, Shield Guard uses an additional 30 Shield, and Gate Knight uses 180 Body/100 Shield. This preserves established hit counts. Player HP/Stamina and every enemy/Boss outgoing damage/timing remain unchanged. Shield visuals now use ratios so 30/100-point shields retain intact/damaged/critical readability.

Regular-enemy drop resolution and the fixed first-Boss reward are composed outside AI and damage components; see `loot_drop_system_spec.md` and `weapon_system_spec.md`. No store, upgrade, affix or Chapter II gameplay is present.
