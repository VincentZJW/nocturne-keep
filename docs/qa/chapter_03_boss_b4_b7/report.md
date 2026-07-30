# Chapter III Boss B4–B7 forced QA

Date: 2026-07-30

Formal runtime route: `main_bootstrap.tscn -> chapter_03_route.tscn -> CH3_BOSS`

Boss instance: `Ch3BossSanctumRoom/BossActors/ThirteenthPontiffEdran`

## Verdict

| Area | Status | Evidence |
|---|---|---|
| B4 protected transition | PASS | 198 HP clamp, 5.20 s / 11 named stages, input and vulnerability locks, summon cleanup; captures 04–14 |
| Phase 2 structural identity | PASS | independent 94-frame SpriteFrames; empty split face, external ribs/black bell, elongated arms, fused crozier and chain censer; capture 15 |
| Six Phase 2 attacks | PASS | deterministic attack contract plus captures 16–21 |
| Phase-aware damage/Poise | PASS | 0.80 single incoming multiplier, 145 Poise, 0.44 s stagger and 3.50 s protection |
| Summon stress/cleanup | PASS | Phase 2 cap 2, one per type, transition/death cleanup, no loot |
| Intro and titles | PASS | nine-line formal intro and phase title; captures 01–03 and 15 |
| Death sequence | PASS | five stages, all attack volumes and summons close, defeat signal once; captures 22–26 |
| Reward interface | PASS | reliquary collection and chapter-complete flags, with no invented WeaponData; captures 27–28 |
| Chapter IV playable scene | PARTIAL | planned entrance is unlocked, but the repository has no `chapter_04_drowned_underkeep` PackedScene |
| 20-run regression matrix | PASS | 10 Boss wins, 5 player deaths and 5 Phase 2 retries |
| Main/F5 evidence | PASS | 28 new MainBootstrap captures plus 8 earlier B2/B3 Main captures |
| Manual feel/fairness | MANUAL | timing readability and encounter fairness require user playtest |

The implementation itself passes B4–B7. Overall content hand-off remains **PARTIAL only at the Chapter IV boundary**, because a missing next-chapter scene cannot honestly be treated as complete.

## Production asset totals

- Transition: 45 transparent 96×96 frames across 11 animations.
- Phase 2: 94 transparent 96×96 frames across 18 animations.
- Transition SpriteFrames: `res://chapters/chapter_03_chapel_of_thirteen_echoes/assets/bosses/thirteenth_pontiff_edran/animations/edran_phase_transition_sprite_frames.tres`.
- Phase 2 SpriteFrames: `res://chapters/chapter_03_chapel_of_thirteen_echoes/assets/bosses/thirteenth_pontiff_edran/animations/edran_phase_02_sprite_frames.tres`.
- Concept boards: `edran_phase_transition_and_phase_02_board.png` and `edran_phase_02_anatomy_and_weapon_board.png` in the Boss `concept_art/` directory.

## Deterministic verification

| Check | Result |
|---|---|
| B1 asset contract | PASS |
| B2 Phase 1/Main contract | PASS; B4 boundary now complete |
| B3 summon contract | PASS |
| B4–B7 full Boss contract | PASS; `transition=true phase2_attacks=6 death=true reward_interface=true regressions=20` |
| Exact Godot 4.7.1 editor import/parse | PASS |
| Isolated Boss scene | PASS |
| Formal MainBootstrap capture | PASS; `captures=28 route=MainBootstrap transition=true phase2=true death=true reward=true` |

## Main screenshot evidence (36 images)

New B4–B7 Main captures:

1. `01_intro_scripture_main.png`
2. `02_intro_dialogue_main.png`
3. `03_phase_01_ready_main.png`
4. `04_transition_seals_break_main.png`
5. `05_transition_crown_crack_main.png`
6. `06_transition_mask_void_main.png`
7. `07_transition_vestment_split_main.png`
8. `08_transition_chest_open_main.png`
9. `09_transition_rib_frame_main.png`
10. `10_transition_black_bell_main.png`
11. `11_transition_arm_lengthen_main.png`
12. `12_transition_crozier_fuse_main.png`
13. `13_transition_chain_bind_main.png`
14. `14_transition_phase_02_rise_main.png`
15. `15_phase_02_idle_main.png`
16. `16_bell_bound_cleave_main.png`
17. `17_hollow_toll_main.png`
18. `18_censer_chain_judgment_main.png`
19. `19_scripture_burial_main.png`
20. `20_procession_of_the_unburied_main.png`
21. `21_fourteenth_seat_main.png`
22. `22_death_crozier_break_main.png`
23. `23_death_censer_drop_main.png`
24. `24_death_bell_fall_main.png`
25. `25_death_collapse_main.png`
26. `26_death_dissolve_main.png`
27. `27_post_boss_reliquary_main.png`
28. `28_reward_collected_chapter_04_entrance_main.png`

Earlier formal Main continuity evidence:

29. `../chapter_03_boss_b2/01_edran_phase_01_idle_main.png`
30. `../chapter_03_boss_b2/02_edran_pontifical_sweep_active_main.png`
31. `../chapter_03_boss_b2/03_edran_b4_boundary_main.png`
32. `../chapter_03_boss_b3/01_raise_the_absolved_windup_main.png`
33. `../chapter_03_boss_b3/02_ossuary_penitent_telegraph_main.png`
34. `../chapter_03_boss_b3/03_ossuary_penitent_active_main.png`
35. `../chapter_03_boss_b3/04_mixed_summons_active_main.png`
36. `../chapter_03_boss_b3/05_transition_cleanup_main.png`

## Manual F5 acceptance

1. Enable Chapter Debug Start for `CHAPTER_03_CHAPEL_OF_THIRTEEN_ECHOES`.
2. Use `CH3_BOSS` for the full intro and two-phase fight.
3. Use `CH3_BOSS_PHASE_02` for fast Phase 2 iteration, `CH3_BOSS_SUMMON_TEST` for summon pressure and `CH3_POST_BOSS` for reliquary/exit checks.
4. Verify no unavoidable overlap between Boss fields and two summons, Phase 2 attack silhouettes remain readable, death cleanup occurs once and the reward interface unlocks the underkeep entrance.
5. Restore Debug Chapter Start to its default disabled state after testing.
