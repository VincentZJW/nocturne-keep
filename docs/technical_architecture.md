# Technical Architecture

Version: 0.1.0 (M0)
Last updated: 2026-07-20

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

No Autoload is needed in M0. Future global services are limited to durable cross-scene concerns such as session state and a small typed event bus. Movement, combat, AI, and encounter behavior remain instanced nodes.

## Signal boundaries

Planned public signals include `health_changed`, `died`, `damage_received`, `checkpoint_activated`, `ability_unlocked`, `boss_phase_changed`, `boss_defeated`, and `game_won`. Every signal will use typed parameters where it carries data.

## Data and saves

- Character and combat values will use custom Resources or explicit exported typed values.
- Session checkpoint state will store checkpoint position, double-jump unlock, defeated key enemies, boss state, and required flow flags.
- Any future disk save must use `user://`; no absolute local path may enter runtime save logic.

## Collision ownership (planned)

Collision layers will be documented before M2 combat implementation. World bodies, actors, hitboxes, hurtboxes, and triggers will use distinct named layers/masks. Overall body collisions will never substitute for hitbox/hurtbox damage resolution.

## Scene flow (planned)

```text
Main Menu → Room 01 → Room 02 ⇄ Room 03 → Boss Arena → Victory
                         ↑ checkpoint   ↑ double jump gate
```

The return from Room 03 to the elevated route in Room 02 is the required light backtracking path.

## Testing layers

1. Headless import and project startup for parser/resource failures.
2. Script-level automated tests for deterministic components.
3. Focused manual scene tests for movement, combat, enemies, and flow.
4. Full playthrough plus visual evidence at M8.
