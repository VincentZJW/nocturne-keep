# 第二章场景与敌人联合设计

Status: Phase 1 room graybox and Phase 2 five-enemy prototypes implemented; formal encounters/Boss remain planned

## Design objective

`Chapter II: The Silent Court / 第二章：沉寂王庭` is a 25–35 minute linear chapter with two short optional branches. Wide combat rooms alternate with narrow connectors and safe rooms. Difficulty comes from mixed combat roles, positional pressure and readable tells rather than inflated health or enemy volume.

The chapter communicates that the court repeats remnants of the Night of the Hollow Bell, the Warden entered these halls seven years ago, the Crown and Veilbound Order cooperated, Elowen recognizes the Warden, and the Chapel of Thirteen Echoes lies deeper inside. It does not reveal the underground-gate motive, Elowen's control state, the complete fourteenth toll ritual, the King's end goal, or the Soul-Pact Mark's final cost.

## Actual project audit

| # | Audited item | Actual state before Stage 1 |
| --- | --- | --- |
| 1 | `run/main_scene` | `res://scenes/cinematics/opening_cinematic.tscn` |
| 2 | Main / Bootstrap | Playable Chapter I is `res://chapters/chapter_01_ravenmourn_outskirts/scenes/level/ravenmourn_outskirts.tscn`; no Bootstrap/router exists. |
| 3 | Debug Chapter Start | `res://scripts/systems/debug_run_config.gd`, `res://scripts/systems/chapter/chapter_registry.gd`, `res://scripts/systems/chapter/chapter_start_profile.gd`. |
| 4 | Current F5 default | Actual F5 still starts Opening. Debug config selects Chapter II but nothing consumes it. |
| 5 | Chapter II Start Profile | No saved `.tres` exists. Only registry metadata exists in code; planned saved path is `res://chapters/chapter_02_silent_court/resources/chapter/chapter_02_start_profile.tres`. |
| 6 | Chapter II main scene | Missing. Registered target is `res://chapters/chapter_02_silent_court/scenes/level/silent_court.tscn`. |
| 7 | Chapter II directory | Missing before this milestone; Stage 1 creates only its six `docs/` files. |
| 8 | Chapter I → II transition | `Main/CastleEntranceTransition` loads only `res://chapters/chapter_01_ravenmourn_outskirts/scenes/transitions/ravenmourn_threshold.tscn`, a static threshold presentation with no Chapter II transition controller. |
| 9 | Formal Player | `res://scenes/player/player.tscn`, `res://scripts/player/player.gd`. It remains shared and is not copied. |
| 10 | Camera | `Player/Camera2D`, local `(0,-105)`, smoothing 7, current Chapter I limits `0..6600`; Boss room controller temporarily replaces horizontal limits. |
| 11 | HUD / Debug HUD | Formal `Main/HUD` CanvasLayer; compact debug `Main/Interface/DebugHudRoot` CanvasLayer root. Main-local NodePaths mean Stage 2 must compose/rebind shared HUD presentation for Silent Court. |
| 12 | Session / Run state | Runtime-only `/root/ChapterSession`, `/root/CurrencyManager`, `/root/WeaponInventory`, `/root/EquipmentManager`; no generic GameSession, RunState or disk save. |
| 13 | Checkpoint | `res://scripts/systems/checkpoint_trigger.gd` updates a scene-local `PlayerRespawnController`. It is reusable if its exported NodePath is set per Chapter II scene. |
| 14 | Encounter controller | `res://scripts/encounters/encounter_group.gd` provides one-shot activation and clear counting. It has no gate ownership/reset policy yet. |
| 15 | Door base | No generic Door base. Existing Catacomb stone door, Castle gate and Boss barrier are specialized. Stage 3 must introduce a small reusable door contract instead of copying one. |
| 16 | Enemy shared base | `EnemyCombatant` contract and `GroundEnemyBase` lifecycle provide targeting, gravity, edges, Hurt, Death and facing. New roles should compose these where appropriate. |
| 17 | Health | `res://scripts/combat/health_component.gd`; bounded integer HP and one-shot `died`. |
| 18 | Loot | `res://scripts/items/loot_drop_component.gd`; health-aware one-roll drops. Stage 5 must reuse it, not copy it. |
| 19 | AttackContext | No `AttackContext` class. `HitboxComponent` currently carries typed damage, faction, attack kind/direction, attacker and attack ID with per-target deduplication. |
| 20 | Collision | Project layers: World 1, PlayerBody 2, EnemyBody 3, PlayerHurtbox 4, EnemyHurtbox 5, PlayerHitbox 6, EnemyHitbox 7, Detection 8, Projectile 9. |
| 21 | Viewport | 1280×720, `canvas_items` stretch, GL Compatibility. |
| 22 | Single jump | Measured rise 83.77 px and horizontal range 153.59 px at current tuning. |
| 23 | Double jump | Measured total rise 167.10 px and horizontal range 281.92 px. |
| 24 | Dash | One motion segment is `480×0.18 = 86.40 px`; single/double jump plus one Air Dash measured 196.59/321.26 px. |
| 25 | Inspector overrides | Main's Player instance overrides position only. The pre-existing dirty action Resource is a Godot UID/default reserialization; no Chapter II override exists. Stage 2 must not serialize old Main-local camera or tuning overrides into Silent Court. |
| 26 | Output / Debugger | Exact Godot 4.7.1 import and Stage 2A/metric tests exit 0 with no red diagnostics. |

## Shared-versus-chapter ownership

Shared assets stay at their current paths: Player, Camera behavior, HUD scripts, session/currency/equipment, respawn/checkpoint base, encounter base, combat components, loot and returning enemies. Chapter II owns room composition, room-local geometry and art, Encounter resources/spawn layouts, narrative triggers, new enemy scenes/data/art and Duchess content.

The Godot Gameplay Scripter composition rule applies: new enemy roles compose Health, Hurtbox, Hitbox and Loot nodes; level flow observes typed signals; no chapter Autoload or monolithic chapter manager will absorb combat behavior.

## Visual language

- Far Background: moonlit vault depth and distant silent courtiers.
- Mid Background: cold stone arches, stained glass, portraits and oxidized gold.
- Playable Geometry: high-contrast cold-gray floors and platforms.
- Props: dark-red carpet, grey banners, tables, black-iron candelabra and broken mirrors.
- Foreground: sparse columns/curtains restricted to screen edges.
- Effects: blue soul fire, blood-candle red, dust and low fog below the actors' feet.

No background or foreground layer may obscure actor silhouettes, weapon tips, tells, platform edges, doors or interaction prompts.

## Enemy-role summary

| Role | HP | Primary pressure | First appearance |
| --- | ---: | --- | --- |
| Hollow Retainer | 48 | fast close pressure | E01 Grey Banner Corridor |
| Court Halberdier | 72 | mid-range horizontal control | E03 corridor exit |
| Mourning Armor | 96 | slow frontal pressure / flank target | E05 Banquet Hall |
| Blood-Candle Acolyte | 60 | rear support and priority target | E09 Chapel entrance |
| Hanging Stalker | 48 | ceiling telegraph and drop punish | E07 Portrait Gallery |

The complete roster, state/interrupt rules and damage values are authoritative in `chapter_02_enemy_roster.md`. The 34-enemy matrix is authoritative in `chapter_02_encounter_matrix.md`.

## Current stage boundary

MainBootstrap and the saved Chapter II profile now load the nine-room Silent Court. Phase 2 adds one acceptance instance of each approved new enemy under `Phase2EnemyPrototypeShowcase`; it does not consume the 15 encounter anchors, populate the 34-enemy matrix, implement returning enemies or create Hollow Duchess behavior. Those boundaries remain explicit future approvals.
