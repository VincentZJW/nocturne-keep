# Fallen Gate Knight Greatsword Revision QA

Date: 2026-07-29
Result: **PASS** — focused weapon-art scope complete; subjective game-feel review remains manual.

## Design authority

- Formal name: `Gatewarden Greatsword / 守门誓剑`.
- Proportion target: roughly 84–88% of the authored Boss height in a neutral vertical presentation, inside the user's requested 80–95% range.
- User reference B informed only the restrained knight-to-sword scale relationship. User reference C informed only the readable blade planes, guard, grip and pommel hierarchy. The production silhouette, gate-arch guard, oath seal and Ravenmourn material language are original.
- The design board was produced in Imagegen original-design mode from the three supplied references, then the formal pixel implementation was authored deterministically with Godot `Image` drawing code. No third-party runtime art is used.

## Acceptance matrix

| Check | Status | Evidence |
|---|---|---|
| Old short-sword baseline preserved | PASS | `00_before_user_reference.png`, `reference/gatewarden_greatsword_v3_before/runtime_preview_before.png` |
| New weapon concept and material study | PASS | `fallen_gate_knight_greatsword_design.png` |
| Phase 1 idle + Player scale | PASS | `01_phase_1_idle_with_player_main.png` |
| Phase 1 slash readability | PASS | `02_phase_1_sword_slash_main.png` |
| Heavy attack placement | PASS | `03_phase_1_heavy_overhead_main.png` |
| Phase 2 two-handed identity | PASS | `04_phase_2_two_handed_idle_main.png` |
| Phase 2 long thrust | PASS | `05_phase_2_charge_thrust_main.png` |
| Phase 2 combo slash | PASS | `06_phase_2_combo_slash_main.png` |
| Death placement / no floor clipping | PASS | `07_death_sword_placement_main.png` |
| Old/new same-camera comparison | PASS | `08_before_left_after_right_main.png` |
| Runtime frame edge clipping guard | PASS | `test_fallen_gate_knight_art_v3.gd` |
| Existing Boss combat contract | PASS | `test_first_level_boss.gd` |
| Actual MainBootstrap route | PASS | capture script launched `MainBootstrap -> Chapter I -> boss_checkpoint` |

## Runtime evidence

- Main route: `res://scenes/bootstrap/main_bootstrap.tscn`
- Chapter I: `res://chapters/chapter_01_ravenmourn_outskirts/scenes/level/ravenmourn_outskirts.tscn`
- Live Boss: `World/CastleEntranceArea/FallenGateKnight`
- Visual node: `VisualRoot/AnimatedSprite2D`
- SpriteFrames: `res://chapters/chapter_01_ravenmourn_outskirts/resources/boss/fallen_gate_knight_sprite_frames.tres`
- Main capture utility: `res://chapters/chapter_01_ravenmourn_outskirts/scripts/tests/capture_fallen_gate_knight_greatsword_revision_qa.gd`

The saved Main instance has no sprite-resource override. Replacing the authoritative SpriteFrames inputs therefore updates both the formal Boss scene and F5 Chapter I route without modifying the dirty saved level serialization.
