# Nocturne Keep / 夜幕古堡

原创哥特风横版 2D 动作闯关游戏灰盒原型，使用 Godot Engine 4.7.1 标准版与 GDScript 开发。

当前版本：`第一章开场、暮帷墓窟复苏、嵌入式教程与34敌人路线 · Chapter I Graybox 4.1`

## 当前范围

F5首先播放70.2秒、8镜头、可长按ESC/Enter跳过的双语叙事开场，然后进入约69秒的`Veilbound Catacomb / 暮帷墓窟`剧情复苏。玩家在断魂祭坛复魂、与守烛人完成30句双语台词、拾回双匕首并自行穿过符文石门后，才进入正式Main的`DarkForestTutorialSpawn`。第一关现有11步非阻塞教程、18个一次性EncounterGroup和34只普通敌人（Guard 14、Shield 5、Spearman 6、Crossbowman 5、Gargoyle 4），其中27只在主路线、7只在可选高台路线。后续普通死亡仍只执行既有快速幽灵/检查点重生，不会重播墓窟。当前没有第二关正式玩法、经验系统、商店、磁盘存档或新能力树。

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

按 `F5` 会先运行项目配置的开场场景：

```text
res://scenes/cinematics/opening_cinematic.tscn
```

章节化启动基础已完成阶段2A：项目现在拥有统一`ChapterRegistry`、类型化`ChapterStartProfile`和`DebugRunConfig`，默认开发目标登记为第二章《沉寂王庭》。本阶段尚未接入启动路由，且第二章场景仍未建立，因此F5行为保持不变；不要手工改写`run/main_scene`。路由、合法第二章启动档案和F5直达验收分别留待阶段2B、2C和2D。

第二章开发阶段1联合设计已完成：九个房间规划为总长32,128 px的线性主路加三条短支路，五种新敌人与15组Encounter合计34只普通敌人，无声舞会厅按4608×900 px规划。当前只有设计文档；`silent_court.tscn`、保存的Start Profile和Debug路由仍未创建，因此此时F5仍从Opening开始。下一阶段会先建立有效第二章入口，再制作九房间完整灰盒。

自然播放或跳过后加载`res://scenes/levels/veilbound_catacomb.tscn`。墓窟剧情可长按ESC/Enter跳过；获得控制后使用A/D移动、E互动，拾取`World/Interactions/DaggerPickup`后可开启石门并自行进入出口。出口淡出并加载`res://scenes/main/main.tscn`，Player出生于`World/DarkForestTutorialSpawn (320,612)`，随后既有教程、HUD、死亡/重生、18组遭遇和木桥Boss流程继续运行。

`F6`只运行Godot编辑器当前打开的场景；它不是固定路径。当前审计保存的编辑器场景为Main，因此此时F6与F5一致。也可以直接启动F5目标：

```bash
"$GODOT_BIN" --path .
```

第一只敌人的独立战斗测试房仍保留在：

```text
res://scenes/tools/combat_test_room.tscn
```

在Godot的FileSystem面板双击该场景后按`F6`，或使用命令：

```bash
"$GODOT_BIN" --path . res://scenes/tools/combat_test_room.tscn
```

测试房继续只包含一名Player和一只守卫，并提供血量、状态、实际剑伤害、可关闭的Hitbox/Hurtbox可视化以及Reset按钮；它不会替换正式Main启动场景。Main默认使用紧凑Debug HUD：左上保留Player状态、HP、耐力、速度、Dash、Hurt与无敌摘要；左下保留当前遭遇及存活/参与/攻击数量。F2展开后仍可查看原有全部Action字段和每只敌人的完整运行信息。

混合敌人独立测试房：

```text
res://scenes/tools/enemy_variety_test_room.tscn
```

该场景同时放置剑卫、盾卫、长矛兵和高平台弩手，提供每只敌人的类型、状态、生命、动画、攻击阶段、盾牌状态、射程/装填和弩箭数量，并有可关闭的Hitbox/Hurtbox显示与Reset。Main的`ENEMY DEBUG`使用同一通用敌人接口，不再硬编码为Castle Guard。

新增独立测试房：

```text
res://scenes/tools/gargoyle_test_room.tscn
res://scenes/tools/boss_test_room.tscn
```

它们用于快速验证石像鬼和Boss状态/动画；最终验收仍以F5开场后Main的18组实际遭遇和城堡木桥流程为准。

建议Main人工测试顺序：从出生点观察月亮、远景树海与前景枯树的层次，沿Group01..03确认泥石路、杂草、灌木、破栅栏、路标、车轮和墓石不会掩盖攻击；在Group03..05观察森林减少、废岗楼/断墙/铁门增加且远处尖塔逐渐放大。继续从边缘登上PlatformB/C/D与GargoylePerch，在Group06/07确认后段城墙、石砖、碎石、杂草和链条仍保持敌人可读性。到达`(5480,612)`前应看到`RAVENMOURN CASTLE`铁拱门且可自由通行；踏上木桥后确认深青蓝水面/倒影/桥影、多尖塔城堡主体、加宽重门、100点Boss盾量与Phase 2正常。击败Boss后等待完整1.20秒升门，拾取永久鸦牙双匕奖励，再进入`CastleEntranceTrigger`并无文字淡出到阈厅占位场景。

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

连续按J使用同一个四帧基础突刺组成最多三段的有限攻击链，而不是无限连招树。首个J立即响应并约0.05秒进入有效帧；0.10–0.20秒合法窗口只锁存一个0.08秒输入且不会被乱按刷新。每段完整播放后以0.32秒最短起手间隔衔接，第三段结束固定进入0.34秒强制收招；收招结束前不能开始新的第一段。每段拥有独立attack_id，过早或窗口外连按不会重置第1帧。Attack期间保持现有规则：Shift不能取消Attack。正式能力标记`has_double_jump`默认关闭。当前Player场景仅为试玩验证将`debug_enable_double_jump`默认开启；这不是正式解锁流程。Shift可在同一次滞空中继续触发Air Dash，实际次数只由Ground/Air共享耐力决定；满耐力最多支付四段。每次消耗后保留0.60秒延迟；延迟结束后地面回复35点/秒，普通空中状态默认回复14点/秒。Ground/Air Dash与Dash Attack期间延迟暂停且不回复；普通Attack、跳跃和二段跳当前不消耗耐力，因此不额外阻断。Dash Attack沿用当前Dash已支付的耐力、不重复扣费。受到非致命伤害时Hurt优先中断这些动作；死亡仍优先于Hurt。

## 文档

- [技术架构](docs/technical_architecture.md)
- [章节系统规格](docs/design/chapter_system_spec.md)
- [Debug章节启动规格](docs/design/debug_chapter_start_spec.md)
- [Session与存档边界](docs/design/save_and_session_spec.md)
- [第二章实施计划](docs/design/chapter_02_implementation_plan.md)
- [第二章场景与敌人联合设计](chapters/chapter_02_silent_court/docs/chapter_02_scene_enemy_design.md)
- [第二章房间指标](chapters/chapter_02_silent_court/docs/chapter_02_room_metrics.md)
- [第二章路线与流程](chapters/chapter_02_silent_court/docs/chapter_02_route_and_flow.md)
- [第二章敌人名册](chapters/chapter_02_silent_court/docs/chapter_02_enemy_roster.md)
- [第二章Encounter矩阵](chapters/chapter_02_silent_court/docs/chapter_02_encounter_matrix.md)
- [第二章Boss房规划](chapters/chapter_02_silent_court/docs/chapter_02_boss_room_plan.md)
- [游戏设计基线](docs/game_design.md)
- [开发日志](docs/development_log.md)
- [世界观](docs/narrative/world_bible.md)
- [开场分镜](docs/narrative/opening_cinematic_script.md)
- [第一章叙事](docs/narrative/chapter_01_story_spec.md)
- [暮帷墓窟复苏场景](docs/narrative/veilbound_catacomb_scene.md)
- [守烛人角色规格](docs/narrative/candle_warden_character_spec.md)
- [墓窟复苏完整对话](docs/narrative/catacomb_revival_dialogue.md)
- [场景切换规格](docs/design/scene_transition_spec.md)
- [主角叙事规格](docs/narrative/character_protagonist_spec.md)
- [嵌入式教程规格](docs/design/tutorial_spec.md)
- [第一关34敌人编排](docs/design/first_level_encounter_spec.md)
- [环境叙事规格](docs/design/environment_storytelling_spec.md)
- [检查点与重生规格](docs/design/checkpoint_and_respawn_spec.md)
- [玩家动作接口](docs/design/player_combat_spec.md)
- [基础战斗组件规格](docs/design/combat_system_spec.md)
- [Cursed Castle Guard敌人规格](docs/design/enemy_castle_guard_spec.md)
- [敌人名册](docs/design/enemy_roster_spec.md)
- [Cursed Shield Guard规格](docs/design/enemy_cursed_shield_guard_spec.md)
- [Decayed Spearman规格](docs/design/enemy_decayed_spearman_spec.md)
- [Fallen Crossbowman规格](docs/design/enemy_fallen_crossbowman_spec.md)
- [Gargoyle Sentinel规格](docs/design/enemy_gargoyle_sentinel_spec.md)
- [Fallen Gate Knight Boss规格](docs/design/boss_fallen_gate_knight_spec.md)
- [第一关遭遇规格](docs/design/first_level_encounter_spec.md)
- [Boss房与重生规格](docs/design/boss_room_spec.md)
- [第一关环境美术规格](docs/design/environment_art_spec.md)
- [灰盒遭遇设计规格](docs/design/encounter_design_spec.md)
- [Debug HUD规格](docs/design/debug_hud_spec.md)
- [随机掉落系统](docs/design/loot_drop_system_spec.md)
- [治疗拾取](docs/design/health_pickup_spec.md)
- [金币系统](docs/design/currency_system_spec.md)
- [武器与装备](docs/design/weapon_system_spec.md)
- [第一章武器平衡](docs/design/weapon_balance_spec.md)
- [第二章数值衔接边界](docs/design/chapter_02_combat_scaling_spec.md)
- [耐力系统规格](docs/design/stamina_system_spec.md)
- [移动范围与关卡尺度](docs/design/level_metrics.md)
- [第一关移动与平台规范](docs/design/level_traversal_spec.md)
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

Starting Veilbound Daggers deal 10 normal / 20 Dash damage. Enemy and Boss Health/shield pools are scaled 10× to preserve hit counts; enemy/Boss outgoing damage and Player 100 HP/100 Stamina did not change. The Gate Knight awards 30 coins and leaves Ravenfang Daggers (12/24) at `Main/World/CastleEntranceArea/BossReward/WeaponPickup`. Press E to collect; the opened gate will not transition until the story weapon is taken.

Ravenfang now uses a complete alternate 49-frame Player set rather than an overlay: curved raven-claw blades, folded-wing guards, black grips and cold blue-gray edges remain consistent in locomotion, aerial movement, Attack, Dash Attack, Hurt and Death. In the Boss fight, normal hits still deal damage but use a 0.32-second lightweight visual reaction without cancelling an attack, Turn, Attack Gap or AI. Dash reactions use a 0.50-second feedback cooldown and can only interrupt neutral Idle/Approach/Recovery for 0.12 seconds; Turn is no longer interruptible. Fallen Gate Knight now owns separate close Shield Bash (`14×30`), medium Slash (`26×22`) and long Thrust (`32×10`) damage volumes instead of the old shared `100×42` rectangle. Shield Bash uses a readable `0.46 / 0.10 / 0.68` second windup/active/recovery sequence, a 2.70-second repeat cooldown and a 22% Phase-1 selection weight. The latest turn target supersedes the old 0.80–1.00-second band: `0.33` seconds reaction plus `0.80` seconds authored motion measures `1.1333` seconds at 60 Hz, with facing committed at 80% of the animation. Per-skill post-active gaps remain 1.05–1.20 seconds except Shield Bash, now 1.18 seconds to preserve its full recovery and counter window.

Compact HUD shows coin count and `WPN T# normal / dash`. Expanded Debug also shows the latest drop, selected Health tier/ratio, roll, result, source, active weights and Boss reward state. Debug methods can set Player HP to 100/75/50/20, force one roll and reset statistics. Deterministic tests are under `tests/items/`; visual evidence is under `docs/qa/`.
