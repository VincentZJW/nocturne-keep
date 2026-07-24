# Nocturne Keep / 夜幕古堡

原创哥特风横版 2D 动作闯关游戏灰盒原型，使用 Godot Engine 4.7.1 标准版与 GDScript 开发。

当前版本：`Ravenmourn Castle环境与开门演出强化 · Castle Bridge Graybox 3.2`

## 当前范围

当前F5 Main已形成第一关完整灰盒路线：7个分段ActivationArea、18只普通敌人（Guard 8、Shield 2、Spearman 2、Crossbowman 3、Gargoyle 3），随后穿过标记`RAVENMOURN CASTLE`的非阻挡哥特铁拱门，从Boss检查点踏上深青蓝护城河上的加固旧木桥迎战两阶段`Fallen Gate Knight / 堕落门卫骑士`。后段现有分层尖塔、断墙、石砌平台、链条与稀疏灯火；桥后保存一座原创16-bit-inspired宏伟城堡背景和厚重木铁升降门。Boss死亡后不再弹出章节/开门文字：大门用1.20秒缓慢升起，碰撞清空后玩家自行进入门洞，经0.55秒无文字淡出抵达极简`RavenmournThreshold`占位过渡场景。当前没有第二关正式玩法、掉落、经验、装备或存档。

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

按 `F5` 会始终运行项目配置的完整主场景：

```text
res://scenes/main/main.tscn
```

该场景包含Player、Health/Stamina HUD、死亡/重生流程、7个手工普通遭遇组和保存于`World/CastleEntranceArea`的城堡木桥Boss区。Player出生于`(320,612)`；普通组规模为2/3/2/2/2/3/4。三个弩手台顶部为y=500/504/508，石像鬼落点顶部为y=492；Solid化后需从平台边缘起跳并落在顶部，不能再从正下方穿过。Boss检查点位于`(5480,612)`；河岸x=5520与木桥x=5560之间是一个40像素、普通单跳即可跨越的护城河入口，木桥延伸至x=6360且顶面y=640，Boss出生于`(6120,596)`。走下河岸跌入`MoatHazard`会复用玩家倒地、幽灵、0.50秒停顿与检查点重生；未击败Boss会完整重置，已击败Boss不会复活。

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

它们用于快速验证石像鬼和Boss状态/动画；最终验收仍以F5 Main的七组实际遭遇和城堡木桥流程为准。

建议Main人工测试顺序：先在PlatformA下方验证单跳/二段跳撞底和Air Dash/Dash Attack撞侧，再从边缘登上PlatformB/C/D与GargoylePerch；在Group06/07留意后段分层城堡远景、石砖、碎石、杂草和链条是否保持敌人可读性。到达`(5480,612)`前应看到`RAVENMOURN CASTLE`铁拱门且可自由通行；踏上木桥后确认深青蓝水面/倒影/桥影、完整城堡主体、厚重大门、10点Boss盾量与Phase 2正常。击败Boss后等待完整1.20秒升门，确认没有章节/开门大字、Player控制保留，然后自行进入`CastleEntranceTrigger`并无文字淡出到阈厅占位场景。

当前灰盒击杀次数：剑卫普通/Dash为3/2；盾卫从背后或破盾后击杀本体为5/3，纯正面总输入为普通8次或Dash 5次（前3/2次只削减盾量且破盾伤害不溢出）；长矛兵为5/3；弩手为4/2。满血Player分别在剑卫第20、盾卫第13、长矛兵第10、弩箭第17次命中时死亡。

## 计划操作

当前试玩输入映射：

| 动作 | 键盘 |
| --- | --- |
| 左右移动 | A / D 或方向键 |
| 跳跃 | Space；Debug开关启用时可二段跳 |
| Dash / 冲刺 | Shift（Left Shift与Right Shift）；地面或空中均可 |
| 连续Ground/Air Dash | 连续独立按下Shift；每段消耗共享耐力25点 |
| 普通双匕首前刺 | J；对古堡守卫造成1点伤害 |
| Dash Attack | Shift后在Dash的0.18秒窗口内按J；同帧Shift+J也可直接触发；造成2点伤害 |
| Air Dash Attack | 空中Shift后在Dash中按J |

Main开发调试快捷键：

| 调试动作 | 键盘 | 默认状态 |
| --- | --- | --- |
| 显示/隐藏全部Debug HUD | F1 | 显示 |
| Compact/Expanded切换 | F2 | Compact |
| 单独展开/折叠Enemy详情 | F3 | 折叠 |
| Level Traversal测量 | F4 | 关闭 |

正式Health/Stamina始终显示，不受F1影响。左下`TAKE 25 DMG`仅用于开发死亡/重生验证，并会随Debug HUD一起隐藏。F4的Traversal覆盖层默认关闭，只读显示脚底高度、起跳点、相对上升、位移、最近平台和Reachable评级；它属于同一Debug根节点，因此F1仍可统一隐藏。Main的调试面板使用锚点与容器布局；Enemy文本最多每0.15秒更新一次，隐藏时停止拼接。完整结构与字段契约见[Debug HUD规格](docs/design/debug_hud_spec.md)。

连续按J仍重复同一个四帧基础突刺，而不是多段连招树。首个J立即响应并约0.05秒进入有效帧；只有0.15–0.20秒的末段窗口接受一次0.06秒缓存，完整`attack_04`之后必须经过0.06秒`AttackRecovery`才能接续。过早或窗口外连按不会重置第1帧，也不能跳过最小收招节拍。Attack期间保持现有规则：Shift不能取消Attack。正式能力标记`has_double_jump`默认关闭。当前Player场景仅为试玩验证将`debug_enable_double_jump`默认开启；这不是正式解锁流程。Shift可在同一次滞空中继续触发Air Dash，实际次数只由Ground/Air共享耐力决定；满耐力最多支付四段。每次消耗后保留0.60秒延迟；延迟结束后地面回复35点/秒，普通空中状态默认回复14点/秒。Ground/Air Dash与Dash Attack期间延迟暂停且不回复；普通Attack、跳跃和二段跳当前不消耗耐力，因此不额外阻断。Dash Attack沿用当前Dash已支付的耐力、不重复扣费。受到非致命伤害时Hurt优先中断这些动作；死亡仍优先于Hurt。当前没有连招树或复杂伤害公式。

## 文档

- [技术架构](docs/technical_architecture.md)
- [游戏设计基线](docs/game_design.md)
- [开发日志](docs/development_log.md)
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
- [耐力系统规格](docs/design/stamina_system_spec.md)
- [移动范围与关卡尺度](docs/design/level_metrics.md)
- [第一关移动与平台规范](docs/design/level_traversal_spec.md)
- [碰撞层与实体几何规范](docs/design/collision_layers_spec.md)
- [已知问题](docs/known_issues.md)

## 原创与素材

当前角色与敌人像素图由项目内Godot `Image`工具原创生成，场景背景和灰盒几何使用Godot原生节点；没有下载或复制第三方素材。后续资产必须登记来源并满足项目的原创及许可要求。
