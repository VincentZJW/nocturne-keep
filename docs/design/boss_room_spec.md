# Castle Bridge Boss Room Specification

Version: 2.0
Last updated: 2026-07-24

## Saved F5 Main composition

The only shipping source is `res://scenes/main/main.tscn` under `Main/World/CastleEntranceArea`.

| Element | Saved path / coordinate | Contract |
| --- | --- | --- |
| Boss checkpoint | `BossCheckpoint` `(5480,612)` | near bank, before bridge |
| Checkpoint trigger | `BossCheckpointTrigger` `(5480,560)` | selects respawn; restores HP/Stamina before an uncleared encounter |
| Moat | `Moat` x=5520..6360 | deep blue/teal Gothic water; 40-pixel exposed entry gap plus unchanged hazard below bridge |
| Bridge | `WoodenBridge` center `(5960,650)`, 800×20 | continuous full-solid World collider; top y=640 |
| Boss trigger | `BossEntryTrigger` `(5780,430)` | about 27.5% into bridge |
| Rear barrier | `RearBattleBarrier` x=5420 | visible chain/curse slab behind the checkpoint/near bank; only closed during live encounter |
| Boss | `FallenGateKnight` `(6120,596)` | bridge bounds x=5650..6320 |
| Castle gate | `CastleGate` `(6400,510)` | visible 48×260 closed World collider |
| Entrance trigger | `CastleEntranceTrigger` `(6428,510)` | enabled only after gate animation completion, just behind the opened gate |

The former meaningless blocker was `Main/World/BossRoom/EntranceGate` at x=5630. The former `BossRoom`, `EntranceGate`, `ExitGate`, and `ExitTrigger` composition has been removed rather than hidden; Main now saves the bridge/castle composition above.

## Encounter and camera flow

1. Reaching the near-bank checkpoint selects `(5480,612)`. Entering the bridge trigger restores Player HP/Stamina, closes the visible rear barrier, keeps the castle gate closed, locks Camera limits to x=5340..6620, activates the Boss, and displays the signal-driven Boss HUD.
2. Boss movement and charge motion are clamped to x=5650..6320. These logical bounds do not create a Player collider. Approaching either edge cancels outward velocity; Player movement across the bridge is unaffected.
3. Player death or moat death runs the existing five-frame body collapse, dagger drop, ghost rise, 0.50-second ghost pause, then respawns at the checkpoint. An uncleared Boss restores Body 18, Shield 10, intact shield visuals, initial left facing, zeroed turn timers/cooldown and Phase 1; rear barrier reopens, castle gate closes, Camera limits release, and Boss HUD hides.
4. `boss_defeated` is emitted only after the Boss death animation completes. The controller then opens the rear barrier, releases Camera limits, and starts the 1.00-second raised-portcullis animation.
5. `GateCollision` remains enabled for the complete opening animation. Only `gate_opened` disables its World layer/collision and enables `CastleEntranceTrigger`; the message becomes `The castle gate is open. / 城堡大门已经开启。`.
6. Crossing the enabled trigger shows `CHAPTER I COMPLETE / 第一章完成`. No second-level scene is loaded or fabricated.

Boss completion is persistent for the current Main instance: a later Player death does not revive the Boss or close the opened gate.

## Moat hazard

`Main/World/CastleEntranceArea/Moat/MoatHazard` is an `Area2D` with no solid layer and a PlayerBody/EnemyBody mask. It deals exactly the Player's remaining health once, then disarms until the existing respawn signal. A non-Boss enemy receives lethal component damage once; the Boss is ignored because its independent bridge bounds prevent entry. The hazard does not block attacks or act as floor collision. The continuous bridge provides the intended combat surface; the hazard remains below it for falls/forced test placement.

Presentation remains separate from hazard authority. `WaterVisual`, `WaterDepth`, `WaterSurfaceBand`, `WaterReflection`, `WaterRippleMid`, `WaterRippleFar`, `BridgeShadow`, `NearStoneBank`, and `FarStoneBank` are saved Polygon2D layers under the same `Moat` node. They provide readable blue depth, cold reflections, restrained horizontal ripples, stone edges and a timber shadow without changing the Area2D shape, masks, bridge body or route geometry.

## Presentation limits

- Bridge art is gray-box old timber with a bright top edge, end chain posts, and continuous collision—decorative damage never creates hidden holes.
- Castle gate is a visible iron-barred slab, not an invisible wall. The facade is also solid and leaves a readable 80-pixel doorway; the completion trigger sits inside that doorway before the right tower collision.
- Gate opening plays a quiet, deterministic synthesized chain/stone placeholder from `GateAudio`; it uses no downloaded asset and remains replaceable by a licensed final sound.
- Boss HUD observes Body/Shield signals only and never mutates combat data.
- The configured Main Boss has no local Shield/turn Inspector override. It uses the shared 10-point Shield and 0.10/0.13/0.12-second reaction/animation/cooldown resource values directly.
