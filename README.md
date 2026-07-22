# Nocturne Keep / 夜幕古堡

原创哥特风横版 2D 动作闯关游戏灰盒原型，使用 Godot Engine 4.7.1 标准版与 GDScript 开发。

当前版本：`M1.5 Dash Attack输入链原型`

## 当前范围

M1.5在M1移动基础上增加开发验证用二段跳、地面/水平空中Dash、普通双匕首前刺，以及可由Dash衔接的Dash Attack。所有攻击仍只有动画和移动接口，没有伤害或Hitbox；敌人、完整战斗、Hurt和Death Gameplay仍未开始。

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
| 普通双匕首前刺 | J |
| Dash Attack | Shift后在Dash中按J；J后0.12秒内按Shift也可组合 |
| Air Dash Attack | 空中Shift后在Dash中按J |

正式能力标记`has_double_jump`默认关闭。当前Player场景仅为试玩验证将`debug_enable_double_jump`默认开启；这不是正式解锁流程。空中每次离地最多Dash一次，落地后恢复；地面与空中Dash共享0.45秒冷却。Dash Attack没有额外Dash次数、无敌帧或伤害判定。

## 文档

- [技术架构](docs/technical_architecture.md)
- [游戏设计基线](docs/game_design.md)
- [开发日志](docs/development_log.md)
- [已知问题](docs/known_issues.md)

## 原创与素材

当前画面仅由 Godot 原生节点和程序化几何图形组成，没有下载或复制第三方素材。后续资产必须登记来源并满足项目的原创及许可要求。
