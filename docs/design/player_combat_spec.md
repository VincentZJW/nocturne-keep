# Player Action/Combat Interface Specification

Version: 0.2 — Dash-chain stamina compatibility
Date: 2026-07-22
Status: presentation and input contract only; no damage system

## Scope boundary

This document names the current Attack-facing interfaces so future combat work can integrate without mixing damage into movement or animation. The delivered prototype contains no Hitbox node, Hurtbox, target memory, damage, health mutation, enemy, Boss, invulnerability, or multi-animation combo tree.

## Basic Attack

- Input Map action: `attack`, bound to physical J.
- Start rule: when no exclusive action is active, J begins `attack` in the same action-dispatch tick. Key release is not required.
- Presentation: four transparent 64×64 frames at 20 FPS, non-looping; total designed duration is 0.20 seconds.
- Effective-pose latency: `attack_02` begins after one 20-FPS frame, approximately 0.05 seconds after accepted input.
- Pose contract: both hands thrust forward together; main/offhand blades are vertically offset and never become a lateral slash.
- Facing remains locked through the action. Locomotion animation cannot override it.
- Attack has no movement impulse in this prototype.

Future metadata-only effective frames are `attack_02` and `attack_03`. A future narrow forward rectangle may query `PlayerAnimationController.is_attack_hit_window()`, mirror with facing, and remain disabled outside those frames. That node and all damage behavior are intentionally absent.

## Repeat input buffer

`PlayerActionPrototypeConfig.attack_buffer_time` is `0.10` seconds. `PlayerActionController` owns:

- `attack_buffered`: a single-entry boolean request;
- `attack_buffer_timer`: remaining lifetime;
- `can_chain_attack()`: true from `attack_03` onward;
- measured time from accepted input to the first effective frame.

An initial J is consumed immediately and is never also stored as a repeat. One later J during Attack fills the empty buffer; further J edges cannot add entries or extend the timer. The request does not restart the current frame. At `attack_03` or natural completion, a live entry is consumed once and authorizes `restart_locked_one_shot("attack")`. Stopping J lets the final complete Attack finish normally.

This is repetition of one basic Attack, not a formal combo tree: there are no branches, damage multipliers, different animations, or target-dependent transitions.

## Dash Attack

- Input paths: same-frame Shift+J, or J within the first 0.18 seconds of an active Ground/Air Dash.
- J-first on an earlier frame is no longer delayed; it begins normal Attack. The current cancellation policy rejects a later Dash until Attack completes.
- Presentation: five frames at 20 FPS, non-looping, approximately 0.25 seconds.
- Movement: 320 px/s for 0.15 seconds, then 0.10 seconds of linear deceleration through `CharacterBody2D.velocity` and `move_and_slide()`.
- Dash Attack does not repeat from the normal Attack buffer and cannot be restarted by repeated J/Shift.
- A legal Dash or same-frame Shift+J spends one 25-point Dash charge. Transitioning that active Dash into Dash Attack never spends a second charge.
- Entering Dash Attack clears any pending Ground Dash request. Shift during Dash Attack cannot restart presentation or queue a follow-up; a later independent Shift may begin a new Dash only after completion.

Future metadata-only effective frames are `dash_attack_03` and `dash_attack_04`. A future hitbox would be longer and narrow, face forward, disable outside the window, and remember targets once per action. None of this future behavior is instantiated now.

## Priority and cancellation

```text
death > hurt > dash_attack > attack > ground_dash/air_dash > locomotion
```

Hurt/Death remain preview-only placeholders. In the current Gameplay prototype:

- locomotion cannot cancel Attack or Dash Attack;
- Dash cannot cancel Attack;
- Attack cannot cancel Dash Attack;
- a legal Attack buffer may repeat only Attack;
- Dash Attack completion restores grounded or airborne locomotion from actual contact state.

Changing these cancellation rules requires a later explicit design decision.

## Stamina boundary

`PlayerStaminaComponent` is a movement-resource dependency, not a combat resolver. Normal Attack, jump, and double jump currently cost zero. Ground Dash and Air Dash each request one 25-point charge at successful start; Dash Attack reuses that paid action. The component exposes value/depleted/insufficient signals and contains no health, damage, target, or invulnerability behavior.

## Diagnostics and acceptance

The optional Main debug HUD can be disabled and reports current Attack frame, buffer flag, remaining buffer time, chain-window state, and measured input-to-`attack_02` time. Automated tests cover immediate dispatch, every four-frame pose, a single early buffer, one-time consumption, four deliberate repeated Attacks, locomotion/facing locks, and the approximately 0.25-second Dash Attack.
