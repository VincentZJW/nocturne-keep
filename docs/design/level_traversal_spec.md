# First-Level Traversal Specification

Version: 1.0
Last updated: 2026-07-24

## Contract

The F5 source of truth is `res://scenes/main/main.tscn`. Main progression must remain possible across the continuous Floor-to-WoodenBridge route with single/double jump and cannot require chained Air Dash, enemy collision, remote teleport, or frame-perfect input.

Measured production envelope:

- single jump: 83.77 px rise / 153.59 px forward;
- double jump: 167.10 px rise / 281.92 px forward;
- single jump + one Air Dash: 192.92–196.59 px forward;
- double jump + one Air Dash: 321.26–324.92 px forward;
- full-Stamina four-Air-Dash action: 344.00 px;
- minimum production landing width: 48 px.

Main-route surfaces are limited to 80% of double-jump rise (133.68 px). Challenge surfaces may use 80–90% (up to 150.39 px). Hidden/reward surfaces may use 90–95% only with visual guidance or a clearly intended single Air Dash. Anything higher is invalid.

## Route layers

### Main route

`SpawnPoint (320,612) → EncounterGroup01..07 → BossCheckpoint (5480,612) → NearBank → WoodenBridge → Boss Entry`

This route stays on solid Main geometry, requires no Air Dash, and crosses every ActivationArea. Floor ends at x=5520; a clearly visible 40-pixel moat opening requires one ordinary jump onto the 800-pixel bridge at x=5560. `CastleFloor` continues flush from x=6360. Walking deliberately off the bank reaches the moat hazard, while the normal jump is far inside the measured single-jump envelope.

### Mobility route

The repaired Crossbow platforms are optional combat access points. PlatformB/C are Challenge double jumps; PlatformD is main-safe. A double jump plus one Air Dash may shorten the PlatformC approach but is never mandatory.

### Gargoyle counter route

`GargoylePerch` is a Challenge surface at 148 px (88.6%). It accepts a delayed second jump in deterministic testing, is 240 px wide, and gives the Player a stable surface on which a diving Gargoyle enters its 0.65-second GroundStun counter window.

No hidden route currently carries required first-level content.

## Repaired surfaces

| Path | Before center | After center | Top-surface rise | Horizontal gap from Floor below | Ability | Route class |
| --- | --- | --- | ---: | ---: | --- | --- |
| `Main/World/PlatformA` | `(870,520)` | unchanged | 132 | 0 | double jump | main-safe |
| `Main/World/PlatformB` | `(2780,438)` | `(2780,512)` | 140 | 0 | double jump | challenge |
| `Main/World/PlatformC` | `(4420,470)` | `(4420,516)` | 136 | 0 | double jump; one Air Dash optional | challenge |
| `Main/World/PlatformD` | `(5160,450)` | `(5160,520)` | 132 | 0 | double jump | main-safe |
| `Main/World/GargoylePerch` | `(3560,340)` | `(3560,504)` | 148 | 0 | stable/delayed double jump | challenge |

All five now use full solid collision. Top/bottom/side surfaces remain visually aligned with their 24-pixel collision thickness; widths are 190–240 px and exceed the 48 px production minimum. The intended access route approaches from a platform edge, rises above the solid top, then lands; jumping vertically through the stone from below is no longer valid.

## Enemy spawn changes

- Group04 Crossbow: `(2780,396) → (2780,470)`.
- Group06 Crossbow: `(4420,428) → (4420,474)`.
- Group07 Crossbow: `(5160,408) → (5160,478)`.
- Group05 Gargoyles: `(3480,270)/(3680,270) → (3500,402)/(3620,402)`.

Crossbow roots remain exactly 30 px above their platform top and centered. Gargoyles remain 90 px above the perch and inside both safe edges.

## Development telemetry

F4 toggles a default-off, read-only Level Traversal overlay. It displays collision-foot Y, jump start, current rise, horizontal displacement, recorded single/double peaks, nearest platform, surface differences, and Reachable/Risky/Hidden/Unreachable classification. It is a child of the existing Debug root, so F1 still hides all development diagnostics. It never modifies physics or collision.

## Acceptance routes

1. No-Air-Dash mainline: actual spawn to bridge Boss entry over continuous solid Floor/Bridge; all seven ActivationAreas entered.
2. Mobility route: actual spawn, edge approach to PlatformB, double jump + one Air Dash edge approach onto PlatformC, then PlatformD.
3. New-player timing: actual spawn to GargoylePerch; second jump intentionally delayed until downward velocity reaches 50 px/s.

All spawn-to-route tests issue real Input actions and never change Player position after scene spawn. Focused collision tests additionally place the shipping Player under each saved platform to prove single/double-jump ceiling contact, non-negative post-impact vertical velocity, Air Dash/Dash Attack side blocking, and top landing. Manual F5 should still judge subjective readability and comfort.
