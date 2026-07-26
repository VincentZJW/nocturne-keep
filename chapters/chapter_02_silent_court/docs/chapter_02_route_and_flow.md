# 第二章路线与流程

Status: Stage 1 route authority

## Critical route map

```text
F5 Debug Bootstrap (planned Stage 2)
  ↓ CH2_START / CP01 (x=384)
[01 Castle Gate Interior 0..2304] SAFE
  ↓ D01
[02 Grey Banner Corridor 2304..6912] E01 → E02 → E03
  ↓ D02
[03 Last Banquet Hall 6912..11520] E04 → E05 → E06 → CP02
  ├─ optional banquet service balcony ─┐
  ↓ D03                               │ future shortcut return
[04 Royal Portrait Gallery 11520..15616] E07 → E08 → memory
  ├─ optional portrait archive
  ↓ D04
[05 Blood-Candle Chapel 15616..19456] E09 → E10 ↑ → E11 → CP03
  ↓ D05
[06 Servant Passage 19456..22784] E12
  ├─ kitchen/store branch E13
  ↓ D06
[07 Old Armory 22784..24832] E14 optional → CP04 → shortcut unlock ─┘
  ↓ D07
[08 Ballroom Antechamber 24832..27520] E15 → CP05 → Boss Door
  ↓ D08
[09 Silent Ballroom 27520..32128] Hollow Duchess space → exit
```

## Main and branch pacing

- Main route is linear and never requires repeated backtracking.
- Optional Branch A: Banquet service balcony, one 128 px cumulative rise and one 176 px gap, returns inside Banquet.
- Optional Branch B: Gallery archive, two 64 px tiers, returns before D04.
- Optional Branch C: Servant kitchen/store path containing E13, reconnects before the Armory.
- Armory shortcut is persistent runtime state and links CP04 back to the safe post-Banquet corridor; it is not required for the first clear.
- Every major combat sequence is followed by at least 320 px of safe horizontal travel; CP02–CP05 sit outside encounter gates and detection zones.

## Door and gate coordinates

Four door categories are planned. No generic Door base exists yet; Stage 3 creates one shared contract with typed `opened`, `closed` and `locked_changed` signals, then composes specialized visuals.

### Normal connection doors

`D01..D08` sit at global X `2304, 6912, 11520, 15616, 19456, 22784, 24832, 27520`. They connect adjacent PackedScenes and stay open during ordinary traversal.

### Encounter gates

Each E01–E15 owns left/right gate anchors at the exact zone bounds in `chapter_02_encounter_matrix.md`. Teaching encounters may leave the entrance open after activation; locked combat rooms use both gates. Gates reopen from one authoritative `encounter_cleared` event and must also reopen if the remaining enemy is removed by a world hazard.

### Shortcut door

`ShortcutDoor_ArmoryToBanquet` has endpoints `(23040,612)` in Old Armory and `(11264,612)` in the post-Banquet safe corridor. It starts locked from the Banquet side, activates only from Armory, records `chapter_02_armory_shortcut=true` in disposable session state, and remains open after death within the run.

### Boss door

`BossDoor_SilentBallroom` is at `(27520,612)`. Its approach trigger is at `(27360,612)`, after CP05. It closes only after the Player crosses into the Ballroom, never when merely activating CP05. It reopens on Boss death and resets on an uncleared death.

## Narrative trigger plan

| Trigger | Position / room | Presentation | Story function |
| --- | --- | --- | --- |
| Chapter title | Room 01 x=520 | bilingual area title, 2.2 s | establishes Silent Court |
| Hollow-night echo | Room 01 x=1320 | blue silhouettes/audio placeholder | court repeats seven years ago |
| Grey banner seal | Room 02 x=2080 local | inspectable Veilbound/Crown joint mark | secret cooperation |
| Last banquet restoration | Room 03 entry x=240 local | intact-table overlay then ruin | frozen Night of Hollow Bell memory |
| Elowen portrait | Room 04 x=1680 local | interaction and close portrait | Elowen knows the Warden |
| Royal key memory | Room 04 x=2940 local | brief silhouettes, no full exposition | Warden entered before |
| Thirteen-toll inscription | Room 05 x=1920 local | altar inscription | points toward Chapter III |
| Servant whisper | Room 06 branch x=2440 local | positional subtitle placeholder | “not an ordinary intruder” clue |
| Armory NPC silhouette | Room 07 x=1120 local | interaction placeholder only | future shop, no shop implementation |
| Duchess entrance | Room 08 x=2480 local | Boss-door trigger | introduces Seraphine |
| Boss final line | Room 09 death | “殿下一直在等你。” | required chapter reveal boundary |

All memory triggers are one-shot per disposable chapter session and must not mutate a future formal save during debug starts.

## Transition and startup plan

Current F5 does not enter Chapter II. Stage 2 must implement the minimum route promised by the prior chapter-start foundation:

1. Keep `project.godot` on the Opening.
2. Add one debug-aware Bootstrap/routing authority before formal flow continuation.
3. Create a saved `chapter_02_start_profile.tres` and valid `silent_court.tscn` before setting `debug_ready=true`.
4. In debug builds, validate selector, scene and spawn; reset disposable session; equip Ravenfang; set 30 coins/full health; then enter Silent Court.
5. In release or on validation failure, fall back to the authored Opening without partial state mutation.

The first-level `ravenmourn_threshold.tscn` remains a visual threshold until a separately approved cross-chapter transition pass. Stage 1 does not change it.

## Stage 2 PackedScene manifest

Stage 2 creates exactly these level/room scenes before any formal enemy AI is added:

```text
res://chapters/chapter_02_silent_court/scenes/level/silent_court.tscn
res://chapters/chapter_02_silent_court/scenes/rooms/01_castle_gate_interior.tscn
res://chapters/chapter_02_silent_court/scenes/rooms/02_grey_banner_corridor.tscn
res://chapters/chapter_02_silent_court/scenes/rooms/03_last_banquet_hall.tscn
res://chapters/chapter_02_silent_court/scenes/rooms/04_royal_portrait_gallery.tscn
res://chapters/chapter_02_silent_court/scenes/rooms/05_blood_candle_chapel.tscn
res://chapters/chapter_02_silent_court/scenes/rooms/06_servant_passage.tscn
res://chapters/chapter_02_silent_court/scenes/rooms/07_old_armory_safe_room.tscn
res://chapters/chapter_02_silent_court/scenes/rooms/08_silent_ballroom_antechamber.tscn
res://chapters/chapter_02_silent_court/scenes/rooms/09_silent_ballroom.tscn
```

The main scene instances the nine rooms and the shared Player/HUD services. Door, encounter, checkpoint, spawn and narrative items remain named anchors/placeholders in Stage 2; their functional scenes belong to Stages 3 and 4.
