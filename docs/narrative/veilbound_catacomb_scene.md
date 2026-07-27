# Veilbound Catacomb Revival Scene

Runtime scene: `res://scenes/levels/veilbound_catacomb.tscn`

Controller: `res://scripts/levels/veilbound_catacomb_controller.gd`

## Composition

- `VeilboundCatacomb/World/SeveredAltar` is the solid central **Severed Altar**.
- `World/Player/RevivalPlayerArt` owns story-only corpse, breath, sit, hands, kneel, stand, unarmed and descending-soul poses. It is independent from the fast combat respawn animation.
- `World/CandleWarden` instances the standalone NPC scene.
- `World/Interactions/DaggerPickup` holds the two visible altar daggers and the E interaction area.
- `World/ArchitectureFront/WallAndPortraitFront` owns the chamber wall, Veiled Order portrait/crest and the transparent door aperture at world `(1298,406,144,248)`.
- `World/StoneDoorBody/DoorOpeningBackdrop` owns the aperture-clipped exterior night at z0; `StoneDoorVisual` owns only the moving rune slab at z20; `DoorFrameFront` masks the aperture edge at z25. Their sibling CollisionShape remains solid until the opening animation completes.
- `World/Interactions/CatacombExitTrigger` changes to Main only after story completion, dagger recovery and door opening.
- Five optional observation Areas cover the Order crest, fallen Veilbound, Soul Mark fragment, broken sarcophagus and broken dagger.

The original native-2D environment contains cold stone courses, sarcophagi, pillars, black cloaks, remains, broken steel, blue soul flames, silver Order marks, floor mist and moonlit forest silhouettes. There are no enemy or combat encounter nodes.

World draw order is explicit and does not use YSort or Parallax: clipped exterior night z0 → wall/portrait facade z5 → Player and Candle Warden z10 → moving slab z20 → fixed front frame z25. HUD and Narrative CanvasLayers remain 6 and 20 respectively. Thus the night can appear only through the carved aperture and cannot cover Player or surrounding masonry.

## Sequence and control

The authored automatic duration is approximately 69 seconds: low procedural bell, 1.2-second fade, soul descent, Soul Mark pulse, twitch/breath/sit, three-line internal monologue, Candle Warden entrance, and 27-line conversation. Enter advances a line; holding Enter or Escape for 0.75 seconds completes the story state without duplicating signals or the NPC.

During the automatic sequence Player is `LOCKED` and physics-paused. Completion enables `CATACOMB_MOVE_ONLY`: horizontal movement remains available while jump, double jump, Attack and Dash stay blocked. Recovering the dagger pickup replaces the unarmed story presentation with the existing armed Player `VisualRoot`. E at the door raises the Candle Warden lantern, lights the runes and opens collision. The player retains control and must walk into the exit.

## Transition

The exit records ChapterSession flags, fades for 0.55 seconds and loads `res://chapters/chapter_01_ravenmourn_outskirts/scenes/level/ravenmourn_outskirts.tscn`. Main begins at `Main/World/DarkForestTutorialSpawn (320,612)`. Later deaths do not reference this scene.
