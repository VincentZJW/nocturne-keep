# Chapters I–III Character Replication QA Report

Date: 2026-08-03  
Engine: Godot Engine 4.7.1 Standard (`a13da4feb`)  
Main authority: `res://scenes/bootstrap/main_bootstrap.tscn`

## Result

Automated asset, scene-reference and MainBootstrap validation: **PASS**.  
Unified F5 visual/game-feel acceptance: **PENDING USER PLAYTEST**.

## Formal roster

| Scope | Formal actors | Canvas | Gate |
|---|---:|---:|---|
| Chapter I | Castle Guard, Cursed Shield Guard, Decayed Spearman, Fallen Crossbowman, Gargoyle Sentinel, Fallen Gate Knight | 128 / Boss 192 | PASS |
| Chapter II | Hollow Retainer, Court Halberdier, Mourning Armor, Blood Candle Acolyte, Hanging Stalker, Hollow Duchess Seraphine | 128 / Boss 192 | PASS |
| Chapter III | Bellchain Penitent, Censer Executioner, Silent Chorister, Stained Glass Seraph, Confessional Wraith, Thirteenth Scribe, Choir Husk, Ossuary Penitent, Thirteenth Pontiff Edran | 128 / Boss 192 | PASS |
| Shared core | Night Warden (Veilbound, Ravenfang, Crimson Masque), Candle Warden | 96 / NPC 128 | PASS |

The formal scene paths and animation names are unchanged. Replaced frames therefore propagate through saved SpriteFrames, chapter scenes and Main routes without Inspector texture overrides. Runtime scans found no `archive_legacy` reference.

## Exact verification

- Exact Godot 4.7.1 asset generators for Chapters I–III, Player and Candle Warden — PASS.
- `Godot --headless --editor --path . --import --quit` — PASS; no parser or missing-resource error.
- `test_chapter_01_character_replication_95.gd` — PASS.
- `test_chapter_02_character_replication_95.gd` — PASS.
- `test_chapter_03_character_replication_95.gd` — PASS.
- `test_core_character_replication_95.gd` — PASS.
- `Godot --headless --path . --quit-after 300` — PASS; Bootstrap selected the formal opening cinematic and emitted no red runtime error.
- `git diff --check` — PASS.

## Visual evidence

- `res://docs/qa/chapter_01_character_replication/chapter_01_replication_roster.png`
- `res://docs/qa/chapter_02_character_replication/chapter_02_replication_roster.png`
- `res://docs/qa/chapter_03_character_replication/chapter_03_replication_roster.png`
- `res://docs/qa/core_character_replication/core_character_replication_roster.png`

## Manual F5 acceptance

Use the existing chapter-start profiles to inspect each chapter's normal roster and Boss route. Verify nearest-neighbor edges, foot anchors, left/right flip, full weapon silhouettes, attack telegraphs, hurt/death continuity, Boss phase transitions, Player equipment swaps and the Prologue Candle Warden dialogue gestures. Gameplay balance and AI were intentionally not changed by this pass.
