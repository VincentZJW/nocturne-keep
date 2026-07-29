# Chapter III render-layer repair — L1 structural repair

Date: 2026-07-29

Engine: Godot 4.7.1 Standard (`a13da4feb`)

Scope: structural draw-order repair and automated effective-z verification. The full action-pose screenshot matrix remains L2.

## Result

| Item | Status | Evidence |
|---|---|---|
| Shared production contract | PASS | `docs/production/render_layer_contract.md`, `RenderLayerContract` |
| Four ordinary room doors | PASS | complete panels effective z=-30; prompts effective z=14 |
| Last Vigil checkpoint regression | PASS | saved composite remains effective z=-30 |
| Thirteen Confessions checkpoint | PASS | composite changed from effective z=14 to -30 |
| Thirteenth Echo Boss gate | PASS | all three full panels effective z=-30; seal/crack FX effective z=16 |
| Duplicate world titles | PASS | five duplicate world titles hidden; persistent HUD remains authoritative |
| Underkeep water | PASS | 96-pixel water body behind actors plus four-pixel foreground surface |
| Dynamic pickups | PASS | spawned pickups receive Drop z=13 before positioning |
| Chapter III projectile/field | PASS | spawned gameplay FX receive CombatFX z=16 |
| Y-sort | PASS | zero enabled nodes in the affected structures |
| Full visual/action acceptance | PENDING L2 | not claimed in L1 |

## Effective-z changes

| Structure | Before | After |
|---|---:|---:|
| Vestibule NaveDoor full panel | 14 | -30 |
| Nave ChoirDoor full panel | 14 | -30 |
| Choir CheckpointDoor full panel | 14 | -30 |
| Last Vigil ConfessionDoor full panel | 14 | -30 |
| Antechamber CheckpointVisual | 14 | -30 |
| Boss gate Closed/Lit/Open composites | 14 | -30 |
| Boss gate seal lights / wax crack | 14 inherited | 16 |
| Spawned pickup | implicit 0 | 13 |
| Spawned projectile / timed field | implicit 0 | 16 |
| Underkeep water body | 20 | -30 |
| Underkeep surface edge | part of 96 px sprite at 20 | cropped 4 px sprite at 20 |

Player remains z=12, enemies remain z=10 and the equipped Player weapon remains effective z=13. No global Player escalation was used.

## Door structure

All four ordinary doors now use the same shape:

```text
DoorAuthority (Area2D, z=0)
├── Presentation (Node2D, z=-30)
│   └── DoorVisual (moving Sprite2D)
├── Interaction (Node2D, z=14)
│   └── Prompt
├── Blocker
└── Detection CollisionShape2D
```

The existing script still animates only `DoorVisual`, disables the same blocker and emits the same room-transition request. Destination IDs, collision dimensions and opening durations were not changed.

## Boss-region structure

- `BossAntechamber/CheckpointVisual` is behind actors. The persistent HUD room label remains the name authority.
- `BossGate/Visuals` is behind actors. `GateClosed`, `GateLit`, `GateOpen` and bells inherit -30; the compact seal lights and wax crack add +46 and resolve to CombatFX z=16.
- `GateName`, antechamber `AreaTitle`, `SanctumTitle`, post-Boss `AreaTitle` and underkeep `AreaTitle` remain saved for reference but are hidden. Room names continue through `PersistentRuntime/ChapterRuntime/HUD/RoomName` on CanvasLayer 1.
- Boss gate blocker, input threshold, thirteen-bell sequence, fade and room swap are unchanged and pass the R4 regression.

## Underkeep water

Each previous 768×96 foreground composite is split into:

- a full `WaterBodyBehind` at z=-30;
- an `AtlasTexture` surface crop measuring 768×4 at z=20 and y=614.

This makes the maximum intended foreground coverage four pixels at the floor contact line instead of covering the lower body.

## Automated verification

1. Exact Godot 4.7.1 editor import/parse: exit 0; no parse or missing-resource error.
2. `test_chapter_03_render_layers_l1.gd`: PASS — four doors, checkpoint, three Boss gate states, five duplicate titles, two water surfaces, live Drop and CombatFX spawns, zero Y-sort.
3. Regenerated runtime audit through MainBootstrap: PASS — `rooms=8 canvas_items=421 anomalies=0 unknown_visible=0 drawable=151 y_sort=0`.
4. Updated R3 layer/collision regression: PASS — stair/platform alignment, door blocker and actor bands retained.
5. R4 Boss flow regression: PASS — checkpoint, E gate, room swap, intro, post-Boss and underkeep hooks retained.
6. R5 full-route regression: PASS — 40 transitions / 10 cycles, persistent runtime and platform combat retained.

Post-repair machine evidence:

- `docs/qa/chapter_03_render_layer_l1/runtime_layer_audit_after_l1.tsv`
- `docs/qa/chapter_03_render_layer_l1/anomaly_inventory_after_l1.tsv`
- `docs/qa/chapter_03_render_layer_l1/scene_inventory_after_l1.tsv`

## L2 stop gate

L1 structural repair is complete. L2 must enter Main/F5 and capture the supplied four viewpoints plus the additional three doors and underkeep water while exercising idle, movement, jump/fall, attack, dash, hurt, death/ghost, open/closed door states, pickups and combat FX. No final visual acceptance is claimed before that matrix passes.
