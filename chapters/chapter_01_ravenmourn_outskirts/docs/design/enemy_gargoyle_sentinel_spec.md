# Gargoyle Sentinel Specification

Version: 1.2
Last updated: 2026-08-05

## Role and presentation

`GargoyleSentinel / 石像鬼哨兵` is the first airborne normal enemy. Its rebuilt original 64×64 transparent frames use a hunched masonry torso, horned and heavy-browed head, broad membrane bat wings, separate claws, pointed tail, gray stone planes, old green verdigris and sparse pale cracks. The restrained red eye remains a curse accent. It is a medieval Gothic stone beast rather than an insect/fly silhouette, is not a reskinned ground soldier, and never creates a Player-style ghost.

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

### Top-limit recovery contract

Chapter I retains its formal `WorldBounds2D` (`Rect2(0, 0, 6800, 720)`) and
56-pixel flight margin, so the playable flight top is world Y 56. Reaching that
top while moving upward is an explicit event rather than a velocity-only clamp:

```text
upward state + flight_top_reached
→ close DiveHitbox and clear the invalid attack
→ ReturnToPlayableAltitude (fixed, legal return_target)
→ original Hover Anchor
→ HoverRecover (0.70 s)
→ reacquire overlapping Player
→ Track/Hover + existing 1.10 s attack cooldown
```

`return_target` is captured when return begins and is never recomputed from the
Player during the return. Its Y is clamped between the safe flight top and the
room bottom minus the 96-pixel minimum hover height. If the authored home anchor
is already legal, that exact anchor wins. `flight_top_reached` is latched once
per recovery, closes the active attack window, and cannot repeatedly transition
at the ceiling. AI disable/re-enable (checkpoint reset or room re-entry) clears
the latch, attack id, transient timers and velocity while preserving the legal
home anchor.

The formal Main debug route `CH1_GARGOYLE_HEIGHT_TEST` spawns the Player at
`World/GargoyleHeightTestSpawn` and exercises the saved
`World/Encounters/ForestEncounter03/Enemies/ForestGargoyle01`. Debug output
exposes state, top Y, fixed return target, attack-cycle count and ceiling count.
The deterministic regression performs ten consecutive ceiling recoveries,
Player leave/re-enter reacquisition, Hurt recovery and AI reset/re-entry without
removing the world ceiling or teleporting over normal return movement.

The Dive Hitbox opens once per attack id and deals at most one hit to a target. World collision closes it immediately and creates the 0.65-second grounded counter-window. Return movement goes to the authored hover Y rather than granting a second Dive while grounded.

## Animation contract

`dormant`, `wake`, `hover`, `dive_windup`, `dive`, `ground_stun`, `return_to_air`, `hurt`, `death_fall`, `death_shatter`. All use nearest filtering, no mipmaps, right-facing source art plus `flip_h`.

- `dormant` folds the stone wing around a crouched perch silhouette; `wake` unfolds it in four stages.
- `hover` uses broad up/mid/down bat-wing shapes around the compact torso rather than thin insect limbs.
- `dive_windup` raises and spreads the wings; `dive` compresses into a horizontal horned stone predator with swept membrane, forward claws and trailing tail.
- `ground_stun` visibly collapses the wing and body onto the surface; `return_to_air` reopens the wings.
- `hurt`, five-frame fall and five-frame stone-fragment shatter retain the existing AI/death timing and no-ghost contract.

Production frames remain under `assets/sprites/enemies/gargoyle_sentinel/<animation>/`. The replaced fly-like presentation is retained only for visual audit under `assets/sprites/enemies/gargoyle_sentinel/reference/deprecated_v1/` and is excluded from production SpriteFrames/asset counts.

## Main placement

- Group05: `(3500,402)`, `(3620,402)` — isolated aerial teaching encounter, 90 px above the repaired y=492 reachable perch.
- Group07: `(4960,300)` — mixed final normal encounter.

Saved Main instance paths are `Main/World/Encounters/EncounterGroup05/Enemies/GargoyleSentinel01`, `.../GargoyleSentinel02`, and `Main/World/Encounters/EncounterGroup07/Enemies/GargoyleSentinel03`. All three instance `res://shared/scenes/enemies/gargoyle_sentinel.tscn` and the same `res://shared/resources/enemies/gargoyle_sentinel_sprite_frames.tres`; there is no legacy runtime instance.
