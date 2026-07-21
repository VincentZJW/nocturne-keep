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
