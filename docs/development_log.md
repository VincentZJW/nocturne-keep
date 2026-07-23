# Development Log

## Current authoritative status

- Last audited: 2026-07-23
- Audit baseline: `master` at `e11638b chore: harden repository privacy rules`
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
| Player animation presentation | Implemented and re-verified | `AnimatedSprite2D`, `PlayerAnimationController`, a 16-animation `SpriteFrames` resource, production/reference assets, and preview tooling are present. `death` is a five-frame production body fall; only `hurt` remains placeholder art. |
| M1 locomotion | Implemented and re-verified | `CharacterBody2D` movement, ground/air acceleration, gravity, jump, 0.10 s coyote time, 0.12 s jump buffer, Camera2D, facing, and six locomotion animations passed the current regression. |
| Debug double jump | Implemented for testing; formal unlock pending | `has_double_jump` defaults false, while `debug_enable_double_jump` defaults true in `Player`; no ability-unlock/session system exists. |
| M1.5 actions | Implemented and re-verified; manual feel approval pending | Four-frame Attack, Ground/Air Dash chains, Dash Attack, input buffers, collision-safe motion, stamina component/HUD, and configurable airborne regeneration passed current automated tests. No damage is produced. |
| Player Health HUD | Implemented and re-verified | `Main/HUD/HealthContainer` observes the composed Player `HealthComponent`, initializes without polling, displays current/maximum values, and supports explicit signal-safe rebinding. It does not own Health data or death behavior. |
| Player death state | Implemented and re-verified; manual visual acceptance pending | `Player` enters one explicit `LifeState.DEAD`, cancels action/input/Stamina processing, and delegates a five-frame flat-body fall plus detached daggers and hooded ghost rise/pause to `PlayerDeathSequence`. |
| Player respawn | Implemented and re-verified; single test spawn only | After the approximately 1.30-second presentation completes, Main's typed coordinator returns the same Player instance to one `Marker2D`, restores Health/Stamina and control state, hides the prompt, and retains Camera2D following. No checkpoint/session selection exists. |
| Combat foundation | Partially implemented | Player composes an independently tested `HealthComponent` with bounded mutation and death signaling, plus death/respawn consumers. Formal damage sources, Hitbox, Hurtbox, invulnerability, target memory, enemy damage, and game-over flow do not exist. Attack effective frames remain metadata/interfaces only. |
| Enemies and boss | Planned / not implemented | Enemy/Boss scene, script, and resource directories contain no implemented actors. |
| Level and game flow | Planned / not implemented beyond test spawn | Main is a movement/action laboratory with floor, two platforms, boundary walls, debug UI, and one fixed respawn marker. The planned three rooms, checkpoint selection, elite unlock, boss arena, victory flow, menu, and save/session state do not exist. |
| Export/release | Pending verification / not configured | No `export_presets.cfg` was found during the audit. |

### Current validation baseline

On 2026-07-23, the exact Godot 4.7.1 executable completed a fresh headless editor import, headless Main/Player startup, and all fifteen repository test scripts without `SCRIPT ERROR`, `ERROR:`, or `WARNING:` output. The passing checks cover the isolated Health contract, signal-driven Health HUD, explicit death-state lockout, five-frame horizontal death body and detached daggers, hooded ghost rise/0.50-second pause/cleanup, presentation-gated repeatable single-point respawn, eleven concept assets plus the board, 38 current production action/death frames plus the ghost and four byte-identical references, sixteen configured animations, M1 movement, M1.5 actions, Dash Attack, fast Attack buffering, shared Ground/Air Dash stamina, continuous Air Dash, and level metrics.

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
4. Replace the remaining `hurt` placeholder only when its Gameplay state enters an approved milestone; manually accept the new production death body/ghost readability at game scale.
5. Resolve or tolerance-bound the 360.33–362.22 px landing-total measurement variation; the 344.00 px Dash-only envelope is currently stable.
6. Bring the M0 metadata/status in `game_design.md`, `technical_architecture.md`, and `known_issues.md` up to date in a separate documentation-only task.
7. Define named collision layers/masks before implementing combat; current Player and world body collision use the baseline layer/mask rather than the planned actor/hitbox/hurtbox separation.
8. Keep Main's geometric level and stamina/debug interface classified as laboratory/placeholder presentation, not finished room or UI content.

### Next-stage plan — requires explicit approval

1. **M1.5 acceptance gate:** perform manual feel/visual checks, record accepted tuning, and freeze movement/action metrics used for level construction.
2. **Documentation alignment:** update the stale M0 design/architecture/known-issues metadata without changing gameplay, and decide whether a separate project plan is needed.
3. **M2 combat foundation:** only after approval, add separated typed Damage/Health/Hitbox/Hurtbox/invulnerability responsibilities and connect the existing Attack/Dash-Attack frame windows. Do not add combo branches as part of the foundation.
4. **Content after combat foundation:** proceed milestone by milestone toward the fixed scope of two normal enemy types, one elite, three main rooms, one boss arena, one boss, checkpoint/unlock flow, and victory flow. None of these content milestones is authorized or started by this documentation audit.

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
