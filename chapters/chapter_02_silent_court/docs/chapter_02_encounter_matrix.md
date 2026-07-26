# 第二章 Encounter 矩阵

Status: Stage 1 coordinate and composition authority

All positions use the global route coordinates defined in `chapter_02_room_metrics.md`. Zone bounds become `ActivationArea` plus left/right gate anchors in Stage 4. No encounter is active outside its room.

| ID | Room / global X zone | Composition | Count | Limit | Gate / pacing rule |
| --- | --- | --- | ---: | ---: | --- |
| E01 | Corridor `2752..3504` | Retainer ×1 | 1 | 1 | teaching; no entrance lock |
| E02 | Corridor `3968..5120` | Retainer ×2 | 2 | 2 | second enemy wakes 0.45 s after first |
| E03 | Corridor `5568..6560` | Retainer ×1, Halberdier ×1 | 2 | 2 | full gate; first mixed-role lesson |
| E04 | Banquet `7232..8384` | Retainer ×2, Halberdier ×1, returning Shield Guard ×1 | 4 | 2 | wide room; only two high-pressure attackers |
| E05 | Banquet `8672..9792` | Mourning Armor ×1, Retainer ×1 | 2 | 2 | heavy tutorial; Retainer delayed 0.60 s |
| E06 | Banquet `10112..11200` | Mourning Armor ×1, Halberdier ×1, Retainer ×1 | 3 | 2 | CP02 is beyond the right gate |
| E07 | Gallery `12160..12992` | Hanging Stalker ×1 | 1 | 1 | ceiling tell starts after Player is 160 px inside |
| E08 | Gallery `13632..15104` | Stalker ×2, returning Crossbowman ×1 | 3 | 2 | Stalker drops separated by ≥0.90 s |
| E09 | Chapel `15936..16672` | Acolyte ×1, Retainer ×1 | 2 | 2 | Acolyte first, Retainer positioned below |
| E10 | Chapel `16736..17920` | Stalker ×1, Acolyte ×1, returning Gargoyle ×1 | 3 | 2 | vertical lanes; no simultaneous Stalker/Gargoyle dive |
| E11 | Chapel `18016..19104` | Acolyte ×1, Halberdier ×1, Retainer ×1 | 3 | 2 | CP03 beyond right gate |
| E12 | Passage `19904..20896` | Retainer ×1 | 1 | 1 | short close-range rhythm reset |
| E13 | Kitchen branch `21120..22464` | Halberdier ×1, Stalker ×1 | 2 | 2 | optional; branch clear never locks main route |
| E14 | Armory branch `23680..24576` | Mourning Armor ×1, Acolyte ×1 | 2 | 2 | optional elite; safe-room center isolated by gate |
| E15 | Antechamber `25152..26368` | Mourning Armor ×1, Halberdier ×1, Acolyte ×1 | 3 | 2 | last ordinary fight; 664 px clear path to CP05 |

## Totals

- Hollow Retainer 11
- Court Halberdier 6
- Mourning Armor 4
- Blood-Candle Acolyte 5
- Hanging Stalker 5
- Returning shared enemies 3
- **Total 34 ordinary enemies across 15 finite encounters**

## Activation and reset contract

- Teaching groups contain at most two actors; ordinary groups at most three; E04 is the only four-actor group and has two low-pressure Retainers plus attack arbitration limit 2.
- Every group is finite and hand-authored. There is no spawn loop, global pursuit or cross-room target retention.
- Encounter activation enables only its own enemies and gates. `encounter_cleared` fires once when all HealthComponents are dead/removed, including hazard removal.
- Optional E13/E14 never blocks a main-route door or required checkpoint.
- Death reload/reset restores uncleared encounters to authored spawn state. Cleared-state persistence is a Stage 3/4 runtime design decision and must remain separate from formal disk save.
- Acolyte buffs and Stalker telegraphs are scoped to their group and are cleaned on reset.

## Spawn-point planning

Stage 2 creates placeholder `Marker2D` nodes named `E##_Spawn_##_<Role>`. Stage 4 assigns placeholder PackedScenes; Stage 7 replaces them with formal enemy scenes. Spawn points stay at least 128 px from activation edges and never overlap doors, checkpoints or each other. Grounded heavy/long-weapon actors require 256 px clear horizontal footing; ceiling anchors require 420 px clear vertical space.
