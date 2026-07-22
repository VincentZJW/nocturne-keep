# Player Movement and Level Metrics

Version: 1.0
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
| Floor | -100 to 2500 | 640 | — |
| Platform A | 760 to 980 | 508 | 132 px above floor |
| Platform B | 1185 to 1375 | 426 | 82 px above Platform A; 214 px above floor |

Implications:

- Both Platform A (220 px wide) and Platform B (190 px wide) are narrower than the 344 px four-Air-Dash envelope. A player already at a suitable height can pass either platform's full horizontal footprint without landing.
- The A→B horizontal edge gap is 205 px, also below the chain envelope. Continuous Air Dash can bypass the intended intermediate landing rhythm between their edges.
- A stationary single jump rises only 83.77 px. This is barely above the 82 px A→B elevation change and leaves about 1.77 px of vertical tolerance; it is not a robust production route at the measured 153.59 px horizontal range.
- Debug double jump rises 167.10 px, enough for floor→A (132 px), but not floor→B (214 px). Continuous horizontal Air Dash adds no lift, so it does not by itself make floor→B reachable without an elevation source.
- From the current spawn center at x=320 to Platform A's left edge is 440 px, more than the isolated 344 px and measured 362.22 px takeoff-to-landing Air-Dash envelope. The chain does not make that stationary direct transfer automatic.
- The current floor is continuous under both platforms, so both are already optional visual/test platforms rather than mandatory main-route gates. No existing platform was moved or raised in this task.

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
