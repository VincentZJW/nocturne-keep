# M1.5 Player Action Prototype QA

Date: 2026-07-21
Engine: Godot 4.7.1 stable (`a13da4feb`)

## Preflight asset audit

- `assets/sprites/player/assassin/attack/`: present; six source PNGs, `attack_01.png` through `attack_06.png`.
- `assets/sprites/player/assassin/dash/`: present; five source PNGs, `dash_01.png` through `dash_05.png`.
- Persistent SpriteFrames: `attack`, six frames, 12 FPS, non-looping; `dash`, five frames, 20 FPS, non-looping.
- Independent preview: dedicated Dash and Attack buttons plus physical keys 7 and 8 both call the shared presentation controller.
- Formal M1 absence cause: the Player requested only locomotion animations and the Input Map had no Dash/Attack actions. No source asset was missing.

## Automated behavior coverage

- Debug double jump is provisioned while the formal `has_double_jump` flag remains false.
- Ground/coyote jump preserves the air jump; the legal air jump consumes it; a third airborne jump is rejected; landing restores it.
- Shared jump buffering is consumed by the valid air-jump path and a single input edge cannot execute two jumps.
- Dash is rejected in air, applies 480 px/s for the 0.20-second motion window, uses frame five as zero-velocity recovery, locks facing, blocks ordinary horizontal control, and observes the 0.45-second cooldown.
- Attack wins simultaneous Attack/Dash input, cannot be restarted while active, is not overwritten by locomotion, locks facing, and returns to Idle or Run after all six frames.
- `attack_03` and `attack_04` remain metadata-only reserved frames; the Player scene contains no damage, hitbox, hurtbox, health, enemy, or boss node.

## Visual checks

- Existing animation contact sheet was reviewed at original resolution. Dash has a low extended travel silhouette; Attack has a distinct anticipation, lunge, thrust, follow-through, and recovery.
- Main and preview scenes were rendered at 1280×720 using GL Compatibility on Apple M4.
- Main instructions fit inside the panel and explicitly label the debug double-jump override.
- Preview retains sharp 6× nearest-neighbor rendering and exposes both production actions.

## Manual checks requested

1. Run Main and press Space twice, then confirm a third airborne press has no effect.
2. Press Shift on the ground and confirm the travel/recovery rhythm and cooldown feel appropriate.
3. Hold a movement direction during Attack and confirm the six frames complete before Run resumes.
4. Change direction during Attack/Dash and confirm the visible facing remains locked until completion.
5. Confirm Output and Debugger remain free of red errors during a normal play session.
