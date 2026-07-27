# Chapter II Implementation Plan

Target: 第二章 · 沉寂王庭 / Chapter II · The Silent Court

## Milestone ledger

1. Stage 1 — joint scene/enemy design: complete.
2. Stage 2 — nine-room full graybox, saved profile and debug F5 route: complete.
3. Phase 1 vertical graybox refinement: complete pending approval.
4. Phase 2 five enemy roles and independent tests: pending approval.
5. Later phases — encounter runtime/population, narrative presentation, Armory safe-room/shop boundary and Hollow Duchess Boss: not started.

## Stage 2 delivered paths

- Level: `res://chapters/chapter_02_silent_court/scenes/level/silent_court.tscn`
- Saved profile: `res://chapters/chapter_02_silent_court/resources/chapter/chapter_02_start_profile.tres`
- Shared runtime: `res://scenes/runtime/chapter_gameplay_runtime.tscn`
- Nine rooms: all exact non-numbered PackedScene paths listed in `chapter_02_route_and_flow.md`.
- Test: `res://chapters/chapter_02_silent_court/tests/test_silent_court_graybox.gd`
- F5 evidence: `res://docs/qa/chapter_02_graybox/room_01_castle_gate_interior_f5.png` through `room_09_silent_ballroom_f5.png`.

## Current guarantees

- Debug F5 enters `CH2_START` with one Player, one HUD, Ravenfang, 30 coins, 100 HP and 100 Stamina; the configured `run/main_scene` remains MainBootstrap and formal startup remains Opening-first.
- All nine rooms are continuous and independently instantiable. Fifteen encounter anchors, thirty enemy spawn markers, five checkpoint anchors, ten door anchors, six narrative anchors, six debug spawns and the Boss-space anchors resolve from saved scenes.
- Stage 2 does not instantiate enemies or make doors, checkpoints, encounters, narrative or Boss behavior functional.
- Script-based test processes bypass debug routing so the formal Opening → Catacomb → Chapter I regressions remain independently testable.

## Next-stage acceptance boundary

The next stage may implement only the five approved Chapter II enemy roles and their independent resource/animation/AI tests. It must not silently populate encounters, implement the Hollow Duchess, activate doors/checkpoints, add final environment art, build a shop or begin Chapter III.
