# Fallen Crossbowman / 堕落弩手

Version: 1.1 · 2026-07-24

## Identity and role

A slim cursed archer in dark leather/mail, half-closed head protection, quiver, and medieval crossbow. It creates deliberate ranged approach pressure without a melee fallback.

## Runtime contract

- Enemy scene: `res://scenes/enemies/fallen_crossbowman.tscn`
- Projectile scene: `res://scenes/projectiles/crossbow_bolt.tscn`
- Health 4; patrol/chase 38/48 px/s; detection 280; safe distance 70.
- Aim lasts 0.60 seconds and visibly precedes projectile creation. Shoot spawns one bolt; Reload locks firing for 1.50 seconds.
- Bolt speed 260 px/s, damage 6, lifetime 3 seconds. It hits Player once, ignores enemies/shooter, ray-checks World to prevent thin-wall tunneling, and persists if the shooter dies.
- Inside 70 pixels the Crossbowman retreats toward 105 pixels if ground is safe. Hurt cancels its current cadence; Death falls with the crossbow, dissolves, and creates no ghost.

The shared Crossbowman Config is authoritative: `projectile_damage = 6`, while its inherited generic damage field is kept equal to prevent contradictory inspector/debug values. The bolt scene stores no independent damage default and activates only after initialization.

## Animation resource

`resources/enemies/fallen_crossbowman_sprite_frames.tres`

| Animation | Frames | FPS | Loop |
| --- | ---: | ---: | --- |
| idle / walk | 4 / 6 | 4 / 8 | yes |
| aim / shoot / reload | 4 / 3 / 4 | 6 / 12 / 4 | Aim loops; others do not |
| hurt / death | 3 / 6 | 16.667 / 8 | no |

Source art: `assets/sprites/enemies/fallen_crossbowman/`; bolt art: `assets/sprites/projectiles/crossbow_bolt.png`.

## Manual checks

Confirm Aim is visible against the dark background, bolts do not pass platforms/walls, the platform shooter remains reachable with current Air Dash, and retreat does not step off an edge.
