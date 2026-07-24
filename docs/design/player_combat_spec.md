# Player Action/Combat Interface Specification

Version: 0.6 — deliberate basic-Attack cadence
Date: 2026-07-24
Status: Player Attack/Dash Attack and non-lethal Hurt integrated; no combo tree

## Scope boundary

This document defines the Player-facing action interface and its narrow integration with the minimal combat foundation. Damage remains outside movement and animation ownership: `PlayerActionController` opens composed Hitbox nodes only when the presentation controller reports approved effective frames, while `PlayerHurtController` reacts to accepted hostile contacts. The delivered prototype still contains no Boss, armor/status formula, or multi-animation combo tree.

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

`PlayerActionPrototypeConfig` centralizes a `0.15..0.20` second chain-input window, a `0.06` second single-entry buffer, and a `0.06` second minimum recovery beat. `PlayerActionController` owns:

- `attack_buffered`: a single-entry boolean request;
- `attack_buffer_timer`: remaining lifetime;
- `can_chain_attack()`: true only during the final 0.05 seconds of the four-frame Attack;
- `AttackRecovery`: an exclusive 0.06-second beat between completed thrusts;
- measured time from accepted input to the first effective frame.

An initial J is consumed immediately and is never also stored as a repeat. Early repeat edges before 0.15 seconds are intentionally ignored. One J edge inside the 0.15–0.20 window fills the empty buffer; further edges cannot add entries or extend the timer. The current Attack always reaches `attack_04`, then holds one short recovery beat before a live request replays the same one-shot with a fresh attack id. No input can restart frame one from the active window, and no Attack-to-Attack transition can skip the recovery beat. Stopping J lets the final complete Attack and recovery finish normally.

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

Player Hurt is a formal `LifeState.HURT`; Player Death remains higher priority. In the current Gameplay prototype:

- locomotion cannot cancel Attack or Dash Attack;
- Dash cannot cancel Attack;
- Attack cannot cancel Dash Attack;
- a legal Attack buffer may repeat only Attack;
- Dash Attack completion either consumes one legal Dash follow-up from actual contact state or restores grounded/airborne locomotion.
- accepted non-lethal damage cancels Attack, Ground/Air Dash, Dash Attack, their input buffers, and both Player Hitboxes before the 3-frame Hurt animation starts;
- lethal damage enters Death directly and never applies the ordinary Hurt impulse.

Changing these cancellation rules requires a later explicit design decision.

## Hurt reaction and grace window

`PlayerHurtController` owns the focused reaction configuration; `Player` remains responsible for `CharacterBody2D.velocity` and `move_and_slide()`:

- horizontal knockback: 180 px/s away from `HurtboxComponent.hit_received.source_position`;
- vertical knockback: -110 px/s on ground and 70% of that impulse in air;
- 0.16-second hard stun followed by 0.08-second horizontal recovery;
- 0.50-second Hurtbox invulnerability, rejecting even distinct attack ids or simultaneous enemy sources;
- 0.08-second pale-red flash and 0.10-second, 2.5-pixel decaying Camera2D shake;
- reserved `hurt_audio_requested(damage)` signal; no placeholder sound is authored;
- global hit stop is deliberately disabled because this prototype's death/ghost/respawn sequence uses timers that must not be globally frozen.

The production `hurt` animation contains three original 64×64 frames at 16 FPS and is horizontally flipped with the rest of the Player. The old three shifted placeholder frames remain byte-identical under `reference/deprecated_hurt_placeholder/` for audit history.

## Stamina boundary

`PlayerStaminaComponent` is a movement-resource dependency, not a combat resolver. Normal Attack, jump, and double jump currently cost zero. Every successful Ground/Air Dash segment requests one shared 25-point charge; Dash Attack reuses the current paid action, while a post-Dash-Attack Dash pays as a new segment. The component exposes value/depleted/insufficient signals and contains no health, damage, target, or invulnerability behavior. Paid Ground/Air Dash and Dash Attack states block recovery. Zero-cost normal Attack does not: it uses the full grounded rate or reduced airborne rate according to contact.

## Diagnostics and acceptance

The optional Main debug HUD can be disabled and reports current Attack frame, buffers/timers, Dash state, Health/LifeState, invulnerability/stun remaining, last damage/source, and knockback velocity. The dedicated combat room additionally reports both Player hitboxes, the enemy sword window, and its actual configured damage. Automated tests cover the existing action contracts plus grounded/airborne source-derived Hurt, collision-safe wall knockback, action interruption, multi-source invulnerability, animation metadata, and lethal Death precedence.
