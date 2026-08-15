# Ormund Phase 2 Visual + Bleed QA

## Scope and runtime authority

- Main/F5 authority: `res://scenes/bootstrap/main_bootstrap.tscn`
- Formal Boss room: `res://chapters/chapter_04_drowned_underkeep/scenes/rooms/ch4_14_core_of_drowned_gaol.tscn`
- Formal Boss instance: `Ch4CoreOfDrownedGaol/Enemies/SoulGaolerOrmund`
- Boss scene/script: `res://chapters/chapter_04_drowned_underkeep/scenes/bosses/soul_gaoler_ormund.tscn` / `res://chapters/chapter_04_drowned_underkeep/scripts/bosses/soul_gaoler_ormund.gd`
- Attack effect: `res://chapters/chapter_04_drowned_underkeep/scripts/bosses/soul_gaoler_attack_effect.gd`
- Status authority: `res://scripts/player/player_status_effect_controller.gd`
- Fast manual routes: `CHAPTER_04_DROWNED_UNDERKEEP` with `CH4_BOSS_PHASE_01` or `CH4_BOSS_PHASE_02`.

## Root-cause audit

Ormund owns one `AnimatedSprite2D`; the formal Boss scene has no competing Phase-1/Phase-2 visual nodes, `AnimationPlayer`, RESET track, texture track or material track. The authoritative runtime field is `phase`; transition completion and the existing direct-Phase-2 debug entry both set it to `2`.

The regression was deterministic state-entry pollution: `_action_animation()` mapped `drowned_javelin` to the Phase-1 `prison_hook_drag_*` family and `gaolers_verdict` to the Phase-1 `chain_anchor_slam_*` family even after `phase == 2`. Hurt, stagger, turn and recovery did not rewrite the visual resource. The fix maps those requests to `soul_shackle_*` and `chainstorm_cleave_*` in Phase 2 and applies a single phase-aware animation resolver at the existing animation entry point. It does not force visibility or resources every frame.

The resolver records redirects and treats any active Phase-1 animation while `phase == 2` as a violation. Twenty transitions, thirty facing flips, repeated state changes and five 120-second deterministic Phase-2 simulations produced zero violations.

## Bleed contract

- Sources: the real `drowned_javelin` projectile and every real `iron_grave` pike zone.
- Direct damage remains 22 for both sources.
- Apply gate: `HitboxComponent.hit_confirmed`, emitted only after `HurtboxComponent.receive_hit()` accepted the direct hit and health decreased.
- Tick contract: 1 HP at t=1, 2, 3, 4 and 5 seconds; no t=0 tick; total 5 HP.
- Ownership: one Bleed state/timer in the existing `PlayerStatusEffectController`.
- Re-hit: refreshes the five-second duration; never creates a second instance or raises damage per tick.
- DOT semantics: direct HealthComponent damage only, so no Hurt, stagger, knockback, combo cancellation or hitstop; lethal ticks use the existing Player death signal and sequence.
- Presentation: a small dark-crimson Player effect plus one compact status-HUD slot. Burn, Freeze and Mire retain their previous constants and behavior.

## Ormund Phase 2 Visual + Bleed QA

| 项目 | 状态 | 证据 |
|---|---|---|
| Phase2 Transition | PASS | Focused test completed 20 real transition entries; `phase == 2` after completion. |
| Phase2 Visual锁定 | PASS | Phase-aware animation entry resolver; no per-frame visibility override; five 120-second simulations reported 0 violations. |
| Idle保持P2 | PASS | Focused state/animation-family assertion. |
| Move保持P2 | PASS | Focused state/animation-family assertion. |
| Turn保持P2 | PASS | 30 left/right flips; 0 Phase-1 frames. |
| Attack保持P2 | PASS | All P2 actions, including Javelin and Verdict redirects, resolved to P2 families. |
| Hurt保持P2 | PASS | 20 normal hits completed with 0 visual violations. |
| Stagger保持P2 | PASS | 5 forced staggers completed with 0 visual violations. |
| Recovery保持P2 | PASS | Hurt/stagger/action recovery assertions remained P2. |
| Opening AOE保持P2 | PASS | Existing opening graphical captures and focused family assertion. |
| Phase1视觉闪回次数 | PASS | 0 across focused stress and five full deterministic replays. |
| Blade Throw Bleed | PASS | 20 accepted projectile hits applied one Bleed each. |
| Iron Grave Bleed | PASS | 20 accepted pike hits applied one Bleed each. |
| Bleed 1HP/s | PASS | Deterministic timeline observed one HP at each one-second boundary. |
| Bleed 5s | PASS | Active through the fifth tick and expired immediately after settlement. |
| Bleed总伤害5 | PASS | Exactly 5 HP in focused trace for both sources. |
| Bleed不叠层 | PASS | Blade→Pike→Blade pressure retained one active Bleed and 1 damage/tick. |
| Bleed刷新持续时间 | PASS | Re-hit reset remaining duration to 5 seconds without an extra tick. |
| DOT无硬直 | PASS | Player Hurt animation/state counter unchanged across all five ticks. |
| DOT无Knockback | PASS | Player velocity unchanged across all five ticks. |
| DOT可正常击杀Player | PASS | 1-HP Player died through the existing HealthComponent/death signal. |
| Burn/Freeze系统未受影响 | PASS | Chapter III elemental regression: 986 assertions, Burn 30, Freeze 30, Mire 30. |
| Main/F5 | PASS | Main integration and full Q4 Boss→reward→Chapter V route tests passed; live manual handoff remains the user acceptance step. |
| Output/Debugger | PASS | Exact editor import/parse and graphical MainBootstrap run exited without project red errors. |

## Exact verification

```text
/Users/vincentz/Downloads/Godot.app/Contents/MacOS/Godot --headless --editor --path . --quit
PASS — exit 0; no project script/resource error.

/Users/vincentz/Downloads/Godot.app/Contents/MacOS/Godot --headless --path . --script chapters/chapter_04_drowned_underkeep/tests/characters/test_soul_gaoler_ormund_phase_visual_bleed.gd
PASS — TRANSITIONS 20; FLIPS 30; NORMAL_HITS 20; DASH_HITS 10; STAGGERS 5; BLEED_HITS 40.

/Users/vincentz/Downloads/Godot.app/Contents/MacOS/Godot --headless --path . --script chapters/chapter_04_drowned_underkeep/tests/characters/test_soul_gaoler_ormund_attack_variety.gd
PASS — transitions 30; Javelin 20; Verdict 20; Iron Grave 20.

/Users/vincentz/Downloads/Godot.app/Contents/MacOS/Godot --headless --path . --script chapters/chapter_04_drowned_underkeep/tests/characters/test_soul_gaoler_ormund_runtime.gd
PASS.

/Users/vincentz/Downloads/Godot.app/Contents/MacOS/Godot --headless --path . --script chapters/chapter_04_drowned_underkeep/tests/characters/test_soul_gaoler_ormund_balance.gd
PASS.

/Users/vincentz/Downloads/Godot.app/Contents/MacOS/Godot --headless --path . --script chapters/chapter_04_drowned_underkeep/tests/characters/test_soul_gaoler_ormund_balance_replays.gd
PASS — five final replays: standard 257.4 s; conservative 379.6 s ×2; aggressive 191.8 s ×2; all 0 visual violations.

/Users/vincentz/Downloads/Godot.app/Contents/MacOS/Godot --headless --path . --script chapters/chapter_03_chapel_of_thirteen_echoes/tests/test_edran_elemental_magic.gd
PASS — 986 assertions; Burn 30; Freeze 30; Mire 30; cadence 20.

/Users/vincentz/Downloads/Godot.app/Contents/MacOS/Godot --headless --path . --script chapters/chapter_04_drowned_underkeep/tests/characters/test_chapter_04_main_integration.gd
PASS.

/Users/vincentz/Downloads/Godot.app/Contents/MacOS/Godot --headless --path . --script chapters/chapter_04_drowned_underkeep/tests/scenes/test_chapter_04_q4_boss_flow.gd
PASS — MainBootstrap Boss P1/P2/death, reward and CH5_START.

/Users/vincentz/Downloads/Godot.app/Contents/MacOS/Godot --path . --audio-driver Dummy --script chapters/chapter_04_drowned_underkeep/tests/scenes/capture_soul_gaoler_ormund_balance_main_qa.gd
PASS — 16 saved MainBootstrap captures; no project red diagnostic.
```

## Graphical evidence

- Phase transition: `docs/qa/chapter_04_ormund_attack_variety/12_main_phase_transition_protected.png`
- Phase-2 opening telegraph/active/punish: `13_main_phase_02_opening_telegraph.png`, `14_main_phase_02_opening_active.png`, `15_main_phase_02_opening_punish.png`
- Phase-2 Iron Grave: `16_main_phase_02_iron_grave_two_wave.png`
- Javelin direct effect presentation: `06_main_drowned_javelin_direction_lock.png`, `07_main_drowned_javelin_release.png`

## Manual acceptance

Run F5 with `CHAPTER_04_DROWNED_UNDERKEEP / CH4_BOSS_PHASE_01`. Cross the real transition and keep Phase 2 active while observing turns, attacks, hurt/stagger and recovery. Deliberately receive Javelin and Iron Grave hits: HP should take the unchanged direct 22 damage, then five silent one-point ticks with the dark-crimson status indication. A second accepted source refreshes the duration; it must not show two simultaneous Bleed ticks.
