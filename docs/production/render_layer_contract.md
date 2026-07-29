# Production render-layer contract

This contract governs world-space `CanvasItem.z_index` values. Screen-space HUD, fades and cinematic overlays must use an explicit `CanvasLayer` and do not participate in this table.

| z | Category | Rules |
|---:|---|---|
| -100 | Far background | Backdrops and distant scenery; never collides or obscures actors. |
| -60 | Background architecture | Walls, arches and rear door frames. |
| -30 | Props behind actors | Furniture, door panels, checkpoints and water bodies that actors must pass in front of. |
| -10 | Ground visual | Floor artwork paired with separately owned collision. |
| 0 | Platforms | Walkable platform artwork and geometry roots. |
| 10 | Enemies | Authoritative enemy actor roots. |
| 11 | NPCs | Non-hostile world actors. |
| 12 | Player | Authoritative Player actor root. |
| 13 | Drops | Collectible pickups; explicitly assigned when spawned. |
| 14 | Interactables | Small prompts or compact interaction cores only. Never an entire door, statue or checkpoint composite. |
| 16 | Combat FX | Projectiles and gameplay-significant attack/field presentation. |
| 20 | Limited foreground | Narrow atmospheric trim only; may cover at most 0–4 pixels of an actor's feet. |

## Structural rules

- Fixed architecture must not use Y-sort. Actor roots use explicit z values and remain siblings of room presentation where practical.
- `z_as_relative` may remain enabled only when the effective parent-plus-child value still matches this contract. Tests must validate effective z, not only the local property.
- A door separates collision/interaction authority from presentation. Rear frame and moving panel stay behind actors; only the prompt, seal glow or a narrow trim may render at or above z=14.
- Full-height foreground sprites are prohibited. Water, fog and railings must split their body behind actors from a tightly cropped foreground edge.
- Dynamic spawns must receive their layer before the first rendered frame. Drops use z=13; gameplay projectiles and timed fields use z=16.
- Room/area names belong to the persistent HUD. Duplicate world-space title panels must remain hidden or be removed.
- Raising Player above defective scenery is not an accepted repair because it breaks enemy, drop, FX and death-presentation ordering.
