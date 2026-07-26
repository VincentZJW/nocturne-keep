# Chapter System Specification

Status: Stage 2A foundation complete; routing and state application pending

## Purpose

The chapter system separates the permanent project entry from a developer-selected test target. `project.godot` continues to start the authored Opening. `ChapterRegistry` is a typed metadata catalogue; it does not load or change scenes. `ChapterStartProfile` is the reusable state contract that later stages will validate and apply.

## Registered IDs

| ID | Display name | Main scene path | Debug ready |
| --- | --- | --- | --- |
| `CHAPTER_PROLOGUE` | 序章 · 复苏 / Prologue · Awakening | `res://scenes/cinematics/opening_cinematic.tscn` | yes |
| `CHAPTER_01_RAVENMOURN_OUTSKIRTS` | 第一章 · 鸦泣城郊 / Chapter I · Ravenmourn Outskirts | `res://scenes/main/main.tscn` | yes |
| `CHAPTER_02_SILENT_COURT` | 第二章 · 沉寂王庭 / Chapter II · The Silent Court | `res://chapters/chapter_02_silent_court/scenes/level/silent_court.tscn` | no, scene/profile pending |
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
- `DebugRunConfig`: centralized development preferences only.
- Future Bootstrap/Main router: validates and consumes a selected profile.
- Existing `ChapterSession`: remains the current Chapter I runtime flag owner until an approved migration.

Stage 2A does not route F5, apply profiles, create Chapter II content, or alter the Opening → Veilbound Catacomb → Main flow.
