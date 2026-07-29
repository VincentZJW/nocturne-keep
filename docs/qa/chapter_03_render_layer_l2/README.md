# Chapter III render-layer L2 evidence

Status: **Main/F5-equivalent capture complete for all content present on current HEAD; final L3 sign-off not started.**

## Runtime source

- `project.godot` resolves `run/main_scene` to `res://scenes/bootstrap/main_bootstrap.tscn`.
- The capture driver starts that saved Main scene, uses `DebugRunConfig` to enter the formal `Chapter03Route`, and does not instantiate the room scenes as isolated F6 tests.
- Every PNG is 1280x720 and was captured from the root viewport after a forced render draw.
- `screenshot_index.tsv` records room, target, Player position, live Camera center/limit, action, door state and capture status for 79 unique PNGs.
- `runtime_layer_samples.tsv` records 530 live CanvasItem samples with node path, parent, local/effective z, relative-z status, y-sort status, CanvasLayer, visibility and runtime position.
- `00_vestibule_runtime_collisions.png` is captured from a clean Main load with runtime collision hints enabled. The capture driver then reloads Main with collision hints disabled before generating the visual matrix, so debug geometry does not contaminate the remaining evidence.

## Coverage

| Formal room | PNG count | Covered presentation |
|---|---:|---|
| `CH3_CHAPEL_VESTIBULE` | 14 | supplied door viewpoint, bench/stair risk points, jump, attack, dash attack, ordinary-door closed/partial/open, runtime collision overlay |
| `CH3_NAVE_ENTRY` | 11 | run, ground/air dash, fall, three formal enemy roles, ordinary-door states |
| `CH3_CHOIR_GALLERY` | 12 | ground/platform movement and attack, three formal enemy roles, runtime Drop z=13, CombatFX z=16, ordinary-door states |
| `CH3_BOSS_CHECKPOINT` | 14 | supplied checkpoint viewpoint from left/front/right, interaction, jump, attack, hurt, death body, ghost, respawn, ordinary-door states |
| `CH3_BOSS_ANTE` | 17 | supplied statue/shrine/lectern/boards viewpoints, jump and both attacks, Boss gate closed/lit/partial/open/Fade |
| `CH3_BOSS` | 3 | formal Boss-intro completion, entry, center attack and east air dash |
| `CH3_POST_BOSS` | 3 | entry, reliquary boundary and underkeep exit |
| `CH3_UNDERKEEP_DESCENT` | 5 | entry, both 4 px water-surface risk points, jump/attack and planned Chapter IV boundary |

The image set has 79 distinct SHA-256 contents; there are no duplicated/stale viewport frames. Four critical rooms were reloaded 20 times each (80 successful swaps total) with one active room and Player effective z=12 after every swap.

## Runtime layer observations

- Player roots resolve to effective z=12 in all eight rooms; `WeaponVisual` resolves to 13 and `DeathEffects/GhostSprite` to 14.
- All six formal Chapter III enemy actors resolve to effective z=10.
- The generated coin pickup and its visual resolve to z=13.
- The live projectile and timed-field subtrees resolve to z=16.
- Ordinary door panels, checkpoint composites and full Boss-gate states remain behind actors at z=-30; prompts and interaction text remain at z=14.
- Underkeep water bodies remain behind actors, with only the authored 4 px surface strips at limited foreground z=20.
- No Chapter III CanvasItem uses y-sort in the captured route.

## Representative evidence

- Supplied vestibule viewpoint: `02_vestibule_v02_door_center.png`
- Player attack at the same door: `08_vestibule_v08_attack.png`
- Runtime collision overlay: `00_vestibule_runtime_collisions.png`
- Supplied checkpoint viewpoint: `30_checkpoint_c02_front.png`
- Death body and ghost: `36_checkpoint_death_body.png`, `37_checkpoint_ghost_release.png`
- Supplied confessions/lectern viewpoint: `46_ante_t04_lectern_front.png`
- Boss gate partial opening with Player in front: `55a_gate_b08_open_25.png`
- Runtime Drop and CombatFX: `drop_coin_runtime_z13.png`, `combat_fx_runtime_z16.png`
- Limited water foreground: `66_underkeep_water_attack.png`
- Planned terminal boundary: `67_underkeep_chapter4_boundary.png`

## Truthful boundaries

- The current HEAD still has no Thirteenth Pontiff Edran combat entity, authoritative Boss reward instance or loadable Chapter IV scene. Environment and transition boundaries are captured, but those actor/content-specific checks remain **PARTIAL**.
- This Codex session has no Computer Use/editor-inspector control. `runtime_layer_samples.tsv` is a programmatic Main runtime equivalent of Remote Scene Tree/Inspector data, but no Godot editor Remote-dock screenshot is claimed. The final L3 checklist must retain that UI-only evidence item as **PARTIAL** until it is captured manually.
- This folder is L2 evidence, not the final L3 acceptance report.
