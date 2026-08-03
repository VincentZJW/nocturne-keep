# Chapter IV Scene Production S2 QA

## Result

Status: **PASS — formal environment asset kit complete; route assembly not started**

- Catalog: 297 original RGBA8 PNGs (228 P0 / 60 P1 / 9 P2).
- Godot import: lossless `compress/mode=0`, `mipmaps/generate=false` for every catalog entry.
- Packaged animation resources: 25 animations across water and environment-motion SpriteFrames.
- QA boards: five 1600×900 nearest-neighbour contact sheets.
- Main/Chapter IV gameplay contract: regression-tested without changing formal routes, encounters, collisions or tuning.

## Visual evidence

- `s2_core_architecture_contact_sheet.png`
- `s2_route_props_contact_sheet.png`
- `s2_dynamic_water_fx_contact_sheet.png`
- `s2_boss_memory_contact_sheet.png`
- `s2_actor_readability_mockup.png`

The actor board checks the formal Player beside Drowned Gaoler, Mire Harpooner and Underkeep Executioner. It also verifies supported Harpooner ledges and the rear/highlight/front-lip water split.

## Automated checks

The S2 asset test validates:

- all declared P0 families are present;
- catalog paths and dimensions match the PNGs;
- every image remains RGBA8;
- every PNG has lossless, no-mipmap Godot import metadata;
- the front water lip remains no more than 4 px;
- both SpriteFrames resources contain the expected frame counts.

## Exact Godot 4.7.1 commands and results

| Command | Result |
|---|---|
| `Godot --headless --path . --script res://chapters/chapter_04_drowned_underkeep/scripts/tools/generate_chapter_04_environment_assets_s2.gd` | PASS — `files=297` |
| `Godot --headless --path . --script res://chapters/chapter_04_drowned_underkeep/scripts/tools/generate_chapter_04_environment_s2_qa.gd` | PASS — `boards=5` |
| `Godot --headless --path . --import` | PASS — 297 catalog PNGs imported |
| `Godot --headless --path . --script res://chapters/chapter_04_drowned_underkeep/scripts/tools/build_chapter_04_environment_resources_s2.gd` | PASS — `resources=2` |
| `Godot --headless --path . --script res://chapters/chapter_04_drowned_underkeep/tests/environment/test_chapter_04_environment_assets_s2.gd` | PASS — `assets=297 animations=25` |
| `Godot --headless --path . --script res://chapters/chapter_04_drowned_underkeep/tests/characters/test_chapter_04_enemy_runtime.gd` | PASS |
| `Godot --headless --path . --script res://chapters/chapter_04_drowned_underkeep/tests/characters/test_chapter_04_main_integration.gd` | PASS |
| `Godot --headless --path . --script res://chapters/chapter_04_drowned_underkeep/tests/characters/test_soul_gaoler_ormund_runtime.gd` | PASS |
| `Godot --headless --path . --quit-after 180` | PASS — MainBootstrap loaded the formal opening cinematic |
| Runtime concept-reference scan | PASS — zero runtime references |
| `git diff --check` | PASS |

All commands used `/Users/vincentz/Downloads/Godot.app/Contents/MacOS/Godot`, version `4.7.1.stable.official.a13da4feb`.

## Manual acceptance boundary

This pass verifies asset completeness, technical usability, layer separation and actor-scale readability. Room-by-room visual composition, collision, traversal, Encounter placement, visibility gating and full Main/F5 chapter traversal belong to CH4-S3 and later stages. They are not claimed here.
