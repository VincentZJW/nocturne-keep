# Cursed Shield Guard / 诅咒盾卫

Version: 1.0 · 2026-07-23

## Identity and role

A broad closed-helmet knight with old iron shield, short mace, dark plate, and a restrained red eye slit. It is slower and wider than the Player and converts frontal pressure into a facing/positioning decision.

## Runtime contract

- Scene: `res://scenes/enemies/cursed_shield_guard.tscn`
- Script/config: `cursed_shield_guard.gd` / `cursed_shield_guard_config.tres`
- Health 20; patrol/chase 35/52 px/s; weapon damage 8.
- Frontal normal Attack: consumed by Block, no Health loss, no ordinary Hurt.
- Frontal Dash Attack: consumed and enters 0.60-second GuardBreak. Blocking is disabled during the punish window.
- Back attacks and GuardBreak attacks damage normally. Direction is computed from source x-position versus `FacingRoot.scale.x`; there is no all-direction block.
- Hurt interrupts Attack. Death collapses shield/body together, dissolves, and frees without a ghost.

## Animation resource

`resources/enemies/cursed_shield_guard_sprite_frames.tres`

| Animation | Frames | FPS | Loop |
| --- | ---: | ---: | --- |
| idle / walk | 4 / 6 | 4 / 7 | yes |
| block / guard_break | 3 / 3 | 12 / 8 | no |
| attack | 5 | 10 with configured duration ratios | no |
| hurt / death | 3 / 6 | 16.667 / 8 | no |

Source art: `assets/sprites/enemies/cursed_shield_guard/`.

## Manual checks

Verify both facings, Block readability, Dash GuardBreak feedback, enough space to circle behind, and whether 20 Health is too durable for the short Main route.
