# Player Movement Specification

Version: 1.2 — M1.5 fast Attack response
Date: 2026-07-22
Status: implemented prototype; no combat resolution

## Scope

This specification covers the formal M1 locomotion plus the approved M1.5 debug double jump, Ground Dash, horizontal Air Dash, normal Attack, and one buffered Dash Attack transition. It excludes enemies, bosses, damage, Hitbox nodes, hurtboxes, invulnerability, combo trees, and production encounter design.

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
| `attack` | J | Immediate normal Attack or Dash-to-Attack transition request |

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
- Dash Attack input window: 0.18 seconds after Dash starts
- normal Attack input buffer: 0.10 seconds
- Dash Attack speed: 320 px/s
- sustained Dash Attack movement: 0.15 seconds
- linear recovery/deceleration: 0.10 seconds

The movement plus recovery durations total 0.25 seconds, matching five frames at 20 FPS. Speed is intentionally lower than the 480 px/s Dash so the attack inherits momentum without becoming another full Dash.

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
- Ordinary movement presentation cannot overwrite it. J starts immediately, and `attack_02` arrives after one 20-FPS frame (approximately 0.05 seconds).
- One further J may be buffered for 0.10 seconds. It is consumed once at `attack_03` or completion and restarts the same four-frame action; it never resets frame zero immediately when pressed.
- Attack remains uncancellable by Dash in this revision. Frames `attack_02` and `attack_03` are metadata-only reservations for a future narrow forward Hitbox. No Hitbox node or damage logic exists.

## Dash Attack input and state

- Shift alone starts Ground Dash or the one permitted Air Dash.
- J during the first 0.18 seconds of that Dash transitions to `DashAttack`, inherits `dash_direction`, and marks `dash_attack_used=true`.
- Same-frame Shift+J starts Dash Attack directly when the Dash is legal.
- J pressed before Shift starts normal Attack immediately. A later Shift is rejected by the preserved no-Dash-cancel rule; there is no standalone-Attack latency for reverse-order pairing.
- J after the Dash combination window is ignored for Dash Attack and is not leaked into a later action.
- One Dash can transition once. Dash Attack blocks further Dash and Attack starts and rejects frame-zero restart spam.

### Dash Attack movement

- Movement remains inside `CharacterBody2D.velocity` followed by `move_and_slide()`; no global-position warp is used.
- The first 0.15 seconds use 320 px/s along inherited Dash direction. The following 0.10 seconds linearly reduce that velocity to zero.
- Ground completion returns to Run/Idle, or Land if the action contacted the floor from the air.
- Air Dash Attack keeps vertical velocity at zero and suspends gravity only while the one-shot is active. Completion restores gravity and enters Fall unless a real landing occurred.
- Starting or completing Air Dash Attack never restores `air_dash_available`; only actual landing does.

## Action priority and recovery

```text
dash_attack > attack > ground_dash / air_dash > land > jump_start > jump_loop / fall > run > idle
```

- Same-frame Shift/J or J inside an active Dash window resolves to Dash Attack.
- Normal Attack accepts one next-Attack buffer but rejects Dash; Dash Attack mutually excludes ordinary Attack/Dash input.
- Ground Dash recovers to Run or Idle from current input.
- Air Dash recovers to Jump Loop or Fall from vertical state.
- Attack recovers to Run/Idle when grounded or Jump Loop/Fall when airborne.
- Dash Attack preserves its ground/air origin for gravity handling and recovers from actual contact state.

## Acceptance boundaries

Automated tests verify named Input Map bindings, immediate J response, one-entry Attack buffering, repeated complete Attack cycles, same-frame and Dash-first Dash Attack input, late-input rejection, once-per-Dash use, Air Dash preservation, direction/facing, gravity restoration, collision-safe movement, metadata windows, and ground/air recovery. Main's optional debug HUD also displays current Attack frame, buffer state/time, chain readiness, and measured input-to-effective-frame time. Player feel and visual timing still require manual playtesting.
