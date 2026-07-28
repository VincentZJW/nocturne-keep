# The Candle Warden — Stage 3 Art and Presentation Specification

## Scope

Stage 3 replaces the Prologue's geometric placeholder NPC with one formal, reusable presentation scene. It does not change Player gameplay, combat, chapter geometry, enemies, bosses, or the 27-line bilingual narrative text. Stage 4 remains the separate strong visual-QA gate.

## Character direction

The Candle Warden is the gaunt keeper of the Severed Soul Altar: possibly living, possibly already dead, quiet rather than hostile. The readable anchors are a split funerary mask beneath a deep hood, layered and frayed ritual robes, crossed bindings and wax seal, an old key ring, and a formed dark-iron lantern carrying a restrained cold-blue soul flame.

- Runtime canvas: `80×80` transparent pixels, nearest-neighbour filtering.
- Measured idle height: 105–120% of the accepted Player idle height (enforced by test).
- Palette: blue-black cloth, weathered slate, bone/old-metal mask, muted leather and wax, cold cyan soul light.
- Silhouette: narrow hood, long divided robe hem, lantern mass on one side and gesture/key hand on the other.
- Behaviour: story-only presentation; no combat, following AI, collision, or gameplay authority.

## Source and concept delivery

Root: `res://chapters/prologue_veilbound_catacomb/assets/npcs/candle_warden/`

Two original high-resolution masters are retained alongside ten named production crops:

- `concept_art/candle_warden_turnaround_master.png`
- `concept_art/candle_warden_gesture_cinematic_master.png`
- `concept_art/candle_warden_front_concept.png`
- `concept_art/candle_warden_side_concept.png`
- `concept_art/candle_warden_back_concept.png`
- `concept_art/candle_warden_silhouette.png`
- `concept_art/candle_warden_mask_design.png`
- `concept_art/candle_warden_lantern_design.png`
- `concept_art/candle_warden_key_design.png`
- `concept_art/candle_warden_gesture_sheet.png`
- `concept_art/candle_warden_scale_with_player.png`
- `concept_art/candle_warden_scene_composition.png`

Image-generation mode: built-in image generation, used only for original concept references. Runtime pixel frames were authored deterministically with Godot `Image` operations; no generated raster was downscaled into gameplay sprites.

Final concept prompt A: a polished original gothic 16-bit character-design turnaround board for The Candle Warden, showing front, side, back and black silhouette plus mask, blue-soul lantern, old key and scale against The Night Warden; tall gaunt proportions, split funerary mask, hood, layered frayed ritual robes, wax seals and bindings; restrained cold palette; no commercial-character imitation and no UI mock-up.

Final concept prompt B: a matching original gesture and cinematic composition sheet showing idle breathing, lantern idle, look at Player, quiet talk, key emphasis, point, warning, door opening, slow walk, return to shadow, soul-flame variations, altar reveal and two-character dialogue framing; readable side-view poses suitable for 80×80 pixel translation.

## Runtime resources

- Body frames: `candle_warden_sprite_frames.tres`
- Flame frames: `candle_warden_soul_flame_sprite_frames.tres`
- Body PNGs: `animations/<animation>/<animation>_NN.png`
- Lantern light: `effects/candle_warden_soul_light.png`
- Soul mote: `effects/candle_warden_soul_mote.png`
- Soul flame: `effects/soul_flame/soul_flame_01.png` … `06.png`
- Archived geometric implementation: `archive_legacy/candle_warden_geometric_v1.gd.txt`

There are 15 body animations / 65 body frames and one 6-frame looping flame animation:

| Animation | Frames | Role |
|---|---:|---|
| `seated` | 2 | altar-shadow starting pose |
| `rising` | 5 | controlled entrance |
| `idle` | 4 | restrained breathing |
| `lantern_idle` | 6 | robe/lantern secondary motion |
| `look_at_player` | 3 | deliberate head/torso acknowledgement |
| `talk` | 4 | quiet conversation |
| `talk_emphasis` | 4 | raised key/open palm on important lines |
| `gesture_point` | 4 | point toward castle/door |
| `gesture_warn` | 4 | lantern close, warning hand raised |
| `offer_key` | 4 | key presentation |
| `open_door` | 5 | key directed toward the rune lock |
| `slow_walk` | 6 | dragging robe and pendulum lantern |
| `raise_lantern` | 4 | soul-mark examination/emphasis |
| `turn_away` | 4 | controlled turn |
| `return_to_shadow` | 6 | retreat before presentation fade |

## Scene ownership and layering

- Formal scene: `res://scenes/npcs/candle_warden.tscn`
- Typed presentation: `res://scripts/npcs/candle_warden.gd`
- Formal Prologue instance: `VeilboundCatacomb/World/CandleWarden`
- Sequence controller: `res://scripts/levels/veilbound_catacomb_controller.gd`
- F5 authority: `res://scenes/bootstrap/main_bootstrap.tscn`
- Formal route: `MainBootstrap → OpeningCinematic → VeilboundCatacomb`

`VisualRoot/Body` is the 80×80 body layer. `VisualRoot/Lantern` is in front (`z_index = 3`) and contains `SoulFlame`, `SoulLight`, and `SoulMotes`. The Warden remains at world `z_index = 10`; dialogue remains on `CanvasLayer 20`, so world art never overlaps narrative UI.

## Dialogue and cinematic mapping

The bilingual text, speakers, durations, and order remain unchanged. Only cue values drive presentation:

- “七年 / Seven years”: lantern contemplation and temporary flame contraction.
- “替死者守门的人 / keeps the gate for the dead”: raised key emphasis.
- “你没有活过来 / You did not return to life”: look directly at Player.
- Soul/mark lines: warn or raise lantern; light pulses without saturating the scene.
- Castle, bell, road, knight and blade objectives: clear point gestures.
- Fourteenth toll: warning pose, brief flame contraction and restrained 4% camera push.
- Important bell/key lines: emphasis pose, brief light pulse and restrained 4% camera push.
- Door interaction: `offer_key → open_door`, synchronized to rune response.
- Exit transition: play `return_to_shadow` before the existing fade.

The camera begins on the altar, eases toward the Warden on reveal, frames Player and Warden together for dialogue, performs only restrained important-line pushes, and returns to normal Player follow when story control is granted.

## Regeneration

Deterministic runtime assets can be regenerated with:

```bash
/Users/vincentz/Downloads/Godot.app/Contents/MacOS/Godot --headless --path . --script res://scripts/tools/generate_candle_warden_stage_3_assets.gd
/Users/vincentz/Downloads/Godot.app/Contents/MacOS/Godot --headless --editor --path . --quit
/Users/vincentz/Downloads/Godot.app/Contents/MacOS/Godot --headless --path . --script res://scripts/tools/build_candle_warden_stage_3_sprite_frames.gd
```

The concept masters are intentionally not regenerated by these commands.

## Stage 3 acceptance boundary

Implementation, integration, parsing, focused contracts, Prologue flow regression, MainBootstrap route and eight formal-Prologue captures are complete. Final pass/fail grading against the dedicated Candle Warden strong-QA matrix belongs to Stage 4 and requires separate approval.
