# Chapter III Enemy Trial Hall Plan / 第三章敌人试炼厅计划

Status: **Phase 0 plan — scene and spawn ids are not implemented**

## Purpose and boundary

The Trial Hall is a Debug-only combat harness for six Chapter III normal enemies. It may use clear test geometry because it is explicitly `prototype_only`; it is not the Chapter III chapel map and cannot satisfy formal scene-art acceptance.

Planned scene:

`res://chapters/chapter_03_chapel_of_thirteen_echoes/scenes/tests/chapter_03_enemy_trial_hall.tscn`

It must instantiate the existing shared `ChapterGameplayRuntime` so Main creates exactly one Player, HUD, Camera, inventory/equipment chain and respawn controller. It must never become `run/main_scene`.

## Current Main/Chapter audit

- `run/main_scene`: `res://scenes/bootstrap/main_bootstrap.tscn`.
- Chapter III registry/profile already exists and is Debug-ready.
- Current profile target: `scenes/level/chapter_03_entry_placeholder.tscn`.
- Current spawn ids: `chapter_03_start`, `Chapter03PlayerSpawn` only.
- The current profile already completes prior chapters, owns all three dagger sets, equips `crimson_masque_stilettos`, starts at full 100 HP and does not write a disk save.
- Therefore Phase 3 should extend the saved Chapter III profile only after the Trial Hall exists and passes resource validation. Phase 0 does not add nonresolving spawn ids.

## Planned profile integration

Phase 3 adds the following ids to the Chapter III profile and routes its test target to the Trial Hall through the existing MainBootstrap contract:

- `CH3_ENEMY_TRIAL_START`
- `CH3_TEST_PENITENT`
- `CH3_TEST_EXECUTIONER`
- `CH3_TEST_CHORISTER`
- `CH3_TEST_SERAPH`
- `CH3_TEST_WRAITH`
- `CH3_TEST_SCRIBE`
- `CH3_TEST_COMBINATIONS`

The implementation must choose one unambiguous profile strategy before editing: either a dedicated Debug Trial profile registered under the existing Chapter III id, or one Chapter III scene router that resolves spawn ids to the entry/Trial Hall. It must not create two conflicting registry entries with the same chapter id.

## Planned layout

```text
Chapter03EnemyTrialHall
├── GameplayWorld
│   ├── Geometry
│   │   ├── SafeEntrance
│   │   ├── GroundLane
│   │   ├── WideHeavyLane
│   │   ├── ReachableMidPlatform
│   │   ├── AirVolume
│   │   ├── ProjectileWallLane
│   │   └── CombinationArena
│   └── ChapterRuntime (one shared instance)
├── SpawnPoints (eight ids)
├── EnemyStations (six resettable stations)
├── CombinationGroups (eight authored combinations)
├── Checkpoints
├── CameraBounds
├── DebugControls
└── TrialHallController
```

Required stations:

1. safe entrance and instruction panel;
2. Penitent ground/edge lane;
3. Executioner wide floor and smoke boundary lane;
4. Chorister reachable platform and projectile-gap lane;
5. Seraph bounded air volume and ground-vulnerable landing zone;
6. Wraith authored confessional/tether lane;
7. Scribe wide seal/projectile lane;
8. combination arena with resettable groups.

## Debug controls

- reset current station/group without reloading the formal save;
- toggle visible collisions/Hitbox and telegraph outlines;
- display enemy type, state, HP, Poise, animation, attack phase/id, cooldown, active field/projectile count and bounds;
- display Player HP/stamina/equipped 14/28 weapon without making HUD the data owner;
- keep Debug controls removable/hidden and avoid input conflicts with Player actions.

No control creates Labels every frame. State text is reused and updates at a bounded cadence.

## Required combination groups

Each group is run at least five times in Phase 4:

1. Penitent + Chorister;
2. Penitent + Scribe;
3. Executioner + Penitent;
4. Executioner + Chorister;
5. Seraph + Penitent;
6. Wraith + Scribe;
7. Seraph + Chorister;
8. Penitent ×2 + Chorister ×1.

For every run record safe route, telegraph overlap, control overlap, rear-unit access, clear time, damage taken and whether Player could identify target priority.

## Per-enemy forced QA

Phase 4 minimums:

- at least 20 confirmed kills of each enemy;
- at least 15 triggers of every attack;
- both facings and all Windup/Active/Recovery phases;
- light hit, Poise break/Stagger, Hurt, Death, loot, reset and encounter death count;
- platform edges, walls, floor-height boundary and Camera bounds;
- no air Hitbox, duplicate damage, warning omission, wall lock, fall-out, permanent stun or excessive frequency/HP drag.

## Main/F5 acceptance procedure after Phase 3

1. Set `DebugRunConfig.debug_chapter_start_enabled = true`.
2. Set chapter to `CHAPTER_03_CHAPEL_OF_THIRTEEN_ECHOES`.
3. Set spawn to `CH3_ENEMY_TRIAL_START`.
4. Press F5; do not run the Trial Hall as the project main scene.
5. Confirm MainBootstrap initializes one Player/HUD/Camera and equips Crimson Masque 14/28.
6. Walk through the six stations or use the six dedicated Debug spawn ids.
7. Enter `CH3_TEST_COMBINATIONS` and run all eight groups.
8. Restore the project default Debug start setting after the QA capture.

Fixed acceptance answer for Phase 0: **this procedure is not available yet**. F5 currently enters the Chapter III entry placeholder because the Trial Hall and `CH3_*` spawn ids do not exist. Claiming otherwise would be false.

## QA evidence plan

Target folder: `res://docs/qa/chapter_03_enemy_trial/`.

The final enemy milestone requires at least 18 real screenshots:

- six concept images (one per enemy);
- six Main/F5 single-enemy combat frames;
- at least six combination/state/Hitbox frames covering all required groups collectively.

The QA report records exact command, 1280×720 capture path, byte size, dimensions and SHA-256, plus separate human acceptance items. Phase 0 generates no screenshots because no enemy visual/runtime exists.
