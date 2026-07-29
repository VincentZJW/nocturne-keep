# Chapter III render-layer repair — L0 runtime audit

Date: 2026-07-29

Engine: Godot 4.7.1 Standard (`a13da4feb`)

Scope: audit and evidence only; no formal scene layer was changed

## L0 result

| Item | Status | Evidence |
|---|---|---|
| Main/F5 entry resolved | PASS | `project.godot` -> `res://scenes/bootstrap/main_bootstrap.tscn` |
| Chapter III formal route resolved | PASS | MainBootstrap loads `res://chapters/chapter_03_chapel_of_thirteen_echoes/scenes/level/chapter_03_route.tscn` |
| Eight formal rooms loaded through RoomHost | PASS | `runtime_layer_audit.tsv` records every registered room |
| Four supplied screenshots located | PASS | exact scene and runtime node paths below |
| Whole Chapter III `.tscn` inventory | PASS | 26 scenes in `scene_inventory.tsv` |
| Runtime CanvasItem scan | PASS | 411 CanvasItems; 149 drawable; 0 visible drawable `Unknown` |
| Y-sort scan | PASS | 0 enabled runtime CanvasItems |
| Layer repair | NOT STARTED | prohibited in L0 |
| Final render-layer QA | FAIL / PENDING | three supplied defects reproduce; additional defects exist |

L0 itself is complete, but **the Chapter III render-layer repair has not passed final acceptance**. L1 structural repair, L2 Main verification, and L3 final QA have not been authorized or performed.

## Runtime route and current layer contract

The running hierarchy is:

```text
Chapter03Route
├── RoomHost
│   └── <one active Chapter03Room, replaced on transition>
└── PersistentRuntime
    └── ChapterRuntime
        ├── Player
        └── HUD (CanvasLayer layer=1)
```

The currently implemented Chapter III contract is:

| Effective z | Current category | Audit finding |
|---:|---|---|
| -100 | Far background | consistent |
| -60 | Background architecture | consistent |
| -30 | Props behind actors | consistent except one checkpoint asset |
| -10 | Ground visual | consistent |
| 0 | Platforms/walkable visuals | consistent for current rooms |
| 10 | Enemies | set again at runtime by `Chapter03Room` |
| 12 | Player | set again at runtime by transition controller |
| 14 | Interactables | unsafe when applied to an entire door/checkpoint composite |
| 20 | Limited foreground | two water strips use it, but exceed the allowed visual occlusion area |

The current class is `chapter_03_layer_contract.gd`. It does **not** yet define the required long-term NPC=11, Drop=13, or CombatFX=16 constants, and `docs/production/render_layer_contract.md` does not yet exist. Establishing that shared production contract is the first L1 action.

## A. Known problems from the four supplied screenshots

| Screenshot | True formal scene | Problem node (runtime path under `Chapter03Route`) | Runtime values | Current reproduction | Precise L1 repair |
|---|---|---|---|---|---|
| 1 — Chapel Vestibule central door | `scenes/rooms/ch3_chapel_vestibule.tscn` | `RoomHost/Ch3ChapelVestibule/Doors/NaveDoor/DoorVisual` | parent `NaveDoor` local z=14; visual local z=0; effective z=14; relative=true; Y-sort=false | CONFIRMED: Player z=12 is reduced to feet only | Remove presentation z from Area2D root. Split rear frame/backdrop to -60/-30, door panel behind actor, interaction core at 14, and only narrow trim if visually justified. Keep blocker/collision independent. |
| 2 — Last Vigil Checkpoint | `scenes/rooms/ch3_boss_checkpoint.tscn` | `RoomHost/Ch3BossCheckpoint/CheckpointVisual` | parent room z=0; local/effective z=-30; relative=true; Y-sort=false | NOT REPRODUCED on current HEAD: Player renders fully in front | Keep the current behind-actor placement and add it as an L2 regression point. Do not move it forward. The adjacent `ConfessionDoor` remains independently defective at z=14. |
| 3 — Thirteen Confessions checkpoint/saint base | `scenes/rooms/ch3_boss_ante_room.tscn` -> `scenes/areas/ch3_boss_antechamber.tscn` | `RoomHost/Ch3BossAnteRoom/BossAntechamber/CheckpointVisual` | parent `BossAntechamber` z=0; local/effective z=14; relative=true; Y-sort=false | CONFIRMED: only Player feet remain | Split the checkpoint into base/body at -30 and a small soul-flame/interaction FX at 14 or 16. The full 220x180 composite must not remain at 14. |
| 4 — Gate of the Thirteenth Echo | `scenes/rooms/ch3_boss_ante_room.tscn` -> `scenes/areas/ch3_boss_gate_transition.tscn` | `RoomHost/Ch3BossAnteRoom/BossGate/Visuals/{GateClosed,GateLit,GateOpen}` | parent `Visuals` local/effective z=14; child local z=0; relative=true; Y-sort=false | CONFIRMED: Player disappears behind the full gate | Split the gate into background opening/frame, rear door panels, interaction/seal FX, and optional narrow trim. Preserve blocker and sequence script; do not keep the whole 384x? gate composite at 14. Move persistent gate title to HUD or an intentionally bounded world label. |

Current Main-render evidence:

- `docs/qa/chapter_03_render_layer_l0/01_vestibule_nave_door_current.png`
- `docs/qa/chapter_03_render_layer_l0/02_last_vigil_checkpoint_current.png`
- `docs/qa/chapter_03_render_layer_l0/03_thirteen_confessions_checkpoint_current.png`
- `docs/qa/chapter_03_render_layer_l0/04_thirteenth_echo_gate_current.png`

The supplied screenshot 2 is therefore retained as a historical regression example, but its reported draw-order fault is not present in the current saved/runtime values. L1 must not reintroduce it.

## B. Whole-chapter scan: newly discovered issues

The automated runtime table has 14 anomalous drawable rows. Parent/child duplicates collapse to 11 structural issue groups. Four additional static/runtime-generation checks add four issue groups, for **15 total L0 issue groups**. Three correspond directly to currently reproducible supplied screenshots; **12 are additional findings outside those three reproduced examples**.

| ID | Scene / source | Node or generation path | Runtime result | L1 disposition |
|---|---|---|---|---|
| EXTRA-DOOR-01 | Nave Entry | `Doors/ChoirDoor/DoorVisual` effective z=14 | Player is reduced to feet | same ordinary-door split as screenshot 1 |
| EXTRA-DOOR-02 | Choir Gallery | `Doors/CheckpointDoor/DoorVisual` effective z=14 | Player is reduced to feet | same ordinary-door split |
| EXTRA-DOOR-03 | Boss Checkpoint | `Doors/ConfessionDoor/DoorVisual` effective z=14 | Player is reduced to feet | same ordinary-door split |
| EXTRA-UI-01 | Boss antechamber | `AreaTitle` Panel + Label effective z=14, CanvasLayer=0 | world UI participates in actor sorting | use persistent HUD room name; remove/migrate duplicate world title |
| EXTRA-UI-02 | Boss gate | `GateName` Panel + Label effective z=14, CanvasLayer=0 | world title can overlap actors | migrate to HUD or constrain as a non-overlapping world sign |
| EXTRA-UI-03 | Boss sanctum | `SanctumTitle` effective z=14, CanvasLayer=0 | world UI participates in actor sorting | migrate/remove duplicate title |
| EXTRA-UI-04 | Post-boss room | `AreaTitle` effective z=14, CanvasLayer=0 | world UI participates in actor sorting | migrate/remove duplicate title |
| EXTRA-UI-05 | Underkeep descent | `AreaTitle` effective z=14, CanvasLayer=0 | world UI participates in actor sorting | migrate/remove duplicate title |
| EXTRA-FG-01 | Underkeep descent | `ShallowWater01`, `ShallowWater02`, effective z=20 | 768x96 strips cover far more than the allowed 0–4 px of Player; current capture confirms major lower-body occlusion | split/clip/reposition water edge so only a narrow surface highlight is foreground; keep water body behind |
| EXTRA-DROP-01 | `loot_drop_component.gd` | pickup is added to the enemy's parent with default z=0 | no Drop=13 contract is applied; pickup can sit behind ground detail/actors | introduce a Drop container or assign contract z=13 at spawn |
| EXTRA-FX-01 | `chapter_03_specialist_enemy.gd` | projectile is added to `current_scene` with default z=0 | projectile visual can render below actors/ground detail | add a CombatFX container or assign z=16 |
| EXTRA-FX-02 | same | timed field is added to `current_scene` with default z=0 | field ordering is implicit and can hide under scenery | give field an explicit behind/above-actor FX category according to gameplay purpose |

Visual evidence for the three additional door defects and water defect:

- `docs/qa/chapter_03_render_layer_l0/05_nave_choir_door_extra.png`
- `docs/qa/chapter_03_render_layer_l0/06_choir_checkpoint_door_extra.png`
- `docs/qa/chapter_03_render_layer_l0/07_checkpoint_confession_door_extra.png`
- `docs/qa/chapter_03_render_layer_l0/08_underkeep_shallow_water_extra.png`

## Complete Chapter III scene inventory

The exact generated inventory, including flags, Spawn IDs, and audit state, is `docs/qa/chapter_03_render_layer_l0/scene_inventory.tsv`.

| Scene | Category | Main reachable | Room / Spawn IDs | Audit status |
|---|---|---:|---|---|
| `scenes/level/chapter_03_route.tscn` | FormalRoute | yes | route authority | AUDITED |
| `scenes/rooms/ch3_chapel_vestibule.tscn` | FormalRoom | yes | CH3_CHAPEL_VESTIBULE / EntryWest | AUDITED runtime |
| `scenes/rooms/ch3_nave_entry.tscn` | FormalRoom | yes | CH3_NAVE_ENTRY / EntryWest, BellchainTest, ScribeTest | AUDITED runtime |
| `scenes/rooms/ch3_choir_gallery.tscn` | FormalRoom | yes | CH3_CHOIR_GALLERY / EntryWest, EnemyTest | AUDITED runtime |
| `scenes/rooms/ch3_boss_checkpoint.tscn` | FormalRoom | yes | CH3_BOSS_CHECKPOINT / EntryWest, BossCheckpoint | AUDITED runtime |
| `scenes/rooms/ch3_boss_ante_room.tscn` | FormalRoom | yes | CH3_BOSS_ANTE / EntryWest | AUDITED runtime |
| `scenes/rooms/ch3_boss_sanctum_room.tscn` | FormalRoom | yes | CH3_BOSS / EntryWest | AUDITED runtime |
| `scenes/rooms/ch3_post_boss_room.tscn` | FormalRoom | yes | CH3_POST_BOSS / EntryWest | AUDITED runtime |
| `scenes/rooms/ch3_underkeep_room.tscn` | FormalRoom | yes | CH3_UNDERKEEP_DESCENT / EntryWest | AUDITED runtime |
| `scenes/areas/ch3_boss_antechamber.tscn` | FormalDependency | yes | instanced by CH3_BOSS_ANTE | AUDITED runtime |
| `scenes/areas/ch3_boss_gate_transition.tscn` | FormalDependency | yes | instanced by CH3_BOSS_ANTE | AUDITED runtime |
| `scenes/areas/ch3_boss_sanctum.tscn` | FormalDependency | yes | instanced by CH3_BOSS | AUDITED runtime |
| `scenes/areas/ch3_post_boss_reliquary.tscn` | FormalDependency | yes | instanced by CH3_POST_BOSS | AUDITED runtime |
| `scenes/areas/ch3_underkeep_descent.tscn` | FormalDependency | yes | instanced by CH3_UNDERKEEP_DESCENT | AUDITED runtime |
| `scenes/enemies/bellchain_penitent.tscn` | FormalDependency | yes | encounter dependency | AUDITED static + runtime instance |
| `scenes/enemies/censer_executioner.tscn` | FormalDependency | yes | encounter dependency | AUDITED static + runtime instance |
| `scenes/enemies/confessional_wraith.tscn` | FormalDependency | yes | encounter dependency | AUDITED static + runtime instance |
| `scenes/enemies/silent_chorister.tscn` | FormalDependency | yes | encounter dependency | AUDITED static + runtime instance |
| `scenes/enemies/stained_glass_seraph.tscn` | FormalDependency | yes | encounter dependency | AUDITED static + runtime instance |
| `scenes/enemies/thirteenth_scribe.tscn` | FormalDependency | yes | encounter dependency | AUDITED static + runtime instance |
| `scenes/projectiles/chapter_03_enemy_projectile.tscn` | FormalDependency | yes | dynamic enemy spawn | AUDITED static; live generation requires L2 |
| `scenes/projectiles/chapter_03_timed_field.tscn` | FormalDependency | yes | dynamic enemy spawn | AUDITED static; live generation requires L2 |
| `scenes/level/chapter_03_entry_placeholder.tscn` | Retired | no | legacy/debug spawn set | CATALOGUED, excluded from formal route |
| `scenes/tests/bellchain_penitent_test_room.tscn` | Debug | no | F6 test | CATALOGUED |
| `scenes/tests/chapter_03_enemy_combination_test_room.tscn` | Debug | no | F6 test | CATALOGUED |
| `scenes/tests/chapter_03_enemy_trial_hall.tscn` | Debug | no | F6 test | CATALOGUED |

Totals: 26 scene files = 1 formal route + 8 formal rooms + 13 formal dependencies + 1 retired scene + 3 debug scenes.

## Door inventory

| Door / gate | Formal scene | Visual structure | Effective z | State / L0 result |
|---|---|---|---:|---|
| MirrorBackDoor (architectural) | Chapel Vestibule | one background Sprite2D | -60 | safe, non-interactive |
| NaveDoor | Chapel Vestibule | one `DoorVisual`; no Frame/Panel/Trim split | 14 | FAIL |
| ChoirDoor | Nave Entry | one `DoorVisual`; no split | 14 | FAIL |
| CheckpointDoor | Choir Gallery | one `DoorVisual`; no split | 14 | FAIL |
| ConfessionDoor | Boss Checkpoint | one `DoorVisual`; no split | 14 | FAIL |
| Gate of the Thirteenth Echo | Boss Ante | `Visuals` parent contains full Closed/Lit/Open composites, bells, seal FX | 14 | FAIL; collision is separate and can be preserved |
| DescentSeal | Post Boss | Sealed/Open children under parent z=-30 | -30 | draw order safe; story-state regression still required |
| UnderkeepGate | Underkeep | one background Sprite2D | -30 | draw order safe, non-animated visual |

Visual-less room exit Area2Ds are transition triggers, not rendered doors; they were audited but are not draw-order defects.

## Foreground inventory

Only two formal runtime nodes classify as LimitedForeground:

| Scene | Node | Parent | local/effective z | Size / result |
|---|---|---|---:|---|
| Underkeep | `UnderkeepDescent/ShallowWater01` | UnderkeepDescent z=0 | 20 / 20 | 768x96; FAIL visual-occlusion budget |
| Underkeep | `UnderkeepDescent/ShallowWater02` | UnderkeepDescent z=0 | 20 / 20 | 768x96; FAIL visual-occlusion budget |

No `Foreground` container exists. The two water composites are individually placed at z=20.

## Actor containers and runtime values

| Runtime path | Purpose | Parent/effective z | Result |
|---|---|---:|---|
| `PersistentRuntime/ChapterRuntime/Player` | persistent Player | PersistentRuntime / 12 | stable across all eight room swaps |
| `.../Player/VisualRoot/AnimatedSprite2D` | Player body | Player / 12 | stable |
| `.../Player/VisualRoot/WeaponVisual` | equipped weapon | Player + local 1 / 13 | below defective full doors at 14 |
| `.../Player/VisualRoot/DeathEffects` | death presentation | Player + local 2 / 14 | same effective z as interactables; tie must be regression-tested |
| `.../DeathEffects/GhostSprite` | ghost | effective 14 | hidden during idle audit; L2 death test required |
| `RoomHost/Ch3NaveEntry/Enemies` | encounter actor container | 0 | contains 3 enemies, each effective z=10 |
| `RoomHost/Ch3ChoirGallery/Enemies` | encounter actor container | 0 | contains 3 enemies, each effective z=10 |

There is no dedicated NPC container, Drop container, or CombatFX container in the formal route. No Chapter III NPC exists in the eight current formal rooms. The CH3_BOSS room currently contains environment/flow but no authoritative boss Actor, so boss layer acceptance remains PARTIAL until that Actor exists.

## Y-sort, parent z, and CanvasLayer audit

- Runtime `y_sort_enabled=true`: **0**. No fixed architecture currently depends on Y-sort.
- All eight active room roots resolve to z=0; `RoomHost` and `PersistentRuntime` both resolve to z=0.
- The four ordinary door Area2D roots are z=14 and all children are relative, causing the complete door bitmap and prompt to inherit 14.
- Boss gate root is z=0, but its `Visuals` parent is z=14, so every gate composite, bell, crack and seal inherits 14.
- Boss antechamber `Architecture` is z=-60; confession tablets, both saints, choir stalls and lectern inherit -60 and are not the current screenshot-3 occluder. The checkpoint composite at z=14 is the occluder.
- Formal HUD and room fade are inside `PersistentRuntime/ChapterRuntime/HUD`, CanvasLayer=1. Boss gate transition fade is CanvasLayer=90. These do not compete with world z.
- Several duplicate area titles and the Boss gate name are Controls in CanvasLayer=0 at z=14; they are world-space UI anomalies.

## Runtime script overrides and reparent audit

| Script | Runtime operation | Layer impact |
|---|---|---|
| `chapter_03_room_transition_controller.gd::_ready` | sets Player z=12, relative=true | authoritative Player override |
| `chapter_03_room_transition_controller.gd::_swap_room` | adds active room to `RoomHost`; moves persistent Player but does not reparent it | stable Player parent; room is replaced per transition |
| `chapter_03_room.gd::_apply_actor_layer_contract` | recursively sets every EnemyCombatant z=10, relative=true | authoritative enemy override |
| `chapter_03_room_door.gd` | moves `DoorVisual.position` during open/close | no z mutation; defective inherited z remains in all states |
| `chapter_03_boss_gate.gd` | changes visibility/modulate and blocker state | no z mutation; closed/lit/open all retain effective z=14 |
| `chapter_03_specialist_enemy.gd` | adds projectile/field to `current_scene` | generated FX receives implicit z=0 |
| `loot_drop_component.gd` | adds pickup to enemy parent | generated pickup receives implicit z=0 |

No Chapter III gameplay script calls `reparent()`. No Chapter III animation track modifying `z_index` or `z_as_relative` was found.

## Exact L1 repair order

1. Create `docs/production/render_layer_contract.md` and extend `Chapter03LayerContract` with NPC=11, Drop=13, CombatFX=16 plus explicit relative-z/Y-sort/door rules.
2. Fix the reusable ordinary-room door structure once, then apply it to NaveDoor, ChoirDoor, CheckpointDoor, and ConfessionDoor. Update the existing R3 test that currently asserts the unsafe whole-door z=14 behavior.
3. Split the Boss antechamber checkpoint composite into behind-actor structure and small interaction/FX front content.
4. Split Gate of the Thirteenth Echo into rear architecture, panels, interaction FX, and optional narrow trim while retaining current collision and scripted states.
5. Replace/migrate world-space duplicate area titles and gate name; keep HUD/fade in CanvasLayer.
6. Add explicit Drop and CombatFX placement policy and update dynamic spawn sites.
7. Rework the 768x96 underkeep water composites so foreground pixels remain within the 0–4 px foot-only budget.
8. Add structural tests for effective z (including parent accumulation), all door states, dynamic pickup/projectile placement, and no fixed-architecture Y-sort.
9. Stop for L2 authorization, then use Main/F5 to run the full action/door/transition/death/ghost/drop matrix and collect the mandated expanded screenshot index.

## Evidence files

- `docs/qa/chapter_03_render_layer_l0/runtime_layer_audit.tsv` — all 411 runtime CanvasItems across persistent runtime and eight formal rooms.
- `docs/qa/chapter_03_render_layer_l0/anomaly_inventory.tsv` — machine-detected drawable anomaly rows.
- `docs/qa/chapter_03_render_layer_l0/scene_inventory.tsv` — all 26 Chapter III scenes.
- `docs/qa/chapter_03_render_layer_l0/*.png` — eight MainBootstrap/OpenGL runtime captures.

## Stop gate

L0 is complete. No `.tscn`, gameplay behavior, collision, art, layer contract, Main registration, or project setting was changed. Await explicit approval before L1.
