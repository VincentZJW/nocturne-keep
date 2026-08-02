# Save and Session Specification

Status: W3 minimum disk progress service implemented; no Continue UI yet

## Current state

The project retains focused runtime Autoloads for chapter flags, currency, owned weapons and equipment. W3 adds `PlayerProgressSaveService`, a narrow disk authority for permanent weapon ownership/equipment and the minimum chapter recovery ledger. It does not own combat, Player movement, UI, currency or chapter gameplay.

## State domains

| Domain | Owner | Lifetime | Disk persisted |
| --- | --- | --- | --- |
| Authored chapter metadata | `ChapterRegistry` / `ChapterStartProfile` | project | no mutation |
| Debug start preferences | `DebugRunConfig` | process | no |
| Active story/objective flags | current `ChapterSession` | process + selected recovery fields | W3 selected fields |
| Currency/equipment | focused existing Autoloads | process | no |
| Permanent weapon ownership/equipment | `PlayerProgressSaveService` | across processes | `user://player_progress_v1.json` |
| Currency | `CurrencyManager` | process | no |

Debug start data and formal progress remain separate. `MainBootstrap` calls `begin_debug_session()` before applying a disposable profile, which disables autosave and leaves the formal file unchanged. A formal New Game clears the previous weapon-progress file, resets runtime state, then enables autosave and writes a clean baseline. Release builds continue to ignore debug routing regardless of editor preferences.

## W3 save schema and API

The version-1 JSON stores only:

- sorted unique owned weapon IDs;
- the equipped weapon ID;
- selected ChapterSession story/completion flags;
- current chapter and recovery spawn identifiers;
- the small legacy opening/revival/reward booleans required by existing routes.

Public service methods are `save_progress()`, `load_progress()`, `clear_progress()`, `begin_new_game()`, `begin_debug_session()` and `enable_formal_persistence()`. Loading validates the schema version, every weapon ID and equipped ownership before mutating runtime state. Inventory restore always injects the starting Veilbound weapon and preserves unique-ledger semantics.

There is intentionally no Continue menu or automatic route selection in W3. `load_progress()` is the tested recovery entry for the future title/menu flow; the current F5 formal path remains an explicit New Game and therefore clears old progress by design.

## Future application contract

The later Continue/title milestone must validate the saved chapter/spawn against `ChapterRegistry`, invoke `load_progress()`, and only then route to the recovered scene. Currency, Health, Boss runtime state and shortcut transactions remain future work and must not be inferred from the W3 weapon-progress file.

Runtime save files are never repository assets and must not be committed.
