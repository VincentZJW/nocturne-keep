# First-Level Environment Art Specification

Version: 2.0
Last updated: 2026-07-24

## Direction and provenance

The complete first level is one original 16-bit-inspired Gothic journey rather than separate gray boxes: cursed wilderness and dark forest outskirts gradually yield to a ruined castle frontier, fortified outer walls, a moat bridge and the pointed Ravenmourn stronghold. The shared palette is deep navy night, desaturated forest green, brown-gray earth, cold gray masonry, restrained blue moon edges, sparse amber windows, black iron and weathered timber. It uses only project-authored Godot native 2D drawing and saved scene nodes—no downloaded, provenance-unknown or copied commercial-game art.

Gameplay readability is the first constraint. Background masonry stays darker and less saturated than Player/enemy silhouettes; foreground detail stays below feet or inside existing surfaces. Decorative cracks, planks and missing edges never change collision.

## Visual progression

| Span | Theme | Saved Main authority |
| --- | --- | --- |
| x≈0..2100 | `Dark Forest Outskirts`: moonlit tree sea, twisted dead trees, mist, dirt/stone road, weeds, brambles, fence/sign/cart/grave remnants | `World/DarkForestOutskirtsArt`, `World/OutskirtsSurfaceDetails`, encounters 01..03 and `PlatformA` |
| x≈2100..3900 | `Castle Frontier`: forest thins while watch-post ruins, low walls, broken iron gate and distant spires increase | `World/CastleFrontierTransitionArt`, encounters 03..05, `PlatformB`, `GargoylePerch` |
| x≈3560..5520 | fortified approach: navy castle sky, towers, battlements, outer walls, stone road/platforms, chains | `World/LateLevelApproachArt`, `World/LateLevelSurfaceDetails`, encounters 05..07, `PlatformC/D` |
| x≈5520..6624 | moat, reinforced bridge, monumental pointed fortress, main gate and Boss | `World/CastleEntranceArea`, `World/BossCastleBackdrop` |

The spans intentionally overlap. Forest silhouettes continue behind the first ruins; distant spires appear before the masonry-dominant approach; the late walls lead directly into the moat banks and fixed gatehouse. This prevents a hard visual cut while making proximity to the castle legible.

## Saved F5 Main layers

| Purpose | Saved path | Content |
| --- | --- | --- |
| Early sky/far/mid depth | `Main/World/DarkForestOutskirtsArt` | layered navy/green-black sky, pixel-edged moon, clouds, far tree boundary, pines, twisted tree silhouettes, mist and distant roadside ruins |
| Early/middle surface and foreground | `Main/World/OutskirtsSurfaceDetails` | earth road, cobbles, weeds, brambles, PlatformA/B joints, broken fence, sign, cart wheel and grave stones; always behind actors |
| Frontier transition | `Main/World/CastleFrontierTransitionArt` | thinning forest, distant three-spire silhouette, broken watch post, low outer wall and iron gate remains |
| Late approach depth | `Main/World/LateLevelApproachArt` | navy sky bands, cloud bands, five distant towers, spires, battlements, two broken mid-walls, arches and restrained windows |
| Play-surface detail | `Main/World/LateLevelSurfaceDetails` | stone courses, platform joints, rubble, weeds and hanging chains around Group06/07 |
| Destination landmark | `Main/World/RavenmournArchway` | non-blocking iron pointed arch and `RAVENMOURN CASTLE` nameplate |
| Boss fortress | `Main/World/BossCastleBackdrop` | far flanking towers, layered bastions, high central four-tower spire crown, vertical keep, buttresses, Gothic windows, widened gatehouse and threshold steps |
| Bridge detail | `Main/World/CastleEntranceArea/WoodenBridge/DetailedBridgeArt` | twenty timber planks, wear, rivets, supports, low posts and sagging chain rails |
| Moat detail | `Main/World/CastleEntranceArea/Moat/MoatAtmosphere` | vertical fortress reflections, varied ripples and bank foam seams |
| Moving gate | `Main/World/CastleEntranceArea/CastleGate/GateVisual/DetailedGateArt` | 88×260 visual oak/iron main gate, five planks/bars, heavy bands, side chains, rivets, crest, ring and portcullis teeth |

The arch is a wayfinding/art node with no CollisionObject2D child. The battle-only `RearBattleBarrier` remains separate: its old opaque slab is replaced by a narrow curse line and crossing chains, and it appears/collides only during the locked Boss encounter.

## Castle and arena composition

The fortress silhouette begins left of the physical gate so it remains legible inside the saved Boss camera limits rather than appearing as a clipped right-edge rectangle. Uneven far towers, left bastion, the broad body and a four-tower pointed crown establish a clear left/right tower + central keep hierarchy. The tallest central spire and finial reinforce Gothic verticality while retaining stepped 16-bit-inspired edges. The gatehouse stays aligned to the authoritative gate at x=6400. Cold windows establish depth, while sparse amber/metal accents create contrast without competing with attacks.

The bridge remains centered at `(5960,650)` with its unchanged 800×20 full-solid collider. The blue/teal moat remains x=5520..6360 with the unchanged 840×104 hazard. Visual posts and chains are low enough to preserve attack silhouettes. Water layers render below bridge art and use horizontal highlights/vertical reflections to read as water during a fall.

## Gate and completion presentation

Boss alive: the 88-pixel-wide detailed portcullis is visibly closed and `GateCollision` remains the unchanged 48×260 World-solid authority. The visual overhang sits inside the widened stone frame and never creates a false side passage.
Boss defeated: after the existing death animation completes, the rear seal opens and the gate rises 240 pixels over 1.20 seconds with cubic weight. Collision remains active until `gate_opened`.  
Gate open: the black threshold is visible, the entrance trigger enables and Player control continues. No `LevelCompletePanel`, gate-open message, chapter title or victory copy is displayed.  
Entrance: `Main/CastleEntranceTransition` performs a 0.55-second text-free fade and loads `res://scenes/transitions/ravenmourn_threshold.tscn`, an art-only interior placeholder with no Label nodes and no second-level combat.

## Scope guard

All environment renderers are collision-free custom-draw `Node2D` composition. Main still contains no TileMap/TileMapLayer or Parallax node; the current depth is authored through ordered world-space sky, far, mid, play-surface and restrained foreground layers. Boss/Player/enemy values, attacks, AI, encounter counts, Camera limits, bridge/floor/platform collision, MoatHazard behavior, respawn, HUD data and second-level gameplay remain unchanged.
