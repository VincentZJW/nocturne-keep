# First-Level Environment Art Specification

Version: 1.0  
Last updated: 2026-07-24

## Direction and provenance

The first-level late route is an original 16-bit-inspired Gothic fortress approach: deep navy night, cold gray masonry, restrained blue moon edges, sparse amber windows, black iron and weathered timber. It uses only project-authored Godot native 2D drawing and saved scene nodes—no downloaded, provenance-unknown or copied commercial-game art.

Gameplay readability is the first constraint. Background masonry stays darker and less saturated than Player/enemy silhouettes; foreground detail stays below feet or inside existing surfaces. Decorative cracks, planks and missing edges never change collision.

## Saved F5 Main layers

| Purpose | Saved path | Content |
| --- | --- | --- |
| Late approach depth | `Main/World/LateLevelApproachArt` | navy sky bands, cloud bands, five distant towers, spires, battlements, two broken mid-walls, arches and restrained windows |
| Play-surface detail | `Main/World/LateLevelSurfaceDetails` | stone courses, platform joints, rubble, weeds and hanging chains around Group06/07 |
| Destination landmark | `Main/World/RavenmournArchway` | non-blocking iron pointed arch and `RAVENMOURN CASTLE` nameplate |
| Boss fortress | `Main/World/BossCastleBackdrop` | multi-layer towers, keep, spired roof, buttresses, Gothic windows, gatehouse and threshold steps |
| Bridge detail | `Main/World/CastleEntranceArea/WoodenBridge/DetailedBridgeArt` | twenty timber planks, wear, rivets, supports, low posts and sagging chain rails |
| Moat detail | `Main/World/CastleEntranceArea/Moat/MoatAtmosphere` | vertical fortress reflections, varied ripples and bank foam seams |
| Moving gate | `Main/World/CastleEntranceArea/CastleGate/GateVisual/DetailedGateArt` | oak planks, iron bands/bars, rivets, crest and portcullis teeth |

The arch is a wayfinding/art node with no CollisionObject2D child. The battle-only `RearBattleBarrier` remains separate: its old opaque slab is replaced by a narrow curse line and crossing chains, and it appears/collides only during the locked Boss encounter.

## Castle and arena composition

The fortress silhouette begins left of the physical gate so it remains legible inside the saved Boss camera limits rather than appearing as a clipped right-edge rectangle. Left bastion, far towers and main keep frame the Player/Boss; the gatehouse stays aligned to the authoritative gate at x=6400. Cold windows establish depth, while two small amber windows create contrast without competing with attacks.

The bridge remains centered at `(5960,650)` with its unchanged 800×20 full-solid collider. The blue/teal moat remains x=5520..6360 with the unchanged 840×104 hazard. Visual posts and chains are low enough to preserve attack silhouettes. Water layers render below bridge art and use horizontal highlights/vertical reflections to read as water during a fall.

## Gate and completion presentation

Boss alive: the detailed portcullis is visibly closed and `GateCollision` remains World-solid.  
Boss defeated: after the existing death animation completes, the rear seal opens and the gate rises 240 pixels over 1.20 seconds with cubic weight. Collision remains active until `gate_opened`.  
Gate open: the black threshold is visible, the entrance trigger enables and Player control continues. No `LevelCompletePanel`, gate-open message, chapter title or victory copy is displayed.  
Entrance: `Main/CastleEntranceTransition` performs a 0.55-second text-free fade and loads `res://scenes/transitions/ravenmourn_threshold.tscn`, an art-only interior placeholder with no Label nodes and no second-level combat.

## Scope guard

This pass changes presentation and the already-approved post-Boss scene transition only. Boss/Player/enemy values, attacks, AI, encounter counts, Camera limits, bridge/floor/platform collision, MoatHazard behavior, respawn, HUD data and second-level gameplay remain unchanged.
