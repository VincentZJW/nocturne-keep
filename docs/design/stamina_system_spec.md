# Player Stamina System Specification

Version: 1.1 — shared Dash pool and grounded-only recovery
Date: 2026-07-22
Status: implemented functional prototype

## Scope and ownership

`PlayerStaminaComponent` is composed under `Player` and solely owns value, affordability, successful charges, grounded recovery timing, clamping, and typed signals. `PlayerActionController` requests charges; `PlayerStaminaHud` observes signals and never calculates or mutates stamina.

This is not health, damage, equipment, consumable, save, or general skill-resource logic.

## Parameters and spending

| Parameter | Value |
| --- | ---: |
| Initial / maximum stamina | 100 |
| Ground Dash cost | 25 |
| Air Dash cost | 25 |
| Eligible-ground recovery delay | 0.60 s |
| Recovery rate | 35/s |
| Clamp | 0–100 |

- Every successful Ground/Air Dash segment spends 25 immediately and resets the delay to 0.60 s.
- Ground and Air use the same pool; four accepted segments exhaust full stamina in any combination.
- A rejected request spends nothing and emits one insufficient signal.
- Dash→Dash-Attack reuses the paid segment. A direct same-frame Shift+J pays one charge. A Dash-Attack→Dash continuation pays the normal next-segment charge.
- Normal Attack, jump, and debug double jump cost zero.

## Grounded-only recovery

`Player` calls `advance(delta, regeneration_allowed)` with permission only when its pre-move floor state is true and no action is active. If permission is false, the component returns without decrementing its timer.

Consequently:

- Jump, Double Jump, Fall, Air Dash, Ground Dash, Dash Attack, and locked Attack provide zero recovery and zero delay progress.
- Waiting in the air for any duration leaves both stamina and the remaining 0.60-second delay unchanged.
- Landing neither refills stamina nor clears the timer. The player must accumulate 0.60 s of eligible grounded, action-free time before recovery begins.
- Recovery then adds 35 points/s smoothly and clamps at 100.
- Repeated landings and held Shift cannot bypass this timeline.

## Signals

- `stamina_changed(current: float, maximum: float)` after spend, recovery, reset, or guarded refund;
- `stamina_depleted()` when a successful charge reaches zero;
- `stamina_insufficient()` for each independent legal request that cannot pay 25.

## HUD contract

`Main/HUD` is a fixed `CanvasLayer`. Its 0–100 `ProgressBar` and numeric label update from `stamina_changed`. One insufficient request triggers one bounded feedback tween; it never loops. The replaceable pixel-style appearance contains no resource rules.

The optional Action Debug HUD reports current/maximum value, remaining delay, and `REGEN READY/BLOCKED`, alongside contact/action diagnostics. It can be disabled.

## Acceptance

Automated coverage verifies exact 25-point costs, four Ground/Air/mixed starts from full, rejected fifth with no cost, completely frozen airborne recovery, 0.60 s eligible-ground delay, 35/s rate, action blocking, Dash Attack no-double-charge and paid follow-up, held-input rejection, wall collision, clamping, signals, and HUD synchronization. Manual acceptance remains required for bar readability and depletion feel.
