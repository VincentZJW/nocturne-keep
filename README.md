# Nocturne Keep / 夜幕古堡

原创哥特风横版 2D 动作闯关游戏灰盒原型，使用 Godot Engine 4.7.1 标准版与 GDScript 开发。

当前版本：`M0 环境和仓库初始化`

## 当前范围

M0 只包含可启动的 Godot 项目、Main 场景、目录结构和基础文档。玩家移动、战斗、敌人、关卡和流程功能尚未开始，必须在对应里程碑获批后逐步实现。

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

输入映射将在 M1 添加，目标键位为：

| 动作 | 键盘 |
| --- | --- |
| 左右移动 | A / D 或方向键 |
| 跳跃 | Space |
| 攻击 | J |
| 闪避 | K |
| 暂停 | Escape |
| 交互 | E |

## 文档

- [技术架构](docs/technical_architecture.md)
- [游戏设计基线](docs/game_design.md)
- [开发日志](docs/development_log.md)
- [已知问题](docs/known_issues.md)

## 原创与素材

当前画面仅由 Godot 原生节点和程序化几何图形组成，没有下载或复制第三方素材。后续资产必须登记来源并满足项目的原创及许可要求。
