# Technical Architecture

Version: 0.2.2
Last updated: 2026-08-02

## Goals

- Build a small, completable 2D action prototype without a monolithic game manager.
- Keep combat, movement, health, abilities, encounters, and UI independently testable.
- Use typed signals for local and cross-system events.
- Keep tuning data separate from behavior.

## Planned scene composition

```text
Main / flow root
├── ActiveLevel
│   ├── Room geometry and encounter controllers
│   ├── Player (CharacterBody2D)
│   │   ├── PlayerStateMachine
│   │   ├── HealthComponent
│   │   ├── HurtboxComponent
│   │   ├── AttackHitbox
│   │   └── Camera2D
│   └── Enemies and boss (self-contained scenes)
└── UI (CanvasLayer)
```

This is the target decomposition, not functionality delivered in M0.

## Responsibilities

| Area | Planned responsibility |
| --- | --- |
| `scripts/player/` | Player controller and explicit finite state machine |
| `scripts/combat/` | Damage data, hitbox, hurtbox, health, invulnerability |
| `scripts/enemies/` | Shared enemy contracts and distinct enemy behavior |
| `scripts/bosses/` | Boss state/attack selection and phase rules |
| `scripts/systems/` | Session checkpoint and ability progression services |
| `scripts/core/` | Narrow scene/game flow coordination |
| `scripts/ui/` | Menus, HUD, prompts, and flow screens |
| `resources/` | Tunable player, enemy, and boss data |

## Global state policy

M0 required no Autoload. The current project now uses narrow Autoloads only for genuine cross-scene concerns: `ChapterSession` for process-lifetime progression/story flags, `DebugRunConfig` for guarded development routing, `SceneTransitionManager` for fade-backed scene replacement, and the existing currency/inventory/equipment services. Movement, combat, AI, encounters, Player/HUD composition and presentation remain instanced nodes.

`SceneTransitionManager` resolves chapter targets through `ChapterRegistry`, records the pending chapter/spawn in `ChapterSession`, fades, and replaces the active PackedScene. It does not own Player state or chapter gameplay. `ChapterSession` remains the runtime authority; W3's `PlayerProgressSaveService` serializes only permanent weapon ownership/equipment and a minimum recovery snapshot to `user://`. It does not own or poll gameplay.

`PlayerProgressSaveService` starts disabled. `MainBootstrap` explicitly selects one lifetime: Debug starts keep persistence disabled, while formal New Game clears the prior file, resets runtime state and enables autosave. Loading is an explicit validated API reserved for a future Continue/title flow, so default F5 semantics remain New Game rather than silently resuming.

## Signal boundaries

Planned public signals include `health_changed`, `died`, `damage_received`, `checkpoint_activated`, `ability_unlocked`, `boss_phase_changed`, `boss_defeated`, and `game_won`. Every signal will use typed parameters where it carries data.

## Data and saves

- Character and combat values will use custom Resources or explicit exported typed values.
- Session checkpoint state will store checkpoint position, double-jump unlock, defeated key enemies, boss state, and required flow flags.
- W3 weapon-progress saves use versioned JSON at `user://player_progress_v1.json`; no absolute local path enters runtime save logic.
- The save contains sorted unique owned weapon IDs, equipped ID and selected ChapterSession recovery fields. Currency, Health, live Boss state and Debug profiles are intentionally excluded.
- Every loaded weapon ID is checked against `EquipmentManager` before runtime mutation; the equipped ID must be owned.

## Collision ownership (planned)

Collision layers will be documented before M2 combat implementation. World bodies, actors, hitboxes, hurtboxes, and triggers will use distinct named layers/masks. Overall body collisions will never substitute for hitbox/hurtbox damage resolution.

## Current chapter flow

```text
MainBootstrap
├── Formal: Opening → Veilbound Catacomb → Chapter I → Chapter II
└── Guarded Debug: ChapterStartProfile → selected chapter/spawn

Chapter II Silent Ballroom
→ fixed Crimson Masque WeaponPickup / WeaponInventory / EquipmentManager
→ Royal Chapel Passage
→ Chapter III Chapel Vestibule entry placeholder
```

Every chapter destination composes one shared gameplay runtime instance. Cross-scene travel never moves Player by absolute global coordinates and never duplicates Player, HUD or session services.

Weapon acquisition remains composed rather than chapter-local: WeaponData owns immutable tuning/presentation, WeaponInventory owns unique run-lifetime ids, EquipmentManager owns the equipped id and damage resolution, PlayerWeaponVisual swaps one complete SpriteFrames resource, and the HUD observes typed equipment signals. Chapter III Start Profile applies required ownership and equipped weapon through this same chain.

## Chapter III authored encounters

Chapter III normal-enemy distribution is resource-driven and deterministic. Nine
`Chapter03RoomDefinition` Resources own fixed visual composition, platforms, room
transitions and one `Chapter03EncounterManifest`. Each manifest owns bounded
EncounterGroups and typed `Chapter03EnemySpawnData` entries. The development-only
generator uses seed `31372026` and saves the result; runtime never rerolls positions.

`Chapter03RoomTransitionController` keeps one room under `RoomHost`, while
`Chapter03EncounterSpawner` instantiates the saved manifest. Each EncounterGroup
begins disabled and enables process, physics processing and AI only when its local
ActivationArea is entered. Cross-room pursuit, infinite respawning and whole-chapter
AI processing are therefore excluded by composition rather than global flags.

## Testing layers

1. Headless import and project startup for parser/resource failures.
2. Script-level automated tests for deterministic components.
3. Focused manual scene tests for movement, combat, enemies, and flow.
4. Full playthrough plus visual evidence at M8.
