# Chapter II encounter matrix — grounded and elevated runtime

Status: finite Main population, 2026-07-27

`SilentCourt/EnemySpawnPoints` is the saved source of truth. `Chapter02EncounterRuntime` groups those typed SpawnPoints under `SilentCourt/GameplayWorld/Enemies/EncounterE##`; it no longer owns a duplicate hard-coded coordinate table.

| Floor / room | Encounter | Ground | Platform | Ceiling/Air | Composition and intent |
| --- | --- | ---: | ---: | ---: | --- |
| F1 Grey Banner | E01 | 1 | 0 | 0 | Retainer ground introduction |
| F1 Grey Banner | E02 | 1 | 1 | 0 | Retainer on mid platform plus ground Retainer |
| F1 corridor end | E03 | 2 | 0 | 0 | Ground Retainer + Halberdier; Armory safe space remains clear |
| F1 Last Banquet | E04 | 1 | 1 | 0 | Ground Armor + reachable upper Crossbowman |
| F1 Last Banquet | E05 | 3 | 0 | 0 | Retainer, Halberdier and Armor on broad floor |
| F1 Last Banquet | E06 | 3 | 0 | 0 | Final ground group bounded to `x=5620..6280`, before the enemy-free stair |
| F2 Portrait Gallery | E07 | 1 | 1 | 0 | Ground Retainer + upper Crossbowman |
| F2 Portrait Gallery | E08 | 0 | 2 | 1 | Mid Retainer, upper Crossbowman, ceiling Stalker |
| F2 Chapel | E09 | 2 | 1 | 0 | Ground Halberdier/Retainer + upper Acolyte |
| F2 Chapel | E10 | 0 | 1 | 1 | Upper Acolyte + ceiling Stalker |
| F2 Chapel | E11 | 1 | 1 | 1 | Ground Halberdier, upper Acolyte, ceiling Stalker |
| F2 Servant Passage | E12 | 2 | 0 | 0 | Retainer + Halberdier bounded to `x=790..1240`; no stair pursuit |
| F3 Antechamber stage 1 | E13 | 1 | 2 | 1 | Ground Halberdier, mid Crossbowman, upper Retainer, air Gargoyle |
| F3 Antechamber stage 2 | E14 | 1 | 1 | 1 | Ground Armor, upper Acolyte, delayed ceiling Stalker |
| F3 Antechamber stage 3 | E15 | 3 | 0 | 0 | Ground Retainer/Halberdier/Armor before the Boss threshold |
| **Total** | **15** | **22** | **11** | **5** | **38 normal enemies; Boss excluded** |

Platform participation is `11 / 38 = 28.9%`; including five explicit Ceiling/Air positions, `16 / 38 = 42.1%` of the roster is no longer authored on a main-floor line. Large Armor units remain on broad ground, Halberdiers are not placed on narrow suspended platforms, Acolytes/Crossbowmen favor elevated positions, and Stalkers/Gargoyle retain ceiling/air starts.

The Ballroom Boss room contains only the Hollow Duchess. E13–E15 form staged Antechamber pressure before the Boss room; their activation ranges are respectively 520, 440 and 300 px, avoiding one simultaneous room-wide wake-up.
