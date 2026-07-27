# Chapter II short-stair and floor-transition QA

Date: 2026-07-27

Engine: Godot 4.7.1 Standard (`a13da4feb`)

Main entry: `res://scenes/bootstrap/main_bootstrap.tscn`

Chapter scene: `res://chapters/chapter_02_silent_court/scenes/level/silent_court.tscn`

## Saved-scene contract

- Short stair instances:
  - `SilentCourt/GameplayWorld/Geometry/GrandServiceStair`
  - `SilentCourt/GameplayWorld/Geometry/ServantSideStair`
- Transition triggers:
  - `SilentCourt/TransitionAreas/Floor1ToFloor2` -> `CH2_FLOOR_2_START`
  - `SilentCourt/TransitionAreas/Floor2ToFloor3` -> `CH2_FLOOR_3_START`
- Controller: `SilentCourt/ChapterSystems/FloorTransitionController`
- Full-screen fade: `SilentCourt/GameplayWorld/PlayerAnchorOrRuntimeActors/ChapterRuntime/HUD/FloorTransitionFade`
- Timing: `0.22 s` fade-out, `0.08 s` black hold, `0.22 s` fade-in (`0.52 s` total).
- Relocation occurs only after opacity reaches 1.0. The shared Player is input-locked and temporarily invulnerable; velocity is cleared, Camera2D floor bounds are updated, and the prior input/invulnerability contract is restored after reveal.

## Automated results

- `SILENT_COURT_GRAYBOX_TEST: PASS rooms=9 floors=3 spawns=11 encounters=15 enemies=38 player=1 hud=1`
- `CH2_FLOOR_TRANSITION_TEST: PASS transitions=2 player=1 hud=1`
- `CH2_THREE_FLOOR_ROUTE_TEST: PASS runs=3 softlocks=0`; each simulated no-combat route completed in `89.00 s`.
- Phase 2 enemy prototype and damage checks passed.
- Hollow Duchess attack-cycle, Main integration and five full-fight simulations passed.
- Graphical MainBootstrap capture: `CH2_FLOOR_TRANSITION_MAIN_QA: PASS captures=5 transitions=2`.

The automated route intentionally disables combat so it can isolate locomotion, collision, trigger, camera and softlock behavior. Encounter fairness and the visual feel of the stairs remain manual F5 acceptance items.

## Visual evidence

All captures are 1280×720 RGBA PNG files generated from the graphical MainBootstrap path.

| Evidence | Purpose | SHA-256 |
| --- | --- | --- |
| `01_floor_1_short_grand_stair.png` | Short F1 stone stair, Player and landing readability | `6229ff6330addb5c38db6813051e37b07d2606b9ccc70e1d435265a5a16195d2` |
| `02_floor_transition_blackout.png` | Fully opaque transition frame; no intermediate elevation is exposed | `84467b364c46c8b3661913ebac73f4a406de6dd715ef0286466f87e374b5180c` |
| `03_floor_2_landing.png` | F2 destination, restored Player/HUD and correct camera floor | `a1692fa05cff83896720fadace56e0b975b43dd8df56b81e273899d55492c5c9` |
| `04_floor_2_short_servant_stair.png` | Mirrored F2 servant stair with timber accents and safe nearby enemies | `1bd29478377f00b61ed82d64b195d8b993521fda289d1fc37037b810ea5e2652` |
| `05_floor_3_landing.png` | F3 destination, restored Player/HUD and correct camera floor | `d0a089ed5531cc7b5dc0ecaf3076d5c5315153d847e77990592d3b3b32530930` |

## Manual F5 acceptance

Enable the Chapter II direct-start debug configuration, start at `CH2_FLOOR_1_START`, and press F5. Travel right through F1, climb the short stone stair at the far right of Last Banquet Hall, and walk into its landing trigger. After the black transition, cross F2 from right to left, climb the short servant stair at the far left, and enter the second trigger. Confirm that F3 appears with the same Player/HUD, the Camera2D follows the correct floor, controls return immediately, and neither stair produces a collision snag.

## Known boundary

This Stage 1 evidence does not claim completion of the later enemy stuck-point/distribution audit, Boss-room shortening/dialogue/reward/Chapter III exit, or whole-chapter environment-art pass.
