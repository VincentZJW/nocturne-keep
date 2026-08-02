# Thirteenfold Absolution W3 — WeaponData and progress persistence

Status: implemented and automated QA passed

## Authority Resource

`res://chapters/chapter_03_chapel_of_thirteen_echoes/resources/weapons/thirteenfold_absolution_blades.tres`

| Field | Value |
| --- | --- |
| Weapon ID | `thirteenfold_absolution_blades` |
| English | `Thirteenfold Absolution` |
| Chinese | `十三重赦刃` |
| Type / tier | `dual_daggers` / `3` |
| Normal / Dash | `14 / 28` |
| Player visual | `thirteenfold_absolution` |
| Unique / permanent | `true / true` |
| Story reward / sellable | `true / false` |
| Auto-equip / duplicates | `true / false` |

This is an independent WeaponData Resource. It does not share the Crimson Masque Resource even though the current greybox damage values are intentionally equal.

## Runtime ownership

- `PlayerWeaponInventory` remains the unique owned-ID ledger and now exposes sorted snapshot export plus validated replacement import. The starting Veilbound weapon is always restored.
- `PlayerEquipmentManager` registers the new Resource as the fourth formal weapon. Damage and Player presentation continue to resolve from the equipped WeaponData.
- W2's complete `thirteenfold_absolution_player_sprite_frames.tres` remains the visual authority. Equipping W3 data selects that visual through the existing typed equipment signal.
- Player death, scene replacement and respawn do not reset either Autoload, so ownership/equipment remain intact.

## Version-1 disk progress

`PlayerProgressSaveService` writes JSON only under `user://player_progress_v1.json`. The file contains the sorted unique weapon IDs, equipped ID and the minimum ChapterSession recovery ledger. It validates its schema and registered weapon IDs before restore and suppresses autosave while importing.

Formal New Game clears the old file and creates a clean baseline after runtime reset. Debug Chapter Start calls `begin_debug_session()`, which disables all save writes and preserves any formal file. The W3 test uses an isolated `user://thirteenfold_absolution_w3_test.json` and removes it after verification.

W3 deliberately does not add a title-screen Continue command. The explicit `load_progress()` API is the tested recovery entry for that future flow.

## Stage boundary

Not implemented in W3:

- Edran death reward formation;
- reliquary/pickup scene and E interaction;
- acquisition panel or reward sound;
- formal `chapter_03_boss_reward_collected` grant transaction;
- Underkeep/Chapter IV unlock or a Chapter IV PackedScene.

Those remain W4–W5. `CH3_REWARD_TEST` is still the W2 visual-only preview and does not grant or persist the weapon.
