# Nocturne Keep / 夜幕古堡

原创哥特风横版 2D 动作闯关游戏灰盒原型，使用 Godot Engine 4.7.1 标准版与 GDScript 开发。

当前版本：`M1.5 连续Dash与耐力原型`

## 当前范围

M1.5在M1移动基础上增加开发验证用二段跳、一次水平空中Dash、由独立Shift输入触发的连续地面Dash、功能性耐力条、可快速重复的双匕首前刺，以及Dash Attack。每段Dash消耗25/100耐力；没有新的Shift按下边沿就不会自动续段。所有攻击仍只有动画、输入和移动接口，没有伤害或Hitbox；敌人、完整战斗、Hurt和Death Gameplay仍未开始。

## 环境要求

- macOS（主要开发环境）
- Godot Engine 4.7.1 Standard
- Git

本机已验证的 Godot 可执行文件：

```text
/Users/USER/Downloads/Godot.app/Contents/MacOS/Godot
```

该绝对路径只用于本地运行说明，不会写入游戏逻辑、资源路径或存档。

## 运行项目

在仓库根目录执行：

```bash
"/Users/USER/Downloads/Godot.app/Contents/MacOS/Godot" --editor --path .
```

然后按 `F6` 运行当前场景，或按 `F5` 运行项目。也可以直接启动：

```bash
"/Users/USER/Downloads/Godot.app/Contents/MacOS/Godot" --path .
```

## 计划操作

当前试玩输入映射：

| 动作 | 键盘 |
| --- | --- |
| 左右移动 | A / D 或方向键 |
| 跳跃 | Space；Debug开关启用时可二段跳 |
| Dash / 冲刺 | Shift（Left Shift与Right Shift） |
| 连续Ground Dash | 连续独立按下Shift；每段消耗25耐力 |
| 普通双匕首前刺 | J |
| Dash Attack | Shift后在Dash的0.18秒窗口内按J；同帧Shift+J也可直接触发 |
| Air Dash Attack | 空中Shift后在Dash中按J |

连续按J时，当前Attack进入第3帧后会消费至多一条0.10秒缓存并重新播放同一基础突刺；这不是多段连招树。Attack期间保持现有规则：Shift不能取消Attack。正式能力标记`has_double_jump`默认关闭。当前Player场景仅为试玩验证将`debug_enable_double_jump`默认开启；这不是正式解锁流程。空中Shift每次离地最多使用一次，落地只恢复Air Dash资格，不补满耐力。耐力耗尽后需等待最后一次消耗满0.60秒，再以35点/秒恢复。Dash Attack沿用当前Dash已支付的耐力，不重复扣费，也没有无敌帧或伤害判定。

## 文档

- [技术架构](docs/technical_architecture.md)
- [游戏设计基线](docs/game_design.md)
- [开发日志](docs/development_log.md)
- [玩家动作接口](docs/design/player_combat_spec.md)
- [耐力系统规格](docs/design/stamina_system_spec.md)
- [已知问题](docs/known_issues.md)

## 原创与素材

当前画面仅由 Godot 原生节点和程序化几何图形组成，没有下载或复制第三方素材。后续资产必须登记来源并满足项目的原创及许可要求。
