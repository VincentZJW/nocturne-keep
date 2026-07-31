# Thirteenfold Absolution W1 QA Report

Date: 2026-07-31
Stage: W1 concept art

## Result

**PASS** for the W1 concept-art scope. Twelve distinct original PNG assets exist, import as Godot textures, have non-empty image data and unique hashes. W2 pixel production has not started.

## Visual review matrix

| Requirement | Status | Evidence |
|---|---|---|
| Pair master | PASS | `thirteenfold_absolution_pair_concept.png` |
| Absolution front/side | PASS | Long triangular thrust blade, oval hollow-bell guard and real side thickness |
| Penance front/side | PASS | Shorter broad shallow hook, thurible vents, semicircular guard and fixed ring |
| Distinct silhouettes | PASS | `thirteenfold_absolution_silhouette.png` |
| Guard construction | PASS | `thirteenfold_guard_breakdown.png` |
| Thirteen seals and empty seat | PASS | `thirteen_seal_nodes.png` shows thirteen filled medallions plus one empty dark socket |
| Player scale and grip | PASS | `thirteenfold_player_scale.png` |
| Combat readability | PASS | `thirteenfold_combat_pose.png` keeps both hands/blades visible in side-view thrusts |
| Edran relic continuity | PASS | `thirteenfold_reforging_sequence.png` starts from the existing crozier/thurible language |
| Reliquary scale | PASS | `thirteenfold_reliquary_concept.png` is low, compact and leaves the Player visible |
| No real religious marks/text | PASS | Native-resolution inspection of all twelve files |
| W1 scope isolation | PASS | No runtime scene, WeaponData, SpriteFrames, equipment, save or Main modification |

## Asset manifest

| File | Dimensions | Bytes | SHA-256 |
|---|---:|---:|---|
| `absolution_main_blade_front.png` | 1024×1536 | 2,263,782 | `81fba20184938b098523e5cf45b4293a2ca99881b17d13ce90e951e03ffe2a99` |
| `absolution_main_blade_side.png` | 1024×1536 | 2,119,133 | `372ecac0a173bd740c04911d7a88baa8e351d81ac8b758d365d4a8d9c08632bb` |
| `penance_offhand_blade_front.png` | 1024×1536 | 2,197,068 | `309bd33310a83f1556393e23baf9a3eb8c97335b0b27aa98c7e2d4e14a677d36` |
| `penance_offhand_blade_side.png` | 1024×1536 | 2,147,714 | `454ed33fd17059be0d23eb02d2fae3ef7adc43187f15cdac87ebb573db15d9a4` |
| `thirteen_seal_nodes.png` | 1254×1254 | 2,477,438 | `4d62d9de57d1d9211e699c92c7bf1667d44a5d0289c461a02d7ab95a4aa009a8` |
| `thirteenfold_absolution_pair_concept.png` | 1536×1024 | 2,170,651 | `c1d59420accad81a956c372887f404fa6255e5cf2149e54cbe43c3906b33bd8c` |
| `thirteenfold_absolution_silhouette.png` | 1536×1024 | 1,108,735 | `1fe127741595d3499b7cb0cbae0af3c80ee6b2f51e57142c5b196b1032392ec6` |
| `thirteenfold_combat_pose.png` | 1536×1024 | 2,614,779 | `3c8618edf2023c37ec54694e2367c750f7cf2d721a10d33447fd0f9b9c290ff0` |
| `thirteenfold_guard_breakdown.png` | 1536×1024 | 2,389,039 | `7dda8c2fa17250d7256a80cf6745bd9ed90d021bd81d1947eac12fc911dcc475` |
| `thirteenfold_player_scale.png` | 1536×1024 | 2,435,021 | `f436756afe0d341b93404abc853012a40d416bc3758cc59bd15bd7946b97ce62` |
| `thirteenfold_reforging_sequence.png` | 1536×1024 | 2,812,802 | `6fd415ebf3647460b29f4af0e0f1115821ad73c5efb4bb96ae0475a68d70e925` |
| `thirteenfold_reliquary_concept.png` | 1536×1024 | 2,712,615 | `a18baa35456c60074f8b9fa9d2ed6401eb12c3d7b9722e1f6d29860ff50f1731` |

## QA evidence

- Contact sheet: `docs/qa/chapter_03_thirteenfold_absolution/w1/concept_art_contact_sheet.png`
- Contact sheet: 1940×976, 1,896,517 bytes, SHA-256 `9cb2afd8db99fcd99bd9c19868fc395d7b3cddab378e7bb5ae50811d07a47fdd`.
- Source artwork directory: `chapters/chapter_03_chapel_of_thirteen_echoes/assets/weapons/thirteenfold_absolution/concept_art/`.

## Manual acceptance still required

- Confirm whether the main guard should retain the large oval proportion or be reduced slightly for the 64px Player translation.
- Confirm whether Penance's shallow hook is sufficiently distinct from Ravenfang while remaining readable at 48–64px.
- Confirm the balance of aged copper versus bone-white blade area and whether the reliquary is appropriately restrained for the post-Boss room.

These are visual-direction decisions, not W1 file-integrity failures. No W2 pixel asset should be produced until W1 is accepted.

## Exact verification commands and outcomes

1. `/Users/vincentz/Downloads/Godot.app/Contents/MacOS/Godot --headless --editor --path /Users/vincentz/Desktop/Game/godot-codex --quit`
   - PASS; all twelve PNGs imported, exit code 0, no script or resource error.
2. `/Users/vincentz/Downloads/Godot.app/Contents/MacOS/Godot --headless --path /Users/vincentz/Desktop/Game/godot-codex --script res://chapters/chapter_03_chapel_of_thirteen_echoes/tests/test_thirteenfold_absolution_w1_concepts.gd`
   - PASS; `concepts=12 unique_hashes=12`.
3. `/Users/vincentz/Downloads/Godot.app/Contents/MacOS/Godot --headless --path /Users/vincentz/Desktop/Game/godot-codex --script res://chapters/chapter_02_silent_court/tests/test_crimson_masque_weapon.gd`
   - PASS; `data=1 frames=49 damage=14/28 dedup=1 profile=1`.
4. `/Users/vincentz/Downloads/Godot.app/Contents/MacOS/Godot --headless --path /Users/vincentz/Desktop/Game/godot-codex --quit-after 240`
   - PASS; MainBootstrap selected `res://scenes/cinematics/opening_cinematic.tscn`; no red Output/Debugger error.
5. `git diff --check`
   - Recorded after final scope review.
