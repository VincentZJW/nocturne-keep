# Chapter II encounter matrix — three-floor runtime

Status: finite Main population, 2026-07-27

`Chapter02EncounterRuntime` creates every actor below under `SilentCourt/GameplayWorld/Enemies/EncounterE##`. Each saved definition stores a global foot position; the runtime applies the actor-origin offset once and activates only groups within 720 px X / 430 px Y of Player. Vertical filtering prevents another floor from waking at the same X.

| Floor | Encounters | Enemy count | Focus |
| --- | --- | ---: | --- |
| F1 | E01–E06 | 13 | Retainer teaching, Halberdier spacing, Armor/Shield weight; E06 remains on safe banquet ground before the short-stair transition |
| F2 | E07–E12 | 15 | Stalker ceiling anchors, Acolyte support, Crossbow/Gargoyle pressure |
| F3 | E13–E15 | 10 | compact mixed-role final examinations before CP05 |
| Total | 15 | 38 | Boss excluded |

Composition counts are defined centrally in `scripts/level/chapter_02_encounter_runtime.gd`; no room owns an enemy instance. Grounded scenes use surface anchors, Hanging Stalkers use explicit ceiling positions and Gargoyles use explicit air positions.

Stage 1 floor-transition replacement preserves all 15 groups and 38 normal enemies. Only E06 and E12 anchors invalidated by removal of the two long ramps were moved to existing flat floor surfaces; comprehensive stuck-point and encounter redistribution work remains a separate approved stage.

Activation does not create infinite spawns, cross-floor pursuit or global encounter state. Death/loot remain on the existing enemy components. The Hollow Duchess is separately composed at `GameplayWorld/BossArea/HollowDuchess` and is the only actor in the Boss fight lane.
