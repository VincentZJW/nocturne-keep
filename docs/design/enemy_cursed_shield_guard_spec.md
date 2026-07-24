# Cursed Shield Guard / 诅咒盾卫

Version: 1.3 · 2026-07-24

## Identity and role

A broad closed-helmet knight with old iron shield, short mace, dark plate, and a restrained red eye slit. It is slower and wider than the Player and converts frontal pressure into a facing/positioning decision.

## Runtime contract

- Scene: `res://scenes/enemies/cursed_shield_guard.tscn`
- Script/config: `cursed_shield_guard.gd` / `cursed_shield_guard_config.tres`
- Health 7; patrol/chase 35/52 px/s; weapon damage 8.
- Frontal normal Attack: consumed by Block, no Health loss, no ordinary Hurt.
- Frontal Dash Attack while the shield is intact: consumed, permanently marks the shield broken, and enters a 0.70-second GuardBreak. GuardBreak cannot chase, attack, or block; damaging punish hits do not cancel its hard-stun state.
- Back attacks damage normally and a back Dash Attack does not break the shield. After the one-time break, attacks from every direction damage normally and no later state transition can restore Block.
- Direction is computed from source x-position versus `FacingRoot.scale.x`; there is no all-direction block.
- Hurt interrupts Attack. An intact enemy collapses with the shield; a broken enemy uses the shieldless Death variant. Both dissolve and free without a ghost.

## Break feedback and persistent state

- `ShieldBlockComponent.shield_broken` is the logical authority. `set_blocking(true)` is ignored after break, so presentation and AI recovery cannot accidentally restore defense.
- `guard_break_01` shows the intact shield flashing/cracking; frames 02–03 separate it into readable iron/rust fragments; frame 04 holds a larger recoil silhouette with no shield.
- `FacingRoot/ShieldBreakEffect` adds a four-frame pale-steel/amber impact flash and fragment overlay at integer 2× scale. Its four equal frames span the complete 0.70-second GuardBreak window instead of ending after the former 0.33-second flash.
- `VisualRoot/GuardBreakMarker` shows a compact cracked-shield pixel icon above the enemy for the complete hard-stun window. A 0.12-second body highlight reinforces the exact break instant; both cues are hidden on recovery or Death.
- Recovery selects persistent `idle_unshielded`, `walk_unshielded`, `attack_unshielded`, `hurt_unshielded`, and `death_unshielded` frames. The shield therefore never visually reappears before cleanup.
- Expanded Main Enemy Debug reports `STATE`, `BLOCK ON/OFF`, and `SHIELD BROKEN true/false` from the same runtime policy.

## Animation resource

`resources/enemies/cursed_shield_guard_sprite_frames.tres`

| Animation | Frames | FPS | Loop |
| --- | ---: | ---: | --- |
| idle / walk | 4 / 6 | 4 / 7 | yes |
| block / guard_break | 3 / 4 | 12 / 10 with a 0.70 s authored hold | no |
| attack | 5 | 10 with configured duration ratios | no |
| hurt / death | 3 / 6 | 16.667 / 8 | no |
| idle_unshielded / walk_unshielded | 4 / 6 | 4 / 7 | yes |
| attack_unshielded | 5 | 10 with configured duration ratios | no |
| hurt_unshielded / death_unshielded | 3 / 6 | 16.667 / 8 | no |

Break overlay: `resources/enemies/cursed_shield_guard_shield_break_fx_sprite_frames.tres` (4 frames, 5.714 FPS, 0.70 seconds, non-looping, displayed at 2×).

Break marker: `assets/sprites/enemies/cursed_shield_guard/shield_break_fx/broken_shield_marker.png` (20×20, transparent, nearest-neighbor).

Source art: `assets/sprites/enemies/cursed_shield_guard/`.

## Manual checks

Verify both facings, Block readability, one-time Dash GuardBreak feedback, permanent shield absence in every post-break action, enough space to circle behind, and whether seven post-break normal hits/four Dash hits preserve the heavy-defense role without excessive durability.
