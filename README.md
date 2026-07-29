# Nocturne Keep / 夜幕古堡

原创哥特风横版 2D 动作闯关游戏灰盒原型，使用 Godot Engine 4.7.1 标准版与 GDScript 开发。

当前版本：`第二章 Boss 美术 Stage 2 · 空心公爵夫人·瑟芙琳`

第三章Boss当前仅完成B0设计与战斗基线锁定：正式身份为`The Thirteenth Pontiff, Edran / 第十三响教宗·埃德兰`，确定360 HP、55%转阶段阈值、单层防御倍率、分阶段Poise、两种受限尸骸召唤及Main/F5接入计划。Boss战斗实体、美术、动画、奖励和第四章跳转仍未实现，不能视为可玩Boss。权威规格见[第三章埃德兰Boss B0规格](chapters/chapter_03_chapel_of_thirteen_echoes/docs/chapter_03_thirteenth_pontiff_edran_boss_spec.md)，审计证据见[第三章Boss B0审计报告](docs/qa/chapter_03_boss_b0/report.md)。

第二章普通敌人美术 Stage 1 已接入正式 Silent Court 路线：空壳侍从、王庭戟卫、哀悼铠甲、血烛侍祭与倒悬猎兽均通过 F5/Main 使用章节内正式概念图与扩展 64×64 SpriteFrames。验收索引见 `docs/qa/chapter_02_enemy_boss_art_rework/stage_1_report.md`。

第二章Boss美术 Stage 2 已接入同一正式路线：瑟芙琳现在使用独立的96×96 Phase 1礼服/白瓷面具形态、39帧完整破面变身和无面骨扇Phase 2形态，共362张正式像素帧。原有220 HP、55%转阶段阈值、AI、攻击判定、遗物龛与第三章通道保持不变。强制QA见 `docs/qa/chapter_02_enemy_boss_art_rework/stage_2_report.md`。

## 章节生产规范

任何新章节、章节扩展、正式场景返修、普通/精英敌人、Boss或重要NPC任务开始前，必须先读取根目录[AGENTS.md](AGENTS.md)以及以下四份项目级长期规范：

- [章节场景设计工作流](docs/production/chapter_scene_workflow.md)
- [章节人物设计工作流](docs/production/chapter_character_workflow.md)
- [章节生产检查清单](docs/production/chapter_production_checklist.md)
- [章节强制QA标准](docs/production/chapter_qa_standard.md)

正式章节交付必须先理解背景故事、先补齐章节资产，再完成保存场景/人物、MainBootstrap/F5集成和强制QA。概念图精细但实装粗糙、只在F6或测试房可见、仍使用占位几何、运行时继续引用旧素材，均不能标记为完成。普通任务不能默认忽略这些规范；任何例外必须明确指出规则并获得用户批准。

## 当前范围

F5首先播放70.2秒、8镜头、可长按ESC/Enter跳过的双语叙事开场，然后进入约69秒的`Veilbound Catacomb / 暮帷墓窟`剧情复苏。玩家在断魂祭坛复魂、与守烛人完成30句双语台词、拾回双匕首并自行穿过符文石门后，才进入正式Main的`DarkForestTutorialSpawn`。第一关现有11步非阻塞教程、18个一次性EncounterGroup和34只普通敌人。第二章现已重构为九房间、三楼层的蛇形古堡路线，包含15组正式Encounter、38只普通敌人、五种第二章敌人和完整接入Silent Ballroom的两阶段Boss空心公爵夫人·瑟芙琳；商店与最终环境精修仍未开始。

## 环境要求

- macOS（主要开发环境）
- Godot Engine 4.7.1 Standard
- Git

请将 `GODOT_BIN` 设置为本机 Godot 4.7.1 可执行文件，例如：

```bash
GODOT_BIN="/absolute/path/to/Godot"
```

该变量只用于本地运行，不会写入游戏逻辑、资源路径或存档。

## 运行项目

在仓库根目录执行：

```bash
"$GODOT_BIN" --editor --path .
```

按 `F5` 会先运行唯一正式入口：

```text
res://scenes/bootstrap/main_bootstrap.tscn
```

`MainBootstrap`是唯一启动场景和路由执行者。默认`DebugRunConfig.debug_chapter_start_enabled = false`，所以F5自动选择`res://scenes/cinematics/opening_cinematic.tscn`，Opening自然结束或合法长按跳过后进入`res://scenes/levels/veilbound_catacomb.tscn`，墓窟流程完成后才进入第一章。`ChapterStartRouter`只解析经过校验的Debug目标，不再通过Autoload `_ready()`替换刚加载的Opening。Release构建始终忽略Debug章节启动；不要手工改写`run/main_scene`。

第一章正式根目录是`res://chapters/chapter_01_ravenmourn_outskirts/`，主场景是`res://chapters/chapter_01_ravenmourn_outskirts/scenes/level/ravenmourn_outskirts.tscn`。若要直接验证第一章，将`scripts/systems/debug_run_config.gd`中的`debug_chapter_start_enabled`临时设为`true`、章节设为`CHAPTER_01_RAVENMOURN_OUTSKIRTS`；Boss前流程再将`debug_start_spawn_id`设为`&"boss_checkpoint"`。完整章节直达测试使用`&"dark_forest_tutorial_spawn"`。完成后应把Debug开关恢复为`false`。

第二章主场景为`res://chapters/chapter_02_silent_court/scenes/level/silent_court.tscn`。它保留九房间灰盒和正式章节边界，并在`Phase2EnemyPrototypeShowcase`下放置五个独立验收实例；这些不是正式EncounterGroup，不代表最终数量或布阵。

第二章开发直达：将Debug开关设为`true`、`debug_start_chapter_id`设为`CHAPTER_02_SILENT_COURT`、`debug_start_spawn_id`设为`&"CH2_FLOOR_1_START"`（兼容`&"CH2_START"`）后按F5。Output必须打印`DEBUG CHAPTER START ACTIVE`并直接进入`res://chapters/chapter_02_silent_court/scenes/level/silent_court.tscn`；此模式不会播放Opening或进入墓窟。新版路线为F1向右→短宴会石阶与0.52秒黑屏转场→F2向左→短仆役侧阶与0.52秒黑屏转场→F3向右→Silent Ballroom；楼层直达还可使用`CH2_FLOOR_2_START`、`CH2_FLOOR_2_CHAPEL`、`CH2_FLOOR_3_START`和`CH2_BOSS`。

第二章五敌人独立验收房：

```text
res://chapters/chapter_02_silent_court/scenes/tests/phase_2_enemy_prototype_room.tscn
```

使用F6或`"$GODOT_BIN" --path . <scene path>`运行。房间从左到右依次为侍从、戟卫、铠甲、侍祭和倒悬猎兽；它只验证原型，不替代Bootstrap/第二章Main验收。

第二章Boss直达验收：保持`debug_start_chapter_id = CHAPTER_02_SILENT_COURT`，将`debug_start_spawn_id`设为`&"CH2_BOSS"`后按F5。玩家从CP05向右看到白瓷裂面徽记、双雕像、黑红地毯和“最后一支舞，不容缺席”的Boss门；玩家与角色武器始终绘制在门板之前。接近后门在0.90秒内开启，短距离抵达Intro Trigger。首次播放6.40秒原创破损华尔兹与五句入场对白，死亡重试缩短为1.25秒；华尔兹在变身开始时停止。瑟芙琳在121/220 HP进入4.40秒变身，切换为独立的`The Hollow Duchess, Unmasked / 无面公爵夫人`逐帧美术与80 Poise。击败后向右约850px（0.66个1280px视口）到小型`Duchess's Reliquary / 公爵夫人遗物台`；进入112px交互范围后出现“按 E 拾取 绯幕礼刺”，台座双烛以三帧像素火焰动态摆动。按E取得绯幕礼刺后展示武器与提示消失，镜墙才产生十三道裂纹并允许进入王室礼拜秘门。正式验收路径仍是`MainBootstrap`，独立快速测试房仅用于动作排查：

```text
res://chapters/chapter_02_silent_court/scenes/tests/hollow_duchess_test_room.tscn
```

第二章至第三章转场已经接入同一F5路径。击败瑟芙琳后会播放四句死亡对白，舞会厅镜墙恢复并出现十三道裂纹，随后露出王室礼拜秘门。Boss固定掉落第三阶`Crimson Masque Stilettos / 绯幕礼刺`；靠近后按E会加入唯一武器库存、自动装备、把HUD更新为14/28并写入章节奖励旗标。随后在秘门前按E，穿过无敌人的王室礼拜回廊，再在尽头按E即可抵达`res://chapters/chapter_03_chapel_of_thirteen_echoes/scenes/level/chapter_03_route.tscn`。第三章R2已把旧12784×720单画布原型从Main引用中移除：现在以持久Player/HUD、单一RoomHost和局部Fade串联礼拜堂前庭、送葬正厅、断声唱诗廊、末祷检查点与十三忏前厅；门扉使用E开启，前庭至正厅包含实体短石阶。R3完成正式图层和碰撞终验；R4完成末祷检查点、E确认十三响门、单一Fade独立圣所换房、十三烛/镜头/双语Boss标题演出，以及Boss死亡和奖励系统未来可调用的遗物室/溺圣下行道类型化接口。R5已从MainBootstrap完成40次关键转场压力回归和8张正式路线截图，并把第二章转场验收更新到正式`Chapter03Route`。仓库仍没有钟忏司祭·埃德兰战斗实体、权威Boss奖励或第四章PackedScene，因此Boss战、奖励授予和第四章加载保持明确PARTIAL，不以假内容替代；严格终验结论见第三章R5 QA报告。

正式人工测试：保持Debug开关关闭并按F5，确认Bootstrap自动进入Opening；等待动画自然结束或在提示出现后长按ESC/Enter 0.75秒，确认只进入一次暮帷墓窟而不是直接进入第一章。完成复苏、守烛人对话、双匕首回收和石门流程后，第一章暗黑森林教程才开始。

`F6`只运行Godot编辑器当前打开的场景；它不是固定路径。当前审计保存的编辑器场景为Main，因此此时F6与F5一致。也可以直接启动F5目标：

```bash
"$GODOT_BIN" --path .
```

第一只敌人的独立战斗测试房仍保留在：

```text
res://chapters/chapter_01_ravenmourn_outskirts/scenes/tests/combat_test_room.tscn
```

在Godot的FileSystem面板双击该场景后按`F6`，或使用命令：

```bash
"$GODOT_BIN" --path . res://chapters/chapter_01_ravenmourn_outskirts/scenes/tests/combat_test_room.tscn
```

测试房继续只包含一名Player和一只守卫，并提供血量、状态、实际剑伤害、可关闭的Hitbox/Hurtbox可视化以及Reset按钮；它不会替换正式Main启动场景。Main默认使用紧凑Debug HUD：左上保留Player状态、HP、耐力、速度、Dash、Hurt与无敌摘要；左下保留当前遭遇及存活/参与/攻击数量。F2展开后仍可查看原有全部Action字段和每只敌人的完整运行信息。

混合敌人独立测试房：

```text
res://chapters/chapter_01_ravenmourn_outskirts/scenes/tests/enemy_variety_test_room.tscn
```

该场景同时放置剑卫、盾卫、长矛兵和高平台弩手，提供每只敌人的类型、状态、生命、动画、攻击阶段、盾牌状态、射程/装填和弩箭数量，并有可关闭的Hitbox/Hurtbox显示与Reset。Main的`ENEMY DEBUG`使用同一通用敌人接口，不再硬编码为Castle Guard。

新增独立测试房：

```text
res://chapters/chapter_01_ravenmourn_outskirts/scenes/tests/gargoyle_test_room.tscn
res://chapters/chapter_01_ravenmourn_outskirts/scenes/tests/boss_test_room.tscn
```

它们用于快速验证石像鬼和Boss状态/动画；最终验收仍以F5开场后Main的18组实际遭遇和城堡木桥流程为准。

建议Main人工测试顺序：从出生点观察月亮、远景树海与前景枯树的层次，沿Group01..03确认泥石路、杂草、灌木、破栅栏、路标、车轮和墓石不会掩盖攻击；在Group03..05观察森林减少、废岗楼/断墙/铁门增加且远处尖塔逐渐放大。继续从边缘登上PlatformB/C/D与GargoylePerch，在Group06/07确认后段城墙、石砖、碎石、杂草和链条仍保持敌人可读性。到达`(5480,612)`前应看到`RAVENMOURN CASTLE`铁拱门且可自由通行；踏上木桥后确认深青蓝水面/倒影/桥影、多尖塔城堡主体、加宽重门、100点Boss盾量与Phase 2正常。击败Boss后等待完整1.20秒升门，拾取永久鸦牙双匕奖励，再进入`CastleEntranceTrigger`并淡出加载第二章城门内厅。

当前灰盒击杀次数：剑卫普通/Dash为3/2；盾卫从背后或破盾后击杀本体为5/3，纯正面总输入为普通8次或Dash 5次（前3/2次只削减盾量且破盾伤害不溢出）；长矛兵为5/3；弩手为4/2。满血Player分别在剑卫第20、盾卫第13、长矛兵第10、弩箭第17次命中时死亡。

## 计划操作

当前试玩输入映射：

| 动作 | 键盘 |
| --- | --- |
| 左右移动 | A / D 或方向键 |
| 跳跃 | Space；Debug开关启用时可二段跳 |
| Dash / 冲刺 | Shift（Left Shift与Right Shift）；地面或空中均可 |
| 连续Ground/Air Dash | 连续独立按下Shift；每段消耗共享耐力25点 |
| 普通双匕首前刺 | J；暮帷/鸦牙当前造成10/12点伤害 |
| Dash Attack | Shift后在Dash的0.18秒窗口内按J；同帧Shift+J也可直接触发；暮帷/鸦牙造成20/24点伤害 |
| Air Dash Attack | 空中Shift后在Dash中按J |
| 墓窟互动 | E：拾取匕首、观察环境、开启石门 |
| 跳过Opening/复苏剧情 | 长按 ESC 或 Enter |

Main开发调试快捷键：

| 调试动作 | 键盘 | 默认状态 |
| --- | --- | --- |
| 显示/隐藏全部Debug HUD | F1 | 显示 |
| Compact/Expanded切换 | F2 | Compact |
| 单独展开/折叠Enemy详情 | F3 | 折叠 |
| Level Traversal测量 | F4 | 关闭 |

正式Health/Stamina始终显示，不受F1影响。左下`TAKE 25 DMG`仅用于开发死亡/重生验证，并会随Debug HUD一起隐藏。F4的Traversal覆盖层默认关闭，只读显示脚底高度、起跳点、相对上升、位移、最近平台和Reachable评级；它属于同一Debug根节点，因此F1仍可统一隐藏。Main的调试面板使用锚点与容器布局；Enemy文本最多每0.15秒更新一次，隐藏时停止拼接。完整结构与字段契约见[Debug HUD规格](docs/design/debug_hud_spec.md)。

第二章Phase 1立体灰盒与Phase 2五敌人原型均接入同一个`MainBootstrap`/Debug Chapter Start目标。九房间最大连续层级高差120px；五种原型使用原创64×64像素帧、最近邻显示、共享Health/Hitbox/Hurtbox/Loot契约，并保持Ravenfang 12/24不变。当前几何见[第二章房间指标](chapters/chapter_02_silent_court/docs/chapter_02_room_metrics.md)，敌人交付边界见[第二章敌人原型规格](chapters/chapter_02_silent_court/docs/chapter_02_enemy_prototype_spec.md)。

第二章正式城堡资产已接入F5保存场景：旧军械库、最后宴会厅、王室画像长廊、血烛礼拜堂、无声舞会前厅和无声舞会厅使用原创像素门拱、真实人物画像、兵器架、铠甲、家具、帷幔与定时烛火，不再依赖交叉直线、空画框或细线拱门。绯幕礼刺拥有世界陈列、基座、拾取和背包四种清晰形态。Boss门现在执行淡出→全黑搬运→淡入→五句对白→双语标题→战斗；死亡重试保留缩短演出。详见[第二章正式城堡环境规格](chapters/chapter_02_silent_court/docs/chapter_02_castle_environment_spec.md)。

第三章六种敌人的415张正式运行帧已完成第一轮全量美术重制，旧Phase 2几何占位源文件已删除；历史新旧对比仅保留为QA截图，SpriteFrames与Main只引用正式`sprites/`资源。F5仍从`MainBootstrap`进入；开发验收时临时选择Chapter III Debug Start，并使用`CH3_BELLCHAIN_TEST`、`CH3_EXECUTIONER_TEST`、`CH3_CHOIR_TEST`、`CH3_SCRIBE_TEST`逐组查看，测试后恢复Debug Start关闭。完整的新旧对比、Main单体/攻击/组合截图和PASS/FAIL边界见[第三章敌人美术重制强制QA报告](docs/qa/chapter_03_enemy_art_rework/qa_report.md)。第一章人物与Boss、第二章五种普通敌人与瑟芙琳Boss也已完成各自批准阶段的正式美术重制与Main绑定。

第三章Boss环境路线已经接入同一正式Chapter III Main：`CH3_BOSS_ANTE`检查十三忏前厅、检查点、十三响门与Fade，`CH3_BOSS`检查第十三回响圣所、十三烛、香雾和入场镜头，`CH3_POST_BOSS`检查末次忏悔遗物室与奖励系统接口，`CH3_UNDERKEEP_DESCENT`检查向下墓窟、滴水、浅水和第四章终端。当前仓库尚无钟忏司祭·埃德兰Boss实体、权威Boss奖励和第四章PackedScene，因此这三项保持PARTIAL；环境不会伪造战斗、道具或章节跳转。详见[第三章Boss环境规格](chapters/chapter_03_chapel_of_thirteen_echoes/docs/chapter_03_boss_environment_spec.md)与[强制QA报告](docs/qa/chapter_03_boss_environment/report.md)。

连续按J使用同一个四帧基础突刺组成最多三段的有限攻击链，而不是无限连招树。首个J立即响应并约0.05秒进入有效帧；0.10–0.20秒合法窗口只锁存一个0.08秒输入且不会被乱按刷新。每段完整播放后以0.32秒最短起手间隔衔接，第三段结束固定进入0.34秒强制收招；收招结束前不能开始新的第一段。每段拥有独立attack_id，过早或窗口外连按不会重置第1帧。Attack期间保持现有规则：Shift不能取消Attack。正式能力标记`has_double_jump`默认关闭。当前Player场景仅为试玩验证将`debug_enable_double_jump`默认开启；这不是正式解锁流程。Shift可在同一次滞空中继续触发Air Dash，实际次数只由Ground/Air共享耐力决定；满耐力最多支付四段。每次消耗后保留0.60秒延迟；延迟结束后地面回复35点/秒，普通空中状态默认回复14点/秒。Ground/Air Dash与Dash Attack期间延迟暂停且不回复；普通Attack、跳跃和二段跳当前不消耗耐力，因此不额外阻断。Dash Attack沿用当前Dash已支付的耐力、不重复扣费。受到非致命伤害时Hurt优先中断这些动作；死亡仍优先于Hurt。

## 文档

- [技术架构](docs/technical_architecture.md)
- [章节生产规范入口](docs/production/chapter_production_checklist.md)
- [章节场景强制工作流（权威）](docs/production/chapter_scene_workflow.md)
- [章节人物强制工作流（权威）](docs/production/chapter_character_workflow.md)
- [章节强制QA标准](docs/production/chapter_qa_standard.md)
- [旧章节场景规范（兼容参考）](docs/design/chapter_scene_workflow_spec.md)
- [章节系统规格](docs/design/chapter_system_spec.md)
- [Debug章节启动规格](docs/design/debug_chapter_start_spec.md)
- [Session与存档边界](docs/design/save_and_session_spec.md)
- [第二章实施计划](docs/design/chapter_02_implementation_plan.md)
- [第二章场景与敌人联合设计](chapters/chapter_02_silent_court/docs/chapter_02_scene_enemy_design.md)
- [第二章房间指标](chapters/chapter_02_silent_court/docs/chapter_02_room_metrics.md)
- [第二章路线与流程](chapters/chapter_02_silent_court/docs/chapter_02_route_and_flow.md)
- [第二章正式城堡环境规格](chapters/chapter_02_silent_court/docs/chapter_02_castle_environment_spec.md)
- [第二章敌人名册](chapters/chapter_02_silent_court/docs/chapter_02_enemy_roster.md)
- [第二章敌人原型规格](chapters/chapter_02_silent_court/docs/chapter_02_enemy_prototype_spec.md)
- [第二章敌人与Boss美术规范](chapters/chapter_02_silent_court/docs/chapter_02_enemy_boss_art_bible.md)
- [第二章Boss美术Stage 2强制QA](docs/qa/chapter_02_enemy_boss_art_rework/stage_2_report.md)
- [第二章Encounter矩阵](chapters/chapter_02_silent_court/docs/chapter_02_encounter_matrix.md)
- [第二章Boss房规划](chapters/chapter_02_silent_court/docs/chapter_02_boss_room_plan.md)
- [空心公爵夫人Boss规格](chapters/chapter_02_silent_court/docs/chapter_02_hollow_duchess_boss_spec.md)
- [空心公爵夫人入口、无面阶段与遗物龛规格](docs/design/hollow_duchess_boss_spec.md)
- [第二章至第三章转场规格](chapters/chapter_02_silent_court/docs/chapter_02_to_03_transition_spec.md)
- [第三章敌人名册](chapters/chapter_03_chapel_of_thirteen_echoes/docs/chapter_03_enemy_roster.md)
- [第三章敌人战斗规格](chapters/chapter_03_chapel_of_thirteen_echoes/docs/chapter_03_enemy_combat_spec.md)
- [第三章敌人平衡基线](chapters/chapter_03_chapel_of_thirteen_echoes/docs/chapter_03_enemy_balance.md)
- [第三章敌人美术规范](chapters/chapter_03_chapel_of_thirteen_echoes/docs/chapter_03_enemy_art_bible.md)
- [第三章敌人正式像素质量规格](chapters/chapter_03_chapel_of_thirteen_echoes/docs/chapter_03_enemy_sprite_quality_spec.md)
- [第三章敌人美术重制强制 QA 报告](docs/qa/chapter_03_enemy_art_rework/qa_report.md)
- [第三章敌人Trial Hall计划](chapters/chapter_03_chapel_of_thirteen_echoes/docs/chapter_03_enemy_trial_plan.md)
- [第三章Boss环境规格](chapters/chapter_03_chapel_of_thirteen_echoes/docs/chapter_03_boss_environment_spec.md)
- [第三章Boss区域强制 QA 报告](docs/qa/chapter_03_boss_environment/report.md)
- [第三章埃德兰Boss B0规格](chapters/chapter_03_chapel_of_thirteen_echoes/docs/chapter_03_thirteenth_pontiff_edran_boss_spec.md)
- [第三章Boss B0审计报告](docs/qa/chapter_03_boss_b0/report.md)
- [第三章Boss B1美术QA](docs/qa/chapter_03_boss_b1/README.md)
- [第三章Boss B2 Phase 1/Main QA](docs/qa/chapter_03_boss_b2/README.md)
- [第三章结构返修 R2 实装记录](chapters/chapter_03_chapel_of_thirteen_echoes/docs/chapter_03_structural_rework_r2_implementation.md)
- [第三章结构返修 R3 图层与碰撞报告](chapters/chapter_03_chapel_of_thirteen_echoes/docs/chapter_03_structural_rework_r3_layer_collision_report.md)
- [第三章结构返修 R4 Boss流程报告](chapters/chapter_03_chapel_of_thirteen_echoes/docs/chapter_03_structural_rework_r4_boss_flow_report.md)
- [第三章结构返修 R5 Main回归与QA报告](chapters/chapter_03_chapel_of_thirteen_echoes/docs/chapter_03_structural_rework_r5_qa_report.md)
- [第三章图层叠放修复 L3 强制QA报告](docs/qa/chapter_03_render_layer_l3/report.md)
- [游戏设计基线](docs/game_design.md)
- [开发日志](docs/development_log.md)
- [世界观](docs/narrative/world_bible.md)
- [开场分镜](docs/narrative/opening_cinematic_script.md)
- [第一章叙事](chapters/chapter_01_ravenmourn_outskirts/docs/narrative/chapter_01_story_spec.md)
- [暮帷墓窟复苏场景](docs/narrative/veilbound_catacomb_scene.md)
- [守烛人角色规格](docs/narrative/candle_warden_character_spec.md)
- [墓窟复苏完整对话](docs/narrative/catacomb_revival_dialogue.md)
- [场景切换规格](chapters/chapter_01_ravenmourn_outskirts/docs/design/scene_transition_spec.md)
- [主角叙事规格](docs/narrative/character_protagonist_spec.md)
- [嵌入式教程规格](chapters/chapter_01_ravenmourn_outskirts/docs/design/tutorial_spec.md)
- [第一关34敌人编排](chapters/chapter_01_ravenmourn_outskirts/docs/design/first_level_encounter_spec.md)
- [环境叙事规格](chapters/chapter_01_ravenmourn_outskirts/docs/design/environment_storytelling_spec.md)
- [检查点与重生规格](docs/design/checkpoint_and_respawn_spec.md)
- [玩家动作接口](docs/design/player_combat_spec.md)
- [基础战斗组件规格](docs/design/combat_system_spec.md)
- [Cursed Castle Guard敌人规格](chapters/chapter_01_ravenmourn_outskirts/docs/design/enemy_castle_guard_spec.md)
- [敌人名册](chapters/chapter_01_ravenmourn_outskirts/docs/design/enemy_roster_spec.md)
- [Cursed Shield Guard规格](chapters/chapter_01_ravenmourn_outskirts/docs/design/enemy_cursed_shield_guard_spec.md)
- [Decayed Spearman规格](chapters/chapter_01_ravenmourn_outskirts/docs/design/enemy_decayed_spearman_spec.md)
- [Fallen Crossbowman规格](chapters/chapter_01_ravenmourn_outskirts/docs/design/enemy_fallen_crossbowman_spec.md)
- [Gargoyle Sentinel规格](chapters/chapter_01_ravenmourn_outskirts/docs/design/enemy_gargoyle_sentinel_spec.md)
- [Fallen Gate Knight Boss规格](chapters/chapter_01_ravenmourn_outskirts/docs/design/boss_fallen_gate_knight_spec.md)
- [第一关遭遇规格](chapters/chapter_01_ravenmourn_outskirts/docs/design/first_level_encounter_spec.md)
- [Boss房与重生规格](chapters/chapter_01_ravenmourn_outskirts/docs/design/boss_room_spec.md)
- [第一关环境美术规格](chapters/chapter_01_ravenmourn_outskirts/docs/design/environment_art_spec.md)
- [灰盒遭遇设计规格](chapters/chapter_01_ravenmourn_outskirts/docs/design/encounter_design_spec.md)
- [Debug HUD规格](docs/design/debug_hud_spec.md)
- [随机掉落系统](docs/design/loot_drop_system_spec.md)
- [治疗拾取](docs/design/health_pickup_spec.md)
- [金币系统](docs/design/currency_system_spec.md)
- [武器与装备](docs/design/weapon_system_spec.md)
- [绯幕礼刺规格](chapters/chapter_02_silent_court/docs/chapter_02_crimson_masque_stilettos_spec.md)
- [第一章武器平衡](docs/design/weapon_balance_spec.md)
- [第二章数值衔接边界](docs/design/chapter_02_combat_scaling_spec.md)
- [耐力系统规格](docs/design/stamina_system_spec.md)
- [移动范围与关卡尺度](chapters/chapter_01_ravenmourn_outskirts/docs/design/level_metrics.md)
- [第一关移动与平台规范](chapters/chapter_01_ravenmourn_outskirts/docs/design/level_traversal_spec.md)
- [碰撞层与实体几何规范](docs/design/collision_layers_spec.md)
- [已知问题](docs/known_issues.md)

## 原创与素材

当前角色与敌人像素图由项目内Godot `Image`工具原创生成，场景背景和灰盒几何使用Godot原生节点；没有下载或复制第三方素材。后续资产必须登记来源并满足项目的原创及许可要求。
## Loot, currency and weapons

Chapter I normal enemies resolve exactly one health-aware result on Player kill: coin, 10-HP small vial, 20-HP large vial or none. The Player Health snapshot at the enemy's death selects the shared table below; every row totals 100 and one roll cannot create both coin and healing.

| Player Health | Coin | Small vial | Large vial | None |
| --- | ---: | ---: | ---: | ---: |
| Full (`HP = max`) | 72% | 0% | 0% | 28% |
| Light damage (`50% < HP < 100%`) | 50% | 28% | 7% | 15% |
| Heavy damage (`20% < HP ≤ 50%`) | 35% | 35% | 15% | 15% |
| Critical (`HP ≤ 20%`) | 20% | 25% | 40% | 15% |

Pickups use original Godot-drawn pixel shapes, expire after 20 seconds (blink for the final 3), do not block actors and never heal a dead/full-health Player. Environment deaths never create healing and use half of the selected tier's coin chance. Coins and equipped weapon persist through Player death and the castle threshold; a fresh run resets them.

Starting Veilbound Daggers deal 10 normal / 20 Dash damage. Enemy and Boss Health/shield pools are scaled 10× to preserve hit counts; enemy/Boss outgoing damage and Player 100 HP/100 Stamina did not change. The Gate Knight awards 30 coins and leaves Ravenfang Daggers (12/24) at `Main/World/CastleEntranceArea/BossReward/WeaponPickup`. After the Hollow Duchess dissolves, Crimson Masque Stilettos (14/28) remain mounted in `SilentCourt/GameplayWorld/BossArea/DuchessReliquary/WeaponDisplay` until collected. Press E at either story reward; the relevant chapter exit will not transition until the reward is taken.

Ravenfang now uses a complete alternate 49-frame Player set rather than an overlay: curved raven-claw blades, folded-wing guards, black grips and cold blue-gray edges remain consistent in locomotion, aerial movement, Attack, Dash Attack, Hurt and Death. In the Boss fight, normal hits still deal damage but use a 0.32-second lightweight visual reaction without cancelling an attack, Turn, Attack Gap or AI. Dash reactions use a 0.50-second feedback cooldown and can only interrupt neutral Idle/Approach/Recovery for 0.12 seconds; Turn is no longer interruptible. Fallen Gate Knight now owns separate close Shield Bash (`14×30`), medium Slash (`26×22`) and long Thrust (`32×10`) damage volumes instead of the old shared `100×42` rectangle. Shield Bash uses a readable `0.46 / 0.10 / 0.68` second windup/active/recovery sequence, a 2.70-second repeat cooldown and a 22% Phase-1 selection weight. The latest turn target supersedes the old 0.80–1.00-second band: `0.33` seconds reaction plus `0.80` seconds authored motion measures `1.1333` seconds at 60 Hz, with facing committed at 80% of the animation. Per-skill post-active gaps remain 1.05–1.20 seconds except Shield Bash, now 1.18 seconds to preserve its full recovery and counter window.

Fallen Gate Knight's formal Phase 1 and Phase 2 frames now use the original `Gatewarden Greatsword / 守门誓剑`: a restrained body-scale guard longsword with a sharpened two-plane blade, gate-arch crossguard, wrapped grip and oath-seal pommel. The larger `128×96` presentation cell gives every idle, locomotion, turn, attack, hurt and death pose enough horizontal weapon room while retaining the existing feet/world anchor; gameplay hitboxes, attack ranges, cadence and damage are unchanged.

Compact HUD shows coin count and `WPN T# normal / dash`. Expanded Debug also shows the latest drop, selected Health tier/ratio, roll, result, source, active weights and Boss reward state. Debug methods can set Player HP to 100/75/50/20, force one roll and reset statistics. Deterministic tests are under `tests/items/`; visual evidence is under `docs/qa/`.
