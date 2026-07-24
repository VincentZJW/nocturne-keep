# Veilbound Catacomb Revival Scene

Runtime scene: `res://scenes/levels/veilbound_catacomb.tscn`

Controller: `res://scripts/levels/veilbound_catacomb_controller.gd`

## Composition

- `VeilboundCatacomb/World/SeveredAltar` is the solid central **Severed Altar**.
- `World/Player/RevivalPlayerArt` owns story-only corpse, breath, sit, hands, kneel, stand, unarmed and descending-soul poses. It is independent from the fast combat respawn animation.
- `World/CandleWarden` instances the standalone NPC scene.
- `World/Interactions/DaggerPickup` holds the two visible altar daggers and the E interaction area.
- `World/StoneDoorBody/StoneDoorVisual` owns the rune glow, raised slab and forest threshold presentation; its sibling CollisionShape remains solid until the opening animation completes.
- `World/Interactions/CatacombExitTrigger` changes to Main only after story completion, dagger recovery and door opening.
- Five optional observation Areas cover the Order crest, fallen Veilbound, Soul Mark fragment, broken sarcophagus and broken dagger.

The original native-2D environment contains cold stone courses, sarcophagi, pillars, black cloaks, remains, broken steel, blue soul flames, silver Order marks, floor mist and moonlit forest silhouettes. There are no enemy or combat encounter nodes.

## Sequence and control

The authored automatic duration is approximately 69 seconds: low procedural bell, 1.2-second fade, soul descent, Soul Mark pulse, twitch/breath/sit, three-line internal monologue, Candle Warden entrance, and 27-line conversation. Enter advances a line; holding Enter or Escape for 0.75 seconds completes the story state without duplicating signals or the NPC.

During the automatic sequence Player is `LOCKED` and physics-paused. Completion enables `CATACOMB_MOVE_ONLY`: horizontal movement remains available while jump, double jump, Attack and Dash stay blocked. Recovering the dagger pickup replaces the unarmed story presentation with the existing armed Player `VisualRoot`. E at the door raises the Candle Warden lantern, lights the runes and opens collision. The player retains control and must walk into the exit.

## Transition

The exit records ChapterSession flags, fades for 0.55 seconds and loads `res://scenes/main/main.tscn`. Main begins at `Main/World/DarkForestTutorialSpawn (320,612)`. Later deaths do not reference this scene.
