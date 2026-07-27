# Chapter II three-floor room metrics

Status: current saved-scene authority, 2026-07-27

## Width comparison

| Measurement | Width |
| --- | ---: |
| Chapter I outer wall/effective horizontal range | 6,624 px |
| Chapter II before rebuild | 32,128 px |
| Chapter II after rebuild | 7,168 px |
| New Chapter II / Chapter I | 108.2% |

The rebuild removes 24,960 horizontal pixels (77.7%) while retaining nine named room scenes across three elevations.

## World ranges and rooms

| Floor | World range | Surface | Direction | Rooms / local width |
| --- | --- | ---: | --- | --- |
| F1 Public Court | x `0..7168`, y `0..720` | 612 | left -> right | Gate 1408; Corridor 1792; Armory 1024; Banquet 2944 |
| F2 Noble/Chapel | x `0..7168`, y `-900..-180` | -288 | right -> left | Servant 1280; Chapel 2688; Gallery 3200 |
| F3 Ritual/Ballroom | x `0..7168`, y `-1800..-1080` | -1188 | left -> right | Antechamber/Upper Gallery 2688; Ballroom 4480 |

Room roots:

- F1: `CastleGateInterior (0,0)`, `GreyBannerCorridor (1408,0)`, `OldArmorySafeRoom (3200,0)`, `LastBanquetHall (4224,0)`.
- F2: `ServantPassage (0,-900)`, `BloodCandleChapel (1280,-900)`, `RoyalPortraitGallery (3968,-900)`.
- F3: `SilentBallroomAntechamber (0,-1800)`, `SilentBallroom (2688,-1800)`.

## Stair metrics

- Grand Service Stair: scene `scenes/rooms/grand_service_stair.tscn`, world origin `(6320,0)`, 560 px horizontal run / 192 px rise, approximately 592 px surface length, with 14 visible stone steps.
- Servant Side Stair: scene `scenes/rooms/servant_side_stair.tscn`, world origin `(168,-900)`, 560 px horizontal run / 192 px rise, approximately 592 px surface length, with 14 visible stone-and-timber steps.
- Both stairs use a solid collision wedge, a rear structural fill and a separately drawn tread/rail treatment. They only communicate a nearby floor change; they no longer span the full 900 px elevation gap.
- `TransitionAreas/Floor1ToFloor2` at `(6880,372)` relocates to `CH2_FLOOR_2_START`; `TransitionAreas/Floor2ToFloor3` at `(208,-528)` relocates to `CH2_FLOOR_3_START`.
- `ChapterSystems/FloorTransitionController` performs `0.22 s` fade-out + `0.08 s` full-black hold + `0.22 s` fade-in (`0.52 s` total). Player input and damage reception are temporarily locked, relocation happens only at full black, and the existing Camera2D bounds are switched to the destination floor before reveal.
- The 900 px floor separation remains intentionally larger than the measured 167.10 px double-jump rise; normal jumping cannot bypass the authored floor transitions.

## Spawn positions

All Marker2D values are Player origins (28 px above the surface). Enemy runtime anchors store true foot positions, then apply the shared `Vector2(0,-28)` origin conversion exactly once.

| Selector | Position |
| --- | --- |
| CH2_START / CH2_FLOOR_1_START | `(384,584)` |
| CH2_BANQUET / CH2_FLOOR_1_BANQUET | `(4480,584)` |
| CH2_ARMORY | `(3340,584)` |
| CH2_GALLERY / CH2_FLOOR_2_START | `(6840,-316)` |
| CH2_CHAPEL / CH2_FLOOR_2_CHAPEL | `(3700,-316)` |
| CH2_FLOOR_3_START | `(384,-1216)` |
| CH2_BOSS | `(2500,-1216)` |

Camera bounds are `0..7168` horizontally and floor-local vertical limits of `0..720`, `-900..-180`, or `-1800..-1080`. Room Area limits now add the room's global Y offset before emission.
