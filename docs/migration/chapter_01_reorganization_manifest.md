# Chapter I Reorganization Manifest

Date: 2026-07-27
Chapter: `CHAPTER_01_RAVENMOURN_OUTSKIRTS`
Status: complete; migration and verification finished on 2026-07-27

This manifest is the execution authority for moving the complete Chapter I runtime out of the legacy root folders. Directory rows include every tracked source file and its tracked `.gd.uid` or source `.import` sidecar. `.godot/` cache files are never migration inputs.

## Scope and ownership decisions

- Prologue assets (`Opening Cinematic`, `Veilbound Catacomb`, Candle Warden and revival dialogue) remain in their existing project-level locations. They are not Chapter I content.
- Chapter I owns Ravenmourn Outskirts, its tutorial/regions/encounters, Castle Guard, Decayed Spearman, Fallen Gate Knight, the bridge arena, reward/exit composition, Chapter I QA tooling and Chapter I design documents.
- Cursed Shield Guard, Fallen Crossbowman and Gargoyle Sentinel move to `res://shared/` because the approved Chapter II roster explicitly reuses their formal scenes. Chapter I and Chapter II must reference one shared source of truth.
- Castle Guard and Decayed Spearman remain Chapter I-owned because Chapter II has no approved runtime use for them.
- Player, combat components, health/stamina/HUD, inventory/equipment/currency, generic pickups, checkpoint/respawn, generic debug UI, fonts and global chapter services remain in their current neutral project paths. Moving those systems is outside this migration.
- The existing `run/main_scene` remains the formal Opening scene. Chapter I's gameplay root moves, and all registry/controller/test references are updated to the new path.

## Migration units

| Current path | Target path | File type / count | Ownership | Principal reference sources | Operation | Status |
|---|---|---|---|---|---|---|
| `res://scenes/main/main.tscn` | `res://chapters/chapter_01_ravenmourn_outskirts/scenes/level/ravenmourn_outskirts.tscn` | PackedScene / 1 | Chapter I | ChapterRegistry, Catacomb controller, tests, QA tools | `git mv`, rewrite references | Complete |
| `res://scenes/levels/first_level_encounters.tscn` | `res://chapters/chapter_01_ravenmourn_outskirts/scenes/encounters/first_level_encounters.tscn` | PackedScene / 1 | Chapter I | Chapter I gameplay root | `git mv`, rewrite references | Complete |
| `res://scenes/enemies/castle_guard.tscn` | `res://chapters/chapter_01_ravenmourn_outskirts/scenes/enemies/castle_guard.tscn` | PackedScene / 1 | Chapter I | encounter/test scenes | `git mv`, rewrite references | Complete |
| `res://scripts/enemies/castle_guard*.gd*` | `res://chapters/chapter_01_ravenmourn_outskirts/scripts/enemies/` | Script + UID / 6 | Chapter I | Castle Guard scene/config/tests/tools | `git mv`, rewrite references | Complete |
| `res://resources/enemies/castle_guard_*` | `res://chapters/chapter_01_ravenmourn_outskirts/resources/enemies/` | Resources / 2 | Chapter I | Castle Guard scene, asset validation | `git mv`, rewrite references | Complete |
| `res://assets/sprites/enemies/castle_guard/` | `res://chapters/chapter_01_ravenmourn_outskirts/assets/enemies/castle_guard/` | PNG + import sidecars / 50 | Chapter I | Castle Guard SpriteFrames/builders | `git mv`, rewrite references | Complete |
| `res://scenes/enemies/decayed_spearman.tscn` | `res://chapters/chapter_01_ravenmourn_outskirts/scenes/enemies/decayed_spearman.tscn` | PackedScene / 1 | Chapter I | encounters/tests | `git mv`, rewrite references | Complete |
| `res://scripts/enemies/decayed_spearman*.gd*` | `res://chapters/chapter_01_ravenmourn_outskirts/scripts/enemies/` | Script + UID / 4 | Chapter I | Spearman scene/config/tests/tools | `git mv`, rewrite references | Complete |
| `res://resources/enemies/decayed_spearman_*` | `res://chapters/chapter_01_ravenmourn_outskirts/resources/enemies/` | Resources / 2 | Chapter I | Spearman scene/frames/tests | `git mv`, rewrite references | Complete |
| `res://assets/sprites/enemies/decayed_spearman/` | `res://chapters/chapter_01_ravenmourn_outskirts/assets/enemies/decayed_spearman/` | PNG + import sidecars / 50 | Chapter I | Spearman SpriteFrames/builders | `git mv`, rewrite references | Complete |
| `res://scenes/enemies/cursed_shield_guard.tscn` | `res://shared/scenes/enemies/cursed_shield_guard.tscn` | PackedScene / 1 | Shared Chapters I/II | encounters, mixed test room, Chapter II roster | `git mv`, rewrite references | Complete |
| `res://scripts/enemies/cursed_shield_guard*.gd*` | `res://shared/scripts/enemies/` | Script + UID / 4 | Shared Chapters I/II | Shield Guard scene/config | `git mv`, rewrite references | Complete |
| `res://resources/enemies/cursed_shield_guard_*` | `res://shared/resources/enemies/` | Resources / 5 | Shared Chapters I/II | Shield Guard scene/assets/tests | `git mv`, rewrite references | Complete |
| `res://assets/sprites/enemies/cursed_shield_guard/` | `res://shared/assets/enemies/cursed_shield_guard/` | PNG + import sidecars / 140 | Shared Chapters I/II | Shield Guard SpriteFrames/effects | `git mv`, rewrite references | Complete |
| `res://scenes/enemies/fallen_crossbowman.tscn` | `res://shared/scenes/enemies/fallen_crossbowman.tscn` | PackedScene / 1 | Shared Chapters I/II | encounters, mixed test room, Chapter II roster | `git mv`, rewrite references | Complete |
| `res://scripts/enemies/fallen_crossbowman*.gd*` | `res://shared/scripts/enemies/` | Script + UID / 4 | Shared Chapters I/II | Crossbowman scene/config | `git mv`, rewrite references | Complete |
| `res://resources/enemies/fallen_crossbowman_*` | `res://shared/resources/enemies/` | Resources / 2 | Shared Chapters I/II | Crossbowman scene/frames/tests | `git mv`, rewrite references | Complete |
| `res://assets/sprites/enemies/fallen_crossbowman/` | `res://shared/assets/enemies/fallen_crossbowman/` | PNG + import sidecars / 60 | Shared Chapters I/II | Crossbowman SpriteFrames | `git mv`, rewrite references | Complete |
| `res://scenes/projectiles/crossbow_bolt.tscn` | `res://shared/scenes/projectiles/crossbow_bolt.tscn` | PackedScene / 1 | Shared Chapters I/II | Crossbowman scene/tests | `git mv`, rewrite references | Complete |
| `res://scripts/projectiles/crossbow_bolt.gd*` | `res://shared/scripts/projectiles/crossbow_bolt.gd*` | Script + UID / 2 | Shared Chapters I/II | bolt scene | `git mv`, rewrite references | Complete |
| `res://assets/sprites/projectiles/crossbow_bolt.png*` | `res://shared/assets/projectiles/crossbow_bolt.png*` | PNG + import / 2 | Shared Chapters I/II | bolt scene | `git mv`, rewrite references | Complete |
| `res://scenes/enemies/gargoyle_sentinel.tscn` | `res://shared/scenes/enemies/gargoyle_sentinel.tscn` | PackedScene / 1 | Shared Chapters I/II | encounters, Gargoyle test, Chapter II roster | `git mv`, rewrite references | Complete |
| `res://scripts/enemies/gargoyle_sentinel*.gd*` | `res://shared/scripts/enemies/` | Script + UID / 4 | Shared Chapters I/II | Gargoyle scene/config | `git mv`, rewrite references | Complete |
| `res://resources/enemies/gargoyle_sentinel_*` | `res://shared/resources/enemies/` | Resources / 2 | Shared Chapters I/II | Gargoyle scene/frames/tests | `git mv`, rewrite references | Complete |
| `res://assets/sprites/enemies/gargoyle_sentinel/` | `res://shared/assets/enemies/gargoyle_sentinel/` | PNG + import sidecars / 124 | Shared Chapters I/II | Gargoyle SpriteFrames | `git mv`, rewrite references | Complete |
| `res://scripts/enemies/{enemy_combatant,enemy_ground_config,ground_enemy_base}.gd*` | `res://shared/scripts/enemies/` | Common scripts + UID / 6 | Shared | all ground/flying enemy scripts | `git mv`, rewrite references | Complete |
| `res://scenes/bosses/fallen_gate_knight*.tscn` | `res://chapters/chapter_01_ravenmourn_outskirts/scenes/boss/` | PackedScenes / 2 | Chapter I | gameplay root, Boss tests/tools | `git mv`, rewrite references | Complete |
| `res://scripts/bosses/` | `res://chapters/chapter_01_ravenmourn_outskirts/scripts/boss/` | Scripts + UIDs / 10 | Chapter I | Boss scenes, root controller/HUD | `git mv`, rewrite references | Complete |
| `res://resources/bosses/` | `res://chapters/chapter_01_ravenmourn_outskirts/resources/boss/` | Resources / 3 | Chapter I | Boss scene/SpriteFrames | `git mv`, rewrite references | Complete |
| `res://assets/sprites/bosses/fallen_gate_knight/` | `res://chapters/chapter_01_ravenmourn_outskirts/assets/boss/fallen_gate_knight/` | PNG + import sidecars / 200 | Chapter I | Boss SpriteFrames/generator/validator | `git mv`, rewrite references | Complete |
| Chapter I world scripts listed below | `res://chapters/chapter_01_ravenmourn_outskirts/scripts/level/` | Scripts + UIDs / 28 | Chapter I | gameplay root | `git mv`, rewrite references | Complete |
| `res://scripts/tutorial/tutorial_controller.gd*` | `res://chapters/chapter_01_ravenmourn_outskirts/scripts/level/tutorial_controller.gd*` | Script + UID / 2 | Chapter I | gameplay root | `git mv`, rewrite references | Complete |
| `res://scripts/world/castle_entrance_transition.gd*` | `res://chapters/chapter_01_ravenmourn_outskirts/scripts/transitions/castle_entrance_transition.gd*` | Script + UID / 2 | Chapter I | gameplay root | `git mv`, rewrite references | Complete |
| `res://scenes/transitions/ravenmourn_threshold.tscn` | `res://chapters/chapter_01_ravenmourn_outskirts/scenes/transitions/ravenmourn_threshold.tscn` | PackedScene / 1 | Chapter I transition presentation | current transition/tests | `git mv`, rewrite references | Complete |
| Chapter I-specific tests listed below | `res://chapters/chapter_01_ravenmourn_outskirts/tests/` | SceneTree tests + UIDs | Chapter I | direct Main/Boss/encounter paths | `git mv`, rewrite references | Complete |
| Chapter I-specific QA/build tools listed below | `res://chapters/chapter_01_ravenmourn_outskirts/scripts/tests/` | tools + UIDs | Chapter I | Main/Boss/assets/QA outputs | `git mv`, rewrite references | Complete |
| Chapter I design/narrative documents listed below | `res://chapters/chapter_01_ravenmourn_outskirts/docs/` | Markdown | Chapter I | README/cross-doc links | `git mv`, rewrite references | Complete |

### Chapter I world scripts

`castle_frontier_transition_art`, `castle_gate_controller`, `chapter_one_storytelling_art`, `dark_forest_outskirts_art`, `moat_hazard`, `outskirts_surface_details`, `ravenmourn_approach_art`, `ravenmourn_archway_art`, `ravenmourn_bridge_art`, `ravenmourn_castle_backdrop`, `ravenmourn_gate_art`, `ravenmourn_moat_art`, `ravenmourn_surface_details`, plus `boss_last_words_presenter` and their `.gd.uid` sidecars.

### Chapter I-specific tests

- Combat: `test_boss_attack_geometry`, `test_boss_counter_windows`, `test_first_level_boss`, `test_main_enemy_integration`, `test_ravenfang_boss_pressure`.
- Level: `test_castle_bridge_flow`, `test_chapter_one_flow`, `test_first_level_environment_unity`, `test_main_platform_reachability`, `test_main_traversal_routes`, `test_ravenmourn_environment`.
- Items: `test_loot_weapon_progression`.
- Tools: `validate_first_level_boss_assets`.

Shared enemy tests remain in `res://tests/` for this pass; their path references will point to `res://shared/`. Player/HUD tests also remain project-level and use the migrated Chapter I scene only as an integration fixture.

### Chapter I-specific QA/build tools

`boss_attack_geometry_debug_draw`, `first_level_boss_sprite_frames_builder`, `pixel_first_level_boss_generator`, `capture_boss_attack_geometry_qa`, `capture_castle_bridge_qa`, `capture_chapter_one_qa`, `capture_fallen_gate_knight_turn_shield_qa`, `capture_first_level_environment_unity_qa`, `capture_first_level_main`, `capture_loot_weapon_qa`, `capture_main_traversal_qa`, `capture_ravenfang_boss_cadence_qa`, `capture_ravenmourn_environment_qa`, `capture_shield_guard_break_main` and their `.gd.uid` sidecars.

### Chapter I-specific documents

- Narrative: `chapter_01_story_spec.md`.
- Level/environment: `environment_art_spec.md`, `environment_storytelling_spec.md`, `first_level_encounter_spec.md`, `level_metrics.md`, `level_traversal_spec.md`, `tutorial_spec.md`, `scene_transition_spec.md`, `encounter_design_spec.md`.
- Enemies/Boss: all five `enemy_*_spec.md`, `enemy_roster_spec.md`, `boss_fallen_gate_knight_spec.md`, `boss_room_spec.md`.

Project-wide combat, player, health/stamina, currency/loot/weapon architecture, chapter system, save/session boundary and world-bible documents stay under `res://docs/`.

## References that must change

The pre-move audit found 388 files containing at least one legacy Chapter I/enemy/Boss path and 845 matching path occurrences. This includes:

- `.tscn` / `.tres` `ext_resource` entries and SpriteFrames texture paths;
- GDScript `preload`, `load`, `ResourceLoader` and `change_scene_to_file` strings;
- `ChapterRegistry.CHAPTER_01_SCENE_PATH` and the Catacomb exported Chapter I target;
- development QA tools, deterministic tests, README and current design documents;
- tracked `.import` `source_file` fields for moved source PNGs.

Outside this manifest and explicitly historical migration records, the final runtime/test old-path count must be zero.

## Dirty-worktree protection

Preflight contains 20 user-owned modified/untracked paths, including the Chapter I root scene, Boss/enemy tuning Resources, SpriteFrames, seven QA images and two generated `.uid` files. Migration will preserve their working-tree bytes. The migration commit will stage baseline path moves/reference rewrites; overlapping user edits will remain visible as unstaged changes at their new paths instead of being silently included or discarded.

## Execution order

1. Move shared enemy/common/projectile bundles and repair their internal references.
2. Move Chapter I-only enemies, Boss bundle, environment/tutorial scripts and tools/tests/docs.
3. Move encounter scene and Chapter I gameplay root last.
4. Update all remaining runtime, registry, test, tool and documentation references.
5. Import with exact Godot 4.7.1, run deterministic tests, then run direct Chapter I and configured F5 profiles.
6. Record screenshots/logs under `res://docs/qa/chapter_01_reorganization/`, verify zero broken resources and create one isolated commit.

## Completion record

- `824` tracked files were moved or removed from legacy locations (806 detected renames plus 18 legacy-path deletions). The committed Chapter I tree contains `472` tracked files; the shared tree contains `359` tracked files, including previously existing shared runtime content.
- Live code/scene/resource search contains `501` resolved Chapter I/shared path references across `97` non-document files. The old Main/enemy/Boss/projectile runtime path patterns return zero matches outside historical development/migration records and QA archives.
- Chapter I-owned runtime: gameplay root, encounters, Castle Guard, Decayed Spearman, Fallen Gate Knight, Chapter I presentation/controllers, transition, tests and chapter-specific design/narrative documents.
- Shared runtime: Cursed Shield Guard, Fallen Crossbowman, Gargoyle Sentinel, Crossbow Bolt, `EnemyCombatant`, `EnemyGroundConfig` and `GroundEnemyBase`. The approved Chapter II roster reuses the three enemy types directly, so no duplicate formal scene/script/SpriteFrames tree was created.
- Root-retained by design: Player, combat components, HUD, health/stamina, inventory/equipment/currency, loot/pickups, checkpoint/respawn, chapter services, Prologue/Catacomb and historical QA evidence. Empty legacy category directories retain only tracked `.gitkeep` markers.
- Formal `run/main_scene` remains `res://scenes/cinematics/opening_cinematic.tscn`. Debug F5 now defaults to the saved Chapter I start profile; `boss_checkpoint` provides the Boss-preflight selector. The opened Chapter I gate targets the existing Chapter II level scene.
- Verification evidence is under `res://docs/qa/chapter_01_reorganization/`: import logs, 45-test regression log, configured F5 runtime log, rendered QA log and six 1280×720 screenshots.
