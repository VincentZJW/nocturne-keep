# Gray-box Encounter Design Specification

Version: 2.0
Last updated: 2026-07-24
Status: superseded by `first_level_encounter_spec.md`; retained historical detail

## Main composition

F5 Main has been expanded to a 6700-pixel floor (`x=-100..6600`), seven groups, eighteen normal enemies, and a separate Boss room. The authoritative current table is `first_level_encounter_spec.md`.

## Activation contract

- `EncounterGroup` owns one Player-only ActivationArea, an Enemies container, latched activation, and debug counts.
- Every enemy is visible but has AI/detection paused before first entry.
- Activation enables every `EnemyCombatant`; the Player is supplied only when already within that enemy's configured detection range.
- Dead enemies remain removed. No wave, timer, pooling, or random respawn exists.
- Engaged counts also include Gargoyle Track, DiveWindup, Dive, GroundStun, and ReturnToAir.

## Fairness constraints

- Group size normally stays at three or below; Group07 deliberately uses four as the last normal-enemy mastery check.
- Enemies cannot walk off platform edges and do not jump. The platform Crossbowman may target the ground through its explicit 260-pixel vertical tolerance.
- Body contact and friendly fire do no damage. Per-attack memory prevents repeated active-frame damage; Player's 0.50-second invulnerability prevents same-frame multi-source stun lock.
- Group03 isolates Shield Guard routing, Group04 isolates the first Crossbow, and Group05 isolates two Gargoyles before either mechanic joins mixed groups.
- These constraints establish reproducibility, not final difficulty. Group06/07 pressure and the Boss arena require manual playtesting.

## Debug and reset

Main's closable enemy panel reports group activation, engaged/alive/attacking counts, Shield routing, Gargoyle Dive/stun/target/height, and Boss Phase/Body/Shield/state/Hitbox/room fields. Reloading Main resets all seven groups, eighteen normals, and Boss room.

## Manual acceptance

1. Confirm Group01 activates at spawn and later groups remain paused until their boundaries.
2. Verify the Spearman 0.15-second lock in Group02, Shield routing in Group03, and Crossbow 0.18-second aim lock in Group04.
3. Verify Group05 Gargoyles telegraph, hit once, collide with World, expose GroundStun, and return.
4. Judge Group06/07 mixed readability and safe-space separation.
5. Enter the Boss room, verify lock/HUD/checkpoint, both phases, Player-death full reset, Boss-death exit, and level-complete message.

## Exclusions

No elite, second Boss, experience, random encounter, group tactics, formation, shop or second level is included. Chapter I regular-enemy loot and the fixed first-Boss weapon reward are documented separately in `loot_drop_system_spec.md` and `weapon_system_spec.md`.
