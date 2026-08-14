# `ch3_underkeep_descent` Art and Shallow-Water QA

Date: 2026-08-02
Engine: Godot 4.7.1 Standard, GL Compatibility, OpenGL 4.1 Metal / Apple M4
Formal authority: `res://scenes/bootstrap/main_bootstrap.tscn`

## Audit result

The user-supplied old F5 screenshot showed a chart-like stepped composite. Runtime audit identified it as:

`/root/Chapter03Route/RoomHost/Ch3UnderkeepRoom/UnderkeepDescent/OssuaryStairs`

It was a non-colliding Sprite2D using `assets/environment/r3_grid_aligned/ossuary_stairs_496x200.png`, derived from `assets/environment/water_transition/ossuary_stairs.png`. The node, both PNGs/import records, original generator call/function, R3 resize variant and runtime test manifest entry are deleted. Repository search over current Chapter III source returns no `ossuary_stairs`/`OssuaryStairs` match.

## Strong QA table

| Item | Status | Evidence |
|---|---|---|
| Gray/chart node located | PASS | UD0 audit above; historical runtime audit TSV and user screenshot |
| Gray/chart node fully removed | PASS | `01_main_placeholder_location_recomposed.png`; focused repository search |
| Related collision removed | PASS | audited node had none; no replacement blocker; collision table below |
| Scene composition rebuilt | PASS | images 01, 13 and 15 |
| Formal drainage/ossuary assets | PASS | 54 generated originals; chapter-owned asset tree |
| Water bed | PASS | `water/water_bed/water_bed_2304x108.png` |
| Water body | PASS | four 768x108 frames; images 02–03 |
| Animated surface | PASS | six rear + six four-pixel front frames at 7 FPS |
| Animated highlights | PASS | four frames at 4 FPS; images 02–03 |
| Local ripple | PASS | images 05, 06 and 12 |
| Drip animation/audio | PASS | images 11–12; three randomized 1.8–4.5 s points |
| Player shallow-water run | PASS | focused action test; image 05 |
| Player jump | PASS | focused action test; image 08 |
| Player double jump | PASS | focused action test; formal Player state consumes one air jump |
| Player Ground Dash | PASS | focused action test; image 07 |
| Player attack | PASS | focused action test; image 09 |
| Dash Attack | PASS | focused action test; image 10 |
| Step splash | PASS | image 05 |
| Dash splash | PASS | images 07 and 10 |
| Jump splash | PASS | image 08 |
| Landing ripple | PASS | image 06 |
| Player unobstructed/readable | PASS (rendered) | all inspected Main captures; four-pixel front edge only |
| No air wall | PASS (structural) | continuous floor plus nonblocking Areas; image 14 |
| Chapter IV exit | PASS | image 15 and transition test |
| Fade transition | PASS | images 16–18; formal SceneTransitionManager |
| Main/F5 integration | PASS (script-driven Main) | graphical `UNDERKEEP_UD5_MAIN_QA` |
| Repeat stability | PASS | 10 room round trips, 10 Chapter IV entries, 10 direct reloads |
| Performance budget | PASS (structural) / manual profiler pending | cap=10 transient effects, 3 drips, no shader/material duplication |
| Output/parser/resource errors | PASS | exact editor import + focused tests exit 0 |
| Direct desktop input/Remote Tree | PARTIAL | desktop mouse/keyboard/editor-control tool unavailable in this Codex environment |

Overall result: **PARTIAL pending human feel/Remote-tree acceptance**. Implementation, formal Main renderer, transitions and deterministic regressions pass; direct desktop operation is not fabricated.

## Collision record

| Node path | Original collision | Problem | Resolution | Status |
|---|---|---|---|---|
| `UnderkeepDescent/OssuaryStairs` | none | misleading chart-like presentation | node/resource/generator removed | PASS |
| `UnderkeepDescent/Floor/CollisionShape2D` | 2304x108 StaticBody2D | none; required floor | preserved, top y=612 | PASS |
| `UnderkeepDescent/WaterInteractionArea` | new Area2D mask 2 | must not block | collision layer 0, monitor-only | PASS |
| `MidgroundNarrativeProps/*` | none | potential air walls | all remain presentation-only | PASS |
| `ChapterFourExitArea` | Area2D mask 2 | transition trigger | preserved as nonblocking interaction | PASS |

## Exact verification

```text
generate_underkeep_transition_assets.gd
  UNDERKEEP_ASSET_GENERATION PASS assets=54 original=true nearest_ready=true

test_underkeep_descent_transition.gd
  UNDERKEEP_TRANSITION_TEST PASS placeholder=false water=animated interaction=nonblocking chapter4=reachable

test_underkeep_player_actions.gd
  UNDERKEEP_PLAYER_ACTIONS_TEST PASS run=true jump=true double_jump=true dash=true attack=true dash_attack=true

test_underkeep_transition_stability.gd
  UNDERKEEP_STABILITY_TEST PASS room_roundtrips=10 postboss_entries=10 chapter4_entries=10 direct_reloads=10 elapsed_ms=10146

test_chapter_03_r4_boss_flow.gd
  CH3_R4_BOSS_FLOW PASS checkpoint=true e_gate=true room_swap=true intro=true reward_formation=true weapon_pickup=true underkeep_hook=true

test_chapter_03_r5_full_route.gd
  CH3_R5_FULL_ROUTE PASS transitions=50 cycles=10 persistent_runtime=true platform_combat=true boss_entity=true reward=true

test_chapter_03_render_layers_l1.gd
  CH3_RENDER_LAYERS_L1 PASS doors=4 checkpoint=1 gate_states=3 titles=5 water_edges=2 drop=13 combat_fx=16 y_sort=0

test_edran_b4_b7_full_boss.gd
  EDRAN_B4_B7_FULL_BOSS PASS transition=true phase2_attacks=6 death=true reward_interface=true regressions=20

capture_underkeep_ud5_main_qa.gd
  UNDERKEEP_UD5_MAIN_QA PASS captures=18 main_bootstrap=true water_fx=true chapter4=true
  independently relaunched three times: 3/3 PASS
```

Exact 4.7.1 headless editor import and the updated Chapter III Boss environment regression also exit 0 with no red parser/resource diagnostics.

## Current Main images

1. `01_main_placeholder_location_recomposed.png` — same western location after removal.
2. `02_main_water_animation_frame_a.png`
3. `03_main_water_animation_frame_b.png`
4. `04_main_shallow_water_idle.png`
5. `05_main_shallow_water_run_step.png`
6. `06_main_landing_ripple.png`
7. `07_main_ground_dash_splash.png`
8. `08_main_jump_takeoff_splash.png`
9. `09_main_normal_attack_in_water.png`
10. `10_main_dash_attack_in_water.png`
11. `11_main_drip_falling.png`
12. `12_main_drip_impact_ripple.png`
13. `13_main_half_submerged_props.png`
14. `14_main_visible_collision_shapes.png`
15. `15_main_chapter_four_prompt.png`
16. `16_main_fade_out.png`
17. `17_main_chapter_four_fade_in.png`
18. `18_main_chapter_four_threshold.png`

All paths are below `res://docs/qa/chapter_03_underkeep_descent/` and were captured from the graphical MainBootstrap route, not F6.

## Manual acceptance steps

1. Keep `run/main_scene` at `res://scenes/bootstrap/main_bootstrap.tscn`.
2. Enable Debug Chapter Start; select `CHAPTER_03_CHAPEL_OF_THIRTEEN_ECHOES` and `CH3_UNDERKEEP_DESCENT`.
3. Press F5. Walk through the old left/centre stair location and confirm the chart-like object and any air wall are gone.
4. In the shallow water test left/right Run, Idle, Turn, Jump, Double Jump, Ground Dash, Air Dash, Normal Attack chain and Dash Attack.
5. Confirm footsteps/ripples stop at Idle, jump/landing/dash reactions remain low, and the animated rear water/front four-pixel edge never hides the torso or weapons.
6. Wait beside a drain for randomized falling droplets, impact ripple and quiet positional sound.
7. Open Debug > Visible Collision Shapes and inspect the uninterrupted floor, detection-only water Area and nonblocking props. Inspect Remote Scene Tree z values against the layer table in the spec.
8. Walk to the right gate, press E, confirm Fade Out, `CH4_START`, Fade In, one Player and one HUD.
9. Inspect Output and Debugger; any red line is a failure to report.
