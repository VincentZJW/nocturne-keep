# Prologue and Chapter I Path Manifest

Date: 2026-07-26
Purpose: Stage 0 source-of-truth for the approved Stage 1 migration.
Status: planned only; no listed path has moved yet.

`是否移动` means the Stage 1 proposal. `保留并更新引用` means the file stays at its current path but references to moved targets inside it must change. Directory rows include every tracked source file and its tracked `.uid`/`.import` sidecar under that directory unless a later row narrows the scope.

## Prologue manifest

| 当前路径 | 目标路径 | 类型 | 归属 | 引用位置 | 是否移动 |
|---|---|---|---|---|---|
| `scenes/cinematics/opening_cinematic.tscn` | `chapters/prologue/scenes/cinematics/opening_cinematic.tscn` | PackedScene | prologue | `project.godot`; Chapter flow tests/tools; tutorial replay | 是 |
| `scripts/cinematics/opening_cinematic_controller.gd` + `.uid` | `chapters/prologue/scripts/cinematics/opening_cinematic_controller.gd` + `.uid` | Script | prologue | Opening scene; controller target string | 是 |
| `scripts/cinematics/opening_cinematic_art.gd` + `.uid` | `chapters/prologue/scripts/cinematics/opening_cinematic_art.gd` + `.uid` | Script | prologue | Opening scene | 是 |
| `scripts/cinematics/opening_cinematic_timeline.gd` + `.uid` | `chapters/prologue/scripts/cinematics/opening_cinematic_timeline.gd` + `.uid` | Resource script | prologue | Opening timeline Resource | 是 |
| `resources/narrative/opening_cinematic_timeline.tres` | `chapters/prologue/resources/narrative/opening_cinematic_timeline.tres` | Resource | prologue | Opening scene | 是 |
| `scenes/levels/veilbound_catacomb.tscn` | `chapters/prologue/scenes/level/veilbound_catacomb.tscn` | PackedScene | prologue | Opening target; ChapterSession; tests/tools | 是 |
| `scripts/levels/veilbound_catacomb_controller.gd` + `.uid` | `chapters/prologue/scripts/level/veilbound_catacomb_controller.gd` + `.uid` | Script | prologue | Catacomb scene; Main target string | 是 |
| `scripts/world/veilbound_catacomb_art.gd` + `.uid` | `chapters/prologue/scripts/world/veilbound_catacomb_art.gd` + `.uid` | Script | prologue | Catacomb scene | 是 |
| `scripts/world/catacomb_stone_door.gd` + `.uid` | `chapters/prologue/scripts/world/catacomb_stone_door.gd` + `.uid` | Script | prologue | Catacomb scene | 是 |
| `scripts/world/catacomb_door_opening_backdrop.gd` + `.uid` | `chapters/prologue/scripts/world/catacomb_door_opening_backdrop.gd` + `.uid` | Script | prologue | Catacomb scene | 是 |
| `scripts/world/catacomb_door_frame_front.gd` + `.uid` | `chapters/prologue/scripts/world/catacomb_door_frame_front.gd` + `.uid` | Script | prologue | Catacomb scene | 是 |
| `scripts/narrative/catacomb_dialogue.gd` + `.uid` | `chapters/prologue/scripts/narrative/catacomb_dialogue.gd` + `.uid` | Resource script | prologue | Four Catacomb dialogue Resources | 是 |
| `scripts/narrative/revival_player_art.gd` + `.uid` | `chapters/prologue/scripts/narrative/revival_player_art.gd` + `.uid` | Script | prologue | Catacomb scene | 是 |
| `scenes/npcs/candle_warden.tscn` | `chapters/prologue/scenes/npcs/candle_warden.tscn` | PackedScene | prologue | Catacomb scene | 是 |
| `scripts/npcs/candle_warden.gd` + `.uid` | `chapters/prologue/scripts/npcs/candle_warden.gd` + `.uid` | Script | prologue | Candle Warden scene | 是 |
| `scripts/ui/catacomb_dialogue_ui.gd` + `.uid` | `chapters/prologue/scripts/ui/catacomb_dialogue_ui.gd` + `.uid` | Script | prologue | Catacomb scene | 是 |
| `scripts/ui/chapter_objective_ui.gd` + `.uid` | `chapters/prologue/scripts/ui/chapter_objective_ui.gd` + `.uid` | Script | uncertain | Catacomb scene only today; may become shared in Chapter II | 暂不移动；Stage 2复审 |
| `resources/dialogue/catacomb_revival_*.tres` | `chapters/prologue/resources/dialogue/catacomb_revival_*.tres` | 4 Resources | prologue | Catacomb scene; dialogue script | 是 |
| `tests/level/test_veilbound_catacomb_flow.gd` + `.uid` | `chapters/prologue/tests/level/test_veilbound_catacomb_flow.gd` + `.uid` | Test | prologue | Direct scene/resource paths | 是 |
| `tests/level/test_veilbound_scene_transitions.gd` + `.uid` | `chapters/prologue/tests/integration/test_veilbound_scene_transitions.gd` + `.uid` | Test | prologue | Opening/Catacomb/Main path chain | 是 |
| `scripts/tools/capture_veilbound_catacomb_qa.gd` + `.uid` | `chapters/prologue/scripts/tools/capture_veilbound_catacomb_qa.gd` + `.uid` | QA tool | prologue | Catacomb/Main preloads; docs/qa outputs | 是 |
| `docs/narrative/opening_cinematic_script.md` | `chapters/prologue/docs/opening_cinematic_script.md` | Document | prologue | README/docs links | 是 |
| `docs/narrative/veilbound_catacomb_scene.md` | `chapters/prologue/docs/veilbound_catacomb_scene.md` | Document | prologue | README/docs links | 是 |
| `docs/narrative/candle_warden_character_spec.md` | `chapters/prologue/docs/candle_warden_character_spec.md` | Document | prologue | README/docs links | 是 |
| `docs/narrative/catacomb_revival_dialogue.md` | `chapters/prologue/docs/catacomb_revival_dialogue.md` | Document | prologue | README/docs links | 是 |

## Chapter I runtime manifest

| 当前路径 | 目标路径 | 类型 | 归属 | 引用位置 | 是否移动 |
|---|---|---|---|---|---|
| `scenes/main/main.tscn` | `chapters/chapter_01_ravenmourn_outskirts/scenes/level/ravenmourn_outskirts.tscn` | PackedScene | chapter_01 | Catacomb target; 24+ tests/tools/docs; Player/Boss/encounter instances | 是 |
| `scenes/levels/first_level_encounters.tscn` | `chapters/chapter_01_ravenmourn_outskirts/scenes/encounters/first_level_encounters.tscn` | PackedScene | chapter_01 | Main; five enemy PackedScenes; EncounterGroup script | 是 |
| `scenes/bosses/fallen_gate_knight.tscn` | `chapters/chapter_01_ravenmourn_outskirts/scenes/boss/fallen_gate_knight.tscn` | PackedScene | chapter_01 | Main; Boss test room; tests/tools | 是 |
| `scenes/bosses/fallen_gate_knight_reward.tscn` | `chapters/chapter_01_ravenmourn_outskirts/scenes/boss/fallen_gate_knight_reward.tscn` | PackedScene | chapter_01 | Main; Ravenfang pickup shared dependency | 是 |
| `scenes/transitions/ravenmourn_threshold.tscn` | `chapters/chapter_01_ravenmourn_outskirts/scenes/transitions/ravenmourn_threshold.tscn` | PackedScene | chapter_01 | Castle transition; loot test/tool | 是 |
| `scripts/bosses/` | `chapters/chapter_01_ravenmourn_outskirts/scripts/boss/` | 5 Scripts + UIDs | chapter_01 | Boss/Boss reward/Main HUD and controller | 是（整个目录） |
| `resources/bosses/` | `chapters/chapter_01_ravenmourn_outskirts/resources/boss/` | 3 Resources | chapter_01 | Boss scene; SpriteFrames contain 141 animation frame entries | 是（整个目录） |
| `assets/sprites/bosses/fallen_gate_knight/` | `chapters/chapter_01_ravenmourn_outskirts/assets/boss/fallen_gate_knight/` | 200 asset/import files | chapter_01 | Boss SpriteFrames; generator/validator | 是（整个目录） |
| `scripts/tutorial/tutorial_controller.gd` + `.uid` | `chapters/chapter_01_ravenmourn_outskirts/scripts/level/tutorial_controller.gd` + `.uid` | Script | chapter_01 | Main; Opening replay path | 是 |
| `scripts/world/castle_entrance_transition.gd` + `.uid` | `chapters/chapter_01_ravenmourn_outskirts/scripts/transitions/castle_entrance_transition.gd` + `.uid` | Script | chapter_01 | Main; threshold target string | 是 |
| `scripts/world/castle_frontier_transition_art.gd` + `.uid` | `chapters/chapter_01_ravenmourn_outskirts/scripts/world/castle_frontier_transition_art.gd` + `.uid` | Script | chapter_01 | Main | 是 |
| `scripts/world/castle_gate_controller.gd` + `.uid` | `chapters/chapter_01_ravenmourn_outskirts/scripts/world/castle_gate_controller.gd` + `.uid` | Script | chapter_01 | Main/Boss room | 是 |
| `scripts/world/chapter_one_storytelling_art.gd` + `.uid` | `chapters/chapter_01_ravenmourn_outskirts/scripts/world/chapter_one_storytelling_art.gd` + `.uid` | Script | chapter_01 | Main | 是 |
| `scripts/world/dark_forest_outskirts_art.gd` + `.uid` | `chapters/chapter_01_ravenmourn_outskirts/scripts/world/dark_forest_outskirts_art.gd` + `.uid` | Script | chapter_01 | Main | 是 |
| `scripts/world/moat_hazard.gd` + `.uid` | `chapters/chapter_01_ravenmourn_outskirts/scripts/world/moat_hazard.gd` + `.uid` | Script | chapter_01 | Main | 是 |
| `scripts/world/outskirts_surface_details.gd` + `.uid` | `chapters/chapter_01_ravenmourn_outskirts/scripts/world/outskirts_surface_details.gd` + `.uid` | Script | chapter_01 | Main | 是 |
| `scripts/world/ravenmourn_*.gd` + `.uid` | `chapters/chapter_01_ravenmourn_outskirts/scripts/world/ravenmourn_*.gd` + `.uid` | 7 Scripts + UIDs | chapter_01 | Main environment | 是 |
| `scripts/ui/boss_last_words_presenter.gd` + `.uid` | `chapters/chapter_01_ravenmourn_outskirts/scripts/ui/boss_last_words_presenter.gd` + `.uid` | Script | chapter_01 | Main | 是 |
| `scenes/ui/tutorial_prompt_ui.tscn` | `scenes/ui/tutorial_prompt_ui.tscn` | PackedScene | shared | Main; reusable prompt surface | 否 |
| `scripts/ui/tutorial_prompt_ui.gd` + `.uid` | 同当前路径 | Script | shared | Tutorial prompt scene | 否 |
| `scripts/tools/{first_level_boss_sprite_frames_builder,pixel_first_level_boss_generator}.gd` + `.uid` | `chapters/chapter_01_ravenmourn_outskirts/scripts/tools/` | 2 tools + UIDs | chapter_01 | Boss asset generation paths | 是 |
| `scripts/tools/capture_{boss_attack_geometry,castle_bridge,chapter_one,fallen_gate_knight_turn_shield,first_level_environment_unity,first_level_main,main_traversal,ravenfang_boss_cadence,ravenmourn_environment}.gd` + `.uid` | `chapters/chapter_01_ravenmourn_outskirts/scripts/tools/` | 9 QA tools + UIDs | chapter_01 | Main/Boss preloads; docs/qa outputs | 是 |
| `scripts/tools/capture_loot_weapon_qa.gd` + `.uid` | `chapters/chapter_01_ravenmourn_outskirts/scripts/tools/capture_loot_weapon_qa.gd` + `.uid` | QA tool | chapter_01 | Main and threshold preloads | 是 |
| `scripts/tools/boss_attack_geometry_debug_draw.gd` + `.uid` | `chapters/chapter_01_ravenmourn_outskirts/scripts/tools/boss_attack_geometry_debug_draw.gd` + `.uid` | Debug presentation | chapter_01 | Boss scene | 是 |
| `scenes/tools/boss_test_room.tscn` | 同当前路径 | Test scene | do_not_move | Player and Chapter I Boss PackedScenes | 否；更新引用 |
| `scripts/tools/boss_test_room_controller.gd` + `.uid` | 同当前路径 | Test script | do_not_move | Boss test room | 否 |

## Chapter I test and document manifest

| 当前路径 | 目标路径 | 类型 | 归属 | 引用位置 | 是否移动 |
|---|---|---|---|---|---|
| `tests/combat/test_{boss_attack_geometry,boss_counter_windows,first_level_boss,ravenfang_boss_pressure}.gd` + `.uid` | `chapters/chapter_01_ravenmourn_outskirts/tests/combat/` | 4 Tests | chapter_01 | Main/Boss/config paths | 是 |
| `tests/combat/test_main_enemy_integration.gd` + `.uid` | `chapters/chapter_01_ravenmourn_outskirts/tests/combat/test_main_enemy_integration.gd` + `.uid` | Test | chapter_01 | F5/Main/encounter paths | 是 |
| `tests/items/test_loot_weapon_progression.gd` + `.uid` | `chapters/chapter_01_ravenmourn_outskirts/tests/items/test_loot_weapon_progression.gd` + `.uid` | Integration test | chapter_01 | Main/Boss/threshold; shared item systems | 是 |
| `tests/level/test_{castle_bridge_flow,chapter_one_flow,first_level_environment_unity,main_platform_reachability,main_traversal_routes,ravenmourn_environment}.gd` + `.uid` | `chapters/chapter_01_ravenmourn_outskirts/tests/level/` | 6 Tests | chapter_01 | Main and Chapter I scripts/nodes | 是 |
| `tests/tools/validate_first_level_boss_assets.gd` + `.uid` | `chapters/chapter_01_ravenmourn_outskirts/tests/tools/validate_first_level_boss_assets.gd` + `.uid` | Test | chapter_01 | Boss asset/resource paths | 是 |
| `docs/narrative/chapter_01_story_spec.md` | `chapters/chapter_01_ravenmourn_outskirts/docs/narrative/chapter_01_story_spec.md` | Document | chapter_01 | README | 是 |
| `docs/design/boss_fallen_gate_knight_spec.md` | `chapters/chapter_01_ravenmourn_outskirts/docs/design/boss_fallen_gate_knight_spec.md` | Document | chapter_01 | README/docs | 是 |
| `docs/design/boss_room_spec.md` | `chapters/chapter_01_ravenmourn_outskirts/docs/design/boss_room_spec.md` | Document | chapter_01 | README/docs | 是 |
| `docs/design/environment_art_spec.md` | `chapters/chapter_01_ravenmourn_outskirts/docs/design/environment_art_spec.md` | Document | chapter_01 | README/docs | 是 |
| `docs/design/environment_storytelling_spec.md` | `chapters/chapter_01_ravenmourn_outskirts/docs/design/environment_storytelling_spec.md` | Document | chapter_01 | README/docs | 是 |
| `docs/design/first_level_encounter_spec.md` | `chapters/chapter_01_ravenmourn_outskirts/docs/design/first_level_encounter_spec.md` | Document | chapter_01 | README/docs | 是 |
| `docs/design/level_metrics.md` | `chapters/chapter_01_ravenmourn_outskirts/docs/design/level_metrics.md` | Document | chapter_01 | README/tests | 是 |
| `docs/design/level_traversal_spec.md` | `chapters/chapter_01_ravenmourn_outskirts/docs/design/level_traversal_spec.md` | Document | chapter_01 | README/docs | 是 |
| `docs/design/tutorial_spec.md` | `chapters/chapter_01_ravenmourn_outskirts/docs/design/tutorial_spec.md` | Document | chapter_01 | README/docs | 是 |
| `docs/design/weapon_balance_spec.md` | `chapters/chapter_01_ravenmourn_outskirts/docs/design/weapon_balance_spec.md` | Document | chapter_01 | README/docs | 是 |
| `docs/qa/` | `docs/qa/` | Historical evidence | do_not_move | Many reports/screenshots/logs; seven user-modified captures | 否；只更新必要的当前文档引用 |

## Shared enemy migration manifest

| 当前路径 | 目标路径 | 类型 | 归属 | 引用位置 | 是否移动 |
|---|---|---|---|---|---|
| `scenes/enemies/` | `shared/scenes/enemies/` | 5 PackedScenes | shared | Chapter I encounters, test rooms, tests/tools | 是（整个目录） |
| `scripts/enemies/` | `shared/scripts/enemies/` | 13 Scripts + UIDs | shared | Enemy scenes/config Resources/tests | 是（整个目录） |
| `resources/enemies/` | `shared/resources/enemies/` | 13 Resources | shared | Enemy scenes; 124+ texture references | 是（整个目录） |
| `assets/sprites/enemies/` | `shared/assets/enemies/` | 423 asset/import files | shared | Enemy SpriteFrames, builders/validators | 是（整个目录） |
| `scripts/encounters/encounter_group.gd` + `.uid` | `shared/scripts/encounters/encounter_group.gd` + `.uid` | Script | shared | Chapter I encounter scene | 是 |
| `scenes/projectiles/crossbow_bolt.tscn` | `shared/scenes/projectiles/crossbow_bolt.tscn` | PackedScene | shared | Crossbowman scene/tests | 是 |
| `scripts/projectiles/crossbow_bolt.gd` + `.uid` | `shared/scripts/projectiles/crossbow_bolt.gd` + `.uid` | Script | shared | Bolt scene | 是 |
| `assets/sprites/projectiles/` | `shared/assets/projectiles/` | Asset/import files | shared | Bolt scene | 是 |
| `tests/enemies/` | `shared/tests/enemies/` | 2 Tests + UIDs | shared | Five enemy types | 是（整个目录） |
| `tests/combat/test_{crossbow_bolt,enemy_balance,enemy_variety_damage,gargoyle_sentinel}.gd` + `.uid` | `shared/tests/combat/` | 4 Tests | shared | Shared enemy/projectile paths | 是 |
| `tests/tools/validate_{castle_guard,enemy_variety}_assets.gd` + `.uid` | `shared/tests/tools/` | 2 Tests | shared | Shared enemy assets | 是 |
| `scenes/tools/{combat_test_room,enemy_variety_test_room,gargoyle_test_room}.tscn` | 同当前路径 | Test scenes | do_not_move | Shared enemy/Player paths | 否；更新引用 |
| `scripts/tools/{combat_test_room,enemy_variety_test_room}.gd` + `.uid` | 同当前路径 | Test scripts | do_not_move | Shared test scenes | 否；更新引用 |
| `scripts/tools/{build_castle_guard_assets,castle_guard_sprite_frames_builder,enemy_variety_sprite_frames_builder,pixel_castle_guard_generator,pixel_enemy_variety_generator}.gd` + `.uid` | 同当前路径 | Asset tools | do_not_move | Shared enemy asset/resource paths | 否；更新引用 |
| `scripts/tools/capture_shield_guard_break_main.gd` + `.uid` | 同当前路径 | QA tool | do_not_move | Chapter I fixture plus shared Shield Guard | 否；更新引用 |
| `docs/design/enemy_*.md` | 同当前路径 | Documents | shared | README/docs | 否；update paths |
| `docs/design/enemy_roster_spec.md` | 同当前路径 | Document | shared | README/docs | 否；update paths |

## Shared and system paths retained in Stage 1

| 当前路径 | 目标路径 | 类型 | 归属 | 引用位置 | 是否移动 |
|---|---|---|---|---|---|
| `scenes/player/player.tscn` | 同当前路径 | PackedScene | shared | Prologue, Chapter I, tools/tests | 否 |
| `scripts/player/`, `resources/player/`, `assets/sprites/player/` | 同当前路径 | Runtime bundle | shared | Player scene and tests | 否 |
| `scripts/combat/` | 同当前路径 | Components | shared | Player, enemies, Boss | 否 |
| `scripts/items/`, `resources/items/`, `scenes/items/`, `assets/ui/items/` | 同当前路径 | Runtime bundle | shared | Autoloads, enemies, Boss reward, HUD | 否 |
| `scripts/systems/checkpoint_trigger.gd` + `.uid` | 同当前路径 | Script | shared | Chapter I checkpoints | 否 |
| `scripts/systems/player_respawn_controller.gd` + `.uid` | 同当前路径 | Script | shared | Chapter I and test scenes | 否 |
| `scripts/systems/chapter_session.gd` + `.uid` | 同当前路径 | Autoload script | system | `project.godot`; Catacomb replay string | 否；更新引用 |
| `scripts/systems/currency_manager.gd` + `.uid` | 同当前路径 | Autoload script | system | `project.godot` | 否 |
| `scripts/items/{weapon_inventory,equipment_manager}.gd` + `.uid` | 同当前路径 | Autoload scripts | system | `project.godot` | 否 |
| `scripts/ui/player_*.gd`, `scripts/ui/run_inventory_hud.gd` | 同当前路径 | HUD scripts | shared | Prologue/Chapter I HUD | 否 |
| `scripts/tools/main_*.gd`, `scripts/tools/player_*.gd`, `scripts/tools/level_traversal_debug_overlay.gd` | 同当前路径 | Debug tools | shared | Chapter I Main | 否；更新Main paths in tests/tools as needed |
| `tests/player/`, `tests/ui/`, shared component tests | 同当前路径 | Tests | shared | Shared Player/HUD/components | 否；update Chapter I fixture path where necessary |
| `docs/design/chapter_02_combat_scaling_spec.md` | Stage 2 destination to decide | Document | uncertain | Future Chapter II | 否 |
| `docs/narrative/world_bible.md` | 同当前路径 | Document | shared | Global lore | 否 |
| `docs/narrative/character_protagonist_spec.md` | 同当前路径 | Document | shared | Player narrative | 否 |
| `docs/development_log.md` | 同当前路径 | Primary log | system | Project history | 否；update active path references during Stage 1 |
| `docs/technical_architecture.md` | 同当前路径 | Architecture | system | Project-wide | 否；update ownership/path facts only |
| `README.md` | 同当前路径 | Project entry doc | system | All users | 否；update paths |
| `project.godot` | 同当前路径 | Project settings | system | Engine | 否；update `run/main_scene` only after migrated chain resolves |

## Old-path references that Stage 1 must update

1. `res://scenes/cinematics/opening_cinematic.tscn`: `project.godot`, tutorial replay, Chapter flow tests and QA tools.
2. `res://scenes/levels/veilbound_catacomb.tscn`: Opening scene/controller, `ChapterSession`, Catacomb tests and QA tools.
3. `res://scenes/main/main.tscn`: Catacomb controller, 24+ tests/tools and current documents.
4. `res://scenes/levels/first_level_encounters.tscn`: Chapter I gameplay scene.
5. `res://scenes/bosses/fallen_gate_knight*.tscn`: Chapter I gameplay scene, Boss test room and Boss tests/tools.
6. `res://resources/bosses/*`, `res://scripts/bosses/*`, `res://assets/sprites/bosses/*`: Boss scene, SpriteFrames, builders, validators and documents.
7. `res://scenes/transitions/ravenmourn_threshold.tscn`: transition controller, tests/tools and docs.
8. `res://scenes/enemies/*`, `res://scripts/enemies/*`, `res://resources/enemies/*`, `res://assets/sprites/enemies/*`: encounters, test rooms, loot/tests/tools and docs.
9. Prologue dialogue/narrative and world/UI script paths in Catacomb `.tscn`/`.tres` files.
10. README and all current design/narrative path examples. Historical address literals in `docs/development_log.md` require a deliberate migration note or rewrite; they must not be mistaken for live paths.

Stage 1 must end with a global old-path search. Outside `docs/migration/`, no live runtime/test reference may resolve to an old address.
