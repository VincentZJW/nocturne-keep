# Development Log

## M0 — Environment and repository initialization

Date: 2026-07-20
Status: complete — awaiting approval for M1

### Preflight

- Repository audit: directory was empty; no Git metadata or user files were present.
- Godot discovery: PATH aliases `godot` and `godot4` were absent; application found at `/Users/USER/Downloads/Godot.app`.
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
