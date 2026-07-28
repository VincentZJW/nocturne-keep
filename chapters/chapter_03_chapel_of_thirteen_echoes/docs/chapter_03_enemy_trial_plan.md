# Chapter III Enemy Trial Hall Plan / 第三章敌人试炼厅计划

Status: **Phase 2 combination harness available; full Phase 3 station-based Trial Hall is not implemented**

## Purpose and boundary

The Trial Hall is a Debug-only combat harness for six Chapter III normal enemies. It may use clear test geometry because it is explicitly `prototype_only`; it is not the Chapter III chapel map and cannot satisfy formal scene-art acceptance.

Planned scene:

`res://chapters/chapter_03_chapel_of_thirteen_echoes/scenes/tests/chapter_03_enemy_trial_hall.tscn`

It must instantiate the existing shared `ChapterGameplayRuntime` so Main creates exactly one Player, HUD, Camera, inventory/equipment chain and respawn controller. It must never become `run/main_scene`.

## Current Main/Chapter audit

- `run/main_scene`: `res://scenes/bootstrap/main_bootstrap.tscn`.
- Chapter III registry/profile already exists and is Debug-ready.
- Current profile target: `scenes/level/chapter_03_entry_placeholder.tscn`.
- Current spawn ids: base start plus `CH3_BELLCHAIN_TEST`, `CH3_EXECUTIONER_TEST`, `CH3_CHOIR_TEST` and `CH3_SCRIBE_TEST`.
- The current profile already completes prior chapters, owns all three dagger sets, equips `crimson_masque_stilettos`, starts at full 100 HP and does not write a disk save.
- Phase 2 added only spawn ids that resolve inside the saved entry acceptance scene. Phase 3 may add the separate Trial Hall ids below only after that scene exists and passes resource validation; no nonresolving id is permitted.

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

Current Phase 2 acceptance: F5 can route through MainBootstrap to the Chapter III entry and the four saved direct spawns above. The separate `chapter_03_enemy_combination_test_room.tscn` contains all six enemies for stability/interaction smoke testing. The eight-station `CH3_ENEMY_TRIAL_START` procedure remains unavailable until Phase 3 and is not falsely claimed by the combination room.

## QA evidence plan

Target folder: `res://docs/qa/chapter_03_enemy_trial/`.

The final Phase 4 enemy milestone requires at least 18 real screenshots:

- six concept images (one per enemy);
- six Main/F5 single-enemy combat frames;
- at least six combination/state/Hitbox frames covering all required groups collectively.

Phase 1 already preserves six concept comparisons. Phase 2 adds five 1280×720 Main/F5 action captures under `docs/qa/chapter_03_enemy_phase_02/`; Bellchain retains its Phase 2A capture set. The later Trial Hall must add the required combination/Hitbox evidence rather than reuse these as a false Phase 4 completion claim.
