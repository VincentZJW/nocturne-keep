# Player Movement and Level Metrics

Version: 2.0
Date: 2026-07-24
Status: measured against shipping Player and repaired F5 Main

## Runtime source of truth

- F5: `res://scenes/main/main.tscn`
- Player: `Main/World/Player`, instance of `res://scenes/player/player.tscn`
- Movement: `res://resources/player/player_movement_config.tres`
- Actions: `res://resources/player/player_action_prototype_config.tres`
- Stamina: `Main/World/Player/StaminaComponent`
- Physics: Godot 4.7.1, 60 ticks/s, `CharacterBody2D.move_and_slide()`

Main has no local overrides for Player movement, action, double-jump, or Stamina values.

## Actual movement parameters

| Parameter | Runtime value | Notes |
| --- | ---: | --- |
| Horizontal speed | 220 px/s | shared ground/air cap |
| Ground acceleration / deceleration | 1400 / 1700 px/s² | unchanged |
| Air acceleration | 850 px/s² | air-control acceleration |
| Gravity | 1100 px/s² | no maximum-fall-speed clamp |
| Ground jump velocity | -420 px/s | negative Y is upward |
| Double-jump velocity | -420 px/s | reuses the same configured jump velocity |
| Coyote time | 0.10 s | first ground jump only |
| Jump input buffer | 0.12 s | unchanged |
| Variable jump cut | none | releasing Space does not truncate ascent |
| Double jump | `debug_enable_double_jump=true` | formal `has_double_jump=false` remains locked |
| Air/Ground Dash | 480 px/s × 0.18 s | horizontal; gravity suspended during active Air Dash |
| Stamina | 100 maximum / 25 per Dash | four paid segments from full |
| Player body | 24×52 px, local Y +2 | root-to-foot offset 28 px |

## Measured movement envelope

`tests/player/measure_player_level_metrics.gd` instantiates the shipping Player scene and issues real Input Map actions. Vertical rise is measured from collision-foot Y, not sprite or node center.

| Movement | Horizontal range | Maximum foot rise | Result |
| --- | ---: | ---: | --- |
| Standing single jump | 0 px | 83.77 px | measured |
| Standing debug double jump | 0 px | 167.10 px | second jump near apex |
| Forward single jump | 153.59 px | 83.77 px | takeoff to landing |
| Forward debug double jump | 281.92 px | 167.10 px | takeoff to landing |
| Single jump + one Air Dash | 192.92–196.59 px | 83.77 px | fixed-step input boundary range near apex |
| Double jump + one Air Dash | 321.26–324.92 px | 167.10 px | fixed-step input boundary range near second apex |
| Four continuous Air Dashes | 344.00 px | 0 px added | action-only movement |
| Four-Dash jump entry to landing | 360.33–362.22 px | entry dependent | full Stamina theoretical route check |

The formula `480 × 0.18 × 4 = 345.6 px` is the theoretical Dash-only maximum. The fixed-step result is 344.00 px and is the production QA value.

### Edge, center, and landing width

- The Player half-width is 12 px. On a 220 px departure platform, a center start versus a 12 px-safe edge start changes available horizontal reach by 98 px (`110 - 12`). This is route margin, not additional movement capability.
- A physical collision can occur with less overlap, but the production minimum landing surface is 48 px: 24 px body plus 12 px safety on each side. Main platforms are 190–240 px wide, so each provides substantially more than the required 8–16 px margin.
- Platform elevation always uses lower and upper top surfaces. Node-center differences are invalid because every platform is 24 px thick and Floor collision is 96 px thick.

## Reachability thresholds

Using the 167.10 px measured double-jump rise:

| Route class | Limit | World-pixel rise | Rule |
| --- | ---: | ---: | --- |
| Main route | ≤80% | ≤133.68 px | stable double jump, no Air Dash |
| Challenge | >80% to 90% | 133.69–150.39 px | repeatable double jump with generous landing |
| Hidden/reward | >90% to 95% | 150.40–158.75 px | precision or clearly signposted one Air Dash |
| Invalid | >95% | >158.75 px | lower, reroute, or add an intermediate surface |

The first-level required progression remains the continuous Floor. Elevated combat surfaces may be Challenge routes, but no enemy staging surface may be unreachable.

## F5 Main platform audit and repair

All platforms are direct `StaticBody2D` children of `Main/World`; no TileMap, nested Level PackedScene, or stale Main reference is involved.

| Node path | Width | Before center/top | After center/top | Rise from Floor | Class / required ability | Content |
| --- | ---: | --- | --- | ---: | --- | --- |
| `Main/World/Floor` | 6700 | center `(3250,688)`, top 640 | unchanged | 0 | main route | all encounters, checkpoint, Boss entry |
| `Main/World/PlatformA` | 220 | `(870,520)`, top 508 | unchanged; one-way enabled | 132 | 79.0%, main-safe double jump | no required content |
| `Main/World/PlatformB` | 190 | `(2780,438)`, top 426 | `(2780,512)`, top 500 | 140 | 83.8%, Challenge double jump | Group04 Crossbowman |
| `Main/World/PlatformC` | 220 | `(4420,470)`, top 458 | `(4420,516)`, top 504 | 136 | 81.4%, Challenge double jump | Group06 Crossbowman |
| `Main/World/PlatformD` | 220 | `(5160,450)`, top 438 | `(5160,520)`, top 508 | 132 | 79.0%, main-safe double jump | Group07 Crossbowman |
| `Main/World/GargoylePerch` | 240 | `(3560,340)`, top 328 | `(3560,504)`, top 492 | 148 | 88.6%, Challenge double jump | Group05 dive landing/counter surface |

Because the Floor runs beneath every elevated surface and those surfaces are now downward-facing one-way collisions, the reasonable departure point is directly below the target: horizontal platform gap is 0. The actual movement challenge is vertical timing and landing margin, not an artificial center-to-center horizontal gap.

### Enemy alignment after repair

| Enemy path | Before | After | Surface relation |
| --- | --- | --- | --- |
| `Main/World/Encounters/EncounterGroup04/Enemies/FallenCrossbowman01` | `(2780,396)` | `(2780,470)` | 30 px root offset above PlatformB top |
| `Main/World/Encounters/EncounterGroup06/Enemies/FallenCrossbowman02` | `(4420,428)` | `(4420,474)` | 30 px root offset above PlatformC top |
| `Main/World/Encounters/EncounterGroup07/Enemies/FallenCrossbowman03` | `(5160,408)` | `(5160,478)` | 30 px root offset above PlatformD top |
| `Main/World/Encounters/EncounterGroup05/Enemies/GargoyleSentinel01` | `(3480,270)` | `(3500,402)` | 90 px above perch; 44 px edge margin |
| `Main/World/Encounters/EncounterGroup05/Enemies/GargoyleSentinel02` | `(3680,270)` | `(3620,402)` | 90 px above perch; 44 px edge margin |

The Crossbowmen remain centered with at least 79 px platform edge clearance. The Gargoyles now dive onto a reachable surface and have enough vertical clearance to wind up, Dive, enter GroundStun, and return to their saved home Y.

## Collision and route findings

- All five elevated collision shapes are one-way downward surfaces. Player upward motion passes through; falling Player and diving Gargoyles collide with the top.
- Visual top and collision top share the same `-12` local Y. Irregular lower stone edges are visual only and do not create hidden collision.
- Boss checkpoint `(5480,612)`, Boss entry, gates, Camera 0..6600, and arena Floor are unchanged and remain reachable through the Floor mainline.
- No intermediate platform was necessary: lowering the invalid authored surfaces was the least invasive correction.
- Player jump, gravity, Dash, Stamina, collision size, and Camera tuning were not changed.

## Reproduction

```bash
"$GODOT_BIN" --headless --path . --script tests/player/measure_player_level_metrics.gd
"$GODOT_BIN" --headless --path . --script tests/level/test_main_platform_reachability.gd
"$GODOT_BIN" --headless --path . --script tests/level/test_main_traversal_routes.gd
```

Expected summaries:

```text
PLAYER_LEVEL_METRICS: PASS ... standing_single_rise=83.77 standing_double_rise=167.10 ... single_plus_air_dash=196.59 double_plus_air_dash=321.26 ...
MAIN_PLATFORM_REACHABILITY_TEST: PASS (5 surfaces, one-way collision, enemies aligned, real double-jump landings)
MAIN_TRAVERSAL_ROUTES_TEST: PASS (mainline no Air Dash, mobility Crossbow route, novice-timing Gargoyle route; no teleport)
```
