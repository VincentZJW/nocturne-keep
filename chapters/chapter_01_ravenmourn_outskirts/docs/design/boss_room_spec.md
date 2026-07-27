# Castle Bridge Boss Room Specification

Version: 2.3
Last updated: 2026-07-26

## Saved F5 Main composition

The only shipping source is `res://chapters/chapter_01_ravenmourn_outskirts/scenes/level/ravenmourn_outskirts.tscn` under `Main/World/CastleEntranceArea`.

| Element | Saved path / coordinate | Contract |
| --- | --- | --- |
| Boss checkpoint | `BossCheckpoint` `(5480,612)` | near bank, before bridge |
| Checkpoint trigger | `BossCheckpointTrigger` `(5480,560)` | selects respawn; restores HP/Stamina before an uncleared encounter |
| Moat | `Moat` x=5520..6360 | deep blue/teal Gothic water; 40-pixel exposed entry gap plus unchanged hazard below bridge |
| Bridge | `WoodenBridge` center `(5960,650)`, 800×20 | continuous full-solid World collider; top y=640 |
| Boss trigger | `BossEntryTrigger` `(5780,430)` | about 27.5% into bridge |
| Rear barrier | `RearBattleBarrier` x=5420 | narrow chain/curse battle seal behind the checkpoint/near bank; only closed during live encounter |
| Boss | `FallenGateKnight` `(6120,596)` | bridge bounds x=5650..6320 |
| Castle gate | `CastleGate` `(6400,510)` | unchanged 48×260 closed World collider inside an 88×260 moving main-gate visual |
| Entrance trigger | `CastleEntranceTrigger` `(6428,510)` | enabled only after gate animation completion, just behind the opened gate |
| Transition | `Main/CastleEntranceTransition` | 0.55-second text-free fade to `ravenmourn_threshold.tscn` |

The saved non-blocking wayfinding structure is `Main/World/RavenmournArchway` at `(5420,640)`, marked `RAVENMOURN CASTLE`. It replaces the old slab as the permanent approach landmark. `RearBattleBarrier` remains a separate, narrow chain/curse battle seal and World collision only while the live encounter is locked; it is not the archway and is invisible before entry/after clear.

The former meaningless blocker was `Main/World/BossRoom/EntranceGate` at x=5630. The former `BossRoom`, `EntranceGate`, `ExitGate`, and `ExitTrigger` composition has been removed rather than hidden; Main now saves the bridge/castle composition above.

## Encounter and camera flow

1. Reaching the near-bank checkpoint selects `(5480,612)`. Entering the bridge trigger restores Player HP/Stamina, closes the visible rear barrier, keeps the castle gate closed, locks Camera limits to x=5340..6620, activates the Boss, and displays the signal-driven Boss HUD.
2. Boss movement and charge motion are clamped to x=5650..6320. These logical bounds do not create a Player collider. Approaching either edge cancels outward velocity; Player movement across the bridge is unaffected.
3. Player death or moat death runs the existing five-frame body collapse, dagger drop, ghost rise, 0.50-second ghost pause, then respawns at the checkpoint. An uncleared Boss restores Body 180, Shield 100, intact shield visuals, initial left facing, zeroed turn timers/cooldown and Phase 1; rear barrier reopens, castle gate closes, Camera limits release, and Boss HUD hides. Once the final Boss death completes, the Boss stays defeated and the permanent reward/gate state survives Player death.
4. `boss_defeated` is emitted only after the Boss death animation completes. The controller then opens the rear barrier, releases Camera limits, and starts the 1.20-second weighted raised-portcullis animation. Player control is not removed.
5. `GateCollision` remains enabled for the complete opening animation. Only `gate_opened` disables its World layer/collision and enables `CastleEntranceTrigger`. No gate-open, chapter-complete or victory text is displayed.
6. Crossing the enabled trigger emits the existing `level_completed` logic signal and asks the composed `CastleEntranceTransition` to fade for 0.55 seconds, then loads the minimal text-free `res://chapters/chapter_01_ravenmourn_outskirts/scenes/transitions/ravenmourn_threshold.tscn`. This is a visual threshold placeholder, not a developed second level.

Boss completion is persistent for the current Main instance: a later Player death does not revive the Boss or close the opened gate.

## Moat hazard

`Main/World/CastleEntranceArea/Moat/MoatHazard` is an `Area2D` with no solid layer and a PlayerBody/EnemyBody mask. It deals exactly the Player's remaining health once, then disarms until the existing respawn signal. A non-Boss enemy receives lethal component damage once; the Boss is ignored because its independent bridge bounds prevent entry. The hazard does not block attacks or act as floor collision. The continuous bridge provides the intended combat surface; the hazard remains below it for falls/forced test placement.

Presentation remains separate from hazard authority. `WaterVisual`, `WaterDepth`, `WaterSurfaceBand`, `WaterReflection`, `WaterRippleMid`, `WaterRippleFar`, `BridgeShadow`, `NearStoneBank`, `FarStoneBank`, and visual-only `MoatAtmosphere` are saved under the same `Moat` node. They provide readable blue depth, cold castle reflections, foam seams, restrained horizontal ripples, stone edges and a timber shadow without changing the Area2D shape, masks, bridge body or route geometry.

## Presentation limits

- `DetailedBridgeArt` builds twenty worn planks, rivets, cracked boards, underside supports, low iron posts and sagging chains over the unchanged continuous collision—decorative damage never creates hidden holes.
- `BossCastleBackdrop` draws a multi-layer fortress with unequal far towers, a high central four-tower spire crown, pointed roofs/finial, buttresses, Gothic windows, wall courses, a widened stone gatehouse and threshold behind the playable silhouettes. Its clear high-tower/central-keep/entrance hierarchy is structurally castle-like but remains an original dark Ravenmourn composition. The fixed `CastleFacade` collision still leaves the same readable doorway.
- `CastleGate/GateVisual/DetailedGateArt` is a moving 88×260 oak-and-iron portcullis with five planks/bars, heavier reinforcement bands, side chains, rivets, pointed lower teeth, crest and ring. Its collision authority deliberately remains the saved 48×260 `GateCollision`; opening distance/duration/clearance are unchanged.
- Gate opening plays a quiet, deterministic synthesized chain/stone placeholder from `GateAudio`; it uses no downloaded asset and remains replaceable by a licensed final sound.
- Boss HUD observes Body/Shield signals only and never mutates combat data.
- The configured Main Boss has no local Shield/turn/Attack-Gap/attack-geometry Inspector override. It inherits the reusable Boss scene's separate `ShieldBashHitbox`, `SlashHitbox` and `ThrustHitbox`, shared 100-point Shield, 0.33/0.80/0.14-second reaction/animation/cooldown values, 80% facing commit, 2.70-second Bash repeat cooldown and 22/43/35 Phase-1 weights. Main also inherits the seven 1.05–1.20-second per-skill gaps (Shield Bash 1.18) plus the unchanged 0.32-second light and 0.50-second heavy reaction cooldowns. The bridge bounds, checkpoint, trigger, Camera lock, Boss spawn `(6120,596)` and arena collision are unchanged.

## Chapter I narrative epilogue addendum

Main arena: `Main/World/CastleEntranceArea`
Controller: `Main/BossRoomController`

The existing bridge, rear battle barrier, camera lock, Boss reset, Health HUD, weighted gate, and castle threshold remain authoritative. No normal enemy from the 34-enemy roster is placed on the bridge.

On Boss body Health death, `BossLastWordsPresenter` displays once:

> 钟……认得你。
> The bell… remembers you.

The line is a small bottom-centered subtitle. It does not pause AI, delay or own the death animation, open the gate, or transition scenes. `BossRoomController` remains the only gate/threshold authority. A room reset clears the one-shot subtitle latch so the next valid fight can present it again.

After the death presentation, the gate opens with its existing 1.2-second weighted motion. Entering the enabled `CastleEntranceTrigger` invokes the existing text-free fade into `ravenmourn_threshold.tscn`; no second gameplay level is created.
