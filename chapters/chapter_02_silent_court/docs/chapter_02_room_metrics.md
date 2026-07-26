# 第二章房间尺寸与移动指标

Status: authoritative Stage 1 graybox measurements

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

## Platform coordinate plan

| Room | Required surfaces (local coordinates) | Optional surfaces |
| --- | --- | --- |
| Corridor | steps `(880,556)`, `(1160,500)`; low platform `(2380,540)` | high ledge `(2860,484)`, reached through 128 px cumulative rise |
| Banquet | tables centered `(980,560)`, `(1420,560)`, `(3300,560)` | balcony floor `y=480`, access via two 66 px tiers |
| Gallery | long floor and 420 px clear overhead | portrait branch platforms `y=548 → 484`, 160 px minimum width |
| Chapel | side platforms `y=540`, `468`, `396`; central altar `y=560` | upper relic perch `y=332`, approached by 64 px tier |
| Passage | stairs `y=556 → 500` and return to 612 | kitchen branch gap 176 px maximum |
| Armory | flat protected floor | shortcut landing 128 px wide minimum |
| Antechamber | final arena flat floor | CP05 platform remains full solid, not one-way |
| Ballroom | uninterrupted `y=612` floor | no gameplay platform in first Boss pass |

Large platforms are fully solid including their undersides. Only small platforms explicitly named `OneWayPlatform_*` may use one-way collision in Stage 3.

## Camera plan

The shared `Player/Camera2D` remains the camera. Stage 2 may set room limits through a narrow room-boundary component; it must not duplicate Player or permanently modify its Resource.

| Room | Planned Camera2D limits `(left, top, right, bottom)` |
| --- | --- |
| 01 | `(0, 0, 2304, 720)` |
| 02 | `(2304, -180, 6912, 720)` |
| 03 | `(6912, -360, 11520, 720)` |
| 04 | `(11520, -180, 15616, 720)` |
| 05 | `(15616, -720, 19456, 720)` |
| 06 | `(19456, -180, 22784, 720)` |
| 07 | `(22784, 0, 24832, 720)` |
| 08 | `(24832, -180, 27520, 720)` |
| 09 | `(27520, -180, 32128, 720)` |

Room-limit changes call `reset_smoothing()` once. Camera never zooms to compensate for invalid geometry. The Ballroom uses a locked range only after the Boss trigger; the Player and placeholder Boss must remain visible at opposite points in the 3968 px usable lane through normal camera following rather than a full-arena zoom-out.

## Checkpoint and spawn coordinates

| Selector | Saved ID | Global position | Safety contract |
| --- | --- | --- | --- |
| `CH2_START` | `chapter_02_cp01` | `(384,612)` | Castle Gate Interior; no enemies in detection range |
| `CH2_BANQUET` | `chapter_02_banquet_cp02` | `(11320,612)` | after E06, before Gallery connector |
| `CH2_CHAPEL` | `chapter_02_chapel_cp03` | `(19216,612)` | after E11, outside projectile/ember coverage |
| `CH2_ARMORY` | `chapter_02_armory_cp04` | `(23424,612)` | protected Armory center; enemies cannot enter |
| `CH2_BOSS` | `chapter_02_boss_cp05` | `(27032,612)` | after E15 and 488 px before Boss door trigger |

The existing registry aliases must be expanded in Stage 2 to include CP03 and the six selectors without breaking the Stage 2A IDs.
