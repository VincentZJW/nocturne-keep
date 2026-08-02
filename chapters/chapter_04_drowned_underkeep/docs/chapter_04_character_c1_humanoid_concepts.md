# Chapter IV CH4-C1 Humanoid Concept Art / 第四章人形普通敌人原画

- 阶段：`CH4-C1`
- 状态：**CONCEPT PASS / 正式像素实装尚未开始**
- 设计基线：`chapter_04_character_roster_c0.md`
- 生产方式：OpenAI内置图像生成工具，原创提示生成，无第三方素材输入

## 1. 本阶段范围

本阶段完成四种人形普通敌人的正式概念板：

1. Drowned Gaoler / 溺牢狱卒；
2. Chainbound Convict / 锁链重囚；
3. Mire Harpooner / 淤水鱼叉手；
4. Sunken Shield Penitent / 沉水盾忏者。

每张板均包含主视设计、侧面、背面、纯黑剪影、武器/装备拆解和横版动作语言。概念图是C4像素生产依据，不是可直接缩小使用的游戏Sprite。

## 2. 正式原画索引

| 角色 | 正式原画 | 分辨率 | SHA-256 |
|---|---|---:|---|
| Drowned Gaoler | `res://chapters/chapter_04_drowned_underkeep/assets/enemies/drowned_gaoler/concept_art/drowned_gaoler_concept_sheet.png` | 1536×1024 | `f184ac1df69a727abfb0cc40ccb14be1302eebc32a941c8b8224bda3440e2317` |
| Chainbound Convict | `res://chapters/chapter_04_drowned_underkeep/assets/enemies/chainbound_convict/concept_art/chainbound_convict_concept_sheet.png` | 1536×1024 | `11492e26b0588be265f774b4861e1cd6bc94cb46c996bfca68ffe7baa312c0c2` |
| Mire Harpooner | `res://chapters/chapter_04_drowned_underkeep/assets/enemies/mire_harpooner/concept_art/mire_harpooner_concept_sheet.png` | 1536×1024 | `2d62c552f144f2bda805e87bbccdfb6fb2284ddeffddd322d2580e34d87b0bc6` |
| Shield Penitent | `res://chapters/chapter_04_drowned_underkeep/assets/enemies/sunken_shield_penitent/concept_art/sunken_shield_penitent_concept_sheet.png` | 1536×1024 | `7610beed64362e588d5e7fced0483d0553ae81dd7b5917873088f940bace3386` |

## 3. Drowned Gaoler / 溺牢狱卒

### 设计结果

- 通过破损高冠狱卒帽、分层湿皮甲和胸前牢门式护片建立制度残留，而不是普通士兵轮廓；
- 大型钥匙环是腰部识别核心，短重砍刀与双钩钥匙链分别承担横斩和钩刺；
- 冷色眼光严格限制在面罩内部，主体依靠湿布、铁锈与金属冷边分层；
- 动作板清楚覆盖待机、警戒、砍击、链钩牵引和死亡/入水姿态。

### C4像素锁定

- 96×96画布；帽顶、钥匙环和双钩必须保留；
- 砍刀必须有厚刃、刀背、握柄与铆钉，不得成为白线；
- 钥匙不能逐把动画，但环形大轮廓与2–3把主钥匙必须可读；
- 侧视朝右时砍刀在前、链钩在后，保证攻击朝向。

## 4. Chainbound Convict / 锁链重囚

### 设计结果

- 背部木枷采用真实木梁、铁箍和脊背承托结构，显著扩大横向剪影；
- 腕镣、脚镣、粗链和实心链球都有独立机械拆解；
- 身体是受重量压迫的高大囚犯，不是盔甲Boss或方块巨人；
- 动作板表现拖行、抓链、横扫、砸地和倒地。

### C4像素锁定

- 128×128画布；木枷、链球和双脚必须完整留在安全区；
- 链球永久连接左脚镣。攻击时角色用双手抓住链条中段挥动，不在不同动画中改变物理挂点；
- 链条用连续、有节奏的像素链节表现，禁止单像素虚线；
- 重击Active可由Poise保护，但Windup和Recovery必须有明显低姿态。

## 5. Mire Harpooner / 淤水鱼叉手

### 设计结果

- 鱼骨呼吸罩、短防水披肩和绳轮腰具形成独立于枪兵/弩手的猎手轮廓；
- 鱼叉包含多倒钩刃、长杆、后端配重、旋转连接环和系绳；
- 后视图明确绳轮、备用短叉、浮标和牢号牌的挂载；
- 动作板全部位于平台边缘，覆盖瞄准、投射、收线、钩拉和近身杆击。

### C4像素锁定

- 128×96横向画布，保证鱼叉尖端和绳线不裁切；
- 正式Sprite保留面罩骨刺但压缩为3个主要外轮廓组，避免噪点；
- 绳轮为腰部圆形识别点；投射物必须复用同一鱼叉头设计；
- 平台待机的脚底锚点固定，投掷动作不得将身体重心移出碰撞体。

## 6. Sunken Shield Penitent / 沉水盾忏者

### 设计结果

- 盾牌明确是牢门刑具：腐木门芯、铁条、铰链、铆接边框、编号牌、水位线和封印；
- 盾形采用不对称拱顶与残缺外缘，避免普通矩形塔盾；
- 短钩戟包含月牙钩、金属套筒、皮革握段和柄尾；
- 四个盾损坏阶段通过裂缝、弯折铁条、缺口和结构崩解永久递进，不靠颜色变暗；
- 动作页区分推进、盾击、钩刺、Guard Break和受击。

### C4像素锁定

- 128×128画布；身体腿部不能完全被盾遮蔽；
- 四阶段Shield Sprite必须保持相同外部锚点，破碎仅改变结构与碎片；
- `shield_hp=0`后不再显示完整牢门，Guard Break结束后使用无盾身体帧；
- 钩戟攻击Hitbox必须与前伸钩刃一致，不借盾牌制造背后攻击范围。

## 7. 四角色视觉差异矩阵

| 角色 | 高度/体量 | 外轮廓中心 | 主要材质 | 武器读法 | 战斗读法 |
|---|---|---|---|---|---|
| Gaoler | 中等偏宽 | 帽、钥匙环、双持 | 湿布/皮/小铁甲 | 短砍刀+链钩 | 基础追击与两击节奏 |
| Convict | 最高最宽 | 横向木枷、链球 | 皮肤/木/粗铁 | 拖链重球 | 慢转身大范围重击 |
| Harpooner | 最高最瘦 | 面罩、横向鱼叉 | 防水皮/骨/绳 | 长投叉+绳轮 | 可抵达平台远程 |
| Penitent | 宽厚 | 牢门盾、短钩戟 | 湿袍/腐木/铁栅 | 防御盾+短钩 | 正面路由与破盾窗口 |

四者仅看黑色剪影即可区分，不依赖颜色或UI名称。

## 8. 生产边界与下一阶段

- C1未生成透明Sprite、SpriteFrames、EnemyData、AI、Hitbox或Main实例；
- C1未修改C0锁定的HP、伤害、Poise和攻击节奏；
- C1未进入三种非人形敌人的`CH4-C2`；
- 下一阶段必须先审核这些人形概念板，再进入C2；
- C4正式像素生产必须逐帧重绘，不能直接缩小本阶段原画。
