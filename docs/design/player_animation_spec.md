# Player Animation Integration Specification

Version: 1.2 — M1.5 player action prototype
Date: 2026-07-21
Status: M1 locomotion complete; M1.5 double-jump/Dash/Attack prototype complete without combat

## Scope

This document defines the player presentation layer for The Night Warden, its M1 locomotion integration, and the limited M1.5 action prototype. It covers sprite animation resource names, timing, loop behavior, priority arbitration, facing, movement-state selection, debug double jump, ground Dash motion, and Attack animation triggering. It does not implement damage, hitboxes, hurtboxes, invulnerability, combos, enemies, bosses, or production levels.

## Node composition

```text
PreviewRoot (Control)
└── Player (Node2D)
    ├── VisualRoot (Node2D)
    │   └── AnimatedSprite2D
    └── AnimationController (PlayerAnimationController)
```

The controller resolves its `AnimatedSprite2D` through an exported relative `NodePath`. Horizontal facing uses only `AnimatedSprite2D.flip_h`; it does not change `Player`, `VisualRoot`, collision state, or node position.

## SpriteFrames resource

Resource: `res://resources/player/player_sprite_frames.tres`

| Animation | Frames | FPS | Loop | Art status |
| --- | ---: | ---: | :---: | --- |
| `idle` | 4 | 5 | Yes | Production |
| `run` | 6 | 10 | Yes | Production |
| `jump_start` | 2 | 12 | No | M1 production |
| `jump_loop` | 2 | 4 | Yes | M1 production |
| `fall` | 2 | 4 | Yes | M1 production |
| `land` | 2 | 12 | No | M1 production |
| `dash` | 5 | 20 | No | Production |
| `attack` | 6 | 12 | No | Production |
| `hurt` | 3 | 12 | No | Placeholder |
| `death` | 8 | 8 | No | Placeholder |

Only Hurt and Death remain placeholders. Their files live under `assets/sprites/player/assassin/placeholder/`, every filename starts with `placeholder_`, and they must not be treated as approved final animation art.

The original front, side, static Dash, and static Attack images remain byte-identical in `assets/sprites/player/assassin/reference/`.

## Timing contracts

Dash frames are `dash_01` start compression, `dash_02` rear-leg drive, `dash_03` travel core, `dash_04` extension, and `dash_05` recovery. At 20 FPS the first four frames span exactly `0.20 seconds`; frame five is visual recovery outside the planned movement window.

Attack frames are ready, anticipation, lunge, strike, follow-through, and recover. `attack_03` and `attack_04` are reserved as the future hitbox-active window. `PlayerAnimationController.is_attack_hit_window()` exposes this frame query without implementing hitboxes or damage.

## M1 locomotion art contract

- Jump Start: two grounded-baseline frames, moving from a compressed crouch into a clear two-leg push. Both daggers remain close to the body.
- Jump Loop: two compact rising frames with tucked legs and a slightly downward-trailing short mantle.
- Fall: two open descending frames with downward legs, wider arms, and an upward mantle angle.
- Land: two grounded frames, first absorbing impact in a low split stance and then recovering upward.
- Idle remains the approved restrained four-frame breathing loop with fixed feet.
- Run remains the approved six-frame alternating stride; front/rear legs and both dagger directions stay separated.

All six M1 animation groups pass 48×48 nearest-neighbor readability checks. Ground-contact/extended frames use the common visible row `y=60`; airborne articulation occurs inside the same centered 64×64 canvas without changing the sprite node anchor.

## Priority and lock contract

```text
death > hurt > attack > dash > land > jump_start > jump_loop/fall > run > idle
```

- Every one-shot locks ordinary lower-priority requests until `animation_finished`.
- A higher-priority one-shot may interrupt a lower-priority lock.
- `death` remains locked after its final frame; only an explicit reset/respawn call may clear it.
- Re-requesting the currently playing animation returns `false` and never resets frame zero.
- Lower-priority loops cannot replace higher-priority loops by default. A future state machine may pass the explicit priority-release flag after it has authoritatively exited the higher state.
- Locked one-shots always reject lower-priority movement loops regardless of that loop-transition flag.
- One-shot completion emits typed `one_shot_finished(animation_name: StringName)`.
- Godot loop animations use `animation_looped` internally and do not trigger the controller's one-shot completion path.

## Facing contract

- All source art faces right.
- `set_facing_left(true)` sets `flip_h=true`; right sets `flip_h=false`.
- Attack and Dash lock facing for their full one-shot.
- A facing request received during those locks is queued and applied immediately after completion.
- Flipping never changes the sprite node position or its parent transforms.

## M1 Player movement integration

Scene: `res://scenes/player/player.tscn`

```text
Player (CharacterBody2D)
├── VisualRoot
│   └── AnimatedSprite2D
├── CollisionShape2D
├── Camera2D
├── AnimationController
└── ActionController
```

Dedicated input actions:

- `player_move_left`: physical A and Left Arrow.
- `player_move_right`: physical D and Right Arrow.
- `player_jump`: physical Space.

Movement tuning is stored in `player_movement_config.tres`: speed 220, ground acceleration 1400, ground deceleration 1700, air acceleration 850, gravity 1100, jump velocity -420, coyote time 0.10 seconds, and jump buffer 0.12 seconds.

The explicit M1 locomotion FSM owns only `idle`, `run`, `jump_start`, `jump_loop`, `fall`, and `land`:

```text
ground stopped → idle
ground moving → run
accepted jump → jump_start
jump_start finished while rising → jump_loop
vertical velocity >= 0 in air → fall
air-to-floor contact → land
land finished → idle/run according to current input
```

Land may be interrupted immediately by an accepted jump or horizontal movement. The controller prevents per-frame animation restart.

## M1.5 action prototype

Dedicated inputs extend the M1 map:

- `player_dash`: physical Shift.
- `player_attack`: physical J.

### Double jump

- `has_double_jump` defaults to `false` and remains the future formal unlock flag.
- `debug_enable_double_jump` defaults to `true` only for the current trial scene.
- `air_jumps_remaining` is restored to one on landing when either flag enables the capability.
- A ground or coyote-time jump does not consume the air jump. Only a jump after the first-jump coyote window consumes it.
- The shared 0.12-second input buffer feeds both valid ground and air jump paths, but one physics input edge can produce at most one jump.
- `double_jump` is reserved as the future independent animation name. The prototype deliberately resets and replays Jump Start as fallback art; no final double-jump animation is claimed.

### Ground Dash

- Tuning resource: `player_action_prototype_config.tres`.
- Speed 480 px/s; travel window 0.20 seconds; cooldown 0.45 seconds.
- Frames one through four at 20 FPS are the travel window. Frame five is recovery with zero Dash velocity.
- Dash may start only while grounded, blocks ordinary horizontal control for the complete five-frame action, and locks facing until completion.
- Dash has no invulnerability, collision bypass, damage, or hitbox behavior.

### Attack animation trigger

- J requests the existing six-frame, 12 FPS non-looping Attack.
- It locks facing and suppresses locomotion animation requests until all six frames complete.
- Repeated J edges while active are rejected rather than restarting frame one.
- Completion returns to Idle/Run on the ground or the appropriate air loop if the action finished airborne.
- `attack_03` and `attack_04` remain queryable future hit-window metadata only; they have no Gameplay effect.

### Active M1.5 priority

```text
attack > dash > jump/fall/land > run > idle
```

Attack wins if both action inputs arrive on the same physics frame. Once either action starts, the action component rejects the other until completion. Hurt and Death remain available only to the independent animation preview and have no formal Player caller.

## Pixel display and anchor rules

- Every frame is a transparent 64×64 texture.
- Source import uses Lossless compression with mipmaps disabled.
- The project Canvas texture default and preview sprite both use Nearest filtering.
- Preview scale is the integer value 6×.
- Grounded production frames use a common visible ground baseline at source row `y=60`.
- The animation canvas and centered sprite anchor remain fixed; airborne placeholders move pixels within that same canvas.
- The pre-existing Dash core frame was shifted down one pixel to correct its baseline without changing its pose design.

## Controller public API

- `play_loop(animation_name, allow_lower_priority=false) -> bool`
- `play_one_shot(animation_name) -> bool`
- `set_facing_left(facing_left) -> bool`
- `pause()`, `resume()`, `restart_current()`
- `reset_to_idle()` for preview reset and future respawn ownership
- `is_animation_locked()`, `is_facing_locked()`
- `is_attack_hit_window()`
- `one_shot_finished`, `animation_changed`, and `facing_changed` typed signals

The controller owns presentation state only. Movement state, health, damage, hitboxes, and respawn decisions remain external responsibilities.

## Preview usage

Open `scenes/tools/player_animation_preview.tscn` and run the current scene (`F6`). Choose actions with the ten buttons or physical number keys `1` through `0`. The panel displays current animation, current frame, FPS, loop/one-shot mode, direction, locks, placeholder/production status, and the reserved Attack hit-window indicator. Playback can be resumed, paused, restarted, or flipped with dedicated buttons.
