# Chapter III Structural Rework — R3 Layer and Collision Report

Status: R3 complete. R4 Boss-flow finalization and R5 full-route acceptance remain deliberately pending.

## Scope and Main authority

R3 changes the active Chapter III route loaded by Main/F5:

`res://chapters/chapter_03_chapel_of_thirteen_echoes/scenes/level/chapter_03_route.tscn`

The route continues to own one persistent Player/HUD runtime and one active room. R3 does not change Player movement, combat values, enemy AI, Boss AI, gate interaction semantics or cross-chapter progression.

## Authoritative draw contract

| Category | z_index | Runtime use |
|---|---:|---|
| Far Background | -100 | backdrops, distant organ pipes |
| Background Architecture | -60 | fixed arches, organ case, deep Boss architecture |
| Props Behind Actors | -30 | benches, choir stalls, lecterns, altars, statues |
| Ground Visual | -10 | Boss ritual floor |
| Platforms | 0 | every playable platform and vestibule stair |
| Enemies | 10 | all Chapter III enemy roots; room controller reapplies this to runtime actors |
| Player | 12 | persistent Main-route Player |
| Interactables | 14 | physical doors, checkpoint art, prompts and room titles |
| Limited Foreground | 20 | low underkeep water edge only |
| HUD | CanvasLayer | persistent gameplay HUD and room Fade |

`Chapter03LayerContract` is the single named source for these bands. No formal room uses Y-sort, `top_level`, or a foreground CanvasLayer to alter actor ordering. Enemy and Player roots retain relative z ordering through room swaps.

## Collision corrections

| Area / node | Audit finding | R3 result |
|---|---|---|
| Vestibule `Geometry/Step01..08` | Eight visible 64 px courses had only five 100 px rectangles; first physical top was 8 px below art | Rebuilt as eight shapes. Tops are exactly y612, 622, 632, 642, 652, 662, 672 and 682; the 512 px stair is continuous through the room exit |
| Vestibule `Doors/NaveExit` | Exit volume ended before the lowest visible course | Center moved to y640 so the exit covers the final stair courses without creating a blocker |
| Nave four platforms | Visual/collision surface contract needed final acceptance | All four visual and physical tops match; 60 px rise cadence retained |
| Choir four platforms | Same final-acceptance requirement | All four visual and physical tops match; organ access remains ordinary-jump reachable |
| Formal room doors | Visible door and physics blocker could diverge after opening | Each door disables its exact blocker before/while the visual raises; automated acceptance covers Nave, Boss gate and post-Boss descent gate |
| Choir organ layers | Large organ art risked becoming an invisible wall | Far pipes and organ case remain Sprite2D-only; no collision exists on either decorative layer |
| Boss Sanctum right boundary | Existing blocker looked suspicious in the old one-canvas layout | Retained only at the visibly closed room boundary. R4 owns opening/exit progression; it is not placed across an open passage |
| Reliquary descent seal | Closed art has a blocker | Reward collection swaps to open art and disables that blocker on the next physics frame |
| Underkeep foreground water | Needed actor-readability check | Water is z20 but confined to the low floor edge and owns no collision |

## Pixel-grid cleanup

The reused Boss modules previously scaled source PNGs at 0.62, 0.72, 0.78, 0.80 and 0.82 and rotated fixed props. R3 generated eight chapter-local nearest-neighbour, grid-sized variants under:

- `assets/environment/r3_grid_aligned/`
- `assets/props/r3_grid_aligned/`

Formal Boss/transition scenes now reference these integer-sized textures at scale 1 (or x=-1 for a deliberate horizontal mirror), and fixed environmental props no longer use fractional rotation. This removes fractional sampling without replacing or repainting the original source assets.

## Reachability and actor readability

- The measured conservative single-jump rise remains 62.83 px; all normal-route vertical steps remain 60 px.
- Nave playable widths are 160, 160, 96 and 144 px. Choir widths are 192, 192, 96 and 160 px.
- The Player is z12 and enemies are z10, both ahead of all architecture/props. Doors remain ahead only while physically closed; low foreground is restricted to the underkeep water edge.
- The continuous floor is still the critical path. Elevated surfaces remain optional pressure/attack routes rather than mandatory extreme-jump checks.

## Main/F5 evidence

All captures use `main_bootstrap.tscn` with Chapter III Debug Start and resolve to the active formal route, not an F6-only fixture:

- `docs/qa/chapter_03_r3_vestibule_stair_main.png`
- `docs/qa/chapter_03_r3_nave_platform_main.png`
- `docs/qa/chapter_03_r3_choir_layers_main.png`
- `docs/qa/chapter_03_r3_stair_visible_collisions_main.png`
- `docs/qa/chapter_03_r3_visible_collisions_main.png`

The two collision images were captured from the same Main path with Godot `--debug-collisions`. The stair image shows eight physical courses matching the visible steps. The Choir image shows physical floor/platform/door shapes while the organ art itself owns no world blocker.

## Commands and results

1. Exact Godot 4.7.1 grid-asset generator — PASS, `variants=8 integer_grid=true`.
2. Exact Godot 4.7.1 headless editor import/parse — exit 0; no parser or missing-resource error.
3. `test_chapter_03_r3_layers_collisions.gd` — PASS, `stairs=8 platforms=8 doors=3 actor_z=10/12`.
4. `test_chapter_03_r2_room_structure.gd` — PASS, `rooms=8 swaps=4 persistent_player=1`.
5. `test_chapter_03_boss_environment.gd` — PASS.
6. `test_chapter_03_boss_route.gd` — PASS.
7. `test_chapter_03_phase_2_enemy_roster.gd` — PASS, `roles=6`.
8. Saved F5/Main bootstrap smoke — exit 0; formal opening route starts with no red runtime error.
9. Graphical Main capture — PASS in normal and visible-collision modes.

## R3 acceptance matrix

| Check | Status | Evidence |
|---|---|---|
| Unified z contract | PASS | `Chapter03LayerContract`, R3 test |
| Player/enemy visibility | PASS | z12/z10 assertions and Nave/Choir Main captures |
| Eight-step visible/physical alignment | PASS | deterministic top assertions and stair collision capture |
| Platform visible/physical alignment | PASS | eight deterministic platform assertions |
| Door blocker release | PASS | three blocker-release assertions |
| Organ/decoration air-wall audit | PASS | no decorative collision plus visible-collision capture |
| Integer-grid Boss-area assets | PASS | eight pre-sized PNG variants; no fractional scene scale/rotation |
| Main/F5 integration | PASS | MainBootstrap output and five screenshots |
| Output / Debugger red errors | PASS | import, tests, smoke and captures completed without red errors |

## Stage boundary

R3 is complete. The closed Boss threshold remains intentional. The E-confirmed Boss gate sequence, Boss intro authority, exit and post-Boss transition are R4; full Chapter II → Chapter III → Boss → Chapter IV regression and final visual acceptance are R5. This report does not claim either later stage is complete.
