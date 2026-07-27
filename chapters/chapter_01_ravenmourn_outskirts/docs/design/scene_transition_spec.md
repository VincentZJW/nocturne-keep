# Chapter I Scene Transition Specification

## F5 route

```text
project.godot run/main_scene
  -> res://scenes/cinematics/opening_cinematic.tscn
  -> res://scenes/levels/veilbound_catacomb.tscn
  -> res://chapters/chapter_01_ravenmourn_outskirts/scenes/level/ravenmourn_outskirts.tscn
  -> res://chapters/chapter_01_ravenmourn_outskirts/scenes/transitions/ravenmourn_threshold.tscn (after the existing Boss gate)
```

Opening natural completion and hold-skip share one fade and target. Catacomb natural completion and hold-skip share one story-completion boundary, but neither bypasses dagger recovery or the voluntary exit. The stone-door trigger remains inactive in practice until story plus dagger prerequisites are true. The exit records runtime-only ChapterSession flags, fades, and loads Main. Main's authored Player and `DarkForestTutorialSpawn` both remain `(320,612)`.

`ChapterSession` is a narrow runtime Autoload for cross-scene completion/objective flags only. It owns no movement, combat, enemies, checkpoints or disk save. `reset_revival_state()` and `replay_revival_scene()` are explicit development APIs. A process restart represents a new game and resets the runtime flags.

Player death inside Main never invokes scene transition: the existing DeathSequence and PlayerRespawnController return to the selected Main checkpoint. Castle gate entry keeps its pre-existing text-free transition and is unaffected.
