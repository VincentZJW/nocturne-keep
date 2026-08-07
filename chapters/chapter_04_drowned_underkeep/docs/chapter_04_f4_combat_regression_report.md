# Chapter IV CH4-F4 Combat Regression Report

Date: 2026-08-06
Engine: Godot 4.7.1 (`a13da4feb`)
Main authority: `res://scenes/bootstrap/main_bootstrap.tscn`

## 2026-08-07 natural-traversal addendum

The earlier deterministic F4 matrix proved the runtime contracts after loading,
activating and positioning actors, but it did not walk the Player through each
piece of saved room collision. A user playtest exposed that gap: in the Cistern,
Encounter 01 worked, then the Player stopped at `x≈856`, before Encounter 02's
ActivationArea at `x=1120`. The later actors therefore correctly remained
dormant and appeared inert/unhittable, which prevented the room-clear gate from
opening.

The obstruction was the left edge of `PlatformCollision_01` (`x=868–932`).
Chapter IV's 12px-thick elevated platforms were authored as two-way rectangles,
so they acted as side walls at Player/enemy body height. A previous narrow fix
changed only Cistern `PlatformCollision_00`; the same defect remained on the
next platform and in other formal rooms.

The repaired contract is now explicit:

- all 23 `PlatformCollision_*` shapes in the nine affected saved Chapter IV
  rooms are one-way platforms;
- the formal-room builder writes `one_way_collision = true`, preventing a
  regeneration regression;
- floors, room/gate blockers and actor collision remain two-way;
- the Main encounter test asserts this contract on all 165 room loads;
- before the deterministic matrix, the test now performs a natural Cistern
  pass with real `move`, `jump`, `attack` and parsed `interact` Input Map
  events—no direct Encounter activation, target assignment, health mutation or
  room handoff.

Observed result: both Cistern groups cleared through real Player attacks, the
second group produced 26 health-change events, the encounter gate unlocked and
the saved `ExitEast` interaction entered `CH4_AREA_06`. The visible Godot run
also showed Encounter 02 active beyond the former blocker; Sewer Maw, Mirefin
Raider and Bog Toad moved/attacked and their health decreased in sequence.

| Natural-flow gate | Status | Evidence |
|---|---|---|
| Cross former `x≈856` blocker | PASS | Player reached Encounter 02 at `x>1120` |
| Encounter 02 activation | PASS | AI/Hurtbox/target restored on formal actors |
| Real Player hits | PASS | 26 `health_changed` emissions in Encounter 02 |
| Both groups clear | PASS | no direct damage/activation calls in natural pass |
| Cistern gate unlock | PASS | gate and `ExitEast` reported unlocked |
| Formal interaction | PASS | `CH4_AREA_05 → CH4_AREA_06` via `interact` event |
| Full Chapter IV regressions | PASS | F4, S5, combat, Main integration and Q4/Boss flow |
| Output/Debugger | PASS | no red script/resource/runtime error |

## Result

CH4-F4 passes. No new production-code, tuning, Player, Boss, Chapter I–III,
art, music, narrative, loot, or Encounter-composition change was required.
F1–F3 fixes remain stable through repeated formal Main room reloads.

| Gate | Status | Evidence |
|---|---|---|
| Eight ordinary/elite roles | PASS | 460 formal Main instances; all 8 roles observed |
| Encounter activation/serialization | PASS | 20 unique groups, 200 activations; S4 runtime serialization/rollback/rearm PASS |
| Movement and tracking | PASS | 460 formal Main chase-velocity checks |
| Shallow-water behavior | PASS | S5 formal Main 22 shallow-water checks |
| Enemy attacks Player | PASS | S5 92 formal Main contacts; combat stress 48 bilateral/facing contacts |
| Player normal/Dash attacks enemies | PASS | S5 184 formal Main contacts; combat stress 32 bilateral/facing contacts |
| One hit per attack | PASS | S5 and combat stress exact-damage/dedup assertions |
| Enemy death/clear | PASS | 10 formal Main deaths per role (80); isolated stress 20 per role (160) |
| Encounter leave/return | PASS | five full forward/reverse passes, 165 room loads |
| Checkpoint registration/reload | PASS | Area 06/12 anchors five times each; Broken Chainway checkpoint reloads 5 |
| Animated room transitions | PASS | 32 forward/reverse transitions, one persistent Player/HUD, one room instance |
| Boss isolation | PASS | Q4 flow PASS; Boss route 10 complete cycles |
| Main/F5 authority | PASS | default MainBootstrap 180-frame smoke entered formal opening cinematic |
| Output/Debugger | PASS | final valid commands contain no red script/resource/runtime error |

## Formal Main route coverage

- 17 unique rooms.
- 5 full forward and reverse route passes.
- 165 room loads.
- 10 combat rooms, 20 saved Encounter groups and 46 enemies per complete
  chapter population.
- 200 Encounter lifecycle activations and clears.
- 460 formal Main enemy instances and movement checks.
- 80 formal Main deaths: 10 each for Drowned Gaoler, Chainbound Convict,
  Mire Harpooner, Sunken Shield Penitent, Mirefin Raider, Bog Toad, Sewer
  Maw and Underkeep Executioner.
- 10 checkpoint-anchor registrations: 5 in Area 06 and 5 in Area 12.

## Exact commands and outcomes

All commands used `/Users/vincentz/Downloads/Godot.app/Contents/MacOS/Godot`
with `--headless --path .`.

| Test | Outcome |
|---|---|
| Editor import/parse (`--editor --quit-after 8`) | exit 0 |
| `test_chapter_04_main_encounters_s4.gd` | PASS `5/165/200/460/460/80/10/8` |
| `test_chapter_04_enemy_runtime.gd` | PASS |
| `test_chapter_04_encounter_runtime_s4.gd` | PASS serialization/rollback/rearm/reload |
| `test_chapter_04_encounter_manifests_s4.gd` | PASS `10 rooms/20 groups/46 enemies` |
| `test_chapter_04_formal_route_s3.gd` | PASS `17 rooms/672 assets/2 checkpoints/20/46` |
| `test_chapter_04_transitions_s5.gd` | PASS `32 transitions/40 activations/92 movement/92 action/92 enemy damage/184 Player damage/22 water/8 roles` |
| `test_chapter_04_combat_stress.gd` | PASS `8 roles/160 deaths/360 actions/48 enemy contacts/32 Player contacts/5 reloads` |
| `test_broken_chainway_transition_stress.gd` | PASS `10 transitions/5 checkpoint reloads` |
| `test_chapter_04_boss_route_stress.gd` | PASS all ten-cycle Boss/reward/memory gates |
| `test_chapter_04_main_integration.gd` | PASS |
| `test_chapter_04_q4_boss_flow.gd` | PASS |
| Default Main smoke (`--quit-after 180`) | exit 0, formal opening cinematic selected |

## Scope audit

| Out-of-scope subsystem | Modified files |
|---|---:|
| Chapter I | 0 |
| Chapter II | 0 |
| Chapter III | 0 |
| Player | 0 |
| Chapter IV Boss | 0 |
| Shared gameplay/combat | 0 |
| Enemy/Player tuning | 0 |

## Manual F5 acceptance

Enable the existing Chapter IV debug start (`chapter_id =
CHAPTER_04_DROWNED_UNDERKEEP`, spawn `CH4_START`) and traverse Areas 01–12.
For each combat room, confirm enemies are visible but dormant before their
boundary, then track/move/attack after entry; use normal and Dash attacks in
both directions; leave and return to representative rooms; activate the dry
gaoler and last-gaol checkpoints. Automated gates prove deterministic
contracts, while reaction feel, combat fairness and visual readability remain
manual acceptance items.
