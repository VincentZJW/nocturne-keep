# Save and Session Specification

Status: contract defined; no disk save implemented

## Current state

The project has runtime-only Autoloads for Chapter I flags, currency, owned weapons and equipment. They survive scene changes within one process but are not a formal save file. A process restart starts a new run.

## State domains

| Domain | Owner | Lifetime | Disk persisted |
| --- | --- | --- | --- |
| Authored chapter metadata | `ChapterRegistry` / `ChapterStartProfile` | project | no mutation |
| Debug start preferences | `DebugRunConfig` | process | no |
| Active story/objective flags | current `ChapterSession` | process | no |
| Currency/equipment | focused existing Autoloads | process | no |
| Future formal save | future save service | across processes | planned under `user://` |

Debug start data and formal progress must remain separate. A debug reset may initialize a disposable session from a validated profile, but it must not overwrite a future player save. Release builds must ignore debug routing regardless of saved editor preferences.

## Future application contract

When approved, a chapter-start transaction will validate the target scene and spawn ID, reset only disposable runtime state, apply prerequisite story flags, weapons/equipment, currency, health, boss and shortcut state, then load the scene and place the player. Failure at any validation step falls back to the normal Opening flow without partially applied state.

Stage 2A only defines the typed inputs. It does not apply state, create files under `user://`, or migrate the existing Chapter I Autoloads.
