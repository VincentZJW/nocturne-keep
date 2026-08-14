# Soul Gaoler Ormund Difficulty Rebalance Report

Date: 2026-08-14  
Scope: `CH4-BOSS-BALANCE-0` through `CH4-BOSS-BALANCE-5`  
Formal authority: `res://scenes/bootstrap/main_bootstrap.tscn`  
Primary weapon: Thirteenfold Absolution / 十三重赦刃 (`14 / 28`)

## QA result

Overall: **PASS for deterministic/runtime balance and Main integration; PARTIAL for final human-feel acceptance.**

The exact Godot 4.7.1 runtime, formal Boss scene, production Health/Hurtbox/
DamagePolicy/Poise chain, formal Chapter IV Boss room and MainBootstrap were
tested. Desktop Control opened the real Main debug build and confirmed the
`CH4_BOSS_PHASE_01` room, `14/28` HUD value and saved presentation. Continuous
held-key input is not exposed by the available desktop driver, so it could not
honestly substitute for the user's final hands-on feel pass. Complete-fight
telemetry below comes from deterministic production-component replays, not a
fabricated claim of manual play.

## Baseline audit

| Item | Before |
|---|---:|
| Max HP | 560 |
| Phase II threshold | 55% |
| P1 / P2 damage taken | 0.82 / 0.72 |
| P1 / P2 Poise | 150 / 190 |
| P1 / P2 Stagger | 0.48 s / 0.38 s |
| P1 / P2 protection | 3.40 s / 4.00 s |
| Boss source alpha height | 172 px / 170 px |
| Player alpha height | 57 px |
| Boss / Player height ratio | 3.02 / 2.98 |
| Body collider | 66 × 142 at y=-71 |
| Hurtbox | 76 × 148 at y=-74 |
| Frontal melee hitbox | 148 × 72 at x=90, y=-65 |
| Area hitbox | 260 × 138 at y=-68 |
| Maximum combo | Unbounded reselection |
| Forced Player Turn | None |
| 180-degree response | 0.22 / 0.16 s wait, then immediate flip |

The old AI could finish Recovery and roll another attack without a guaranteed
neutral interval. It had no Combo Budget, no PlayerTurn state, no recent-attack
history and no high-pressure spacing rule.

## Formal attack timeline

Damage values were deliberately preserved.

| Phase | Attack | Windup | Active | Old Recovery | New Recovery | Damage | Coverage / Tracking |
|---|---|---:|---:|---:|---:|---:|---|
| 1 | Halberd Sweep | 0.60 | 0.15 | 0.76 | 0.90 | 18 | front-only; locked through Active |
| 1 | Anchor Slam | 0.82 | 0.17 | 1.05 | 1.48 | 22 | front-only; heavy punish |
| 1 | Prison Hook Drag | 0.70 | 0.14 | 0.88 | 1.12 | 15 | front-only; suppressed at wall |
| 1 | Floodgate Charge | 0.66 | 0.24 | 1.05 | 1.08 | 19 | committed direction; suppressed at wall |
| 1 | Soul Cage Pulse | 0.78 | 0.16 | 0.92 | 1.18 | 14 | explicit 360°; 7.5 s cooldown |
| 2 | Chainstorm Cleave | 0.58 | 0.22 | 0.78 | 1.15 | 21 | front-only; high pressure |
| 2 | Undertow Pull | 0.72 | 0.18 | 0.86 | 0.74 | 17 | spacing tool, not a full freeze |
| 2 | Drowned Cell Rupture | 0.88 | 0.18 | 1.00 | 1.32 | 23 | explicit 360°; 5 s cooldown |
| 2 | Soul Shackle | 0.64 | 0.14 | 0.82 | 0.76 | 16 | front pressure; no forced heavy follow-up |
| 2 | Flooded Judgment | 1.02 | 0.24 | 1.15 | 1.62 | 25 | explicit 360°; 10 s cooldown |

Normal frontal attacks use the 100 × 48 front hitbox. Only Pulse, Rupture and
Judgment use the reduced 180 × 96 area hitbox. Attack direction is committed
from Windup through Recovery; a successful crossing does not drag the weapon
hitbox around the Boss.

## Rhythm and turning

- Phase I Combo Budget is 2, followed by an uncancellable 1.05-second Player Turn.
- Phase II normally uses 2 attacks; every fourth sequence may use 3, followed by
  an uncancellable 0.82-second Player Turn.
- The same attack cannot repeat immediately. Chainstorm, Rupture and Judgment
  cannot share one Combo Budget.
- The Boss takes 0.50 seconds in Phase I and 0.40 seconds in Phase II to complete
  a 180-degree facing change. The visual flip occurs at the end, not on the first
  physics frame.
- Charge and Hook are suppressed while the Player is within 170 px of an arena
  edge. Movement bounds are supplied by the formal Boss room controller.
- Phase I/II movement speed and every attack's damage remain unchanged.

## Collider and presentation result

`VisualRoot` uses nearest-neighbour scale `0.6`, which yields measured alpha
ratios of 1.81× in Phase I and 1.79× in Phase II. The Boss remains a large heavy
humanoid without retaining the source sheet's former 3× gameplay footprint.
Body collision is now 44 × 92 and covers the torso, not the Soul Cage, chains or
weapon. Hurtbox is 50 × 98. This preserves body solidity while allowing a dash
or jump to cross behind the torso.

## Punish windows

| Attack | Recommended dodge | Can cross behind | Safe Normal count | Dash Attack | Window before next attack |
|---|---|---|---:|---|---:|
| Sweep | dash through / step out | Yes | 2 | Yes | 0.90 s |
| Anchor Slam | late dash / jump | Yes | 3 | Yes + Normal | 1.48 s |
| Hook Drag | dash through hook | Yes | 3 | Yes | 1.12 s |
| Charge | cross after commitment | Yes | 3 | Yes | 1.08 s |
| Soul Cage Pulse | leave area, re-enter | N/A (360°) | 3 | Yes | 1.18 s |
| Chainstorm | dash through final cleave | Yes | 3 | Yes | 1.15 s |
| Undertow | jump / lateral escape | Yes | 2 | No guaranteed Dash | 0.74 s |
| Cell Rupture | leave telegraph | N/A (360°) | 3 | Yes | 1.32 s |
| Soul Shackle | jump / step behind | Yes | 2 | No guaranteed Dash | 0.76 s |
| Flooded Judgment | clear telegraph | N/A (360°) | 3 | Yes + Normal | 1.62 s |

Across the replayed Boss cycles, the average best punish window is 1.35 seconds
(the arithmetic mean across all ten individual Recovery values is 1.14 seconds).
The longest interval with no recovery/output opportunity is 1.26 seconds. The
longest three-action Phase II sequence is 6.80 seconds including its internal
Recovery windows; it is not 6.80 seconds of continuous lockout.

## A/B and complete-fight telemetry

The full-fight replays apply every Normal and Dash hit through the real player
Hitbox → Boss Hurtbox → BossDamagePolicy → Health/Poise path. They select
Balance B because it shortens attrition without lowering attack damage or
removing Phase II pressure.

| Run | Weapon | Time | Normal Hits | Dash Hits | Staggers | Player Hit Count | Death | Result |
|---:|---|---:|---:|---:|---:|---:|---:|---|
| Balance A standard (480 / .88 / .82) | 14/28 | 249.7 s | 21 | 10 | 2 | 2 | 0 | Victory |
| Balance B standard (460 / .90 / .84) | 14/28 | 237.8 s | 20 | 9 | 2 | 2 | 0 | Victory |
| Balance B conservative | 14/28 | 330.5 s | 26 | 6 | 2 | 3 | 0 | Victory |
| Balance B aggressive | 14/28 | 154.8 s | 26 | 6 | 2 | 1 | 0 | Victory |

| Metric | Standard B |
|---|---:|
| Longest Boss sequence | 6.80 s (contains Recovery windows) |
| Longest Player no-output opportunity | 1.26 s |
| Average punish window | 1.35 s |
| Successful behind-cross cycles | 20 |
| Average attacks after crossing | 1.45 |
| Phase I time | 112.9 s |
| Phase II time | 124.9 s |

Pure 14-damage input resolves to 13/12 damage in Phase I/II; pure 28-damage
Dash resolves to 25/24. The mixed standard replay is 38 Normal Equivalent
inputs (20 + 9×2), two equivalents above the nominal 28–36 target but well
below the former effective-health burden. Because the recommended 460 HP and
integer 13/12 damage resolution mathematically require about 38 pure Normal
hits, Balance B is kept instead of reducing the Boss below its intended Chapter
IV durability. The measured standard fight still lands inside the requested
3.5–5-minute experience window.

## Forced QA table

| Item | Before | After | PASS/FAIL |
|---|---:|---:|---|
| Boss Max HP | 560 | 460 | PASS |
| P1 Damage Taken | 0.82 | 0.90 | PASS |
| P2 Damage Taken | 0.72 | 0.84 | PASS |
| P1 Poise | 150 | 130 | PASS |
| P2 Poise | 190 | 158 | PASS |
| P1 Stagger | 0.48 s | 0.82 s | PASS |
| P2 Stagger | 0.38 s | 0.65 s | PASS |
| Boss/Player height ratio | 3.02 / 2.98 | 1.81 / 1.79 | PASS |
| Extra interval after sequence | 0 | 1.05 / 0.82 s | PASS |
| Maximum continuous attacks | unbounded | 2 / normally 2, rare 3 | PASS |
| P1 Player Turn | none | 1.05 s | PASS |
| P2 Player Turn | none | 0.82 s | PASS |
| 180° Turn Time | 0.22 / 0.16 then instant flip | 0.50 / 0.40 s | PASS |
| Behind-cross stability | unreliable | 30/30 focused crossings | PASS |
| Heavy punish window | 1.00–1.15 s | 1.32–1.62 s | PASS |
| Standard player fight | not measured / reported overlong | 237.8 s | PASS |
| Aggressive player fight | blood-magic route required | 154.8 s | PASS |
| Boss pressure | continuous | dangerous turns with guaranteed release | PASS |
| Boss weight | large footprint | deliberate turn and committed attacks | PASS |
| Main/F5 | former saved Boss | new saved Boss through MainBootstrap | PASS |
| Human feel acceptance | user reported FAIL | pending user play | PARTIAL |

## Main/F5 evidence

- Main path: `res://scenes/bootstrap/main_bootstrap.tscn`
- Chapter: `CHAPTER_04_DROWNED_UNDERKEEP`
- Spawn: `CH4_BOSS_PHASE_01`
- Saved room: `res://chapters/chapter_04_drowned_underkeep/scenes/rooms/ch4_14_core_of_drowned_gaol.tscn`
- Boss instance: `Enemies/SoulGaolerOrmund`
- Boss scene: `res://chapters/chapter_04_drowned_underkeep/scenes/bosses/soul_gaoler_ormund.tscn`

Desktop inspection opened Main at the formal Boss spawn and visibly confirmed
the 14/28 weapon readout. The scripted Main capture additionally resolved the
saved room/Boss/controller, both phases, Direction Lock, PlayerTurn and the
ultimate Recovery.

Evidence:

- `01_main_phase_01_scale_and_spacing.png`
- `02_main_anchor_slam_direction_lock.png`
- `03_main_anchor_slam_active.png`
- `04_main_anchor_slam_punish_window.png`
- `05_main_player_turn_back_position.png`
- `06_main_phase_02_scale.png`
- `07_main_flooded_judgment_active.png`
- `08_main_flooded_judgment_punish_window.png`

## Commands and results

- Exact 4.7.1 headless editor/import: exit 0.
- `test_soul_gaoler_ormund_runtime.gd`: PASS.
- `test_soul_gaoler_ormund_balance.gd`: PASS, including 30/30 focused
  committed-direction back crossings.
- `test_soul_gaoler_ormund_balance_replays.gd`: PASS, four complete replays.
- `capture_soul_gaoler_ormund_balance_main_qa.gd`: PASS, eight Main captures,
  formal `14/28` weapon.
- `test_chapter_04_q4_boss_flow.gd`: PASS.
- `test_chapter_04_main_integration.gd`: PASS.
- Existing `test_chapter_04_boss_route_stress.gd`: FAIL in unrelated reward
  persistence expectations (`reward_collected` / memory passage). The formal Q4
  route test passed; no reward-system code was changed because it is explicitly
  outside this task.

Godot editor Debugger inspection showed zero red errors after the focused tests.

## Required answers

1. Ordinary attacks give **0.74–1.15 seconds**, usually about **0.9–1.1 seconds**.
2. Heavy attacks give **1.32–1.62 seconds**.
3. Dash crossing behind is stable against the reduced torso collider and locked
   frontal hitbox; final feel acceptance remains the user's manual gate.
4. Re-facing takes **0.50 seconds in Phase I** and **0.40 seconds in Phase II**.
5. Standard 14/28 production-component replay: **237.8 seconds (3:57.8)**.
6. The standard replay used **38 Normal Equivalent** inputs.
7. Phase I: **112.9 seconds**; Phase II: **124.9 seconds**.
8. Blood-magic play is **not required**; conservative dodge → punish completed
   in **330.5 seconds** without death.
9. The Boss remains dangerous and heavy: **yes**. Damage, movement speed, skills,
   Soul Cage identity and Phase II mechanics were preserved.

## Manual acceptance

From the editor, set Debug Chapter Start to Chapter IV / `CH4_BOSS_PHASE_01`,
equip Thirteenfold Absolution, and press F5. Verify one complete conservative
run and one standard run, paying special attention to dash-through reliability,
the 0.50/0.40-second delayed turn, the 1.48-second Slam punish and the
1.62-second Judgment punish. This is the remaining subjective acceptance step.
