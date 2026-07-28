# Development Log

## 2026-07-28 — Chapter III Phase 2B–2F enemy implementation

Status: complete — all six Chapter III normal enemies are saved, Main-accessible and verified; manual combat-feel review remains

### Goal, planned files, tests, and scope check

- Continue from the committed Bellchain Penitent Phase 2A baseline and implement, in order, Censer Executioner, Silent Chorister, Stained Glass Seraph, Confessional Wraith and Thirteenth Scribe. Each role must receive original 64×64 pixel animation assets, concentrated typed tuning, a saved independently instantiable scene, distinct AI/action contracts, Poise, Health/Hitbox/Hurtbox integration and death cleanup.
- Reuse the committed Chapter III Poise component and shared combat contracts. Add only narrow Chapter III projectile, timed-area and temporary-player-modifier support required by the approved enemy designs; do not duplicate Player Health or damage settlement and do not alter Ravenfang/Player balance.
- Extend the Chapter III entry prototype so all six roles are directly reachable through the configured Main/Bootstrap debug route. Add a six-enemy combination test room and focused deterministic tests for saved values, animation families, action phases, projectile/world collision, single-hit ledgers, support-field non-stacking and cleanup.
- Generate all enemy art locally through Godot Image APIs. No external/downloaded/commercial/AI-generated asset is authorized. The Chapter III entry remains an enemy acceptance prototype rather than a claim of final Chapter III environment art.
- Verify with the exact Godot 4.7.1 executable: deterministic generation and import, independent scene smoke tests, focused role and damage tests, combination room, Bootstrap/Main debug route, formal F5 smoke, graphical QA evidence, ordered regression, `git diff --check`, and an isolated staged-tree check.

### Read-only findings and scope boundary

- Preflight is `master` at `8ca0a80` with Phase 2A committed. Existing Chapter I/shared tuning, QA-image and generated UID changes remain user-owned, out of scope and must not be staged.
- Bellchain Penitent already establishes the Chapter III scene/config/Poise/loot conventions and is the first of six. The remaining roles need distinct locomotion and attack contracts; they will share only bounded infrastructure, not one copied enemy script per role.
- Authorized: five remaining enemy prototypes, their original assets/animations/configs/scenes/AI, Chapter III-local projectiles/hazards/modifiers, one combination test room, Main acceptance instances, tests, QA evidence and current Chapter III documentation.
- Not authorized: Chapter III Boss, formal encounter progression, final chapter environment, new Player abilities, weapon/stat rebalance, Chapter I/II changes, loot-table redesign or unrelated refactors.

### Delivered implementation

- Completed the roster in the approved order: Bellchain Penitent (existing Phase 2A), Censer Executioner, Silent Chorister, Stained-Glass Seraph, Confessional Wraith and Thirteenth Scribe. The five new roles add 345 locally authored transparent 64×64 frames and five saved SpriteFrames resources; all six retain the Phase 1 signature objects at 48 px readability scale.
- Added one typed `Chapter03SpecialistConfig` and one bounded role-driven controller rather than cloning five scripts. The configs preserve distinct HP/Poise/action names/timing: Executioner heavy sweep/crush/smoke, Chorister wave/hymn/Hush, Seraph shared-ledger volley/dive/shatter, Wraith hidden reveal/slash/dash/scream, and Scribe lance/Binding/Seal/Paper Ward.
- Added Chapter III-local world-blocked projectile and timed-field scenes. Seraph shards explicitly share one target ledger, smoke uses bounded timed ticks, Hush keys a nonstacking stamina-regeneration modifier, Binding keys a temporary movement modifier, and owner death clears live fields. Base Player speed, jump, gravity, Dash, stamina rates and 14/28 weapon damage remain unchanged.
- Every new enemy composes existing Health, Hurtbox, two Hitboxes, Chapter III Poise and LootDrop contracts and has a chapter-local tuning and loot Resource. No second Health/damage source or global gameplay singleton was introduced.
- Expanded the Chapter III entry acceptance prototype and start profile to 4200 px with separated Phase2A, Phase2B, Phase2CDE and Phase2F encounter groups plus `CH3_BELLCHAIN_TEST`, `CH3_EXECUTIONER_TEST`, `CH3_CHOIR_TEST` and `CH3_SCRIBE_TEST`. Added `chapter_03_enemy_combination_test_room.tscn` with one instance of each role. This is enemy acceptance content, not the formal Chapter III map or final Encounter distribution.

### Verification and QA evidence

- Exact engine: `/Users/vincentz/Downloads/Godot.app/Contents/MacOS/Godot --version` → `4.7.1.stable.official.a13da4feb`.
- Asset generation/import: `CH3 PHASE2B-2F ASSETS | PASS roles=5 frames=345`; SpriteFrames `PASS roles=5 frames=345`; saved scenes `PASS roles=5`; headless editor import exited 0 without parser/resource errors.
- Focused tests: Chapter III concept assets PASS (12); Bellchain Phase 2A PASS (70 frames); full roster PASS (`roles=6 remaining_frames=345 main=6 combination_room=1`); Hitbox/Hurtbox dedup PASS; continuous Dash/stamina PASS.
- Runtime stability: both the six-enemy combination room and Chapter III Main acceptance scene ran for 600 frames headlessly (`CH3_LONG_SMOKE: PASS combination=600 main=600`). MainBootstrap graphical capture printed `DEBUG CHAPTER START ACTIVE` and `CH3_PHASE2_MAIN_QA: PASS captures=5`.
- Full deterministic suite: 62 scripts executed; 61 passed on the first ordered run. `test_player_death_presentation.gd` produced one load-sensitive early-completion failure, then passed independently three consecutive times and also passes on the untouched `HEAD` baseline. Nine older Chapter II/Main tests emit shutdown-only Resource/RID diagnostics while returning PASS; the floor-transition test reproduces the identical 47 ObjectDB/30 Resource/2 Shape/4 texture diagnostic set in an isolated `git archive HEAD`, so it is recorded as pre-existing cleanup debt rather than this milestone's regression.
- QA screenshots: `docs/qa/chapter_03_enemy_phase_02/01_censer_executioner_overhead_main.png` through `05_thirteenth_scribe_seal_main.png`, all 1280×720 and captured from the actual Bootstrap-routed Chapter III scene.
- Isolated staged tree `/tmp/nocturne-ch3-phase2.iY1sSC`: exact-engine import exit 0, roster test PASS and shared Hitbox/Hurtbox regression PASS with no red diagnostics. The staged file list contains zero Chapter I/shared tuning paths, proving the commit does not depend on preserved user-owned worktree changes.

### Known limits and manual acceptance

- The current Chapter III entry remains a deliberately simple enemy acceptance prototype. Formal chapel environments, the Phase 3 station-based Trial Hall, the planned 44-enemy Encounter distribution, Boss, audio and final combat VFX are not claimed.
- Automated verification proves saved values, frames, collision/dedup contracts, Main composition and long-run stability; visual timing, target-priority fairness, smoke/Hush/Seal legibility and six-role combination pressure still require the user's manual review.

## 2026-07-27 — Chapter II Phase 2 enemy prototypes (preflight)

Status: complete — Phase 2 implementation, Main integration and automated/graphical verification passed; manual combat-feel acceptance pending

### Goal, planned files, tests, and scope check

- Implement the five approved Chapter II enemy prototypes: Hollow Retainer, Court Halberdier, Mourning Armor, Blood-Candle Acolyte and Hanging Stalker. Each prototype will have original locally generated 64×64 pixel assets, typed tuning, an independently instantiable scene, reusable Health/Hitbox/Hurtbox composition and a bounded AI/state contract matching the approved roster.
- Add one Chapter II prototype test room and focused deterministic tests for saved resources, required animations, combat values, state boundaries, frontal Mourning Armor mitigation/Poise, Acolyte projectile/support behavior and the Stalker's telegraphed direction-locked drop.
- Keep configured F5 authority at `res://scenes/bootstrap/main_bootstrap.tscn`. To make the approved prototypes directly testable without beginning formal encounter population, add exactly one clearly named showcase instance of each role to the existing composed `SilentCourt` level. These are prototype acceptance instances, not EncounterGroups and not the planned 34-enemy roster.
- Planned changes are confined to Chapter II enemy assets/resources/scripts/scenes/tests, the Chapter II level showcase references, Chapter II roster/implementation documentation, README, QA evidence and this log. Shared combat code, Player/weapon tuning, Chapter I content and existing user-owned dirty files are out of scope.
- Verify with the exact Godot 4.7.1 executable: deterministic asset generation, import/parse, every enemy scene independently, the prototype room, focused Phase 2 tests, updated Chapter II/Main integration, configured formal F5 smoke, graphical Debug Chapter II evidence, the ordered full regression suite, `git diff --check`, and an isolated staged-tree check.

### Read-only findings

- Preflight is `master` at `f71603606414b85183c62193828ac49ef3728700`. The worktree already contains user-owned Chapter I tuning/scene/QA changes, shared returning-enemy resource changes and generated UID files; all are preserved and will be excluded from the Phase 2 commit.
- Phase 1 leaves the nine-room `SilentCourt` composition authoritative with one shared Player/HUD and zero enemies. Its 15 encounter anchors and 30 spawn markers remain inert; Phase 2 will not activate them or author encounter progression.
- Shared typed contracts already exist for `EnemyCombatant`, `GroundEnemyBase`, `HealthComponent`, `HitboxComponent`, `HurtboxComponent` and collision factions. Phase 2 can compose these rather than duplicate Health or damage settlement. Four grounded roles can share one narrow Chapter II behavior/config implementation; Hanging Stalker requires a separate ceiling-ambush controller.
- Ravenfang remains authoritative at Normal 12 / Dash Attack 24. Phase 2 will not change Player Health, movement, actions, weapon damage, Chapter I enemies, loot balance, Bootstrap routing or room geometry.

### Scope boundary

- Authorized: five prototype roles, their original assets/animations/data/scenes/AI, one projectile/ember pair required by the Acolyte, one independent prototype room, focused tests, one-per-role Chapter II showcase instances, QA evidence and documentation.
- Not authorized: formal E01–E15 population or activation, the planned 34-enemy distribution, returning-enemy placement, Hollow Duchess, Boss arena logic, narrative/doors/checkpoints/shop activation, final environment art, Chapter III, Player tuning or unrelated refactors.

### Delivered implementation

- Added five independently instantiable enemy scenes with concentrated typed Resources. Hollow Retainer delivers single stab/two-hit combo/retreat cadence; Court Halberdier chooses thrust, sweep or close shaft push and uses a 0.32-second Turn; Mourning Armor has 25% frontal Normal mitigation, full rear damage and four-point Poise with enhanced Dash impact; Blood-Candle Acolyte releases an 8-damage straight projectile, a one-hit 4-damage ground ember and at most one non-stacking 0.90 windup ally buff; Hanging Stalker uses a 0.55-second shadow telegraph, locked drop, guaranteed miss recovery, at most one claw and anchor return.
- Four grounded roles share one Chapter II behavior/config layer over `GroundEnemyBase`; Hanging Stalker keeps its distinct `EnemyCombatant` ceiling controller. Every role composes the existing Health, Hurtbox, Hitbox, faction, attack-ID dedup and LootDrop responsibilities. No Player, Ravenfang, shared combat component or Chapter I runtime file changed.
- Added five editable original concept SVGs, 184 transparent 64×64 PNG animation frames generated deterministically through Godot Image APIs and five nearest-neighbor SpriteFrames Resources. No external/downloaded/AI image or paid service was used.
- Added the Blood-Candle projectile/ember scenes, one combined `phase_2_enemy_prototype_room.tscn`, two focused test scripts and a Main/Bootstrap graphical capture runner.
- Added exactly one acceptance instance per new role under `SilentCourt/Phase2EnemyPrototypeShowcase`, at Grey Banner, Banquet, Gallery and Chapel locations. The existing 15 encounter anchors and 30 spawn markers remain inert; no EncounterGroup, planned 34-enemy population, returning enemy or Boss was added.

### Verification commands and actual results

1. Asset generation and import:
   - `Godot --headless --path . --script .../generate_phase_2_enemy_assets.gd`: `CH2_PHASE2_ASSET_GENERATOR: PASS enemies=5`.
   - `Godot --headless --path . --script .../build_phase_2_sprite_frames.gd`: `CH2_PHASE2_SPRITE_FRAMES: PASS resources=5`.
   - `Godot --headless --editor --path . --import --quit`: exit 0 on exact `4.7.1.stable.official.a13da4feb`; no parser, missing-resource, invalid-UID, warning or import error.
2. Focused contracts:
   - `test_phase_2_enemy_prototypes.gd`: PASS for five scenes, 184 original 64×64 source frames, required animations, exact HP/primary values, Retainer bounded Recovery, Mourning Armor front 12→9/rear 12, Acolyte projectile and non-stacking buff, and Stalker direction lock.
   - `test_phase_2_enemy_damage.gd`: `PASS damages=7/5,10/6,14/9,8/4,9/6 dedup=ok`.
   - `test_silent_court_graybox.gd`: PASS for nine rooms, six debug spawns, fifteen inert encounter anchors, one Player/HUD and exactly five named prototype showcase instances.
   - All five independent enemy scenes and `phase_2_enemy_prototype_room.tscn` started headlessly without red diagnostics.
3. Main/Bootstrap and graphics:
   - `Godot --path . --script .../capture_phase_2_enemy_qa.gd`: `CH2_PHASE2_MAIN_QA: PASS captures=5`; Output proved legal `DEBUG CHAPTER START ACTIVE` routed MainBootstrap to the production Silent Court scene. The live screenshots include real AI attacks and resulting Player HP changes.
   - `Godot --path . --quit-after 240`: exit 0 and printed `MAIN BOOTSTRAP | FORMAL NEW GAME | res://scenes/cinematics/opening_cinematic.tscn`, so formal F5 remains Opening-first.
4. Regression and hygiene:
   - Ordered exact-engine execution of all project/chapter SceneTree tests: `FULL_SUITE tests=49 failed=0`; all 49 logs contain no `SCRIPT ERROR`, `ERROR:` or `WARNING:`.
   - `git diff --check`: PASS.
   - Isolated staged implementation tree `/tmp/nocturne_phase2.ofxoiy`: exact-engine import exit 0; Phase 2 prototype, exact-damage/dedup and composed Silent Court tests all PASS. This proves the milestone does not depend on preserved unstaged Chapter I/shared-resource changes.

### Known limitations and manual acceptance

- Phase 2 art is production-oriented prototype pixel art, not final environment-matched animation polish. Audio, particles and final combat VFX remain deferred.
- The five Main instances are intentionally spaced one per role for acceptance. They do not use encounter activation and must be replaced, not multiplied, when a separately approved Phase 3 authors E01–E15.
- Human playtesting must still judge Retainer combo reaction time, Halberdier rear window, Mourning Armor Poise feel, Acolyte priority pressure and Stalker shadow readability. Automated results prove contracts and persistence, not subjective fairness.
- Hollow Duchess, full encounter population, returning enemies, narrative/door/checkpoint/shop runtime and Chapter III remain unstarted.

## 2026-07-27 — Chapter II vertical graybox and traversal refinement (preflight)

Status: complete — Phase 1 vertical graybox, Main integration, physical traversal and regression passed; manual feel acceptance pending

### Goal, planned files, tests, and scope check

- Refine the nine existing `Chapter II: The Silent Court` rooms into a readable multi-level graybox: visible collision-backed platforms, broad stair/ramp routes, two- and three-tier spaces, safe rejoin paths, and a deliberately flat ballroom combat lane.
- Keep the existing composed Chapter II scene and Bootstrap/Main startup chain authoritative. Regenerated room scenes must be the same PackedScenes instanced by `res://chapters/chapter_02_silent_court/scenes/level/silent_court.tscn`; formal Chapter I → Chapter II routing and Debug Chapter Start remain unchanged.
- Planned runtime changes are limited to the Chapter II room graybox renderer, its deterministic room builder, and the nine generated Chapter II room scenes. Planned support changes are limited to Chapter II traversal tests/QA evidence, environment concept documentation, current Chapter II design documents, README and this log.
- Verify with the exact Godot 4.7.1 executable: rebuild rooms, headless import/parse, focused Chapter II geometry/reachability and Bootstrap tests, full deterministic regression, graphical Bootstrap/Debug Chapter II run, screenshot inspection, `git diff --check`, and an isolated staged-tree check.
- Scope is Phase 1 terrain only. No enemy, encounter activation, Boss, combat tuning, door gameplay, player ability, HUD, Chapter I asset, or unrelated system change is authorized. Existing encounter/door/checkpoint markers remain anchors only.

### Read-only findings

- Preflight is `master` at `62ca018fa29b80ed93a53ace23f68066dff2da14`. The worktree already contains user-owned Chapter I tuning, scene, shared enemy, QA image and generated UID changes; these paths will be preserved and excluded from this milestone.
- Chapter II's composed level already instances all nine room PackedScenes at contiguous world positions and owns exactly one shared runtime Player/HUD. The room builder is the correct single source for collision geometry, while `Chapter02RoomGraybox` currently draws only the floor and two hard-coded ramp cases.
- Several existing upper-platform collisions are therefore visually invisible, and the banquet hall, gallery, armory and antechamber lack authored access routes. The chapel has vertically spaced platforms but no stairs; this does not yet satisfy a reliable, readable traversal contract.
- Existing measured movement supports approximately 83 px single-jump rise, 167 px double-jump rise and 321 px jump-plus-air-dash horizontal reach. Phase 1 keeps required tier rises at or below 120 px, uses broad landings, retains one continuous main traversal surface that rejoins y=612 before protected exits, and avoids mandatory precision gaps or one-way softlocks.

### Delivered implementation

- `Chapter02RoomGraybox` now exports typed `platform_rects` and `stair_polygons`. Its drawing code renders blocks, edge highlights and stair treads directly from those same arrays; the deterministic builder consumes the arrays to create matching `StaticBody2D` collisions. This removes the previous invisible-platform and hard-coded two-ramp split.
- Regenerated all nine existing room PackedScenes used by the composed `SilentCourt` level. Gate Interior has an arrival lookout; Grey Banner has a long upper corridor; Banquet has a continuous double-level route; Gallery has five optional air-route platforms; Chapel has a symmetric three-tier stair; Servant Passage rises and descends; Armory has a safe mezzanine; Antechamber returns to a 588 px clear Boss buffer; Ballroom remains flat.
- All platform widths are at least 192 px and all distinct adjacent tier heights differ by at most 120 px. Full-solid stairs have broad ascents/descents and no one-way traps. Existing room boundaries, shared Player/HUD, camera limits, door/checkpoint/narrative anchors and 15 future encounter anchors remain composed but inert.
- Physical traversal exposed two genuine left-edge collision walls in Grey Banner and Banquet. Both were redesigned into continuous staged slopes and re-tested from the beginning. `CH2_ARMORY` and CP04 were also moved from the new stair volume to clear floor; all six Debug selectors now spawn at their exact markers.
- Added an original editable environment layout board at `res://chapters/chapter_02_silent_court/assets/environment/concept_art/silent_court_vertical_graybox.svg`, a Bootstrap-based graphical QA capture script, six representative Main screenshots, and refreshed nine-room sequential traversal captures. No external asset or paid service was used.

### Verification commands and actual results

1. Deterministic room generation and focused contract:
   - `Godot --headless --path . --script chapters/chapter_02_silent_court/scripts/tools/build_silent_court_graybox.gd`: `SILENT_COURT_ROOM_BUILDER: PASS rooms=9`.
   - `Godot --headless --path . --script chapters/chapter_02_silent_court/tests/test_silent_court_graybox.gd`: PASS for nine rooms, expected platform/stair counts, collision parity, maximum 120 px tier rise, flat Ballroom, six Debug spawns, fifteen future encounter anchors, one Player/HUD and zero enemies.
2. Final physical route:
   - `Godot --path . chapters/chapter_02_silent_court/scenes/level/silent_court.tscn -- --recapture-ch2-graybox-fast`: `CH2_GRAYBOX_F5_TRAVERSAL: PASS duration=146.02s screenshots=9` after crossing all eight room joints through Player physics. Ground Dash, double jump and Air Dash were exercised; no coordinate teleport is used by this traversal runner.
3. Configured Main/Bootstrap graphical QA:
   - `Godot --path . --script chapters/chapter_02_silent_court/scripts/tools/capture_chapter_02_vertical_qa.gd`: `CH2_VERTICAL_MAIN_QA: PASS captures=6`; Output confirmed the legal Debug Chapter Start selected the production Silent Court scene.
   - `Godot --path . --quit-after 240`: exit 0 on GL Compatibility / Apple M4 and printed `MAIN BOOTSTRAP | FORMAL NEW GAME | res://scenes/cinematics/opening_cinematic.tscn`, proving formal F5 remains Opening-first.
4. Regression and hygiene:
   - `Godot --headless --editor --path . --import --quit`: exit 0 on exact Godot `4.7.1.stable.official.a13da4feb`; no parser, missing-resource, invalid-UID or import error.
	- Ordered project and chapter SceneTree regression: `FULL_SUITE tests=47 failed=0`.
	- `git diff --check`: PASS. QA commands and hashes are preserved in `res://docs/qa/chapter_02_vertical_graybox/phase_1_vertical_graybox_report.md`.
	- Isolated staged implementation tree `7198722f1f593c73f0fa87261b6b6064ebf026a3`: exact-engine import exit 0 and focused Silent Court contract PASS, proving the milestone does not rely on preserved unstaged Chapter I/shared-resource changes.

### Known limitations and manual acceptance

- The new geometry is deliberately graybox: stair faces use visual tread marks over broad polygon slopes, not final tiles, props or environment lighting.
- Automated and physical tests prove collision continuity and movement-envelope compliance; a human should still judge optional Gallery jump comfort, camera composition on the Chapel top tier and whether each upper route feels rewarding.
- Enemy scenes, encounter activation/population, Hollow Duchess, combat gates, functional checkpoint activation and final environment art remain absent. Phase 2 must not start without explicit approval.

## 2026-07-27 — Main / Bootstrap formal startup routing repair (preflight)

Status: complete — Bootstrap routing, formal/Debug separation, regression and graphical QA passed; full-length pacing acceptance remains manual

### Goal, files, tests, and scope

- Replace the conflicting `OpeningCinematic`-as-main plus Autoload redirect sequence with one explicit Main/Bootstrap authority. Formal F5 must select Opening first; Debug Chapter Start may bypass it only when its debug-build gate and enable flag both pass.
- Planned runtime changes are limited to `project.godot`, a new Bootstrap scene/script, the existing narrow ChapterStartRouter/DebugRunConfig, and the Chapter I/II debug-profile guards. Opening content, Catacomb dialogue, chapter gameplay, enemies, Bosses, weapons, tuning, art and migration layout remain out of scope.
- Update startup contract tests and current README/chapter/debug specifications. Add three rendered QA checkpoints for Bootstrap → Opening, Opening → Veilbound Catacomb, and Bootstrap debug route → Chapter II.
- Verify with the exact Godot 4.7.1 executable: import/parse, focused startup/transition tests, the complete SceneTree test suite, configured graphical F5 smoke, QA capture, runtime-path audit and `git diff --check`. Create one isolated commit without staging the pre-existing user-owned tuning, scene, QA image or generated UID changes.

### Read-only findings

- Preflight is `master` at `62a972895a03518c55c0bd4f8391d9063b557d26`, four commits ahead of `origin/master`, with the existing modified/untracked gameplay, tuning, QA and UID paths preserved.
- `project.godot` incorrectly uses `res://scenes/cinematics/opening_cinematic.tscn` itself as `run/main_scene`. `/root/ChapterStartRouter` then runs an Autoload `_ready()` side effect and immediately replaces that Opening whenever the debug flag is enabled; `DebugRunConfig.debug_chapter_start_enabled` currently defaults to `true`. This is the direct cause of the missing formal Opening.
- Opening and Catacomb paths are loadable and were not moved by the Chapter I migration. Opening uses `ShotTimer` plus Tweens, not an `AnimationPlayer`; its guarded `finish_cinematic()` already unifies natural completion and 0.75-second hold-to-skip, marks Opening complete once, and targets `res://scenes/levels/veilbound_catacomb.tscn`.
- No `SceneTransitionManager` exists. Current authored transitions consistently use `SceneTree.change_scene_to_file`; the repair will retain that single engine mechanism behind Bootstrap loading validation rather than introduce a second global transition subsystem.
- Chapter I and Chapter II scene controllers currently apply their selected debug profile by chapter ID alone. They do not also require `is_chapter_start_allowed()`, so a disabled Debug start can still apply disposable debug state after the formal Catacomb route. This is a second formal/debug separation defect within scope.

### Delivered implementation

- Added `res://scenes/bootstrap/main_bootstrap.tscn` and typed `MainBootstrap`. `project.godot` now points only at that formal entry. Bootstrap defers one startup decision, validates the selected PackedScene with `ResourceLoader`, initializes a formal or disposable Debug session, then uses `SceneTree.change_scene_to_packed` exactly once.
- Removed the Autoload redirect side effect from `ChapterStartRouter`. It now only resolves a valid debug-build `ChapterStartProfile`; disabled Debug, release builds and invalid profiles return no target and therefore fall through to Opening. A valid Debug route prints `DEBUG CHAPTER START ACTIVE | <chapter> | <path>`.
- Changed `DebugRunConfig.debug_chapter_start_enabled` and its reset default to `false`. Formal F5 therefore always selects Opening unless a developer explicitly enables a legal Debug profile. `run/main_scene` never needs to change for Chapter I or Chapter II work.
- Added runtime-only `ChapterSession.is_debug_run`, `begin_formal_new_game()` and `begin_debug_run()`. Formal Bootstrap clears all Prologue flags before Opening; Opening still marks completion only through its guarded natural/skip exit. Chapter I and Chapter II now require `is_chapter_start_allowed()` before applying disposable Debug spawn/state, preventing a disabled profile ID from contaminating the formal route.
- Preserved the existing Opening implementation and content. It has no `AnimationPlayer`; `OpeningCinematic/ShotTimer`, an eight-shot `OpeningCinematicTimeline`, and Tweens drive playback. Natural completion and the existing 1.5-second unlock plus 0.75-second ESC/Enter hold continue through the same `_finishing`-guarded exit to Veilbound Catacomb.
- Updated current startup tests, asset-isolation validators, README, chapter/debug specifications and the Opening narrative path note. No invalid migrated Opening/Catacomb runtime path existed, so zero runtime old-path replacements were necessary; the actual repair changed the single F5 entry and startup ownership instead.

### Verification commands and actual results

1. Exact engine import/parse:
   - `/Users/vincentz/Downloads/Godot.app/Contents/MacOS/Godot --headless --editor --path . --import --quit`: exit 0 on `4.7.1.stable.official.a13da4feb`; Bootstrap, Router, session and chapter scripts registered without parser, missing-resource, invalid-UID or null-PackedScene errors.
2. Focused startup contracts:
   - `tests/systems/test_chapter_start_foundation.gd`: PASS for seven registry entries, formal Bootstrap entry, disabled Debug default and debug/release gate.
   - `tests/systems/test_main_bootstrap_flow.gd`: PASS for real Bootstrap → Opening, accelerated natural eight-shot completion → Veilbound Catacomb, formal flag reset, and Debug Bootstrap → Chapter II. Output included the required Debug-active diagnostic.
   - `tests/level/test_veilbound_scene_transitions.gd`: PASS for the existing legal Opening skip → Catacomb skip → Chapter I route and all four ChapterSession progress flags.
   - `tests/level/test_veilbound_catacomb_flow.gd`, Chapter I flow/profile tests, and Chapter II graybox test: PASS.
3. Full deterministic regression:
   - Ordered run of 46 `tests/` and chapter-owned test scripts: `FULL_SUITE tests=46 failed=0`.
   - `tests/player/measure_player_level_metrics.gd` verified separately: PASS with unchanged movement metrics. Total verified SceneTree scripts: 47.
   - The first regression pass correctly exposed that the Chapter I start-profile fixture no longer explicitly enabled Debug routing; the fixture was fixed to exercise the new gate, then passed. No gameplay behavior was changed to satisfy it.
4. Configured graphical F5-equivalent smoke:
   - `Godot --path . --quit-after 240`: exit 0 on GL Compatibility / Apple M4; Output printed `MAIN BOOTSTRAP | FORMAL NEW GAME | res://scenes/cinematics/opening_cinematic.tscn`, and no red diagnostic appeared.
5. Graphical production-route QA:
   - `Godot --path . --script scripts/tools/capture_main_bootstrap_qa.gd`: exit 0 and `MAIN_BOOTSTRAP_QA: PASS`.
   - Evidence under `docs/qa/main_bootstrap_startup/`: `formal_01_opening_cinematic.png`, `formal_02_veilbound_catacomb.png`, and `debug_03_chapter_02_silent_court.png`. Direct inspection confirmed visible Opening subtitles/art, Catacomb arrival, and a single Player/HUD in Chapter II.
6. Hygiene:
   - Runtime search found no live `res://scenes/main/main.tscn`, planned `res://chapters/prologue` reference, or old Opening-as-`run/main_scene` setting outside historical documentation.
   - `git diff --check`: PASS after removing the new trailing whitespace.
   - Isolated staged tree `4f68f6a1c473f06bda98847d719a0d8daeba26b1`: exact-engine import exit 0 and all seven focused Bootstrap/Opening/Catacomb/Chapter I/Chapter II contracts passed, proving the commit does not rely on the preserved unstaged gameplay changes.

### Known limitations and manual acceptance

- The natural-completion contract uses the real timer/signal path with test-only accelerated shot durations; the graphical F5 smoke and QA capture verify presentation/start and legal skip. A human should still watch the full authored 70.2-second pacing once and complete the full Catacomb interaction sequence.
- There is no `SceneTransitionManager` node or script to report. This milestone intentionally retains the project's existing SceneTree transition mechanism rather than invent a parallel manager.
- Existing user-owned tuning, Chapter I scene serialization, QA images and generated UID changes remain outside this isolated startup commit and are not staged.

## 2026-07-26 — Chapter folder reorganization Stage 0 audit and migration plan

Status: complete — audit, path manifest and pre-migration verification delivered; no runtime file moved or modified

### Goal and scope

- Audit the current Prologue, Chapter I and shared ownership boundaries before any path change.
- Record the full F5 chain, Autoloads, PackedScene composition, hard-coded paths, UIDs/import sidecars, instance overrides, duplicates and working-tree risks.
- Add `docs/migration/chapter_folder_reorganization_plan.md` and `docs/migration/chapter_01_path_manifest.md` as the sole Stage 1 execution contract.
- Scope is documentation only. No `.gd`, `.tscn`, `.tres`, asset, `project.godot`, input, flow, scene, tuning or gameplay change is authorized in Stage 0.

### Read-only findings

- Created branch `chore/chapter-folder-reorganization` from `c934ed0`. The worktree already contained 20 user-owned modified/untracked paths, including Main, Enemy/Boss/Player resources, seven QA captures and two generated `.uid` files; they were preserved and excluded from this milestone.
- Configured flow is `res://scenes/cinematics/opening_cinematic.tscn` → `res://scenes/levels/veilbound_catacomb.tscn` → `res://scenes/main/main.tscn` → `res://scenes/transitions/ravenmourn_threshold.tscn`.
- `project.godot` has four Autoloads: `ChapterSession`, `CurrencyManager`, `WeaponInventory` and `EquipmentManager`. Stage 1 will keep their current neutral paths and update only moved target strings.
- Current inventory is 26 scenes, 177 GDScript files, 34 Resources, 568 PNGs, 177 `.gd.uid` sidecars and 451 source `.import` sidecars. The repository contains 911 `res://` references, including 141 GDScript preloads, 12 loads, 5 scene-change calls, 587 external Resource declarations and 25 PackedScene references.
- No inherited-scene root or runtime absolute local path was found. Most scenes have no saved scene UID, so textual paths remain authoritative. Main's Boss bridge bounds and authored encounter transforms are important local instance overrides that must survive the move.
- All five normal enemies are classified shared because Chapter II is expected to reuse four of them and all five share the same reusable combat/configuration stack. Player, combat, HUD, items and Autoload systems remain at their current neutral paths in Stage 1 to avoid unrelated churn.
- Byte-identical animation/reference frames exist by design in Player, Shield Guard, Crossbow/Spear, Gargoyle and Boss assets. The migration will not delete or deduplicate them.

### Verification commands and actual results

1. `/Users/vincentz/Downloads/Godot.app/Contents/MacOS/Godot --headless --editor --path . --import --quit`
   - Exit 0 on Godot `4.7.1.stable.official.a13da4feb`; no parser or missing-resource error.
2. Focused tests:
   - `tests/level/test_chapter_one_flow.gd`: PASS.
   - `tests/level/test_veilbound_catacomb_flow.gd`: PASS.
   - `tests/level/test_veilbound_scene_transitions.gd`: PASS with real Opening → Catacomb → Main changes.
   - `tests/combat/test_first_level_boss.gd`: PASS.
3. Ordered execution of every `tests/**/*.gd` SceneTree test with the exact engine: `FULL_SUITE tests=43 failed=0`.
   - The first shell harness attempt exited before the suite because zsh reserves `status`; the corrected harness used `test_exit`, after which all project tests passed. This was not a Godot error.
4. Configured graphical startup: `Godot --path . --quit-after 300`: exit 0 on GL Compatibility / Apple M4; no red diagnostics.
5. Direct Chapter I smoke: `Godot --path . --quit-after 600 res://scenes/main/main.tscn`: exit 0; no red diagnostics.

### Delivered documentation and next gate

- The migration plan records the current/target trees, ownership decisions, 10-risk register, reference mechanisms, leaf-to-root move order, rollback constraints and Stage 1 acceptance gates.
- The manifest maps Prologue, Chapter I, shared enemy, retained shared/system and uncertain paths, including their reference sites and move decisions.
- Stage 1 must not start until the overlapping pre-existing worktree changes have a recoverable, user-approved snapshot. It must use path-only moves/edits, preserve `.uid`/`.import` sidecars and Inspector overrides, then prove zero old runtime references and rerun the full baseline.


## 2026-07-24 — Veilbound Catacomb revival sequence (preflight)

Status: complete — implementation, 39-script regression, real scene transitions, graphical QA and F5 startup passed; manual pacing/visual acceptance pending

### Read-only findings

- Git preflight: clean `master` at `7e3efaf feat: add Chapter I opening tutorial and encounters`, synchronized with `origin/master`.
- `project.godot` configures F5 as `res://scenes/cinematics/opening_cinematic.tscn`; the Opening controller currently fades directly to `res://scenes/main/main.tscn` on both natural completion and skip.
- Main is `res://scenes/main/main.tscn`. Its current Player and fixed respawn marker both begin at `(320, 612)` under `Main/World`; this is the authored Dark Forest tutorial entrance and will be named explicitly as `Main/World/DarkForestTutorialSpawn` while preserving the same position.
- The existing Chapter I tutorial is scene-local and event-driven (`Main/TutorialController`), starts immediately in Main, and owns the small bilingual tutorial/location panel. Main also owns the signal-driven Health/Stamina HUD and compact Debug HUD.
- No general DialogueController, CutsceneController, objective controller, NPC base scene, or new-game session service exists. The only scene fades are the Opening controller and the castle-threshold transition. A narrow catacomb-local controller plus structured dialogue Resources is therefore the minimum compatible composition.
- Player gameplay input is read directly in `Player._physics_process()`. A narrow control-profile API is required so the catacomb can permit horizontal movement while blocking jump, Dash, Attack, Hurtbox combat, and double jump without changing any movement/combat tuning.
- The current later death flow is Player-local and checkpoint-driven. The new story revival must remain an independent one-shot scene and must not replace or call the combat respawn sequence.

### Goals, planned files, tests, and scope

- Add `veilbound_catacomb.tscn`, a typed catacomb controller, original native-2D catacomb art, a self-contained Candle Warden NPC, data-driven bilingual dialogue Resources, a small dialogue/objective UI, dagger pickup, optional observations, rune stone door, and explicit exit trigger.
- Redirect Opening to the catacomb. The catacomb will fade to Main only after revival/dialogue completion, dagger pickup, door opening, and voluntary Player entry. Main will expose `World/DarkForestTutorialSpawn`, retain the same forest start coordinates, and start the existing tutorial only after this scene load.
- Add deterministic tests for structured dialogue order/localization, natural/skip state completion, Player control gating, dagger/door prerequisites, the exit target, F5 route, and Main tutorial spawn. Run exact Godot 4.7.1 import/parse checks, repository regressions, configured startup, isolated scene startup, and graphical QA capture.
- Scope is limited to the Chapter I startup bridge. Player/Enemy/Boss Health, damage, counts, timings, encounters, forest/castle art direction, bridge, gate, and second-level content remain unchanged.

### Delivered implementation

- Redirected both natural and skipped Opening completion to `res://scenes/levels/veilbound_catacomb.tscn` while preserving `project.godot` F5 authority at the Opening scene. A runtime-only `ChapterSession` Autoload records opening, revival, dagger, exit and current Chapter objective flags across scene changes; it owns no gameplay or disk save.
- Added an independently instantiable 1600×720 Veilbound Catacomb with original native-2D cold-stone environment, broken sarcophagi, Veiled Order crest/remains, severed altar, blue soul fires, mist, soul particles, rune door and moonlit forest threshold. No enemy, Boss, Hitbox or encounter was added.
- Added a story-only `RevivalPlayerArt` presentation separate from combat death/respawn. It provides corpse, twitch, breath, sit, hands, kneel, stand, unarmed and descending-soul poses. A procedural low bell, silver-blue Soul Mark pulse and timed scene beats produce an approximately 68.9-second natural revival including dialogue.
- Added standalone `CandleWarden` scene/script with seated, rise, walk, idle, talk, lantern-raise and turn-away presentation. It contains no combat or follow AI.
- Added four aligned structured dialogue Resources: three-line protagonist monologue plus 27-line Candle Warden conversation in Chinese and English. Runtime validates speakers/lines/cues/durations, displays a bottom bilingual subtitle, supports automatic or Enter advance, and completes once on 0.75-second Escape/Enter hold skip.
- Added a narrow Player input profile boundary. The catacomb automatic sequence locks Player; completion enables horizontal movement only while jump, double jump, Attack and Dash remain disabled. Dagger pickup swaps the unarmed story art for the existing armed gameplay `VisualRoot`; no movement or combat tuning changed.
- Added E interaction for dagger recovery, five optional observations and the stone door. Story plus dagger prerequisites raise the Warden lantern, light runes, lift the door, disable its World collider on completion, and leave Player control active until voluntary exit.
- Exit fades for 0.55 seconds and loads unchanged Main. Renamed the initial Main marker to `Main/World/DarkForestTutorialSpawn` at the same `(320,612)` coordinate and bound PlayerRespawnController to it. The existing 11-step tutorial then starts normally. Main checkpoint death remains local and never reloads the catacomb.
- Added a small transient objective presentation and the current Chapter objective state without building a quest log. Added six 1280×720 F5-route QA captures covering corpse, soul descent, sit, Warden dialogue, open door and Dark Forest arrival.

### Commands and actual results

1. Exact engine import and parse:
   - `/Users/vincentz/Downloads/Godot.app/Contents/MacOS/Godot --headless --editor --path . --import --quit`: exit 0; new global classes/resources/autoload registered without parse or resource errors.
2. Focused startup/flow:
   - `Godot --headless --path . --script tests/level/test_veilbound_catacomb_flow.gd`: PASS for F5 route, all 30 bilingual entries, scene composition, no enemies, control lock/skip, dagger swap, door/collision and Main spawn.
   - `Godot --headless --path . --script tests/level/test_veilbound_scene_transitions.gd`: PASS using real SceneTree changes for Opening skip -> Catacomb skip -> Main tutorial, including all ChapterSession flags and no leak warning after timer cleanup.
   - `Godot --path . --quit-after 180`: exit 0 on GL Compatibility / Apple M4; configured F5 Opening launched without error or warning.
3. Full regression:
   - Sequential execution of all `tests/**/*.gd`: 39/39 PASS, 0 failures. Existing Player movement/action/stamina/Hurt/death/respawn, HUD, 34-enemy roster, platform routes, environment, Boss and gate tests remained green.
   - Stable movement metrics remained 153.59 px single-jump range, 281.92 px debug-double-jump range and 344.00 px four-Air-Dash action travel; no tuning value changed.
4. Graphical QA:
   - `Godot --path . --script scripts/tools/capture_veilbound_catacomb_qa.gd`: exit 0, `VEILBOUND_CATACOMB_QA: PASS`; saved six images under `docs/qa/veilbound_catacomb_*.png` and direct inspection confirmed sharp scene art, readable bottom subtitles and the open forest threshold.
5. Final hygiene:
   - `git diff --check`: PASS.

### Manual acceptance still required

- Play the natural approximately 68.9-second revival once and judge the pause rhythm, body-pose readability, lantern visibility and whether manual line advance feels responsive.
- Verify A/D-only control after dialogue, E priority near overlapping optional observations, the visual handoff from unarmed proxy to armed Player, and door collision timing at normal play speed.
- Confirm later Main death at every checkpoint keeps the current fast body/ghost respawn and never returns to the catacomb. This is covered automatically but still benefits from a full human F5 playthrough.

## Current authoritative status

- Last audited: 2026-07-24
- Implementation baseline before this revision: `master` at `b62b7a2 fix: rebalance first enemy roster`
- Engine verified in this audit: `4.7.1.stable.official.a13da4feb`

This section is the current project snapshot. The dated entries below are retained as historical records of what was planned, implemented, tested, and still awaiting approval at each point in time. A historical plan or an earlier test result is not, by itself, evidence that a later feature exists or still passes.

### Status vocabulary

- **Implemented and re-verified** — the referenced files exist and the current HEAD passed the listed automated check during the 2026-07-22 documentation audit.
- **Implemented; manual acceptance pending** — code/assets and automated coverage exist, but player feel or visual acceptance still requires a human playtest.
- **Placeholder** — a deliberately temporary asset or presentation exists and must not be treated as final content.
- **Planned / not implemented** — described by design or architecture documents but absent from the current runtime scene/code path.
- **Pending verification** — the repository contains related material, but this audit did not establish runtime acceptance.

### Current delivery matrix

| Area | Current status | Repository evidence |
| --- | --- | --- |
| M0 project baseline | Implemented and re-verified | `project.godot` targets Godot 4.7 GL Compatibility and `scenes/main/main.tscn`; current headless import and Main startup passed. |
| Pixel character concept tool | Implemented and re-verified | Runnable design lab, eleven concept PNGs, 1600×1000 board, generator scripts, and asset validator are present. |
| Player animation presentation | Implemented and re-verified | `AnimatedSprite2D`, `PlayerAnimationController`, a 16-animation `SpriteFrames` resource, production/reference assets, and preview tooling are present. `death` is a five-frame production body fall; `hurt` is now a three-frame, 16 FPS production recoil sequence. |
| M1 locomotion | Implemented and re-verified | `CharacterBody2D` movement, ground/air acceleration, gravity, jump, 0.10 s coyote time, 0.12 s jump buffer, Camera2D, facing, and six locomotion animations passed the current regression. |
| Debug double jump | Implemented for testing; formal unlock pending | `has_double_jump` defaults false, while `debug_enable_double_jump` defaults true in `Player`; no ability-unlock/session system exists. |
| M1.5 actions | Implemented and re-verified; manual feel approval pending | Four-frame Attack, Ground/Air Dash chains, Dash Attack, input buffers, collision-safe motion, stamina component/HUD, and configurable airborne regeneration passed current automated tests. Attack now drives one-damage and Dash Attack two-damage composed Hitboxes only on their approved frames. |
| Player Health HUD | Implemented and re-verified | `Main/HUD/HealthContainer` observes the composed Player `HealthComponent`, initializes without polling, displays current/maximum values, and supports explicit signal-safe rebinding. It does not own Health data or death behavior. |
| Player death state | Implemented and re-verified; manual visual acceptance pending | `Player` enters one explicit `LifeState.DEAD`, cancels action/input/Stamina processing, and delegates a five-frame flat-body fall plus detached daggers and hooded ghost rise/pause to `PlayerDeathSequence`. |
| Player respawn | Implemented and re-verified; single test spawn only | After the approximately 1.30-second presentation completes, Main's typed coordinator returns the same Player instance to one `Marker2D`, restores Health/Stamina and control state, hides the prompt, and retains Camera2D following. No checkpoint/session selection exists. |
| Combat foundation | Implemented minimum; manual feedback acceptance pending | Typed Health/Hitbox/Hurtbox responsibilities, named layers, faction/dedup rejection, Player 1/2-point attacks, and one five-point sword source are tested. Player non-lethal Hurt now cancels actions, uses source-derived collision-safe knockback, and grants a 0.50-second multi-source grace window. Attributes, armor, and game-over flow do not exist. |
| Enemies and boss | Four normal enemy prototypes implemented in Main; manual acceptance pending | Castle Guard plus Shield Guard, Spearman, and Crossbowman have original art, typed configs/scenes/AI, shared combat contracts, Hurt/Death, 9 staged Main instances, and mixed test-room coverage. Shield Guard now has a permanent frontal Dash shield break, 0.70-second GuardBreak, readable fragments/flash, and persistent unshielded actions. Flying, elite, and Boss enemies remain unimplemented. |
| Level and game flow | Mixed Main combat laboratory implemented; formal rooms planned | Main has floor, two platforms, walls, one respawn marker, Player/HUD, and nine mixed enemies in four one-shot groups (2/2/2/3). The planned three rooms, checkpoint selection, elite unlock, boss arena, victory flow, menu, and save/session state do not exist. |
| Export/release | Pending verification / not configured | No `export_presets.cfg` was found during the audit. |

### Current validation baseline

On 2026-07-24, the exact Godot 4.7.1 executable completed a fresh import, started the updated Shield Guard independently and configured Main, and passed all 28 repository test scripts without final `SCRIPT ERROR`, `ERROR:`, or `WARNING:` output. Coverage retains the Health/HUD/death/respawn/movement/action/assets/Hurt baseline plus all four enemy roles, centralized current balance, encounter activation, and Main Debug behavior. Shield-specific coverage now proves front Block, back damage, one-time frontal Dash break, 0.70-second state lock, permanent post-break vulnerability, unshielded action/death presentation, live Main instances, and truthful Debug fields. Main still records groups sized 2/2/2/3 with three Castle Guards, two Shield Guards, two Spearmen, and two Crossbowmen; Group01 is active and later groups are paused at startup.

The stable measured envelopes are 153.59 px single-jump horizontal range / 83.77 px rise, 281.92 px debug-double-jump range / 167.10 px rise, and 344.00 px of four-Air-Dash action travel. The total takeoff-to-landing Air-Dash measurement alternated between 360.33 px and 362.22 px across three consecutive audit runs; this approximately one-physics-frame variation is recorded as a test determinism issue rather than a changed movement parameter.

### Documentation responsibility

- `docs/development_log.md` is the single primary development record and current-status source.
- `README.md` accurately identifies the current build as an M1.5 prototype and links here.
- `docs/game_design.md` and `docs/technical_architecture.md` are M0-era target/baseline documents. Their combat, level, enemy, checkpoint, and flow descriptions are plans, not delivered functionality.
- `docs/known_issues.md` was last reviewed at M0 and is stale. It must not be used alone to assess the current build.
- No separate `PLAN.md`, `ROADMAP.md`, `PROJECT_PLAN.md`, `PROGRESS.md`, `WORKLOG.md`, or equivalent primary progress file was found. Creating a duplicate development log is therefore unnecessary.

### Open issues and improvement needs

1. Complete a manual Godot editor/playtest acceptance pass for the latest continuous Ground/Air Dash, Attack chaining, Dash Attack handoff, stamina recovery, wall contact, both facings, HUD behavior, and animation readability.
2. Decide whether continuous airborne Dash and the current 100/25 stamina economy are accepted design baselines before building levels around the measured reach.
3. Replace the debug-default double jump with the planned ability-unlock/session-state path before treating progression as implemented.
4. Manually accept the new production Hurt silhouettes, flash strength, 2.5-pixel Camera shake, 180/-110 knockback, and existing death body/ghost readability at gameplay scale.
5. Resolve or tolerance-bound the 360.33–362.22 px landing-total measurement variation; the 344.00 px Dash-only envelope is currently stable.
6. Bring the M0 metadata/status in `game_design.md`, `technical_architecture.md`, and `known_issues.md` up to date in a separate documentation-only task.
7. Manually tune the four prototype enemy roles, especially Shield durability/break, Spear close dead zone, Crossbow Aim visibility, projectile pressure, Group04 spacing, and dissolve contrast; automated correctness does not establish encounter feel.
8. Keep Main and the dedicated combat room classified as laboratory/placeholder presentation, not finished room or UI content.

### Next-stage plan — requires explicit approval

1. **M1.5 acceptance gate:** perform manual feel/visual checks, record accepted tuning, and freeze movement/action metrics used for level construction.
2. **Documentation alignment:** update the stale M0 design/architecture/known-issues metadata without changing gameplay, and decide whether a separate project plan is needed.
3. **Enemy-variety acceptance gate:** manually verify Shield front/back/GuardBreak, Spear range/dead zone, Crossbow Aim/bolt/reload, all facings, Player evasion verbs, Hurt/Death, and the 2/2/2/3 Main route before any retuning.
4. **Scope reconciliation after explicit approval:** select or merge prototype roles back toward the fixed two-normal-enemy production scope before elite/Boss/content work. Flying enemy, elite, three main rooms, boss arena, Boss, drops, and progression remain unauthorized and unstarted.

## 2026-07-23 — First enemy variety batch (preflight)

Status: complete — implementation, 26-script regression, standalone/F5 startup, and graphical inspection passed; manual combat-feel acceptance pending

### Read-only findings

- Git preflight: clean `master` at `707f043 test: enforce F5 main scene synchronization`, one local commit ahead of `origin/master`.
- `project.godot` still explicitly sets `run/main_scene="res://scenes/main/main.tscn"`.
- The existing Cursed Castle Guard is `res://scenes/enemies/castle_guard.tscn`, driven by `scripts/enemies/castle_guard.gd`, `CastleGuardStateMachine`, `HealthComponent`, `HurtboxComponent`, one sword `HitboxComponent`, Player `DetectionArea`, forward wall/floor RayCasts, and production `castle_guard_sprite_frames.tres`.
- `HealthComponent`, `HitboxComponent`, and `HurtboxComponent` are already faction-safe reusable combat composition. Player normal/Dash Attack sources are separate Hitboxes but do not yet expose a typed attack-kind label required by frontal shield policy.
- Castle Guard owns its gravity, target acquisition, patrol/chase/edge handling, Hurt interruption/knockback, facing, attack-frame gating, Death/dissolve, and debug API in one script. Those behaviors are stable but should not be copied three times.
- `EncounterGroup` and `MainEnemyDebugOverlay` are currently hard-coded to `CastleGuard`; they must be generalized to a narrow enemy contract before mixed groups can activate and report correctly.
- Collision layers currently name World, Player/Enemy Body, Player/Enemy Hurtbox, Player/Enemy Hitbox, and Detection. A ninth explicit Projectile layer is required; Player Hurtbox must accept both EnemyHitbox and Projectile while enemy Hurtboxes continue accepting PlayerHitbox only.
- Main currently has four one-shot groups and five Castle Guards. The current 2600-pixel gray-box floor and two platforms can host four staged mixed groups without adding a production room or exceeding the fixed game scope.

### Reuse plan

- Add a thin `EnemyCombatant` contract for mixed encounter activation/debug and a `GroundEnemyBase` for the three new grounded enemies' common detection, gravity, edge checks, facing, Hurt, Death/dissolve, Health/Hurtbox, and AI enable/disable lifecycle.
- Keep Castle Guard's proven AI logic; change only its parent contract and add generic type/debug/detection methods.
- Extend `HitboxComponent` with a typed `attack_kind` and `HurtboxComponent` with an optional typed `EnemyHitPolicyComponent`. Implement frontal shield behavior in `ShieldBlockComponent`; blocked hits are consumed once without mutating Health.
- Add separate typed configs, scenes, AI scripts, original Godot-Image pixel generators, SpriteFrames resources, and deterministic tests for Cursed Shield Guard, Decayed Spearman, Fallen Crossbowman, and `crossbow_bolt.tscn`.
- Generalize `EncounterGroup` and Main debug to `EnemyCombatant`, create `enemy_variety_test_room.tscn`, and replace Main's homogeneous layout with four authored mixed groups of sizes `2/2/2/3` containing all four enemy types.

### Planned files and verification

- Gameplay: common enemy contract/base/config/hit policy, three enemy scripts/configs/scenes/resources, projectile script/scene, generalized encounters/debug, Player/Hitbox/Hurtbox collision metadata, and Main mixed instances.
- Assets/tooling: 64×64 transparent original pixel frames under the three requested directories, one Godot generator, one SpriteFrames builder, and one variety contact sheet/QA frame.
- Tests: focused combat-policy/projectile/enemy AI/assets/variety-room/Main mixed-encounter coverage plus the full existing suite.
- Run exact Godot 4.7.1 fresh import, each enemy scene standalone, projectile/variety/combat rooms, configured F5 Main headless and graphical, all tests, log diagnostics, visual inspection, and `git diff --check`.

### Scope check

- Authorized: three normal grounded enemy types, one bolt projectile, necessary shared combat/AI contracts, one test room, mixed Main encounters, documentation, and tests.
- Excluded: flying enemies, elite, Boss, drops, experience, equipment, new Player damage/tuning, complex combo trees, or production-room expansion.

## 2026-07-23 — F5 Main scene synchronization acceptance (preflight)

Status: complete — configured Main, standalone combat room, graphical evidence, and full regression passed

### Read-only findings

- Git preflight: clean `master` at `04c8769 fix: defer hurtbox physics state changes`, synchronized with `origin/master`.
- `project.godot` explicitly sets `run/main_scene="res://scenes/main/main.tscn"`; this path was read from project settings rather than inferred from filenames.
- Main directly instances `res://scenes/player/player.tscn` at `Main/World/Player` and `res://scenes/enemies/castle_guard.tscn` five times beneath `Main/World/Encounters/EncounterGroup01..04/Enemies`.
- The saved Main composition contains one `Marker2D` spawn, the typed respawn coordinator, signal-driven Health/Stamina HUD, Player action/death debug controls, four authored activation areas, and one/two-enemy group sizes of `1/1/1/2`.
- The current Player PackedScene composes the latest Player SpriteFrames, movement/action/Hurt configurations, AnimationController, Stamina/Health/Hurtbox, normal and Dash Attack Hitboxes, Camera2D, HurtController, and death/ghost sequence.
- The current Guard PackedScene composes the latest Guard SpriteFrames/configuration and centralized sword damage is `5`. No Main instance overrides the PackedScene with an older script, SpriteFrames resource, or damage value.
- Existing Main-specific coverage proves group activation, five-point Guard damage, Player Hurt/invulnerability, and Guard Death cleanup; separate Player tests exercise movement/actions and Main-backed death/ghost/respawn. This task will add a saved/runtime resource-path and HUD/debug-state guard so future tool-scene-only integrations fail CI-style verification.

### Goals, planned files, and tests

- Strengthen `tests/combat/test_main_enemy_integration.gd` with explicit checks for the configured F5 path, Player/Guard source PackedScenes, latest SpriteFrames/config resources, composed gameplay controllers, live Health/Stamina HUD binding, respawn wiring, and closable debug presentation.
- Do not alter Player feel, input mapping, combat values, enemy placement, encounter count, AI, animation art, collision shapes, or the Main node tree unless runtime evidence exposes a real synchronization defect.
- Run the exact Godot `4.7.1.stable.official.a13da4feb` executable for fresh import, focused Main integration, Player movement/actions, Hurt, death/respawn, Guard/combat room, full repository regression, configured F5 graphical startup, and diagnostic-log scanning.
- Preserve Main graphical evidence and a concise audit report under `docs/qa/`; update README only if the verified F5 route differs from its current instructions.

### Scope check

- This is an integration/acceptance hardening task for already approved Player, Guard, encounter, HUD, death, and respawn work.
- It adds no new gameplay verb, enemy type, damage rule, room, Boss, item, drop, animation, or tuning change.

### Delivered acceptance hardening

- Strengthened `test_main_enemy_integration.gd` so it fails if configured F5 stops targeting `scenes/main/main.tscn`, if Main switches to an outdated Player/Guard PackedScene, SpriteFrames, action/Hurt/Guard config, or if any saved Guard overrides the centralized five-point damage.
- Added Main-runtime checks for the exact Player gameplay composition, live signal-bound Health/Stamina HUD, SpawnPoint/respawn wiring, active Player Camera2D, and independently closable action/enemy debug overlays.
- Replaced the previous direct terminal Guard damage in the Main test with the Main Player's actual action controller and composed Hitboxes: the real four-frame normal Attack deals one point, then the real Dash Attack deals two points and causes the three-Health Guard's Death/dissolve cleanup.
- Preserved the first Guard's natural AI sword path and now also proves Hurt recovery before Player control resumes. The Guard still deals exactly five points, the immediate second hit is rejected during the 0.50-second invulnerability window, and the Player returns to Alive.
- No runtime scene, art, parameter, input, Player code, enemy code, HUD code, collision, or encounter placement changed because the saved Main was already synchronized. The only executable change is stronger regression coverage preventing future tool-scene-only delivery.
- Added `docs/qa/f5_main_sync_report.md`, an inspected 1280×720 configured-Main frame, and focused import/Main/combat-room logs. The Movie Maker's duplicate first two frames and generated silent WAV were discarded; the final evidence frame remains.

### Commands and actual results

1. Exact engine and parsing:
   - `/Users/vincentz/Downloads/Godot.app/Contents/MacOS/Godot --version`: `4.7.1.stable.official.a13da4feb`.
   - Fresh headless editor import: exit 0; no parse, resource, script, error, or warning diagnostics.
2. Configured F5 Main:
   - `Godot --headless --path . --quit-after 180`: exit 0 with no diagnostics.
   - `test_main_enemy_integration.gd`: PASS for latest resource paths, live HUD, debug toggles, four activation groups/five Guards, natural five-point Guard Attack, Player Hurt/invulnerability/recovery, real one-point Player Attack, real two-point Dash Attack, Guard Death/dissolve, and active Camera2D.
3. Independent scene and focused behavior:
   - Explicit `combat_test_room.tscn` startup: exit 0.
   - `test_m1_player_movement.gd`: PASS for movement, jump assists, collision, Camera, and six locomotion animations.
   - `test_player_hurt_reaction.gd`: PASS for production Hurt, action interruption, collision-safe knockback, invulnerability, airborne handling, and Death precedence.
   - `test_player_death_presentation.gd`: PASS for flat body, released daggers, ghost rise/pause, and cleanup.
   - Main-backed `test_player_respawn.gd`: PASS in its preserved focused run for delayed ghost-complete respawn, SpawnPoint return, Health/Stamina/HUD reset, Camera continuity, and input recovery.
4. Full regression:
   - All 22 repository test scripts passed individually. Preserved log scan contains no `SCRIPT ERROR`, `ERROR:`, `WARNING:`, parse error, missing resource, or blocked PhysicsServer call.
5. Graphical F5-equivalent run:
   - `Godot --path . --write-movie docs/qa/f5_main_sync_runtime.png --fixed-fps 1 --quit-after 3 --audio-driver Dummy`: exit 0 using GL Compatibility on Apple M4.
   - Inspected `docs/qa/f5_main_sync_runtime00000002.png` at 1280×720. It visibly shows the Main Player, first Guard encounter, four group/five Guard rows with damage 5, and live Health/Stamina/action HUD.

### Manual acceptance still required

- Use F5 with both debug toggles disabled and judge Player movement/jump/double-jump/continuous-Dash feel, Attack/Dash Attack readability, Hurt knockback/shake comfort, Guard windup fairness, late two-enemy pressure, and death/ghost visual quality. Automated results establish correctness and persistence, not subjective feel.
- Rerun F5 after closing/reopening the editor to confirm the same saved Main presentation in the user's local editor workflow; resource-path and serialized-scene checks already prove persistence at file level.

## 2026-07-23 — Godot Debugger five-error repair (preflight)

Status: complete — five repeated Debugger errors identified and fixed; full regression passed

### Read-only findings

- Git preflight: clean `master` at `eb1e4fd feat: add player hurt and grouped encounters`, two commits ahead of `origin/master`.
- The latest project `user://logs/godot.log` contains exactly five `ERROR:` entries. All five are the same Godot 4.7.1 engine guard: `Function blocked during in/out signal. Use set_deferred("monitorable", true/false).`
- Each stack is identical: Player Hitbox `area_entered` → `HitboxComponent.try_hit()` → Guard `HurtboxComponent.receive_hit()` → Health reaches zero → `CastleGuard._enter_death()` → `HurtboxComponent.set_enabled(false)` → synchronous `Area2D.monitorable` assignment.
- The error repeats once for each of the five Main Guards killed during the user's run; there are not five independent code defects.
- `set_enabled()` already changes collision-shape disabled state with `set_deferred()`, but line 53 still writes `monitorable = enabled` synchronously. The component's immediate `is_enabled` flag already rejects any late contact in the same frame, so deferring the physics-server property is both safe and the Godot-required lifecycle behavior.
- Previous automated tests did not reproduce this because most lethal tests call `try_hit()` directly rather than letting PhysicsServer emit a real `area_entered` callback.

### Goals, planned files, and tests

- Change only `scripts/combat/hurtbox_component.gd` so monitorability is queued with `set_deferred()` while logical enable/disable remains immediate.
- Add a focused regression to `tests/combat/test_hitbox_hurtbox_components.gd` that creates overlapping areas, lets the physics engine emit `area_entered`, kills the target inside that callback chain, and verifies one death with no debugger error.
- Re-run exact Godot 4.7.1 import, the focused component/Guard/Main tests, all repository tests, configured Main, and scan preserved logs for `ERROR:`/warnings.
- Update only this development record beyond the focused code/test change; do not alter combat values, Player feel, enemy count, scene layout, art, or milestone scope.

### Scope check

- This is a lifecycle correctness fix for the existing Hurtbox composition.
- It adds no enemy, skill, damage rule, animation, UI, encounter, Boss, drop, or progression content.

### Delivered repair

- Replaced the synchronous `monitorable = enabled` write in `HurtboxComponent.set_enabled()` with `set_deferred("monitorable", enabled)`, matching Godot 4.7.1's PhysicsServer lifecycle rule for Area2D enter/exit callbacks.
- Kept `is_enabled` immediate. Therefore a lethal contact closes logical damage acceptance in the same call stack, while only the server-backed monitorability and CollisionShape2D state wait for the safe deferred phase.
- Added a PhysicsServer-driven regression to `test_hitbox_hurtbox_components.gd`: overlapping hostile areas now let the engine emit `area_entered`, lethal damage disables the Hurtbox inside the callback chain, and the test verifies one death plus final non-monitorability. This covers the path that direct `try_hit()` tests previously missed.
- No combat number, state priority, animation, scene, enemy placement, or Player input behavior changed.

### Commands and actual results

1. Historical evidence:
   - Read the latest `user://logs/godot.log`; it contained exactly five copies of the same blocked `set_monitorable` stack, each ending at `HurtboxComponent.set_enabled()` during `CastleGuard._enter_death()`.
2. Focused verification with exact Godot `4.7.1.stable.official.a13da4feb`:
   - `Godot --headless --path . --script tests/combat/test_hitbox_hurtbox_components.gd`: PASS, including deferred physics disable; preserved log contains no error/warning.
   - Fresh headless editor import: exit 0, no parse/resource/error/warning output.
   - `test_castle_guard.gd`: PASS for patrol, Chase, fair Attack, Hurt, and Death.
   - `test_main_enemy_integration.gd`: PASS for four groups, five Guards, Hurt, five-point damage, and Death.
3. Full regression:
   - All 22 repository test scripts exited 0.
   - Exact stdout/log scan found no `SCRIPT ERROR`, `ERROR:`, `WARNING:`, or blocked in/out-signal diagnostic.
   - Movement/action metrics remain unchanged: 153.59 px single-jump range, 281.92 px debug-double-jump range, 344.00 px four-Air-Dash action travel.
4. Runtime startup:
   - Configured Main completed a non-headless 120-frame GL Compatibility launch on Apple M4 with exit 0 and no diagnostics.

### Manual acceptance

- Clear the Godot Debugger's historical error list (or restart the editor), run F5, and defeat the five Guards again. The previous five entries remain visible until cleared, but no new `Function blocked during in/out signal` entry should be added.

## 2026-07-23 — Player Hurt feedback, Guard damage, and gray-box encounter density (preflight)

Status: complete — implementation and automated regression passed; manual feel/visual acceptance pending

### Read-only findings

- Git preflight: clean `master` at `37d116c feat: integrate cursed guards into main scene`, one local commit ahead of `origin/master`.
- Player Health is composed through `HealthComponent` with the unchanged default/runtime maximum and current value of 100/100. The Player has only `ALIVE` and `DEAD` life states; accepted Hurtbox contacts currently emit `damage_received` but do not enter a Hurt state, cancel actions, apply knockback, grant invulnerability, flash the sprite, or shake Camera2D.
- `hurt` already exists in the Player SpriteFrames contract as three non-looping frames, but it runs at 12 FPS and references `placeholder_hurt_01..03.png`. Those images are generated by shifting existing Attack/reference frames; they are explicitly placeholder art, not a production recoil sequence.
- Cursed Castle Guard sword damage has one tuning authority: `resources/enemies/castle_guard_config.tres` currently sets `attack_damage = 1`; `castle_guard.gd` copies that value into the sword Hitbox and uses it for each new active window. No separate gameplay script hardcodes the production sword value.
- Hitbox target memory already prevents one `attack_id` from damaging the same Hurtbox on multiple active frames. There is no Player-side invulnerability, so different attack ids or multiple enemies can currently apply damage without a shared grace window.
- F5 Main contains exactly two Guard instances at `(500, 610)` and `(850, 610)`, directly under `World/Enemies`. There is no encounter group, ActivationArea, persistent activation flag, active-enemy cap, or encounter debug authority.
- The gray-box floor spans approximately 2600 horizontal pixels (`-100..2500`), about 2.03 viewports at 1280px rather than the suggested 3–5-screen case. The density target is therefore five Guards across four hand-authored groups (1/1/1/2), not six to eight.
- Pre-change runtime audit passed: configured Main loaded both Guards and the active Player Camera, with the near Guard in Chase and the far Guard Idle; no baseline Godot error or warning was emitted.

### Goals and planned files

- Replace the three placeholder Hurt frames with original 64×64 production pixel poses at 16 FPS, archive the exact placeholder sources under `reference/deprecated_hurt_placeholder/`, rebuild SpriteFrames, and retain Nearest/lossless/mipmap-free imports.
- Add a focused typed Player Hurt reaction component/config for one accepted hit: source-derived knockback, 0.16-second stun plus 0.08-second recovery, 0.50-second invulnerability, action/buffer/Hitbox cancellation, non-lethal Hurt arbitration, restrained flash and Camera shake, and safe death/respawn cleanup. Global Hit Stop will remain disabled unless tests establish a safe local implementation.
- Change the single Guard damage resource value from 1 to 5 and expose the actual damage in debug output without duplicating it in AI code.
- Replace Main's flat two-enemy container with four hand-authored activation groups containing five total instances. Add one reusable encounter controller/scene contract that keeps inactive AI paused, activates once when Player enters, and reports group/active/alive/attacking counts.
- Planned implementation areas: Player scene/scripts/resource, Hurtbox invulnerability support, Player asset tooling/resources/tests, Guard config/debug/tests, Main encounter composition/controller/tests, README, five existing design/log documents, and new `docs/design/encounter_design_spec.md`.

### Verification plan

1. Generate/archive/import Hurt PNGs and rebuild Player SpriteFrames with exact Godot 4.7.1; validate frame count, 16 FPS, binary transparency, common baseline, distinct recoil silhouettes, and 48px readability.
2. Test grounded/airborne source-directed knockback, wall collision, Attack/Dash/Dash-Attack cancellation, buffer/Hitbox cleanup, 0.50-second multi-source rejection, flash/Camera restoration, lethal Death priority, and respawn reset.
3. Verify Guard windup remains damage-free, `attack_03/04` deal one deduplicated 5-point hit, body contact remains harmless, and 100 Health permits exactly twenty such hits.
4. Verify five saved Main Guards, four persistent activation groups, staged activation, no opening whole-map aggro, no spawn overlap, maximum two attackers per group, safe floor positions, and one-enemy combat-room preservation.
5. Run all repository scripts, isolated Player/Guard/combat-room scenes, configured Main, graphical captures, log scans, and `git diff --check`.

### Scope check

- This revision changes only Player Hurt feedback, the existing Cursed Castle Guard damage value, and first-enemy gray-box encounter density/activation.
- It does not add another enemy type, elite, Boss, drop, experience, random/infinite spawning, object pooling, complex squad tactics, new Player skill, or formal production level.

### Delivered implementation

- Replaced the placeholder Hurt contract with three original 64×64 frames at 16 FPS. The sequence uses a real rearward torso/hood shift, unstable dagger arms, a lifted/recovering stance, common y=60 ground baseline, binary transparency, and Nearest imports. The exact former placeholder PNGs remain under `assets/sprites/player/assassin/reference/deprecated_hurt_placeholder/`.
- Added typed `PlayerHurtConfig` and `PlayerHurtController`, composed as `Player/HurtController`. Accepted non-lethal hits cancel all action state/buffers/Hitboxes, enter `LifeState.HURT`, play the production animation, apply 180 px/s source-opposed horizontal and -110 px/s vertical knockback (70% vertical in air), lock control for 0.16 seconds plus 0.08-second recovery, and move only through Player velocity plus `move_and_slide()`.
- Extended `HurtboxComponent` with synchronous invulnerability rejection and a typed state signal. One accepted hit grants 0.50 seconds; distinct sources in the same or later physics frames are rejected until expiry. Death cancels Hurt feedback, and respawn clears invulnerability, sprite modulation, camera offset, timers, and history.
- Added 0.08-second pale-red flash/flicker and a deterministic decaying 2.5-pixel, 0.10-second Camera2D shake. Reserved `hurt_audio_requested`; no fake audio was added. Global Hit Stop remains disabled because existing death/ghost/respawn timers must not be frozen by a global time-scale mutation.
- Changed the one Guard tuning authority to `attack_damage = 5`; AI active windows and both debug views read the same resource value. Player maximum Health stays 100, so hits 1–19 are survivable and hit 20 is lethal from full Health.
- Added reusable `EncounterGroup` activation gating and replaced flat `World/Enemies` with four Main groups containing five total Guards (1/1/1/2). Inactive groups keep their Guard visuals in Idle while AI/detection are paused; Player entry activates once for the scene run. Authored spacing and the 260-pixel lose range prevent startup whole-map aggro, while the only two-enemy group caps local participation at two.
- Expanded closable diagnostics with Player Health/LifeState, invulnerability/stun remaining, last damage/source/knockback and encounter activation/engaged/alive/attacking counts plus actual Guard damage. The dedicated combat room still contains exactly one Guard.

### Commands and actual results

1. Asset and parse pipeline with exact `4.7.1.stable.official.a13da4feb`:
   - `Godot --headless --path . --script scripts/tools/build_player_animation_assets.gd -- --hurt-production-only`: exit 0; six outputs (three production frames plus three archived placeholders), zero failures.
   - `Godot --headless --editor --path . --import --quit`: exit 0; all six PNGs imported and new classes registered without diagnostics.
   - `Godot --headless --path . --script scripts/tools/build_player_animation_assets.gd`: exit 0; `PLAYER_SPRITE_FRAMES_BUILD: OK`.
2. Focused runtime checks:
   - `test_player_hurt_reaction.gd`: PASS for production art, action interruption, collision wall knockback, multi-source invulnerability, airborne scaling, and Death precedence.
   - `test_castle_guard.gd`: PASS with 0.35-second safe windup and one deduplicated five-point active hit.
   - `test_main_enemy_integration.gd`: PASS for configured F5 scene, four groups/five Guards, staged activation, Hurt, five-point damage, and enemy Death cleanup.
   - `test_combat_test_room.gd`: PASS; its one Guard still drives damage, Player death presentation, and respawn.
3. Full regression:
   - All 22 `tests/**/*.gd` scripts exited 0. Log scan found no `SCRIPT ERROR`, `ERROR:`, `WARNING:`, parse error, or missing resource.
   - Stable movement metrics remain single jump 153.59 px / 83.77 px rise, debug double jump 281.92 px / 167.10 px rise, four-Air-Dash action travel 344.00 px; this run's landing total was 362.22 px.
4. Startup checks:
   - Configured Main, independent `combat_test_room.tscn`, and independent `castle_guard.tscn` each exited 0 under `--headless --quit-after 3` with no diagnostics.
   - Configured Main also completed a non-headless 120-frame launch on GL Compatibility / Apple M4 (`OpenGL API 4.1 Metal`) with exit 0 and no error/warning output.
   - Final PNG audit: all three Hurt sources are distinct 64×64 files (808/830/819 bytes), imported Lossless with mipmaps disabled; the focused test also passed byte-identical placeholder archival and 48×48 nearest-neighbor readability.

### Manual acceptance still required

- At gameplay scale, judge whether all three Hurt poses, flash, and shake communicate impact without reading as Death or excessive screen motion.
- Verify grounded and airborne knockback feel fair from both sides, especially next to walls and during Player Attack/Dash/Dash Attack.
- Traverse all four groups and confirm the 1/1/1/2 pacing leaves enough stamina recovery space and the final pair does not feel like unavoidable synchronized pressure.

## 2026-07-23 — Main scene Cursed Castle Guard integration audit (preflight)

Status: complete — implementation, runtime audit, full regression, and graphical verification passed; manual combat-feel acceptance pending

### Read-only findings

- Git preflight: clean `master` at `5e897f6 feat: refine cursed castle guard animations`, tracking `origin/master` with no uncommitted files.
- Godot 4.7.1 reports `run/main_scene="res://scenes/main/main.tscn"`; the saved editor layout also has `res://scenes/main/main.tscn` as its current scene, so both F5 and the editor's current F6 route enter Main in the audited editor state.
- `scenes/main/main.tscn` contains Player, movement geometry, HUD, and respawn composition but no Cursed Castle Guard resource reference, `Enemies` container, enemy instance, or runtime enemy-spawn script.
- `scenes/tools/combat_test_room.tscn` is the only gameplay scene that currently instances `res://scenes/enemies/castle_guard.tscn`; this explains why the enemy exists in the repository and passes isolated tests while remaining absent from the user's normal F5/F6 run.
- The reusable enemy is not placeholder-only: the scene composes body collision, Player detection, Health, Hurtbox, sword Hitbox, wall/floor probes, typed state authority, and the production five-animation SpriteFrames resource. All 24 expected 64×64 source frames and their imports exist.
- Baseline Godot checks passed before any change: headless editor import, configured Main startup, independent combat-room startup, Castle Guard state/combat test, and combat-room player-death/respawn test. No `SCRIPT ERROR`, `ERROR:`, or `WARNING:` entries were found in the preserved logs.

### Goals and planned files

- Instance at least two existing Cursed Castle Guards under a dedicated `Main/World/Enemies` container, on valid floor positions with staged spacing for immediate and later encounter testing.
- Add one Main-only, closable enemy debug panel showing each valid guard's state, Health, animation/frame, target state, sword active window, position, and horizontal speed; do not copy enemy behavior into Main.
- Add an automated Main integration/runtime audit that proves both enemy node paths exist and remain alive/visible with valid runtime data, while retaining the independent combat room and existing combat tests.
- Planned implementation files: `scenes/main/main.tscn`, one focused `scripts/tools/` Main combat-debug controller, one focused `tests/combat/` Main integration test, README, combat/enemy specifications, and this development log. Final graphical evidence will be retained under `docs/qa/`.

### Verification plan

1. Run a fresh Godot 4.7.1 headless editor import/parse check.
2. Run the configured F5 Main and the independent `combat_test_room.tscn`, checking their logs for any error or warning.
3. Assert the Main runtime Player, active Camera2D, both enemy node paths, positions, visibility, animation/frame, Health, AI state, target status, Hitbox/Hurtbox state, and collision contracts.
4. Exercise Player normal Attack (1 damage), Dash Attack (2 damage), guard sword damage (1), Hurt interruption, Death/dissolve cleanup, edge safety, and Player death/respawn through deterministic tests.
5. Render and directly inspect a 1280×720 Main screenshot proving enemy visibility, then run all repository tests and `git diff --check`.

### Scope check

- This repair uses the existing first melee enemy and shared combat components only.
- It does not add a second enemy type, elite, Boss, drop, item, new skill, formal map, or unrelated Player tuning.
- The dedicated combat room remains independently runnable and is not promoted to the project Main scene.

### Delivered implementation

- Added one reusable enemy PackedScene dependency to Main and exactly two instances under `Main/World/Enemies`: `CursedGuardNear` at `(500, 610)` and `CursedGuardFar` at `(850, 610)`. The Player remains at `(320, 612)`, so the near Guard begins at the requested 180-pixel test distance while the far Guard stays outside initial detection.
- Added a Main-only `ENEMY DEBUG` toggle and typed overlay. For every live direct child of `Enemies`, it reports AI state, current/max Health, animation and one-based frame, Player-target acquisition, sword Hitbox activity, position, horizontal speed, facing, and visibility. It is presentation/debug code and owns no AI or Health state.
- Added `test_main_enemy_integration.gd`. It verifies the configured F5 path, saved/runtime node paths, active Player Camera2D, exact spawns, visibility, animation playback, Health, staged target acquisition, concrete collision layers/masks, a natural Main AI sword hit, Player one-point Attack, Player two-point Dash Attack, lethal Hurtbox forwarding, and Death/dissolve cleanup.
- Tightened Castle Guard's existing Death completion boundary: after the final dissolve frame it emits `presentation_finished` and calls `queue_free()`. The independent combat room now safely reports `GUARD CLEARED AFTER DEATH/DISSOLVE`; no invalid enemy reference is polled or drawn.
- Updated Main's visible title/instructions, README F5/F6 guidance, collision contract, enemy deployment specification, and retained two 1280×720 Main runtime frames under `docs/qa/`.

### Commands and actual results

1. Pre-change baseline with exact `4.7.1.stable.official.a13da4feb`:
   - Headless editor import, configured Main startup, and independent combat-room startup: all exit 0.
   - `test_castle_guard.gd`: PASS for patrol, edge, Chase, fair Attack, Hurt, and Death.
   - `test_combat_test_room.gd`: PASS for composition, contact safety, enemy damage, Player death, and respawn.
2. Main runtime audit:
   - `Godot --headless --path . --script res://tests/combat/test_main_enemy_integration.gd`: exit 0; `MAIN_ENEMY_INTEGRATION_TEST: PASS`.
   - Runtime SceneTree paths: `/root/Main/World/Enemies/CursedGuardNear` and `/root/Main/World/Enemies/CursedGuardFar`.
   - Eight physics frames after start: Player `/root/Main/World/Player`; active Camera `/root/Main/World/Player/Camera2D`; near Guard `(496.7333, 609.9252)`, visible, Chase, `walk:2`, 3/3, target true; far Guard `(850, 610)`, visible, Idle, `idle:1`, 3/3, target false.
   - The same test observed a natural near-Guard AI Attack reduce Player Health by exactly one, then verified Player Attack 1, Dash Attack 2, and terminal Guard cleanup.
3. Full regression and startup:
   - All 21 scripts under `tests/` exited 0; combined log scan found no `SCRIPT ERROR`, `ERROR:`, `WARNING:`, parse error, or missing resource.
   - Configured Main, independent `combat_test_room.tscn`, and independent `castle_guard.tscn` each started and exited 0 without diagnostics.
   - Movement metrics remained 153.59/83.77 single jump, 281.92/167.10 debug double jump, 344.00 four-Air-Dash action travel, and 362.22 through landing.
4. Graphical evidence:
   - `Godot --path . --write-movie docs/qa/main_cursed_guard_runtime.png --fixed-fps 1 --quit-after 2 --audio-driver Dummy`: exit 0; two 1280×720 frames rendered through GL Compatibility on Apple M4.
   - `docs/qa/main_cursed_guard_runtime00000001.png` was inspected at original resolution. It visibly contains Player, both distinct Guard instances, fixed Health/Stamina HUD, and live near/far enemy debug rows without blocking the ground combat silhouettes.
   - A separate 90-frame, fixed-60-FPS `combat_test_room` death demo completed without diagnostics. The last frame was inspected and shows no Guard/ghost, no stale collision drawing, and the safe `GUARD CLEARED AFTER DEATH/DISSOLVE` status.

### Manual acceptance requested

1. Press F5 and confirm both Guard silhouettes appear immediately: the near Guard should acquire/approach, while the far Guard patrols separately.
2. Toggle `ENEMY DEBUG` off/on and confirm Gameplay continues while only the diagnostic rows hide/show.
3. Test J, Shift, Shift→J, jump, Ground/Air Dash, both facings, wall contact, and platform-edge behavior against both Guards.
4. Defeat each Guard and judge Hurt, grounded Death, and dissolve readability; confirm no enemy ghost appears and no invisible body blocks movement afterward.
5. Allow the sword to deplete Player Health or use the existing development damage button, then confirm the Player death/ghost/respawn sequence and both HUD bars remain correct.

### Known limitations

- Main remains a gray-box combat laboratory, not one of the planned three production rooms. It has no encounter reset button; rerun F5 to restore freed Guards.
- Player has no invulnerability frames or production Hurt state, so separate enemy attacks can remove Health on separate attack ids. The two Guards are spaced to avoid immediate simultaneous acquisition, but future encounter tuning still needs manual approval.
- F6 always follows whichever scene is currently open in the editor. The saved audited editor state points to Main, but opening another scene intentionally changes F6 behavior; F5 remains the authoritative complete Main route.

## M0 — Environment and repository initialization

Date: 2026-07-20
Status: complete — awaiting approval for M1

### Preflight

- Repository audit: directory was empty; no Git metadata or user files were present.
- Godot discovery: PATH aliases `godot` and `godot4` were absent; application found at the developer's local Godot application path.
- Confirmed engine: `4.7.1.stable.official.a13da4feb`.
- Confirmed OS: macOS 26.5.2 (Build 25F84).
- Confirmed Git: 2.54.0; repository not initialized at preflight.

### Goals

- Initialize a Godot 4.7.1 project and Git repository.
- Establish the required directory layout and agent conventions.
- Create one dependency-free Main scene that starts safely.
- Document architecture, design baseline, test method, and known issues.

### Planned files

- Root: `project.godot`, `.gitignore`, `README.md`, `AGENTS.md`.
- Scene: `scenes/main/main.tscn`.
- Docs: technical architecture, game design baseline, development log, known issues.
- Placeholder files for required empty directories.

### Test plan

1. Verify exact Godot executable and version.
2. Run `--headless --editor --path . --import --quit` for project import/resource parsing.
3. Run `--headless --path . --quit-after 5` for main-scene startup.
4. Launch the graphical project briefly and capture startup evidence if the environment permits.
5. Review Godot output for errors and warnings and inspect Git status.

### Scope check

M0 contains no player controller, movement, input actions, combat, enemies, levels, checkpoint, or menu behavior. The static Main screen exists only to prove project startup.

### Commands and results

1. `Godot --version`
   - Result: exit 0; `4.7.1.stable.official.a13da4feb`.
2. `sw_vers` and `git --version`
   - Result: macOS 26.5.2 (Build 25F84); Git 2.54.0.
3. `Godot --headless --editor --path . --import --quit`
   - Result: exit 0; filesystem scan and editor initialization completed; no resource or parser errors in output.
4. `Godot --headless --path . --quit-after 5`
   - Result: exit 0; configured Main scene started and stopped without errors.
5. `Godot --path . --write-movie docs/qa/m0_startup.png --fixed-fps 30 --quit-after 3 --audio-driver Dummy --log-file docs/qa/m0_graphical_run.log`
   - Result: exit 0; OpenGL Compatibility renderer initialized on Apple M4 and wrote three 1280×720 frames.
   - Reviewed evidence: `docs/qa/m0_startup00000002.png`; the title, Chinese subtitle, procedural moon/spires, and M0 status are visible and correctly laid out.
6. `git status --short --branch`
   - Result: repository contents reviewed before the milestone commit; `.godot/` is correctly ignored.

No scripts exist in M0, so script-unit tests and GDScript static analysis have no applicable targets yet.

### Delivered

- Godot project configuration with `scenes/main/main.tscn` as the main scene.
- Required scene, script, resource, asset, test, documentation, and add-on directories.
- Repository/agent conventions, technical architecture, design baseline, known-issue log, and visual QA evidence.
- Main scene uses only Godot native nodes and procedural polygons; no third-party assets were introduced.

### Manual acceptance

1. Open the project with Godot 4.7.1 Standard.
2. Press `F5` and confirm a 1280×720 window opens.
3. Confirm `NOCTURNE KEEP`, `夜幕古堡`, and `M0 · PROJECT INITIALIZED` are visible.
4. Stop the project and confirm the editor Output/Debugger shows no error.

### M0 tuning changes

None. Gameplay values were not implemented or altered in this milestone.

## M0 — Final project baseline

Date: 2026-07-20
Status: complete

### Preflight and scope

- This pass is limited to M0 project settings, Godot import boundaries, documentation, verification, and Git cleanup.
- No input action, player node, gameplay script, level geometry, collision, or other M1 feature is included.
- Preflight Git state contained an editor-normalized `project.godot` plus four untracked `.import` sidecars for the QA movie output.

### `project.godot` review

- Godot replaced the custom file header with its standard generated header.
- Godot removed `rendering/textures/default_filters/use_nearest_mipmap_filter=false` from the serialized project file.
- A Godot 4.7.1 runtime query confirmed that setting is registered and its effective default remains `false`; omitting a value equal to that default does not change behavior.
- That setting controls whether mipmapped textures prefer nearest mipmap filtering. It does not select nearest filtering for ordinary CanvasItem textures.
- Godot 4.7.1 reports `rendering/textures/canvas_textures/default_texture_filter` with enum values `Nearest, Linear, Linear Mipmap, Nearest Mipmap`. The prior effective value was `1` (`Linear`).
- The project now explicitly sets `textures/canvas_textures/default_texture_filter=0` under `[rendering]`, giving future 2D pixel textures a nearest-filtered default.

### QA import sidecars

- The three PNGs and WAV under `docs/qa/` are test evidence, are not referenced by the Main scene, and are not runtime source assets.
- Their `.import` files contained default importer metadata and generated UIDs. In this context they were reproducible metadata that should not be part of the runtime asset graph.
- Added `docs/qa/.gdignore` so Godot excludes the QA evidence directory from resource scanning.
- Removed only the four untracked `.import` sidecars. The original PNG, WAV, log, and report files remain unchanged.
- A fresh Godot editor import did not recreate the sidecars and no longer listed the QA media in `filesystem_cache10`.

### Ignore rules

- `.godot/` is ignored.
- `.DS_Store` is ignored.
- `builds/`, `exports/`, and common exported package types (`*.app`, `*.dmg`, `*.pck`, `*.zip`) are ignored.
- No `.gitignore` edit was necessary in this pass.

### Commands and results

1. `Godot --headless --path . --script /tmp/nocturne_keep_project_settings_audit.gd`
   - First attempt: failed because the temporary audit script called a nonexistent `ProjectSettings.get_initial_value()` API. This was an audit-script parse failure, not a project error.
   - Corrected attempt: exit 0; confirmed both setting names, the old mipmap-filter value `false`, and Canvas default filter `0` after the project update.
2. `Godot --headless --editor --path . --import --quit --log-file /tmp/nocturne_keep_m0_import.log`
   - Result: exit 0; filesystem scan and editor initialization completed without script or resource errors.
3. `Godot --headless --path . --quit-after 5 --log-file /tmp/nocturne_keep_m0_startup.log`
   - Result: exit 0; the configured Main scene started and exited without error.
4. `Godot --path . --write-movie /tmp/nocturne_keep_m0_final.png --fixed-fps 30 --quit-after 2 --audio-driver Dummy`
   - Result: exit 0; OpenGL Compatibility initialized on Apple M4 and rendered two 1280×720 frames. The reviewed frame shows the intact M0 title scene.
5. `find docs/qa -maxdepth 1 -type f -name '*.import' -print`
   - Result: no output after import; the four QA sidecars were not recreated.
6. `git diff --check`
   - Result: no whitespace errors.

### Manual acceptance

1. Open the project in Godot 4.7.1 and confirm `docs/qa/` is excluded from the FileSystem asset index.
2. Run the project with `F5` and confirm the M0 title scene remains visible.
3. Confirm Project Settings → Rendering → Textures → Canvas Textures → Default Texture Filter is `Nearest`.

### Known limitations

- M0 contains no pixel-art textures, so the setting value is verified programmatically; its visual effect will first be observable when a pixel texture is introduced in an approved later milestone.
- This pass does not add or test any M1 gameplay behavior.

## Pre-M1 tool — Pixel character concept generator

Date: 2026-07-21
Status: complete — awaiting visual approval; M1 remains paused

### Goals and scope

- Replace the unavailable Figma workflow with a local Godot 4.7.1/GDScript pixel-character tool.
- Generate an original 16-bit-inspired Concept C for The Night Warden at 64px plus a 48px readability floor.
- Deliver front, side, silhouette, dagger, palette, key-pose, preview, and 1600×1000 board PNGs.
- Keep the formal Main scene and all M1 movement/gameplay behavior unchanged.
- Use no downloaded assets, online image generators, or paid external services.

### Files planned

- Tool scene: `scenes/tools/character_design_lab.tscn`.
- Tool scripts: pixel canvas, character generator, board exporter, and preview orchestrator under `scripts/tools/`.
- Generated sources: `assets/sprites/player/concept_c/`.
- Design/QA: `docs/design/pixel_character_spec.md`, character board, lab preview, and QA report.
- Validation: `tests/tools/validate_pixel_character_assets.gd`.

### Scope check

- No `CharacterBody2D`, movement, input action, collision, combat system, combo state, enemy, map, or level behavior was added.
- `project.godot` and `scenes/main/main.tscn` were not modified.
- The concept lab is independently runnable and is not configured as the project Main scene.
- The attack drawings describe one basic attack only: main-hand slash followed by an offhand visual follow-through.

### Implementation notes

- Character pixels are authored directly on low-resolution `Image` canvases through clipped `fill_rect`, `set_pixel`, and Bresenham line operations.
- 48px studies use nearest-neighbor resizing; board and lab previews use exact integer scaling.
- The fixed requested five-color palette was retained without adjustment.
- Import sidecars are retained for source assets because they record `compress/mode=0` and `mipmaps/generate=false`; `.godot/` remains ignored.
- The board is composed inside an isolated 1600×1000 `SubViewport`; it does not alter the project viewport or formal UI.

### Commands and actual results

1. `Godot --headless --editor --path . --import --quit`
   - Initial parse/import completed and registered the four tool classes without parser errors.
   - The surrounding zsh wrapper initially attempted to assign the reserved variable `status`; the editor command itself exited successfully. The wrapper was corrected to task-specific variable names for later commands.
2. `Godot --headless --path . scenes/tools/character_design_lab.tscn -- --generate-only --skip-board`
   - First attempt exposed empty exported NodePaths in the hand-authored scene; switched the scene to typed unique-node references.
   - Second attempt exposed GDScript typed-array literal conversion errors; replaced calls with explicitly typed local arrays.
   - Corrected result: exit 0; all eleven transparent asset PNGs generated without warnings or errors.
3. `Godot --path . scenes/tools/character_design_lab.tscn --audio-driver Dummy -- --generate-only`
   - Result: exit 0 under the GL Compatibility renderer on Apple M4; the 1600×1000 design board was generated.
4. `Godot --headless --editor --path . --import --quit`
   - Result: exit 0; all generated PNGs imported as textures, with no script or resource errors.
5. `Godot --headless --path . --script res://tests/tools/validate_pixel_character_assets.gd`
   - First validation compared all raw bytes and correctly revealed that the importer normalizes RGB channels beneath fully transparent pixels. The check was narrowed to alpha plus visible RGBA pixels.
   - Final result: exit 0; `PIXEL_CHARACTER_VALIDATION: PASS (11 assets + board)` with no warnings or errors.
6. `Godot --path . scenes/tools/character_design_lab.tscn --write-movie /tmp/nocturne_keep_character_lab_final.png --fixed-fps 1 --quit-after 6 --audio-driver Dummy`
   - Result: exit 0; six deterministic preview frames rendered. The final completed frame was preserved as `docs/qa/character_design_lab_preview.png`.
   - Visual review found the first layout used native texture size despite integer-sized containers; `TextureRect` was corrected to explicit Nearest scaling and the QA image was regenerated.
7. `Godot --headless --path . --quit-after 5`
   - Final result: exit 0; the configured formal Main scene started and stopped without warnings or errors.
8. `Godot --headless --path . scenes/tools/character_design_lab.tscn -- --generate-only --skip-board`
   - Final result: exit 0; the independent lab generated all low-resolution PNG sources without a rendering display.
9. Final parallel check: Main startup, pixel asset validator, and headless lab generation.
   - Result: all three processes exited 0; validator reported `PASS (11 assets + board)`.

### Visual acceptance results

- The 64px front/side views read as the same character.
- The pointed hood, pale eye, segmented torso, separate legs, short mantle, and warm clasp remain visible.
- The main dagger clearly establishes right-facing orientation; the shorter offhand blade remains behind the body.
- The 48px side view remains recognizable without anti-aliased or partial-alpha pixels.
- The black silhouette retains hood, posture, weapon directions, mantle projection, and leg gap.
- Board and lab screenshots were reviewed directly and are linked from `docs/qa/pixel_character_report.md`.

### Manual acceptance

1. Open `scenes/tools/character_design_lab.tscn` in Godot 4.7.1 and press `F6`.
2. Confirm the status reaches `Export complete` and every preview group is visible by scrolling.
3. Confirm character and dagger edges remain sharp and the 48px views are readable.
4. Press the regenerate button and confirm the PNG/board timestamps update without changing the Main scene.
5. Review the decisions listed at the end of `docs/design/pixel_character_spec.md` before approving any animation or M1 work.

### Known limitations

- The output is a concept baseline and three static key poses, not a final sprite sheet.
- Board text uses system fonts, so a regenerated board may have small cross-platform typography differences; the character pixel data is deterministic.
- M1 player movement remains intentionally unstarted in this pass.

## Pre-M1 art production — Player pixel animation batch 01

Date: 2026-07-21
Status: complete — awaiting animation approval; M1 remains paused

### Goals and scope

- Preserve the approved front, side, dash, and attack static art as reference material instead of deleting it.
- Extend the black-hooded dual-dagger design into 21 usable transparent 64×64 frames: Idle 4, Run 6, Dash 5, Attack 6.
- Provide an independently runnable `AnimatedSprite2D` preview with manual action switching.
- Validate a 48×48 readability floor without creating gameplay code, player controllers, enemies, bosses, maps, or formal Main integration.

### Files planned and delivered

- Animation outputs and reference copies: `assets/sprites/player/assassin/`.
- Pose, renderer, sequence generator, QA sheet, and preview controller: `scripts/tools/`.
- Independent preview: `scenes/tools/player_animation_preview.tscn`.
- Automated validation: `tests/tools/validate_player_animation_assets.gd`.
- Visual QA and updated specification: `docs/qa/player_animation_*` and `docs/design/pixel_character_spec.md`.

### Preflight version-control state

- Before this batch, `project.godot` was the only modified file.
- Its sole diff moved `textures/canvas_textures/default_texture_filter=0` above the renderer keys. The key and value were unchanged, so the diff was an editor-normalized ordering change with no rendering behavior change.
- The Nearest filter remained active. No additional project setting or formal Main change was made for this batch.

### Implementation notes

- A typed pose object stores the torso, hood, hands, knees, feet, blade tips, and mantle tip for each frame.
- One renderer draws every pose with the same anatomy construction, proportions, dagger language, and fixed five-color palette.
- The first animation pass exports separate PNGs rather than an atlas, keeping every frame directly inspectable and replaceable.
- The original four reference images are copied byte-for-byte into `reference/`; the original `concept_c/` files remain in place.
- Preview textures are created from the generated images and explicitly use Nearest filtering at 6× integer scale.
- Source `.import` sidecars retain Lossless compression and disabled mipmaps; `.godot/` remains ignored.

### Commands and actual results

1. `Godot --version`
   - Result: `4.7.1.stable.official.a13da4feb`.
2. `Godot --headless --path . scenes/tools/player_animation_preview.tscn -- --generate-only`
   - First attempt ran before the editor class scan and could not resolve the newly added global pose class. No assets were lost; the process was stopped.
   - After the required editor import, result: exit 0; `PLAYER_ANIMATION_EXPORT: 21 frames + 4 references`.
3. `Godot --headless --editor --path . --quit`
   - Result: exit 0; registered new global classes and imported all 25 animation/reference PNGs without resource errors.
4. `Godot --headless --path . --script tests/tools/validate_player_animation_assets.gd`
   - Result: exit 0; `PLAYER_ANIMATION_VALIDATION: PASS (21 frames + 4 byte-identical references)`.
5. `Godot --headless --path . scenes/tools/player_animation_preview.tscn --quit-after 3`
   - Result: exit 0; independent animation preview loaded, generated frames, and played without script/resource errors.
6. `Godot --headless --path . --quit-after 3`
   - Result: exit 0; configured formal Main loaded and exited without errors.

### Visual acceptance results

- The 21-frame QA contact sheet was reviewed directly at original resolution.
- Idle remains deliberately subtle; Run uses a readable six-frame alternating stride.
- Dash uses a lower, longer travel silhouette with rear-leg extension.
- Attack uses a planted lunge, extended main-hand thrust, rear support dagger, and distinct follow-through.
- All four representative 48px checks retain hood, eye, legs, and both weapon directions without smoothing.

### Scope check and known limitations

- No formal gameplay scene, input action, movement state, collision, combat logic, combo system, enemy, boss, or map was added.
- The preview is a design tool and is not configured as the project Main scene.
- No atlas or `.tres` SpriteFrames resource is delivered yet; this batch uses individual PNGs and runtime-built preview frames.
- Motion timing is an initial art-production cadence and still requires user approval before formal player integration.

## Pre-M1 presentation integration — Player animation system

Date: 2026-07-21
Status: complete — awaiting animation-system approval; M1 gameplay remains paused

### Goals and scope

- Integrate the existing 21 production frames into one persistent `SpriteFrames` resource with exact names, FPS values, and loop flags.
- Add clearly marked temporary frames for the six not-yet-authored actions: jump start, jump loop, fall, land, hurt, and death.
- Build a typed, presentation-only `PlayerAnimationController` with priority, one-shot, direction-lock, and completion-signal behavior.
- Upgrade the independent preview to expose all ten animations, playback controls, direction flipping, and live metadata.
- Preserve all existing concept and reference PNGs and keep the formal Main scene unchanged.

### Planned files

- `scripts/player/player_animation_controller.gd` for animation selection and presentation locks only.
- `resources/player/player_sprite_frames.tres` for persistent animation configuration.
- `assets/sprites/player/assassin/placeholder/` for explicitly temporary PNG frames.
- Updated `scenes/tools/player_animation_preview.tscn` and its tool controller.
- `docs/design/player_animation_spec.md`, this log, and focused automated tests.

### Planned validation

- Headless editor import/parse with Godot 4.7.1.
- Resource assertions for all names, counts, speeds, loop flags, texture imports, and shared foot baseline.
- Controller assertions for priority, idempotent replay prevention, one-shot completion, loop behavior, and facing locks.
- Independent preview startup and configured formal Main startup.

### Scope guard

- No movement physics, collision, input map, health, damage, hitbox implementation, combo, enemy, boss, level, or formal player scene integration is authorized in this batch.

### Delivered architecture

- Persistent `SpriteFrames`: ten snake_case animations with the requested counts, rates, and loop flags.
- Composition: `PreviewRoot / Player / VisualRoot / AnimatedSprite2D` plus sibling `AnimationController`.
- Presentation controller: typed signals, one-shot priority locks, Attack/Dash direction locks, queued facing, idempotent replay prevention, pause/resume/restart, and explicit reset.
- Attack timing interface: zero-based frames `2` and `3`, corresponding to `attack_03` and `attack_04`; no hitbox or damage behavior was added.
- Missing art: 19 PNGs under the dedicated `placeholder/` directory, with `placeholder_` prefixes and documentation labels.
- Reference preservation: all four reference PNGs remain present and unchanged.

### Commands and actual results

1. `Godot --headless --editor --path . --quit`
   - Initial pass registered the new builder/controller classes and imported assets.
   - It exposed that a constructed `PackedInt32Array` is not a valid constant expression in Godot 4.7.1. The Attack window constant was corrected to a typed `Array[int]`, and the following import completed without parser/resource errors.
2. `Godot --headless --path . --script scripts/tools/build_player_animation_assets.gd -- --placeholders-only`
   - Result: exit 0; `PLAYER_PLACEHOLDER_EXPORT: 19 files, 0 failures`.
3. `Godot --headless --path . --script scripts/tools/build_player_animation_assets.gd`
   - Result: exit 0; `PLAYER_SPRITE_FRAMES_BUILD: OK`.
4. `Godot --headless --path . scenes/tools/player_animation_preview.tscn --quit-after 3`
   - Result: exit 0 after the constant fix; the independently runnable preview loaded the persistent SpriteFrames without errors.
5. `Godot --headless --path . --script tests/player/test_player_animation_system.gd`
   - First run revealed a test-side API type mismatch (`get_animation_names()` returns `PackedStringArray`) and a real one-pixel baseline mismatch in `dash_03`.
   - The test type was corrected. The Dash core source pose was shifted down one pixel, and production/placeholder assets were regenerated.
   - Final result: exit 0; `PLAYER_ANIMATION_SYSTEM_TEST: PASS (10 animations, controller locks/signals verified)`.
6. `Godot --path . scenes/tools/player_animation_preview.tscn --write-movie /tmp/nocturne_keep_spriteframes_preview.png --fixed-fps 10 --quit-after 3 --audio-driver Dummy`
   - Result: exit 0; GL Compatibility rendered the preview at 1280×720 on Apple M4.
   - Visual review confirmed sharp 6× pixel scaling, complete metadata, ten action buttons, playback controls, and explicit placeholder labels. The ground guide was moved above the metadata after this review.
7. Final regression: legacy concept validator, 21-frame source validator, 40-frame system/controller test, independent preview startup, configured Main startup, and `git diff --check`.
   - Result: all commands exited 0. Reports: `PIXEL_CHARACTER_VALIDATION: PASS`, `PLAYER_ANIMATION_VALIDATION: PASS`, `PLAYER_ANIMATION_SYSTEM_TEST: PASS`, and `FINAL_PLAYER_ANIMATION_REGRESSION:PASS`.
8. Priority tightening regression: editor parse, system/controller test, preview startup, Main startup, and whitespace check.
   - Result: all commands exited 0; the system test remained `PASS` after adding explicit loop-priority release behavior.

### Automated acceptance results

- Exactly the ten required animation names exist; no extra animation is present.
- Counts, FPS, and loop flags match the specification.
- All 40 integrated frames are 64×64, binary-alpha, imported textures without mipmaps.
- Idle/Run/Dash/Attack/Land/Hurt share visible ground row `y=60`.
- Dash's first four frames span 0.20 seconds and its fifth frame completes before `one_shot_finished`.
- Attack reaches frame six; `attack_03` and `attack_04` are the only reserved hit-window frames.
- Same-animation requests do not rewind; looping actions do not emit one-shot completion.
- Priority, Death persistence, Attack/Dash facing locks, queued flip, and unchanged sprite position all pass.
- Lower-priority loops cannot overwrite higher-priority loops unless the caller explicitly authorizes a completed state transition.

### Manual acceptance

1. Run `scenes/tools/player_animation_preview.tscn` with `F6`.
2. Select all ten buttons and confirm the production/placeholder label, frame count, FPS, and mode.
3. During Dash or Attack, request the opposite facing and confirm it applies only after completion.
4. Pause, resume, and restart both a loop and a one-shot.
5. Confirm `attack_03` and `attack_04` display `HIT WINDOW` only as preview metadata.

### Known limitations and scope check

- Jump Start, Jump Loop, Fall, Land, Hurt, and Death use integration placeholders and require authored final frames later.
- This system does not decide locomotion state; a future approved player state machine will call the presentation API.
- `one_shot_finished` is an animation event only and has no damage, invulnerability, physics, or gameplay side effects.
- Formal Main and its startup scene remain unchanged; no M1, enemy, boss, level, or combat functionality was added.

## M1 — Animation completion and player movement integration

Date: 2026-07-21
Status: complete — awaiting M1 gameplay approval

### Goals and scope

- Replace only the Jump Start, Jump Loop, Fall, and Land placeholder art with formal 64×64 five-color pixel frames.
- Revalidate the existing four-frame Idle and six-frame Run loops, preserving them unless a concrete anchor/readability defect is found.
- Add the formal `CharacterBody2D` player with horizontal acceleration/deceleration, air control, gravity, jumping, 0.10-second coyote time, and 0.12-second jump buffering.
- Add dedicated player movement input actions, a following `Camera2D`, collision, facing, and the six-state M1 animation flow.
- Integrate the Player into Main with only minimal collision geometry needed to exercise M1 movement.

### Planned files

- Formal M1 animation PNGs under `assets/sprites/player/assassin/{jump_start,jump_loop,fall,land}/`.
- Updated SpriteFrames builder/resource and preview metadata.
- Player movement config resource, `scripts/player/player.gd`, and `scenes/player/player.tscn`.
- M1 input entries in `project.godot` and a minimal movement test space in `scenes/main/main.tscn`.
- Deterministic animation/movement tests, QA evidence, this log, and `docs/design/player_animation_spec.md`.

### Baseline tuning from the Master Prompt

- `move_speed=220`, `ground_acceleration=1400`, `ground_deceleration=1700`, `air_acceleration=850`.
- `jump_velocity=-420`, `gravity=1100`, `coyote_time=0.10`, `jump_buffer_time=0.12`.
- No tuning changes are planned before actual runtime evidence.

### Planned validation

- Exact animation names/counts/FPS/loop flags, transparency, no mipmaps, 48px readability, anchor and grounded baseline checks.
- Deterministic movement acceleration/deceleration, collision, jump, coyote-time, jump-buffer, facing, camera, and animation-state checks.
- Independent Player scene, animation preview, and formal Main startup/render checks with Godot 4.7.1.

### M2 exclusion guard

- Dash and Attack art/resource entries remain available in the preview only; the formal M1 Player must never request them.
- Hurt and Death remain explicitly marked placeholders and are not called by M1 gameplay.
- No hitbox, damage, health, invulnerability, dash movement, attack input, hurt/death flow, enemy, boss, or level-production system is authorized.

### Delivered animation art

- Replaced the eight temporary Jump Start, Jump Loop, Fall, and Land PNGs with authored 64×64 transparent five-color pixel frames in dedicated production directories.
- Removed only the superseded M1 placeholder PNGs and their import sidecars after verifying that the rebuilt SpriteFrames resource no longer referenced them. Hurt and Death placeholders remain intact.
- Revalidated the approved four-frame Idle and six-frame Run loops without overwriting them; their feet, alternating strides, dagger separation, and shared canvas anchor remained suitable for M1.
- Generated `docs/qa/m1_player_animation_contact_sheet.png`, including nearest-neighbor 64px presentation and 48px readability samples.
- Kept every Dash, Attack, concept, and `reference/` image unchanged.

### Delivered Player integration

- Added a reusable `CharacterBody2D` Player scene with `VisualRoot/AnimatedSprite2D`, `CollisionShape2D`, following `Camera2D`, and the existing `PlayerAnimationController` as `AnimationController`.
- Added a typed movement configuration resource using the approved tuning values and no terminal-velocity cap.
- Added dedicated A/D, arrow-key, and Space input actions through a reproducible InputMap configuration script.
- Implemented ground acceleration/deceleration, air control, gravity, single jump, 0.10-second coyote time, 0.12-second input buffering, collision via `move_and_slide()`, and controller-owned horizontal facing.
- Implemented an explicit six-state M1 animation flow. One-shot completion now releases presentation locks before notifying the Player, allowing Jump Start and Land callbacks to select their next locomotion state without replaying frame zero.
- Replaced the M0 title-only Main contents with a minimal M1 movement test room, static collision floor/platforms, the instanced Player, and controls legend. The configured Main path itself was not changed.

### Commands and actual results

1. `Godot --headless --path . --script scripts/tools/build_player_animation_assets.gd -- --m1-animation-only`
   - Result: exit 0; `PLAYER_M1_ANIMATION_EXPORT: 8 files, 0 failures`.
2. `Godot --headless --editor --path . --quit`
   - Result: exit 0; imported the new PNGs and parsed the new scene/scripts without resource errors.
3. `Godot --headless --path . --script scripts/tools/build_player_animation_assets.gd`
   - Result: exit 0; `PLAYER_SPRITE_FRAMES_BUILD: OK`; formal M1 paths replaced the old placeholder references.
4. `Godot --headless --path . --script scripts/tools/configure_m1_input_map.gd`
   - Result: exit 0; `M1_INPUT_MAP_CONFIG: OK`.
5. `Godot --headless --path . --script tests/player/test_m1_player_movement.gd`
   - The first test revision released its synthetic jump input before the Player's physics callback and therefore did not exercise the jump. The harness was corrected to hold input across physics frames.
   - Final result: exit 0; `M1_PLAYER_MOVEMENT_TEST: PASS (movement, jump assists, collision, camera, six animations)`.
6. Consolidated regression: concept asset validator, 21-frame source validator, ten-animation/controller test, M1 movement test, standalone Player startup, animation preview startup, and configured Main startup.
   - Result: every command exited 0. Reports: `PIXEL_CHARACTER_VALIDATION: PASS`, `PLAYER_ANIMATION_VALIDATION: PASS`, `PLAYER_ANIMATION_SYSTEM_TEST: PASS`, and `M1_PLAYER_MOVEMENT_TEST: PASS`.
7. `Godot --path . --write-movie /tmp/nocturne_keep_m1_main.png --fixed-fps 30 --quit-after 3 --audio-driver Dummy`
   - Result: exit 0 using GL Compatibility on Apple M4. Visual review confirmed the Player on collision ground, sharp pixels, intact camera presentation, and readable M1 controls.
8. `Godot --path . scenes/tools/player_animation_preview.tscn --write-movie /tmp/nocturne_keep_m1_preview.png --fixed-fps 10 --quit-after 3 --audio-driver Dummy`
   - Result: exit 0. Visual review confirmed Jump Start/Loop/Fall/Land are shown as production art while only Hurt and Death retain placeholder labels.

### Automated acceptance results

- All six M1 animation groups have the required counts, FPS, and loop flags; the four newly authored groups use formal paths rather than `placeholder/`.
- Jump Start, Jump Loop, Fall, and Land have distinct image hashes and visually distinct silhouettes.
- All tested frames are 64×64, transparent, imported without mipmaps, and retain readable 48×48 nearest-neighbor reductions.
- Ground acceleration reaches 220 px/s, deceleration returns to zero, left-facing uses `flip_h`, and the sprite node does not move while flipping.
- The runtime sequence reaches Jump Start, Jump Loop, Fall, Land, and the correct grounded loop without per-frame restarts.
- Coyote-time jump and buffered-on-landing jump both pass with real physics-frame input and collision.
- Player settles on the floor without penetration; its enabled child Camera2D follows the Player.
- Horizontal input or a new accepted jump can interrupt Land.
- Formal Player state constants and animation requests contain no Dash, Attack, Hurt, or Death entry.

### Manual acceptance requested

1. Run the configured project and evaluate horizontal acceleration/deceleration feel with A/D and arrow keys.
2. Walk off a platform and press Space within 0.10 seconds to judge coyote-time feel rather than only functional correctness.
3. Press Space just before landing to judge the 0.12-second input-buffer feel.
4. Check Jump Start, rising loop, Fall, and Land transitions at normal speed in both facing directions.
5. Run `scenes/tools/player_animation_preview.tscn` and confirm Dash/Attack still play there but never activate during formal movement.

### Known limitations and handoff

- Main is an intentionally minimal movement laboratory, not a production level.
- Jump Loop and Fall use two frames each by design; they prioritize readable poses over ornamental motion.
- Hurt and Death remain explicit preview placeholders.
- Dash, Attack, Hurt, Death gameplay, health/damage, hitboxes, enemies, bosses, and level production remain deferred to M2 or later and require separate approval.

## M1.5 — Player action prototype

Date: 2026-07-21
Status: complete — awaiting M1.5 prototype approval

### Goals and scope

- Audit the committed Attack/Dash PNGs, persistent SpriteFrames entries, and independent preview controls before changing gameplay.
- Add debug-enabled double-jump capability with a locked-by-default formal ability flag, one recoverable air jump, and no third jump.
- Add one ground-only Dash prototype with fixed motion timing/cooldown and no invulnerability.
- Add one Attack animation trigger with no damage, hitbox, combo, or enemy interaction.
- Preserve the M1 locomotion flow, all reference art, the preview tool, and the existing Commit history.

### Preflight audit

- Git worktree was clean at milestone start; baseline commit: `cda7bdc feat: complete M1 player movement and animations`.
- Both `assets/sprites/player/assassin/attack/` and `assets/sprites/player/assassin/dash/` exist.
- All requested source frames exist: `attack_01.png` through `attack_06.png` and `dash_01.png` through `dash_05.png`.
- `resources/player/player_sprite_frames.tres` contains non-looping `attack` at 12 FPS and non-looping `dash` at 20 FPS with the complete frame paths.
- `scenes/tools/player_animation_preview.tscn` exposes dedicated Dash and Attack buttons. Its controller maps keys 7 and 8 to the same animations and calls the shared `PlayerAnimationController`.
- Formal M1 gameplay did not show either action because `scripts/player/player.gd` intentionally contained only the six M1 locomotion states and `project.godot` contained no Dash or Attack input actions.
- No missing art or SpriteFrames repair is required.

### Planned implementation

- Extend the reproducible Input Map with physical Shift for Dash and J for Attack.
- Store Dash speed, duration, and cooldown in a typed action-prototype Resource.
- Compose a focused `PlayerActionController` node beside the existing presentation controller; it will own action mutual exclusion, Dash timing, cooldown, and action completion signals.
- Keep jump/coyote/buffer physics in the Player, with explicit `has_double_jump`, `debug_enable_double_jump`, and `air_jumps_remaining` state.
- Add deterministic tests for asset audit, preview selection, double-jump consumption/recovery, third-jump rejection, Dash timing/cooldown, Attack completion, facing locks, and locomotion non-overwrite.

### M2 exclusion guard

- No enemy, boss, health, damage, invulnerability, hitbox, hurtbox, combo, or completed Hurt/Death gameplay is authorized.
- `attack_03` and `attack_04` remain metadata-only future hit-window frames.
- `double_jump` is reserved as a future animation name; this prototype may reuse existing Jump Start/Loop art and must not label that fallback as final art.

### Delivered architecture and behavior

- Added physical Shift and J input actions without altering the existing movement/jump bindings.
- Added `PlayerActionPrototypeConfig` with Dash speed 480 px/s, motion duration 0.20 seconds, and cooldown 0.45 seconds.
- Added a composed `PlayerActionController` sibling node. It owns only Attack/Dash mutual exclusion, the Dash motion/cooldown timers, and typed `action_started`/`action_finished` signals.
- Extended Player with `has_double_jump=false`, `debug_enable_double_jump=true`, and `air_jumps_remaining`. Ground/coyote jumps preserve the air jump, the independent air path consumes one, landing restores it, and a third airborne jump is rejected.
- The existing 0.12-second buffer is shared by legal ground and air jump paths. The pre-move/landing guard prevents one input edge from producing two jumps in one frame.
- Reserved `double_jump` as the future animation name. The prototype explicitly resets and replays Jump Start as fallback art.
- Dash starts only while grounded, locks facing, blocks ordinary horizontal control, applies motion only during the first four 20-FPS frames, uses the fifth frame as recovery, and provides no invulnerability.
- Attack is animation-only, locks facing, cannot be restarted while active, and returns to the correct locomotion animation after frame six.
- Simultaneous Attack/Dash input selects Attack. Once either action begins, the component rejects the other until completion.
- Updated Main's internal test panel with all controls and an explicit debug-double-jump notice. The independent ten-animation preview remains intact.

### Commands and actual results

1. Filesystem/SpriteFrames/scene audit using `find`, `stat`, `shasum`, and `rg`.
   - Result: both action directories and all 11 PNGs present; SpriteFrames entries complete; preview buttons/key mappings present; formal M1 absence traced to deliberate Player/Input scope rather than missing art.
2. `Godot --headless --editor --path . --quit`
   - Result: exit 0; registered the new typed Resource/controller classes and parsed the updated Player scene without script/resource errors.
3. `Godot --headless --path . --script scripts/tools/configure_m1_input_map.gd`
   - Result: exit 0; `M15_INPUT_MAP_CONFIG: OK`; physical Shift and J serialized into `project.godot`.
4. `Godot --headless --path . --script tests/player/test_m1_player_movement.gd`
   - Initial regression inherited the new debug capability and therefore correctly treated the old buffered-air test as a double jump. The M1-only harness was made explicit by disabling the debug override for that suite.
   - Final result: exit 0; `M1_PLAYER_MOVEMENT_TEST: PASS (movement, jump assists, collision, camera, six animations)`.
5. `Godot --headless --path . --script tests/player/test_m15_player_actions.gd`
   - The first integrated version passed. During the full regression, a fixed-frame assertion occasionally sampled after Dash completion; it was replaced with direct motion-timer/completion-state observation and then passed three consecutive runs.
   - Final result: exit 0; `M15_PLAYER_ACTION_TEST: PASS (assets, preview, double jump, dash, attack)`.
6. `Godot --path . --write-movie /tmp/nocturne_keep_m15_main.png --fixed-fps 30 --quit-after 3 --audio-driver Dummy`
   - Result: exit 0; rendered 1280×720 with GL Compatibility on Apple M4. Visual review confirmed sharp Player pixels and readable Move/Jump×2/Dash/Attack instructions.
7. `Godot --path . scenes/tools/player_animation_preview.tscn --write-movie /tmp/nocturne_keep_m15_preview.png --fixed-fps 10 --quit-after 2 --audio-driver Dummy`
   - Result: exit 0; preview retained its ten controls, production Attack/Dash entries, nearest-neighbor scaling, and placeholder labels only for Hurt/Death.
8. Final consolidated regression: editor import, concept validator, 21-frame/reference validator, ten-animation controller test, M1 movement test, M1.5 action test, standalone Player, preview, configured Main, and `git diff --check`.
   - Result: every command exited 0; `M15_FINAL_REGRESSION:PASS`.

### Automated acceptance results

- All 11 Attack/Dash files exist and the persistent resource exposes the correct counts, rates, and non-looping flags.
- Preview Dash and Attack buttons select and play the corresponding SpriteFrames animations.
- Formal ability flag defaults false while the current debug trial supplies exactly one air jump.
- Ground jump does not consume it; coyote applies only to the first jump; second jump consumes it; third jump is rejected; landing restores it.
- Air Dash is rejected. Ground Dash speed, motion window, recovery, facing lock, input blocking, completion, and cooldown pass.
- Attack wins simultaneous action input, survives ordinary movement requests, rejects restart spam, completes all six frames, and returns to Idle or Run.
- Existing controller validation still confirms only `attack_03` and `attack_04` report the reserved future hit window.
- Four original reference PNGs remain byte-identical.
- No new health, damage, invulnerability, combo, enemy, boss, hitbox, or hurtbox behavior exists.

### Manual acceptance requested

1. Press Space twice during one airborne arc, then press a third time and confirm only the first two jumps occur.
2. Land and repeat to confirm the debug air jump recovers.
3. Press Shift on the ground, judge the 0.20-second travel plus recovery feel, and verify rapid Shift presses respect cooldown.
4. Hold a direction and press J; confirm all six Attack frames finish before Run resumes and facing remains locked during the action.
5. Press J and Shift together; confirm Attack wins once without action restart loops.
6. Watch the Godot Output/Debugger during a normal manual session and report any environment-specific red error not reproduced by the automated suite.

### Known limitations and handoff

- `double_jump` has only a reserved name; Jump Start is temporary fallback art.
- Dash and Attack are prototypes, not a combat system. Dash has no invulnerability and Attack has no gameplay hit detection.
- Attack may play while airborne; on completion it returns to Jump Loop/Fall rather than forcing an invalid grounded animation.
- Main remains an internal movement/action laboratory rather than a production level.
- Hurt and Death remain preview placeholders with no formal Player trigger.

## M1.5 revision — Air Dash and dual-dagger thrust

Date: 2026-07-22
Status: complete — awaiting manual approval

### Goals and scope

- Replace the current ground-only Dash restriction with one horizontal air Dash per airborne cycle while retaining the existing ground Dash.
- Change the Input Map action from the provisional `player_dash` name to the approved `dash` action and bind physical Left Shift plus optional Right Shift.
- Split presentation names into `ground_dash` and `air_dash`, with clearly different grounded and airborne silhouettes.
- Archive all six pre-revision Attack PNGs before replacing the production sequence with a synchronous dual-dagger lunging thrust.
- Preserve the Attack hit-window metadata at frames three and four without creating a Hitbox, Hurtbox, damage, enemy, boss, or combo system.

### Preflight audit

- Git worktree was clean; baseline commit: `0e7be18 feat: add M1.5 player action prototype`.
- Existing ground Dash source contains five 64×64 transparent frames under `assets/sprites/player/assassin/dash/`; the persistent animation is named `dash` at 20 FPS.
- Existing Attack contains six 64×64 transparent frames under `assets/sprites/player/assassin/attack/`; its second, fifth, and related transition poses do not maintain a synchronous two-blade forward thrust.
- `PlayerActionController` currently rejects all airborne Dash attempts and stores only one generic Dash action state.
- `Player` currently reads the Input Map action `player_dash`; Gameplay contains no direct Shift-key polling.
- `docs/design/player_movement_spec.md` does not yet exist and will be created in this revision.

### Planned files and tests

- Update the procedural pose generator, production contact sheet, SpriteFrames builder/resource, animation controller, preview controller/scene, Player action component, Player integration, and reproducible Input Map writer.
- Add archived old Attack PNGs under a reference/deprecated directory and new `air_dash` production PNGs.
- Extend resource/controller tests for `ground_dash`, `air_dash`, frame counts, locks, hit-window metadata, and visual/action distinction.
- Extend Gameplay tests for rising/falling air Dash, direction selection, vertical freeze, single-use/reset, shared cooldown, gravity restoration, repeat rejection, and correct post-Dash locomotion.
- Run editor import, all existing regressions, standalone Player/preview/Main startup, and GL Compatibility visual captures with Godot 4.7.1.

### Scope guard

- No Attack movement will be added unless collision-safe behavior is clearly justified; this revision defaults to animation-only thrust.
- No actual hitbox node, hit detection, damage, health, invulnerability, enemy, boss, or combo behavior is authorized.
- Air Dash remains horizontal only; there is no vertical or diagonal Dash.

### Delivered implementation

- Replaced the provisional `player_dash` Input Map action with `dash`. It contains two physical Shift events distinguished by Left/Right key location. Gameplay reads only `Input.is_action_just_pressed(DASH_ACTION)` and contains no direct key polling.
- Split the former generic presentation name into non-looping `ground_dash` and `air_dash`, both five frames at 20 FPS. The old generic `dash` SpriteFrames alias was removed to prevent ambiguous state selection.
- Renamed the pre-existing five Ground Dash PNGs without art loss. Hash comparison confirmed each new `ground_dash_01`–`05` PNG is byte-identical to its corresponding former `dash_01`–`05` source; the duplicate old path was removed after verification.
- Added five original 64×64 Air Dash frames with a horizontal airborne body, retracted legs, close arms/blades, trailing mantle, transparent background, fixed canvas anchor, Nearest import, and no mipmaps.
- Archived all six previous Attack PNGs before production overwrite under `assets/sprites/player/assassin/reference/deprecated_attack_slash/`. SHA-256 evidence was captured before replacement and the archive files remain independently importable.
- Replaced Attack with six original 64×64 synchronous dual-dagger thrust frames: guard, compression, drive, core strike, held extension, and recovery. The two forward blades are vertically separated and no sweeping arc is present.
- Preserved `attack_03` and `attack_04` as query-only future hit-window metadata. No Hitbox, Hurtbox, damage, enemy, invulnerability, or combo node/logic was created.
- Extended `PlayerActionController` with explicit Ground Dash and Air Dash states, a stored horizontal direction, mutual exclusion, the existing 480 px/s travel speed, 0.20-second motion timer, and shared 0.45-second cooldown.
- Added `air_dash_available`. Air Dash can start while rising or falling, consumes the flag immediately, zeros vertical velocity, suspends gravity during the one-shot, rejects repeats, and resumes normal gravity afterward. Only an actual landing resets the flag; coyote time does not.
- Direction uses live horizontal input when present because facing is updated immediately before action dispatch; otherwise it uses current facing. Ground/Air Dash and Attack lock facing until completion and flip with `AnimatedSprite2D.flip_h` only.
- Updated the independent preview to eleven buttons/animations, the Main test overlay, reproducible asset/Input/SpriteFrames builders, placeholder regeneration references, asset validation, movement/animation specifications, README, and QA contact sheet/report.

### Commands and actual results

1. `Godot --headless --editor --path . --quit`
   - Exit 0. Godot 4.7.1 imported the new PNGs and parsed all typed scripts/scenes without errors.
2. `Godot --headless --path . --script scripts/tools/build_player_animation_assets.gd -- --archive-legacy-attack`
   - Exit 0; `PLAYER_ATTACK_ARCHIVE: 6 files, 0 failures`. This ran before overwriting production Attack.
3. `Godot --headless --path . --script scripts/tools/build_player_animation_assets.gd`
   - Exit 0; `PLAYER_PRODUCTION_EXPORT: 26 files, 0 failures`.
4. `Godot --headless --path . --script scripts/tools/configure_m1_input_map.gd`
   - Exit 0; `M15_INPUT_MAP_CONFIG: OK`. `dash` has Left and Right Shift; `player_dash` is absent.
5. `Godot --headless --path . --script scripts/tools/player_sprite_frames_builder.gd`
   - Exit 0; `PLAYER_SPRITE_FRAMES_BUILD: OK`.
6. `Godot --headless --path . --script tests/tools/validate_player_animation_assets.gd`
   - Exit 0; `PLAYER_ANIMATION_VALIDATION: PASS (26 frames + 4 byte-identical references)`.
7. `Godot --headless --path . --script tests/player/test_player_animation_system.gd`
   - Exit 0; `PLAYER_ANIMATION_SYSTEM_TEST: PASS (11 animations, controller locks/signals verified)`.
8. `Godot --headless --path . --script tests/player/test_m1_player_movement.gd`
   - Exit 0; `M1_PLAYER_MOVEMENT_TEST: PASS (movement, jump assists, collision, camera, six animations)`.
9. `Godot --headless --path . --script tests/player/test_m15_player_actions.gd`
   - Exit 0; `M15_PLAYER_ACTION_TEST: PASS (ground/air Dash, reset/cooldown, thrust Attack)`.
10. `Godot --path . --write-movie /tmp/nocturne_keep_air_dash_main.png --fixed-fps 30 --quit-after 2 --audio-driver Dummy`
    - Exit 0; Main rendered at 1280×720 through GL Compatibility with the Player, camera view, and updated Ground/Air Dash controls visible. No red Output/Debugger errors appeared.
11. `Godot --path . scenes/tools/player_animation_preview.tscn --write-movie /tmp/nocturne_keep_air_dash_preview.png --fixed-fps 10 --quit-after 2 --audio-driver Dummy`
    - Exit 0; preview rendered at 1280×720 with eleven controls including Ground Dash, Air Dash, and Attack. No red Output/Debugger errors appeared.
12. Original-resolution inspection of `docs/qa/player_animation_contact_sheet.png` plus `git diff --check`.
    - Visual result: Ground Dash reads planted, Air Dash reads airborne, Attack reads as two-blade forward thrust; pixel edges remain sharp. Diff check returned no whitespace errors.
13. Final consolidated regression also ran `tests/tools/validate_pixel_character_assets.gd` before every animation and movement suite.
    - Every command exited 0. Final reports: `PIXEL_CHARACTER_VALIDATION: PASS (11 assets + board)`, `PLAYER_ANIMATION_VALIDATION: PASS (26 frames + 4 byte-identical references)`, `PLAYER_ANIMATION_SYSTEM_TEST: PASS (11 animations, controller locks/signals verified)`, `M1_PLAYER_MOVEMENT_TEST: PASS (movement, jump assists, collision, camera, six animations)`, and `M15_PLAYER_ACTION_TEST: PASS (ground/air Dash, reset/cooldown, thrust Attack)`.

### Automated acceptance results

- Rising and falling Air Dash both start successfully; no-input direction uses facing and held input selects the matching direction.
- Air Dash zeros vertical velocity, pauses gravity, plays `air_dash`, consumes one availability flag, rejects a second airborne Dash, and restores normal gravity after completion.
- Landing restores exactly one Air Dash. Coyote time does not alter availability. Ground Dash does not consume the Air Dash.
- Ground and Air Dash share cooldown, cannot restart from repeated Shift edges, apply horizontal motion for the first four frames, and lock facing.
- The new Attack core has two separated forward Pale Steel blade bands and extends to the front edge of the 64×64 action silhouette. It differs from every archived slash frame.
- Attack rejects repeat input, cannot be overwritten by locomotion, preserves frames three/four as metadata-only, and recovers to grounded or airborne locomotion appropriately.
- Left-facing presentation uses `flip_h` without changing the player transform, collision, or sprite anchor.
- Main, preview, M1 locomotion, reference assets, and debug double jump remain intact.

### Manual acceptance requested

1. In Main, try Shift during both ascent and descent, then attempt a second Air Dash before landing.
2. Land and immediately retry to confirm availability resets reliably.
3. Compare Ground Dash and Air Dash at full speed, especially the legs and perceived ground contact.
4. Press J facing right and left and confirm both dagger tips read as a simultaneous thrust rather than a swing.
5. Hold movement during action completion and confirm Ground Dash/Attack recover to Run while Air Dash recovers to Fall/Jump Loop.

### Known limitations and handoff

- The Air Dash is deliberately horizontal-only and provides no invulnerability.
- Attack is presentation-only and adds no movement impulse; the future narrow forward Hitbox remains metadata, not a node.
- Hurt and Death remain explicitly labeled preview placeholders.
- Main remains an internal action laboratory, not a production level.
- No enemy, damage, Hitbox, Hurtbox, combo, Boss, or other M2 combat work was started.

## M1.5 extension — Dash Attack input chain

Date: 2026-07-22
Status: complete — awaiting manual feel approval

### Goals and scope

- Add one `dash_attack` action reachable from Ground Dash or Air Dash by buffered Shift/J input without requiring a same-frame chord.
- Preserve standalone Dash and standalone dual-dagger Attack behavior while introducing a configurable pairing window and attack-input buffer.
- Add one six-frame, 16-FPS, non-looping shared Dash Attack animation with distinct high-speed dual-thrust readability at 64×64 and 48×48.
- Apply inherited Dash direction and collision-safe CharacterBody2D movement, with reduced speed and recovery deceleration rather than a second full Dash.
- Expose metadata-only future hit-window frames three through five and add an optional test-scene debug overlay.

### Preflight audit

- Git worktree was clean; baseline commit: `ad94391 feat: add air dash and dual-dagger thrust`.
- Existing action state is one of None, Ground Dash, Air Dash, or Attack; Attack currently wins same-frame Shift/J and there is no cross-frame combination window.
- Input Map currently uses `dash` for Left/Right Shift and the legacy project-local name `player_attack` for J. This milestone will adopt the requested `attack` action and remove the old alias.
- `PlayerActionPrototypeConfig` currently centralizes Dash speed/duration/cooldown only; all Dash Attack timing and movement values will be added there.
- Ground/Air Dash and Attack are separate one-shots with facing locks. SpriteFrames currently contains eleven animations; no `dash_attack` source or resource entry exists.
- Existing Ground Dash, Air Dash, Attack, deprecated slash frames, concept references, M1 locomotion, debug double jump, and commit history must remain intact.

### Planned implementation and tests

- Extend the procedural animation generator, contact sheet, SpriteFrames builder/resource, animation controller, preview scene/controller, action configuration, action state component, Player physics integration, Main debug overlay, tests, and specifications.
- Use a 0.18-second post-Dash combination window and 0.12-second pre-Dash Attack buffer. The latter deliberately adds at most 120 ms to a standalone Attack so an Attack-first near-chord can resolve without briefly playing/canceling the normal Attack.
- Configure Dash Attack at 320 px/s with 0.18 seconds of sustained movement and 0.195 seconds of linear recovery, matching the complete 6/16-second animation while remaining below the 480 px/s Dash speed.
- Test standalone inputs, both chord orders, late rejection, one-use/restart protection, ground/air recovery, Air Dash preservation rules, collision against a wall, facing, metadata, scene startup, and all existing regressions.

### Scope guard

- No Hitbox node, target tracking, enemy, health, damage, invulnerability, combo tree, Hurt/Death Gameplay, or Boss behavior is authorized.
- Dash Attack may expose only a presentation query/signal contract for future frames three through five.
- Ground and Air Dash Attack share one animation in this first pass; code retains the airborne-origin flag for distinct gravity and recovery behavior.

### Delivered implementation

- Replaced the legacy Input Map name `player_attack` with the requested `attack` action bound to physical J. Dash remains `dash` with Left/Right Shift. Gameplay reads only named Input Map actions.
- Extended the typed action Resource with a 0.18-second post-Dash combination window, 0.12-second Attack-first buffer, 320 px/s Dash Attack speed, 0.18-second sustained movement, and 0.195-second recovery. The latter two total the full 0.375-second animation.
- Added explicit `DashAttack` state, `dash_attack_used`, Ground/Air origin tracking, window/buffer timers, inherited direction, direct near-chord start, Dash-to-Dash-Attack transition, and typed `action_transitioned` signal.
- Shift alone still starts Ground/Air Dash. J alone waits for the short pairing grace then starts normal Attack. J during the open Dash window transitions; J then Shift inside the buffer and same-frame Shift/J start Dash Attack directly.
- Late J during Dash is rejected instead of leaking into a later Attack. Dash Attack blocks normal Attack and Dash, ignores repeat input, and cannot restart its first frame.
- Dash Attack uses `CharacterBody2D.velocity` plus `move_and_slide()`: 320 px/s during the first 0.18 seconds, followed by linear deceleration for 0.195 seconds. It never writes `global_position` and passes a solid-wall collision test.
- Air Dash Attack consumes the existing Air Dash opportunity, holds vertical velocity at zero while active, then restores gravity and enters Fall unless an actual landing occurred. It never refreshes `air_dash_available`; only landing does.
- Added six original transparent 64×64 `dash_attack` PNGs, integrated them at 16 FPS non-looping, and preserved all existing Dash/Attack/reference/deprecated resources.
- Added `is_dash_attack_hit_window()` for metadata-only frames three through five. No Hitbox node, target memory, damage, enemy, combo, or Boss implementation exists.
- Added an optional Main action debug HUD showing current state, window/open time, use flag, Air Dash availability, and horizontal speed. Its checkbox disables the display without changing Gameplay.
- Updated the twelve-animation preview, production generator/contact sheet, SpriteFrames resource, validation suites, README, animation/movement specifications, and QA report.

### Commands and actual results

1. Preflight reads of `AGENTS.md`, README, development log, technical architecture, relevant scripts/resources/scenes/tests, plus `git status` and recent history.
   - Result: clean baseline `ad94391`; no prior Dash Attack art/state; existing Dash/Attack/reference assets intact.
2. Initial `Godot --headless --path . --script scripts/tools/build_player_animation_assets.gd` before production generation.
   - Result: the default SpriteFrames mode correctly reported six missing new Dash Attack textures. Existing source/reference PNGs were untouched; the temporarily incomplete SpriteFrames resource was rebuilt after import. The sequence was corrected rather than ignoring the errors.
3. `Godot --headless --path . --script scripts/tools/build_player_animation_assets.gd -- --production-only`
   - Exit 0; `PLAYER_PRODUCTION_EXPORT: 32 files, 0 failures`.
4. `Godot --headless --editor --path . --quit`, followed by the default SpriteFrames build.
   - Exit 0; six new PNGs imported without errors; `PLAYER_SPRITE_FRAMES_BUILD: OK`.
5. `Godot --headless --path . --script scripts/tools/configure_m1_input_map.gd`
   - Exit 0; `M15_INPUT_MAP_CONFIG: OK`; `dash` and `attack` are present, deprecated `player_dash`/`player_attack` are absent.
6. `Godot --headless --path . --script tests/tools/validate_pixel_character_assets.gd`
   - Exit 0; `PIXEL_CHARACTER_VALIDATION: PASS (11 assets + board)`.
7. `Godot --headless --path . --script tests/tools/validate_player_animation_assets.gd`
   - Exit 0; `PLAYER_ANIMATION_VALIDATION: PASS (32 frames + 4 byte-identical references)`.
8. `Godot --headless --path . --script tests/player/test_player_animation_system.gd`
   - Exit 0; `PLAYER_ANIMATION_SYSTEM_TEST: PASS (12 animations, controller locks/signals verified)`.
9. `Godot --headless --path . --script tests/player/test_m1_player_movement.gd`
   - Exit 0; `M1_PLAYER_MOVEMENT_TEST: PASS (movement, jump assists, collision, camera, six animations)`.
10. `Godot --headless --path . --script tests/player/test_m15_player_actions.gd`
    - Exit 0; `M15_PLAYER_ACTION_TEST: PASS (ground/air Dash, reset/cooldown, thrust Attack)`.
11. `Godot --headless --path . --script tests/player/test_dash_attack.gd`
    - The first timing assertion sampled one physics tick before the 0.18-second window closed; the test was corrected to sample the exact closed-window interval.
    - Final exit 0; `DASH_ATTACK_TEST: PASS (buffer, transitions, air recovery, collision, debug HUD)`.
12. `Godot --path . --write-movie /tmp/nocturne_keep_dash_attack_main.png --fixed-fps 30 --quit-after 2 --audio-driver Dummy`
    - Exit 0; Main rendered 1280×720 through GL Compatibility with complete controls and the action debug HUD. No red Output/Debugger errors appeared.
13. `Godot --path . scenes/tools/player_animation_preview.tscn --write-movie /tmp/nocturne_keep_dash_attack_preview.png --fixed-fps 10 --quit-after 2 --audio-driver Dummy`
    - Exit 0; preview rendered 1280×720 with twelve animation buttons including Dash Attack. No red Output/Debugger errors appeared.
14. Original-resolution review of `docs/qa/player_animation_contact_sheet.png` and `git diff --check`.
    - Result: Dash Attack reads as a low high-speed dual thrust distinct from regular Dash and Attack; its 48×48 check remains readable; no whitespace errors.

### Automated acceptance results

- Standalone Shift, standalone J, Dash-then-J, J-then-Shift, and same-frame Shift/J all resolve to the intended action.
- J after the 0.18-second combination window does not trigger Dash Attack or leak into a later Attack.
- Each Dash produces at most one Dash Attack; repeated J/Shift cannot restart, cancel, or nest it.
- Ground recovery reaches Run/Idle. Air recovery restores gravity, reaches Fall, keeps Air Dash spent, and restores it only on actual landing.
- Dash Attack inherits direction, locks facing, flips correctly, moves below full Dash speed, decelerates, and cannot pass through the test wall.
- SpriteFrames contains twelve correctly configured animations. Dash Attack frames are 64×64, binary-alpha, mipmap-free, palette-valid, and readable after 48×48 nearest-neighbor conversion.
- Future Dash Attack hit-window queries return true only on frames three, four, and five.
- Main and the preview scene remain independently runnable; all earlier movement, animation, double-jump, Dash, and Attack regressions pass.

### Manual acceptance requested

1. Press J alone repeatedly and judge whether the intentional 0.12-second pairing delay remains responsive enough.
2. Try Shift then J at the beginning and near the end of the 0.18-second window on ground and in air.
3. Compare the 320 px/s Dash Attack movement and recovery against the 480 px/s ordinary Dash.
4. Inspect frames three through five facing both directions and confirm both dagger tips remain distinct at gameplay scale.
5. Disable `ACTION DEBUG HUD` and confirm the laboratory view remains uncluttered.

### Known limitations and handoff

- Ground and Air Dash Attack intentionally share one animation; airborne origin is represented by world position and physics rather than a second art set.
- Supporting Attack-first pairing adds up to 0.12 seconds of latency to standalone Attack; this requires manual feel approval.
- Dash Attack has no invulnerability, gameplay Hitbox, target memory, damage, enemy interaction, or combo follow-up.
- Hurt and Death remain preview-only placeholders; Main remains an internal action laboratory.
- No enemy, formal damage settlement, combo tree, or Boss work was started.

## M1.5 refinement — Fast Attack response and buffering

Date: 2026-07-22
Status: complete — awaiting manual feel approval

### Goals and scope

- Compress the production `attack` animation from six frames at 12 FPS to four frames at 20 FPS, preserving a synchronous dual-dagger forward thrust and reducing input-to-core-pose latency to approximately 0.05 seconds.
- Add a single-entry, 0.10-second Attack input buffer that may restart the same basic Attack only from frame three onward or at natural completion; rapid J input must never restart frame one immediately.
- Compress `dash_attack` from six frames at 16 FPS to five frames at 20 FPS and align its future metadata-only hit window to frames three and four.
- Archive both superseded six-frame animation sequences before production overwrite and retain all earlier references/deprecated assets.
- Extend the optional debug HUD and deterministic tests with Attack frame, buffer timer, chain readiness, and measured input-to-effective-frame latency.

### Preflight audit

- Git worktree is clean at baseline commit `753003f feat: add buffered dash attack`.
- Standalone J currently waits up to 0.12 seconds in order to support the older J-first near-chord path. This conflicts with the new immediate-Attack requirement and will be removed.
- Same-frame Shift+J and Dash-then-J can remain Dash Attack paths. J-first will now start Attack immediately; the existing policy that Dash does not cancel Attack remains unchanged.
- Production `attack` and `dash_attack` each currently contain six transparent 64×64 PNG frames. SpriteFrames configures them at 12 FPS and 16 FPS respectively.
- Current future window metadata is Attack frames three/four and Dash Attack frames three/four/five. It will change to Attack frames two/three and Dash Attack frames three/four.

### Planned files and tests

- Update the pixel pose generator, archive/export tool, SpriteFrames builder/resource, animation controller, action config/controller, debug overlay, contact-sheet/asset validation, and affected Gameplay tests.
- Add `docs/design/player_combat_spec.md`; update README, animation specification, movement specification where its input contract is affected, QA report, and this development log.
- Verify immediate single Attack, approximately 0.05-second effective pose, one-entry buffer consumption, repeated complete attacks without frame-one starvation, movement/facing locks, five-frame Dash Attack duration, 48×48 readability, Main/preview startup, and all existing regressions with the exact Godot 4.7.1 executable.

### Scope guard

- This is one repeatable basic Attack animation, not a multi-animation combo tree.
- Dash still cannot cancel an active Attack; no new cancel matrix is introduced.
- No Hitbox node, target tracking, enemy, health, damage, invulnerability, Boss, Hurt Gameplay, or Death Gameplay is authorized.

### Delivered implementation

- Archived the immediately preceding six production Attack frames to `assets/sprites/player/assassin/reference/deprecated_attack_six_frame/` and six Dash Attack frames to `reference/deprecated_dash_attack_six_frame/`. Pre-overwrite SHA-256 comparison confirmed all twelve archive files are byte-identical to their production sources.
- Rebuilt Attack as four distinct 64×64 frames at 20 FPS: short compression, first dual-thrust core, held maximum extension/chain window, and rapid retraction. Future metadata is now exactly `attack_02` and `attack_03`.
- Rebuilt Dash Attack as five distinct 64×64 frames at 20 FPS: Dash carry-over, initial extension, arrow-shaped core, held thrust, and recovery. Future metadata is now exactly `dash_attack_03` and `dash_attack_04`.
- Removed the 0.12-second standalone-Attack pairing delay. J now dispatches Attack immediately; the effective `attack_02` timeline begins after one 20-FPS frame (`0.05 seconds`).
- Added a centralized `attack_buffer_time=0.10`. An active Attack stores at most one later J, never extends that entry from repeat spam, and consumes it only from frame three onward or at natural completion.
- Added an animation-controller-authorized same-one-shot restart that preserves animation/facing locks. Each consumed buffer restarts the same basic Attack exactly once and emits a new action-start event; it does not define a combo branch.
- Preserved the existing cancellation policy: Dash does not cancel Attack. Same-frame Shift+J and Dash-then-J still start Dash Attack, but J-first on an earlier frame is now an immediate normal Attack.
- Shortened Dash Attack movement to 0.15 seconds at 320 px/s plus 0.10 seconds of linear recovery, totaling the five-frame 0.25-second presentation.
- Extended the optional Main HUD with current Attack frame, buffer flag/timer, chain readiness, and input-to-first-effective-frame timeline. Updated Main labeling, SpriteFrames, preview data, procedural builders, placeholder dependencies, QA sheet/reports, README, animation/movement specifications, and the new combat-interface specification.

### Commands and actual results

1. `Godot --headless --path . --script scripts/tools/build_player_animation_assets.gd -- --archive-fast-attack-source`
   - Exit 0; `PLAYER_FAST_ATTACK_ARCHIVE: 12 files, 0 failures`.
   - `shasum -a 256` comparison before overwrite produced matching source/archive hashes for every old Attack and Dash Attack frame.
2. `Godot --headless --path . --script scripts/tools/build_player_animation_assets.gd -- --production-only`
   - Exit 0; `PLAYER_PRODUCTION_EXPORT: 29 files, 0 failures`. Obsolete production `attack_05`, `attack_06`, and `dash_attack_06` plus their import sidecars were removed only after archival.
3. First editor import after source compression
   - The editor reported the three removed frame paths because the persistent SpriteFrames resource still contained its old references. This was not ignored: the resource was immediately rebuilt with the new counts, and the final clean import below produced no error.
4. `Godot --headless --path . --script scripts/tools/build_player_animation_assets.gd`
   - Exit 0; `PLAYER_SPRITE_FRAMES_BUILD: OK` with Attack 4/20 FPS and Dash Attack 5/20 FPS.
5. Final `Godot --headless --editor --path . --import --quit --log-file /tmp/nocturne_keep_fast_attack_import.log`
   - Exit 0; no script/resource error or warning.
6. Serial automated suites with exact Godot 4.7.1 executable:
   - `validate_pixel_character_assets.gd`: `PASS (11 assets + board)`.
   - `validate_player_animation_assets.gd`: `PASS (29 frames + 4 byte-identical references)`; additionally validates both new six-frame archive directories.
   - `test_player_animation_system.gd`: `PASS (12 animations, controller locks/signals verified)`.
   - `test_m1_player_movement.gd`: `PASS (movement, jump assists, collision, camera, six animations)`.
   - `test_m15_player_actions.gd`: `PASS (ground/air Dash, reset/cooldown, thrust Attack)`.
   - `test_dash_attack.gd`: `PASS (immediate J, transitions, air recovery, collision, debug HUD)`.
   - `test_fast_attack.gd`: `PASS (immediate response, single buffer, four-repeat chain, 0.25s Dash Attack)`; repeated three consecutive runs also passed.
7. `Godot --path . --write-movie /tmp/nocturne_keep_fast_attack_main.png --fixed-fps 30 --quit-after 2 --audio-driver Dummy`
   - Exit 0; GL Compatibility initialized on Apple M4 and rendered two 1280×720 Main frames. The expanded two-line HUD fits the panel and the project Main remains intact.
8. `Godot --path . scenes/tools/player_animation_preview.tscn --write-movie /tmp/nocturne_keep_fast_attack_preview.png --fixed-fps 20 --quit-after 2 --audio-driver Dummy`
   - Exit 0; the independent twelve-animation preview rendered two 1280×720 frames without red Output/Debugger errors.
9. Original-resolution review of `docs/qa/player_animation_contact_sheet.png` and `git diff --check`
   - The new Attack row shows two separate forward blades on frames two/three; Dash Attack shows the longer arrow silhouette on frames three/four. Both 48px checks retain hood, legs, and two weapon bands. Diff check passed.

### Automated acceptance results

- A normal Attack enters the action state synchronously on its accepted J edge. It never waits for J release or a chord timeout.
- The timeline from accepted input to `attack_02` is exactly one 20-FPS frame (`0.05 seconds`) at normal speed.
- One early repeat J remains buffered through the locked first half, does not restart frame one, and is consumed once when `attack_03` opens the chain window.
- Four deliberately repeated Attacks each reached `attack_02` and `attack_03`; the action-start count matched the accepted input count, and stopping J allowed the final `attack_04` recovery to finish.
- Movement presentation and facing cannot overwrite active Attack. The preserved Dash-during-Attack request is rejected.
- Dash Attack retains collision-safe CharacterBody2D motion, reaches half speed midway through its 0.10-second recovery, and reaches zero at 0.25 seconds.
- Both actions remain dual-hand forward thrusts with vertically separated blades and no lateral arc. Their 48×48 nearest-neighbor checks remain readable.
- No Hitbox, Hurtbox, enemy, target memory, damage, health, invulnerability, Boss, or formal combo tree was added.

### Manual acceptance requested

1. Tap J once and judge whether the short frame-one compression and approximately 0.05-second first thrust feel immediate.
2. Tap J repeatedly at slow, medium, and rapid rhythms; confirm the character finishes readable thrust cycles instead of sticking on frame one.
3. Stop J after several repeats and confirm the final Attack retracts immediately into Idle/Run/air locomotion.
4. Compare normal Attack (compact, stationary, 0.20 seconds) with Dash Attack (longer silhouette, inherited movement, 0.25 seconds) facing both directions.
5. Confirm the chosen preserved rule—Shift cannot cancel an active Attack—matches the desired feel before any later cancel matrix is designed.

### Known limitations and handoff

- The one-entry buffer repeats one identical basic Attack; it has no alternating art, branch, damage scaling, target logic, or formal combo counter.
- Input-to-effective-frame diagnostics report the SpriteFrames timeline at current `speed_scale`; they are deterministic presentation timing, not operating-system input-latency profiling.
- The earlier J-first Dash Attack pairing was intentionally removed to satisfy immediate J response. Same-frame Shift+J and Dash-then-J remain supported.
- Dash Attack still has no damage, invulnerability, or gameplay Hitbox. Hurt/Death remain preview placeholders.
- No enemy, damage settlement, formal combo tree, or Boss work was started.
## 2026-07-22 — Continuous Dash and stamina milestone (preflight)

### Goal

- Replace the legacy long Dash cooldown with one-entry, edge-triggered Ground Dash chaining limited by stamina.
- Preserve one Air Dash per airborne cycle and keep Dash Attack compatible without charging stamina twice.
- Add a presentation-only stamina HUD and optional diagnostics while keeping stamina ownership in a dedicated player component.

### Planned files and tests

- Add a typed `PlayerStaminaComponent`, connect it to `PlayerActionController`, `Player`, and a signal-driven Main HUD.
- Split the Ground Dash presentation into `dash_start`, `dash_loop`, and `dash_end`; archive the current five-frame `ground_dash` source before replacement.
- Update production generators, SpriteFrames, animation preview, automated tests, README, movement/combat specifications, and add `docs/design/stamina_system_spec.md`.
- Verify independent Shift edges, one-entry Dash buffering, four full-stamina Dash starts, rejected fifth Dash without a charge, delayed/rate-limited regeneration, one Air Dash per airtime, Dash Attack compatibility, collision-safe movement, HUD synchronization, Main/preview startup, and a clean Godot 4.7.1 import.

### Scope guard

- This milestone adds no enemy, Boss, Hitbox, Hurtbox, health, damage, invulnerability, or additional skill system.
- Holding Shift will never synthesize repeated Dash input; every segment requires a new `dash` action edge.
- Landing restores only Air Dash eligibility. It neither refills stamina nor bypasses the regeneration delay.

### Delivered implementation

- Replaced the legacy 0.45-second Dash cooldown with 0.18-second paid segments, a 0.10-second one-entry Ground Dash buffer, and a 0.03-second minimum segment interval. Gameplay still reads only `Input.is_action_just_pressed("dash")`; holding Shift produces exactly one segment.
- Added the composed, typed `PlayerStaminaComponent`: 100 maximum, 25 per successful Ground/Air Dash, 0.60-second post-spend delay, 35 points/second regeneration, clamping, and `stamina_changed`, `stamina_depleted`, and `stamina_insufficient` signals.
- Ground Dash now moves through `dash_start` (2 frames), locked looping `dash_loop` (3 frames), and `dash_end` (2 frames), all at 20 FPS. A live paid chain resets only the collision-safe motion segment and remains in `dash_loop`, avoiding a standing recovery between segments.
- Archived the prior five Ground Dash PNGs byte-identically under `assets/sprites/player/assassin/reference/deprecated_ground_dash_five_frame/` before removing their obsolete production paths. SHA-256 comparison matched all five source/archive pairs.
- Preserved one Air Dash per airborne cycle. It costs stamina, ignores chained Shift, is restored only by landing, and never receives availability from Dash Attack or coyote time. Landing does not alter stamina.
- Dash Attack continues to inherit direction and collision-safe movement, clears a pending Dash request, and never charges the already-paid Dash again. Same-frame legal Shift+J pays exactly one Dash charge.
- Added a signal-driven fixed `Main/HUD/StaminaContainer` with 0–100 bar, numeric value, and one-shot insufficient feedback. Added optional diagnostics for stamina, regeneration timer, Dash buffer/time, segment number, Air Dash availability, action state, animation, and horizontal speed.
- Updated the fourteen-animation preview, 31-frame production generator/contact sheet, SpriteFrames resource, animation/action regressions, README, movement/animation/combat specifications, and the new stamina specification. No enemy, health, damage, Hitbox, Hurtbox, invulnerability, Boss, or other skill system was added.

### Commands and actual results

1. `Godot --headless --path . --script scripts/tools/build_player_animation_assets.gd -- --archive-ground-dash-source`
   - Exit 0; `PLAYER_GROUND_DASH_ARCHIVE: 5 files, 0 failures`.
   - `shasum -a 256` reported identical hashes for every old production frame and archived counterpart.
2. `Godot --headless --path . --script scripts/tools/build_player_animation_assets.gd -- --production-only`
   - Exit 0; `PLAYER_PRODUCTION_EXPORT: 31 files, 0 failures` and regenerated `docs/qa/player_animation_contact_sheet.png`.
3. `Godot --headless --path . --script scripts/tools/build_player_animation_assets.gd`
   - Exit 0; `PLAYER_SPRITE_FRAMES_BUILD: OK` with fourteen named animations.
4. `Godot --headless --path . --script scripts/tools/build_player_animation_assets.gd -- --remove-archived-ground-dash-source`
   - Exit 0; five exact obsolete sources removed only after byte comparison against the archive.
5. Final `Godot --headless --editor --path . --import --quit --log-file /tmp/nocturne_keep_chain_dash_final_import.log`
   - Exit 0; no script/resource error or warning.
6. Exact Godot 4.7.1 serial regression suite:
   - `validate_pixel_character_assets.gd`: `PASS (11 assets + board)`.
   - `validate_player_animation_assets.gd`: `PASS (31 frames + 4 byte-identical references)` and validates the five-frame Dash archive.
   - `test_player_animation_system.gd`: `PASS (14 animations, segmented Dash locks/signals verified)`.
   - `test_m1_player_movement.gd`: `PASS (movement, jump assists, collision, camera, six animations)`.
   - `test_m15_player_actions.gd`: `PASS (split Ground Dash, Air Dash reset, thrust Attack)`.
   - `test_dash_attack.gd`: `PASS (immediate J, transitions, air recovery, collision, debug HUD)`.
   - `test_fast_attack.gd`: `PASS (immediate response, single buffer, four-repeat chain, 0.25s Dash Attack)`.
   - `test_chain_dash_stamina.gd`: `PASS (edge chaining, four charges, air limit, HUD, collision)`.
7. `Godot --path . --write-movie /tmp/nocturne_keep_stamina_main.png --fixed-fps 30 --quit-after 2 --audio-driver Dummy`
   - Exit 0; GL Compatibility initialized on Apple M4 and rendered two 1280×720 Main frames. The fixed stamina HUD and three-line optional diagnostics fit without following the camera.
8. `Godot --path . scenes/tools/player_animation_preview.tscn --write-movie /tmp/nocturne_keep_stamina_preview.png --fixed-fps 20 --quit-after 2 --audio-driver Dummy`
   - Exit 0; independent fourteen-animation preview rendered two frames without red Output/Debugger errors.
9. Original-resolution review of Main, preview, and `docs/qa/player_animation_contact_sheet.png`, plus `git diff --check`
   - HUD values/layout are readable; all three Ground Dash phases retain crisp nearest-neighbor pixels and the common baseline; diff check passed.

### Automated acceptance results

- One Shift edge starts one Dash. Holding Shift across completion produced one action-start event and one 25-point charge.
- Four timed independent edges from full stamina produced four collision-safe Ground Dash segments and zero stamina. A fifth request started no action, spent nothing, and emitted one insufficient event.
- Each accepted chained segment stayed in the low `dash_loop`; only final/rejected continuation entered `dash_end`. All motion used `CharacterBody2D.velocity` and `move_and_slide()`, and the chained wall test stopped at the collider boundary.
- Regeneration remained zero through 0.59 seconds after spend, began after the 0.60-second threshold at 35 points/second, remained blocked during Dash/Dash Attack, and clamped to the configured maximum.
- Air Dash charged once and disabled `air_dash_available`; a second airborne Shift spent nothing. Air Dash Attack spent nothing extra, did not restore availability, and landing restored only availability while the zero-regeneration test value remained 75.
- The Main ProgressBar and numeric label updated to 75 immediately from the component signal. Insufficient feedback is a bounded tween, not a persistent flash.
- Existing immediate Attack buffering, Dash Attack transition/motion, locomotion, animation locks, Main startup, and preview startup all remain green.

### Manual acceptance requested

1. Tap Shift four times with the next tap late in each Dash and judge whether chained `dash_loop` motion feels seamless rather than visually restarting.
2. Hold Shift through a complete Dash and confirm it never repeats; then release and tap again to confirm a fresh edge is required.
3. Spend all four charges and judge the one-shot insufficient bar feedback; wait and confirm the bar starts climbing after the configured delay.
4. Verify one Air Dash per airtime, Air Dash-to-J Dash Attack, both facing directions, and wall contact in the Main trial scene.
5. Toggle `ACTION DEBUG HUD` off and confirm the production-facing stamina bar remains visible and camera-independent.

### Known limitations and handoff

- The stamina bar uses replaceable pixel-style `StyleBoxFlat` placeholders, not final UI art.
- Ground Dash chaining preserves the original direction and facing for the entire chain; a future explicit design decision is required before permitting per-segment turnarounds.
- Air Dash remains a single non-looping five-frame presentation and cannot chain regardless of spare stamina.
- Stamina currently pays only Dash-family starts. There are no upgrades, equipment modifiers, saves, consumables, enemies, damage, invulnerability, or formal skill framework.

## 2026-07-22 — Continuous Air Dash and ground-only stamina recovery (preflight)

### Goal

- Remove the one-Air-Dash-per-airtime qualification and make Ground/Air Dash chains share the same 100-point stamina pool as their only count limit.
- Add one-entry Air Dash and Dash Attack follow-up buffering, with per-segment direction selection and locked direction within each segment.
- Restrict regeneration and its delay countdown to grounded, non-Dash, non-Dash-Attack, non-Attack time.
- Split Air Dash presentation into `air_dash_start`, `air_dash_loop`, and `air_dash_end`, preserving the replaced five-frame source as a deprecated reference.

### Baseline audit

- Worktree is clean at `88118d4 feat: add chained dash stamina system`.
- `Player.air_dash_available` currently hard-limits Air Dash to one use and is reset on landing; `PlayerActionController.try_start_actions()` rejects airborne Dash when that flag is false.
- Ground Dash already supports one-entry edge-triggered chaining and spends 25 stamina per accepted segment, but Air Dash ignores later Shift edges.
- Stamina currently decrements its 0.60-second timer even while airborne/action-blocked, so a long airtime may permit immediate recovery on landing. This conflicts with the newly required grounded-only recovery timeline.
- Dash Attack currently rejects Shift entirely and clears the Dash buffer, so it cannot transition into a paid follow-up Ground/Air Dash.
- Production presentation contains segmented Ground Dash but only one five-frame `air_dash` one-shot.

### Planned files and tests

- Refactor the action controller and Player integration to remove Air Dash qualification, unify Ground/Air chain resolution, store one buffered per-segment direction, and continue from Dash Attack according to actual floor contact.
- Update stamina advancement, debug HUD, animation controller/builders/generator/preview, archive tooling, and all affected regressions.
- Add deterministic continuous-Air-Dash coverage and a repeatable movement-metrics runner; record single jump, debug double jump, four-Air-Dash reach, and current Main platform implications in `docs/design/level_metrics.md`.
- Run exact Godot 4.7.1 import, all existing regression suites, Main/preview rendering, collision tests, and diff checks.

### Scope guard

- No enemy, Boss, health, damage settlement, Hitbox/Hurtbox implementation, invulnerability, new attack, or map redesign is authorized.
- Continuous Dash remains edge-triggered; held Shift must never synthesize additional segments.
- Existing platforms will be measured and documented, not moved or globally raised.

### Delivered implementation

- Removed `Player.air_dash_available` and every landing/coyote qualification for Air Dash. Ground and Air now share the same paid segment path, 100-point pool, 25-point cost, 0.18-second motion time, 0.10-second one-entry Shift buffer, and 0.03-second minimum interval.
- Air Dash can chain repeatedly in one airtime while stamina can pay. Each buffered segment samples its own left/right direction, locks velocity/facing for that segment, zeros vertical velocity, and preserves gravity suspension across a successful continuation. Held Shift produces no new input edge.
- Split presentation into `air_dash_start` (2 frames, one-shot), `air_dash_loop` (3, looping), and `air_dash_end` (2, one-shot), all 20 FPS. A chain plays start once, loop through paid continuations, and end once. The superseded five PNGs were archived byte-identically under `assets/sprites/player/assassin/reference/deprecated_air_dash_five_frame/` before their production paths were removed.
- `PlayerStaminaComponent.advance()` now accepts positive recovery permission. Airborne/action-blocked time neither regenerates stamina nor decrements the 0.60-second delay. Landing does not refill or clear the timer; only grounded, action-free time advances toward 35 points/second recovery.
- Dash Attack clears pre-transition Dash input, accepts one new Shift edge during its action, and on completion starts a paid Ground/Air Dash from actual `CharacterBody2D.is_on_floor()` contact. The transition into Dash Attack is still free after its source Dash; the next segment costs exactly 25.
- Expanded optional diagnostics with floor contact, locomotion/action state, Ground/Air Dash type, chain number, buffered request/time, stamina/recovery state, direction, horizontal/vertical velocity, animation, and existing Attack data. The fixed stamina HUD remains signal-driven and camera-independent.
- Updated the production generator, archive/removal tooling, contact sheet, 16-animation SpriteFrames resource/controller/preview, Main laboratory copy, README, movement/animation/combat/stamina specifications, and tests. The preview layout was raised 50 px so all 16 selection and playback controls fit at 1280×720.
- Added `tests/player/measure_player_level_metrics.gd` and `docs/design/level_metrics.md`. At 60 physics ticks/s, measured from the real Player scene: single jump 153.59 px horizontal / 83.77 px rise; debug double jump 281.92 / 167.10; four paid Air Dashes 344.00 px action-only and 362.22 px from Dash-entry takeoff position to landing.
- Audited Main platforms without modifying them. Platform A/B widths (220/190 px) and the A→B edge gap (205 px) are below the 344 px chain envelope, so an already-elevated player can bypass their intermediate landing rhythm. Air Dash adds no lift: floor→B still exceeds the measured double-jump rise, and the continuous floor already makes both test platforms optional.

### Commands and actual results

1. `$GODOT_BIN --headless --path . --script scripts/tools/build_player_animation_assets.gd -- --archive-air-dash-source`
   - Exit 0; `PLAYER_AIR_DASH_ARCHIVE: 5 files, 0 failures`.
   - SHA-256 of the five archived sources: `7671ec…`, `1034bc…`, `3ac64f…`, `11584a…`, and `8b8727…`; each matched its former production file before deletion.
2. First `--production-only` generation attempt exposed an out-of-range contact-sheet row-color access. Godot printed a `SCRIPT ERROR` even though the script process returned 0; this run was not accepted.
   - Fixed the contact sheet for ten production rows and 1200×1840 output.
   - Rerun: `PLAYER_PRODUCTION_EXPORT: 33 files, 0 failures`, with no script error.
3. Exact Godot editor import, SpriteFrames build, and guarded obsolete-source removal:
   - `--headless --editor --path . --import --quit`: exit 0.
   - animation asset build: `PLAYER_SPRITE_FRAMES_BUILD: OK`, 16 names.
   - `--remove-archived-air-dash-source`: `5 files, 0 failures`; removal occurred only after byte comparison.
4. The first movement-metrics run found a pre-tree `@onready` access, and the next found an incorrectly parenthesized format expression. Both emitted `SCRIPT ERROR` and were rejected. After fixes, the exact runner produced:
   - `PLAYER_LEVEL_METRICS: PASS physics_fps=60 single_jump_range=153.59 single_jump_rise=83.77 double_jump_range=281.92 double_jump_rise=167.10 four_air_dash_range=344.00 four_air_dash_total_to_landing=362.22`.
5. Final exact Godot 4.7.1 import:
   - `$GODOT_BIN --headless --editor --path . --import --quit --log-file /tmp/nocturne_keep_air_chain_commit_import.log`
   - Exit 0; no parse, script, or resource errors.
6. Final serial regression suite using the same executable:
   - `validate_pixel_character_assets.gd`: `PASS (11 assets + board)`.
   - `validate_player_animation_assets.gd`: `PASS (33 frames + 4 byte-identical references)`; also validates both five-frame Dash archives.
   - `test_player_animation_system.gd`: `PASS (16 animations, segmented Ground/Air Dash verified)`.
   - `test_m1_player_movement.gd`: `PASS (movement, jump assists, collision, camera, six animations)`.
   - `test_m15_player_actions.gd`: `PASS (split Ground Dash, chained Air Dash, thrust Attack)`.
   - `test_dash_attack.gd`: `PASS (immediate J, transitions, air recovery, collision, debug HUD)`.
   - `test_fast_attack.gd`: `PASS (immediate response, single buffer, four-repeat chain, 0.25s Dash Attack)`.
   - `test_chain_dash_stamina.gd`: `PASS (edge chaining, four charges, shared Air/Ground pool, HUD, collision)`.
   - `test_continuous_air_dash.gd`: `PASS (four Air segments, mixed pool, direction, gravity, collision)`.
   - `measure_player_level_metrics.gd`: PASS with the values recorded above.
7. Main and preview runtime rendering:
   - Main: `--path . --write-movie /tmp/nocturne_keep_continuous_air_main.png --fixed-fps 30 --quit-after 2 --audio-driver Dummy`; exit 0, GL Compatibility on Apple M4, two 1280×720 frames.
   - Preview after layout correction: `--path . scenes/tools/player_animation_preview.tscn --write-movie /tmp/nocturne_keep_continuous_air_preview_v2.png --fixed-fps 20 --quit-after 2 --audio-driver Dummy`; exit 0, two 1280×720 frames.
   - Log search found no `ERROR`, `SCRIPT ERROR`, parse error, or warning. Original-resolution review confirmed crisp nearest-neighbor art, readable HUD/debug rows, and fully visible preview controls.
8. `git diff --check`: passed after removing documentation trailing whitespace.

### Automated acceptance results

1. Ground Dash chains from independent Shift edges: PASS.
2. Air Dash chains repeatedly in one airtime: PASS.
3. Full stamina accepts exactly four paid segments: PASS for Ground, Air, and 2+2 mixed use.
4. Fifth zero-stamina request is rejected: PASS.
5. Every accepted segment costs exactly 25: PASS.
6. Failed request spends nothing and signals insufficient once: PASS.
7. Airborne waiting leaves stamina and the 0.60-second timer unchanged: PASS.
8. Landing does not refill; recovery begins after 0.60 eligible grounded seconds: PASS.
9. Held Shift produces one segment/charge: PASS.
10. Timed independent Shift edges continue without an inserted standing/Fall phase: PASS.
11. Next Air segment can reverse direction: PASS.
12. Current Air segment ignores ordinary direction changes and keeps velocity/facing locked: PASS.
13. Air animation uses start once, loop during continuation, end once: PASS; contact sheet visually checked.
14. Air Dash→Dash Attack→buffered Air Dash: PASS.
15. Dash Attack source transition costs zero extra; follow-up costs one charge: PASS for grounded and airborne completion.
16. Continuous Air Dash stops at a wall through `move_and_slide()`: PASS.
17. Signal-driven bar and numeric label match the component: PASS.
18. Final import, all headless suites, Main, and preview contain no red errors: PASS.

### Manual acceptance requested

1. Jump and tap Shift four times near each segment end; judge whether `air_dash_start → air_dash_loop … → air_dash_end` feels continuous at 20 FPS.
2. During the next segment buffer, hold the opposite horizontal direction and confirm only the next paid segment flips; confirm the current segment never turns early.
3. Try Ground/Air mixed spending and verify the HUD reaches 75/50/25/0, then wait airborne and confirm it remains frozen until 0.60 seconds of eligible ground time.
4. Air Dash, press J, then Shift during Dash Attack; verify the follow-up uses the current contact domain and direction without restarting Dash Attack.
5. Test wall contact in both directions and toggle `ACTION DEBUG HUD` off to confirm the stamina bar remains fixed and readable.

### Known limitations and handoff

- The 0.10-second Dash buffer intentionally rewards a new Shift edge in the latter portion of each 0.18-second segment; earlier inputs expire rather than queue multiple future segments. Manual feel tuning may revise the window later.
- Ground Dash preserves its chain direction. Only Air Dash has approved per-segment turnaround behavior.
- Air Dash end begins gravity restoration during its two-frame recovery; there is no separate upward/downward/diagonal Dash or invulnerability.
- Continuous Air Dash materially widens optional traversal. Current Main remains a laboratory with continuous floor, not a production level; future rooms must preserve a single-jump main route and treat continuous Air Dash as a high-mobility route rather than a mandatory early-game gate.
- Hurt/Death remain preview placeholders. No enemy, health, damage settlement, Hitbox/Hurtbox, invulnerability, combo tree, Boss, or map redesign was added.

## 2026-07-22 — Configurable airborne stamina regeneration (preflight)

### Goal

- Allow stamina recovery during ordinary ascent and free fall at a configurable fraction of the existing grounded rate.
- Continue to block recovery during every stamina-consuming Dash/Dash-Attack action.
- Preserve current movement, gravity, jump, animation, input, collision, Dash cost, and HUD ownership.

### Baseline audit

- Clean worktree at `e8af02b feat: add continuous air dash stamina chains`.
- `PlayerStaminaComponent` owns `max_stamina=100`, `dash_stamina_cost=25`, `stamina_regen_delay=0.60`, `stamina_regen_rate=35`, the current value/timer, and typed UI signals.
- `Player` currently calls `advance(delta, was_on_floor and not action_controller.is_action_active())`; airborne time and all actions therefore freeze both regeneration and its delay.
- Successful Ground/Air Dash segments and direct Dash Attack are the only stamina spenders. Dash-to-Dash-Attack does not double-charge; a follow-up Dash pays normally. Jump, debug double jump, and normal Attack cost zero. No separate evade/dodge action exists.
- `PlayerStaminaHud` only observes `stamina_changed` and `stamina_insufficient`; it owns no resource math.

### Planned files and tests

- Add an exported 0–1 airborne multiplier to `player_stamina_component.gd`, keep the established 35/s ground rate, and derive the default 14/s airborne rate from multiplier 0.40.
- Pass contact state and a narrow stamina-action block from `Player`; expose that block query from `PlayerActionController` without changing action behavior.
- Update optional debug status, README, and stamina/movement specifications.
- Add deterministic component/integration coverage for ground rate, airborne rate, delay progress, Dash/Dash-Attack blocking, zero-cost Attack allowance, and signal-driven HUD updates; rerun all existing movement/action suites and Main startup.

### Scope guard

- Do not modify movement speed/acceleration, gravity, jump velocity/height, coyote time, input buffers, Dash physics, animation frames, collision, enemy/combat systems, or level geometry.
- Do not add stamina costs to Jump, Double Jump, or normal Attack in this task.

### Delivered implementation

- Added exported `airborne_stamina_regen_multiplier=0.40` to `PlayerStaminaComponent`. The existing grounded `stamina_regen_rate=35` is preserved, producing a default derived airborne rate of 14/s. `get_regeneration_rate(is_grounded)` is the single rate calculation path and supports inspector/runtime tuning without business-logic literals.
- Changed stamina advancement to accept `is_grounded` and `regeneration_blocked`. When unblocked, the existing 0.60-second delay now advances on ground or in ordinary air; recovery then uses the contact-appropriate rate. A blocked paid action freezes both value and delay exactly as before.
- Added `PlayerActionController.is_stamina_regeneration_blocked()`, limited to Ground Dash, Air Dash, and Dash Attack—the only current stamina-consuming action states. Zero-cost normal Attack, Jump, Double Jump, Jump Loop, and Fall do not block recovery.
- `Player` now forwards its pre-move floor contact plus that narrow action query. No velocity, gravity, jump, coyote, buffer, collision, animation, or action-transition values changed.
- Kept the functional HUD signal-only. `stamina_changed` continues to update its bar/value for ground and air recovery. Updated optional diagnostics to show `GROUND 35.0/s`, `AIR 14.0/s`, or `BLOCKED`.
- Updated README and movement/combat/stamina specifications. No scene structure or UI calculation ownership changed.

### Commands and actual results

1. Exact Godot 4.7.1 import after implementation:
   - `$GODOT_BIN --headless --editor --path . --import --quit --log-file /tmp/nocturne_keep_airborne_stamina_final_import.log`
   - Exit 0; no parse, script, resource, or warning output.
2. Exact serial regression suite:
   - `validate_pixel_character_assets.gd`: `PASS (11 assets + board)`.
   - `validate_player_animation_assets.gd`: `PASS (33 frames + 4 byte-identical references)`.
   - `test_player_animation_system.gd`: `PASS (16 animations, segmented Ground/Air Dash verified)`.
   - `test_m1_player_movement.gd`: `PASS (movement, jump assists, collision, camera, six animations)`.
   - `test_m15_player_actions.gd`: `PASS (split Ground Dash, chained Air Dash, thrust Attack)`.
   - `test_dash_attack.gd`: `PASS (immediate J, transitions, air recovery, collision, debug HUD)`.
   - `test_fast_attack.gd`: `PASS (immediate response, single buffer, four-repeat chain, 0.25s Dash Attack)`.
   - `test_chain_dash_stamina.gd`: `PASS (edge chaining, four charges, shared Air/Ground pool, HUD, collision)`.
   - `test_continuous_air_dash.gd`: `PASS (four Air segments, mixed pool, direction, gravity, collision)`.
   - `measure_player_level_metrics.gd`: primary envelopes unchanged—single jump 153.59/83.77, double jump 281.92/167.10, four-Air-Dash action range 344.00 px.
3. After adding explicit configurable-multiplier, normal-Attack, and Dash-Attack block assertions, both stamina suites were rerun independently and passed.
4. Main runtime render:
   - `$GODOT_BIN --path . --write-movie /tmp/nocturne_keep_airborne_stamina_main.png --fixed-fps 30 --quit-after 2 --audio-driver Dummy --log-file /tmp/nocturne_keep_airborne_stamina_main.log`
   - Exit 0; GL Compatibility on Apple M4, two 1280×720 frames, no red errors/warnings. Original-resolution inspection confirmed the fixed HUD and `REGEN GROUND 35.0/s` debug status are readable.
5. `git diff --check`: passed.

### Automated acceptance results

- Export default is 0.40 and changing it to 0.50 changes the derived air rate from 14.0 to 17.5 without code-branch edits.
- One unblocked grounded second restores exactly 35; one unblocked airborne second restores exactly 14 at defaults.
- Airborne time advances the 0.60-second delay. No value is restored before expiry; reduced-rate recovery begins afterward.
- Air Dash and Dash Attack leave both current value and delay unchanged throughout their action. Ground Dash uses the same blocking query.
- Zero-cost airborne normal Attack continues reduced-rate recovery. Jump and double jump remain zero-cost and use the ordinary air rule.
- Spend costs, four-segment shared pool, failed fifth Dash, Dash Attack no-double-charge, continuous Dash, wall collision, movement/jump metrics, and animation state tests remain green.
- The signal-driven HUD reflected an airborne component step from 75 to 89 immediately; it still owns no gameplay math.

### Manual acceptance requested

1. Spend stamina, jump/fall without Dashing, and confirm the bar starts rising slowly after the same 0.60-second delay.
2. Compare airborne recovery with grounded recovery and judge whether the default 40% relationship feels appropriate.
3. Air Dash or Dash Attack during the delay/recovery and confirm the bar freezes until the paid action finishes.
4. Use normal Attack in air and confirm it does not freeze the bar under the current zero-cost design.
5. Toggle `ACTION DEBUG HUD` and verify `GROUND 35.0/s`, `AIR 14.0/s`, and `BLOCKED` match the actual state.

### Known limitations and handoff

- Ground recovery remains 35/s rather than the prompt's illustrative 20/s value so this targeted change does not alter established ground recovery feel. The exported property remains configurable.
- Recovery delay is paused during paid Dash/Dash-Attack actions, preserving the prior action-blocking contract; ordinary airborne time now advances it.
- Normal Attack is allowed to recover because it currently costs zero. If later work assigns it a stamina cost, its block state must be changed with that same cost decision.
- No dodge action currently exists. No stamina cost, movement, combat, enemy, Boss, damage, Hitbox/Hurtbox, invulnerability, animation, or level change was added.

## 2026-07-22 — Development log documentation audit

Date: 2026-07-22
Status: complete — documentation-only audit; no Gameplay/content change and no Git commit/push

### Scope and document selection

- Searched the repository for development-log, changelog, progress, worklog, journal, roadmap, plan, and TODO-style filenames and references.
- Confirmed `docs/development_log.md` is the only document fulfilling the primary development-log role and is linked from README.
- Retained every historical entry and added the authoritative status section at the top of this file instead of creating a competing log.
- No `.gd`, scene, project setting, input map, resource, test, asset, import sidecar, plugin, Shader, audio, or export file was intentionally changed.

### Evidence inspected

- Git: clean `master` tracking `origin/master`, fourteen reachable commits through `e11638b`, and the commit subjects/stat history.
- Project/runtime configuration: `project.godot`, Main, Player, both tool scenes, player tuning resources, and the 16-animation SpriteFrames resource.
- Runtime ownership: Player movement, action, animation, stamina, HUD, debug overlay, and their explicit node dependencies/signals.
- Automated coverage: all ten scripts under `tests/player/` and `tests/tools/`.
- Documentation: README, the full historical development log, technical architecture, game-design baseline, known issues, player movement/animation/combat/stamina specifications, level metrics, and QA reports.
- Content inventory: player concept/production/reference/placeholder assets and the empty planned enemy, boss, level, combat, core, and system implementation directories.

### Current automated verification

Commands used the exact executable at the developer's local `GODOT_BIN` path; logs were written under `/tmp`.

1. `Godot --headless --editor --path . --import --quit`
   - Exit 0; no script/resource error or warning detected.
2. `validate_pixel_character_assets.gd`
   - `PIXEL_CHARACTER_VALIDATION: PASS (11 assets + board)`.
3. `validate_player_animation_assets.gd`
   - `PLAYER_ANIMATION_VALIDATION: PASS (33 frames + 4 byte-identical references)`.
4. `test_player_animation_system.gd`
   - `PASS (16 animations, segmented Ground/Air Dash verified)`.
5. `test_m1_player_movement.gd`
   - `PASS (movement, jump assists, collision, camera, six animations)`.
6. `test_m15_player_actions.gd`
   - `PASS (split Ground Dash, chained Air Dash, thrust Attack)`.
7. `test_dash_attack.gd`
   - `PASS (immediate J, transitions, air recovery, collision, debug HUD)`.
8. `test_fast_attack.gd`
   - `PASS (immediate response, single buffer, four-repeat chain, 0.25s Dash Attack)`.
9. `test_chain_dash_stamina.gd`
   - `PASS (edge chaining, four charges, shared Air/Ground pool, HUD, collision)`.
10. `test_continuous_air_dash.gd`
    - `PASS (four Air segments, mixed pool, direction, gravity, collision)`.
11. `measure_player_level_metrics.gd`, run three times
    - All three runs passed. Jump and four-Dash action-range values were identical; takeoff-to-landing totals were `360.33`, `362.22`, and `360.33` px.
12. `Godot --headless --path . --quit-after 2`
    - Exit 0; configured Main scene started and stopped without detected error/warning output.

### Audit conclusions

- Current automated evidence supports the M0, pixel-art tool, animation presentation, M1 locomotion, and M1.5 action/stamina implementation claims listed in the new status matrix.
- It does not establish final player feel, final art approval, editor Debugger cleanliness during an interactive session, export readiness, or full-playthrough quality; those remain pending manual verification.
- M2 combat architecture and all enemy/Boss/room/progression systems remain planned only. Existing Attack and Dash Attack are animation/input/movement prototypes without damage resolution.
- The dated M0 metadata in the design baseline, architecture, and known-issues documents is a documentation-maintenance issue, not evidence that current Gameplay is absent.
- Final document-only diff verification passed: `git diff --check` reported no error, and `git diff --name-only` listed only `docs/development_log.md`.

## 2026-07-22 — PLAYER-HP-001 player health data foundation

Date: 2026-07-22
Status: complete — unified Health mutation contract verified; no damage source or death state added

### Approved scope extension preflight

- The existing working-tree `HealthComponent` is the only Health implementation. It already owns maximum/current values, clamping, reset, and `health_changed`, but has no `take_damage`, `heal`, `died`, or death-signal guard.
- Player uses composed Animation, Action, Stamina, and Health nodes; locomotion uses `MovementState` while actions use a separate `ActionState`. Extending the existing Health node is the smallest architecture-consistent change.
- The current stamina HUD is signal-driven and does not own stamina math. No player health HUD or Gameplay death state exists; preview-only `death` art remains a placeholder.
- This extension will modify only the existing Health component and its isolated test, then update this log. Player scene structure, movement/actions, stamina/HUD, input, presentation, enemies, and levels remain out of scope.

### Goal

- Add a small, independently testable player health component with a configurable maximum, a clamped current value, unified damage/healing methods, reset-to-full behavior, typed change/death signals, and repeated-death protection.
- Attach the component to the existing Player scene without coupling it to movement, actions, animation, stamina, or UI.

### Planned files and tests

- Add `scripts/combat/health_component.gd` and attach `HealthComponent` under `scenes/player/player.tscn`.
- Add `tests/combat/test_health_component.gd` for defaults, custom maximum, lower/upper clamping, damage, healing, reset behavior, signal order, death guarding/rearming, and Player-scene composition.
- Run the exact Godot 4.7.1 editor import, the new isolated test, all ten existing regression scripts, and configured Main startup.

### Scope guard

- This task adds only Health value mutation semantics. It does not add damage sources, a player death/hurt state, invulnerability, knockback, respawn, health UI, Hitbox/Hurtbox, enemies, levels, or new input.
- Existing movement, jump, Dash, Attack, stamina, animation, and Main behavior must remain unchanged.

### Delivered implementation

- Added the statically typed, composition-first `HealthComponent` under `scripts/combat/`. It owns `max_health`, a read/write `current_health` property, clamping to `0...max_health`, `take_damage(amount)`, `heal(amount)`, `reset_to_full()`, `is_dead()`, typed `health_changed(current, maximum)`, and `died` notification.
- The exported maximum defaults to 100 and is sanitized to a minimum of one during `_ready()`. Current health initializes to the resulting maximum and emits its initial value once.
- Non-positive damage/healing requests are ignored. Overkill damage clamps to zero, excess healing clamps to maximum, and post-death damage cannot mutate the value.
- Unchanged assignments do not emit duplicate notifications. A lethal change emits `health_changed` before `died`; repeated zero/damage cannot emit `died` again. Restoring positive health through healing/reset rearms one later death event.
- Both the explicit setter, direct property assignment, damage, healing, and reset use the same clamp/signal path.
- Added a uniquely addressable `HealthComponent` child to the Player scene. `player.gd`, Main, input, movement, action, stamina, animation, and UI code were not changed.
- Added an isolated SceneTree test for default/custom/invalid maximum values, lower/upper clamping, damage/healing limits, lethal event order, death suppression/rearming, reset behavior, and Player scene composition.
- Godot generated tracked UID sidecars for the two new GDScript files during exact editor import.

### Files

- New: `scripts/combat/health_component.gd` and its generated `.uid`.
- Modified: `scenes/player/player.tscn` (one composed node and script resource only).
- New: `tests/combat/test_health_component.gd` and its generated `.uid`.
- Modified: `docs/development_log.md`, preserving the pre-existing documentation-audit changes.

### Commands and actual results

1. Exact engine check and final editor import:
   - `$GODOT_BIN --version` returned `4.7.1.stable.official.a13da4feb`.
   - `Godot --headless --editor --path . --import --quit --log-file /tmp/nocturne_keep_hp_damage_import.log`: exit 0; no parse, script, resource, or warning match.
2. New isolated test:
   - `Godot --headless --path . --script tests/combat/test_health_component.gd --log-file /tmp/nocturne_keep_hp_damage_test.log`.
   - Exit 0; damage, healing, clamping, signal order, death guard/rearm, and Player composition assertions passed.
3. Final serial regression suite using the same executable:
   - `validate_pixel_character_assets.gd`: `PASS (11 assets + board)`.
   - `validate_player_animation_assets.gd`: `PASS (33 frames + 4 byte-identical references)`.
   - `test_player_animation_system.gd`: `PASS (16 animations, segmented Ground/Air Dash verified)`.
   - `test_m1_player_movement.gd`: `PASS (movement, jump assists, collision, camera, six animations)`.
   - `test_m15_player_actions.gd`: `PASS (split Ground Dash, chained Air Dash, thrust Attack)`.
   - `test_dash_attack.gd`: `PASS (immediate J, transitions, air recovery, collision, debug HUD)`.
   - `test_fast_attack.gd`: `PASS (immediate response, single buffer, four-repeat chain, 0.25s Dash Attack)`.
   - `test_chain_dash_stamina.gd`: `PASS (edge chaining, four charges, shared Air/Ground pool, HUD, collision)`.
   - `test_continuous_air_dash.gd`: `PASS (four Air segments, mixed pool, direction, gravity, collision)`.
   - `measure_player_level_metrics.gd`: PASS; unchanged primary values of 153.59/83.77 single jump, 281.92/167.10 debug double jump, and 344.00 four-Air-Dash action range.
4. Configured Main startup:
   - `Godot --headless --path . --quit-after 2 --log-file /tmp/nocturne_keep_hp_damage_main.log`: exit 0.
5. Final suite log scan:
   - No `SCRIPT ERROR`, `ERROR:`, `WARNING:`, parse error, or missing-resource match.

### Verification note

- The first aggregate regression attempt used `status` as a zsh variable and stopped after its first passing test because that name is read-only; the wrapper was corrected without changing project files.
- A subsequent aggregate run observed one transient `Preview did not play dash_start` assertion in `test_m15_player_actions.gd`. The test then passed three consecutive isolated runs and passed again in the final full serial suite. No animation/preview code was changed. This is recorded as an existing one-frame preview-test timing sensitivity, not treated as a Health regression.

### Scope result and handoff

- PLAYER-HP-001 acceptance is satisfied at the reusable component-contract level. There is intentionally no visible health UI, damage source, death state, or current Gameplay caller of the mutation methods.
- No manual player-feel acceptance is required for this isolated contract. A future health HUD, hazard, enemy attack, or death-state task will require separate approval and verification.
- Recommended next task, subject to explicit approval: a signal-driven player Health HUD that observes this component without owning or mutating its values.
- No Git commit or push was performed. The pre-existing uncommitted development-log audit remains in the same working-tree file alongside this incremental record.

## 2026-07-22 — PLAYER-HP-002 signal-driven player Health HUD

Date: 2026-07-22
Status: complete — automated and visual verification passed

### Goal

- Add a fixed player Health bar above the existing Stamina bar in `Main/HUD`, matching its dimensions, margins, typography, and numeric presentation.
- Keep Health data exclusively in `HealthComponent`; the HUD observes `health_changed`, initializes from current state, and supports explicit rebinding without per-frame polling.

### Planned files and tests

- Add `scripts/ui/player_health_hud.gd` as a presentation-only, typed, rebindable observer.
- Modify `scenes/main/main.tscn` to add `HealthContainer`, `HealthValue`, and `HealthBar` while preserving the existing Stamina and debug HUD ownership/paths.
- Add `tests/ui/test_player_health_hud.gd` for initial state, damage/healing/reset signal updates, progress limits, old-signal disconnection during rebinding, and Stamina HUD regression.
- Run exact Godot 4.7.1 import, the new HUD test, all eleven current tests, configured Main startup, and a nearest-neighbor graphical capture for visual inspection.

### Scope guard

- Do not add damage sources, player death state/prompt, respawn, spawn point, enemies, Hitbox/Hurtbox, effects, sound, low-health feedback, or health-bar animation.
- Do not modify player movement/actions, Health mutation semantics, Stamina calculation/HUD script, debug overlay logic, input, collision, or level geometry.

### Delivered implementation

- Added `PlayerHealthHud` as a typed, presentation-only `Control`. It resolves the configured Player `HealthComponent`, subscribes to `health_changed`, and immediately renders the component's current state without `_process()` polling.
- Added `bind_health_component(component)` for future Player replacement. Rebinding disconnects the previous valid component before subscribing to the new one; `_exit_tree()` also disconnects. An explicit unbound state shows `--- / ---` rather than inventing Health data.
- Added `Main/HUD/HealthContainer` above the existing `StaminaContainer`, using the same 224×66 px container, 204×20 px bar, margins, 12 px typography, dark background, cool border, fixed CanvasLayer, and `%03d / %03d` numeric format. Health uses a muted crimson fill; Stamina retains its existing amber fill and node paths.
- Moved only the Stamina container's screen offsets from y=24–90 to y=100–166. `PlayerStaminaHud`, its signal/calculation ownership, and the separate `Interface/Panel/ActionDebug` hierarchy were not changed.
- Added integration coverage for initial 100/100 state, `take_damage(10)`, `heal(10)`, `reset_to_full()`, ProgressBar bounds, Health rebinding, old-signal disconnection, new-signal updates, Stamina consumption/display, and debug-HUD preservation.
- Godot generated `.gd.uid` sidecars for the new HUD and test scripts during editor import.

### Files

- New: `scripts/ui/player_health_hud.gd` and generated `.uid`.
- Modified: `scenes/main/main.tscn` for Health HUD nodes/styles and Stamina vertical placement only.
- New: `tests/ui/test_player_health_hud.gd` and generated `.uid`.
- Modified: `docs/development_log.md`, preserving all pre-existing uncommitted audit and PLAYER-HP-001 history.

### Commands and actual results

1. Exact Godot 4.7.1 editor import:
   - `Godot --headless --editor --path . --import --quit --log-file /tmp/nocturne_keep_hp_hud_import.log`.
   - Exit 0; `PlayerHealthHud` registered and no parse/script/resource warning was detected.
2. New HUD integration test:
   - Initial run correctly passed the Health, Stamina, and rebind assertions but failed the test-only debug path `Interface/ActionDebug`; the actual unchanged path is `Interface/Panel/ActionDebug`.
   - After correcting only that assertion path: `Godot --headless --path . --script tests/ui/test_player_health_hud.gd --log-file /tmp/nocturne_keep_hp_hud_test_v2.log`.
   - Exit 0; `PLAYER_HEALTH_HUD_TEST: PASS (initial, signals, reset, rebind, Stamina regression)`.
3. Final serial suite using the exact executable:
   - `test_health_component.gd`: `PASS (health, damage, healing, death guard, Player composition)`.
   - `test_player_health_hud.gd`: `PASS (initial, signals, reset, rebind, Stamina regression)`.
   - `validate_pixel_character_assets.gd`: `PASS (11 assets + board)`.
   - `validate_player_animation_assets.gd`: `PASS (33 frames + 4 byte-identical references)`.
   - `test_player_animation_system.gd`: `PASS (16 animations, segmented Ground/Air Dash verified)`.
   - `test_m1_player_movement.gd`: `PASS (movement, jump assists, collision, camera, six animations)`.
   - `test_m15_player_actions.gd`: `PASS (split Ground Dash, chained Air Dash, thrust Attack)`.
   - `test_dash_attack.gd`: `PASS (immediate J, transitions, air recovery, collision, debug HUD)`.
   - `test_fast_attack.gd`: `PASS (immediate response, single buffer, four-repeat chain, 0.25s Dash Attack)`.
   - `test_chain_dash_stamina.gd`: `PASS (edge chaining, four charges, shared Air/Ground pool, HUD, collision)`.
   - `test_continuous_air_dash.gd`: `PASS (four Air segments, mixed pool, direction, gravity, collision)`.
   - `measure_player_level_metrics.gd`: PASS with unchanged 153.59/83.77 single-jump, 281.92/167.10 debug-double-jump, and 344.00 four-Air-Dash action envelopes.
4. Configured Main startup:
   - `Godot --headless --path . --quit-after 2 --log-file /tmp/nocturne_keep_hp_hud_main_headless.log`: exit 0.
   - All suite/Main logs scanned clean for script error, error, warning, parse error, and missing resource.
5. Graphical Main capture:
   - `Godot --path . --write-movie /tmp/nocturne_keep_hp_hud_main.png --fixed-fps 30 --quit-after 2 --audio-driver Dummy --log-file /tmp/nocturne_keep_hp_hud_main_graphical.log`.
   - Exit 0; GL Compatibility on Apple M4, two 1280×720 frames. Original-resolution inspection confirmed aligned Health/Stamina blocks, legible values, distinct fills, and no debug-HUD overlap.

### Automated acceptance results

- Main starts at Health 100/100; bar bounds/value and text match the component.
- `take_damage(10)` updates the bar to 90 and text to `090 / 100` synchronously through `health_changed`; `heal(10)` and `reset_to_full()` restore 100/100.
- Rebinding to a 60-maximum replacement initializes 60/60, ignores later signals from the old component, and follows the new component to 45/60.
- Stamina still spends to 75 and renders `075 / 100`; its script and gameplay state are unchanged.
- Debug HUD structure, all movement/action/stamina regressions, Main startup, and measured movement envelopes remain intact.

### Manual acceptance requested

1. Run Main and confirm the upper-right HEALTH block sits directly above STAMINA with equal width/margins and remains fixed while the camera moves.
2. Confirm muted crimson Health and amber Stamina remain distinguishable against the moon/background at the target display.
3. Health mutation currently has no Gameplay input or enemy source; use the automated test or Remote Inspector only if manually checking value changes. Do not interpret the absence of in-game damage as a HUD failure.

### Scope result and handoff

- PLAYER-HP-002 is complete. No death state/prompt, respawn, spawn point, enemy, damage area, Hitbox/Hurtbox, health animation/effect, or sound was added.
- No plan/roadmap document exists to synchronize; this primary development log contains the task status.
- The next ordered task is `PLAYER-DEATH-001`, but it remains unapproved and was not started.
- No Git commit or push was performed; final output will report the complete working-tree diff, including preserved earlier uncommitted changes.

## 2026-07-22 — PLAYER-DEATH-001 player death state

Date: 2026-07-22
Status: complete — automated and graphical death-state verification passed

### Goal

- Enter one explicit Player death state when the existing `HealthComponent.died` signal fires, cancel active movement/actions, block subsequent Gameplay input and Stamina processing, and expose a one-shot one-second delay hook for the future respawn task.
- Add a temporary `YOU DIED / 已阵亡` HUD prompt and one clearly marked development-only button that applies 25 Health damage for manual testing.

### Planned files and tests

- Modify `scripts/player/player.gd` to own the life-state transition and typed death signals while preserving the existing movement/action state split.
- Add a narrow action-controller cancellation method so an in-progress Dash/Attack cannot remain active after death.
- Add presentation-only `scripts/ui/player_death_hud.gd`, test-only `scripts/tools/player_death_test_button.gd`, and their Main scene nodes.
- Add `tests/player/test_player_death_state.gd` for one-shot death entry, action/velocity cancellation, input/Stamina lockout, zero-Health HUD, prompt visibility, delay hook, and repeated-damage protection.
- Run exact Godot 4.7.1 import, the new death test, all twelve current tests, Main startup, and graphical/manual-button verification.

### Scope guard

- The existing eight-frame `death` animation remains explicitly placeholder art; using it does not approve or create a final death animation.
- Do not add respawn movement/reset, spawn points, checkpoints, enemies, Hitbox/Hurtbox, damage areas, invulnerability, knockback, game-over flow, effects, sound, or input-map actions.
- Preserve the unrelated current `player_sprite_frames.tres` UID-normalization diff without editing or reverting it.

### Delivered implementation

- Added a separate `Player.LifeState` (`ALIVE`, `DEAD`) rather than expanding or disturbing the six-state locomotion enum. `HealthComponent.died` is connected once during Player readiness.
- Death entry is guarded and performs one transition: sets the life state, zeros velocity/coyote/jump buffers/pending movement, cancels active action data, clears action buffers, resets presentation arbitration, plays the existing explicitly placeholder `death` animation, and emits `death_state_entered`.
- Dead physics processing advances only the one-second `death_state_delay`, forces zero velocity through the existing `CharacterBody2D.move_and_slide()` path, and returns before input, jump, action, Stamina, and locomotion animation processing. It emits `death_delay_elapsed` once and does not respawn.
- Added `PlayerActionController.cancel_all_actions()` as a narrow non-emitting cancellation path. It clears current Dash/Attack state, timing, buffers, action response data, and chain count without falsely reporting a normal action completion that could resume locomotion.
- Added a temporary fixed `DeathOverlay` displaying `YOU DIED / 已阵亡`; it only observes `Player.death_state_entered`. No health/death state is stored in the HUD.
- Added `Interface/DamageTestButton`, labeled `DEV TEST · TAKE 25 DAMAGE`. Its test-only script resolves the current Player Health component on each independent click and calls `take_damage(25)`; it adds no input action or damage area.
- Added deterministic death coverage that starts a real Dash, spends 25 Stamina, kills through four button presses, verifies Dash cancellation, zero Health HUD, prompt/placeholder animation, blocked movement/jump/Dash/Attack, frozen Stamina, one death event, one delay event, repeated-damage protection, and absence of respawn.
- Godot generated `.gd.uid` sidecars for the new death HUD, test button, and test scripts during editor import.

### Files

- Modified: `scripts/player/player.gd` for life-state ownership and death transition only.
- Modified: `scripts/player/player_action_controller.gd` for the narrow cancellation method.
- New: `scripts/ui/player_death_hud.gd` and generated `.uid`.
- New: `scripts/tools/player_death_test_button.gd` and generated `.uid`.
- Modified: `scenes/main/main.tscn` for the temporary prompt and development-only button.
- New: `tests/player/test_player_death_state.gd` and generated `.uid`.
- Modified: `docs/development_log.md`, retaining all earlier uncommitted task history.
- Unrelated/pre-existing and preserved: `resources/player/player_sprite_frames.tres` UID serialization diff; this task did not edit its animation data.

### Commands and actual results

1. Exact Godot 4.7.1 import:
   - `Godot --headless --editor --path . --import --quit --log-file /tmp/nocturne_keep_player_death_import.log`.
   - Exit 0; `PlayerDeathHud` and `PlayerDeathTestButton` registered with no parse/script/resource warning.
2. Isolated death integration:
   - `Godot --headless --path . --script tests/player/test_player_death_state.gd --log-file /tmp/nocturne_keep_player_death_test.log`.
   - Exit 0; `PLAYER_DEATH_STATE_TEST: PASS (single entry, lockout, HUD, delay, no respawn)`.
3. Final serial suite with the exact executable:
   - `test_health_component.gd`: PASS.
   - `test_player_health_hud.gd`: PASS.
   - `test_player_death_state.gd`: PASS.
   - Both asset validators: PASS.
   - Animation system, M1 movement, M1.5 actions, Dash Attack, fast Attack, chained Stamina Dash, continuous Air Dash, and level-metrics tests: all PASS.
   - Level metrics remain unchanged at 153.59/83.77 single jump, 281.92/167.10 debug double jump, and 344.00 four-Air-Dash action range.
4. Configured Main startup:
   - `Godot --headless --path . --quit-after 2 --log-file /tmp/nocturne_keep_player_death_main_headless.log`: exit 0.
   - All thirteen suite/Main logs scanned clean for script error, error, warning, parse error, and missing resource.
5. Graphical automated button run:
   - `Godot --path . --script tests/player/test_player_death_state.gd --write-movie /tmp/nocturne_keep_player_death_visual.png --fixed-fps 60 --audio-driver Dummy --log-file /tmp/nocturne_keep_player_death_visual.log`.
   - Exit 0; GL Compatibility on Apple M4, 95 frames at 1280×720. Frames 20 and 70 were inspected at original resolution.
   - Visual result: Health `000 / 100`, Stamina frozen at `075 / 100`, debug animation `death`, readable centered prompt, visible development button, and placeholder sprite settling to its final death pose.

### Automated acceptance results

- Four independent button presses cause 25 damage each and enter death exactly once at zero Health.
- A Ground Dash active at the lethal hit is cancelled; velocity becomes and remains zero.
- Held move, jump, Dash, and Attack inputs for twelve physics frames cannot move the Player, restart an action, or spend/regenerate Stamina.
- Post-death damage does not re-enter Player death. The one-second delay signal emits once and remains one after further waiting.
- Health HUD stays at zero and the death prompt stays visible. PLAYER-DEATH-001 intentionally leaves the Player dead after the delay.
- All pre-existing Health, HUD, movement, action, animation, Stamina, collision, and metrics tests remain green.

### Manual acceptance requested

1. In the opened Main window, click `DEV TEST · TAKE 25 DAMAGE` four times; confirm Health steps 100→75→50→25→0 and the prompt appears only at zero.
2. Start moving, Dashing, or attacking before the fourth click; confirm the lethal hit stops the action and subsequent A/D, Space, Shift, and J do nothing.
3. Wait beyond one second and confirm no respawn occurs yet; PLAYER-RESPAWN-001 remains a separate approval gate.
4. Treat the current death frames as placeholder art, not visual approval of the final death animation.

### Scope result and handoff

- PLAYER-DEATH-001 is complete. No spawn point, respawn/reset, enemy, damage area, Hitbox/Hurtbox, invulnerability, checkpoint, game over, effect, sound, or final death animation was added.
- The next ordered task is `PLAYER-RESPAWN-001`, but it remains unapproved and was not started.
- No Git commit or push was performed. Final diff reporting separates this task from the preserved earlier work and unrelated SpriteFrames UID normalization.

## 2026-07-22 — PLAYER-RESPAWN-001 single spawn point and player respawn

Date: 2026-07-22
Status: complete — automated and graphical verification passed; manual acceptance requested

### Approved scope preflight

- `PLAYER-DEATH-001` currently emits `death_delay_elapsed` once after its configured one-second delay, but intentionally leaves the Player dead. There is no spawn point, respawn coordinator, position reset, Health/Stamina restoration, or death-prompt dismissal.
- Player already owns the internal state that must be reset: life state, velocity, coyote/jump buffers, air-jump availability, action controller, movement animation, Health, and Stamina. Main owns the current test-level Player instance and is therefore the narrow scene-level owner for selecting a spawn point.
- The Health and Stamina HUDs already observe their components' typed signals. Calling the existing `reset_to_full()` methods will update both displays without adding polling or UI-owned Gameplay data.
- The existing death integration test explicitly verifies that no respawn occurs. It will retain that isolated contract by disabling the new coordinator before lethal damage; a separate respawn integration test will own death-to-respawn assertions.

### Goal

- Add one `Marker2D` spawn point to the current Main test scene and a typed, composition-based coordinator that responds to the Player's existing death-delay hook.
- Respawn the Player at that point exactly once per death, restore Health and Stamina, clear movement/action/jump/death timers, restore input and idle presentation, dismiss the temporary death prompt, and keep the child Camera2D following the same Player instance.

### Planned files and tests

- Modify `scripts/player/player.gd` with a single public `respawn_at(global_spawn_position)` reset boundary and typed `respawned` signal.
- Add `scripts/systems/player_respawn_controller.gd`; modify `scenes/main/main.tscn` with `World/SpawnPoint` and `PlayerRespawnController` using exported NodePaths.
- Modify `scripts/ui/player_death_hud.gd` to hide on the Player's typed respawn signal.
- Update `tests/player/test_player_death_state.gd` to disable the coordinator for isolated death-state verification; add `tests/player/test_player_respawn.gd` for position, Health, Stamina, actions, prompt, camera, duplicate protection, repeated cycles, and restored movement.
- Run the exact Godot 4.7.1 import, both focused death/respawn tests, the complete existing regression suite, configured Main startup, and a graphical death-to-respawn capture.

### Scope guard

- This task adds only one fixed spawn point and delayed Player reset. It does not add checkpoints, multiple spawn selection, enemies, damage areas, Hitbox/Hurtbox, invulnerability, knockback, game-over flow, final death/respawn art, sound, save state, or new input.
- Preserve all pre-existing uncommitted Health/HUD/death work and the unrelated `player_sprite_frames.tres` UID-normalization diff. Do not change movement feel, action timing, collision shapes, level geometry, Input Map, or animation frame data.

### Delivered implementation

- Added `Player.respawn_at(global_spawn_position)` as the single atomic reset boundary. It rejects calls while alive; for a dead Player it teleports to the approved marker, clears velocity, coyote/jump/input/landing/action/death state, restores the configured air-jump count, resets Health and Stamina through their existing component APIs, restores Idle animation/locomotion, resets Camera2D smoothing, emits typed `movement_state_changed` and `respawned` signals, and returns success.
- Added `PlayerRespawnController` under `scripts/systems/`. It resolves Player and `Marker2D` through typed exported NodePaths, observes the existing one-shot `death_delay_elapsed`, guards re-entry, calls the Player-owned reset once, and emits its own typed level-level notification. Its exported `enabled` switch supports isolated death-state testing without changing production defaults.
- Added `World/SpawnPoint` at the current safe floor spawn `(320, 612)` and a Main-level `PlayerRespawnController`. This is one fixed test spawn, not a checkpoint/session system.
- Updated the presentation-only `PlayerDeathHud` to observe `Player.respawned` and hide itself. Health and Stamina bars continue to update from their component signals; no HUD owns or mutates Gameplay data.
- Preserved the death-state test by disabling the coordinator before lethal damage, so it still proves the one-shot dead-state contract independently. Added a separate respawn integration test that executes two complete death cycles and verifies delay, one respawn per death, position, Health/Stamina/timers, action/jump state, prompt/HUD, Camera parentage, input recovery, and death-signal rearming.
- Godot 4.7.1 import generated UID sidecars for the new controller and respawn test scripts.

### Files

- Modified: `scripts/player/player.gd` for the typed respawn signal, Camera reference, and atomic reset method.
- New: `scripts/systems/player_respawn_controller.gd` and generated `.uid`.
- Modified: `scripts/ui/player_death_hud.gd` to dismiss on respawn.
- Modified: `scenes/main/main.tscn` for one `Marker2D` and the coordinator node.
- Modified: `tests/player/test_player_death_state.gd` to isolate death behavior by disabling the coordinator.
- New: `tests/player/test_player_respawn.gd` and generated `.uid`.
- Modified: `docs/development_log.md`, retaining all prior uncommitted history.
- Preserved unrelated/pre-existing changes, including `resources/player/player_sprite_frames.tres` UID normalization; this task did not edit animation data.

### Commands and actual results

1. Exact engine and editor import:
   - `$GODOT_BIN --version` returned `4.7.1.stable.official.a13da4feb`.
   - `Godot --headless --editor --path . --import --quit --log-file /tmp/nocturne_keep_player_respawn_import.log`: exit 0; the new controller/test classes registered without parse, script, resource, or warning output.
2. Focused contract tests:
   - `Godot --headless --path . --script tests/player/test_player_death_state.gd --log-file /tmp/nocturne_keep_player_death_after_respawn.log`: exit 0; isolated death entry, lockout, prompt, one-shot delay, and no-respawn assertions passed with the coordinator disabled.
   - `Godot --headless --path . --script tests/player/test_player_respawn.gd --log-file /tmp/nocturne_keep_player_respawn_test.log`: exit 0; `PLAYER_RESPAWN_TEST: PASS (delay, reset, HUD, repeat cycle, input recovery)`.
3. Final serial regression suite with the same executable:
   - All fourteen scripts passed: Health component; Health HUD; death state; respawn; both asset validators; animation system; M1 movement; M1.5 actions; Dash Attack; fast Attack; chained Dash/Stamina; continuous Air Dash; and level metrics.
   - Stable metrics remain 153.59/83.77 single jump, 281.92/167.10 debug double jump, and 344.00 four-Air-Dash action range.
4. Scene startup checks:
   - `Godot --headless --path . --quit-after 2 --log-file /tmp/nocturne_keep_respawn_main_v2.log`: exit 0.
   - `Godot --headless --path . res://scenes/player/player.tscn --quit-after 2 --log-file /tmp/nocturne_keep_respawn_player_scene_v2.log`: exit 0, confirming Player remains independently instantiable.
   - Final logs contained no `SCRIPT ERROR`, `ERROR:`, `WARNING:`, parse error, or missing-resource match.
5. Graphical death-to-respawn run:
   - `Godot --path . --script tests/player/test_player_respawn.gd --write-movie /tmp/nocturne_keep_player_respawn_visual.png --fixed-fps 60 --audio-driver Dummy --log-file /tmp/nocturne_keep_player_respawn_visual.log`: exit 0; GL Compatibility on Apple M4, 111 frames at 1280×720.
   - Frames 30 and 75 were inspected at original resolution. Frame 30 shows zero Health, frozen 75 Stamina, death animation/debug state, and the centered prompt. Frame 75 shows the Player back on the safe floor marker, Idle, prompt hidden, and both HUD values restored to 100/100.

### Automated acceptance results

- Lethal damage enters the existing dead state first; no respawn occurs before the configured one-second delay.
- Each delay expiry produces exactly one respawn. Waiting additional frames produces no duplicate, and a second lethal cycle independently respawns exactly once, confirming Health death signaling and Player timers rearm correctly.
- The Player returns to `(320, 612)` with zero velocity, zero death/coyote/jump-buffer timers, one Debug air jump restored, no active Dash/Attack, Idle state/presentation, full Health, full Stamina, and zero Stamina regeneration delay.
- The temporary prompt hides and both signal-driven HUD bars/numbers restore to 100/100. Movement input works again after respawn.
- The same Camera2D remains a child of the same Player instance and smoothing is reset after the teleport. Graphical capture confirms the camera follows the respawned position.
- All prior animation, movement, action, Stamina, collision, asset, and metrics regressions remain green.

### Manual acceptance requested

1. Run Main and move away from the initial floor position.
2. Spend some Stamina, then click `DEV TEST · TAKE 25 DAMAGE` until Health reaches zero; confirm input locks and the death prompt appears.
3. Wait approximately one second; confirm the Player returns to the initial safe floor position, prompt disappears, Health/Stamina both read `100 / 100`, and movement/jump/Dash/Attack work again.
4. Repeat the cycle once to confirm no duplicate or stuck respawn. Treat the current death presentation as placeholder art.

### Known limitations and handoff

- This is one fixed Main-scene spawn with a direct delayed reset. It does not choose checkpoints, persist a spawn across scenes, provide post-respawn invulnerability, reset enemies, or implement a game-over/session flow.
- Because no enemy or damage area exists, immediate repeated damage at the spawn is not yet possible or tested. That protection belongs to a later approved damage/combat-loop task.
- No movement, Input Map, action timing, collision shape, animation frame, enemy, Hitbox/Hurtbox, or damage-source logic was changed.
- `PLAYER-RESPAWN-001` is complete. The next ordered task remains `ENEMY-BASE-001`, but it was not started and requires explicit approval.
- No Git commit or push was performed. Final diff reporting separates this task from preserved earlier work and the unrelated SpriteFrames UID normalization.

## 2026-07-23 — Player death presentation sequence

Date: 2026-07-23
Status: complete — asset, timing, regression, and graphical verification passed; manual visual acceptance requested

### Approved scope preflight

- The active `death` animation is still an eight-frame placeholder assembled from shifted standing art at 8 FPS. It does not show a fall, horizontal corpse, or released daggers.
- `Player` currently starts that placeholder animation and advances a fixed one-second internal death timer. `PlayerRespawnController` listens to `death_delay_elapsed` and respawns immediately when that timer expires; there is no presentation-completion gate.
- Player input/action/Stamina lockout and one-shot death-state entry already exist and pass tests. There is no active Hitbox/Hurtbox or damage shape to disable; cancelling `PlayerActionController` already removes the current attack/dash state and reserved hit-window animation.
- No ghost texture, ghost node, death-sequence component, or `player_respawn_spec.md` exists. The current single Main `SpawnPoint` and atomic `Player.respawn_at()` reset contract are functional and should be preserved.

### Goal

- Replace the placeholder death presentation with five original 64×64 pixel frames that progress from lethal imbalance to a clearly horizontal body, with the main and off-hand daggers visibly released beside it.
- Add one original transparent hooded-face ghost texture and a composed death-sequence controller that waits for the body animation, floats the ghost upward 8–16 pixels, holds it for exactly 0.50 seconds, cleans it up, and only then authorizes the existing respawn coordinator.

### Planned files and tests

- Add a deterministic Godot Image generator under `scripts/tools/` and generate `assets/sprites/player/assassin/death/death_01.png` through `death_05.png` plus `assets/sprites/player/assassin/death/ghost_hooded_face.png`.
- Update `PlayerSpriteFramesBuilder` and the persistent SpriteFrames resource to use five production death frames at approximately 0.45 seconds total.
- Add `scripts/player/player_death_sequence.gd` and compose it with a nearest-neighbor `GhostSprite` in `scenes/player/player.tscn`.
- Narrow `player.gd` to death-state ownership and airborne corpse gravity; change `PlayerRespawnController` to listen to typed death-sequence completion instead of a fixed Player timer.
- Update death/respawn/animation validators and add focused death-presentation timing/cleanup assertions; update `docs/design/player_animation_spec.md`, create `docs/design/player_respawn_spec.md`, and complete this log entry.

### Scope guard

- Do not add enemies, Bosses, damage resolution, Hitbox/Hurtbox nodes, invulnerability, checkpoints, new inputs, sound, particles, RigidBody dagger physics, or unrelated movement/action changes.
- Preserve the current fixed Main spawn, Health/Stamina reset behavior, all reference assets, and every pre-existing uncommitted change. The old placeholder death PNGs remain as unreferenced historical material rather than being deleted.

### Delivered implementation

- Added a deterministic, statically typed Godot Image generator for five original 64×64 death frames and one transparent hooded-face ghost. The active frames move from lethal imbalance through backward collapse to a low horizontal corpse. `death_03` visibly releases both weapons; `death_05` leaves the longer main dagger in front and shorter off-hand dagger on the opposite side without introducing physics bodies.
- Rebuilt `player_sprite_frames.tres` so `death` uses the production `death/death_01...05.png` sequence at 11.111111 FPS, non-looping, for approximately 0.45 seconds. The final wide/low silhouette shares source ground row `y=60`; every body frame also passes the existing nearest-neighbor 48×48 readability path. The previous eight placeholder death PNGs remain unmodified and unreferenced.
- Added a 64×64 pale-blue/white semi-transparent ghost with a front-facing hood, dark face opening, two sharp eye highlights, and a restrained alpha halo. It is a single nearest-neighbor `Sprite2D`, not a particle system or generated runtime blur.
- Added composed `PlayerDeathSequence`. It listens to typed Player life-cycle signals, starts the locked body animation once, reveals the ghost only after `death_05`, floats it upward 14 pixels over 0.35 seconds, holds it visibly for 0.50 seconds, hides it, then emits `sequence_completed`. Its generation guard and single owned Tween prevent late or duplicated completion; respawn cleanup resets the ghost to its hidden default state.
- Removed the parallel fixed one-second Player death timer. Player now owns only `LifeState.DEAD`, action/input/Stamina lockout, and safe dead-body vertical gravity; an airborne dead Player falls without steering. `PlayerRespawnController` listens only to `PlayerDeathSequence.sequence_completed`, so body/ghost presentation must finish before `respawn_at()` can restore the Player.
- Extended automated coverage for five-frame metadata, 64×64/import/mipmap/palette rules, unique frame hashes, final corpse bounds/baseline, ghost partial alpha, sequence phase ordering, 14-pixel rise, 0.50-second pause, no early respawn, duplicate prevention, cleanup, two complete respawn cycles, and restored control/HUD.
- Updated the animation specification and added a dedicated death/respawn ownership, timing, cleanup, and limitation specification.

### Generated PNGs

| Path | Bytes | SHA-256 | Purpose |
| --- | ---: | --- | --- |
| `assets/sprites/player/assassin/death/death_01.png` | 690 | `6f40a823b45b0126cd516281d0052a798af1555df6a6d345f310f60f85aad5b3` | Lethal imbalance |
| `assets/sprites/player/assassin/death/death_02.png` | 664 | `f76d5f44a547e72d3e68aaff8a82919426a9e526c83150cdc56c3f9540dbacf3` | Backward fall |
| `assets/sprites/player/assassin/death/death_03.png` | 579 | `254ad829307a67828e7e502d039a183eec2a53d66f240df1d7e68b5ac2992085` | Near-ground weapon release |
| `assets/sprites/player/assassin/death/death_04.png` | 555 | `4aeffb49fd6bff316d985a07a2af9f54d6396d2a1f814542c576d59b363cad93` | Horizontal impact |
| `assets/sprites/player/assassin/death/death_05.png` | 548 | `4aba4225c45209a42379971f8eb728c8e9729b035c9465016bae1b2d5542b922` | Still corpse and detached daggers |
| `assets/sprites/player/assassin/death/ghost_hooded_face.png` | 483 | `29853c753398a327b18ffb36d9bcdc72308a7bc4cd54f319e6700cdc9128ede9` | Semi-transparent hooded spirit |

All six are 64×64 RGBA PNG sources with transparent backgrounds, no source mipmaps, Lossless Godot import, and Nearest canvas display.

### Files

- New: `scripts/tools/pixel_player_death_generator.gd` and generated UID.
- Modified: `scripts/tools/build_player_animation_assets.gd`, `scripts/tools/player_sprite_frames_builder.gd`, and `resources/player/player_sprite_frames.tres`.
- New: six PNG sources and Godot import sidecars under `assets/sprites/player/assassin/death/`.
- New: `scripts/player/player_death_sequence.gd` and generated UID.
- Modified: `scenes/player/player.tscn`, `scripts/player/player.gd`, and `scripts/systems/player_respawn_controller.gd`.
- New: `tests/player/test_player_death_presentation.gd` and generated UID.
- Modified: death-state, respawn, animation-system, and animation-asset tests.
- Modified: `docs/design/player_animation_spec.md`; new: `docs/design/player_respawn_spec.md`; modified: this log.
- Preserved: all Health/HUD/death/respawn work already present in the uncommitted working tree and the unrelated SpriteFrames UID normalization history. No placeholder/reference asset was deleted.

### Commands and actual results

1. Asset generation and persistent resource build with exact Godot 4.7.1:
   - `Godot --headless --path . --script scripts/tools/build_player_animation_assets.gd -- --death-presentation-only`: exit 0; `PLAYER_DEATH_PRESENTATION_EXPORT: 6 files, 0 failures`.
   - `Godot --headless --editor --path . --import --quit --log-file /tmp/nocturne_keep_death_asset_import.log`: exit 0; six PNGs imported without error/warning.
   - `Godot --headless --path . --script scripts/tools/build_player_animation_assets.gd --log-file /tmp/nocturne_keep_death_frames_build.log`: exit 0; `PLAYER_SPRITE_FRAMES_BUILD: OK`.
2. Focused validation:
   - `validate_player_animation_assets.gd`: PASS, `38 frames + ghost + 4 byte-identical references`.
   - `test_player_animation_system.gd`: PASS, all 16 animations plus production death count/FPS/loop/flat-body metadata.
   - `test_player_death_state.gd`: PASS, single entry, input/action/Stamina lockout, HUD, full presentation, no respawn when disabled.
   - `test_player_death_presentation.gd`: PASS, flat body, released daggers, ghost rise/pause, duplicate prevention, and cleanup.
   - `test_player_respawn.gd`: PASS, two full presentation-gated death/respawn cycles and input recovery.
3. Final serial suite:
   - All fifteen repository scripts passed. Health, HUD, asset, movement, animation, M1.5 action, fast Attack, Dash Attack, chained Stamina, continuous Air Dash, collision, and respawn regressions remain green.
   - Level metrics remain unchanged at 153.59/83.77 single jump, 281.92/167.10 debug double jump, and 344.00 four-Air-Dash action range.
4. Startup and log scan:
   - Configured Main and independently instantiated Player scene both exited 0 under `--headless --quit-after 2`.
   - All final import/suite/startup logs contained no `SCRIPT ERROR`, `ERROR:`, `WARNING:`, parse error, or missing-resource match.
5. Graphical verification:
   - `test_player_death_presentation.gd` with `--write-movie`, fixed 60 FPS: exit 0, 90 frames at 1280×720. Frames 20, 38, 58, and 80 were inspected at original resolution and show the low corpse, both blades, ghost emergence, top pause, and stable prompt/HUD.
   - `test_player_respawn.gd` with `--write-movie`, fixed 60 FPS: exit 0, 212 frames. Frame 90 confirms the first full sequence has cleaned the ghost/prompt and restored the Player and both bars to 100/100 at the spawn.

### Automated acceptance results

- Health zero enters Dead once, cancels ongoing actions, blocks all Gameplay input, and keeps Stamina unchanged through the sequence.
- `death_05` is a clearly horizontal final frame; both daggers are detached and remain static beside the body. Its production source is distinct from all earlier placeholder frames.
- The ghost cannot appear before body completion. It rises from the corpse by 14 pixels, reaches `GhostPause`, remains visible for at least 29 physics frames (approximately 0.50 seconds), then is hidden before completion.
- The full sequence cannot complete before its body/emerge/pause phases; the timing test requires at least 72 physics frames and observed the nominal approximately 1.30-second flow.
- Repeated zero-Health damage cannot spawn another sequence or ghost. The one owned Tween and ghost node are cleaned after completion and again on respawn.
- Respawn occurs only after `sequence_completed`; two consecutive cycles restore the fixed spawn position, full Health/Stamina, Idle, action/jump buffers, Camera following, HUD, and normal input exactly once per death.
- All previous Gameplay metrics and regressions remain unchanged.

### Manual acceptance requested

1. Run Main, click `DEV TEST · TAKE 25 DAMAGE` four times, and watch the complete sequence without pressing further inputs.
2. Confirm the body reads as falling backward and finishes fully horizontal, with the longer blade in front and shorter blade on the other side rather than still in the hands.
3. Confirm the hooded front-face ghost emerges only after the body settles, rises a small readable distance, visibly pauses, then disappears immediately before respawn.
4. Repeat facing left and right, and trigger one death while airborne to verify the dead body falls without steering and the ghost remains centered on the Player.
5. Confirm the approximately 1.30-second duration feels neither abrupt nor sluggish at normal play speed.

### Known limitations and handoff

- Dagger release is authored directly into the death frames; there is no independent trajectory, bounce, or RigidBody simulation.
- The ghost is a deliberately small single Sprite2D with alpha glow, not a particle/VFX stack. Manual approval may request contrast tuning against future room backgrounds.
- Airborne death uses normal vertical gravity while the body animation proceeds; at extreme future room heights, presentation could complete before landing and may require a separate floor-confirmation gate.
- Main still has one fixed test spawn and no respawn invulnerability, enemy reset, checkpoint selection, audio, screen fade, or final game-over flow.
- No enemy, Boss, damage-source, Hitbox/Hurtbox, combat resolution, input, movement tuning, or unrelated Gameplay system was added.
- No Git commit or push was performed. Work stops here for visual approval.
## 2026-07-23 — ENEMY-BASE-001 Castle Guard and minimal combat foundation

Date: 2026-07-23
Status: complete — implementation and automated/graphical verification passed; manual combat-feel acceptance pending

### Goal

- Add one original 16-bit-inspired melee enemy, `Castle Guard / 古堡守卫`, for testing the existing Player Attack, Dash Attack, evasion, Health, death, and respawn flow.
- Add only the reusable combat responsibilities required by this enemy: typed Hitbox/Hurtbox interaction, faction filtering, one-hit-per-attack memory, and Player attack-frame integration.
- Keep the enemy deliberately slower and more telegraphed than the Player: 0.35-second windup, 0.10-second active window, and 0.45-second recovery are initial playtest hypotheses.

### Planned files and responsibilities

- `scripts/combat/`: add composed Hitbox and Hurtbox components while reusing the existing `HealthComponent` as the sole Health authority.
- `scripts/player/player_action_controller.gd` and `scenes/player/player.tscn`: connect the existing Attack/Dash-Attack frame windows to separate narrow forward hitboxes without changing movement, stamina, input buffering, or animation timings.
- `scripts/enemies/`, `resources/enemies/`, and `scenes/enemies/`: add one data-configured Castle Guard actor with Idle, Patrol, Chase, Attack, Hurt, and Death states.
- `scripts/tools/` and `assets/sprites/enemies/castle_guard/`: generate original transparent 64×64 pixel frames and a persistent SpriteFrames resource using nearest-neighbor import/display.
- `scenes/tools/combat_test_room.tscn`: add a flat, bounded, independently runnable combat laboratory with one Player, one Castle Guard, signal-driven debug values, optional collision-shape visualization, and reset control.
- `tests/combat/` and `tests/enemies/`: cover component filtering/deduplication, Player damage windows, AI transitions/edge safety, fair enemy attack timing, Hurt/Death cancellation, and the end-to-end damage loop.
- `docs/design/combat_system_spec.md`, `docs/design/enemy_castle_guard_spec.md`, and `README.md`: document delivered behavior and manual test controls after verification.

### Verification plan

1. Generate/import enemy assets and build SpriteFrames with the exact Godot 4.7.1 executable.
2. Run headless editor import and isolated component, Player-combat, enemy-AI, and combat-room tests.
3. Run every pre-existing regression script to detect movement, stamina, animation, Health HUD, death, or respawn regressions.
4. Start the Player, Castle Guard, combat test room, and configured Main scenes independently under headless Godot.
5. Capture the combat room graphically at fixed FPS and inspect original-resolution frames for silhouette, facing, weapon/Hurtbox placement, HUD readability, and attack telegraph.

### Scope guard

- This milestone adds exactly one normal melee enemy and no ranged/flying/elite enemy, Boss, drop, loot, experience, combo tree, invulnerability system, production room, or complex navigation.
- Enemy body contact causes no damage; only explicitly active weapon hitboxes may mutate Health.
- Player Attack deals 1 and Dash Attack deals 2. Castle Guard sword attacks deal 1. These integer values are prototype hypotheses, not a finalized difficulty curve.
- No existing Player movement, gravity, jump, Dash, stamina, death presentation, or respawn timing may be retuned as part of this work.

### Delivered implementation

- Added typed `HitboxComponent` and `HurtboxComponent` nodes around the existing single `HealthComponent` contract. Hitboxes own damage/faction/attack id/target memory; Hurtboxes own hostile-contact filtering and Health forwarding. Body collision remains damage-free.
- Named all eight current 2D collision responsibilities and separated World, Player/Enemy bodies, Player/Enemy Hurtboxes, Player/Enemy Hitboxes, and detection.
- Added Player Hurtbox plus distinct mirrored normal/Dash Attack rectangles. Existing animation metadata now opens the normal one-damage rectangle only on `attack_02/03` and the two-damage rectangle only on `dash_attack_03/04`. Action cancellation, chaining, transitions, completion, and Player death reliably close both.
- Added one independently instantiable Castle Guard with centralized config, 3 Health, bounded patrol, wall/edge checks, detection hysteresis, same-platform horizontal Chase, frame-timed sword Attack, interruptible Hurt/knockback, and terminal Death cleanup.
- Generated 24 original transparent 64×64 Castle Guard frames through Godot Image operations: four Idle, six Walk, five Attack, three Hurt, and six Death. All imports are Lossless, mipmap-free, nearest-filtered. The generated contact sheet was visually inspected.
- Encoded Castle Guard attack fairness directly in SpriteFrames duration ratios derived from the config: 0.35 seconds across the first two telegraph frames, 0.10 seconds across active frames three/four, and 0.45 seconds on recovery frame five.
- Added an independently runnable flat combat room with the current Player, one Guard, fixed respawn, Player Health/Stamina UI, Player/Guard Health/state/animation diagnostics, optional world-space combat guides, and Reset.
- Added five new automated scripts and updated two historical Player tests whose previous scope assertions intentionally rejected Hitbox nodes.

### Files

- New combat scripts: `scripts/combat/hitbox_component.gd`, `scripts/combat/hurtbox_component.gd` and generated UID sidecars.
- Modified Player integration: `project.godot`, `scenes/player/player.tscn`, `scripts/player/player.gd`, `scripts/player/player_action_controller.gd`.
- New enemy/config/state: `scripts/enemies/castle_guard.gd`, `castle_guard_config.gd`, `castle_guard_state_machine.gd`, `resources/enemies/castle_guard_config.tres`, `scenes/enemies/castle_guard.tscn`.
- New art tooling/resources: `pixel_castle_guard_generator.gd`, `castle_guard_sprite_frames_builder.gd`, `build_castle_guard_assets.gd`, `resources/enemies/castle_guard_sprite_frames.tres`, 24 PNGs/import sidecars under `assets/sprites/enemies/castle_guard/`, and `docs/qa/castle_guard_animation_sheet.png`.
- New test room/tool: `scenes/tools/combat_test_room.tscn`, `scripts/tools/combat_test_room.gd`.
- New tests: `test_hitbox_hurtbox_components.gd`, `test_player_attack_damage.gd`, `test_combat_test_room.gd`, `test_castle_guard.gd`, `validate_castle_guard_assets.gd`, plus generated UID sidecars.
- New/updated docs: `combat_system_spec.md`, `enemy_castle_guard_spec.md`, `player_combat_spec.md`, `player_animation_spec.md`, `README.md`, and this log.

### Commands and actual results

1. Exact engine and asset generation:
   - `$GODOT_BIN --version`: `4.7.1.stable.official.a13da4feb`.
   - `$GODOT_BIN --headless --path . --script scripts/tools/build_castle_guard_assets.gd -- --generate`: exit 0; `CASTLE_GUARD_ASSET_EXPORT: 25 files, 0 failures` (24 frames plus contact sheet).
   - Headless editor import: exit 0; all 24 PNG sources imported.
   - `$GODOT_BIN --headless --path . --script scripts/tools/build_castle_guard_assets.gd`: exit 0; `CASTLE_GUARD_SPRITE_FRAMES_BUILD: OK`.
2. Focused tests after test-fixture corrections:
   - `HITBOX_HURTBOX_TEST`: PASS.
   - `PLAYER_ATTACK_DAMAGE_TEST`: PASS.
   - `CASTLE_GUARD_ASSET_TEST`: PASS.
   - `CASTLE_GUARD_TEST`: PASS.
   - `COMBAT_TEST_ROOM_TEST`: PASS.
3. Full serial regression:
   - Every one of 20 scripts under `tests/` exited 0. No test log contained `SCRIPT ERROR`, `ERROR:`, or `WARNING:`.
   - Existing measured Player envelopes remained 153.59 px single jump, 281.92 px debug double jump, 344.00 px four-Air-Dash action travel, and 362.22 px total-to-landing in the final run.
4. Independent scene startup:
   - Player, Castle Guard, combat test room, player animation preview, and configured Main each exited 0 under two-frame headless startup; no scene log contained an error or warning.
5. Graphical verification:
   - Combat room ran for 180 fixed 60-FPS frames at 1280×720 using GL Compatibility on Apple M4; exit 0 and no error/warning.
   - Original-resolution frames 0, 30, 60, 90, 120, and 150 were inspected. They show Idle→Chase→raised-sword Attack, correct left-facing sword placement, one-point Health changes on separated swings, fixed HUD, and readable dark-armored silhouette.
   - After the two-sided facing fix, a second 120-frame graphical run also exited 0 without diagnostics; inspected frames 0, 60, and 119 show the Guard facing the Player before Attack, the sword window activating only after windup, and Player Health changing from 100 to 99 once.
   - `docs/qa/castle_guard_animation_sheet.png` was inspected at original resolution; Idle breathing, alternating heavy walk, raised-sword windup, forward active extension, recoil, and horizontal collapse are distinct.

### Verification corrections recorded

- The first isolated component run failed because the dynamic test fixture had not named its Health node `HealthComponent`; production scenes were correct. The fixture was named to match the explicit NodePath contract and passed.
- The first asset validator used `Image.load_from_file`, which produced export-safety warnings. It now decodes `FileAccess` PNG bytes and passes warning-free.
- The first AI fixture placed Player inside the 180-pixel detection radius while asserting Idle, correctly causing immediate Chase. The fixture now begins outside perception. The edge assertion was moved to the actual configured boundary. No enemy tuning changed for these test-only corrections.
- A strengthened two-sided attack assertion exposed that a Guard spawned already inside attack range could start its sword sequence before turning toward a Player on the opposite side. Chase now resolves facing from the target offset before entering Attack. Five consecutive focused enemy runs and the final 20-script regression passed after the production fix.

### Manual acceptance requested

1. Run `scenes/tools/combat_test_room.tscn` and approach the Guard from both sides; confirm 0.35-second windup and the narrow sword direction are readable.
2. Avoid attacks using retreat, jump, Ground Dash, and Air Dash; confirm ordinary body contact alone never changes Health.
3. Confirm J removes one Guard Health, Shift→J removes two, and a single animation never double-hits.
4. Interrupt windup/active frames and confirm Hurt cancels the sword; defeat the Guard and confirm it no longer blocks, detects, moves, or attacks.
5. Use the debug toggle and Reset button; judge whether 45/75 px/s movement, 3 Health, 120 px/s knockback, and recovery cadence feel fair.

### Known limitations and handoff

- Player Hurt remains placeholder art with no dedicated Hurt state or invulnerability frames. Accepted enemy hits update Health and can trigger the complete existing Death/respawn flow without interrupting Player actions.
- The Guard hides after Death rather than dropping loot or respawning. Reset reloads the isolated room.
- Natural defeat of the 100-Health Player takes many one-damage sword hits by design of the requested integer contract; automated tests lower Health to verify the death loop deterministically.
- There is no navigation, jumping AI, attack variation, audio, particles, drops, encounter persistence, second enemy, elite, or Boss.
- Work stops at the first Castle Guard and awaits manual combat-feel approval.

## 2026-07-23 — Cursed Castle Guard animation refinement

Date: 2026-07-23
Status: complete — implementation, automated regression, scene startup, and graphical verification passed; manual animation-feel approval pending

### Goal

- Promote the existing first melee enemy's presentation name to `Cursed Castle Guard / 诅咒剑卫（诅咒古堡守卫）` while retaining the stable internal `CastleGuard` resource and scene identifiers.
- Preserve the already functional four-frame Idle, six-frame heavy Walk, five-frame Attack, three-frame Hurt, and six-frame Death animation contracts.
- Redraw the active Attack poses so frames three/four read as a committed one-handed heavy downward sword cut rather than a Player-like horizontal thrust.
- Redraw the last two Death frames so a fully grounded body visibly darkens, fragments, and dissipates without a Player-style ghost; keep animation completion as the existing cleanup signal.
- Add a generated reference asset under the enemy source tree and refresh the QA animation sheet for manual visual review.

### Planned files and responsibilities

- `scripts/tools/pixel_castle_guard_generator.gd`: refine attack/death pixel construction and generate a stable reference image.
- `assets/sprites/enemies/castle_guard/`: regenerate only the deterministic enemy PNG sources and add `reference/`; retain the existing internal path to avoid duplicating or breaking the combat scene.
- `resources/enemies/castle_guard_sprite_frames.tres`: rebuild against the imported frames without changing animation names or gameplay windows.
- `scenes/tools/combat_test_room.tscn` and documentation: update presentation text to the canonical cursed-guard name while retaining `CastleGuard` code identifiers.
- `tests/tools/validate_castle_guard_assets.gd`: add deterministic checks for the reference asset, grounded death pose, visible late-frame pixel reduction, and the absence of any enemy ghost node/resource.
- `docs/design/enemy_castle_guard_spec.md`, `docs/design/combat_system_spec.md`, and this log: document the revised visual language and verified timing.

### Verification plan

1. Generate assets with the exact Godot 4.7.1 executable, run editor import, and rebuild SpriteFrames.
2. Run the Castle Guard asset validator and enemy state/attack/death test in isolation.
3. Start the enemy scene and combat test room independently, then run the complete repository regression suite.
4. Capture the animation sheet and combat room at original resolution to inspect weight, attack readability, left/right flipping, foot baseline, grounded collapse, and dissolve.

### Scope guard

- This milestone changes only the first enemy's authored pixel presentation, persistent animation resource, validation, display naming, and documentation.
- It does not add or retune Player movement/combat, enemy damage, AI ranges/speeds, a second enemy, elite, Boss, drops, audio, particles, navigation, or level content.
- Attack Hitbox activation remains strictly on zero-based frames 2/3 (`attack_03/04`); death still uses no ghost and no physics-driven sword/body debris.

### Delivered implementation

- Kept the existing 24-frame production contract and stable `CastleGuard` scene/class paths, while promoting the visible name to Cursed Castle Guard / 诅咒剑卫. No duplicate enemy scene or asset tree was introduced.
- Re-authored Attack frames one through four. Frames one/two now hold the sword overhead and load the torso backward; frames three/four drive a clearly diagonal downward-forward single-sword cut. The final frame retains the low committed recovery.
- Re-authored all six Death frames into a continuous imbalance→diagonal fall→near-ground→fully grounded→dark fragmented body→sparse semitransparent debris sequence. Sprite completion still hides the actor; no ghost, particle system, RigidBody, or persistent corpse was added.
- Added `assets/sprites/enemies/castle_guard/reference/cursed_castle_guard_reference.png`, a generated integer-scaled six-pose reference board. The existing QA animation sheet was regenerated at integer scale.
- Added asset invariants for the reference/import, shared foot baseline, downward-forward steel pixels in active Attack art, fully grounded `death_04`, reduced/faded `death_05`, sparse `death_06`, and absence of a ghost node.
- Added an internal-only `--guard-death-demo` command-line argument to the existing combat test room for deterministic graphical capture. It applies lethal damage after 0.25 seconds and does not affect normal gameplay.
- Kept timing unchanged: Idle 4 FPS, Walk 8 FPS, Attack 10 FPS base with custom 0.35/0.10/0.45-second phases, Hurt 16.667 FPS matching 0.18 seconds, and Death 8 FPS. AI, damage, Health, collision, Player actions, and Main scene configuration were not retuned.

### Files changed

- Regenerated art: selected Attack and all Death PNGs under `assets/sprites/enemies/castle_guard/`; new generated `reference/` PNG/import; refreshed `docs/qa/castle_guard_animation_sheet.png`.
- Generation/validation: `scripts/tools/pixel_castle_guard_generator.gd`, `tests/tools/validate_castle_guard_assets.gd`.
- Presentation/test tool: `scripts/enemies/castle_guard.gd`, `scripts/tools/castle_guard_sprite_frames_builder.gd`, `scripts/tools/combat_test_room.gd`, `scenes/tools/combat_test_room.tscn`.
- Documentation: `README.md`, `docs/design/enemy_castle_guard_spec.md`, `docs/design/combat_system_spec.md`, and this log.

### Commands and actual results

1. Asset generation and import with exact Godot `4.7.1.stable.official.a13da4feb`:
   - `--script scripts/tools/build_castle_guard_assets.gd -- --generate`: exit 0; `CASTLE_GUARD_ASSET_EXPORT: 26 files, 0 failures` (24 production frames, QA sheet, reference board).
   - Headless editor import: exit 0; changed Attack/Death sources and the new reference imported without script/resource errors or warnings.
   - SpriteFrames rebuild: exit 0; `CASTLE_GUARD_SPRITE_FRAMES_BUILD: OK`.
2. Focused validation:
   - `CASTLE_GUARD_ASSET_TEST`: PASS — 24 frames plus reference, heavy cut, dissolve, exact timing, scene composition, nearest/lossless/mipmap-free imports, shared baseline, and no ghost.
   - `CASTLE_GUARD_TEST`: PASS — patrol, edge safety, chase, both facings, fair active window, Hurt interruption, and Death cleanup.
   - `PLAYER_ATTACK_DAMAGE_TEST`: PASS; `COMBAT_TEST_ROOM_TEST`: PASS.
3. Complete serial regression:
   - All 20 repository test scripts exited 0. Logs contained no `SCRIPT ERROR`, `ERROR:`, or `WARNING:`.
   - Existing Player metrics remained unchanged: 153.59-pixel single-jump range, 281.92-pixel debug double-jump range, 344.00-pixel four-Air-Dash action travel, and 362.22 pixels through landing.
4. Independent startup:
   - Enemy scene, combat test room, and configured Main each exited 0 under two-frame headless startup with no diagnostics.
5. Graphical verification:
   - A 120-frame fixed-60-FPS combat capture showed the raised-sword telegraph, diagonal heavy cut, correct left-facing presentation, one active sword window, and one-point Player Health loss.
   - A separate 90-frame death capture used the test-only demo argument. Inspected frames showed lethal recoil, grounded armor/sword, faded fragmented body, sparse debris, then complete hide. No ghost appeared.
   - The regenerated contact sheet and reference board were inspected at original resolution; Idle/Walk baseline, heavy step alternation, Attack anticipation/cut/recovery, Hurt recoil, and Death stages are visually distinct.

### Manual acceptance requested

1. Run `scenes/tools/combat_test_room.tscn` and judge whether the six-frame Walk feels sufficiently heavy at actual gameplay scale rather than merely slower.
2. Approach from both sides and confirm the overhead sword in `attack_01/02` gives a readable reaction window before the diagonal `attack_03/04` cut.
3. Interrupt Attack with Player damage and verify the visual transition to Hurt feels intentional.
4. Defeat the Guard normally and confirm the final two dissolve frames remain readable against the intended dark room background without resembling a Player ghost.

### Known limitations and handoff

- The guard has a deliberately compact 64×64 prototype silhouette with no subpixel armor motion, sword trail, audio, particles, or shader dissolve. The late Death breakup is authored directly into PNG pixels.
- Hurt runs at 16.667 FPS rather than the suggested 10–12 because three frames must match the already-approved 0.18-second enemy hard-stun window; changing it would retune gameplay rather than only art.
- Animation names and source folder remain `castle_guard` for API stability. This canonical enemy is the Cursed Castle Guard, not a separate un-cursed variant.
- Work stops at the first enemy animation set. No second enemy, elite, Boss, drop, or unrelated Gameplay work was started.

## 2026-07-23 — First enemy variety batch (delivery)

Status: complete — automated/runtime/visual verification passed; manual balance and readability acceptance pending

### Delivered implementation

- Added Cursed Shield Guard, Decayed Spearman, and Fallen Crossbowman as independently instantiable 64×64 pixel enemies with centralized Resources, AnimatedSprite2D animation sets, grounded AI, attacks, Hurt interruption, fall/dissolve Death, and no ghost.
- Added a 24×8 CrossbowBolt projectile with a separate Projectile collision layer, four-point one-hit damage, faction safety, World ray collision, three-second lifetime, and shooter-independent persistence.
- Kept Health/Hitbox/Hurtbox as composed data/interaction authorities. Added `attack_kind`, an optional typed enemy hit policy, directional shield block/GuardBreak, a narrow `EnemyCombatant` encounter contract, and shared `GroundEnemyBase` lifecycle without copying Castle Guard AI three times.
- Generalized `EncounterGroup` and Main debug from CastleGuard-only arrays to mixed `EnemyCombatant` arrays while retaining `get_guards()` for compatibility.
- Generated and imported 85 original transparent enemy frames plus one bolt through Godot Image operations. All sources are lossless, nearest-filtered, mipmap-free, and pass a nearest-neighbor 48×48 readability floor.
- Added `enemy_variety_test_room.tscn` with all four enemy types, a high platform, type-specific diagnostics, toggleable combat geometry, and Reset.
- Replaced Main's homogeneous 1/1/1/2 layout with four mixed groups sized 2/2/2/3: Guard+Shield, Spear+Guard, platform Crossbow+Guard, and Shield+Spear+Crossbow. F5 remains `res://scenes/main/main.tscn`.

### Prototype balance

| Enemy | HP | Damage | Attack distance | Telegraph / recovery | Normal / Dash hits to kill | Hits to defeat 100-HP Player |
| --- | ---: | ---: | ---: | --- | --- | ---: |
| Castle Guard | 3 | 5 | 46 | 0.35 / 0.45 s | 3 / 2 | 20 |
| Shield Guard | 20 | 8 | 46 | 0.40 / 0.55 s | 20 / 10* | 13 |
| Spearman | 10 | 10 | 76 | 0.45 / 0.60 s | 10 / 5 | 10 |
| Crossbowman | 5 | 4 | 260 | 0.60 Aim / 1.50 Reload | 5 / 3 | 25 |

`*` Frontal Dash play requires one prior GuardBreak input, so the practical all-frontal sequence is at least 11. The explicit four-point bolt requirement is used instead of the earlier eight-point parameter suggestion.

### Commands and actual results

1. Exact Godot 4.7.1 asset pipeline:
   - `pixel_enemy_variety_generator.gd`: exit 0; `ENEMY_VARIETY_PIXEL_BUILD: OK (86 files)`.
   - Headless editor import: exit 0 with no parse/resource/diagnostic match.
   - `enemy_variety_sprite_frames_builder.gd`: exit 0; three persistent SpriteFrames resources saved.
2. Focused verification:
   - `ENEMY_VARIETY_ASSET_TEST`: PASS for 85 64×64 sources, transparency, exact frame/FPS/loop metadata, lossless/no mipmaps, and 48px floor.
   - `ENEMY_VARIETY_TEST`: PASS for frontal Block, back damage, Dash GuardBreak, Spear reach/window, Crossbow Aim/Shoot/Reload/bolt creation, Player 1/2-point damage, Death cleanup, and no enemy ghost.
   - `ENEMY_VARIETY_DAMAGE_TEST`: PASS for Shield 8, Spear 10, Bolt 4, and Player Hurt entry.
   - `CROSSBOW_BOLT_TEST`: PASS for one hit, four damage, and World collision cleanup.
   - `MAIN_ENEMY_INTEGRATION_TEST`: PASS for F5 path, four groups, nine typed enemies, platform Crossbowman, activation, current resources, live HUD/respawn, debug toggle, and collision factions.
3. Complete serial regression:
   - Fresh headless editor import exited 0.
   - All 26 scripts under `tests/` exited 0; output scan found no `SCRIPT ERROR`, `ERROR:`, or `WARNING:`.
4. Scene startup:
   - Shield Guard, Spearman, Crossbowman, CrossbowBolt, old combat room, new variety room, and configured F5 Main all exited 0 under bounded headless runs with no diagnostics.
5. Graphical verification:
   - Configured Main recorded three 1280×720 GL Compatibility frames; `docs/qa/enemy_variety_f5_main.png` visibly reports all 4 groups/9 enemies, Group01-only activation, live Health/Stamina, and the first Guard/Shield encounter.
   - Variety room overview recorded two frames; `docs/qa/enemy_variety_test_room.png` shows the Player plus all four distinct silhouettes, including the Crossbowman on its platform. Representative shield attack, spear full extension, crossbow Aim, and final death/dissolve PNGs were inspected at original resolution.

### Manual acceptance and known limitations

1. Verify shield front/back classification under real left/right movement and judge 20 HP/0.60-second break duration.
2. Judge Spear telegraph, 34-pixel close dead zone, and whether its 10 damage/0.60 recovery is fair.
3. Confirm Crossbow Aim visibility, bolt/world collision, platform reach using Air Dash, and retreat behavior near edges.
4. Play Group04 with debug off and judge three-role readability, spacing, and the Player's existing 0.50-second invulnerability.
5. Enemy art and dissolve are authored prototype pixels with no audio, particles, shader dissolve, drops, navigation, jumping, or enemy respawn.
6. The project contract targets two final normal-enemy types. This larger four-type runtime roster is an explicitly requested evaluation batch; a later approval gate must select/merge roles before final scope lock rather than treating all prototypes as committed production content.

## 2026-07-24 — Compact Debug HUD (preflight)

Status: in progress — read-only audit complete; implementation and verification pending

### Goal

- Keep every existing Player and Enemy diagnostic field available while making the F5 Main view default to a compact two-line summary.
- Add independent F1 visibility, F2 compact/expanded, and F3 Enemy-detail controls through Input Map actions.
- Reduce the formal Health/Stamina footprint and the development damage button without changing their data sources or behavior.
- Replace the current fixed large panels with anchored, container-driven layout that remains on-screen from a small test window through 1920×1080.

### Read-only audit

- `run/main_scene` is `res://scenes/main/main.tscn`; the design viewport is 1280×720 with `canvas_items` stretch.
- Main uses two CanvasLayers: `Main/Interface` for development UI and `Main/HUD` for formal vitals/death UI.
- Player Action diagnostics are currently `Main/Interface/Panel/ActionDebug`, a Label driven every frame by `scripts/tools/player_action_debug_overlay.gd` inside a fixed 986×250 ColorRect.
- Enemy diagnostics are currently `Main/Interface/EnemyDebugPanel/EnemyDebug`, a Label driven every frame by `scripts/tools/main_enemy_debug_overlay.gd` inside a fixed 800×250 ColorRect. It serializes all encounter groups and all live enemy summaries every frame.
- Health is `Main/HUD/HealthContainer` (`PlayerHealthHud`, signal-driven); Stamina is `Main/HUD/StaminaContainer` (`PlayerStaminaHud` on the CanvasLayer, signal-driven). Their current fixed width is 224 pixels.
- `Main/Interface/DamageTestButton` is a 204×38 Button using the existing test-only damage script.
- The current panels use fixed offsets and do not provide responsive anchors or Compact/Expanded state. Existing CheckButtons only hide their individual labels.

### Planned files and responsibilities

- `project.godot`: add non-conflicting F1/F2/F3 Input Map actions.
- `scripts/tools/main_debug_hud_controller.gd`: own visibility, compact mode, Enemy detail state, responsive panel sizing, and small fold controls without recreating nodes.
- `scripts/tools/player_action_debug_overlay.gd`: retain the full five-line diagnostic payload and add a two-line compact renderer.
- `scripts/tools/main_enemy_debug_overlay.gd`: retain the full per-enemy payload, add encounter summary rendering, and throttle visible text refresh to 0.15 seconds.
- `scenes/main/main.tscn`: anchor the debug surfaces, place their children in Containers/ScrollContainer, compact formal vitals, and shrink the existing damage button.
- UI/integration tests: verify defaults, toggles, preserved expanded fields, signal-driven formal HUD, responsive bounds, and current Main resource paths.
- `README.md`, `docs/design/debug_hud_spec.md`, and this log: document operation, exact structure, evidence, and acceptance steps.

### Verification plan

1. Run exact Godot 4.7.1 headless import/parse checks and focused HUD/Main integration tests.
2. Run the complete repository test suite serially and scan all logs for errors and warnings.
3. Start the configured Main scene headlessly and graphically; verify Player/enemy systems remain unchanged.
4. Exercise layout at approximately 1280×664, 1280×720, 1920×1080, and a smaller window.
5. Capture and inspect Compact, Expanded, and fully hidden Debug HUD states under `docs/qa/`.

### Scope guard

- No combat values, Player abilities, enemy AI, encounter composition, animation, collision, Health/Stamina authority, or death/respawn behavior will change.
- No existing debug field will be deleted; fields omitted from Compact mode remain available in Expanded mode.
- The work applies to the configured F5 Main scene, not only a tool or preview scene.

### Delivered implementation

- Added `MainDebugHudController` directly to `Main/Interface`. It owns typed visibility/compact/Enemy-detail signals, handles Input Map actions, updates existing controls in place, and recalculates bounded panel geometry when the viewport changes.
- Rebuilt Main's development layout under a full-rect `DebugHudRoot`. Player Debug is a 340×64 top-left surface; Enemy Debug is a 380×68 bottom-left surface; both use MarginContainer plus ScrollContainer and 11-pixel text. Their backgrounds use 66% opacity.
- Added the default two-line Player summary (`PLAYER/STATE/HP/STA` plus `VX/VY/DASH/HURT/INV`) while preserving the original five-line payload exactly in Expanded mode.
- Added the default two-line active-encounter summary (`ENC/ALIVE/ENGAGED/ATK` plus live type counts). The original four-group/per-enemy diagnostic list remains available in Expanded or F3 Enemy-only detail mode.
- Reduced Enemy diagnostic refresh from every rendered frame to once per 0.15 seconds and disabled both overlay processors when F1 hides Debug.
- Registered F1 `debug_toggle_hud`, F2 `debug_toggle_compact`, and F3 `debug_toggle_enemy_details`. Small 20×20 `+`/`−` buttons mirror F2/F3 without rebuilding nodes or reconnecting signals.
- Anchored formal Health and Stamina to the top-right at 196×56 each, kept their signal-driven bindings intact, reduced label type to 11 pixels, and retained visible numeric current/maximum values.
- Anchored the existing development damage button to the lower-left at 120×28, renamed its visible text to `TAKE 25 DMG`, and kept its original 25-damage behavior. It now hides with the Debug root.
- Center-anchored the existing Death overlay so the HUD remains bounded if the viewport changes; no death timing, presentation, or respawn behavior changed.
- Added deterministic command-line-only screenshot states (`--debug-expanded`, `--debug-hidden`) to the Debug presentation controller. These flags affect QA capture only and do not alter the default F5 state.

### Main scene synchronization

- Configured F5 path: `res://scenes/main/main.tscn`.
- Updated instance paths: `Main/Interface`, `Main/Interface/DebugHudRoot/Panel`, `Main/Interface/DebugHudRoot/EnemyDebugPanel`, `Main/Interface/DebugHudRoot/DamageTestButton`, `Main/HUD/HealthContainer`, and `Main/HUD/StaminaContainer`.
- Current overlay resources: `res://scripts/tools/main_debug_hud_controller.gd`, `res://scripts/tools/player_action_debug_overlay.gd`, and `res://scripts/tools/main_enemy_debug_overlay.gd`.
- Main continues to instantiate the current Player plus all four encounter groups/nine mixed enemies. Existing integration tests confirmed live Health/Stamina, respawn, enemy components, projectiles, and activation after the HUD path update.

### Commands and actual results

1. Exact Godot `4.7.1.stable.official.a13da4feb` import/parse:
   - `/Users/vincentz/Downloads/Godot.app/Contents/MacOS/Godot --headless --path . --editor --quit`: exit 0; scripts/classes and Main loaded without errors or warnings.
2. Focused HUD and integration verification:
   - `tests/ui/test_main_debug_hud.gd`: PASS for default Compact, preserved Expanded content, Enemy-only expansion, F1/F2/F3 end-to-end Input events, processor suspension, formal-HUD independence, compact dimensions, and responsive bounds.
   - `test_player_health_hud.gd`, `test_main_enemy_integration.gd`, `test_dash_attack.gd`, `test_player_death_state.gd`, `test_player_respawn.gd`, and `test_chain_dash_stamina.gd`: all PASS after saved Main path changes.
3. Responsive layout:
   - The isolated HUD test temporarily disabled project content scaling and verified compact/expanded surfaces at 800×540, 1280×664, 1280×720, and 1920×1080. Every panel stayed inside the viewport; Player Debug did not overlap Health, Enemy Debug did not overlap its button, and expanded Player/Enemy surfaces did not overlap.
   - Graphical Movie Maker follows the project's 1280×720 logical canvas under `canvas_items`, so physical `--resolution` requests are encoded at the authored logical size. The responsive test therefore performs the additional scale-disabled true-bound check described above.
4. Complete regression:
   - All 27 scripts under `tests/` exited 0. The combined log scan found no `SCRIPT ERROR`, `ERROR:`, or `WARNING:`.
   - Existing Player metrics remained stable: 153.59-pixel single-jump range, 281.92-pixel debug double-jump range, 344.00-pixel four-Air-Dash range, and 360.33 pixels through landing in this run.
5. Scene startup:
   - Configured Main ran headlessly for 120 frames; `combat_test_room.tscn` and `enemy_variety_test_room.tscn` also started independently. All exited 0 without matched diagnostics.
6. Actual GL Compatibility F5 captures on Apple M4:
   - Compact, Expanded, and hidden Main each rendered one fixed-FPS 1280×720 frame and exited 0. Log scans found no errors or warnings.
   - Original-resolution inspection confirmed the Player and first Guard/Shield encounter remain visible in Compact, all legacy text is readable through Expanded scrolling, and hidden Debug leaves only formal HP/STA.
7. `git diff --check`: PASS.

### QA evidence

- `docs/qa/debug_hud_compact00000000.png`: default F5 Compact Player/Enemy summaries, compact damage button, formal vitals.
- `docs/qa/debug_hud_expanded00000000.png`: complete Player fields and all authored group/enemy rows.
- `docs/qa/debug_hud_hidden00000000.png`: Debug root and damage button hidden; formal Health/Stamina remain visible.

### Manual acceptance requested

1. Run F5 and use F1 twice; confirm all development panels/button disappear and return without affecting Health/Stamina or gameplay.
2. Use F2 while moving, attacking, taking damage, and Dashing; confirm the complete original diagnostic values remain live and Compact restores immediately.
3. Use F3 in Compact mode; confirm only Enemy details expand and that the ScrollContainer keeps the lower panel bounded.
4. Resize the project window around 1280×664, 1280×720, and 1920×1080; confirm default engine-font readability and that the authored logical UI scaling is acceptable on the target display.
5. Judge whether 66% Debug backgrounds provide sufficient contrast on future brighter rooms; this is a presentation approval, not a data or combat change.

### Known limitations and handoff

- Expanded mode intentionally occupies more of the left side because it preserves every original diagnostic field. It is an explicit inspection mode, not the startup presentation.
- The project uses a 1280×720 logical canvas with `canvas_items` stretch. Very small or non-16:9 physical windows scale that logical canvas rather than authoring a second breakpoint-specific font size.
- Current controls use Godot's engine font, not a final licensed pixel UI font. The text remains vector-rendered and is independent of nearest-neighbor sprite filtering.
- Enemy Compact selection follows the latest activated authored group in scene order; encounters are currently one-shot and sequential. A future non-linear encounter system may require an explicit focus authority.
- No debug field, combat value, Player ability, enemy AI/state, encounter member, Health/Stamina rule, animation, collision, or death/respawn behavior was removed or retuned.

## 2026-07-24 — First normal-enemy gray-box rebalance (preflight)

Status: complete — centralized balance, F5 Main synchronization, regression, and graphical verification passed; manual feel approval pending

### Goal

- Preserve the Cursed Castle Guard at 3 HP / 5 damage.
- Reduce the Cursed Shield Guard to 7 HP while preserving 8 damage, directional Block, and GuardBreak.
- Reduce the Decayed Spearman to 5 HP while preserving 10 damage, 76 range, and its current windup/active/recovery cadence.
- Reduce the Fallen Crossbowman to 4 HP and raise its bolt to 6 damage while preserving detection, Aim, Reload, movement, projectile speed, and AI behavior.
- Keep Player Health and normal/Dash Attack damage fixed at 100 / 1 / 2.

### Read-only audit

- F5 remains `res://scenes/main/main.tscn`; Main instances all enemy types from their current PackedScenes, and those scenes reference the shared `resources/enemies/*_config.tres` resources rather than Main-local overrides.
- Runtime Health authority is each enemy Config: `CastleGuard._ready()` and `GroundEnemyBase._ready()` copy `config.max_health` into the composed HealthComponent and reset it before combat.
- Runtime melee damage authority is each enemy Config: attack windows call `begin_attack(..., config.attack_damage)`; the scene's saved Hitbox damage is only a redundant prototype copy.
- Crossbow runtime damage authority is `FallenCrossbowmanConfig.projectile_damage`; `_spawn_bolt()` passes it to `CrossbowBolt.initialize()`. The bolt scene nevertheless retains a redundant four-damage prototype default and activates before initialization.
- Saved enemy scenes also retain redundant old HealthComponent maxima (3/20/10/5), and Shield/Spear Hitboxes retain 8/10. They match current runtime values but can conflict after balancing, so this milestone will remove those scene-local copies.
- Existing tests cover factions, one-hit-per-attack memory, Block/GuardBreak, timing, damage, death, Main composition, and Debug summaries, but do not yet assert all requested kill counts from current Main resources.

### Planned files and responsibilities

- Enemy Config resources: apply only the requested HP/bolt changes and preserve all timing/range fields byte-for-byte.
- Enemy/projectile scenes and `crossbow_bolt.gd`: remove redundant saved HP/damage values and make explicit initialization the only way a bolt opens its Hitbox.
- Enemy damage/profile/Main integration tests plus a focused balance test: assert 3/2, 7/4, 5/3, and 4/2 kill counts, six-point one-hit bolts, Player 100/1/2, unchanged cadence, current Main instances, Debug text, and death entry.
- `README.md`, `docs/design/enemy_roster_spec.md`, and this log: record the revised gray-box table and the distinction between mathematical lethal-hit counts and Player survivable hits.

### Verification plan

1. Run exact Godot 4.7.1 import/parse and focused balance/damage/Main tests.
2. Run every repository test serially and scan output for errors or warnings.
3. Start all four enemy scenes, the bolt, both combat test rooms, and configured Main independently.
4. Run configured F5 Main graphically with Expanded Enemy Debug and inspect current HP/damage values plus live death behavior.

### Scope guard

- No Player Health/damage, enemy range/timing/movement/AI, Block/GuardBreak, encounter composition, animation, collision shape, projectile speed, Hurt, death presentation, drop, or new enemy changes are authorized.
- The values will be changed in shared Config resources used by both independent scenes and every F5 Main instance; Main will not receive divergent local overrides.

### Delivered balance

| Enemy | Before HP / damage | Current HP / damage | Normal / Dash hits | Player survives / lethal hit |
| --- | --- | --- | --- | --- |
| Cursed Castle Guard | 3 / 5 | 3 / 5 | 3 / 2 | 19 / 20 |
| Cursed Shield Guard | 20 / 8 | 7 / 8 | 7 / 4 after break/back access | 12 / 13 |
| Decayed Spearman | 10 / 10 | 5 / 10 | 5 / 3 | 9 / 10 |
| Fallen Crossbowman | 5 / 4 bolt | 4 / 6 bolt | 4 / 2 | 16 / 17 |

- Preserved every requested role/timing value: Castle 46 range and 0.35/0.10/0.45 cadence; Shield 46 range, 0.40/0.10/0.55 cadence, directional Block, and 0.60 GuardBreak; Spear 76 range and 0.45/0.10/0.60 cadence; Crossbow 280 detection, 0.60 Aim, 1.50 Reload, 260 projectile speed, and three-second lifetime.
- Preserved Player 100 Health, one-point normal Attack, and two-point Dash Attack.
- Removed saved `HealthComponent.max_health` copies from all four enemy PackedScenes and saved `Hitbox.damage` copies from Shield, Spear, and CrossbowBolt scenes. Shared enemy Config resources are now the only authored balance source.
- CrossbowBolt no longer opens its Hitbox from a scene-local default during `_ready()`. It remains inactive until the shooter passes `FallenCrossbowmanConfig.projectile_damage` to `initialize()`, which assigns six damage and starts the one-hit attack id.
- Kept the inherited Crossbow `attack_damage` equal to `projectile_damage` inside the same Config so generic inspector/debug consumers cannot report a contradictory value; runtime bolt damage continues to use the explicit projectile field.

### F5 Main synchronization

- `run/main_scene` remains `res://scenes/main/main.tscn`.
- Main's 3 Castle Guards, 2 Shield Guards, 2 Spearmen, and 2 Crossbowmen all instance the current enemy PackedScenes; those scenes reference the updated shared Config resources, with no Main-local HP/damage overrides.
- The Main integration test read every live instance and confirmed the expected type profile. It then used the actual Main Player normal/Dash Hitboxes against paired live instances of every enemy type, confirmed 3/2, 7/4, 5/3, and 4/2 hit counts, verified each Death animation, emitted completion, confirmed dissolve/hide cleanup, and confirmed no enemy ghost. The extra third Castle Guard also follows the same Config and is used for a direct lethal-path assertion.
- Expanded Main Enemy Debug reported `HP 3/3 DMG 5`, `HP 7/7 DMG 8`, `HP 5/5 DMG 10`, and `HP 4/4 DMG 6` on the live F5 instances.

### Commands and actual results

1. Exact Godot `4.7.1.stable.official.a13da4feb` editor import/parse: exit 0 without matched errors or warnings.
2. Focused balance checks:
   - `ENEMY_BALANCE_TEST`: PASS — Player 100/1/2, centralized Config values, unchanged ranges/cadences, no scene-local duplicates, kill counts 3/2, 7/4, 5/3, 4/2, and same-attack deduplication on every type.
   - `ENEMY_VARIETY_TEST`: PASS — Shield Block/GuardBreak, Spear reach, Crossbow Aim/Reload, current HP, Player damage totals, Hurt, and non-ghost Death.
   - `ENEMY_VARIETY_DAMAGE_TEST`: PASS — Shield 8, Spear 10, Bolt 6, and Player Hurt entry.
   - `CROSSBOW_BOLT_TEST`: PASS — six damage, single-hit memory, World collision cleanup.
   - `MAIN_ENEMY_INTEGRATION_TEST`: PASS — four groups/nine current Main enemies, latest Debug values, activation, actual Main Player Hitbox kill counts for all four roles, Death animation/dissolve, HUD/respawn, and projectile layer.
   - `PLAYER_ATTACK_DAMAGE_TEST`: PASS — Player Attack remains one, Dash Attack remains two, active windows/dedup/facing unchanged.
3. Complete regression: all 28 test scripts exited 0; combined logs contained no `SCRIPT ERROR`, `ERROR:`, or `WARNING:`. Existing movement metrics remained 153.59 single-jump range, 281.92 double-jump range, 344.00 four-Air-Dash range, and 360.33 pixels through landing.
4. Independent startup: Castle Guard, Shield Guard, Spearman, Crossbowman, CrossbowBolt, combat test room, enemy variety room, and configured Main all exited 0 under bounded headless runs with no matched diagnostics.
5. Graphical configured-Main run:
   - `Godot --path . --write-movie docs/qa/enemy_balance_f5_main.png --fixed-fps 1 --quit-after 1 --audio-driver Dummy -- --debug-expanded`: exit 0 using GL Compatibility on Apple M4.
   - Original-resolution inspection shows the live Player at 100/100 and all nine Main enemies with the current HP/damage values in Expanded Enemy Debug.
6. `git diff --check`: PASS.

### QA evidence and manual acceptance

- `docs/qa/enemy_balance_f5_main00000000.png`: configured F5 Main, current encounter instances, current Expanded Enemy Debug HP/damage, formal Player HUD.
- Manually confirm the seven-hit post-break Shield window feels brief enough before Block returns; the automated kill-count check intentionally disables Block to measure pure post-break/back damage math.
- Manually judge whether six-point bolts plus 0.60 Aim/1.50 Reload create enough pressure without making Group03/04 oppressive.
- The practical all-frontal Shield Dash sequence is five inputs, not four: one Dash Attack is consumed by GuardBreak, followed by four damaging Dash Attacks if the punish opportunities are maintained.

### Known limitations and handoff

- These are deterministic gray-box damage counts, not a final difficulty curve. Enemy group composition and Player invulnerability can materially change encounter time-to-kill and time-to-death.
- Enemy Debug shows the current configured damage source, not predicted DPS or blocked damage.
- Historical development-log entries retain the values that were true when those milestones shipped; this dated section and the current roster/specification supersede them.
- No Player stat, enemy timing/range/AI, encounter placement, animation, collision, Hurt/Death behavior, or new content was changed.
## 2026-07-24 — Shield Guard permanent break feedback (preflight)

Status: complete — implementation, 28-script regression, standalone/F5 startup, and graphical Main evidence passed; manual feel/readability approval pending

### Goal

- Make a frontal Player Dash Attack permanently destroy the Cursed Shield Guard's shield.
- Hold a distinct 0.70-second GuardBreak state with no blocking, attacking, or chasing.
- Replace the intact-shield recovery with readable pixel fragments/flash and persistent unshielded movement, attack, Hurt, and Death presentation.
- Expose `BLOCK ON/OFF`, `SHIELD BROKEN true/false`, and state through the existing Main Enemy Debug detail view.

### Read-only audit

- F5 remains `res://scenes/main/main.tscn`; its `World/Encounters/EncounterGroup01/Enemies/CursedShieldGuard01` and `EncounterGroup04/Enemies/CursedShieldGuard02` both instance `res://scenes/enemies/cursed_shield_guard.tscn` without local shield overrides.
- `ShieldBlockComponent` currently owns only transient `is_blocking`. A frontal Dash Attack emits `guard_broken`, but no permanent broken flag is recorded.
- `CursedShieldGuard._process_reaction()` currently re-enables blocking after the 0.60-second timer, and every Idle/Patrol/Chase/Hurt recovery also requests blocking.
- The current three-frame `guard_break` shifts an intact shield downward. Subsequent `idle`, `walk`, `attack`, `hurt`, and `death` frames all render the full shield again.
- Expanded Main Enemy Debug receives `CursedShieldGuard.get_debug_summary()`, but that summary currently reports only the transient Block and Hitbox flags.

### Planned files and responsibilities

- `shield_block_component.gd`: own the one-way broken state and make all post-break block requests ineffective.
- Shield Guard script/config/scene: enforce GuardBreak priority and duration, drive the break effect, select persistent unshielded animations, and expose truthful Debug fields.
- Shield Guard pixel generator, SpriteFrames builder, assets, and resources: author four GuardBreak poses, a short fragment/flash overlay, and unshielded Idle/Walk/Attack/Hurt/Death variants.
- Shield Guard asset/behavior/Main tests: assert one-time break, 0.70 seconds, permanent frontal vulnerability, visual disappearance, state lock, both facings, and live Main instances.
- Shield Guard, combat, roster, and development documents: record the permanent-break contract without changing 7 HP or 8 damage.

### Verification plan

1. Run exact Godot 4.7.1 asset generation/import and SpriteFrames build.
2. Run focused Shield Guard behavior, asset, combat-damage, balance, and Main integration tests.
3. Run every repository test serially and scan for errors/warnings.
4. Start the Shield Guard scene independently and run configured F5 Main graphically, preserving a QA capture of the live broken state.

### Scope guard

- No other enemy, Player ability/stat, combat damage, encounter composition, HUD layout, Boss, hit-stop, camera shake, or new system is authorized.
- Shield Guard balance remains 7 Health and 8 attack damage. Only the explicitly requested GuardBreak duration changes from 0.60 to 0.70 seconds.

### Delivered implementation

- Added permanent `shield_broken` authority to `ShieldBlockComponent`. The first intact frontal Dash Attack changes it once, emits one break event, consumes that Dash damage, and forces all future block requests off. Back Dash Attacks and every post-break attack resolve as ordinary damage.
- Kept GuardBreak as a dedicated state for 0.70 seconds. Attack, chase, and target-acquisition transitions are rejected while locked; punish damage is accepted without replacing the larger GuardBreak silhouette with ordinary Hurt. Death retains higher priority.
- Re-authored GuardBreak as four 64×64 frames: cracked/white-flashed shield, two fragment/recoil stages, then an unshielded hard-stun hold. Added a separate four-frame 12 FPS pale flash/iron-fragment overlay at `FacingRoot/ShieldBreakEffect`; it hides after completion.
- Added persistent unshielded Idle (4), Walk (6), Attack (5), Hurt (3), and Death (6) production frames. The Shield Guard dynamically resolves only its own post-break presentation to these animations, so the shield cannot reappear during action, damage, AI reset, or death cleanup.
- Added a narrow death-animation hook to `GroundEnemyBase` so the Shield Guard's `death_unshielded` variant completes the existing dissolve/free lifecycle without changing other enemy behavior.
- Expanded Shield Guard debug summary fields to include explicit `STATE`, uppercase `BLOCK ON/OFF`, and `SHIELD BROKEN true/false`. Existing Main Enemy Debug renders the same live string in Expanded mode.
- Preserved 7 Health, 8 attack damage, all attack timing/range/movement values, both authored Main instances, Player values, encounter composition, and every other enemy.

### Commands and actual results

1. Exact engine and resource production:
   - `/Users/vincentz/Downloads/Godot.app/Contents/MacOS/Godot --version`: `4.7.1.stable.official.a13da4feb`.
   - Pixel generator: `ENEMY_VARIETY_PIXEL_BUILD: OK (115 files)`.
   - Fresh headless editor import: exit 0; all new PNGs imported losslessly without mipmaps.
   - SpriteFrames builder: `ENEMY_VARIETY_SPRITE_FRAMES_BUILD: OK`.
2. Focused verification:
   - `ENEMY_VARIETY_TEST`: PASS for front Block, back damage, one-time break, 0.70-second lock, no Attack transition, permanent frontal vulnerability, unshielded Idle/Walk/Attack/Hurt/Death, effect cleanup, and non-ghost Death.
   - `ENEMY_VARIETY_ASSET_TEST`: PASS for 114 64×64 enemy/effect frames plus bolt, transparency, lossless/no-mipmap import, 48×48 readability floor, and exact 0.70-second GuardBreak animation duration.
   - `ENEMY_BALANCE_TEST`: PASS; requested 3/2, 7/4, 5/3, 4/2 kill counts and centralized values remain unchanged.
   - `ENEMY_VARIETY_DAMAGE_TEST`: PASS; Shield damage remains 8.
   - `MAIN_ENEMY_INTEGRATION_TEST`: PASS using both live Main Shield Guards for frontal Block, frontal Dash break, 0.70-second lock, post-break frontal damage, back damage, Debug fields, correct shielded/unshielded Death, and cleanup.
   - The first asset-test run exposed a test-only `frames`/`sprite_frames` identifier typo. It was corrected; the final asset test and subsequent regression are clean.
3. Complete regression:
   - All 28 scripts under `tests/` passed serially. No final run contained `SCRIPT ERROR`, `ERROR:`, or `WARNING:`.
   - Movement metrics remained 153.59-pixel single-jump range, 281.92-pixel debug-double-jump range, 344.00-pixel four-Air-Dash action range, and 360.33 pixels through landing.
4. Runtime startup and graphical Main:
   - Shield Guard standalone startup (`--quit-after 60`): exit 0.
   - Configured F5 Main startup (`Godot --headless --path . --quit-after 120`): exit 0.
   - GL Compatibility Main QA capture on Apple M4: 19 frames at 1280×720/30 FPS, exit 0. It used `Main/World/Player`'s real Dash Hitbox against `EncounterGroup01/Enemies/CursedShieldGuard01` and exposed the broken state in Expanded Enemy Debug.
5. Final `git diff --check`: PASS.

### F5 Main synchronization and QA evidence

- `application/run/main_scene` remains `res://scenes/main/main.tscn`.
- Main nodes `World/Encounters/EncounterGroup01/Enemies/CursedShieldGuard01` and `EncounterGroup04/Enemies/CursedShieldGuard02` both instance the updated `res://scenes/enemies/cursed_shield_guard.tscn`; neither has local behavior, config, SpriteFrames, or shield-state overrides.
- The shared scene now owns `FacingRoot/ShieldBreakEffect` and loads `cursed_shield_guard_sprite_frames.tres` plus `cursed_shield_guard_shield_break_fx_sprite_frames.tres`. Saving/reopening therefore retains the implementation without editing Main-local instance data.
- `docs/qa/shield_guard_break_f5_main.png` is the inspected 1280×720 Main frame. It shows the live break flash, recoiling shield enemy, and Expanded row `STATE GuardBreak ... BLOCK OFF SHIELD BROKEN true`.

### Manual acceptance and known limitations

- Manually test both facings at normal game speed and judge whether the pale flash/fragments remain readable against future brighter rooms; automated and original-resolution inspection establish presence, not subjective impact.
- Confirm the permanent-defense loss makes the seven-Health enemy appropriately vulnerable for the remainder of the encounter. No HP/damage compensation was introduced.
- The break effect is intentionally lightweight: embedded pixel cracks/fragments plus a short overlay. Hit-stop, camera shake, audio, particles, shield physics, shield regeneration, and additional combat systems remain excluded.
- GuardBreak preserves its large recoil animation while accepting punish damage. It does not play the smaller ordinary Hurt animation until after the 0.70-second lock ends.

## 2026-07-24 — Shield break Main readability follow-up (preflight)

Status: complete — Main readability fix, 28-script regression, standalone/F5 startup, and graphical evidence passed; manual approval pending

### Goal

- Make the existing one-time Shield Guard break unmistakable at normal F5 Main camera distance without changing combat balance or shield rules.
- Keep the break flash/fragments readable for the full 0.70-second GuardBreak window and add a compact persistent broken-shield cue during that hard stun.
- Preserve the permanent unshielded animation set after GuardBreak.

### Read-only audit

- F5 still resolves to `res://scenes/main/main.tscn`; both Main Shield Guard instances use the shared current `res://scenes/enemies/cursed_shield_guard.tscn` without local overrides.
- The current `FacingRoot/ShieldBreakEffect` is a 64×64 four-frame overlay played at 12 FPS and 1× scale, so it lasts only about 0.33 seconds while GuardBreak itself lasts 0.70 seconds.
- The previous QA frame proves `STATE GuardBreak`, `BLOCK OFF`, and `SHIELD BROKEN true`, but its only non-debug break cue is a very small pale cross. That is not sufficient visual acceptance evidence.
- Permanent `idle_unshielded`, `walk_unshielded`, `attack_unshielded`, `hurt_unshielded`, and `death_unshielded` resources are already correct and must remain intact.

### Planned files and responsibilities

- Shield break pixel generator/assets/SpriteFrames: enlarge the authored flash/fragments, add a pixel broken-shield marker, and align overlay duration with the 0.70-second state.
- Shield Guard scene/script: show the marker for the entire GuardBreak, apply a brief body flash, and guarantee cleanup on recovery or death.
- Shield behavior/Main/asset tests: assert effect scale/duration, marker lifecycle, persistent broken state, and both live Main instances.
- Shield/combat specs and this log: record the failed acceptance finding and the corrected presentation contract.

### Verification plan

1. Regenerate/import the focused pixel assets and rebuild SpriteFrames with exact Godot 4.7.1.
2. Run focused asset, Shield behavior, and live Main integration tests, then all repository tests.
3. Start the standalone enemy and configured Main, then capture and inspect a new original-resolution Main break frame.

### Scope guard

- No Health, damage, Block direction, GuardBreak duration, AI cadence, encounter placement, Player ability, other enemy, HUD, camera shake, hit-stop, audio, Boss, or unrelated system changes.

### Delivered correction

- Re-authored the four break-overlay frames with a larger eight-direction pale impact, brighter core, and more widely separated metal fragments. The scene displays the 64×64 overlay at integer 2× nearest-neighbor scale.
- Changed the overlay from 12 FPS/about 0.33 seconds to 5.714 FPS/exactly 0.70 seconds so feedback spans the complete GuardBreak window.
- Added `VisualRoot/GuardBreakMarker`, a 20×20 transparent cracked-shield pixel icon above the enemy. It remains visible for the complete hard stun and is removed on recovery or Death.
- Added a restrained 0.12-second body highlight at the break instant. No camera shake, hit-stop, audio, particle system, or gameplay timing change was introduced.
- Kept every permanent unshielded animation and the existing permanent `shield_broken` authority. Health remains 7 and attack damage remains 8.
- Updated the graphical QA utility to preserve the default Compact Main HUD so the cue is judged in normal play space rather than behind Expanded diagnostics.

### Commands and actual results

1. Exact Godot `4.7.1.stable.official.a13da4feb` pixel generation/import/build:
   - `ENEMY_VARIETY_PIXEL_BUILD: OK (116 files)`.
   - `Godot --headless --path . --import`: exit 0; the new marker and four revised effect PNGs imported losslessly without mipmaps.
   - `ENEMY_VARIETY_SPRITE_FRAMES_BUILD: OK`.
2. Focused checks:
   - `ENEMY_VARIETY_ASSET_TEST`: PASS — 64×64 effect frames, 20×20 marker, transparent/lossless imports, and exact 0.70-second overlay duration.
   - `ENEMY_VARIETY_TEST`: PASS — enlarged effect, marker lifecycle, one-time break, 0.70-second lock, permanent unshielded recovery, and Death cleanup.
   - `MAIN_ENEMY_INTEGRATION_TEST`: PASS — both shared live Main Shield instances own the latest effect/marker; frontal Player Dash Hitbox starts both cues and recovery clears them without restoring Block.
3. Complete regression: all 28 repository test scripts exited 0 with no final `SCRIPT ERROR`, `ERROR:`, or `WARNING:`. Player movement metrics remain unchanged at 153.59 single-jump, 281.92 double-jump, 344.00 four-Air-Dash action range, and 360.33 pixels through landing.
4. Runtime startup: standalone Shield Guard and configured F5 Main both exited 0 under bounded headless runs with no diagnostics.
5. Graphical configured-Main capture: 19 frames at 1280×720/30 FPS under GL Compatibility on Apple M4, exit 0. The inspected frame uses the real `Main/World/Player` Dash Attack Hitbox against `EncounterGroup01/Enemies/CursedShieldGuard01` and retains the default Compact HUD.
6. `git diff --check`: PASS.

### F5 Main synchronization and QA evidence

- `application/run/main_scene` remains `res://scenes/main/main.tscn`.
- `World/Encounters/EncounterGroup01/Enemies/CursedShieldGuard01` and `EncounterGroup04/Enemies/CursedShieldGuard02` both instance the revised shared `cursed_shield_guard.tscn`; no Main-local override or stale PackedScene exists.
- The shared scene now loads `FacingRoot/ShieldBreakEffect` at 2× and `VisualRoot/GuardBreakMarker`; saving and reopening Main retains both through the PackedScene reference.
- `docs/qa/shield_guard_break_readable_f5_main.png` is the inspected original 1280×720 Compact-HUD frame. It visibly shows the enlarged break impact, shield fragments, cracked-shield marker, and the unshielded recoil pose.

### Manual acceptance and known limitations

- The break requires a **frontal Dash Attack while the shield is still intact**. A rear Dash Attack is ordinary damage by design and intentionally does not trigger the break cue.
- Manually confirm both facings in the normal F5 encounter and judge whether the new cue is sufficiently strong on the target display. Automated evidence establishes timing and visibility, not personal visual preference.
- The cracked-shield marker communicates the 0.70-second punish window only; it disappears when hard stun ends. The permanent missing shield on every subsequent animation communicates the lasting defense loss.

## 2026-07-24 — Shield Guard independent shield-health redesign (preflight)

Status: complete — independent Shield routing, Main integration, 28-script regression, and visual QA passed; manual feel acceptance pending

### Goal

- Replace the one-input frontal Dash break with an independent three-point shield-health component.
- Route one-point normal and two-point Dash attacks exclusively to the intact shield from the front, while rear/center-overlap attacks bypass it and damage the five-point body.
- Separate the shield from body art, expose intact/cracked/critical/broken states, preserve a 0.65-second GuardBreak, and add a 0.22-second target-side turn delay so rear attacks are practically achievable.
- Deliver the same behavior through both shared Shield Guard instances in configured F5 Main.

### Read-only audit

- `project.godot` sets `run/main_scene="res://scenes/main/main.tscn"`.
- Main instances `World/Encounters/EncounterGroup01/Enemies/CursedShieldGuard01` and `EncounterGroup04/Enemies/CursedShieldGuard02` both instance `res://scenes/enemies/cursed_shield_guard.tscn` without local script/config/art overrides.
- Body Health is currently authored as 7 in `cursed_shield_guard_config.tres`; damage is 8 and Player attack values remain centralized at 1/2.
- `ShieldBlockComponent` owns only transient `is_blocking` plus permanent `shield_broken`; it has no maximum/current shield Health or Health-change signal.
- One shared Hurtbox delegates to `ShieldBlockComponent.resolve_damage()`. Source x-position versus `FacingRoot.scale.x` determines front/back with no center tolerance. A frontal Dash Attack immediately calls `break_shield()`; a frontal normal Attack is consumed without changing persistent state.
- The same shared Hurtbox prevents separate Shield/Body Area overlap, and `HitboxComponent` already remembers one target per attack id. This is the correct single routing boundary to retain.
- Shield pixels are baked into intact Idle/Walk/Block/Attack/Hurt/Death body frames. There is no separate ShieldVisual. Existing `_unshielded` frames and GuardBreak/break-effect resources provide a safe body-only and VFX baseline for the refactor.
- Chase calls `set_facing_direction()` as soon as target x changes side, including again on Attack entry. There is no turn timer or turn state, so a player crossing behind can be mirrored within one physics frame.
- Compact Main Enemy Debug currently reports encounter aggregates only; Expanded Shield summary exposes Block/broken state but not shield Health, side routing, damage split, attack id, overflow, or turn timer.

### Planned files and responsibilities

- New `ShieldComponent`: own max/current/broken state, typed signals, center-tolerant side classification, one-path damage routing, last-hit audit data, zero clamp, and no-overflow break contract.
- Shield Guard config/script/scene: set body 5, shield 3, GuardBreak 0.65, turn delay 0.22; arbitrate ShieldHit/Turn/GuardBreak/Death; drive separated ShieldVisual and feedback.
- Pixel generator/SpriteFrames/assets: convert Shield Guard body animations to shield-free art and author independent intact/cracked/critical/break plus small metal-hit assets.
- Main debug overlay and tests: surface compact shield state and expanded routing details without creating new HUD authority.
- README, Shield/combat/roster/encounter specifications, and this log: replace the superseded one-Dash-break contract.

### Verification plan

1. Generate/import/build assets with exact Godot 4.7.1 and validate transparency, nearest/lossless/no-mipmap imports, cracks, break, and foot baseline.
2. Test front normal 3→2→1→0 with body 5, front Dash 3→1→0 without overflow, rear 1/2 body damage with unchanged shield, center-overlap body routing, deduplication, 0.22-second turn window, 0.65-second GuardBreak, permanent unshielded recovery, and non-ghost Death.
3. Test both live Main instances, compact/expanded Debug, Player/HUD/Hurt/respawn regressions, all independent scenes, and the complete repository test suite.
4. Run configured Main graphically and retain original-resolution QA evidence for intact, cracked/critical, and broken states.

### Scope guard

- No other enemy, Player Health/damage/ability, attack timing, encounter count, Boss, item, drop, equipment, camera shake, hit-stop, audio, or unrelated system change.

### Delivered implementation

- Replaced the boolean-only `ShieldBlockComponent` with a typed `ShieldComponent` that owns `shield_max_health=3`, current Shield Health, broken state, change/hit/break signals, source-side classification, zero clamping, and last-hit audit data.
- Retained one shared enemy Hurtbox. Its policy resolves each accepted Player hit to exactly one destination: front normal/Dash attacks apply 1/2 Shield damage; rear or ±8-pixel center-overlap attacks apply 1/2 Body damage. The breaking hit discards overflow and never starts ordinary Body Hurt.
- Changed Shield Guard Body Health from 7 to 5 while retaining damage 8 and all existing move/attack cadence values. GuardBreak is 0.65 seconds and target-side turning is delayed 0.22 seconds.
- Added an explicit `Turn` state. Chase starts the timer when the target crosses behind, keeps the old facing during the window, and flips only after the delay. Attack, Block/ShieldHit, GuardBreak, Hurt, and Death do not turn.
- Separated body and shield presentation. All 31 shielded body source frames were regenerated without shield pixels; `FacingRoot/ShieldVisual` now owns intact, cracked, critical, and four-frame break art. A three-frame metal-hit flash, two-pixel shield shake, existing large fragment overlay, body flash, and GuardBreak marker provide distinct shield feedback.
- Kept the named shieldless action set for post-break Idle/Walk/Attack/Hurt/Death. Zero Shield immediately disables routing, the break runs once, ShieldVisual hides, and no recovery path restores it.
- Added attack-direction context to `HitboxComponent.begin_attack()` and supplied the actual Player/Shield Guard attack facing without changing damage, windows, movement, or input behavior.
- Compact Main Enemy Debug now adds a third shield summary line with Body, Shield, visual state, side, state, and turn timer while preserving the existing 380×68 panel. Expanded Debug additionally reports attack kind/source/direction/id, Shield/Body applied damage, discarded overflow, and GuardBreak remaining time.
- Moved Main Group01 Shield Guard to `(500, 610)` and Castle Guard to `(690, 610)`. This preserves the same roster/count while making the shield mechanic the first isolated encounter target.

### Commands and actual results

1. Exact engine/resource production:
   - `/Users/vincentz/Downloads/Godot.app/Contents/MacOS/Godot --version`: `4.7.1.stable.official.a13da4feb`.
   - Pixel generator: `ENEMY_VARIETY_PIXEL_BUILD: OK (126 files)`.
   - `Godot --headless --path . --import`: exit 0; new/changed transparent PNGs imported without script or resource diagnostics.
   - SpriteFrames builder: `ENEMY_VARIETY_SPRITE_FRAMES_BUILD: OK`.
2. Focused tests:
   - `ENEMY_VARIETY_TEST`: PASS — 3→2→1→0 normal route, 3→1→0 Dash route, no overflow, rear/center Body routing, single-hit memory, Shield states/VFX, 0.22-second turn, 0.65-second GuardBreak, punish window, permanent unshielded Death, and no ghost.
   - `ENEMY_BALANCE_TEST`: PASS — frontal totals 8 normal / 5 Dash; rear totals 5 normal / 3 Dash; other enemies and Player invariants unchanged.
   - `ENEMY_VARIETY_ASSET_TEST`: PASS — 124 64×64 frames/effects plus bolt; transparent, lossless/no-mipmap imports and 48×48 readability floor.
   - `MAIN_ENEMY_INTEGRATION_TEST`: PASS — both saved Main instances own ShieldComponent/ShieldVisual, use Body 5 and Shield 3, execute both frontal break routes, rear bypass, post-break damage, correct debug, Death, and cleanup.
3. Full regression:
   - First pass stopped at `test_main_debug_hud.gd` because an interim 420×84 panel exceeded the existing compact contract. The panel was restored to 380×68 without dropping fields.
   - Final serial run: all 28 scripts under `tests/` exited 0 with no final `SCRIPT ERROR`, `ERROR:`, or `WARNING:` output.
   - Player level metrics remain 153.59 single-jump range, 281.92 debug-double-jump range, 344.00 four-Air-Dash action range, and 360.33 pixels through landing.
4. Runtime startup:
   - `Godot --headless --path . res://scenes/enemies/cursed_shield_guard.tscn --quit-after 120`: exit 0.
   - `Godot --headless --path . --quit-after 120`: configured F5 Main exit 0.
5. Graphical Main QA:
   - `Godot --path . --script res://scripts/tools/capture_shield_guard_break_main.gd --write-movie docs/qa/shield_guard_independent_main.png --fixed-fps 30 --audio-driver Dummy --log-file docs/qa/shield_guard_independent_main.log`: exit 0 under GL Compatibility on Apple M4; 37 frames at 1280×720.
   - The capture uses the real Main Player Dash Hitbox twice against `EncounterGroup01/Enemies/CursedShieldGuard01`. Selected frames were inspected at original resolution.
6. Final `git diff --check`: PASS.

### F5 Main synchronization and QA evidence

- `application/run/main_scene` remains `res://scenes/main/main.tscn`.
- `World/Encounters/EncounterGroup01/Enemies/CursedShieldGuard01` and `World/Encounters/EncounterGroup04/Enemies/CursedShieldGuard02` both reference the current `res://scenes/enemies/cursed_shield_guard.tscn` with no local script/config/resource override.
- The shared scene owns `ShieldComponent`, one `Hurtbox`, `FacingRoot/ShieldVisual`, `ShieldHitEffect`, `ShieldBreakEffect`, body-only SpriteFrames, and the existing GuardBreak marker. Main therefore cannot retain the removed boolean policy or shield-baked art after reload.
- `docs/qa/shield_guard_critical_f5_main.png` (SHA-256 `2dc545143e9f0a336e5300fd2dff3c2923cae42b630fd3b189bda6b3117e1150`) shows live Main at Body 5/5, Shield 1/3, `critical`, front-side Block.
- `docs/qa/shield_guard_break_f5_main_v2.png` (SHA-256 `62e11d0bacaf02477ae6027d9706f7637e1102a3920f215d2dc6b80f2758ef9f`) shows the second Dash impact, Shield 0/3, `broken`, GuardBreak, flash/fragments, marker, and absent shield body art.
- Main integration and the full suite also preserve live Health/Stamina binding, Player Hurt/invulnerability, death ghost/respawn, encounters, other enemy damage/Death, camera, and movement behavior.

### Manual acceptance and known limitations

- Manually judge the light/severe crack shapes at the user's display scale and test both facings with actual inputs. Automated image inspection establishes that distinct art and state transitions are rendered, not subjective readability on every monitor.
- The 0.22-second turn uses the existing idle body pose rather than new bespoke turn frames. Logic and facing remain truthful throughout the rear window.
- No always-on in-world Shield bar was added; the required visual cracks are authoritative, while Compact/Expanded Debug provides numeric development confirmation.
- Hit-stop, camera shake, audio, rigid shield fragments, shield regeneration, new attacks, and all unrelated enemy/Player systems remain intentionally excluded.

## 2026-07-24 — Shield Guard Dash penetration and break-flash correction (preflight)

Status: complete — unified source routing, two-layer attack-id deduplication, softer shield-local flash, 28-script regression, and configured-Main graphical QA passed; manual feel acceptance pending

### Goal

- Stop one frontal Dash Attack from reaching Shield and Body during the same action, including the frame after a breaking hit.
- Keep rear routing and no-overflow behavior unchanged.
- Replace the current whole-body/high-intensity break flash with a 0.05-second, 0.30-alpha shield-local cue while retaining cracks, fragments, disappearance, and GuardBreak.

### Read-only audit and root cause

- `project.godot` still resolves F5 to `res://scenes/main/main.tscn`; both saved Main Shield Guards instance the current shared `cursed_shield_guard.tscn` without local overrides.
- Shield Guard has exactly one `HurtboxComponent`, which delegates to exactly one `ShieldComponent`; there are no overlapping Shield/Body Hurtboxes and no Area signal-order race between two Health writers.
- Player normal and Dash attacks use separate Hitbox nodes. A Dash Attack action creates one `_current_attack_id`, opens the Dash Hitbox across consecutive frames 03–04, and `HitboxComponent` normally remembers the one target for that active window.
- `ShieldComponent` nevertheless classifies side using `hitbox.global_position`. At body-contact distance the Player remains in front while the 37-pixel-forward Dash Hitbox center reaches the Shield Guard center/other side, so the unified policy can misclassify a visually frontal Dash as Body. Tests previously placed the Hitbox center 30–32 pixels in front and did not reproduce real scene geometry.
- `ShieldComponent` also has no independent consumed-attack ledger. If the same Dash Hitbox is re-enabled/re-scanned with the same `attack_id` after Shield reaches zero, its local target set may be cleared and the now-broken policy can route that continuing action to Body.
- The current break presentation combines a 2× overlay containing a pure-white 9×9 core with whole-body `Color(1.8, 1.65, 1.25)` modulation lasting 0.12 seconds. This makes the auxiliary flash visually dominate the authored cracks/fragments.

### Planned files and scope

- `HitboxComponent` and Player action wiring: carry the typed attacker/root source position while preserving the same stable action id and all animation/input/damage values.
- `ShieldComponent`: classify against attacker position, record the last consumed id per attacker, reject repeated submissions even after break, and expose route/dedup/overflow audit fields.
- Shield Guard config/presentation/generator: configure 0.05/0.30, localize the flash to the shield, soften the overlay core, and keep all existing fragment/GuardBreak timing.
- Shield/Main tests: reproduce actual Player/DashHitbox offsets, both facings, same-id re-entry after break, new-id post-break damage, unchanged rear damage, and saved Main instances.
- Only `development_log.md`, `combat_system_spec.md`, and `enemy_cursed_shield_guard_spec.md` will be updated. No balance, animation timing, Player movement/action, encounter-count, other-enemy, or new-feature changes are in scope.

### Delivered correction

- Extended `HitboxComponent` with a typed attacker reference. Player normal and Dash active windows now retain the Player root as their source, while all existing callers fall back to the Hitbox position. The Shield policy therefore classifies the actor's side rather than the forward weapon volume's center.
- Kept one shared Shield Guard Hurtbox and one `ShieldComponent` decision boundary. A received attack is marked consumed before the policy selects exactly one route: intact/front Player weapon attacks go to Shield; rear, center-source, non-Player-weapon, or already-broken cases go to Body.
- Added a bounded Shield-side ledger keyed by `attacker instance id + attack_id`. It survives shield break and rejects a later active frame or a second detector submission from the same action. `HitboxComponent` also no longer clears its local target memory when the same attack id is merely reopened.
- Retained no-overflow semantics. A two-damage Dash against Shield 1/3 produces Shield 0/3, records one discarded point, enters GuardBreak, and leaves Body 5/5.
- Replaced the 0.12-second whole-body `Color(1.8, 1.65, 1.25)` break highlight with a shield-local 0.05-second alpha-0.30 pale-steel flash. The 9×9 pure-white core and long thick rays were removed from the first two overlay frames; cracks, metal fragments, shield disappearance, marker, and 0.65-second GuardBreak remain.
- Ordinary shield-hit feedback is now lower priority than break: local spark alpha 0.18 and mild ShieldVisual modulation `Color(1.08, 1.06, 0.98)`; the body is never flashed.
- Compact Shield Debug remains inside the existing panel contract and reports Body/Shield, side, route, type/id, broken, and state. Expanded output adds shield/body detector route flags, consumed, duplicate blocked, and discarded overflow.

### Actual route matrix

- Front normal from Shield 3/3: Body remains 5/5 while Shield progresses 2/3 → 1/3 → 0/3.
- Front real-geometry Dash: before `BODY 5 SH 3`; hit 1 `BODY 5 SH 1`; hit 2 `BODY 5 SH 0`.
- Shield 1/3 + front Dash 2: `BODY 5 SH 0`, overflow discarded 1.
- Rear Dash: `BODY 3 SH 3`.
- After break, new ids route normally: new normal changes Body 5→4; the following new Dash changes Body 4→2.
- The regression fixture explicitly places the Player 34 pixels in front while the authored Dash Hitbox center reaches the Shield Guard's ±8-pixel center tolerance. It therefore reproduces the old false Body route and verifies the Player-root correction rather than hiding it by shrinking the Hitbox.

### Commands and actual results

1. Exact Godot 4.7.1 asset production/import:
   - `Godot --headless --path . --script scripts/tools/pixel_enemy_variety_generator.gd`: exit 0; `ENEMY_VARIETY_PIXEL_BUILD: OK (126 files)`.
   - `Godot --headless --path . --editor --quit`: exit 0; two revised break-overlay PNGs reimported without diagnostics.
2. Focused tests:
   - `test_hitbox_hurtbox_components.gd`: PASS, including same-id active-window reopen deduplication.
   - `test_player_attack_damage.gd`: PASS, including stable Dash id across both active frames and Player-root source context.
   - `test_enemy_variety.gd`: PASS and printed `SHIELD_DASH_MATRIX: before B5 SH3; front1 B5 SH1; front2 B5 SH0; rear B3 SH3; post-break normal/dash B4/B2`.
   - `test_enemy_balance.gd`: PASS; Body 5, Shield 3, damage 8, GuardBreak 0.65, turn 0.22, Player 1/2, and all other enemy values remain unchanged.
   - `test_main_enemy_integration.gd`: PASS using the live Main Player/Shield Guard geometry and the shared Main instances.
   - `validate_enemy_variety_assets.gd`: PASS for 124 64×64 frames/effects plus bolt, transparency, lossless/no-mipmap imports, and 48-pixel readability floor.
3. Full serial regression: all 28 scripts under `tests/` exited 0; no captured output contained final `SCRIPT ERROR`, `ERROR:`, or `WARNING:` diagnostics.
4. Runtime startup:
   - Standalone `cursed_shield_guard.tscn --quit-after 120`: exit 0.
   - Configured F5 Main `--quit-after 120`: exit 0.
5. Graphical configured-Main run:
   - `capture_shield_guard_break_main.gd` with `--write-movie`, 1280×720, fixed 30 FPS, GL Compatibility on Apple M4: exit 0, 37 frames.
   - Runtime output: `SHIELD_MAIN_QA: BODY 5 SH 0 ROUTE shield SIDE front DUP false`.
   - Original-resolution inspection confirms Shield 1/3 critical feedback, Shield 0/3 GuardBreak, missing shield, fragments/marker, and no whole-body white flash.

### F5 Main synchronization and QA evidence

- `application/run/main_scene` remains `res://scenes/main/main.tscn`.
- `World/Encounters/EncounterGroup01/Enemies/CursedShieldGuard01` and `World/Encounters/EncounterGroup04/Enemies/CursedShieldGuard02` still instance the updated shared `res://scenes/enemies/cursed_shield_guard.tscn` without local script/config/resource overrides.
- The Player instance `World/Player` uses the revised shared `player.tscn` controller and both Player Hitboxes now submit `World/Player` as attacker. Both Shield Guard instances use the revised shared `ShieldComponent` and flash Config, so no Main-local reauthoring is required or stale.
- Group01 remains the isolated first Shield Guard encounter and the encounter roster/count is unchanged.
- `docs/qa/shield_guard_dash_route_soft_flash_f5_main.png` (SHA-256 `82fbadf79d015a556bd5a0515ef72ee3668db0f84b9febe051ff4286ab3e93c3`) is the inspected configured-Main frame. Its Compact row shows Body 5/5, Shield 0/3, front, shield route, Dash id, broken, and GuardBreak while the body remains normally lit.
- `docs/qa/shield_guard_dash_route_soft_flash_f5_main.log` preserves the graphical run output.

### Manual acceptance and known limitations

- Manually repeat the front Dash test from both sides at normal input speed and judge the reduced flash on the target display. Automated geometry, routing, state, and original-resolution rendering are verified; subjective brightness still requires user acceptance.
- The shared Shield Guard scene intentionally has one Hurtbox detector rather than separate physical Shield/Body Areas. Expanded `SH_DETECT/BODY_DETECT` fields describe the final unified route, not two independent damage writers.
- The consumed-key ledger retains the latest 64 attack keys per Shield Guard, which is ample for the encounter and bounded against unbounded growth. Shield reset clears it; shield break does not.

## 2026-07-24 — First-level enemy roster and Fallen Gate Knight Boss (preflight)

Status: in progress — implementation and acceptance evidence pending

### Goal

- Add the airborne `GargoyleSentinel` normal enemy with a readable Dive → GroundStun → Return loop.
- Add the two-phase `FallenGateKnight` Boss with independently routed Body/Shield Health, five distinct attack families, Boss HUD, arena gates, checkpoint/reset flow, and level-complete exit.
- Expand configured F5 Main from four groups/nine enemies to seven groups/eighteen enemies, then place a separate Boss room after the normal-enemy route.
- Preserve all approved Player, Shield Guard, normal-enemy, HUD, damage, death, and respawn behavior.

### Read-only audit

- `project.godot` resolves F5 to `res://scenes/main/main.tscn`; the authored viewport is 1280×720.
- Main currently ends near x=2500, contains one Player spawn, four one-shot EncounterGroups, and nine normal enemies: Castle Guard ×3, Shield Guard ×2, Spearman ×2, Crossbowman ×2. It has no gargoyle, Boss, Boss room gates, pre-Boss checkpoint, Boss HUD, or level exit.
- Existing combat composition is reusable: `EnemyCombatant`, `GroundEnemyBase`, `HealthComponent`, `HitboxComponent`, `HurtboxComponent`, and the corrected `ShieldComponent` already provide typed contracts, faction filtering, stable attack-id deduplication, and single-route Shield/Body damage.
- Castle Guard, Shield Guard, Spearman, Crossbowman, Player Health, and Player 1/2 attack damage match the approved balance. Spearman lacks the requested 0.15-second late-windup direction lock; Crossbowman tracks continuously through Aim and lacks the requested final 0.18-second aim lock.
- `PlayerRespawnController` currently owns one fixed `Marker2D` reference and has no checkpoint setter or Boss-reset handshake.
- `EncounterGroup` supports mixed `EnemyCombatant` children but limits simultaneous attackers to three and its engaged/attacking state lists do not include Gargoyle states.
- Current Main Debug uses typed enemy queries and compact/expanded text reuse. It needs only bounded Gargoyle/Boss fields; no new gameplay authority belongs in Debug UI.

### Planned files and responsibilities

- Gargoyle config/script/scene, generated transparent pixel frames, SpriteFrames, and focused tests: flight state, dive collision/damage, stun counter-window, return, hurt, and shatter death.
- Fallen Gate Knight config/script/scene and art: Boss AI/presentation, shared ShieldComponent routing, phase transition, distinct attack windows, no-ghost death, and resettable instance lifecycle.
- Boss room controller and Boss HUD: encounter locking, checkpoint selection, Player restore, Boss reset on Player respawn, signal-driven bars, gate-open message, and level-complete exit.
- Main/encounters/debug: extend the graybox, author seven staged groups with eighteen normal enemies, add Gargoyle teaching space and a separate Boss arena, then surface concise debug state.
- Existing Spearman/Crossbowman config and scripts: add only the missing direction/aim lock parameters without changing approved cadence or balance.
- Tests, QA capture scripts/evidence, README, combat/roster/encounter/Boss specs, level metrics, and this log.

### Verification plan

1. Generate/import/build all art with exact Godot 4.7.1; validate frame names, transparency, nearest/lossless/no-mipmap imports, anchors, facings, and 48-pixel readability.
2. Run focused component/enemy/Boss/room tests, updated Main integration tests, every independent scene, and the complete serial repository suite.
3. Run configured F5 Main headlessly and graphically; verify seven encounter activations, all five normal types, Boss lock/phase/death/reset/exit, Player attacks/Hurt/death/respawn, HUD bindings, collision/camera, and zero final errors.
4. Retain original-resolution configured-Main screenshots and log output under `docs/qa/`.

### Scope guard

- No flying-enemy variant, elite enemy, second Boss, third Boss phase, summons, experience, loot, inventory, equipment, save system, second level, or unrelated Player/balance redesign.

### Delivered implementation

- Added `GargoyleSentinelConfig`, a composed `GargoyleSentinel` scene, ten named animations, and 41 original 64×64 source frames. The state loop is Dormant/Wake → Track → 0.45-second DiveWindup with final 0.15-second lock → one-hit Dive → World-impact GroundStun 0.65 → ReturnToAir. Health 3, damage 7, 220-pixel detection, 45 hover speed, 300 Dive speed, 70-pixel return height, and 1.10-second cooldown are centralized in one Config.
- Added a resettable `FallenGateKnight` Boss composed from the existing Health/Hitbox/Hurtbox and corrected ShieldComponent rather than a duplicate routing implementation. Body is 18, Shield is 6; Bash/Slash/Heavy/Charge/Shockwave damage is 8/10/15/12/8. All seven attack families use stable ids, bounded active frames, faction filtering, and CharacterBody collision motion.
- Authored 18 Boss animations and 90 original 96×96 source frames. Phase 1 cycles Shield Bash, Sword Slash, and Heavy Overhead. Shield zero has no Body overflow, plays a 0.90-second ShieldBreak plus 1.10-second PhaseTransition, permanently removes defense, and enters faster Phase 2 with Combo Slash, Jump Smash, Charge Thrust, and Shockwave Strike. Death drops the sword, collapses/dissolves, emits completion, and never creates a ghost.
- Added `BossRoomController`: checkpoint `(5480,612)`, entry x=5600, entrance gate x=5630, Boss `(6120,596)`, exit gate x=6480, and exit trigger x=6540. Entry restores Player Health/Stamina, selects checkpoint, locks the arena, activates Boss, and shows HUD. Player respawn fully resets Boss and rearms entry. Boss death opens the exit and displays the bilingual gate message; exit displays level complete without loading another level.
- Added a signal-driven Boss HUD for name, Body 18, and Shield 6. Shield zero hides the Shield bar and reports `BROKEN`; Boss death fades the panel. The HUD never owns combat values.
- Expanded configured Main floor to x=-100..6600 with seven staged normal encounters and eighteen enemies: Guard 8, Shield 2, Spear 2, Crossbow 3, Gargoyle 3. Group sizes are 2/3/2/2/2/3/4; Group05 isolates Gargoyles, Group06/07 combine mechanics, and the Boss arena contains no normals.
- Added only the missing approved direction rules to existing enemies: Spearman locks the final 0.15 seconds of windup and Crossbowman locks the final 0.18 seconds of Aim. All existing Health, damage, attack cadence, Player, Shield Guard, and HUD balance remains unchanged.
- Extended Main Debug type naming and expanded summaries for Gargoyle Dive/stun/target/height and Boss Phase/Body/Shield/state/Hitbox/room/dead fields. Existing compact panel dimensions, F1/F2/F3 behavior, and Debug-off behavior remain unchanged.
- Added independent Gargoyle/Boss test rooms, deterministic pixel/SpriteFrames builders, focused state/combat/room tests, source-asset validation, and configured-Main graphical capture tooling.

### Commands and actual results

1. Engine and baseline:
   - `/Users/vincentz/Downloads/Godot.app/Contents/MacOS/Godot --version`: `4.7.1.stable.official.a13da4feb`.
   - Baseline configured Main `--headless --path . --quit-after 120`: exit 0, no script/resource diagnostics.
2. Asset production:
   - `--script res://scripts/tools/pixel_first_level_boss_generator.gd`: `FIRST_LEVEL_BOSS_PIXEL_BUILD: OK (131 files)`.
   - `--headless --path . --import`: exit 0.
   - `--script res://scripts/tools/first_level_boss_sprite_frames_builder.gd`: `FIRST_LEVEL_BOSS_SPRITE_FRAMES_BUILD: OK`.
   - `validate_first_level_boss_assets.gd`: PASS — 131 transparent frames, Gargoyle 64×64, Boss 96×96, lossless import, no mipmaps.
3. Focused behavior:
   - `test_gargoyle_sentinel.gd`: PASS — wake, 7-damage one-hit Dive, 0.65 GroundStun, return, death fall/shatter, no ghost.
   - `test_first_level_boss.gd`: PASS — Main nodes/coordinates, entry restore/lock/HUD, Shield 6 routing/no overflow, Phase 2, all seven attack-family active windows and 8/10/15/12/8 damage, one-hit memory, death/exit, and full respawn reset.
   - `test_main_enemy_integration.gd`: PASS — seven groups, eighteen mixed enemies, every saved Main PackedScene/resource, activation, Player 1/2 damage, normal-enemy death, Gargoyle shatter, HUD/respawn, and Boss room.
4. Independent scenes:
   - `gargoyle_sentinel.tscn`, `fallen_gate_knight.tscn`, `gargoyle_test_room.tscn`, and `boss_test_room.tscn` each ran headlessly for 120 frames with exit 0 and no final diagnostics.
5. Complete regression:
   - Exact Godot import plus every `.gd` under `tests/` in sorted serial order: `FINAL_TESTS count=31 failures=0`; captured output contained no final `SCRIPT ERROR`, `ERROR:`, or `WARNING:` diagnostics.
   - Existing measured Player envelope remains unchanged: single jump 153.59 px, debug double jump 281.92 px, four-Air-Dash action range 344.00 px.
6. Configured Main runtime:
   - `Godot --headless --path . --quit-after 120 --log-file docs/qa/first_level_main_headless.log`: exit 0, no red errors.
   - Graphical GL Compatibility run on Apple M4 using `capture_first_level_main.gd`: exit 0 and printed `FIRST_LEVEL_MAIN_QA: groups=7 normals=18 boss=BossIntro locked=true hud=true`.
   - `docs/qa/first_level_main_gargoyle.png`: 1280×720, SHA-256 `80ef35cbcdfe721563267ad7e83d3996560d2c2b393e7a408e3b755d85ff5262`.
   - `docs/qa/first_level_main_boss.png`: 1280×720, SHA-256 `c23d4d53469baa5a373bf1905f1fd4dcd8a8bfdebf9b7cf92bb388cb7a84f867`.
   - Both images were inspected at original resolution: Gargoyle silhouettes, Boss/Player scale, arena gate, 18/6 Boss HUD, formal HP/Stamina HUD, and nearest-neighbor pixel edges are visibly present in the actual configured Main.

### F5 Main synchronization

- `application/run/main_scene` remains `res://scenes/main/main.tscn`.
- Normal enemy instances live at `World/Encounters/EncounterGroup01..07/Enemies/*` and all reference shared current PackedScenes. Gargoyles are Group05 at `(3480,270)` / `(3680,270)` and Group07 at `(4960,300)`.
- Boss integration is saved under `World/BossRoom`: `BossCheckpoint`, `EntryTrigger`, `EntranceGate`, `FallenGateKnight`, `ExitGate`, and `ExitTrigger`. `BossRoomController` is the Main sibling coordinator; `HUD/BossHealthHud` and `HUD/LevelCompletePanel` are the live presentation instances.
- Player Camera limits now cover 0..6600; floor/world collision and the right boundary extend through the exit. Formal Health/Stamina bindings, Debug Canvas, Player death ghost, respawn controller, and all existing shared Player resources remain live.

### Manual acceptance and known limitations

- Manual play should judge Group06/07 multi-enemy fairness, Gargoyle windup/ground-stun readability, and each Boss telegraph at normal input speed. Automated tests prove timing, routing, collision interfaces, and saved integration, not subjective difficulty.
- Boss Phase 2 is a deterministic four-attack cycle for gray-box reproducibility. There is no behavior tree, random weighting, third phase, summon, elite, reward, or audio pass.
- Boss reset currently occurs after the existing complete Player death/ghost sequence; normal enemies already defeated before the checkpoint remain removed. This is intentional for the one-checkpoint first-level gray box.
- The level-complete exit displays a terminal overlay and does not load a second level, as scoped.

## 2026-07-24 — First-level platform reachability audit and repair (preflight)

Status: complete — all elevated Main combat surfaces reachable, three spawn-origin route runs and 33-script regression passed; manual feel acceptance pending

### Goal

- Measure the shipping Player scene through its real Input Map and `CharacterBody2D` path, then repair every unreachable standable surface in configured F5 Main.
- Keep Player movement, stamina, combat, enemy balance/AI, Boss behavior, HUD sizing, and animation art unchanged.
- Make all elevated Crossbow positions and the Gargoyle landing/counter window reachable by stable double jump without requiring chained Air Dash.

### Read-only audit

- `project.godot` resolves F5 to `res://scenes/main/main.tscn`; Main directly instances `res://scenes/player/player.tscn` at `World/Player` with no movement, double-jump, action, or stamina overrides.
- First-level collision is authored directly under `Main/World` as one continuous `StaticBody2D` floor plus `PlatformA..D` and `GargoylePerch`; there is no TileMap or nested stale Level PackedScene.
- Shipping tuning is `move_speed 220`, ground/air acceleration `1400/850`, jump velocity `-420`, gravity `1100`, coyote `0.10`, buffer `0.12`, Dash `480 × 0.18`, and Stamina `100/25`. There is no separate double-jump velocity, variable-height release cut, or maximum-fall clamp. Debug double jump is enabled in the shared Player scene and reuses `-420`.
- Exact Godot 4.7.1 baseline measurement at 60 physics ticks/s: single jump `153.59` horizontal / `83.77` rise; apex-timed double jump `281.92` horizontal / `167.10` rise; four paid Air Dash segments `344.00` action-only range. Player collision is 24×52 at local y=2, so root-to-foot is 28 px.
- Platform top-surface audit: Floor y=640; PlatformA y=508 (132 rise, safe); PlatformB y=426 (214 rise, unreachable); PlatformC y=458 (182 rise, unreachable); PlatformD y=438 (202 rise, unreachable); GargoylePerch y=328 (312 rise, unreachable). The three unreachable combat platforms each host a Crossbowman; the perch intercepts Gargoyle dives above the Player's reachable counter window.

### Planned files, tests, and scope check

- Extend the existing deterministic movement-envelope test to cover standing rise, forward jump/double-jump, one-Air-Dash combinations, full-stamina chain, collision-foot displacement, departure/landing margins, and minimum production landing width.
- Add a focused Main traversal regression that reads saved top surfaces, widths, enemy offsets, and route classification from the actual F5 scene.
- Move only the four invalid Main surfaces and their dependent Crossbow/Gargoyle spawn positions; keep Floor, PlatformA, encounter triggers, Camera limits, checkpoint, gates, Boss arena, and all gameplay tuning unchanged.
- Add a small default-off Level Traversal Debug overlay that observes Player/platform state and shares existing F1 visibility without owning collision or gameplay.
- Update `level_metrics.md`, `first_level_encounter_spec.md`, add `level_traversal_spec.md`, update README and this log; retain configured-Main QA evidence under `docs/qa/`.
- Scope remains limited to first-level traversal repair: no new enemy, Boss skill, second level, equipment, combat tuning, or Player ability change.

### Delivered repair

- Kept the configured F5 source at `res://scenes/main/main.tscn` and changed its direct World geometry rather than creating a parallel level. PlatformB/C/D centers moved from y=438/470/450 to 512/516/520, producing top surfaces y=500/504/508. `GargoylePerch` moved from center y=340 to 504, producing top y=492.
- PlatformA and all four moved surfaces now use downward-facing one-way collision. Their visual top remains exactly aligned with collision top; only the lower stone edge gained a restrained broken-stone silhouette. No invisible collider or TileMap layer was introduced.
- Resulting rises from Floor top y=640 are 132/140/136/132/148 px for PlatformA/B/C/D/Perch: 79.0%/83.8%/81.4%/79.0%/88.6% of measured double-jump rise. Every surface is inside the main/challenge 90% ceiling and 190–240 px wide versus the 48 px production landing minimum.
- Moved the Group04/06/07 Crossbowmen from y=396/428/408 to 470/474/478. Each root remains exactly 30 px above its new top and centered with at least 79 px edge clearance.
- Moved Group05 Gargoyles from `(3480,270)/(3680,270)` to `(3500,402)/(3620,402)`. Both remain 90 px above the reachable perch with 44 px horizontal edge safety, so Dive can produce a reachable GroundStun counter window and ReturnToAir can recover to the saved home height.
- Added a default-off read-only `LevelTraversalDebugOverlay` at `Main/Interface/DebugHudRoot/LevelTraversalDebug`. F4 toggles collision-foot Y, jump start/rise/distance, recorded peaks, nearest platform deltas, and reach rating; F1 still hides its parent Debug root. It creates no geometry and owns no gameplay state.
- Added deterministic platform and route suites. The platform test performs real double-jump landings on all five surfaces. The three-route test starts at the saved spawn and never changes Player position: Floor-only/no-Air-Dash Boss approach, mobility Crossbow route including double jump + one Air Dash, and a novice Gargoyle route with the second jump deliberately delayed until downward velocity reaches 50 px/s.

### Actual measurements and route standards

- Standing/forward single jump: 83.77 px rise; forward range 153.59 px.
- Standing/forward double jump: 167.10 px rise; forward range 281.92 px.
- Single jump + one Air Dash: 192.92–196.59 px; double jump + one Air Dash: 321.26–324.92 px. The small interval is the accepted fixed-step boundary depending on which apex tick consumes input.
- Four paid Air Dashes: 344.00 px action-only; 360.33–362.22 px from jump entry to landing. Full-Stamina chains remain shortcut capacity, not a normal-platform requirement.
- Main safe ceiling is 133.68 px (80%); Challenge ceiling is 150.39 px (90%); Hidden/reward ceiling is 158.75 px (95%).

### Commands and actual results

1. Exact Godot 4.7.1 measurement:
   - `Godot --headless --path . --script tests/player/measure_player_level_metrics.gd`: PASS with the values above, Player foot offset 28 px, 98 px center-to-safe-edge departure difference on a 220 px platform, and 48 px minimum safe landing width.
2. Saved Main geometry/physics:
   - `test_main_platform_reachability.gd`: PASS — five surfaces, one-way collision, aligned enemies, and five real double-jump landings.
   - `test_main_traversal_routes.gd --log-file docs/qa/main_traversal_routes.log`: PASS — all three routes from actual spawn, no teleport.
3. Focused regressions:
   - Main enemy integration, Gargoyle Sentinel, first-level Boss, M1 movement, and Main Debug HUD including F4: all PASS.
4. Complete repository regression:
   - All 33 scripts under `tests/` ran serially through exact Godot 4.7.1 and passed. Captured outputs contained no final `SCRIPT ERROR`, `ERROR:`, or `WARNING:` diagnostics.
5. Configured Main runtime:
   - Headless `Godot --headless --path . --quit-after 300 --log-file docs/qa/main_traversal_f5_headless.log`: exit 0, no diagnostics.
   - Graphical `Godot --path . --quit-after 300 --log-file docs/qa/main_traversal_f5_graphical.log`: exit 0, GL Compatibility on Apple M4, no diagnostics.
   - Graphical Main QA capture script: exit 0 and `MAIN_TRAVERSAL_QA: PlatformB top=500 GargoylePerch top=492 PlatformC/D top=504/508`.

### Configured-Main QA evidence

- `docs/qa/main_traversal_crossbow_platform_b.png`: 1280×720, SHA-256 `6ecb6489f985954541bc89c4533dfd857f66ffe91db100896d1cd23365615346`.
- `docs/qa/main_traversal_gargoyle_perch.png`: 1280×720, SHA-256 `d421ba23ecec23ee52fc2a07c740b2d76d141241032c5fe0b725db0bf2583c33`.
- `docs/qa/main_traversal_platforms_c_d.png`: 1280×720, SHA-256 `3e011f2c96f5566a5caaf9a03b925135821785bb3c0d990129db76ba625f4272`.
- Original-resolution inspection confirms Player/collision-foot alignment on PlatformB/Perch, centered Crossbow/Gargoyle positions, readable broken-stone edges, formal HUD, and compact Debug panels in the actual Main composition.

### Manual acceptance and known limitations

- Manually repeat PlatformB/C/D and GargoylePerch from Floor at normal input speed, including approaching from both directions. Automation proves physics reach and timing tolerance; it cannot decide subjective platform rhythm.
- The first-level Floor remains a continuous gray-box mainline. Lowering the combat surfaces makes them accessible but does not convert this milestone into a finished environmental-art or multi-route level-design pass.
- Traversal classification is based on the current measured Player resource. If Player movement is deliberately retuned later, rerun the measurement and update the overlay thresholds/spec together.
- No intermediate platforms were added because direct lowering and one-way collision fully solved the invalid surfaces with the smallest Main diff.

## 2026-07-24 — Solid platform collision and castle-bridge Boss arena redesign (preflight)

Status: complete — solid collision, configured-Main castle bridge flow, 34-script regression and graphical QA passed; manual feel acceptance pending

### Goal

- Replace the first-level elevated one-way surfaces with real solid world collision so the Player lands from above and is stopped by the underside from below during jump, double jump, Air Dash, and Dash Attack traversal.
- Replace the current flat-floor two-rectangle Boss room with a saved F5 Main route of checkpoint → near bank → moat → continuous old wooden bridge → Fallen Gate Knight battle → closed castle gate → animated gate opening → Chapter I completion trigger.
- Keep Player movement/jump/Dash/Stamina/attack tuning, all enemy and Boss health/damage/attack profiles, enemy AI, and HUD sizes unchanged.

### Read-only audit

- `project.godot` resolves F5 to `res://scenes/main/main.tscn`; Git started clean on `master` at `1f4ab5f` and synchronized with `origin/master`.
- Main authors collision directly under `Main/World`. `PlatformA`, `PlatformB`, `PlatformC`, `PlatformD`, and `GargoylePerch` are `StaticBody2D` nodes whose `CollisionShape2D.one_way_collision` is still `true`; this is the direct cause of underside penetration.
- The shipping Player uses a 24×52 rectangular `CharacterBody2D` collider and `move_and_slide()` for normal movement and action movement. No alternate Dash collider or position teleport was found. The body script does not yet explicitly clear upward velocity after a ceiling collision.
- The current `World/BossRoom` is drawn over the same continuous Floor: checkpoint x=5480, entry trigger x=5600, a narrow `EntranceGate` x=5630, Boss x=6120, narrow `ExitGate` x=6480, and exit trigger x=6540. There is no moat, bridge body, water hazard, visible rear battle barrier, castle facade, animated gate, bridge bounds, or Boss-camera lock.
- `BossRoomController` instantly hides/disables gates. Boss death completion already emits only after the death animation finishes, and Player respawn already resets an uncleared Boss while retaining a cleared Boss; these behaviors will be preserved and extended rather than duplicated.
- Existing traversal and Boss tests explicitly assert the obsolete one-way/two-gate design and must be rewritten against the saved Main composition.

### Planned files, tests, and scope check

- Update `scenes/main/main.tscn`, `scripts/player/player.gd`, `scripts/bosses/fallen_gate_knight.gd`, and `scripts/bosses/boss_room_controller.gd`; add small composed gate and moat controllers rather than embedding the complete sequence in Player or Boss code.
- Rewrite the platform collision tests for underside blocking plus top landing, retain spawn-origin route tests with edge approaches suitable for solid platforms, and extend Boss integration tests for checkpoint, visible rear barrier, bridge bounds, moat death, delayed gate collision release, reset, and completion.
- Add/update the requested traversal, Boss room, encounter, collision-layer, and level-metrics documentation and capture three configured-Main QA frames: underside collision, bridge battle, and opened castle gate.
- Scope excludes new enemies, new Boss attacks/phases, second level, rewards, combat tuning, Player ability changes, and unrelated visual/UI redesign.

### Delivered implementation

- Removed `one_way_collision` from `Main/World/PlatformA`, `PlatformB`, `PlatformC`, `PlatformD`, and `GargoylePerch`. All retain their saved 190–240×24 visual/collision dimensions and now block from top, bottom and sides. Floor, walls, bridge, castle floor/facade, rear barrier and closed gate are also full World bodies.
- Kept the shipping Player 24×52 rectangle at local y=2 for Standing, Hurt, Dash, Dash Attack, Death and Respawn. All action movement still reaches `move_and_slide()`; no action changes `global_position`. A focused post-slide ceiling resolver now guarantees `velocity.y >= 0` on `is_on_ceiling()` and returns unlocked locomotion to Fall without restoring jumps, Stamina or land state.
- Replaced the saved `World/BossRoom/EntranceGate/ExitGate` composition. Main now owns `World/CastleEntranceArea`: checkpoint `(5480,612)`, Floor bank edge x=5520, a marked 40-pixel ordinary-jump moat opening, dark-water hazard x=5520..6360, continuous 800×20 WoodenBridge x=5560..6360, castle floor x=6360..6624, and solid castle facade/80-pixel doorway.
- Moved encounter entry to `(5780,430)` (27.5% into the bridge) and saved a visible chain/curse `RearBattleBarrier` at x=5420 behind the checkpoint. Entry restores HP/Stamina, closes that barrier, retains the visible closed castle gate, activates Boss/HUD and sets Camera limits x=5340..6620. Death or Boss clear releases the limits.
- Kept Fallen Gate Knight at `(6120,596)` with unchanged Body 18, Shield 6, phases, damage and attacks. Main enables logical x bounds 5650..6320; approach, charge and knockback cannot carry it off the bridge, while no boundary collider blocks Player motion.
- Added `CastleGateController`: the visible 48×260 gate remains on World during a 1.00-second vertical lift, plays a quiet runtime-synthesized chain/stone placeholder, and disables collision/enables `CastleEntranceTrigger` only after animation completion. Crossing `(6428,510)` then shows `CHAPTER I COMPLETE / 第一章完成`; no second scene loads.
- Added `MoatHazard`: one trigger per Player life invokes the existing Health → Dead → five-frame body collapse → dagger drop → ghost rise → 0.50-second pause → checkpoint respawn flow. An uncleared encounter resets Boss Body/Shield/phase/position, rear barrier, gate, HUD and Camera. A cleared Boss remains dead and the gate remains open after later Player death. Non-Boss enemies receive one lethal component hit; the bounded Boss is ignored.
- Rewrote the saved-Main traversal contracts for solid geometry. Platform tests now prove single/double-jump underside blocking, non-negative ceiling velocity, Air Dash/Dash Attack side blocking and top landings. Spawn-origin routes approach elevated edges and use a normal jump over the 40-pixel bridge-entry gap. The new castle-flow suite verifies solid bridge underside, live-encounter moat death, complete ghost/respawn, Boss reset and post-clear persistence.
- Added/updated the requested README, traversal, Boss room, encounter, collision-layer and metrics specifications. Original-resolution configured-Main QA capture is reproducible through `scripts/tools/capture_castle_bridge_qa.gd`.

### Commands and actual results

1. Exact engine/import:
   - `/Users/vincentz/Downloads/Godot.app/Contents/MacOS/Godot --version`: `4.7.1.stable.official.a13da4feb` (confirmed during preflight).
   - `Godot --headless --path . --import --quit-after 120`: exit 0; new global classes and Main scene loaded without resource/script diagnostics.
2. Focused saved-Main collision and flow:
   - `tests/level/test_main_platform_reachability.gd`: PASS — five solid platforms, single/double-jump underside blocking, Air Dash/Dash Attack side blocking, top landings and enemy alignment.
   - `tests/level/test_main_traversal_routes.gd`: PASS — spawn-origin mainline with ordinary bridge-entry jump, solid edge approaches to Crossbow surfaces, and delayed Gargoyle route; no post-spawn teleport.
   - `tests/combat/test_first_level_boss.gd`: PASS — saved castle composition, 800×20 bridge, 5650..6320 Boss bounds, unchanged combat profiles, visible rear lock, Camera lock/release, gate collision timing/audio, reset and Chapter I trigger.
   - `tests/level/test_castle_bridge_flow.gd`: PASS — bridge underside, actual physics fall into moat, full death/ghost/respawn, uncleared Boss reset and cleared-Boss persistence.
3. Regression:
   - Exact Godot serial execution of every `.gd` under `tests/`: `FINAL_TESTS count=34 failures=0`. The runner treated nonzero exit, `SCRIPT ERROR`, `ERROR:` and explicit failure summaries as failures; none were present.
   - Existing `boss_test_room.tscn` and `combat_test_room.tscn` each ran independently for 180 headless frames with exit 0, confirming the Main-specific bridge bounds/controller did not break reusable Boss/enemy scenes.
4. Configured F5 Main:
   - `Godot --headless --path . --quit-after 600 --log-file docs/qa/castle_bridge_f5_headless.log`: exit 0, no Script Error/Error/Warning lines.
   - `Godot --path . --quit-after 300 --log-file docs/qa/castle_bridge_f5_graphical.log`: exit 0, GL Compatibility on Apple M4, no Script Error/Error/Warning lines.
   - Graphical configured-Main capture: exit 0 and `CASTLE_BRIDGE_QA: ceiling=true rear_open=true gate_open=true boss_bounds=(5650.0, 6320.0)`.

### Configured-Main QA evidence

- `docs/qa/solid_platform_ceiling_collision.png`: 1280×720, 24,276 bytes, SHA-256 `76f4eff3bd6cac80573ea781937e2383ce311f81bde802e5f72f0bec77def905`.
- `docs/qa/castle_bridge_boss_fight.png`: 1280×720, 29,103 bytes, SHA-256 `8ba583dc57fed814f78facdb51df963e3e2ea7f040d1b13c55ba75dde9d0400a`.
- `docs/qa/castle_gate_open.png`: 1280×720, 29,829 bytes, SHA-256 `4f9e0fba44416a5a91f84ca4a5e1b3f80283558b3307cdca6813f2168e7b3718`.
- Original-resolution inspection confirms Player/PlatformA underside contact, visible rear barrier + closed castle gate + both combatants on the continuous timber bridge, and the raised-gate/open-doorway state with the bilingual message. Computer-use Remote Scene Tree control was unavailable; saved-tree paths were instead instantiated and asserted through exact-Godot Main tests, then rendered graphically from the same configured PackedScene.

### Manual acceptance and known limitations

- Manually judge the 40-pixel near-bank jump readability, bridge combat spacing, Camera framing during every Boss attack, synthesized gate placeholder loudness and the perceived timing between Boss collapse and the 1.00-second gate lift. Automation proves collision/state/timing contracts, not subjective feel.
- The bridge is intentionally continuous across its 800-pixel combat span. The moat is naturally reachable at the marked bank-to-bridge opening and through forced test placement; no hidden gap was inserted into the combat floor.
- Environmental art remains gray-box native Godot polygons. The dark water, old timber, chain posts, barrier and castle facade establish readable function but are not a final tile/art/audio pass.
- No Player tuning, enemy/Boss balance, enemy AI, HUD dimensions, new enemy, Boss skill, equipment or second-level content was changed.

## 2026-07-24 — Fallen Gate Knight turn response and Shield durability (preflight)

Status: complete — configured-Main implementation, 34-script regression and graphical QA passed; manual feel acceptance pending

### Goal

- Raise only the first Boss Shield from 6 to 10 while retaining Body 18, all Boss damage/skills/movement, and Player Normal/Dash Attack damage 1/2.
- Replace the current delayed instantaneous mirror with a readable two-stage turn: 0.07-second reaction plus 0.10-second authored turn animation, followed by a 0.12-second anti-jitter cooldown.
- Keep contact-time front/back Shield routing, no break-hit overflow, reset behavior, signal-driven Boss HUD, and the configured F5 Main instance synchronized.

### Read-only audit

- `project.godot` resolves F5 to `res://scenes/main/main.tscn`. The live Boss is `Main/World/CastleEntranceArea/FallenGateKnight`, instanced from `res://scenes/bosses/fallen_gate_knight.tscn`; the live HUD is `Main/HUD/BossHealthHud`.
- `res://resources/bosses/fallen_gate_knight_config.tres` currently owns Body 18, Shield 6, and one `turn_duration = 0.18`. Main overrides only bridge bounds; it has no Shield or turn Inspector override.
- Turning currently updates only in `ApproachShielded` / `ApproachUnshielded`. The first detection tick initializes 0.18 seconds without consuming that tick, so a 60 Hz free-Approach turn completes in about 0.20 seconds and then instantly changes both `AnimatedSprite2D.flip_h` and `FacingRoot.scale.x`. Attacks, Hurt, ShieldBreak, PhaseTransition, GuardRecovery, ordinary Recovery and Death do not update turning; the perceived delay can therefore stack the remaining locked attack plus 0.48-second Recovery before the 0.20-second turn.
- There is no center-side threshold in Boss turning, no post-turn cooldown, no Turn state, and no turn animation. The shared `ShieldComponent` does classify source side at contact and consumes one attack id before routing, so existing rear/front routing and no-overflow break behavior can be retained.
- `BossHealthHud` listens to `HealthComponent.health_changed` and `ShieldComponent.shield_health_changed`; it does not own combat data. Its saved scene defaults still show 6/6, but binding replaces them with the component's real values.

### Planned files, tests, and scope check

- Update the centralized Boss config, Boss state/presentation script, Boss scene/SpriteFrames and deterministic original pixel generators; add Shield damage overlays for intact/damaged/critical/broken and authored shielded/unshielded turn frames.
- Extend the saved-Main Boss test for 10-point routing, HUD/reset, 0.16–0.20-second turn completion, reaction cancellation, center hysteresis, cooldown and attack-direction locking. Run all repository tests plus exact Godot 4.7.1 import, headless F5 and graphical F5 checks.
- Update only the requested Boss, room, combat and metric specifications plus this log. No Player tuning, Boss Body/damage/skill/movement, other enemy, bridge/moat/gate geometry or completion-flow change is in scope.

### Delivered implementation

- Replaced the single `turn_duration = 0.18` delayed mirror with centralized `boss_turn_reaction_delay = 0.07`, `boss_turn_animation_duration = 0.10`, `boss_turn_cooldown = 0.12`, and `turn_side_threshold = 12`. Added explicit `TurnShielded` / `TurnUnshielded` states and three-frame 30 FPS original pixel animations.
- Idle, Approach, GuardRecovery and Recovery can request a turn. A rear request cancels if the Player returns to the current front or the 12-pixel center zone before reaction completes. All attacks, Hurt, ShieldBreak, PhaseTransition and Death retain locked facing and interrupt/reject turn requests.
- The visual and `FacingRoot` now commit together only after the turn animation. Commit is deferred until the current contact frame completes, so Shield routing on that frame uses the old facing and the next frame uses the new facing. A 0.12-second cooldown prevents center-line oscillation.
- Raised only `boss_shield_max_health` from 6 to 10. Body remains 18, Player Normal/Dash damage remains 1/2, every Boss damage/movement/skill/cadence value remains unchanged, frontal hits remain Shield-only, rear hits remain Body-only, and the breaking attack still discards overflow and cannot hit Body with the same attack id.
- Added a signal-driven full-canvas pixel `ShieldDamageOverlay`: 10–8 intact, 7–5 damaged, 4–1 critical, and 0 broken. Its offsets follow shielded Idle, ShieldBash and Turn frames; the existing restrained shield-break flash/animation remains unchanged.
- The signal-driven Boss HUD now initializes from and displays 10/10, decrements from real Shield signals, shows `BROKEN` at zero, and returns to 10/10 on reset. Main's saved HUD defaults were synchronized for editor/runtime consistency without moving combat ownership into UI.
- `reset_boss()` now restores Body 18, Shield 10, intact overlay, initial left facing, Phase 1, and clears reaction, animation-commit and cooldown state. Main still overrides only bridge bounds and directly instances the shared latest Boss scene/config.

### Measured timing and balance records

- Previous free-Approach behavior: about 0.20 seconds at 60 Hz from first detection to an instantaneous mirror (0.18 configured plus its initialization/fixed-step boundary). During a locked attack it could additionally wait for the remaining attack and up to the 0.48-second Recovery because Recovery did not process turning.
- New free-Approach and GuardRecovery behavior: 0.1833 seconds measured at 60 Hz from clear rear detection to queued contact-frame commit, inside the 0.16–0.20-second target. Authored nominal duration is 0.17 seconds.
- Full Shield break counts: 10 Normal Attacks, 5 Dash Attacks, or any 1/2-damage mix totaling 10 (for example 4 Dash + 2 Normal). Body remains 18 through five frontal Dash hits; a rear Normal + Dash changes Body 18→15 while Shield stays unchanged.
- Deterministic tests found no center-threshold flip, stale reaction after returning front, cooldown bypass, attack-state turn, same-frame rear-to-front routing error, or break-hit overflow. Subjective Phase 1/Phase 2 average duration and average successful rear hit count require manual multi-run play; they were not fabricated from automation. Shield 15 remains documentation-only as a future hard-mode candidate.

### Commands and actual results

1. Exact asset build/import:
   - `Godot --headless --path . --script scripts/tools/pixel_first_level_boss_generator.gd`: PASS, 141 original Gargoyle/Boss PNG files.
   - `Godot --headless --path . --import --quit-after 120`: final rerun exit 0 without diagnostics.
   - `Godot --headless --path . --script scripts/tools/first_level_boss_sprite_frames_builder.gd`: PASS, current Boss and Shield-overlay SpriteFrames saved.
2. Focused saved-Main checks:
   - `tests/combat/test_first_level_boss.gd`: PASS; printed `BOSS_TURN_TIMING: free=0.1833 recovery=0.1833`, 10-point Shield/HUD/front/rear/no-overflow/reset and every unchanged attack profile.
   - `tests/tools/validate_first_level_boss_assets.gd`: PASS, 141 transparent lossless/no-mipmap frames.
   - `tests/level/test_castle_bridge_flow.gd`: PASS, moat death/ghost/respawn and 10-point Boss reset/persistence.
   - `tests/combat/test_main_enemy_integration.gd`: PASS, seven groups/18 normal enemies/Boss room/HUD/respawn unchanged.
   - The first Debug HUD invocation used obsolete `tests/tools/test_main_debug_hud.gd` and correctly failed as missing; the located real command `tests/ui/test_main_debug_hud.gd` then passed compact/expanded/hidden/F1–F4 behavior. The missing-path attempt is not counted as a project failure or a passed test.
3. Complete regression:
   - Exact Godot serial execution of every `.gd` under `tests/`: `FULL_TESTS count=34 failures=0`; runner rejected nonzero exit plus `SCRIPT ERROR`, `ERROR:`, `WARNING:` and explicit failure summaries.
4. Configured F5 Main runtime:
   - Headless `Godot --headless --path . --quit-after 600 --log-file docs/qa/fallen_gate_knight_f5_headless.log`: exit 0, no Script Error/Error/Warning diagnostics.
   - Graphical `Godot --path . --quit-after 300 --log-file docs/qa/fallen_gate_knight_f5_graphical.log`: exit 0, GL Compatibility on Apple M4, no diagnostics.
   - Graphical configured-Main capture script: exit 0 and `FALLEN_GATE_KNIGHT_QA: ... shield=6/10 visual=damaged state=TurnShielded turn_frame=1` from `Main/World/CastleEntranceArea/FallenGateKnight`.

### Configured-Main QA evidence

- `docs/qa/fallen_gate_knight_shield_10_main.png`: 1280×720, SHA-256 `d53cca07279235c754f724a5ccf6e5be017e59b463d683f2752777eb6bfb3888`; live HUD visibly reads Body 18/18 and Shield 10/10.
- `docs/qa/fallen_gate_knight_shield_damaged_main.png`: 1280×720, SHA-256 `dfbcd6393bc5029d49191335defc98c3771e8d1821d8432f6cccd05462e42b02`; four real frontal Normal hits produce Shield 6/10 and the damaged overlay without Body loss.
- `docs/qa/fallen_gate_knight_turn_main.png`: 1280×720, SHA-256 `778f8bee555bbdcfc7730180b104b500532de34f2348128beef35a474bcd3cde`; configured Main shows `TurnShielded` frame 2 before facing/Hitbox commit.
- Original-resolution inspection confirmed sharp nearest-neighbor art, readable shield/sword/body compression during turn, synchronized HUD values, and no full-screen shield flash.

### Manual acceptance and known limitations

- Manually repeat jump, double-jump and Air Dash cross-ups at normal speed, and judge whether the 0.1833-second response leaves one satisfying Normal hit or the start of one Dash Attack without permitting sustained rear output. Automation proves timing/routing/state locks, not perceived pressure.
- Manually record several complete Phase 1/2 durations and rear-hit counts. They depend on human movement/attack choice and are intentionally marked pending instead of inferred from deterministic damage counts.
- The turn is a compact three-frame 96×96 pixel twist rather than skeletal interpolation. The damage overlay uses three visible durability levels plus the existing broken animation; it does not create ten unique Shield sprites.
- No Player value, Boss Body/damage/movement/skill, normal-enemy behavior, bridge/moat/gate geometry, HUD placement or chapter-completion flow changed.

## 2026-07-24 — Boss pressure, Player attack cadence, moat and Gargoyle presentation

Status: complete — implementation, 34-script regression and configured-Main graphical QA passed; manual feel acceptance pending

### Goal

- Increase Fallen Gate Knight pressure through modestly faster existing attack anticipation/recovery only, while preserving every damage value, Body 18, Shield 10, current skills, phases, bounds and encounter flow.
- Replace the Player's frame-three immediate Attack restart with a short, explicit chain-input window plus a minimum recovery beat; retain the same four-frame 20 FPS dual-dagger thrust, damage, range, Stamina and Dash Attack behavior.
- Lengthen the Boss's authored rear-cross turn from the measured 0.1833 seconds to a nominal 0.23 seconds so a clean jump-behind creates one readable Normal Attack opportunity without allowing sustained rear pressure.
- Make the saved F5 Main moat visibly read as deep blue Gothic water without changing `MoatHazard`, bridge collision or castle-flow logic, and redraw the existing three shared Gargoyle Sentinel instances as stone medieval gargoyles without changing their AI/combat contract.

### Read-only audit

- `project.godot` resolves F5 to `res://scenes/main/main.tscn`. Git began on `master` at `ca6c8e9`, two commits ahead of `origin/master`; the only pre-existing untracked path is `scripts/tools/capture_fallen_gate_knight_turn_shield_qa.gd.uid`.
- The live Boss is `Main/World/CastleEntranceArea/FallenGateKnight`, instanced from `res://scenes/bosses/fallen_gate_knight.tscn`. Central config currently owns Body 18, Shield 10, shared `attack_recovery=0.48`, and turn reaction/animation/cooldown values `0.07/0.10/0.12`; recent deterministic measurement is 0.1833 seconds total at 60 Hz.
- Existing Boss attacks use their authored SpriteFrames timing rather than separate per-attack windup variables. First active-frame delays range from 0.1818 to 0.375 seconds; reducing those animation timings by about 8–10% and shared recovery by 12.5% stays inside the requested limited pressure pass without hiding tells.
- The Player Attack is four frames at 20 FPS. `player_action_controller.gd` currently stores one 0.10-second repeat-J input and immediately calls `restart_locked_one_shot()` as soon as frame index 2 (`attack_03`) is reached, so repeated input can skip the last recovery frame and has no minimum gap.
- Main's moat nodes are `Main/World/CastleEntranceArea/Moat/WaterVisual`, `WaterReflection` and unchanged `MoatHazard`; the first two use only one near-black blue rectangle and a five-pixel surface strip. The continuous bridge is the separate `Main/World/CastleEntranceArea/WoodenBridge` body.
- All three saved Main Gargoyles (`EncounterGroup05/.../GargoyleSentinel01`, `...02`, and `EncounterGroup07/.../GargoyleSentinel03`) instance the same `res://scenes/enemies/gargoyle_sentinel.tscn`, SpriteFrames and 64×64 PNG tree. Their state loop and combat parameters are already functional; the current thin line wings and rectangular torso are the presentation defect.

### Planned files, tests, and scope check

- Update centralized Boss/Player action Resources and typed controllers, Boss SpriteFrames timing, Main moat presentation nodes, the deterministic Gargoyle generator, shared Gargoyle PNG/SpriteFrames resources, and focused tests for timing/chain contracts.
- Archive the replaced Gargoyle presentation under its `reference/deprecated_v1` tree while keeping runtime validation limited to production animation folders. Preserve all three Main instance paths and the existing enemy count.
- Run exact Godot 4.7.1 generation/import/build, focused Player/Boss/Gargoyle/Main tests, all repository tests, configured headless and graphical F5 Main, and capture configured-Main Boss bridge, moat and new-Gargoyle QA images under `docs/qa/`.
- Update README plus Boss, combat, Gargoyle and Boss-room specifications. Scope excludes new attacks/phases/enemies, Player or Boss damage/HP/Stamina changes, Dash Attack redesign, MoatHazard/collision changes, encounter-count changes, second-level content and rewards.

### Delivered implementation

- Increased pressure only through existing timing. Shield Bash/Sword Slash are 9.0→9.8 FPS, Heavy Overhead/Shockwave 8.0→8.8, both Combo steps 11.0→12.0, Jump Smash 9.0→9.8 and Charge Thrust 10.0→11.0. Their first active-frame delays are about 8–10% shorter while every authored anticipation and active frame remains. Shared post-attack Recovery is 0.48→0.42 seconds. Body 18, Shield 10, all damage values, movement, bounds, phases and skill selection are unchanged.
- Lengthened the authored Boss cross-up response from 0.07+0.10 seconds to 0.10+0.13 seconds. The three-frame turn now plays at 23.076923 FPS; deterministic 60 Hz measurement is 0.2333 seconds versus the previous 0.1833 seconds. The 12-pixel threshold, 0.12-second cooldown, reaction cancellation, attack direction locks and contact-frame routing remain intact.
- Replaced immediate frame-three Player Attack restart. The first J still starts the same four-frame 20 FPS thrust immediately and reaches `attack_02` in about 0.05 seconds. Only a J edge during 0.15–0.20 seconds can fill one shortened 0.06-second buffer. The current attack always reaches `attack_04`, then holds an exclusive 0.06-second `AttackRecovery` before a valid repeat receives a fresh attack id. Early/out-of-window spam cannot restart frame one; Dash Attack, damage 1/2, range, Stamina and cancellation rules are unchanged.
- Saved nine presentation-only nodes under `Main/World/CastleEntranceArea/Moat`: blue/teal base and depth bands, surface highlight, two cold ripple/reflection layers, bridge shadow and two stone banks. The first capture exposed negative-Z concealment behind the root Backdrop; the final saved Z order renders water above Backdrop and below/around bridge art. `MoatHazard`, its shape/masks/death behavior, `WoodenBridge/BridgeCollision`, route geometry and castle flow were not changed.
- Rebuilt all 41 production Gargoyle frames across `dormant`, `wake`, `hover`, `dive_windup`, `dive`, `ground_stun`, `return_to_air`, `hurt`, `death_fall` and `death_shatter`. The new silhouette uses a hunched stone torso, horn/brow/muzzle, broad membrane bat wings, separate claws, tail, gray/verdigris planes and sparse cracks. AI config, Health 3, Dive damage 7 and all state timings remain unchanged.
- Archived the 41 replaced PNGs under `assets/sprites/enemies/gargoyle_sentinel/reference/deprecated_v1/`; `.gdignore` keeps them out of runtime import and production asset counts. All runtime frames remain under the original animation paths and rebuild the existing shared `gargoyle_sentinel_sprite_frames.tres`.

### Configured F5 Main synchronization

- `run/main_scene` remains `res://scenes/main/main.tscn`. Boss path remains `Main/World/CastleEntranceArea/FallenGateKnight`, using `res://scenes/bosses/fallen_gate_knight.tscn`, `fallen_gate_knight_config.tres` and the rebuilt Boss SpriteFrames timing.
- Gargoyle paths remain `Main/World/Encounters/EncounterGroup05/Enemies/GargoyleSentinel01`, `.../GargoyleSentinel02`, and `Main/World/Encounters/EncounterGroup07/Enemies/GargoyleSentinel03`. Main integration asserts all three use `res://scenes/enemies/gargoyle_sentinel.tscn` plus the same latest `res://resources/enemies/gargoyle_sentinel_sprite_frames.tres`; enemy count remains 18 and no legacy runtime copy exists.
- Moat presentation path is `Main/World/CastleEntranceArea/Moat`; hazard authority remains `Main/World/CastleEntranceArea/Moat/MoatHazard`, and the solid bridge remains `Main/World/CastleEntranceArea/WoodenBridge`.

### Commands and actual results

1. Original assets and resources:
   - Exact 4.7.1 `--script scripts/tools/pixel_first_level_boss_generator.gd`: PASS, 141 production Gargoyle/Boss PNGs generated.
   - Exact 4.7.1 `--import --quit-after 120`: exit 0 without Script Error/Error/Warning diagnostics.
   - Exact 4.7.1 `--script scripts/tools/first_level_boss_sprite_frames_builder.gd`: PASS.
2. Focused contracts:
   - `tests/player/test_fast_attack.gd`: PASS — immediate 0.05-second effective pose, strict final input window, one buffer, complete frame four and 0.06-second recovery across four deliberate repeats.
   - `tests/player/test_dash_attack.gd`: PASS — unchanged Ground/Air Dash Attack behavior.
   - `tests/combat/test_first_level_boss.gd`: PASS and `BOSS_TURN_TIMING: free=0.2333 recovery=0.2333 target=0.22..0.26`; timings, damage, Shield, bridge, moat presentation nodes and room flow passed.
   - `tests/combat/test_gargoyle_sentinel.gd`, `test_main_enemy_integration.gd`, and `validate_first_level_boss_assets.gd`: PASS — unchanged AI/damage/death, all three shared Main instances and 141 transparent lossless/no-mipmap production frames.
3. Complete regression:
   - Serial exact-Godot execution of all test scripts: final `FULL_TESTS count=34 failures=0`. One earlier full run observed the existing death-flow total-duration assertion cross its approximately-one-frame lower bound; the isolated rerun passed and the final complete rerun passed 34/34. No death/respawn implementation or assertion was changed.
4. Configured Main runtime:
   - Exact Godot headless F5 target for 600 frames: exit 0, no Script Error/Error/Warning.
   - Exact Godot graphical F5 target for 300 frames: exit 0, GL Compatibility on Apple M4, no Script Error/Error/Warning.
   - Configured-Main graphical capture script: exit 0 and saved all three required frames from the same Main PackedScene.

### Configured-Main QA evidence

- `docs/qa/fallen_gate_knight_pressure_main.png`: 1280×720, 16,456 bytes, SHA-256 `f773ed8f955957d1af0d6f92c1ed34af74016650f3e6c57e07ddf41864d1bd1c`.
- `docs/qa/gothic_moat_main.png`: 1280×720, 9,603 bytes, SHA-256 `7265ca337a1746d255f60e81b69d1c57ebda10c14791282bc0a705e8a8cdb8b1`.
- `docs/qa/gargoyle_stone_redesign_main.png`: 1280×720, 10,049 bytes, SHA-256 `95bbcc2ae229da073161f99757d5d04fd692a39b2f49874736f03eae31612189`.
- Original-resolution inspection confirms visible deep-teal water and surface bands below the bridge, sharp nearest-neighbor horned stone Gargoyles in Main Group05, and the unchanged Boss/HUD/bridge composition.

### Manual acceptance and known limitations

- Manually judge whether the 8–10% shorter Boss tells plus 0.42-second Recovery feel more pressuring without becoming visually unfair, and whether the 0.2333-second cross-up consistently grants one satisfying normal hit but not sustained rear output.
- Manually compare deliberate J rhythm against random high-frequency spam. Automation proves no active-frame restart and a mandatory 0.06-second gap; subjective cadence still requires play feel approval.
- Gargoyle art is a procedural 64×64 gray-box production pass, not final hand-polished pixel art. In particular, inspect the side-view Dive at motion speed and confirm the swept wing/tail reads as a stone predator rather than a projectile or insect.
- Water is layered native Polygon2D gray-box art with static ripples; it has no shader, particles or downloaded texture. This intentionally avoids changing hazard/collision logic.
- No Player/Boss damage or Health/Stamina value, Boss skill/phase, Gargoyle AI, enemy count/type, encounter activation, Moat death, gate completion, second level, reward or equipment system was added or changed.

## 2026-07-24 — Ravenmourn Castle approach and Boss bridge environment pass

Status: complete — implementation, 35-script regression, configured-Main graphical QA and text-free scene transition passed; manual visual/play acceptance pending

### Goal

- Replace the empty late-level black space with an original 16-bit-inspired Gothic castle approach: layered towers, broken walls, stonework, sparse vegetation, chains, rubble and restrained moon/fire accents while preserving every gameplay surface and encounter.
- Replace the meaningless pre-bridge slab presentation with a non-blocking iron Gothic arch carrying the name `RAVENMOURN CASTLE`; retain only the existing battle-lock collision/seal behavior required by the live Boss encounter.
- Make the saved F5 Boss bridge read as a complete moat crossing toward a monumental fortress, with a detailed castle silhouette, readable central gate, reinforced timber bridge and deeper blue water presentation.
- Remove all visible chapter/gate-complete messaging. After the existing Boss death and weighted 1.20-second gate opening, keep Player control and enable the existing entrance trigger to fade into a minimal, text-free Ravenmourn threshold scene rather than implementing a second level.

### Read-only audit

- Git began on `master` at `5c4eeb4`, three commits ahead of `origin/master`, with a clean worktree. `project.godot` resolves F5 to `res://scenes/main/main.tscn`.
- The late approach is the saved Main span around `World/Encounters/EncounterGroup06`, `EncounterGroup07`, `PlatformC`, `PlatformD`, `GargoylePerch` and the near bank at x≈3900..5520. It currently renders against the root near-black `Backdrop` with only flat platform/floor polygons.
- The Boss bridge composition is `Main/World/CastleEntranceArea`: `WoodenBridge`, `Moat` and unchanged `MoatHazard`, `FallenGateKnight`, `CastleFacade`, `CastleGate`, `CastleEntranceTrigger`, and the live battle lock `RearBattleBarrier` at x=5420. The current castle is one simple right-edge tower; the gate is a 48×260 slab/bars visual raised by `scripts/world/castle_gate_controller.gd`.
- `scripts/bosses/boss_room_controller.gd` currently shows `Main/HUD/LevelCompletePanel` with opening/open text, then replaces it with `CHAPTER I COMPLETE / 第一章完成` at the entrance. The entrance only emits `level_completed`; it does not change scene.
- Main Camera is `Main/World/Player/Camera2D`; the Boss controller temporarily uses horizontal limits 5340..6620 and releases to 0..6600. Baseline exact-Godot 4.7.1 import and 180-frame configured F5 both exited 0 with no Script Error/Error/Warning diagnostics.

### Planned files, tests, and scope check

- Add narrowly scoped, typed native-2D presentation scripts/scenes for the castle approach, iron arch, bridge/moat decoration, fortress backdrop, moving portcullis art and text-free threshold transition; instance them directly in `res://scenes/main/main.tscn`.
- Update `BossRoomController` only at its completion boundary: remove the visible message dependency, retain the existing signals and gate/trigger authority, and delegate fade/scene change to a composed transition node. Preserve Boss reset, checkpoint, camera lock, bridge bounds and respawn behavior.
- Update focused Boss/bridge/Main tests to assert saved environment nodes, no completion panel/text, weighted opening with collision held until completion, and the enabled entrance transition. Capture three original-resolution configured-Main images for the approach, live Boss bridge/castle and opened gate.
- Run exact Godot 4.7.1 import, focused tests, full serial tests, configured headless/graphical F5 and graphical QA capture; preserve commands and actual results here.
- Scope excludes Boss values/AI/attacks/phases, Player movement/combat, enemy count/config/AI, encounter activation, HUD data, world collision geometry, Moat death behavior, a playable second level, rewards and save systems.

### Delivered implementation

- Added `LateLevelApproachArt` and `LateLevelSurfaceDetails` directly to the saved Main World. Original native-2D layers now cover x≈3560..5600 with navy sky bands, clouds, five distant spired towers, battlements, broken outer walls, arched openings, restrained cold/amber windows, stone courses, platform joints, rubble, weeds and hanging chains. All Floor/Platform shapes and all seven encounters are untouched.
- Replaced the permanent visual meaning of the x=5420 slab with non-blocking `Main/World/RavenmournArchway`: a black-iron pointed arch, spikes, brass-edged timber nameplate and the final approved destination name `RAVENMOURN CASTLE`. It has no collision child. The existing `RearBattleBarrier` remains a separate narrow curse line/crossed-chain battle seal only while Boss lock is active, preserving reset/arena authority without presenting as a wooden board.
- Added `Main/World/BossCastleBackdrop`, deliberately starting left of the physical gate so the existing Boss Camera limits frame a visible fortress rather than a clipped right-edge rectangle. It draws far towers, a high central keep, spired roof/finial, battlements, buttresses, masonry courses, cold and sparse warm Gothic windows, a fixed gatehouse, crest and threshold stairs behind Player/Boss silhouettes.
- Rebuilt bridge/gate presentation without changing physics. `DetailedBridgeArt` adds twenty worn planks, rivets, cracks, underside supports, low pointed posts and sagging chains over the same 800×20 full-solid bridge. `MoatAtmosphere` adds castle reflections, varied ripples and bank foam over the same 840×104 `MoatHazard`. `DetailedGateArt` replaces the simple slab/bars with a 68-pixel oak-and-iron portcullis, bands, five bars, rivets, teeth and crest.
- Lengthened only the gate presentation from 1.00 to 1.20 seconds and changed its value track to cubic interpolation for visible weight. Gate collision still remains enabled until the full 240-pixel rise completes; only then does `gate_opened` enable the unchanged entrance trigger. No Boss/Player/enemy tuning or collision geometry changed.
- Removed `Main/HUD/LevelCompletePanel` and all `BossRoomController` dependencies/calls that showed gate-opening, gate-open or chapter-complete text. `level_completed` remains as a logic signal. Crossing the enabled trigger now delegates to composed `Main/CastleEntranceTransition`, preserving Player control until contact, fading to black for the production 0.55 seconds and loading the new text-free `res://scenes/transitions/ravenmourn_threshold.tscn` art placeholder.
- The threshold scene is an intentionally minimal interior vault with dark masonry, columns, floor light and two restrained sconces. It contains no Label and no Player/combat/second-level content. The graphical QA driver shortened only its local capture-instance fade to 0.20 seconds and confirmed the real Main trigger changed `current_scene` to `RavenmournThreshold`.
- Camera limits remain 5340..6620 during the Boss and 0..6600 outside it. Rather than changing gameplay framing, the fortress was composed across x≈5420..6720; the 1280×720 configured-Main capture confirms Player, Boss, bridge, moat, keep and physical gate share the live frame, and the opening remains visible from the right bridge approach.

### Commands and actual results

1. Baseline before edits:
   - Exact `/Users/vincentz/Downloads/Godot.app/Contents/MacOS/Godot --version`: `4.7.1.stable.official.a13da4feb`.
   - Exact 4.7.1 import and 180-frame configured F5: both exit 0 with no Script Error/Error/Warning.
2. Focused contracts:
   - `tests/combat/test_first_level_boss.gd`: PASS — unchanged Body/Shield/damage/attacks/turn timing, saved art nodes, no completion panel, 1.20-second gate, transition start and Boss reset.
   - `tests/level/test_castle_bridge_flow.gd`: PASS — unchanged solid bridge underside, moat death/ghost/respawn, uncleared reset and cleared persistence.
   - `tests/level/test_ravenmourn_environment.gd`: PASS without diagnostics — required Main art paths/nameplate, non-blocking arch, unchanged bridge/hazard shapes, collision held during opening, transition target and no duplicate gameplay authority.
3. Complete regression:
   - Exact-Godot serial execution of all 35 scripts under `tests/`, split into deterministic ranges 1..12, 13..24 and 25..35 to accommodate the long traversal test: final `35/35`, zero nonzero exits and zero Script Error/Error/Warning/FAIL matches.
   - The first middle-range run observed the existing `test_m15_player_actions.gd` preview assertion miss `dash_start` once. No Player/preview file changed; immediate standalone rerun passed, and the final complete 13..24 range passed without diagnostics. This timing-only observation is retained rather than hidden.
4. Configured Main and transition runtime:
   - Final exact 4.7.1 `--import --quit-after 120`: exit 0, no diagnostics (`docs/qa/ravenmourn_import.log`).
   - Headless configured F5 for 600 frames: exit 0, no diagnostics (`docs/qa/ravenmourn_f5_headless.log`).
   - Graphical configured F5 for 300 frames: exit 0, GL Compatibility on Apple M4, no diagnostics (`docs/qa/ravenmourn_f5_graphical.log`).
   - Text-free threshold standalone for 120 frames: exit 0, no diagnostics (`docs/qa/ravenmourn_threshold_headless.log`).
   - Graphical configured-Main QA captured all three requested views, then invoked the live `CastleEntranceTrigger` path; output reports `gate_open=true` and `RAVENMOURN_THRESHOLD_QA: loaded=true` (`docs/qa/ravenmourn_environment_capture.log`).

### Configured-Main QA evidence

- `docs/qa/ravenmourn_approach_main.png`: 1280×720, SHA-256 `0630c71ddf13425d7c0432586f153b8c4f512500c5a22a1fbf1805f974d30446` — Group06/07 approach, masonry/platform detail and readable arch nameplate.
- `docs/qa/ravenmourn_boss_bridge_main.png`: 1280×720, SHA-256 `4d1d4a514a9aac541e068184fcff03ea265eacd331514ca0fadc100fe0b8f578` — live Boss, reinforced bridge, deep-blue moat, fortress keep and closed portcullis in one configured-Main frame.
- `docs/qa/ravenmourn_gate_open_main.png`: 1280×720, SHA-256 `1c19731085cb4baf2efa230fb56c16e9fddfff3b8b82712677d816df7bfeee75` — defeated Boss state, raised portcullis and unobstructed dark threshold with no completion message.

### Manual acceptance and known limitations

- Manually traverse Group06/07 at combat speed and confirm the denser masonry does not hide Crossbow bolts, Gargoyle Dive silhouettes or platform edges. Automation proves node/collision separation, not subjective contrast during play.
- Manually defeat the Boss normally and judge the 1.20-second cubic portcullis weight, doorway visibility and 0.55-second fade cadence. The QA path exercised the identical saved Main flow but accelerated its capture-only fade after the required gate-open screenshot.
- Environment art is authored native-2D gray-box presentation with clean vector/pixel-like edges, not final hand-painted tile art, dynamic parallax, water shader or licensed audio. The visual layering is static world-space depth so it cannot perturb Camera/physics.
- No Boss value/mechanic, Player ability, normal-enemy/stone-Gargoyle AI, encounter count, platform/floor/bridge geometry, MoatHazard, respawn, HUD authority or second-level gameplay changed.
## 2026-07-24 — First-level environment unity and Gothic castle reinforcement (preflight)

Status: in progress — read-only Main audit complete; implementation and configured-Main visual acceptance pending

### Goal

- Unify the configured F5 first level as one continuous journey from `Dark Forest Outskirts` through a ruined castle frontier and fortified approach to the Ravenmourn moat, bridge, gate and pointed Gothic Boss fortress.
- Replace the visually empty early/middle route with layered, original Godot-native sky, far forest, twisted trees, roadside ruins, vegetation and surface detail while preserving all gameplay silhouettes and collision authority.
- Increase the saved Boss fortress silhouette hierarchy and make the moving main gate visibly wider/heavier without changing its physical blocker, opening authority or post-Boss flow.

### Read-only audit

- Git began clean on `master` at `04256d1`, four commits ahead of `origin/master`. `project.godot` resolves F5 to `res://scenes/main/main.tscn`.
- The early route is the saved Main span x≈0..2100 around `World/Encounters/EncounterGroup01..03` and `World/PlatformA`; it currently has only the root `Backdrop`, `MoonGlow`, `Moon` and a single coarse `FarKeep` polygon, with no forest, roadside, foreground or surface-detail renderer.
- The middle transition is x≈2100..3900 around `EncounterGroup03..05`, `PlatformB` and `GargoylePerch`; it has no dedicated environment layer. The late approach starts abruptly at x≈3560 through `World/LateLevelApproachArt` and `World/LateLevelSurfaceDetails`.
- The Boss composition is `World/CastleEntranceArea`, while its fortress art is the visual-only `World/BossCastleBackdrop`; bridge detail is `CastleEntranceArea/WoodenBridge/DetailedBridgeArt`, moat authority/detail is under `CastleEntranceArea/Moat`, and the moving gate is `CastleEntranceArea/CastleGate/GateVisual/DetailedGateArt`.
- Main contains no `TileMap`, `TileMapLayer`, `Parallax2D`, `ParallaxBackground`, or dedicated foreground layer. Its environment is saved native-2D nodes plus typed custom-draw renderers. Camera authority remains `World/Player/Camera2D` with the existing Boss-room limit controller.

### Planned files, tests, and scope check

- Add narrowly scoped typed environment renderers for early forest depth, middle frontier transition and early/middle surface/foreground detail; instance them directly in `scenes/main/main.tscn` and retire only the obsolete coarse root `FarKeep` visual.
- Extend `ravenmourn_castle_backdrop.gd` and `ravenmourn_gate_art.gd` for a more vertical multi-spire keep and a wider, heavier visual gate while leaving every `StaticBody2D`, `CollisionShape2D`, hazard, encounter, Player, enemy, Boss and HUD value unchanged.
- Add a configured-Main environment contract test and a graphical capture driver for early, transition and Boss views. Run exact Godot 4.7.1 import/parse, focused tests, all repository tests, headless/graphical configured Main and original-resolution screenshot inspection.
- Update README plus environment, Boss-room and first-level encounter specifications. Scope excludes Player abilities, combat tuning, Boss/enemy values or mechanics, enemy counts, HUD behavior, world/platform/bridge collision, MoatHazard, second-level gameplay and licensed/external art.

### Delivered implementation

- Replaced the isolated root `MoonGlow`, `Moon` and coarse `FarKeep` polygons with saved `Main/World/DarkForestOutskirtsArt`. The typed visual renderer covers x=-100..2420 with a deep navy/gray-green sky, restrained moon/glow, cloud bands, layered forest boundary, repeated distant pines, five twisted leafless trees, low mist and a roadside ruin. It owns no collision or gameplay state.
- Added saved `Main/World/OutskirtsSurfaceDetails` behind actors. It overlays the unchanged Floor/PlatformA/B geometry with brown-gray earth, dirt-road patches, cobbles, weeds, brambles, platform joints, a broken fence, directional sign, cart wheel wreck and two grave markers. Props were placed outside primary attack silhouettes; no prop is a CollisionObject2D.
- Added overlapping `Main/World/CastleFrontierTransitionArt` across x≈2100..3740. The forest silhouette visibly thins while a broken watch post, low wall, Gothic arch opening, iron gate remnants and three increasingly tall distant spires introduce the fortress language before the existing late approach begins at x≈3560.
- Preserved `LateLevelApproachArt`/`LateLevelSurfaceDetails` as the masonry-dominant third act, producing a continuous forest → ruin → outer wall → moat visual progression across the same seven encounter coordinates.
- Re-composed `Main/World/BossCastleBackdrop` with five uneven far towers and a four-tower central pointed crown over the broad fortress body. The tallest central spire/finial, stepped roofs, battlements, buttresses, narrow Gothic windows and wider fixed gatehouse give the Boss bridge a clear side-towers/central-keep/main-door hierarchy rather than a large rectangular block.
- Widened only the moving main-gate presentation from 68 to 88 pixels and added a fifth timber plank, wider iron bands, side chains, rivets, door ring and heavier stone frame. The authoritative `GateCollision` remains exactly 48×260; rise distance, 1.20-second cubic opening, collision release timing and entrance transition are unchanged.
- Added `test_first_level_environment_unity.gd`, which fails if any saved progression layer is missing/owns collision, if the obsolete coarse silhouette returns, or if encounter count, normal-enemy count, platform geometry, Camera limits, gate collider or opening duration changes. Added a configured-Main graphical capture driver for the three requested regions.

### Configured F5 Main synchronization

- `run/main_scene` remains `res://scenes/main/main.tscn`. Early paths are `Main/World/DarkForestOutskirtsArt` and `Main/World/OutskirtsSurfaceDetails`; middle is `Main/World/CastleFrontierTransitionArt`; late remains `Main/World/LateLevelApproachArt` plus `LateLevelSurfaceDetails`.
- Boss authority remains `Main/World/CastleEntranceArea`; fortress art remains `Main/World/BossCastleBackdrop`; bridge, moat and moving gate art remain below the same live `CastleEntranceArea` nodes. Camera remains `Main/World/Player/Camera2D`.
- All seven ActivationAreas, eighteen normal-enemy instances, Player/Boss scenes and values, Floor/Platform/bridge/gate colliders, MoatHazard, HUD and post-Boss transition persist from the serialized Main. No test/preview scene substitutes for this integration.

### Commands and actual results

1. Baseline and exact engine:
   - `/Users/vincentz/Downloads/Godot.app/Contents/MacOS/Godot --version`: `4.7.1.stable.official.a13da4feb`.
   - Pre-edit exact 4.7.1 import and configured F5 for 180 frames: both exit 0 without Script Error/Error/Warning diagnostics.
2. Final import and focused contracts:
   - Exact 4.7.1 `--headless --path . --import --quit-after 120`: exit 0; all new typed classes registered without diagnostics.
   - `tests/level/test_first_level_environment_unity.gd`: PASS for forest/frontier/approach/fortress paths, visual-only ownership and gameplay-geometry preservation.
   - `tests/level/test_ravenmourn_environment.gd`: PASS for bridge/hazard preservation, 1.20-second gate and text-free transition.
   - `tests/combat/test_first_level_boss.gd`, `test_main_enemy_integration.gd`, `test_main_platform_reachability.gd` and `test_main_traversal_routes.gd` passed inside the complete run.
3. Complete regression:
   - Serial exact-Godot execution of all repository test scripts: `FULL_TESTS count=36 failures=0`. No movement, combat, Health/Stamina, enemy, Boss, asset, traversal or Debug HUD regression was observed.
4. Configured Main runtime:
   - Exact headless configured F5 for 600 frames: exit 0, no Script Error/Error/Warning.
   - Exact graphical configured F5 for 300 frames: exit 0, GL Compatibility on Apple M4, no Script Error/Error/Warning.
   - Configured-Main graphical QA capture: exit 0 and reports the project run scene plus all three authored regions.

### Configured-Main QA evidence

- `docs/qa/dark_forest_outskirts_main.png`: 1280×720, 20,829 bytes, SHA-256 `c5b823f7043ae83808fc7e50272a5326d5730aad9a8137bf7690d67d6cf04481` — moonlit forest layers, twisted trunks, mist, vegetation, road/fence/sign and live Player/enemy silhouettes.
- `docs/qa/castle_frontier_transition_main.png`: 1280×720, 16,221 bytes, SHA-256 `5f8d4fe7cc2a359d7435d71611504b559a4f12ed4b45afc3f34f44cc6bbf7f15` — thinning forest, ruined watch post/wall/gate and distant spire transition around live Main encounters/platforms.
- `docs/qa/gothic_spired_castle_boss_main.png`: 1280×720, 39,396 bytes, SHA-256 `783053322d6697a3301d0aad8b9d208d7184333919fca2aaddc96275c0101679` — live Boss/HUD, complete bridge/moat composition, layered pointed castle and wider closed main gate.
- Original-resolution inspection confirms all three images come from the configured Main PackedScene, foreground props stay behind combatants, platform edges remain readable and the Boss bridge frames Player/Boss/gate without decorative overlap.

### Manual acceptance and known limitations

- Manually traverse each encounter at combat speed and judge whether the early tree mass, middle ruin shapes and late masonry maintain bolt, shield, spear and Gargoyle readability under motion. Automated visual/collision separation cannot decide subjective contrast.
- Manually defeat the Boss and judge the wider gate's perceived weight during the unchanged 1.20-second rise. Automated gate coverage proves the physical blocker remains until full clearance and the transition still works.
- Environment art remains an original Godot-native gray-box presentation pass, not final hand-painted TileSet/parallax/shader production art. It intentionally uses static world-space layers and clean low-detail shapes so it cannot change physics or camera behavior.
- No Player mechanic, enemy/Boss value or AI, encounter count, collision, hazard, HUD behavior, second-level gameplay or external asset was introduced.
## 2026-07-24 — Chapter I opening, embedded tutorial and 34-enemy authored route (preflight)

Status: in progress — runtime audit and baseline exact-Godot verification complete

### Goal

- Establish the approved `Veil of Ravenmourn / 鸦泣之帷` world premise and a 60–90 second skippable pixel-panel opening before Player control.
- Enter the existing first-level Main directly from the cinematic, present eleven small in-world tutorial steps without modifying Player movement/combat code, and retain progress for the current Main instance across death/respawn.
- Replace the seven-group/18-enemy Main roster with the specified eighteen authored encounters and exact 34-enemy composition: Guard 14, Shield 5, Spearman 6, Crossbowman 5, Gargoyle 4; 27 mainline and 7 optional.
- Preserve every approved Player/enemy/Boss value and core mechanic, the castle environment, moat/bridge/gate collision, text-free post-Boss entrance and the absence of second-level gameplay.

### Read-only audit

- Git began clean on `master` at `e0e7ad1`, five commits ahead of `origin/master`. `project.godot` currently resolves F5 directly to `res://scenes/main/main.tscn`; there is no title, New Game, opening cinematic, CutsceneController, TutorialController, tutorial prompt, subtitle/dialogue layer or save system.
- Main Player is `Main/World/Player`, instanced from `res://scenes/player/player.tscn`. Its typed public signals already expose jump, double jump, landing, movement, damage/death/respawn; its composed `ActionController` exposes typed `action_started`/`action_finished`. Tutorial observation can therefore remain outside Player.
- `Main/World/Encounters` currently contains seven direct `EncounterGroup` nodes and eighteen normal enemies: Guard 8, Shield 2, Spearman 2, Crossbowman 3, Gargoyle 3. Activation is one-shot; all enemy AI is disabled until Player enters each saved `ActivationArea`.
- Respawn authority is `Main/PlayerRespawnController`, initially bound to `Main/World/SpawnPoint`; Boss checkpoint selection/reset is already composed through `BossRoomController`. No general-purpose first-level checkpoint trigger exists.
- Boss bridge is `Main/World/CastleEntranceArea`; Boss is `.../FallenGateKnight`, gate is `.../CastleGate`, and entrance trigger is `.../CastleEntranceTrigger`. `BossRoomController` opens the weighted 1.20-second gate only after `boss_defeated`, enables entry only after `gate_opened`, then delegates the 0.55-second text-free fade to `Main/CastleEntranceTransition` and `res://scenes/transitions/ravenmourn_threshold.tscn`.
- No chapter-complete/gate-open UI or visible message exists in the current Main. Exact Godot 4.7.1 baseline import and configured 180-frame F5 both exited 0 with no Script Error/Error/Warning diagnostics.

### Planned files, tests, and scope check

- Add typed timeline Resource/controller/art and a standalone `scenes/cinematics/opening_cinematic.tscn`; make it the configured F5 entry while retaining `scenes/main/main.tscn` as the gameplay level target.
- Add a composed TutorialController plus independently instantiable TutorialPromptUI, saved tutorial obstacle/platform nodes, three reusable checkpoint triggers and visual-only Chapter I storytelling art directly to Main.
- Move the authored normal roster into one independently instantiable `first_level_encounters.tscn` with eighteen direct EncounterGroups so current debug tooling remains simple; extend EncounterGroup only with metadata and clear/reset-safe signals needed by tutorial/checkpoint orchestration.
- Add a Boss last-words presenter that observes existing Boss Health/room-reset signals without changing Boss combat or gate timing. Keep the existing threshold scene as the approved castle-entry placeholder.
- Add deterministic startup/cinematic/tutorial/roster/checkpoint/Boss-flow tests, configured-F5 capture evidence and three route simulations. Update the required narrative/design documents and README.
- Scope excludes new enemy types, second Boss, full second level, saves, equipment, experience, drops, skills, Player/enemy/Boss tuning, core combat changes and external/licensed assets.

### Delivered implementation

- Added the standalone, eight-shot `OpeningCinematic` and made it the persisted F5 entry. Its typed timeline contains 66 seconds of shot holds plus seven 0.60-second transitions (70.2 seconds authored total), bilingual Chinese/English subtitles, a 1.5-second skip lockout and 0.75-second ESC/Enter hold. Natural completion and skip stop Timer plus art/transition Tweens before loading Main.
- Established the approved `Veil of Ravenmourn / 鸦泣之帷` canon: Valendor / 瓦伦多尔王国, Ravenmourn Castle, The Hollow Bell / 无声之钟, Night of Hollow Bells / 空钟之夜, Veiled Order / 暮帷会, Veilbound / 夜誓者, Soul Mark / 魂契印, the failed expedition, resurrection and protagonist culpability mystery.
- Added a composed eleven-step `TutorialController` and small bilingual `TutorialPromptUI`. It observes Player/ActionController/Encounter/Shield signals without changing locomotion or combat. Progress belongs to Main and therefore survives Player respawn in the current runtime; explicit development reset/replay APIs are available.
- Added the solid tutorial log, launch platform and air-dash landing platform; existing Player metrics and traversal physics remain unchanged. Added three reusable one-shot CheckpointTriggers after tutorial, forest and outskirts; the existing Boss checkpoint remains the fourth progression checkpoint.
- Replaced the seven-group serialized roster with `first_level_encounters.tscn`: 18 direct EncounterGroups, 34 normal enemies, exact Guard/Shield/Spear/Crossbow/Gargoyle totals 14/5/6/5/4, 27 mainline and 7 optional. AI remains disabled until local one-shot activation. The Boss bridge has no normal enemy.
- Added a collision-free Chapter I environment-storytelling renderer with fallen Order cloak/daggers, warning post, empty armor, spear remains, failed camp, Soul Mark fragments and recurring crows.
- Added the one-shot Boss subtitle “钟……认得你。 / The bell… remembers you.” on Boss Health death. It resets with the existing Boss room, but does not own combat, death, gate or transition. The weighted 1.20-second gate and text-free `ravenmourn_threshold.tscn` transition remain unchanged.
- Added a Chapter I composition test and graphical QA driver; updated prior tests that intentionally guarded the replaced F5 path, roster size and pre-tutorial traversal route. No Player/enemy/Boss tuning or core mechanic changed.

### Saved F5 and Main synchronization

- `project.godot` now resolves `run/main_scene` to `res://scenes/cinematics/opening_cinematic.tscn`; its only gameplay target is `res://scenes/main/main.tscn`.
- Main Player remains `Main/World/Player`; tutorial is `Main/TutorialController` and `Main/HUD/TutorialPrompt`; normal roster is the instance `Main/World/Encounters`; checkpoints are `Main/World/Checkpoints/*` plus `Main/World/CastleEntranceArea/BossCheckpoint`.
- Boss, gate and threshold authority remain `Main/World/CastleEntranceArea/FallenGateKnight`, `.../CastleGate`, `.../CastleEntranceTrigger`, `Main/BossRoomController` and `Main/CastleEntranceTransition`.
- A repository search found no visible `Chapter Complete`, `第一章完结` or `Gate Open` gameplay node/string under scenes or scripts.

### Commands and actual results

1. Exact engine/import/startup:
   - `/Users/vincentz/Downloads/Godot.app/Contents/MacOS/Godot --headless --editor --path . --quit`: exit 0; all new typed classes registered with no diagnostics.
   - Graphical configured F5 (`--quit-after 300 --audio-driver Dummy`): exit 0 on GL Compatibility / Apple M4; no Error/Warning (`docs/qa/chapter_01_f5_opening.log`).
   - Graphical direct Main runtime (`--quit-after 600 ... res://scenes/main/main.tscn`): exit 0; no Error/Warning (`docs/qa/chapter_01_main_runtime.log`).
2. Chapter I and complete regression:
   - `tests/level/test_chapter_one_flow.gd`: PASS for F5 entry, eight shots, 70.2-second duration, skip stop/dedup, eleven-step tutorial composition, exact roster/regions/optional total, checkpoint binding, Boss line, gate and threshold.
   - `tests/combat/test_main_enemy_integration.gd`: PASS for 18 groups, 34 live mixed enemies, type totals, activation, current combat/Health/Shield values, HUD, respawn and Boss room.
   - `tests/level/test_main_traversal_routes.gd`: PASS using real Input from spawn and no post-spawn teleport: tutorial obstacle, mainline without Air Dash, optional Crossbow route and novice Gargoyle platform route.
   - Serial execution of all 37 repository test scripts with exact Godot 4.7.1: `FULL_TESTS count=37 failures=0`.
3. Graphical QA:
   - `scripts/tools/capture_chapter_one_qa.gd`: exit 0; GL Compatibility on Apple M4; seven 1280×720 images captured from the opening/Main PackedScenes.

### QA evidence

- `docs/qa/chapter_01_opening_black_bell.png` — Hollow Bell shot, bilingual subtitle.
- `docs/qa/chapter_01_opening_awakening.png` — resurrection/Soul Mark shot, bilingual subtitle.
- `docs/qa/chapter_01_tutorial_area.png` — saved Main tutorial obstacle and Jump prompt.
- `docs/qa/chapter_01_shield_tutorial.png` — isolated Shield lesson and live formal HUD.
- `docs/qa/chapter_01_mixed_encounter.png` — Outskirts mixed ground/elevated composition.
- `docs/qa/chapter_01_boss_bridge.png` — live bridge Boss/HUD/gate composition.
- `docs/qa/chapter_01_gate_entry.png` — raised weighted gate and Player-controlled entrance with no completion text.

### Acceptance status and known limitations

- Automated route A covers the non-Air-Dash mainline to Boss entry; route B covers optional elevated Crossbow/Gargoyle traversal; route C combines repeated Player death/respawn, Boss reset/defeat and threshold contracts across dedicated deterministic suites. All passed.
- Three complete human F5 playthroughs (natural opening/mainline, skipped opening plus optional region, and tutorial/level/Boss death-recovery run) remain manual acceptance. Automation and capture prove composition/state contracts, but must not be represented as human judgment of 20–30 minute pacing, tutorial clarity or encounter fairness.
- The opening uses original Godot-native 2D panel art rather than a pre-rendered film, licensed music or final hand-painted pixel illustrations. Environmental narrative props are deliberately visual-only.
- Tutorial progress persists only for the current Main runtime because no save system exists. Encounter death persistence/checkpoint serialization is not introduced.
- No second level, sixth normal enemy, second Boss, equipment, experience, drops, skill tree, or new combat tuning was added.
## 2026-07-24 — Loot, currency and first weapon progression loop (preflight)

Status: in progress — read-only architecture and value audit complete

### Goal

- Add deterministic, health-aware one-drop enemy loot, collectible coins and healing vials without changing movement, stamina, enemy AI or outgoing enemy/Boss damage.
- Replace Player attack hitbox literals with equipped `WeaponData`, provide run-persistent currency/inventory/equipment state, and award Ravenfang Daggers plus 30 coins after the first Boss.
- Scale the existing normal-enemy, shield and Boss health pools by 10× so the approved 10/20 and 12/24 weapon damage values preserve current time-to-kill.
- Gate the existing castle threshold until the permanent Boss weapon pickup is collected, while retaining the existing Boss death, gate-opening and scene-transition responsibilities.

### Read-only audit

- Git began clean on `master` at `369dd1f`, one commit ahead of `origin/master`. Configured F5 starts `res://scenes/cinematics/opening_cinematic.tscn`, which loads `res://scenes/main/main.tscn`; Main Player is `Main/World/Player`, Boss is `Main/World/CastleEntranceArea/FallenGateKnight`, and the exit is `Main/World/CastleEntranceArea/CastleEntranceTrigger`.
- Player damage is currently duplicated as literal overrides in `scripts/player/player_action_controller.gd`: normal Attack calls `begin_attack(..., 1, ...)` and Dash Attack calls `begin_attack(..., 2, ...)`; the saved Dash hitbox also stores `damage = 2`. No weapon Resource, weapon inventory or equipment authority exists.
- `HealthComponent`, `HitboxComponent` and `HurtboxComponent` already provide bounded health, one-hit-per-attack ledgers and faction filtering. Ground enemies and the Boss emit `enemy_died` when entering Death, before their visual presentation queues the node for deletion. No loot, pickup, wallet or currency HUD exists.
- Current centralized values are Guard 3 HP/5 damage, Shield Guard 5 body HP/3 shield HP/8 damage, Spearman 5 HP/10 damage, Crossbowman 4 HP/6 projectile damage, Gargoyle 3 HP/7 dive damage, Boss 18 body HP/10 shield HP. Player Health/Stamina are both 100. Enemy and Boss outgoing damage values are already Resource/config driven and will remain unchanged.
- Main serializes one `first_level_encounters.tscn` instance containing 34 normal enemies. Reusable enemy PackedScenes and common base classes mean a composed loot component can be added once per enemy type instead of per Main instance. The current threshold scene has no run inventory summary.

### Planned files, tests, and scope check

- Add typed `WeaponData` resources plus focused `CurrencyManager`, `WeaponInventory` and `EquipmentManager` autoloads; wire Player damage to equipped weapon values and expose signal-driven HUD/read-only debug summaries.
- Add a typed loot profile/component and three reusable pickup scenes (coin, small vial, large vial), with deterministic debug modes, source-classification rules, expiry/blink behavior and collision-safe pop motion.
- Compose loot into all five normal-enemy PackedScenes, scale centralized health/shield resources, and add deterministic statistical/component tests rather than per-instance Main overrides.
- Extend the existing Boss room/exit flow with one fixed reward controller and permanent Ravenfang pickup on the safe bridge; Boss reward state persists across Player death and prevents the gate trigger from transitioning before collection.
- Add a compact threshold inventory summary, QA capture drivers/evidence, exact Godot 4.7.1 import/runtime/regression checks, required design documents and README instructions.
- Scope excludes shop UI, second-level gameplay, weapon upgrades/affixes, consumable inventory, random Boss loot, enemy AI changes, new enemy types, Player HP/Stamina changes and changes to enemy/Boss outgoing damage.

### Delivered implementation

- Added typed `WeaponData` plus Veilbound Daggers (Tier 1, 10/20) and Ravenfang Daggers (Tier 2, 12/24). `WeaponInventory` owns unique ids; `EquipmentManager` owns the equipped id and is now the sole source for Player normal/Dash Attack damage. The old 1/2 Hitbox literals and saved Dash damage override were removed.
- Added `Player/VisualRoot/WeaponVisual`, driven by `weapon_equipped`. Veilbound keeps the existing authored frame blades; Ravenfang overlays longer black-steel/pale-edge blades and restrained dark-red rune pixels across idle, run, jump, Ground/Air Dash, normal Attack and Dash Attack while retaining `flip_h` and unchanged combat geometry.
- Scaled the centralized target pools to Guard 30, Shield Guard Body 50/Shield 30, Spearman 50, Crossbowman 40, Gargoyle 30 and Gate Knight Body 180/Shield 100. Enemy/Boss outgoing damage, Player HP 100, Stamina 100, action timings, movement and AI are unchanged. Shield/Boss damage-art thresholds now use ratios.
- Added `LootDropProfile` and one `LootDropComponent` to each of the five reusable normal-enemy PackedScenes. All 34 Main instances inherit one health-aware roll: high HP 58/12/3/27, mid HP 52/16/5/27 and low HP 45/22/8/25 for coin/small/large/none. Player fatal Hitboxes are captured before Health mutation. Environment deaths never yield healing and retain only half of otherwise successful coin outcomes; debug deletion may suppress the roll. One resolved guard prevents duplicate drops.
- Added original Godot-drawn `CoinPickup`, 10-HP Small Blood Vial and 20-HP Large Blood Vial. Pickups pop a restrained 14 pixels, do not block or enter combat layers, expire after 20 seconds and blink during the final 3. Full-health/dead Players leave vials intact; accepted healing clamps in `HealthComponent`, emits the existing HUD signal and shows a small `+HP` plus dark-red pixel feedback.
- Added run-persistent `CurrencyManager`, signal-driven coin HUD and debug reset/grant helpers. Coin ranges are Guard 1–2, Shield 2–4, Spear 2–3, Crossbow 2–3 and Gargoyle 2–4. Failed spend leaves the balance unchanged and no operation can create a negative wallet.
- Added a fixed `BossRewardController` at bridge world `(6210,592)`. The complete Boss death grants 30 coins once, plays a small coin-bag/text response and original procedural chime, and reveals a permanent Ravenfang pickup. E adds it once, auto-equips it, updates Player blades/HUD immediately and persists through Player death. The gate still opens on Boss death; `CastleEntranceTrigger` blocks only the scene transition until the story weapon is collected and shows a small return prompt.
- Added the same compact coin/weapon HUD to `ravenmourn_threshold.tscn` under a CanvasLayer, proving wallet/equipment state survives Main → castle threshold. `ChapterSession` stores Boss reward spawned/collected flags for this run; no save file or shop was added.

### F5 and Main synchronization

- `project.godot` remains `run/main_scene="res://scenes/cinematics/opening_cinematic.tscn"`; the real path is Opening → `res://scenes/levels/veilbound_catacomb.tscn` → `res://scenes/main/main.tscn`.
- Main authorities are `Main/World/Player`, `Main/World/Encounters` (18 groups / 34 normal enemies), `Main/World/CastleEntranceArea/FallenGateKnight`, `Main/World/CastleEntranceArea/BossReward/WeaponPickup`, `Main/World/CastleEntranceArea/CastleEntranceTrigger`, `Main/HUD/RunInventory`, `Main/Interface`, `Main/BossRoomController` and `Main/CastleEntranceTransition`.
- The five normal PackedScenes each own one current LootDropComponent/Profile; Main contains no stale per-instance probability or HP override. The Player PackedScene owns the current equipment visual and current ActionController; Main does not override weapon damage.
- Main Debug compact/expanded output now reports coins, equipped weapon tier/id and 10/20 or 12/24 damage. Enemy details report loot profile/result/roll/source; Boss details report Body/Shield and fixed reward/collection state. F1/F2/F3 behavior remains unchanged.

### Commands and actual results

1. Exact engine and import/runtime:
   - `/Users/vincentz/Downloads/Godot.app/Contents/MacOS/Godot --version`: `4.7.1.stable.official.a13da4feb`.
   - Exact 4.7.1 editor parse and headless `--import --quit-after 120`: exit 0, no Script Error/Error/Warning.
   - Direct Main headless runtime for 600 frames: exit 0, no Script Error/Error/Warning.
   - Configured graphical F5 for 300 frames with Dummy audio: exit 0 on GL Compatibility / Apple M4, no Script Error/Error/Warning.
2. Deterministic loot/weapon progression:
   - `tests/items/test_loot_weapon_progression.gd`: PASS for data resources, 10/20→12/24 auto-equip, Player visual switch, six scaled pools, all 34 loot components, coin/heal/full/dead/single-consume cases, wallet death persistence/no-negative spend, environment rule, Boss reward gating/dedup and threshold persistence.
   - Seed 4242 / 100 rolls: high HP `{coin:63, small:9, large:3, none:25}`; mid HP `{59,12,5,24}`; low HP `{49,21,8,22}`. Every sample totals 100 and low-HP healing frequency is higher without becoming guaranteed.
3. Complete regression:
   - Serial exact-Godot execution of all repository test scripts: `FULL_TESTS count=40 failures=0 diagnostics=0`. This covers movement, Health/Stamina, death/respawn, Player attacks, five enemies, shield routing, Boss/reset/gate, 34-enemy Main, opening/revival/tutorial, traversal, assets and the new run progression.
4. Graphical evidence:
   - `scripts/tools/capture_loot_weapon_qa.gd`: exit 0 and reports `LOOT_WEAPON_QA: PASS` after capturing live Main pickups/Boss reward/equipment plus threshold persistence.

### QA evidence

- `docs/qa/loot_normal_enemy_coin_main.png`: 1280×720, 18,631 bytes, SHA-256 `4c07f6fde9b16e9079e0c72f1960d25f595f8b9f861973548a86fcdc10b185e3` — a real Castle Guard Death signal resolves forced coin through its composed Main-compatible LootDropComponent.
- `docs/qa/loot_small_blood_vial_main.png`: 1280×720, 18,084 bytes, SHA-256 `c27771650c8020f2a7f159e7cbfe56489ee5a94353f6f96285683874435900f2`.
- `docs/qa/loot_large_blood_vial_main.png`: 1280×720, 18,140 bytes, SHA-256 `19cce3041b422f97e388615b5224a39595b099de7d45ba176aaa9f589b7d5a26`.
- `docs/qa/boss_ravenfang_reward_main.png`: 1280×720, 35,313 bytes, SHA-256 `522134073f306fcb129496ead6f378326cba823decbcf162152932ddae6dcda4` — safe bridge reward and +30 coin feedback after complete Boss defeat.
- `docs/qa/ravenfang_equipped_main.png`: 1280×720, 45,882 bytes, SHA-256 `78c78fde16ab4af1c901e9fdcc82c37cd9d3d06a5c58f00f5d5afb7e29a92096` — acquisition prompt, Ravenfang Player presentation and WPN T2 12/24 HUD.
- `docs/qa/threshold_inventory_persistence.png`: 1280×720, 11,037 bytes, SHA-256 `2ed65343557ce6f314acb363bac2de64880bb52c3006ce52a86d3c343826695a` — castle threshold CanvasLayer still shows 30 coins and WPN T2 12/24.

### Acceptance status and known limitations

- Automated tests verify one-roll/dedup, exact values, signal wiring, 34 inherited components, gate blocking and state persistence. A human should still play Opening → revival → several health bands → Boss, judge drop readability/frequency, listen to the restrained reward chime, and confirm Ravenfang overlays remain clear through all fast actions and both facings.
- Pickups use a safe visual pop and fixed nearby settle point rather than RigidBody physics; this intentionally prevents wall/water launches and actor blocking. No navigation, enemy AI, movement, attack timing, Player HP/Stamina or incoming damage was changed.
- Persistence is runtime-only. A future save system must serialize coins, owned ids, equipped id, reward flags and chapter; no complete save, NPC store, Chapter II scene, upgrades, affixes, elements, durability, consumable inventory, weapon hot-swap or third weapon exists.

## 2026-07-26 — Dynamic normal-enemy loot by Player health (preflight)

Status: in progress — read-only audit and baseline verification complete

### Goal

- Replace the hard-coded normal-enemy loot thresholds with one shared, data-driven four-tier profile keyed from the Player Health snapshot at enemy death.
- Make full Health strongly favor coins and forbid blood vials; progressively favor healing at Light, Heavy and Critical damage without guaranteeing a drop.
- Preserve one-roll resolution, existing per-enemy coin quantity ranges, environment-kill restrictions, Boss fixed rewards, Player/Enemy combat values and all 34 authored Main enemies.

### Read-only audit

- Git began clean on `master` at `78b66b5`; configured F5 remains `res://scenes/cinematics/opening_cinematic.tscn`, which reaches `res://scenes/main/main.tscn` through the approved opening/catacomb flow.
- `scripts/items/loot_drop_component.gd` currently owns three hard-coded probability bands: high `58/12/3/27`, mid `52/16/5/27`, low `45/22/8/25` for coin/small/large/none. The component reads Player `current_health / max_health` when `enemy_died` fires, captures whether the last resolving Hitbox belonged to the Player and uses `_resolved` to prevent duplicate drops.
- Environment deaths cannot produce healing and apply a second 50% gate to otherwise successful coin results. One roll selects exactly one result, so coin and healing cannot spawn together.
- Each of the five normal-enemy PackedScenes owns exactly one `LootDropComponent` and its type-specific `LootDropProfile` for coin quantity. All 34 Main enemies inherit those five scenes; neither `first_level_encounters.tscn` nor `main.tscn` overrides probability data.
- `FallenGateKnight` has no `LootDropComponent`. `BossRewardController` remains the separate fixed authority for 30 coins and Ravenfang, so Boss rewards are outside this change.
- `MainEnemyDebugOverlay` currently reports result, integer roll, source and per-type quantity profile in Expanded mode, but not Health tier, ratio or active weights.
- Exact Godot 4.7.1 baseline command `--headless --path . --script res://tests/items/test_loot_weapon_progression.gd` exited 0 with `LOOT_WEAPON_PROGRESSION_TEST: PASS` and no Error/Warning diagnostics.

### Planned files, tests, and scope check

- Add typed loot-weight and dynamic-profile Resources plus one shared `.tres` containing the exact Full/Light/Heavy/Critical 100-point tables.
- Update only `LootDropComponent`, the five normal-enemy scene references and read-only Main Enemy Debug output; retain each enemy type's existing coin range profile.
- Extend deterministic tests with exact boundary mapping, forced-roll routing, 1,000 samples per tier, one-result/dedup, environment restrictions, all-34 shared-profile inheritance and Boss exclusion.
- Update README and the loot, healing and currency design documents; run exact import, complete tests and configured/direct-Main runtime checks before one milestone commit.
- Scope excludes pickup behavior, healing amounts, coin ranges, Player/Enemy/Boss balance, weapon damage, Boss reward, shops, Chapter II and any new gameplay system.

### Delivered implementation

- Added typed `LootProbabilityWeights` and `DynamicLootProfile`. The shared `default_dynamic_loot_profile.tres` stores Full `72/0/0/28`, Light `50/28/7/15`, Heavy `35/35/15/15` and Critical `20/25/40/15`; every row is validated to total exactly 100 during component startup.
- Replaced the three script literals with exact ratio boundaries: 100/100 Full; 99/51 Light; 50/21 Heavy; 20/1/0 Critical. Maximum Health remains read from `HealthComponent`; no fixed-100 gameplay decision was introduced.
- Enemy Death now reads current/maximum Health once and stores `selected_health_tier`, `selected_drop_result`, `drop_roll` and `player_health_ratio_at_kill`. One floating-point `[0,100)` roll chooses exactly one result. `_resolved` still blocks repeated Death and `reset_drop_state()` restores an explicitly reused test actor.
- Preserved environment rules without a second category roll: healing is impossible and coin uses half of the selected tier's coin interval; all remaining probability becomes none. Debug suppression still drops nothing.
- Each of the five reusable normal-enemy scenes explicitly references the same dynamic profile while retaining its existing type-specific quantity profile. No Main/encounter instance overrides were introduced, so all 34 tutorial/mainline/optional enemies inherit the current tables.
- Expanded Main Enemy Debug now retains the latest resolved drop and shows tier, death-time ratio, float roll, result, amount/source and active weights. Debug-build-only helpers provide exact Full/75%/50%/20% Health presets, one forced next roll and statistics reset without moving Health ownership into UI.
- Boss composition remains separate: Fallen Gate Knight has no normal `LootDropComponent`; its fixed 30 coins, Ravenfang reward and gate flow are unchanged. Small/large vial healing remains 10/20 and all coin quantity ranges remain unchanged.

### Main and data synchronization

- `project.godot` remains `run/main_scene="res://scenes/cinematics/opening_cinematic.tscn"`; the approved flow reaches `res://scenes/main/main.tscn` through Veilbound Catacomb.
- Main's `Main/World/Encounters` still contains 18 groups and 34 ordinary enemies: Guard 14, Shield 5, Spearman 6, Crossbowman 5 and Gargoyle 4. Their five PackedScenes all reference `res://resources/items/loot/default_dynamic_loot_profile.tres` and retain existing `resources/items/loot/*_loot.tres` quantity ranges.
- Main's live debug path is `Main/Interface/DebugHudRoot/EnemyDebugPanel/Content/EnemyScroll/EnemyDebug`. Formal Health/Stamina/currency UI, enemy combat values, Player weapon damage and encounter placement were not changed.

### Commands and actual results

1. Exact engine/import/runtime:
   - `/Users/vincentz/Downloads/Godot.app/Contents/MacOS/Godot --version`: `4.7.1.stable.official.a13da4feb`.
   - Exact editor parse plus headless import: exit 0; both new typed Resource classes registered; no Script Error/Error/Warning.
   - Graphical configured entry for 300 frames with Dummy audio: exit 0 on GL Compatibility / Apple M4; no red diagnostics.
   - Graphical direct `res://scenes/main/main.tscn` for 600 frames: exit 0; no red diagnostics.
2. Dynamic loot and Main contracts:
   - `tests/items/test_loot_weapon_progression.gd`: PASS for exact tables/boundaries, forced roll, one-result/dedup, death-time snapshot, reset, 34 shared profiles, unchanged coin ranges, environment restrictions, debug presets and fixed Boss reward.
   - Seed 4242 / 1,000 Player-kill rolls: Full `{coin:708, small:0, large:0, none:292}`; Light `{513,267,69,151}`; Heavy `{350,345,164,141}`; Critical `{196,240,423,141}`.
   - Seed 9102 / 1,000 Full-Health environment deaths: `{coin:360, small:0, large:0, none:640}`, matching half of the 72% coin chance with no healing.
   - `tests/ui/test_main_debug_hud.gd`: PASS; Compact/Expanded/hidden and F1/F2/F3/F4 remain functional.
   - `tests/combat/test_main_enemy_integration.gd`: PASS for 18 groups, 34 mixed enemies, Boss room, HUD and respawn.
3. Complete regression:
   - Standard 60 Hz ordered execution of all repository tests: `ORDERED_FULL_TESTS count=40 failures=0 diagnostics=0`.
   - During an earlier high-load serial order, the existing death presentation lower-bound check crossed its approximately-one-frame threshold and the Shield test emitted one transient in/out-signal diagnostic. Both passed repeated isolation; running those time-sensitive tests first produced the clean complete result above. No death, shield, animation or combat code/test was changed.

### Acceptance status and known limitations

- Automated Main instances verify the exact health matrix, one-roll behavior, all 34 inherited components, unchanged quantity profiles and Boss exclusion. Graphical smoke verifies both configured startup and the direct Main PackedScene without parser/runtime diagnostics.
- A human should still play the complete F5 flow and judge the perceived cadence across many real kills at Full, Light, Heavy and Critical Health. Statistical correctness does not replace subjective evaluation of whether 72% coins at Full and 40% large vials at Critical feel appropriately generous.
- Debug Health presets are callable development helpers rather than new on-screen buttons, so Compact HUD remains small. They refuse to run when Debug HUD is hidden or in a non-debug build.
- No pickup art/behavior, healing amount, coin quantity, Boss reward, shop, weapon/enemy balance, encounter count or Chapter II content was modified.
## 2026-07-26 — Veilbound Catacomb stone-door layering repair (preflight)

Status: in progress — read-only scene/render audit complete

### Goal

- Repair the F5 revival-scene stone door so the exterior night is visible only through the aperture, behind the wall/portrait facade, door frame and Player.
- Preserve the complete opening, revival dialogue, dagger recovery, door interaction/collision, exit fade and Main tutorial flow.

### Read-only audit

- Git began clean on `master` at `e0e8c96`, one local commit ahead of `origin/master`. `project.godot` resolves F5 to `res://scenes/cinematics/opening_cinematic.tscn`; the cinematic targets `res://scenes/levels/veilbound_catacomb.tscn`, whose exit targets `res://scenes/main/main.tscn`.
- Stone-door body is `VeilboundCatacomb/World/StoneDoorBody`; moving presentation is `.../StoneDoorVisual`; Player is `VeilboundCatacomb/World/Player`. The complete chamber wall, Veiled Order portrait/crest and broad exit moonlight are all drawn by `VeilboundCatacomb/World/CatacombArt`.
- `CatacombStoneDoor._draw()` currently owns four incompatible layers in one CanvasItem: opaque opening backing, rising stone slab/runes, exterior forest silhouette and moon. The entire item is `z_index=2`; Player root remains default z0. Consequently the exterior shapes render over a Player entering the doorway.
- The facade and aperture are not separate nodes. `VeilboundCatacombArt` draws the stone wall continuously behind the door and draws a wide translucent exit-light polygon last, so no explicit clipped background/front-frame relationship exists.
- World rendering uses neither YSort, Parallax nor top-level CanvasItems. Only formal HUD and narrative UI use CanvasLayers 6 and 20. No `show_behind_parent` override exists.
- Exact baseline `tests/level/test_veilbound_catacomb_flow.gd` passed, and direct catacomb runtime for 240 frames exited 0 without Script Error/Error/Warning.

### Planned files, tests, and scope check

- Split the exterior into a clipped `DoorOpeningBackdrop`, retain the current controller-facing `StoneDoorVisual` for the moving slab only, and add a `DoorFrameFront` presentation layer.
- Recompose the existing wall/portrait art under an explicit `ArchitectureFront/WallAndPortraitFront` node, carve the aperture from the wall renderer, place Player between backdrop and frame, and constrain moonlight to the threshold floor.
- Extend the existing catacomb QA capture with open-door overview and Player-in-aperture evidence; update the catacomb narrative scene specification and development log.
- Run exact Godot import, focused flow/transition tests, graphical configured F5 and direct catacomb runtime, visual inspection and complete regression before one commit.
- Scope excludes dialogue, timing, inputs, collisions, movement, tutorial, Main combat, loot, economy and all other environment art.

### Delivered implementation

- Replaced the single mixed-purpose door renderer with three explicit presentation responsibilities under the existing `World/StoneDoorBody`: `DoorOpeningBackdrop` draws only the aperture-clipped exterior night, `StoneDoorVisual` draws only the rising rune slab, and `DoorFrameFront` draws the fixed front jamb/lintel mask. The body collision and controller-facing `StoneDoorVisual` path remain unchanged.
- Reparented the existing chamber facade to `World/ArchitectureFront/WallAndPortraitFront`, carved the exact `(1298,406,144,248)` aperture out of the wall renderer and removed its full-screen opaque front-layer fill. This last fill was the second occlusion cause: it hid the correctly ordered night even after the nodes were separated.
- Established and regression-tested the explicit World order: exterior night z0 → wall/portrait facade z5 → Player/Candle Warden z10 → moving slab z20 → fixed door frame z25. World YSort remains disabled; there is no Parallax, `top_level` or `show_behind_parent` override. HUD and Narrative UI retain CanvasLayer 6 and 20.
- Restricted the former broad exit moonlight overlay to a low-opacity floor-threshold spill. The visible moon, stars and two forest silhouettes remain entirely inside the door aperture and therefore cannot cover the surrounding architecture or Player.
- Extended the existing catacomb QA capture and scene test with a full open-door overview, Player-in-aperture evidence, required node paths and strict z-order/YSort assertions. Opening, revival art/dialogue, dagger pickup, door collision/opening and Main transition behavior were not changed.

### Commands and actual results

1. Exact engine/import and scene contracts:
   - `/Users/vincentz/Downloads/Godot.app/Contents/MacOS/Godot --headless --path . --editor --quit`: exit 0; both new typed presentation classes registered; no Script Error/Error/Warning.
   - `tests/level/test_veilbound_catacomb_flow.gd`: PASS, including the new backdrop/facade/Player/slab/frame order and disabled YSort assertions.
   - `tests/level/test_veilbound_scene_transitions.gd`: PASS for Opening skip → Catacomb skip → Main tutorial.
   - `tests/level/test_chapter_one_flow.gd`: PASS for opening, tutorial, encounters, checkpoints and Boss epilogue contracts.
   - All other level scripts passed: bridge flow, environment unity, platform reachability, traversal routes and Ravenmourn environment.
2. Graphical runtime and evidence:
   - Configured graphical F5 entry `/Users/vincentz/Downloads/Godot.app/Contents/MacOS/Godot --path . --audio-driver Dummy --quit-after 300`: exit 0 on GL Compatibility / Apple M4; no red diagnostics.
   - `scripts/tools/capture_veilbound_catacomb_qa.gd`: exit 0 with `VEILBOUND_CATACOMB_QA: PASS (altar, soul, dialogue, layered door, player aperture, forest)`. This instantiates the exact F5-route Catacomb PackedScene, opens its real door presentation and captures both required spatial cases before checking the real Main PackedScene.
3. Complete regression:
   - Ordered execution reached `count=40`; 39 tests passed in the batch with zero unrelated diagnostics. The existing `test_player_death_presentation.gd` frame-count lower-bound assertion reproduced its documented one-frame timing fluctuation (`Full death flow completed too early`) in that batch, then passed immediately in isolation with its flat-body, dagger, ghost-pause and cleanup contract. No death, respawn or timing code was touched by this milestone.

### QA evidence and acceptance

- `docs/qa/veilbound_catacomb_door_layering_overview.png`: 1280×720, 18,473 bytes, SHA-256 `27f5b0e7510e554e2caf97b56004db6329fea085ca7cc4a9e414a3a7df6dafed` — open slab, facade/portrait masonry in front, and moon/forest restricted to the aperture.
- `docs/qa/veilbound_catacomb_player_in_doorway.png`: 1280×720, 18,475 bytes, SHA-256 `cc14f27c2dee4572a84b136ff4f407afcbd30a6837492c8f8425f1dc23aad759` — the live Player is visible in front of the night while the fixed jamb/lintel remain in front of the aperture edge.
- Automated and captured checks confirm no scene-parser/runtime errors and preserve the full F5 route. Human acceptance should still walk through the non-skipped revival, open the door with E and judge the final contrast while crossing the threshold on the user's display.

## 2026-07-26 — Ravenfang visual rebuild and Boss pressure-cadence repair (preflight)

Status: in progress — read-only audit and baseline verification complete

### Goal

- Replace the Ravenfang Daggers' straight overlay placeholder with one consistent, original curved raven-claw pixel design across inventory icon, Boss reward pickup and every equipped Player animation.
- Bound normal J chaining to three complete attacks followed by a mandatory recovery; preserve one fresh attack ID per strike and the existing 12/24 Ravenfang damage values.
- Prevent repeated normal hits from cancelling Fallen Gate Knight attacks indefinitely, while making rear-contact routing deterministic and lengthening the full turn response to a readable 0.48 seconds.

### Read-only audit

- Work began on `master` at `dc6496d`; `project.godot` still starts at `res://scenes/cinematics/opening_cinematic.tscn`, then reaches Catacomb and `res://scenes/main/main.tscn`. The live Boss instance is `Main/World/CastleEntranceArea/FallenGateKnight`; the live Player is `Main/World/Player`.
- The worktree already contained 13 unrelated modified Godot scene/resource files before this milestone, including `main.tscn`, Boss/enemy SpriteFrames/config resources and the Player action `.tres`. They are preserved as user-owned changes and will not be staged in this milestone.
- Ravenfang currently uses a 16×16 straight-bar icon and `PlayerWeaponVisual` draws a second straight blade overlay above base frames that already contain Veilbound daggers. This causes weapon silhouettes to mix, omits Hurt/Death and cannot provide one authoritative equipped design.
- `PlayerActionController` currently permits the same four-frame, 20 FPS Attack to repeat indefinitely whenever one input is buffered inside each chain window. It assigns fresh attack IDs and does not restart an active strike, but has no chain length cap or mandatory combo-end recovery.
- `FallenGateKnight._on_hurtbox_hit_received()` and `_on_shield_hit()` unconditionally terminate the active attack/turn and restart Hurt/Block on every accepted hit. This is the permanent-pressure root cause. Current turn defaults total about 0.23 seconds (`0.10 + 0.13`), below the requested readable response.
- Baseline exact Godot 4.7.1 results: `test_fast_attack.gd` PASS; `test_loot_weapon_progression.gd` PASS. `test_first_level_boss.gd` reported its existing camera-release assertion only (`Boss camera limits did not release`); turn timing printed `0.2333s`. This baseline failure predates task edits and is retained for comparison.

### Planned files, tests, and scope check

- Extend the existing pixel generators with a Ravenfang weapon style, generate a separate Ravenfang Player SpriteFrames resource and switch the real `AnimatedSprite2D` frames on equip rather than drawing an overlay.
- Update the existing item icon generator and pickup renderer; keep all equipment identity, reward, persistence, prompt and 12/24 combat data unchanged.
- Add explicit three-hit combo counters/recovery to the Player action controller and expanded-only debug data. Add Boss light/heavy reaction cadence, uninterruptible attack windows, 0.18-second turn reaction plus 0.30-second turn animation, and contact-time routing diagnostics.
- Add focused deterministic tests for resource coverage, three-hit termination, 20 rear normal trials, 10 rear Dash trials and a ten-second pressure simulation; capture at least six Main-backed QA images.
- Run exact import/parse, focused tests, complete regressions and graphical configured-F5/direct-Main smoke before one clear commit. Scope excludes damage rebalance, new weapons, enemies, Boss attacks, Chapter II and unrelated gameplay or art.

### Delivered implementation

- Rebuilt Ravenfang as an original paired raven-claw silhouette: forward-curved dark-steel blades, cold blue-grey edge, pale tip, folded-wing guard and beak-ring pommel. The 16×16 icon, Boss reward pickup and equipped Player now share that grammar; no licensed or third-party art was introduced.
- Generated a complete Ravenfang Player set at `assets/sprites/player/ravenfang/`: 49 transparent 64×64 PNG frames across all 16 existing animations. `PlayerWeaponVisual` now swaps the complete `SpriteFrames` resource atomically while preserving animation/frame/playback state, so base Veilbound blades never remain baked beneath a second overlay. Hurt and Death, including released death-frame daggers, use Ravenfang too.
- Limited normal Attack to three complete strikes. One input may be buffered only in the configured 0.10–0.20 chain window; every strike receives a fresh attack ID; the third strike rejects a fourth queued restart and enters a mandatory 0.34-second recovery. Minimum inter-strike cadence remains centrally configured at 0.32 seconds. Expanded debug reports combo step/max, window, buffered/queued state, attack ID and recovery without enlarging Compact HUD.
- Split Fallen Gate Knight feedback into light and heavy cadence. Normal hits always route damage but cannot cancel or restart any of the seven Boss attacks; a 0.32-second light-feedback cooldown prevents flash spam. Dash/heavy feedback uses a 0.50-second cooldown and may interrupt only neutral approach/turn/recovery states for 0.12 seconds. Shield break, phase transition and Death retain priority.
- Added immutable contact-time shield routing data (attack id/kind, source, Boss position/facing and timestamp). Rear normal trials therefore preserve the attack's original contact side even if the Boss begins turning afterward. Turn response is now 0.18 seconds plus a speed-scaled 0.30-second turn animation, measured at 0.4833 seconds end to end.
- Fixed two regression-support issues uncovered by the complete run: Player camera limits are explicit in the reusable Player scene, and pickup Area monitoring is disabled deferred so PhysicsServer state is never mutated while flushing overlap queries. No Main encounter, movement, HP/Stamina, damage value or Boss attack content was changed.

### Main synchronization and balance invariants

- Configured F5 remains `res://scenes/cinematics/opening_cinematic.tscn` and reaches `res://scenes/main/main.tscn` through the approved Catacomb flow. Main continues to instance `Main/World/Player` from `res://scenes/player/player.tscn` and `Main/World/CastleEntranceArea/FallenGateKnight` from `res://scenes/bosses/fallen_gate_knight.tscn`; their updated scripts/resources are therefore live without a Main-local override.
- The fixed Boss reward still equips `res://resources/items/weapons/ravenfang_daggers.tres`. Ravenfang damage remains exactly 12 normal / 24 Dash Attack; no enemy, Player Health, Stamina or reward-economy value changed.
- The complete Ravenfang frame resource is `res://resources/player/ravenfang_player_sprite_frames.tres`. Runtime equipment switches the real Player `VisualRoot/AnimatedSprite2D` to this resource, including idle, locomotion, air actions, every Dash/Attack variant, Hurt and Death.

### Commands and actual results

1. Exact engine and generation:
   - `/Users/vincentz/Downloads/Godot.app/Contents/MacOS/Godot --headless --path . -s res://scripts/tools/generate_ravenfang_player_assets.gd`: PASS, 16 animations / 49 transparent 64×64 frames.
   - `... -s res://scripts/tools/build_ravenfang_sprite_frames.gd`: PASS, all 16 animations built.
2. Deterministic gameplay verification:
   - `tests/player/test_fast_attack.gd`: PASS (immediate response, one buffer, three-hit cap, 0.34-second forced recovery, 0.25-second Dash Attack).
   - `tests/combat/test_ravenfang_boss_pressure.gd`: PASS. Twenty rear normal trials accepted first hits `20/20`, timing-dependent second hits `7/20`, and third hits `0/20`; ten rear Dash trials routed `10/10`; the ten-second J-pressure simulation recorded `9` Boss attacks started and `9` completed.
   - `tests/combat/test_first_level_boss.gd`: PASS; free and recovery turns both measured `0.4833s`; all seven attacks resist normal-hit interruption.
   - Ordered execution of every repository test: `FULL_SUITE tests=41 failed=0`, with no `SCRIPT ERROR`, `ERROR:` or failed assertion.
3. Graphical runtime and evidence:
   - Configured graphical F5 entry for 300 frames: exit 0 on Godot `4.7.1.stable.official.a13da4feb`, GL Compatibility / Apple M4, no red diagnostics.
   - Direct graphical `res://scenes/main/main.tscn` for 600 frames: exit 0, no red diagnostics.
   - `scripts/tools/capture_ravenfang_boss_cadence_qa.gd`: `RAVENFANG_BOSS_CADENCE_QA: PASS (9 Main-backed captures)`.

### QA evidence and acceptance

- `docs/qa/ravenfang_icon_main.png` — inventory icon and paired curved silhouette, SHA-256 `9b8787791914527e64d9c7ab1bf15e56b70e30fb382443ceb067bf05a7a6bb2b`.
- `docs/qa/ravenfang_boss_pickup_main.png` — live safe-bridge Boss reward pickup, SHA-256 `42413557842a2940025305a25f43febc989baf55bb74aee0e2593eefcf6fe263`.
- `docs/qa/ravenfang_equipped_idle_main.png` — complete equipped idle replacement and WPN 12/24 HUD, SHA-256 `e95bfc4735ac638682148c49ccc988a90f54192a26fe0df19264c9ce70677856`.
- `docs/qa/ravenfang_normal_attack_main.png` and `docs/qa/ravenfang_dash_attack_main.png` — separate curved-blade thrust silhouettes, SHA-256 `23361fe79ad138f3779fb479d0689f1169420d9007dd7122adf1792b5b7de1f1` / `b7c4c2f7d6b203751dddbc31b6ca9c222a9a533317a3a239ea7a48b9b684638d`.
- `docs/qa/ravenfang_death_frame_main.png` — Ravenfang-specific released death-frame daggers, SHA-256 `1997cde0bce4856f3a83f17bcb5f48f36fd6d3021daeda919e875b0a07d95d65`.
- `docs/qa/boss_light_pressure_counter_main.png`, `docs/qa/boss_rear_normal_window_main.png` and `docs/qa/boss_turn_reward_window_main.png` — Boss counter cadence, rear routing and readable turn window, SHA-256 `f9db86237bb7fd3a5c53c1a7c80d235b4c940d42d9efbcf4ea989863ccb69e4b` / `244af9f5762a71bec1becc53c84a42691c993bc5bbaea097b9bdcb66c50c4f13` / `534bc1740d704faf4b28f1fff2f56f237a14acafd65731c6d3c3312c0d0b3cbd`.
- Human acceptance should complete the full F5 route, collect Ravenfang after the bridge Boss, inspect both facings and all fast actions, then alternate frontal pressure and jump-behind attacks. The automated cadence is bounded and counter-capable; final subjective tuning of the three-hit rhythm and 0.48-second turn reward remains a play-feel decision.

### Known limitations and scope

- Ravenfang is a complete alternate frame set rather than a skeletal weapon layer; future pose additions must be generated for both weapon styles. This is intentional for crisp 64×64 silhouettes and prevents mixed weapons.
- Boss normal-hit feedback is cooldown-gated rather than full super armor: damage always applies, Dash/heavy contact retains stronger neutral-state feedback, and shield/phase/death transitions remain authoritative.
- The 13 scene/resource changes already present at preflight remain user-owned and are intentionally excluded from this milestone commit. No new weapon, enemy, Boss move, Chapter II content or combat-number rebalance was added.

## 2026-07-26 — Fallen Gate Knight turn and post-attack gap revision (preflight)

Status: in progress — latest requirements and live timing paths audited

### Goal

- Supersede the prior 0.44–0.56-second turn target with a readable 0.80–1.00-second complete turn, initially targeting 0.90 seconds without allowing hits to pause, restart or instantly finish the turn.
- Measure the unchanged Player action timings, then establish per-skill intervals measured from the previous active Hitbox close to the next windup start so one Normal or one Dash Attack plus an escape is viable.
- Preserve light-hit anti-lock behavior, contact-time front/back routing, all Player/weapon values, Boss HP/Shield/damage/moves/phases and the complete F5 flow.

### Read-only audit

- Current branch/commit is `master` at `6c5a0d8`; configured F5 is `res://scenes/cinematics/opening_cinematic.tscn` and reaches `res://scenes/main/main.tscn`. Live paths remain `Main/World/Player` and `Main/World/CastleEntranceArea/FallenGateKnight`.
- Thirteen pre-existing Godot scene/resource reserializations plus one generated QA-script UID remain outside this milestone. Main has no local override for turn or attack-recovery timing; its Boss inherits `res://scenes/bosses/fallen_gate_knight.tscn` and `res://resources/bosses/fallen_gate_knight_config.tres`.
- Current turn is `0.18 + 0.30 = 0.48s`, committed only after the authored Turn state. Light hits do not interrupt attacks, but heavy feedback currently lists Turn as interruptible and therefore can still cancel the turn.
- Every attack currently enters a single `attack_recovery = 0.42s` after its complete animation. Because that timer begins at animation end rather than active-window close, there is no authoritative per-skill active-end-to-next-windup measurement or guaranteed counter window.
- Player values are unchanged: Normal is 4 frames at 20 FPS (0.20s animation), active frames 2–3 (0.05–0.15s), and unlocks Dash/jump at 0.32s after its minimum-interval recovery. Horizontal movement remains available during Normal. Dash Attack is 5 frames at 20 FPS (0.25s; 0.2667s from a Dash press followed by next-frame J), active from 0.10–0.20s and can hand a buffered reverse Dash off at 0.25s. A Dash motion segment is 0.18s; a buffered reverse segment starts at that boundary, while an unbuffered Dash also plays a 0.10s end animation.

### Planned files, tests, and scope check

- Add exact turn and seven per-skill post-active gap values to `FallenGateKnightConfig`; update only Boss cadence/state bookkeeping and Expanded debug fields in the existing Boss script.
- Count the gap concurrently with attack follow-through and turn animation, prevent attacks until both gap and facing are valid, and allow only reduced-speed repositioning during the remainder.
- Extend Main-backed Boss tests with exact Player action measurements, 20 rear trials, five counter attempts after every major skill, phase cadence, reset behavior and three deterministic complete-fight cadence simulations.
- Update README plus the combat, Boss, room and level-metrics specifications. Run Godot 4.7.1 parse/import, focused and complete tests, configured F5/direct-Main graphical smoke, then create one isolated commit.
- Scope excludes Ravenfang art/values, Player action/movement timing, loot, other enemies, Boss HP/Shield/damage/moves/phases and Chapter II.

### Delivered implementation

- Revised the centralized Boss timing defaults to a 0.25-second reaction, 0.65-second authored turn and 0.14-second post-turn cooldown. Facing, sprite and directional combat roots still commit together only after the complete turn; normal hits cannot pause it, and heavy feedback can no longer cancel it.
- Replaced the single animation-end recovery gate with seven skill-specific Attack Gaps measured from the natural close of the final active Hitbox to the next legal windup: Shield Bash 0.98, Sword Slash 1.05, Heavy Overhead 1.20, complete Combo Slash 1.05, Charge Thrust 1.12, Jump Smash 1.16 and Shockwave Strike 1.10 seconds. The timer runs concurrently with follow-through and turning rather than adding dead time after them.
- Recovery movement is capped at 50% and used only when range adjustment is needed. A new attack cannot begin until both the Attack Gap and any required turn are complete. Hurt feedback preserves the running gap; reset clears every gap/measurement field.
- Expanded-only debug now exposes active-end time, remaining Gap, next-windup time, measured interval, reaction/animation/total turn timing, counter action and escape result. The Main Player debug also reports action frame, Dash/movement availability and distance to the live Boss without expanding Compact HUD.
- Player action timings and combat values were not edited. Main-backed measurement records Normal unlock at 0.320 seconds, Normal active at 0.050–0.150 seconds, standalone Dash Attack at 0.250 seconds, Dash-press-to-Dash-Attack completion at 0.267 seconds, earliest buffered reverse Dash at 0.267 seconds, Normal plus reverse-Dash escape at 0.500 seconds, Normal plus 48 px ordinary ground movement at 0.620 seconds and Dash Attack plus reverse-Dash escape at 0.447 seconds.

### F5 Main synchronization

- `project.godot` remains `run/main_scene="res://scenes/cinematics/opening_cinematic.tscn"`; the approved route transitions through Veilbound Catacomb to `res://scenes/main/main.tscn`.
- The playable nodes remain `Main/World/Player` and `Main/World/CastleEntranceArea/FallenGateKnight`. Main has no local timing override and inherits the revised `res://resources/bosses/fallen_gate_knight_config.tres`, `res://scripts/bosses/fallen_gate_knight_config.gd` and `res://scripts/bosses/fallen_gate_knight.gd` through the existing Boss PackedScene.
- Bridge checkpoint/trigger/Boss positions remain approximately x=5480 / 5780 / 6120. Encounter layout, camera, arena gates, Player equipment and Boss reward are unchanged.

### Commands and actual results

1. Exact engine/import and focused contracts:
   - `/Users/vincentz/Downloads/Godot.app/Contents/MacOS/Godot --version`: `4.7.1.stable.official.a13da4feb`.
   - Exact editor parse/headless import: exit 0; no Script Error/Error/Warning.
   - `tests/combat/test_boss_counter_windows.gd`: PASS. Natural active-close measurements at 60 Hz were Bash `0.983`, Slash `1.050`, Heavy `1.200`, complete Combo `1.050`, Charge `1.133`, Jump `1.167` and Shockwave `1.100` seconds.
   - `tests/combat/test_first_level_boss.gd`: PASS; free and Recovery turns both measured `0.9000s`; reset and all seven skill gaps matched centralized values.
   - `tests/combat/test_ravenfang_boss_pressure.gd`: PASS; rear Normal first hit `20/20`, second `14/20`, third `0/20`; rear Dash `10/10`; ten-second pressure completed all `6/6` Boss attacks that started.
   - `tests/ui/test_main_debug_hud.gd`: PASS for Compact/Expanded/hidden behavior plus the new Expanded timing fields.
   - `tests/combat/test_main_enemy_integration.gd`: PASS for the unchanged Main Player/Boss/encounter integration.
2. Counter-path and complete-fight simulation:
   - Every one of the seven major attacks passed Dash Attack → reverse Dash `5/5` and Normal → reverse Dash `5/5` deterministic Main-backed attempts.
   - Shield Bash, Sword Slash and Heavy Overhead also passed Normal → 48 px ordinary ground escape `5/5`. The test deliberately rejects a safe three-hit chain inside any configured gap.
   - Three controlled Main-backed complete-fight cadence simulations finished in `27.76`, `26.27` and `32.48` seconds; arithmetic mean `28.84` seconds. These deterministic simulations validate state progression and counter opportunities, not subjective human difficulty.
3. Regression/runtime/evidence:
   - Ordered execution of all repository tests: `FULL_SUITE tests=42 failed=0`; no red diagnostics.
   - Configured graphical F5 entry for 300 frames: exit 0 on Godot 4.7.1 GL Compatibility / Apple M4; no red diagnostics.
   - Direct graphical `res://scenes/main/main.tscn` for 600 frames: exit 0; no red diagnostics.
   - `scripts/tools/capture_ravenfang_boss_cadence_qa.gd`: `RAVENFANG_BOSS_CADENCE_QA: PASS (10 Main-backed captures)`.

### QA evidence and acceptance

- `docs/qa/boss_turn_reward_window_main.png`: 1280×720, 45,697 bytes, SHA-256 `549875e11dad3bad80016823fcc33ac2c1ffc94086c273ed297f374809ce49c1` — Main Boss turn evidence labelled `0.25 REACTION + 0.65 ANIMATION = 0.90`.
- `docs/qa/boss_post_attack_gap_main.png`: 1280×720, 46,696 bytes, SHA-256 `f30018d0070e67f3fdd0bac2e35db2ef3e4af53731b4ca1cb1d9286d69870882` — Main bridge counter evidence showing one attack plus reverse Dash while the next windup remains locked.
- Human F5 acceptance should reach the bridge from the x≈5480 checkpoint, cross the x≈5780 trigger, then test J→escape and Shift+J→reverse Shift after every major Boss attack. Jump/double-jump/Air Dash behind the Boss should expose the complete 0.90-second turn without allowing a safe third Normal. Expanded debug (F1/F2) exposes the measured Gap and turn fields.

### Known limitations and scope

- Exact intervals quantize to 60 Hz, hence configured 0.98/1.12/1.16 values measure as 0.983/1.133/1.167 seconds. All remain inside the approved bands.
- Automated checks prove deterministic timing, routing, state completion and bounded pressure. Final judgement of animation readability, ordinary-movement distance and full-fight difficulty still requires the user's human play-feel pass.
- Ravenfang art, Player Normal/Dash timing and damage, Boss HP/Shield/damage/moves/phases, other enemies, loot and Chapter II were not modified. The pre-existing Godot scene/resource reserializations remain outside this milestone commit.

## 2026-07-26 — Fallen Gate Knight attack geometry, Shield Bash, and turn-response revision (preflight)

Status: complete — implemented, verified, documented, and awaiting human play-feel acceptance

### Goal

- Replace the shared oversized melee damage volume with attack-family geometry that matches the authored shield, slash and thrust silhouettes.
- Slow Shield Bash to a readable 0.46-second windup / 0.10-second active / 0.68-second recovery, enforce a 2.70-second repeat cooldown, reduce its Phase-1 share and restrict it to true close range.
- Supersede the 0.80–1.00-second turn target with a 1.00–1.30-second target, initially 0.32-second reaction plus 0.80-second animation, with facing committed no earlier than 70% of the authored turn.
- Preserve the existing active-end Attack Gaps, anti-pressure rules, damage/Health/Shield, Player/weapon tuning, arena, loot and encounter content.

### Read-only audit

- Work began on `master` at `5bb811d`; F5 is `res://scenes/cinematics/opening_cinematic.tscn` and reaches `res://scenes/main/main.tscn`. The live Boss is `Main/World/CastleEntranceArea/FallenGateKnight`, instanced from `res://scenes/bosses/fallen_gate_knight.tscn` with `res://scripts/bosses/fallen_gate_knight.gd` and no Main-local attack/turn overrides.
- The worktree already contained user-owned Godot scene/resource reserializations, regenerated legacy QA images and generated `.uid` files. They will be preserved and excluded from this milestone except for precise task-owned hunks.
- The Boss currently composes one `FacingRoot/MeleeHitbox` Rectangle `100×42` at `(65,4)` for Shield Bash, Sword Slash, Heavy Overhead, both Combo steps, Jump Smash and Charge Thrust. Its local forward edge is x=115 although active-frame shield/sword tips are only about 20–34 pixels forward of the actor center. `FacingRoot/ShockwaveHitbox` is the only separate damage volume. The common melee rectangle starts at x=15, so it does not reach the true rear but overlaps the body front and extends far beyond every visible melee weapon.
- Phase 1 is a deterministic equal cycle `[ShieldBash, SwordSlash, HeavyOverhead]`: effective Shield Bash share 33.3%, no explicit weight and no repeat cooldown. It does not directly repeat only because of this fixed cycle. Phase 2 owns ComboSlash, JumpSmash, ChargeThrust and ShockwaveStrike and cannot Shield Bash after shield loss.
- Current five-frame Shield Bash at 9.8 FPS is approximately 0.204-second windup, 0.204-second active and 0.102-second visual recovery; frames 2–3 own the Hitbox. Its active-end Attack Gap is 0.983 seconds. Sword Slash uses the same timing; Heavy Overhead is about 0.341/0.227/0.114 seconds; Charge Thrust is about 0.182/0.182/0.091 seconds.
- Current turn is 0.25 reaction + 0.65 animation = 0.9000 seconds at 60 Hz. Facing/Sprite/FacingRoot commit together at animation end. Light and heavy feedback do not interrupt Turn; every attack Hitbox is closed outside its active frames and Turn states cannot select an attack.
- Exact Godot 4.7.1 editor/import baseline exited 0 without Script Error/Error/Warning. `tests/combat/test_first_level_boss.gd` passed with free and Recovery turns both measured at `0.9000s`.

### Planned files, tests, and scope check

- Update the centralized Boss config and exact saved resource values; add separate Shield Bash, Slash and Thrust hitbox nodes/shapes to the reusable Boss scene and route active windows by attack family.
- Add close/mid/long distance eligibility, weighted Phase-1 selection, an explicit Shield Bash repeat timer, custom frame durations for the requested Shield Bash stages, and late-turn facing commit bookkeeping.
- Extend Expanded Main debug with attack type/range/shape/cooldown/weight/distance and an optional geometry drawer; Compact remains unchanged.
- Add Main-backed geometry, timing, selection-distribution, left/right, single-hit, turn and counter-window tests plus four QA captures. Run exact parse/import, focused tests, complete regression, configured F5 and direct-Main graphical smoke.
- Update README, Boss/combat/room/metrics specifications and this log, create one isolated commit, then stop. Scope excludes every damage value, Body/Shield pool, Player/weapon parameter/art, other enemy, arena, loot, gate and Chapter II content.

### Delivered implementation

- Replaced `FacingRoot/MeleeHitbox` (`100×42 @ (65,4)`, local edge x=115) with three saved and runtime-configured Areas: `ShieldBashHitbox` `14×30 @ (19,4)`, `SlashHitbox` `26×22 @ (16,0)`, and `ThrustHitbox` `32×10 @ (20,-7)`. Their shape edges end at x=26/29/36, respectively 6/2/5 pixels inside the measured active shield/sword tips. With the current Player Hurtbox half-width, deterministic effective root ranges are 37/40/47 pixels. Heavy/Combo/Jump route through the slash volume; ChargeThrust uses the thrust volume; Shockwave retains its separate low long-range Area.
- Phase 1 now uses seeded weighted selection rather than the fixed equal cycle. The authoritative weights are Shield Bash 22%, Sword Slash 43%, Heavy Overhead 35%; a 2.70-second timer and last-attack guard prevent Bash repetition. Bash enters the pool only at ≤37 px, Slash/Heavy at ≤40 px, and the Boss approaches when none is eligible. Phase 2 and its existing `ChargeThrust` remain unchanged; no Shield Bash is available after shield loss.
- Authored Shield Bash as five frames at 10 FPS with duration units `2.3/2.3/0.5/0.5/6.8`, yielding exactly 0.46-second windup, 0.10-second active and 0.68-second recovery. Frames 2–3 remain the only active frames. Its active-end gap is 1.18 seconds (1.183 fixed-step), while every other approved gap and all damage values remain unchanged.
- Superseded the prior 0.80–1.00-second turn with 0.33-second reaction plus 0.80-second authored animation. The 0.33 value, rather than 0.32, compensates the existing 60 Hz request boundary and produces a measured 1.1333-second complete response. Facing/Sprite/FacingRoot commit at 80% of the animation (0.9833 seconds from rear entry), while attacks remain closed until Turn ends and distance is reevaluated.
- Expanded Enemy Debug retains Compact dimensions but adds live attack range, active family/width/offset, Bash cooldown/weight, turn commit and Player distance. Expanded/F3 detail also enables the real Boss collision rectangles, active fill, visual-tip reference lines and Player Hurtbox; Compact/F1-hidden modes disable drawing.

### Main synchronization and unchanged scope

- `project.godot` remains `run/main_scene="res://scenes/cinematics/opening_cinematic.tscn"`; the approved Opening → Veilbound Catacomb route reaches `res://scenes/main/main.tscn`. The live nodes are `Main/World/Player` and `Main/World/CastleEntranceArea/FallenGateKnight`.
- Main's Boss instance has no local attack geometry, Bash cadence, selection or turn Inspector override. It inherits `res://scenes/bosses/fallen_gate_knight.tscn`, `res://resources/bosses/fallen_gate_knight_config.tres`, `res://resources/bosses/fallen_gate_knight_sprite_frames.tres` and `res://scripts/bosses/fallen_gate_knight.gd`; no edit to `main.tscn` was required.
- Boss Body 180, Shield 100, Bash/Slash/Heavy/Charge/Shockwave damage 8/10/15/12/8, Player HP/Stamina/damage/movement, Ravenfang, all skills/phases, bridge bounds, gate, loot, enemies and Chapter content are unchanged.

### Commands and actual results

1. Exact engine/import and focused contracts:
   - `/Users/vincentz/Downloads/Godot.app/Contents/MacOS/Godot --headless --editor --path . --quit`: exit 0; no Script Error/Error/Warning.
   - `tests/combat/test_boss_attack_geometry.gd`: PASS. For Shield/Slash/Thrust, left and right each passed 10 inside/outside PhysicsServer shape-query trials plus a rear-safe check. Sampled 2,000 Phase-1 selections were Bash `20.9%`, Slash `43.0%`, Heavy `36.0%`; no direct/cooldown-bypassing Bash was selected.
   - `tests/combat/test_first_level_boss.gd`: PASS; free and Recovery turns measured `1.1333s`, facing commit `0.9833s`, target `1.00..1.30`.
   - `tests/combat/test_boss_counter_windows.gd`: PASS; Bash stages `0.46/0.10/0.68`, post-active gap `1.183`, and all approved counter/escape paths `5/5`.
   - `tests/combat/test_ravenfang_boss_pressure.gd`: PASS; rear Normal first `20/20`, second `14/20`, third `0/20`; rear Dash `10/10`; pressure simulation completed all `6/6` Boss attacks.
   - `tests/ui/test_main_debug_hud.gd`: PASS; Compact/Expanded/F3/F1 behavior and geometry-draw lifetime verified.
2. Controlled Main-backed cadence runs:
   - Fight 1 (12 Phase-1 choices): Bash 2, Slash 4, Heavy 6; shortest repeated Bash interval 4.80 s.
   - Fight 2: Bash 3, Slash 6, Heavy 3; shortest repeated Bash interval 3.60 s.
   - Fight 3: Bash 1, Slash 4, Heavy 7; no second Bash, so repeated interval is not applicable.
   - Existing complete-fight state simulations finished in `28.46/26.98/33.54s` (mean `29.66s`). These are deterministic Main-backed simulations, not fabricated human input or a final play-feel judgement.
3. Regression and runtime:
   - Ordered execution of every `tests/**/*.gd` SceneTree test: `FULL_SUITE tests=43 failed=0`.
   - Configured graphical F5 entry, 300 frames: exit 0 on Godot 4.7.1 GL Compatibility / Apple M4; no red diagnostics.
   - Direct graphical `res://scenes/main/main.tscn`, 600 frames: exit 0; no red diagnostics.
   - `scripts/tools/capture_boss_attack_geometry_qa.gd`: `BOSS_ATTACK_GEOMETRY_QA: PASS (4 Main-backed captures)`.

### QA evidence and acceptance

- `docs/qa/boss_thrust_hitbox_main.png`: 1280×720, 41,237 bytes, SHA-256 `7d5b18f27c50aa956b7e06e22be998f621c72d59823019ef0683c98e348a9014`.
- `docs/qa/boss_slash_hitbox_main.png`: 1280×720, 41,108 bytes, SHA-256 `16e3303227a06ffd49c4d73695f5695613460546e0a70d6d70bc392510b7a272`.
- `docs/qa/boss_shield_bash_hitbox_main.png`: 1280×720, 41,974 bytes, SHA-256 `0bb2210727d247e48e892b21dbd3bc31bf97cc96818dd0646b398ffb16d7b455`.
- `docs/qa/boss_rear_turn_window_main.png`: 1280×720, 43,183 bytes, SHA-256 `509e6672525a0be119f8f5965ba44f877b229e6c7d5e94f983a941bb9af07dce`.
- Human acceptance should traverse the real F5 Opening/Catacomb flow, reach the x≈5480 checkpoint, cross the x≈5780 bridge trigger and press F2 (or F3 for Enemy details) to show geometry. Stand beyond/inside each colored edge in both directions, then use jump/double-jump/Air Dash to cross behind and judge whether the 1.133-second response permits the intended one stable or timing-sensitive second Normal. F1 hides all Debug drawing.

### Known limitations and scope

- The user's three-name summary does not match the live seven-attack state machine: Phase 1 actually selects Shield Bash, Sword Slash and Heavy Overhead, while `ChargeThrust` belongs to the unchanged Phase-2 four-attack cycle. The implementation documents and tunes the real states instead of silently moving ChargeThrust between phases or adding a new move.
- Physics/automation proves saved geometry, left/right/rear ranges, timing, one-hit ledgers, weighted selection and bounded rear pressure. Final visual contact feel, Bash tell strength and whether the second Normal is appropriately skill-dependent still require human F5 playtesting.
- Pre-existing user-owned Main/resource reserializations and legacy QA changes remain unstaged. No weapon, loot, other enemy, Boss damage/Health/Shield, arena, second level or new attack was modified.

## 2026-07-26 — Chapter start foundation Stage 2A

Status: complete — implemented, verified, documented, and awaiting Stage 2B approval

## Goal

- Establish a reusable typed Chapter Registry and Chapter Start Profile without loading unfinished chapter scenes.
- Add one centralized Debug Run Config whose default selection is Chapter II, while leaving the configured F5 Opening and the complete formal flow unchanged.
- Register the prologue and Chapters I–VI, document debug/save isolation, and stop before Stage 2B routing.

## Read-only audit

- Work began on `master` at `fe57165`; `project.godot` resolves `run/main_scene` to `res://scenes/cinematics/opening_cinematic.tscn`.
- Formal flow remains Opening → `res://scenes/levels/veilbound_catacomb.tscn` → `res://scenes/main/main.tscn`.
- Existing `ChapterSession` is a narrow Chapter I runtime-only flag service. Currency, weapon inventory and equipment also persist only for the process; there is no disk save or generic chapter registry.
- The worktree contained 20 user-owned modified/untracked paths before this milestone. They are preserved and excluded from this commit.

## Planned files, tests, and scope check

- Add `ChapterStartProfile`, `ChapterRegistry`, and side-effect-free `DebugRunConfig`; register the latter as a genuine pre-scene configuration Autoload.
- Add a deterministic Stage 2A test for seven registry entries (prologue plus six chapters), Chapter II metadata/default selection, debug/release guard and unchanged F5 route.
- Add chapter/debug/save/Chapter II planning specifications and update README.
- Run exact Godot 4.7.1 import/parse, the focused Stage 2A test, existing formal-flow tests and a project startup smoke. Create one isolated commit.
- Scope excludes routing, profile application, Chapter II scene/gameplay, any migration of Chapter I files, and all combat/content changes.

## Delivered implementation

- Added a typed `ChapterStartProfile` Resource contract for scene/spawn/checkpoint, prerequisites, weapon/equipment, currency/health, Boss/shortcut/story flags and readiness metadata. Planned scene paths are validated as metadata without loading them.
- Added `ChapterRegistry` with the Prologue plus all six numbered chapter IDs. Prologue and Chapter I reference current scenes; Chapter II is registered at `res://chapters/chapter_02_silent_court/scenes/level/silent_court.tscn`; Chapters III–VI are planned entries. Unfinished chapters remain `debug_ready = false`.
- Added the side-effect-free `/root/DebugRunConfig` Autoload. Its default target is `CHAPTER_02_SILENT_COURT` / `chapter_02_cp01`, with disposable 30-coin, full-health test preferences. Its gate requires `OS.is_debug_build()`; it never changes scenes.
- Preserved `run/main_scene="res://scenes/cinematics/opening_cinematic.tscn"` and the complete authored Opening → Veilbound Catacomb → Main flow. Stage 2B routing, Stage 2C state application/real Chapter II scene and Stage 2D direct-F5 QA remain unimplemented by design.

## Commands and actual results

1. `/Users/vincentz/Downloads/Godot.app/Contents/MacOS/Godot --headless --editor --path . --quit`: exit 0; all three new global classes and the Autoload parsed/imported without red diagnostics.
2. `... --headless --path . --script res://tests/systems/test_chapter_start_foundation.gd`: `CHAPTER_START_FOUNDATION_TEST: PASS (7 entries, Chapter II default, no routing)`.
3. Existing formal-flow contracts:
   - `tests/level/test_chapter_one_flow.gd`: PASS.
   - `tests/level/test_veilbound_scene_transitions.gd`: PASS.
   - `tests/level/test_veilbound_catacomb_flow.gd`: PASS.
4. `... --headless --path . --quit-after 120`: exit 0; configured Opening startup produced no Script Error or Error.
5. Ordered execution of every `tests/**/*.gd` SceneTree test: `FULL_SUITE tests=44 failed=0`.

## Known limitations and manual acceptance

- Chapter II is deliberately selected but not runnable: its scene and saved legal start profile do not exist yet, so registry readiness remains false and no attempt is made to load it.
- This data-only stage has no new visual result or screenshot requirement. F5 manual acceptance is simply that the existing Opening still appears and proceeds through the unchanged story flow.
- The 20 user-owned preflight paths remain preserved and unstaged. No Main scene, combat, enemy, Player, HUD, art or chapter gameplay content was changed by Stage 2A.

## 2026-07-26 — Chapter II joint scene/enemy design, Stage 1

Status: complete — documented, verified, and awaiting Stage 2 approval

### Goal

- Convert the approved Silent Court narrative, nine-room route, five enemy roles, fifteen encounters and Ballroom Boss-space brief into build-ready dimensions and coordinates derived from the live Player metrics.
- Audit the actual startup, shared systems, transitions, collisions and Inspector state instead of assuming Chapter II or its routing already exists.
- Keep this stage documentation-only and stop before scenes, routing, enemies, encounters, doors or gameplay are created.

### Read-only audit

- Work began on `master` at `653671d`; F5 remains `res://scenes/cinematics/opening_cinematic.tscn`. Stage 2A registered Chapter II metadata and a default Debug selection, but no router consumes it.
- `res://chapters/chapter_02_silent_court/`, the target `silent_court.tscn` and a saved Chapter II Start Profile do not exist. The first-level entrance currently changes only to the presentation-only `res://scenes/transitions/ravenmourn_threshold.tscn`.
- The reusable Player, HUD, checkpoint, respawn, encounter, health, hitbox/hurtbox, enemy base and loot components remain at shared paths. There is no generic Door base, SceneTransitionManager, generic GameSession/RunState or `AttackContext` data class yet.
- Exact Godot 4.7.1 import exited 0 without red diagnostics. Live metric measurement at 60 Hz reported 83.77 px single rise, 167.10 px double rise, 153.59/281.92 px horizontal single/double ranges, 196.59/321.26 px with one Air Dash, 86.40 px one Dash motion segment, 28 px foot offset and 48 px minimum safe landing width.
- Twenty pre-existing user-owned modified/untracked paths remain present. They will be preserved and excluded from this documentation commit.

### Planned files, tests, and scope check

- Create the six requested documents under `chapters/chapter_02_silent_court/docs/`, with exact room/camera/door/checkpoint/spawn/encounter coordinates and the 34-enemy roster.
- Update README and this log only. Do not edit `project.godot`, scripts, scenes, Resources, input, tuning, art or tests.
- Re-run exact Godot import, Chapter foundation and metric contracts, then verify the Git diff contains only documentation owned by this stage and create one isolated commit.
- Stage 2 will create the loadable Chapter II scene/profile, minimal debug route and nine-room graybox; none of that is claimed complete in Stage 1.

### Delivered design

- Created six build-ready Chapter II documents under the new chapter-owned `docs/` path. They define a 32,128 px / 25.1-screen route, exact room/global/camera bounds, safe traversal envelopes, five checkpoint positions, four door categories, ten narrative triggers and the complete Stage 2 PackedScene manifest.
- Planned 15 bounded Encounter zones with 34 finite enemies: Retainer 11, Halberdier 6, Mourning Armor 4, Acolyte 5, Stalker 5 and three shared returning enemies. Every role has HP, damage, kill counts, state responsibilities, interruption rules and component ownership.
- Planned the 4608×900 Silent Ballroom with a 3968 px clear combat lane, CP05 separation, Boss door/trigger, Camera contract and the Stage 8 Duchess placeholder boundary.
- Preserved the narrative reveal limits and established one-shot trigger locations for the banquet echo, Elowen portrait/key memory, Crown/Veilbound seal, thirteen-toll inscription and required Boss final line.
- Documented the actual startup gap rather than claiming a feature that does not exist: F5 still enters Opening; Stage 2 must create the valid target/profile and minimum debug router before the nine-room graybox can be entered.

### Commands and actual results

1. `/Users/vincentz/Downloads/Godot.app/Contents/MacOS/Godot --headless --editor --path . --quit`: exit 0 after documentation; no Script Error or Error.
2. `... --headless --path . --quit-after 120`: exit 0; configured Opening startup remains intact.
3. `tests/systems/test_chapter_start_foundation.gd`: PASS — seven entries, Chapter II default metadata and no routing.
4. `tests/player/measure_player_level_metrics.gd`: PASS — 83.77/167.10 px rises, 153.59/281.92 px single/double ranges, 196.59 px single+Air Dash, 324.92 px double+Air Dash on the final run, 48 px safe landing floor. Design uses the more conservative repeated 321.26 px double+Air-Dash measurement.

### Known limitations and manual acceptance

- Stage 1 is intentionally non-playable design. There is no Silent Court scene, saved Start Profile, Bootstrap/router, Chapter II Player/HUD instance or room geometry to inspect in-game.
- Pressing F5 currently verifies only that the unchanged Opening still starts cleanly. The Debug config metadata can be inspected in `scripts/systems/debug_run_config.gd`; playable Castle Gate Interior acceptance begins in Stage 2.
- No screenshot was generated because no visual/runtime content changed. The 20 pre-existing user-owned paths remain outside this milestone.

## 2026-07-26 — Chapter II Stage 2: nine-room full graybox route

Status: in progress — implementation authorized; no later Chapter II content stage is in scope

### Goal

- Build the complete nine-room Silent Court graybox as independently instantiable room scenes plus one chapter-owned level scene.
- Make the existing debug Chapter Start configuration enter Chapter II from F5 while preserving the authored Opening as `run/main_scene` and preserving the normal non-debug flow.
- Reuse exactly one shared Player, camera, respawn service and signal-driven HUD; provide six selectable debug spawns and all approved checkpoint, encounter, door, narrative, enemy-spawn and Boss-room anchors.

### Pre-implementation audit

- Work begins on `master` at `ef5471d`; `project.godot` still resolves `run/main_scene` to `res://scenes/cinematics/opening_cinematic.tscn`.
- Stage 2A provides typed chapter metadata and a side-effect-free `DebugRunConfig`, but there is no router, saved Chapter II start profile, Silent Court PackedScene, room scene, Player/HUD runtime composition or Chapter II test.
- The shared Player already owns Camera2D, health, stamina, combat presentation and the existing death sequence. Existing signal-driven Health, Stamina and run-inventory HUD scripts can be reused without copying gameplay data into UI.
- Twenty pre-existing user-owned modified/untracked paths are present, including `scenes/main/main.tscn` and live Chapter I/Boss tuning. They will be preserved and excluded from this stage's commit.

### Planned files, tests, and scope check

- Add nine exact room scenes under `chapters/chapter_02_silent_court/scenes/rooms/`, their chapter-owned graybox presentation/camera scripts, the composed `silent_court.tscn`, a saved Chapter II Start Profile and one reusable shared chapter gameplay runtime.
- Add a guarded debug-start router Autoload while leaving `run/main_scene` unchanged. Apply only disposable debug state: Ravenfang equipped, 30 coins, full health/stamina and the selected `CH2_*` spawn.
- Add deterministic graybox/profile/router contracts; run exact Godot 4.7.1 import, focused tests, existing startup regressions, a real graphical F5 traversal, and capture at least one QA screenshot for every room.
- Stage 2 contains solid traversal geometry and named future-system anchors only. It explicitly excludes enemy AI/instances, encounter activation, functional doors/checkpoints/narrative, final art, complete Boss/shop logic and Chapter III work.

### Delivered implementation

- Added the independently loadable `silent_court.tscn` and all nine required non-numbered room PackedScenes. They form a continuous 32,128 px route with a common full-solid floor at `y=612`, exact Stage 1 room widths, solid ceiling boundaries, two authored stair-ramp areas, jumpable banquet tables, a Chapel altar, optional movement-test platforms, distinct low-cost room presentation and one room-boundary Area each.
- Added one reusable `chapter_gameplay_runtime.tscn` containing exactly one existing Player instance, its existing Camera2D, respawn controller and signal-driven Health/Stamina/inventory HUD. No room contains Player, HUD, enemies or gameplay managers.
- Added the saved Chapter II Start Profile, six legal `CH2_*` selectors and guarded `ChapterStartRouter`. `run/main_scene` remains the Opening; Debug F5 validates and enters Silent Court, while release/disabled/invalid and `--script` test processes fall through.
- Debug start resets disposable state, equips Ravenfang, grants 30 coins, restores 100 HP/100 Stamina, places Player origin at the selected safe marker and binds respawn to the same marker.
- Added all five checkpoint, fifteen Encounter, thirty enemy-spawn, ten door, six narrative and required Boss-space anchors. They are inert by stage contract; no enemy, door, checkpoint, encounter, narrative or Boss logic is claimed.
- The one Camera2D keeps continuous horizontal limits `0..32128` and switches only room vertical limits. This avoids horizontal snapping at room joints and deliberately refines the Stage 1 proposal for hard per-room horizontal clamps.

### Commands and actual results

1. `/Users/vincentz/Downloads/Godot.app/Contents/MacOS/Godot --headless --editor --path . --quit`: exit 0; room, level, router, runtime, profile and test resources parsed/imported without red diagnostics.
2. `... --headless --path . --script res://chapters/chapter_02_silent_court/tests/test_silent_court_graybox.gd`: `PASS rooms=9 spawns=6 encounters=15 player=1 hud=1`.
3. `tests/systems/test_chapter_start_foundation.gd`: PASS — seven entries, Chapter II ready and Opening still configured.
4. `tests/player/measure_player_level_metrics.gd`: PASS — 83.77/167.10 px jump rises, 153.59/281.92 px normal ranges, 192.92/321.26 px with Air Dash, 48 px minimum safe landing width; Player tuning was unchanged.
5. First formal transition regression exposed that the new Debug router intercepted a script-driven Opening test. Routing was narrowed to bypass all `--script` processes; rerun `tests/level/test_veilbound_scene_transitions.gd` then passed Opening skip → Catacomb skip → Main tutorial.
6. Existing `test_chapter_one_flow.gd` and `test_veilbound_catacomb_flow.gd`: PASS. Ordered full deterministic suite including the new chapter test: `FULL_SUITE tests=45 failed=0`.
7. Final graphical F5 command `... --path . -- --capture-ch2-graybox`: Player traversed through CharacterBody2D physics with no coordinate write or flight, triggered Ground Dash plus double-jump/Air Dash through Input Map, jumped solid table/altar obstacles when blocked, and stopped 25 seconds in each room; `PASS duration=362.05s screenshots=9`.
8. Forced-render final-geometry preflight `... --path . -- --recapture-ch2-graybox-fast`: exit 0, `duration=146.09s`, all nine logged Player X coordinates within their rooms and nine unique 1280×720 screenshots. No Script Error, Error or debugger-red output occurred.

### QA evidence and known limitations

- Evidence and SHA-256 ledger: `docs/qa/chapter_02_graybox/stage_2_f5_report.md`; screenshots `room_01_castle_gate_interior_f5.png` through `room_09_silent_ballroom_f5.png` in the same directory.
- Automated evidence proves saved paths, anchors, single Player/HUD composition, basic collision continuity, debug profile state, full route and camera-boundary switching. Jump/Dash metrics prove comfortable geometry envelopes; platform feel and optional-branch readability still require human F5 playtesting.
- Platforms, banquet tables, altar and stair ramps use full-solid graybox collision. One-way behavior, staircase comfort, underside/edge polish, functional normal/encounter/shortcut/Boss doors and active CP01–CP05 are deliberately deferred.
- The 20 pre-existing user-owned modified/untracked paths remain preserved and excluded. No Chapter I Main scene, existing enemy/Boss tuning, combat, Player movement Resource or art was modified by Stage 2.
## 2026-07-27 — Chapter I filesystem reorganization

Status: complete — Chapter I filesystem migration, shared ownership split, debug profiles and regression evidence delivered; Chapter II feature development remains paused

### Goal

- Move the complete Ravenmourn Outskirts runtime, encounters, two Chapter I-only normal enemies, Fallen Gate Knight, Chapter I environment/tutorial/test tooling and Chapter I documents under `res://chapters/chapter_01_ravenmourn_outskirts/`.
- Move the three normal enemies explicitly reused by the approved Chapter II roster (Cursed Shield Guard, Fallen Crossbowman and Gargoyle Sentinel) into `res://shared/` without duplicating their formal assets.
- Preserve the formal Opening bootstrap, current gameplay/tuning/node names and all user-owned dirty work while updating every live path reference.

### Pre-implementation audit and plan

- Work begins on `master` at `86403d7`; `project.godot` still resolves `run/main_scene` to `res://scenes/cinematics/opening_cinematic.tscn`.
- The formal non-debug flow remains Opening → Veilbound Catacomb → legacy `res://scenes/main/main.tscn`; Debug F5 currently routes to the existing Chapter II Stage 2 graybox. This migration does not add Chapter II gameplay.
- Twenty pre-existing modified/untracked paths overlap several migration targets. They are preserved; overlapping content will not be reset, cleaned or silently folded into the migration commit.
- The authoritative pre-move inventory and path map is `docs/migration/chapter_01_reorganization_manifest.md`. It records 388 files containing 845 relevant legacy path occurrences before movement.
- Scope excludes Prologue relocation, new enemies/Bosses, encounter changes, balance changes, art replacement, Player changes and Chapter II graybox/content work.

### Delivered migration

- Added `res://chapters/chapter_01_ravenmourn_outskirts/` and moved the saved Main gameplay root to `scenes/level/ravenmourn_outskirts.tscn`; its local encounter/Boss bridge transforms, Checkpoints, HUD, tutorial, reward and gate composition remain intact.
- Moved Castle Guard, Decayed Spearman and Fallen Gate Knight formal runtime/art into Chapter I. Moved Shield Guard, Crossbowman, Gargoyle, Crossbow Bolt and the minimal generic enemy base/config scripts into `res://shared/`, because the approved Chapter II roster directly reuses those types.
- Moved Chapter I environment/tutorial/transition scripts, test scenes, QA/build helpers, deterministic tests and chapter-specific design/narrative documents into the chapter tree. Public Player/combat/HUD/items/checkpoint/chapter services and Prologue/Catacomb remain at neutral root paths.
- Rewrote scene/resource/script/import references and refactored the mixed enemy art/SpriteFrames builders to use explicit per-enemy roots instead of a legacy common directory. Old live Main/enemy/Boss/projectile path search is now zero outside historical records.
- Added the saved `chapter_01_start_profile.tres`, a narrow Chapter I debug-spawn adapter and five validated selectors. Debug F5 defaults to `dark_forest_tutorial_spawn`; `boss_checkpoint` is the Boss-preflight selector. The formal Opening bootstrap remains configured.
- Updated Castle Entrance to load the existing Chapter II level after Boss reward/gate completion. This closes the already-authored chapter boundary without adding Chapter II gameplay.
- Git removed `824` tracked files from legacy locations (806 detected renames plus 18 deletions paired with regenerated/moved assets). Final Chapter I contains `472` tracked files; `shared` contains `359` tracked files total. There are `501` resolved Chapter I/shared references across `97` live non-document files.

### Exact commands and actual results

1. Godot 4.7.1 import/parse:
   - `/Users/vincentz/Downloads/Godot.app/Contents/MacOS/Godot --headless --editor --path . --quit`: exit 0; no Script Error, Parse Error, Failed to Load, Invalid UID or Missing Resource diagnostic. Logs: `docs/qa/chapter_01_reorganization/headless_import.log` and `headless_import_after_profiles.log`.
2. Ordered automated regression:
   - Every `test_*.gd` and `validate_*.gd` below root tests plus Chapter I/II tests ran with the exact engine. First run: 44/45 passed; the sole failure was an obsolete assertion that still expected the removed threshold placeholder. After updating that contract, focused rerun passed; final full rerun is recorded in `all_automated_tests_final.log`.
   - Coverage includes five Chapter I debug spawns, Chapter I flow/encounters/checkpoints, all five normal enemies, Boss geometry/counter windows/reward/gate, Player/combat/HUD regressions and Chapter II graybox preservation.
3. Configured graphical F5-equivalent startup:
   - `/Users/vincentz/Downloads/Godot.app/Contents/MacOS/Godot --path . --quit-after 360`: exit 0 on GL Compatibility / Apple M4; Opening bootstrap routed through the default Chapter I profile without red diagnostics. Log: `f5_chapter_01_start.log`.
4. Rendered Chapter I/transition QA:
   - `Godot --path . --script chapters/chapter_01_ravenmourn_outskirts/scripts/tests/capture_chapter_01_reorganization_qa.gd`: exit 0, `PASS (6 rendered checkpoints, Chapter II loaded)`.
   - Evidence: `chapter_01_forest.png`, `chapter_01_outskirts.png`, `chapter_01_castle_approach.png`, `chapter_01_boss.png`, `chapter_01_ravenfang_drop.png`, `chapter_01_enter_chapter_02.png` under `docs/qa/chapter_01_reorganization/`.
5. Hygiene:
   - Old live runtime path search: zero matches outside the explicitly excluded historical logs/manifests/QA.
   - `git diff --check`: recorded after final staging review.

### Manual acceptance and preserved worktree state

- Full Chapter I: leave `debug_start_chapter_id` at Chapter I and `debug_start_spawn_id=&"dark_forest_tutorial_spawn"`, press F5, then traverse forest → outskirts → castle approach → Boss bridge.
- Boss-preflight: set only `debug_start_spawn_id=&"boss_checkpoint"`, press F5, defeat Fallen Gate Knight, collect Ravenfang and enter the open gate; Chapter II Castle Gate Interior must load.
- Automated checks establish saved paths, spawning, resources, enemy/Boss behavior contracts and scene change. Human acceptance is still required for uninterrupted full-chapter pacing and combat feel.
- The pre-existing user-owned tuning, Main reserialization, seven QA image changes and two untracked generated UID files remain preserved. They are not to be silently included in this isolated migration commit.
## 2026-07-27 — Chapter II Hollow Duchess Boss milestone

Status: complete — implementation, Main integration, exact-engine regression and graphical QA passed; manual combat-feel acceptance pending

### Goal

- Implement The Hollow Duchess, Seraphine as the complete two-phase Chapter II Boss, including authored movement, seven readable attacks, attack/recovery cadence, turn locking, Poise/Stagger resistance, intro/death presentation and deterministic reset.
- Produce original, game-ready pixel sprites and effects under the Chapter II Boss-owned asset tree, compose an independently loadable Boss scene/test room, and integrate the real encounter into Silent Ballroom and the Bootstrap Chapter II `CH2_BOSS` path.
- Reuse the existing typed Health/Hitbox/Hurtbox, Player, respawn and chapter-runtime contracts without changing Player movement, Ravenfang 12/24 damage, Chapter I content, Phase 2 enemy tuning, loot, currency or later chapters.

### Pre-implementation audit

- Work begins on `master` at `fe667345e0371d14ba46cb008c88c576cb87dbac`. `project.godot` resolves `run/main_scene` to `res://scenes/bootstrap/main_bootstrap.tscn`; debug Chapter Start is currently disabled and defaults to Chapter I.
- Chapter II Main is `res://chapters/chapter_02_silent_court/scenes/level/silent_court.tscn`. It already owns `PlayerSpawnPoints/CH2_BOSS`, `BossArea/BossSpawn`, `BossArea/PlayerBossEntry`, `BossArea/BossActivationArea`, `BossArea/BossCameraBounds`, `BossArea/BossDoorRear` and `BossArea/BossExitDoor`, but all are inert graybox anchors and there is no Hollow Duchess scene, script, Resource, art or animation.
- Silent Ballroom is `res://chapters/chapter_02_silent_court/scenes/rooms/silent_ballroom.tscn`; CP05 and the Boss-door anchor are in `silent_ballroom_antechamber.tscn`. The composed Player is `res://scenes/player/player.tscn` with `res://scripts/player/player.gd`: run speed 220 px/s, jump velocity -420 px/s, Dash 480 px/s for 0.18 s, Ravenfang Normal/Dash damage 12/24, and the existing Health/Hurt/respawn/HUD composition.
- Reusable combat contracts are `HealthComponent`, `HitboxComponent` and `HurtboxComponent`. Chapter I's room controller, Boss HUD, camera lock and reset patterns are implementation references only; Chapter I files and its live tuning will not be modified.
- Pre-existing user-owned Chapter I/shared tuning, QA images and two untracked UID files remain in the worktree. They will be preserved and excluded from this Boss commit.

### Planned files, tests, and scope check

- Add Chapter II-owned Boss config/state script, room controller/presentation components, boss scene, isolated test room, original pixel generator/SpriteFrames/effects, focused deterministic tests and F5 QA capture tooling.
- Update Silent Court only where required for the actual Boss instance, solid doors, activation, CP05 respawn, camera lock, Boss HUD/dialogue and cleared-state exit placeholder. Do not populate E01–E15 or create Chapter III content.
- Verify exact Godot 4.7.1 import/parse, standalone Boss/test-room startup, seven attack timing/dedup contracts, turn/Poise/phase/reset contracts, existing Chapter II/Player regressions, formal F5 bootstrap and graphical `CH2_BOSS` Main captures. Record real commands/results before one isolated commit.

### Delivered implementation

- Added a typed, concentrated `HollowDuchessConfig` and explicit two-phase `HollowDuchess` state controller. Phase 1 implements Rapier Thrust, Fan Slash, Backstep Riposte and Side-Step Cut; Phase 2 adds Double Waltz Lunge, two telegraphed non-solid Phantom Dancer routes and three-pass Final Waltz Crossing. Every action has explicit Windup/Active/Recovery, direction lock, bounded repeat selection and mandatory chain recovery.
- Added 220 HP, the exact 121 HP/55% transition without healing, 60 Poise, Normal 10/Dash 24 Poise pressure, 0.56-second Stagger and 2.50-second protection. Normal attacks cannot cancel Boss attacks, Dash light reaction is neutral-state-only, and the 0.14+0.44-second Turn commits facing at 70% rather than one-frame flipping.
- Composed the saved `hollow_duchess.tscn` from the existing shared Health/Hitbox/Hurtbox contracts. Separate geometry covers Rapier, Fan, Riposte, Side Cut, both Double Lunge hits and Final Waltz. Phantom and Final passes use fresh attack IDs and the shared target ledger to prevent repeated damage inside one active pass.
- Generated 101 original transparent 96×96 nearest-neighbor Boss frames across twenty named sequences, plus an original editable concept SVG and phantom effect. Built one saved SpriteFrames Resource; no external, downloaded, AI-generated or provenance-unknown asset was used.
- Added the production encounter at `SilentCourt/BossArea/HollowDuchess`, signal-driven bilingual Boss HP/Phase/Poise HUD, intro/death dialogue, Ballroom presentation, solid rear/exit doors, existing-camera bounds, CP05 retry and deterministic reset. Player death keeps the established ghost/respawn presentation; Boss death does not create a ghost and opens the safe exit placeholder without starting Chapter III.
- Added an independently runnable Boss test room, configuration/state tests, Main composition test, five full live-component battle simulations and Bootstrap-based graphical QA tooling. Updated current Chapter II plan, Boss-room plan, README and dedicated Boss specification.

### Verification commands and actual results

1. Generation/import:
   - Exact Godot asset generator: `HOLLOW_DUCHESS_ASSET_GENERATOR: PASS animations=20`.
   - Exact Godot SpriteFrames builder: `HOLLOW_DUCHESS_SPRITE_FRAMES: PASS animations=20`.
   - `Godot --headless --editor --path . --import --quit`: exit 0 on `4.7.1.stable.official.a13da4feb`; no parser, resource, UID or import error.
2. Focused Boss contracts:
   - `test_hollow_duchess_boss.gd`: `PASS attacks=7 iterations=70 phase=2 poise=60`; each of seven attacks completed ten start/active/finish cycles.
   - `test_hollow_duchess_main_integration.gd`: `PASS boss=1 doors=2 cp05=1 hud=1` and exact `CH2_BOSS` Player spawn.
   - `test_hollow_duchess_full_fights.gd`: five real-component simulations completed at 222/223/224/225/226 simulated seconds, 16 accepted Player hits each and 294 total Boss attack starts.
   - Standalone Boss scene/test room and composed Silent Court started headlessly without red diagnostics.
3. Main/Bootstrap graphics:
   - `Godot --path . --script .../capture_hollow_duchess_qa.gd`: `PASS captures=10`; Output proves MainBootstrap selected the saved Chapter II Main. Evidence covers intro, seven attacks, phase transition and death under `res://docs/qa/chapter_02_hollow_duchess/`.
   - `Godot --headless --path . --quit-after 120`: formal default still prints `MAIN BOOTSTRAP | FORMAL NEW GAME | res://scenes/cinematics/opening_cinematic.tscn`.
4. Regression/hygiene:
   - Recursive exact-engine `test_*.gd` suite: `FULL_SUITE tests=46 passed=46 failed=0`.
   - Five existing pixel/enemy/Boss asset validators: 5 passed, 0 failed.
   - Isolated staged tree `/tmp/nocturne_duchess_staged_final.CQn6yI`: exact-engine import plus Boss contract, Main composition and all five full fights passed, proving the milestone does not depend on preserved unstaged Chapter I/shared tuning.
   - `git diff --check`: PASS.

### Known limitations and manual acceptance

- The Boss is a complete first playable pixel implementation, not final per-frame art polish. Final audio, richer particles and environment-matched lighting are intentionally deferred.
- Automated fights use the real damage component chain and real Boss AI while protecting the test Player from death. They prove state/cadence/victory completion, not subjective reaction comfort or player skill balance.
- Manual F5 acceptance should judge Rapier/Fan silhouette clarity, Riposte/Side-Step punish windows, 0.58-second Turn readability, Phantom lane contrast, Final Waltz routing, camera extremes and whether one safe punish but not three greedy hits feels consistent.
- The five Phase 2 enemy showcase instances and formal E01–E15 population remain unchanged. Chapter III, shop, final environment art and unrelated Chapter I/user-owned dirty paths remain outside this commit.

## 2026-07-27 — Chapter II layering repair and three-floor rebuild

Status: complete — Main integration, three-floor route, layer/collision evidence and exact-engine regression passed; human combat/pacing acceptance pending

### Goal and scope

- Repair the live Chapter II actor/terrain draw-order fault, normalize runtime enemy parenting and safe spawn placement, and rebuild the 32,128 px single-floor strip as a compact three-floor castle.
- Preserve Player movement, Ravenfang damage, enemy/Boss tuning, loot/currency, Chapter I, save foundations and Chapter III scope. The existing Hollow Duchess remains the third-floor terminal Boss.
- Deliver through the configured `MainBootstrap` F5 path with chapter debug selectors, exact Godot 4.7.1 tests, live collision/layer evidence and twelve rendered Main screenshots.

### Pre-implementation audit and plan

- Work begins on `master` at `5e9e83df076e8da9f87e24312d09645027ebd5b3`; `project.godot` resolves `run/main_scene` to `res://scenes/bootstrap/main_bootstrap.tscn`, and Chapter II Main is `res://chapters/chapter_02_silent_court/scenes/level/silent_court.tscn`.
- The broken Banquet actor path is rooted at `SilentCourt/Phase2EnemyPrototypeShowcase/MourningArmorPrototype`; all five prototype enemies are chapter-root siblings of `Rooms`, remain at default `z_index=0`, and use manually authored old single-floor coordinates. The room root `Chapter02RoomGraybox` also draws background masonry, the complete 108 px ground fill, raised-route fill and surface edge in one default-z CanvasItem. Player visuals happen to use local z 1/2, explaining why Player is readable while default-z enemies merge with or fall behind the ground drawing.
- No Chapter II room uses `CanvasLayer` or Y-sort; only the shared HUD is a CanvasLayer. Enemy Sprite/CharacterBody origins use the common 64 px centered-frame contract with a 28 px foot offset; old showcase instances were placed at player-origin y=584 without a formal spawn/snap service. Room `EnemySpawnAnchors` are inert children of offset room scenes, so using their local values as globals would double/miss room transforms.
- Current Chapter II bounds are `0..32128`; Chapter I's real outer wall is at x=6624. The rebuild target is 7168 px (108.2% of Chapter I), with floor surfaces at y=612, -288 and -1188 and two continuous collision-backed stairs. Existing room widths total 32,128 px and repeat the same full-screen masonry/floor treatment.
- Planned task-owned files: Chapter II level/room builder and presentation scripts, two stair scenes, runtime encounter/spawn composition, Chapter II Start Profile/spawns, focused tests/QA capture, five Chapter II specifications and this log. Existing user-owned Chapter I/shared tuning and QA changes will remain unstaged and untouched.

### Delivered implementation

- Replaced the 32,128 px one-floor strip with a 7,168 px-wide three-floor snake route: F1 moves right at surface y=612, F2 moves left at y=-288, and F3 moves right at y=-1188 into the existing Hollow Duchess room. This is 108.2% of Chapter I's measured 6,624 px width and removes 77.7% of Chapter II's former horizontal span.
- Rebuilt the saved Main hierarchy around explicit absolute world layers: Far/Mid/Architecture/GroundBack at z=-100/-80/-60/-30, room art at z=-60, PropsBehind at z=-10, enemies/Boss at z=10, Player at z=12, pickups at z=14, projectiles/effects at z=16, three-pixel walkable trim at z=20, front props at z=25 and foreground at z=30. Y-sort remains disabled; the shared HUD remains the sole gameplay CanvasLayer.
- Removed `Phase2EnemyPrototypeShowcase` and centralized 38 finite normal-enemy instances under `GameplayWorld/Enemies/EncounterE01..E15`. All ground definitions now store global foot coordinates and apply `Vector2(0,-28)` exactly once; ceiling and air actors use explicit anchor types. Vertical activation filtering prevents another floor at the same x coordinate from engaging.
- Reauthored all nine room scenes with compact room widths, distinct F1/F2/F3 native-2D first-pass art and separated full ground fill from the three-pixel foreground surface trim. Added wide Grand Service and narrow Servant Side staircase scenes with continuous collision polygons and narrow structural beams; there is no large high-z ground or stair polygon covering actors.
- Moved the production Boss area to the third-floor Ballroom, updated its activation/camera/door paths, and added the six requested floor selectors through the formal Chapter Start Profile: `CH2_FLOOR_1_START`, `CH2_FLOOR_1_BANQUET`, `CH2_FLOOR_2_START`, `CH2_FLOOR_2_CHAPEL`, `CH2_FLOOR_3_START`, `CH2_BOSS`.
- Fixed room camera bounds to include the room root's world y offset. All floors share horizontal limits 0..7168; vertical limits are 0..720, -900..-180 and -1800..-1080, with a combined transition range while the Player is on either staircase.

### Exact commands and actual results

1. Exact-engine import/parse: `/Users/vincentz/Downloads/Godot.app/Contents/MacOS/Godot --headless --editor --path . --quit` — exit 0, no parser/resource/import error.
2. Saved-scene contract: `... --headless --path . --script res://chapters/chapter_02_silent_court/tests/test_silent_court_graybox.gd` — `PASS rooms=9 floors=3 spawns=11 encounters=15 enemies=38 player=1 hud=1`.
3. Boss/Main regression: `... test_hollow_duchess_main_integration.gd` — `PASS boss=1 doors=2 cp05=1 hud=1` after the third-floor relocation.
4. Three physics/Input Map route passes: `... test_chapter_02_three_floor_route.gd` — all three reached `(5708.55,-1216.075)`, each logged 90.90 simulated seconds and `softlocks=0`.
5. Chapter II focused suite: 7/7 passed. Full recursive deterministic suite: `FULL_SUITE tests=47 passed=47 failed=0`.
6. Graphical MainBootstrap capture: `... --script res://chapters/chapter_02_silent_court/scripts/tools/capture_chapter_02_three_floor_qa.gd` — `PASS captures=12 encounters=15 enemies=38`; live tree printed Player z=12, Enemies z=10 and Y-sort off.
7. Visible collision capture: `... capture_chapter_02_collision_audit.gd` — `PASS`; Banquet floor collision at y=612, authored Retainer foot `(4740,612)`, settled actor origin near `(4740,583.49)`.
8. `git diff --check` — PASS after final documentation/staging review.

### Scope, evidence and known limitations

- QA ledger and 13 rendered 1280x720 images: `docs/qa/chapter_02_three_floor/chapter_02_three_floor_qa_report.md`. It covers all floors, both stairs, the Boss lane and visible collision shapes.
- Automated traversal deliberately disables combat and uses real Player physics/Input Map. It proves three complete routes without softlock, but it does not substantiate the 25–35 minute first-play target; combat pacing, encounter fairness and stair feel remain human F5 acceptance items.
- Environment art is an editable Godot-native first playable pass, not final tiles or independent painted concept art. Floor-owned folders contain honest replacement-slot README files and are not claimed as completed concept sheets.
- No Chapter I, Player tuning, Ravenfang damage, Chapter II enemy/Boss balance, loot/currency, save foundation or Chapter III logic was changed. Pre-existing user-owned Chapter I/shared resource and QA changes remain preserved outside this commit.

## 2026-07-27 — Chapter II polish Stage 1: short stairs and floor fades

Status: complete — short stairs, two Main floor transitions, QA evidence and focused regression delivered

### Goal and scope

- Replace the two 1,800 px continuous inter-floor ramps with short, visibly stepped castle stairs followed by a 0.35–0.80 second black-screen relocation through the existing MainBootstrap/Chapter II runtime.
- Preserve exactly one Player, HUD, Camera2D and encounter runtime; update camera bounds at blackout, prevent input/damage during relocation, and keep the current three-floor direction and spawn selectors.
- This stage explicitly excludes the later enemy-platform redistribution, Boss-room/dialogue/reward/Chapter III exit work and environment-wide art polish requested for subsequent approvals.

### Pre-implementation audit and planned files

- Work begins on `master` at `5f84f1ca3d4dd9f937c33f0fbf0e34725fcd87cb`; `project.godot` resolves `run/main_scene` to `res://scenes/bootstrap/main_bootstrap.tscn`, Chapter II resolves to `res://chapters/chapter_02_silent_court/scenes/level/silent_court.tscn`, and Debug direct start remains opt-in through `DebugRunConfig` with `CHAPTER_02_SILENT_COURT` plus `CH2_START`/`CH2_FLOOR_1_START`.
- Current F1→F2 traversal is `GameplayWorld/Geometry/GrandServiceStair`, scene `scenes/rooms/grand_service_stair.tscn`, spanning 1,800 px run and 900 px rise. F2→F3 is the equivalent `ServantSideStair`; both use one-way collision wedges and no trigger/fade. `TransitionAreas` is empty.
- Chapter runtime contains the sole Player/Camera/HUD. The Player provides the safe `InputProfile.LOCKED` contract; the HUD CanvasLayer has no Chapter II floor fade. Camera floor limits are selected in `silent_court.gd` from world Y.
- Fifteen Encounter groups and 38 enemies are built by `Chapter02EncounterRuntime`. E06 currently places actors on/around the long Grand stair and E12 sits next to the long Servant stair; only the minimum positions invalidated by removing those ramps may be moved in this stage.
- Planned task files: both stair scenes and their drawing script, a typed transition Area/controller, the Silent Court Main composition/controller, focused transition/route tests, Stage 1 Main QA capture, route/metrics documentation and this log. Pre-existing Chapter I/shared tuning, loot/Player Resources and old QA image changes remain untouched and unstaged.

### Delivered

- Replaced both 1,800 px / 900 px long ramps with compact 560 px horizontal / 192 px-rise stairs. `GrandServiceStair` uses 14 visible stone steps; `ServantSideStair` mirrors the route direction and adds restrained timber rail accents. Both use solid collision wedges and preserve actor readability.
- Added typed `Chapter02FloorTransition` trigger areas and a focused `Chapter02FloorTransitionController`. Its `0.22 s` fade-out + `0.08 s` full-black hold + `0.22 s` fade-in totals `0.52 s`, within the approved `0.35–0.80 s` target.
- The controller reuses the sole saved Player, Camera2D and HUD, locks input, temporarily prevents damage, clears velocity, relocates only at full black, changes the existing floor-local camera limits and restores the previous input/invulnerability contract after reveal. Concurrent requests and dead-player requests are rejected.
- Added F1→F2 and F2→F3 triggers to the saved Chapter II Main scene. The first resolves to `CH2_FLOOR_2_START`; the second resolves to `CH2_FLOOR_3_START`. `project.godot` remains unchanged and F5 still enters `MainBootstrap`.
- Preserved all 15 encounter groups and 38 normal enemies. Only E06 and E12 actors whose anchors depended on the removed long ramps were moved to existing safe floor surfaces; comprehensive enemy-stuck and distribution work remains Stage 2.
- Added focused saved-scene and runtime transition assertions, updated the existing graybox/route QA, and added a graphical MainBootstrap capture with five 1280×720 evidence frames under `docs/qa/chapter_02_floor_transitions/`.

### Commands and actual results

- `/Users/vincentz/Downloads/Godot.app/Contents/MacOS/Godot --headless --editor --path . --quit`
  - Exit `0`; exact Godot `4.7.1.stable.official.a13da4feb`; no parse, import or resource errors.
- `/Users/vincentz/Downloads/Godot.app/Contents/MacOS/Godot --headless --path . --script res://chapters/chapter_02_silent_court/tests/test_silent_court_graybox.gd`
  - `PASS rooms=9 floors=3 spawns=11 encounters=15 enemies=38 player=1 hud=1`.
- `/Users/vincentz/Downloads/Godot.app/Contents/MacOS/Godot --headless --path . --script res://chapters/chapter_02_silent_court/tests/test_chapter_02_floor_transitions.gd`
  - `PASS transitions=2 player=1 hud=1`; both transitions rejected duplicate requests, locked input, applied temporary invulnerability, selected the correct destination/camera floor and restored state.
- `/Users/vincentz/Downloads/Godot.app/Contents/MacOS/Godot --headless --path . --script res://chapters/chapter_02_silent_court/tests/test_chapter_02_three_floor_route.gd`
  - `PASS runs=3 softlocks=0`; all three real-physics/Input Map routes finished in `89.00 s` at `(5703.896,-1216.075)`.
- The same exact-engine invocation passed `test_phase_2_enemy_prototypes.gd`, `test_phase_2_enemy_damage.gd`, `test_hollow_duchess_boss.gd`, `test_hollow_duchess_main_integration.gd` and `test_hollow_duchess_full_fights.gd`. Boss coverage completed seven attack cycles ×10, Main composition `boss=1 doors=2 cp05=1 hud=1`, and five complete simulated fights with 294 attacks total.
- `/Users/vincentz/Downloads/Godot.app/Contents/MacOS/Godot --path . --script res://chapters/chapter_02_silent_court/scripts/tools/capture_chapter_02_floor_transition_qa.gd`
  - `CH2_FLOOR_TRANSITION_MAIN_QA: PASS captures=5 transitions=2`; graphical MainBootstrap run completed without red errors. Evidence and hashes are recorded in `docs/qa/chapter_02_floor_transitions/chapter_02_floor_transition_qa_report.md`.

### Defect found during Stage 1 verification

- The first transition run exposed a saved-transform error: the shortened `ServantSideStair` still inherited its former `-1800` world Y and its new solid wedge overlapped the F3 destination. The focused runtime test reported the incorrect landing, the root was corrected to `(168,-900)`, and all subsequent transition and three-route runs passed.

### Known issues and manual acceptance

- Automated traversal deliberately disables combat and therefore does not certify encounter fairness, enemy/platform stuck points or the human feel of the short stair approach. Those are Stage 2/manual acceptance items.
- Current native-2D stair art is a readable first pass, not the later environment-wide art-polish deliverable. Existing debug labels remain visible in QA captures.
- Manual F5 route: enable Chapter II direct start at `CH2_FLOOR_1_START`; travel F1 right to the short Grand stair and enter its landing, then travel F2 right-to-left to the short Servant stair and enter its landing. Verify the black transition, destination floor, Camera2D, controls and HUD after both moves.
- Next proposed stage: Stage 2, a read-only-first audit of all Chapter II enemy platform/stuck points followed by minimal encounter and spawn redistribution. No Stage 2 work was performed here.

## 2026-07-27 — Chapter II to Chapter III transition milestone

Status: complete — implementation, MainBootstrap integration, reload contract, full regression and six-image graphical QA passed; manual pacing acceptance pending

### Goal and scope

- Complete the narrative and playable transition from `Chapter II: The Silent Court` to a clearly marked minimal `Chapter III: Chapel of Thirteen Echoes` entry placeholder.
- Deliver the Hollow Duchess four-line death exchange, Ballroom mirror mechanism, Royal Chapel Passage secret door, short enemy-free processional corridor, reward-condition placeholder, typed runtime story flags and a formal Chapter Registry/scene-transition route.
- This milestone does not create Crimson Masque Stilettos or any other final Boss weapon, does not alter Boss combat tuning, Player values, enemies, Chapter II floor structure, Chapter I or loot probabilities, and does not implement Chapter III encounters/map/Boss/final art.

### Pre-implementation audit

- Work begins on `master` at `b60daf3a837b63d27d421fbf6b88bfb29d22fd9e`; `project.godot` still starts `res://scenes/bootstrap/main_bootstrap.tscn`, and Chapter II resolves to `res://chapters/chapter_02_silent_court/scenes/level/silent_court.tscn`.
- The saved Hollow Duchess encounter is `SilentCourt/GameplayWorld/BossArea/HollowDuchess`, controlled by `SilentCourt/ChapterSystems/HollowDuchessRoomController`. Its current death state emits only `夜巡守卫：你认识我？` and `瑟芙琳：不……但殿下一直在等你。`, then opens the plain `BossExitDoor`; no mirror wall, religious secret door, post-Boss passage, reward anchor or Chapter III scene exists.
- `ChapterRegistry.CHAPTER_03_CHAPEL_OF_THIRTEEN_ECHOES` is presently a `debug_ready=false` planned entry pointing at a missing `chapel_of_thirteen_echoes.tscn`. The project has `ChapterSession`, `ChapterRegistry`, `ChapterStartProfile` and direct `SceneTree.change_scene_to_file` controllers, but no `SceneTransitionManager`, no generic GameSession and no reusable story-flag ledger. The new cross-scene fade service and flags must therefore be narrow additions to the existing architecture, not falsely described as pre-existing systems.
- Existing Player/HUD runtime composition is reusable. A scene change frees the source runtime and instantiates exactly one destination runtime; Autoload state persists. `interact` is already mapped to E.
- Existing user-owned Chapter I, Player/item and shared-enemy Resource changes plus old QA image changes are present before this milestone. They are unrelated, will not be modified, staged or claimed.

### Planned task-owned files and tests

- Extend the typed ChapterSession/Bootstrap/Registry contracts, add one cross-scene fade service, create a Chapter III start profile and minimal entry scene, then add composed Chapter II mirror/secret-door/reward-placeholder and an enemy-free Royal Processional Passage scene.
- Add focused story/reload/transition tests, update existing Chapter Registry assertions, create at least six graphical MainBootstrap evidence frames and run exact Godot 4.7.1 import, Chapter II/Boss regressions and the affected system suite.

### Delivered implementation

- Extended the existing typed `ChapterSession` instead of creating a duplicate GameSession. It now owns process-lifetime chapter completion, story flags and one pending transition spawn; `MainBootstrap` applies complete debug profiles through the same service.
- Added the global `SceneTransitionManager` fade service and connected it to `ChapterRegistry`. The Boss never hard-codes a Chapter III path, and each destination scene composes exactly one existing Player/HUD runtime.
- Completed Seraphine's four-line death exchange, clears her Ballroom presentation, and starts a 2.20-second native-2D mirror sequence. The restored mirror contains no Player reflection, receives thirteen visible cracks and separates to reveal a black bell-shaped Royal Chapel Passage door with thirteen grooves, royal crest, prayer statues and restrained mist.
- Added a clearly labeled neutral Boss reward placeholder at `SilentCourt/GameplayWorld/BossArea/Chapter02BossWeaponPickupAnchor`. It exists only to prove `chapter_02_boss_weapon_collected`; it is not Crimson Masque Stilettos and does not alter weapon inventory, HUD or damage.
- Added the enemy-free `RoyalChapelPassage` with one shared runtime, short ceremonial route, pointed windows, prayer benches, bell motifs and an E-driven side-door transition. Added the safe `Chapter03EntryPlaceholder` with the required spawn, CP01, CameraBounds, door, title trigger, floor, route placeholder, safety bounds and Debug label; it contains no enemies, encounters, Boss or full Chapter III content.
- Reloading Chapter II after Seraphine's defeat hides the Boss, retains the revealed mirror and reconstructs a missing uncollected placeholder. The secret door refuses entry until collection and displays `公爵夫人的遗物仍留在舞厅中。`.
- Added the dedicated transition specification and a six-image MainBootstrap QA ledger. Shared HUD room labels now update correctly in the processional passage and Chapter III vestibule.

### Story flags and transition timing

- Flags: `hollow_duchess_defeated`, `chapter_02_exit_revealed`, `chapter_02_boss_weapon_collected`, `chapter_02_completed`, `royal_chapel_passage_opened`, `chapter_03_started`.
- Boss death presentation: about 3.70 seconds; mirror reveal: 2.20 seconds; door open: 1.10 seconds; fade out/in: 0.50/0.50 seconds.
- Dialogue: `夜巡守卫：你认识我？` → `瑟芙琳：不……但殿下一直在等你。` → `瑟芙琳：穿过镜后的礼门。` → `瑟芙琳：十三声忏悔，会替她回答。`.

### Commands and actual results

1. Exact import: `/Users/vincentz/Downloads/Godot.app/Contents/MacOS/Godot --headless --editor --path . --import --quit` — exit 0 on `4.7.1.stable.official.a13da4feb`; no parser, missing-resource, invalid-UID or import error.
2. Focused contracts:
   - `test_chapter_start_foundation.gd`: PASS — seven Registry entries, Chapters I/II/III-entry ready and MainBootstrap preserved.
   - `test_hollow_duchess_main_integration.gd`: `PASS boss=1 doors=2 cp05=1 hud=1 mirror=1 reward_anchor=1`.
   - `test_chapter_02_to_03_transition.gd`: `PASS dialogue=4 mirror=1 reward_gate=1 reload=1 passage=1 chapter3=1`.
   - `test_silent_court_graybox.gd`: `PASS rooms=9 floors=3 spawns=11 encounters=15 enemies=38 player=1 hud=1`.
   - `test_chapter_02_three_floor_route.gd`: `PASS runs=3 softlocks=0` after three real-physics/Input Map traversals.
3. Full deterministic regression: root suite 22/22 plus chapter suite 27/27; `FULL_SUITE tests=49 failed=0`. This includes Chapter I gameplay, all Player systems, Chapter II enemies, seven Boss attack loops and five complete Boss simulations.
4. Graphical MainBootstrap flow: `Godot --path . --script res://chapters/chapter_02_silent_court/scripts/tools/capture_chapter_02_to_03_qa.gd` — exit 0 on GL Compatibility / Apple M4; `CH2_TO_CH3_MAIN_QA: PASS captures=6 bootstrap=1 mirror=1 passage=1 chapter3=1`.
5. Visual evidence and SHA-256 ledger: `docs/qa/chapter_02_to_03_transition/chapter_02_to_03_transition_qa_report.md`. Six real 1280×720 frames cover Boss death, dialogue, thirteen cracks, secret door, processional passage and Chapter III vestibule.
6. Isolated staged tree `/tmp/nocturne_ch2_transition.gEYf1c`: exact-engine import plus Chapter Registry, Hollow Duchess Main composition and full Chapter II→III transition tests all passed without relying on preserved unstaged tuning/resources.
7. Final `git diff --check`: PASS; no user-owned dirty path is included in the milestone diff.

### Scope and manual acceptance

- The final Chapter II Boss weapon is deliberately deferred despite the second attachment. This milestone stops at an honest reward prerequisite placeholder, as required by the first attachment and the project's approval gate.
- Human F5 acceptance: enable Chapter II Debug start, select `CH2_BOSS`, press F5, enter the Ballroom, defeat Seraphine, inspect the mirror, first try the door without collecting, then collect the placeholder, press E, traverse the short corridor and press E into the Chapel Vestibule.
- Automation proves the complete route, reload recovery, saved composition and 49 regressions. A human should still judge natural post-Boss pacing, the intended 15–30 second corridor duration and full CH2_START combat pacing.
- Pre-existing user-owned Chapter I/shared tuning, Player/item Resources, old QA image changes and two untracked UID sidecars remain preserved and excluded. No Boss combat value, normal enemy, Chapter II floor, Chapter I, Player value, loot probability or formal Chapter III gameplay was changed.
## 2026-07-27 — Crimson Masque Stilettos milestone preflight

Status: complete — fixed Boss reward, Player/HUD integration, Chapter III profile, automated regression and six-image Main QA passed; human feel review pending

### Goal and scope

- Replace the explicit Chapter II Boss-reward placeholder with the permanent `Crimson Masque Stilettos / 绯幕礼刺` fixed reward, preserving the completed Duchess dialogue, mirror reveal, Royal Chapel Passage and Chapter III entry route.
- Add a typed tier-3 WeaponData contract, original native pixel assets, complete Player SpriteFrames, world pickup, compact acquisition feedback, unique inventory/equipment persistence and the Chapter III debug-start loadout.
- Keep Player movement, attack timing/range, Dash, enemy/Boss tuning, Chapter I weapon values, normal loot probabilities and formal Chapter III gameplay unchanged.

### Read-only audit and planned files

- Work begins on `master` at `82643ea43a7dc7f7763b1063ba44456dad2910da`; F5 remains `res://scenes/bootstrap/main_bootstrap.tscn`, Chapter II Main remains `res://chapters/chapter_02_silent_court/scenes/level/silent_court.tscn`, and the saved reward anchor is `SilentCourt/GameplayWorld/BossArea/Chapter02BossWeaponPickupAnchor`.
- Existing weapon ownership/equipment is centralized in `WeaponInventory` and `EquipmentManager`; combat reads equipped damage only from WeaponData. `PlayerWeaponVisual` currently switches complete SpriteFrames between Veilbound and Ravenfang, and `RunInventoryHud` listens to `weapon_equipped`.
- The Chapter II transition controller currently instantiates `Chapter02BossRewardPlaceholder`, sets only `chapter_02_boss_weapon_collected`, and intentionally does not touch inventory/equipment. The Chapter III Start Profile owns only Veilbound/Ravenfang and equips Ravenfang.
- Planned task-owned work: extend the existing WeaponData/equipment/visual contracts for a third weapon; generate Crimson icons, pickup and all 49 Player frames; replace the placeholder scene/controller contract; update the Chapter III profile; add focused damage, acquisition, reload and Main graphical QA; update weapon/transition documentation.
- Pre-existing user-owned Chapter I/shared tuning resources, `resources/player/player_action_prototype_config.tres`, old QA images and two untracked UID sidecars remain outside this milestone and will not be staged.

### Delivered implementation

- Replaced the neutral reward placeholder with the production `Crimson Masque Stilettos / 绯幕礼刺` WeaponPickup at the existing fixed `Chapter02BossWeaponPickupAnchor`. Collection reuses WeaponInventory/EquipmentManager, remains unique, auto-equips, updates the signal-driven icon/Tier/damage HUD and writes the existing passage prerequisite flag.
- Added the tier-3 WeaponData with exact 14 Normal / 28 Dash values, bilingual description, unique/permanent/unsellable/story-reward metadata and separate inventory/HUD icon plus world pickup references. Veilbound remains 10/20 and Ravenfang remains 12/24.
- Generated 49 original transparent 64×64 Player frames across all 16 existing animations, two 32×32 icons and one 64×64 broken-mask world pickup through Godot Image APIs. The straight Crimson Needle, shorter Masque Fan Blade, porcelain/fan guards and crimson grooves are distinct from both earlier weapon silhouettes. SpriteFrames swapping preserves pivots, feet, FPS, attack windows, Hitboxes and `flip_h` behavior.
- Added the compact acquisition panel, upgraded the shared runtime HUD with a signal-driven weapon icon, and updated Chapter III Debug Start to own all three weapons and equip Crimson Masque without re-awarding it.
- Reload contract now has both branches: defeated/uncollected recreates the weapon at the deterministic anchor; collected never respawns or duplicates it. The existing dialogue, mirror, processional passage and Chapter III entry remain the same MainBootstrap route.

### Exact commands and actual results

1. Asset generation: `/Users/vincentz/Downloads/Godot.app/Contents/MacOS/Godot --headless --path . --script res://chapters/chapter_02_silent_court/scripts/tools/generate_crimson_masque_assets.gd` — `PASS animations=16 frames=49 icons=2 pickup=1`.
2. Exact-engine import/parse: `Godot --headless --editor --path . --import --quit`, followed by `Godot --headless --editor --path . --quit` — exit 0 on `4.7.1.stable.official.a13da4feb`; final run had no parser, missing-resource, invalid-UID or import errors. PNG inspection confirmed RGBA, lossless import and `mipmaps/generate=false`; project filter remains nearest.
3. SpriteFrames build: `Godot --headless --path . --script .../build_crimson_masque_sprite_frames.gd` — `PASS animations=16 frames=49`.
4. Focused weapon contract: `test_crimson_masque_weapon.gd` — `PASS data=1 frames=49 damage=14/28 dedup=1 profile=1`; additionally verifies three-weapon switching, left/right flip without combat-anchor change, source-art differentiation and Chapter III ownership/equipment.
5. Full Boss/reload/route contract: `test_chapter_02_to_03_transition.gd` — `PASS dialogue=4 mirror=1 crimson=14/28 reload=2 passage=1 chapter3=1`. Chapter Registry, Hollow Duchess Main composition and Silent Court graybox tests also passed.
6. Graphical F5/MainBootstrap QA: `Godot --path . --script res://chapters/chapter_02_silent_court/scripts/tools/capture_crimson_masque_qa.gd` — GL Compatibility / Apple M4, `PASS captures=6 bootstrap=1 damage=14/28 chapter3=1`. Six 1280×720 frames and hashes are recorded in `docs/qa/crimson_masque_stilettos/crimson_masque_qa_report.md`.
7. Final recursive exact-engine regression after all runtime changes: ordered execution of every `test_*.gd` — `FULL_SUITE tests=50 failed=0`, logs `/tmp/crimson-final-suite.5AI4fu`; no test produced `SCRIPT ERROR`, `ERROR:` or a failed assertion.
8. Final `git diff --check` — PASS.

### Scope and manual acceptance

- No Player speed, reach, action timing, input, Dash behavior, combo/crit/element logic, enemy/Boss tuning, loot table, Chapter I weapon value or formal Chapter III gameplay changed. The Godot Gameplay skill kept weapon data, inventory/equipment, Player presentation, UI and story transition responsibilities separate rather than placing reward state in the Boss script.
- Human F5 route: use Chapter II Debug start `CH2_BOSS`, defeat Seraphine, finish all four lines, inspect the mask-and-paired-stiletto pickup, first verify the door refuses entry, collect with E, confirm the compact panel plus HUD T3 14/28, test J and Dash Attack in both directions, then cross the Processional Passage into Chapter III.
- Art is deterministic project-native 16-bit-inspired production prototype art, not externally sourced concept illustration or final audio/VFX. Save-file persistence remains deferred; current ownership/equipment/story flags persist for the run and chapter transitions.

## 2026-07-27 — Chapter II stair terminals and elevated encounters preflight

Status: in progress — read-only node/spawn audit complete; implementation and Main/F5 evidence pending

### Goal and scope

- Preserve the current three-floor route while turning both floor-change stairs into unmistakable physical endpoints: a short stair, safe landing, closed architectural wall/door, transition trigger, then a stable next-floor vestibule.
- Re-author the existing 38-enemy encounter composition so formal elevated platforms participate in combat, with explicit per-spawn movement bounds and no normal AI pursuit/retreat beyond platform edges.
- Keep Chapter II Boss tuning/reward/Chapter III story, Chapter I, Player movement, ordinary enemy HP/damage and loot probabilities unchanged.

### Read-only audit and planned task-owned files

- Work begins on `master` at `1d39a68af73c654177d3d52966c3b3e6c4ca3042`; F5 remains `res://scenes/bootstrap/main_bootstrap.tscn` and Chapter II Main remains `res://chapters/chapter_02_silent_court/scenes/level/silent_court.tscn`.
- Floor 1 currently overlaps `LastBanquetHall` ground beyond `GrandServiceStair` and its `Floor1ToFloor2` trigger; Floor 2 similarly keeps `ServantPassage` ground outside `ServantSideStair` and `Floor2ToFloor3`. The destinations are `PlayerSpawnPoints/CH2_FLOOR_2_START` and `PlayerSpawnPoints/CH2_FLOOR_3_START`.
- All 38 enemies are presently authored from global coordinates inside `Chapter02EncounterRuntime`; five Ceiling/Air entries exist, but all 33 grounded entries use the three main-floor Y levels. Room-local `EnemySpawnAnchors` exist as untyped `Marker2D` references and are not consumed by the runtime.
- Shared `GroundEnemyBase` already has forward floor/wall RayCasts and patrol-half-width protection. This milestone will add an optional per-instance bounded-platform contract, use typed platform SpawnPoints in the formal encounter runtime, update the two terminal/arrival compositions and add deterministic route/spawn tests plus eight real MainBootstrap screenshots.
- Pre-existing user-owned Chapter I/shared enemy tuning, Player/item Resources, old QA images and two untracked UID sidecars remain outside this milestone and will not be staged or claimed.

## 2026-07-27 — Chapter II stair terminals and elevated encounters completion

Status: complete — closed floor endpoints, formal bounded platform spawns, Main integration, exact-engine regression and eight-image QA delivered; human combat-feel acceptance pending

### Delivered scope

- Preserved the existing three-floor snake route and replaced only its ambiguous endpoints. Floor 1 now ends at `GrandServiceStairTerminal`, a collision-backed royal arch/heavy door/crest/twin-candle composition. Floor 2 ends at the narrower timber `ServantSideStairTerminal` with a side-wing door, crest and lamp.
- Cropped the obsolete `LastBanquetHall` continuation at global `x=6320..7168` and the obsolete `ServantPassage` walkable region at local `x=0..768`. Those regions are no longer hidden walkable floor; terminal walls and Camera bounds physically close the route.
- Added closed arrival vestibules for `CH2_FLOOR_2_START` and `CH2_FLOOR_3_START`. Floor transitions now deactivate every encounter group and clear Chapter II Crossbow/Blood-Candle projectiles before relocation; the existing Player/HUD/Camera are reused.
- Replaced the runtime's duplicated hard-coded spawn table with 38 typed saved `Chapter02EnemySpawnPoint` nodes. Final distribution is 22 Ground, 11 Platform and 5 Ceiling/Air across the existing 15 encounters.
- Added optional per-instance movement bounds to `GroundEnemyBase`. Normal patrol/approach/retreat movement respects the authored platform bounds as well as existing floor/wall raycasts; combat knockback may still push an actor off a platform.
- Reworked the Ballroom Antechamber as three staged groups: E13 provides an elevated Crossbowman, elevated Retainer, ground Halberdier and air Gargoyle; E14 adds elevated Acolyte, ground Armor and delayed ceiling Stalker; E15 places the final ground trio before the Boss threshold. The Boss room itself remains Boss-only.
- Added formal quick spawns `CH2_FLOOR_1_STAIRS`, `CH2_FLOOR_2_STAIRS`, and `CH2_ANTECHAMBER`; the existing `CH2_GALLERY` and `CH2_CHAPEL` selectors remain available.

### Exact commands and actual results

1. Exact import/parse: `/Users/vincentz/Downloads/Godot.app/Contents/MacOS/Godot --headless --editor --path . --import --quit` — exit 0 on `4.7.1.stable.official.a13da4feb`; no parser, import or missing-resource error.
2. New terminal/platform test: `Godot --headless --path . --script res://chapters/chapter_02_silent_court/tests/test_chapter_02_stair_platform_fix.gd` — `PASS transitions=20 ground=22 platform=11 air=5 bounded=11`. Both transitions were requested ten times; all 11 platform actors stayed on floor and within bounds over 240 physics frames.
3. Saved Main contract: `test_silent_court_graybox.gd` — `PASS rooms=9 floors=3 spawns=14 encounters=15 enemies=38 player=1 hud=1`.
4. Floor controller regression: `test_chapter_02_floor_transitions.gd` — `PASS transitions=2 player=1 hud=1`.
5. Three real-physics/Input Map routes: `test_chapter_02_three_floor_route.gd` — all three finished at `(5703.896,-1216.075)` and `PASS runs=3 softlocks=0`.
6. Chapter II enemy/Boss/story regressions: Phase 2 prototypes, Phase 2 damage, Hollow Duchess Main and Chapter II→III transition all passed with existing damage/dialogue/reward contracts unchanged.
7. Full recursive exact-engine regression: every `test_*.gd` — `FULL_SUITE tests=51 failed=0`.
8. Graphical MainBootstrap QA: `Godot --path . --script res://chapters/chapter_02_silent_court/scripts/tools/capture_chapter_02_stair_platform_qa.gd` — GL Compatibility / Apple M4; `PASS captures=8 bootstrap=1 enemies=38 platform=11`. Runtime output contained no script/resource error. Evidence and hashes are in `docs/qa/chapter_02_stair_platform_fix/chapter_02_stair_platform_qa_report.md`.

### Scope and acceptance

- No Boss attack/value, Crimson Masque reward, Chapter II→III story, Chapter I, Player movement, ordinary enemy HP/damage or loot probability was changed. The Godot Gameplay skill guided a typed SpawnPoint composition and bounded movement contract rather than another hard-coded level table.
- Automated checks verify saved height, platform floor contact, movement bounds, finite encounter membership, two 10-run transitions and three complete routes. Shared Phase 2 tests verify attack/hurt/death behavior. Subjective platform reachability, combat fairness, aggressive knockback outcomes and checkpoint replay feel still require human F5 play.
- Manual route: set Debug chapter to `CHAPTER_02_SILENT_COURT`, spawn to `CH2_START`, press F5, follow F1 right through Banquet and the Grand door, follow F2 left through Chapel and the Servant door, then inspect the staged Antechamber before the Boss.
- Pre-existing user-owned Chapter I/shared tuning, Player/item Resources, old QA images and two UID sidecars remain preserved and excluded from this milestone commit.

## 2026-07-27 — Hollow Duchess entrance, unmasked phase and reliquary preflight

Status: in progress — read-only Main/Boss/reward audit complete; implementation and exact-engine verification pending

### Goal and scope

- Make the saved F5 Chapter II Boss route unmistakable and compact: a formal entrance, 5–8 second first-view introduction, 1–1.5 second retry, a 3.5–5.5 second one-shot 55% transformation, genuinely redrawn Unmasked SpriteFrames, Phase 2 defense/damage/cadence changes, and a short post-fight Duchess’s Reliquary route.
- Preserve the existing three-floor route, normal enemies, Chapter I, Player movement, Ravenfang values, Crimson Masque 14/28 values, loot/coin systems and the Chapter III destination scenes.

### Read-only audit and planned task-owned files

- Work begins on `master` at `cdd6b358c80ee0cc6f1df7469b815afe2839ac5c`; F5 resolves through `res://scenes/bootstrap/main_bootstrap.tscn` to `res://chapters/chapter_02_silent_court/scenes/level/silent_court.tscn` for the Chapter II Debug route.
- Saved Main paths are `SilentCourt/GameplayWorld/Geometry/Rooms/SilentBallroomAntechamber`, `SilentCourt/GameplayWorld/Geometry/Rooms/SilentBallroom`, `SilentCourt/GameplayWorld/BossArea/HollowDuchess`, `SilentCourt/GameplayWorld/BossArea/BossActivationArea`, `SilentCourt/ChapterSystems/HollowDuchessRoomController` and `SilentCourt/ChapterSystems/Chapter02To03TransitionController`.
- Current CP05 is global `x=2500`, activation is `x=3100` (600 px), while Seraphine is at `x=6000`; the saved Ballroom is 4480 px wide and the Boss config spans 4140 px (`-3020..+1120`). The encounter therefore reads as a long corridor even though the trigger itself is near CP05.
- The current intro only emits `你果然回来了。`; no saved entrance presentation or AnimationPlayer owns the required five-line exchange. Phase transition is 1.22 seconds, only draws cracks into the Phase 1 frame, and never switches SpriteFrames. Phase 2 has no damage reduction, remains at 60 Poise and reuses Phase 1 damage values.
- The existing Chapter II→III controller spawns Crimson Masque at `Chapter02BossWeaponPickupAnchor` and begins mirror reveal immediately on Boss defeat. Reload restores that floor pickup and already-revealed mirror. The new flow must instead unlock a saved reliquary, preserve an uncollected displayed weapon, and reveal/enable the mirror only after collection.
- Planned task-owned files include the Hollow Duchess config/runtime/room/transition scripts and tests, Silent Ballroom/Main saved composition, a narrow Boss hit policy, a composed entrance presentation, a composed reliquary, deterministic Godot Image generators/builders for Phase 2, focused Main/reload/phase tests, ten MainBootstrap screenshots, and Boss/transition/design documentation.
- Pre-existing user-owned Chapter I/shared tuning, Player/item Resources, old QA images and two untracked UID sidecars are unrelated. They will remain untouched and excluded from staging.

## 2026-07-27 — Hollow Duchess entrance, Unmasked phase and reliquary completion

Status: complete — saved MainBootstrap route, original Phase 2 pixel art/audio, phase contracts, reliquary reward flow, 52-test regression and ten-frame graphical QA passed; human feel/audio-level acceptance pending

### Delivered scope

- Added the collision-backed `DuchessBossEntrance` at x=3100 with monumental black-red split doors, oxidized-gold framing, cracked porcelain crest, two faceless statues, sequential candles, carpet and bilingual “The final waltz admits no absence. / 最后一支舞，不容缺席。” inscription. CP05 remains at x=2500, all ordinary E15 actors end by x=2300, and the intro trigger is x=3800.
- Reframed the old misleading 600 px trigger plus 2900 px hidden Boss leg into a 1300 px CP05→trigger route (1.02 design viewports, approximately 5.9 seconds at 220 px/s) with a visible door halfway through. Reduced the Ballroom saved width from 4480 to 3712 px; its collision-backed fight floor is 2770 px or 2.16 viewports.
- Added a saved `DuchessEncounterPresentation/AnimationPlayer` with `intro_full` 6.40 s, `intro_retry` 1.25 s and `phase_transition_full` 4.40 s. First entry locks Player, frames both actors, lights candles, shows phantom dancers, plays an original project-generated broken waltz and emits the exact five-line exchange plus title. Retry shows only the shortened title route.
- Built a separate looping `AudioStreamWAV` Resource at `assets/boss/hollow_duchess/audio/broken_waltz_intro.tres`; it is generated from deterministic project code, uses no downloaded/source-unknown asset and stops when Phase Transition starts. Chapter II currently has no ambient BGM source to duck.
- Rebuilt Phase 2 as 100 original transparent source frames across all 20 saved animation names, plus five named transition stages. Runtime uses the Phase 1 SpriteFrames until the one-shot 55% transition, then swaps to `hollow_duchess_unmasked_sprite_frames.tres`; it does not use a red modulate/shader substitute.
- Phase 2 keeps current HP, changes incoming damage to 0.85, Poise 60→80, stagger 0.56→0.48 s, protection 2.50→3.00 s and attack gap 0.84–1.02→0.82–1.02 s. Runtime attack values are Rapier 13, Fan 16, Riposte/Side 14, Double 10/14, Phantom 12 and Final Waltz 10 per pass; Phase 1 remains 11/13/12/12.
- Replaced the corpse-side floor reward with the saved `DuchessReliquary` at x=5550. It unlocks only after death presentation and sits 850 px (0.66 viewport, approximately 3.9 seconds) from the Boss saved start. The saved crossed-stiletto display owns the visible weapon; E collection reuses the existing unique Tier 3 14/28 pickup contract, empties the cabinet, reveals the thirteen-crack mirror and unlocks the Royal Chapel Passage. Defeated/uncollected and collected reload branches both passed.

### Exact commands and actual results

1. Audio generation: `/Users/vincentz/Downloads/Godot.app/Contents/MacOS/Godot --headless --path . --script res://chapters/chapter_02_silent_court/scripts/tools/generate_duchess_broken_waltz.gd` — `DUCHESS_BROKEN_WALTZ: PASS samples=145530`.
2. Exact import/parse: `/Users/vincentz/Downloads/Godot.app/Contents/MacOS/Godot --headless --editor --path . --import --quit` — exit 0 on `4.7.1.stable.official.a13da4feb`; no parser, import, UID or missing-resource error.
3. Presentation/phase contract: `Godot --headless --path . --script res://chapters/chapter_02_silent_court/tests/test_hollow_duchess_presentation_phase.gd` — `PASS intro=5 transition=10 phase2=0.85/80`. It verifies the looping AudioStreamWAV, five intro plays with only one full five-line dialogue, ten one-shot transitions, no HP restore, SpriteFrames swap and all Phase 2 damage values.
4. Saved Main composition: `test_hollow_duchess_main_integration.gd` — `PASS boss=1 entrance=1 presentation=1 cp05=1 hud=1 reliquary=1 mirror=1`.
5. Reward/reload/passage: `test_chapter_02_to_03_transition.gd` — `PASS dialogue=4 reliquary=1 mirror_after_reward=1 crimson=14/28 reload=2 passage=1 chapter3=1`.
6. Full recursive exact-engine regression: a sorted loop over every repository `test_*.gd` using `Godot --headless --path . --script res://<test>` — `FULL_SUITE tests=52 failed=0`. This includes three complete physics/Input Map Chapter II routes, all Player/combat systems, Boss attack loops, five full Boss simulations, chapter transitions and Chapter I regressions.
7. Graphical MainBootstrap QA: `/Users/vincentz/Downloads/Godot.app/Contents/MacOS/Godot --path . --script res://chapters/chapter_02_silent_court/scripts/tests/capture_hollow_duchess_qa.gd` — GL Compatibility / Apple M4; `HOLLOW_DUCHESS_MAIN_QA: PASS captures=10 entrance=1 intro=1 phase2=1 reliquary=1 main=res://chapters/chapter_02_silent_court/scenes/level/silent_court.tscn`. Runtime output contained no `SCRIPT ERROR`, missing resource or red Godot error. SHA-256 evidence ledger: `docs/qa/chapter_02_hollow_duchess/hollow_duchess_entrance_phase_reliquary_qa_report.md`.
8. Isolated staged-tree verification: archived tree `645c056b68b483d6cbbeed681706685c159c8bfd` to `/var/folders/ps/tqqkgqfd0k752pz37ddxwybh0000gn/T/tmp.x9jJpTNc1j`; exact import exited 0, and presentation/phase, saved Main composition and Chapter II→III transition tests all passed with `tests_failed=0`. This proves the milestone without the preserved unstaged Chapter I/shared/Player tuning changes.

### Defects found and corrected during verification

- Initial route regression exposed that shortening the Boss-room right wall globally also removed necessary floor bounds on earlier floors. Restoring the saved world wall to x=7200 returned all three full routes to `softlocks=0` without widening the actual Ballroom collision floor.
- The first Phase 2 evidence capture proved runtime state but left Seraphine at the camera edge. The Main QA driver now waits for Phase 2 `Idle`, reframes the real saved Boss and captures a readable Unmasked silhouette; Gameplay timing is unchanged.
- The first reliquary placement was 1150 px/0.90 viewport from the Boss saved start. It was moved to x=5550 and retested at 850 px/0.66 viewport, satisfying the requested 0.3–0.7 viewport and 3–8 second post-fight route.

### Scope, known issues and manual acceptance

- No Chapter II normal enemy, three-floor route, Chapter I file, Player movement/value, Ravenfang/Crimson value, loot probability, coin system or Chapter III formal map was changed. Pre-existing unrelated dirty files remain preserved and excluded from this milestone commit.
- The original broken waltz is a functional low-fidelity prototype. Human acceptance is still required for loudness/musical feel, camera framing, entrance pacing, Phase 2 telegraph readability and the 3.9-second reliquary walk. Chapter II has no separate ordinary-area BGM source, so proximity ducking could not truthfully be implemented in this milestone.
- F5 acceptance: set Debug chapter `CHAPTER_02_SILENT_COURT`, spawn `CH2_BOSS`, press F5, start at CP05, enter the visible door, cross the short threshold, view Phase 1, reach 121/220 HP, view the 4.40-second transformation, defeat Unmasked Seraphine, walk right to the reliquary, press E for Crimson Masque and use the revealed Royal Chapel Passage. Stop after the existing Chapter III entry placeholder; no Chapter III gameplay was added.

## 2026-07-28 — Chapter II Stage A layering, reliquary and transition-performance preflight

Status: in progress — read-only Main audit complete; implementation, exact-engine verification and graphical QA pending

### Goal and strict scope

- Stage A only: correct Chapter II actor/environment drawing order, rebuild the Duchess's Reliquary as a compact interactive medieval pedestal with animated candle flames, and remove measured transition/Boss-area frame-time waste.
- Integrate every change into the saved F5 Main route and preserve both `CH2_START` and `CH2_BOSS` Debug entry paths. Produce at least eight real MainBootstrap QA captures and measured before/after transition results.
- Stop after the Stage A report. Do not begin the requested Stage B environment-polish pass without a separate approval.

### Read-only audit and planned task-owned files

- Work begins on `master` at `9d36ff919b09449458134149ccfbdebd6346ba5c`. `project.godot` resolves F5 through `res://scenes/bootstrap/main_bootstrap.tscn`; the Chapter II Main scene is `res://chapters/chapter_02_silent_court/scenes/level/silent_court.tscn`.
- The runtime Player path is `SilentCourt/GameplayWorld/PlayerAnchorOrRuntimeActors/ChapterRuntime/Player`; Chapter II forces it to absolute `z_index=12`. The saved `BossArea` is absolute `z_index=10`, but both `DuchessBossEntrance` (`z_index=14`, relative) and `DuchessReliquary` (`z_index=12`, relative) inherit that parent layer, producing effective layers 24 and 22 in front of the Player. No Main-level YSort or erroneous CanvasLayer is involved.
- The stable saved layer contract is background `-100..-30`, behind-actor props `-10`, enemies `10`, Player `12`, pickups `14`, effects `16`, thin front ground edge `20`, intentional front props `25`, foreground `30`, and HUD CanvasLayers. The Boss entrance and reliquary must become absolute behind-actor world props while interaction prompts remain above actors.
- The current `DuchessReliquary` is a 352×276 custom-drawn cabinet and the `ReliquaryWeaponDisplay` renders two long lines, causing the oversized cabinet/metal-rod result in the supplied screenshots. Planned files are the saved reliquary scene/script, its weapon display, a composed candle-flame presenter, the Chapter II→III transition controller, the generic pickup's narrowly scoped external-interaction switch, focused saved-Main/reload tests, and Stage A QA tooling/evidence.
- The most concrete persistent performance defect is `HollowDuchessBallroomFx`: it redraws a roughly 3712×792 custom canvas every rendered frame from Chapter II startup even while the Ballroom is off-screen. It will be visibility-gated and updated at a bounded visual cadence. Chapter II room/floor transitions reuse one loaded scene and Player; the Chapter II→passage→Chapter III route still uses synchronous `change_scene_to_file`, so the transition service and Chapter II passage flow will be audited for safe threaded preload under the existing fade.
- Planned verification: a real graphical frame-time benchmark covering both floor transitions, Boss entrance/intro, Phase transition, reliquary interaction and Chapter II→III passage; exact import/parse; focused layering/reward/performance tests; full recursive regression; and an eight-frame MainBootstrap evidence set.
- Pre-existing Chapter I/shared enemy tuning, Player/item Resources, old QA images and two untracked UID sidecars remain user-owned and outside this task. They will be preserved and excluded from staging.

## 2026-07-28 — Chapter II Stage A layering, reliquary and transition-performance completion

Status: complete — saved Main layering/reliquary flow, measured transition optimization, 52-test regression and ten-frame MainBootstrap QA passed; Stage B has not started

### Delivered scope

- Corrected the two proven composition defects rather than changing Player rendering globally: `DuchessBossEntrance` and `DuchessReliquary` are now absolute world `z_index=8`, behind the absolute Player `z_index=12`. Their text/prompt overlays are absolute `z_index=20`. Chapter II keeps its explicit background/enemy/player/pickup/effect/front-prop layer contract and continues to use no Main-level YSort.
- Rebuilt `DuchessReliquary` from a 352×276 museum cabinet into a compact stone/dark-oak medieval pedestal with an oxidized-gold backplate, normal-size crossed Crimson Masque stilettos and small side candles. Each stiletto now has a pommel, grip, guard, tapered blade, point and center ridge instead of one long line.
- Added `InteractionArea` with a 112 px radius, `InteractionPrompt` with `按 E 拾取 绯幕礼刺 / PRESS E TO TAKE CRIMSON MASQUE`, and a typed `pickup_requested` signal. The hidden fixed WeaponPickup remains the inventory/equipment source but has its duplicate Area/input path disabled. E collection clears the saved display/prompt, preserves 14/28 equipment/HUD behavior and only then reveals the mirror. Defeated/uncollected and collected reload branches both passed.
- Added two restrained three-frame pixel flames controlled by a 0.12-second Timer. This creates visibly different saved QA frames without adding a decorative per-frame process.
- Added `BallroomFx/VisibilityNotifier`: the 3712×792 custom Ballroom canvas now stops processing off-screen and visible animation redraws are capped at 12 Hz. After Boss defeat, the fifteen inactive ordinary encounter groups are released over successive frames.
- Extended `SceneTransitionManager` with threaded PackedScene preparation. Chapter II requests the Royal Chapel Passage at level initialization; the Passage requests Chapter III during its safe traversal. Prepared scene instantiation measured 0.339 ms. At blackout the retired scene is hidden, input/physics/audio-disabled immediately and released leaf-first in batches of 18 nodes instead of one full-tree destruction frame.

### Exact commands and actual results

1. Modification-before baseline: `/Users/vincentz/Downloads/Godot.app/Contents/MacOS/Godot --path . --script res://chapters/chapter_02_silent_court/scripts/tests/benchmark_chapter_02_stage_a.gd` — the original synchronous scene retirement measured 39.014 ms for Chapter II→Passage and 22.318 ms for Passage→Chapter III; floor switches, Phase transition and reliquary flow were below 18 ms.
2. Exact import/parse: `/Users/vincentz/Downloads/Godot.app/Contents/MacOS/Godot --headless --editor --path . --import --quit` — exit 0 on `4.7.1.stable.official.a13da4feb`; no parser, import, autoload or missing-resource error after correcting the Godot 4.7 enum name to `THREAD_LOAD_INVALID_RESOURCE`.
3. Saved Main composition/layer/proximity test: `Godot --headless --path . --script res://chapters/chapter_02_silent_court/tests/test_hollow_duchess_main_integration.gd` — `PASS boss=1 layers=1 entrance=1 presentation=1 cp05=1 hud=1 reliquary=1 candles=1 proximity=112 mirror=1`.
4. Reward/reload/passage test: `test_chapter_02_to_03_transition.gd` — `PASS dialogue=4 reliquary=1 mirror_after_reward=1 crimson=14/28 reload=2 passage=1 chapter3=1`. It collects through the reliquary signal and exercises both threaded prepared transitions.
5. Floor regression: `test_chapter_02_floor_transitions.gd` — `PASS transitions=2 player=1 hud=1`.
6. Full recursive exact-engine regression: sorted execution of every repository `test_*.gd` in an independent Godot process — `FULL_SUITE tests=52 failed=0`; the log was also scanned for `SCRIPT ERROR`, `Parse Error` and failed assertions.
7. Final graphical frame-time probe: `Godot --path . --script res://chapters/chapter_02_silent_court/scripts/tests/benchmark_chapter_02_stage_a.gd` — Chapter II→Passage max 13.082 ms, Passage→Chapter III max 10.952 ms, Phase transition max 12.767 ms, Boss death→reliquary max 12.023 ms and mirror max 7.876 ms. No transition boundary produced a >25 ms frame. One non-repeatable 31.285 ms sample occurred inside the long 600-frame Boss-intro observation window; intro p95 was 12.287 ms and the earlier baseline intro max was 13.368 ms, so human F5 feel remains an explicit acceptance item rather than a false deterministic claim.
8. Graphical MainBootstrap QA: `Godot --path . --script res://chapters/chapter_02_silent_court/scripts/tests/capture_chapter_02_stage_a_qa.gd` — `PASS captures=10 layers=1 transitions=2 proximity=112 candle_frames=2 collected=1`. All files are 1280×720 and hashes are recorded in `docs/qa/chapter_02_stage_a/chapter_02_stage_a_qa_report.md`.
9. Formal F5 bootstrap smoke: `Godot --path . --quit-after 240` — exit 0, `MAIN BOOTSTRAP | FORMAL NEW GAME | res://scenes/cinematics/opening_cinematic.tscn`; no runtime `ERROR`, `SCRIPT ERROR` or Debugger failure.
10. Isolated staged-tree verification: archived tree `db1f23bf266223e4fbf04859a7472beda024617c` to `/var/folders/ps/tqqkgqfd0k752pz37ddxwybh0000gn/T/tmp.tX7iJexMsw`; exact import exited 0 and saved Main, reward/reload/passage, and both floor-transition tests all passed (`tests=3 failed=0`). This proves Stage A without the preserved unstaged Chapter I/shared/Player tuning changes.

### Scope, diagnostics and manual acceptance

- No Stage B environment polish was started. No Chapter I/III gameplay, Player movement/value, Chapter II enemy value, Boss story/value, Crimson Masque 14/28 value, loot probability or three-floor route was changed.
- Graphical QA scripts call `SceneTree.quit()` and Godot 4.7.1 prints generated GL texture/RID teardown diagnostics after their PASS line. The formal F5 smoke and every runtime test assertion had no script/resource error; the harness-only shutdown diagnostics remain documented rather than misreported as gameplay errors.
- Boss quick acceptance: set `debug_start_chapter_id = CHAPTER_02_SILENT_COURT`, `debug_start_spawn_id = CH2_BOSS`, press F5, walk right from CP05, stand against the opening door to verify the Player is in front, defeat Seraphine, walk to x=5550, approach the small pedestal, observe two flame poses, press E, then use the revealed mirror passage.
- Full-route acceptance: use `CH2_START`, press F5, verify Floor 1→2 and Floor 2→3 fades/landings, then continue through entrance, Intro, Phase 2, reliquary and Passage. Subjective transition feel, the one observed non-repeatable intro outlier and the preferred pedestal scale remain human-playtest items.
- Pre-existing user-owned Chapter I/shared tuning, Player/item Resources, old QA images and two UID sidecars remain preserved and excluded from this commit.

## 2026-07-28 — Chapter II formal environment assets and Boss threshold preflight

Status: in progress — saved Main/room/Boss-entry audit complete; asset generation, integration, profiling and graphical acceptance pending

### Goal and strict scope

- Replace the proven Chapter II room placeholders with original, reusable pixel assets before scene integration: formal Crimson Masque crossed-stiletto displays, six inhabited royal portraits, distinct armory/chapel/ballroom doors and arches, candle fixtures and castle furniture/decoration.
- Apply those assets to the saved F5 Main route in Old Armory Safe Room, Last Banquet Hall, Royal Portrait Gallery, Blood Candle Chapel, Silent Ballroom Antechamber and the Silent Ballroom threshold without changing Player/enemy/Boss balance, room collisions or Chapter III gameplay.
- Replace the current walk-through Boss threshold with a short fade-out, collision-safe relocation to the saved Ballroom entry, fade-in and the existing five-line first-entry presentation. Preserve the shortened retry presentation.
- Measure the existing floor/room/Boss/phase/reward/chapter-boundary frame-time probes before and after the art integration, then capture at least twelve real MainBootstrap frames and run exact-engine regression before one focused commit.

### Read-only audit and planned task-owned files

- Work begins on `master` at `771ccf81c59f2d8b8ad7d1371bda6b35ce683ea8`; the branch is nine commits ahead of `origin/master`. Pre-existing unstaged Chapter I/shared enemy tuning, Player/item Resources, old QA images and two untracked UID sidecars remain user-owned and outside this task.
- `project.godot` resolves F5 through `res://scenes/bootstrap/main_bootstrap.tscn`; Chapter II resolves to `res://chapters/chapter_02_silent_court/scenes/level/silent_court.tscn`.
- The six saved room scenes are `old_armory_safe_room.tscn`, `last_banquet_hall.tscn`, `royal_portrait_gallery.tscn`, `blood_candle_chapel.tscn`, `silent_ballroom_antechamber.tscn` and `silent_ballroom.tscn` under `chapters/chapter_02_silent_court/scenes/rooms/`.
- The supplied Main frames match the saved implementation: every audited room still exposes empty `BackgroundPlaceholder` and `PropsPlaceholder` nodes. `chapter_02_room_graybox.gd` draws Armory weapons as two five-pixel lines, Gallery portraits as empty rectangles, Chapel architecture/candles as arcs and vertical lines, Banquet furniture as rectangles and Antechamber identity as plain banners. There are no Chapter II portrait PNGs and no reusable room-door/arch/candlestick asset set.
- The current Boss threshold is `SilentCourt/GameplayWorld/BossArea/DuchessBossEntrance`; its `ApproachArea` only tweens `door_open_progress` and disables `DoorBlocker`. The later `BossActivationArea` independently starts `HollowDuchessRoomController`, so walking through the opening can reach combat without a black-screen relocation. The existing `DuchessEncounterPresentation` already owns the required full five-line/short retry presentation and will be reused rather than duplicated.
- Planned task-owned files include a deterministic Godot Image asset generator, generated PNGs under Chapter II `assets/environment`, `assets/props`, `assets/portraits`, `assets/doors`, `assets/weapons` and `assets/fx`, saved room Sprite2D compositions, a typed Boss-threshold transition controller, narrowly adjusted entrance/room-controller APIs, focused tests, graphical QA tooling/evidence and Chapter II environment/Boss documentation.
- Verification baseline and completion commands use `/Users/vincentz/Downloads/Godot.app/Contents/MacOS/Godot` 4.7.1: exact import/parse, the Chapter II Stage A frame-time benchmark, focused saved-Main/Boss/route tests, full recursive `test_*.gd` regression, formal bootstrap smoke and at least twelve MainBootstrap screenshots covering all requested rooms and Boss entry phases.

## 2026-07-28 — Chapter II formal castle assets, performance and Boss threshold completion

Status: complete — saved Main art replacement, transition profiling, formal Boss entry, exact-engine regression and 18-image QA delivered; human visual/feel acceptance pending

### Delivered scope

- Added a deterministic Godot `Image` generator and 35 original pixel PNGs: four distinct Crimson Masque stiletto presentations, six inhabited royal portraits, five doors/arches, two architectural modules, fifteen furniture/armour/fixture props and three candle-flame frames. The Armory uses `world_display`, the Duchess reliquary uses `pedestal_display`, the story pickup uses `pickup_icon`, and `WeaponData` uses `inventory_icon_formal` (with the compact pickup art as its HUD icon). No external asset, online generator or uncertain license source was used.
- Replaced the six audited room identities in their saved `.tscn` files. Old Armory now contains readable stilettos/racks/armour; Banquet contains tables, benches and remnants; Gallery has people rather than empty panels; Chapel uses full masonry doors/arches and an altar rather than line arcs; Antechamber and Ballroom now have coherent pillars, drapes, crests and candle fixtures.
- Retained the existing room geometry, three-floor route, enemy placement and combat values. `chapter_02_room_graybox.gd` now exposes an explicit legacy fallback, while all six formal saved rooms disable it.
- Added the reusable `Chapter02WallSconce`; its flames advance from a Timer and pause off-screen rather than creating a decorative per-frame workload.
- Replaced the walk-through Boss placeholder with `DuchessBossThresholdTransition`: 0.24 s fade-out, 0.10 s fully black collision-safe relocation, 0.24 s fade-in, existing five-line first-entry dialogue, bilingual title and then combat. It locks Player input/velocity/facing, applies temporary invulnerability and reconfigures/reset the existing Camera before revealing the room.
- Reused the existing `DuchessEncounterPresentation` and `intro_seen` contract. First entry remains 6.4 seconds/five lines; death retry remains the shortened 1.25-second presentation. No duplicate Player, HUD, Camera or dialogue controller was created.
- Corrected the interior staging after visual review: the exterior door/armour group hides after opening, the arrival no longer overlaps a foreground pillar, and the 0.82 intro framing shows Player and Seraphine before returning to the saved combat zoom.

### Performance audit and actual measurements

- Pre-modification Stage A benchmark: Floor 1→2 max 17.545 ms, Floor 2→3 max 16.626 ms, Boss intro max 19.097 ms, Phase max 17.118 ms, Boss death→reliquary max 17.703 ms, reliquary→mirror max 18.038 ms, Chapter II→Passage max 11.528 ms and Passage→Chapter III max 11.855 ms; every segment had zero frames over 25 ms.
- Post-integration benchmark command: `/Users/vincentz/Downloads/Godot.app/Contents/MacOS/Godot --path . --script res://chapters/chapter_02_silent_court/scripts/tests/benchmark_chapter_02_stage_a.gd` — `PASS`. Floor 1→2 max 13.365 ms, Floor 2→3 max 12.342 ms, Boss intro max 13.735 ms, Phase max 18.757 ms, Boss death→reliquary max 14.142 ms, reliquary→mirror max 13.566 ms, Chapter II→Passage max 13.439 ms and Passage→Chapter III max 13.475 ms. Every segment again had zero frames over 25 ms.
- The result does not prove universal hardware performance, but it rejects the suspected synchronous import/scene-instantiation spike on the tested Apple M4 GL Compatibility path. Assets are pre-imported and saved in the Chapter scene; floor transitions still reuse the same Player/HUD/Camera and do not load room files at the transition boundary.

### Exact commands and actual results

1. Asset generator: `Godot --headless --path . --script res://chapters/chapter_02_silent_court/scripts/tools/generate_chapter_02_castle_assets.gd` — `PASS files=35`.
2. Exact import/parse: `/Users/vincentz/Downloads/Godot.app/Contents/MacOS/Godot --headless --editor --path . --import --quit` — exit 0 on `4.7.1.stable.official.a13da4feb`; no parser, import or missing-resource error.
3. New saved-art/threshold contract: `test_chapter_02_formal_environment.gd` — `PASS assets=16 portraits=6 weapon_contexts=4 rooms=6 threshold=fade/relocate/intro`.
4. Saved Boss/Main integration: `test_hollow_duchess_main_integration.gd` — `PASS boss=1 layers=1 entrance=1 presentation=1 cp05=1 hud=1 reliquary=1 candles=1 proximity=112 mirror=1`.
5. Presentation timing: `test_hollow_duchess_presentation_phase.gd` — `PASS intro=5 transition=10 phase2=0.85/80`.
6. Three-floor real-physics route: `test_chapter_02_three_floor_route.gd` — `PASS runs=3 softlocks=0` after disabling only the Boss threshold inside this route-only test.
7. Full recursive exact-engine regression: sorted independent execution of every repository `test_*.gd` — `FULL_SUITE tests=53 failed=0`.
8. MainBootstrap graphical QA: `Godot --path . --script res://chapters/chapter_02_silent_court/scripts/tests/capture_chapter_02_castle_qa.gd` — `PASS captures=19 rooms=6 threshold=fade/relocate/dialogue/title/combat reliquary=1 transitions=2`. Evidence/hashes are in `docs/qa/chapter_02_castle_polish/chapter_02_castle_polish_qa_report.md`.
9. Formal F5-equivalent bootstrap smoke: `Godot --path . --quit-after 240` — exit 0, `MAIN BOOTSTRAP | FORMAL NEW GAME | res://scenes/cinematics/opening_cinematic.tscn`; no runtime, script or resource error.

### Diagnostics, scope and manual acceptance

- The graphical QA and benchmark intentionally call `SceneTree.quit()`; Godot 4.7.1 reports GL texture/RID/ObjectDB teardown diagnostics after each PASS. The formal F5 smoke exits cleanly without them. No script, parse, missing-resource, assertion or Debugger error occurred during runtime verification.
- No Player/enemy/Boss combat value, room collision, chapter route, reward value, Chapter I or Chapter III gameplay was changed. The Godot Gameplay skill guided typed signal/controller separation and saved Sprite2D composition rather than placing transition control inside the Boss AI.
- Full-route manual test: choose `CHAPTER_02_SILENT_COURT` + `CH2_START`, press F5, inspect Armory/Banquet on Floor 1, Gallery/Chapel on Floor 2, then Antechamber/Ballroom on Floor 3. Boss-only manual test: choose `CH2_BOSS`, press F5, walk right into the large double door, verify fade/black relocation/fade-in, five dialogue lines, title and combat; die once to check the shortened retry.
- Human acceptance still owns subjective portrait polish, prop density, candle atmosphere, Boss entrance pacing and real combat readability. Pre-existing user-owned Chapter I/shared tuning, Player/item Resources, old QA images and two UID sidecars remain preserved and excluded from this milestone.

## 2026-07-28 — Mandatory chapter-scene workflow policy preflight

Status: in progress — repository governance audit complete; policy documentation and verification pending

### Goal, files, tests and scope check

- Make the chapter-scene quality contract mandatory for every future Chapter III–VI scene milestone and any formal Chapter I/II rework: story/theme audit first, formal chapter-owned pixel assets before formal scene assembly, environmental storytelling, saved Main/F5 integration and visual/technical QA before completion.
- Add the enforceable source of truth at `docs/design/chapter_scene_workflow_spec.md`, bind it from root `AGENTS.md`, and expose it from `README.md`. This log is the only other task-owned file.
- Formal completion must fail when a scene remains visibly graybox, uses geometric stand-ins as final art, lacks chapter identity or narrative function, is absent from the saved Main route, or lacks preserved QA evidence. Explicit prototype milestones may still use labeled graybox scenes, but they cannot be reported as formal environment completion.
- This governance milestone changes documentation only. It does not modify `.gd`, `.tscn`, `.tres`, `project.godot`, runtime balance, Chapter I/II content, Chapter III gameplay or generated assets.
- Planned verification uses the exact Godot 4.7.1 executable at `/Users/vincentz/Downloads/Godot.app/Contents/MacOS/Godot`: documentation diff/whitespace validation, headless import/parse and an F5-equivalent bootstrap smoke. No gameplay assertion is replaced by a documentation claim.
- Work starts on `master` at `7f8e7d7d41489d1b124157334bc2beba7a952042`. Pre-existing Chapter I/shared/Player tuning changes, QA image edits and two untracked UID sidecars remain user-owned and outside this policy commit.

## 2026-07-28 — Mandatory chapter-scene workflow policy completion

Status: complete — six mandatory gates, chapter asset ownership, Main/F5 acceptance and fixed reporting contract are now repository policy

### Delivered policy

- Added `docs/design/chapter_scene_workflow_spec.md` as the authoritative workflow for Chapter III–VI and formal Chapter I/II rework. It defines the chapter audit, asset-first, formal scene assembly, environmental narrative, Main integration and QA gates, plus explicit failure conditions that prevent graybox-quality work from being reported as complete.
- Bound the policy from root `AGENTS.md`, including the rule that geometric stand-ins are allowed only inside explicitly labeled prototype/graybox milestones and never satisfy formal environment acceptance.
- Standardized chapter-local ownership for environment, prop, door, portrait, weapon, pickup, FX and UI assets; shared reuse requires an explicit provenance/adaptation note.
- Added an environment narrative matrix, combat-readability requirements, QA evidence contract and the exact `Chapter X 场景开发报告` headings. Every report must answer how the user can press F5, enter Main and assess the chapter's scene quality.
- Linked the mandatory policy from `README.md`. No gameplay scene, script, Resource, asset, project setting, routing or balance value was changed.

### Exact commands and actual results

1. Documentation validation: `git diff --check -- AGENTS.md README.md docs/development_log.md docs/design/chapter_scene_workflow_spec.md` — exit 0; no whitespace error.
2. Exact import/parse: `/Users/vincentz/Downloads/Godot.app/Contents/MacOS/Godot --headless --editor --path . --import --quit` — exit 0 on `4.7.1.stable.official.a13da4feb`; no parser, import, autoload or missing-resource error.
3. F5-equivalent Main bootstrap smoke: `/Users/vincentz/Downloads/Godot.app/Contents/MacOS/Godot --path . --quit-after 240` — exit 0; `MAIN BOOTSTRAP | FORMAL NEW GAME | res://scenes/cinematics/opening_cinematic.tscn`; no runtime, script or resource error.

### Scope and future acceptance

- This milestone deliberately contains documentation/governance changes only; no visual asset was generated and no chapter content was altered. Full gameplay regression was not repeated because the runtime tree is unchanged; exact import and formal Main startup verify that policy files did not disturb project loading.
- The policy does not auto-authorize Chapter III or any rework. Each new chapter still requires explicit approval and a separate milestone with audit, asset creation, saved Main integration, exact-engine verification and human visual acceptance.
- Pre-existing user-owned Chapter I/shared/Player tuning changes, QA image edits and two UID sidecars remain preserved and excluded from this policy commit.

## 2026-07-28 — Chapter III normal enemies Phase 0 preflight

Status: in progress — real-project audit complete; enemy art/combat/file specifications and verification pending

### Approved phase and strict scope

- Execute only Phase 0 from the approved `Chapter III: Chapel of Thirteen Echoes` enemy milestone: audit the real project, lock the six-enemy world/combat/art direction, document target values and publish the exact future file/QA plan.
- Do not create concept PNGs, SpriteFrames, enemy scenes, AI scripts, projectiles, fields, Trial Hall runtime, Main spawn ids or Encounter population in this phase. Those belong to Phase 1, Phase 2A–2F and Phase 3 and require separate approval after this report.
- Task-owned files are the five new Chapter III enemy documents under `chapters/chapter_03_chapel_of_thirteen_echoes/docs/` plus this development-log entry. No Chapter I/II file, Player value, Crimson Masque value, loot probability, formal Chapter III map, Boss, Save foundation or `project.godot` setting will change.

### Read-only audit baseline

- Work starts on `master` at `88a28bf6311453d6af6e1dbf29a7604c76048367`. Pre-existing user-owned Chapter I/shared/Player tuning, old QA image changes and two UID sidecars remain outside the task.
- `project.godot` resolves F5 to `res://scenes/bootstrap/main_bootstrap.tscn`. Chapter III is registered by `scripts/systems/chapter/chapter_registry.gd` and currently resolves to the explicit `chapter_03_entry_placeholder.tscn`, with a debug-ready Start Profile that owns/equips `Crimson Masque Stilettos / 绯幕礼刺` at the verified 14 Normal / 28 Dash damage.
- The current Chapter III tree has only the entry placeholder, its two level scripts and one Start Profile. It has no enemy docs, enemy assets, enemy Resources, enemies, trial scene or trial spawn ids. The geometric `Chapter03EntryArt` is explicitly marked entry-placeholder content and is not evidence of a formal Chapter III map.
- Existing reusable contracts are `EnemyCombatant`, `GroundEnemyBase`, `HealthComponent`, `HitboxComponent`, `HurtboxComponent`, `EnemyHitPolicyComponent`, `LootDropComponent` and `EncounterGroup`. Ground edge/wall protection already uses raycasts plus optional authored movement bounds.
- No `AttackContext` class/resource and no generic shared Projectile base exist. Attack identity/dedup is implemented inside `HitboxComponent`; projectiles are concrete `CrossbowBolt` and `BloodCandleProjectile` implementations. Poise/Stagger exists only inside Chapter II enemy/Boss code and must not be misreported as a shared component.
- Exact pre-modification import baseline: `/Users/vincentz/Downloads/Godot.app/Contents/MacOS/Godot --headless --editor --path . --import --quit` — exit 0 on Godot `4.7.1.stable.official.a13da4feb`; no parser, resource or autoload error.

### Planned verification

- Validate Markdown/path tables and whitespace, rerun exact Godot 4.7.1 import, run the chapter-start foundation and Crimson Masque contract tests, and execute an F5-equivalent Main bootstrap smoke.
- Because Phase 0 adds no enemy runtime, it cannot truthfully claim F6 enemy tests, Main enemy visibility, 20 kills per enemy, combo trials or 18 screenshots. Those remain explicit acceptance gates for their later phases.

## 2026-07-28 — Chapter III normal enemies Phase 0 completion

Status: complete — real-project audit, six-enemy world/combat baseline, art bible, balance and Trial Hall/file plan delivered; Phase 1 approval pending

### Delivered Phase 0 scope

- Added the Chapter III roster and narrative role contract for Bellchain Penitent, Censer Executioner, Silent Chorister, Stained-Glass Seraph, Confessional Wraith and Thirteenth Scribe, including the later 44-enemy population hypothesis and safe combination constraints without creating formal Encounters.
- Added a native-pixel art bible with a restrained chapel palette, six silhouette contracts, exact Phase 1 concept/silhouette paths, 64×64 production rules, 48×48 readability and a file authenticity gate. No empty folder, PNG or claimed concept was created early.
- Added the combat specification and complete audit ledger. Existing Health/Hitbox/Hurtbox/Loot/Encounter/GroundEnemy contracts are designated for reuse; the absent AttackContext/shared Projectile/Poise contracts are recorded honestly with narrow Chapter III-local plans rather than reported as existing.
- Added `baseline_v1` HP, Poise, damage, timing and kill-count tables against the verified Crimson Masque 14/28 WeaponData. Prompt-defined values are locked as implementation targets; unspecified timing and the proposed 14/28 Poise-pressure mapping remain explicitly `[PLAYTEST_REQUIRED]`.
- Added the Debug-only Trial Hall architecture, eight planned `CH3_*` spawn ids, required combination matrix, twenty-kill/fifteen-attack QA minimums, Main/F5 procedure and 18-image evidence plan. The document explicitly states that this F5 procedure is unavailable until Phase 3.
- Added the exact future scene/controller/EnemyData/SpriteFrames manifest for all six enemies. No `.gd`, `.tscn`, `.tres`, PNG, `project.godot`, Main route, Player/weapon value, Chapter I/II content, loot probability, Chapter III map or Boss was changed.

### Exact commands and actual results

1. Pre- and post-document exact import: `/Users/vincentz/Downloads/Godot.app/Contents/MacOS/Godot --headless --editor --path . --import --quit` — both exit 0 on `4.7.1.stable.official.a13da4feb`; no parser, missing-resource or autoload error.
2. Chapter registry/profile: `Godot --headless --path . --script res://tests/systems/test_chapter_start_foundation.gd` — `PASS (7 entries, Chapters I/II/III-entry ready, Bootstrap preserved)`.
3. Main routing: `test_main_bootstrap_flow.gd` — PASS for formal Opening and Debug Chapter II. The harness reports two ObjectDB instances during forced test exit after PASS; it is not present in formal Main startup.
4. Weapon/profile contract: `test_crimson_masque_weapon.gd` — `PASS data=1 frames=49 damage=14/28 dedup=1 profile=1`.
5. Chapter II→III saved route: `test_chapter_02_to_03_transition.gd` — `PASS dialogue=4 reliquary=1 mirror_after_reward=1 crimson=14/28 reload=2 passage=1 chapter3=1`. Its forced SceneTree teardown prints known Resource/RID diagnostics after PASS; no runtime assertion, parser or missing-resource failure occurred.
6. Formal F5-equivalent smoke: `Godot --path . --quit-after 240` — exit 0; `MAIN BOOTSTRAP | FORMAL NEW GAME | res://scenes/cinematics/opening_cinematic.tscn`; no Output/Debugger runtime, script or resource error.
7. Documentation check: `git diff --check -- docs/development_log.md chapters/chapter_03_chapel_of_thirteen_echoes/docs` — exit 0 before the completion append; repeated before staging.

### Known gaps and next approval

- Chapter III still opens the explicitly labeled geometric entry placeholder. There are no enemy visuals, scenes, AI, trial spawns or Trial Hall in Main, so F6/F5 enemy combat, twenty-kill runs, loot/reset, combinations and screenshots are not claimed.
- Phase 1 is the next allowed milestone: create exactly twelve original concept/silhouette PNGs, validate their content/dimensions/hashes/readability, report and stop. It must not start Phase 2A code without a further approval.
- The game-design skill shaped the role/telegraph/counterplay and balance failure criteria; the Godot gameplay skill shaped composition, typed-signal and missing-contract boundaries. Pre-existing user-owned dirty files remain preserved and excluded.

## 2026-07-28 — Chapter III normal enemies Phase 1 preflight

Status: in progress — twelve concept/silhouette PNGs approved; generation and authenticity QA pending

### Approved scope, files and tests

- Execute only Phase 1: create one original full-body concept and one silhouette/proportion sheet for each of Bellchain Penitent, Censer Executioner, Silent Chorister, Stained-Glass Seraph, Confessional Wraith and Thirteenth Scribe.
- Final assets will live under each enemy's Chapter III-owned `assets/enemies/<enemy>/concept_art/` directory. Concepts target 256×256 RGBA; silhouette sheets target 192×192 RGBA. Transparent background, complete signature object, distinct thumbnail silhouette and nearest-neighbor presentation are mandatory.
- Use original generated raster concepts followed by local transparency cleanup and deterministic silhouette derivation. No downloaded third-party asset, prior-chapter recolor, protected commercial character or geometric runtime stand-in is allowed.
- Task-owned documentation is this log, `chapter_03_enemy_art_bible.md`, and a Phase 1 QA manifest/report under Chapter III docs/QA. No gameplay `.gd`, enemy `.tscn`, EnemyData, SpriteFrames, Main route, Player/weapon value, Chapter I/II content, loot value or project input/render setting is in scope.
- Authenticity QA will record path, dimensions, mode/alpha, byte size, SHA-256, visible bounds and nontransparent pixel count for all twelve PNGs; six contact sheets/screenshots will verify concept/silhouette relation and 48 px readability.
- Verification uses the exact Godot 4.7.1 executable: headless import/parse, a dedicated asset integrity check, Chapter start regression and formal Main bootstrap smoke. Phase 1 will stop after reporting and one isolated commit; Phase 2A code remains unapproved.
- Work begins on `master` at `9660451`. Existing Chapter I/shared/Player tuning, QA-image edits and two UID sidecars remain user-owned and excluded from this milestone.

## 2026-07-28 — Chapter III normal enemies Phase 1 completion

Status: complete — twelve original concept/silhouette PNGs delivered and authenticity-checked; human art-direction approval pending

### Delivered Phase 1 scope

- Created one complete 256×256 RGBA concept for each of Bellchain Penitent, Censer Executioner, Silent Chorister, Stained-Glass Seraph, Confessional Wraith and Thirteenth Scribe. Every concept includes the enemy's complete signature ritual object and uses a transparent background with hard alpha.
- Created one 192×192 RGBA silhouette/proportion sheet per enemy. Each sheet includes the current 64 px Night Warden scale guide and a shared baseline; all six silhouette hashes are unique and remain distinguishable in the preserved 48 px nearest-neighbor previews.
- Concepts were generated specifically from the approved Chapter III contracts with the built-in image generation workflow, then locally chroma-keyed, hard-alpha cleaned and nearest-neighbor fitted. No downloaded asset, protected commercial character, real religious portrait, prior-chapter enemy image or recolor was used as input.
- Added six 768×384 per-enemy QA sheets and one 1536×1152 overview under `docs/qa/chapter_03_enemy_phase_01/`, plus a complete byte/hash/alpha-bound/visible-pixel manifest and a dedicated exact-engine resource test.
- Updated the art bible from Phase 0 planning to the completed Phase 1 handoff. The accepted concepts are now binding visual sources for their later 64×64 gameplay sprites; Phase 2 must retain the signature object and silhouette rather than substitute a generic enemy.

### Exact commands and actual results

1. Local transparency cleanup used the Image Generation skill's installed `remove_chroma_key.py` with border auto-key, soft matte and despill; all six sources produced non-empty alpha foregrounds. Final repository PNGs were hard-alpha normalized and nearest-neighbor fitted to 256×256/192×192.
2. Exact Godot import: `/Users/vincentz/Downloads/Godot.app/Contents/MacOS/Godot --headless --editor --path . --import --quit` — exit 0 on `4.7.1.stable.official.a13da4feb`; all twelve PNGs imported with no parser, import or missing-resource error.
3. Dedicated authenticity test: `Godot --headless --path . --script res://chapters/chapter_03_chapel_of_thirteen_echoes/tests/test_chapter_03_enemy_concept_assets.gd` — `PASS files=12 concepts=6 silhouettes=6 unique_silhouettes=6`; no final warning or error.
4. Chapter registry regression: `test_chapter_start_foundation.gd` — `PASS (7 entries, Chapters I/II/III-entry ready, Bootstrap preserved)`.
5. Formal F5-equivalent Main smoke: `Godot --path . --quit-after 240` — exit 0; `MAIN BOOTSTRAP | FORMAL NEW GAME | res://scenes/cinematics/opening_cinematic.tscn`; no runtime, script or resource error.
6. Visual QA: `chapter_03_enemy_concept_overview.png` and six per-enemy sheets were inspected at original resolution. Complete objects, transparent separation, distinct silhouettes and 48 px role readability pass; subjective art-direction acceptance remains with the user.

### Scope and next gate

- Phase 1 intentionally adds no gameplay SpriteFrames, enemy scene, EnemyData, AI, attack, projectile, field, Trial Hall, Encounter, Main spawn or Chapter III formal map. The concepts are not yet visible in F5/Main and this is stated explicitly in the QA report.
- Phase 2A is the next allowed milestone after user approval: create only Bellchain Penitent's 64×64 production animation set, combat prototype, independent F6 validation and saved Main/F5 integration, then stop again.
- Existing user-owned Chapter I/shared/Player tuning, old QA image edits and two UID sidecars remain preserved and excluded from this milestone.

## 2026-07-28 — Chapter III normal enemies Phase 2A preflight

Status: in progress — Bellchain Penitent production Sprite, combat prototype and Main integration approved

### Goal, files, tests and scope check

- Implement only the first enemy, `Bellchain Penitent / 钟链忏者`, as the Chapter III baseline mid-range pressure unit. Preserve the approved 256 px concept's wrapped mask, sealed mouth, copper throat bell, separate prayer bell/short chain, stooped robe and pendulum motion in original 64×64 production frames.
- Add the enemy's typed Resource/config, AI script, saved scene, dynamic-loot profile, SpriteFrames and 17 animation families: idle, movement, alert, turn, split Windup/Active/Recovery clips for Chain Lash, Bell Slam and Short Chain Pull, light-hit, stagger, hurt and death.
- Reuse `GroundEnemyBase`, `EnemyCombatant`, `HealthComponent`, `HitboxComponent`, `HurtboxComponent`, `LootDropComponent` and current collision/faction conventions. Phase 2A may add a narrow Chapter III hit/Poise policy or Penitent-local typed state logic, but will not copy the Chapter II multi-role script or create an inheritance tree for the other five enemies prematurely.
- Target tuning remains HP 70, Poise 32, Chain Lash 11 at 0.42/0.12/0.52 s, Bell Slam 13 at 0.62/0.14/0.76 s, and Short Chain Pull 8 with 3.0 s cooldown and collision-safe 20–30 px target displacement. Unspecified approach/turn/pull phase values remain `[PLAYTEST_REQUIRED]` and will be centralized in the Penitent config.
- Add one independently runnable Chapter III Bellchain test room and one saved prototype Encounter inside the actual Chapter III entry scene. Add `CH3_BELLCHAIN_TEST` to the Start Profile and make the scene consume the pending spawn id without changing formal `run/main_scene` or committing the global Debug switch enabled.
- Planned exact-engine validation: deterministic Image generator, import/parse, SpriteFrames builder, frame/dimension/alpha test, state/attack/damage/dedup/Poise/pull/death test, independent test-room smoke, Chapter start regression, saved Chapter III Main-integration test, Debug MainBootstrap graphical QA and formal Bootstrap smoke. Visual evidence belongs under `docs/qa/chapter_03_enemy_phase_02a/`.
- Phase 2B–2F, the six-enemy Trial Hall, combination Encounters, formal Chapter III map/Boss and any Chapter I/II/Player/Crimson Masque tuning are out of scope. Completion must stop after one commit and human feel/visual acceptance steps.
- Work begins on `master` at `cfb5c8c`. Existing user-owned Chapter I/shared/Player tuning, old QA-image edits and two UID sidecars remain preserved and excluded.

## 2026-07-28 — Chapter III normal enemies Phase 2A completion

Status: complete — Bellchain Penitent production enemy, solo test room and saved Chapter III Main prototype encounter delivered; Phase 2B not started

### Delivered scope

- Generated 70 original transparent 64×64 frames across 17 animation families: Idle, Walk, Alert, Turn, split Windup/Active/Recovery clips for Chain Lash, Bell Slam and Short Chain Pull, plus Light Hit, Stagger, Hurt and Death. The wrapped mask, sealed mouth, copper throat bell, separate prayer bell and pendulum chain remain recognizable from the approved concept.
- Added typed `BellchainPenitentConfig`, `BellchainPenitent`, and composed `Chapter03PoiseComponent`. Reused GroundEnemyBase, Health, Hitbox, Hurtbox, Encounter and Loot contracts without changing Player, weapon, loot probability or earlier-chapter behavior.
- Implemented HP 70 / Poise 32; Chain Lash 11 at 0.42/0.12/0.52 s; Bell Slam 13 at 0.62/0.14/0.76 s; Short Chain Pull 8 at 0.48/0.10/0.60 s with 3.0 s cooldown. Every Active owns a unique attack id, front-only shape and one-hit target ledger. Windup is light-hit interruptible; Active/Recovery are not permanently reset; Poise break enters distinct Stagger.
- Added independently runnable `bellchain_penitent_test_room.tscn`. Added one saved `Phase2AEncounter` and `CH3_BELLCHAIN_TEST` to the actual Chapter III entry target loaded through MainBootstrap. Committed Debug defaults remain disabled.
- Added deterministic coverage for SpriteFrames, configuration, three exact once-only damages, Poise break, Death, Hurtbox/Hitbox shutdown, one-shot death/loot resolution, cleanup, standalone room and Main composition. Added five MainBootstrap screenshots and one animation sheet under `docs/qa/chapter_03_enemy_phase_02a/`.

### Exact commands and actual results

1. `Godot --headless --path . --script res://chapters/chapter_03_chapel_of_thirteen_echoes/scripts/tools/generate_bellchain_penitent_assets.gd` — PASS, `frames=70 animations=17`.
2. Exact 4.7.1 import/parse (`/Users/vincentz/Downloads/Godot.app/Contents/MacOS/Godot --headless --path . --editor --quit`) — exit 0; PNGs, typed classes, scenes and resources imported with no error.
3. SpriteFrames builder (`build_bellchain_penitent_sprite_frames.gd`) — PASS, `animations=17 frames=70`.
4. `test_bellchain_penitent_phase2a.gd` — PASS: `animations=17 frames=70 hp=70 poise=32 attacks=3 solo_test=1 main_encounter=1 spawn=CH3_BELLCHAIN_TEST`; Lash/Slam/Pull dealt 11/13/8 exactly once, and Death/loot emitted once.
5. Independent room smoke: exact Godot 4.7.1 with `--headless --quit-after 180 bellchain_penitent_test_room.tscn` — exit 0, no Output/Debugger error.
6. Graphical MainBootstrap QA (`capture_bellchain_penitent_phase2a_qa.gd`) — final clean rerun PASS, `captures=5 route=MainBootstrap spawn=CH3_BELLCHAIN_TEST attacks=3 stagger=1`; no runtime red error. An initial QA-harness-only print-format error was corrected before the recorded rerun.
7. Phase 1 art regression (`test_chapter_03_enemy_concept_assets.gd`) — PASS, `files=12 concepts=6 silhouettes=6 unique_silhouettes=6`.
8. Chapter registry/profile regression (`test_chapter_start_foundation.gd`) — PASS, `7 entries, Chapters I/II/III-entry ready, Bootstrap preserved`.
9. Main route regression (`test_main_bootstrap_flow.gd`) — PASS for formal Opening and Debug Chapter II. The harness retains its known two ObjectDB instances during forced test teardown; no parser/resource/runtime assertion failed.
10. Formal F5-equivalent smoke (`Godot --path . --quit-after 240`) — exit 0, `MAIN BOOTSTRAP | FORMAL NEW GAME | res://scenes/cinematics/opening_cinematic.tscn`; default Debug routing remains disabled.

### Manual acceptance and remaining gate

- F5 direct test: temporarily configure Chapter III + `CH3_BELLCHAIN_TEST`, then verify J/Dash Attack interruption pressure, jumping over Bell Slam, 3-second Pull cadence, short collision-safe Pull, both facings, death and loot. Restore the Debug switch afterward.
- The Chapter III destination is still an explicitly labeled entry prototype. Its solo encounter is saved and F5-playable, but is not claimed as the formal Chapter III map or final encounter placement.
- Phase 2B (Censer Executioner) and all later enemies remain untouched. Short Pull distance, approach speed, Poise mapping 14/28 and encounter feel remain human `[PLAYTEST_REQUIRED]` values.
- Game-design guidance shaped the telegraph/counterplay split; Godot gameplay guidance shaped typed composition, active-only hitboxes and exact-engine verification. Pre-existing user-owned dirty files remain preserved and excluded.
## 2026-07-28 — 全章节敌人美术重制 Stage 0 + Stage 1 preflight

Status: in progress — 全章节只读资产审计与第三章六敌人正式像素美术重制获批；第一、二章只审计不改动

### 目标、范围与质量门

- 本里程碑先记录 Chapter I–III 已存在的普通敌人、特殊敌人、Boss、概念图、SpriteFrames、场景和 Main 引用，再只重制 Chapter III 的 Bellchain Penitent、Censer Executioner、Silent Chorister、Stained-Glass Seraph、Confessional Wraith、Thirteenth Scribe。
- 第三章当前十二张 256/192 px 概念与剪影经原尺寸检查具备明确设定识别，继续作为权威视觉来源；真正不达标的是运行时 64×64 Phase 2 帧：方块头、矩形躯干、直线武器和几乎不变的攻击姿势，与概念落差明显。本轮必须替换所有 415 张运行帧，而非只修 idle。
- 每个角色必须在章节自有目录中保留 `concept_art/`、新 `sprites/`、`animations/`，并补齐有实际内容的 `effects/`、`docs/`。旧 Phase 2 运行帧整体归档到 `reference/deprecated_phase_2/`，不得继续被 SpriteFrames 或 Main 引用。
- 保留现有战斗数值、AI、Hitbox/Hurtbox、掉落、Player、武器、Chapter I/II 运行内容和 `project.godot` 正式入口。只允许为视觉验收增加第三章试炼厅、QA脚本、文档和 MainBootstrap 可达的 Chapter III Debug 测试证据。
- 完成状态使用 PASS/PARTIAL/FAIL。正式 Sprite 或 Main 集成未通过时不得写完成；QA必须包含六张概念证据、六张Sprite预览、六张Main实机、攻击动作、组合战斗和旧版对比。

### 只读基线

- Work starts on `master` at `79dc8636ac67199fc48ed7976d791aaf0dded5e0`. Existing user-owned Chapter I/shared/Player tuning, old QA PNG edits and two UID sidecars remain preserved and excluded from this commit.
- F5 remains `res://scenes/bootstrap/main_bootstrap.tscn`; Chapter III target remains `res://chapters/chapter_03_chapel_of_thirteen_echoes/scenes/level/chapter_03_entry_placeholder.tscn`. All six enemy scenes already use `AnimatedSprite2D` and chapter-local SpriteFrames, and the saved Chapter III target references all six PackedScenes.
- Current runtime inventory is 415 transparent 64×64 PNGs: Bellchain 70, Executioner 71, Chorister 69, Seraph 67, Wraith 71, Scribe 67. Nearest-neighbor is enforced by per-sprite `texture_filter` and project default filter 0; viewport is 1280×720.
- Visual inspection of all six idle and representative active frames confirms the acceptance failure: body/limbs/weapons are primarily rectangles and straight lines, with attack active frames often visually indistinguishable from idle. These files are classified as `deprecated_phase_2`, not formal art.

### Planned verification

- Generate all six role-specific, non-template 64×64 animation sets with hard alpha and stable anchors; rebuild SpriteFrames; run dimension/alpha/animation/hash/reference tests; run every independent enemy scene, the combination room and the saved trial hall.
- Use the exact `/Users/vincentz/Downloads/Godot.app/Contents/MacOS/Godot` 4.7.1 executable for import/parse, automated tests, F5-equivalent MainBootstrap routing and screenshot capture. Record actual commands/results and preserve all evidence under `docs/qa/chapter_03_enemy_art_rework/`.
- Update the Chapter III art bible and add `chapter_03_enemy_sprite_quality_spec.md`, Stage 0 audit, per-role art notes, mapping/animation/legacy tables. Create one isolated commit and stop for review; do not begin Chapter I/II art replacement.

## 2026-07-28 — 全章节敌人美术重制 Stage 0 + Stage 1 completion

Status: complete for the authorized Stage 0 audit and Chapter III Stage 1 replacement; Chapter I/II replacement not started

### Delivered scope

- Audited the real Chapter I–III enemy/Boss assets, scenes, SpriteFrames, runtime references and Main route. Chapter I and II remain audit-only; no existing gameplay or art file in those chapters was changed by this milestone.
- Retained the six accepted Chapter III 256×256 concepts and 192×192 silhouette sheets as the authoritative source. Added one role-specific action-production reference and one effect/material reference per enemy rather than generating unrelated replacement concepts.
- Replaced every one of the 415 formal Chapter III runtime PNGs in place: Bellchain Penitent 70, Censer Executioner 71, Silent Chorister 69, Stained-Glass Seraph 67, Confessional Wraith 71 and Thirteenth Scribe 67. The new frames use role-specific layered silhouettes, separated limbs, garment/armor layers and distinct cloth, iron, copper, bone/parchment, glass, timber, ink and spectral materials.
- Archived all 415 superseded Phase 2 runtime frames under each role's `reference/deprecated_phase_2/sprites/`. Existing SpriteFrames continue to use the stable formal `sprites/` paths, and deterministic tests reject any archived path in runtime animation resources.
- Populated each role's required `concept_art/`, `sprites/`, `animations/`, `effects/` and `docs/` directories with real content. Added `chapter_03_enemy_sprite_quality_spec.md`, per-role production notes and the Stage 0 audit.
- Added the saved `chapter_03_enemy_trial_hall.tscn` alias for six-role review. The actual Main integration remains the existing Chapter III saved destination loaded through `res://scenes/bootstrap/main_bootstrap.tscn`, with all six enemy PackedScenes inside four saved Encounter groups.
- Produced 27 QA PNGs: six concept/old/new boards, six animation previews, a six-role overview, old-vs-new overview, six Main idle screenshots, six Main attack screenshots and one three-role combination screenshot. The authoritative result and mapping tables are in `docs/qa/chapter_03_enemy_art_rework/qa_report.md`.
- No Player, enemy AI, combat timing, damage, Hitbox/Hurtbox, loot, weapon, Chapter I/II runtime, Chapter III routing or `project.godot` value was changed.

### Exact commands and actual results

1. Formal art generator: `/Users/vincentz/Downloads/Godot.app/Contents/MacOS/Godot --headless --path . --script res://chapters/chapter_03_chapel_of_thirteen_echoes/scripts/tools/generate_chapter_03_enemy_art_v2.gd` — PASS, `roles=6 frames=415`.
2. Exact import/parse: `/Users/vincentz/Downloads/Godot.app/Contents/MacOS/Godot --headless --editor --path . --import --quit` — exit 0 on Godot 4.7.1; 842 new/formal/archive images imported without parser, resource or autoload errors.
3. QA board generator: exact Godot 4.7.1 running `build_chapter_03_enemy_art_qa.gd` — PASS, `roles=6 boards=14`.
4. Formal art/reference test: exact Godot 4.7.1 running `test_chapter_03_enemy_art_rework.gd` — PASS, `roles=6 frames=415 archives=415 main_refs=6`.
5. Concept regression: `test_chapter_03_enemy_concept_assets.gd` — PASS, `files=12 concepts=6 silhouettes=6 unique_silhouettes=6`.
6. Six-role Phase 2 regression: `test_chapter_03_phase_2_enemy_roster.gd` — PASS, `roles=6 remaining_frames=345 main=6 combination_room=1`.
7. Bellchain combat regression: `test_bellchain_penitent_phase2a.gd` — PASS, `animations=17 frames=70 hp=70 poise=32 attacks=3 solo_test=1 main_encounter=1`.
8. Chapter start regression: `test_chapter_start_foundation.gd` — PASS, `7 entries, Chapters I/II/III-entry ready, Bootstrap preserved`.
9. Bootstrap regression: `test_main_bootstrap_flow.gd` — PASS for formal Opening and Debug Chapter II. Forced test teardown still reports its existing two ObjectDB fixture instances; no assertion, parser, resource or runtime red error.
10. Six independent enemy scene smokes plus `chapter_03_enemy_trial_hall.tscn`: exact Godot 4.7.1 with `--headless --quit-after 30` — all seven exit 0 with no Output/Debugger error.
11. Main graphical QA: exact Godot 4.7.1 running `capture_chapter_03_enemy_art_rework_qa.gd` — PASS, `captures=13 route=MainBootstrap enemies=6 attacks=6 combination=1`; the script restores the Debug Start setting after capture.
12. Formal F5-equivalent smoke: `/Users/vincentz/Downloads/Godot.app/Contents/MacOS/Godot --path . --quit-after 240` — exit 0, `MAIN BOOTSTRAP | FORMAL NEW GAME | res://scenes/cinematics/opening_cinematic.tscn`.
13. Whitespace validation will run after final documentation edits with `git diff --check` before the isolated commit.

### Acceptance and known limits

- Third chapter audit, concepts, silhouettes, formal sprites, all animation families, scene replacement, Main integration and automated tests are PASS. The old rectangular/line-based frames are no longer referenced by the six formal SpriteFrames.
- Bellchain's curved chain is readable in the integer-scale asset preview but remains the densest/finest feature in a 1280×720 full-scene screenshot; it is explicitly listed for human 1× playtest review rather than hidden behind a generic PASS claim.
- The Chapter III destination remains an explicitly labeled enemy acceptance prototype, not a finished Chapter III environment. Environment completion was not authorized by this art milestone.
- Chapter I/II audit is PASS, but their concepts, formal enemy/Boss replacements and Main replacement are FAIL/not started by scope. Stop after this isolated commit and wait for the user's third-chapter art acceptance before any Chapter I/II replacement.

## 2026-07-28 — Chapter III legacy enemy art removal preflight

Status: in progress — user approved deletion of the superseded Chapter III Phase 2 archive and requested explicit Main verification

### Goal and scope

- Delete only the six tracked `reference/deprecated_phase_2/` trees created by commit `8d25810`; they contain 415 old PNGs plus their Godot import sidecars and are recoverable from Git history.
- Preserve the accepted concepts, silhouettes, action references, effect references, 415 formal `sprites/` frames, chapter-local SpriteFrames, all enemy scenes, combat logic and the 27 already-generated QA images.
- Update the art integrity test so deletion—not archive presence—is the invariant. Update the QA-board builder so future evidence regeneration no longer depends on deleted source files.
- Reconfirm every formal SpriteFrames texture resolves under `assets/enemies/<role>/sprites/`, every enemy scene uses its chapter-local SpriteFrames, and the saved Chapter III Main target contains all six PackedScenes.
- Do not touch Chapter I, shared enemy, Player, loot or pre-existing QA changes already present in the worktree.

### Read-only audit before deletion

- Work begins on `master` at `8d25810f755bfc9d369dd3901a55fb1238ab65da`; unrelated user-owned dirty files remain unstaged.
- Six old archive roots exist and contain exactly 415 PNGs. No `animations/*.tres`, enemy scene, Chapter III level scene or `project.godot` entry references `reference/deprecated_phase_2`.
- The six formal SpriteFrames contain exactly 70/71/69/67/71/67 texture references under their role-local formal `sprites/` paths. `chapter_03_entry_placeholder.tscn`, reached through `res://scenes/bootstrap/main_bootstrap.tscn`, references all six formal enemy scenes.

### Planned verification

- Remove the six tracked archive trees with `git rm -r`, then verify zero old archive files and zero runtime legacy references.
- Run exact Godot 4.7.1 import/parse, the revised art integrity/Main-reference test, six-role roster regression, six independent enemy scene smokes, Trial Hall smoke, Main graphical capture and formal F5-equivalent startup.
- Update the QA report, README/art documentation and this log; create one isolated cleanup commit and stop.

## 2026-07-28 — Chapter III legacy enemy art removal completion

Status: complete — superseded Phase 2 source art removed; formal v2 SpriteFrames and Main route verified

### Delivered scope

- Removed six `reference/deprecated_phase_2/` trees: 415 old PNGs and 415 `.import` sidecars. The deletion is recoverable from Git commit `8d25810`; the baked old-vs-new QA images remain as historical evidence.
- Removed `generate_bellchain_penitent_assets.gd` and `generate_phase_2b_2f_enemy_assets.gd` plus their UID files because they could regenerate the obsolete geometric art over the formal source paths. `generate_chapter_03_enemy_art_v2.gd` remains the supported generator.
- Revised `test_chapter_03_enemy_art_rework.gd` to require all six old archive directories to be absent while still validating 415 formal frames, SpriteFrames paths, scene bindings and six saved Main references.
- Revised the QA board builder so it no longer reads deleted sources. It now builds six concept/action/effect/formal boards, six Sprite previews and the all-enemy formal overview; the previously generated old-vs-new board remains immutable historical evidence.
- Updated README, art bible, sprite-quality contract, per-role production notes and the strong QA report. No gameplay code, AI, damage, collision, Player, loot, routing, `project.godot`, Chapter I or Chapter II runtime content changed.

### Main integration result

- F5 entry remains `res://scenes/bootstrap/main_bootstrap.tscn`.
- The Chapter III saved target remains `res://chapters/chapter_03_chapel_of_thirteen_echoes/scenes/level/chapter_03_entry_placeholder.tscn` and contains all six formal enemy PackedScenes.
- Each enemy scene still owns `VisualRoot/AnimatedSprite2D` with its role-local `animations/<role>_sprite_frames.tres`. Those resources contain 70/71/69/67/71/67 formal references under `assets/enemies/<role>/sprites/`, for a total of 415; no legacy reference exists.
- Main graphical QA entered Chapter III through MainBootstrap and captured six enemies, six attacks and the three-role combination after deletion. The script restored Debug Start; a subsequent formal F5 smoke entered Opening Cinematic.

### Exact commands and actual results

1. Read-only inventory and reference audit: six legacy roots, 415 PNGs; zero SpriteFrames/Main/project references to `deprecated_phase_2`; formal references total 415.
2. `git rm -r` on the six explicit `reference/deprecated_phase_2` roots — success; post-delete legacy file count `0`.
3. Revised QA builder with exact Godot 4.7.1 — PASS: `roles=6 live_boards=13 historical_comparison_preserved=1`.
4. Exact import/parse after deletion: `/Users/vincentz/Downloads/Godot.app/Contents/MacOS/Godot --headless --editor --path . --import --quit` — exit 0; no parser/resource/autoload error.
5. Revised art/reference/Main test — PASS: `roles=6 frames=415 legacy_dirs=0 main_refs=6`.
6. Six-role roster regression — PASS: `roles=6 remaining_frames=345 main=6 combination_room=1`.
7. Main graphical QA through MainBootstrap — PASS: `captures=13 route=MainBootstrap enemies=6 attacks=6 combination=1`.
8. Six individual enemy scene smokes and `chapter_03_enemy_trial_hall.tscn`, exact Godot 4.7.1 with `--headless --quit-after 30` — all seven exit 0 without Output/Debugger errors.
9. Formal F5-equivalent smoke: `/Users/vincentz/Downloads/Godot.app/Contents/MacOS/Godot --path . --quit-after 240` — exit 0; `MAIN BOOTSTRAP | FORMAL NEW GAME | res://scenes/cinematics/opening_cinematic.tscn`.

### Manual acceptance and recovery

- Use the same Chapter III Debug Start ids documented in README to inspect each formal enemy through MainBootstrap; restore Debug Start afterward.
- If the old source art is ever needed for forensic comparison, recover it from commit `8d25810` rather than reintroducing it into the runtime asset tree.
- Pre-existing Chapter I/shared/Player/old-QA worktree changes remain preserved and excluded from this cleanup commit.
