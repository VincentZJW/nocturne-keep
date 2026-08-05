# Chapter IV Q4 / BOSS4 Main QA

Date: 2026-08-05
Engine: Godot 4.7.1 Standard (`a13da4feb`)
Renderer: OpenGL Compatibility on Apple M4
Main authority: `res://scenes/bootstrap/main_bootstrap.tscn`

Result: PASS — 13 distinct 1280×720 MainBootstrap frames; no red runtime/script/resource error.

| Frame | Evidence |
|---|---|
| 01 | Soul Lock gate closed in the formal antechamber |
| 02 | Player locked during the bilingual Ormund intro |
| 03 | Phase 1 HUD and safe combat start |
| 04 | Phase 1 active attack presentation |
| 05 | Phase 2 body/arena state and HUD |
| 06 | Phase 2 active attack presentation |
| 07 | death collapse with combat stopped |
| 08 | final soul release before reward unlock |
| 09 | one unclaimed Broken Chain reliquary placeholder |
| 10 | collected/empty reward state and unlocked passage |
| 11 | enemy-free Hall of Drowned Memories; transition-safe fragment controller |
| 12 | formal E-interaction memory exit to Chapter V |
| 13 | Chapter V placeholder entered at `CH5_START` |

The final Chapter IV reward design is intentionally unresolved. Frame 09 labels it as an unnamed placeholder and contains no final WeaponData or balance values.

SHA-256 values were checked after the final GUI capture; all images have unique hashes. The authoritative hashes are reproducible with:

`shasum -a 256 docs/qa/chapter_04_q4_boss_flow/*.png`

Repeated route stress also passed after the final capture: checkpoint `10`, gate `20`, intro/retry/death `10` each, unclaimed reward reload `5`, reward collect `10`, repeated interaction `100`, memory/CH5 handoff `10`.
