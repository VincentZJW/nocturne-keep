# The Night Warden — Pixel Character Specification

Version: 1.0 concept baseline
Date: 2026-07-21
Status: selected Concept C direction; awaiting visual approval

## Scope

This document defines the pre-M1 visual concept for **The Night Warden / 夜巡守卫**. It is a static 16-bit-inspired character study, not a final sprite sheet and not a gameplay implementation. No player controller, combat combo, state machine, input mapping, or Main-scene integration is included.

## Character direction

The Night Warden is a compact, right-facing gothic assassin entering a cursed keep to investigate and hunt the source of its corruption.

Design priorities:

1. A pointed black hood remains readable at 48px.
2. The torso, arms, two legs, and weapons stay visually separated.
3. The longer main dagger establishes the forward/right direction.
4. The shorter offhand dagger sits behind the body in reverse grip.
5. A short mantle provides motion potential without the cost of a long cape.
6. One muted-amber clasp is the only warm identification mark.

The silhouette must retain the hood, forward lean, short mantle, two legs, forward blade, and rear blade without relying on interior color.

## Production sizes

- Recommended gameplay sprite target: `64×64 px`.
- Minimum readability floor: `48×48 px`.
- Default facing: right.
- Future left-facing display: whole-sprite horizontal flip.
- Preview scaling: integer multiples only with nearest-neighbor filtering.
- Current deliverable: individual static PNG studies, not an animation atlas.

## Palette

| Token | Hex | Use |
| --- | --- | --- |
| `HOOD_BLACK` | `#08101A` | Hood, boots, deepest face and garment shadows |
| `MIDNIGHT_NAVY` | `#172B3D` | Torso, sleeves, leggings, dagger grips |
| `MOONLIT_SLATE` | `#607A90` | Bracers, chest segmentation, shoulder structure, blade lowlight |
| `PALE_STEEL` | `#D5DEE3` | Blade faces, eye glints, critical silhouette accents |
| `MUTED_AMBER` | `#B98243` | One small clasp and dagger pommel accents |

No palette adjustment was made from the requested values. An additional near-black `#04080D` is used only as face-cavity shadow, and `#F2F5F6` is a one-pixel blade highlight; neither functions as a new costume color.

## Asset inventory

| File | Dimensions | Purpose |
| --- | ---: | --- |
| `assassin_front_64.png` | 64×64 | Front construction and bilateral limb separation |
| `assassin_side_64.png` | 64×64 | Default right-facing gameplay concept |
| `assassin_silhouette_64.png` | 64×64 | One-color silhouette readability test |
| `dagger_main.png` | 40×16 | Longer forward-grip main weapon profile |
| `dagger_offhand.png` | 32×16 | Shorter reverse-grip offhand profile |
| `assassin_front_48.png` | 48×48 | Minimum-size front readability test |
| `assassin_side_48.png` | 48×48 | Minimum-size side readability test |
| `palette_preview.png` | 160×32 | Exact five-color palette strip |
| `assassin_idle_pose.png` | 64×64 | Static idle key-pose study |
| `assassin_attack_anticipation.png` | 64×64 | Pre-attack load and blade separation study |
| `assassin_dash_pose.png` | 64×64 | Low, extended dash key-pose study |

All character and weapon PNGs have transparent backgrounds and binary alpha edges.

## Dagger contract

- Main hand: longer blade, forward/right, conventional grip, pale-steel face.
- Offhand: shorter blade, behind/left of the body, reverse grip.
- Both weapons share the same guard, grip, amber pommel, steel face, and slate lowlight language.
- The two weapons must never fully overlap the torso or each other.
- The planned basic attack may show a main-hand slash followed by a quick offhand follow-through, but this remains one gameplay attack and is not a combo system.

## Animation planning

| Animation | Suggested frames | Key requirement |
| --- | ---: | --- |
| Idle | 6–8 | Readable ready pose; minimal hood and mantle settle |
| Run | 8–10 | Forward lean; hands remain uncrossed |
| Jump Start | 3–4 | Compress, blades close, clear lift |
| Jump Loop | 4–6 | Compact air silhouette |
| Fall | 3–5 | Open downward silhouette; keep weapon gaps |
| Land | 4–6 | Low contact and short recovery |
| Attack | 8–10 | Main slash and offhand follow-through in one action |
| Dash | 5–7 | Low profile, both blades tucked away from legs |
| Hurt | 3–5 | Preserve hood and weapon readability during recoil |
| Death | 10–14 | Controlled collapse; one optional dropped blade |

Key poses should be approved before in-between frames. Final sprite production should use Aseprite or an equivalent dedicated pixel-animation tool.

## Godot generation architecture

- `pixel_art_canvas.gd`: clipped pixel rectangles, Bresenham pixel lines, silhouette conversion, nearest-neighbor resize and compositing helpers.
- `pixel_character_generator.gd`: owns the character palette, anatomy clusters, pose construction, dagger profiles, and PNG output.
- `character_board_exporter.gd`: builds the 1600×1000 concept board inside an isolated `SubViewport` and saves it as PNG.
- `character_design_lab.gd`: orchestrates generation and populates the internal preview UI.
- `character_design_lab.tscn`: independently runnable internal design scene; it is not the project Main scene.

## Pixel import and display rules

- Project setting `rendering/textures/canvas_textures/default_texture_filter=0` selects Nearest filtering.
- Every generated PNG import sidecar records `compress/mode=0` (Lossless).
- Every generated PNG import sidecar records `mipmaps/generate=false`.
- Preview `TextureRect` nodes explicitly use `CanvasItem.TEXTURE_FILTER_NEAREST`.
- Preview sizes are exact integer multiples of source dimensions.
- The validator compares imported visible RGBA pixels against the PNG source and rejects partial-alpha pixels.

## Running the tool

Open `scenes/tools/character_design_lab.tscn` and run the current scene (`F6`), or execute:

```bash
"/Users/USER/Downloads/Godot.app/Contents/MacOS/Godot" --path . scenes/tools/character_design_lab.tscn
```

The scene auto-generates on startup. Its button regenerates all PNGs and the design board. For non-rendering automation, pass `-- --generate-only --skip-board`; the board export requires a rendering display.

## Decisions awaiting approval

1. Whether the hood point should be sharper or slightly shorter.
2. Whether the single eye glint should remain one-pixel-wide in side view.
3. Whether the chest armor should retain the current symmetrical front segmentation.
4. Whether the offhand blade should angle farther downward in the final idle pose.
5. Whether 64px remains the production target before any full animation work begins.
