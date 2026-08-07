# Chapter IV Q4 / BOSS4 Main QA

Date: 2026-08-05
Engine: Godot 4.7.1 Standard (`a13da4feb`)
Renderer: OpenGL Compatibility on Apple M4
Main authority: `res://scenes/bootstrap/main_bootstrap.tscn`

Result: PASS — 13 original 1280×720 Boss-flow frames plus the Final Lock interaction regression frame; no red runtime/script/resource error.

| Frame | Evidence |
|---|---|
| 00 | Final Lock Approach saved E prompt visible beside the formal east gate; visible Main run entered Area 12 after E |
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

The 2026-08-07 regression additionally starts MainBootstrap at `CH4_AREA_11` and drives the actual Input Map action through Area 12 and the now-reachable Area 13 soul-lock trigger into the formal Area 14 Boss room. This prevents isolated-room or direct private-swap tests from masking an inaccessible saved gate.
