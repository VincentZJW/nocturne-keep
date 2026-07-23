# Player Death and Respawn Specification

Version: 1.0
Date: 2026-07-23
Status: Single-spawn death presentation and respawn flow implemented

## Scope

This specification covers the current Player-only flow from `HealthComponent.died` through input lockout, body fall, ghost emergence, a 0.50-second ghost pause, cleanup, and respawn at Main's single fixed marker. It does not define enemies, damage sources, checkpoints, post-respawn invulnerability, scene persistence, game over, or save data.

## Composition and ownership

```text
Main
├── World
│   ├── SpawnPoint (Marker2D)
│   └── Player (CharacterBody2D)
│       ├── VisualRoot
│       │   ├── AnimatedSprite2D
│       │   └── DeathEffects
│       │       └── GhostSprite
│       ├── HealthComponent
│       ├── ActionController
│       └── DeathSequence (PlayerDeathSequence)
└── PlayerRespawnController
```

- `HealthComponent` owns bounded Health and emits one guarded `died` signal.
- `Player` owns `LifeState`, input/action lockout, dead-body gravity, and the atomic `respawn_at(position)` reset boundary.
- `PlayerDeathSequence` owns only body/ghost presentation timing and emits `sequence_completed` after cleanup.
- `PlayerRespawnController` owns the current scene's spawn marker selection and calls `Player.respawn_at()` only after `sequence_completed`.
- Health, Stamina, and death HUDs remain signal-driven observers and are not Gameplay data sources.

## Ordered death contract

1. Health reaches zero and emits `died` once.
2. Player enters `LifeState.DEAD`, clears velocity and movement/jump buffers, cancels all Dash/Attack state and buffered actions, and emits `death_state_entered`.
3. `PlayerDeathSequence` starts the locked five-frame `death` animation. Lower-priority movement/action animations cannot replace it.
4. At approximately 0.45 seconds, `death_05` remains as the horizontal corpse. Both daggers are pixels in the body animation and are visibly detached; no RigidBody physics is used.
5. The hooded front-face ghost appears at local offset `(0, 7)`, fades in, and rises 14 pixels over 0.35 seconds.
6. At the top of the rise, the ghost remains visible for exactly 0.50 seconds.
7. The sequence hides the ghost, sets its phase to Idle, and emits `sequence_completed` once.
8. The enabled Main respawn coordinator returns the Player to `World/SpawnPoint`, restores Health/Stamina and control state, resets Camera2D smoothing and Idle presentation, and emits `respawned`.
9. HUD values restore through component signals and the death overlay hides through `Player.respawned`.

Nominal total presentation time is approximately `0.45 + 0.35 + 0.50 = 1.30 seconds`. Respawn is completion-gated; there is no parallel fixed Player timer that can fire early.

## Dead-state rules

- Move, jump, Dash, Attack, action buffering, and Stamina processing remain disabled.
- There is currently no active Hitbox/Hurtbox node. Cancelling `PlayerActionController` and switching away from Attack/Dash animations closes all current reserved attack-window metadata.
- Horizontal velocity is forced to zero. An airborne dead Player continues downward under the existing configured gravity until collision with the floor; it cannot steer.
- Repeated damage at zero Health cannot start a second death sequence or emit another death event.
- Facing remains the facing at death. The front-facing ghost does not flip because it represents a recognizable face rather than directional Gameplay.

## Reset and cleanup contract

`Player.respawn_at()` succeeds only while dead. It resets position, velocity, action state, coyote time, jump input buffer, landing flags, configured air-jump availability, Stamina and its regeneration timer, Health/death guard, life state, Idle animation, and Camera2D smoothing. `Player.respawned` instructs `PlayerDeathSequence` to cancel any remaining tween and restore the hidden/default ghost state.

One sequence may own at most one ghost tween. Sequence generation guards prevent a cancelled or superseded coroutine from emitting a late completion. Temporary presentation is scene-owned and no orphan ghost node is instantiated.

## Current limitations

- Main exposes one fixed test `SpawnPoint`; it is not a checkpoint system.
- Respawn does not reset enemies because no enemy exists yet.
- There is no respawn invulnerability, fade transition, sound, particle system, or separate dagger physics.
- The death overlay and damage button remain development presentation/testing aids.

## Verification

- `tests/player/test_player_death_state.gd`: one-shot death entry, action/input/Stamina lockout, HUD, full presentation completion, and no respawn when the coordinator is disabled.
- `tests/player/test_player_death_presentation.gd`: five-frame flat body, ghost ordering, 14-pixel rise, 0.50-second pause, duplicate prevention, and cleanup.
- `tests/player/test_player_respawn.gd`: two complete presentation-gated death/respawn cycles, spawn position, Health/Stamina/action/jump reset, HUD, camera, and input recovery.
- `tests/tools/validate_player_animation_assets.gd`: source/import dimensions, transparency, palette, uniqueness, 48×48 readability, flat-corpse bounds, ghost partial alpha, and no mipmaps.
