# Chapter System Specification

Status: Main/Bootstrap routing implemented and verified

## Purpose

The chapter system separates the permanent project entry from a developer-selected test target. `project.godot` starts `res://scenes/bootstrap/main_bootstrap.tscn`; Bootstrap selects exactly one formal or Debug route. `ChapterRegistry` remains a typed metadata catalogue and never changes scenes. `ChapterStartProfile` is the validated route/state contract.

## Registered IDs

| ID | Display name | Main scene path | Debug ready |
| --- | --- | --- | --- |
| `CHAPTER_PROLOGUE` | 序章 · 复苏 / Prologue · Awakening | `res://scenes/cinematics/opening_cinematic.tscn` | yes |
| `CHAPTER_01_RAVENMOURN_OUTSKIRTS` | 第一章 · 鸦泣城郊 / Chapter I · Ravenmourn Outskirts | `res://chapters/chapter_01_ravenmourn_outskirts/scenes/level/ravenmourn_outskirts.tscn` | yes |
| `CHAPTER_02_SILENT_COURT` | 第二章 · 沉寂王庭 / Chapter II · The Silent Court | `res://chapters/chapter_02_silent_court/scenes/level/silent_court.tscn` | yes |
| `CHAPTER_03_CHAPEL_OF_THIRTEEN_ECHOES` | 第三章 · 十三回声礼拜堂 / Chapter III · Chapel of Thirteen Echoes | planned chapter path | no |
| `CHAPTER_04_DROWNED_UNDERKEEP` | 第四章 · 沉没下堡 / Chapter IV · The Drowned Underkeep | planned chapter path | no |
| `CHAPTER_05_NIGHT_REPEATED` | 第五章 · 重演之夜 / Chapter V · Night Repeated | planned chapter path | no |
| `CHAPTER_06_HOLLOW_BELL_ABYSS` | 第六章 · 空钟深渊 / Chapter VI · Hollow Bell Abyss | planned chapter path | no |

The prologue plus Chapters I–VI are seven registry entries. The six numbered chapter IDs requested for long-term development are all present.

## Profile contract

Each `ChapterStartProfile` records an ID and bilingual name, scene path, default spawn/checkpoint, available spawn IDs, completed prerequisite chapters, required/equipped weapons, currency and health initialization, boss/shortcut/story flags, and `debug_ready`. Planned paths are stored as strings, so registering an unfinished chapter never imports or loads a missing scene.

`is_valid_registry_entry()` checks metadata without requiring the scene. `is_valid_debug_target()` additionally requires `debug_ready` and an existing `PackedScene`. This distinction prevents unfinished Chapter II–VI paths from generating startup errors.

## Ownership

- `ChapterRegistry`: immutable catalogue access; returned profiles are deep duplicates.
- `ChapterStartProfile`: typed data only; no scene changes and no global mutation.
- `DebugRunConfig`: centralized development preferences only; disabled by default and release-gated.
- `ChapterStartRouter`: side-effect-free resolver for a valid Debug profile; it has no `_ready()` redirect.
- `MainBootstrap`: sole startup authority, session-mode initializer and validated PackedScene loader.
- Existing `ChapterSession`: remains the current Chapter I runtime flag owner until an approved migration.

## Runtime routes

Formal new game (`debug_chapter_start_enabled = false`):

```text
MainBootstrap
→ OpeningCinematic
→ VeilboundCatacomb
→ RavenmournOutskirts (Chapter I)
→ SilentCourt (Chapter II gate)
```

Debug chapter start (`OS.is_debug_build()` and the flag is true):

```text
MainBootstrap
→ validated ChapterStartProfile.main_scene_path
```

Bootstrap resets runtime-only story state before a formal new game. Opening marks `opening_completed` only from its guarded natural/skip exit. Debug sessions are marked `ChapterSession.is_debug_run`; a later formal Bootstrap start clears that marker and all disposable Prologue state. Chapter scene profile application also checks the same debug/release gate, so selecting a chapter ID alone cannot mutate the formal route.

No `SceneTransitionManager` exists in the current project. Bootstrap validates the target with `ResourceLoader`, then uses the existing Godot `SceneTree.change_scene_to_packed` mechanism. Opening and Catacomb continue to own their later local `change_scene_to_file` transitions.
