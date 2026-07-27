# Chapter I Embedded Tutorial Specification

Runtime controller: `res://chapters/chapter_01_ravenmourn_outskirts/scripts/level/tutorial_controller.gd`
Prompt UI: `res://scenes/ui/tutorial_prompt_ui.tscn`

The tutorial is event-driven and belongs to Main, not Player. Its eleven completion flags therefore survive player death and respawn for the life of the current Main instance. It never pauses gameplay and never displays a completion banner.

The tutorial begins only after `Opening Cinematic -> Veilbound Catacomb -> DarkForestTutorialSpawn`. The catacomb permits A/D movement and E interaction but deliberately blocks jump, double jump, Attack, Dash, and Dash Attack. Those verbs remain introduced by the existing Main sequence below; the revival scene does not mark any tutorial step complete.

| Step | Prompt | Completion evidence |
|---:|---|---|
| 1 | A/D or arrows | 72 px horizontal travel |
| 2 | Space jump | `jump_performed` |
| 3 | Space in air | `double_jump_performed` |
| 4 | J normal attack | `action_started(attack)` |
| 5 | Read windup and evade | Tutorial Encounter 02 cleared after the isolated dodge lesson |
| 6 | Two foes | Tutorial Encounter 03 cleared |
| 7 | Shift dash | ground/air dash action begins |
| 8 | Platform combat | Tutorial Encounter 04 cleared |
| 9 | Shield front/back | shield hit or Tutorial Encounter 05 cleared |
| 10 | J during Dash | `action_started(dash_attack)` |
| 11 | Shift in air | Air Dash seen and player reaches x ≥ 2480 |

The small bilingual panel is top-centered, semi-transparent, responsive, and independent of Health/Stamina and Debug HUD. `reset_tutorial_progress()` and `replay_opening_cinematic()` are explicit development APIs; they are not player-facing progression or save systems.

The authored area adds a fallen log, launch platform, and air-dash landing platform. Ground remains available below the air-dash lesson, preventing a tutorial soft lock.
