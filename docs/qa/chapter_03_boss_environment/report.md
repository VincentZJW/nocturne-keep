# 第三章 Boss 区域场景强制 QA 报告

## 工作流确认

- 类型：章节场景专项生产；阶段止于 Boss 区域、奖励环境、向下转场和 Main QA。
- F5 权威入口：`res://scenes/bootstrap/main_bootstrap.tscn`。
- 先创建 42 个原创正式像素/音频资产，再由五个独立 Area Scene 引用；运行时几何仅承担碰撞和触发。
- 未越界：未创建/改写 Edran、未修改普通敌人或战斗数值、未伪造奖励、未创建第四章地图。

## 强制 QA 矩阵

| 项目 | 状态 | 证据 |
|---|---|---|
| Boss前室建筑 | PASS | [01](01_boss_antechamber_panorama_main.png) |
| Boss前室装饰 | PASS | [02](02_thirteen_blood_candles_main.png)、[03](03_thirteen_confession_tablets_main.png) |
| 十三响视觉 | PASS | 13血烛、13忏悔板、13钟与门上13封印；[02](02_thirteen_blood_candles_main.png)、[05](05_boss_gate_lit_main.png) |
| Boss门 | PASS | 三态正式门体、门框、门板、封印与碰撞；[04](04_boss_gate_closed_main.png) |
| Boss门动画 | PASS | 13步钟/封印、蜡裂、开门及原创音频；[05](05_boss_gate_lit_main.png)、[06](06_boss_gate_open_main.png) |
| Fade转场 | PASS | Main 真实 CanvasLayer 淡出证据；[07](07_gate_fade_out_main.png)、[08](08_boss_room_fade_in_main.png) |
| Boss房建筑 | PASS | 3200×720 后殿、肋拱、管风琴与无遮挡平地；[09](09_boss_sanctum_panorama_main.png) |
| Boss祭坛 | PASS | 多层祭坛、13铭牌、讲台与仪式名册；[10](10_central_altar_main.png) |
| Boss彩窗 | PASS | 中央司祭、十二跪者、第十三牺牲者与刮除位置；[11](11_thirteenfold_stained_glass_main.png) |
| Boss唱诗席 | PASS | 左右正式木质唱诗席；[12](12_choir_stalls_main.png) |
| Boss动态烛火 | PASS | 13灯逐一启用、死亡时逆序熄灭；[09](09_boss_sanctum_panorama_main.png)、[16](16_boss_death_environment_response_main.png) |
| Boss香炉 | PASS | 双侧悬挂香炉与动态烟雾；[13](13_dynamic_incense_main.png) |
| Boss入场环境演出 | PARTIAL | 镜头推进、烛火、香雾、共振、输入锁已完成；Edran实体/对白/名称尚无权威资源；[14](14_boss_intro_environment_main.png) |
| Boss战可读性 | PARTIAL | 3200px平地、低层装饰和Boss锚点完成；Edran战斗不存在，不能声称实战通过；[15](15_boss_combat_readability_hook_main.png) |
| Boss死亡环境响应 | PARTIAL | 蜡烛熄灭、彩窗裂纹、祭坛崩解、出口开启已完成；等待未来Boss `died` 信号正式绑定；[16](16_boss_death_environment_response_main.png) |
| 奖励区 | PARTIAL | 遗物龛、交互、旗标和门解锁接口完成；权威Boss奖励物品不存在；[17](17_post_boss_reliquary_main.png)、[18](18_underground_gate_open_main.png) |
| 地下入口 | PASS | 向下墓窟、湿墙、滴水、圣像、锈栅和浅水；[19](19_drowned_saints_descent_main.png) |
| 第四章转场 | PARTIAL | 方向、终端与类型化请求完成；第四章PackedScene不存在，系统明确拒绝伪跳转；[20](20_shallow_water_chapter_four_gate_main.png) |
| Main集成 | PASS | `MainBootstrap → Chapter III`，五区位于 `GameplayWorld/Chapter03BossAreas`，四个Debug Spawn实测 |
| Output与Debugger | PASS | Godot 4.7.1生成、导入、场景smoke、route/state tests与Main capture均无红色错误 |

## 场景与资产路径

- 正式 Chapter III Main：`res://chapters/chapter_03_chapel_of_thirteen_echoes/scenes/level/chapter_03_entry_placeholder.tscn`
- 五个区域：`res://chapters/chapter_03_chapel_of_thirteen_echoes/scenes/areas/`
- Boss环境规格：`res://chapters/chapter_03_chapel_of_thirteen_echoes/docs/chapter_03_boss_environment_spec.md`
- 正式资产根：`res://chapters/chapter_03_chapel_of_thirteen_echoes/assets/`
- QA证据根：`res://docs/qa/chapter_03_boss_environment/`

## Main/F5 测试

1. 在 `DebugRunConfig` 启用 Chapter III Debug Start。
2. `CH3_BOSS_ANTE`：测试 `CP_CH3_BOSS`、前室、十三响门、音效、碰撞与Fade。
3. `CH3_BOSS`：测试圣所Fade In、13烛、香雾、共振、入场镜头和Boss接口锚点。当前Boss本体为PARTIAL。
4. `CH3_POST_BOSS`：测试死亡后的彩窗/祭坛状态、奖励交互接口与地下门；当前奖励授予为PARTIAL。
5. `CH3_UNDERKEEP_DESCENT`：测试向下墓窟、滴水、浅水与第四章终端；当前第四章场景为PARTIAL。
6. 测试后恢复 `DebugRunConfig.reset_to_defaults()`，正式F5继续从Opening进入。

## 性能与运行结果

- 42个确定性资产生成成功；图片为硬边PNG，音效为项目内生成的22.05kHz单声道WAV。
- 五个Area Scene均可独立实例化；最近邻全局配置仍为0，场景Sprite明确使用Nearest。
- 十三响门时序完成后恢复Player输入，碰撞阻挡被移除并安全移动到 `CH3_BOSS`。
- Main capture在1280×720 OpenGL/Metal兼容渲染下输出20张证据；截图均已人工检查。

## PARTIAL边界

唯一的未通过完整验收项均由仓库中尚不存在的权威内容导致：Edran Boss实体、Boss奖励Resource、Chapter IV PackedScene。环境侧没有用假Boss、假奖励或假第四章掩盖这些缺口。
