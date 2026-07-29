# Chapter III Structural Rework — R2 Implementation

Status: R2 implemented. R3 is now complete in the separate layer/collision report; R4–R5 remain pending.

## Runtime result

Chapter III now starts from `scenes/level/chapter_03_route.tscn`. The route owns one persistent `ChapterRuntime` (Player, respawn controller and HUD), one `RoomHost`, one chapter-local transition controller and one active room at a time. The old `12784×720` prototype canvas remains in the repository for pre-R2 regression tests but is no longer referenced by `ChapterRegistry` or the Chapter III start profile.

Implemented formal route in R2:

`CH3_CHAPEL_VESTIBULE → CH3_NAVE_ENTRY → CH3_CHOIR_GALLERY → CH3_BOSS_CHECKPOINT → CH3_BOSS_ANTE`

The pre-existing Sanctum, post-Boss reliquary and underkeep modules are independently loadable through room wrappers for Debug starts. The final E-confirmed Boss gate, Boss intro ownership and post-Boss progression remain R4 work; the R2 normal route therefore stops safely at the closed gate instead of fabricating a partial Boss transition.

## New formal assets

All R2 art is original, generated at source resolution with Godot `Image` and saved below the chapter folder:

- `assets/environment/structural_r2/`: four room backdrops, the physical vestibule stair and four platform widths.
- `assets/doors/structural_r2/`: mirror-back entry, nave iron door, choir screen and vestry door.
- `assets/props/structural_r2/`: mourner bench, thirteen-bell font/emblem, votive lectern, choir seat, distant organ pipes and organ case.

The Nave and Choir are not recolors of a single canvas. They use different room dimensions, prop silhouettes, encounter lanes and platform purposes. Organ pipes and case are separate assets so R3 can finalize their z contract without repainting them.

## Room and transition contract

| Room | Size | Spawn | Exit |
|---|---:|---:|---|
| Chapel Vestibule | 2048×720 | (160, 584) | E raises the nave door; player walks the 512 px physical stair into a local Fade |
| Processional Nave | 2304×720 | (128, 584) | E opens the choir screen and Fades |
| Broken Choir Gallery | 2432×720 | (128, 584) | E opens the vestry door and Fades |
| Last Vigil Checkpoint | 896×720 | (128, 584) | E opens the confession door and Fades |
| Thirteen Confessions | 1664×720 | (160, 584) | closed formal Boss gate; R4 owns final interaction |

The Fade swap locks Player input, preserves the same Player/HUD instances, unloads the previous room, loads exactly one destination room, relocates the persistent respawn anchor, updates camera limits and restores input. It does not call the global scene transition service because these are local Chapter III rooms.

## Traversal and encounters

- Nave uses 160/160/96/144 px surfaces at planned floor-top heights 552/552/492/432.
- Choir uses 192/192/96/160 px surfaces at the same 60 px rise cadence.
- Visual platform tops and collision tops are aligned to the R1 coordinates. The 60 px ordinary route remains below the measured 62.83 px conservative vertical limit.
- Nave hosts Bellchain Penitent, Confessional Wraith and a high-ledge Thirteenth Scribe. Choir hosts Censer Executioner, Silent Chorister and Stained Glass Seraph. The continuous floor remains the critical path; platforms provide readable optional pressure lanes.

## Main integration

- `ChapterRegistry.CHAPTER_03_SCENE_PATH` and `chapter_03_start_profile.tres` both target `chapter_03_route.tscn`.
- Chapter II continues to transition through the registry/profile contract, so its handoff now lands in the formal vestibule without a hardcoded legacy path.
- Debug spawns map to the appropriate independent room; new room ids `CH3_CHAPEL_VESTIBULE`, `CH3_NAVE_ENTRY`, `CH3_CHOIR_GALLERY` and `CH3_BOSS_CHECKPOINT` are registered.

## QA evidence

- `docs/qa/chapter_03_r2_vestibule_main.png`
- `docs/qa/chapter_03_r2_nave_main.png`
- `docs/qa/chapter_03_r2_choir_main.png`

The capture route was entered through `main_bootstrap.tscn` with Chapter III Debug Start, not by F6-loading room scenes.

## Pending by approved stage boundary

- R3: complete; see `chapter_03_structural_rework_r3_layer_collision_report.md`.
- R4: Boss checkpoint semantics, E-confirmed gate performance, Boss intro, Boss exit and post-Boss route.
- R5: full Chapter II→III→Boss→Chapter IV regression and forced visual acceptance.

R2 does not claim those stages are complete.
