# Chapter IV Q2–Q4 and BOSS4 completion report

Date: 2026-08-05
F5 authority: `res://scenes/bootstrap/main_bootstrap.tscn`
Formal chapter scene: `res://chapters/chapter_04_drowned_underkeep/scenes/level/drowned_underkeep.tscn`

The read-only inventory and root-cause evidence for all 17 rooms, 20 EncounterGroups, 46 ordinary/elite instances and nine combatant types is retained in `chapter_04_q1_a_boss4_0_audit.md`. This report records the implemented Q2, Q3, Q4 and BOSS4 results.

## 第四章战斗与转场QA总结果

| 验收项 | 状态 | 证据 |
|---|---|---|
| 全部正式场景已扫描 | PASS | `test_chapter_04_formal_route_s3.gd`: 17 rooms, 670 assets |
| 全部敌人实例已扫描 | PASS | formal route/manifests: 20 groups, 46 enemies, 8 ordinary/elite roles plus Ormund |
| 全部Encounter已扫描 | PASS | `test_chapter_04_encounter_manifests_s4.gd`: 10 combat rooms, 20 groups |
| 敌人能够移动 | PASS | common runtime test plus 160-kill/360-attack stress run |
| 敌人能够检测Player | PASS | Main encounter runtime and every role's shared detection contract |
| 敌人能够攻击 | PASS | `test_chapter_04_enemy_runtime.gd` and combat stress |
| 攻击Hitbox能够伤害Player | PASS | shared active-window/unique-attack-id runtime checks |
| Player能够命中敌人 | PASS | all eight role Hurtboxes plus Boss Hurtbox after intro |
| Enemy Hurtbox能够收伤 | PASS | LightHit exit fixed; Sewer Maw Hurtbox restored after emergence |
| 敌人能够死亡 | PASS | 160 stress kills, encounter completion and cleanup |
| Encounter能够结算 | PASS | Cistern all groups clear and gate unlock in Main flow test |
| 异鳞蓄水池出口提示 | PASS | `Ch4CisternOfTheChanged/Transitions/ExitEast/Prompt` verified visible in range |
| 异鳞蓄水池出口交互 | PASS | real `interact` InputEventAction accepted after encounters clear |
| 下一场景正常加载 | PASS | Main transition controller loaded `CH4_AREA_06/EntryWest` |
| Player出生点正确 | PASS | Player position equals Area 06 `SpawnPoints/EntryWest` |
| Camera与HUD正常 | PASS | persistent Player/HUD IDs and per-room camera bounds across 32 transitions |
| Main/F5正式流程 | PASS | GUI MainBootstrap capture and headless MainBootstrap route tests |
| Output与Debugger | PASS | exact Godot 4.7.1 suites finish without red script/resource/runtime errors |

## Q2 enemy runtime fixes

The fixes remain shared rather than per-instance overrides:

- `res://scripts/encounters/encounter_group.gd`: dormant groups now hide enemies and mark `encounter_active=false`; activation restores visibility, processing and AI once.
- `res://chapters/chapter_04_drowned_underkeep/scripts/encounters/chapter_04_encounter_spawner.gd`: room activation can be suspended during scene insertion.
- `res://chapters/chapter_04_drowned_underkeep/scripts/level/chapter_04_room_transition_controller.gd`: destination room metadata is set before `add_child`, preventing an old Player world position from activating the wrong encounter under the fade.
- `res://chapters/chapter_04_drowned_underkeep/scripts/enemies/chapter_04_enemy.gd`: every reaction state, including `LightHitReaction`, exits; Sewer Maw always re-enters its hidden/emergence contract after dormancy and re-enables the Hurtbox before combat.

Collision/authority stayed centralized: world `1`, Player body `2`, Player Hurtbox `8`, enemy body `4`, enemy Hurtbox `16`, Player Hitbox mask `16`, enemy Hitbox mask `8`. No broad collision-mask workaround, permanent aggro or direct-position chase was introduced.

## Q3 Cistern exit

Formal nodes:

- Room: `Ch4CisternOfTheChanged`
- Exit: `Ch4CisternOfTheChanged/Transitions/ExitEast`
- Prompt: `Ch4CisternOfTheChanged/Transitions/ExitEast/Prompt`
- Gate: `Ch4CisternOfTheChanged/Transitions/CisternExitGate`
- Physical blocker: `Ch4CisternOfTheChanged/Transitions/CisternExitGate/Blocker`
- Destination: `CH4_AREA_06`, spawn `EntryWest` at the safe in-bounds marker.

The exit is now an explicit E interaction. It displays a sealed message before every Cistern encounter is complete, opens the visual/physical gate after completion, delays briefly for presentation, then emits the ordinary room-transition request. The Player cannot walk beyond the camera/world boundary and cannot bypass the encounter through an invisible auto-trigger.

## 第四章Boss区域与第五章转场强制QA报告

| 项目 | 状态 | 证据 |
|---|---|---|
| Boss前最后战斗 | PASS | Area 11 retains two ordered formal EncounterGroups from the 20-group manifest |
| Boss检查点 | PASS | Area 12 `Gameplay/Checkpoint`, ID `CP_CH4_BOSS`; stress reload 10/10 |
| Boss前室 | PASS | `ch4_13_soul_lock_antechamber.tscn` |
| Boss身份预告 | PASS | chapter-authored Soul Lock architecture and gate presentation |
| Boss门设计 | PASS | `BossGatePresentation` with panels, blocker and interaction prompt |
| Boss门交互 | PASS | interaction contract observed 20/20 in Main route stress |
| Boss门Collision | PASS | gate blocker is a dedicated `StaticBody2D`, room transition occurs only after interaction |
| Fade Out | PASS | persistent `Chapter04RoomTransitionController` fade path |
| Boss房加载 | PASS | Area 14 `Core of Drowned Gaol` through Main controller |
| Player Spawn | PASS | Area 14 `EntryWest`, input locked during intro |
| Boss首次Intro | PASS | seven approved bilingual beats, completed 10/10 in stress test |
| Boss对白 | PASS | church absolution lie, imprisoned memory, seven-year return and deepest-cell reveal retained |
| Boss名称与血条 | PASS | runtime `BossFlowUI/BossHUD`, hidden until intro conclusion |
| Phase Transition | PASS | typed Phase 2 transition, hitboxes canceled, separate Phase 2 music |
| Boss死亡 | PASS | death start → collapse → soul release, 10/10; attack windows end first |
| Boss音乐淡出 | PASS | MusicManager fade at death; two original chapter-local tracks |
| 奖励只出现一次 | PASS | one `RewardController`; repeated collect calls are idempotent |
| 奖励未领取持久化 | PASS | 5/5 room reload/backtrack checks keep reward present and passage locked |
| 奖励领取去重 | PASS | 10 collection runs and 100 repeated E-equivalent requests produced one flag transaction per run |
| 第五章出口解锁 | PASS | requires `ch4_reward_collected` / `ch4_memory_passage_unlocked` |
| 溺忆回廊 | PASS | Area 16 `Hall of Drowned Memories`, no encounters |
| CH5_START | PASS | registered debug-ready Chapter V placeholder and exact spawn, checked 10/10 |
| Main/F5 | PASS | actual MainBootstrap OpenGL Compatibility capture, 13 frames |
| Output/Debugger | PASS | editor parse, route, runtime, stress and GUI capture have no red errors |

## Boss lifecycle and retry authority

- Formal controller: `Ch4CoreOfDrownedGaol/BossRoomController`.
- Formal Boss: `Ch4CoreOfDrownedGaol/Enemies/SoulGaolerOrmund`.
- Intro owns Player lock/invulnerability; Boss AI, DetectionArea and Hurtbox remain disabled until the HUD reveal ends.
- Player respawn restarts Area 14 with full Boss HP and Phase 1. The persistent `ch4_boss_intro_seen` flag selects a 0.45-second retry presentation instead of replaying the long dialogue.
- Boss death sets `ch4_boss_defeated` and `ch4_reward_unlocked` once. Backtracking through Area 14 no longer creates a second Boss and keeps the reward exit open.
- Phase tracks are `CH4_BOSS_SOUL_GAOLER_PHASE_01` and `CH4_BOSS_SOUL_GAOLER_PHASE_02`; both WAVs are original locally generated assets.
- Leaving or restarting the Boss room stops only Ormund's active track and clears its Phase 2 guard, preventing an AudioStream playback/resource survivor during repeated room teardown.

## Reward and Chapter V boundary

The fourth-chapter reward's final identity and gameplay values were not approved. The implementation therefore uses the explicit flow-only ID `CH4_UNNAMED_CHAIN_RELIC_PLACEHOLDER`. It owns no permanent weapon stats and is never reported as final content.

Formal route:

`Final Lock Approach → Last Gaol Checkpoint → Soul Lock Antechamber → Core of Drowned Gaol → Broken Soul Reservoir → Hall of Drowned Memories → CH5_START placeholder`.

On the first Hall entry, `MemoryPassageController` presents three restrained bilingual water/Veil/Crown fragments, protects and locks the Player only for the short presentation, and restores the prior input/invulnerability state even if the room is exited early. Its node-owned Timer sequence waits for the room-transition lock to settle and is destroyed with the room, avoiding stale locks and suspended coroutines during rapid backtracking. The final E prompt uses `SceneTransitionManager` to load the registered Chapter V scene and place the persistent Player at `CH5_START`.

Flags:

- `ch4_boss_intro_seen`
- `ch4_boss_defeated`
- `ch4_reward_unlocked`
- `ch4_reward_collected`
- `ch4_memory_passage_unlocked`
- `ch4_memory_passage_entered`

## Exact verification

- `test_chapter_04_formal_route_s3.gd` — PASS: rooms 17, assets 670, checkpoints 2, encounters 20, enemies 46.
- `test_chapter_04_transitions_s5.gd` — PASS: 32 transitions, one room instance, persistent Player/HUD.
- `test_chapter_04_encounter_manifests_s4.gd` — PASS: 20 groups, 46 enemies, 13 elevated placements, 7 harpooners.
- `test_chapter_04_encounter_runtime_s4.gd` — PASS: serialization, rearm and deterministic reload.
- `test_chapter_04_main_encounters_s4.gd` — PASS through MainBootstrap; its former forced-exit resource warning was removed by deterministic teardown.
- `test_chapter_04_enemy_runtime.gd` — PASS.
- `test_chapter_04_combat_stress.gd` — PASS: eight roles, 160 kills, 360 attacks, five encounter reloads.
- `test_soul_gaoler_ormund_runtime.gd` — PASS.
- `test_chapter_04_q4_boss_flow.gd` — PASS: Main Boss/reward/memory, actual E-driven `SceneTransitionManager` handoff to CH5 and natural Cistern E transition.
- `test_chapter_04_boss_route_stress.gd` — PASS: checkpoint 10, gate 20, intro 10, retry 10, death 10, unclaimed reload 5, reward collect 10, repeated input 100, memory/CH5 10.
- `capture_chapter_04_q4_boss_main_qa.gd` — PASS: OpenGL Compatibility / Apple M4, 13 distinct 1280×720 images.
- `git diff --check` — PASS.

## Human acceptance boundary

Automated runtime contracts and rendered Main evidence are PASS. Human playtesting should still judge Boss music, dialogue cadence, attack fairness and the visual clarity of the temporary reward presentation. Final reward content remains the only deliberately unresolved design item.
