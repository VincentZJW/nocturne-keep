# Player Movement and Level Metrics

Version: 1.1
Date: 2026-07-22
Status: measured prototype guidance; no map redesign performed

## Measurement method

Metrics come from `tests/player/measure_player_level_metrics.gd` using the shipping Player scene and resources under Godot 4.7.1 at 60 physics ticks/s. Tests use a flat collision floor, start from rest, hold right, and execute input through the real Input Map and `CharacterBody2D.move_and_slide()` path.

- Single jump: right plus one ground jump, measured from takeoff position to landing.
- Debug double jump: second jump at the first apex, measured from first takeoff to landing.
- Four Air Dash chain: jump, then four right-facing paid Air Dash segments buffered near each segment end. `four_air_dash_range` isolates the Dash action from the first accepted segment through `air_dash_end`; total-to-landing includes the short surrounding airborne locomotion.

These values are deterministic engineering envelopes, not guarantees for slopes, walls, moving platforms, or player timing.

## Measured movement envelope

| Movement | Horizontal range | Maximum rise | Notes |
| --- | ---: | ---: | --- |
| Single jump from rest | 153.59 px | 83.77 px | 220 px/s cap, -420 px/s jump |
| Debug double jump from rest | 281.92 px | 167.10 px | Second jump triggered near apex |
| Four continuous Air Dashes | 344.00 px | 0 px contributed | 4 × 25 stamina; gravity suspended during paid segments |
| Four-Air-Dash takeoff-to-landing total | 362.22 px | Depends on jump entry | Includes short pre/post-Dash travel |

At current tuning, the nominal Dash-only envelope is close to `480 × 0.18 × 4 = 345.6 px`; the measured 344 px reflects fixed-step transition timing. The measurement, not the formula, should be used for prototype QA tolerances.

## Current Main platform audit

Current collision geometry in `scenes/main/main.tscn`:

| Element | Horizontal span | Top Y | Relative rise from previous surface |
| --- | --- | ---: | ---: |
| Floor | -100 to 6600 | 640 | — |
| Platform A | 760 to 980 | 508 | 132 px above floor |
| Platform B | 2685 to 2875 | 426 | 214 px above floor; Crossbow staging |
| Platform C | 4310 to 4530 | 458 | 182 px above floor; Group06 Crossbow |
| Platform D | 5050 to 5270 | 438 | 202 px above floor; Group07 Crossbow |
| Gargoyle perch | 3440 to 3680 | 328 | visual/World Dive collision surface |

The first-level combat route now adds authored platforms centered at x=2780, 4420, and 5160 plus a Gargoyle perch at x=3560. These remain optional combat staging surfaces above the continuous floor. The Boss arena spans approximately x=5630..6480; checkpoint `(5480,612)` and Boss spawn `(6120,596)` are separated by enough horizontal room for all Player movement options and the Boss charge.

Implications:

- Every combat platform is narrower than the measured 344 px four-Air-Dash envelope, so a player at suitable height can cross its footprint without landing.
- The continuous floor is the required main route. Elevated Crossbow positions are optional approach problems and never require Air Dash to continue the level.
- The 182–214 px floor-to-platform rises exceed a stationary single jump and usually require the debug double jump or chained mobility to reach directly; Crossbowmen can still be defeated from the floor when line of attack permits.
- Encounter safe gaps are substantially longer than one full-stamina Dash chain, so an early chain cannot skip all activation boundaries or enter the Boss room from spawn.

## Route-design guidance

Future rooms should preserve three readable layers:

1. a required main route completable with the normal single jump;
2. optional exploration that rewards unlocked double jump;
3. high-mobility shortcuts or secrets that reward continuous Air Dash and stamina planning.

Do not require continuous Air Dash for the initial mainline. For gaps intended to resist a full-stamina chain, account for at least the measured 344 px Dash-only reach plus the jump entry/exit margin, and test the actual collision layout rather than applying a global platform-height increase.

## Reproduction

```bash
"$GODOT_BIN" \
  --headless --path . --script tests/player/measure_player_level_metrics.gd
```

Expected current result:

```text
PLAYER_LEVEL_METRICS: PASS physics_fps=60 single_jump_range=153.59 single_jump_rise=83.77 double_jump_range=281.92 double_jump_rise=167.10 four_air_dash_range=344.00 four_air_dash_total_to_landing=362.22
```
