# Nocturne Keep / 夜幕古堡

原创哥特风横版 2D 动作闯关游戏灰盒原型，使用 Godot Engine 4.7.1 标准版与 GDScript 开发。

当前版本：`第一批敌人多样性 · Shield Guard / Spearman / Crossbowman`

## 当前范围

当前在既有玩家移动、动作、耐力、生命、受击、死亡/幽灵/重生和诅咒剑卫基础上，加入三种完整普通敌人：正面格挡且可被Dash Attack破防的诅咒盾卫、拥有贴身死角的长距离腐朽长矛兵、具备Aim→Shoot→Reload节奏并发射碰墙销毁弩箭的堕落弩手。F5 Main在`World/Encounters`下布置4组、共9只混合敌人，组规模为2/2/2/3；所有组仍由ActivationArea分阶段启用。玩家攻击为1/2点；剑卫、盾卫、长矛兵、弩箭分别造成5/8/10/4点。敌人身体接触和同阵营接触不造成伤害。当前没有飞行敌人、精英、Boss、掉落、经验或装备系统。

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

该场景包含Player、Health/Stamina HUD、死亡/重生流程，以及4个手工混合遭遇组。Player出生于`(320, 612)`；Group01为剑卫+盾卫，Group02为长矛兵+剑卫，Group03为高平台弩手+地面剑卫，Group04为盾卫+长矛兵+弩手。未进入ActivationArea的组保持Idle并暂停AI，同时活跃上限不超过3只。

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

测试房继续只包含一名Player和一只守卫，并提供血量、状态、实际剑伤害、可关闭的Hitbox/Hurtbox可视化以及Reset按钮；它不会替换正式Main启动场景。Main的`ACTION DEBUG HUD`会显示玩家Hurt、无敌剩余、最近伤害/来源和击退速度；`ENEMY DEBUG`会显示各遭遇组的激活、参与战斗/存活/攻击数量，以及每只剑卫的实际伤害。

混合敌人独立测试房：

```text
res://scenes/tools/enemy_variety_test_room.tscn
```

该场景同时放置剑卫、盾卫、长矛兵和高平台弩手，提供每只敌人的类型、状态、生命、动画、攻击阶段、盾牌状态、射程/装填和弩箭数量，并有可关闭的Hitbox/Hurtbox显示与Reset。Main的`ENEMY DEBUG`使用同一通用敌人接口，不再硬编码为Castle Guard。

建议Main人工测试顺序：先确认普通Attack被盾卫正面格挡、Dash Attack触发GuardBreak、绕后可直接伤害；随后测试长矛兵的远距狭长前刺和贴身死角；在高平台组观察弩手0.60秒Aim、发射和1.50秒Reload，并用跳跃/连续Air Dash接近。继续向右触发最终三敌组，确认玩家受击无敌、HUD、死亡幽灵与重生均保持正常。重新运行F5会恢复全部组和敌人。

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

连续按J时，当前Attack进入第3帧后会消费至多一条0.10秒缓存并重新播放同一基础突刺；这不是多段连招树。Attack期间保持现有规则：Shift不能取消Attack。正式能力标记`has_double_jump`默认关闭。当前Player场景仅为试玩验证将`debug_enable_double_jump`默认开启；这不是正式解锁流程。Shift可在同一次滞空中继续触发Air Dash，实际次数只由Ground/Air共享耐力决定；满耐力最多支付四段。每次消耗后保留0.60秒延迟；延迟结束后地面回复35点/秒，普通空中状态默认回复14点/秒。Ground/Air Dash与Dash Attack期间延迟暂停且不回复；普通Attack、跳跃和二段跳当前不消耗耐力，因此不额外阻断。Dash Attack沿用当前Dash已支付的耐力、不重复扣费。受到非致命伤害时Hurt优先中断这些动作；死亡仍优先于Hurt。当前没有连招树或复杂伤害公式。

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
- [灰盒遭遇设计规格](docs/design/encounter_design_spec.md)
- [耐力系统规格](docs/design/stamina_system_spec.md)
- [移动范围与关卡尺度](docs/design/level_metrics.md)
- [已知问题](docs/known_issues.md)

## 原创与素材

当前角色与敌人像素图由项目内Godot `Image`工具原创生成，场景背景和灰盒几何使用Godot原生节点；没有下载或复制第三方素材。后续资产必须登记来源并满足项目的原创及许可要求。
