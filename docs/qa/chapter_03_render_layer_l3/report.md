# 第三章图层叠放修复强制 QA 报告

日期：2026-07-29

引擎：Godot 4.7.1 Standard (`a13da4feb`)

正式入口：`res://scenes/bootstrap/main_bootstrap.tscn`

第三章正式路线：`res://chapters/chapter_03_chapel_of_thirteen_echoes/scenes/level/chapter_03_route.tscn`

## 图层修复 QA 总结果

**严格总状态：PARTIAL。**

当前 HEAD 上实际存在的第三章房间、普通敌人、门、Player、Drop、Combat FX、死亡幽灵和有限前景图层均通过 MainBootstrap 运行证据与自动回归；没有已知 Player 头部或躯干被建筑/门体吞没的残留错误。可是最高强度验收层还要求当前仓库并不存在的 NPC、钟忏司祭·埃德兰 Boss 实体、权威 Boss 奖励、可加载 Chapter IV 场景，以及 Godot 编辑器 Remote Dock 截图和多窗口尺寸实机矩阵。它们不能伪造为 PASS。

因此，本报告必须明确写：**第三章图层叠放修复尚未通过最终验收。**

| 项目 | 状态 | 证据 |
|---|---|---|
| 前庭玩家可见性 | PASS | `02_vestibule_v02_door_center.png`、`07_vestibule_v07_jump.png`、`08_vestibule_v08_attack.png` |
| 前庭门体层级 | PASS | 普通门全板 -30、交互 14；closed/25%/50%/100% 四状态截图 |
| 末祷检查点玩家可见性 | PASS | `29_checkpoint_c01_left.png` 至 `38_checkpoint_respawn.png` |
| 末祷圣龛层级 | PASS | 运行时 `CheckpointVisual` effective z=-30；Player z=12 |
| 十三忏前厅玩家可见性 | PASS | `43_ante_t01_statue.png` 至 `49_ante_t07_dash_attack.png` |
| 告解板层级 | PASS | `45_ante_t03_confession_boards.png`、Player run 可见 |
| 雕像与讲台层级 | PASS | `43_ante_t01_statue.png`、`46_ante_t04_lectern_front.png`、`47_ante_t05_lectern_jump.png` |
| Boss 门区域玩家可见性 | PASS | `50_gate_b01_closed_front.png` 至 `56a_gate_b11_fade.png` |
| Boss 门开关层级 | PASS | closed/lit/25%/50%/100%/Fade 均有 Main 运行截图；全门板 effective z=-30 |
| Player 层级稳定性 | PASS | 八房 Player root effective z=12；WeaponVisual=13；GhostSprite=14 |
| Enemy 层级稳定性 | PASS | 六种正式敌人均有截图，六个根节点 effective z=10 |
| NPC 层级稳定性 | PARTIAL | Layer Contract 定义 NPC=11，但当前八个正式房间没有 NPC 实例，无法提供实体截图 |
| 掉落物层级 | PASS | `drop_coin_runtime_z13.png`；CoinPickup effective z=13 |
| 攻击特效层级 | PASS | `combat_fx_runtime_z16.png`；Projectile/TimedField effective z=16 |
| 图层切换稳定性 | PARTIAL | R5 已完成四条关键边界各 10 次（40/40）；最高 QA 要求的每一条完整路线边界各 10 次未全部取证 |
| 房间重载稳定性 | PASS | 四个最高风险房间各 20 次，80/80；每次一个 active room、Player z=12 |
| Main/F5 集成 | PASS | MainBootstrap 加载正式 Chapter03Route；79 张根 Viewport 截图均来自该保存路线 |
| Output 与 Debugger | PASS | exact import、L1/R3/R4/R5/roster、Main smoke 均无红色运行错误 |

统一统计（上述 18 项 + 5 项最高 QA 补充边界）：

- PASS：16
- PARTIAL：7（NPC、全路线转场矩阵、教宗 Boss、Boss 奖励、Chapter IV、Remote Dock UI 截图、多分辨率矩阵）
- FAIL：0
- 已知 Player 头部/躯干关键遮挡：0

## QA 总结果（标准 15 项矩阵）

| 项目 | 状态 | 证据 |
|---|---|---|
| Chapel Vestibule | PASS | 14 图；门、长椅、楼梯、动作、碰撞 |
| Last Vigil Checkpoint | PASS | 14 图；交互、hurt、death、ghost、respawn、门状态 |
| Thirteen Confessions | PASS | 17 图；雕像、圣龛、告解板、讲台、动作、Boss 门 |
| Boss Gate | PASS | 关闭、点亮、25%、50%、完全开启、穿越、Fade |
| Player Layer | PASS | 八房根节点 z=12，武器 z=13，幽灵 z=14 |
| Enemy Layer | PASS | 六种正式敌人 z=10 |
| NPC Layer | PARTIAL | 规范 z=11；当前正式路线无 NPC 实例可视验收 |
| Drop Layer | PASS | live CoinPickup z=13 |
| Combat FX Layer | PASS | live Projectile/TimedField z=16 |
| Door State Layers | PASS | 四普通门与 Boss 门状态均不抬高整块门体 |
| Y-sort | PASS | 530 条运行时样本全部 `y_sort_enabled=false` |
| z_as_relative | PASS | 运行时 effective-z 已按父链计算并验证；无相对 z 漂移 |
| Main/F5 | PASS | `main_bootstrap=true`，正式路由而非 F6 房间 |
| 20 次重载稳定性 | PASS | 四个关键房间各 20 次，共 80/80 |
| Output/Debugger | PASS | 本报告所列命令均 exit 0，无红色运行错误 |

## 旧图层结构

L0 在真实 Main 路线中扫描了 411 个 CanvasItem（149 个可绘制项），发现 14 条机器异常记录，折叠为 11 个结构问题组；再加 4 个静态/动态生成问题，共 **15 个问题组**。

旧结构的核心错误不是 Player 太低，而是把完整建筑复合图放到 Interactable z=14：

- 四个普通门把完整 `DoorVisual` 继承到 z=14；
- 十三忏前厅完整检查点复合图位于 z=14；
- Boss 门 Closed/Lit/Open 三个完整门体继承 z=14；
- 五个世界空间标题参与世界 z 排序；
- 768×96 浅水整块位于 LimitedForeground z=20；
- 动态 Drop、Projectile、TimedField 使用隐式 z=0。

未使用“提高 Player 到 9999”“隐藏前景”“删除建筑”“关闭 Y-sort 掩盖问题”等假修复。

## 新 Layer Contract

权威规范位于 `docs/production/render_layer_contract.md`：

| z / Layer | 类别 |
|---:|---|
| -100 | Far Background |
| -60 | Background Architecture |
| -30 | Props Behind Actors |
| -10 | Ground Base |
| 0 | Walkable Geometry |
| 8 | Ground Detail |
| 10 | Enemy |
| 11 | NPC |
| 12 | Player |
| 13 | Drop / Pickup |
| 14 | Interactable Core |
| 16 | Combat FX |
| 20 | Limited Foreground（最多 0–4 px 脚部边缘） |
| CanvasLayer | HUD / Dialogue / Fade |

`RenderLayerContract` 为共享权威，`Chapter03LayerContract` 仅作同值别名。固定建筑不使用 Y-sort；相对 z 只允许在明确的容器内累加，并以 effective z 而不是局部值验收。

## 前庭修复

`Ch3ChapelVestibule/Doors/NaveDoor` 由整体 z=14 改为：

```text
NaveDoor (Area2D, z=0)
├── Presentation (z=-30)
│   └── DoorVisual
├── Interaction (z=14)
│   └── Prompt
├── Blocker
└── CollisionShape2D
```

Player 在门中心、左右门框、长椅、石阶、Jump、Attack、Dash Attack 以及门关闭/部分开启/穿越状态均保持可见。

## 末祷检查点修复

- `Ch3BossCheckpoint/CheckpointVisual` 保持 effective z=-30；L0 已确认用户截图 2 的旧问题在当前 HEAD 不再复现，L1/L2 将其作为强制回归点。
- 相邻 `ConfessionDoor` 使用与其他普通门相同的后置 Presentation / 前置 Interaction 分层。
- L2 覆盖左右两侧、正面、交互、双跳、攻击、受击、倒地、幽灵释放和重生。

## 十三忏前厅修复

- `BossAntechamber/CheckpointVisual` 从 effective z=14 移至 -30。
- 雕像、圣龛、告解板和讲台作为后方叙事物件保持在 actor 后方。
- Player 的 run/jump/attack/dash_attack 均有最危险重叠站位截图，不再只剩脚部。

## Boss 门修复

- `Visuals/GateClosed`、`GateLit`、`GateOpen` 和完整门体/钟体均为 effective z=-30。
- 仅紧凑的 `SealLights` 与 `WaxCrack` 使用 CombatFX z=16。
- Blocker、E 交互阈值、十三响序列、Fade 和房间替换行为没有改变。
- closed、lit/cracked、25%、50%、100%、Player 穿过和 Fade 七个关键状态均有截图。

## Door 分层结构

四个普通门均使用统一结构，Authority 和碰撞保持 z=0，完整门板在 z=-30，只有提示在 z=14。Boss 门使用独立但相同原则：完整建筑后置，局部交互/裂纹 FX 前置。Post-Boss `DescentSeal` 和 Underkeep 背景门在 L0 已处于 -30，无需粗暴改动。

## Player 运行时层级

`runtime_layer_samples.tsv` 对所有八个正式房间记录：

| 节点 | effective z |
|---|---:|
| `PersistentRuntime/ChapterRuntime/Player` | 12 |
| `Player/VisualRoot/AnimatedSprite2D` | 12 |
| `Player/VisualRoot/WeaponVisual` | 13 |
| `Player/VisualRoot/DeathEffects/GhostSprite` | 14 |

Player 始终挂在 `PersistentRuntime/ChapterRuntime`，房间切换只替换 `RoomHost` 下的活动房间，不重复 reparent Player，也不生成第二套 Visual。

## Enemy / NPC / Drop 回归

- 六种正式敌人各自的 `CharacterBody2D` 根均为 effective z=10，且有独立 Main 截图。
- 当前正式八房无 NPC 实例；NPC=11 只完成规范和契约，严格标记 PARTIAL。
- live CoinPickup 与其 PixelVisual 为 z=13；不再依赖敌人父节点默认值。

## Y-sort 审计

530 条 L2 运行时 CanvasItem 样本中，`y_sort_enabled=true` 数量为 **0**。固定门、建筑、Actor 和 LimitedForeground 均未借由关闭/开启 Y-sort 掩盖层级错误。

## z_as_relative 审计

L2 表格同时记录 local z、effective z、`z_as_relative` 与 Parent。L3 自动检查按 effective z 验证八房 Player、六敌人、武器、幽灵、Drop、Projectile、TimedField 和水面。当前没有父节点 z 累加导致整块门体重新抬到 Player 之前的记录。

## Remote Scene Tree 证据

`docs/qa/chapter_03_render_layer_l2/runtime_layer_samples.tsv` 提供 530 条 Main 运行时等价数据：节点路径、类型、Parent、local/effective z、`z_as_relative`、Y-sort、CanvasLayer、visible 和 global position。

本 Codex 会话不具备 Godot 编辑器 Computer Use / Remote Dock 控制，因此没有伪造 Remote Scene Tree 或 Inspector UI 截图。**UI 截图项为 PARTIAL**；用户可按文末路线运行 F5，在 Godot Remote 选项卡中选择 Player、Door 和 BossGate，对照该 TSV 手工补证。

## 动态动作测试

截图索引覆盖：idle、run、jump、jump apex、fall、ground dash、air dash、normal attack、dash attack、interact、hurt、death、ghost release、respawn。L3 自动检查要求这 14 类动作均存在、Player visible=true、状态为 CAPTURED，且 79 张 PNG 内容哈希互不重复。

## 门开关状态测试

- 四个普通门：closed、25%、50%、100% / pass-through。
- Boss 门：closed、lit/cracked、25%、50%、100% / pass-through、Fade。
- 门板位置改变不改变其 Presentation effective z；提示与局部 FX 不会把完整门体带到 actor 前方。

## 20 次重载测试

以下四个最高风险房间各自重新加载 20 次，共 80/80：

- `CH3_CHAPEL_VESTIBULE`
- `CH3_BOSS_CHECKPOINT`
- `CH3_BOSS_ANTE`
- `CH3_UNDERKEEP_DESCENT`

每次均验证一个 active room、Player effective z=12。R5 另对 Vestibule→Nave、Nave→Choir、Choir→Checkpoint、Ante→Sanctum 四条边界各执行 10 次，共 40/40，保持一个 Player、一个 HUD、正确 Camera limits、输入恢复和无卡死 Fade。

最高 QA 补充要求的“全部路线边界各 10 次”尚未完整自动取证，因此独立的全路线转场项保持 PARTIAL。

## 第三章完整场景清单

L0 共扫描 26 个 `.tscn`：

- 1 个正式路线：`chapter_03_route.tscn`；
- 8 个正式房间：Vestibule、Nave、Choir、Boss Checkpoint、Boss Ante、Boss Sanctum、Post-Boss、Underkeep；
- 13 个正式依赖：5 个 Boss/转场区域、6 种敌人、Projectile、TimedField；
- 1 个 retired entry placeholder；
- 3 个 Debug 测试场景。

精确路径、分类、Main 可达性、Room / Spawn ID 与审计状态见 `docs/qa/chapter_03_render_layer_l0/scene_inventory.tsv`。

## 第三章全量节点审计

| 阶段 | CanvasItem | drawable | 异常 |
|---|---:|---:|---:|
| L0 修复前运行时 | 411 | 149 | 14 机器行 / 15 问题组 |
| L1 修复后运行时 | 421 | 151 | 0 |
| L2 动态/全房样本 | 530 | 含动态 Actor/Drop/FX | L3 契约错误 0 |

L2 的 530 行包含八次正式房间运行状态以及动态 Drop/FX，不能与 L0 单次分类统计直接相加。

## 用户截图问题修复

| 用户截图 | 对应正式场景 | 原问题 | 修复 | 状态 |
|---|---|---|---|---|
| 1 前庭门 | `ch3_chapel_vestibule.tscn` | 完整 DoorVisual effective z=14 | Door Presentation=-30，Interaction=14 | PASS |
| 2 末祷检查点 | `ch3_boss_checkpoint.tscn` | 历史截图遮挡；当前 L0 已为 -30 | 保持 -30 并做完整死亡/重生回归 | PASS |
| 3 十三忏前厅圣龛 | `ch3_boss_ante_room.tscn` + `ch3_boss_antechamber.tscn` | 完整 CheckpointVisual z=14 | composite=-30 | PASS |
| 4 第十三响门 | `ch3_boss_ante_room.tscn` + `ch3_boss_gate_transition.tscn` | Closed/Lit/Open 全门体 z=14 | 全门体=-30，局部 FX=16 | PASS |

## 全章额外发现问题

L0 在三处当前可复现的用户截图问题之外额外发现 **12** 个问题组：Nave/Choir/Checkpoint 三个普通门、五个世界标题、Underkeep 大面积水前景、Drop 隐式 z、Projectile 隐式 z、TimedField 隐式 z。L1 全部按契约修复，修复异常总数为 **15/15**，L1 运行时异常表只剩表头。

## 普通门图层审计

NaveDoor、ChoirDoor、CheckpointDoor、ConfessionDoor 的完整面板均为 -30，交互提示为 14；每扇门都有 closed/25%/50%/100% 截图。MirrorBackDoor、DescentSeal 和 UnderkeepGate 在 L0 已安全位于后方。

## Boss 门图层审计

Boss Gate 三种完整视觉均为 -30，wax/seal FX 为 16。Player 在门中心、左右侧、门楣跳跃、提示、裂纹、两段部分开启、完全通过和 Fade 中均有证据。

## 平台与楼梯图层审计

- `00_vestibule_runtime_collisions.png` 记录正式 Main 的运行时碰撞提示。
- R3 回归通过 `stairs=8 platforms=8 doors=3 actor_z=10/12`。
- Nave 与 Choir 包含地面、空中、fall、平台 jump 和平台 attack 截图；没有大型前景跨越 Player 主体。

## Player 全动作图层测试

14 类动作证据齐全；武器在 attack/dash attack 中仍为 z=13，死亡主体与双匕首、GhostSprite 均保持可读。没有通过暂停在安全 pose 来规避风险点。

## 六种普通敌人图层测试

| 敌人 | 证据 |
|---|---|
| Bellchain Penitent | `enemy_nave_bellchain_penitent.png` |
| Confessional Wraith | `enemy_nave_confessional_wraith.png` |
| Thirteenth Scribe | `enemy_nave_thirteenth_scribe.png` |
| Censer Executioner | `enemy_choir_censer_executioner.png` |
| Silent Chorister | `enemy_choir_silent_chorister.png` |
| Stained Glass Seraph | `enemy_choir_stained_glass_seraph.png` |

六个实体根均为 effective z=10。

## 教宗 Boss 图层测试

**PARTIAL。** 当前 HEAD 的 Sanctum 只有环境、入场接口和标题演出，没有钟忏司祭·埃德兰 combat entity、Boss Sprite 或阶段动画。`57_boss_room_entry.png`、`58_boss_room_center_attack.png`、`59_boss_room_air_dash.png` 只能通过环境与 Player 图层，不能替代 Boss 全阶段验收。

## Drop 与 CombatFX 图层测试

- live CoinPickup：z=13，截图 `drop_coin_runtime_z13.png`；
- live Chapter03EnemyProjectile：z=16；
- live Chapter03TimedField：z=16；
- 组合截图：`combat_fx_runtime_z16.png`。

## 全部转场稳定性测试

当前自动证据：四条关键边界 40/40，四个风险房间重载 80/80。Post-Boss→Underkeep 与 Chapter III→IV 不能组成完整正式闭环，因为权威奖励和 Chapter IV PackedScene 尚不存在；最高规范要求的每条边界 10 次矩阵保持 PARTIAL。

## Debug Spawn 与正式路线一致性

L2 驱动从保存的 MainBootstrap 进入 Chapter03Route；Debug Start 只选择合法章节/Spawn，不实例化孤立房间。R5 验证八个 direct starts 都映射到同一正式 RoomHost / PersistentRuntime 结构。默认 Main smoke 仍从 Opening 正式开局。

## 全章截图索引

完整 79 行索引位于 `docs/qa/chapter_03_render_layer_l2/screenshot_index.tsv`，字段包含截图、场景、Spawn、位置、Camera center/limit、Player visible、动作、门状态、验收对象和状态。79 张均为 1280×720，SHA-256 内容 79/79 唯一。

代表性截图：

- 前庭运行碰撞：`00_vestibule_runtime_collisions.png`
- 前庭门前攻击：`08_vestibule_v08_attack.png`
- 末祷倒地/幽灵：`36_checkpoint_death_body.png`、`37_checkpoint_ghost_release.png`
- 十三忏讲台：`46_ante_t04_lectern_front.png`
- Boss 门 25%：`55a_gate_b08_open_25.png`
- Boss 门通过：`56_gate_b10_open_pass.png`
- Underkeep 水面攻击：`66_underkeep_water_attack.png`
- 第四章计划边界：`67_underkeep_chapter4_boundary.png`

## 修改文件

L3 仅新增/修改：

- `chapters/chapter_03_chapel_of_thirteen_echoes/tests/test_chapter_03_render_layer_l3_evidence.gd`
- `docs/qa/chapter_03_render_layer_l3/report.md`
- `README.md`（QA 报告索引）
- `docs/development_log.md`

L3 没有修改 `.tscn`、玩法脚本、碰撞、AI、Player、敌人、数值、资产或 startup 配置。

## Output 和 Debugger

最终实际命令与结果记录在 `docs/development_log.md` 的 L3 completion。核心结果：

- exact Godot 4.7.1 import/parse：exit 0；
- L3 evidence：PASS，79 unique、8 rooms、530 runtime samples；
- L1/R3/R4/R5/roster：PASS（各自保留已声明的 Boss/reward/Chapter IV partial boundary）；
- default MainBootstrap smoke：exit 0；
- 红色运行错误：0。

## PARTIAL 或 FAIL 项目

| 项目 | 状态 | 原因 / 解除条件 |
|---|---|---|
| NPC 运行时层级 | PARTIAL | 当前正式八房无 NPC；新增正式 NPC 后按 z=11 取证 |
| 全路线每边界 10 次 | PARTIAL | 当前四条关键边界 40/40；补齐 Post-Boss/Underkeep/Chapter IV 闭环后重跑 |
| 钟忏司祭·埃德兰 Boss | PARTIAL | 当前无 combat entity / phases；Boss milestone 实装后取证 |
| 权威 Boss 奖励 | PARTIAL | 当前仅 reliquary interface；奖励 milestone 实装后取证 |
| Chapter IV 场景 | PARTIAL | 当前无 loadable PackedScene；Chapter IV milestone 后取证 |
| Remote Scene Tree / Inspector UI 截图 | PARTIAL | 本会话无 editor Computer Use；运行时 TSV 已提供，仍需手工 UI 截图 |
| 多分辨率/最大化窗口矩阵 | PARTIAL | 当前正式截图均为 1280×720；需手工补默认、最大化和正式 Stretch 观察 |

FAIL：**0**。

## 仍未解决的图层问题

在当前存在且可运行的第三章内容中，没有已知 Player 头部/躯干、武器、Enemy、Drop、CombatFX、门体或水面关键遮挡问题。未完成项是缺少对应内容或 UI/窗口证据，并非已经观测到但未修复的遮挡。

由于上述七项 PARTIAL，严格结论仍是：**第三章图层叠放修复尚未通过最终验收。**

## 我现在按 F5 进入 Main 后，如何亲自验证玩家不会再被第三章建筑与门体遮挡？

使用项目现有 Debug Chapter Start 选择下列 Spawn；每次都从 `MainBootstrap` 按 F5，不要直接 F6 房间：

1. `CH3_VESTIBULE` / `chapter_03_start`：站在门前中心、左右门框、长椅旁和石阶处，依次测试 Idle、Jump、Attack、Dash Attack 和开门；确认头、躯干和双匕首始终在完整门板前。
2. `CH3_LAST_VIGIL_CHECKPOINT` / `CH3_BOSS_CHECKPOINT`：站在圣龛正面和左右侧，按 E 交互、跳跃、攻击；使用开发伤害使 Player 死亡，观察倒地、幽灵和重生，确认圣龛不吞掉主体。
3. `CH3_THIRTEEN_CONFESSIONS` / `CH3_BOSS_ANTE`：依次经过雕像、圣龛、告解板、讲台和地面装饰，测试 Run、Jump、Attack、Dash Attack；生成 Drop/CombatFX 时确认 Player、Enemy、掉落和特效层级可读。
4. `CH3_BOSS_GATE_APPROACH` / `CH3_BOSS_ANTE`：在门中心及两侧检查 closed；按 E 触发后检查 25%、50%、100%、穿过门洞和 Fade，确认完整门板始终在 Player 后，只有裂纹/封印 FX 位于前方。

如需补齐 Remote UI 证据，F5 运行时切换 Godot 的 Remote Scene Tree，依次选择：

- `Chapter03Route/PersistentRuntime/ChapterRuntime/Player`（z=12）；
- 当前房间 `Doors/*/Presentation`（effective z=-30）；
- `BossGate/Visuals`（完整门体 effective z=-30）；
- `BossGate/Visuals/SealLights` 与 `WaxCrack`（effective z=16）。

同时在默认窗口、最大化窗口和正式 Stretch 模式各走一次上述四点。任何位置若出现 Player 头部/躯干或武器被完整建筑吞没，即应记录截图并将对应项降为 FAIL。
