# Player Movement and Level Metrics

Version: 2.0
Date: 2026-07-24
Status: measured against shipping Player and repaired F5 Main

## Runtime source of truth

- F5: `res://chapters/chapter_01_ravenmourn_outskirts/scenes/level/ravenmourn_outskirts.tscn`
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
| `Main/World/Floor` | 5620 | center `(2710,688)`, top 640 | ends at near-bank edge x=5520 | 0 | main route | seven encounters and near-bank checkpoint |
| `Main/World/PlatformA` | 220 | `(870,520)`, top 508 | unchanged; full solid | 132 | 79.0%, main-safe edge double jump | no required content |
| `Main/World/PlatformB` | 190 | `(2780,438)`, top 426 | `(2780,512)`, top 500 | 140 | 83.8%, Challenge double jump | Group04 Crossbowman |
| `Main/World/PlatformC` | 220 | `(4420,470)`, top 458 | `(4420,516)`, top 504 | 136 | 81.4%, Challenge double jump | Group06 Crossbowman |
| `Main/World/PlatformD` | 220 | `(5160,450)`, top 438 | `(5160,520)`, top 508 | 132 | 79.0%, main-safe double jump | Group07 Crossbowman |
| `Main/World/GargoylePerch` | 240 | `(3560,340)`, top 328 | `(3560,504)`, top 492 | 148 | 88.6%, Challenge double jump | Group05 dive landing/counter surface |

Because elevated surfaces are now solid, the valid route starts just beyond an edge, clears the top, and steers onto the platform. The unchanged 167.10-pixel double-jump rise remains sufficient for all 132–148-pixel rises; deterministic route tests use real air control and no teleport after spawn. Jumping from directly below intentionally produces a ceiling collision instead of access.

### Castle bridge metrics

| Surface / bound | Saved value | Purpose |
| --- | --- | --- |
| Near-bank Floor end | x=5520, top y=640 | checkpoint approach; 40-pixel jump to bridge |
| WoodenBridge | x=5560..6360, 800×20, top y=640 | continuous solid Boss arena |
| CastleFloor | x=6360..6624, top y=640 | post-gate completion area |
| Boss logical bounds | x=5650..6320 | keeps 38-pixel Boss body away from bridge ends/gate |
| Boss entry | x=5780 | 27.5% into bridge |
| CastleGate | center x=6400, 48×260 | visible closure; 1.00-second lift |

### Fallen Gate Knight response metrics

| Metric | Configured Main value | Fixed-step result / purpose |
| --- | ---: | --- |
| Body Health | 180 | unchanged |
| Shield Health | 100 | unchanged; Ravenfang 12/24 damage remains authoritative |
| Turn reaction | 0.33 s | cancellable while Player returns to front/center |
| Turn animation | 0.80 s | three authored 128×96 frames runtime-scaled; facing commits at 80% |
| Total turn | 1.13 s authored | 1.1333 s measured at 60 physics ticks/s; target 1.00–1.30 s |
| Side threshold | 12 px | center-line hysteresis |
| Turn cooldown | 0.14 s | prevents repeated left/right jitter |
| Shield Bash timing | 0.46 / 0.10 / 0.68 s | windup / active / recovery |
| Shield Bash selection | 22%, 2.70 s cooldown | close-only (≤37 px), no direct repeat |

The old 0.80–1.00-second target is superseded. The Player now receives one stable rear Normal or Dash punish before the late facing commit, with a timing-dependent second Normal. In 20 deterministic rear-entry trials, the first hit routed rear 20/20, the second 14/20 and the third 0/20; rear Dash routed body 10/10. Facing committed at 0.9833 seconds and the state completed at 1.1333 seconds without light/heavy hit feedback resetting the timer. Attack windups/active frames remain direction-locked, while GuardRecovery and ordinary Recovery can begin the turn. Per-skill Attack Gaps are measured from active close—not animation finish—to next windup: Shield Bash 1.183, Sword Slash 1.050, Heavy Overhead 1.200, complete Combo Slash 1.050, Charge Thrust 1.133, Jump Smash 1.167 and Shockwave Strike 1.100 seconds at 60 Hz. Damage and active-frame indices are unchanged.

| Melee family | Before | After | Shape edge / effective Player-root distance | Visual tip |
| --- | --- | --- | ---: | ---: |
| Shield Bash | shared `100×42 @ (65,4)` | `14×30 @ (19,4)` | 26 / 37 px | 32 px |
| Sword/Heavy/Combo/Jump Slash | shared `100×42 @ (65,4)` | `26×22 @ (16,0)` | 29 / 40 px | 31 px |
| Charge Thrust | shared `100×42 @ (65,4)` | `32×10 @ (20,-7)` | 36 / 47 px | 41 px |

The former shared volume had a 115 px local forward edge and about 126 px effective root reach after the Player Hurtbox half-width. The new shapes end inside their active visual tips, stay entirely forward of the Boss center and mirror through the same `FacingRoot` as the attack art.

Bridge and castle floor meet flush at x=6360. The near bank intentionally ends 40 pixels before the bridge at x=5560: a forgiving single jump crosses it, while walking off allows the existing moat death flow to be tested. Moat water/hazard occupies x=5520..6360 below the bridge.

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

- All five elevated collision shapes are full solid World surfaces. Player upward motion hits the bottom, side movement hits the edge, and falling Player/enemies land on top.
- Visual top and collision top share the same `-12` local Y. Irregular lower stone edges are visual only and do not create hidden collision.
- Boss checkpoint remains `(5480,612)`, but the former flat `BossRoom/EntranceGate/ExitGate` was replaced by `CastleEntranceArea`, moat, 800-pixel bridge, visible rear barrier, animated castle gate and completion trigger. Normal Camera limits remain 0..6600; live Boss limits are 5340..6620.
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
MAIN_PLATFORM_REACHABILITY_TEST: PASS (5 solid surfaces, jump/double-jump underside blocking, Dash side blocking, top landings)
MAIN_TRAVERSAL_ROUTES_TEST: PASS (mainline no Air Dash, mobility Crossbow route, novice-timing Gargoyle route; no teleport)
CASTLE_BRIDGE_FLOW_TEST: PASS (solid underside, moat death/respawn, Boss reset/persistence)
```

## Chapter I opening/tutorial/roster metrics

Viewport design target: 1280×720. Player camera limits remain 0–6600 horizontally and 0–720 vertically.

| Metric | Value |
|---|---:|
| Main route start | x 320 |
| Tutorial end/checkpoint | x 2580 |
| Forest end/checkpoint | x 3780 |
| Outskirts end/checkpoint | x 4780 |
| Boss checkpoint | x 5480 |
| Castle threshold | x 6428 |
| Normal enemies | 34 |
| EncounterGroups | 18 |
| Mainline enemies | 27 |
| Optional enemies | 7 |
| Bosses | 1 |

Tutorial additions use solid `StaticBody2D` collision and integer positions: fallen log center (620, 618), launch platform (2170, 522), landing platform (2460, 452). Existing Platform A–D, Gargoyle perch, world floor, bridge, walls, moat hazard, and castle collision remain unchanged.

Automated metrics validate composition and node contracts. Jump timing, air-dash comfort, sightline fairness, encounter recovery length, and a 20–30 minute first-play target remain manual acceptance items.
