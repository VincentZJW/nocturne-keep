# Chapter II Implementation Plan

Target: 第二章 · 沉寂王庭 / Chapter II · The Silent Court

## Required order

1. **Stage 2A — Foundation (complete):** register chapter metadata, define `ChapterStartProfile`, and centralize `DebugRunConfig`. F5 still starts the Opening.
2. **Stage 2B — Routing:** add one Bootstrap/Main routing authority. In debug builds it validates the config; in release or on failure it follows the formal Opening route.
3. **Stage 2C — Legal Chapter II start:** create the real Chapter II `PackedScene`, a saved start-profile resource, CP01 spawn/checkpoint, prerequisite Chapter I state, Ravenfang equipment, 30 test currency, full health and clean Chapter II flags.
4. **Stage 2D — F5 acceptance:** enable validated direct entry, run the complete debug start, preserve formal/release flow, and capture QA evidence.
5. **Chapter II gameplay milestones:** only after 2D approval, implement the Silent Court rooms, encounters, narrative, checkpoints and Boss as separately approved work.

## Chapter II registered target

- Scene: `res://chapters/chapter_02_silent_court/scenes/level/silent_court.tscn`
- Default spawn/checkpoint: `chapter_02_cp01`
- Additional planned starts: banquet/CP02, chapel, armory/CP04, boss/CP05
- Prerequisites: Prologue and Chapter I complete
- Required equipment metadata: Veilbound and Ravenfang daggers; Ravenfang equipped
- Debug defaults: 30 currency, full health, intro not skipped

The target path and metadata are registered in Stage 2A, but the scene does not yet exist and `debug_ready` is therefore false. No code may pretend the chapter is playable before Stage 2C.

## Acceptance gates

- Stage 2B: no route loops, invalid targets fall back, release ignores debug config.
- Stage 2C: all scene/resource paths exist, spawn ID resolves, state application is atomic and test-isolated.
- Stage 2D: F5 starts Chapter II only in the intended debug configuration; formal Opening remains recoverable; restart behavior is deterministic; screenshots and logs are kept under `docs/qa/`.
