# Chapter III Edran Art Rework QA

Date: 2026-07-30

Scope: overwrite the existing production art for `The Thirteenth Pontiff, Edran`, `Ossuary Penitent`, and `Choir Husk` without changing combat values, AI, collision shapes, hitboxes, Main routing, or summon limits.

## Runtime result

The formal F5 chain is:

```text
res://scenes/bootstrap/main_bootstrap.tscn
→ res://chapters/chapter_03_chapel_of_thirteen_echoes/scenes/level/chapter_03_route.tscn
→ CH3_BOSS_SUMMON_TEST
→ CH3_BOSS / Ch3BossSanctumRoom
```

The capture run loaded this chain through `MainBootstrap`, activated the saved Boss instance, forced the two production crozier attacks, raised both saved summon scenes through the Boss-owned director, and captured all actors in the formal sanctum.

## Art changes

### Edran crozier

- Replaced the small simplified head with a large open pontifical ring.
- Added thirteen external round seal medallions, central hanging bell, separate black clapper, layered neck, long segmented iron shaft, oxblood grip bands, and a pointed lower finial.
- Re-authored the crozier in every one of Edran's 114 Phase 1 frames. Sweep and thrust keep the same complete head and material hierarchy instead of collapsing into a line.

### Ossuary Penitent

- Rebuilt the silhouette around a skull, hunched broad torso, back reliquary slab, shoulder seals, visible ribs, chains, long arms, oversized asymmetric claws, ragged material, and heavy feet.
- Re-authored 58 frames across 14 production animations. Claw and lunge poses change reach and weight rather than translating the idle frame.

### Choir Husk

- Rebuilt the silhouette around a long cracked mask, cold-blue slit, throat bell, thirteen vertical chest seal nodes, layered ragged robes, long arms, and a suspended lower body.
- Re-authored 50 frames across 11 production animations. Drift has vertical float; aim/shoot/recovery establish a clear casting line and projectile release.

## Forced QA table

| Item | Status | Evidence |
|---|---|---|
| New crozier static design | PASS | `assets/bosses/thirteenth_pontiff_edran/concept_art/pontifical_hollow_bell_crozier_design.png`; `assets/bosses/thirteenth_pontiff_edran/previews/edran_phase_01_sprite_master.png` |
| Crozier idle in Main | PASS | `01_edran_crozier_idle_main.png` |
| Crozier sweep consistency | PASS | `02_edran_crozier_sweep_main.png` |
| Crozier thrust consistency | PASS | `03_edran_crozier_thrust_main.png` |
| Penitent concept identity | PASS | `assets/boss_summons/ossuary_penitent/concept_art/ossuary_penitent_concept_board.png` |
| Penitent production static | PASS | `assets/boss_summons/ossuary_penitent/previews/ossuary_penitent_master_preview.png`; `04_ossuary_penitent_idle_main.png` |
| Penitent attack readability | PASS | `05_ossuary_penitent_claw_main.png` |
| Choir Husk concept identity | PASS | `assets/boss_summons/choir_husk/concept_art/choir_husk_concept_board.png` |
| Choir Husk production static | PASS | `assets/boss_summons/choir_husk/previews/choir_husk_master_preview.png`; `06_choir_husk_idle_main.png` |
| Choir Husk casting readability | PASS | `07_choir_husk_cast_main.png` |
| Mixed summons with Edran | PASS | `08_edran_mixed_summons_main.png` |
| Main/F5 integration | PASS | `EDRAN_ART_REWORK_MAIN_QA | PASS captures=8 route=MainBootstrap boss=true summons=2` |
| Collision/hurtbox stability | PASS | `EDRAN_ART_REWORK | PASS ... collisions_unchanged=true` |
| Output/Debugger red errors | PASS | Exact Godot 4.7.1 capture and headless regression commands exited 0 without red runtime errors |

## Evidence files

- `docs/qa/chapter_03_edran_art_rework/01_edran_crozier_idle_main.png`
- `docs/qa/chapter_03_edran_art_rework/02_edran_crozier_sweep_main.png`
- `docs/qa/chapter_03_edran_art_rework/03_edran_crozier_thrust_main.png`
- `docs/qa/chapter_03_edran_art_rework/04_ossuary_penitent_idle_main.png`
- `docs/qa/chapter_03_edran_art_rework/05_ossuary_penitent_claw_main.png`
- `docs/qa/chapter_03_edran_art_rework/06_choir_husk_idle_main.png`
- `docs/qa/chapter_03_edran_art_rework/07_choir_husk_cast_main.png`
- `docs/qa/chapter_03_edran_art_rework/08_edran_mixed_summons_main.png`

## Exact verification

1. `Godot --headless --path . --script .../generate_edran_phase_01_art.gd` — PASS, 27 animations / 114 frames.
2. `Godot --headless --path . --script .../generate_edran_summon_art.gd` — PASS, 2 actors / 108 frames.
3. `Godot --headless --editor --path . --quit` — PASS, import and script parse.
4. `Godot --headless --path . --script .../build_edran_phase_01_sprite_frames.gd` — PASS, 27 animations / 114 frames.
5. `Godot --headless --path . --script .../build_edran_summon_sprite_frames.gd` — PASS, 2 actors / 108 frames.
6. `test_edran_b1_assets.gd` — PASS.
7. `test_edran_b2_phase_01.gd` — PASS.
8. `test_edran_b3_summons.gd` — PASS.
9. `test_edran_art_rework.gd` — PASS, 222 production frames, Main spawn retained, collision and hurtbox dimensions unchanged.
10. `capture_edran_art_rework_qa.gd` — PASS on OpenGL/Metal Compatibility, 8 formal Main captures.

## Honest boundary

The current repository milestone implements Edran Phase 1 and the two Phase 1 summons. Phase 2 remains a later approved Boss milestone and is not falsely represented by this art pass. No Phase 2 runtime frame was invented, and no B4 gameplay boundary was crossed.
