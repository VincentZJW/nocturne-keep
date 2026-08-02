# Chapter IV Character Roster C0 / 第四章人物体系与数值锁定

- 章节：`Chapter IV: The Drowned Underkeep / 第四章：沉没下堡`
- 阶段：`CH4-C0`
- 状态：**DESIGN LOCKED / 尚未创建正式 EnemyData、Sprite 或 AI**
- 审计基线：2026-08-02，`master@a10bc5c` 加当前工作区实际配置
- 正式启动权威：`res://scenes/bootstrap/main_bootstrap.tscn`

## 1. C0范围与完成定义

本阶段只锁定人物体系、战斗岗位、数值、资产规格、架构复用和后续 Main/F5 测试路线。第四章正式敌人资源、EnemyData、AI、动画、Encounter 和 Boss 战均从后续 `CH4-C1` 起生产。本文件不是“已实装”声明。

本阶段明确不做：

- 不创建任何第四章 EnemyData 或 Boss Data；
- 不生成概念图、SpriteFrames、攻击特效或音频；
- 不实例化敌人到第四章阈值场景；
- 不修改 Player HP、第三章奖励武器伤害或前三章平衡；
- 不把第三章敌人脚本复制到第四章；
- 不把 C0 设计数据伪称为 Main 中已经可玩。

## 2. 项目与第四章现状审计

### 2.1 Main与正式章节入口

| 项目 | 审计结果 |
|---|---|
| `run/main_scene` | `res://scenes/bootstrap/main_bootstrap.tscn` |
| 第四章注册ID | `ChapterRegistry.CHAPTER_04_DROWNED_UNDERKEEP` |
| 第四章正式场景 | `res://chapters/chapter_04_drowned_underkeep/scenes/level/drowned_underkeep.tscn` |
| 当前正式出生点 | `CH4_START` |
| 当前Debug Ready | `false`；注册项仍为 planned profile |
| 正式进入方式 | 第三章 `CH3_UNDERKEEP_DESCENT` 的右侧入口，经 `SceneTransitionManager` 进入 `CH4_START` |

第四章当前只有入口阈值：一张正式入口背景、连续地面碰撞、`ChapterGameplayRuntime`、`CH4_START` 和章节标题。没有第四章敌人、Boss、Encounter、人物试炼、角色资源或专属战斗组件。

### 2.2 当前目录

已存在：

```text
res://chapters/chapter_04_drowned_underkeep/
├── assets/environment/threshold/
├── scenes/level/drowned_underkeep.tscn
└── scripts/level/drowned_underkeep.gd
```

后续阶段按以下章节所有权扩展，不把第四章角色散落到全局根目录：

```text
res://chapters/chapter_04_drowned_underkeep/
├── assets/
│   ├── enemies/<enemy_id>/{concept_art,sprites,animations,effects,audio,archive_legacy}/
│   └── bosses/soul_gaoler_ormund/{concept_art,sprites,animations,effects,audio,archive_legacy}/
├── scenes/{enemies,bosses,trials,encounters}/
├── scripts/{components,enemies,bosses,projectiles,trials}/
├── resources/{enemies,bosses,encounters}/
├── tests/{characters,combat,main}/
└── docs/
```

### 2.3 可复用架构与必须新建部分

直接复用：

- `EnemyCombatant`：统一死亡、目标、攻击窗口和Debug接口；
- `GroundEnemyBase`：重力、墙/地面RayCast、平台边缘、目标检测、移动边界、受击、死亡和朝向；
- `HealthComponent`、`HitboxComponent`、`HurtboxComponent`：生命、阵营、`attack_id`和单目标去重；
- `EncounterGroup`：延迟激活、存活/交战/攻击计数；
- `LootDropComponent`：死亡时动态掉落；
- `ChapterGameplayRuntime`：Player、HUD、重生和正式章节运行时。

第四章章节内新建：

- `Chapter04EnemyConfig`：集中容纳超过共享 `EnemyGroundConfig` 100 HP上限的数值；不扩大旧资源范围并制造回归；
- `Chapter04PoiseComponent`：第四章本地可复用韧性，不依赖第三章目录；
- `Chapter04Projectile`：带扫掠/射线碰撞、世界阻挡、生命周期、阵营和一次命中的鱼叉/泥弹基类；
- `Chapter04ShallowWaterContext`：只提供敌人水域移动倍率和有限状态效果；Player不进入游泳状态；
- `Chapter04PullResolver`：通过碰撞安全速度/位移请求实现有限拉扯，禁止直接改`global_position`穿墙；
- `SoulGaolerOrmundController`：章节专属Boss状态机。前三章没有统一Boss基类，不建立深继承。

审计确认项目没有独立的 `AttackContext` 类。第四章继续使用现有 `HitboxComponent` 的攻击ID、攻击类型、方向、来源和去重契约，不杜撰第二套上下文。

## 3. 前三章实际数值基线

### 3.1 Player与第三章奖励武器

| 项目 | 实际值 | 权威路径 |
|---|---:|---|
| Player最大生命 | 100 | `res://scripts/combat/health_component.gd` 默认值，Player场景无覆盖 |
| 第三章奖励武器 | `Thirteenfold Absolution Blades` | `res://chapters/chapter_03_chapel_of_thirteen_echoes/resources/weapons/thirteenfold_absolution_blades.tres` |
| Normal Attack | 14 | 同上 |
| Dash Attack | 28 | 同上 |

第四章击杀次数统一按 `ceil(HP / damage)` 计算；盾牌正面路由不溢出，盾与Body分别向上取整。

### 3.2 第一至第三章普通敌人区间

| 章节 | 实际HP区间 | 单次伤害区间 | Poise区间 | 说明 |
|---|---:|---:|---:|---|
| Chapter I | 30–50 Body；盾卫另有30 Shield | 5–10 | 未统一使用Poise | 当前工作区正式场景实际加载值；其中部分Ch1资源有未提交调整 |
| Chapter II | 48–96 | 4–14 | 0–4（仅旧式局部值） | 五种王庭敌人Data实值 |
| Chapter III | 70–126 | 8–17 | 30–82 | 六种正式敌人；专精敌人的`chapter_max_health`在`_ready()`写入Health |

第四章采用“整体上移、岗位分层”：基础人形已高于第三章低档位，重型单位超过第三章上限；伏击小怪和远程单位仍允许以低HP换岗位强度，避免所有敌人都成为血包。

### 3.3 第一至第三章Boss

| Boss | HP / 阶段 | 防御 | Poise | 主要伤害 | 当前阶段结构 |
|---|---|---|---|---:|---|
| Fallen Gate Knight | 180 Body + 100 Shield | 正面盾牌独立承伤 | 无统一Poise | 8–15 | Shield破碎触发狂战形态 |
| Hollow Duchess Seraphine | 220；55%进入P2 | P1 ×1.00；P2 ×0.85 | 60 / 80 | P1约10–14；P2最高16 | 共享剩余HP的两阶段 |
| Thirteenth Pontiff Edran | 360；198 HP进入P2 | P1 ×0.88；P2 ×0.80 | 110 / 145 | P1 7–15；P2最高20 | 共享剩余HP的两阶段 |

## 4. 第四章生态与岗位关系

本章采用两个互相解释的生态群：

1. **监牢职责残留**：溺牢狱卒、锁链重囚、淤水鱼叉手、沉水盾忏者、地牢行刑官与奥蒙德。他们体现巡查、拘束、拖回、阻挡、处刑和看守灵魂的旧制度。
2. **地下水生异变**：淤鳞袭掠者、泥沼巨蟾、下水裂口兽。他们源于污水、尸体、献祭残渣和地下生物污染，提供与人形监牢体系不同的高度、移动与攻击读法。

组合规则：

- 狱卒负责建立基础近战节奏；鱼叉手迫使Player改变楼层；
- 盾忏者控制正面推进，但必须留绕后空间；
- 重囚、巨蟾和行刑官只放宽场地，避免大体型堵死狭道；
- 袭掠者利用浅水加速，但扑击锁方向且有Recovery；
- 裂口兽只少量伏击，出现前强制可视/可听预警；
- 同组最多一个重型压迫核心，远程平台必须可达，不用不可接近的炮台制造假难度。

## 5. 最终普通敌人与精英数值

以下数值为C0锁定值；后续若F5实测需要调整，必须在单独平衡任务中记录修改前后值。

| ID / 名称 | 岗位 | HP | Shield | Poise | 攻击与伤害 | Normal / Dash击杀 |
|---|---|---:|---:|---:|---|---|
| `drowned_gaoler` 溺牢狱卒 | 基础中近战 | 104 | — | 44 | Cleave 12；Hook Jab 11；Shoulder Check 10 | 8 / 4 |
| `chainbound_convict` 锁链重囚 | 重型地面压迫 | 152 | — | 92 | Chain Sweep 16；Ball Slam 19；Chain Drag 11 | 11 / 6 |
| `mire_harpooner` 淤水鱼叉手 | 可抵达平台远程 | 96 | — | 38 | Harpoon 13；Hooked Bolt 11；Shaft Strike 10 | 7 / 4 |
| `sunken_shield_penitent` 沉水盾忏者 | 防守推进 | 132 Body | 72 | 70 | Bash 14；Hook Thrust 14；Gate Crush 17 | 背后10 / 5；正面16 / 8 |
| `mirefin_raider` 淤鳞袭掠者 | 浅水高速近战 | 116 | — | 50 | Claw 13；Lunge 16；Bite Rush 14 | 9 / 5 |
| `bog_toad` 泥沼巨蟾 | 大型区域控制 | 142 | — | 76 | Leap 17；Mud Spit 11；Tongue 13 | 11 / 6 |
| `sewer_maw` 下水裂口兽 | 低矮预警伏击 | 82 | — | 26 | Bite 10；Ambush 14；Latch 8 | 6 / 3 |
| `underkeep_executioner` 地牢行刑官 | 精英重装 | 244 | — | 126 | Cleave 20；Reaper 18；Slam 23；Drag 13 | 18 / 9 |

校准说明：

- 相对附件建议值，普通基础/重型HP小幅上调6–8点，精英上调12点，使第四章总体耐久确实高于第三章，同时保留远程与伏击单位的脆弱岗位。
- 未提高Player伤害。第三章奖励武器依然是14/28，普通敌人实际击杀范围为3–11次Dash或Normal对应6–16次；没有把每只敌人都堆到高血量。
- Shield Penitent正面不溢出：Normal需`ceil(72/14)+ceil(132/14)=6+10=16`，Dash需`ceil(72/28)+ceil(132/28)=3+5=8`；背后直接伤Body。
- Player满血可承受的理论命中次数按`ceil(100 / damage)`：10伤害10次、11伤害10次、12伤害9次、13伤害8次、14伤害8次、16伤害7次、17伤害6次、19伤害6次、20伤害5次、23伤害5次。实际无敌帧和攻击去重仍由现有组件约束。

### 5.1 行为与公平性锁定

- 溺牢狱卒：Windup 0.40–0.52秒，Recovery 0.50–0.66秒，最多连续2击。
- 锁链重囚：慢转身；重击明显Recovery；Active期间仅Poise规则决定中断；禁止窄平台。
- 淤水鱼叉手：默认在中/高层宽平台；投射物受世界碰撞；Hook拉扯20–26px且不穿墙。
- 沉水盾忏者：正面Normal/Dash优先伤盾，背后伤Body；盾破后0.72秒Guard Break且永久失盾。
- 淤鳞袭掠者：浅水移速提高，但Lunge提前锁向，扑空后不可立即追踪修正。
- 泥沼巨蟾：Leap有地面落点；Mud Spit减速25%持续2秒且不叠加；不连续跳扑。
- 下水裂口兽：伏击前至少0.45秒水泡/淤泥预警；不持续吸血；同组不大量堆叠。
- 地牢行刑官：同Encounter最多1只；Guillotine Slam有至少0.78秒Windup；不召唤杂兵。

## 6. Boss：Soul Gaoler Ormund / 魂狱看守·奥蒙德

### 6.1 身份与视觉

奥蒙德是淹没地牢的最高典狱官，负责把失败献祭者的灵魂锁回尸体和牢房。视觉高度锁定为Player约1.95倍。

Phase 1是“仍在执行职责的重型典狱长”：深水刑狱冠、超宽肩甲、背部魂笼、粗锁链、大钥匙与`Soul-Prison Key Halberd / 魂狱钥戟`。Phase 2是“魂笼从体内破裂的监牢怪物”：头盔裂开、胸背魂笼外翻、锁链与手臂/武器融合、姿态前倾并增高。Phase 2必须重绘身体、武器、魂笼与动作，不得只换色或加蓝光。

### 6.2 最终数值

| 项目 | Phase 1 | Phase 2 |
|---|---:|---:|
| 总HP | 560共享HP | 308 HP（55%）进入 |
| 伤害倍率 | ×0.82 | ×0.72 |
| Poise | 150 | 190 |
| Stagger | 0.48秒 | 0.38秒 |
| Stagger Protection | 3.4秒 | 4.0秒 |
| 普通攻击间隔 | 0.82–1.04秒 | 0.68–0.88秒 |
| 强制Recovery | 连续最多2击后1.10–1.30秒 | 连续最多2击后0.95–1.15秒 |

伤害倍率只应用一次，采用`maxi(1, roundi(raw_damage * multiplier))`。不叠加隐藏Armor、第二层百分比减伤或未显示护盾。

第三章奖励武器实伤：

| Phase | Normal 14 | Dash 28 |
|---|---:|---:|
| Phase 1 ×0.82 | 11 | 23 |
| Phase 2 ×0.72 | 10 | 20 |

纯单一攻击的理论击杀量：P1需削减252 HP，为23次Normal或11次Dash；P2需削减308 HP，为31次Normal或16次Dash；合计约54次Normal或27次Dash。实际战斗目标4–6分钟必须由攻击窗口、移动与场地机制实测确认，C0不把理论次数伪称为已达到时长；若熟练实测超过6分钟，优先放宽Recovery/受击窗口，而不是叠加伤害。

### 6.3 Phase 1攻击

| 攻击 | 伤害 | 时序/约束 |
|---|---:|---|
| Gaoler Key Halberd Sweep | 18 | 0.60 Windup / 0.15 Active / 0.76 Recovery |
| Chain Anchor Slam | 22 | 0.82 / 0.17 / 1.05；落点提示 |
| Prison Hook Drag | 15 | 有限拉扯；碰撞安全；不拉进Boss身体 |
| Floodgate Charge | 19 | 短冲锋、提前锁向；撞墙/扑空强Recovery |
| Soul Cage Pulse | 14 | 有限半径，可远离或跳过；非全屏必中 |

### 6.4 Phase 2攻击

| 攻击 | 伤害 | 时序/约束 |
|---|---:|---|
| Chainstorm Cleave | 21 | 多条锁链依次生效，不同时铺满Hitbox |
| Undertow Pull | 17 | 地面暗流；Player可移动、跳跃、Dash反抗 |
| Drowned Cell Rupture | 23 | 固定牢笼标记；预警至少0.85秒并保留安全区 |
| Soul Shackle | 16 | 仅禁Dash约1.2秒；仍可移动、跳跃、攻击 |
| Flooded Judgment | 25 | 低血量大招；固定水流路线和安全区；Cooldown≥6.5秒 |

水位机制只允许局部、短时、可反抗的减速/牵引。Player始终能移动、跳跃和攻击，不进入游泳状态；水面和波纹不得覆盖Player、武器或攻击提示。

## 7. 原画计划与核心识别元素

| 角色 | 原画必交付 | 必须保留的识别元素 |
|---|---|---|
| Drowned Gaoler | 三视/剪影、钥匙钩与砍刀、动作页 | 狱卒帽、钥匙环、锁链、湿皮甲、短钩 |
| Chainbound Convict | 三视/剪影、木枷/链球结构、动作页 | 宽肩、木枷、脚腕镣、粗链、链球、囚衣 |
| Mire Harpooner | 三视/剪影、鱼叉/绳钩拆解、平台姿态 | 呼吸罩/鱼骨面具、长鱼叉、绳索、浮标、编号 |
| Shield Penitent | 三视/剪影、牢门盾四阶段、短戟动作 | 牢门铁条/铰链/封印、水位线、忏悔袍 |
| Mirefin Raider | 三视/剪影、骨骼/鳍腮爪、运动页 | 鱼骨头、腮裂、背鳍、长臂、蹼爪、锁链残布 |
| Bog Toad | 三视/剪影、骨骼/口腔/后腿、跳扑页 | 低伏大体、肿包苔藓、真实四肢、黏液、骨增生 |
| Sewer Maw | 三视/剪影、口部牙层/触肢、伏击页 | 贴地裂口、多层牙、短爪、骨刺、排水垃圾 |
| Executioner | 三视/剪影、护甲层次、完整钩斧、攻击页 | 铁面具、湿皮围裙、刑具、巨刃/柄/配重、重甲 |
| Ormund | P1/P2三视、两阶段剪影、武器、刑狱冠、魂笼、变身/攻击/死亡/比例页 | P1典狱冠与魂笼；P2破裂躯体、外翻灵魂、融合锁链与钥戟 |

每个普通敌人至少交付正面/三分之二、横版侧视、背面、黑色剪影、武器或生理结构、配色条、Idle/Move/Attack/Hurt/Death姿态。非人形额外提供结构和运动图；精英额外提供完整武器与护甲层次；Boss按附件的14项清单完整生产。

## 8. Sprite与动画生产计划

### 8.1 画布规格

| 角色 | 正式像素画布 | 理由 |
|---|---|---|
| Drowned Gaoler | 96×96 | 基础人形，保留钥匙/钩具 |
| Chainbound Convict | 128×128 | 木枷、链球与重型轮廓 |
| Mire Harpooner | 128×96 | 长鱼叉横向延伸不裁切 |
| Shield Penitent | 128×128 | 牢门盾厚度与损坏阶段 |
| Mirefin Raider | 128×96 | 前倾长臂与扑击空间 |
| Bog Toad | 128×128 | 大型低伏身体与跳扑 |
| Sewer Maw | 96×96 | 低矮口部和短扑，避免无意义大画布 |
| Executioner | 160×128 | 精英高大轮廓与完整钩斧 |
| Ormund | 192×192 | P2展开锁链、魂笼和大型武器 |

全部透明PNG、整数锚点/脚底、Nearest、Filter关闭、Mipmaps关闭、无损导入；角色场景显式`texture_filter=1`。概念图不得直接缩小冒充Sprite。

### 8.2 动画清单

- Drowned Gaoler：`idle, patrol, alert, approach, turn, cleave, hook_jab, shoulder_check, light_hit, stagger, hurt, death`。
- Chainbound Convict：`chained_idle, heavy_walk, alert, turn, chain_sweep, ball_slam, chain_drag, poise_hit, stagger, hurt, death_collapse`。
- Mire Harpooner：`platform_idle, aim, throw_windup, throw_release, throw_recovery, hook_shot, close_strike, turn, hurt, stagger, death`。
- Shield Penitent：`idle_shielded, walk_shielded, block_hit, bash, hook_thrust, gate_crush, shield_break, guard_break, idle_unshielded, walk_unshielded, hurt, stagger, death`；四阶段盾损坏永久映射。
- Mirefin Raider：`crouched_idle, water_skitter, land_move, alert, claw, lunge, bite_rush, turn, hurt, stagger, death`。
- Bog Toad：`swamp_idle, crawl, inflate, leap_windup, leap_air, land, mud_spit, tongue_snap, hurt, stagger, death`。
- Sewer Maw：`submerged_hidden, bubble_telegraph, emerge, skitter, bite, ambush, hurt, stagger, death_dissolve`。
- Executioner：`idle, heavy_walk, alert, turn, executioner_cleave, hooked_reaper, guillotine_slam, prisoner_drag, poise_hit, stagger, hurt, death`。
- Ormund P1：`dormant, intro, idle_p1, walk_p1, turn_p1, halberd_sweep, anchor_slam, hook_drag, floodgate_charge, soul_cage_pulse, light_hit_p1, stagger_p1, phase_transition`。
- Ormund P2：`idle_p2, move_p2, turn_p2, chainstorm_cleave, undertow_pull, cell_rupture, soul_shackle, flooded_judgment, light_hit_p2, stagger_p2, death_start, death_collapse, soul_release`。

每种攻击必须在运行时拆出可读的Windup/Active/Recovery事件；若美术资源使用单动画，控制器仍按帧事件开启/关闭Hitbox，不能依赖动画名猜有效窗口。

## 9. 后续场景、资源与Main计划

### 9.1 正式路径模板

以溺牢狱卒为例：

```text
assets/enemies/drowned_gaoler/concept_art/
assets/enemies/drowned_gaoler/sprites/
assets/enemies/drowned_gaoler/animations/
assets/enemies/drowned_gaoler/effects/
scenes/enemies/drowned_gaoler.tscn
scripts/enemies/drowned_gaoler.gd
resources/enemies/drowned_gaoler_data.tres
```

Boss使用：

```text
assets/bosses/soul_gaoler_ormund/{concept_art,sprites,animations,effects,audio}/
scenes/bosses/soul_gaoler_ormund.tscn
scripts/bosses/soul_gaoler_ormund.gd
resources/bosses/soul_gaoler_ormund_data.tres
```

### 9.2 阶段门

- `CH4-C1`：四种人形普通敌人概念原画；
- `CH4-C2`：三种非人形敌人概念原画；
- `CH4-C3`：精英与Boss两阶段原画；
- `CH4-C4`：七种普通敌人正式Sprite、动画、AI并逐只Main验证；
- `CH4-C5`：行刑官正式实装；
- `CH4-C6`：Ormund P1、变身、P2与Boss战；
- `CH4-C7`：人物试炼、Main全回归和强制QA。

## 10. Main/F5测试计划

C0当前可验证：F5权威仍为`MainBootstrap`；通过正式第三章结尾可进入第四章`CH4_START`阈值。当前阈值**不会出现敌人**，这是C0正确边界。

后续C4–C7必须建立并注册以下Debug入口，同时保留正式路线：

| Spawn | 用途 |
|---|---|
| `CH4_START` | 正式章节开场 |
| `CH4_CHARACTER_TRIAL` | 九角色动画/比例/受击/死亡总览 |
| `CH4_HUMANOID_COMBAT` | 四种人形组合 |
| `CH4_CREATURE_COMBAT` | 三种异变生态组合 |
| `CH4_ELITE_TRIAL` | 行刑官单体与组合 |
| `CH4_BOSS_PHASE_01` | Ormund完整入场/P1 |
| `CH4_BOSS_PHASE_02` | 仅Debug的P2快速验收 |

最终F5验收必须覆盖：

1. `MainBootstrap -> 第三章结尾 -> CH4_START`正式路线；
2. 七种普通敌人均使用最新PackedScene/SpriteFrames，旧引用为0；
3. 平台远程可达、墙体阻挡投射物、重型单位不掉平台；
4. Normal 14 / Dash 28击杀次数符合本表且同一`attack_id`只结算一次；
5. Poise、Stagger、盾牌无溢出、有限拉扯和浅水倍率符合锁定契约；
6. Boss P1/P2倍率只应用一次，五种攻击各有安全区和恢复窗口；
7. Player HP/HUD/重生、掉落、Encounter计数、Camera和层级不回归；
8. Godot 4.7.1 Output/Debugger无红色错误，证据保存到`res://docs/qa/chapter_04_characters/`。

## 11. C0 QA结论

| 检查项 | 状态 | 证据/结论 |
|---|---|---|
| Main权威路径 | PASS | `project.godot`明确指向MainBootstrap |
| 第四章目录与入口 | PASS | 注册场景、`CH4_START`与阈值场景均存在 |
| 前三章普通敌人数值 | PASS | 已读取当前资源与专精敌人运行时HP写入 |
| 前三章Boss数值 | PASS | 已读取Boss配置/脚本默认值与阶段倍率 |
| 第三章奖励武器 | PASS | 14 Normal / 28 Dash |
| 第四章阵容与数值 | PASS / DESIGN | 7普通+1精英+1两阶段Boss已锁定 |
| 第四章EnemyData | NOT STARTED | C0明确禁止提前创建 |
| 正式Sprite/AI/Main敌人 | NOT STARTED | 属于C1–C7 |

已知风险：当前工作区存在与本阶段无关、尚未提交的第一章平衡、第三章Underkeep和共享资源改动。C0以“当前工作区实际运行配置”为数值审计基准，但不修改、不暂存也不替这些改动背书；进入C4前必须重新确认基线没有被后续提交改变。
