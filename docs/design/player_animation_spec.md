# Player Animation Integration Specification

Version: 2.0 — Night Warden Stage 1 formal art integration
Date: 2026-07-28
Status: 30-animation, three-weapon formal Player presentation complete; Stage 2 visual QA pending

## Scope

This document defines the player presentation layer for The Night Warden, its M1 locomotion integration, M1.5 actions, approved death presentation, and the animation events consumed by the combat foundation. Stage 1 replaces active block-art sources with one shared 64×64 body model and three baked weapon variants. It adds authored presentation names without changing movement, damage, collision, attack reach, camera, Health or stamina tuning.

Formal source roots:

- `res://shared/assets/player/animations/veilbound/`
- `res://shared/assets/player/animations/ravenfang/`
- `res://shared/assets/player/animations/crimson_masque/`
- `res://shared/assets/player/revival/`
- `res://shared/assets/player/effects/`

The active `SpriteFrames` resources still live at their established resource paths, so chapter and equipment contracts remain compatible. Historical sources under `res://assets/sprites/player/` remain references only and are no longer referenced by active Player frame resources.

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
| `idle` | 4 | 5 | Yes | Stage 1 production |
| `ready_idle` | 4 | 5 | Yes | Stage 1 production |
| `walk` | 6 | 7 | Yes | Stage 1 production |
| `run` | 6 | 10 | Yes | Stage 1 production |
| `turn` | 3 | 12 | No | Stage 1 production |
| `start_move` | 3 | 12 | No | Stage 1 production |
| `stop_move` | 3 | 12 | No | Stage 1 production |
| `jump_start` | 2 | 12 | No | M1 production |
| `jump_rise` | 2 | 4 | Yes | Stage 1 production |
| `jump_loop` | 2 | 4 | Yes | M1 production |
| `jump_apex` | 2 | 6 | Yes | Stage 1 production |
| `fall` | 2 | 4 | Yes | M1 production |
| `double_jump` | 4 | 16 | No | Stage 1 production |
| `land` | 2 | 12 | No | M1 production |
| `dash_start` | 2 | 20 | No | Production |
| `dash_loop` | 3 | 20 | Yes | Production |
| `dash_end` | 2 | 20 | No | Production |
| `air_dash_start` | 2 | 20 | No | Production |
| `air_dash_loop` | 3 | 20 | Yes | Production |
| `air_dash_end` | 2 | 20 | No | Production |
| `attack` | 4 | 20 | No | Runtime alias for current combo step |
| `attack_1` | 4 | 20 | No | Main-hand short diagonal cut |
| `attack_2` | 4 | 20 | No | Off-hand reverse cut |
| `attack_3` | 4 | 20 | No | Crossed dual-dagger finisher |
| `combo_transition` | 2 | 20 | No | Presentation-only bridge |
| `dash_attack` | 5 | 20 | No | Production high-speed dual thrust |
| `hurt` | 3 | 16 | No | Production compatibility alias |
| `hurt_light` | 3 | 16 | No | Stage 1 production |
| `hurt_heavy` | 4 | 12 | No | Stage 1 production |
| `death` | 5 | 11.111 | No | Production horizontal body fall, ~0.45 s |

All 30 entries are formal Stage 1 art. The original front, side, static Dash and static Attack references and deprecated sequences remain preserved under `res://assets/sprites/player/assassin/reference/`, but active resources reference only the shared Stage 1 roots.

## Timing contracts

Ground Dash presentation is deliberately segmented. `dash_start` has two fast compression/drive frames and is used only for the first segment. `dash_loop` has three low, trailing-mantle travel frames and remains locked while 0.18-second motion segments chain. `dash_end` has two extension/recovery frames and plays only when no live paid segment follows. A legal chain therefore remains `dash_start → dash_loop → dash_loop … → dash_end`, with no inserted standing recovery.

Air Dash follows the same chain grammar: two-frame `air_dash_start`, three-frame locked `air_dash_loop`, and two-frame `air_dash_end`, all at 20 FPS. Only the first paid segment uses start; successful continuations remain in loop; the end phase occurs once after chaining stops. The body is horizontal, both feet stay clear of the ground line, both blades remain close and readable, and the mantle trails backward. It avoids the grounded rear-leg push and the Attack's extended paired blades.

Normal Attack keeps the existing four-frame, 20 FPS gameplay timing and the logical animation name `attack`. `PlayerAnimationController.select_attack_variant()` copies the corresponding `attack_1`, `attack_2` or `attack_3` presentation into that logical slot before playback, preserving all existing state, hit-window and test contracts. The three silhouettes are now a main-hand diagonal cut, off-hand reverse cut and crossed dual-dagger finisher. `attack_02/03` remain the effective visual/hit frames; damage and mandatory recovery values are unchanged.

Dash Attack uses one shared ground/air five-frame sequence at 20 FPS: `dash_attack_01` inherits Dash and retracts both elbows, `02` starts paired extension, `03` forms the full arrow-shaped core, `04` holds the narrow thrust, and `05` retracts while movement decelerates. Total presentation time is approximately 0.25 seconds. It has no lateral slash or broad effect arc. `dash_attack_03/04` now drive a separate two-damage narrow Hitbox; presentation still does not own damage calculation.

Death uses five non-looping 64×64 frames at 11.111 FPS, approximately 0.45 seconds total. `death_01` breaks balance while both blades remain near the hands; `death_02` begins the backward fall; `death_03` approaches the floor and visibly separates both daggers; `death_04` reaches a horizontal grounded body; `death_05` is a still, fully horizontal corpse with the longer main dagger in front and shorter off-hand dagger on the opposite side. The final visible baseline is `y=60`, and its wide/low bounds are checked automatically at 64×64 and through nearest-neighbor 48×48 reduction.

The separate `res://shared/assets/player/effects/night_warden_ghost_hooded_face.png` is not a SpriteFrames entry. It is a 64×64 transparent, pale-blue/white hooded front-face texture. `PlayerDeathSequence` keeps the established rise, hold and respawn timing.

The Prologue's `RevivalPlayerArt` now draws eight authored 64×64 unarmed poses from `res://shared/assets/player/revival/` rather than constructing the protagonist from rectangles and lines. Dialogue, pose cue timing, soul-mark timing, camera and dagger-pickup transition remain unchanged.

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
│   ├── AnimatedSprite2D
│   └── DeathEffects
│       └── GhostSprite
├── CollisionShape2D
├── Hurtbox
├── CombatRoot
│   ├── AttackHitbox
│   └── DashAttackHitbox
├── Camera2D
├── AnimationController
├── StaminaComponent
├── ActionController
└── DeathSequence
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
- A legal air jump now plays the four-frame `double_jump` one-shot and emits the existing capability signal. If the resource is unavailable, the controller retains `jump_start` as a defensive fallback. No jump velocity, air-jump count or unlock rule changed.

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
- A J edge only during the 0.15–0.20-second final input window stores at most one next-Attack request for 0.06 seconds. It never restarts frame one at input time; the complete animation is followed by a 0.06-second minimum recovery beat before replay.
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

Same-frame Shift/J and Dash-then-J resolve to Dash Attack. Normal Attack accepts only its bounded one-entry Attack buffer; Dash Attack rejects Attack starts but may hold one Shift follow-up for its completion. Hurt remains preview-only. Death is now entered only through the Player Health death state and is orchestrated by `PlayerDeathSequence`; ordinary locomotion/actions cannot override it.

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

The animation controller owns animation arbitration only. `PlayerDeathSequence` owns death presentation timing, while Player owns life state and the Main-level respawn controller owns the spawn decision. Health, damage, hitboxes, and checkpoint selection remain external responsibilities.

## Preview usage

Open `scenes/tools/player_animation_preview.tscn` and run the current scene (`F6`). Sixteen buttons expose every SpriteFrames entry, including independent Ground and Air `start`, `loop`, and `end` phases. The panel displays current animation, frame, FPS, loop mode, direction, locks, production status, and Attack/Dash Attack metadata windows. Playback can be resumed, paused, restarted, or flipped with dedicated buttons.
