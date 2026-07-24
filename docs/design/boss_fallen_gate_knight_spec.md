# Fallen Gate Knight Boss Specification

Version: 1.0
Last updated: 2026-07-24

## Identity

`Fallen Gate Knight / 堕落门卫骑士` is a 96×96, roughly 1.6× Player-scale Gothic knight with great sword and heavy shield. The generated pixel art is original. Death drops the sword, collapses, and dissolves; no ghost is spawned.

## Shared combat authority

- Body: `HealthComponent`, 18 Health.
- Shield: shared corrected `ShieldComponent`, 6 Health, front-only Player weapon routing, no breaking-hit overflow, stable attacker/id ledger, permanent break.
- Damage: Bash 8, Slash 10, Heavy/Jump Smash 15, Charge 12, Shockwave 8.
- Turn lock: 0.18 s. ShieldBreak: 0.90 s. PhaseTransition: 1.10 s.

## Phase 1 — shielded

`BossIntro → IdleShielded ↔ ApproachShielded → ShieldBash / SwordSlash / HeavyOverhead → GuardRecovery`.

Frontal normal/Dash attacks damage only Shield; rear/center or post-break attacks damage Body. Shield hits play `shield_block`. Shield zero enters `ShieldBreak`, then a one-way `PhaseTransition`.

## Phase 2 — unshielded

`IdleUnshielded ↔ ApproachUnshielded → ComboSlash / JumpSmash / ChargeThrust / ShockwaveStrike → Recovery`.

Phase 2 is faster, never restores Shield, and has no third phase or summons. Each attack owns one stable attack id and frame-bound Hitbox. ComboSlash has two authored steps but remains one Boss attack family, not a Player combo system.

## Animation contract

`idle_shielded`, `walk_shielded`, `shield_block`, `shield_bash`, `sword_slash`, `heavy_overhead`, `hurt_shielded`, `shield_break`, `phase_transition`, `idle_unshielded`, `walk_unshielded`, `combo_slash_1`, `combo_slash_2`, `jump_smash`, `charge_thrust`, `shockwave_strike`, `hurt_unshielded`, `death`.

## Reset contract

`reset_boss()` restores spawn `(6120,596)`, Body 18, Shield 6, Phase 1, collision, Hurtbox, visuals, attack ids/windows, and inactive AI. Player death/respawn invokes this through `BossRoomController`; the defeated instance is retained for deterministic reset rather than freed.
