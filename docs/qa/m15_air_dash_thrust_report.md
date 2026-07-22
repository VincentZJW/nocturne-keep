# M1.5 Air Dash and Dual-Dagger Thrust QA

Date: 2026-07-22
Engine: Godot Engine 4.7.1 Standard (`a13da4feb`)
Renderer: GL Compatibility on Apple M4

## Asset evidence

- Production Ground Dash: five transparent 64×64 PNGs in `assets/sprites/player/assassin/ground_dash/`.
- Production Air Dash: five transparent 64×64 PNGs in `assets/sprites/player/assassin/air_dash/`.
- Production Attack: six transparent 64×64 PNGs in `assets/sprites/player/assassin/attack/`.
- Deprecated sideways-slash comparison: six preserved PNGs in `assets/sprites/player/assassin/reference/deprecated_attack_slash/`.
- Contact sheet: `docs/qa/player_animation_contact_sheet.png`.

The contact sheet was inspected at original resolution. Ground Dash has a planted rear-leg drive and low grounded baseline. Air Dash keeps both legs off the floor and pulls the body into a more horizontal travel pose. Attack clearly extends two parallel, vertically separated Pale Steel blades beyond the face and torso, with a bent lead leg and straight rear leg. No broad slash arc exists in the new sequence.

## Automated checks

| Check | Result |
| --- | --- |
| Editor import and typed script parse | PASS |
| 26 production PNGs, palette, alpha, dimensions, imports, 48px conversion | PASS |
| 11 SpriteFrames animations, FPS, loop flags, locks, completion signals | PASS |
| M1 movement/jump/collision/camera regression | PASS |
| Ground/Air Dash, single-use reset, shared cooldown, gravity restore | PASS |
| Dual-dagger thrust art and Attack lifecycle | PASS |
| Main GL Compatibility startup/render | PASS |
| Animation preview GL Compatibility startup/render | PASS |

## Manual acceptance focus

1. Dash during ascent and descent and judge whether the 0.20-second horizontal travel feels responsive.
2. Attempt a second Air Dash before landing, then land and confirm one Air Dash becomes available again.
3. View Attack facing both directions and confirm both dagger tips remain distinct in the core strike.
4. Compare Ground Dash, Air Dash, and Attack in the independent preview and report any pose that reads ambiguously at gameplay scale.

No enemy, damage, hitbox, hurtbox, invulnerability, combo, or Boss functionality was added.
