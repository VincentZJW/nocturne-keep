# Fallen Gate Knight Boss Specification

Version: 1.1
Last updated: 2026-07-24

## Identity

`Fallen Gate Knight / 堕落门卫骑士` is a 96×96, roughly 1.6× Player-scale Gothic knight with great sword and heavy shield. The generated pixel art is original. Death drops the sword, collapses, and dissolves; no ghost is spawned.

## Shared combat authority

- Body: `HealthComponent`, 18 Health.
- Shield: shared corrected `ShieldComponent`, 10 Health, front-only Player weapon routing, no breaking-hit overflow, stable attacker/id ledger, permanent break. A future hard-mode experiment may test 15, but shipping Main remains 10.
- Damage: Bash 8, Slash 10, Heavy/Jump Smash 15, Charge 12, Shockwave 8.
- Turn: 0.07 s reaction + 0.10 s authored animation, 12 px side threshold, 0.12 s post-turn cooldown. ShieldBreak: 0.90 s. PhaseTransition: 1.10 s.

## Phase 1 — shielded

`BossIntro → IdleShielded ↔ ApproachShielded ↔ TurnShielded → ShieldBash / SwordSlash / HeavyOverhead → GuardRecovery`.

Frontal normal/Dash attacks damage only Shield; rear/center or post-break attacks damage Body. Shield hits play `shield_block`. Shield zero enters `ShieldBreak`, then a one-way `PhaseTransition`.

Shield presentation uses four states without duplicating combat authority: 10–8 intact, 7–5 damaged, 4–1 critical, and 0 broken. `ShieldDamageOverlay` listens to the same Shield signal as the HUD; it adds pixel cracks only, while the existing shield-break animation removes the shield. Five frontal Dash Attacks or ten frontal Normal Attacks break a full Shield. The breaking hit never overflows into Body.

## Phase 2 — unshielded

`IdleUnshielded ↔ ApproachUnshielded ↔ TurnUnshielded → ComboSlash / JumpSmash / ChargeThrust / ShockwaveStrike → Recovery`.

Phase 2 is faster, never restores Shield, and has no third phase or summons. Each attack owns one stable attack id and frame-bound Hitbox. ComboSlash has two authored steps but remains one Boss attack family, not a Player combo system.

## Animation contract

`idle_shielded`, `walk_shielded`, `turn_shielded`, `shield_block`, `shield_bash`, `sword_slash`, `heavy_overhead`, `hurt_shielded`, `shield_break`, `phase_transition`, `idle_unshielded`, `walk_unshielded`, `turn_unshielded`, `combo_slash_1`, `combo_slash_2`, `jump_smash`, `charge_thrust`, `shockwave_strike`, `hurt_unshielded`, `death`.

At 60 physics ticks/s, the configured 0.07 + 0.10 sequence completes in 0.1833 s. The reaction cancels if the Player returns to the current front or center tolerance. The authored three-frame turn narrows/twists the torso and draws shield/sword inward before the visual and `FacingRoot` commit together. Commit is deferred to the end of the contact frame, so a hit arriving on that frame still routes against the old facing; the next frame uses the new front.

Turn requests are accepted from shielded/unshielded Idle and Approach plus GuardRecovery/Recovery. Attack windup/active/recovery animation direction is locked until its Recovery state, and ShieldBreak, PhaseTransition, Hurt and Death interrupt or reject turning. The 12 px threshold plus 0.12 s cooldown prevents center-line flip jitter without removing the intended single-hit rear punish window.

## Reset contract

`reset_boss()` restores spawn `(6120,596)`, Body 18, Shield 10, intact Shield overlay, initial left facing, Phase 1, collision, Hurtbox, attack ids/windows, zeroed turn reaction/cooldown, and inactive AI. Player death/respawn invokes this through `BossRoomController`; the defeated instance is retained for deterministic reset rather than freed.
