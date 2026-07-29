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

## Chapter Production Standards / 章节生产规范

Repository naming note: the root guide retains the original “Nocturne Keep”
prototype heading for history; the current project title is *Veil of
Ravenmourn / 鸦泣之帷*. The legacy three-room prototype scope above applies only
to that original prototype milestone. It does not override a later,
user-approved chapter scope; each approved chapter task still has its own
explicit boundary and stop point.

The following documents are permanent repository policy for every new chapter,
chapter expansion, and formal Chapter I/II rework:

1. `docs/production/chapter_scene_workflow.md`
2. `docs/production/chapter_character_workflow.md`
3. `docs/production/chapter_production_checklist.md`
4. `docs/production/chapter_qa_standard.md`

Before any scene, ordinary-enemy, elite-enemy, Boss, important-NPC, or combined
chapter task, read all four documents and record the loaded workflow, approved
stage, owned files, tests, and stop point in `docs/development_log.md`. At the
start of the user-facing work, provide the short **工作流确认** required by the
checklist. A normal task prompt cannot silently waive these standards. A waiver
or change must explicitly identify the affected rule and be approved by the
user; safety, licensing, Main integration, and honest QA evidence remain
mandatory.

Permanent production gates:

1. **Story first:** understand the place, its past, chapter truth, inhabitants,
   Boss relationship, pacing, and adjacent-chapter contrast before design.
2. **Assets before formal assembly:** if a suitable asset does not exist, create
   an original or provenance-safe formal asset in the correct chapter tree.
   Lines, flat rectangles, empty frames, and graybox geometry are not final art.
3. **Concept and runtime parity:** refined concepts do not compensate for crude
   sprites, incomplete animation, weak scene composition, or stale runtime art.
4. **Independent chapter identity:** every chapter needs its own architecture,
   palette, environmental narrative, character roster, Boss identity, and
   signature visual language—not recolored copies of earlier content.
5. **Main/F5 is the authority:** formal content must be reachable through the
   saved `MainBootstrap` route (or its validated Debug Chapter Start). F6,
   preview scenes, screenshots, and isolated test rooms are supporting evidence
   only.
6. **Forced QA:** use `PASS`, `PARTIAL`, or `FAIL`; preserve commands, Main route,
   screenshots/logs, old-reference audit, Output/Debugger result, and manual
   acceptance steps under `docs/qa/`. Placeholder-looking content is `FAIL`.

These gates do not authorize a new milestone or broaden an approved scope. Work
still stops at the approved stage boundary and follows the milestone approval
rules above.

## Mandatory chapter scene workflow (compatibility summary)

The authoritative scene specification is now
`docs/production/chapter_scene_workflow.md`, with completion and evidence gates
defined by `docs/production/chapter_production_checklist.md` and
`docs/production/chapter_qa_standard.md`. The older
`docs/design/chapter_scene_workflow_spec.md` remains a compatibility reference,
not a second authority. These standards apply to every formal Chapter III–VI
scene milestone and to any formal Chapter I/II rework.

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
