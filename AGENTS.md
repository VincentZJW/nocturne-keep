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
