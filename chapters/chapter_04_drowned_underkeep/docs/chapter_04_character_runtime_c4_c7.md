# Chapter IV Character Runtime — CH4-C4 through CH4-C7

## Scope and authority

This document records the formal runtime implementation of the Chapter IV roster locked in
`chapter_04_character_roster_c0.md`. The project launch authority remains
`res://scenes/bootstrap/main_bootstrap.tscn`; Chapter IV is registered through
`chapter_04_start_profile.tres` and routes to the saved `drowned_underkeep.tscn` Main level.

The current deliverable is a complete character-combat trial embedded in the formal Chapter IV
level. It is not a claim that the complete Chapter IV environment route is finished.

## Runtime roster

| Character | Role | HP | Poise | Primary / Secondary / Special damage |
|---|---|---:|---:|---:|
| Drowned Gaoler | baseline jailer | 104 | 44 | 12 / 11 / 10 |
| Chainbound Convict | slow control bruiser | 152 | 92 | 16 / 19 / 11 |
| Mire Harpooner | long-range tether pressure | 96 | 38 | 13 / 11 / 10 |
| Sunken Shield Penitent | directional shield wall | 132 + 72 shield | 70 | 14 / 14 / 17 |
| Mirefin Raider | fast amphibious flanker | 116 | 50 | 13 / 16 / 14 |
| Bog Toad | heavy leap / mud control | 142 | 76 | 17 / 11 / 13 |
| Sewer Maw | hidden ambush creature | 82 | 26 | 10 / 14 / 8 |
| Underkeep Executioner | elite heavy control | 244 | 126 | 20 / 18 / 23 |

All eight characters use typed `Chapter04EnemyConfig` resources and one bounded Chapter IV
controller. Shared `HealthComponent`, `HitboxComponent`, `HurtboxComponent`, `EncounterGroup`,
`LootDropComponent` and `GroundEnemyBase` contracts remain authoritative. Chapter IV adds only
the local Poise, swept projectile, shield presentation and role action data it requires.

## Pixel production

- Runtime character canvas: 96×96 transparent PNG, nearest-neighbour import, no mipmaps.
- Total normal/elite frames: 544, generated from deliberate low-resolution pixel structures.
- Every role has idle/walk/turn/alert/light-hit/stagger/hurt/death plus its named action phases.
- The shield Penitent owns a separate four-state shield presentation and no-overflow shield
  routing. The Harpooner uses a chapter-local swept projectile instead of a line placeholder.
- Reference sheets live beside each role under `assets/enemies/<role>/reference/`.

## Soul Gaoler Ormund

Ormund uses one 560 HP pool and a real 55% transition at 308 HP.

| Phase | Identity | Mitigation | Poise | Actions |
|---|---|---:|---:|---|
| I — The Last Gaoler | closed helm, intact soul cage, halberd/anchor guard stance | 0.82 | 150 | Halberd Sweep, Chain Anchor Slam, Prison Hook Drag, Floodgate Charge, Soul Cage Pulse |
| II — The Broken Cage | split helm, open soul cage, exposed drowned light, aggressive two-hand key-halberd | 0.72 | 190 | Chainstorm Cleave, Undertow Pull, Drowned Cell Rupture, Soul Shackle, Flooded Judgment |

Boss production uses 192×192 transparent frames: 46 named authored animation groups, 211 PNG
frames, plus the runtime `idle` compatibility alias in the final `SpriteFrames` resource. Phase
II is not a tint: helm, torso cage, stance, grip, cape and weapon silhouette are redrawn.

## Main integration and reproducible routes

The formal Chapter IV level instances `CharacterTrial` at `DrownedUnderkeep/CharacterTrial` and
contains five normal/elite encounter groups plus `OrmundBossEncounter`. The Main player, HUD,
camera and collision runtime are reused; the Boss HUD binds directly to Ormund's health and phase
signals.

Available F5 spawn IDs:

- `CH4_HUMANOID_COMBAT`
- `CH4_CREATURE_COMBAT`
- `CH4_ELITE_TRIAL`
- `CH4_BOSS_PHASE_01`
- `CH4_BOSS_PHASE_02`

Both Boss spawn IDs activate the saved encounter. The Phase II spawn crosses the real 308 HP
threshold and skips only the presentation delay, making phase-specific F5 iteration deterministic.

## Non-goals

- No Player movement, health, stamina or attack values were changed.
- No Chapter I–III enemy or Boss was changed.
- No Chapter IV full-room/environment milestone is claimed here.
- No rewards, final narrative or chapter transition were invented.
