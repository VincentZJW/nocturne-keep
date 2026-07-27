# Chapter II Implementation Plan

Target: 第二章 · 沉寂王庭 / Chapter II · The Silent Court

## Required order

1. **Stage 2A — Foundation (complete):** registry, typed profile contract and centralized Debug config.
2. **Stage 2B–2D — Routing/legal start/F5 acceptance (complete):** guarded router, saved Chapter II profile, one shared runtime and real graphical F5 evidence.
3. **Chapter II Stage 2 — nine-room graybox (complete):** continuous 32,128 px route, all named future-system anchors and six debug selectors; no enemies or functional doors/checkpoints.
4. **Phase 1 — vertical graybox refinement (complete pending approval):** visible collision-backed platforms, broad stairs, two/three-level room silhouettes, reachable routes, protected spawns and flat Boss lane; no enemies or functional encounters.
5. **Next approved phase:** build the five Chapter II enemy roles and their independent test scenes. Do not begin encounter population or the Hollow Duchess Boss in that phase.

## Chapter II registered target

- Scene: `res://chapters/chapter_02_silent_court/scenes/level/silent_court.tscn`
- Default spawn/checkpoint: `CH2_START` / `Chapter02CP01`
- Additional legal starts: `CH2_BANQUET`, `CH2_GALLERY`, `CH2_CHAPEL`, `CH2_ARMORY`, `CH2_BOSS`
- Prerequisites: Prologue and Chapter I complete
- Required equipment metadata: Veilbound and Ravenfang daggers; Ravenfang equipped
- Debug defaults: 30 currency, full health, intro not skipped

The target scene and saved profile exist and are `debug_ready=true`. `MainBootstrap` remains the configured F5 scene; formal startup selects Opening, while explicitly enabled Debug Chapter Start enters this same Chapter II composed scene.

## Acceptance gates

- Stage 2B: no route loops, invalid targets fall back, release ignores debug config.
- Stage 2C: all scene/resource paths exist, spawn ID resolves, state application is atomic and test-isolated.
- Stage 2D: F5 starts Chapter II only in the intended debug configuration; formal Opening remains recoverable; restart behavior is deterministic; screenshots and logs are kept under `docs/qa/`.
- Phase 1: all nine rooms keep continuous collision, visible geometry matches collision data, every tier rise is at most 120 px, the six legal debug starts remain safe, Ballroom is flat, and zero enemy instances are introduced.
