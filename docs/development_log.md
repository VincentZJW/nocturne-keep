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
