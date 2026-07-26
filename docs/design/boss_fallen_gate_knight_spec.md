# Fallen Gate Knight Boss Specification

Version: 1.3
Last updated: 2026-07-26

## Identity

`Fallen Gate Knight / 堕落门卫骑士` is a 96×96, roughly 1.6× Player-scale Gothic knight with great sword and heavy shield. The generated pixel art is original. Death drops the sword, collapses, and dissolves; no ghost is spawned.

## Shared combat authority

- Body: `HealthComponent`, 180 Health.
- Shield: shared corrected `ShieldComponent`, 100 Health, front-only Player weapon routing, no breaking-hit overflow, stable attacker/id ledger, permanent break.
- Damage: Bash 8, Slash 10, Heavy/Jump Smash 15, Charge 12, Shockwave 8.
- Turn: 0.25 s reaction + 0.65 s authored animation, 12 px side threshold, 0.14 s post-turn cooldown. The old 0.44–0.56-second target is superseded; fixed-step total is 0.9000 s. ShieldBreak: 0.90 s. PhaseTransition: 1.10 s.
- Post-attack cadence is per skill and measured from active Hitbox close to the next windup, not appended after the full animation. Attack damage, Body/Shield, skills, phases, base movement and bridge bounds are unchanged.

## Phase 1 — shielded

`BossIntro → IdleShielded ↔ ApproachShielded ↔ TurnShielded → ShieldBash / SwordSlash / HeavyOverhead → GuardRecovery`.

Frontal normal/Dash attacks damage only Shield; rear/center or post-break attacks damage Body. Shield hits play `shield_block`. Shield zero enters `ShieldBreak`, then a one-way `PhaseTransition`.

Shield presentation uses ratio bands without duplicating combat authority: above 80% intact, 51–80% damaged, 1–50% critical, and 0 broken. `ShieldDamageOverlay` listens to the same Shield signal as the HUD; it adds pixel cracks only, while the existing shield-break animation removes the shield. With Veilbound Daggers, five frontal Dash Attacks or ten frontal Normal Attacks break a full Shield. The breaking hit never overflows into Body.

## Phase 2 — unshielded

`IdleUnshielded ↔ ApproachUnshielded ↔ TurnUnshielded → ComboSlash / JumpSmash / ChargeThrust / ShockwaveStrike → Recovery`.

Phase 2 is faster, never restores Shield, and has no third phase or summons. Each attack owns one stable attack id and frame-bound Hitbox. ComboSlash has two authored steps but remains one Boss attack family, not a Player combo system.

## Animation contract

`idle_shielded`, `walk_shielded`, `turn_shielded`, `shield_block`, `shield_bash`, `sword_slash`, `heavy_overhead`, `hurt_shielded`, `shield_break`, `phase_transition`, `idle_unshielded`, `walk_unshielded`, `turn_unshielded`, `combo_slash_1`, `combo_slash_2`, `jump_smash`, `charge_thrust`, `shockwave_strike`, `hurt_unshielded`, `death`.

At 60 physics ticks/s, the configured 0.25 + 0.65 sequence completes in 0.9000 s. The reaction cancels if the Player returns to the current front or center tolerance. The existing three-frame authored turn is runtime-scaled to exactly the 0.65-second animation stage; it narrows/twists the torso and draws shield/sword inward before visual and `FacingRoot` commit together near the end. Commit is deferred to the end of the contact frame. `ShieldComponent` also stores source/Boss position, facing and timestamp at resolution, so a same-frame hit keeps the old rear route and the next contact uses the new front.

Turn requests are accepted from shielded/unshielded Idle and Approach plus GuardRecovery/Recovery. Attack windup/active direction is locked until Recovery; ShieldBreak, PhaseTransition and Death reject turning. The 12 px threshold plus 0.14 s cooldown prevents center-line jitter. Light or heavy feedback cannot restart, pause, shorten or cancel an active Turn. The Attack Gap continues to count during turning, but another windup waits for the turn commit. The 0.90-second response makes one rear Normal stable, a precise second possible and a third unavailable in the deterministic 20-trial timing matrix.

Normal Player hits use a 0.32-second lightweight feedback cooldown and never cancel AI, a chosen attack, Turn, Attack Gap, windup or active frames. Dash hits use a 0.50-second heavy-feedback cooldown; only neutral Idle, Approach and normal Recovery can become the 0.12-second Hurt reaction. Turn, the seven Boss attacks, ShieldBreak, PhaseTransition and Death are light/heavy uninterruptible. Recovery Hurt returns to the still-running Attack Gap instead of skipping it. Shield-side hits preserve the same routing/overflow rules and use feedback without body Hurt. `reset_boss()` clears both reaction cooldowns, Turn and Attack-Gap measurement state.

## Post-active counter window

The timer begins on the transition out of the final active frame. Animation follow-through and Turn consume the same timer concurrently, so these values are the complete action-right window rather than extra idle appended to an animation.

| Attack family | Configured gap | Measured at 60 Hz | Phase |
| --- | ---: | ---: | ---: |
| Shield Bash | 0.98 s | 0.983 s | 1 |
| Sword Slash | 1.05 s | 1.050 s | 1 |
| Heavy Overhead | 1.20 s | 1.200 s | 1 |
| Combo Slash, after step 2 only | 1.05 s | 1.050 s | 2 |
| Charge Thrust | 1.12 s | 1.133 s | 2 |
| Jump Smash | 1.16 s | 1.167 s | 2 |
| Shockwave Strike | 1.10 s | 1.100 s | 2 |

Recovery permits 50% movement only when distance adjustment is needed. It cannot begin a new attack early, and a Turn takes priority if the Player crosses behind. The Player timing baseline remains Normal unlock 0.320 s, Normal+reverse-Dash travel 0.500 s, Normal+48 px ground escape 0.620 s and Dash Attack+reverse-Dash travel 0.447 s. All seven gaps passed five deterministic attempts for Dash Attack→reverse Dash and Normal→reverse Dash; Shield Bash, Sword Slash and Heavy Overhead also passed five Normal→48 px movement attempts. A complete three-hit Player chain plus escape exceeds every gap.

## Pressure pass

The pass shortens existing tells by about 8–10%, not by deleting anticipation frames. All effective-frame indices remain unchanged.

| Existing attack | FPS before → after | First active delay before → after | Full animation before → after |
| --- | ---: | ---: | ---: |
| Shield Bash / Sword Slash | 9.0 → 9.8 | 0.222 → 0.204 s | 0.556 → 0.510 s |
| Heavy Overhead / Shockwave | 8.0 → 8.8 | 0.375 → 0.341 s | 0.750 → 0.682 s |
| Combo Slash step 1/2 | 11.0 → 12.0 | 0.182 → 0.167 s | 0.455 → 0.417 s each |
| Jump Smash | 9.0 → 9.8 | 0.333 → 0.306 s | 0.667 → 0.612 s |
| Charge Thrust | 10.0 → 11.0 | 0.200 → 0.182 s | 0.500 → 0.455 s |

The legacy shared 0.42-second field remains only as a defensive fallback for malformed/skipped active-window callbacks. Runtime cadence uses the per-skill active-end gaps above. No attack gains a new active frame or higher damage.

## Reset contract

`reset_boss()` restores spawn `(6120,596)`, Body 180, Shield 100, intact Shield overlay, initial left facing, Phase 1, collision, Hurtbox, attack ids/windows, zeroed turn reaction/cooldown, zeroed Attack Gap/timestamps/counter debug, and inactive AI. Before final defeat, Player death/respawn invokes this through `BossRoomController`; after final defeat, reward/gate state persists and the Boss remains defeated.
## Fixed Chapter I reward and scaled target pools

Body/Shield are 180/100. Every outgoing Boss damage and attack timing remains unchanged. The complete Death animation emits `boss_defeated`; Main's independent `BossRewardController` then grants 30 coins once and reveals Ravenfang Daggers at `(6210,592)`. The pickup persists through Player death, auto-equips on E, and must be collected before `CastleEntranceTrigger` loads the threshold. The Boss never rolls the normal-enemy loot table.

The fixed reward uses a restrained coin-bag/text presentation and an original 0.22-second procedural two-tone chime. Headless tests skip audio stream construction; graphical F5 creates it at runtime, so no external audio asset or leaked test playback is introduced.
