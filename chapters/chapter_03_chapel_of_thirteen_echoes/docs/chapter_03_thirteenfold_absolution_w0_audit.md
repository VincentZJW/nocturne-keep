# Chapter III Boss Reward Weapon — W0 Audit and Delivery Plan

Date: 2026-07-31
Stage: W0 — architecture audit and implementation plan
Status: complete; W1 has not started

## 工作流确认

- 已读取 `AGENTS.md`、人物与武器资产工作流、章节场景工作流、章节生产清单、章节 QA 标准和渲染图层契约。
- 本任务属于第三章 Boss 固定奖励武器开发，最终交付对象为 `Thirteenfold Absolution / 十三重赦刃`，由 `Absolution / 赦罪` 与 `Penance / 忏悔` 组成一个不可拆分的双匕首 Inventory Item。
- 未来阶段将分别覆盖原画、正式 Sprite、Player 动画适配、WeaponData、Inventory/Equipment/Save、Boss 死亡演出、遗物龛交互、Main/F5 集成和强制 QA。
- 当前停止点为 W0：只记录真实架构、正式设计、文件所有权与测试计划。本阶段未创建 WeaponData、图片、动画、拾取场景、存档服务或运行时代码，未修改 Main。

## 范围约束

W1–W5 不得改变 Player 基础攻击速度、连段窗口、攻击范围、Hitbox、Dash 距离、耐力、移动、跳跃、Poise 或暴击体系；不得修改第二章武器数值、Edran 数值、第四章地图或其他武器。第三章武器是与第二章武器同数值的叙事和视觉分支，不是数值升级。

## 1. 第二章绯幕礼刺实际 WeaponData 路径

`res://chapters/chapter_02_silent_court/resources/weapons/crimson_masque_stilettos.tres`

资源实际名称为 `Crimson Masque Stilettos / 绯幕礼刺`，`weapon_id = crimson_masque_stilettos`，`weapon_type = dual_daggers`，`tier = 3`。

该资源是第三章武器数值校准的唯一权威来源；十三重赦刃必须创建独立 `.tres`，不得复用同一个 Resource 实例。

## 2. 第二章武器实际 normal_damage

当前项目字段名为 `normal_attack_damage`，实际值为 **14**。

## 3. 第二章武器实际 dash_damage

当前项目字段名为 `dash_attack_damage`，实际值为 **28**。

## 4. 当前 WeaponData 字段

资源类路径：`res://scripts/items/weapon_data.gd`，类名 `WeaponData`。

| 分类 | 实际字段 |
|---|---|
| Identity | `weapon_id`, `display_name_zh`, `display_name_en`, `description_zh`, `description_en`, `weapon_type`, `tier` |
| Combat | `normal_attack_damage`, `dash_attack_damage` |
| Presentation | `icon`, `hud_icon`, `player_visual_id`, `player_idle_visual`, `player_attack_visual`, `world_pickup_visual`, `acquisition_sound` |
| Economy/rules | `shop_value`, `can_sell`, `is_story_reward`, `is_unique`, `is_permanent`, `auto_equip_on_pickup`, `allow_duplicates` |

当前类**没有** `short_description_*`、`long_description_*`、`main_hand_sprite`、`off_hand_sprite`、`pickup_sprite`、`reliquary_sprite`、`lost_on_death` 或 `persist_between_chapters` 字段。W3 必须适配实际类：

- 短描述先落在现有 `description_zh/en`；长描述由获得面板或章节文档承载，除非届时确认有真实消费方才最小扩展 WeaponData。
- Player 武器外观当前由整套 `SpriteFrames` 通过 `player_visual_id` 切换，不使用独立左右手 Sprite 字段。
- `is_permanent = true`、唯一 Inventory ledger、正式存档所有权共同表达不随死亡丢失和跨章节继承；不能写不存在而无人读取的字段。

## 5. Player 武器挂点与视觉切换

Player 场景：`res://scenes/player/player.tscn`。

| 职责 | 真实节点/脚本 |
|---|---|
| 完整角色与武器画面 | `Player/VisualRoot/AnimatedSprite2D` |
| 装备视觉协调器 | `Player/VisualRoot/WeaponVisual` → `res://scripts/player/player_weapon_visual.gd` |
| 动画协调器 | `Player/AnimationController` → `res://scripts/player/player_animation_controller.gd` |
| 普通攻击判定 | `Player/CombatRoot/AttackHitbox` |
| Dash Attack 判定 | `Player/CombatRoot/DashAttackHitbox` |

结论：项目没有独立的手部武器挂点。`WeaponVisual` 根据 EquipmentManager 发出的 `WeaponData.player_visual_id` 原子替换 `AnimatedSprite2D.sprite_frames`，因此十三重赦刃必须提供完整 Player SpriteFrames，不能只生成两张孤立武器 Sprite。

当前绯幕礼刺正式 SpriteFrames：

`res://chapters/chapter_02_silent_court/resources/weapons/crimson_masque_player_sprite_frames.tres`

其运行时动画契约包含 30 个动画：`air_dash_end`、`air_dash_loop`、`air_dash_start`、`attack`、`attack_1`、`attack_2`、`attack_3`、`combo_transition`、`dash_attack`、`dash_end`、`dash_loop`、`dash_start`、`death`、`double_jump`、`fall`、`hurt`、`hurt_heavy`、`hurt_light`、`idle`、`jump_apex`、`jump_loop`、`jump_rise`、`jump_start`、`land`、`ready_idle`、`run`、`start_move`、`stop_move`、`turn`、`walk`。Prompt 中的 `normal_attack_1/2/3` 和 `ground_dash/air_dash` 是设计语义；正式资源必须使用控制器实际请求的上述名称。

## 6. 第三章奖励区路径

| 对象 | 路径 |
|---|---|
| Post-Boss room | `res://chapters/chapter_03_chapel_of_thirteen_echoes/scenes/rooms/ch3_post_boss_room.tscn` |
| Room script | `res://chapters/chapter_03_chapel_of_thirteen_echoes/scripts/level/chapter_03_post_boss_room.gd` |
| Reliquary scene | `res://chapters/chapter_03_chapel_of_thirteen_echoes/scenes/areas/ch3_post_boss_reliquary.tscn` |
| Reliquary script | `res://chapters/chapter_03_chapel_of_thirteen_echoes/scripts/areas/chapter_03_post_boss_reliquary.gd` |
| Runtime reliquary | `Ch3PostBossRoom/PostBossReliquary` |
| Interaction area | `Ch3PostBossRoom/PostBossReliquary/RewardInteractArea` |
| Prompt | `Ch3PostBossRoom/PostBossReliquary/InteractionPrompt` |
| Descent seal | `Ch3PostBossRoom/PostBossReliquary/DescentSeal` |
| Descent blocker | `Ch3PostBossRoom/PostBossReliquary/DescentBlocker` |
| Chapter exit | `Ch3PostBossRoom/UnderkeepExit` |

现有 `bell_reliquary.png` 和奖励逻辑是 B6 的剧情令牌/集成接口，并不是获批 WeaponData。当前没有任何 `thirteenfold_absolution` 运行时资源或占位武器。

## 7. 当前 Boss 死亡信号

Boss 场景：`res://chapters/chapter_03_chapel_of_thirteen_echoes/scenes/bosses/thirteenth_pontiff_edran.tscn`。
Boss 脚本：`res://chapters/chapter_03_chapel_of_thirteen_echoes/scripts/bosses/thirteenth_pontiff_edran.gd`。

Edran 在死亡序列完成后只发出一次无参数 `defeated` 信号。死亡序列当前已处理权杖断裂、香炉落地、黑钟坠落、身体倒下、召唤物/Hitbox 清理和消散。

Boss room 脚本：

`res://chapters/chapter_03_chapel_of_thirteen_echoes/scripts/level/chapter_03_boss_sanctum_room.gd`

它监听 `Ch3BossSanctumRoom/BossActors/ThirteenthPontiffEdran.defeated`，通知 Sanctum 环境死亡演出；只有环境演出完成后才开放 `PostBossExit`。W4 应在这个现有信号链上加一个职责独立的奖励形成控制器，不重复实现 Boss 死亡或清理。

## 8. 当前第三章到第四章解锁条件

当前条件链：

1. 进入 post-Boss room 后，遗物龛被 reveal，`UnderkeepExit` 保持 disabled。
2. 玩家在 `RewardInteractArea` 按 `interact`，当前占位逻辑设置 `chapter_03_boss_reward_collected`。
3. `notify_reward_collected()` 将封印由 Sealed 切到 Open、禁用 `DescentBlocker`、发出 `descent_unlocked`。
4. Room 收到信号后启用 `UnderkeepExit`，目标为 `CH3_UNDERKEEP_DESCENT`。

现有 ChapterSession 还同步使用 `boss_reward_spawned`、`boss_reward_collected` 运行时布尔值。正式实现将复用并规范为：

- `chapter_03_boss_environment_defeated`（现有 Boss 流程权威标志）；
- `chapter_03_boss_reward_spawned`（W4 新增）；
- `chapter_03_boss_reward_collected`（保留现有，避免重复 flag）；
- `chapter_03_underkeep_descent_unlocked`（W4 新增，显式表达门状态）。

重要边界：`res://chapters/chapter_04_drowned_underkeep/scenes/level/drowned_underkeep.tscn` 当前不存在。W5 可以完整验证遗物龛、Underkeep descent、运行时/磁盘装备继承契约；但在第四章场景被其所属里程碑正式提供前，不能诚实声称“已进入第四章实景并验证”，该项必须标记 PARTIAL，而不能由本武器任务越界新建第四章地图。

## 9. 十三重赦刃最终设计摘要

正式名称：`Thirteenfold Absolution / 十三重赦刃`。
正式 ID：`thirteenfold_absolution_blades`。
类型：`dual_daggers`，Inventory 中是一件不可拆分的双持武器。

它由 Edran 断裂空钟权杖的中央钟环、赦罪香炉的链条和旧铜炉体、胸前十三格封印残片重铸。其意义不是接受教宗教义，而是“将虚假的赦罪权，从教宗手中夺走”。

共同视觉语言：骨白/冷银刀面、黑铁暗面、暗红祷文槽、旧铜/暗金结构、黑色皮革握柄；空钟环、香炉孔洞、十三枚熄灭封印节点以及不写现代数字的第十四个空位。禁止现实十字、现实教会纹章、现实宗教文字和现实祭祀器具复制。

与现有三套武器的差异：它不是暮帷双匕的标准短匕、不是鸦牙双匕的大弯爪，也不是绯幕礼刺的纯直线宫廷刺剑；黑色剪影必须靠“长三角刺刃＋空钟圆环”和“短钩刃＋香炉半环/固定链环”独立识别。

短描述：

> 由断裂的空钟权杖与赦罪香炉重铸而成的仪式双刃。十三枚封印已经熄灭，第十四席仍旧空白。

> Ritual blades reforged from the shattered hollow-bell crozier and thurible of Pontiff Edran. Thirteen seals have gone dark; the fourteenth seat remains empty.

## 10. 主手与副手结构

### Absolution / 赦罪（主手）

- Player 前臂长度的约 1.25–1.45 倍；比暮帷更长，略短于完整绯幕礼刺。
- 细长三角刺刃，清楚尖端，骨白/冷银刃面、黑铁暗边和暗红中央槽。
- 小型椭圆空钟圆环护手；环周配置十三个微小封印节点和一个未镶嵌的空槽，环下只保留克制黑色钟舌。
- 黑皮缠柄、暗金分节；柄首取自权杖尾端的锐利小型尖饰。

### Penance / 忏悔（副手）

- 主手长度的约 70%–82%；更短、更宽，末端轻微内弯但不形成鸦牙式大弯爪。
- 刀背带香炉孔洞/钟纹镂空，仍保持清楚刃尖。
- 半圆、多孔香炉护手与固定的小链环；链条不作为流星锤，不在普通动画中乱甩。
- 暗红/黑包裹、旧铜分节；小型香炉盖或十三格残片柄首。

两把武器必须始终呈现不同长度、不同护手和不同刃形，不能仅靠颜色区分。

## 11. 武器属性

| 字段 | 正式值 |
|---|---|
| `weapon_id` | `thirteenfold_absolution_blades` |
| `display_name_en` | `Thirteenfold Absolution` |
| `display_name_zh` | `十三重赦刃` |
| `weapon_type` | `dual_daggers` |
| `tier` | `3` |
| `normal_attack_damage` | `14` |
| `dash_attack_damage` | `28` |
| `can_sell` | `false` |
| `is_story_reward` | `true` |
| `is_unique` | `true` |
| `is_permanent` | `true` |
| `auto_equip_on_pickup` | `true` |
| `allow_duplicates` | `false` |
| `player_visual_id` | `thirteenfold_absolution` |

不增加燃烧、冰冻、泥沼、召唤、回血、吸血、攻速、穿透或其他隐藏被动。Dash Attack 不重复扣耐力，不新增 Hitbox。

## 12. 将创建的文件（W1–W5计划）

### W1 — 概念原画

目录：`res://chapters/chapter_03_chapel_of_thirteen_echoes/assets/weapons/thirteenfold_absolution/concept_art/`

计划创建 Prompt 要求的 12 张正式图：

- `thirteenfold_absolution_pair_concept.png`
- `absolution_main_blade_front.png`
- `absolution_main_blade_side.png`
- `penance_offhand_blade_front.png`
- `penance_offhand_blade_side.png`
- `thirteenfold_absolution_silhouette.png`
- `thirteenfold_guard_breakdown.png`
- `thirteen_seal_nodes.png`
- `thirteenfold_player_scale.png`
- `thirteenfold_combat_pose.png`
- `thirteenfold_reforging_sequence.png`
- `thirteenfold_reliquary_concept.png`

并创建章节本地生成器/验证脚本和 `docs/qa/chapter_03_thirteenfold_absolution/w1/` 证据。W1 不建立 WeaponData。

### W2 — 正式像素素材与完整 Player SpriteFrames

- `assets/weapons/thirteenfold_absolution/sprites/`：icon、HUD icon、世界掉落、遗物龛用正式像素素材。
- `assets/weapons/thirteenfold_absolution/animations/player/`：全部 30 个运行时动画的透明像素帧。
- `assets/weapons/thirteenfold_absolution/effects/`：克制的骨白/暗金轨迹、钟环残影和拾取光效。
- `resources/weapons/thirteenfold_absolution_player_sprite_frames.tres`。
- 章节本地像素生成、SpriteFrames 构建、结构/帧覆盖测试与 Main 图像捕获脚本。

W2 的 F5 证据只验证视觉资源被 Main Player 正确加载；正式 Inventory/Equipment 注册留在 W3。

### W3 — WeaponData、Inventory、Equipment、Save

- `resources/weapons/thirteenfold_absolution_blades.tres`（独立 WeaponData）。
- `scripts/systems/player_progress_save_service.gd`（正式磁盘保存服务；文件落在 `user://`，不提交运行时存档）。
- 针对 WeaponData 独立性、14/28 数值、唯一获取、装备恢复、死亡保留、磁盘重载和 New Game 清理的测试。
- 如现有获得 UI 无法承载该武器，创建章节本地 acquisition panel，而不是把章节叙事塞进通用 Inventory。

存档服务只持久化权威的 owned weapon IDs、equipped weapon ID、必要章节完成/奖励 flags 与恢复入口；Debug start 必须运行在非持久化测试会话，不能污染正式存档。

### W4 — Boss形成演出、遗物龛与拾取

- `scenes/weapons/thirteenfold_absolution_pickup.tscn`。
- `scenes/areas/last_absolution_reliquary.tscn`（或在确认现有 PostBossReliquary 可无损升级后替换其内部正式资产）。
- `scripts/transitions/chapter_03_reward_sequence_controller.gd`。
- `scripts/ui/thirteenfold_absolution_acquisition_panel.gd` 与对应场景（如果通用 UI 不足）。
- 3.5–5.5 秒形成演出所需正式碎片、蜡烛、封印、短促共鸣和拾取效果素材。
- reward sequence、重复交互、未拾取门锁、拾取后开门、返回房间空龛状态测试。

### W5 — 持久化、Main回归与强制QA

- `tests/test_thirteenfold_absolution_full_flow.gd`。
- `scripts/tools/capture_thirteenfold_absolution_qa.gd`。
- `docs/qa/chapter_03_thirteenfold_absolution/w5/` 完整截图、报告、哈希/路径清单。
- `docs/design/chapter_03_thirteenfold_absolution_spec.md` 最终规格。

## 13. 将修改的文件（W1–W5计划）

W0 不修改以下任何运行时文件。获批后的最小修改计划：

| 阶段 | 文件 | 修改目的 |
|---|---|---|
| W2 | `scripts/player/player_weapon_visual.gd` | 注册 `thirteenfold_absolution` 完整 SpriteFrames 并保证原子切换/无旧武器闪回 |
| W2 | Chapter III route/profile（仅若 Main 视觉测试需要） | 增加非持久化 `CH3_REWARD_TEST` debug spawn；不改变正式启动 |
| W3 | `scripts/items/equipment_manager.gd` | 注册独立 WeaponData，伤害继续从装备资源读取 |
| W3 | `scripts/items/weapon_inventory.gd` | 增加最小 export/import snapshot API，保留唯一 ledger 语义 |
| W3 | `scripts/systems/chapter_session.gd` | 增加必要 flag snapshot/restore API；不让 UI 成为权威数据源 |
| W3 | `project.godot` | 仅在正式 Save 服务设计获批并测试后注册一个真实跨场景 Autoload |
| W4 | `scripts/level/chapter_03_boss_sanctum_room.gd` | 接入独立 reward sequence，不重复 Boss 死亡职责 |
| W4 | `scripts/level/chapter_03_post_boss_room.gd` | 用真实 WeaponData 获取流程替换 B6 剧情令牌占位 |
| W4 | `scripts/areas/chapter_03_post_boss_reliquary.gd` | 使用 spawned/collected/unlocked flags、真实提示和唯一交互保护 |
| W4 | `scenes/rooms/ch3_post_boss_room.tscn` | 替换正式遗物龛/武器实例与正确图层、碰撞、Player可见性 |
| W4 | `scenes/areas/ch3_post_boss_reliquary.tscn` | 正式低矮石台、旧铜边、双蜡烛、十三熄灭节点与空席结构 |
| W4 | `scenes/rooms/ch3_boss_sanctum_room.tscn` | 仅增加奖励形成控制器/演出挂点，不改变 Boss 数值或 arena |
| W5 | `chapters/.../resources/chapter/chapter_03_start_profile.tres` 及 route debug mapping | 对 W5 的四个 debug 状态进行非持久化模拟；不改正式 Opening route |
| W1–W5 | `docs/development_log.md` 与 Chapter III 武器规格/QA文档 | 每阶段记录真实命令、结果、边界和人工验收 |

现有第二章 WeaponData、Player action config、攻击 Hitbox、Boss config、第四章地图以及其他武器不在修改范围内。

## 14. Main/F5测试计划

F5 权威路径保持：

`run/main_scene = res://scenes/bootstrap/main_bootstrap.tscn`

正式启动仍由 MainBootstrap 进入 Opening；所有 debug 测试通过 ChapterStartProfile/DebugRunConfig 选择章节和 spawn，不把章节场景设为 main scene，不用 F6 代替验收。

### `CH3_BOSS`

- 完整击败 Edran；验证死亡序列、召唤清理、Boss Hitbox关闭。
- 验证 3.5–5.5 秒遗物重铸、Player临时锁定/无伤、武器与低矮遗物台出现。
- 未拾取前 Underkeep 锁定；按 E 仅获取一次、自动装备、HUD 更新、遗物台清空，随后门解锁。

### `CH3_POST_BOSS`

- 模拟 Boss 已死亡且 `reward_spawned = true`、`reward_collected = false`。
- Main 中武器必须存在且可领取；未领取时门持续关闭；退出到菜单/正式重载后仍可领取，不能永久丢失。

### `CH3_REWARD_TEST`

- 新增的 Debug-only、非持久化入口。
- 快速检查 12 张原画索引、世界 Sprite、武器剪影、Player Idle/Run/Jump/30动画、三段攻击、Dash Attack、hurt/death、拾取与装备。
- Debug session 不写正式 `user://` 存档。

### `CH3_UNDERKEEP_DESCENT`

- 模拟已拥有并装备十三重赦刃、reward collected、descent unlocked。
- 验证 Main 中装备仍为该武器，14/28 正确，死亡/重生后不丢失，返回第三章不重复生成。
- 在第四章 PackedScene 尚不存在时，入口边界明确标记 PARTIAL；场景由第四章里程碑提供后，再补正式进入第四章的 PASS 证据。

### 自动与人工验收

- 精确 Godot 4.7.1 editor import/parse；MainBootstrap headless startup；全部新增 deterministic tests。
- 检查独立 Resource 实例、14/28 数值、所有30动画、左右翻转、脚底锚点、无旧武器闪回、判定未改、唯一领取、断电式进程重启恢复、New Game清理和Debug隔离。
- 所有运行截图来自 F5 Main；最终矩阵按 `PASS / PARTIAL / FAIL` 记录，并保留路径到 `docs/qa/chapter_03_thirteenfold_absolution/`。
- 武器剪影、材质、手部贴合、轨迹克制度、场景遮挡、拾取节奏和音效疲劳仍需人工试玩验收，不能由自动测试替代。

## 当前持久化审计与风险

- `PlayerWeaponInventory`、`PlayerEquipmentManager` 和 `ChapterSessionState` 都是 Autoload，当前能跨场景和玩家死亡保留状态。
- `reset_for_new_run()` 会按预期清空到起始武器。
- 项目当前**没有磁盘 Save/Load 服务**；文档也明确记录为 runtime-only。因此“退出游戏再重开仍拥有/装备正确”现在不成立，必须在 W3 最小实现并测试正式保存，而不能在 W0 或报告中虚构 PASS。
- EquipmentManager 目前以 `match` 预载三把武器；W3 增加第四把即可满足当前规模，W0 不借机重构成复杂数据库。
- 第四章正式场景缺失使 W5 的“实景进入第四章”天然依赖外部里程碑。武器开发只负责保存/入口契约与可证明的继承，不越界造第四章地图。

## W0完成判定

- 第二章权威数值、字段和独立 Resource 要求已确认。
- Player 全帧视觉切换、Boss `defeated` 信号、Post-Boss 遗物龛占位、解锁门链路和当前 runtime-only 持久化限制已确认。
- 正式设计、结构、属性、W1–W5 文件所有权和 Main/F5 测试入口已锁定。
- 本阶段没有创建或接入十三重赦刃运行时资源。下一步只能在用户批准 W1 后开始概念原画。

## W0实际验证

使用精确 Godot `4.7.1.stable.official.a13da4feb`：

1. `/Users/vincentz/Downloads/Godot.app/Contents/MacOS/Godot --headless --editor --path /Users/vincentz/Desktop/Game/godot-codex --quit`
   - PASS；退出码 0；编辑器完成 filesystem/class/autoload/plugin 扫描，无脚本或资源错误。
2. `/Users/vincentz/Downloads/Godot.app/Contents/MacOS/Godot --headless --path /Users/vincentz/Desktop/Game/godot-codex --script res://chapters/chapter_02_silent_court/tests/test_crimson_masque_weapon.gd`
   - PASS；`data=1 frames=49 damage=14/28 dedup=1 profile=1`。
3. `/Users/vincentz/Downloads/Godot.app/Contents/MacOS/Godot --headless --path /Users/vincentz/Desktop/Game/godot-codex --script res://chapters/chapter_03_chapel_of_thirteen_echoes/tests/test_edran_b4_b7_full_boss.gd`
   - PASS；`transition=true phase2_attacks=6 death=true reward_interface=true regressions=20`。
4. `/Users/vincentz/Downloads/Godot.app/Contents/MacOS/Godot --headless --path /Users/vincentz/Desktop/Game/godot-codex --script res://chapters/chapter_03_chapel_of_thirteen_echoes/tests/test_chapter_03_r5_full_route.gd`
   - PASS；`transitions=50 cycles=10 persistent_runtime=true platform_combat=true`；测试按实际架构把 `boss_entity`、`reward`、`chapter4` 报为 `partial`。
5. `/Users/vincentz/Downloads/Godot.app/Contents/MacOS/Godot --headless --path /Users/vincentz/Desktop/Game/godot-codex --quit-after 240`
   - PASS；`MAIN BOOTSTRAP | FORMAL NEW GAME | res://scenes/cinematics/opening_cinematic.tscn`；无红色 Output/Debugger 错误。

W0没有视觉/交互交付，因此没有虚构 F5 截图；正式运行截图从 W1/W2 对应资产阶段开始按 QA 标准保留。
