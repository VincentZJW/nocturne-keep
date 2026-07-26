# 第二章房间尺寸与移动指标

Status: Stage 2 implemented dimensions and collision audit

## Live measurement baseline

Measurements were produced by Godot 4.7.1 at 60 physics ticks using `tests/player/measure_player_level_metrics.gd`, not estimated from screenshots.

| Metric | Live value |
| --- | ---: |
| Viewport | 1280×720 px |
| Move speed | 220 px/s |
| Jump velocity / gravity | -420 / 1100 px/s² |
| Single-jump rise / horizontal range | 83.77 / 153.59 px |
| Double-jump rise / horizontal range | 167.10 / 281.92 px |
| Single jump + one Air Dash | 196.59 px horizontal |
| Double jump + one Air Dash | 321.26 px horizontal |
| One Dash motion segment | 86.40 px (`480×0.18`) |
| Player foot offset | 28 px |
| Minimum measured safe landing width | 48 px |
| Platform center-to-safe-edge metric | 98 px |

## Authored traversal envelope

- Mandatory single-jump rises: 48–72 px; 72 leaves 11.77 px measured vertical tolerance.
- Mandatory double-jump rises: 96–136 px; 136 leaves 31.10 px tolerance. No mandatory rise exceeds 136 px.
- Mandatory single-jump gaps: 64–112 px; 112 leaves 41.59 px horizontal tolerance.
- Optional double-jump gaps: 128–208 px; 208 leaves 73.92 px tolerance.
- Optional Air-Dash route gaps: maximum 176 px, leaving 20.59 px against the measured single-jump-plus-dash range.
- Stable navigation platforms: minimum 96 px wide. Combat platforms: minimum 192 px. The 48 px measured floor is reserved for non-critical challenge landings, never checkpoints or required combat footing.
- Normal corridor clear height: at least 192 px. Halberdier/Mourning Armor combat clear height: at least 256 px. Hanging Stalker chambers: at least 420 px.
- Consecutive vertical tiers use 56–72 px steps; the Chapel may stack tiers but never asks for more than one 136 px rise between recoverable footholds.

## Room coordinate convention

Room PackedScenes use local X from zero. The common main-route floor baseline is local/global `y=612`; taller rooms extend upward into negative Y. Stage 2 places the room roots at the global X origins below. Dimensions are authored world bounds, not background-image sizes.

| # | Room | Screens W | World size | Global X | Vertical bounds | Main traversal notes |
| --- | --- | ---: | --- | --- | --- | --- |
| 01 | Castle Gate Interior | 1.80 | 2304×720 | 0..2304 | 0..720 | safe spawn, flat floor, no enemies |
| 02 | Grey Banner Corridor | 3.60 | 4608×900 | 2304..6912 | -180..720 | stairs at 56 px tiers; low 72 px and optional 128 px platforms |
| 03 | Last Banquet Hall | 3.60 | 4608×1080 | 6912..11520 | -360..720 | 52 px tables, 132 px optional balcony, broad floor |
| 04 | Royal Portrait Gallery | 3.20 | 4096×900 | 11520..15616 | -180..720 | ≥420 px ceiling clearance, one optional upper portrait branch |
| 05 | Blood-Candle Chapel | 3.00 | 3840×1440 | 15616..19456 | -720..720 | three reachable tiers at 72 px steps; no unreachable caster perch |
| 06 | Servant Passage | 2.60 | 3328×900 | 19456..22784 | -180..720 | alternating 256 px halls and 192 px connectors; kitchen branch |
| 07 | Old Armory Safe Room | 1.60 | 2048×720 | 22784..24832 | 0..720 | 320 px protected center; CP04 and shortcut |
| 08 | Silent Ballroom Antechamber | 2.10 | 2688×900 | 24832..27520 | -180..720 | final encounter, then 512 px safe Boss buffer |
| 09 | Silent Ballroom | 3.60 | 4608×900 | 27520..32128 | -180..720 | 3968 px clear battle lane, flat floor |

Total authored horizontal extent is 32,128 px (25.1 viewport widths). Direct held-right travel is not the chapter pacing measure; Stage 2 acceptance times the critical traversal with stairs, vertical crossings, doors, branches and camera transitions. Target no-combat human traversal remains 6–9 minutes; a pure movement speedrun is expected to be substantially shorter and will be recorded separately.

## Implemented platform coordinates

All coordinates are `(left, top, width, thickness)` in room-local pixels. The uninterrupted main floor is authoritative; these are optional movement-test surfaces rather than mandatory route blockers.

| Room | Implemented full-solid platforms | Branch/anchor |
| --- | --- | --- |
| Gate Interior | `(920,498,280,20)`, `(1560,450,320,20)` | `GateUpperLookout` |
| Corridor | solid stair ramp `(700,612)→(1100,500)→(1300,500)→(1700,612)`; platforms `(2240,456,320,20)`, `(3520,490,300,20)` | `CorridorUpperRoute` |
| Banquet | four jumpable tables `(560/1840/3120/3800,548,520,18)`; balcony `(2140,398,360,20)` | `BanquetServiceBranch`, `BanquetBalconyBranch`, `ChandelierAnchor`; final table ends before CP02 safety margin |
| Gallery | `(760,490,300,20)`, `(1780,442,300,20)`, `(2920,490,300,20)` | `GalleryCeilingAnchor` |
| Chapel | side arc `(720,486)→(1280,354)→(1840,222)→(2400,354)→(2960,486)`, all 300×20; altar `(1660,560,520,52)` | `ChapelCeilingAnchor`, `BloodCandleAnchor` |
| Passage | ramp `(420,612)→(760,520)→(1040,520)→(1380,612)`; center platform `(1760,442,300,20)`; second ramp `(1900,612)→(2240,520)→(2480,520)→(2820,612)` | `KitchenBranch` |
| Armory | `(690,492,300,20)`, `(1270,456,300,20)` | `ArmoryMerchantPlaceholder` |
| Antechamber | `(720,492,300,20)`, `(1640,452,320,20)` | Boss approach buffer |
| Ballroom | none | `BossLaneCenter`; 3968 px clear floor lane |

Large platforms are fully solid including their undersides. Only small platforms explicitly named `OneWayPlatform_*` may use one-way collision in Stage 3.

## Implemented Camera plan

The shared `Player/Camera2D` remains the camera. Stage 2 may set room limits through a narrow room-boundary component; it must not duplicate Player or permanently modify its Resource.

The one existing `Player/Camera2D` uses continuous horizontal limits `(0,32128)` in every room to prevent boundary snapping. Each room-owned `CameraBounds` Area only changes vertical limits and calls `reset_smoothing()` once. This is the intentional Stage 2 refinement of the Stage 1 per-room horizontal clamp proposal.

| Room | Active Camera2D limits `(left, top, right, bottom)` |
| --- | --- |
| 01 | `(0, 0, 32128, 720)` |
| 02 | `(0, -180, 32128, 720)` |
| 03 | `(0, -360, 32128, 720)` |
| 04 | `(0, -180, 32128, 720)` |
| 05 | `(0, -720, 32128, 720)` |
| 06 | `(0, -180, 32128, 720)` |
| 07 | `(0, 0, 32128, 720)` |
| 08 | `(0, -180, 32128, 720)` |
| 09 | `(0, -180, 32128, 720)` |

Room-limit changes call `reset_smoothing()` once. Camera never zooms to compensate for invalid geometry. The Ballroom uses a locked range only after the Boss trigger; the Player and placeholder Boss must remain visible at opposite points in the 3968 px usable lane through normal camera following rather than a full-arena zoom-out.

## Checkpoint and spawn coordinates

Debug markers store the Player origin at `y=584`, placing its measured 28 px foot offset exactly on floor `y=612`. Checkpoint anchors themselves remain floor-location placeholders at `y=612`.

| Selector | Checkpoint association | Global Player origin | Safety contract |
| --- | --- | --- | --- |
| `CH2_START` | `Chapter02CP01` | `(384,584)` | Castle Gate Interior; no enemies instantiated |
| `CH2_BANQUET` | `Chapter02CP02` | `(11320,584)` | post-Banquet / Gallery approach |
| `CH2_GALLERY` | inspection selector | `(11840,584)` | Gallery entry |
| `CH2_CHAPEL` | `Chapter02CP03` | `(15776,584)` | Chapel entry |
| `CH2_ARMORY` | `Chapter02CP04` | `(23424,584)` | protected Armory center |
| `CH2_BOSS` | `Chapter02CP05` | `(27032,584)` | Antechamber, before Boss door |

The saved Start Profile exposes exactly these six selectors. Respawn binds to the selected marker for this graybox; activating CP01–CP05 is deferred to the next stage.

## Stage 2 collision findings

- All nine room floors are full-solid `StaticBody2D` rectangles on World layer 1. Their edges meet at the exact room global bounds; a real F5 traversal crossed all eight joints without a step, fall or narrow seam.
- Optional platforms, banquet tables and the Chapel altar are full solid. Corridor and Servant Passage use solid shallow-slope stair polygons, and every room owns a solid ceiling boundary at its authored vertical minimum. No one-way collision, moving platform or door collision is introduced in Stage 2.
- The full 32,128 px route is bounded by 64 px outer walls. Boss-room activation is an inert Area placeholder; `BossSpawn`, `PlayerBossEntry`, `BossCameraBounds`, rear door and exit door are named anchors only.
- Known limitation: platform underside, edge comfort, staircase feel, Chapel vertical framing and all four door collision modes still require the approved next-stage collision pass.
