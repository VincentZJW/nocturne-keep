# First Level Encounter Specification

Version: 1.2
Last updated: 2026-07-24

The gameplay Main uses eighteen one-shot ActivationAreas and exactly thirty-four normal enemies before the separate castle-bridge Boss encounter. F5 reaches it through Opening → Catacomb Revival → Main. The exact current group composition is the authoritative table below; the earlier seven-group/18-enemy gray box has been retired.

The encounter sequence now sits inside a saved visual progression without changing any activation geometry or roster:

- Groups01..03 use the `Dark Forest Outskirts` language: earth/cobble road, tangled vegetation, broken rural props, moonlit tree boundary and twisted trunks.
- Groups03..05 form the overlapping `Castle Frontier`: vegetation recedes while a broken watch post, low walls, iron obstruction remains and three distant spires appear.
- Groups05..07 retain the fortified late approach, now visually connected to the preceding ruins instead of starting from an empty black field.
- The Boss remains the only hostile actor on the moat bridge. After death, the fixed reward appears safely at `(6210,592)`; the gate opens normally but entry waits for Ravenfang collection.

Every environment renderer is visual-only and ordered behind Player/enemy instances. Shield routes, Spearman thrust lanes, Crossbow sightlines, Gargoyle dive reads and safe spaces are unchanged by the loot/equipment milestone.

First appearances isolate each new mechanic before combinations. PlatformB/C/D top surfaces are y=500/504/508 and `GargoylePerch` is y=492; all are now full solid 24-pixel stone bodies, reached from their edges rather than passed through from below. Crossbowmen retain centered edge margins and clear horizontal sightlines. Shield Guards still have room to circle, Spearmen retain a full thrust length, and the solid Floor-to-Bridge route remains the no-Air-Dash route into every encounter and the Boss fight.

The Boss segment is saved at `World/CastleEntranceArea`: checkpoint `(5480,612)`, continuous bridge x=5560..6360, trigger x=5780, Boss `(6120,596)`, visible rear barrier x=5420, and castle gate x=6400. Only the Boss occupies the bridge; its logical movement range is x=5650..6320. The barrier leaves the checkpoint and marked 40-pixel moat entry gap inside the live arena so the moat death/reset path remains testable.

The Group06/07 approach now shares two visual-only saved Main renderers: `World/LateLevelApproachArt` supplies layered sky, clouds, far towers, broken walls and cold/warm Gothic windows, while `World/LateLevelSurfaceDetails` adds stone courses, platform joints, rubble, sparse weeds and chains. No ActivationArea, enemy instance, platform/floor collider, sightline, camera bound or encounter count changed. The non-blocking `World/RavenmournArchway` at `(5420,640)` names the destination and provides a clear pre-Boss landmark without narrowing the route.

## Chapter I 34-enemy expansion

Source scene: `res://chapters/chapter_01_ravenmourn_outskirts/scenes/encounters/first_level_encounters.tscn`
Main node: `Main/World/Encounters`

Normal-enemy contract: **34 enemies, 18 EncounterGroups, 27 mainline, 7 optional.** The Fallen Gate Knight is excluded. Each group starts with AI disabled and activates once when Player enters its authored Area2D.

| Region | Groups | Guard | Shield | Spear | Crossbow | Gargoyle | Total | Optional |
|---|---:|---:|---:|---:|---:|---:|---:|---:|
| Tutorial | 6 | 7 | 1 | 0 | 0 | 0 | 8 | 0 |
| Dark Forest | 5 | 4 | 1 | 2 | 1 | 2 | 10 | 2 |
| Castle Outskirts | 4 | 3 | 2 | 2 | 2 | 0 | 9 | 2 |
| Castle Approach | 3 | 0 | 1 | 2 | 2 | 2 | 7 | 3 |
| **Total** | **18** | **14** | **5** | **6** | **5** | **4** | **34** | **7** |

## Exact Encounter composition

| Encounter | Route | Composition |
|---|---|---|
| TutorialEncounter01 | mainline | Guard ×1 |
| TutorialEncounter02 | mainline | Guard ×1 |
| TutorialEncounter03 | mainline | Guard ×2 |
| TutorialEncounter04 | mainline | Guard ×1 |
| TutorialEncounter05 | mainline | Shield ×1 |
| TutorialEncounter06 | mainline | Guard ×2 |
| ForestEncounter01 | mainline | Guard ×1, Spear ×1 |
| ForestEncounter02 | mainline | Guard ×1, Crossbow ×1 |
| ForestEncounter03 | mainline | Guard ×1, Gargoyle ×1 |
| ForestOptional01 | optional | Guard ×1, Gargoyle ×1 |
| ForestEncounter04 | mainline | Shield ×1, Spear ×1 |
| OutskirtsEncounter01 | mainline | Guard ×1, Shield ×1 |
| OutskirtsEncounter02 | mainline | Spear ×1, Crossbow ×1 |
| OutskirtsEncounter03 | mainline | Guard ×2, Crossbow ×1 |
| OutskirtsOptional01 | optional | Shield ×1, Spear ×1 |
| ApproachEncounter01 | mainline | Spear ×1, Gargoyle ×1 |
| ApproachEncounter02 | mainline | Shield ×1, Crossbow ×1 |
| ApproachOptional01 | optional | Crossbow ×1, Spear ×1, Gargoyle ×1 |

Optional groups are placed on elevated routes. Mainline groups are separated by short recovery stretches and cap simultaneous authored group size at three. Activation is one-shot and local: enemies begin with AI and detection disabled; crossing that group's Area2D activates only the group. Authored groups expose an attack cap of two by default and three for the final optional mix. The approach ends before the Boss checkpoint, leaving the Boss bridge as a quiet zone with zero normal enemies. `EncounterGroup` emits activation and clear signals for tutorial and QA consumers without owning tutorial progression.

## Pacing intent

- Tutorial: one mechanic at a time; final two-guard test.
- Forest: pair fundamentals with first ranged/aerial pressure.
- Outskirts: shield, spear, and crossbow combinations.
- Approach: no basic Guard filler; specialized threats prepare the Boss.

These values are a composition baseline, not proof of encounter fairness. Full-combat and optional-route feel require manual playtesting.
