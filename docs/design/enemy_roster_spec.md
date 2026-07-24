# Enemy Roster Specification

Version: 1.3
Last updated: 2026-07-24

## Current normal-enemy roster

| Enemy | Role | Body HP | Shield HP | Damage | Range | Windup / active / recovery |
| --- | --- | ---: | ---: | ---: | ---: | --- |
| Cursed Castle Guard | baseline heavy melee | 3 | — | 5 | 46 | 0.35 / 0.10 / 0.45 s |
| Cursed Shield Guard | positional durability | 5 | 3 | 8 | 46 | 0.40 / 0.10 / 0.55 s |
| Decayed Spearman | long linear spacing | 5 | — | 10 | 76 | 0.45 / 0.10 / 0.60 s |
| Fallen Crossbowman | ranged pressure | 4 | — | 6 bolt | 260 | 0.60 Aim / shot / 1.50 Reload |

Player has 100 Health, normal Attack deals 1, and Dash Attack deals 2. Castle Guard, Spearman, and Crossbowman require 3/2, 5/3, and 4/2 normal/Dash hits. Shield Guard rear or post-break Body kills require 5/3 hits. From the front, Shield 3 absorbs the first 3 normal or 2 Dash hits without overflow, so total normal/Dash inputs are 8/5. Shield Guard damage remains 8, so a full-Health Player dies on the 13th hit. These are gray-box values, not final balance.

| Shield Guard route | Normal hits | Dash hits |
| --- | ---: | ---: |
| Break Shield from front | 3 | 2 |
| Kill Body from rear / after break | 5 | 3 |
| Full frontal Shield + Body sequence | 8 | 5 |

The shared enemy Config resources are the sole authored tuning authority. Enemy scenes do not save local `HealthComponent.max_health` or weapon/projectile `Hitbox.damage` copies. At runtime the enemy copies Config Health into its component, and each active attack passes Config damage to the Hitbox. Crossbow bolts remain inactive until `FallenCrossbowmanConfig.projectile_damage` is supplied during initialization.

All four enemies use transparent original 64×64 pixel frames, nearest filtering, no mipmaps, one shared foot baseline, right-facing source art with runtime horizontal flip, common factions, body-contact safety, Hurt interruption, and non-ghost fall/dissolve death.

## Scope boundary

This roster fills the two-normal-enemy product allocation only provisionally for mechanic evaluation; content count must be reconciled before final scope lock. No flying enemy, elite, or Boss is implemented by this batch.
