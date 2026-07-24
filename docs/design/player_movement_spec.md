# Player Movement Specification

Version: 1.4 — continuous Ground/Air Dash with shared stamina
Date: 2026-07-22
Status: implemented prototype; no combat resolution

## Scope

This specification covers M1 locomotion plus the approved M1.5 debug double jump, continuous horizontal Ground/Air Dash, normal Attack, and Dash Attack transitions. It excludes enemies, bosses, damage, Hitbox/Hurtbox nodes, invulnerability, combo trees, and production encounter design.

## Player composition

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

`Player` owns CharacterBody2D physics and locomotion selection. `PlayerActionController` owns action exclusion, edge-triggered buffers, Dash timing/direction, lifecycle signals, and the narrow query that identifies stamina-consuming action states. `PlayerStaminaComponent` alone owns stamina spending and ground/air regeneration rates. `PlayerAnimationController` owns SpriteFrames presentation, priority, locks, and facing.

## Input Map

| Action | Physical keys | Gameplay use |
| --- | --- | --- |
| `player_move_left` | A, Left Arrow | Horizontal input |
| `player_move_right` | D, Right Arrow | Horizontal input |
| `player_jump` | Space | Ground/coyote/air jump request |
| `dash` | Left Shift, Right Shift | Ground or horizontal Air Dash |
| `attack` | J | Immediate Attack or Dash-to-Dash-Attack request |

Gameplay reads named Input Map actions only; there is no physical Shift polling. Every Dash segment requires a new `Input.is_action_just_pressed("dash")` edge, so holding Shift cannot synthesize a chain.

## Tuning

Locomotion values in `resources/player/player_movement_config.tres`:

- move speed 220 px/s; ground acceleration/deceleration 1400/1700 px/s²;
- air acceleration 850 px/s²; gravity 1100 px/s²; jump velocity -420 px/s;
- coyote time 0.10 s; jump buffer 0.12 s.

Action values in `resources/player/player_action_prototype_config.tres`:

- Dash speed 480 px/s; motion duration 0.18 s per paid segment;
- one-entry Dash input buffer 0.10 s; minimum segment interval 0.03 s;
- Dash Attack combination window 0.18 s;
- normal Attack chain window 0.15–0.20 s, buffer 0.06 s, minimum recovery 0.06 s;
- Dash Attack 320 px/s for 0.15 s plus 0.10 s linear recovery.

The removed 0.45-second Dash cooldown is not used. Stamina is the chain limiter.

## Jump and debug double jump

- Ground and coyote jumps do not consume an air jump.
- `has_double_jump` is the formal capability flag and defaults false; `debug_enable_double_jump` is true only for the current trial Player.
- One legal airborne jump consumes `air_jumps_remaining`; a third jump is rejected.
- Landing restores the air jump. Coyote time applies only to the first jump.
- The 0.12-second buffer supports legal ground and air jumps, while one input edge executes at most once.

## Unified Dash contract

- Ground and Air Dash use one state controller, one 100-point stamina pool, and one 25-point cost per successful segment.
- A Dash starts in the current physical domain: grounded becomes `GroundDash`; airborne becomes `AirDash`.
- Horizontal input at segment start selects direction. With no horizontal input, current facing selects it.
- Each accepted segment applies `dash_direction * 480` px/s for 0.18 s through `CharacterBody2D.velocity` and `move_and_slide()`.
- Direction and `AnimatedSprite2D.flip_h` are locked within the segment. For Air Dash, a buffered next segment samples direction again and may reverse.
- A new Shift edge stores at most one request for 0.10 s. A live request at segment end pays 25 stamina and continues immediately. Consumption clears the request.
- Failure to pay clears the buffer and starts the appropriate end phase without spending.
- One held Shift produces one segment. Presentation is never reset per physics frame and collision is never bypassed with direct position mutation.

Full stamina therefore permits any four paid segments: four Ground, four Air, or a mixed total such as two Ground plus two Air.

## Ground Dash

- The first segment presents `dash_start → dash_loop`. Successful continuations stay in the locked looping `dash_loop` and never insert a standing recovery.
- When chaining stops or stamina is insufficient, `dash_end` plays before grounded locomotion resumes.
- Ordinary horizontal control is disabled during Dash; facing remains locked to its direction.

## Continuous horizontal Air Dash

- There is no `air_dash_available`, landing reset, or fixed per-airtime count. Air Dash can chain while rising or falling as long as the shared pool can pay.
- Starting any Air Dash sets vertical velocity to zero. Gravity is suspended during paid motion segments.
- The first segment presents `air_dash_start → air_dash_loop`; legal continuations remain in `air_dash_loop` with no Fall or restart phase between them.
- Each continuation may reselect left/right from that Shift edge. Input cannot turn the current segment.
- When no continuation succeeds, `air_dash_end` plays. Gravity resumes during this short two-frame recovery, then locomotion resolves from actual vertical velocity to Jump Loop or Fall.
- Only horizontal Air Dash exists: no upward, downward, diagonal, invulnerable, or collision-bypassing variant.

## Attack and Dash Attack interaction

- J begins the four-frame, 20 FPS dual-dagger thrust immediately. One later J can buffer one repeat; movement presentation cannot overwrite it.
- Attack remains uncancellable by Dash in this revision.
- J inside the first 0.18 s of Ground/Air Dash transitions to `DashAttack` and inherits direction. Same-frame Shift+J begins a legal direct Dash Attack.
- Transitioning from an already-paid Dash costs nothing extra. A direct Dash Attack costs one Dash charge.
- Entering Dash Attack clears a prior Dash buffer. A new Shift edge during Dash Attack may store exactly one follow-up.
- At Dash Attack completion, a live affordable request starts a new paid GroundDash or AirDash from actual floor contact. This continuation increments the chain number, cannot restart Dash Attack, and cannot restore stamina.

## State and priority

Explicit states are Idle, Run, Jump, DoubleJump, Fall, GroundDash, AirDash, DashAttack, Attack, and Land. Implemented action priority is:

```text
death > hurt > dash_attack > attack > ground_dash / air_dash > land > jump / fall > run > idle
```

Hurt/Death remain preview-only placeholders. Legal transitions include GroundDash→GroundDash, AirDash→AirDash, either Dash→DashAttack, and DashAttack→GroundDash/AirDash based on contact. Stamina failure, held input, locomotion, or repeated J cannot restart an exclusive action.

## Acceptance boundary

Automated coverage verifies Ground/Air four-segment chains, the shared mixed pool, rejected fifth input without spending, held-Shift non-repeat, one-entry buffering, Air direction reselection and within-segment lock, segmented presentation, wall collision, full grounded regeneration, 40% ordinary-air regeneration, paid-action blocking, Dash Attack no-double-charge and follow-up Dash, HUD synchronization, and Main/preview regression. Player feel and route fairness still require manual playtesting.
