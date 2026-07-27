# 第二章房间尺寸与移动指标

Status: Phase 1 vertical graybox implemented and verified

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

- Mandatory tier rises: 68–120 px. Every authored vertical sequence stays at or below 120 px, leaving at least 47.10 px against the measured double-jump rise.
- Mandatory single-jump gaps: 64–112 px; 112 leaves 41.59 px horizontal tolerance.
- Optional double-jump gaps: 128–208 px; 208 leaves 73.92 px tolerance.
- Optional Air-Dash route gaps: maximum 176 px, leaving 20.59 px against the measured single-jump-plus-dash range.
- Stable navigation platforms are at least 192 px wide; the narrowest new route landing is 360 px. The 48 px measured floor is never used for a required landing, checkpoint or future combat footing.
- Normal corridor clear height: at least 192 px. Halberdier/Mourning Armor combat clear height: at least 256 px. Hanging Stalker chambers: at least 420 px.
- Consecutive vertical tiers use 56–72 px steps; the Chapel may stack tiers but never asks for more than one 136 px rise between recoverable footholds.

## Room coordinate convention

Room PackedScenes use local X from zero. The common main-route floor baseline is local/global `y=612`; taller rooms extend upward into negative Y. Stage 2 places the room roots at the global X origins below. Dimensions are authored world bounds, not background-image sizes.

| # | Room | Screens W | World size | Global X | Vertical bounds | Main traversal notes |
| --- | --- | ---: | --- | --- | --- | --- |
| 01 | Castle Gate Interior | 1.80 | 2304×720 | 0..2304 | 0..720 | safe spawn plus low arrival lookout; no enemies |
| 02 | Grey Banner Corridor | 3.60 | 4608×900 | 2304..6912 | -180..720 | broad stair entries and a continuous upper gallery |
| 03 | Last Banquet Hall | 3.60 | 4608×1080 | 6912..11520 | -360..720 | tables below, two-sided stairs and a long upper balcony |
| 04 | Royal Portrait Gallery | 3.20 | 4096×900 | 11520..15616 | -180..720 | five small ascending/descending air-route platforms |
| 05 | Blood-Candle Chapel | 3.00 | 3840×1440 | 15616..19456 | -720..720 | symmetrical three-tier monumental stair, max tier rise 120 px |
| 06 | Servant Passage | 2.60 | 3328×900 | 19456..22784 | -180..720 | one continuous rise/crest/descent service route |
| 07 | Old Armory Safe Room | 1.60 | 2048×720 | 22784..24832 | 0..720 | safe spawn on clear floor; optional two-tier mezzanine |
| 08 | Silent Ballroom Antechamber | 2.10 | 2688×900 | 24832..27520 | -180..720 | two-level approach ending before a 588 px Boss/checkpoint buffer |
| 09 | Silent Ballroom | 3.60 | 4608×900 | 27520..32128 | -180..720 | 3968 px clear battle lane, flat floor |

Total authored horizontal extent is 32,128 px (25.1 viewport widths). Direct held-right travel is not the chapter pacing measure; Stage 2 acceptance times the critical traversal with stairs, vertical crossings, doors, branches and camera transitions. Target no-combat human traversal remains 6–9 minutes; a pure movement speedrun is expected to be substantially shorter and will be recorded separately.

## Implemented platform coordinates

All coordinates are `(left, top, width, thickness)` in room-local pixels. The continuous left-to-right traversal spine is authoritative: broad stair surfaces may raise it above y=612, but every required rise is staged and each room rejoins the shared floor before its protected exit.

| Room | Implemented full-solid platforms | Branch/anchor |
| --- | --- | --- |
| Gate Interior | stair plateau `(440,612)→(800,520)→(1420,520)→(1740,612)`; platforms `(880,520,520,24)`, `(1540,448,420,24)` | `GateUpperLookout` |
| Corridor | entry stair to `(1040,500,800,24)`; upper spans `(1980/3020,410,880,24)`; second stair ascends through y=500 before descending to exit | `CorridorUpperRoute` |
| Banquet | four jumpable tables at y=548; lower balconies `(720/3120,480,760,24)` and central `(1640,388,1320,24)`; broad stairs at both ends | `BanquetServiceBranch`, `BanquetBalconyBranch`, `ChandelierAnchor` |
| Gallery | `(480,500,440,24)→(1100,420,360,24)→(1640,340,360,24)→(2180,420,360,24)→(2720,500,440,24)` | `GalleryCeilingAnchor` |
| Chapel | continuous symmetric stair surfaces at y=500/380/260/380/500 with 400–480 px landings; altar `(1660,560,520,52)` | `ChapelCeilingAnchor`, `BloodCandleAnchor` |
| Passage | continuous profile `(260,612)→(620,520)→(1380,440)→(2220,520)→(3040,612)` with 420–500 px landings | `KitchenBranch` |
| Armory | entry stair to `(520,500,480,24)` and optional `(1160,420,480,24)` mezzanine | `ArmoryMerchantPlaceholder` |
| Antechamber | continuous stair profile through `(500,500,520,24)` and `(1180,420,520,24)`, returning to floor at x=2100 | 588 px clear Boss/checkpoint approach |
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
| `CH2_ARMORY` | `Chapter02CP04` | `(22912,584)` | protected clear floor before the Armory stair |
| `CH2_BOSS` | `Chapter02CP05` | `(27032,584)` | Antechamber, before Boss door |

The saved Start Profile exposes exactly these six selectors. Respawn binds to the selected marker for this graybox; activating CP01–CP05 is deferred to the next stage.

## Phase 1 vertical collision findings

- All nine room floors are full-solid `StaticBody2D` rectangles on World layer 1. Their edges meet at the exact room global bounds; a real F5 traversal crossed all eight joints without a step, fall or narrow seam.
- Every visible platform is sourced from the same exported `platform_rects` array that creates its full-solid collision, and every visible staircase is sourced from the same `stair_polygons` array that creates its polygon collision. The old invisible-platform / hard-coded-ramp split has been removed.
- Grey Banner, Banquet, Chapel, Servant Passage, Armory and Antechamber use broad full-solid stair polygons. Gallery deliberately uses separated optional jump platforms above a clear floor. Every raised main-route profile descends to y=612 before a protected exit, and the Ballroom remains fully flat.
- The full 32,128 px route is bounded by 64 px outer walls. Boss-room activation is an inert Area placeholder; `BossSpawn`, `PlayerBossEntry`, `BossCameraBounds`, rear door and exit door are named anchors only.
- Known limitation: these are broad graybox slopes with visual tread marks, not final stair tiles. Platform underside art, edge dressing and all door collision modes remain later work; enemy/encounter/Boss implementation is explicitly absent from Phase 1.
