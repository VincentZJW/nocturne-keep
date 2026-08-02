# Chapter IV CH4-C1 Concept QA

## Result

`PASS / CONCEPT ONLY`

四张1536×1024 PNG均已保存到Chapter IV专属目录并完成视觉检查。文件可被Godot导入，但未被任何运行时场景引用。

## Visual checks

| 检查 | Gaoler | Convict | Harpooner | Penitent |
|---|---|---|---|---|
| 主视完整 | PASS | PASS | PASS | PASS |
| 侧视/背视一致 | PASS | PASS | PASS | PASS |
| 黑色剪影可辨 | PASS | PASS | PASS | PASS |
| 武器/装备有真实结构 | PASS | PASS | PASS | PASS |
| 动作语言可转Sprite | PASS | PASS | PASS | PASS |
| 与前三章敌人区分 | PASS | PASS | PASS | PASS |
| 无商业角色/Logo/水印 | PASS | PASS | PASS | PASS |

## Production caveats

- 原画细节密度高于正式像素预算；C4只保留C0/C1列出的核心识别元素，不逐像素缩小。
- Convict的锁链永久锚定左脚镣，动作时抓取中段链条；这是正式动画必须统一的挂点规则。
- Penitent盾牌的编号是世界内材质细节，不作为必须精确可读的UI文字；正式Sprite只保留编号牌形状和高对比笔画。
- Harpooner绳索在正式游戏中由Projectile/Line表现策略决定，但鱼叉、绳轮和连接环必须持续可见。

## Provenance

- 生成方式：OpenAI built-in image generation tool；
- 输入：仅项目原创文字设计规格，无外部参考图或第三方素材；
- 输出：项目绑定PNG，原始生成文件保留在Codex生成目录；
- 完整生成提示：`generation_prompts.md`。

## Runtime boundary

本阶段没有Main可玩角色，因此没有伪造F5战斗截图。正式F5人物验收属于C4/C7。C1只验证项目导入、MainBootstrap基线和原画文件完整性。
