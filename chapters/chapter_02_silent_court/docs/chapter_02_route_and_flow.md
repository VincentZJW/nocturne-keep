# Chapter II route and flow — three-floor authority

Status: playable Main implementation, 2026-07-27

## Route

```text
F3  x=168 Third Floor Landing -> Upper Court Gallery -> Antechamber -> Ballroom/Boss x=7168
       ^
       | Servant Side Stair (x=168..1968)
F2  x=0 Servant Passage <- Blood-Candle Chapel <- Royal Portrait Gallery x=7168
                                                                    ^
                                                                    | Grand Service Stair (x=5368..7168)
F1  x=0 Castle Gate -> Grey Banner -> Armory -> Last Banquet Hall x=7168
```

- Floor surfaces are `y=612`, `y=-288`, and `y=-1188`.
- Floor 1 advances left-to-right. The broad banquet stair climbs right into Floor 2.
- Floor 2 advances right-to-left. The servant stair climbs left into Floor 3.
- Floor 3 advances left-to-right; the Hollow Duchess remains the terminal encounter.
- Three identical horizontal bounds are shared. The route is long without exposing a 32k-pixel horizontal strip.

## Main entry and debug selectors

`project.godot` runs `res://scenes/bootstrap/main_bootstrap.tscn`. Chapter II resolves to `res://chapters/chapter_02_silent_court/scenes/level/silent_court.tscn`.

Selectors: `CH2_START`, `CH2_BANQUET`, `CH2_GALLERY`, `CH2_CHAPEL`, `CH2_ARMORY`, `CH2_BOSS`, `CH2_FLOOR_1_START`, `CH2_FLOOR_1_BANQUET`, `CH2_FLOOR_2_START`, `CH2_FLOOR_2_CHAPEL`, `CH2_FLOOR_3_START`.

For a complete F5 test, enable Chapter II in `DebugRunConfig`, choose `CH2_FLOOR_1_START` or `CH2_START`, then follow the snake route above. No direct coordinate write is required by gameplay.

## Timing contract

- The exact-engine clean traversal test completed all three floors and reached the Boss lane three times without a softlock.
- Each no-combat run was 90.90 simulated seconds at 220 px/s with automatic jumps around authored props. Combat, exploration, checkpoint use and narrative are not included.
- The 25–35 minute first-play target remains a manual content/pacing acceptance target; it is not claimed by the automated no-combat route.
