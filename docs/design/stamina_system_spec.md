# Player Stamina System Specification

Version: 1.0
Date: 2026-07-22
Status: implemented functional prototype

## Scope and ownership

`PlayerStaminaComponent` is a composed child of `Player`. It alone owns the current value, affordability checks, successful Dash charges, regeneration delay/rate, clamping, and typed notifications. `PlayerActionController` requests a Dash charge only when a legal Ground/Air Dash or direct Dash Attack can start. `PlayerStaminaHud` observes signals and never calculates or mutates stamina.

This system does not implement health, damage, enemies, invulnerability, equipment modifiers, consumables, or a general skill-resource framework.

## Parameters

| Parameter | Value |
| --- | ---: |
| Maximum/current initial stamina | 100 |
| Ground/Air Dash cost | 25 |
| Regeneration delay after last spend | 0.60 s |
| Regeneration rate | 35/s |
| Minimum/maximum clamp | 0 / 100 |

Normal Attack, Dash Attack transition, jump, and debug double jump add no separate cost. A direct legal Shift+J pays one Dash cost because it creates the Dash Attack without an earlier Dash. A Dash-to-Dash-Attack transition has already paid and is never charged twice.

## Regeneration

- Every successful Dash spend resets `stamina_regen_timer` to 0.60 seconds.
- Timer passage is measured from the last spend. No regeneration occurs while Ground Dash, Air Dash, or Dash Attack is active, even if the timer expires during that action.
- After both conditions clear, stamina increases at 35 points per second and clamps at 100.
- Landing restores only `air_dash_available`; it does not mutate stamina or its timer.
- A rejected Dash spends nothing. Repeated landings and held Shift cannot bypass the rules.

## Signals

- `stamina_changed(current: float, maximum: float)` after a successful spend, regeneration step, reset, or guarded refund.
- `stamina_depleted()` when a successful charge reaches zero.
- `stamina_insufficient()` once for each independent legal Dash request that cannot pay 25 points.

## HUD contract

`Main/HUD` is a fixed `CanvasLayer`. `StaminaContainer` contains a 0–100 `ProgressBar` and debug-friendly numeric label. It updates from `stamina_changed`. An insufficient request triggers one short color/position feedback tween; it does not loop. Integer screen offsets and replaceable `StyleBoxFlat` styling keep the prototype UI independent from the gameplay component.

## Acceptance

Automated coverage verifies exact costs, four starts from full, rejected fifth without a charge, 0.60-second delay, 35/s recovery, blocked recovery during Dash states, held-Shift non-repeat, one Air Dash per airtime, landing non-refill, Dash Attack non-double-charge, wall collision, and HUD synchronization. Manual acceptance remains required for chain rhythm, bar readability, and insufficient-feedback feel.
