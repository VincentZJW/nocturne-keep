# W5 artifact and path manifest

## Final weapon asset roots

| Category | Path | Count/role |
|---|---|---|
| concept art | `res://chapters/chapter_03_chapel_of_thirteen_echoes/assets/weapons/thirteenfold_absolution/concept_art/` | 12 PNG sheets |
| Player animation source | `res://chapters/chapter_03_chapel_of_thirteen_echoes/assets/weapons/thirteenfold_absolution/animations/player/` | 97 transparent 64×64 PNG frames / 30 animations |
| presentation sprites | `res://chapters/chapter_03_chapel_of_thirteen_echoes/assets/weapons/thirteenfold_absolution/sprites/` | 6 PNGs |
| reward/equipped effects | `res://chapters/chapter_03_chapel_of_thirteen_echoes/assets/weapons/thirteenfold_absolution/effects/` | 5 PNGs |
| WeaponData | `res://chapters/chapter_03_chapel_of_thirteen_echoes/resources/weapons/thirteenfold_absolution_blades.tres` | gameplay authority |
| Player SpriteFrames | `res://chapters/chapter_03_chapel_of_thirteen_echoes/resources/weapons/thirteenfold_absolution_player_sprite_frames.tres` | presentation authority |

The chapter-local weapon asset tree contains 120 tracked source files excluding import metadata and `.DS_Store`.

## Runtime paths

- Formation: `res://chapters/chapter_03_chapel_of_thirteen_echoes/scenes/transitions/chapter_03_reward_sequence_controller.tscn`
- Post-Boss reliquary: `res://chapters/chapter_03_chapel_of_thirteen_echoes/scenes/areas/ch3_post_boss_reliquary.tscn`
- Formal pickup: `res://chapters/chapter_03_chapel_of_thirteen_echoes/scenes/pickups/thirteenfold_absolution_pickup.tscn`
- Post-Boss room: `res://chapters/chapter_03_chapel_of_thirteen_echoes/scenes/rooms/ch3_post_boss_room.tscn`
- Underkeep room: `res://chapters/chapter_03_chapel_of_thirteen_echoes/scenes/rooms/ch3_underkeep_room.tscn`
- Main route: `res://chapters/chapter_03_chapel_of_thirteen_echoes/scenes/level/chapter_03_route.tscn`
- F5 bootstrap: `res://scenes/bootstrap/main_bootstrap.tscn`

## W5 test/evidence paths

- `res://chapters/chapter_03_chapel_of_thirteen_echoes/tests/test_thirteenfold_absolution_full_flow.gd`
- `res://chapters/chapter_03_chapel_of_thirteen_echoes/scripts/tools/capture_thirteenfold_absolution_qa.gd`
- `res://docs/design/chapter_03_thirteenfold_absolution_spec.md`
- `res://docs/qa/chapter_03_thirteenfold_absolution/w5/report.md`
- `res://docs/qa/chapter_03_thirteenfold_absolution/w5/01_reward_test_uncollected_main.png` through `10_return_empty_reliquary_main.png`
