# CH4 Ormund Phase 2 & Attack Variety QA

Date: 2026-08-14

Authority: `res://scenes/bootstrap/main_bootstrap.tscn` → debug start `CH4_BOSS_PHASE_01` → `CH4_AREA_14`

Formal Boss: `Chapter04DrownedUnderkeep/ActiveRoom/Enemies/SoulGaolerOrmund`

Weapon baseline: Thirteenfold Absolution Blades, normal/Dash `14/28`

## Audit: former Phase-II free-output window

| Item | Before this milestone | Corrected runtime |
|---|---:|---:|
| Phase-II threshold | 55% = 275/500 HP | unchanged |
| State | `PhaseTransition` | `PhaseTransition` → `PhaseTwoOpening` |
| State-gated transition time | 9.230769 s | 2.00 s |
| Saved visual animation | 8 frames at 8 FPS (1.00 s), then visually stale while the state timer continued | 8 frames at 4 FPS (2.00 s), aligned with the state timer |
| Player protection/control | no forced protection; normal control remained available | normal control remains available so the player can reposition |
| Boss Hurtbox | remained enabled for all 9.230769 s | closed for transformation and opener telegraph/active |
| AI / Attack Select | disabled for 9.230769 s | opener begins immediately at 2.00 s; ordinary selection begins after its 0.85 s recovery |
| First Phase-II threat | approximately 9.23 s after threshold, then distance selection | opening telegraph begins at 2.00 s; active at 3.40 s |
| Free normal-animation opportunities | approximately 46 at the 0.20 s base loop | 0 damage opportunities before the opener; the first legal punish window is intentional recovery |
| Free Dash opportunities | initial four-stamina burst plus regeneration during the long state | 0 damage opportunities before the opener; Dash remains movement, not an invented i-frame |

Root cause was the mismatch between a one-second SpriteFrames animation and a
9.230769-second state timer, combined with an enabled Hurtbox and a direct return
to ordinary `Combat`. The corrected transition is a short protected visual bridge,
not a free-output state and not a new high-frequency combo.

The formal Boss scene used an embedded 8-FPS animation. A parallel named
SpriteFrames resource still carried 0.866667 FPS; both saved resources are now
aligned to the same 4-FPS, two-second contract so scene and resource timing no
longer disagree.

## Implemented combat contract

- `Judgment of the Broken Gaol / 破狱裁决` is a one-use Phase-II opener: 1.40 s telegraph, 0.24 s active, 40 damage, two authored safe ground gaps plus a low 16 px jumpable wave, then 0.85 s punish recovery. `phase2_opening_used` resets only on a new Phase-I encounter/retry. Direct `CH4_BOSS_PHASE_02` also begins with this opener.
- `Drowned Javelin / 溺狱投矛`: Far-only at 142+ px, 0.82/0.72 s windup, final 0.25 s direction lock, straight 520 px/s projectile, 22 damage, 1.5 s harmless embedded miss, 6/5 s P1/P2 cooldown.
- `Gaoler's Verdict / 狱钥裁决`: 1.12/0.94 s windup, final 0.28 s direction lock, 28 direct or 18 shockwave damage through one shared ledger, 1.42/1.22 s punish recovery and a restrained camera shake.
- `Iron Grave / 铁墓穿刺`: 0.88 s telegraph, 22 damage per wave through a shared ledger, four P1 pikes with a readable escape gap; P2 uses 3 + 4 pikes with 0.52 s separation and a fresh 0.74 s second-wave telegraph.
- Selection now uses `Close`, `Mid`, `Far`, and `HighPressure` categories with distance, cooldown, recent-action and recent-category guards. An action cannot repeat immediately, a category cannot occur three times consecutively, and High Pressure requires a normal separator.
- Existing Player Turn (1.05/0.82 s), delayed turn (0.50/0.40 s), Combo Budget (2; every fourth P2 sequence may use 3), back-crossing, direction lock and base-action damage remain unchanged.
- Distinct typed presentation cues are emitted for weapon plant, lock, release, impact, pike waves and the four opening telegraph beats. They are routed through the formal Boss-room controller without changing the approved BGM.

## Automated evidence

Commands use `/Users/vincentz/Downloads/Godot.app/Contents/MacOS/Godot` (4.7.1).

```text
/Users/vincentz/Downloads/Godot.app/Contents/MacOS/Godot --headless --editor --path . --quit
/Users/vincentz/Downloads/Godot.app/Contents/MacOS/Godot --headless --path . --script chapters/chapter_04_drowned_underkeep/tests/characters/test_soul_gaoler_ormund_attack_variety.gd
/Users/vincentz/Downloads/Godot.app/Contents/MacOS/Godot --headless --path . --script chapters/chapter_04_drowned_underkeep/tests/characters/test_soul_gaoler_ormund.gd
/Users/vincentz/Downloads/Godot.app/Contents/MacOS/Godot --headless --path . --script chapters/chapter_04_drowned_underkeep/tests/characters/test_soul_gaoler_ormund_balance.gd
/Users/vincentz/Downloads/Godot.app/Contents/MacOS/Godot --headless --path . --script chapters/chapter_04_drowned_underkeep/tests/characters/test_soul_gaoler_ormund_balance_replays.gd
/Users/vincentz/Downloads/Godot.app/Contents/MacOS/Godot --headless --path . --script chapters/chapter_04_drowned_underkeep/tests/characters/test_chapter_04_main_integration.gd
/Users/vincentz/Downloads/Godot.app/Contents/MacOS/Godot --headless --path . --script chapters/chapter_04_drowned_underkeep/tests/characters/test_chapter_04_q4_boss_flow.gd
/Users/vincentz/Downloads/Godot.app/Contents/MacOS/Godot --headless --path . --script chapters/chapter_04_drowned_underkeep/tests/audio/test_soul_gaoler_music_ch4_m5.gd
/Users/vincentz/Downloads/Godot.app/Contents/MacOS/Godot --path . --audio-driver Dummy --script chapters/chapter_04_drowned_underkeep/tests/scenes/capture_soul_gaoler_ormund_balance_main_qa.gd
```

| Check | Result |
|---|---|
| Editor import/parse | PASS, exit 0 |
| Attack-variety contract | PASS: 30 transitions, 20 Javelin, 20 Verdict, 20 Iron Grave |
| Runtime regression | PASS |
| Boss geometry/balance | PASS |
| Main integration | PASS |
| Formal Q4 route/Boss/death/reward/CH5 flow | PASS |
| 14/28 full-fight replays | PASS: standard 257.4 s; conservative 379.6 s; aggressive 191.8 s |
| Graphical MainBootstrap capture | PASS: 16 images, 1280×720, no red diagnostic |
| Desktop Main handoff | PASS: live `Nocturne Keep (DEBUG)` window at formal Phase-I Boss room; Output/Debugger red errors 0 |

The replay harness preserves production timings, damage policy, poise, Player
Turn and Combo Budget. It is deterministic automation, not a claim of human
combat-feel judgment. Manual acceptance should focus on first-read telegraph
clarity, safe-gap visibility and whether 0.85 s feels like the intended punish.

## QA matrix

| Item | Status | Data / evidence |
|---|---|---|
| Phase 2 no long Idle | PASS | 2.00 s protected transition connects directly to opener |
| Phase 2 Opening AOE | PASS | fixed one-use `judgment_of_the_broken_gaol` |
| Opening Telegraph | PASS | 1.40 s; four typed cue beats |
| Opening Damage 40 | PASS | real Hurtbox resolution, 30/30 |
| Opening avoidable | PASS | two safe gaps and low jumpable ground wave; subjective readability remains manual |
| Opening only once | PASS | 30/30 first use, 0 repeats |
| Opening punish | PASS | Hurtbox opens for 0.85 s recovery |
| Drowned Javelin | PASS | 20/20 |
| Javelin Direction Lock | PASS | final 0.25 s, locked target remains unchanged |
| Javelin Damage 22 | PASS | config and real Hitbox contract |
| Gaoler's Verdict | PASS | 20/20 |
| Slam Direct Damage 28 | PASS | real Hurtbox resolution |
| Shockwave Damage 18 | PASS | shared-ledger secondary volume |
| Slam no duplicate settlement | PASS | second volume rejected after direct hit, 20/20 |
| Iron Grave | PASS | 20/20, P1/P2 |
| Pike Telegraph | PASS | 0.88 s; P2 second wave 0.74 s |
| Pike Damage 22 | PASS | real Hurtbox resolution |
| Pike Shared Attack ID | PASS | overlapping same-wave volume settles once, 20/20 |
| Phase 2 Two Wave | PASS | 3 + 4 with independent re-telegraph and wave ledger |
| Attack Category AI | PASS | distance and history assertions |
| Attack repetition guard | PASS | no immediate action repeat; no third same-category choice |
| Combo Budget retained | PASS | P1/P2 2, periodic P2 3 |
| Player Turn retained | PASS | 1.05/0.82 s |
| Back-crossing retained | PASS | existing Main evidence `05_main_player_turn_back_position.png` |
| No unavoidable combo | PASS | Iron→airborne Javelin and opener→Charge guards; no concurrent pike attack |
| Main/F5 authority | PASS | MainBootstrap debug route resolves formal saved room/Boss |
| Output / Debugger | PASS | final import, test suite and graphical capture contain no red diagnostic |

## Rendered evidence

All images are in this directory. Key evidence:

- `06_main_drowned_javelin_direction_lock.png`
- `07_main_drowned_javelin_release.png`
- `08_main_gaolers_verdict_impact.png`
- `10_main_iron_grave_telegraph.png`
- `11_main_iron_grave_active.png`
- `12_main_phase_transition_protected.png`
- `13_main_phase_02_opening_telegraph.png`
- `14_main_phase_02_opening_active.png`
- `15_main_phase_02_opening_punish.png`
- `16_main_phase_02_iron_grave_two_wave.png`

## Manual F5 acceptance

The saved debug configuration is Chapter IV / `CH4_BOSS_PHASE_01`. Press F5,
skip the already-seen intro when applicable, and use the equipped 14/28 weapon.
Verify the P1 introduction of Javelin, Verdict and Iron Grave; take the Boss
below 275 HP; read and evade the fixed opener; punish only after the cyan wave;
then verify P2's second pike wave, normal Player Turns, back-crossing and reward.
