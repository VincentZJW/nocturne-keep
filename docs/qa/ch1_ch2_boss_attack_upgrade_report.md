# CH1 + CH2 Boss Attack Upgrade Report

Date: 2026-08-18
Engine: Godot 4.7.1 Standard
Main authority: `res://scenes/bootstrap/main_bootstrap.tscn`

## QA total result

`PARTIAL` — deterministic gameplay, resource, damage, selector, repetition and
saved-Main checks pass. Crescent weight/readability, Flying Fan boomerang
readability and real-input double-jump timing require the user's graphical
playtest before they can honestly be marked visual PASS.

## Audit and root cause

| Item | Formal implementation | Root cause before change |
| --- | --- | --- |
| CH1 Sword Wave | `fallen_gate_knight.gd::_spawn_gate_severance_wave()`; formal state/attack is `ShockwaveStrike`, presentation name `Gate Severance` | one 42×18 rectangle plus one small flat polygon read as a thin ordinary projectile |
| CH2 Flying Fan | did not exist as a real projectile/state/selector entry | close-range `fan_slash` was the only fan attack, so Far behavior could never choose a flying fan |
| CH2 horizontal puppet skill | attack ID/name `phantom_dancer_sweep`; `duchess_phantom_route.tscn` plus `phantom_dancer.png` | two translucent silhouette lanes had separate damage identities and did not show complete bodies, daggers or a clear jump answer |

Formal Boss scenes remain:

- CH1: `res://chapters/chapter_01_ravenmourn_outskirts/scenes/boss/fallen_gate_knight.tscn`
- CH2: `res://chapters/chapter_02_silent_court/scenes/boss/hollow_duchess.tscn`

No Chapter III/IV Boss, Player, Player weapon, Boss HP/Defense or Boss BGM file
was changed.

## CH1 Sword Wave

- Formal attack/state ID: `ShockwaveStrike`; presentation: `Gate Severance`.
- Original visual: runtime single flat polygon in
  `fallen_gate_knight.gd::_spawn_gate_severance_wave()`; there was no separate
  formal Sprite resource to replace.
- Revised visual: same formal controller now builds a layered wide crescent;
  there is no parallel `_v2`/`_new` resource.
- Visual width: 132 px.
- Visual height: 52 px.
- Crescent curvature: thick root, full center belly and tapered broken tips;
  charcoal core + steel secondary arc + bone-white cutting edge + restrained
  dark-red air tear + stone debris.
- Hitbox: 58×20 px core only.
- Materialize / travel / dissipate: 0.10 / 0.78 / 0.16 s.
- Travel: 330 px, approximately 423 px/s.
- Damage: 8, unchanged.
- Far AI: existing delayed behavior-pressure selector remains authoritative;
  Gate Severance and charge are weighted options, never a guaranteed branch.
- Direction: locked at release; non-homing.
- Release sync: authored `ShockwaveStrike` frame 3/4 callback.
- 20-cycle test: `PASS`; all cycles spawned, armed only after materialization,
  retained layered presentation, damaged once and cleaned up.

Visual score remains pending manual review rather than being self-awarded.

## CH2 Flying Fan

- Formal attack ID: `flying_fan`.
- States: `FlyingFanWindup -> FlyingFanActive -> FlyingFanRecovery`.
- Damage: 16 once.
- Visual: runtime 32×32 black/ivory/silver/crimson gothic bladed fan.
- Motion: target side locks during windup; 0.38 s outbound + 0.38 s return,
  one Hitbox and one attack ID; non-homing.
- Windup / active budget / recovery: 0.72 / 0.82 / 0.72 s.
- Cooldown: 3.2 s.
- Range zones: Close `<128 px`; Mid `128–204 px`; Far `>=205 px`.
- Base weight: 1.00.
- Close / Mid / Far multipliers: 0.30 / 1.20 / 2.20.
- Far-pressure multiplier: ×1.25.
- Immediate-repeat multiplier: ×0.20.
- Seeded Far test: 9 Flying Fan selections in 30 decisions; 18/30 total
  ranged decisions.
- Seeded Close test: 4 Flying Fan selections in 30 decisions.
- Behavior pressure: 10 s Far raised `far_pressure` to 1.00; 10 s Close reduced
  it to 0.00 and raised `close_pressure` to 1.00. Selection is weighted from
  distance, pressure, cooldown and recent history rather than an `if Far then
  fan` command.
- Commitment: changing distance after windup cannot cancel or retarget the fan.

## CH2 Marionette Guillotine

- Formal name: `Marionette Guillotine / 双偶横断`.
- Compatibility attack ID: `phantom_dancer_sweep`; gameplay kind is
  `boss_marionette_guillotine`.
- Phase: Phase 2 only.
- Puppet count: 2, entering from opposite arena edges.
- Puppet design: distinct court-attendant and court-dancer variants with mask,
  head/hair, torso, jointed arms/legs, suspension strings and two visible
  forward silver daggers.
- Telegraph: 1.35 s, with visible puppets, pulsing strings/route and committed
  forward dagger posture.
- Travel time: 0.82 s across the saved arena.
- Damage: 42 maximum per cast.
- Shared settlement: both routes use the same attack ID and shared target
  ledger. Runtime probe settled 42 once; the second puppet was rejected and
  could not produce 84.
- Hitbox: 66×50 px ground-lane volume, excluding strings.
- Double-jump safe margin: 83.36 px from saved Player jump/gravity and authored
  hit-volume top. This exceeds the requested 12–20 px deterministic minimum;
  single jump remains deliberately tight.
- Cooldown: 10 s.
- Attack spacing: at least two other legal attacks.
- Recovery: 1.25 s.
- Boss exclusivity: the Boss remains in its controller pose until both route
  travel and recovery settle; no simultaneous attack state can begin.
- 20-cycle test: `PASS`; every trigger created two routes and completed without
  stacking damage or leaving a route active.

## Automated verification

| Check | Result | Evidence |
| --- | --- | --- |
| Exact 4.7.1 import/parse | PASS | headless editor exited 0 |
| CH1 formal Boss combat | PASS | `FIRST_LEVEL_BOSS_TEST`, including 20 Gate Severance cycles |
| CH2 focused Boss | PASS | 80 base cycles + 20 marionette cycles; selector/damage/clearance assertions |
| CH2 presentation | PASS | state/presentation suite; one known exit-time ObjectDB warning, no gameplay error |
| CH2 full fights | PASS | five production-component fights, approximately 223–226 s |
| CH2 saved Main composition | PASS | Boss, threshold, layers, CP05, HUD, reliquary and mirror path |
| Visual/game-feel acceptance | PARTIAL | user manual test required |

Exact commands are preserved in `docs/development_log.md`; focused output is
also retained for this work session at `/tmp/ch2_boss_focus.log` and
`/tmp/ch2_main_integration.log` (temporary, not repository evidence).

## Main/F5 manual acceptance

The local debug handoff uses:

```gdscript
debug_start_chapter_id = ChapterRegistry.CHAPTER_02_SILENT_COURT
debug_start_spawn_id = &"CH2_BOSS_MUSIC_PHASE_01"
```

Press F5 (or use the game window left open by Codex). In Phase 1, stay beyond
205 px to observe repeated Flying Fan decisions, then close distance during its
windup and confirm the committed throw still completes. At 121 HP enter Phase
2, wait for two other attacks and the 10-second cooldown, then verify two full
dagger marionettes cross from opposite sides. Double jump over the ground lane,
then deliberately take one later cast and confirm one 42-point settlement.

After Chapter II acceptance, switch only the local debug handoff to
`CHAPTER_01_RAVENMOURN_OUTSKIRTS / CH1_BOSS` to judge Gate Severance crescent
weight, left/right direction, release sync, jump clearance and dissipation.
