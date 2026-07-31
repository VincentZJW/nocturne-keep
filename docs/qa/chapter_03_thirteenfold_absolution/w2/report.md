# Thirteenfold Absolution W2 QA Report

Date: 2026-07-31
Stage: W2 formal pixel production and visual-only Main integration

## Result

**PASS** for the approved W2 scope. Formal pixel assets exist, all 30 Player animations resolve to 97 imported 64×64 frames, SpriteFrames timing matches the existing Player contract, and the actual MainBootstrap route displays the new weapon in Chapter III without granting or registering it.

## Acceptance matrix

| Requirement | Status | Evidence |
|---|---|---|
| Formal main/off-hand pixel silhouettes | PASS | `pixel_contact_sheet.png`, `02_ready_idle.png` |
| 30 runtime animation names | PASS | `test_thirteenfold_absolution_w2_visuals.gd` |
| 97 transparent 64×64 frames | PASS | Automated file/resource audit |
| Existing FPS and loop contract preserved | PASS | Automated SpriteFrames audit |
| Idle/run/jump | PASS | `02_ready_idle.png`–`04_jump_apex.png` |
| Three basic thrust variants | PASS | `05_attack_1.png`–`07_attack_3.png` |
| Dash Attack | PASS | `08_dash_attack.png` |
| Left-facing flip | PASS | `09_left_flip.png` |
| Hurt/death resource coverage | PASS | Contact sheet and `10_death_daggers.png` |
| MainBootstrap formal route | PASS | `01_main_route_idle.png`, rendered capture log |
| Visual-only preview isolation | PASS | Main test reports `visual=thirteenfold_absolution`, `equipment=crimson_masque_stilettos` |
| WeaponData/Inventory/Save absent | PASS | W2 boundary assertions |
| Output/Debugger red errors | PASS | Final generator, import, tests and rendered capture have none |

## Visual evidence index

1. `01_main_route_idle.png` — formal MainBootstrap → Chapter III → `CH3_POST_BOSS`, HUD visible.
2. `02_ready_idle.png` — both blade roles at integer 2× camera zoom.
3. `03_run.png` — running silhouette and grip stability.
4. `04_jump_apex.png` — airborne readability.
5. `05_attack_1.png` — first forward thrust.
6. `06_attack_2.png` — second thrust variation.
7. `07_attack_3.png` — third thrust variation.
8. `08_dash_attack.png` — low forward dash-thrust.
9. `09_left_flip.png` — horizontal flip without position or anchor change.
10. `10_death_daggers.png` — prone body with the W2 blade treatment retained.
11. `pixel_contact_sheet.png` — representative Player, pickup, reliquary and isolated pair views.

All screenshots are 1280×720. Close action captures use integer 2× camera zoom; 3× was rejected because the formal room camera limit cropped the Player's feet.

## Asset fingerprints

- 97-frame ordered aggregate SHA-256: `0db31174a97122f29a2db0ba44b2eb6d4b3f50384d69c90acfb69e6bb392d61e`.
- Pixel contact sheet SHA-256: `e6a7228c4d9d45b37f6e974e54087ace6aa7e221f88a17fcc5dad56819c45e91`.
- SpriteFrames resource size: 25,606 bytes.
- Presentation/effect files: 8 distinct PNGs with transparent corners and non-empty used bounds.

## Exact commands and actual outcomes

1. `Godot --headless --path <project> --script res://chapters/chapter_03_chapel_of_thirteen_echoes/scripts/tools/generate_thirteenfold_absolution_assets.gd`
   - PASS: `animations=30 frames=97 presentation=5 effects=3 contact_sheet=1`.
2. `Godot --headless --editor --path <project> --quit`
   - PASS: 105 new W2 PNGs imported; no script/resource error.
3. `Godot --headless --path <project> --script res://chapters/chapter_03_chapel_of_thirteen_echoes/scripts/tools/build_thirteenfold_absolution_sprite_frames.gd`
   - PASS: `animations=30 frames=97`.
4. `Godot --headless --path <project> --script res://chapters/chapter_03_chapel_of_thirteen_echoes/tests/test_thirteenfold_absolution_w2_visuals.gd`
   - PASS: `animations=30 frames=97 assets=8 preview=nonpersistent`.
5. `Godot --headless --path <project> --script res://tests/player/test_player_stage_2_qa.gd`
   - PASS: existing three Player visual sets, 30-animation contract and shared Player authority unchanged.
6. `Godot --headless --path <project> --script res://tests/systems/test_main_bootstrap_flow.gd`
   - PASS: formal Opening and Debug Chapter II route. Godot reports the test's existing two ObjectDB instances at teardown; no red gameplay/resource error.
7. `Godot --headless --path <project> --script res://chapters/chapter_03_chapel_of_thirteen_echoes/tests/test_chapter_03_r5_full_route.gd`
   - PASS: 50 transitions, 10 cycles, persistent runtime; reward and Chapter IV remain truthfully partial.
8. `Godot --path <project> --script res://chapters/chapter_03_chapel_of_thirteen_echoes/scripts/tests/capture_thirteenfold_absolution_w2_main_qa.gd`
   - PASS on OpenGL/Metal Compatibility: 10 rendered Main captures, `room=CH3_POST_BOSS`, `visual=thirteenfold_absolution`, `equipment=crimson_masque_stilettos`.

## W3 boundary and manual acceptance

W2 does not create `thirteenfold_absolution_blades.tres`, register 14/28 damage, add Inventory ownership, auto-equip, persist to disk, alter the Boss death flow, or replace the reliquary interaction. The first Main screenshot still displays the formally equipped Chapter II weapon values by design.

Human review is still required for artistic taste: the grouped seal pixels, off-hand hook strength, copper amount, action silhouette and trail restraint. Approval of W2 authorizes W3 data/inventory/save work; it does not imply W4 reward-flow approval.
