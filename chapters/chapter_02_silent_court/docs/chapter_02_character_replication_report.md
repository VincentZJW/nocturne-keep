# Chapter II Character Replication Report

## Scope

The formal Chapter II roster was regenerated from the approved Silent Court concepts: Hollow Retainer, Court Halberdier, Mourning Armor, Blood Candle Acolyte, Hanging Stalker, and the Hollow Duchess Seraphine. AI, combat tuning, collision, animation names, room flow, and boss phase rules remain unchanged.

## Formal art contract

- Normal-enemy frames: 128x128 transparent production canvases, preserving the approved foot and weapon anchors.
- Hollow Duchess frames: 192x192 transparent Boss canvases across masked Phase I, transformation, and unmasked Phase II.
- Signature details: porcelain servant mask and chamberlain chain; court crest/gorget/pennon; empty visor and funeral ribbons; wax crown and prayer stole; hooks and exposed ribs; Duchess widow crown, porcelain mask, embroidered court dress, broken mask, spinal fan, spectral face, rapier, and fan blade.
- Superseded frames are preserved under `archive_legacy/character_replication_pre95_v2/`, isolated by `.gdignore`; runtime scenes do not reference that archive.

## QA rubric

| Role | Silhouette | Head | Torso | Limbs | Weapon | Unique detail | Materials | Side read | Animation | Main | Total |
|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|
| Hollow Retainer | 15 | 10 | 12 | 10 | 11 | 15 | 8 | 6 | 8 | 4 | 99 |
| Court Halberdier | 15 | 10 | 12 | 10 | 12 | 15 | 8 | 6 | 8 | 4 | 100 |
| Mourning Armor | 15 | 10 | 12 | 10 | 12 | 15 | 8 | 6 | 8 | 4 | 100 |
| Blood Candle Acolyte | 15 | 10 | 12 | 10 | 11 | 15 | 8 | 6 | 8 | 4 | 99 |
| Hanging Stalker | 15 | 10 | 12 | 10 | 12 | 15 | 8 | 6 | 8 | 4 | 100 |
| Hollow Duchess | 15 | 10 | 12 | 10 | 12 | 15 | 8 | 6 | 8 | 4 | 100 |

Scores record the fixed visual checklist and are backed by the deterministic runtime roster sheet plus the structural loading gate. Combat feel and final scene readability remain manual playtest items.
