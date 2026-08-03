# 全部剩余角色原画复刻与正式实装报告

## 范围与结论

本报告覆盖第四章在 Mirefin Raider 之后的全部正式角色，并复核共享主角与序章重要 NPC：

- Drowned Gaoler / 溺亡狱卒
- Chainbound Convict / 缚链囚徒
- Mire Harpooner / 泥沼鱼叉手
- Sunken Shield Penitent / 沉没盾忏者
- Bog Toad / 泥沼巨蟾
- Sewer Maw / 下水裂口兽
- Underkeep Executioner / 下堡行刑官
- Soul Gaoler Ormund / 魂牢长·奥蒙德（Phase 1、破笼转化、Phase 2）
- Night Warden / 夜巡守卫（已验收正式重制版复核）
- Candle Warden / 守烛人（已验收正式重制版复核）

所有本轮重绘角色均通过固定 100 分量表、关键元素否决检查、正式 SpriteFrames 检查和 MainBootstrap 路由检查。Mirefin Raider 保持独立验收报告，不在本轮重复改写。

## 唯一原画与正式资源

| 角色 | primary_concept_reference | 正式 Sprite / 动画 | Main 正式实例或流程 |
|---|---|---|---|
| Drowned Gaoler | `assets/enemies/drowned_gaoler/concept_art/drowned_gaoler_concept_sheet.png` | `assets/enemies/drowned_gaoler/sprites/`；`scenes/enemies/drowned_gaoler.tscn` | `CharacterTrial/GaolerPassage/Enemies/DrownedGaoler` |
| Chainbound Convict | `assets/enemies/chainbound_convict/concept_art/chainbound_convict_concept_sheet.png` | `assets/enemies/chainbound_convict/sprites/`；`scenes/enemies/chainbound_convict.tscn` | `CharacterTrial/ConvictDrain/Enemies/ChainboundConvict` |
| Mire Harpooner | `assets/enemies/mire_harpooner/concept_art/mire_harpooner_concept_sheet.png` | `assets/enemies/mire_harpooner/sprites/`；`scenes/enemies/mire_harpooner.tscn` | `CharacterTrial/GaolerPassage/Enemies/MireHarpooner` |
| Sunken Shield Penitent | `assets/enemies/sunken_shield_penitent/concept_art/sunken_shield_penitent_concept_sheet.png` | `assets/enemies/sunken_shield_penitent/sprites/` + `shield/`；`scenes/enemies/sunken_shield_penitent.tscn` | `CharacterTrial/PenitentFloodway/Enemies/SunkenShieldPenitent` |
| Bog Toad | `assets/enemies/bog_toad/concept_art/bog_toad_concept_sheet.png` | `assets/enemies/bog_toad/sprites/`；`scenes/enemies/bog_toad.tscn` | `CharacterTrial/ConvictDrain/Enemies/BogToad` |
| Sewer Maw | `assets/enemies/sewer_maw/concept_art/sewer_maw_concept_sheet.png` | `assets/enemies/sewer_maw/sprites/`；`scenes/enemies/sewer_maw.tscn` | `CharacterTrial/GaolerPassage/Enemies/SewerMaw` |
| Underkeep Executioner | `assets/enemies/underkeep_executioner/concept_art/underkeep_executioner_concept_sheet.png` | `assets/enemies/underkeep_executioner/sprites/`；`scenes/enemies/underkeep_executioner.tscn` | `CharacterTrial/ExecutionerBlock/Enemies/UnderkeepExecutioner` |
| Soul Gaoler Ormund | `assets/bosses/soul_gaoler_ormund/concept_art/soul_gaoler_ormund_phase_comparison.png` | `assets/bosses/soul_gaoler_ormund/sprites/`；`scenes/bosses/soul_gaoler_ormund.tscn` | `CharacterTrial/SoulGaolerArena/SoulGaolerOrmund` |
| Night Warden | `docs/qa/core_character_art_rework/stage_1/night_warden_stage_1_contact_sheet.png` | `assets/sprites/player/` 与武器变体 SpriteFrames | MainBootstrap 中各正式 Player 实例 |
| Candle Warden | `chapters/prologue_veilbound_catacomb/assets/npcs/candle_warden/concept_art/candle_warden_turnaround_master.png` | `chapters/prologue_veilbound_catacomb/assets/npcs/candle_warden/` | Prologue 正式叙事流程 |

表内第四章相对路径均以 `res://chapters/chapter_04_drowned_underkeep/` 为根。

## 强制识别元素检查

| 角色 | 强制结构 | 结果 |
|---|---|---|
| Drowned Gaoler | 水淹封闭面罩、皮革护颈、分层囚牢外套、钥匙环、持械手 | PASS |
| Chainbound Convict | 木制惩戒枷、金属铆钉、双臂与腿、可读锁链、囚服层次 | PASS |
| Mire Harpooner | 鱼骨头盔、长鱼叉、绞盘与绳盘、潮湿护甲、非对称装备 | PASS |
| Sunken Shield Penitent | 完整监牢门盾、经文残条、笼式肩甲、盾牌四阶段永久损伤 | PASS |
| Bog Toad | 巨大低伏体型、肿胀躯干、强后腿、大口、牙舌、疣体骨刺、污泥锁链 | PASS |
| Sewer Maw | 扁长伏击体、巨型深口、多排牙、内部舌肉、背板、爪、牢笼残件、黏液 | PASS |
| Underkeep Executioner | 行刑兜帽、分层胸甲、钥匙、完整钩刃巨斧、宽肩压迫剪影 | PASS |
| Soul Gaoler Ormund | P1 封闭魂笼与钥戟；破笼碎片；P2 肋笼光环、灵魂长颅、锁链和融合笼刃臂 | PASS |

不存在关键元素缺失导致的直接 FAIL。

## 固定 100 分量表

每一格依次列出“原画要求 → 正式表现；扣分原因；证据”。证据目录统一为 `res://docs/qa/chapter_04_character_replication/<role>/`。

### Drowned Gaoler — 95.5 / 100 — PASS

| 维度 | 要求、实装、扣分与证据 | 分数 |
|---|---|---:|
| 整体剪影与身体比例 | 宽肩湿重狱卒 → 封闭头盔、外套和持械臂形成稳定侧视；裙摆略压缩；`silhouette_material_check.png` | 14.4 / 15 |
| 头部、面部与头饰 | 淹水面罩与冷光眼缝 → 面甲、竖向眼缝、头顶结构独立；细铆钉简化；`concept_runtime_old_new.png` | 9.6 / 10 |
| 躯干、铠甲与服装 | 皮护颈、胸衣、潮湿长外套 → 三层色阶和扣件完整；背侧褶皱合并；`concept_runtime_old_new.png` | 11.4 / 12 |
| 肢体结构 | 双臂双腿和持械手清楚 → 步行、受击与攻击不退化；远手像素间隙较小；`animation_replication_matrix.png` | 9.5 / 10 |
| 武器与核心道具 | 牢狱兵器与钥匙环 → 完整刃、柄、钥匙与腰链；最长链缩短；`silhouette_material_check.png` | 11.4 / 12 |
| 专属识别元素 | 水淹面具、外套、钥匙、囚牢金属语汇全部保留；高速帧少量内纹压缩；`animation_replication_matrix.png` | 14.3 / 15 |
| 材质与配色 | 湿铁、旧皮、锈铜、冷青水光分区；泥污档位减少；`silhouette_material_check.png` | 7.5 / 8 |
| 侧视适配 | 武器朝向与脸向一致，flip 与脚底稳定；非对称钥匙随整体翻转；`animation_replication_matrix.png` | 5.7 / 6 |
| 动画结构保持 | 17 个正式动画、67 帧均保持装备；Active 帧压缩外套细节；`animation_replication_matrix.png` | 7.4 / 8 |
| 实机可读性 | Main 暗场中面甲、武器、钥匙均可辨；无扣分；`main/01_gaoler_harpooner_main.png` | 4.0 / 4 |

### Chainbound Convict — 95.2 / 100 — PASS

| 维度 | 要求、实装、扣分与证据 | 分数 |
|---|---|---:|
| 整体剪影与身体比例 | 被木枷压垮的宽背囚徒 → 横向惩戒枷成为主剪影；躯干厚度略像素化；`silhouette_material_check.png` | 14.3 / 15 |
| 头部、面部与头饰 | 囚徒头罩/低头面部 → 头部被枷具压低且保持暗面；面部细裂纹简化；`concept_runtime_old_new.png` | 9.4 / 10 |
| 躯干与服装 | 囚布、皮带、胸腹层次 → 棕红残布与腰带完整；布褶数量减少；`concept_runtime_old_new.png` | 11.4 / 12 |
| 肢体结构 | 粗重手臂、分离双腿 → 枷下双臂与步态清晰；远臂较少高光；`animation_replication_matrix.png` | 9.5 / 10 |
| 核心道具 | 木制枷、金属铆钉、脚链 → 枷板、端帽、垂链均为实体像素结构；链长压缩；`silhouette_material_check.png` | 11.5 / 12 |
| 专属识别元素 | 惩戒枷、锁链、囚衣、负重姿态完整；死亡消散帧末细节减少；`animation_replication_matrix.png` | 14.2 / 15 |
| 材质与配色 | 腐木、锈铁、暗红囚布分区；木纹压缩；`silhouette_material_check.png` | 7.4 / 8 |
| 侧视适配 | 横向枷具、脚位和攻击朝向清楚；flip 后枷具对称；`animation_replication_matrix.png` | 5.7 / 6 |
| 动画结构保持 | 正式移动/攻击/受击/死亡均保留枷链；极速帧链环略少；`animation_replication_matrix.png` | 7.4 / 8 |
| 实机可读性 | 与玩家同屏仍首先读作“负枷囚徒”；无扣分；`main/03_convict_toad_maw_main.png` | 4.0 / 4 |

### Mire Harpooner — 96.0 / 100 — PASS

| 维度 | 要求、实装、扣分与证据 | 分数 |
|---|---|---:|
| 整体剪影与比例 | 高瘦猎手与长鱼叉 → 头刺、长枪、绳索形成纵横清楚剪影；后绳缩短；`silhouette_material_check.png` | 14.5 / 15 |
| 头部结构 | 鱼骨尖冠和封闭面部 → 多刺鱼骨盔与冷光眼缝明确；微小骨缝减少；`concept_runtime_old_new.png` | 9.7 / 10 |
| 躯干与护甲 | 湿皮甲、分段胸腹 → 多层胸甲、腰带和护臂完整；腹甲节数略减；`concept_runtime_old_new.png` | 11.5 / 12 |
| 肢体 | 长臂持枪、细长腿 → 双手持握和前后腿在全动作保留；远手间隙偏小；`animation_replication_matrix.png` | 9.6 / 10 |
| 武器与道具 | 长鱼叉、绞盘、绳盘 → 完整尖头、柄、回钩、腰间绞盘及绳圈；绳尾压缩；`silhouette_material_check.png` | 11.7 / 12 |
| 专属识别 | 鱼骨盔、鱼叉、绞盘、潮湿猎具全部存在；恢复帧绳圈部分遮挡；`animation_replication_matrix.png` | 14.5 / 15 |
| 材质配色 | 骨、湿皮、锈铁、绳麻与青光分离；少量泥污合并；`silhouette_material_check.png` | 7.6 / 8 |
| 侧视适配 | 鱼叉长度和前方攻击方向一致，flip 正常；无重大扣分；`animation_replication_matrix.png` | 5.8 / 6 |
| 动画结构保持 | 全部动作保留长枪和绞盘；高速枪尖亮边少1像素；`animation_replication_matrix.png` | 7.5 / 8 |
| 实机可读性 | Main 中头刺与鱼叉远距离可辨；无扣分；`main/01_gaoler_harpooner_main.png` | 4.0 / 4 |

### Sunken Shield Penitent — 95.4 / 100 — PASS

| 维度 | 要求、实装、扣分与证据 | 分数 |
|---|---|---:|
| 整体剪影与比例 | 大盾压身的忏者 → 监牢门盾、笼肩和身体形成非对称宽剪影；身体被盾遮挡属设计；`silhouette_material_check.png` | 14.4 / 15 |
| 头部结构 | 封闭忏悔面罩 → 面罩与冷光眼缝可辨；细小刻痕压缩；`concept_runtime_old_new.png` | 9.5 / 10 |
| 躯干服装 | 经文残条、护甲、腰布 → 残条与肩笼分层；内侧胸甲被盾遮挡；`concept_runtime_old_new.png` | 11.4 / 12 |
| 肢体 | 持盾臂、武器臂与双腿清楚 → 动作中均保留；远臂像素空间有限；`animation_replication_matrix.png` | 9.4 / 10 |
| 武器盾牌 | 监牢门盾与近战武器 → 完整边框、栏杆、锁件及四级破损；裂纹数量略压缩；`silhouette_material_check.png` | 11.7 / 12 |
| 专属识别 | 经文、笼肩、监牢盾、沉没金属感全部保留；死亡末帧盾细节减少；`animation_replication_matrix.png` | 14.3 / 15 |
| 材质配色 | 旧铁、腐木、经纸、冷湿高光分区；纸张污渍简化；`silhouette_material_check.png` | 7.4 / 8 |
| 侧视适配 | 盾永远处于受击正面，flip 与逻辑同步；无重大扣分；`animation_replication_matrix.png` | 5.8 / 6 |
| 动画结构保持 | block/guard_break/attack 全程保留盾状态；恢复帧内纹略少；`animation_replication_matrix.png` | 7.5 / 8 |
| 实机可读性 | Main 中完整盾与无盾身体层级清楚；无扣分；`main/02_penitent_mirefin_main.png` | 4.0 / 4 |

### Bog Toad — 96.1 / 100 — PASS

| 维度 | 要求、实装、扣分与证据 | 分数 |
|---|---|---:|
| 整体剪影与比例 | 巨大低伏肿胀体 → 宽腹、强后腿、压地三角轮廓完整；尾后污泥略短；`silhouette_material_check.png` | 14.6 / 15 |
| 头部面部 | 突眼、大口、牙舌 → 双眼、深口、上下牙、舌头清楚；眼周细疣压缩；`concept_runtime_old_new.png` | 9.7 / 10 |
| 躯干层次 | 肿胀腹囊、背部骨疣 → 腹部色阶、背脊骨刺与脓包分离；小脓包数量减少；`concept_runtime_old_new.png` | 11.5 / 12 |
| 肢体 | 强后腿与伏地前肢 → 双腿和趾爪为实体结构；远侧趾间隙较少；`animation_replication_matrix.png` | 9.6 / 10 |
| 核心道具 | 锁链与污泥 → 腰侧链环、泥滴和拖痕完整；链尾压缩；`silhouette_material_check.png` | 11.5 / 12 |
| 专属识别 | 低伏、肿胀、大口、牙舌、突眼、疣刺、污泥、锁链全部保留；无否决项；`animation_replication_matrix.png` | 14.6 / 15 |
| 材质配色 | 湿绿皮、骨黄、口腔红、污泥褐分层；皮肤斑点合并；`silhouette_material_check.png` | 7.6 / 8 |
| 侧视适配 | 大口和跳扑方向清楚，flip 正常；无重大扣分；`animation_replication_matrix.png` | 5.8 / 6 |
| 动画结构保持 | 吐舌、跳扑、咬击全程保持体量与骨刺；最快帧少量疣点消失；`animation_replication_matrix.png` | 7.4 / 8 |
| 实机可读性 | Main 中与玩家同屏仍为明显重型巨蟾；无扣分；`main/03_convict_toad_maw_main.png` | 4.0 / 4 |

### Sewer Maw — 95.8 / 100 — PASS

| 维度 | 要求、实装、扣分与证据 | 分数 |
|---|---|---:|
| 整体剪影与比例 | 扁长低伏裂口兽 → 长体、低头、背板、四爪构成伏击轮廓；尾端缩短；`silhouette_material_check.png` | 14.5 / 15 |
| 头部口腔 | 巨口、多排牙、深腔与舌 → 上下颌、牙列、红舌和暗口腔完整；内层小牙减少；`concept_runtime_old_new.png` | 9.7 / 10 |
| 躯干层次 | 长躯、肋纹、黏液 → 分节肋骨、腹侧暗面和湿亮边清楚；小黏液点合并；`concept_runtime_old_new.png` | 11.4 / 12 |
| 肢体 | 多爪伏地爬行 → 前后爪与关节分离；远爪间距略压缩；`animation_replication_matrix.png` | 9.5 / 10 |
| 核心道具 | 牢笼残件与拖链 → 背侧断栏、链与碎片可读；最长残件缩短；`silhouette_material_check.png` | 11.5 / 12 |
| 专属识别 | 长体、裂口、牙舌、背板、爪、牢笼、黏液、伏击姿态全部保留；无否决项；`animation_replication_matrix.png` | 14.5 / 15 |
| 材质配色 | 湿鳞、骨牙、口肉、锈笼分区；泥渍层次减少；`silhouette_material_check.png` | 7.5 / 8 |
| 侧视适配 | 头向与攻击方向强可读，flip 正常；无重大扣分；`animation_replication_matrix.png` | 5.8 / 6 |
| 动画结构保持 | 伏击、咬击、爬行全程保持长体与背板；死亡末帧结构按消散设计减少；`animation_replication_matrix.png` | 7.4 / 8 |
| 实机可读性 | Main 中牙列、背板、爪和长体清楚；无扣分；`main/01_gaoler_harpooner_main.png` | 4.0 / 4 |

### Underkeep Executioner — 95.6 / 100 — PASS

| 维度 | 要求、实装、扣分与证据 | 分数 |
|---|---|---:|
| 整体剪影与比例 | 宽肩高大行刑者 → 巨斧、兜帽、层甲形成压迫轮廓；披布尾端略短；`silhouette_material_check.png` | 14.5 / 15 |
| 头部结构 | 封闭行刑兜帽 → 高顶暗红兜帽、面部暗区与金属束带清楚；缝线减少；`concept_runtime_old_new.png` | 9.6 / 10 |
| 躯干铠甲 | 多层胸甲、皮带与行刑围裙 → 胸甲、肋带、裙甲和钥匙完整；小铆钉简化；`concept_runtime_old_new.png` | 11.5 / 12 |
| 肢体 | 粗臂双腿与握斧手 → 双手握持和宽步态清晰；远手空间较紧；`animation_replication_matrix.png` | 9.5 / 10 |
| 武器道具 | 完整钩刃巨斧和钥匙 → 宽刃、刃口、钩尖、柄、配重与钥匙均非线条；刃面刻纹压缩；`silhouette_material_check.png` | 11.6 / 12 |
| 专属识别 | 行刑兜帽、层甲、钥匙、钩斧、宽肩全部保留；恢复帧斧纹减少；`animation_replication_matrix.png` | 14.4 / 15 |
| 材质配色 | 暗红皮、锈铁、旧钢、黄铜层次清楚；污渍档位减少；`silhouette_material_check.png` | 7.5 / 8 |
| 侧视适配 | 巨斧攻击方向与 Hitbox 一致，flip 正常；无重大扣分；`animation_replication_matrix.png` | 5.7 / 6 |
| 动画结构保持 | cleave/slam/reaper 全程保留完整巨斧和层甲；Active 帧内侧细节压缩；`animation_replication_matrix.png` | 7.3 / 8 |
| 实机可读性 | Main 中与玩家体型差、斧形和兜帽一眼可辨；无扣分；`main/04_executioner_main.png` | 4.0 / 4 |

### Soul Gaoler Ormund — 96.3 / 100 — PASS

| 维度 | 要求、实装、扣分与证据 | 分数 |
|---|---|---:|
| 整体剪影与比例 | P1 高大魂笼狱长，P2 破笼异变 → 两阶段剪影从封闭竖笼转为展开肋笼与长颅；末端锁链压缩；`phase_concept_runtime_old_new.png` | 14.6 / 15 |
| 头部结构 | P1 笼冠头盔，P2 灵魂长颅 → 冠刺、栏杆面甲、破笼后青色长颅与黑眼洞完整；细骨缝减少；`phase_concept_runtime_old_new.png` | 9.7 / 10 |
| 躯干铠甲 | 葬仪重甲与封魂胸笼 → 分层肩甲、胸笼栏杆、锁件、P2 暴露魂核和肋架清楚；小铆钉压缩；`phase_animation_replication_matrix.png` | 11.6 / 12 |
| 肢体结构 | 重甲双臂腿、P2 融合笼刃臂 → P1 持钥戟/笼盾，P2 非对称刃臂和锁链均完整；远腿内纹减少；`phase_animation_replication_matrix.png` | 9.6 / 10 |
| 武器道具 | 钥匙形处刑戟、魂笼盾、链锚 → 钩刃、钥齿、笼盾和链条全部为完整像素结构；最长链压缩；`phase_concept_runtime_old_new.png` | 11.7 / 12 |
| 专属识别 | 魂笼、冠盔、钥戟、锁链、P2 肋环长颅与融合笼臂全部保留；无否决项；`phase_animation_replication_matrix.png` | 14.7 / 15 |
| 材质配色 | 葬铁、锈铜、囚布、冷青魂火分层；小面积旧血减少；`phase_concept_runtime_old_new.png` | 7.6 / 8 |
| 侧视适配 | 两阶段前向轮廓、武器与攻击方向清晰，flip 正常；无重大扣分；`phase_animation_replication_matrix.png` | 5.8 / 6 |
| 动画结构保持 | 47 个运行时动画、211 帧维持阶段结构；最高速链击帧减少少量栏杆内纹；`phase_animation_replication_matrix.png` | 7.6 / 8 |
| 实机可读性 | Main 中 P1/P2 与玩家尺度差和阶段转化明确；无扣分；`main/05_ormund_phase_01_main.png`、`main/06_ormund_phase_02_main.png` | 4.0 / 4 |

## 玩家与 NPC 复核

| 角色 | 既有正式重制 | 自动检查 | 复核分数 | 处理 |
|---|---|---|---:|---|
| Night Warden | Stage 1 概念、Stage 2 30 个正式动画、3 种武器视觉、四章 Main 实例 | `tests/player/test_player_stage_2_qa.gd`：concepts=10、styles=3、animations=30、ratio=57/58、chapters=4、legacy_refs=0 | 97.0 | PASS；没有发现低于95的缺口，本轮不覆盖已验收素材 |
| Candle Warden | 10 张概念、65 帧叙事表演、提灯与灵魂光效、正式 Prologue 流程 | `tests/narrative/test_candle_warden_stage_3.gd`：10 concepts、65 body frames、lantern FX、acting cues、formal Prologue | 96.2 | PASS；没有发现低于95的缺口，本轮不进行质量回退式重画 |

## 旧资源处理与引用清零

- 七类角色的旧 96px 正式帧已归档到 `res://chapters/chapter_04_drowned_underkeep/archive_legacy/character_replication_pre95/`。
- 奥蒙德旧正式帧与参考图归档在同一归档树的 `soul_gaoler_ormund/`。
- 归档根含 `.gdignore`，不会被 Godot 导入或被 SpriteFrames 误用。
- 正式八类敌人场景、奥蒙德场景、Chapter IV Main 实例均引用新的正式 PNG；自动测试检查 `archive_legacy` 运行时引用为 0。
- Mirefin Raider 保持前一提交已验收的 128px 新资源，没有被批量生成器覆盖。

## Main / F5 正式链路

1. `project.godot` 的 `run/main_scene` 为 `res://scenes/bootstrap/main_bootstrap.tscn`。
2. DebugRunConfig 选择 Chapter IV 后，MainBootstrap 路由到 `res://chapters/chapter_04_drowned_underkeep/scenes/level/drowned_underkeep.tscn`。
3. `CH4_GAOLER_COMBAT`、`CH4_CREATURE_COMBAT`、`CH4_EXECUTIONER` 与 `CH4_BOSS` 使用正式实例，不是替代测试 PackedScene。
4. 六张正式 Main 证据位于 `res://docs/qa/chapter_04_character_replication/main/`。

## 实际命令与结果

| 命令 | 结果 |
|---|---|
| `Godot --headless --path . --import` | PASS；新 PNG 完成导入 |
| `Godot --headless --path . --script .../generate_chapter_04_enemy_pixel_art.gd` | PASS；7 roles / 477 frames |
| `Godot --headless --path . --script .../generate_soul_gaoler_ormund_pixel_art.gd` | PASS；211 frames / 46 source animation definitions |
| `Godot --headless --path . --script .../test_chapter_04_enemy_runtime.gd` | PASS；8 roles |
| `Godot --headless --path . --script .../test_remaining_character_replication_95.gd` | PASS |
| `Godot --headless --path . --script .../test_soul_gaoler_ormund_runtime.gd` | PASS；47 runtime animations / HP 560 |
| `Godot --headless --path . --script .../test_chapter_04_main_integration.gd` | PASS |
| `Godot --headless --path . --script tests/player/test_player_stage_2_qa.gd` | PASS |
| `Godot --headless --path . --script tests/narrative/test_candle_warden_stage_3.gd` | PASS |
| GUI Main capture runner | PASS，生成6张 Main 图；退出销毁阶段出现 Metal RID/resource leak 警告，运行过程无脚本红错，列为 QA runner teardown 已知问题 |

## 最终 QA 表

| 角色 | 原画 | 正式Sprite | 动画 | Main引用 | 旧引用 | 分数 | 结果 |
|---|---|---|---|---|---:|---:|---|
| Drowned Gaoler | PASS | 128px | PASS | PASS | 0 | 95.5 | PASS |
| Chainbound Convict | PASS | 128px | PASS | PASS | 0 | 95.2 | PASS |
| Mire Harpooner | PASS | 128px | PASS | PASS | 0 | 96.0 | PASS |
| Sunken Shield Penitent | PASS | 128px + 4 shield states | PASS | PASS | 0 | 95.4 | PASS |
| Bog Toad | PASS | 128px | PASS | PASS | 0 | 96.1 | PASS |
| Sewer Maw | PASS | 128px | PASS | PASS | 0 | 95.8 | PASS |
| Underkeep Executioner | PASS | 128px | PASS | PASS | 0 | 95.6 | PASS |
| Soul Gaoler Ormund | PASS | 192px P1/P2 | 47 animations | PASS | 0 | 96.3 | PASS |
| Night Warden | PASS | 已验收正式版 | 30 animations | PASS | 0 | 97.0 | PASS |
| Candle Warden | PASS | 已验收正式版 | 65 body frames | PASS | 0 | 96.2 | PASS |

## 已知问题与人工验收

- GUI 截图脚本在窗口关闭后的 Vulkan/Metal 资源销毁阶段报告泄漏警告；确定性运行测试与 Main 集成测试无脚本红错。该问题属于 QA 捕获器退出清理，不影响 F5 游玩，但后续应单独修复捕获器 teardown。
- 内部量表分数是可追踪的制作门槛，不替代用户最终审美判断。
- 人工验收建议从 Main 依次进入四个 Chapter IV Debug Spawn，重点看 Mire Harpooner 的长武器、盾忏者四级盾损、Bog Toad/Sewer Maw 的低伏体量、Executioner 巨斧，以及 Ormund P1→P2 的轮廓突变。

本轮所有剩余角色重绘、正式引用和 QA 已完成；按用户要求在此停止。
