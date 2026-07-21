# Player Animation Integration Specification

Version: 1.0
Date: 2026-07-21
Status: SpriteFrames and presentation controller complete; gameplay integration not started

## Scope

This document defines the player presentation layer for The Night Warden. It covers sprite animation resource names, timing, loop behavior, priority arbitration, facing, and preview controls. It does not implement movement, collision, health, damage, combos, enemies, levels, or formal gameplay state transitions.

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
| `jump_start` | 2 | 12 | No | Placeholder |
| `jump_loop` | 2 | 4 | Yes | Placeholder |
| `fall` | 2 | 4 | Yes | Placeholder |
| `land` | 2 | 12 | No | Placeholder |
| `dash` | 5 | 20 | No | Production |
| `attack` | 6 | 12 | No | Production |
| `hurt` | 3 | 12 | No | Placeholder |
| `death` | 8 | 8 | No | Placeholder |

Placeholder files live only under `assets/sprites/player/assassin/placeholder/` and every filename starts with `placeholder_`. They reuse shifted production silhouettes only to exercise timing and integration and must not be treated as approved final animation art.

The original front, side, static Dash, and static Attack images remain byte-identical in `assets/sprites/player/assassin/reference/`.

## Timing contracts

Dash frames are `dash_01` start compression, `dash_02` rear-leg drive, `dash_03` travel core, `dash_04` extension, and `dash_05` recovery. At 20 FPS the first four frames span exactly `0.20 seconds`; frame five is visual recovery outside the planned movement window.

Attack frames are ready, anticipation, lunge, strike, follow-through, and recover. `attack_03` and `attack_04` are reserved as the future hitbox-active window. `PlayerAnimationController.is_attack_hit_window()` exposes this frame query without implementing hitboxes or damage.

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
