# Chapter Character Workflow / 章节人物设计工作流

- 状态：**Mandatory / 项目级永久规范**
- 适用角色：普通敌人、精英敌人、Boss、重要 NPC、特殊召唤物与变身形态
- 配套文件：`chapter_production_checklist.md`、`chapter_qa_standard.md`
- 交付权威：正式章节 Encounter 与 Main/F5 运行效果

## 1. 人物生产完成定义

人物必须来源于章节背景故事，并同时具备明确战斗岗位、独立剪影、正式概念设计、可用像素素材、完整动画、正确战斗适配、保存场景引用与 Main/F5 证据。

以下情况不算完成：只有原画；只有新 idle；攻击/死亡闪回旧帧；武器在动画中变成线；Boss 是普通敌人放大版；Phase 2 只换色/加粒子；新资源没有进入 Main；旧运行时引用未清零。

## 2. C0：人物体系与战斗岗位审计

开始前读取本章剧情、场景、Encounter、现有角色、共享组件和正式数值。对每个角色确定：

1. 剧情身份、存在原因和与地点/Boss的关系；
2. 战斗岗位、威胁距离、移动方式和组合价值；
3. 头部/躯干/四肢/装备/武器构成与黑色剪影；
4. HP、伤害、Poise、攻击节奏、弱点和恢复窗口；
5. 与玩家、同章角色和前章角色的比例与视觉差异；
6. Boss Phase、入场、变身、死亡、奖励和章节出口关系；
7. 可复用组件与必须新建的章节专属资产；
8. 当前旧资源、Inspector Override、Main 实例和 Output/Debugger 状态。

C0 输出角色矩阵、战斗岗位矩阵、视觉关键词、资产缺口、兼容风险和阶段停止点。不能为了填数量加入与章节无关的怪物。

## 3. C1：概念原画与剪影

每个普通/精英敌人至少制作：正式概念原画、横版侧视参考、剪影、武器/核心道具设计和动作姿态页。重要 NPC 还需叙事姿态、交互距离和表情/面部识别方案。

每个 Boss 至少制作：每个 Phase 的正式原画、阶段剪影对比、武器与装备设计、变身关键帧、攻击姿态页和死亡姿态页。概念资产必须真实存在于仓库并记录来源；它是正式像素生产依据，不是最终实装的替代品。

## 4. C2：正式像素素材

正式像素素材必须：

- 保留概念图的核心识别点和比例；
- 明确区分头部、躯干、四肢、衣物/护甲和装备；
- 通过有限色块表现布料、金属、骨骼、木材、皮革等材质；
- 武器具有刃、护手/结构、握柄与柄首，轮廓与攻击方向清楚；
- 暗背景下保持可读，脚底/身体锚点统一，透明边缘清晰；
- 使用最近邻和项目统一像素规格，不将高清原画直接模糊缩小。

禁止矩形身体、方块头、线条武器、纯色色块袍子、旧敌人换色、Boss 简单放大，以及用 Shader 冒充结构变化。像素风不是降低正式质量的理由。

## 5. C3：动画完整制作

普通/精英敌人原则上至少具有：

- `idle`；
- `patrol` / `move` / `hover`；
- `alert`；
- `approach` 或 `reposition`；
- `turn`；
- 每种攻击的 `windup`、`active`、`recovery`；
- `light_hit`、`hurt`、`stagger`、`death`。

Boss 还需要 `intro`、对白姿态、各 Phase idle/move、全部攻击、Phase Transition/Reveal、Stagger、Death 和奖励/退场衔接。动画必须保持身体、装备和武器结构；武器不能缩短、丢失或退化为线；变身不能只闪屏换图；死亡不能直接隐藏 Sprite。

动画名可适配现有 AI 契约，但必须在规格中建立“语义动作 → 运行时动画名”映射，避免为了美术重命名破坏玩法。

## 6. C4：战斗与系统适配

新美术必须验证 Hitbox/Hurtbox、Attack ID、朝向锁定、Windup/Active/Recovery、平台边缘、楼层/墙体限制、武器挂点、脚底锚点、受击、Stagger、Death、Loot、Encounter 计数和 Checkpoint Reset。

原则上不擅自修改 HP、伤害、攻击速度、Phase 阈值、掉落概率或玩家数值。若视觉适配要求小幅调整挂点、偏移、碰撞或关键帧时间，必须单独列出修改前后值、原因和回归结果，不得以美术任务掩盖平衡改动。

## 7. C5：章节目录与旧资源治理

章节专属角色使用：

```text
res://chapters/<chapter_id>/assets/enemies/<enemy_id>/
res://chapters/<chapter_id>/assets/bosses/<boss_id>/
res://chapters/<chapter_id>/assets/npcs/<npc_id>/
```

根据实际内容包含 `concept_art/`、`sprites/`、`animations/`、`effects/`、`audio/`、`archive_legacy/`。相应保存内容进入章节的 `scenes/`、`scripts/`、`resources/` 下对应角色类别。若仓库已有 `assets/boss/` 等已批准章节结构，应遵循当前章节清单，不为统一命名进行无关迁移。

Player、跨章节角色、通用 Health/Hit/Hurt、Projectile 和 Loot 等共享内容保留在 `shared/` 或现有全局目录，不能复制到每章形成分叉。

旧资源处理顺序：先建立可恢复归档或确认 Git 历史可恢复；更新 SpriteFrames/场景/Main 引用；全项目搜索旧路径；运行时旧引用必须为 0。未经明确批准不得删除用户要求保留的参考资产。

## 8. C6：Main 集成与人物 QA

每个人物依次通过独立动画测试、独立战斗测试、组合战斗测试、正式章节 Encounter 和 Main/F5 测试。独立测试通过不代表 Main 通过。

交付矩阵至少包含：

| 角色 | 原画路径 | Sprite路径 | 动画路径 | 场景路径 | Main测试位置 | 状态 |
|---|---|---|---|---|---|---|

Main 中必须验证实际 Encounter 使用最新 PackedScene/SpriteFrames，无旧实例 Override；视觉朝向、武器、Hitbox、受击、死亡、Loot、重生/重置和多敌人组合均正常。证据保存到 `docs/qa/`，状态只用 `PASS`、`PARTIAL`、`FAIL`。

## 9. Boss 专属永久规则

Boss 必须拥有高于普通敌人的像素质量、独立剪影、独立武器/能力、入场、可读攻击、完整死亡和奖励/出口衔接。多阶段 Boss 至少在以下项目中真正改变三项：姿态、剪影、面部、武器、服装、肢体结构、移动方式、攻击动作。

Phase 2 不得只通过红色 Shader、粒子或速度提升冒充新阶段。Boss QA 必须分别覆盖每个 Phase 原画/实装、阶段剪影、武器、入场、关键攻击、变身、死亡、奖励和 Main 集成。

## 10. 固定人物交付问题

完成报告必须回答：

1. 新增了哪些普通敌人、精英、Boss 或 NPC 正式资产？
2. 哪些为章节专属，哪些为共享？
3. Main 实际引用了哪些新 SpriteFrames/PackedScene？
4. 旧运行时引用是否为 0？
5. 按 F5 后以哪个 `chapter_id`、`spawn_id`、路线和操作测试每个角色？
6. 动画、战斗、死亡和奖励中哪些仍为 `PARTIAL` 或 `FAIL`？

固定验收问题是：“这些内容在独立测试场景完成后，我按 F5 进入 Main，具体在哪里、通过什么操作能够测试？”回答必须可复现。
