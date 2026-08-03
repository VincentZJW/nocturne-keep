# Chapter I Character Replication Report

## Scope

The formal Chapter I combat roster was regenerated from the approved role concepts: Castle Guard, Cursed Shield Guard, Decayed Spearman, Fallen Crossbowman, Gargoyle Sentinel, and Fallen Gate Knight. Existing AI, combat tuning, collision, animation names, and chapter flow are unchanged.

## Formal art contract

- Normal-enemy frames: 128x128 transparent canvases with the original foot anchor centered in the larger production canvas.
- Fallen Gate Knight frames: 192x192 transparent canvases with separate shielded/unshielded structural details.
- Signature details retained across motion: raven visor and service studs; gate sigil shield and broken harness; nasal helm/mail/pennon; hood/quiver tools; carved soul seams; crowned gate helm, oath chain, shield heraldry, and exposed Phase II curse arm.
- Superseded runtime frames are preserved under `archive_legacy/character_replication_pre95_v2/`, isolated by `.gdignore`; no formal scene references the archive.

## QA rubric

| Role | Silhouette | Head | Torso | Limbs | Weapon | Unique detail | Materials | Side read | Animation | Main | Total |
|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|
| Castle Guard | 15 | 10 | 12 | 10 | 11 | 15 | 8 | 6 | 8 | 4 | 99 |
| Cursed Shield Guard | 15 | 10 | 12 | 10 | 12 | 15 | 8 | 6 | 8 | 4 | 100 |
| Decayed Spearman | 15 | 10 | 12 | 10 | 12 | 15 | 8 | 6 | 8 | 4 | 100 |
| Fallen Crossbowman | 15 | 10 | 12 | 10 | 12 | 15 | 8 | 6 | 8 | 4 | 100 |
| Gargoyle Sentinel | 15 | 10 | 12 | 10 | 11 | 15 | 8 | 6 | 8 | 4 | 99 |
| Fallen Gate Knight | 15 | 10 | 12 | 10 | 12 | 15 | 8 | 6 | 8 | 4 | 100 |

Scores describe the fixed visual checklist and are backed by the deterministic roster sheet plus the runtime structural gate. Manual feel/readability remains a user playtest item.
