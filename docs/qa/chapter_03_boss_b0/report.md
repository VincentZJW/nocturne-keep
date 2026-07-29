# Chapter III Boss B0 Audit Report

Date: 2026-07-29

Stage: B0 — audit and design lock
Result: **PASS for B0; Boss combat remains intentionally NOT IMPLEMENTED**

## Project and Main boundary

| Item | Audited result |
|---|---|
| Git branch / commit at preflight | `master` / `2a8f6ffd023fefcefa19d44a7471239e4c48f899` |
| `run/main_scene` | `res://scenes/bootstrap/main_bootstrap.tscn` |
| Chapter III registry target | `res://chapters/chapter_03_chapel_of_thirteen_echoes/scenes/level/chapter_03_route.tscn` |
| Chapter III start profile | `res://chapters/chapter_03_chapel_of_thirteen_echoes/resources/chapter/chapter_03_start_profile.tres` |
| Boss checkpoint room | `res://chapters/chapter_03_chapel_of_thirteen_echoes/scenes/rooms/ch3_boss_checkpoint.tscn` |
| Boss antechamber room | `res://chapters/chapter_03_chapel_of_thirteen_echoes/scenes/rooms/ch3_boss_ante_room.tscn` |
| Boss gate | `Ch3BossAnteRoom/BossGate`, instanced from `scenes/areas/ch3_boss_gate_transition.tscn` |
| Boss sanctum room | `res://chapters/chapter_03_chapel_of_thirteen_echoes/scenes/rooms/ch3_boss_sanctum_room.tscn` |
| Boss environment | `Ch3BossSanctumRoom/BossSanctum`, instanced from `scenes/areas/ch3_boss_sanctum.tscn` |
| Boss integration marker | `Ch3BossSanctumRoom/BossSanctum/BossIntegrationAnchor`, position `(1680, 584)` |
| Post-Boss reward room | `res://chapters/chapter_03_chapel_of_thirteen_echoes/scenes/rooms/ch3_post_boss_room.tscn` |
| Chapter IV boundary | `CH3_UNDERKEEP_DESCENT`; registry entry exists but no loadable Chapter IV PackedScene |

The formal route owns one persistent Player/HUD, one `RoomHost` and one room at a time. The sanctum currently provides typed intro and death-environment hooks only. It contains no fake Boss combatant.

## Current Boss resource audit

| Required object | Result |
|---|---|
| Formal Edran combat scene | Absent |
| Boss controller / state machine | Absent |
| Boss Data Resource | Absent |
| Boss Sprite / SpriteFrames | Absent |
| Boss HealthComponent | Absent |
| Boss Hurtbox / Hitboxes | Absent |
| Boss CollisionShape2D | Absent |
| Boss Poise / defense policy | Absent |
| Boss summons | Absent |
| Authoritative Boss reward | Absent |
| Multiple conflicting Boss definitions | None |
| Inspector overrides on a Boss instance | None, because no Boss instance exists |
| Legacy combat resource still referenced by Main | None |

The only runtime identity is the environment title `BELL CONFESSOR EDRAN / 钟忏司祭·埃德兰`. B0 reclassifies Bell Confessor as Edran's former office. The formal Boss title becomes `The Thirteenth Pontiff, Edran / 第十三响教宗·埃德兰`; updating saved presentation belongs to B6, not B0.

## Combat baseline sources

| Baseline | Source of truth |
|---|---|
| Chapter I HP/shield/damage | `fallen_gate_knight_config.tres` plus typed defaults in `fallen_gate_knight_config.gd` |
| Chapter I defense | `scripts/combat/shield_component.gd` |
| Chapter II HP/Poise/damage/cadence | `hollow_duchess_data.tres` |
| Chapter II Phase 2 defense | `hollow_duchess_hit_policy.gd` |
| Shared health/hit settlement | `health_component.gd`, `hurtbox_component.gd`, `hitbox_component.gd` |
| Player weapon HP damage | three `WeaponData` Resources |
| Chapter III equipped weapon | `chapter_03_start_profile.tres` |
| Chapter III Poise impacts | Chapter III enemy configs: 14 normal / 28 Dash |

### Current final values

- Fallen Gate Knight: 180 body HP, 100 separate front shield HP; 8/10/15/12/8 skill damage; no Poise meter. One attack ID is consumed once, shield overflow does not penetrate the body and rear attacks bypass the shield.
- Hollow Duchess: 220 HP; Phase 2 at 55%; Poise 60/80; Phase 2 incoming multiplier 0.85; attacks span 10–16 damage; chain limit 2.
- Player: 100 max HP; Veilbound 10/20, Ravenfang 12/24, Crimson Masque 14/28; Chapter III formally equips Crimson Masque.

## Existing shared combat model

`HitboxComponent` owns active windows, faction and one-hit-per-attack memory. `HurtboxComponent` rejects disabled, invulnerable, dead and same-faction hits, invokes at most one optional `EnemyHitPolicyComponent`, then forwards the resolved integer once to `HealthComponent`. `HealthComponent` clamps HP and emits death once.

Seraphine demonstrates the correct transparent reduction seam: a single target-owned hit policy applies one phase multiplier. Her Poise is a separate Boss-state value affected by the incoming attack kind. Chapter III normal enemies provide a reusable bounded `Chapter03PoiseComponent`, but its delayed-full-reset behavior is not sufficient by itself to define Edran's stagger protection and summon-interrupt accumulation. B2 should compose or extend the narrow component contract rather than copy all of Seraphine's monolithic state logic.

There is no generic project `Defense` stat. Edran therefore uses one explicit `damage_taken_multiplier` per phase and no additional hidden reduction.

## Existing Encounter, summon and cleanup boundaries

- `EncounterGroup` counts its authored child enemies to determine activation and clear state. Edran summons must not be authored under a normal EncounterGroup and must not participate in that count.
- Existing enemy cleanup uses typed death signals, disables Hurtbox/Hitbox, and either hides or frees presentation. Existing Bosses emit `boss_defeated` once; Seraphine clears her phantom routes before reset/death.
- Chapter III projectiles already use the group `chapter_03_enemy_projectile`; Boss summons need their own `chapter_03_boss_summon` group and a director-owned registry.
- The sanctum's `notify_boss_defeated()` is idempotent and already unlocks the saved post-Boss environment sequence. The future Boss signal should call this hook through the room controller rather than editing environment state directly.

## Locked B0 decisions

| Decision | Locked value |
|---|---|
| HP | 360 |
| Phase threshold | 55% / 198 HP |
| Incoming multiplier | 0.88 Phase 1 / 0.80 Phase 2 |
| Poise | 110 Phase 1 / 145 Phase 2 |
| Stagger | 0.52 s / 0.44 s |
| Protection | 3.0 s / 3.5 s |
| Formal Player damage basis | Crimson Masque 14 normal / 28 Dash |
| Player Poise impact basis | 14 normal / 28 Dash |
| Summon cap | 2 Phase 1 / 3 Phase 2; max one Choir Husk |
| Summon interrupt | 36 Poise during 1.15 s windup |

Full skills, summon values, file plan and hit-count calculations are authoritative in `chapter_03_thirteenth_pontiff_edran_boss_spec.md`.

## Worktree separation

Preflight found unrelated existing modifications in Chapter I/shared Resources, generated SpriteFrames and QA PNGs. In particular, the Chapter I Boss config has been reduced to explicit 180/100 values while the other values fall back to typed defaults matching the committed explicit values. B0 did not change or stage these files. The B0 commit must contain only its two reports, README cross-link and development log.

## Verification scope

B0 verification is limited to:

1. exact Godot 4.7.1 import/parse;
2. default MainBootstrap smoke;
3. current Chapter III R4 Boss-environment flow regression;
4. current Chapter III R5 full-route regression;
5. documentation diff and reference review.

B0 cannot test Boss actions, summons, transition, death, reward or Chapter IV because those systems do not yet exist. Those items remain `PARTIAL`, not PASS.

## B1 approval gate

B1 may begin only after explicit approval. It owns Phase 1 concept art, crown, vestment, crozier, censer and the formal Phase 1 Sprite; it may not implement Phase 1 combat before B2.
