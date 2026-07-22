# Player Movement Specification

Version: 1.0 — M1.5 air Dash revision
Date: 2026-07-22
Status: implemented prototype; no combat resolution

## Scope

This specification covers the formal M1 locomotion plus the approved M1.5 debug double jump, Ground Dash, horizontal Air Dash, and animation-only Attack trigger. It excludes enemies, bosses, damage, hitboxes, hurtboxes, invulnerability, combos, and production encounter design.

## Player composition

```text
Player (CharacterBody2D)
├── VisualRoot
│   └── AnimatedSprite2D
├── CollisionShape2D
├── Camera2D
├── AnimationController
└── ActionController
```

`Player` owns CharacterBody2D physics and locomotion selection. `PlayerActionController` owns only action mutual exclusion, Dash timing/direction/cooldown, and action lifecycle signals. `PlayerAnimationController` owns only SpriteFrames presentation, priority, one-shot locks, and facing locks.

## Input Map

| Action | Physical keys | Gameplay use |
| --- | --- | --- |
| `player_move_left` | A, Left Arrow | Horizontal input |
| `player_move_right` | D, Right Arrow | Horizontal input |
| `player_jump` | Space | Ground/coyote/air jump request |
| `dash` | Left Shift, Right Shift | Ground or horizontal Air Dash |
| `player_attack` | J | Animation-only Attack |

Gameplay reads named Input Map actions. It contains no direct Shift key polling.

## Locomotion parameters

Movement values live in `res://resources/player/player_movement_config.tres`:

- maximum horizontal speed: 220 px/s
- ground acceleration: 1400 px/s²
- ground deceleration: 1700 px/s²
- air acceleration: 850 px/s²
- gravity: 1100 px/s²
- jump velocity: -420 px/s
- coyote time: 0.10 seconds
- jump input buffer: 0.12 seconds

Dash values live in `res://resources/player/player_action_prototype_config.tres`:

- Dash speed: 480 px/s
- motion duration: 0.20 seconds
- shared cooldown: 0.45 seconds

## Jump and debug double jump

- Ground and coyote jumps do not consume an air jump.
- `has_double_jump` is the formal capability flag and defaults to `false`.
- `debug_enable_double_jump` defaults to `true` only in the current trial Player scene.
- One legal airborne jump consumes `air_jumps_remaining`; a third jump is rejected.
- Landing restores the available air jump. Coyote time applies only to the ground jump and cannot restore airborne abilities.
- The same 0.12-second buffer supports a legal ground or air jump, while one input edge can execute at most one jump.

## Ground Dash

- Ground Dash starts only while grounded and plays `ground_dash`.
- With horizontal input, direction follows input; without input, it follows current facing.
- Ordinary horizontal control is disabled for the one-shot and facing is locked.
- The first four 20-FPS frames apply 480 px/s motion for 0.20 seconds. Frame five is recovery.
- Ground Dash does not consume `air_dash_available`.

## Horizontal Air Dash

- `air_dash_available` begins true and permits one Air Dash in an airborne cycle.
- Rising and falling states can start `air_dash`; no upward, downward, or diagonal variants exist.
- Input direction wins; otherwise current facing determines `dash_direction`.
- Start sets `velocity.y` to zero. Vertical velocity remains zero and gravity is suspended throughout the Air Dash one-shot.
- Starting consumes `air_dash_available` immediately. Repeated Shift edges cannot restart the action or grant another Air Dash.
- Landing reliably resets availability. Coyote time never resets it.
- Ground and Air Dash share the same 0.45-second cooldown.
- On completion, normal gravity resumes and animation selection uses actual vertical velocity, entering Jump Loop if rising or Fall otherwise.

## Attack prototype

- J plays one complete dual-dagger lunging-thrust animation and locks facing.
- It has no movement impulse, so it cannot become a second Dash and cannot bypass collision.
- Ordinary movement presentation cannot overwrite it; repeated J does not restart frame zero.
- Frames `attack_03` and `attack_04` are metadata-only reservations for a future narrow forward Hitbox. No Hitbox node or damage logic exists in this milestone.

## Action priority and recovery

```text
attack > ground_dash / air_dash > land > jump_start > jump_loop / fall > run > idle
```

- Attack wins simultaneous Attack/Dash input.
- Attack and Dash mutually exclude each other while active.
- Ground Dash recovers to Run or Idle from current input.
- Air Dash recovers to Jump Loop or Fall from vertical state.
- Attack recovers to Run/Idle when grounded or Jump Loop/Fall when airborne.

## Acceptance boundaries

Automated tests verify named Input Map bindings, one Air Dash per airborne cycle, landing reset, rising/falling starts, direction fallback, vertical freeze, gravity restoration, shared cooldown, facing lock, action non-restart, and correct animation recovery. Player feel and visual timing still require manual playtesting in `res://scenes/main/main.tscn`.
