# Decayed Spearman / 腐朽长矛兵

Version: 1.0 · 2026-07-23

## Identity and role

A tall, narrow soldier in ruined mail and nasal helmet carrying a readable long spear. Its upright restraint and committed thrust contrast with Player agility and the Castle Guard's heavy cut.

## Runtime contract

- Scene: `res://scenes/enemies/decayed_spearman.tscn`
- Health 10; patrol/chase 42/64 px/s; damage 10; attack range 76 px.
- The forward Hitbox is narrow and long. `attack_thrust_04/05` are the only active frames.
- Windup/active/recovery are 0.45/0.10/0.60 seconds.
- Below 34 pixels it retreats at 32 px/s instead of allowing a misleading point-blank shaft hit.
- It cannot hit behind, sweep, jump, or leave platform edges. Hurt cancels thrust; death drops support, falls, dissolves, and creates no ghost.

## Animation resource

`resources/enemies/decayed_spearman_sprite_frames.tres`

| Animation | Frames | FPS | Loop |
| --- | ---: | ---: | --- |
| idle / walk | 4 / 6 | 4 / 8 | yes |
| attack_thrust | 6 | 10 with configured duration ratios | no |
| hurt / death | 3 / 6 | 16.667 / 8 | no |

Source art: `assets/sprites/enemies/decayed_spearman/`.

## Manual checks

Judge whether the first three anticipation frames clearly expose the threat, whether close-range retreat is exploitable without oscillation, and whether 76 pixels leaves enough jump/Dash response room.
