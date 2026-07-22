# Player Stamina System Specification

Version: 1.2 — configurable airborne recovery
Date: 2026-07-22
Status: implemented functional prototype

## Scope and ownership

`PlayerStaminaComponent` is composed under `Player` and solely owns value, affordability, successful charges, recovery timing/rates, clamping, and typed signals. `PlayerActionController` requests charges and exposes whether the active action consumes stamina. `Player` supplies current floor contact. `PlayerStaminaHud` observes signals and never calculates or mutates stamina.

This is not health, damage, equipment, consumable, save, or general skill-resource logic.

## Parameters and spending

| Parameter | Value |
| --- | ---: |
| Initial / maximum stamina | 100 |
| Ground Dash cost | 25 |
| Air Dash cost | 25 |
| Recovery delay after spend | 0.60 s |
| Ground recovery rate | 35/s |
| Airborne recovery multiplier | 0.40, exported 0–1 |
| Derived default airborne rate | 14/s |
| Clamp | 0–100 |

The existing 35/s grounded rate is intentionally preserved. Airborne rate is always derived by `get_regeneration_rate(false)`; gameplay does not embed a separate hard-coded 14 or 0.40 branch.

- Every successful Ground/Air Dash segment spends 25 immediately and resets the delay to 0.60 s.
- Ground and Air use the same pool; four accepted segments exhaust full stamina in any combination.
- A rejected request spends nothing and emits one insufficient signal.
- Dash→Dash-Attack reuses the paid segment. A direct same-frame Shift+J pays one charge. A Dash-Attack→Dash continuation pays the normal next-segment charge.
- Normal Attack, jump, and debug double jump cost zero.
- No separate evade/dodge action exists in the current prototype.

## Recovery policy

`Player` calls `advance(delta, is_grounded, regeneration_blocked)` after action dispatch each physics step.

- Grounded and unblocked: the delay advances, then stamina recovers at 35/s.
- Ordinary Jump Start/Loop, Double Jump, and Fall: the delay advances, then stamina recovers at 35 × 0.40 = 14/s by default.
- Zero-cost normal Attack: recovery continues at the contact-appropriate rate.
- Ground Dash, Air Dash (including start/loop/end), and Dash Attack: recovery and delay progress are both blocked for the full paid action.
- Landing does not refill stamina or clear the timer. It only changes subsequent recovery from the airborne rate to the full grounded rate.
- Recovery clamps at 100 and a failed Dash never changes value/timing.

Blocking is based on cost ownership, not every animation/action lock. If later work adds a stamina cost to Attack, Jump, or a future dodge, that action must be added explicitly to `is_stamina_regeneration_blocked()` as part of the same cost change.

## Signals

- `stamina_changed(current: float, maximum: float)` after spend, recovery, reset, or guarded refund;
- `stamina_depleted()` when a successful charge reaches zero;
- `stamina_insufficient()` for each independent legal request that cannot pay 25.

## HUD and diagnostics

`Main/HUD` is a fixed `CanvasLayer`. Its 0–100 `ProgressBar` and numeric label update only from `stamina_changed`. One insufficient request triggers one bounded feedback tween; it never loops.

The optional Action Debug HUD reports `REGEN BLOCKED`, `GROUND 35.0/s`, or `AIR 14.0/s`, plus the current delay and action/contact diagnostics. It can be disabled.

## Acceptance

Automated coverage verifies the exported 0.40 default and custom multiplier, exact 35/s ground and 14/s air rates, airborne delay progress, full blocking during Air/Ground Dash and Dash Attack, recovery during zero-cost Attack, exact costs, four shared starts, rejected fifth without cost, signals, clamping, and HUD synchronization. Manual acceptance remains required for perceived recovery balance.
