# Gargoyle Sentinel Specification

Version: 1.0
Last updated: 2026-07-24

## Role and presentation

`GargoyleSentinel / 石像鬼哨兵` is the first airborne normal enemy. Original 64×64 transparent frames use a compact stone torso, angular wings, red eye slit, and horizontal Dive silhouette. It is not a reskinned ground soldier and never creates a Player-style ghost.

## Central tuning

| Property | Value |
| --- | ---: |
| Body Health | 3 |
| Dive damage | 7 |
| Detection | 220 px |
| Hover speed | 45 px/s |
| Dive windup | 0.45 s |
| Final direction lock | 0.15 s |
| Dive speed | 300 px/s |
| GroundStun | 0.65 s |
| Return height | 70 px |
| Cooldown | 1.10 s |

The source of truth is `resources/enemies/gargoyle_sentinel_config.tres`.

## State loop

```text
Dormant → wake → Hover/Track → DiveWindup → Dive
                                      ↓ world impact
                              GroundStun → ReturnToAir → Track
Any living state → Hurt; Health 0 → DeathFall → DeathShatter → cleanup
```

The Dive Hitbox opens once per attack id and deals at most one hit to a target. World collision closes it immediately and creates the 0.65-second grounded counter-window. Return movement goes to the authored hover Y rather than granting a second Dive while grounded.

## Animation contract

`dormant`, `wake`, `hover`, `dive_windup`, `dive`, `ground_stun`, `return_to_air`, `hurt`, `death_fall`, `death_shatter`. All use nearest filtering, no mipmaps, right-facing source art plus `flip_h`.

## Main placement

- Group05: `(3480,270)`, `(3680,270)` — isolated aerial teaching encounter.
- Group07: `(4960,300)` — mixed final normal encounter.
