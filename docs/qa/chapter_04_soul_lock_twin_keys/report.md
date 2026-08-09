# 第四章Boss奖励——魂锁双钥强制QA报告

## QA总结果

**PASS** — W1–W5 implementation, deterministic combat/persistence checks, and rendered MainBootstrap evidence are complete. Subjective player-feel acceptance remains available to the user through the documented F5 route, but no known technical or visual gate is left failing.

| 项目 | 状态 | 根因/证据 |
|---|---|---|
| 正式名称与ID | PASS | `Soul-Lock Twin Keys / 魂锁双钥`, `soul_lock_twin_keys` |
| Lockbreaker / 断狱 | PASS | 宽钥齿刃、断裂镣铐护手与短断链在正式像素帧中可辨认 |
| Soulseal / 魂契 | PASS | 窄刃、完整锁环、冷青魂流与较短副手比例可辨认 |
| 原创概念图 | PASS | `assets/weapons/soul_lock_twin_keys/concept_art/soul_lock_twin_keys_concept_board.png` |
| 正式世界拾取物 | PASS | Area 15遗匣使用正式`WeaponPickup`，非静态装饰占位 |
| 30套玩家动画 | PASS | 97张64×64透明帧，SpriteFrames构建测试为30/97 |
| Normal Attack实际伤害 | PASS | 真实Player Attack Hitbox命中100 HP目标后为84 HP |
| Dash Attack实际伤害 | PASS | 真实Player Dash Hitbox命中100 HP目标后为68 HP |
| 唯一与不可重复 | PASS | 首次拾取成功，第二次及重载回访均被拒绝，库存计数为1 |
| 自动装备 | PASS | 正式拾取后`equipped_weapon_id == soul_lock_twin_keys` |
| 死亡/重生保留 | PASS | W4 write/load测试中致死与`respawn_at()`后仍为16/32 |
| 关闭游戏重载保留 | PASS | 两个独立Godot进程完成save/write与fresh load验证 |
| Boss死亡不提前授予 | PASS | Main Q4测试确认死亡后未拥有武器且记忆通路仍锁定 |
| 奖励演出 | PASS | 水静止→灵魂释放→锁链收紧→遗匣升起→断狱→魂契→可领取七阶段均被观测 |
| 第五章通路 | PASS | 只有收取奖励后才设置`ch4_memory_passage_unlocked`并打开Area 16 |
| Main/F5集成 | PASS | `application/run/main_scene`保持`MainBootstrap`; Q4全流程PASS |
| Output/Debugger | PASS | 最终editor/import、W4、奖励、Q4测试及有窗口Main截图过程无项目红错 |

## 设计与资产

- 主手**断狱**使用更宽、破损且明显不对称的钥齿刃；副手**魂契**保持更短、更窄并以冷青魂流区分。
- 两把武器保留双匕首角色既有动作语法，没有增加被动、额外Hit、攻击距离、攻速或耐力改动。
- 正式运行资源合计112张PNG：97张玩家动画帧、6张图标/展示素材、8张演出效果与1张概念板。
- 概念图由内置图像生成工作流制作，提示目标为原创哥特像素游戏武器概念板：一把断裂监牢主钥刃、一把完整魂契副钥刃、黑铁/腐银/锈铜/溺水冷青色板，以及游戏拾取与角色持握参考。正式运行像素素材由Godot低分辨率Image绘制器重新制作，没有直接缩放概念图。

## 正式奖励演出与进度

1. `ch4_boss_defeated` / `ch4_reward_unlocked`仅允许进入破魂蓄池。
2. Area 15播放七阶段遗匣演出并锁定玩家输入、临时保护玩家。
3. 演出结束后现有`WeaponPickup`才可交互。
4. 收取后由现有Inventory/Equipment系统唯一入库并自动装备。
5. `ch4_reward_collected`与`ch4_memory_passage_unlocked`永久保存；Area 15回访显示空遗匣。
6. 现有Area 16记忆出口继续负责正式进入第五章；没有建立平行章节系统。

## 实际命令与结果

```text
/Users/vincentz/Downloads/Godot.app/Contents/MacOS/Godot --headless --path . --editor --quit
PASS — import/parse clean

... --script res://chapters/chapter_04_drowned_underkeep/scripts/tools/generate_soul_lock_twin_keys_assets.gd
PASS — original pixel resources generated

... --script res://chapters/chapter_04_drowned_underkeep/scripts/tools/build_soul_lock_twin_keys_sprite_frames.gd
PASS — animations=30 frames=97

... --script res://chapters/chapter_04_drowned_underkeep/tests/test_soul_lock_twin_keys_reward_sequence.gd
PASS — stages=7, actual hit damage=16/32, unique collection

SOUL_LOCK_W4_PHASE=write ... --script res://chapters/chapter_04_drowned_underkeep/tests/test_soul_lock_twin_keys_progress.gd
PASS — unique/equip=16/32 death=retained save=retained

SOUL_LOCK_W4_PHASE=load ... --script res://chapters/chapter_04_drowned_underkeep/tests/test_soul_lock_twin_keys_progress.gd
PASS — fresh-process ownership/equipment/flags/empty reliquary retained

... --script res://chapters/chapter_04_drowned_underkeep/tests/scenes/test_chapter_04_q4_boss_flow.gd
PASS — Main=bootstrap Boss=P1/P2/death reward=locked/collected memory=CH5_START cistern=cleared

... --script res://chapters/chapter_04_drowned_underkeep/tests/scenes/capture_soul_lock_twin_keys_main_qa.gd
PASS — captures=9 through rendered MainBootstrap
```

## Main/F5人工验收

1. 保持`run/main_scene = res://scenes/bootstrap/main_bootstrap.tscn`。
2. 开发时将Chapter Debug Start设为`CHAPTER_04_DROWNED_UNDERKEEP`、spawn设为`CH4_AREA_14`，F5完成奥蒙德战并向右进入Area 15；或用`CH4_AREA_15`快速检查遗匣（正式奖励条件仍由Boss旗标控制）。
3. 观察水声沉寂、魂光、锁链、遗匣与双钥分阶段成形；领取前Area 16出口保持锁定。
4. 按E领取后确认HUD显示`WPN T4 16 / 32`，普通攻击、Dash Attack、左右翻转、死亡重生与回访空遗匣。
5. 向右进入Hall of Drowned Memories，完成短记忆演出后从既有出口进入Chapter V。

## 截图证据

- [可领取双钥](07_claimable.png)
- [获得并装备16/32](08_obtained_and_equipped.png)
- [装备攻击](09_equipped_attack.png)
- [像素动作接触表](w2/pixel_contact_sheet.png)
- 同目录`01`至`06`依次记录水静止、灵魂释放、锁链、遗匣、断狱和魂契阶段。

## 已知边界

- 本任务没有增加新攻击动作、被动效果、额外Hit、攻击距离或第五章玩法。
- 自动测试验证了命中伤害与状态；战斗节奏和视觉偏好仍建议用户按上述Main路线进行最终主观试玩。
