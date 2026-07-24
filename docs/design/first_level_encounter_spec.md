# First Level Encounter Specification

Version: 1.0
Last updated: 2026-07-24

F5 Main uses seven one-shot ActivationAreas and exactly eighteen normal enemies before the separate castle-bridge Boss encounter.

| Group | Activation center | Roster | Purpose |
| --- | --- | --- | --- |
| 01 | `(430,470)` | Guard ×2 | baseline movement/attack teaching |
| 02 | `(1120,470)` | Guard ×2, Spearman ×1 | introduce long thrust |
| 03 | `(1960,470)` | Shield Guard ×1, Guard ×1 | shield routing and rear approach |
| 04 | `(2670,470)` | Crossbowman ×1 at `(2780,470)`, Guard ×1 | reachable PlatformB ranged pressure |
| 05 | `(3370,430)` | Gargoyle ×2 at `(3500,402)` / `(3620,402)` | reachable-perch Dive teaching |
| 06 | `(4120,430)` | Shield ×1, Spear ×1, Crossbow ×1 at `(4420,474)` | three-role mastery check |
| 07 | `(4880,430)` | Gargoyle ×1, Guard ×2, Crossbow ×1 at `(5160,478)` | final normal mixed encounter |

Counts: Guard 8, Shield 2, Spear 2, Crossbow 3, Gargoyle 3. Groups are separated by safe travel space; Group07 alone permits four simultaneous actors. Pre-activation AI/detection remains paused. The `CastleEntranceArea` wooden bridge contains no normal enemies.

First appearances isolate each new mechanic before combinations. PlatformB/C/D top surfaces are y=500/504/508 and `GargoylePerch` is y=492; all are now full solid 24-pixel stone bodies, reached from their edges rather than passed through from below. Crossbowmen retain centered edge margins and clear horizontal sightlines. Shield Guards still have room to circle, Spearmen retain a full thrust length, and the solid Floor-to-Bridge route remains the no-Air-Dash route into every encounter and the Boss fight.

The Boss segment is saved at `World/CastleEntranceArea`: checkpoint `(5480,612)`, continuous bridge x=5560..6360, trigger x=5780, Boss `(6120,596)`, visible rear barrier x=5420, and castle gate x=6400. Only the Boss occupies the bridge; its logical movement range is x=5650..6320. The barrier leaves the checkpoint and marked 40-pixel moat entry gap inside the live arena so the moat death/reset path remains testable.
