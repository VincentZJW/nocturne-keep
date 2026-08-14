# Drowned Saints Descent / 溺圣下行道

## Narrative purpose

This enemy-free 15–30 second buffer carries the Player from the Chapter III reliquary through drowned chapel drainage and an ossuary converted into a prison threshold. Chapel ribs, a Bell Saint and a drowned reliquary establish the sacred layer; drains, waterlines, rusted bars and the final black gate introduce Chapter IV's carceral language.

## Saved route

`MainBootstrap -> Chapter03Route -> CH3_POST_BOSS -> CH3_UNDERKEEP_DESCENT -> CH4_START`

- Area: `res://chapters/chapter_03_chapel_of_thirteen_echoes/scenes/areas/ch3_underkeep_descent.tscn`
- Room: `res://chapters/chapter_03_chapel_of_thirteen_echoes/scenes/rooms/ch3_underkeep_room.tscn`
- Chapter IV threshold: `res://chapters/chapter_04_drowned_underkeep/scenes/level/drowned_underkeep.tscn`

The Chapter IV scene is a formal landing/threshold, not a claim that the complete Chapter IV map exists.

## Composition

| Layer | z | Content |
|---|---:|---|
| Far architecture | -100 | damp bricks, chapel ribs, cracks and drains |
| Narrative props | -35 | collapsed beam, reliquary, Bell Saint, bars and gate |
| Water bed/body | -32/-25 | flooded stone bed and four-frame body |
| Rear surface/highlight/foam | 8/9/10 | six-frame wave edge, four-frame reflection and local drain foam |
| Player | 12 | formal persistent runtime |
| Front water edge | 13 | four pixels only; feet/lower-ankle occlusion budget |
| Reactions | 15–23 | local ripples, steps, splash and drip impact |
| Prompt | 30 | bounded E interaction label |

No water layer uses CanvasLayer or Y-sort. Props are presentation only and introduce no hidden blockers.

## Shallow-water contract

- Water is not swimming, mud or a movement modifier.
- `WaterInteractionArea` is Area2D layer 0/mask 2, monitoring Player only.
- Player stands on the unchanged continuous floor (top y=612).
- Run, jump, double jump, Ground/Air Dash, Normal Attack, Dash Attack, hurt, pickups and exit interactions retain their existing gameplay authority.
- Step reactions use a 0.24-second cadence above 35 px/s. Jump, double jump, landing and dash animation signals request one-shot five-frame effects.
- Transient Player effects cap at ten and self-delete. Three randomized drip points run only while this saved room exists, each creating one drop, one five-frame impact ripple and one short positional sound.

## Asset ownership

All new Chapter III assets live below:

`res://chapters/chapter_03_chapel_of_thirteen_echoes/assets/environment/water_transition/`

- `water/water_bed`: one 2304x108 flooded-floor image.
- `water/water_body`: four 768x108 loop frames.
- `water/water_surface`: six 768x16 rear frames and six 768x4 front frames.
- `water/highlights`: four restrained reflection frames.
- `water/foam`: four local drain-foam frames.
- `water/ripples` and `water/splashes`: ripple, step, dash and landing one-shots.
- `props`: eight drainage/ossuary/prison silhouettes.
- `fx/dripping_water`: one 8x16 drop.

The deterministic source is `scripts/tools/generate_underkeep_transition_assets.gd`. PNG imports use lossless compression with mipmaps disabled, and runtime textures use nearest filtering.

## Collision contract

| Node | Collision | Result |
|---|---|---|
| former `OssuaryStairs` | none | node, source/derived PNGs and generator references deleted |
| `Floor/CollisionShape2D` | StaticBody2D layer 1; 2304x108 | unchanged continuous walk surface |
| `WaterInteractionArea` | Area2D layer 0/mask 2 | detects Player; never blocks |
| submerged props | none | readable scenery without air walls |
| `ChapterFourExitArea` | Area2D layer 0/mask 2 | E prompt/transition only |

## Performance budget

- 14 lightweight looping Sprite2D layers share imported textures; no per-tile ShaderMaterial exists.
- Player reaction instances cap at ten and last five frames.
- Three asynchronous drip points are the only timed ambient emitters.
- Leaving the room destroys the complete area and its timers/effects through the existing one-room RoomHost authority.
