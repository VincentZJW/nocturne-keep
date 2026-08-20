# EDRAN PHASE 2 FORCED GRAVITY ROOT-CAUSE REPORT

Status: **PASS**

Date: 2026-08-20

Main authority: `res://scenes/bootstrap/main_bootstrap.tscn`

Debug route: `CHAPTER_03_CHAPEL_OF_THIRTEEN_ECHOES` / `CH3_BOSS`

## Reproduced Original Failure

- Player HP: 60
- Phase 2 reached: yes
- Dialogue completed: yes
- Gravity animation played: no
- Final Seal triggered: no
- HP after: 60
- Failure reproduced: yes, from the pre-fix formal runtime trace and saved
  transition wiring.

## Root Cause

Edran owned the structural Phase 2 transition while the Sanctum presentation
owned the Phase 2 dialogue. Both ran concurrently, but the room never forwarded
`phase_transition_environment_finished` to the Boss. Edran therefore restored
combat from its own timer and enabled the normal Phase 2 selector without
waiting for dialogue completion. `WEIGHT_OF_ABSOLUTION` remained an optional
weighted candidate behind its first-cast delay instead of being the mandatory
opening spell.

## Fix

- Dialogue end callback: the formal Boss room now forwards the Sanctum's saved
  completion signal to Edran.
- Forced gravity state: Edran directly awaits one forced opening cast after the
  dialogue handshake; it does not use attack weighting, distance or cooldown.
- AI gate: normal Phase 2 selection remains disabled through transition,
  dialogue, cast, Final Seal and recovery.
- Animation: the formal `mire_spell_windup`, `mire_spell_target_lock` and
  `mire_spell_recovery` animations run in order.
- Final Seal event: the saved gravity judgment VFX reaches its final-seal state
  before health resolution.
- Health API: settlement mutates the actual Player `HealthComponent` once.
- Opening completion flag: it becomes true only after recovery; the ordinary
  21-second cooldown also starts at that point.

## 60 HP Runtime Test

All rows are fresh MainBootstrap routes and include dialogue, formal cast VFX,
Final Seal, one HealthComponent mutation, recovery and normal-AI release.

| Run | Dialogue End | Cast Animation | Final Seal | HP Before | HP After | PASS |
|---:|---|---|---|---:|---:|---|
| 1 | PASS | PASS | PASS | 60 | 50 | PASS |
| 2 | PASS | PASS | PASS | 60 | 50 | PASS |
| 3 | PASS | PASS | PASS | 60 | 50 | PASS |

## Formal Main Branch Test

These runs prove the three requested runtime branches through the same forced
Phase 2 opening chain, rather than by calling a damage helper in isolation.

| Branch | Before | Expected | Actual | Health mutations | Result |
|---|---:|---:|---:|---:|---|
| Above 50 | 60 | 50 | 50 | 1 | PASS (3/3) |
| At or below 50, above floor | 50 | 30 | 30 | 1 | PASS |
| At floor | 20 | 20 | 20 | 0 | PASS |

## Boundary Test

Focused deterministic resolution additionally covers values around both
boundaries. Values already below 20 remain unchanged; this spell never lowers
them further and does not heal them back to 20.

| Before | Expected | Actual |
|---:|---:|---:|
| 100 | 50 | 50 |
| 51 | 50 | 50 |
| 50 | 30 | 30 |
| 40 | 20 | 20 |
| 35 | 20 | 20 |
| 20 | 20 | 20 |
| 15 | 15 | 15 |

## Final Phase 2 Flow

| Stage | Result |
|---|---|
| Phase 2 Transition | PASS |
| Dialogue | PASS |
| Forced Weight of Absolution | PASS |
| Animation | PASS |
| HP Resolution | PASS |
| Recovery | PASS |
| Normal Phase 2 AI | PASS |

The ordered runtime trace contains:

`PHASE_2_THRESHOLD_REACHED → PHASE_2_TRANSITION_BEGIN →`
`PHASE_2_DIALOGUE_BEGIN → PHASE_2_DIALOGUE_END →`
`GRAVITY_OPENING_REQUESTED → GRAVITY_STATE_ENTER →`
`GRAVITY_CAST_ANIMATION_BEGIN → GRAVITY_FINAL_SEAL →`
`GRAVITY_HP_RESOLVE → GRAVITY_RECOVERY_BEGIN → GRAVITY_COMPLETE →`
`PHASE_2_NORMAL_AI_BEGIN`.

## Commands and Results

```text
/Users/vincentz/Downloads/Godot.app/Contents/MacOS/Godot --headless --path . --editor --quit-after 5
PASS (exit 0; no script/resource errors; benign editor scan-abort warning on timed exit)

/Users/vincentz/Downloads/Godot.app/Contents/MacOS/Godot --headless --path . --script res://chapters/chapter_03_chapel_of_thirteen_echoes/tests/test_edran_phase_02_forced_opening_main.gd
PASS main_runs=5 repeat_60=3 branches=60to50,50to30,20to20 flow=complete

/Users/vincentz/Downloads/Godot.app/Contents/MacOS/Godot --headless --path . --script res://chapters/chapter_03_chapel_of_thirteen_echoes/tests/test_edran_judgment_magic.gd
PASS assertions=93 history_delay=1.0 bolts=3 hp_cases=17

/Users/vincentz/Downloads/Godot.app/Contents/MacOS/Godot --headless --path . --script res://chapters/chapter_03_chapel_of_thirteen_echoes/tests/test_edran_b4_b7_full_boss.gd
PASS transition=true phase2_attacks=6 death=true reward_interface=true regressions=20

/Users/vincentz/Downloads/Godot.app/Contents/MacOS/Godot --headless --path . --script res://chapters/chapter_03_chapel_of_thirteen_echoes/tests/test_edran_elemental_magic.gd
PASS assertions=986 burn_hits=30 freeze_hits=30 mire_casts=30 cadence_battles=20
```

Existing Chapter III MU2/MU3 Boss-music regressions also exit 0. The graphical
MainBootstrap capture exits 0 with five distinct 1280×720 frames and no red
Output/Debugger error.

## Visual Evidence

- `01_phase_02_dialogue_hp_60.png`: formal Phase 2 dialogue at HP 60.
- `02_forced_gravity_windup.png`: dialogue cleared and forced cast begun.
- `03_gravity_final_seal_hp_60.png`: Final Seal before settlement.
- `04_gravity_resolved_hp_50.png`: recovery with HP exactly 50.
- `05_phase_02_normal_ai_after_gravity.png`: normal Phase 2 AI only after cast
  completion.

## Manual Acceptance

Start Main with Chapter III / `CH3_BOSS`, enter the arena, lower Edran to the
Phase 2 threshold and let the dialogue finish. Confirm the forced gravity spell
always runs before ordinary Phase 2 attacks. Repeat with Player HP above 50,
between 21 and 50, and at 20 to assess timing, readability and feel.
