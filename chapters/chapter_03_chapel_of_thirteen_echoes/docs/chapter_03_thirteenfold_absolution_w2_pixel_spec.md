# Thirteenfold Absolution / 十三重赦刃 — W2 Pixel Production Spec

Date: 2026-07-31
Status: W2 complete; W3 not started

## Stage boundary

W2 translates the accepted W1 design into formal hard-edged pixel resources and the existing complete Player animation contract. It deliberately does not create or register `WeaponData`, grant inventory ownership, alter 14/28 damage, write Save data, replace the post-Boss reward interaction, or unlock Chapter IV. Those remain W3–W5.

## Pixel identity

- `Absolution / 赦罪` is the longer forward-hand blade: bone-white thrust face, cold-steel edge, black-iron back, restrained dark-red groove, aged-copper hollow-bell guard, black grip and compact crozier pommel.
- `Penance / 忏悔` is shorter and broader: shallow hooked thurible blade, cold edge, black-iron body, vent pixels, perforated censer guard and one fixed ring.
- The oval guard and thirteen seals are grouped into readable pixel clusters at gameplay scale; they are not enlarged into a torso-obscuring ornament.
- Both weapons remain visible as separate silhouettes in the thrust and dash-thrust poses. No wide slash arc, chain simulation or additional attack range is introduced.

The formal images are generated deterministically with Godot `Image` operations. The accepted W1 concept art is the visual reference; no third-party sprite or generative raster is embedded in the runtime frames.

## Asset locations

| Purpose | Path |
|---|---|
| 97 Player frame PNGs | `assets/weapons/thirteenfold_absolution/animations/player/` |
| Inventory, HUD, pair, world and reliquary sprites | `assets/weapons/thirteenfold_absolution/sprites/` |
| Restrained thrust, bell and pickup effects | `assets/weapons/thirteenfold_absolution/effects/` |
| Formal SpriteFrames | `resources/weapons/thirteenfold_absolution_player_sprite_frames.tres` |
| Deterministic generator | `scripts/tools/generate_thirteenfold_absolution_assets.gd` |
| SpriteFrames builder | `scripts/tools/build_thirteenfold_absolution_sprite_frames.gd` |

All paths above are relative to `res://chapters/chapter_03_chapel_of_thirteen_echoes/`.

## Presentation assets

| File | Size | Use |
|---|---:|---|
| `inventory_icon.png` | 32×32 | Future W3 inventory icon |
| `hud_icon.png` | 24×24 | Future W3 HUD icon |
| `weapon_pair_reference.png` | 64×48 | Pair construction and visual QA |
| `world_pickup.png` | 64×64 | Future W4 world pickup |
| `reliquary_display.png` | 96×64 | Future W4 low reliquary display |
| `bone_gold_thrust_trail.png` | 64×32 | Restrained thrust trail source |
| `hollow_bell_afterimage.png` | 32×32 | Hollow-bell silhouette afterimage |
| `reliquary_pickup_glow.png` | 64×64 | Restrained future pickup glow |

These files are formal pixel assets, but W2 intentionally has no runtime pickup or acquisition scene consuming them yet.

## Player animation contract

The new SpriteFrames preserves the exact existing timing and loop contract:

| Animation | Frames | FPS | Loop |
|---|---:|---:|---|
| `idle`, `ready_idle` | 4 each | 5 | yes |
| `walk` | 6 | 7 | yes |
| `run` | 6 | 10 | yes |
| `turn`, `start_move`, `stop_move` | 3 each | 12 | no |
| `jump_start` | 2 | 12 | no |
| `jump_rise`, `jump_loop` | 2 each | 4 | yes |
| `jump_apex` | 2 | 6 | yes |
| `fall` | 2 | 4 | yes |
| `double_jump` | 4 | 16 | no |
| `land` | 2 | 12 | no |
| `dash_start`, `dash_end` | 2 each | 20 | no |
| `dash_loop` | 3 | 20 | yes |
| `air_dash_start`, `air_dash_end` | 2 each | 20 | no |
| `air_dash_loop` | 3 | 20 | yes |
| `attack`, `attack_1`, `attack_2`, `attack_3` | 4 each | 20 | no |
| `combo_transition` | 2 | 20 | no |
| `dash_attack` | 5 | 20 | no |
| `hurt`, `hurt_light` | 3 each | 16 | no |
| `hurt_heavy` | 4 | 12 | no |
| `death` | 5 | 11.111111 | no |

Total: 30 animations and 97 transparent 64×64 frames. Player pose geometry, frame timing, collision, Hitbox windows, attack reach, movement and stamina are unchanged.

## Runtime visual integration

`Player/VisualRoot/WeaponVisual` now knows the visual ID `thirteenfold_absolution` and atomically swaps the full SpriteFrames resource. The active animation, frame, frame progress and playing/paused state are preserved through the swap.

W2 adds `CH3_REWARD_TEST` as a debug-only Chapter III spawn. It resolves through the formal `MainBootstrap` route into `CH3_POST_BOSS`, then applies `set_visual_preview(&"thirteenfold_absolution")`. That method changes only the Player presentation and never calls Inventory, Equipment or Save.

The W2 Main test proves that the actual equipped item remains `crimson_masque_stilettos`; therefore the HUD continues to display the existing tier-3 14/28 values until W3 formally registers the new WeaponData.

## QA and manual review

- Pixel contact sheet: `res://docs/qa/chapter_03_thirteenfold_absolution/w2/pixel_contact_sheet.png`.
- Main evidence: `res://docs/qa/chapter_03_thirteenfold_absolution/w2/01_main_route_idle.png` through `10_death_daggers.png`.
- Automatic test: `res://chapters/chapter_03_chapel_of_thirteen_echoes/tests/test_thirteenfold_absolution_w2_visuals.gd`.

Manual review should focus on main/off-hand silhouette separation, grip alignment, copper-to-bone-white balance, left-facing readability, and whether the deliberately restrained attack trails remain clear against Chapter III backgrounds. W3 may register data and persistence only after W2 visual acceptance.
