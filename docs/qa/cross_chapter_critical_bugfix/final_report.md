# 第一至第四章严重问题修复强制 QA 报告

日期：2026-08-05
引擎：Godot 4.7.1 Standard（`a13da4feb`）
正式入口：`res://scenes/bootstrap/main_bootstrap.tscn`

## QA 总结果

自动化、正式 MainBootstrap 路由与图形证据结果为 **PASS**。完整产品验收为
**PARTIAL**：所有九类阻断缺陷均已修复并有可重复测试，仍需用户完成玩家手感、
镜头构图和长时间实机试玩的主观验收。没有关键修复项处于 FAIL。

| 问题 | 状态 | 根因 | 修复证据 |
|---|---|---|---|
| 第一章 Boss 巨剑比例 | PASS | 武器烘焙在 165 张帧中，斜持时可见刃长被盾与手臂遮蔽 | V3 生成器重绘全部 41 动画；`fallen_gate_knight_greatsword_revision/01-08` |
| 第一章 Boss 双手持剑 | PASS | Phase 2 有双手意图，但旧帧的第二握点和长刃不够清楚 | Phase 2 全套姿态、转身、连斩、突刺、受击和死亡均重新生成；Boss 测试 PASS |
| 第二章倒悬猎兽循环攻击 | PASS | 返回 `HANG` 后保留同一 target，`set_target()` 的同对象早退使其无法重新 Telegraph | 新增 `reengage_delay=0.65` 与 `HANG -> ALERT_TELEGRAPH` 重入；20 次状态压力 + Main 连续 5 轮证据 |
| 第三章未知敌人身份 | PASS | 截图中的正式身份是 `Confessional Wraith / 告解幽魂`，不是未知占位物 | `confessional_wraith.tscn`、正式 Confessionals Main 截图 |
| 第三章未知敌人可击杀性 | PASS | `starts_hidden` 会关闭 Hurtbox，却保留可见 Sprite；无 target 时永久呈现为“可见但无敌” | Hidden 同步隐藏 Sprite，Reveal 同步开启视觉/Hurtbox；20 普通击杀、5 Dash 击杀、135 次伤害事件 |
| 第三章 Boss 奖励去重 | PASS | Boss 房展示武器在演出结束后未隐藏，遗物台另有唯一真实 Pickup | Boss 房只保留共鸣演出；唯一 Pickup 留在遗物台；10 完整流程、5 未领取重载、10 已领取重载 |
| 第四章敌人主动攻击 | PASS | 共享反应状态恢复不完整，部分实例会停在 GuardBreak；正式 Boss 房仍是占位槽 | 修复反应退出；正式 Area 14 实例化 Ormund；8 角色 × 每种招式 15 次，Boss runtime PASS |
| 第四章敌人可受伤 | PASS | 层/Mask 本身正确，状态卡死使敌人表现为静态装饰 | 8 角色各击杀 20 次（160 次），Normal/Dash 上下文与死亡清理通过 |
| 第四章盾牌比例 | PASS | 牢门盾覆盖头、腿和主体动作 | 正式 ShieldVisual 统一缩放为 0.78，四损坏阶段使用同一变换；Main 证据 03 |
| 第四章低质量角色返工 | PASS | 图 8 确认为 `Chainbound Convict / 锁缚囚徒`，旧版缺少木枷、铁面、链球和腿部 | 128×128 全动画重绘并重建正式资源；Main 证据 03 |
| Broken Chainway 出口 | PASS | 出口是不可读的自动 Area，没有门拱、提示或显式输入 | `ExitArch + Prompt`，E 交互，正式转场到 Area 04；10 次转场、5 次 checkpoint reload |
| 全章节地图限高 | PASS | 只有 Camera limit，缺少共享实体碰撞和 AI 安全高度 | 四章各一个 `WorldBounds2D`，共 16 面物理墙；4 飞行家族 80 次 clamp，20 次 Player 顶碰，20 次 reload |
| Main/F5 集成 | PASS | 多项内容此前只在 Trial/局部房间 | 图形脚本均通过 MainBootstrap 进入正式章节；默认 Main 启动 opening cinematic |
| Output 与 Debugger | PASS | 运行时脚本/资源错误均已消除 | import/parse、默认 Main、15 个聚焦测试及 CH3/CH4 GUI Main 证据均无红错 |

> 工具说明：第二章 GUI 截图进程在退出 Godot 时仍会报告 Metal/GLES3
> Texture/RID 清理警告；功能过程已输出 PASS，正式 Main、无窗口压力测试和其他 GUI
> Main 证据均无该错误。它被记录为证据工具的退出清理限制，不是 Silent Court
> 运行时错误，也没有隐藏在上述正式运行结果中。

## 截图问题逐项映射

| 原图 | 正式对象 | 正式场景/节点 | 结果 |
|---|---|---|---|
| 1 | Fallen Gate Knight | `ravenmourn_outskirts.tscn/Main/World/CastleEntranceArea/FallenGateKnight` | 新巨剑全帧替换 |
| 2 | Hanging Stalker | `silent_court.tscn/GameplayWorld/Enemies/EncounterE08/EncounterE08_01_HangingStalker`（同场景另有 E10/E11/E14） | 连续循环恢复 |
| 3 | Confessional Wraith | `chapter_03_route.tscn/RoomHost/<Confessionals>/.../ConfessionalWraith` | 可见性与 Hurtbox 同步 |
| 4-5 | Boss 房展示 + 遗物台真 Pickup | `Ch3BossSanctumRoom/RewardSequence`、`Ch3PostBossRoom/PostBossReliquary` | 单一领取源 |
| 6 | Mire Harpooner / Mirefin Raider | `ch4_01_flooded_intake.tscn` | AI、攻击、受伤回归通过 |
| 7 | Drowned Gaoler / Shield Penitent / Sewer Maw | `ch4_02_rusted_cellblock.tscn` | 三类回归通过，盾比重修正 |
| 8 | Chainbound Convict | `ch4_02_rusted_cellblock.tscn` | 全动画正式重绘 |
| 9-10 | Mirefin Raider / Bog Toad | `ch4_03_broken_chainway.tscn` | 战斗与右侧出口通过 |
| 11 | 用户比例参考 | 外部参考，不是运行时资源 | 用于 Boss 巨剑比例重绘 |

完整 QA0 路径与身份审计见
`res://docs/qa/cross_chapter_critical_bugfix_qa0.md`。

## 第一章 Boss 巨剑资源与动画

- 生成源：`res://chapters/chapter_01_ravenmourn_outskirts/scripts/tools/generate_fallen_gate_knight_art_v3.gd`
- 正式帧：`res://chapters/chapter_01_ravenmourn_outskirts/assets/boss/fallen_gate_knight/sprites/`
- 正式资源：`res://chapters/chapter_01_ravenmourn_outskirts/resources/boss/fallen_gate_knight_sprite_frames.tres`
- 结果：41 个动画、165 帧统一重绘；Phase 1 盾剑、四段盾损、破盾、Phase 2 双手剑和死亡均使用同一长剑设计。
- 战斗数值保持：Body HP 180、Shield HP 100；没有扩大正式 Hitbox。
- 压力数据：20 个受控完整战斗模型、20 次破盾、Phase 2 每种攻击至少 15 次；模拟时长 26.98–33.54 秒，均值 29.46 秒。

## 倒悬猎兽状态机循环

正式循环现在为：

`HANG -> ALERT_TELEGRAPH -> DROP -> GROUND_RECOVERY/CLAW -> RETREAT -> RETURN_TO_ANCHOR -> HANG(reengage 0.65s)`

返回顶部不会清空仍合法的 Player，也不会立即无预警再落下。`HANG` 的独立计时器
到期后才重新进入 Telegraph。自动测试直接覆盖“玩家始终留在房间”的同 target 路径
20 次；Main 证据覆盖第一次、返回顶部、第二次和第五次预警。

## 第三章未知敌人诊断数据

- 正式身份：Confessional Wraith / 告解幽魂。
- Scene：`res://chapters/chapter_03_chapel_of_thirteen_echoes/scenes/enemies/confessional_wraith.tscn`
- Data：`res://chapters/chapter_03_chapel_of_thirteen_echoes/resources/enemies/confessional_wraith_data.tres`
- 当前 HP 82、Poise 38；没有额外 Defense 或伤害减免。
- Hurtbox layer/mask：16/32，与 Player attack layer 32 对应。
- 自动诊断：普通伤害/击杀 20 次、Dash 击杀 5 次、总伤害事件 135 次；受击后均退出 LightHit/Stagger。

## 第三章奖励生成链路

唯一权威领取链路为：

`Edran defeated -> RewardSequence resonance-only -> story flag reward_spawned -> PostBossReliquary -> ThirteenfoldAbsolutionPickup -> Inventory/Equipment -> empty reliquary -> Underkeep gate`

Boss 房不再保留一把可误认为 Pickup 的武器。重复 E 不增加库存；领取前 reload 保留，
领取后 reload 为空；最终伤害仍是 14/28。

## 第四章全部敌人 AI / Hitbox / Hurtbox

| 角色 | 正式 HP/Poise | 主伤害 | 自动结果 |
|---|---:|---:|---|
| Drowned Gaoler | 104/44 | 12 | 20 kills；全部 3 招各 15 次 |
| Chainbound Convict | 152/92 | 16 | 20 kills；全部 3 招各 15 次 |
| Mire Harpooner | 96/38 | 13 | 20 kills；全部 3 招各 15 次 |
| Sunken Shield Penitent | 132/70 | 14 | 20 kills；盾路由与全部 3 招各 15 次 |
| Mirefin Raider | 116/50 | 13 | 20 kills；全部 3 招各 15 次 |
| Bog Toad | 142/76 | 17 | 20 kills；全部 3 招各 15 次 |
| Sewer Maw | 82/26 | 10 | 20 kills；可用招式各 15 次 |
| Underkeep Executioner | 244/126 | 20 | 20 kills；全部 3 招各 15 次 |
| Soul Gaoler Ormund | 560 | Boss data | 正式 Area 14、两阶段 runtime 与 Main 证据 PASS |

碰撞契约保持：Enemy body 4/3、Hurtbox 16/32、Enemy hitbox 64/8；Player body
2/5、Hurtbox 8/320、attack 32/16。同一次 AttackContext 只结算一次。

## 盾牌缩放前后数据

- 源贴图：128×128，intact/cracked/critical/broken 四阶段。
- 正式 VisualRoot 锚点：`(-15, -37)`。
- 旧运行比例：1.00；新运行比例：0.78（视觉尺寸约 99.8×99.8）。
- 相同缩放由单一 `ShieldVisual` 节点承载，损坏阶段不改变尺寸；身体头部和腿部重新可读。

## 第四章角色 95% 复刻

截图 8 的角色是 Chainbound Convict。正式 128×128 帧现在保留铁面、木枷、裸露重体、
腕镣、双链与配重，并覆盖 idle/walk/turn/alert、三类攻击、受击、硬直和死亡。
原始概念和正式运行引用没有通过临时 Sprite override 分叉。

## Broken Chainway 转场日志

- Room：`res://chapters/chapter_04_drowned_underkeep/scenes/rooms/ch4_03_broken_chainway.tscn`
- Exit：`Transitions/ExitEast`
- 目标：`CH4_AREA_04 / EntryWest`
- 新节点：`ExitEast/ExitArch`、`ExitEast/Prompt`
- 输入：InputMap `interact`（E），不读取物理键码。
- 自动结果：10/10 转场成功，5/5 checkpoint reload 成功；每次只有一个 Player/HUD，RoomTransitionController 完成 Fade/Swap。

## 全场景 World Bounds

| 章节 | 正式 Level | top_limit_y | actor bounds | 安全飞行 Y | Ceiling | 飞行 QA |
|---|---|---:|---|---:|---|---|
| I | `ravenmourn_outskirts.tscn` | 0 | `(0,0,6800,720)` | 56 | `WorldBounds2D/TopCeiling` | Gargoyle 20 clamp + 5 reload |
| II | `silent_court.tscn` | -1900 | `(0,-1900,7200,2620)` | -1844 | `WorldBounds/WorldBounds2D/TopCeiling` | Hanging Stalker 20 clamp + 5 reload |
| III | `chapter_03_route.tscn` | 0 | `(0,0,4096,720)` | 52 | `WorldBounds2D/TopCeiling` | Chorister/Seraph 各 20 clamp + 各 5 reload |
| IV | `drowned_underkeep.tscn` | 0 | `(0,0,4096,720)` | 52 | `WorldBounds2D/TopCeiling` | 当前无正式飞行 roster；物理顶墙覆盖全部换房 |

共享节点生成 Top/Bottom/Left/Right 四个 `StaticBody2D`，Player 通过碰撞停下；飞行 AI
使用同一安全边界重整 anchor 与垂直速度。自动覆盖总计 16 个墙、80 次飞行 clamp、
20 次 Player 顶碰和 20 次场景实例 reload。不同章节各 5 次玩家 Jump/Double Jump/
Air Dash/Knockback/高台手感仍属于人工验收，不把结构测试冒充手感测试。

## F5 测试路线

保持 `run/main_scene` 不变，只修改 `DebugRunConfig` 后按 F5：

- CH1：`CHAPTER_01_RAVENMOURN_OUTSKIRTS` + `CH1_BOSS`（Boss/巨剑）；正式石像鬼房用于高度复核。
- CH2：`CHAPTER_02_SILENT_COURT` + `CH2_START`，前往 E08 画像长廊观察 Stalker 五轮循环。
- CH3：`CHAPTER_03_CHAPEL_OF_THIRTEEN_ECHOES` + `CH3_CONFESSIONALS`、`CH3_BOSS`、`CH3_REWARD_TEST`。
- CH4：`CHAPTER_04_DROWNED_UNDERKEEP` + `CH4_AREA_03`（转场）、`CH4_AREA_02`（敌人/盾）、`CH4_AREA_14`（Ormund）。
- 默认 Debug 关闭：F5 进入 `opening_cinematic.tscn`，证明正式 Bootstrap 未被替换。

## 实际命令与结果

- `Godot --headless --editor --path . --quit` — PASS，无 parser/resource 红错。
- `Godot --headless --path . --quit-after 600` — PASS，输出正式 Opening 路由。
- Chapter I Boss counter/geometry/room tests — PASS；20 fights / 20 breaks / Phase 2 each 15。
- Chapter II prototype test — PASS；Stalker retained-target rearm 20/20。
- Chapter III Wraith test — PASS；20 normal kills / 5 dash kills / 135 damage events。
- Chapter III W4 reward — PASS；10 flows / 5 uncollected reloads / 10 collected reloads。
- Edran full Boss regression — PASS；192×192 正式帧、6 Phase 2 attacks、20-run model。
- Chapter IV enemy runtime/Main — PASS。
- Chapter IV combat stress — PASS；8 roles / 160 kills / 360 attacks / 5 encounter reloads。
- Ormund runtime — PASS。
- Broken Chainway stress — PASS；10 transitions / 5 checkpoint reloads。
- Chapter IV formal/Main route — PASS；17 rooms / 46 enemies。
- Cross-chapter actor bounds — PASS；4 chapters / 16 physical walls。
- Cross-chapter airborne limits — PASS；4 families / 80 clamp / 20 Player / 20 reload。
- GUI Main evidence — CH2 functional PASS、CH3 PASS、CH3 reward PASS、CH4 PASS。

## 证据路径

- Chapter I Boss：`res://docs/qa/fallen_gate_knight_greatsword_revision/`
- Chapter II Stalker：`res://docs/qa/cross_chapter_critical_bugfix/chapter_02_main/`
- Chapter III Wraith：`res://docs/qa/cross_chapter_critical_bugfix/chapter_03_main/`
- Chapter III reward：`res://docs/qa/chapter_03_thirteenfold_absolution/w4/`
- Chapter IV：`res://docs/qa/cross_chapter_critical_bugfix/chapter_04_main/`
- QA0：`res://docs/qa/cross_chapter_critical_bugfix_qa0.md`

## PARTIAL / FAIL 与人工验收边界

- FAIL：无。
- PARTIAL：逐章玩家手感（Jump/Double Jump/Air Dash/Knockback/高台起跳各 5 次）、
  Boss 巨剑主观压迫感、盾牌可读性和第四章 encounter 公平性必须由用户实际操控确认。
- PARTIAL：第二章图形证据脚本退出时的 Metal/GLES3 资源清理警告；正式 Main 与功能测试无红错。

本轮没有修改 Player HP、伤害、Boss 数值、章节掉落、存档格式或 run/main_scene。
