# Player Pixel Animation QA Report

Date: 2026-07-22
Godot: 4.7.1 stable (`a13da4feb`)
Scope: current procedural action batch and 48px readability checks

## Visual evidence

![29 production frames and 48px checks](player_animation_contact_sheet.png)

The rows, from top to bottom, are Idle (4), Run (6), Ground Dash (5), Air Dash (5), Attack (4), and Dash Attack (5). Each production frame is displayed at exact 2× nearest-neighbor scale. The far-right check uses nearest-neighbor resizing to 48×48 and exact integer display scaling.

## Automated checks

- 29 expected PNGs exist and each source is exactly 64×64.
- Every frame has transparent background, binary alpha, visible pixels, and only the fixed five-color palette.
- All frames within each animation have unique SHA-256 values.
- Godot imports every frame as a `Texture2D` without mipmaps or dimension changes.
- Each 48×48 nearest-neighbor check retains binary alpha and more than 120 visible pixels.
- Ground Dash frame 03 is visibly lower than Idle frame 01; Air Dash remains above the ground line.
- Ground Dash, Air Dash, Attack frame 03, and Dash Attack frame 03 are distinct files and poses.
- The preceding six-frame Attack and Dash Attack sequences remain archived as twelve valid 64×64 references.
- The four reference copies are byte-identical to the original front, side, dash, and attack images.
- The formal Main remains `res://chapters/chapter_01_ravenmourn_outskirts/scenes/level/ravenmourn_outskirts.tscn`; the canvas texture default remains Nearest.

## Visual review

- Idle: eye, hood, leg gap, and two blades remain stable while the torso breathes by one pixel.
- Run: front/rear legs alternate over six frames and arms counter-swing without collapsing both blades into one shape.
- Ground/Air Dash remain visually distinct through planted versus airborne legs.
- Attack reaches a simultaneous two-blade forward thrust on its second 20-FPS frame; frame three holds the readable core before a quick recovery.
- Dash Attack forms the longer arrow-shaped thrust on frame three and retains forward momentum through frame four.
- At 48px, hood, torso, separate legs, and vertically offset paired blades remain recognizable.

## Manual preview

Run `scenes/tools/player_animation_preview.tscn` as the current scene. Use its twelve buttons (or documented keyboard shortcuts) to inspect Attack and Dash Attack frame timing. The preview uses `AnimatedSprite2D`, explicit Nearest texture filtering, and 6× integer scaling.
