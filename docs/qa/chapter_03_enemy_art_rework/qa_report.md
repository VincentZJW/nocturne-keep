# 敌人与 Boss 美术重制强制 QA 验收报告

审计基线：`master` / `79dc8636ac67199fc48ed7976d791aaf0dded5e0`

引擎：Godot `4.7.1.stable.official.a13da4feb`

本轮授权范围：Stage 0 全章节审计 + Stage 1 第三章六敌人；第一、二章只审计，不重制。

## QA 总结果

### 第三章敌人重制

- 审计：PASS
- 概念原画：PASS
- 剪影设计：PASS
- 正式像素素材：PASS
- 动画帧：PASS
- 场景替换：PASS
- Main 集成：PASS
- 测试结果：PASS

### 第一章敌人与 Boss 重制

- 审计：PASS
- 概念原画：FAIL（本轮范围未创建或重制）
- 正式像素素材：FAIL（本轮范围未创建或重制）
- Boss 重制：FAIL（本轮范围未开始）
- Main 集成：FAIL（没有第一章美术重制可供集成）

### 第二章敌人与 Boss 重制

- 审计：PASS
- 概念原画：FAIL（本轮范围未创建或重制）
- 正式像素素材：FAIL（本轮范围未创建或重制）
- Boss 重制：FAIL（本轮范围未开始）
- Main 集成：FAIL（没有第二章美术重制可供集成）

结论：第三章 Stage 1 通过本轮强制 QA；“全章节敌人与 Boss 美术重制”总任务尚未完成。不得把本报告解释为第一、二章已重制。

## 概念图与正式实装对照

所有路径均位于 `res://chapters/chapter_03_chapel_of_thirteen_echoes/` 下。

| 角色 | 概念图路径 | 正式 Sprite 路径 | 核心识别元素 | 是否保留 | 备注 |
|---|---|---|---|---|---|
| Bellchain Penitent | `assets/enemies/bellchain_penitent/concept_art/bellchain_penitent_concept.png` | `assets/enemies/bellchain_penitent/sprites/` | 铜钟、弧形锁链、分层忏悔袍、缠布与口枷 | PASS | 链条、祈祷钟与喉钟为三个独立结构；1× Main 中链条较细，需人工重点复核 |
| Censer Executioner | `assets/enemies/censer_executioner/concept_art/censer_executioner_concept.png` | `assets/enemies/censer_executioner/sprites/` | 巨大香炉、铁链、行刑罩、宽肩、围裙 | PASS | 香炉有壳体、孔洞、余火与烟雾，体量明显大于 Player |
| Silent Chorister | `assets/enemies/silent_chorister/concept_art/silent_chorister_concept.png` | `assets/enemies/silent_chorister/sprites/` | 断裂光环、蜡封无口面、长袍、唱诗书、漂浮手势 | PASS | 书本与双臂分离；空中基准稳定 |
| Stained-Glass Seraph | `assets/enemies/stained_glass_seraph/concept_art/stained_glass_seraph_concept.png` | `assets/enemies/stained_glass_seraph/sprites/` | 破碎彩窗翼、铅条骨架、圣像面与头冠 | PASS | 蓝/酒红/旧金玻璃片由暗铅条分隔，攻击时形成箭形轮廓 |
| Confessional Wraith | `assets/enemies/confessional_wraith/concept_art/confessional_wraith_concept.png` | `assets/enemies/confessional_wraith/sprites/` | 忏悔室木格、幽魂面、披带、长臂、探出姿态 | PASS | 木质柜体与灵体使用独立材质色；隐藏/探出动作可区分 |
| Thirteenth Scribe | `assets/enemies/thirteenth_scribe/concept_art/thirteenth_scribe_concept.png` | `assets/enemies/thirteenth_scribe/sprites/` | 遮面羊皮纸、书记祭袍、羽笔、背后账册、墨字 | PASS | 面纸、账册、羽笔、铜扣与袍褶均保留 |

每个角色另有一张动作生产参考图：`assets/enemies/<role>/concept_art/<role>_action_reference.png`。剪影图为 `concept_art/<role>_silhouette.png`，正式动画资源为 `animations/<role>_sprite_frames.tres`。

## 动画资源清单

所有 415 帧均为本轮新重制的 64×64 RGBA PNG；旧 415 帧完整归档在每个角色的 `reference/deprecated_phase_2/sprites/`，SpriteFrames 不引用归档路径。

| 角色 | 动画名（帧数） | 总帧数 | 是否新重制 | 质量状态 |
|---|---|---:|---|---|
| Bellchain Penitent | `idle` 4; `walk` 6; `alert` 3; `turn` 3; `chain_lash_windup/active/recovery` 5/2/5; `bell_slam_windup/active/recovery` 7/2/6; `chain_pull_windup/active/recovery` 5/2/5; `light_hit` 2; `stagger` 4; `hurt` 3; `death` 6 | 70 | 是 | PASS |
| Censer Executioner | `idle` 4; `walk` 6; `alert` 3; `turn` 3; `primary_windup/active/recovery` 5/2/5; `overhead_crush_windup/active/recovery` 7/2/7; `smoke_release_windup/active/recovery` 5/2/5; `light_hit` 2; `stagger` 4; `hurt` 3; `death` 6 | 71 | 是 | PASS |
| Silent Chorister | `idle` 4; `walk` 6; `alert` 3; `turn` 3; `silent_wave_windup/active/recovery` 5/2/5; `crescent_hymn_windup/active/recovery` 5/2/5; `hush_field_windup/active/recovery` 5/4/5; `light_hit` 2; `stagger` 4; `hurt` 3; `death` 6 | 69 | 是 | PASS |
| Stained-Glass Seraph | `idle` 4; `walk` 6; `alert` 3; `turn` 3; `shard_volley_windup/active/recovery` 5/2/5; `dive_windup/active/recovery` 5/2/5; `shatter_burst_windup/active/recovery` 5/2/5; `light_hit` 2; `stagger` 4; `hurt` 3; `death` 6 | 67 | 是 | PASS |
| Confessional Wraith | `hidden` 4; `idle` 4; `walk` 6; `alert` 3; `turn` 3; `emerging_slash_windup/active/recovery` 5/2/5; `spectral_dash_windup/active/recovery` 5/2/5; `confession_scream_windup/active/recovery` 5/2/5; `light_hit` 2; `stagger` 4; `hurt` 3; `death` 6 | 71 | 是 | PASS |
| Thirteenth Scribe | `idle` 4; `walk` 6; `alert` 3; `turn` 3; `ink_lance_windup/active/recovery` 5/2/5; `binding_script_windup/active/recovery` 5/2/5; `thirteenth_seal_windup/active/recovery` 5/2/5; `light_hit` 2; `stagger` 4; `hurt` 3; `death` 6 | 67 | 是 | PASS |

## Main 集成验收

F5 正式入口是 `res://scenes/bootstrap/main_bootstrap.tscn`。Chapter III 注册目标是 `res://chapters/chapter_03_chapel_of_thirteen_echoes/scenes/level/chapter_03_entry_placeholder.tscn`。六个正式敌人场景通过该保存场景的四个 Encounter 进入 MainBootstrap；不是只存在于 Trial Hall。

| 角色 | 场景路径 | Sprite 节点路径 | 动画节点路径 | Main 测试位置 | 状态 |
|---|---|---|---|---|---|
| Bellchain Penitent | `scenes/enemies/bellchain_penitent.tscn` | `VisualRoot/AnimatedSprite2D` | `VisualRoot/AnimatedSprite2D` | `GameplayWorld/Phase2AEncounter/Enemies/BellchainPenitent` | PASS |
| Censer Executioner | `scenes/enemies/censer_executioner.tscn` | `VisualRoot/AnimatedSprite2D` | `VisualRoot/AnimatedSprite2D` | `GameplayWorld/Phase2BEncounter/Enemies/CenserExecutioner` | PASS |
| Silent Chorister | `scenes/enemies/silent_chorister.tscn` | `VisualRoot/AnimatedSprite2D` | `VisualRoot/AnimatedSprite2D` | `GameplayWorld/Phase2CDEEncounter/Enemies/SilentChorister` | PASS |
| Stained-Glass Seraph | `scenes/enemies/stained_glass_seraph.tscn` | `VisualRoot/AnimatedSprite2D` | `VisualRoot/AnimatedSprite2D` | `GameplayWorld/Phase2CDEEncounter/Enemies/StainedGlassSeraph` | PASS |
| Confessional Wraith | `scenes/enemies/confessional_wraith.tscn` | `VisualRoot/AnimatedSprite2D` | `VisualRoot/AnimatedSprite2D` | `GameplayWorld/Phase2CDEEncounter/Enemies/ConfessionalWraith` | PASS |
| Thirteenth Scribe | `scenes/enemies/thirteenth_scribe.tscn` | `VisualRoot/AnimatedSprite2D` | `VisualRoot/AnimatedSprite2D` | `GameplayWorld/Phase2FEncounter/Enemies/ThirteenthScribe` | PASS |

每个 Sprite 节点继续使用 chapter-local `animations/<role>_sprite_frames.tres`；资源路径不变，因此已有场景无需复制或改绑为第二套 PackedScene。确定性测试验证了六个 SpriteFrames 没有任何 `deprecated_phase_2` 引用，并验证 Chapter III Main 目标包含六个正式 PackedScene。

## 截图证据

| 编号 | 内容 | 路径 |
|---:|---|---|
| 01–06 | 六角色概念、旧 Sprite、新 Sprite 对照 | `docs/qa/chapter_03_enemy_art_rework/01_*_concept_old_new.png` 至 `06_*_concept_old_new.png` |
| 07–12 | 六角色正式 Sprite 多动作预览 | `docs/qa/chapter_03_enemy_art_rework/07_*_sprite_preview.png` 至 `12_*_sprite_preview.png` |
| 13 | 六角色新 Sprite 总览 | `docs/qa/chapter_03_enemy_art_rework/13_all_enemy_new_sprite_overview.png` |
| 14 | 六角色旧版 vs 新版总对比 | `docs/qa/chapter_03_enemy_art_rework/14_old_vs_new_overview.png` |
| 15–20 | 六角色经 MainBootstrap 进入 Chapter III 的实机截图 | `docs/qa/chapter_03_enemy_art_rework/15_*_main.png` 至 `20_*_main.png` |
| 21–26 | 六角色在 Main 中的攻击动作截图 | `docs/qa/chapter_03_enemy_art_rework/21_*_attack_main.png` 至 `26_*_attack_main.png` |
| 27 | Chorister + Seraph + Wraith 三角色组合 | `docs/qa/chapter_03_enemy_art_rework/27_three_role_combination_main.png` |

截图脚本实际加载 `MainBootstrap`，临时选择 Chapter III Debug Start Profile，捕获后恢复 Debug 设置。它不把独立测试场景伪装成 Main 证据。

## 自动化与实际运行结果

| 验证 | 实际结果 |
|---|---|
| v2 资源生成 | PASS：`roles=6 frames=415` |
| Godot 4.7.1 import/parse | PASS：842 个新/归档资源完成导入，无 parser/resource/autoload 错误 |
| 美术真实性与引用测试 | PASS：`roles=6 frames=415 archives=415 main_refs=6` |
| 概念与剪影回归 | PASS：`files=12 concepts=6 silhouettes=6 unique_silhouettes=6` |
| Phase 2 六角色阵容回归 | PASS：`roles=6 remaining_frames=345 main=6 combination_room=1` |
| Bellchain 战斗回归 | PASS：`animations=17 frames=70 hp=70 poise=32 attacks=3 solo_test=1 main_encounter=1` |
| Chapter Start Foundation | PASS：`7 entries, Chapters I/II/III-entry ready, Bootstrap preserved` |
| Main Bootstrap flow | PASS：正式 Opening + Debug Chapter II；强制退出时保留既有 2 个 ObjectDB 测试夹具泄漏警告，无红色错误 |
| 六个独立敌人场景 | PASS：全部 `--quit-after 30` exit 0 |
| Trial Hall | PASS：`chapter_03_enemy_trial_hall.tscn` exit 0 |
| Main 图形 QA | PASS：`captures=13 route=MainBootstrap enemies=6 attacks=6 combination=1` |
| F5 正式启动冒烟 | PASS：exit 0，进入 `res://scenes/cinematics/opening_cinematic.tscn` |

## 人工复核步骤

1. 在 Project Settings 的 Chapter Debug Start 中临时选择 Chapter III，并依次使用 `CH3_BELLCHAIN_TEST`、`CH3_EXECUTIONER_TEST`、`CH3_CHOIR_TEST`、`CH3_SCRIBE_TEST`。
2. 按 F5；确认启动节点仍是 `MainBootstrap`，不是直接运行敌人场景。
3. 近距离观察 Idle、转身、受击、Stagger、Death；诱导每种攻击完整经过 Windup/Active/Recovery。
4. 在 `CH3_CHOIR_TEST` 检查 Chorister、Seraph、Wraith 同屏时仍可依轮廓与材质区分。
5. 特别复核 Bellchain 在 1× Main 比例下的链弧可见性、Executioner 香炉重量感、Seraph 玻璃翼破损感。
6. 测试结束后恢复 Debug Chapter Start 为关闭；正式 F5 应进入 Opening Cinematic。

## 已知限制

- Chapter III 当前目的地仍是明确标注的敌人验收原型场景，不是正式章节环境；本轮只授权敌人美术重制，没有把该环境误报为正式第三章地图。
- Bellchain 链条在 1280×720 全景截图中细节密度最低，资源级整数倍预览清楚，但仍列为人工 1× 可读性重点检查。
- `test_main_bootstrap_flow.gd` 在强制退出时报告 2 个 ObjectDB 测试夹具实例；本轮正式 F5、Main 图形 QA、独立场景与资源测试均无该警告或红色错误。
- 第一章、第二章美术重制未获本轮执行授权，因此保持原状；需用户验收第三章方法后另开里程碑。
