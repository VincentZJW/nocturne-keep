# Enemy Roster Specification

Version: 2.0
Last updated: 2026-07-24

## Current normal-enemy roster

| Enemy | Role | Body HP | Shield HP | Damage | Range | Windup / active / recovery |
| --- | --- | ---: | ---: | ---: | ---: | --- |
| Cursed Castle Guard | baseline heavy melee | 30 | — | 5 | 46 | 0.35 / 0.10 / 0.45 s |
| Cursed Shield Guard | positional durability | 50 | 30 | 8 | 46 | 0.40 / 0.10 / 0.55 s |
| Decayed Spearman | long linear spacing | 50 | — | 10 | 76 | 0.45 / 0.10 / 0.60 s |
| Fallen Crossbowman | ranged pressure | 40 | — | 6 bolt | 260 | 0.60 Aim / shot / 1.50 Reload |
| Gargoyle Sentinel | airborne dive / grounded punish | 30 | — | 7 dive | 220 detect | 0.45 windup / Dive / 0.65 stun |

Player has 100 Health; equipped Veilbound Daggers deal 10 normal and 20 Dash damage. Chapter I target Health and shield pools are scaled 10×, preserving Castle/Spear/Crossbow 3/2, 5/3, 4/2 and Shield-front 8/5 hit counts. Shield Guard outgoing damage remains 8. These are gray-box values.

| Shield Guard route | Normal hits | Dash hits |
| --- | ---: | ---: |
| Break Shield from front | 3 | 2 |
| Kill Body from rear / after break | 5 | 3 |
| Full frontal Shield + Body sequence | 8 | 5 |

The shared enemy Config resources are the sole authored tuning authority. Enemy scenes do not save local `HealthComponent.max_health` or weapon/projectile `Hitbox.damage` copies. At runtime the enemy copies Config Health into its component, and each active attack passes Config damage to the Hitbox. Crossbow bolts remain inactive until `FallenCrossbowmanConfig.projectile_damage` is supplied during initialization.

All five enemies use transparent original 64×64 pixel frames, nearest filtering, no mipmaps, right-facing source art with runtime horizontal flip, common factions, body-contact safety, Hurt interruption, and non-ghost fall/dissolve or shatter death. Gargoyle Health 30 means 3 Veilbound normal or 2 Dash attacks; its 7-damage Dive kills a full-Health Player on the 15th hit.

The first-level Boss is tracked separately: Fallen Gate Knight has Body 180, Shield 100, and two phases. Outgoing damage and timings are unchanged. See `boss_fallen_gate_knight_spec.md`.

## Scope boundary

This first-level prototype contains five normal mechanic archetypes plus one Boss, one-roll regular loot, wallet/equipment state and a fixed Boss weapon reward. No store, experience, upgrades, affixes, elite or second Boss are included.
