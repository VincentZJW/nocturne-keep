# Chapter III Edran elemental magic forced QA

Date: 2026-07-30

Formal route: `res://scenes/bootstrap/main_bootstrap.tscn -> chapter_03_route.tscn -> CH3_BOSS`
Boss node: `Ch3BossSanctumRoom/BossActors/ThirteenthPontiffEdran`

## Verdict

| Item | Status | Evidence |
|---|---|---|
| Phase 1 summon frequency | PASS | Config 6.2–7.4 s; deterministic cadence checks |
| Phase 2 summon frequency | PASS | Config 4.8–6.0 s; one summon per cast |
| Interrupted summon retry | PASS | Explicit 3.0 s retry and interruption regression |
| Summon caps | PASS | P1=2, P2=3, Choir Husk<=1; captures 24–25 |
| Fire cast production art | PASS | Boss windup/release/recovery frames; capture 02 |
| Fire projectile and impact | PASS | Formal pixel projectile/impact; captures 03–04 |
| Fire damage and burn | PASS | 8 direct + 3×5; 30/30 deterministic trials; captures 05–06 |
| Ice cast/projectile art | PASS | Formal windup/lance/impact; captures 07–09 |
| Freeze and immunity | PASS | 3.0 s freeze + 5.0 s immunity; 30/30 trials; captures 10–14 |
| Mire telegraph lock | PASS | 1.15 s lock inside 2.0 s cast; captures 15–17 |
| Mire field and slow | PASS | 4.5 s, move×0.35, dash×0.70; 30/30 trials; captures 18–22 |
| Player status HUD | PASS | Signal-driven compact icons/timers; captures 06, 12, 20 |
| Status cleanup | PASS | Death, respawn, transition and field exit contracts tested |
| Boss AI interlocks | PASS | Eligibility, no immediate repeat, pressure guards and phase cleanup asserted |
| Boss elemental animations | PASS | 20 formal phase-aware spell animations, 128 bound frames |
| Necromancy/magic readability | PASS | Separate visual languages; capture 23 |
| Main/F5 integration | PASS | MainBootstrap capture driver, 27 captures, all three spells and summons |
| Existing Boss regression | PASS | B3, B4–B7 and R5 route suites |
| Player regression | PASS | movement, M1.5 actions, death, respawn and health HUD |
| Output/Debugger | PASS | Capture, headless suites and editor parse exited 0 without red errors |
| Subjective encounter fairness | MANUAL | Requires user playtest in formal Main route |

## Deterministic results

- Elemental contract: `PASS assertions=986 burn_hits=30 freeze_hits=30 mire_casts=30 cadence_battles=20`.
- Summon regression: `PASS actors=2 animations=25 cap=2 penitent_cap=1 interrupt=36 cleanup=true main_spawn=true` (Phase 1 contract).
- Full Boss regression: `PASS transition=true phase2_attacks=6 death=true reward_interface=true regressions=20`.
- Route regression: `PASS transitions=40 cycles=10 persistent_runtime=true platform_combat=true boss_entity=partial reward=partial chapter4=partial`; the pre-existing Chapter IV boundary remains partial.
- Player suites: movement, M1.5 actions, death state, respawn and health/stamina HUD all PASS.
- Main capture: `PASS captures=27 route=MainBootstrap fire=true ice=true mire=true summons=true`.

## Main screenshot evidence

All files are in this directory:

1. `01_full_boss_main.png`
2. `02_fire_cast_windup_main.png`
3. `03_fireball_flight_main.png`
4. `04_fireball_impact_main.png`
5. `05_player_burning_main.png`
6. `06_burn_hud_main.png`
7. `07_ice_cast_windup_main.png`
8. `08_ice_lance_flight_main.png`
9. `09_ice_impact_main.png`
10. `10_player_frozen_main.png`
11. `11_frozen_shell_close_main.png`
12. `12_freeze_hud_main.png`
13. `13_ice_shatter_main.png`
14. `14_player_thawed_main.png`
15. `15_mire_circle_initial_main.png`
16. `16_mire_circle_tracking_main.png`
17. `17_mire_circle_locked_main.png`
18. `18_mire_zone_formed_main.png`
19. `19_player_in_mire_main.png`
20. `20_mire_player_overlay_hud_main.png`
21. `21_mire_jump_readability_main.png`
22. `22_mire_attack_readability_main.png`
23. `23_necromancy_vs_mire_visual_language_main.png`
24. `24_phase_01_summon_pressure_main.png`
25. `25_phase_02_three_summon_cap_main.png`
26. `26_summons_plus_fire_main.png`
27. `27_summons_plus_mire_main.png`

## Manual playtest checklist

1. Start `CH3_BOSS` and judge the complete two-phase cadence.
2. Use the three individual magic routes to inspect telegraphs, readability, status exit and input recovery.
3. Use `CH3_BOSS_SUMMON_MAGIC_COMBO` to judge three-summon Phase 2 pressure and confirm Choir Husk never exceeds one.
4. Verify burn cannot create parallel DOT stacks, a thawed Player cannot be immediately frozen, mire tracking stops before activation, and death/respawn leaves no status icon or transient field.
5. Restore Debug Start to disabled after acceptance.

## Honest boundary

The automated 20-battle cadence model verifies state legality and cooldown/cap contracts; it is not presented as 20 human playthroughs. Final fairness, visual comfort and difficulty remain pending user acceptance. Chapter IV scene loading is outside this task and remains the existing partial boundary.
