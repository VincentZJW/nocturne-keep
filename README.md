# Nocturne Keep / 夜幕古堡

原创哥特风横版 2D 动作闯关游戏灰盒原型，使用 Godot Engine 4.7.1 标准版与 GDScript 开发。

当前版本：`基础战斗原型 · Castle Guard / 古堡守卫`

## 当前范围

当前在M1.5移动/动作、耐力、玩家生命/死亡/重生基础上，增加第一只可战斗近战敌人Castle Guard和最小通用战斗层。玩家普通双匕首前刺造成1点伤害，Dash Attack造成2点；古堡守卫的剑在0.35秒前摇后以0.10秒有效窗口造成1点伤害，身体接触不伤害。Hitbox、Hurtbox与Health职责分离，同一攻击不会对同一目标重复结算。敌人具备Idle、Patrol、Chase、Attack、Hurt、Death，且不会主动走下平台。当前仍没有远程/飞行/精英敌人、Boss、掉落、复杂关卡、玩家无敌帧或正式受击状态。

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

然后按 `F6` 运行当前场景，或按 `F5` 运行项目。也可以直接启动：

```bash
"$GODOT_BIN" --path .
```

第一只敌人的独立战斗测试房：

```bash
"$GODOT_BIN" --path . res://scenes/tools/combat_test_room.tscn
```

测试房包含玩家/守卫血量与状态调试信息、可关闭的Hitbox/Hurtbox可视化以及Reset按钮；它不会替换正式Main启动场景。

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

连续按J时，当前Attack进入第3帧后会消费至多一条0.10秒缓存并重新播放同一基础突刺；这不是多段连招树。Attack期间保持现有规则：Shift不能取消Attack。正式能力标记`has_double_jump`默认关闭。当前Player场景仅为试玩验证将`debug_enable_double_jump`默认开启；这不是正式解锁流程。Shift可在同一次滞空中继续触发Air Dash，实际次数只由Ground/Air共享耐力决定；满耐力最多支付四段。每次消耗后保留0.60秒延迟；延迟结束后地面回复35点/秒，普通空中状态默认回复14点/秒。Ground/Air Dash与Dash Attack期间延迟暂停且不回复；普通Attack、跳跃和二段跳当前不消耗耐力，因此不额外阻断。Dash Attack沿用当前Dash已支付的耐力、不重复扣费，期间可缓存一个后续Shift，结束时按实际接触状态转入付费Ground/Air Dash。当前没有玩家无敌帧、连招树或复杂伤害公式。

## 文档

- [技术架构](docs/technical_architecture.md)
- [游戏设计基线](docs/game_design.md)
- [开发日志](docs/development_log.md)
- [玩家动作接口](docs/design/player_combat_spec.md)
- [基础战斗组件规格](docs/design/combat_system_spec.md)
- [Castle Guard敌人规格](docs/design/enemy_castle_guard_spec.md)
- [耐力系统规格](docs/design/stamina_system_spec.md)
- [移动范围与关卡尺度](docs/design/level_metrics.md)
- [已知问题](docs/known_issues.md)

## 原创与素材

当前画面仅由 Godot 原生节点和程序化几何图形组成，没有下载或复制第三方素材。后续资产必须登记来源并满足项目的原创及许可要求。
