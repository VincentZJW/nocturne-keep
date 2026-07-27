# Chapter I Opening Cinematic Script

Runtime source: `res://resources/narrative/opening_cinematic_timeline.tres`  
Scene: `res://scenes/cinematics/opening_cinematic.tscn`  
Formal entry: `res://scenes/bootstrap/main_bootstrap.tscn` → Opening
Authored duration: 70.2 seconds including inter-shot fades.

| Shot | Duration | Image direction | Narrative purpose |
|---:|---:|---|---|
| 1 | 8 s | Northern wilds, distant Ravenmourn, circling crows | Establish isolation and destination. |
| 2 | 8 s | The Black Bell suspended in darkness | Introduce the curse's icon. |
| 3 | 9 s | Bell toll, broken concentric waves | Begin The Night of Hollow Bells. |
| 4 | 8 s | Castle and land overtaken by pale curse | Establish Veilbound catastrophe. |
| 5 | 9 s | Veiled Order silhouettes entering, then falling | Show the failed mission seven years ago. |
| 6 | 8 s | Hooded survivor awakening, Soul Mark and ghost echo | Reveal protagonist connection without explaining it. |
| 7 | 7 s | Fragmented helmet, dagger, hand and bell memories | Make amnesia concrete. |
| 8 | 9 s | The Night Warden departs toward the castle | Transfer intent to the player. |

All shots use bilingual Chinese/English subtitles from the timeline resource. ESC or Enter must be held for 0.75 s; the skip affordance unlocks only after 1.5 s. Skip and natural completion stop the timer and both active Tween channels, fade to black, record Opening completion, and load `res://scenes/levels/veilbound_catacomb.tscn`. The cinematic scene contains no Player, HUD, enemy, or AI nodes; Main is reached only through the catacomb exit.

The art is native Godot 2D drawing, deliberately limited and graphic rather than a pre-rendered video. This keeps the sequence editable, licensed, and deterministic.
