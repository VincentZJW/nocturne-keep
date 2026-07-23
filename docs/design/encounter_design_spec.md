# Gray-box Encounter Design Specification

Version: 1.1
Last updated: 2026-07-23
Status: mixed-roster gray-box; manual feel acceptance pending

## Main composition

F5 Main has a 2600-pixel floor (`x=-100..2500`), about 2.03 reference screens. Nine enemies are staged rather than globally activated:

| Group | Activation center | Saved enemies | Purpose |
| --- | --- | --- | --- |
| 01 | `(430,470)` | Guard `(500,610)`, Shield `(690,610)` | teach sword timing and directional defense |
| 02 | `(850,470)` | Spear `(1030,610)`, Guard `(1170,610)` | long-range spacing and close punish |
| 03 | `(1300,470)` | Crossbow `(1280,396)`, Guard `(1500,610)` | high-platform ranged approach plus ground pressure |
| 04 | `(1840,470)` | Shield `(1940,610)`, Spear `(2160,610)`, Crossbow `(2380,610)` | three-role gray-box stress test |

## Activation contract

- `EncounterGroup` owns one Player-only ActivationArea, an Enemies container, latched activation, and debug counts.
- Every enemy is visible but has AI/detection paused before first entry.
- Activation enables every `EnemyCombatant`; the Player is supplied only when already within that enemy's configured detection range.
- Dead enemies remain removed. No wave, timer, pooling, or random respawn exists.
- Engaged counts include Chase, Attack, Aim, Shoot, Reload, Retreat, Block, GuardBreak, and Hurt.

## Fairness constraints

- Group size never exceeds three; only Group04 uses three roles.
- Enemies cannot walk off platform edges and do not jump. The platform Crossbowman may target the ground through its explicit 260-pixel vertical tolerance.
- Body contact and friendly fire do no damage. Per-attack memory prevents repeated active-frame damage; Player's 0.50-second invulnerability prevents same-frame multi-source stun lock.
- Shield group space permits a back approach. Spear groups have at least 140 pixels of horizontal setup. Crossbow groups have unobstructed horizontal lines and Air-Dash access.
- These constraints establish reproducibility, not final difficulty. Group04 pressure requires manual playtesting.

## Debug and reset

Main's closable enemy panel reports group activation, engaged/alive/attacking counts, and each enemy's type, state, Health, animation, damage, phase, shield state, spear range, reload timer, active bolt count, and x-position. Reloading Main resets all four groups and nine enemies.

## Manual acceptance

1. Confirm only Group01 activates at spawn and later groups remain paused until crossed.
2. Verify frontal Block, Dash GuardBreak, and back damage in Group01.
3. Verify the Spearman telegraph/recovery and point-blank weakness in Group02.
4. Reach the high Crossbowman in Group03 with jump/Air Dash and verify bolts collide with platforms/walls.
5. Judge Group04 readability and escape space with no more than three active actors.

## Exclusions

No flying enemy, elite, Boss, drop, experience, equipment, random encounter, group tactics, formation, or production-room expansion is included.
