# Enemy Roster Specification

Version: 1.0
Last updated: 2026-07-23

## Current normal-enemy roster

| Enemy | Role | HP | Damage | Range | Windup / active / recovery |
| --- | --- | ---: | ---: | ---: | --- |
| Cursed Castle Guard | baseline heavy melee | 3 | 5 | 46 | 0.35 / 0.10 / 0.45 s |
| Cursed Shield Guard | directional defense | 20 | 8 | 46 | 0.40 / 0.10 / 0.55 s |
| Decayed Spearman | long linear spacing | 10 | 10 | 76 | 0.45 / 0.10 / 0.60 s |
| Fallen Crossbowman | ranged pressure | 5 | 4 bolt | 260 | 0.60 Aim / shot / 1.50 Reload |

Player has 100 Health, normal Attack deals 1, and Dash Attack deals 2. Pure damage math therefore gives normal/Dash kill counts of 3/2, 20/10, 10/5, and 5/3 respectively. A frontal Shield Guard requires a prior Dash Attack GuardBreak, so its practical frontal Dash sequence is at least 11 inputs unless the Player attacks from behind or during an existing break. Full-Health Player lethal-hit counts are 20 / 13 / 10 / 25. These are gray-box values, not final balance.

All four enemies use transparent original 64×64 pixel frames, nearest filtering, no mipmaps, one shared foot baseline, right-facing source art with runtime horizontal flip, common factions, body-contact safety, Hurt interruption, and non-ghost fall/dissolve death.

## Scope boundary

This roster fills the two-normal-enemy product allocation only provisionally for mechanic evaluation; content count must be reconciled before final scope lock. No flying enemy, elite, or Boss is implemented by this batch.
