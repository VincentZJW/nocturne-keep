# Enemy and Boss Art Rework Stage 0 Audit

Date: 2026-07-28
Scope: read-only audit of Chapters I–III; implementation is authorized only for Chapter III in Stage 1.

## Runtime and rendering baseline

- F5 entry: `res://scenes/bootstrap/main_bootstrap.tscn`.
- Chapter III runtime target: `res://chapters/chapter_03_chapel_of_thirteen_echoes/scenes/level/chapter_03_entry_placeholder.tscn`.
- Design viewport: 1280×720; canvas-items stretch; project default texture filtering is Nearest (`0`).
- Enemy visuals use `AnimatedSprite2D`; enemy scenes own chapter-local or shared `SpriteFrames` resources. The Player and current normal-enemy gameplay canvases are 64×64.
- The audit distinguishes asset existence from quality and Main usage. A PNG on disk is not considered implemented unless the active enemy scene and Main route resolve to it.

## Chapter I — Ravenmourn Outskirts

| Runtime role | Scene/resource ownership | Current Main use | Stage 0 finding |
|---|---|---|---|
| Cursed Castle Guard | `chapters/chapter_01_ravenmourn_outskirts/scenes/enemies/castle_guard.tscn` | Yes | 64 px generated set; requires later Stage 2 visual review/rework |
| Cursed Shield Guard | `shared/scenes/enemies/cursed_shield_guard.tscn` | Yes | Shared shield/unshielded sets and shield FX exist; provenance and silhouette quality need Stage 2 review |
| Decayed Spearman | `chapters/chapter_01_ravenmourn_outskirts/scenes/enemies/decayed_spearman.tscn` | Yes | 64 px generated set; later Stage 2 rework candidate |
| Fallen Crossbowman | `shared/scenes/enemies/fallen_crossbowman.tscn` | Yes | Shared set used by more than one chapter; later rework must preserve shared-reference consumers |
| Gargoyle Sentinel | `shared/scenes/enemies/gargoyle_sentinel.tscn` | Yes | Current visual benchmark is stronger than early geometric soldiers; still requires formal Stage 2 audit |
| Fallen Gate Knight (Boss) | `chapters/chapter_01_ravenmourn_outskirts/scenes/boss/fallen_gate_knight.tscn` | Yes | Large shielded/unshielded multi-animation set exists; later Boss rework must cover all phases and shield-damage overlays |

Chapter I has five normal/special enemy roles and one Boss in the formal route. This milestone does not edit any of them. Existing user-owned dirty changes in Chapter I/shared configs, SpriteFrames, scene and QA images remain excluded.

## Chapter II — The Silent Court

| Runtime role | Scene/resource ownership | Current Main use | Stage 0 finding |
|---|---|---|---|
| Hollow Retainer | `chapters/chapter_02_silent_court/scenes/enemies/hollow_retainer.tscn` | Yes | Chapter-local 64 px set; later Stage 3 rework candidate |
| Court Halberdier | `chapters/chapter_02_silent_court/scenes/enemies/court_halberdier.tscn` | Yes | Chapter-local thrust/sweep/shaft sets exist; later Stage 3 review |
| Mourning Armor | `chapters/chapter_02_silent_court/scenes/enemies/mourning_armor.tscn` | Yes | Chapter-local heavy armor set; later Stage 3 review |
| Blood-Candle Acolyte | `chapters/chapter_02_silent_court/scenes/enemies/blood_candle_acolyte.tscn` | Yes | Chapter-local caster set and projectile presentation; later Stage 3 review |
| Hanging Stalker | `chapters/chapter_02_silent_court/scenes/enemies/hanging_stalker.tscn` | Yes | Chapter-local hang/drop/retreat set; later Stage 3 review |
| Fallen Crossbowman | shared Chapter I scene | Yes | Reused shared role, not a distinct Chapter II art set |
| Gargoyle Sentinel | shared Chapter I scene | Yes | Reused shared role, not a distinct Chapter II art set |
| Hollow Duchess, Seraphine (Boss) | `chapters/chapter_02_silent_court/scenes/boss/hollow_duchess.tscn` | Yes | Phase 1, transformation and unmasked Phase 2 SpriteFrames exist; Stage 3 must rework and validate every phase together |

Chapter II has five chapter-exclusive normal roles, two shared returning roles and one multi-phase Boss. This milestone does not edit any Chapter II runtime asset.

## Chapter III — Chapel of Thirteen Echoes

| Role | Concept/silhouette | Runtime frames before Stage 1 | Scene/Main reference | Audit result |
|---|---|---:|---|---|
| Bellchain Penitent | 256×256 + 192×192 | 70 | saved scene + Main | concept PASS; runtime FAIL |
| Censer Executioner | 256×256 + 192×192 | 71 | saved scene + Main | concept PASS; runtime FAIL |
| Silent Chorister | 256×256 + 192×192 | 69 | saved scene + Main | concept PASS; runtime FAIL |
| Stained-Glass Seraph | 256×256 + 192×192 | 67 | saved scene + Main | concept PASS; runtime FAIL |
| Confessional Wraith | 256×256 + 192×192 | 71 | saved scene + Main | concept PASS; runtime FAIL |
| Thirteenth Scribe | 256×256 + 192×192 | 67 | saved scene + Main | concept PASS; runtime FAIL |

The concepts already communicate the approved role direction and are retained as authoritative art sources. The 415 Phase 2 runtime frames fail the new acceptance layer: representative idle and active frames use rectangular torsos/heads, straight-line equipment and insufficient pose separation. Some active frames are nearly indistinguishable from idle. This is the exact Stage 1 replacement target.

## Stage 1 replacement decision

- Archive every old Chapter III runtime PNG by role under `reference/deprecated_phase_2/sprites/`.
- Preserve the approved concept and silhouette files; add a formal action-reference triptych derived from each new production set.
- Replace all 415 original runtime paths with role-specific layered pixel art so the existing SpriteFrames, AI timing and scene contracts remain stable.
- Populate each role's `effects/` and `docs/` with actual production references/notes.
- Add deterministic art-integrity checks, static concept-vs-old-vs-new boards, six Main captures, six attack captures, a combination capture and a saved Trial Hall alias.
- Do not begin Chapter I or II replacement until the user accepts the Chapter III method and evidence.
