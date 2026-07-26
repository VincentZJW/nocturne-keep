# Chapter Folder Reorganization Plan

Date: 2026-07-26
Stage: 0 — audit and migration plan only
Branch: `chore/chapter-folder-reorganization`
Audited baseline: `c934ed0 fix: tune Fallen Gate Knight attack readability`

## Stage 0 boundary

This document records the current project and the proposed path migration. Stage 0 does not move, copy, delete, rename, or reserialize gameplay files; it does not change `run/main_scene`, Autoloads, scenes, scripts, resources, tuning, or runtime flow.

The worktree was not clean when the audit began. Twenty user-owned paths were already modified or untracked, including `scenes/main/main.tscn`, Player/Enemy/Boss tuning resources, seven Ravenfang QA captures, and two generated `.uid` files. They remain unstaged and must not be discarded. Before Stage 1, these changes need an explicit recoverable snapshot or a user-approved decision to include them; otherwise a migration commit cannot be isolated safely.

## Current project tree

```text
res://
├── project.godot
├── scenes/
│   ├── cinematics/opening_cinematic.tscn
│   ├── levels/{veilbound_catacomb,first_level_encounters}.tscn
│   ├── main/main.tscn
│   ├── bosses/{fallen_gate_knight,fallen_gate_knight_reward}.tscn
│   ├── enemies/                         # five reusable normal-enemy scenes
│   ├── items/pickups/                   # shared pickups
│   ├── npcs/candle_warden.tscn
│   ├── player/player.tscn
│   ├── projectiles/crossbow_bolt.tscn
│   ├── transitions/ravenmourn_threshold.tscn
│   ├── ui/tutorial_prompt_ui.tscn
│   └── tools/                           # six independent test/preview scenes
├── scripts/
│   ├── cinematics/                      # prologue
│   ├── levels/, narrative/, npcs/       # mostly prologue
│   ├── bosses/                          # Chapter I Boss
│   ├── world/, tutorial/                # mixed prologue and Chapter I
│   ├── enemies/                         # reusable normal enemies
│   ├── player/, combat/, items/         # shared runtime
│   ├── systems/, encounters/            # cross-scene/shared runtime
│   ├── ui/                              # mixed shared and chapter-specific UI
│   ├── projectiles/                     # shared runtime
│   └── tools/                           # development and QA tooling
├── resources/
│   ├── narrative/, dialogue/            # prologue
│   ├── bosses/                          # Chapter I Boss
│   ├── enemies/                         # reusable normal enemies
│   ├── player/                          # shared Player
│   └── items/                           # shared loot and weapons
├── assets/
│   ├── sprites/bosses/fallen_gate_knight/  # Chapter I Boss, 100 PNG + 100 import sidecars
│   ├── sprites/enemies/                    # reusable enemies, 423 files
│   ├── sprites/player/                     # shared Player, 312 files
│   ├── sprites/projectiles/                # shared projectile
│   └── ui/items/                           # shared items
├── tests/                                 # 43 SceneTree tests
└── docs/                                  # design, narrative, QA and log
```

Inventory at audit time: 26 `.tscn`, 177 `.gd`, 34 `.tres`, 568 `.png`, 177 `.gd.uid`, and 451 tracked source `.import` sidecars. `.godot/` is ignored and is not a migration source.

## Runtime source of truth

### Configured flow

```text
project.godot
  run/main_scene = res://scenes/cinematics/opening_cinematic.tscn
    → res://scenes/levels/veilbound_catacomb.tscn
      → res://scenes/main/main.tscn
        → res://scenes/transitions/ravenmourn_threshold.tscn
```

- Prologue root: `OpeningCinematic` in `scenes/cinematics/opening_cinematic.tscn`.
- Revival root: `VeilboundCatacomb` in `scenes/levels/veilbound_catacomb.tscn`.
- Chapter I gameplay root: `Main` in `scenes/main/main.tscn`.
- Chapter I encounters: `Main/World/Encounters`, instanced from `scenes/levels/first_level_encounters.tscn`.
- Chapter I Boss: `Main/World/CastleEntranceArea/FallenGateKnight`, instanced from `scenes/bosses/fallen_gate_knight.tscn`.
- Chapter I exit: `Main/World/CastleEntranceArea/CastleEntranceTrigger`, coordinated by `Main/BossRoomController` and `Main/CastleEntranceTransition`.
- Player: `Main/World/Player`, instanced from shared `scenes/player/player.tscn`.
- HUD: `Main/HUD`; Debug HUD: `Main/Interface/DebugHudRoot`.

### Autoloads

| Name | Current path | Stage 1 decision |
| --- | --- | --- |
| `ChapterSession` | `res://scripts/systems/chapter_session.gd` | Keep path; update its hard-coded Catacomb replay target only. A broader multi-chapter state redesign belongs to a later approved stage. |
| `CurrencyManager` | `res://scripts/systems/currency_manager.gd` | Do not move. |
| `WeaponInventory` | `res://scripts/items/weapon_inventory.gd` | Do not move. |
| `EquipmentManager` | `res://scripts/items/equipment_manager.gd` | Do not move. |

## Ownership decisions

### Prologue

- Opening scene, timeline Resource, controller and native-2D art.
- Veilbound Catacomb scene/controller/art, stone door presentation, dialogue tracks and dialogue UI.
- Revival presentation, Candle Warden scene/script and prologue narrative documents.
- Focused Catacomb flow/transition tests.

### Chapter I — Ravenmourn Outskirts

- Current `Main`, Chapter I environment/collision/checkpoints/tutorial composition, 18-group encounter placement scene and Chapter I transition placeholder.
- Fallen Gate Knight scene, reward composition, scripts, resources, SpriteFrames and all Boss source PNGs.
- Chapter I environment, tutorial, Boss-room, gate/moat and narrative-presentation scripts.
- Chapter I-specific tests, captures/tools and design/narrative documents identified in the manifest.

### Shared

- Player scene/scripts/resources/assets; combat components; Health/Stamina/HUD; inventory, equipment, currency, weapons, loot, pickups and common projectiles.
- All five normal enemies. Chapter II is explicitly expected to reuse Shield Guard, Spearman, Crossbowman and Gargoyle; Castle Guard shares the same base/config/component stack and is also treated as reusable. Their scene/script/resource/asset bundles move together to `shared/` so Chapter II never depends on a Chapter I directory.
- Generic `EncounterGroup`, Player respawn/checkpoint composition, enemy combat bases and test rooms.

### System / do not move in Stage 1

- `project.godot` changes only where a moved path requires it; no input, rendering or gameplay setting changes.
- Existing `scripts/systems/`, `scripts/player/`, `scripts/combat/`, `scripts/items/`, `scripts/ui/`, `resources/player/`, `resources/items/`, `scenes/player/`, `scenes/items/`, and `docs/qa/` remain in their current neutral paths in Stage 1. Moving them would increase blast radius without establishing chapter ownership.
- Development tool scenes remain under `scenes/tools/`; their hard-coded paths will be updated. Chapter-specific generator/capture scripts may move only as listed in the manifest.
- QA evidence is an immutable historical archive for this migration. Existing duplicate/reference/deprecated PNGs are not cleanup targets.

## Proposed target tree after Stage 1

```text
res://
├── chapters/
│   ├── prologue/
│   │   ├── scenes/{cinematics,level,npcs}/
│   │   ├── scripts/{cinematics,level,narrative,npcs,ui,world}/
│   │   ├── resources/{dialogue,narrative}/
│   │   ├── tests/{level,integration}/
│   │   └── docs/
│   └── chapter_01_ravenmourn_outskirts/
│       ├── scenes/{level,encounters,transitions,boss}/
│       ├── scripts/{level,transitions,boss,ui,world,tools}/
│       ├── resources/boss/
│       ├── assets/boss/fallen_gate_knight/
│       ├── tests/{combat,items,level,tools}/
│       └── docs/{design,narrative}/
├── shared/
│   ├── scenes/enemies/
│   ├── scripts/{enemies,encounters}/
│   ├── resources/enemies/
│   └── assets/enemies/
├── scenes/                               # retained shared/tool paths
├── scripts/                              # retained shared/system/tool paths
├── resources/                            # retained Player/item paths
├── assets/                               # retained Player/item/projectile paths
├── tests/                                # retained shared tests
└── docs/                                 # project-wide and QA docs
```

Empty `chapter_03`–`chapter_06` folders will not be created in Stage 1; Git does not track empty directories and those chapters have no approved content yet.

## Reference audit

The current repository contains 911 textual `res://` references across runtime/test files. Mechanisms found:

| Mechanism | Count / finding | Migration handling |
| --- | ---: | --- |
| GDScript `preload("res://…")` | 141 | Rewrite every moved target before import. |
| GDScript `load("res://…")` | 12 | Rewrite every moved target. |
| `ResourceLoader` calls | 1 | Inspect and update target if moved. |
| `change_scene_to_file()` calls | 5 | Update Opening, Catacomb, replay and castle-exit targets. |
| `.tscn` / `.tres` `ext_resource` | 587 | Rewrite paths without reauthoring subresources. |
| `.tscn` / `.tres` `sub_resource` | 88 | Keep IDs and contents unchanged. |
| PackedScene external references | 25 | Update path; verify instantiation. |
| Files containing hard-coded `res://` strings | 86 | Search globally after migration. |
| Runtime absolute `/Users/` or `file://` paths | 0 | No runtime correction required. |

Critical string paths include `project.godot`, Opening target, Catacomb target, `ChapterSession.replay_revival_scene()`, tutorial opening replay, castle threshold target, QA capture preloads and many tests. The detailed path-to-reference mapping is in `chapter_01_path_manifest.md`.

## Godot serialization and metadata findings

- No inherited-scene root was found. Current scene composition uses PackedScene instances and local instance overrides instead.
- Only 2 of 26 scenes have a UID in the `.tscn` header; paths therefore remain authoritative for most scenes. A move must be followed by import and explicit load checks, not a UID-only assumption.
- Every tracked `.gd` currently has a `.gd.uid` sidecar. Each moved script and its sidecar must move together in the same `git mv` operation.
- Source `.import` sidecars exist beside many PNGs. They are source import settings and move with their PNG when the corresponding asset moves; `.godot/imported/` must never be moved or committed.
- Main has important PackedScene instance overrides. The Boss instance overrides `position`, `bridge_bounds_enabled`, `bridge_min_x` and `bridge_max_x`; encounter instances carry authored positions/activation data. Stage 1 must preserve these exact serialized overrides.
- Duplicate SHA-1 groups exist in Player reference/deprecated frames, Shield Guard shielded/unshielded frames, Crossbow/Spearman holds, Gargoyle deprecated frames and Boss repeated poses. They are intentional animation/reference data until a separate visual-asset audit proves otherwise; Stage 1 does not delete or deduplicate them.

## Risk register

| Risk | Severity | Evidence | Stage 1 mitigation |
| --- | --- | --- | --- |
| Dirty user work overlaps migration targets | Critical | 20 modified/untracked paths, including Main and enemy/Boss resources | Obtain a recoverable user-approved snapshot first; never reset, clean or silently include unrelated changes. |
| Broken launch chain | Critical | Four string-addressed scenes form F5 flow | Move in leaf-to-root order, update all four paths in one controlled batch, then run real transition tests. |
| Lost Inspector overrides | Critical | Main Boss/encounter instances contain local values | Use textual `git mv` plus path-only edits; diff overrides before/after. |
| Missing texture/import metadata | High | 568 PNGs and 451 source `.import` files | Move asset directory atomically with tracked sidecars; fresh Godot import; validate SpriteFrames. |
| Script class/UID churn | High | 177 `.gd.uid` sidecars | Move each `.gd` and `.gd.uid` together; do not regenerate manually. |
| Tests and tools silently load old paths | High | 141 preloads; 86 hard-coded-path files | Update tests/tools in the same stage and require zero old runtime paths outside migration docs. |
| Historical docs retain obsolete paths | Medium | README and many design/log entries name old paths | Update current docs and path examples; preserve historical meaning while replacing address literals. |
| Shared enemy dependency points back into Chapter I | High | Chapter I encounter scene uses all five normal enemies | Move the complete enemy bundles to `shared/` before moving the Chapter I encounter scene. |
| Stale architecture claims | Medium | `technical_architecture.md` is M0-era and Autoload section is obsolete | Update only path/ownership facts during Stage 1; broader architecture rewrite remains separate. |
| Accidental cleanup of duplicate art | Medium | Numerous byte-identical production/reference frames | No deletion or deduplication in this migration. |

## Stage 1 execution order

1. Re-read status and compare against this baseline. Resolve the dirty-worktree entry gate without destructive commands.
2. Create target directories and record a machine-readable old/new mapping from the manifest.
3. Move shared enemy bundles first: scenes, scripts plus `.gd.uid`, resources, assets plus `.import`, and generic encounter code. Update their internal dependencies and shared test/tool references.
4. Move prologue leaf resources/scripts/scenes next. Update Opening/Catacomb `ext_resource`, exported scene strings, `ChapterSession` replay and tutorial replay.
5. Move Chapter I Boss assets/resources/scripts/scenes, then Chapter I environment/tutorial/Boss-room scripts and tests.
6. Move the Chapter I encounter scene and finally the gameplay root to `chapters/chapter_01_ravenmourn_outskirts/scenes/level/ravenmourn_outskirts.tscn`.
7. Move the transition placeholder and update `CastleEntranceTransition.target_scene_path`.
8. Update `project.godot` last so F5 points to the migrated Opening only after the entire chain resolves.
9. Update README/design/narrative/test/tool paths. Search every tracked runtime/doc file for old paths; outside migration documentation, expected old-path count is zero.
10. Run exact Godot 4.7.1 import, load each migrated major scene, run 43/43 tests, configured F5 graphical smoke, direct Chapter I graphical smoke and real transition tests.
11. Compare node trees, subresources, instance overrides, animation names/frame counts, collision shapes/masks, Encounter counts and Boss configuration against the Stage 0 manifest.
12. Commit the migration as one isolated, reviewable commit only after all gates pass. Remove only directories proven empty; never delete source content to make the tree look tidy.

## Baseline verification

Commands were run against the unmodified Stage 0 runtime:

- Exact Godot 4.7.1 headless editor import: exit 0; no parser/resource error.
- Focused flow tests: Chapter I flow, Veilbound Catacomb flow, real scene transitions and first Boss tests all passed.
- Full ordered suite: `43/43 PASS`, `0` failures.
- Configured graphical startup (`--quit-after 300`): exit 0 on GL Compatibility / Apple M4, no red diagnostics.
- Direct graphical Chapter I Main (`--quit-after 600 res://scenes/main/main.tscn`): exit 0, no red diagnostics.

The first attempt at the full-suite shell harness stopped before executing the suite because `status` is a read-only zsh variable. The corrected harness used `test_exit`; all 43 project tests then passed. This was a harness issue, not a Godot project error.

## Stage 1 acceptance gates

- F5 reaches Opening → Catacomb → Chapter I → threshold with no missing resource, invalid UID, parser error or null PackedScene.
- Prologue, Chapter I, Boss and encounter scenes load independently.
- Five shared enemy types instantiate, animate, fight, die and drop loot in Chapter I.
- Player, HUD, currency, equipment, Ravenfang reward, checkpoints, Boss defeat and castle gate behavior are unchanged.
- NodePaths named in this document still resolve after re-open.
- No old runtime path remains outside migration documentation.
- No user-owned pre-existing change is discarded or hidden.
