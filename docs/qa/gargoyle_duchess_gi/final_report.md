# 石像鬼攻击循环与第二章 Boss 音乐重制 QA 报告

Date: 2026-08-05
Engine: Godot Engine 4.7.1 Standard, GL Compatibility
Formal entry: `res://scenes/bootstrap/main_bootstrap.tscn`

## GI0 真实实现审计

### 石像鬼

- Formal scene: `res://shared/scenes/enemies/gargoyle_sentinel.tscn`
- Formal script: `res://shared/scripts/enemies/gargoyle_sentinel.gd`
- Main instance used by the focused route:
  `RavenmournOutskirts/World/Encounters/ForestEncounter03/Enemies/ForestGargoyle01`
- World bounds: `Rect2(0, 0, 6800, 720)`, `flight_margin=56`, formal safe top
  `top_limit_y=56`.
- Pre-fix states: `Dormant`, `Hover`, `Track`, `DiveWindup`, `Dive`,
  `GroundStun`, `ReturnToAir`, `Hurt`, `Death`.
- Upward motion occurred in `ReturnToAir` and upward Hurt knockback, while
  tracking/return could also be clamped by the shared bounds. The old clamp
  changed Y/velocity only for selected states; it did not cancel an invalid
  attack or create a recoverable ceiling transition. Return additionally used
  `(current x, home y)`, so the target moved away from the authored anchor.
- Formal authored Hover Anchor is `(3500,400)` after bounds clamping. The
  corrected fixed Return Target is the same legal point. Test-local anchor is
  `(640,260)` with the same contract.

### 空心公爵夫人音乐

- Boss scene: `res://chapters/chapter_02_silent_court/scenes/boss/hollow_duchess.tscn`
- Room controller:
  `res://chapters/chapter_02_silent_court/scripts/boss/hollow_duchess_room_controller.gd`
- Formal Main instance: `SilentCourt/GameplayWorld/BossArea/HollowDuchess`
- Legacy Phase 1 was
  `assets/boss/hollow_duchess/audio/broken_waltz_intro.tres`: 6.6 seconds,
  109.09 BPM, 3/4. A short motif was the entire loop, which directly caused the
  mechanical one-cell repetition.
- Legacy Phase 2 was
  `assets/audio/music/boss/hollow_duchess/hollow_duchess_phase_02_unmasked.ogg`:
  130.909 seconds, 132 BPM, 3/4. It had no dedicated transition Stinger and was
  directly crossfaded by the room controller.
- Third-chapter audit confirmed the reusable, sample-free pipeline:
  `scripts/audio/tools/procedural_music.py` + deterministic score generator +
  standard MIDI + FFmpeg Vorbis render + JSON acoustic analysis. No Chapter III
  melody, harmony, choir or bell structure was copied.
- Buses remain `Master`, `Music`, `SFX`, `Ambient`, `UI`. `MusicManager` remains
  the formal Autoload and owns persistent players rather than allocating one per
  trigger.

## GI1 石像鬼状态机修复

The corrected flow is:

```text
upward top contact
→ flight_top_reached (latched once)
→ active DiveHitbox closed; attack id/invalid vector cleared
→ ReturnToPlayableAltitude
→ fixed get_safe_flight_target(home_position)
→ HoverRecover 0.70 s
→ reacquire Player from DetectionArea
→ Track/Hover + existing 1.10 s cooldown
```

The target Y is clamped to `[safe_top_y, bottom_y - 96]`; the return never
tracks the Player and never teleports during normal runtime. AI disable/re-enable
clears the one-shot latch and transient attack state for checkpoint/room reset.

### Ten-cycle record

| 循环 | 触顶状态 | Return Target | 是否返回 | 等待时间 | 是否再次攻击 | 状态 |
|---:|---|---|---|---:|---|---|
| 01 | Dive | (640,260) | yes | 0.70 | yes | Track |
| 02 | Dive | (640,260) | yes | 0.70 | yes | Track |
| 03 | Dive | (640,260) | yes | 0.70 | yes | Track |
| 04 | Dive | (640,260) | yes | 0.70 | yes | Track |
| 05 | Dive | (640,260) | yes | 0.70 | yes | Track |
| 06 | Dive | (640,260) | yes | 0.70 | yes | Track |
| 07 | Dive | (640,260) | yes | 0.70 | yes | Track |
| 08 | Dive | (640,260) | yes | 0.70 | yes | Track |
| 09 | Dive | (640,260) | yes | 0.70 | yes | Track |
| 10 | Dive | (640,260) | yes | 0.70 | yes | Track |

The formal Main capture independently reports target `(3500,400)`, ten attack
starts and ten ceiling recoveries. Hurt is the current shared Gargoyle's explicit
hit-stun state; its recovery, Player leave/re-enter and AI reset/re-entry all
return to Track without a scene reload.

## GI2–GI4 原创两阶段战斗音乐

| Cue | Runtime file | BPM / meter | Form | Duration / loop |
|---|---|---|---|---|
| Phase 1 | `hollow_duchess_phase_01_waltz.ogg` | 96 / 3-4 | Intro, A, B, C, A', Return | 150.000 s / full |
| Transition | `hollow_duchess_transition_stinger.ogg` | 120 / 3-4 | Mask Break, one shot | 4.500 s / none |
| Phase 2 | `hollow_duchess_phase_02_unmasked_waltz.ogg` | 120 / 3-4 | A2, B2, Phantom, Broken, Final | 132.000 s / full |

Phase 1 contains a six-note main motif, a distinct response, four motif variants
per main section, six harmonic roots, changed register/rhythm/endings, a density
subtraction and an orchestration build. Phase 2 keeps the motifs, D-minor bass
gravity, strings/harpsichord and 3/4 identity while recomposing them into faster,
chromatic, displaced and broken-waltz sections; it is not playback-rate reuse.

All audio is original and synthesized locally without samples, downloaded
assets, paid services or copyrighted music. Editable deliverables live under:

- `.../source/generate_hollow_duchess_music.py`
- `.../source/*_score.json`
- `.../midi/*.mid`
- `.../stems/phase_01_*.ogg`, `.../stems/phase_02_*.ogg`
- `.../*.analysis.json`

Master acoustic analyses report 48 kHz stereo, peak -3.098 dBFS, RMS -18.021
dBFS (P1) / -18.292 dBFS (P2) and exact boundary sample delta `0.0`.

Lifecycle: Phase-1 intro -18 dB; combat -12 dB over 0.55 s; dialogue 6 dB
duck; transition Phase 1 to -20 dB over 0.90 s plus one persistent Stinger;
Phase 2 guarded 1.00 s crossfade; death 1.50 s fade; retry stops all three
persistent players, clears the guard and restarts Phase 1 at zero.

## GI5 强制 QA 总表

| 项目 | 状态 | 根因/证据 |
|---|---|---|
| 石像鬼限高仍有效 | PASS | Formal safe top 56; shared bounds regression 80 clamp attempts |
| 触顶事件正确触发 | PASS | `flight_top_reached`; Main/debug count 10 |
| 触顶后关闭无效攻击 | PASS | Ten-cycle test checks inactive DiveHitbox every loop |
| Return Target合法 | PASS | Test `(640,260)` and Main `(3500,400)` within legal band |
| 返回原始Hover位置 | PASS | Exact anchor equality asserted for ten loops |
| 返回后重新获取Player | PASS | Detection reacquisition + leave/re-enter regression |
| 返回后第二次攻击 | PASS | Attack-cycle counter reaches 2 and then 10 |
| 连续10次攻击循环 | PASS | `GARGOYLE_CEILING_RECOVERY_TEST: PASS` |
| 无顶部抖动 | PASS | One-shot latch; one top event per attack in ten-cycle record |
| 第二章旧音乐问题审计 | PASS | 6.6 s motif loop and direct P2 crossfade identified |
| 新Phase 1音乐 | PASS | 150 s master + MIDI + score + stems |
| Phase 1旋律丰富度 | PASS (structural) | 6 sections, 4 motif variants, 1196 events |
| Phase 1舞厅华尔兹主题 | MANUAL | 3/4 and orchestration proven; subjective fit requires user listening |
| 新Phase 2音乐 | PASS | 132 s master + MIDI + score + stems |
| Phase 2高压变奏 | PASS (structural) | 5 distinct sections, 1623 events, 120 BPM |
| 两阶段主题关联 | PASS | Shared main/response motifs encoded in both score sources |
| Transition Stinger | PASS | 4.5 s non-looping persistent-player cue |
| Phase切换 | PASS | one guard, Stinger, 1.00 s crossfade; formal Main capture |
| Boss死亡淡出 | PASS | 1.50 s fade path and Main capture |
| Retry音乐重置 | PASS | Phase 1 restarts after respawn; Main capture |
| 两首音乐无缝循环 | PASS | Independent 900 s runs: P1 5 wraps, P2 6 wraps, one player, stable memory |
| 对话Duck | PASS | Music bus 6 dB duck/restore lifecycle test |
| SFX可读性 | MANUAL | Bus separation/levels proven; subjective combat mix requires user listening |
| Main/F5集成 | PASS | Both debug routes traverse MainBootstrap/formal chapter scenes |
| Output与Debugger | PASS | No red parser/resource/gameplay errors; 2 teardown warnings in one GUI harness |

## 命令与实际结果

```text
/Users/vincentz/Downloads/Godot.app/Contents/MacOS/Godot --headless --path . --import --quit
PASS — import/parse completed without red errors

.../Godot --headless --path . --script res://tests/combat/test_gargoyle_ceiling_recovery.gd
PASS — cycles=10 ceiling=10 reacquire=yes hurt_recovery=yes

.../Godot --headless --path . --script res://tests/combat/test_gargoyle_sentinel.gd
PASS

.../Godot --headless --path . --script res://tests/regression/test_cross_chapter_airborne_limits.gd
PASS — families=4 clamp_attempts=80 player_attempts=20 reloads=20

.../Godot --headless --path . --script res://chapters/chapter_01_ravenmourn_outskirts/tests/level/test_chapter_01_start_profiles.gd
PASS — 6 saved spawns including CH1_GARGOYLE_HEIGHT_TEST

.../Godot --headless --path . --script res://tests/audio/test_hollow_duchess_music_gi.gd
PASS — p1=150s@96 p2=132s@120 stinger=4.5s source=MIDI+JSON+stems

.../Godot --headless --path . --script res://tests/audio/test_music_manager_mu1.gd
PASS — buses=5 decks=2 transitions=20

.../Godot --path . --script res://chapters/chapter_01_ravenmourn_outskirts/scripts/tests/capture_gargoyle_ceiling_recovery_gi_qa.gd --rendering-method gl_compatibility
PASS — captures=7 cycles=10 top=10, formal Main

.../Godot --path . --script res://chapters/chapter_02_silent_court/scripts/tests/capture_hollow_duchess_music_gi_qa.gd --rendering-method gl_compatibility
PASS — captures=5, formal Main; no red error, 2 ObjectDB teardown warnings

.../Godot --headless --path . --quit-after 180
PASS — MAIN BOOTSTRAP formal new game opened opening_cinematic.tscn

env MU_LONG_PLAY_SECONDS=900 MU_LONG_PLAY_TRACK_ID=CH2_BOSS_MUSIC_PHASE_01 .../Godot --headless --path . --script res://tests/audio/test_music_manager_long_play.gd
PASS — seconds=900.0 wraps=5 max_players=1 memory 34856663→34853775 peak=34858495

env MU_LONG_PLAY_SECONDS=900 MU_LONG_PLAY_TRACK_ID=CH2_BOSS_MUSIC_PHASE_02 .../Godot --headless --path . --script res://tests/audio/test_music_manager_long_play.gd
PASS — seconds=900.0 wraps=6 max_players=1 memory 34856663→34853775 peak=34858495
```

## Main/F5 人工验收

1. Keep `run/main_scene` unchanged. Enable Debug Chapter Start.
2. `CH1_GARGOYLE_HEIGHT_TEST`: keep the Player in detection range and observe
   top/return/cycle counters; then leave/re-enter, take/hit-stun the Gargoyle and
   reset checkpoint.
3. `CH2_BOSS_MUSIC_PHASE_01`: hear Intro/A/B/C/A'/Return development and verify
   attack tells remain clear.
4. `CH2_BOSS_MUSIC_TRANSITION`: confirm one mask-break Stinger and no prolonged
   two-track overlap.
5. `CH2_BOSS_MUSIC_PHASE_02`: identify the transformed Phase-1 motif through
   A2/Phantom/Broken/Final sections.
6. `CH2_BOSS`: verify dialogue Duck, death fade, reward silence and Phase-1
   restart after death/respawn.

## 证据路径

- Gargoyle Main frames: `docs/qa/gargoyle_duchess_gi/main_gargoyle/`
- Ballroom Main frames: `docs/qa/gargoyle_duchess_gi/main_music/`
- Waveforms/spectrograms: `docs/qa/gargoyle_duchess_gi/audio_analysis/`

Automated QA validates state, structure, timing, asset provenance and Main
integration. It does not pretend to replace a human judgement of musical taste,
fatigue or combat-mix clarity; those two rows remain explicit manual acceptance.
