# 第二章敌人名册与岗位

> Art status (2026-07-29): the five Chapter II-specific ordinary roles use the Stage 1 formal concepts and 64×64 runtime sets under `assets/enemies/<role>/`. Existing combat values and behavior below were intentionally preserved. See `res://docs/qa/chapter_02_enemy_boss_art_rework/stage_1_report.md` for Main evidence and complete animation counts.

Status: Phase 2 prototypes implemented and Main-testable; formal encounter population not started

Ravenfang remains authoritative at Normal 12 / Dash Attack 24. This document does not alter Player or weapon tuning.

## Roster overview

| Enemy | HP | Normal / Dash hits | Core role | First encounter |
| --- | ---: | ---: | --- | --- |
| Hollow Retainer | 48 | 4 / 2 | fast basic melee | E01 |
| Court Halberdier | 72 | 6 / 3 | mid-range space control | E03 |
| Mourning Armor | 96 | front 11, rear 8 / 4 | heavy frontal pressure | E05 |
| Blood-Candle Acolyte | 60 | 5 / 3 | ranged support | E09 |
| Hanging Stalker | 48 | 4 / 2 | ceiling ambush | E07 |

## Hollow Retainer / 空壳侍从

- Damage: Single Stab 7; Combo Hit 1/2 each 5.
- States: Idle, Patrol, Alert, Approach, SingleWindup, SingleActive, ComboWindup, Combo1, ComboGap, Combo2, Retreat, Recovery, Hurt, Death.
- Light windups may be interrupted. Active frames finish unless Death wins. One combo always enters Recovery; no loop or cross-room pursuit.
- Backstep is a spacing choice, not invulnerability or a teleport.
- Prototype scene/data: `scenes/enemies/hollow_retainer.tscn`, `resources/enemies/hollow_retainer_data.tres`.

## Court Halberdier / 王庭戟卫

- Damage: Halberd Thrust 10; Horizontal Sweep 12; Shaft Push 6.
- States: Idle, Patrol, Alert, Approach, Turn, ThrustWindup/Active/Recovery, SweepWindup/Active/Recovery, Push, Hurt, Death.
- Thrust is long and narrow; Sweep is shorter vertically readable coverage; Push is the only close response. Visual weapon tip is the maximum Hitbox reference.
- Turn is intentionally slower than Player cross-through and creates a rear reward window. Thrust is illegal at contact distance.
- Prototype scene/data: `scenes/enemies/court_halberdier.tscn`, `resources/enemies/court_halberdier_data.tres`.

## Mourning Armor / 哀悼铠甲

- Damage: Overhead Strike 14; Shoulder Bash 9; Heavy Sweep 12.
- Front Normal resolves at 75%: 12 → 9 damage, so 96 HP takes 11 clean frontal Normals. Rear Normal remains 12 (8 hits). Dash Attack remains 24 (4 hits) and deals enhanced Poise damage.
- States: Dormant, Alert, Approach, Turn, Overhead, Bash, Sweep, Stagger, Hurt, Death.
- No shield-HP system. A limited Poise meter causes a short Stagger after repeated impact; ordinary Normal hits cannot permanently reset windup/active/recovery.
- Long windups and recoveries are the primary fairness mechanism. It cannot turn during an active attack.
- Prototype scene/data: `scenes/enemies/mourning_armor.tscn`, `resources/enemies/mourning_armor_data.tres`.

## Blood-Candle Acolyte / 血烛侍祭

- Damage: Blood Candle Projectile 8; Ground Ember Tick 4.
- States: Idle, Alert, Reposition, CastWindup, CastRelease, CastRecovery, BuffChannel, Hurt, Death.
- Projectile is slow, straight and direction-locked at release. Ember uses one-hit/cooldown accounting and cannot damage every physics frame.
- At most one nearby non-Boss ordinary enemy receives `windup_multiplier=0.90`. Buffs do not stack and clear immediately when the Acolyte dies or target leaves the encounter.
- Retreat uses grounded collision and edge checks. Close-range pressure remains weak.
- Prototype scene/data: `scenes/enemies/blood_candle_acolyte.tscn`, `resources/enemies/blood_candle_acolyte_data.tres`.

## Hanging Stalker / 倒悬猎兽

- Damage: Drop Attack 9; Claw Attack 6.
- States: Hang, AlertTelegraph, Drop, GroundRecovery, ClawWindup, ClawActive, Retreat, ReturnToAnchor, Hurt, Death.
- Starts at an exported `CeilingAnchor`. Shadow/debris appears before a direction-locked drop; no mid-air tracking. A miss guarantees Recovery. It may use at most one claw before retreat/return.
- Silhouette is elongated humanoid plus bat membrane/curse-beast anatomy; no insect eyes or fly wings.
- Prototype scene/data: `scenes/enemies/hanging_stalker.tscn`, `resources/enemies/hanging_stalker_data.tres`.

## Shared component contract

All prototypes reuse `HealthComponent`, `HitboxComponent`, `HurtboxComponent`, `EnemyCombatant`, applicable `GroundEnemyBase` behavior, `LootDropComponent` and existing collision/faction names. Each active action receives one unique `attack_id`; the same action cannot damage a target twice. New chapter scripts must not duplicate these components or create a chapter-global enemy manager.

No standalone `AttackContext` exists. Phase 5 may introduce a narrow typed Resource only if the five prototypes need immutable attack metadata beyond existing Hitbox fields; it is not a Stage 1 deliverable.

## Planned quantities

The table below remains a Phase 3 plan. Phase 2 deliberately delivers one showcase instance of each new role and does not activate E01–E15 or populate these quantities.

| Type | Count |
| --- | ---: |
| Hollow Retainer | 11 |
| Court Halberdier | 6 |
| Mourning Armor | 4 |
| Blood-Candle Acolyte | 5 |
| Hanging Stalker | 5 |
| Returning shared enemies | 3 |
| **Total** | **34** |

Returning instances are one Cursed Shield Guard, one Fallen Crossbowman and one Gargoyle Sentinel. Their formal scene paths are `res://shared/scenes/enemies/cursed_shield_guard.tscn`, `res://shared/scenes/enemies/fallen_crossbowman.tscn` and `res://shared/scenes/enemies/gargoyle_sentinel.tscn`; no enemy is copied from or made dependent on the Chapter I directory.
