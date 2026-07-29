# 第三章场景结构返修 R5 Main 回归与 QA 报告

日期：2026-07-29

引擎：Godot 4.7.1 Standard（`a13da4feb`）

F5 入口：`res://scenes/bootstrap/main_bootstrap.tscn`
第三章正式场景：`res://chapters/chapter_03_chapel_of_thirteen_echoes/scenes/level/chapter_03_route.tscn`

## 结论

R0–R4 所负责的正式房间、图层、碰撞、门扉、检查点、Boss 门槛和环境演出已经通过 R5 Main 回归。R5 新增的压力测试对以下四条边界各执行 10 次，总计 40 次：

- Chapel Vestibule → Processional Nave；
- Processional Nave → Broken Choir Gallery；
- Broken Choir Gallery → Last Vigil Checkpoint；
- Thirteen Confessions Antechamber → Thirteenth Echo Sanctum。

40 次均保持单一 `RoomHost` 子场景、同一 Player、同一 HUD、正确 Camera Bounds、恢复后的输入和隐藏的 Fade。MainBootstrap 图形化运行生成 8 张新的正式路线证据。

但是仓库仍无 Bell Confessor Edran 的正式战斗实体、正式第三章 Boss 奖励和可加载的 Chapter IV PackedScene。因此“玩家与 Boss 实机战斗”“Boss 奖励闭环”“进入第四章”不能标记 PASS。按原 Prompt 的严格终验规则：

**第三章场景结构返修尚未通过最终验收。**

这不是 R5 场景返修失败，而是跨里程碑内容尚未具备；本轮保留了类型化接入点，未制造假 Boss、假奖励或假章节。

## 强制 QA 验收

| 项目 | 状态 | 证据 |
|---|---|---|
| 前厅不再空荡 | PASS | `docs/qa/chapter_03_r5_vestibule_main.png` |
| 前厅身份清楚 | PASS | 双语房名、候礼设施、中央门扉与阶梯均在同一 Main 截图 |
| 前厅资产密度合理 | PASS | 主视觉 1 项、辅助陈设与约 40% 战斗/移动负空间 |
| 前厅到主廊转场 | PASS | `test_chapter_03_r5_full_route.gd` 10/10；正式门由 R3/R4 回归覆盖 |
| 场景间无大段空白 | PASS | 8 个独立房间按 Fade 切换；不存在旧单画布黑缝拼接 |
| 管风琴结构接缝 | PASS | `docs/qa/chapter_03_r3_choir_layers_main.png` |
| 管风琴空气墙 | PASS | R3 测试确认 `OrganPipesFar` / `OrganCaseBehind` 无 Collision |
| 全部 Collision | PASS | `docs/qa/chapter_03_r3_visible_collisions_main.png`、`chapter_03_r3_stair_visible_collisions_main.png` |
| 中层平台 | PASS | `docs/qa/chapter_03_r5_nave_platform_combat_main.png` |
| 高层平台 | PASS | `docs/qa/chapter_03_r5_choir_platform_combat_main.png` |
| 玩家平台可达性 | PASS | R2/R3 的 60 px 梯级与 8 个可见/物理顶面断言 |
| 远程敌人平台适配 | PASS | R5 两个战斗房各有 3 个正式 `EnemyCombatant`，横跨至少 2 个高度带 |
| 空中敌人可攻击性 | PASS | Choir Main 攻击帧证据；空中单位位于可达维修平台攻击带 |
| 资产堆砌减少 | PASS | 每个房间保持单一视觉中心；R5 Main 全景无全屏重复道具 |
| 玩家无遮挡 | PASS | Nave/Choir Main 证据；Player z=12、Enemy z=10、有限前景 z=20 |
| 图层统一 | PASS | R3 `-100/-60/-30/-10/0/10/12/14/20` 合同回归通过 |
| Boss检查点 | PASS | `docs/qa/chapter_03_r5_checkpoint_main.png`，持久 Respawn Anchor 已更新 |
| Boss前室 | PASS | `docs/qa/chapter_03_r5_boss_threshold_main.png`，无敌人/平台干扰 |
| Boss门辨识度 | PASS | 同上；独特十三响门、铭牌、持钟圣像和门名 |
| Boss进入提示 | PASS | `E · ENTER THE THIRTEENTH ECHO SANCTUM`，接近不会自动触发 |
| Boss房独立转场 | PASS | R4 生命周期测试和 R5 10/10 压力测试；独立 `CH3_BOSS` Room |
| Main集成 | PASS | MainBootstrap capture 8/8；Chapter II hand-off 加载 `Chapter03Route` |
| Output与Debugger | PARTIAL | R5 Main、R2–R5 与默认 F5 无运行期红错；旧的 Chapter II 全流程测试/截图工具在进程退出时仍报告既有 Resource/RID teardown leak，见“已知问题” |

## 关键内容边界

| 内容 | 状态 | 当前真实实现 |
|---|---|---|
| Edran 入场环境、标题、集成锚点 | PASS | Fade 后十三烛、镜头、双语标题、`BossIntegrationAnchor` |
| Edran Boss HP / AI / Hitbox / 战斗 | PARTIAL | 仓库无权威 Boss 场景或控制器；没有放入假 EnemyCombatant |
| Boss 死亡环境响应接口 | PASS | `notify_boss_defeated()` → `death_environment_finished` → 出口开放 |
| 第三章 Boss 正式奖励 | PARTIAL | 只有 `reward_collection_requested` / `notify_reward_collected()` 类型化接口 |
| Chapter IV 场景加载 | PARTIAL | Registry 为 planned profile，目标 PackedScene 不存在；终点明确显示“尚未开放” |

## 性能与稳定性

自动化：`test_chapter_03_r5_full_route.gd`

| 转场 | 次数 | Player重复 | HUD重复 | Camera Bounds | Fade | 结果 |
|---|---:|---:|---:|---|---|---|
| Vestibule → Nave | 10 | 0 | 0 | 正确 | 恢复 | PASS |
| Nave → Choir | 10 | 0 | 0 | 正确 | 恢复 | PASS |
| Choir → Checkpoint | 10 | 0 | 0 | 正确 | 恢复 | PASS |
| Antechamber → Sanctum | 10 | 0 | 0 | 正确 | 恢复 | PASS |

测试使用真实 `request_room_change()`、真实 Fade、真实物理帧和正式 Room PackedScene。Boss 压力循环跳过已经由 R4 单独验证过的长 Intro，仅测试房间切换稳定性；R4 仍负责完整 Intro 时序。

## Main 截图证据

### R5 新增

1. `docs/qa/chapter_03_r5_vestibule_main.png`
2. `docs/qa/chapter_03_r5_nave_platform_combat_main.png`
3. `docs/qa/chapter_03_r5_choir_platform_combat_main.png`
4. `docs/qa/chapter_03_r5_checkpoint_main.png`
5. `docs/qa/chapter_03_r5_boss_threshold_main.png`
6. `docs/qa/chapter_03_r5_sanctum_boundary_main.png`
7. `docs/qa/chapter_03_r5_post_boss_reward_boundary_main.png`
8. `docs/qa/chapter_03_r5_chapter_04_planned_boundary_main.png`

### 22 项截图矩阵

| 要求 | 证据 | 状态 |
|---|---|---|
| 1–3 前厅全景/入口/出口门 | R2 Vestibule + R5 Vestibule | PASS |
| 4 前厅到主廊转场 | R5 10/10 + R3 门阻挡器测试 | PASS（动态） |
| 5–6 主廊地面/平台、玩家中层 | R5 Nave | PASS |
| 7 平台远程敌人攻击 | R5 Choir 攻击帧 | PASS |
| 8 空中敌人交战 | R5 Choir 攻击帧 | PASS |
| 9–10 管风琴全景/无接缝 | R3 Choir layers | PASS |
| 11 管风琴 Collision | R3 Visible Collision | PASS |
| 12 唱诗回廊出口门 | R5 Choir | PASS |
| 13 Boss 检查点 | R5 Checkpoint | PASS |
| 14–16 Boss 前室/闭门/提示 | R5 Boss threshold + R4 gate prompt | PASS |
| 17 Boss 门开启 | R4 gate ritual | PASS |
| 18 Fade Out | R4 生命周期测试；旧环境 capture `07_gate_fade_out_main.png` | PASS（动态） |
| 19 Boss 房 Fade In | R4 intro title；旧环境 capture `08_boss_room_fade_in_main.png` | PASS（动态） |
| 20 玩家与 Boss 实机 | 只有 R5 Sanctum 环境和集成锚点 | PARTIAL：Boss实体不存在 |
| 21 玩家无遮挡 | R5 Nave/Choir | PASS |
| 22 Visible Collision | R3 两张 Visible Collision | PASS |

旧图对应用户提供的四张结构问题截图；新图为 R2–R5 MainBootstrap 证据。旧截图未复制为项目资产，避免把外部临时附件误当正式资源；旧问题的节点映射和测量保存在 `chapter_03_structural_rework_r0_audit.md`。

## 精确命令与实际结果

1. `/Users/vincentz/Downloads/Godot.app/Contents/MacOS/Godot --headless --editor --path . --quit-after 5` — exit 0；无解析/缺失资源错误。快速退出产生一次 `Scan thread aborted` 警告，不是脚本错误。
2. `... --headless --path . --script res://chapters/chapter_03_chapel_of_thirteen_echoes/tests/test_chapter_03_r5_full_route.gd` — PASS，`transitions=40 cycles=10 persistent_runtime=true platform_combat=true`。
3. R4 Boss flow — PASS；R3 layers/collisions — PASS；R2 room structure — PASS。
4. Chapter III Boss environment — PASS，Boss hook 仍明确 PARTIAL；六敌人 roster — PASS，`roles=6`。
5. Chapter II→III 行为回归 — PASS，`formal_route=1`；测试进程退出后仍出现既有资源 teardown leak，未被误记为干净。
6. `... --path . --script res://chapters/chapter_03_chapel_of_thirteen_echoes/scripts/tests/capture_chapter_03_r5_full_route_qa.gd` — PASS，MainBootstrap 8 张 1280×720 图，无运行期错误。
7. `... --headless --path . --quit-after 240` — PASS；`MAIN BOOTSTRAP | FORMAL NEW GAME`，无红色运行错误。
8. `git diff --check` — PASS。

## 已知问题

1. Edran 正式 Boss、第三章权威奖励和 Chapter IV PackedScene 不在仓库中；这是最终验收的三个真实阻塞项。
2. Chapter II→III 的旧大型端到端测试与图形 capture 在调用 `quit()` 后触发 Resource/RID teardown leak 报告。功能路径已 PASS，Main/F5 运行过程无红错，但该测试工具清理债务应独立修复；R5 不把它隐藏或写成全绿。
3. 自动化能够验证几何、状态、边界和重复切换；平台操作手感、敌人公平性及可见卡顿仍需人工试玩。

## F5 人工验收路线

临时在 Debug Run Config 选择第三章；验收后恢复正式启动设置。按以下顺序逐项测试：

1. `CH3_VESTIBULE`：检查前厅内容、中央门视觉、负空间、八级短阶和 E 开门。
2. `CH3_NAVE_ENTRY`：检查独立转场、中层平台、远程敌人位置；用普通跳、Normal Attack 和 Dash Attack 验证可达性。
3. `CH3_CHOIR_GALLERY`：检查管风琴接缝/空气墙、维修平台、空中敌人和右侧检查点门。
4. `CH3_BOSS_CHECKPOINT`：激活末祷检查点，确认安全房无敌人且 Respawn 点更新。
5. `CH3_BOSS_ANTE`：走近门只显示提示；按 E 后检查十三响仪式、开门和 Fade。
6. `CH3_BOSS`：检查独立平地圣所、十三烛、镜头和标题；当前只能验收环境流程，不能验收不存在的 Boss 战。

因此，回答固定问题“我现在按 F5 进入 Main 后，如何逐项确认这次截图中反映的五类问题已经修复？”：按上述 1→6 路线依次检查空洞/密度、正式门扉转场、平台与敌人可达性、管风琴接缝与空气墙、Boss 门槛辨识和独立圣所流程。任何一步出现遮挡、空气墙、黑缝、不可达平台、自动开战或红色运行错误，均视为本次结构回归失败。
