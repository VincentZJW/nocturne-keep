# Fallen Gate Knight Boss Art Bible

## Role

The Fallen Gate Knight is Ravenmourn's ruined threshold made animate: a towering oath-bound knight whose shield still bears the gate's fractured raven crest. He must read as a chapter-ending military monument, not an enlarged normal guard.

## Visual hierarchy

- 96×96 canvas gives the Boss a materially larger on-screen body than 64×64 enemies.
- Phase 1 is shield-led: broad heater shield, layered pauldrons, enclosed funerary helm, controlled sword line.
- Shield damage overlays progress from intact to damaged, critical and broken without obscuring the core pose.
- Phase 2 is sword-led: the shield mass is removed, stance opens, curse-red seams and tattered mantle become more visible.
- Weapon silhouette uses a long, chipped gate sword with a pale steel edge and rust-red core.

## Required action families

| Family | Frames | Art purpose |
|---|---:|---|
| idle/walk shielded | 4 / 6 | guarded weight, shield always readable |
| shield_block / shield_bash | 4 / 5 | defense and close pressure clearly distinct |
| sword_slash / combo_slash_1–2 | 5 each | separate arcs and recovery silhouettes |
| heavy_overhead | 6 | high telegraph, vertical impact |
| charge_thrust | 5 | low forward spear-like sword line |
| jump_smash / shockwave_strike | 6 each | airborne compression and ground impact |
| shield_break / phase_transition | 5 each | irreversible visual state change |
| turn shielded/unshielded | 3 each | readable facing correction |
| hurt shielded/unshielded | 3 each | phase-correct hit reaction |
| death | 7 | loss of oath, collapse, no player-style ghost |

## Phase readability

Shield break uses separate fracture effects plus the existing overlay channel. Phase 2 frames do not paint a complete shield. The larger shoulder silhouette, torn mantle and red curse fissures remain consistent so both phases still read as the same individual.

## Prohibited shortcuts

- No scaled normal-enemy body.
- No single rectangle shield or one-pixel line sword.
- No effect-only impact pose.
- No reused player death/ghost language.
