# EDRAN – THE WEIGHT OF ABSOLUTION IMPLEMENTATION REPORT

Status: **PASS — logic, formal selector, saved Main route; manual combat feel pending**

## Initial State

- Current State: `IMPLEMENTED BUT OUTDATED` (STATE C).
- Found Existing Logic: Phase-2-only attack/state chain, 8-second opening
  grace, 21/9-second cooldowns, Poise interruption, Final-Seal cast armour and
  `HealthComponent` settlement.
- Found Existing VFX: tracked thirteenth-bell silhouette, thirteen concentric
  seals and downward compression lines.
- Found Existing Animation: formal Edran staff-cast windup, target lock and
  recovery families.
- Found Attack Selector Entry: yes, in Edran's normal Phase-2 candidate pool.
- Found Runtime Usage: yes, but the saved rule was outdated: every value at or
  below 50 took 20 damage and could kill the Player.

## Changes

- Modified Existing Files: Edran's formal Boss/config/gravity scripts, focused
  test, spell specification, this report and `docs/development_log.md`.
- Created Necessary Formal Files: none; the existing single formal spell was
  completed in place.
- Removed/Replaced Old Logic: removed the `HP <= 50 -> take_damage(20)` branch,
  lethal boundary cases and the old 0.90-second Final Seal timing.

## Gameplay

- Phase: Phase 2 only.
- Attack ID: `WEIGHT_OF_ABSOLUTION` / `weight_of_absolution`.
- First Cast Delay: 8.00 seconds after Phase 2 begins.
- Cast Time: 1.70 seconds.
- Final Seal: 1.40 seconds; movement cannot escape settlement after this point.
- Full Cooldown: 21.00 seconds.
- Partial Cooldown: 9.00 seconds after a pre-seal Poise break.
- Recovery: 1.35 seconds.
- Interrupt Window: cast start through 1.40 seconds; Final Seal has cast armour.
- Follow-up protection: Freeze and major-pressure follow-ups suppressed for
  1.75 seconds.

## Presentation

- 0.35 s: chapter-owned low thirteenth-bell SFX starts.
- 0.55 s: black-blue/pale-silver bell becomes visible over the tracked Player.
- 0.80 s: thirteen-layer muted-violet judgment seal forms at the Player's feet.
- 1.00 s: vertical gravity-compression lines intensify.
- 1.40 s: silver Final Seal closes and ordinary stagger is rejected.
- 1.70 s: HP settles once; the Player visual compresses vertically for 0.28 s
  with a restrained cold-violet tint. No physical hurt animation, knockback,
  blood, physical hit-stop or sword-hit sound is emitted.

## HP Logic

- `> 50`: force final HP to 50.
- `20 < HP <= 50`: subtract 20, clamped to a spell-local floor of 20.
- `<= 20`: unchanged.
- Can Kill Player: **NO**.
- Can Heal Player: **NO**.
- Mutation: one `HealthComponent.set_current_health(target_hp)` call. The
  existing `health_changed` signal remains the HUD source of truth.

## Runtime

- Phase 1 selector: PASS; signature candidate absent.
- Phase 2 formal selector: PASS; deterministic production-selector test chose
  `WEIGHT_OF_ABSOLUTION`, completed its state/recovery chain and settled 90→50.
- Phase transition regression: PASS in the existing B4–B7 full-Boss suite.
- Main/F5 authority: `res://scenes/bootstrap/main_bootstrap.tscn` with Chapter
  III spawn `CH3_BOSS`.
- HUD Sync: PASS by the signal-driven `PlayerHealthHud` contract and one formal
  HealthComponent mutation.
- Exact Godot: `4.7.1.stable.official.a13da4feb`.
- Errors: no script/parser/gameplay error in focused or regression tests.

## HP Matrix

| Before | Expected | Actual | Result |
| -----: | -------: | -----: | :----: |
| 100 | 50 | 50 | PASS |
| 90 | 50 | 50 | PASS |
| 80 | 50 | 50 | PASS |
| 60 | 50 | 50 | PASS |
| 51 | 50 | 50 | PASS |
| 50 | 30 | 30 | PASS |
| 49 | 29 | 29 | PASS |
| 45 | 25 | 25 | PASS |
| 40 | 20 | 20 | PASS |
| 35 | 20 | 20 | PASS |
| 30 | 20 | 20 | PASS |
| 25 | 20 | 20 | PASS |
| 21 | 20 | 20 | PASS |
| 20 | 20 | 20 | PASS |
| 15 | 15 | 15 | PASS |
| 10 | 10 | 10 | PASS |
| 1 | 1 | 1 | PASS |

## Preserved Verification

```text
/Users/vincentz/Downloads/Godot.app/Contents/MacOS/Godot --headless --editor --path . --quit-after 5
/Users/vincentz/Downloads/Godot.app/Contents/MacOS/Godot --headless --path . --script res://chapters/chapter_03_chapel_of_thirteen_echoes/tests/test_edran_judgment_magic.gd
/Users/vincentz/Downloads/Godot.app/Contents/MacOS/Godot --headless --path . --script res://chapters/chapter_03_chapel_of_thirteen_echoes/tests/test_edran_elemental_magic.gd
/Users/vincentz/Downloads/Godot.app/Contents/MacOS/Godot --headless --path . --script res://chapters/chapter_03_chapel_of_thirteen_echoes/tests/test_edran_b4_b7_full_boss.gd
```

Focused result: `PASS assertions=93 history_delay=1.0 bolts=3 hp_cases=17`.
Elemental regression: `PASS assertions=986`. Full Boss regression: `PASS`.
Standing/walking/jump/Dash presentation and perceived 1.35-second punish-window
fairness remain subjective manual acceptance in the live F5 handoff.
