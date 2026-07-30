# 第三章普通敌人密度与分布强制QA报告

Date: 2026-07-30

Engine: Godot 4.7.1 Standard (`a13da4feb`)

Main authority: `res://scenes/bootstrap/main_bootstrap.tscn`

Chapter route: `res://chapters/chapter_03_chapel_of_thirteen_echoes/scenes/level/chapter_03_route.tscn`

## QA result

**PASS — automated structure, deterministic content, MainBootstrap rendering and
regressions passed. Manual combat-feel acceptance remains with the user.**

| 项目 | 状态 | 证据 |
|---|---|---|
| 第三章最终普通敌人总数 | PASS | Distribution test: `enemies=72` |
| 总数不含Boss召唤物 | PASS | All manifests reference only the six normal-enemy scenes |
| 六种新敌人均被使用 | PASS | Exact roster counts: `22/8/12/10/10/10` |
| 开场场景功能明确 | PASS | Vestibule is safe; Nave Entry is first formal combat room |
| 开场首个Encounter | PASS | `03_opening_encounter_main.png`, staged 3 + 1 |
| 主礼拜堂分布 | PASS | `04_main_nave_front_main.png`, `05_main_nave_rear_main.png` |
| 告解室分布 | PASS | `06_confessional_ambush_main.png` |
| 唱诗回廊分布 | PASS | `07_choir_gallery_main.png` |
| 彩窗区域分布 | PASS | `09_stained_glass_hall_main.png` |
| 档案区域分布 | PASS | `10_prayer_archive_main.png` |
| 血烛区域分布 | PASS | `11_blood_candle_zone_main.png` |
| Boss前战斗分布 | PASS | `15_final_pre_boss_combat_main.png` |
| 远程敌人均位于合理平台 | PASS | Role audit plus `12_platform_ranged_rule_main.png` |
| 空中敌人高度合理 | PASS | Role audit plus `13_air_anchor_rule_main.png` |
| 重型敌人不在窄平台 | PASS | All 8 Executioners use `ground_heavy` |
| 同时激活数量合理 | PASS | 20 groups; every group contains 1–4 enemies |
| 无跨房间追踪 | PASS | Single active `RoomHost` child and disabled inactive processing |
| 无无限刷新 | PASS | Saved one-shot group instances; no runtime generation loop |
| 固定Seed与结果持久化 | PASS | Seed `31372026`; nine saved `.tres` room definitions |
| Main/F5集成 | PASS | Bootstrap-routed capture runner: `captures=17 bootstrap=true` |
| 性能 | PASS | Current-room-only load; inactive group process/physics/AI disabled |
| Output与Debugger | PASS | Exact-engine import, focused tests and route regressions have no red errors |

## Final statistics

| 场景 | Encounter数量 | 钟链忏者 | 香炉行刑者 | 唱诗灵 | 彩窗圣骸 | 忏悔亡魂 | 司录者 | 合计 |
|---|---:|---:|---:|---:|---:|---:|---:|---:|
| Opening Processional | 2 | 2 | 0 | 1 | 0 | 1 | 0 | 4 |
| Great Nave Front | 2 | 4 | 0 | 2 | 1 | 0 | 1 | 8 |
| Great Nave Rear | 2 | 3 | 1 | 1 | 1 | 1 | 1 | 8 |
| Thirteen Confessionals | 2 | 2 | 0 | 1 | 0 | 4 | 1 | 8 |
| Broken Choir Gallery | 3 | 2 | 1 | 3 | 1 | 0 | 2 | 9 |
| Shattered Saints | 2 | 2 | 0 | 1 | 4 | 0 | 1 | 8 |
| Prayer Archive | 2 | 2 | 1 | 1 | 0 | 1 | 3 | 8 |
| Blood-Candle Chapel | 2 | 3 | 2 | 1 | 1 | 1 | 0 | 8 |
| Last Procession | 3 | 2 | 3 | 1 | 2 | 2 | 1 | 11 |
| **Total** | **20** | **22** | **8** | **12** | **10** | **10** | **10** | **72** |

- Ground anchored: 40 (22 ground-light, 8 ground-heavy, 10 confessional ambush)
- Platform ranged: 22
- Air anchors: 10
- Confessional ambushes: 10
- Heavy enemies: 8
- EncounterGroups: 20
- Maximum simultaneous group size: 4

## Exact commands and results

```text
/Users/vincentz/Downloads/Godot.app/Contents/MacOS/Godot --headless --editor --path . --quit
PASS — import/parse completed without red errors.

... --headless --path . --script res://chapters/chapter_03_chapel_of_thirteen_echoes/scripts/tools/generate_chapter_03_encounter_manifests.gd
CH3_ENCOUNTER_GENERATION PASS rooms=9 encounters=20 enemies=72 seed=31372026

... --headless --path . --script res://chapters/chapter_03_chapel_of_thirteen_echoes/tests/test_chapter_03_enemy_distribution_b0_b5.gd
CH3_ENEMY_DISTRIBUTION_B0_B5 PASS rooms=9 encounters=20 enemies=72 bellchain=22 executioner=8 chorister=12 seraph=10 wraith=10 scribe=10 platform_ranged=22 air=10 ambush=10 heavy=8 seed=31372026

... --path . --script res://chapters/chapter_03_chapel_of_thirteen_echoes/scripts/tests/capture_chapter_03_enemy_distribution_b0_b5_qa.gd
CH3_ENEMY_DISTRIBUTION_MAIN_QA PASS captures=17 bootstrap=true rooms=9 enemies=72

... --headless --path . --script res://chapters/chapter_03_chapel_of_thirteen_echoes/tests/test_chapter_03_r4_boss_flow.gd
CH3_R4_BOSS_FLOW PASS checkpoint=true e_gate=true room_swap=true intro=true post_boss_hook=true underkeep_hook=true boss_entity=partial chapter4=partial

... --headless --path . --script res://chapters/chapter_03_chapel_of_thirteen_echoes/tests/test_chapter_03_r5_full_route.gd
CH3_R5_FULL_ROUTE PASS transitions=50 cycles=10 persistent_runtime=true platform_combat=true boss_entity=partial reward=partial chapter4=partial

... --headless --path . --script res://chapters/chapter_03_chapel_of_thirteen_echoes/tests/test_chapter_03_render_layers_l1.gd
CH3_RENDER_LAYERS_L1 PASS doors=4 checkpoint=1 gate_states=3 titles=5 water_edges=2 drop=13 combat_fx=16 y_sort=0
```

## Main/F5 evidence

All 17 PNGs in this directory were captured after the runner instantiated the formal
`MainBootstrap`, enabled the guarded Chapter III debug route and loaded the saved
formal rooms. They are not standalone F6 room captures.

1. `01_chapter_03_transition_entry_main.png`
2. `02_first_formal_combat_room_main.png`
3. `03_opening_encounter_main.png`
4. `04_main_nave_front_main.png`
5. `05_main_nave_rear_main.png`
6. `06_confessional_ambush_main.png`
7. `07_choir_gallery_main.png`
8. `08_pipe_organ_encounter_main.png`
9. `09_stained_glass_hall_main.png`
10. `10_prayer_archive_main.png`
11. `11_blood_candle_zone_main.png`
12. `12_platform_ranged_rule_main.png`
13. `13_air_anchor_rule_main.png`
14. `14_high_pressure_encounter_main.png`
15. `15_final_pre_boss_combat_main.png`
16. `16_encounter_debug_statistics_main.png`
17. `17_main_formal_route_checkpoint_main.png`

## Manual acceptance

Use the listed debug spawn ids through MainBootstrap and play each room from west to
east. Confirm activation timing, pressure overlap, platform accessibility, attack
readability and checkpoint reset feel. Automated results deliberately do not certify
those subjective combat qualities.
