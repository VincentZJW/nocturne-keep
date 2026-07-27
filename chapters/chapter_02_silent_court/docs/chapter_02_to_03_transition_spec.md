# Chapter II → Chapter III Transition Specification

Status: implemented first playable transition with final Chapter II Boss weapon

## Player-facing route

```text
Silent Ballroom Boss defeat
→ four-line death exchange
→ Duchess and phantom hazards clear
→ Ballroom mirror restores and receives thirteen cracks
→ mirror panels separate to reveal the Royal Chapel Passage
→ Crimson Masque Stilettos appear at the fixed reward anchor
→ Player collects and auto-equips the permanent reward
→ E opens the Processional Door
→ Royal Processional Passage (enemy-free)
→ E enters the Chapel Vestibule
→ Chapter III entry placeholder
```

The secret exit is intentionally religious and private rather than another exterior castle gate. The mirror contains no Player reflection during the restored state. The passage is a short decompression space with pointed windows, prayer benches, royal carpet, thirteen bell motifs and no combat encounter.

## Authoritative paths and composition

- F5 authority: `res://scenes/bootstrap/main_bootstrap.tscn`
- Chapter II Main: `res://chapters/chapter_02_silent_court/scenes/level/silent_court.tscn`
- Silent Ballroom room scene: `res://chapters/chapter_02_silent_court/scenes/rooms/silent_ballroom.tscn`
- Mirror/secret-door scene: `res://chapters/chapter_02_silent_court/scenes/transitions/ballroom_mirror_gate.tscn`
- Transition controller: `res://chapters/chapter_02_silent_court/scripts/transitions/chapter_02_to_03_transition_controller.gd`
- Transition data: `res://chapters/chapter_02_silent_court/resources/transitions/chapter_02_to_03_transition_data.tres`
- Enemy-free passage: `res://chapters/chapter_02_silent_court/scenes/transitions/royal_chapel_passage.tscn`
- Chapter III entry: `res://chapters/chapter_03_chapel_of_thirteen_echoes/scenes/level/chapter_03_entry_placeholder.tscn`
- Chapter III Start Profile: `res://chapters/chapter_03_chapel_of_thirteen_echoes/resources/chapter/chapter_03_start_profile.tres`

Production Main nodes:

- `SilentCourt/GameplayWorld/BossArea/HollowDuchess`
- `SilentCourt/GameplayWorld/BossArea/BallroomMirrorGate`
- `SilentCourt/GameplayWorld/BossArea/Chapter02BossWeaponPickupAnchor`
- `SilentCourt/ChapterSystems/Chapter02To03TransitionController`

Chapter III entry contract:

- `Chapter03EntryPlaceholder/SpawnPoints/Chapter03PlayerSpawn`
- `Chapter03EntryPlaceholder/SpawnPoints/chapter_03_start`
- `Chapter03EntryPlaceholder/Checkpoints/Chapter03CP01`
- `Chapter03EntryPlaceholder/CameraBounds`
- `Chapter03EntryPlaceholder/Doors/ChapelSideDoor`
- `Chapter03EntryPlaceholder/NarrativeTriggers/ChapterTitleTrigger`
- `Chapter03EntryPlaceholder/GameplayWorld/Geometry/MainRouteExitPlaceholder`

The entry scene is deliberately labeled as a placeholder. It contains one shared gameplay runtime, safe floor/bounds and no enemies, encounter, Boss or complete Chapter III route.

## Death exchange and presentation timing

The complete exchange is:

1. 夜巡守卫：你认识我？
2. 瑟芙琳：不……但殿下一直在等你。
3. 瑟芙琳：穿过镜后的礼门。
4. 瑟芙琳：十三声忏悔，会替她回答。

The authored Boss death presentation lasts about 3.70 seconds. The mirror reveal is 2.20 seconds, the Processional Door opening is 1.10 seconds, and both cross-scene fades are 0.50 seconds. Player input is restored after the mirror reveal so reward inspection and entry remain voluntary.

## Reward prerequisite

The fixed reward is `Crimson Masque Stilettos / 绯幕礼刺`, Weapon ID `crimson_masque_stilettos`. It is instantiated from its production pickup scene at `Chapter02BossWeaponPickupAnchor`, not from Seraphine's final global position. Collection adds the unique permanent WeaponData to WeaponInventory, auto-equips it through EquipmentManager, updates the HUD/Player SpriteFrames and writes `chapter_02_boss_weapon_collected`.

Before collection, using the door shows:

> 公爵夫人的遗物仍留在舞厅中。

If the Boss has been defeated but the fixed pickup is missing and not owned, the transition controller recreates it at the deterministic anchor. Once owned/collected, it is not recreated and the passage can be opened.

## Runtime state and reload behavior

`ChapterSession` owns the runtime-only story ledger. The transition writes:

- `hollow_duchess_defeated`
- `chapter_02_exit_revealed`
- `chapter_02_boss_weapon_collected`
- `chapter_02_completed`
- `royal_chapel_passage_opened`
- `chapter_03_started`

On a Chapter II scene reload after the Boss defeat, the Boss stays hidden, cleared encounter presentation is restored, the mirror remains revealed, and the uncollected Crimson Masque pickup is reconstructed. After collection, inventory/equipment and the flag persist while no duplicate pickup is spawned. This is process-lifetime session persistence, not a disk-save implementation.

`SceneTransitionManager` owns the fade and PackedScene replacement. It resolves chapter targets through `ChapterRegistry`, records the pending spawn in `ChapterSession`, and never duplicates Player/HUD/session state. Boss code contains no Chapter III path.

## Manual F5 acceptance

1. Set `DebugRunConfig.debug_chapter_start_enabled = true`.
2. Set chapter to `CHAPTER_02_SILENT_COURT` and spawn to `CH2_BOSS`.
3. Press F5; MainBootstrap loads the production Silent Court scene at CP05.
4. Enter the Silent Ballroom and defeat Seraphine.
5. Observe all four lines, the mirror restoration/thirteen cracks, the split panels and secret door.
6. Try E before collecting the weapon and confirm the lore prompt blocks passage.
7. Collect Crimson Masque Stilettos, confirm the acquisition panel plus HUD T3 14/28, press E at the door, cross the enemy-free passage, then press E at its side door.
8. Confirm the Chapter III title card and the safe Chapel Vestibule placeholder.

Human acceptance remains required for the full uninterrupted Chapter II pacing and the intended 15–30 second corridor traversal. Automated coverage proves state, gating, reload recovery and scene composition.
