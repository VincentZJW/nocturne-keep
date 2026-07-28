# Nocturne Keep Agent Guide

## Project contract

- Engine: Godot Engine 4.7.1 Standard.
- Language: statically typed GDScript for gameplay code.
- Rendering: Godot native 2D, GL Compatibility.
- Work milestone by milestone. Do not begin the next milestone without explicit user approval.
- Preserve the fixed scope: three main rooms, one boss arena, two normal enemy types, one elite, one boss.
- Do not use unlicensed or provenance-unknown assets.

## Required workflow

Before each milestone:

1. Read `README.md`, `docs/development_log.md`, `docs/technical_architecture.md`, and this file.
2. Inspect `git status` and existing code.
3. Record goals, files, tests, and scope check in `docs/development_log.md`.

After each milestone:

1. Run the project with the exact Godot 4.7.1 executable when available.
2. Run headless import/parse checks and available automated tests.
3. Record commands, actual results, known issues, and manual acceptance steps.
4. Create one clear Git commit.
5. Stop and wait for approval.

## Mandatory chapter scene workflow

The authoritative specification is `docs/design/chapter_scene_workflow_spec.md`. It applies to every formal Chapter III–VI scene milestone and to any formal Chapter I/II rework. Before beginning chapter scene work, read that specification and record compliance in `docs/development_log.md`.

Formal chapter scene work must pass these gates in order:

1. **Chapter audit gate:** document story purpose, theme, art and architectural language, pacing, enemies, Boss relationship, signature imagery, adjacent-chapter contrast, environmental narrative and reusable versus missing assets.
2. **Asset gate:** create missing original or provenance-safe pixel assets inside the chapter-owned asset tree before formal scene assembly. Geometric blocks, lines, empty frames and flat-color stand-ins are not formal assets.
3. **Scene gate:** compose saved scenes from formal assets with readable foreground, midground and background layers, distinct room purposes, controlled occlusion and combat/traversal readability.
4. **Narrative gate:** each area must communicate its former function, what happened there, why its inhabitants belong there, its relationship to the chapter truth/Boss and its gameplay purpose.
5. **Main gate:** integrate the saved scene and assets into the actual `MainBootstrap`/F5 route. A tool, preview or isolated test scene is not completion evidence.
6. **QA gate:** verify visual completeness, theme coherence, layering, reachability, collisions, transitions, resource references, Main integration and Output/Debugger status; preserve relevant evidence under `docs/qa/`.

Graybox geometry is allowed only during an explicitly named prototype/graybox milestone. It must be labeled as non-final, kept out of formal environment acceptance, and replaced before the chapter scene can be marked complete. If any gate fails—or the scene still reads as placeholder art—the milestone status is not complete.

Chapter-exclusive content belongs under the relevant `res://chapters/chapter_xx_.../` tree, normally using `assets/environment`, `assets/props`, `assets/doors`, `assets/portraits`, `assets/weapons`, `assets/pickups`, `assets/fx`, `assets/ui`, plus `scenes`, `docs` and `resources`. Shared assets require an explicit reuse/provenance note.

Every completed chapter-scene report must use the headings and answer the F5 quality-testing question defined in `docs/design/chapter_scene_workflow_spec.md`.

## Code rules

- Files and signals use `snake_case`; classes and node names use `PascalCase`.
- Explicitly type variables, parameters, return values, signals, and typed arrays.
- Prefer node composition and typed signals over deep inheritance or absolute NodePaths.
- Gameplay scenes must be independently instantiable where practical.
- Gameplay tuning belongs in custom Resources or explicit exported properties, separate from behavior.
- Use Autoload only for genuine cross-scene services; never centralize all gameplay in one singleton.
- Separate hitboxes, hurtboxes, health, state machines, presentation, and session state.
- Treat Godot errors and warnings as failures to investigate, not output to ignore.

## Verification rules

- Never claim a test ran without preserving its command and outcome in the development log.
- Automated checks cover deterministic systems; player feel, encounter fairness, and level readability require manual playtesting.
- Keep evidence under `docs/qa/` when screenshots or reports become relevant.
