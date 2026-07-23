# Player Action/Combat Interface Specification

Version: 0.4 — Castle Guard damage integration
Date: 2026-07-23
Status: Player Attack/Dash Attack hitboxes integrated; no combo tree or invulnerability

## Scope boundary

This document defines the Player-facing action interface and its narrow integration with the minimal combat foundation. Damage remains outside movement and animation ownership: `PlayerActionController` opens composed Hitbox nodes only when the presentation controller reports approved effective frames. The delivered prototype still contains no Player invulnerability, formal Hurt state, Boss, status/attribute damage, or multi-animation combo tree.

## Basic Attack

- Input Map action: `attack`, bound to physical J.
- Start rule: when no exclusive action is active, J begins `attack` in the same action-dispatch tick. Key release is not required.
- Presentation: four transparent 64×64 frames at 20 FPS, non-looping; total designed duration is 0.20 seconds.
- Effective-pose latency: `attack_02` begins after one 20-FPS frame, approximately 0.05 seconds after accepted input.
- Pose contract: both hands thrust forward together; main/offhand blades are vertically offset and never become a lateral slash.
- Facing remains locked through the action. Locomotion animation cannot override it.
- Attack has no movement impulse in this prototype.

`attack_02` and `attack_03` activate the narrow forward `CombatRoot/AttackHitbox` for one point of damage. Each accepted/repeated Attack receives a new attack id; the Hitbox remembers each target once for that id and remains disabled outside those frames. `CombatRoot` mirrors with facing without moving the Player body or Hurtbox.

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
- Entering Dash Attack clears any request buffered before the transition. A new independent Shift edge during Dash Attack stores one follow-up without restarting presentation.
- At completion, a live affordable follow-up starts a new paid Ground Dash or Air Dash according to actual floor contact. It inherits the buffered direction, increments the Dash chain number, and clears the request after one consumption.
- The follow-up costs the normal 25 points; the Dash Attack transition itself still never charges the already-paid current Dash. If stamina is insufficient, the request is cleared and locomotion resumes.

`dash_attack_03` and `dash_attack_04` activate the longer narrow `CombatRoot/DashAttackHitbox` for two points of damage. It faces forward, disables outside the window, and remembers each target once per accepted Dash Attack. It does not repeat from the basic Attack buffer.

## Priority and cancellation

```text
death > hurt > dash_attack > attack > ground_dash/air_dash > locomotion
```

Player Hurt remains presentation-only placeholder art; Player Death is an active Gameplay state. In the current Gameplay prototype:

- locomotion cannot cancel Attack or Dash Attack;
- Dash cannot cancel Attack;
- Attack cannot cancel Dash Attack;
- a legal Attack buffer may repeat only Attack;
- Dash Attack completion either consumes one legal Dash follow-up from actual contact state or restores grounded/airborne locomotion.

Changing these cancellation rules requires a later explicit design decision.

## Stamina boundary

`PlayerStaminaComponent` is a movement-resource dependency, not a combat resolver. Normal Attack, jump, and double jump currently cost zero. Every successful Ground/Air Dash segment requests one shared 25-point charge; Dash Attack reuses the current paid action, while a post-Dash-Attack Dash pays as a new segment. The component exposes value/depleted/insufficient signals and contains no health, damage, target, or invulnerability behavior. Paid Ground/Air Dash and Dash Attack states block recovery. Zero-cost normal Attack does not: it uses the full grounded rate or reduced airborne rate according to contact.

## Diagnostics and acceptance

The optional Main debug HUD can be disabled and reports current Attack frame, both buffer flags/timers, Dash type/number/direction, chain-window state, and measured input-to-`attack_02` time. The dedicated combat room additionally reports both Player hitboxes and the enemy sword window. Automated tests cover immediate dispatch, every four-frame pose, a single early Attack buffer, one-time consumption, four deliberate repeated Attacks, locomotion/facing locks, the approximately 0.25-second Dash Attack, no-double-charge transition, paid Ground/Air Dash follow-up, 1/2-point damage, active-window closure, facing, and per-attack target deduplication.
