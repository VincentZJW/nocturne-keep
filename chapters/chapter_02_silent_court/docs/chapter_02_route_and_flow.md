# Chapter II route and flow — closed stair terminals

Status: playable Main implementation, 2026-07-27

## Authoritative route

```text
F3  closed arrival door -> Antechamber platform encounters -> Ballroom/Boss
      ^
      | black transition from the closed Servant Side Stair terminal
F2  servant terminal <- Servant Passage <- Chapel <- Portrait Gallery <- closed arrival door
                                                                        ^
                                                                        | black transition
F1  Castle Gate -> Grey Banner -> Armory -> Last Banquet -> Grand Stair terminal
```

- Walkable floor surfaces remain `y=612`, `y=-288`, and `y=-1188`; the three-floor snake route was not redesigned.
- Floor 1 advances left-to-right. `LastBanquetHall` now ends at global `x=6320`; the former room/floor continuation from `x=6320..7168` was cropped. The short Grand Service Stair leads to a collision-backed landing, royal arch, heavy wood door and terminal wall at global `x=6880`.
- Floor 2 advances right-to-left. `ServantPassage` now has walkable floor only at local `x=768..1280`; the former local `x=0..768` continuation outside the stair was removed. The short Servant Side Stair ends at a narrow wood door and terminal wall at global `x=208`.
- Floor 2 and Floor 3 start beside closed arrival doors (`Floor2ArrivalVestibule`, `Floor3ArrivalVestibule`) rather than in the middle of an open room. The next encounter activation centers remain safely separated from both arrival points.
- Transition duration remains `0.52 s` (`0.22 + 0.08 + 0.22`). The controller reuses the sole Player/HUD/Camera, clears Chapter II projectiles, deactivates encounter groups, updates Camera bounds before fade-in and restores Player control after the destination is stable.
- Camera horizontal limits stop at the architecture: F1 `0..7040`, F2 `64..7168`, F3 `0..7168`. No camera view can pan beyond a stair terminal into an unbuilt corridor.

## Main entry and debug selectors

`project.godot` runs `res://scenes/bootstrap/main_bootstrap.tscn`. Chapter II resolves to `res://chapters/chapter_02_silent_court/scenes/level/silent_court.tscn`.

Formal selectors include:

- Full route: `CH2_START`, `CH2_FLOOR_1_START`
- Stair terminals: `CH2_FLOOR_1_STAIRS`, `CH2_FLOOR_2_STAIRS`
- Platform-combat checks: `CH2_GALLERY`, `CH2_CHAPEL`, `CH2_ANTECHAMBER`
- Existing room/Boss checks: `CH2_BANQUET`, `CH2_ARMORY`, `CH2_BOSS`, `CH2_FLOOR_2_START`, `CH2_FLOOR_3_START`

`CH2_BOSS` now begins outside the saved formal Ballroom door. Walking into its threshold fades to black, relocates the existing Player behind the door, fades into the Ballroom and starts the first-entry five-line presentation. A respawn repeats the same threshold contract with the shortened Boss intro; it does not create a second Player, HUD or Camera.

For normal F5 acceptance, enable the Chapter II debug start, choose `CH2_START`, then follow the snake route. The stair doors are the only continuation points; stepping into their threshold performs the black-screen relocation.

## Verification contract

- The exact-engine transition stress test performed Floor 1→2 and Floor 2→3 ten times each (`20` transitions total) with correct Player landing and floor Camera bounds every time.
- The real-physics/Input Map route test completed all three floors three times with `softlocks=0`.
- Eight 1280×720 MainBootstrap captures under `docs/qa/chapter_02_stair_platform_fix/` show both terminal walls, both arrivals and three elevated-combat rooms.
- Combat pacing, platform reachability feel and encounter fairness remain human F5 acceptance items; deterministic tests prove saved composition, bounds and runtime stability rather than subjective feel.
