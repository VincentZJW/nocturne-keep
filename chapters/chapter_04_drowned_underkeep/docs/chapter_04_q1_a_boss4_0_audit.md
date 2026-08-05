# Chapter IV Q1-A Combat/Transition Runtime Audit and BOSS4-0 Flow Audit

Date: 2026-08-05
Engine used for runtime evidence: Godot 4.7.1 Standard (`a13da4feb`)
Formal F5 authority: `res://scenes/bootstrap/main_bootstrap.tscn`
Formal Chapter IV authority: `res://chapters/chapter_04_drowned_underkeep/scenes/level/drowned_underkeep.tscn`

This document is an audit and implementation plan only. It does not change enemy AI, collision, room transitions, Boss flow, reward content, balance, scenes, or project settings.

## Q1-A — Formal Chapter IV combat and transition audit

### 1. Formal room inventory

| Area | Formal scene | Encounter groups | Normal/elite enemies | Exits | Notes |
|---|---|---:|---:|---:|---|
| 00 | `scenes/rooms/ch4_00_drowned_threshold.tscn` | 0 | 0 | 1 | Chapter entrance |
| 01 | `scenes/rooms/ch4_01_flooded_intake.tscn` | 2 | 4 | 2 | Combat |
| 02 | `scenes/rooms/ch4_02_rusted_cellblock.tscn` | 2 | 5 | 2 | Combat |
| 03 | `scenes/rooms/ch4_03_broken_chainway.tscn` | 2 | 4 | 2 | Combat |
| 04 | `scenes/rooms/ch4_04_harpoon_watch_gallery.tscn` | 2 | 5 | 2 | Combat |
| 05 | `scenes/rooms/ch4_05_cistern_of_the_changed.tscn` | 2 | 5 | 2 | Combat; reported transition problem |
| 06 | `scenes/rooms/ch4_06_dry_gaolers_cell.tscn` | 0 | 0 | 2 | Checkpoint/support |
| 07 | `scenes/rooms/ch4_07_leech_sluice.tscn` | 2 | 4 | 2 | Combat |
| 08 | `scenes/rooms/ch4_08_gaolers_workshop.tscn` | 2 | 5 | 2 | Combat |
| 09 | `scenes/rooms/ch4_09_soul_cage_registry.tscn` | 2 | 4 | 2 | Combat |
| 10 | `scenes/rooms/ch4_10_floodgate_engine_hall.tscn` | 2 | 5 | 2 | Combat |
| 11 | `scenes/rooms/ch4_11_final_lock_approach.tscn` | 2 | 5 | 2 | Final Lock combat |
| 12 | `scenes/rooms/ch4_12_last_gaol_checkpoint.tscn` | 0 | 0 | 2 | Last Gaol checkpoint |
| 13 | `scenes/rooms/ch4_13_soul_lock_antechamber.tscn` | 0 | 0 | 2 | Boss staging shell |
| 14 | `scenes/rooms/ch4_14_core_of_drowned_gaol.tscn` | 0 | Boss only | 2 | Ormund arena shell |
| 15 | `scenes/rooms/ch4_15_broken_soul_reservoir.tscn` | 0 | 0 | 2 | Reward/revelation shell |
| 16 | `scenes/rooms/ch4_16_hall_of_drowned_memories.tscn` | 0 | 0 | 1 | Chapter V placeholder; west exit only |

Totals from saved formal manifests: 17 rooms, 20 EncounterGroups and 46 ordinary/elite enemy instances.

### 2. All saved formal enemy instances

The room scenes do not store Inspector-overridden enemy instances. They store manifests, and `Chapter04EncounterSpawner` creates the following exact runtime instances from the formal enemy PackedScenes.

| Area/group | Saved spawn records |
|---|---|
| 01 / 1 | `CH4_AREA_01_DROWNED_GAOLER_01`, `CH4_AREA_01_DROWNED_GAOLER_02` |
| 01 / 2 | `CH4_AREA_01_MIRE_HARPOONER_01`, `CH4_AREA_01_MIREFIN_RAIDER_01` |
| 02 / 1 | `CH4_AREA_02_DROWNED_GAOLER_01`, `CH4_AREA_02_CHAINBOUND_CONVICT_01` |
| 02 / 2 | `CH4_AREA_02_DROWNED_GAOLER_02`, `CH4_AREA_02_SUNKEN_SHIELD_PENITENT_01`, `CH4_AREA_02_SEWER_MAW_01` |
| 03 / 1 | `CH4_AREA_03_DROWNED_GAOLER_01`, `CH4_AREA_03_MIRE_HARPOONER_01` |
| 03 / 2 | `CH4_AREA_03_MIREFIN_RAIDER_01`, `CH4_AREA_03_BOG_TOAD_01` |
| 04 / 1 | `CH4_AREA_04_DROWNED_GAOLER_01`, `CH4_AREA_04_MIRE_HARPOONER_01` |
| 04 / 2 | `CH4_AREA_04_SUNKEN_SHIELD_PENITENT_01`, `CH4_AREA_04_MIRE_HARPOONER_02`, `CH4_AREA_04_MIREFIN_RAIDER_01` |
| 05 / 1 | `CH4_AREA_05_CHAINBOUND_CONVICT_01`, `CH4_AREA_05_MIREFIN_RAIDER_01` |
| 05 / 2 | `CH4_AREA_05_SEWER_MAW_01`, `CH4_AREA_05_MIREFIN_RAIDER_02`, `CH4_AREA_05_BOG_TOAD_01` |
| 07 / 1 | `CH4_AREA_07_DROWNED_GAOLER_01`, `CH4_AREA_07_SEWER_MAW_01` |
| 07 / 2 | `CH4_AREA_07_SEWER_MAW_02`, `CH4_AREA_07_MIREFIN_RAIDER_01` |
| 08 / 1 | `CH4_AREA_08_DROWNED_GAOLER_01`, `CH4_AREA_08_SUNKEN_SHIELD_PENITENT_01` |
| 08 / 2 | `CH4_AREA_08_CHAINBOUND_CONVICT_01`, `CH4_AREA_08_UNDERKEEP_EXECUTIONER_01`, `CH4_AREA_08_MIRE_HARPOONER_01` |
| 09 / 1 | `CH4_AREA_09_CHAINBOUND_CONVICT_01`, `CH4_AREA_09_DROWNED_GAOLER_01` |
| 09 / 2 | `CH4_AREA_09_SUNKEN_SHIELD_PENITENT_01`, `CH4_AREA_09_MIRE_HARPOONER_01` |
| 10 / 1 | `CH4_AREA_10_SUNKEN_SHIELD_PENITENT_01`, `CH4_AREA_10_MIREFIN_RAIDER_01` |
| 10 / 2 | `CH4_AREA_10_CHAINBOUND_CONVICT_01`, `CH4_AREA_10_BOG_TOAD_01`, `CH4_AREA_10_BOG_TOAD_02` |
| 11 / 1 | `CH4_AREA_11_DROWNED_GAOLER_01`, `CH4_AREA_11_CHAINBOUND_CONVICT_01` |
| 11 / 2 | `CH4_AREA_11_SUNKEN_SHIELD_PENITENT_01`, `CH4_AREA_11_MIRE_HARPOONER_01`, `CH4_AREA_11_UNDERKEEP_EXECUTIONER_01` |

### 3. Shared runtime architecture and collision contract

All eight formal enemy types are independently instantiable but use the shared behavior script:

- `res://chapters/chapter_04_drowned_underkeep/scripts/enemies/chapter_04_enemy.gd`
- type-specific behavior is selected through embedded `Chapter04EnemyConfig` resources in each formal PackedScene.
- similarly named standalone resources under `resources/enemies/` are currently not the runtime authority. This is configuration drift to clean up later; it is not the cause of the reported failure.

Collision layers/masks are mutually compatible:

| Contract | Layer | Mask |
|---|---:|---:|
| Player body | 2 | 5 |
| Player Hurtbox | 8 | 320 |
| Player attack Hitbox | 32 | 16 |
| Enemy body | 4 | 3 |
| Enemy Hurtbox | 16 | 32 |
| Enemy attack Hitbox | 64 | 8 |
| Enemy detection | 128 | 2 |

Therefore the Chapter IV-wide failure is not caused by a global layer/mask mismatch.

### 4. Proven root causes

#### A. Dormant Encounter presentation

`res://scripts/encounters/encounter_group.gd` deliberately makes every member of a dormant group `PROCESS_MODE_DISABLED`, disables physics and disables AI. `Chapter04EncounterSpawner` arms only one EncounterGroup at a time. Enemies belonging to later groups are still rendered in the room, so they look like active combatants while being deliberately unable to move or attack.

Consequences:

- visible later-group enemies stand still;
- their AI and attack timers cannot advance;
- ordinary dormant Hurtboxes can still receive a hit, but the enemy cannot play/finish a reaction while disabled;
- a dormant Sewer Maw cannot be hit because its initial hidden-state Hurtbox is disabled too.

#### B. Destination-room activation race

`chapter_04_room_transition_controller.gd` adds the destination room before it suspends activation and before it moves the persistent Player to the destination spawn. During that ready-frame window, a destination ActivationArea may see the Player at the previous room's coordinate and activate the wrong EncounterGroup. The controller then suspends the room, teleports the Player and resumes it, but the intended group is no longer armed.

This is a shared race between:

- `scripts/level/chapter_04_room_transition_controller.gd`
- `scripts/encounters/chapter_04_encounter_spawner.gd`
- `scripts/encounters/encounter_group.gd`

The result matches the screenshots: visible enemies may remain dormant even after the Player reaches their apparent combat space.

#### C. Shared `LightHitReaction` never exits

The common Chapter IV enemy script can enter `LIGHT_HIT` in `_on_hurtbox_hit_received`, but `_process_reaction()` only exits `STAGGER` and `GUARD_BREAK`. An isolated exact-engine run proved both a Drowned Gaoler and a Bog Toad accepted damage and remained in `LightHitReaction` after two seconds with the original `0.180` timer still present.

This affects all eight common Chapter IV enemy types after a normal hit. It can make an initially active enemy become permanently unable to move or attack after Player contact.

#### D. Sewer Maw emergence/Hurtbox lifecycle

`Sewer Maw` starts in `Hidden` and disables its Hurtbox. Its own hidden-state processor is responsible for re-enabling the Hurtbox when emergence begins. Encounter activation/target assignment can make the shared base AI leave `Hidden` through `Alert/Approach` first, bypassing that re-enable branch. Runtime evidence showed the Maw moving and completing bite/ambush attacks while its Hurtbox was still disabled. This is the one proven type-specific true Player-hit rejection.

### 5. Per-enemy runtime finding

| Enemy | Movement/attack finding | Player-hit finding | Root cause if it fails in Main |
|---|---|---|---|
| Drowned Gaoler | Active instance moved and completed cleave/hook windup, active and recovery | Real Player Hitbox accepted; HP `104→103` | Dormant/race before first activation; shared LightHit lock after a normal hit |
| Sunken Shield Penitent | Active instance approached/turned and completed shield bash/rusted thrust | Hit contract resolves, but frontal normal damage is absorbed by its shield | Dormant/race; frontal zero HP change can be correct shield behavior; shared LightHit lock after unblocked hit |
| Sewer Maw | Active instance approached and completed bite/ambush | Hurtbox stayed disabled; HP `82→82` | Hidden/emergence lifecycle bug, plus dormant/race and shared LightHit risk |
| Mirefin Raider | Active instance moved and attacked | Real Player Hitbox accepted; HP `116→115` | Dormant/race; shared LightHit lock |
| Bog Toad | Active instance moved and completed leap attack | Isolated hit accepted; HP `142→141` | Dormant/race; shared LightHit lock. It is not a collision-mask failure |
| Mire Harpooner | Active instance aimed/fired/completed harpoon phases | Real Player Hitbox accepted; HP `96→95` | Its elevated stationary firing position is intentional; dormant/race prevents attack; shared LightHit lock |
| Chainbound Convict | Active instance completed chain/shackle attacks | Real Player Hitbox accepted; HP `152→151` | Dormant/race; shared LightHit lock. One elevated snapshot was not on floor, but attack execution still worked |
| Underkeep Executioner | Active instance completed executioner cleave | Real Player Hitbox accepted; HP `244→243` | Dormant/race; shared LightHit lock |

The formal scenes and each enemy scene/config are therefore valid enough to run. Q2 must fix activation ordering and reaction state recovery, not replace all AI or collision components.

### 6. Why current tests missed it

Existing tests either call `EncounterGroup.activate()` directly, start attacks by private/debug methods, or only count saved instances. They do not traverse from the previous room into a natural activation area, strike each enemy, wait for recovery, and verify a second autonomous attack. The green tests prove saved data and isolated capability, but not the reported F5 lifecycle.

### 7. Cistern east exit audit

- Formal scene: `res://chapters/chapter_04_drowned_underkeep/scenes/rooms/ch4_05_cistern_of_the_changed.tscn`
- Packed node: `Ch4CisternOfTheChanged/Transitions/ExitEast`
- Runtime Main node: `/root/DrownedUnderkeep/RoomHost/Ch4CisternOfTheChanged/Transitions/ExitEast`
- Position: `(2152, 550)` in a room whose authored width is `2176`.
- Type/script: `Area2D` using `chapter_04_room_exit.gd`.
- Destination: `CH4_AREA_06`.
- Destination scene: `res://chapters/chapter_04_drowned_underkeep/scenes/rooms/ch4_06_dry_gaolers_cell.tscn`.
- Destination spawn: `Ch4DryGaolersCell/SpawnPoints/EntryWest` at `(120, 592)`.
- Interaction mode: automatic (`requires_interaction = false`), so the absent `E` prompt is current behavior, not a missing prompt node.

An exact MainBootstrap runtime probe placed the Player inside the real Area2D and confirmed that Area 06 loaded, the Player remained visible, input returned to Full, and position became `(120,592)`.

The user-facing failure is spatial/readability related: the trigger sits at the extreme composition edge, has no visible door/prompt/feedback, and the shared actor world bounds extend to `x=4096` while the room/camera ends at `x=2176`. The Player can run beyond the authored camera composition before understanding that an automatic exit exists. This produces an apparent disappearance; it is not a `queue_free`, invisible Player, invalid destination scene, or missing spawn.

### 8. Affected shared systems

Q2/Q3 should remain limited to:

1. `chapter_04_room_transition_controller.gd` — instantiate destination suspended before `_ready` can activate groups.
2. `chapter_04_encounter_spawner.gd` / `encounter_group.gd` — explicit dormant presentation/activation contract.
3. `chapter_04_enemy.gd` — exit `LightHitReaction` and preserve the intended next state.
4. Sewer Maw hidden/emergence branch in the same script/config path — always synchronize Hurtbox with visible/combat state.
5. `chapter_04_room_exit.gd` and Cistern/Dry Gaoler room scene — readable interaction/bounds alignment without changing route order.
6. New natural Main traversal/recovery QA, rather than only direct activation.

### 9. Estimated Q2/Q3 files (not changed in this audit)

Estimated implementation set: 6–10 files.

- 3 shared runtime scripts listed above;
- 1–2 Chapter IV room scenes for the Cistern transition;
- 2–4 focused tests/Main capture scripts;
- development log and one QA report.

No enemy art, balance, Player tuning, or project setting should be required.

### 10. Q2/Q3 formal F5 acceptance plan

1. Start MainBootstrap at each combat room west entry, not inside an already active group.
2. Walk naturally through every ActivationArea; confirm only current group is visible as combat-ready or clearly dormant.
3. For every one of the 46 records, verify detection, movement/aim, one autonomous attack, Player normal hit, Player Dash hit, reaction recovery, a second autonomous attack, death and cleanup.
4. Reload every combat room and repeat the first encounter to prove deterministic reset.
5. Traverse 04→05→06→07 through real exits. At the Cistern right edge, verify readable prompt/door, no off-camera walk, correct fade, Area 06 `EntryWest`, visible Player and Full input.
6. Inspect Output/Debugger for parser/resource errors and combat-state errors.

## BOSS4-0 — Existing state and proposed full Boss route

### 1. Existing formal paths

| Element | Current formal path/state |
|---|---|
| Final Lock | `res://chapters/chapter_04_drowned_underkeep/scenes/rooms/ch4_11_final_lock_approach.tscn` |
| Last Gaol checkpoint | `res://chapters/chapter_04_drowned_underkeep/scenes/rooms/ch4_12_last_gaol_checkpoint.tscn`; node `Ch4LastGaolCheckpoint/Gameplay/Checkpoint`; ID `LAST_GAOL` |
| Soul Lock Antechamber | `res://chapters/chapter_04_drowned_underkeep/scenes/rooms/ch4_13_soul_lock_antechamber.tscn` |
| Boss door | No interactive Boss door exists. Area 13 has static `Architecture/FocalAsset_01` outer frame and `Architecture/FocalAsset_02` panel, plus generic automatic `Transitions/ExitEast` |
| Boss room | `res://chapters/chapter_04_drowned_underkeep/scenes/rooms/ch4_14_core_of_drowned_gaol.tscn` |
| Boss instance | `Ch4CoreOfDrownedGaol/Enemies/SoulGaolerOrmund` at `(1567,619)` |
| Boss PackedScene | `res://chapters/chapter_04_drowned_underkeep/scenes/bosses/soul_gaoler_ormund.tscn` |
| Boss script | `res://chapters/chapter_04_drowned_underkeep/scripts/bosses/soul_gaoler_ormund.gd` |
| Boss runtime config | Embedded scene config derived from `SoulGaolerOrmundConfig`; companion data file is `resources/bosses/soul_gaoler_ormund_data.tres` |
| Reward room shell | `res://chapters/chapter_04_drowned_underkeep/scenes/rooms/ch4_15_broken_soul_reservoir.tscn` |
| Memory hall shell | `res://chapters/chapter_04_drowned_underkeep/scenes/rooms/ch4_16_hall_of_drowned_memories.tscn` |

### 2. Current Boss runtime

- Body HP: 560; Phase 2 threshold: 55% in the Boss config.
- Phase 1 attacks: `halberd_sweep`, `chain_anchor_slam`, `prison_hook_drag`, `floodgate_charge`, `soul_cage_pulse`.
- Phase 2 attacks: `chainstorm_cleave`, `undertow_pull`, `drowned_cell_rupture`, `soul_shackle`, `flooded_judgment`.
- Existing intro is only an internal 1.05-second `intro` animation followed immediately by Combat. It has no Player lock, dialogue, camera direction, Boss HUD/name reveal, music gate, first-entry flag, or retry distinction.
- Existing death is `death_start` → wait 0.55 s → `death_collapse` → wait 0.65 s → `soul_release`, after which the base death-animation contract removes the Boss. There is no death dialogue, route flag, reward unlock or exit gate.
- Both room exits are generic and remain available independently of Boss state.
- `soul_gaoler_ormund_hud.gd` exists but is not instanced in the formal room and still points to an obsolete CharacterTrial NodePath.
- No formal Chapter IV Boss music lifecycle is connected to `MusicManager`.

### 3. Reward, flags and Chapter V status

- Formal `RewardSpawner` count: **0**.
- No Chapter IV reward controller, weapon pickup, fixed reward definition or approved final reward values exist. BOSS4-0 deliberately leaves reward content undecided.
- `ChapterSession` has generic `boss_reward_spawned` and `boss_reward_collected`, but no Chapter IV-specific `ch4_boss_defeated`, `ch4_reward_unlocked`, `ch4_reward_collected`, or `ch4_memory_passage_unlocked` flags.
- The Last Gaol checkpoint ID is `LAST_GAOL`, not the requested `CP_CH4_BOSS`.
- Chapter Registry contains a planned `res://chapters/chapter_05_night_repeated/scenes/level/night_repeated.tscn` profile with `chapter_05_start`, but the target directory/scene does not exist and exact `CH5_START` does not exist.
- Area 16 has only a west exit. No formal Chapter IV→V transition is implemented.

### 4. Proposed formal route

```text
CH4_AREA_11 Final Lock
  Encounter A → safety beat → Encounter B
        ↓
CH4_AREA_12 Last Gaol checkpoint (future ID: CP_CH4_BOSS)
        ↓
CH4_AREA_13 Soul Lock Antechamber
  environmental foreshadowing → interactive Soul-Lock Gate
        ↓  E / gate unlock / fade
CH4_AREA_14 Core of Drowned Gaol
  first-entry intro → P1 → phase transition → P2 → death dialogue
        ↓  ch4_boss_defeated
CH4_AREA_15 Broken Soul Reservoir
  fixed reward reliquary (content and values pending approval)
        ↓  ch4_reward_collected / memory passage unlock
CH4_AREA_16 Hall of Drowned Memories
  short memory sequence → interaction → fade
        ↓
Chapter V placeholder / CH5_START (future implementation)
```

### 5. Boss door and antechamber design

The current static frame/panel assets should be retained as art input but reorganized into a real `SoulLockGate` scene:

- `DoorBackground`
- `RearFrame`
- `Panels`
- `Chains`
- `LockCore`
- `ForegroundTrim`
- `InteractionArea`
- blocking `CollisionShape2D`
- disabled-until-open `TransitionTrigger`

The Antechamber remains enemy-free. It should teach that the lock is a controlled threshold: short approach, readable `E` prompt, Player input lock only after accepted interaction, chain/lock animation, fade, atomic Area 14 load. The gate must not be another invisible edge trigger.

### 6. Proposed first-entry intro dialogue

1. Ormund: “礼拜堂终于把你吐了下来。”
2. Player: “埃德兰说，未被赦免的人都在这里。”
3. Ormund: “赦免？” / “那只是他们给处刑写下的名字。”
4. Player: “这些灵魂为什么还被锁着？”
5. Ormund: “因为死去的人会记得。” / “而王冠最害怕的，就是有人记得那一夜。”
6. Player: “七年前，我来过这里。”
7. Ormund: “你不只来过。” / “你亲手打开了最深处的牢门。”
8. Reveal: `SOUL GAOLER ORMUND / 灵魂狱卒·奥尔蒙德` and enable Boss HUD/combat.

Retry should skip or shorten this sequence based on a first-entry flag while preserving a clean P1 reset.

### 7. Proposed death and reward flow

Death dialogue after combat control is safely disabled:

1. Ormund: “锁链断了……” / “记忆就会回来。”
2. Player: “我需要知道那一夜发生了什么。”
3. Ormund: “那就看着水面。” / “看清……你曾经做过什么。”

Then:

1. Set `ch4_boss_defeated` exactly once.
2. Stop/fade Boss music and finish the existing death presentation.
3. Unlock the east route to Area 15.
4. In Area 15, create one persistent reward reliquary slot and `ch4_reward_unlocked`; do not assign weapon identity, stats or ability until separately approved.
5. On collection, set `ch4_reward_collected`, open the memory passage and set `ch4_memory_passage_unlocked`.
6. Area 16 performs the short memory event and hands off to a future real Chapter V scene/spawn.

### 8. Estimated BOSS4 implementation files (not changed in BOSS4-0)

Estimated 14–22 production/test files:

- new Soul-Lock Gate scene/script and interaction assets/references;
- new Area 13 staging controller;
- new Area 14 Boss encounter controller, fixed Boss HUD scene/script binding and arena barriers;
- Ormund lifecycle hooks for externally controlled intro/death (combat moves/tuning preserved);
- Area 15 reward-shell controller with content deliberately unset;
- Area 16 memory/handoff controller;
- ChapterSession/Chapter profile flags and future CH5 placeholder registration;
- MainBootstrap tests, retry/reload tests, captures, specs and development log.

### 9. BOSS4 formal Main/F5 acceptance plan

1. Start MainBootstrap at Final Lock and clear both groups in sequence.
2. Activate `CP_CH4_BOSS`; die/reload and prove exact checkpoint restoration.
3. Enter the Antechamber; verify no automatic invisible transition and that `E` controls the Soul-Lock Gate.
4. First entry: Player input locked, camera/door/Boss presentation ordered, all dialogue shown once, Boss name/HUD/music begin only after intro.
5. Fight through both current phases; verify all current attack/hit/death contracts remain intact.
6. Die in P1 and P2; retry from the Boss checkpoint with HP/stamina/arena/Boss state/music fully reset and no duplicate signals.
7. Defeat Boss; verify death dialogue, single flag emission, no early east exit and no duplicate reward.
8. Enter Area 15; verify exactly one reward shell while leaving final weapon values unassigned.
9. Collect the future approved reward; verify memory passage, Area 16 event and the future `CH5_START` handoff.
10. Save/reload at every persistent boundary and inspect Output/Debugger for red errors.

## Actual audit verification

The following exact-engine checks were run without changing production behavior:

- `Godot --headless --path . --script res://chapters/chapter_04_drowned_underkeep/tests/scenes/test_chapter_04_formal_route_s3.gd` — PASS: 17 rooms, 665 assets, 2 checkpoints, 20 encounters, 46 enemies.
- `Godot --headless --path . --script res://chapters/chapter_04_drowned_underkeep/tests/scenes/test_chapter_04_encounter_manifests_s4.gd` — PASS: 10 combat rooms, 20 groups, 46 enemies, 13 elevated, 7 Harpooners, seed 40446.
- `Godot --headless --path . --script res://chapters/chapter_04_drowned_underkeep/tests/scenes/test_chapter_04_main_route_s3.gd` — PASS: MainBootstrap resolved all 17 rooms and Area 16.
- `Godot --headless --path . --script res://chapters/chapter_04_drowned_underkeep/tests/scenes/test_chapter_04_transitions_s5.gd` — PASS: 32 direct controller transitions; this test does not validate user-visible edge interaction.
- Temporary runtime diagnostic through MainBootstrap — PASS execution: all eight enemy types were observed active; each performed an attack; collision contract was probed with the real Player attack Hitbox.
- Temporary isolated reaction diagnostic — reproduced: Drowned Gaoler and Bog Toad remained `LightHitReaction` two seconds after accepted damage.
- Temporary Cistern probe through MainBootstrap — reproduced a successful Area 05→06 runtime change and confirmed `(120,592)`, visible Player and Full input.

No production code or scene was modified in this audit. Temporary diagnostic scripts were removed after recording the evidence.
