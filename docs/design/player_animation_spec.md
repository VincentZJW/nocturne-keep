# Player Animation Integration Specification

Version: 1.7 — segmented chained Ground/Air Dash
Date: 2026-07-22
Status: M1 locomotion complete; M1.5 Dash/Attack/Dash Attack presentation complete without combat

## Scope

This document defines the player presentation layer for The Night Warden, its M1 locomotion integration, and the limited M1.5 action prototype. It covers sprite animation names, timing, loop behavior, priority arbitration, facing, ground/horizontal air Dash, normal Attack, and the buffered Dash Attack transition. It does not implement damage, Hitbox nodes, hurtboxes, invulnerability, combos, enemies, bosses, or production levels.

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
| `dash_start` | 2 | 20 | No | Production |
| `dash_loop` | 3 | 20 | Yes | Production |
| `dash_end` | 2 | 20 | No | Production |
| `air_dash_start` | 2 | 20 | No | Production |
| `air_dash_loop` | 3 | 20 | Yes | Production |
| `air_dash_end` | 2 | 20 | No | Production |
| `attack` | 4 | 20 | No | Production fast dual-dagger thrust |
| `dash_attack` | 5 | 20 | No | Production high-speed dual thrust |
| `hurt` | 3 | 12 | No | Placeholder |
| `death` | 8 | 8 | No | Placeholder |

Only Hurt and Death remain placeholders. Their files live under `assets/sprites/player/assassin/placeholder/`, every filename starts with `placeholder_`, and they must not be treated as approved final animation art.

The original front, side, static Dash, and static Attack reference images remain byte-identical in `assets/sprites/player/assassin/reference/`. The superseded sideways-slash Attack remains in `reference/deprecated_attack_slash/`. The immediately preceding six-frame thrust sequences remain in their deprecated directories. Replaced five-frame Ground and Air Dash sources are preserved byte-identically in `reference/deprecated_ground_dash_five_frame/` and `reference/deprecated_air_dash_five_frame/`.

## Timing contracts

Ground Dash presentation is deliberately segmented. `dash_start` has two fast compression/drive frames and is used only for the first segment. `dash_loop` has three low, trailing-mantle travel frames and remains locked while 0.18-second motion segments chain. `dash_end` has two extension/recovery frames and plays only when no live paid segment follows. A legal chain therefore remains `dash_start → dash_loop → dash_loop … → dash_end`, with no inserted standing recovery.

Air Dash follows the same chain grammar: two-frame `air_dash_start`, three-frame locked `air_dash_loop`, and two-frame `air_dash_end`, all at 20 FPS. Only the first paid segment uses start; successful continuations remain in loop; the end phase occurs once after chaining stops. The body is horizontal, both feet stay clear of the ground line, both blades remain close and readable, and the mantle trails backward. It avoids the grounded rear-leg push and the Attack's extended paired blades.

Attack is a synchronous four-frame dual-dagger thrust at 20 FPS: `attack_01` is the short compression, `attack_02` snaps both blades into the first core pose, `attack_03` holds maximum extension and opens the repeat window, and `attack_04` retracts quickly. Both blades point forward and remain vertically separated. The designed delay from J to `attack_02` is one 20-FPS frame, approximately 0.05 seconds. `attack_02` and `attack_03` are reserved as the future narrow forward hitbox-active window. `PlayerAnimationController.is_attack_hit_window()` exposes only metadata; there is no Hitbox or damage.

Dash Attack uses one shared ground/air five-frame sequence at 20 FPS: `dash_attack_01` inherits Dash and retracts both elbows, `02` starts paired extension, `03` forms the full arrow-shaped core, `04` holds the narrow thrust, and `05` retracts while movement decelerates. Total presentation time is approximately 0.25 seconds. It has no lateral slash or broad effect arc. `dash_attack_03` and `dash_attack_04` are query-only future hit-window metadata.

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
death > hurt > dash_attack > attack > dash_start/dash_loop/dash_end/air_dash_start/air_dash_loop/air_dash_end > land > jump_start > jump_loop/fall > run > idle
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
- Attack, Dash Attack, and every segmented Ground/Air Dash phase lock facing.
- An Air Dash continuation may authoritatively replace locked facing exactly at its paid segment boundary; ordinary mid-segment facing requests remain queued.
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
├── StaminaComponent
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

- `dash`: physical Left Shift and Right Shift through the Input Map only.
- `attack`: physical J through the Input Map only.

### Double jump

- `has_double_jump` defaults to `false` and remains the future formal unlock flag.
- `debug_enable_double_jump` defaults to `true` only for the current trial scene.
- `air_jumps_remaining` is restored to one on landing when either flag enables the capability.
- A ground or coyote-time jump does not consume the air jump. Only a jump after the first-jump coyote window consumes it.
- The shared 0.12-second input buffer feeds both valid ground and air jump paths, but one physics input edge can produce at most one jump.
- `double_jump` is reserved as the future independent animation name. The prototype deliberately resets and replays Jump Start as fallback art; no final double-jump animation is claimed.

### Ground and air Dash

- Tuning resource: `player_action_prototype_config.tres`.
- Speed 480 px/s; each paid travel segment is 0.18 seconds; the shared Dash buffer is 0.10 seconds and minimum interval is 0.03 seconds.
- The first Ground Dash enters `dash_start`, transitions into locked looping `dash_loop`, and reaches `dash_end` only after chaining stops or stamina is insufficient.
- Ground Dash uses input direction when present, otherwise current facing. It blocks ordinary horizontal control and locks facing until completion.
- Air Dash is horizontal only and may start or continue repeatedly during ascent/fall while shared stamina can pay. There is no per-airtime availability flag.
- The first Air segment enters `air_dash_start`, then locked looping `air_dash_loop`; successful continuations remain in loop and may select a new direction only at the segment boundary. Only final/rejected continuation enters `air_dash_end`.
- Each successful Ground/Air segment spends 25 stamina and accepts exactly one later independent Shift edge. Holding Shift cannot repeat either form.
- Air segment start zeroes vertical velocity and suspends gravity. Gravity resumes during the final end phase; presentation then selects Jump Loop/Fall from actual vertical velocity. Ground completion returns to Idle/Run.
- Dash has no invulnerability, collision bypass, damage, or hitbox behavior.

### Attack animation trigger

- J requests the four-frame, 20 FPS non-looping dual-dagger thrust immediately; it does not wait for key release or for a Dash pairing timer.
- It locks facing and suppresses locomotion animation requests until completion.
- A J edge during Attack stores at most one next-Attack request for 0.10 seconds. It never restarts frame one at input time.
- From `attack_03` onward, a live buffer authorizes `restart_locked_one_shot("attack")`, consumes the buffer once, and starts the same basic Attack again. This is repeat chaining of one action, not a combo tree.
- Completion returns to Idle/Run on the ground or the appropriate air loop if the action finished airborne.
- `attack_02` and `attack_03` remain queryable future hit-window metadata only; they have no Gameplay effect.

### Dash Attack animation trigger

- Ground/Air Dash opens a 0.18-second combination window. J inside it interrupts the Dash presentation with the higher-priority `dash_attack` one-shot.
- Same-frame Shift+J starts Dash Attack directly when Dash is legal. J during the existing 0.18-second Dash window also transitions to Dash Attack.
- J pressed first now starts normal Attack immediately. Because Dash does not cancel Attack, Shift pressed on a later frame does not convert that Attack into Dash Attack.
- A Dash can use this transition only once. Repeated J cannot restart Dash Attack. One new Shift edge may buffer a paid follow-up Dash without restarting its five-frame presentation.
- Ground and Air variants share the same animation in this pass. The action component retains airborne origin so physics can suspend gravity and recover to Fall/Land appropriately.
- On completion, the follow-up becomes Ground or Air Dash from actual contact, uses its stored direction, pays 25, and enters the corresponding start/loop chain. If it cannot pay, locomotion resumes.

### Active M1.5 priority

```text
dash_attack > attack > ground/air dash phases > land > jump_start > jump_loop/fall > run > idle
```

Same-frame Shift/J and Dash-then-J resolve to Dash Attack. Normal Attack accepts only its bounded one-entry Attack buffer; Dash Attack rejects Attack starts but may hold one Shift follow-up for its completion. Hurt and Death remain available only to the independent animation preview and have no formal Player caller.

## Pixel display and anchor rules

- Every frame is a transparent 64×64 texture.
- Source import uses Lossless compression with mipmaps disabled.
- The project Canvas texture default and preview sprite both use Nearest filtering.
- Preview scale is the integer value 6×.
- Grounded production frames use a common visible ground baseline at source row `y=60`; all Air Dash phases keep visible feet above that line within the same canvas.
- The animation canvas and centered sprite anchor remain fixed; airborne production poses move pixels within that same canvas.
- The pre-existing Dash core frame was shifted down one pixel to correct its baseline without changing its pose design.

## Controller public API

- `play_loop(animation_name, allow_lower_priority=false) -> bool`
- `play_one_shot(animation_name) -> bool`
- `restart_locked_one_shot(animation_name) -> bool` for an action-controller-authorized same-animation repeat
- `transition_locked_animation(animation_name) -> bool` for state-authorized segmented Dash presentation
- `set_facing_left(facing_left) -> bool`
- `set_locked_facing_left(facing_left) -> void` for authoritative Air Dash boundary turns
- `pause()`, `resume()`, `restart_current()`
- `reset_to_idle()` for preview reset and future respawn ownership
- `is_animation_locked()`, `is_facing_locked()`
- `is_attack_hit_window()`
- `is_dash_attack_hit_window()`
- `one_shot_finished`, `animation_changed`, and `facing_changed` typed signals

The controller owns presentation state only. Movement state, health, damage, hitboxes, and respawn decisions remain external responsibilities.

## Preview usage

Open `scenes/tools/player_animation_preview.tscn` and run the current scene (`F6`). Sixteen buttons expose every SpriteFrames entry, including independent Ground and Air `start`, `loop`, and `end` phases. The panel displays current animation, frame, FPS, loop mode, direction, locks, production status, and Attack/Dash Attack metadata windows. Playback can be resumed, paused, restarted, or flipped with dedicated buttons.
