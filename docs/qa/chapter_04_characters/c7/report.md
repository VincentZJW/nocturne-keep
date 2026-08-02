# Chapter IV Character C7 Main/F5 QA

Date: 2026-08-02
Engine: Godot Engine 4.7.1 Standard
Renderer: GL Compatibility (OpenGL/Metal graphical capture)

## Result

**PASS for implementation, deterministic runtime contracts and rendered Main integration.**
Human feel/fairness across a complete Chapter IV level remains a manual acceptance item because
the current saved route is the formal character trial, not the final environment chapter.

## Coverage

| Requirement | Status | Evidence |
|---|---|---|
| Seven normal enemies exist as independent scenes | PASS | `scenes/enemies/`; `test_chapter_04_enemy_runtime.gd` |
| Underkeep Executioner elite | PASS | `scenes/enemies/underkeep_executioner.tscn`; `04_executioner_elite_main.png` |
| Normal/elite formal pixel frames | PASS | 544 transparent 96×96 PNGs; role reference sheets |
| Shared combat architecture | PASS | typed config/Poise/projectile/controller; runtime test |
| Ormund Phase I | PASS | `05_ormund_phase_01_main.png` |
| Ormund Phase II | PASS | `06_ormund_phase_02_main.png` |
| Real shared-HP transition | PASS | 560 HP; transition at 308; Boss runtime test |
| Boss attack windows | PASS | windup → active Hitbox → recovery assertions |
| MainBootstrap route | PASS | formal Chapter IV start profile and Main integration test |
| F5 direct Boss routes | PASS | `CH4_BOSS_PHASE_01`, `CH4_BOSS_PHASE_02` |
| Player/HUD/camera preserved | PASS | six 1280×720 Main captures |

## Exact commands and results

```text
/Users/vincentz/Downloads/Godot.app/Contents/MacOS/Godot --headless --editor --path . --quit
PASS — import, script classes and saved resources parsed without missing-resource or parser error.

.../Godot --headless --path . --script res://chapters/chapter_04_drowned_underkeep/tests/characters/test_chapter_04_enemy_runtime.gd
CH4 ENEMY RUNTIME TEST | PASS

.../Godot --headless --path . --script res://chapters/chapter_04_drowned_underkeep/tests/characters/test_soul_gaoler_ormund_runtime.gd
SOUL GAOLER ORMUND TEST | PASS

.../Godot --headless --path . --script res://chapters/chapter_04_drowned_underkeep/tests/characters/test_chapter_04_main_integration.gd
CH4 MAIN INTEGRATION TEST | PASS

.../Godot --path . --script res://chapters/chapter_04_drowned_underkeep/scripts/tests/capture_chapter_04_character_roster_qa.gd
CH4 CHARACTER MAIN QA | PASS captures=6 main=res://chapters/chapter_04_drowned_underkeep/scenes/level/drowned_underkeep.tscn
```

The graphical one-shot capture runner reports renderer resource-cache warnings while the process
shuts down after loading 755 frame textures. These warnings occur after all six files are saved;
they are isolated to forced QA-process teardown and are not emitted by the three deterministic
gameplay/import checks. They are recorded rather than misrepresented as a gameplay pass.

## Render evidence

- `01_humanoid_gaoler_main.png` — Drowned Gaoler and Sewer Maw.
- `02_shield_and_mirefin_main.png` — shield structure and Mirefin silhouette.
- `03_convict_and_bog_toad_main.png` — Convict chain mass and Bog Toad body language.
- `04_executioner_elite_main.png` — elite scale and weapon readability.
- `05_ormund_phase_01_main.png` — closed cage Phase I.
- `06_ormund_phase_02_main.png` — broken cage Phase II at 308/560.

All screenshots are real MainBootstrap-routed 1280×720 frames under this directory.

## Manual acceptance matrix

1. Set DebugRunConfig chapter to `CHAPTER_04_DROWNED_UNDERKEEP`.
2. Use each `CH4_*` spawn ID and press F5.
3. Verify attack telegraphs, collision-safe pull feel, shield routing, water-route readability and
   elite/Boss fairness with direct keyboard input.
4. For Ormund, verify P1 at `CH4_BOSS_PHASE_01` and immediate P2 at `CH4_BOSS_PHASE_02`.
5. Confirm Player Normal/Dash attacks, death/respawn, Health/Stamina HUD and camera remain normal.

## Known boundary

The character roster is complete. Final encounter spacing, environment art, water gameplay and
chapter reward/exit depend on the later Chapter IV level-production milestone.
