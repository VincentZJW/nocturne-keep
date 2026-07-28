# Chapter III Enemy Concept Art Phase 1 QA

Date: 2026-07-28

Engine target: Godot 4.7.1 Standard, GL Compatibility

Scope: six original concepts, six silhouette/proportion sheets, 48 px nearest-neighbor readability only

## Production method and provenance

- Six project-specific raster concepts were created with the built-in image generation workflow from the approved Chapter III art contracts. No third-party/downloaded asset, commercial character, religious portrait or prior-chapter enemy image was used as source material.
- Generation requested deliberate 16-bit-inspired pixel clusters on a uniform green chroma background. The accepted sources were processed locally with the Image Generation skill's chroma-key helper, hard-alpha cleaned, nearest-neighbor fitted to 256×256 and saved under Chapter III ownership.
- Six 192×192 silhouette sheets were deterministically derived from the accepted alpha shapes. Blue-grey is the current 64 px Night Warden scale guide; black is the enemy; ochre is the shared baseline.
- Every QA sheet shows the 256 px concept, its silhouette/proportion sheet and a 48×48 nearest-neighbor preview enlarged by exactly 4×. These QA backgrounds are presentation-only and are not baked into the transparent production PNGs.

## Authenticity manifest

| Enemy | Asset | Dimensions | Bytes | SHA-256 | Alpha bounds | Visible pixels |
|---|---|---:|---:|---|---|---:|
| Bellchain Penitent | concept | 256×256 | 50,080 | `0d3d6d56c415006d75e63c10f2ecb5dcb72ed6e326e74658006ce941ef3b14f0` | 53,10–202,245 | 16,355 |
| Bellchain Penitent | silhouette | 192×192 | 993 | `89573c7ce7c9efd9606232ca95359de84ef548de9e7ed98d10d15ca58c34aad9` | 8,104–183,176 | 3,001 |
| Censer Executioner | concept | 256×256 | 74,833 | `1f0e2fbd4a5c150423f63a0bec4e9bc41b79ad8d0a9167955650d97871e18621` | 25,10–229,245 | 25,141 |
| Censer Executioner | silhouette | 192×192 | 1,175 | `bba1e542581f4bba754190a6c603d27a9f3417550612fe3f6d799af63437e763` | 8,90–183,176 | 4,751 |
| Silent Chorister | concept | 256×256 | 32,521 | `98e468f2066d2b64d4a6dd407803b101e5c33ebdbfa6a35c76ac01d3a0279867` | 74,10–180,245 | 11,781 |
| Silent Chorister | silhouette | 192×192 | 854 | `398b40478e5d377cb8976a69935921ca0422f6ee25f62daee0133ffb202c9c41` | 8,103–183,176 | 2,677 |
| Stained-Glass Seraph | concept | 256×256 | 50,597 | `21f30704e64c58ea556ab025309c6b84199deaafd79d2e0ee4a36997add4cc12` | 12,46–243,245 | 14,607 |
| Stained-Glass Seraph | silhouette | 192×192 | 1,361 | `67969d09683b06bdea70033d29e3c15a06a0b7f6e1424126ccead1c61db413bb` | 8,101–183,176 | 3,566 |
| Confessional Wraith | concept | 256×256 | 40,163 | `ced431377ff0de84f7b26ea2751abfb41001646370405e15b05a619edcda1547` | 73,10–181,245 | 12,972 |
| Confessional Wraith | silhouette | 192×192 | 973 | `4b7292113cd49ff679bb7519264ccb38fb62ea6f34960bad4cd1427cb6eda98e` | 8,86–183,176 | 3,379 |
| Thirteenth Scribe | concept | 256×256 | 35,130 | `02f153e64b210956b994abbf32a14b144468ef425be7bf1c379a4da7da09ac98` | 76,10–178,245 | 10,806 |
| Thirteenth Scribe | silhouette | 192×192 | 942 | `6d1cfb138a6fded600b6fbc7884b6370ee853f13d7b47d38ab265d74872ace93` | 8,92–183,176 | 2,872 |

All twelve assets are RGBA with hard transparent edges; visible and opaque counts are identical. All six silhouette SHA-256 values are unique.

## Visual acceptance

| Enemy | Signature silhouette/object | 48 px result | Phase 2 handoff |
|---|---|---|---|
| Bellchain Penitent | Stooped narrow body, throat bell, separate hand bell and chain | PASS | Preserve pendulum counter-swing and separate bells |
| Censer Executioner | Widest planted body, two-hand chain loop, massive floor censer | PASS | Preserve mass, low drag and ember apertures |
| Silent Chorister | Floating narrow robe, book triangle, broken asymmetric halo | PASS | Preserve footless hover and open-book negative space |
| Stained-Glass Seraph | Wide angular glass wings with gaps and pointed halo | PASS | Preserve lead divisions; do not replace with feathers/gargoyle anatomy |
| Confessional Wraith | Tall booth, grille face, long arms and missing legs | PASS | Booth and wraith remain one authored visual set |
| Thirteenth Scribe | Tallest thin body, face parchment, scroll loop and back ledger | PASS | Preserve writing bend and distinct quill/ledger silhouette |

Human art-direction acceptance is still required before Phase 2A. The 48 px panels validate role/silhouette recognition, not final gameplay animation quality.

## Evidence

- `chapter_03_enemy_concept_overview.png` — all six concepts, silhouettes and 48 px previews.
- `<enemy>_concept_qa.png` — one 768×384 comparison sheet per enemy.
- Production assets remain under `res://chapters/chapter_03_chapel_of_thirteen_echoes/assets/enemies/<enemy>/concept_art/`.

## Exact-engine verification

1. `/Users/vincentz/Downloads/Godot.app/Contents/MacOS/Godot --headless --editor --path . --import --quit` — exit 0 on Godot `4.7.1.stable.official.a13da4feb`; all twelve PNGs imported, with no parser, missing-resource or import error.
2. `/Users/vincentz/Downloads/Godot.app/Contents/MacOS/Godot --headless --path . --script res://chapters/chapter_03_chapel_of_thirteen_echoes/tests/test_chapter_03_enemy_concept_assets.gd` — `PASS files=12 concepts=6 silhouettes=6 unique_silhouettes=6`; final run produced no warning or error.
3. `test_chapter_03_enemy_concept_assets.gd` loads the Godot-imported `Texture2D` resources, verifies exact dimensions, alpha presence, visible content/bounds and six unique silhouette hashes. Its first draft used direct source-image loading and produced an export-compatibility warning; that implementation was replaced before acceptance.
4. `test_chapter_start_foundation.gd` — `PASS (7 entries, Chapters I/II/III-entry ready, Bootstrap preserved)`.
5. Formal F5-equivalent Main smoke: `Godot --path . --quit-after 240` — exit 0; `MAIN BOOTSTRAP | FORMAL NEW GAME | res://scenes/cinematics/opening_cinematic.tscn`; no runtime, script or resource error.

## Scope gate

Phase 1 contains no enemy scene, EnemyData, SpriteFrames, AI, projectile, field, Trial Hall, Encounter or Main spawn. It does not claim that these concepts are visible in F5/Main. Phase 2A may begin only after user approval.
