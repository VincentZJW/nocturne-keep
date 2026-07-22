# Dash Attack QA Report

Date: 2026-07-22
Engine: Godot Engine 4.7.1 Standard (`a13da4feb`)
Renderer: GL Compatibility on Apple M4

## Scope evidence

- Current `dash_attack` is five frames at 20 FPS (approximately 0.25 seconds).
- Supports same-frame Shift/J and Dash-then-J resolution, Ground/Air Dash transitions, collision-safe inherited-direction movement, and an optional Main debug HUD.
- Kept existing Ground Dash, Air Dash, Attack, deprecated Attack comparison, and all character references.
- Added no Hitbox node, enemy, target tracking, health, damage, invulnerability, combo tree, or Boss behavior.

## Visual evidence

The original-resolution contact sheet is `docs/qa/player_animation_contact_sheet.png`. Its sixth row is Dash Attack:

- frames 01–02 inherit a low, forward-moving Dash line while gathering and extending both arms;
- frames 03–04 hold two vertically separated Pale Steel blades in a narrow arrow silhouette;
- frame 05 retracts both blades and shortens the stance;
- no lateral slash or broad effect arc is present;
- the 48×48 nearest-neighbor check at the right retains hood, torso, lead/rear legs, and two weapon tips.

## Deterministic acceptance

| Contract | Result |
| --- | --- |
| Shift alone remains Dash | PASS |
| J alone starts normal Attack immediately | PASS |
| Dash then J inside 0.18 seconds | PASS |
| J then Shift after Attack starts remains normal Attack | PASS (preserved no-Dash-cancel rule) |
| Same-frame Shift/J | PASS |
| Late J rejected as Dash Attack | PASS |
| Once per Dash and no frame-zero restart spam | PASS |
| Ground recovery to Run/Idle | PASS |
| Air recovery to Fall with gravity restored | PASS |
| Air Dash availability remains spent until landing | PASS |
| Left-facing direction and sprite flip | PASS |
| CharacterBody2D wall collision | PASS |
| Future metadata only on frames 03–04 | PASS |
| Debug HUD fields and off toggle | PASS |

## Manual acceptance focus

1. Judge the immediate four-frame normal Attack and its 0.10-second one-entry repeat buffer in hand.
2. Judge the 0.18-second Dash-to-Attack window at both Ground and Air Dash speed.
3. Compare normal Attack, Dash, and Dash Attack at gameplay scale in both directions.
4. Confirm the 320 px/s sustained phase plus linear recovery feels like inherited momentum rather than a second full Dash.
