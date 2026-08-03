# Chapter IV Scene Production S1 QA

- Date: 2026-08-03
- Milestone: `CH4-S1`
- Result: **PASS — internal production gate**
- Manual gate: user visual acceptance of the five concept boards
- Runtime implementation: intentionally not started

## Deliverables

| Check | Result | Evidence |
|---|---|---|
| Chapter-wide visual identity | PASS | `res://chapters/chapter_04_drowned_underkeep/assets/concept_art/environment/chapter_04_environment_visual_identity.png` |
| Early route concept | PASS | `res://chapters/chapter_04_drowned_underkeep/assets/concept_art/environment/chapter_04_early_route_concept.png` |
| Middle route concept | PASS | `res://chapters/chapter_04_drowned_underkeep/assets/concept_art/environment/chapter_04_middle_route_concept.png` |
| Late route concept | PASS | `res://chapters/chapter_04_drowned_underkeep/assets/concept_art/environment/chapter_04_late_route_concept.png` |
| Boss and memory route concept | PASS | `res://chapters/chapter_04_drowned_underkeep/assets/concept_art/environment/chapter_04_boss_memory_route_concept.png` |
| 17-area narrative matrix | PASS | `res://chapters/chapter_04_drowned_underkeep/docs/chapter_04_scene_environment_s1.md` |
| S2 asset production manifest | PASS | `res://chapters/chapter_04_drowned_underkeep/docs/chapter_04_environment_asset_manifest_s1.md` |
| Prompt/provenance/hash manifest | PASS | `res://chapters/chapter_04_drowned_underkeep/docs/chapter_04_environment_concept_manifest_s1.md` |

All five boards are original 1536×1024 RGB PNG files. Exact SHA-256 hashes and the complete final prompt set are preserved in the concept manifest.

## Exact verification

```text
/Users/vincentz/Downloads/Godot.app/Contents/MacOS/Godot --version
4.7.1.stable.official.a13da4feb

/Users/vincentz/Downloads/Godot.app/Contents/MacOS/Godot --headless --path . --import
PASS — five concept PNGs imported; exit 0

/Users/vincentz/Downloads/Godot.app/Contents/MacOS/Godot --headless --path . --script res://chapters/chapter_04_drowned_underkeep/tests/characters/test_chapter_04_enemy_runtime.gd
CH4 ENEMY RUNTIME TEST | PASS

/Users/vincentz/Downloads/Godot.app/Contents/MacOS/Godot --headless --path . --script res://chapters/chapter_04_drowned_underkeep/tests/characters/test_chapter_04_main_integration.gd
CH4 MAIN INTEGRATION TEST | PASS

/Users/vincentz/Downloads/Godot.app/Contents/MacOS/Godot --headless --path . --script res://chapters/chapter_04_drowned_underkeep/tests/characters/test_soul_gaoler_ormund_runtime.gd
SOUL GAOLER ORMUND TEST | PASS

/Users/vincentz/Downloads/Godot.app/Contents/MacOS/Godot --headless --path . --quit-after 180
MAIN BOOTSTRAP | FORMAL NEW GAME | res://scenes/cinematics/opening_cinematic.tscn
PASS — exit 0

rg -n "assets/concept_art/environment|chapter_04_.*_concept\\.png" --glob '*.tscn' --glob '*.tres' --glob '*.gd' .
PASS — no matches
```

## Scope and regression result

- Concept boards are references only and are not runtime scenery.
- No formal room, environment sprite, collision, water/door logic, Encounter manifest, enemy/Boss data, tuning or Main route was modified.
- Existing Chapter IV enemies, Ormund and Main registration remain valid.
- S2 must create low-resolution production pixel assets from the manifest rather than downscaling these concept boards.

## Manual visual acceptance

Review the five boards for the intended progression:

1. chapel runoff and intake oppression;
2. prison ecology and contaminated cisterns;
3. soul-processing institution and monumental locks;
4. Ormund's cage arena;
5. released memory water leading toward Chapter V.

Approval of this visual direction is the only remaining S1 gate. No S2 production work has begun.
