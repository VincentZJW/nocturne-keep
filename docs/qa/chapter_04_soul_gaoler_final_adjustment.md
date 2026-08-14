# CH4 Boss Final Adjustment QA

Date: 2026-08-14
Status: PASS (automated production-path evidence); subjective audio/combat feel remains a manual acceptance gate.

## Music

| Track | File | Tempo | Meter | Duration | Result |
| --- | --- | ---: | --- | ---: | --- |
| Phase 1 | `soul_gaoler_phase_01_submerged_chains.ogg` | 102 BPM | 6/8 | 150.588229 s | PASS |
| Transition | `soul_gaoler_phase_transition_soul_cage_break.ogg` | 128 BPM | 6/8 | 9.375 s | PASS |
| Phase 2 | `soul_gaoler_phase_02_broken_cage.ogg` | 128 BPM | 6/8 | 150.000 s | PASS |

The score retains the original nine-note Ormund theme and fourth-chapter low-string, low-brass, deep-water and restrained-chain identity. Chapter III contributed only production structure: compound meter, clear ostinato, stronger second-phase subdivision and uninterrupted sectional handoffs. No Pontiff melody, thirteen-bell theme or religious choir material is present. Chains are phrase-ending accents; the normal active-layer target is five to seven.

The formal Main music test held each phase in its saved Boss room for 90 seconds, exercised the real transition once, ten Boss lifecycles, twenty guarded phase switches and a direct Phase 2 Main start. Track identity and deck count remained stable.

## Reward interaction root cause and fix

Formal chain: `project.godot interact/E` → `WeaponPickup._unhandled_input()` → `WeaponPickup.collect()` → `EquipmentManager.acquire_and_equip()` → `WeaponInventory.add_weapon()` → `Chapter04RewardController._on_weapon_collected()` → collected/memory flags and exit unlock.

The Prompt and Area were correct. The reward sequence began while the room transition still owned `Player.InputProfile.LOCKED`, saved that transient profile, then restored `LOCKED` after showing the claimable prompt. Consequently `Player.can_process_gameplay_interaction()` rejected E. The controller now waits for the external room-transition lock to release, captures the resulting gameplay profile and owns only its presentation lock.

Ten separate Godot processes sent a real `InputEventAction("interact")`; all ten collected successfully. Ten additional repeated presses per process did not duplicate ownership. Normal/Dash values remained 16/32, auto-equip succeeded, `ch4_reward_collected` and `ch4_memory_passage_unlocked` were set, and the formal Main route reached `CH5_START`.

## Boss balance

| Parameter | Initial | Pre-adjustment | Final |
| --- | ---: | ---: | ---: |
| Visual scale | 1.00 | 0.60 | 0.63 |
| Measured P1/P2 height ratio to 57 px Player | 3.02/2.98 | 1.81/1.79 | 1.90/1.88 |
| Max HP | 560 | 460 | 500 |
| P1 damage taken | 0.82 | 0.90 | 0.87 |
| P2 damage taken | 0.72 | 0.84 | 0.80 |
| P1/P2 Player Turn | absent/absent | 1.05/0.82 s | 1.05/0.82 s |
| P1/P2 turn time | 0.22/0.16 s with early flip | 0.50/0.40 s delayed | 0.50/0.40 s delayed |

Final effective durability is higher than the pre-adjustment build but lower than the initial 560/.82/.72 build. The 14/28 replay authority produced:

| Run profile | Total | P1 | P2 | Normal | Dash | Result |
| --- | ---: | ---: | ---: | ---: | ---: | --- |
| Standard | 261.1 s | 124.5 s | 136.7 s | 22 | 11 | Victory |
| Conservative A/B | 380.6 s | 171.9 s | 208.6 s | 30 | 7 | Victory |
| Skilled A/B | 180.2 s | 90.3 s | 89.9 s | 30 | 7 | Victory |

The historical initial replay was 315.9 seconds under the same standard model. All current replays preserved back crossings, the 1.32–1.38-second average best punish opportunity, and a longest windup+active no-output interval of 1.26 seconds.

## Commands and results

- `/Users/vincentz/Downloads/Godot.app/Contents/MacOS/Godot --version` — PASS, `4.7.1.stable.official.a13da4feb`.
- `Godot --headless --editor --path . --import --quit` — PASS; three revised OGG resources reimported.
- `test_soul_gaoler_ormund_runtime.gd` — PASS.
- `test_soul_gaoler_ormund_balance.gd` — PASS.
- `test_soul_gaoler_ormund_balance_replays.gd` — PASS, five final 14/28 victories plus one initial comparison.
- `test_soul_lock_twin_keys_reward_sequence.gd` — PASS 10/10 clean-process runs using real E InputMap events.
- `test_soul_gaoler_music_ch4_m5.gd` — PASS, including 90 seconds per phase.
- `test_chapter_04_q4_boss_flow.gd` — PASS through MainBootstrap, Boss, reward, Memory Passage and Chapter V handoff.

## Desktop handoff

Desktop Control launched the actual Main project using the saved `CH4_BOSS_PHASE_01` debug entry. The runtime reported the formal Chapter IV level route, was stopped cleanly after the launch/input smoke check, and the Godot editor was left open on `res://chapters/chapter_04_drowned_underkeep/scenes/rooms/ch4_14_core_of_drowned_gaol.tscn` for manual play acceptance.

No Player, Chapters I–III, Chapter IV ordinary enemy, prior weapon or Soul-Lock 16/32 value was modified.
