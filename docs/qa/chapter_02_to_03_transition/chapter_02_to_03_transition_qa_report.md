# Chapter II → Chapter III Transition QA

Date: 2026-07-27

Engine: Godot 4.7.1 Standard (`4.7.1.stable.official.a13da4feb`)

Renderer: GL Compatibility, Apple M4
Viewport: 1280×720

## Commands and actual outcomes

- `Godot --headless --editor --path . --import --quit`: exit 0; no parser, missing-resource, invalid-UID or import error.
- `test_chapter_start_foundation.gd`: PASS — seven Registry entries, Chapters I/II/III-entry ready, MainBootstrap preserved.
- `test_hollow_duchess_main_integration.gd`: PASS — production Boss, doors, CP05, HUD, mirror and reward anchor present.
- `test_chapter_02_to_03_transition.gd`: PASS — four dialogue lines, mirror, reward gate, scene reload, passage and Chapter III entry.
- `test_silent_court_graybox.gd`: PASS — nine rooms, three floors, eleven spawns, fifteen encounters, 38 enemies, one Player/HUD.
- `test_chapter_02_three_floor_route.gd`: PASS — three real-physics/Input Map runs, zero softlocks.
- Ordered deterministic regression: root suite 22/22 and chapter suite 27/27; total 49/49 passed.
- `Godot --path . --script res://chapters/chapter_02_silent_court/scripts/tools/capture_chapter_02_to_03_qa.gd`: exit 0; `CH2_TO_CH3_MAIN_QA: PASS captures=6 bootstrap=1 mirror=1 passage=1 chapter3=1`.

No `SCRIPT ERROR`, `ERROR:`, failed assertion or debugger-red diagnostic was emitted by the final focused, full-regression or graphical QA runs.

## MainBootstrap graphical evidence

| Evidence | File | SHA-256 |
| --- | --- | --- |
| Boss death state | `01_boss_death_main.png` | `7740203a8b06f7f1ef490eb14793dd91edb9887b00ce93481e3334780c5a351d` |
| Death dialogue | `02_death_dialogue_main.png` | `838af45b10610d6be67b8d54b21205c6fa2d334b5f599ab497c53c7c1162fa33` |
| Thirteen mirror cracks | `03_mirror_thirteen_cracks_main.png` | `126a0a6ff1410f03ff644ed0025bfe674a9a68e02ad3beafbe912c6b2bb94efb` |
| Royal Chapel Passage door | `04_royal_chapel_passage_door_main.png` | `26ff77f2cf677f79356cccc479cc2779623eb2b6d96f020fee78ad7b9b2a8e54` |
| Enemy-free Processional Passage | `05_royal_processional_passage_main.png` | `3d5ee488850ab42738369b11534825ea2c8948de743146ca00e682915782ed36` |
| Chapter III Chapel Vestibule entry | `06_chapter_03_vestibule_main.png` | `bd0bb731d3b80b0a0cd93330f4a4370bdb1188d45d7623db2e53d6b29220ef9a` |

All six files are real 1280×720 RGBA screenshots from MainBootstrap routing to the production Chapter II Main, followed by the saved passage and Chapter III entry PackedScenes. The cracks capture selects the real gate renderer's 48% reveal state deterministically; sequence timing itself is covered separately by the runtime test.

## Visual inspection

- The mirror uses thirteen visible radial cracks and opens onto a dark bell-shaped stone door with thirteen grooves.
- The Player is absent from the restored mirror reflection by construction.
- The reward is visibly labeled as a placeholder and is not represented as the final Chapter II weapon.
- The Royal Processional Passage contains no enemy nodes or combat encounter and presents the intended prayer/chapel motifs.
- Shared HUD labels update to the passage and Chapter III vestibule instead of retaining the Silent Ballroom title.
- The Chapter III scene visibly states that it is an entry placeholder with no enemies, encounters or Boss.

## Manual follow-up

- Judge the natural 5–9 second post-Boss presentation cadence without the QA runner's accelerated death timings.
- Walk the corridor normally and judge whether it lands within the intended 15–30 second decompression target.
- Validate the complete CH2_START route as a human; automation covers all three floor routes and the post-Boss transition but does not certify full-chapter pacing or combat fairness.
