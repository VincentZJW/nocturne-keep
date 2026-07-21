# Pixel Character Tool QA Report

Date: 2026-07-21
Engine: Godot `4.7.1.stable.official.a13da4feb`
Result: PASS

## Visual evidence

- [1600×1000 character board](../design/hooded_assassin_character_board.png)
- [Runnable lab preview](character_design_lab_preview.png)
- [64px front view](../../assets/sprites/player/concept_c/assassin_front_64.png)
- [64px side view](../../assets/sprites/player/concept_c/assassin_side_64.png)
- [48px side readability](../../assets/sprites/player/concept_c/assassin_side_48.png)
- [64px silhouette](../../assets/sprites/player/concept_c/assassin_silhouette_64.png)

## Generated PNG manifest

| Path | Size | Bytes | SHA-256 | Purpose |
| --- | ---: | ---: | --- | --- |
| `assets/sprites/player/concept_c/assassin_attack_anticipation.png` | 64×64 | 768 | `e57de72d5382c4de1183c7312b78806d9bd71521ea8c745b193d23fa15ef2996` | Attack anticipation key pose |
| `assets/sprites/player/concept_c/assassin_dash_pose.png` | 64×64 | 787 | `cb243a8b57de9ac643a2392cd51cf5b4825a563282c5900a6fa7dcf947e00edf` | Dash key pose |
| `assets/sprites/player/concept_c/assassin_front_48.png` | 48×48 | 572 | `798f2338a9ce21b7d7d5da0becc551e33164573f6e552259ca4b2de1969cee65` | Minimum-size front check |
| `assets/sprites/player/concept_c/assassin_front_64.png` | 64×64 | 709 | `b17c8c586ff31d3676c7c37da30b05111662d5929ac850707951d16d2ce6d2fb` | Main front concept |
| `assets/sprites/player/concept_c/assassin_idle_pose.png` | 64×64 | 734 | `156a149fd2e89a5a53531f27a6d06c043e89e7f1e1c573036309d4654e4745c0` | Idle key pose |
| `assets/sprites/player/concept_c/assassin_side_48.png` | 48×48 | 559 | `3d62cf268a75f91cefd0bab421ee0434c205b5f5d988362802f68219190d00a0` | Minimum-size side check |
| `assets/sprites/player/concept_c/assassin_side_64.png` | 64×64 | 734 | `156a149fd2e89a5a53531f27a6d06c043e89e7f1e1c573036309d4654e4745c0` | Main gameplay-side concept |
| `assets/sprites/player/concept_c/assassin_silhouette_64.png` | 64×64 | 442 | `9511b373ab242c5df217c457d12d6e267f4a3fb223a648214f0471787863d458` | Single-color silhouette test |
| `assets/sprites/player/concept_c/dagger_main.png` | 40×16 | 242 | `47ed62d5e56628027715d25507077581f76948ef57e2e0519ede452528389c42` | Longer main dagger profile |
| `assets/sprites/player/concept_c/dagger_offhand.png` | 32×16 | 233 | `0b31f94fe44c8895115107c796b224e13dc997f4acace3879a2b516b458dda1b` | Shorter offhand dagger profile |
| `assets/sprites/player/concept_c/palette_preview.png` | 160×32 | 210 | `3e7b351dfbd254fcb958a51601341e4b7cc8cdd3ede218303d7241ac1b0708fb` | Five-color palette |
| `docs/design/hooded_assassin_character_board.png` | 1600×1000 | 131678 | `088bcf1bbd80677173b7347bc0c32218f1e883baac3fce8763e3265e2e1a8259` | Complete concept board |
| `docs/qa/character_design_lab_preview.png` | 1280×720 | 53774 | `612275f9032cc515ed9e7271072433bcd40bfc7602f9a328e55295c54ecddccb` | Completed runnable-tool preview |

## Automated checks

`tests/tools/validate_pixel_character_assets.gd` verifies:

- all eleven asset PNGs and the board exist;
- exact dimensions;
- source images contain no mipmaps;
- imported textures contain no mipmaps;
- visible imported pixels match the lossless PNG source;
- character/weapon images have transparent backgrounds;
- alpha is binary with no blurred edge pixels;
- the silhouette has exactly one opaque color;
- project-wide Canvas texture filtering remains Nearest;
- `application/run/main_scene` remains `res://scenes/main/main.tscn`.

## Visual findings

- Front and side views share the hood, eye value, chest structure, amber clasp, leg proportions, and dagger language.
- The side view reads as right-facing because the longer pale blade clears the front of the body.
- The rear dagger remains separated from the torso and legs.
- The 48px preview preserves the hood point, eye glint, torso/leg separation, and both blade directions.
- The single-color silhouette preserves the hood, mantle projection, forward arm/blade, rear blade, and leg gap.
- All integer-scale previews are sharp under nearest filtering.

## Known limitations

- These are static concept poses, not production animation frames.
- The front view is intentionally more symmetrical than the gameplay view and may need a stronger asymmetrical shoulder cue after visual approval.
- System-font rendering on a regenerated board can vary by operating system; the committed board PNG is the reviewed artifact.
