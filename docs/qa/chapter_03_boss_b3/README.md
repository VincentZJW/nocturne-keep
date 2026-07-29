# Chapter III Boss B3 — Summon QA

Status: **PASS — B3 complete; B4 not started**

Date: 2026-07-29
Runtime authority: `res://scenes/bootstrap/main_bootstrap.tscn` → Chapter III route → saved `CH3_BOSS` room

## Delivered actors

| Actor | Concept | Runtime scene | SpriteFrames | Frames | Result |
|---|---|---|---|---:|---|
| Ossuary Penitent / 圣骨忏者 | `.../ossuary_penitent/concept_art/ossuary_penitent_concept_board.png` | `.../scenes/bosses/ossuary_penitent.tscn` | `.../ossuary_penitent/animations/ossuary_penitent_sprite_frames.tres` | 58 | PASS |
| Choir Husk / 唱诗尸壳 | `.../choir_husk/concept_art/choir_husk_concept_board.png` | `.../scenes/bosses/choir_husk.tscn` | `.../choir_husk/animations/choir_husk_sprite_frames.tres` | 50 | PASS |

Both concepts are original generated reference boards. Runtime art is separately authored by the project-owned deterministic Godot `Image` generator at native 64×64 resolution. Textures use nearest-neighbour filtering and transparent PNG sources.

## Contract results

| Acceptance item | Result | Evidence |
|---|---|---|
| Phase 1 cap = 2 | PASS | `test_edran_b3_summons.gd` |
| Maximum one Penitent and one Choir Husk | PASS | same test plus mixed-summon Main capture |
| Fixed safe spawn candidates | PASS | `ThirteenthPontiffSummonDirector._select_spawn_position()` |
| 0.92 s spawn telegraph before 0.60 s rise | PASS | `02_ossuary_penitent_telegraph_main.png` |
| Hurtbox disabled until rise completes | PASS | summon base state sequence |
| No loot, Encounter count or persistence | PASS | independent scenes and dedicated `chapter_03_boss_summon` group |
| Lifetime 14–18 s and forced dissolve | PASS | typed Boss config and actor lifecycle |
| Boss ritual interrupts at 36 accumulated Poise | PASS | deterministic two-unique-Dash test; no summon created |
| Transition/death cleanup | PASS | `05_transition_cleanup_main.png` and deterministic test |
| MainBootstrap/F5 integration | PASS | GUI capture run through `CH3_BOSS_SUMMON_TEST` |
| B2 combat regression | PASS | all five Phase 1 attacks and 198 HP B4 boundary |

## Main evidence

- `01_raise_the_absolved_windup_main.png` — saved Boss in independent SUMMON state.
- `02_ossuary_penitent_telegraph_main.png` — safe fixed-floor warning before emergence.
- `03_ossuary_penitent_active_main.png` — formal Penitent at native runtime scale.
- `04_mixed_summons_active_main.png` — one Penitent plus one Choir Husk in the saved Boss room.
- `05_transition_cleanup_main.png` — B4 boundary with all B3 summons removed.

## Exact verification

```text
Godot --headless --editor --path . --quit
  PASS: scripts/classes/resources imported with no error.

Godot --headless --path . --script .../tests/test_edran_b1_assets.gd
  EDRAN_B1_ASSETS | PASS concepts=9 animations=27

Godot --headless --path . --script .../tests/test_edran_b2_phase_01.gd
  EDRAN_B2_PHASE_01 | PASS attacks=5 health=360 poise=110 main_room=true transition=B4_pending

Godot --headless --path . --script .../tests/test_edran_b3_summons.gd
  EDRAN_B3_SUMMONS | PASS actors=2 animations=25 cap=2 penitent_cap=1 interrupt=36 cleanup=true main_spawn=true

Godot --path . --script .../scripts/tests/capture_edran_b3_main_qa.gd
  EDRAN_B3_MAIN_QA | PASS captures=5 route=MainBootstrap summons=2 cleanup=true
```

Chapter III R4 Boss flow and R5 ten-cycle route regression also pass. Their legacy summary still calls the *whole Boss entity* `partial` because B4–B6 remain deliberately absent; this does not describe B1–B3.

## Manual review

Enable Chapter III debug start and choose `CH3_BOSS_SUMMON_TEST`. In the formal sanctum, verify `Raise the Absolved / 唤起赦免者`: the 1.15-second stationary ritual, the floor warning, rise delay, slow melee Penitent, slow non-homing Choir projectile, two-actor cap, readable separation from Edran and forced dissolve at the 198 HP phase boundary.

Known boundary: B3 intentionally stops at `TRANSITION_PENDING`. Phase transformation, Phase 2, final death/reward and Chapter IV hand-off belong to B4–B6.
