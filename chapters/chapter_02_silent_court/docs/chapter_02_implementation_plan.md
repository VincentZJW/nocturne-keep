# Chapter II Implementation Plan

Target: 第二章 · 沉寂王庭 / Chapter II · The Silent Court

## Milestone ledger

1. Stage 1 — joint scene/enemy design: complete.
2. Stage 2 — nine-room full graybox, saved profile and debug F5 route: complete.
3. Phase 1 vertical graybox refinement: complete pending approval.
4. Phase 2 five enemy roles and independent tests: complete; manual feel acceptance pending.
5. Hollow Duchess Boss — complete first playable two-phase implementation; manual combat-feel acceptance pending.
6. Later phases — formal encounter population, narrative presentation and Armory safe-room/shop boundary: not started.

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

## Phase 2 delivered paths

- Enemy scenes: `res://chapters/chapter_02_silent_court/scenes/enemies/`.
- Original concept/source/animation art: `res://chapters/chapter_02_silent_court/assets/enemies/`.
- Independent room: `res://chapters/chapter_02_silent_court/scenes/tests/phase_2_enemy_prototype_room.tscn`.
- Focused tests: `test_phase_2_enemy_prototypes.gd`, `test_phase_2_enemy_damage.gd`.
- Main acceptance instances: `SilentCourt/Phase2EnemyPrototypeShowcase`, exactly one of each new role.

## Hollow Duchess delivered paths

- Boss scene/config/state: `res://chapters/chapter_02_silent_court/scenes/boss/hollow_duchess.tscn` and `resources/boss/hollow_duchess_data.tres`.
- Pixel art: `res://chapters/chapter_02_silent_court/assets/boss/hollow_duchess/` (101 runtime frames plus concept/effects).
- Main encounter: `SilentCourt/BossArea/HollowDuchess` with `ChapterSystems/HollowDuchessRoomController`, door/camera/CP05 reset and signal-driven Boss HUD.
- Independent room: `res://chapters/chapter_02_silent_court/scenes/tests/hollow_duchess_test_room.tscn`.
- Specification: `chapter_02_hollow_duchess_boss_spec.md`; Main evidence: `res://docs/qa/chapter_02_hollow_duchess/`.
- Verification: seven attacks ×10 deterministic cycles, five 222–226-second live combat simulations, Bootstrap/CH2_BOSS Main composition and ten rendered checkpoints.

## Next-stage acceptance boundary

The next stage may begin only after approval. It may replace the five clearly named prototype showcase instances with authored E01–E15 encounter runtime/population or separately implement approved narrative/shop work. It must not alter the accepted Duchess cadence without a new balance task, add final environment art or begin Chapter III.
