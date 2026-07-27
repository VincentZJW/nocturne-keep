# Chapter II world layering specification

## Live hierarchy

```text
SilentCourt
|- FarBackground                 z=-100 absolute
|- MidBackground                 z=-80 absolute
|- BackArchitecture              z=-60 absolute
|- GroundBackFill                z=-30 absolute
|- GameplayWorld
|  |- Geometry/Rooms             room backdrop z=-60 absolute
|  |- PropsBehindActors          z=-10 absolute
|  |- Enemies                    z=10 absolute
|  |- PlayerAnchorOrRuntimeActors/ChapterRuntime/Player  z=12 absolute
|  |- Pickups                    z=14 absolute
|  |- Projectiles, Effects       z=16 absolute
|  `- BossArea                   z=10 absolute
|- GroundFrontEdge               z=20 absolute
|- PropsInFrontOfActors          z=25 absolute
|- Foreground                    z=30 absolute
`- Debug                         z=100 contract
```

The shared HUD is the only gameplay CanvasLayer. Player and Enemy are in the same world canvas. No room, actor container or level root enables Y-sort; explicit absolute z values are authoritative.

## Root cause and repair

Previously each room root drew the complete backdrop, masonry, 108 px ground fill, raised-route fill and edge in one default-z CanvasItem. Five enemies were unrelated root siblings in `Phase2EnemyPrototypeShowcase`, also at z=0, and used hand-entered old single-floor positions. Player's visual children happened to be z=1/2. That accidental ordering produced a readable Player and enemies visually merged into the ground.

Room backdrops are now z=-60. Their large ground fill stays behind actors; `WalkableSurfaceTrim` is a separate absolute z=20 child only three pixels high. Enemy instances have one authoritative z=10 parent, and Player is absolute z=12. No large foreground polygon can cover an actor body.

## Spawn contract

- Encounter definitions store global surface/ceiling/air positions.
- Runtime enemies are always children of `GameplayWorld/Enemies/EncounterE##`.
- Ground actor origin conversion is `foot_position + Vector2(0,-28)` exactly once.
- Marker metadata preserves `authored_foot_position` and `spawn_uses_global_position=true` for QA.
- Hanging and flying actors bypass the ground offset.
- Live visible-collision evidence verifies the Banquet floor at y=612 and a Retainer origin near y=584.5 after physics settling.

Evidence: `res://docs/qa/chapter_02_three_floor/13_visible_collision_layer_audit.png`.
