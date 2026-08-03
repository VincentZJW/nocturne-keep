# Mirefin Raider / 淤鳞袭掠者原画复刻QA

## 审计身份

- `reference_concept`: `res://chapters/chapter_04_drowned_underkeep/assets/enemies/mirefin_raider/concept_art/mirefin_raider_concept_sheet.png`
- `side_reference`: `res://docs/qa/chapter_04_character_replication/mirefin_raider/concept_side_reference.png`
- `final_sprite`: `res://chapters/chapter_04_drowned_underkeep/assets/enemies/mirefin_raider/sprites/`
- `animation_resource`: `res://chapters/chapter_04_drowned_underkeep/scenes/enemies/mirefin_raider.tscn`（正式运行使用的内嵌 `SpriteFrames`）
- `scene_path`: `res://chapters/chapter_04_drowned_underkeep/scenes/enemies/mirefin_raider.tscn`
- `main_scene`: `res://scenes/bootstrap/main_bootstrap.tscn`
- `formal_main_instance`: `CharacterTrial/PenitentFloodway/Enemies/MirefinRaider`
- `sprite_canvas`: `128 x 128 RGBA`，透明背景，最近邻采样
- `runtime_anchor`: `VisualRoot/AnimatedSprite2D = (0, -38)`，脚底基线维持世界 `y = 0`
- `legacy_archive`: `res://chapters/chapter_04_drowned_underkeep/assets/enemies/mirefin_raider/archive_legacy/c4_96px_v1/`

## 只读审计结论（返工前）

旧版96像素素材为直立、圆头、简化青绿色人形。背鳍、长颌牙列、腮裂、双手利爪、脚链、囚布和湿润鳞片均缺失或不可辨，且身体没有原画的弯背压地姿态。初始估算为 **35.0 / 100，直接FAIL**。旧版已完整归档，未删除可回滚PNG。

## mandatory_features

| 原画强制特征 | 正式Sprite实现 | 证据 | 状态 |
|---|---|---|---|
| 骨质鱼类头部 | 象牙骨板、眼窝、鼻孔与骨缝分层 | `feature_detail_closeups.png` 第1格 | PASS |
| 长嘴与明显颌部 | 上颅前伸，独立下颌及口腔暗面 | `feature_detail_closeups.png` 第1格 | PASS |
| 多排尖牙 | 上下牙列错位排列，Fin Bite张口仍完整 | `05_f5_fin_bite.png` | PASS |
| 腮裂 | 暗红腮囊及4条浅色腮裂 | `feature_detail_closeups.png` 第1格 | PASS |
| 背鳍与背部鳞片 | 8段不规则背鳍、湿鳞高光和背部色阶 | `feature_detail_closeups.png` 第2格 | PASS |
| 长臂与利爪 | 双臂超过膝线，四指骨爪及蹼膜分离 | `03_f5_claw_swipe.png` | PASS |
| 弯背 | 颈肩前扣、背脊弧线和低重心始终保留 | `01_f5_idle_with_player.png` | PASS |
| 囚犯残布 | 腰带、三条破布和不齐下摆 | `formal_sprite_idle_8x.png` | PASS |
| 锁链 | 后踝镣铐与逐节锁链，步行/攻击随脚位移动 | `feature_detail_closeups.png` 第4格 | PASS |
| 湿滑材质 | 冷青分区、高光斑、滴水与死亡水光 | `07_f5_death.png` | PASS |

`fail_conditions`: 无。没有强制识别元素完全缺失。

## 100分固定量表

| 维度 | 原画要求 | 正式Sprite实际表现 | 扣分原因 | 证据 | 得分 |
|---|---|---|---|---|---:|
| 整体剪影与身体比例 | 大头长颌、弯背、低髋、长臂、背鳍形成压地三角剪影 | 128px侧视完整复现，双臂与后腿形成前后支撑 | 像素画将原画极细尾端收束为较短链尾 | `silhouette_alignment_overlay.png` | 14.5 / 15 |
| 头部、面部与头饰结构 | 鱼骨颅、长嘴、眼窝、多牙列、腮囊 | 骨板分层、冷青魂眼、上下牙列及红色腮笼均独立可读 | 原画颅骨表面的小裂纹数量略有压缩 | `feature_detail_closeups.png` | 9.7 / 10 |
| 躯干、铠甲与服装层次 | 湿鳞弯背、肩胛、囚服残布 | 背部色阶、肩胛亮边、腰带和三层残布保留 | 腹侧细小鳞片为保证暗场可读而合并 | `formal_sprite_idle_8x.png` | 11.4 / 12 |
| 手臂、腿部、爪、鳍与肢体结构 | 长臂、蹼爪、屈膝后腿、鳍列 | 双臂/双腿分层，近远爪都为四指结构，8段背鳍 | 远侧脚趾在最小动作帧中减少1像素间隙 | `animation_structure_matrix.png` | 9.5 / 10 |
| 武器、盾牌、法器与核心道具 | 脚镣与拖链为核心道具 | 镣铐、链环、前后遮挡和动作位移均实现 | 受128px画布限制，最长拖链较原画短 | `feature_detail_closeups.png` | 11.5 / 12 |
| 角色专属识别元素 | 头骨、牙、腮、背鳍、爪、弯背、残布、锁链、湿质 | 10项全部在Idle、移动、攻击、受击、死亡中保留 | Fin Bite最大张口时腮囊被下颌遮挡少量 | `animation_structure_matrix.png` | 14.4 / 15 |
| 材质、明暗与配色 | 冷绿湿鳞、旧骨、暗红腮/残布、青色湿光 | 17色色板区分骨、鳞、布、链和水光 | 原画的泥污暖灰被压缩为两档 | `palette_comparison.png` | 7.5 / 8 |
| 侧视横版适配准确度 | 轮廓朝向清楚，适合横版碰撞与翻转 | 头颌朝前、手爪前后层次清楚，flip后无锚点漂移 | 非对称链条镜像为玩法可读性策略 | `08_f5_flip_right.png` | 5.7 / 6 |
| 动画中结构保持度 | 所有动作不丢失关键结构 | 17个动画、67帧全部重绘并通过区域自动检查 | 最高速Active帧压缩少量内侧鳞片 | `animation_structure_matrix.png` | 7.5 / 8 |
| 实机尺寸、清晰度与可读性 | 正式相机、暗场、浅水、与玩家同屏仍可辨 | Main/F5中骨头、牙、腮、鳍、爪、残布、锁链均可辨 | 无扣分 | `main_f5/01_f5_idle_with_player.png` | 4.0 / 4 |
| **总分** |  |  |  |  | **95.7 / 100** |

## 轮廓对照

| 部位 | 原画轮廓 | Sprite轮廓 | 偏差程度 | 修复状态 |
|---|---|---|---|---|
| 头部 | 前伸鱼骨长颅 | 55px宽骨质长颅和独立下颌 | 低 | 已修复 |
| 背部 | 高低不齐的连续背鳍 | 8段不规则高低鳍列 | 低 | 已修复 |
| 胸部 | 弯背后收、胸腔前扣 | 肩胛前扣与腹部回收 | 低 | 已修复 |
| 手臂 | 长臂落至地面附近 | 近远臂均超过膝线 | 低 | 已修复 |
| 手爪 | 长指骨爪与蹼 | 四指分离并带蹼膜 | 低 | 已修复 |
| 腿部 | 屈曲、压低、爬行倾向 | 前后腿保持屈膝支撑 | 低 | 已修复 |
| 鳍 | 宽而破损 | 像素化为宽根、尖端不齐 | 低 | 已修复 |
| 锁链 | 后踝拖链 | 后踝镣铐及12节链环 | 中低 | 已修复，长度为可读性压缩 |
| 服装下摆 | 多层囚服破布 | 三层错位残布 | 低 | 已修复 |

轮廓叠加采用统一朝向、统一脚底基线与统一身体高度，红色为原画轮廓，青色为Sprite轮廓：`res://docs/qa/chapter_04_character_replication/mirefin_raider/silhouette_alignment_overlay.png`。

## 配色与材质对照

| 配色项 | 原画颜色范围 | Sprite颜色范围 | 一致性 |
|---|---|---|---|
| 湿鳞 | 深海青绿至灰绿高光 | `#1d3433`—`#94aaa0` | PASS |
| 旧骨 | 暗骨灰至湿亮象牙 | `#5f6259`—`#d0c9b3` | PASS |
| 腮/口腔 | 暗酒红至血褐 | `#391f27`—`#7d3b42` | PASS |
| 囚布/皮带 | 泥褐与锈棕 | `#2c211c`—`#86543b` | PASS |
| 锁链 | 冷暗铁至浅钢 | `#263238`—`#a0b0ad` | PASS |
| 魂眼/滴水 | 冷青湿光 | `#6eb4ba`—`#c6ece5` | PASS |

## 动画结构保持度

所有动画最低分为95.0，没有低于95的关键动画。

| 动画 | 帧数 | 保留结构检查 | 分数 | 结果 |
|---|---:|---|---:|---|
| idle | 4 | 全部10项；呼吸仅移动肩、腮和水滴 | 96.5 | PASS |
| walk | 6 | 背鳍、双爪、脚链随步态移动，脚底稳定 | 95.5 | PASS |
| alert | 3 | 头颌抬起、鳍列展开，残布不消失 | 96.0 | PASS |
| turn | 3 | 结构无缩短；左右由正式flip策略完成 | 95.0 | PASS |
| light_hit | 2 | 头骨/牙/鳍/链完整，后仰清楚 | 95.5 | PASS |
| hurt | 3 | 腮、骨颅、双爪和残布均保留 | 95.5 | PASS |
| stagger | 4 | 低姿失衡但不退化为普通人形 | 95.5 | PASS |
| claw_swipe_windup | 5 | 近爪蓄力、远爪与链仍可辨 | 96.0 | PASS |
| claw_swipe_active | 2 | 长臂与四指爪成为攻击主剪影 | 96.5 | PASS |
| claw_swipe_recovery | 5 | 爪、鳍、头颌平滑回位 | 95.5 | PASS |
| mire_lunge_windup | 5 | 躯干压低、背鳍后拖、链未断裂 | 96.0 | PASS |
| mire_lunge_active | 2 | 头颌与双臂同时前送，仍区别于Fin Bite | 96.0 | PASS |
| mire_lunge_recovery | 5 | 身体比例和脚底基线恢复稳定 | 95.5 | PASS |
| fin_bite_windup | 5 | 下颌展开、牙列逐级出现、腮笼保留 | 96.5 | PASS |
| fin_bite_active | 2 | 上下牙列、口腔深度与头骨轮廓清楚 | 96.5 | PASS |
| fin_bite_recovery | 5 | 牙列不跳变，腮与骨颅正确闭合 | 95.5 | PASS |
| death | 6 | 倒地、背鳍塌落、链与骨颅留存并水化消散 | 95.0 | PASS |

## Main/F5实机表现

F5正式路径：

1. `project.godot` → `run/main_scene = res://scenes/bootstrap/main_bootstrap.tscn`；
2. `DebugRunConfig` → Chapter IV / `CH4_CREATURE_COMBAT`；
3. MainBootstrap路由到 `res://chapters/chapter_04_drowned_underkeep/scenes/level/drowned_underkeep.tscn`；
4. 正式实例：`CharacterTrial/PenitentFloodway/Enemies/MirefinRaider`。

截图脚本通过上述正式路径加载，不实例化替代敌人。证据：

- Idle、与Player同屏：`main_f5/01_f5_idle_with_player.png`
- Walk：`main_f5/02_f5_walk.png`
- Claw Swipe：`main_f5/03_f5_claw_swipe.png`
- Mire Lunge：`main_f5/04_f5_mire_lunge.png`
- Fin Bite：`main_f5/05_f5_fin_bite.png`
- Hurt：`main_f5/06_f5_hurt.png`
- Death：`main_f5/07_f5_death.png`
- 反向flip：`main_f5/08_f5_flip_right.png`

正式相机2x像素整数缩放下无平滑插值、无半像素抖动；Player、敌人、浅水地面与场景层次可同时辨认。

## 旧资源替换检查

| 角色 | 旧资源路径 | 新资源路径 | 正式场景已替换 | Debug试炼已替换 | 剩余旧引用 |
|---|---|---|---|---|---:|
| Mirefin Raider | `archive_legacy/c4_96px_v1/sprites/` | `sprites/`（128px） | 是 | 是 | 0 |

正式场景、正式试炼场景、`.tres`资源中对 `archive_legacy` / `c4_96px_v1` 的运行时引用为0。归档目录包含 `.gdignore`，Godot不导入旧帧，也不会产生重复UID。

## 玩法完整性

- 未修改生命、Poise、伤害、AI、攻击时间、攻击范围或Encounter配置。
- 正式身体碰撞仍为 `(0, -30)`，Hurtbox仍为 `(0, -30)`。
- Sprite画布从96扩展到128，但脚底基线与 `AnimatedSprite2D (0, -38)` 锚点不变。
- Primary/Secondary Hitbox、FloorCheck、WallCheck和掉落组件均未改变。
- 正式Main场景与Debug人物试炼通过相同正式PNG路径取得新帧。

## reviewer_notes

- 自动结构测试覆盖17个动画、67帧、透明背景、尺寸、关键区域像素密度、正式Main引用和归档引用清零。
- 95.7分为本项目固定量表下的可审计内部评分；最终审美确认仍需用户查看F5截图或亲自试玩。
- 当前仅Mirefin Raider通过；**不能据此声明第四章全角色已通过95%验收**。

## 最终结果

`total_score = 95.7`

`PASS` — Mirefin Raider单角色达到95分门槛，且不存在关键元素否决项。按任务要求在此停止，不进入Bog Toad。
