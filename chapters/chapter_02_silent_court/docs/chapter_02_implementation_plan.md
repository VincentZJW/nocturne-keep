# Chapter II Implementation Plan

Target: 第二章 · 沉寂王庭 / Chapter II · The Silent Court

## Milestone ledger

1. Stage 1 — joint scene/enemy design: complete.
2. Stage 2 — nine-room full graybox, saved profile and debug F5 route: complete.
3. Next approved stage — refine collision, implement four door categories and activate five checkpoints: pending approval.
4. Later stages — encounter runtime, five enemy roles, narrative presentation, Armory safe-room/shop boundary and Hollow Duchess Boss: not started.

## Stage 2 delivered paths

- Level: `res://chapters/chapter_02_silent_court/scenes/level/silent_court.tscn`
- Saved profile: `res://chapters/chapter_02_silent_court/resources/chapter/chapter_02_start_profile.tres`
- Shared runtime: `res://scenes/runtime/chapter_gameplay_runtime.tscn`
- Nine rooms: all exact non-numbered PackedScene paths listed in `chapter_02_route_and_flow.md`.
- Test: `res://chapters/chapter_02_silent_court/tests/test_silent_court_graybox.gd`
- F5 evidence: `res://docs/qa/chapter_02_graybox/room_01_castle_gate_interior_f5.png` through `room_09_silent_ballroom_f5.png`.

## Current guarantees

- Debug F5 enters `CH2_START` with one Player, one HUD, Ravenfang, 30 coins, 100 HP and 100 Stamina; the configured `run/main_scene` remains Opening.
- All nine rooms are continuous and independently instantiable. Fifteen encounter anchors, thirty enemy spawn markers, five checkpoint anchors, ten door anchors, six narrative anchors, six debug spawns and the Boss-space anchors resolve from saved scenes.
- Stage 2 does not instantiate enemies or make doors, checkpoints, encounters, narrative or Boss behavior functional.
- Script-based test processes bypass debug routing so the formal Opening → Catacomb → Chapter I regressions remain independently testable.

## Next-stage acceptance boundary

The next stage may refine solid/one-way collision, implement normal/encounter/shortcut/Boss doors and connect CP01–CP05 to the existing respawn service. It must not silently begin enemy AI, final environment art, shop, Boss or Chapter III work.
