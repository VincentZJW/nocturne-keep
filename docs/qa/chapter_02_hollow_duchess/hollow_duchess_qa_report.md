# Hollow Duchess QA Report

Date: 2026-07-27
Engine: Godot 4.7.1 Standard (`4.7.1.stable.official.a13da4feb`)
F5 authority: `res://scenes/bootstrap/main_bootstrap.tscn`
Debug route: `CHAPTER_02_SILENT_COURT / CH2_BOSS`

## Runtime results

- Original asset generation: `HOLLOW_DUCHESS_ASSET_GENERATOR: PASS animations=20`.
- SpriteFrames build: `HOLLOW_DUCHESS_SPRITE_FRAMES: PASS animations=20`.
- Import/parse: exit 0; no parser, resource, UID or import error.
- Boss contract: `PASS attacks=7 iterations=70 phase=2 poise=60`.
- Main composition: `PASS boss=1 doors=2 cp05=1 hud=1`.
- Five live-component fight simulations: 222, 223, 224, 225 and 226 seconds; 16 accepted Player hits each; 294 Boss attacks total; all death sequences completed.
- Full recursive regression: 46/46 `test_*.gd` scripts passed.
- Existing asset validators: 5/5 passed.
- Formal F5 smoke: `MAIN BOOTSTRAP | FORMAL NEW GAME | res://scenes/cinematics/opening_cinematic.tscn`.
- Graphical Bootstrap capture: `HOLLOW_DUCHESS_MAIN_QA: PASS captures=10`.

The five fights are deterministic automated combat simulations through the real `HitboxComponent -> HurtboxComponent -> HealthComponent` path. They validate cadence, Poise, phase and victory completion; subjective fairness and input feel still require human playtesting.

## Ten-cycle attack audit

Each named attack completed ten start/active/finish cycles. State transitions were observed at 60 Hz; duration tolerance is one physics tick. The shared Hitbox target ledger rejected repeated settlement for one attack ID.

| Attack | Observed timing contract | Saved local damage reach | Result / available evade |
| --- | --- | --- | --- |
| Rapier Thrust | 0.46 / 0.11 / 0.60 s | front X `+16..+78`, 12 px high | 10/10; jump, cross or retreat |
| Fan Slash | 0.54 / 0.14 / 0.72 s | two rotated `44×12` narrow blades around front X `+7..+51` | 10/10; jump above or leave close range |
| Backstep Riposte | 0.24 + 0.22 + 0.30 / 0.10 / 0.72 s | front X `+16..+74`, 12 px high | 10/10; wait through retreat, then cross/dash |
| Side-Step Cut | 0.38 + 0.12 + 0.32 / 0.11 / 0.66 s | front X `+8..+54`, 18 px high | 10/10; read lateral step, jump or reverse |
| Double Waltz Lunge | 0.48 / 0.10 + 0.27 + 0.11 / 0.80 s | hit 1 to `+74`; hit 2 to `+88` | 10/10; avoid both direction-locked thrusts |
| Phantom Dancer Sweep | 0.75 / 0.72 / 0.82 s | two 1040 px fixed route lanes, non-solid | 10/10; leave the line or move between lanes |
| Final Waltz Crossing | 0.90 + 3×(0.68 + 0.43) / 1.15 s | each body pass `42×52`, fresh attack ID | 10/10; cross between telegraphed passes |

## Main screenshots

| Evidence | SHA-256 |
| --- | --- |
| `01_intro_main.png` | `1a78644c8a368edf792561baa83c4f1aa613de70b1f8f3e0c1286116f43ec194` |
| `02_rapier_thrust_main.png` | `d2ca7aa352b5ed5a095e9258f161001ab272a2bbef092b529d8746afcdce80f7` |
| `03_fan_slash_main.png` | `2a6121cc9d8a909bff93897ad160629c10813c50613bd44b40757f78fe269c66` |
| `04_backstep_riposte_main.png` | `59dd0798acde9df31015f796ca28283423afb6e7a334910811db77e1ca42a1fd` |
| `05_side_step_cut_main.png` | `5a4433027187b5326ddbbeb4e974d38e8333f549bda3c78b35448ab0dc03e1de` |
| `06_phase_transition_main.png` | `cce759cba15fea39e10ceeaab86f1f097b51d329ff64245a4c9ebd07161a286b` |
| `07_double_waltz_main.png` | `80174f51213c34b6175485ea09c674e7c8153276ed78a77b1464dd339ac8a550` |
| `08_phantom_dance_main.png` | `1df7ef9d60c5ea2342a8ce65ebf846c7f1b369e3d893b0aba0d66e8b5b97a6ad` |
| `09_final_waltz_main.png` | `1ffa354fbb5428287974a3319faa1eb2302b27b5912676c6724611940b1795c4` |
| `10_death_main.png` | `a8afc54fe8d194d5b89e5e7db2828775fc34a842c8929cecac1e639f0cfa4b54` |

All images are 1280×720 RGBA and were captured after MainBootstrap selected the saved Silent Court Main scene. They are not editor previews or standalone test-room captures.

## Manual acceptance checklist

1. Set the Chapter II debug spawn to `CH2_BOSS`, press F5 and walk right into the Ballroom.
2. Confirm the intro locks Player input, rear/exit doors close, camera remains in the Ballroom and the Boss HUD appears only when combat begins.
3. Dodge all four Phase 1 tells, attack after Recovery, and verify repeated J cannot permanently hold Seraphine in Hurt.
4. Cross 121 HP and confirm no healing, correct Phase 2 HUD/tint, fixed phantom lanes and visible Final Waltz route warning.
5. Die once and confirm the existing Player ghost sequence returns to CP05 with a clean Boss retry.
6. Defeat Seraphine and confirm both final lines, no Boss ghost, HUD fade and opened exit placeholder.
