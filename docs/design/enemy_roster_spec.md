# Enemy Roster Specification

Version: 1.2
Last updated: 2026-07-24

## Current normal-enemy roster

| Enemy | Role | HP | Damage | Range | Windup / active / recovery |
| --- | --- | ---: | ---: | ---: | --- |
| Cursed Castle Guard | baseline heavy melee | 3 | 5 | 46 | 0.35 / 0.10 / 0.45 s |
| Cursed Shield Guard | directional defense | 7 | 8 | 46 | 0.40 / 0.10 / 0.55 s |
| Decayed Spearman | long linear spacing | 5 | 10 | 76 | 0.45 / 0.10 / 0.60 s |
| Fallen Crossbowman | ranged pressure | 4 | 6 bolt | 260 | 0.60 Aim / shot / 1.50 Reload |

Player has 100 Health, normal Attack deals 1, and Dash Attack deals 2. Pure damage math therefore gives normal/Dash kill counts of 3/2, 7/4, 5/3, and 4/2 respectively. A frontal Shield Guard requires a prior Dash Attack to permanently destroy its shield and enter a 0.70-second GuardBreak, so an all-frontal Dash sequence requires at least five inputs: one consumed break plus four damaging hits. The shield never regenerates during that enemy's lifetime. Full-Health Player lethal-hit counts are 20 / 13 / 10 / 17; equivalently the Player survives 19 / 12 / 9 / 16 prior hits. These are gray-box values, not final balance.

The shared enemy Config resources are the sole authored tuning authority. Enemy scenes do not save local `HealthComponent.max_health` or weapon/projectile `Hitbox.damage` copies. At runtime the enemy copies Config Health into its component, and each active attack passes Config damage to the Hitbox. Crossbow bolts remain inactive until `FallenCrossbowmanConfig.projectile_damage` is supplied during initialization.

All four enemies use transparent original 64×64 pixel frames, nearest filtering, no mipmaps, one shared foot baseline, right-facing source art with runtime horizontal flip, common factions, body-contact safety, Hurt interruption, and non-ghost fall/dissolve death.

## Scope boundary

This roster fills the two-normal-enemy product allocation only provisionally for mechanic evaluation; content count must be reconciled before final scope lock. No flying enemy, elite, or Boss is implemented by this batch.
