# Chapter III Boss Specification — The Thirteenth Pontiff, Edran

Status: **B0 design and combat baseline approved for implementation**

Scope owner: Chapter III Boss B0–B7
Last updated: 2026-07-29

## 1. Authority and milestone boundary

This document is the authoritative design source for the Chapter III Boss. B0 establishes identity, combat numbers, phase rules, summon rules, file ownership and Main integration boundaries. It does **not** claim that any Boss art, scene, AI, animation, summon, reward or Chapter IV transition exists.

The formal runtime entry remains:

```text
res://scenes/bootstrap/main_bootstrap.tscn
```

The formal Chapter III route remains:

```text
res://chapters/chapter_03_chapel_of_thirteen_echoes/scenes/level/chapter_03_route.tscn
```

B1–B7 must follow `docs/production/chapter_character_workflow.md`, the chapter scene workflow, production checklist, QA standard and render-layer contract. No later phase begins without explicit approval.

## 2. Formal identity and narrative role

| Field | Authoritative value |
|---|---|
| Personal name | Edran / 埃德兰 |
| Former office | Bell Confessor / 钟忏司祭 |
| Phase 1 title | The Thirteenth Pontiff, Edran / 第十三响教宗·埃德兰 |
| Phase 2 title | The Hollow Pontiff, Bell-Bound / 钟缚空教宗·埃德兰 |
| Chapter role | Highest prelate of the Chapel of Thirteen Echoes and keeper of the royal sacrifice register |
| Combat identity | Deliberate mid-range pontiff, ritual space controller and bounded necromantic summoner |

Edran once received royal confessions, then converted confession into sentence. Before the Night of the Hollow Bell he selected thirteen victims, recorded their names, declared their executions to be absolution, ordered the choir to hide their cries and routed their bodies and souls beneath the chapel. His doctrine treats an absolved corpse as property that must continue serving the Bell.

This is an original fictional faith built from the visual language of the hollow bell, thirteen seals, chains, names, royal soul control, blood wax, ossuary bone and the black clapper. It must not reproduce a real pope, papal tiara, cross, Vatican emblem or any living religion's iconography.

## 3. Phase design

### Phase 1 — The Thirteenth Pontiff

The silhouette is upright, ceremonial and severe: a tall original bell-shaped crown with thirteen seal nodes, bone-white face covering over a black veil, broad layered vestments in black/bone/dark red, aged-gold trim and a thirteen-cell absolution stole whose blank fourteenth cell is sealed in black wax. Keys, bone fragments, small bells and chains hang at the waist without creating unreadable pixel noise.

The right hand carries the `Pontifical Hollow-Bell Crozier / 教宗空钟权杖`, measuring 90–105% of the Boss's visual height. Its complete shaft, grip and end cap lead to a hollow bell-ring head, black clapper and thirteen external seals. The left hand controls the `Thurible of Absolution / 赦罪香炉`, a readable multi-link chain and perforated old-bronze censer with grey-white and dark-red smoke.

### Phase 2 — The Hollow Pontiff, Bell-Bound

Phase 2 is a structural transformation, not a recolour. The crown cracks, all thirteen seals fail, the face cavity is empty, the neck becomes a bone clapper and the opened ribs form a bell frame around a small black bell. The spine and arms lengthen; the crozier fuses into the right arm; the censer chain binds the left; the lower vestments tear to expose reliquary bone and soul matter. The remnants of crown, stole, vestment, crozier and censer must keep the pontifical identity readable.

The transformation runs 4.5–6.0 seconds, cancels all active Boss Hitboxes, locks and protects the Player, forces all current summons to dissolve, performs the full authored body change, presents the Phase 2 title and only then restores control.

## 4. Audited combat baseline

### Chapter I — Fallen Gate Knight

| Category | Current effective value |
|---|---:|
| Body HP | 180 |
| Separate shield HP | 100 |
| Phase rule | Shield intact = Phase 1; shield broken = Phase 2 |
| Shield Bash | 8 |
| Sword Slash | 10 |
| Heavy Overhead | 15 |
| Charge Thrust | 12 |
| Shockwave | 8 |
| Poise | No shared Poise meter |
| Defense model | Directional front shield routing; shield overflow is discarded, rear/body hits damage HP |

The worktree currently contains a pre-existing uncommitted serialization simplification in `fallen_gate_knight_config.tres`. It preserves explicit 180/100 while omitted fields resolve to the matching typed defaults in `FallenGateKnightConfig`; the committed HEAD contains the full explicit property list. B0 does not own or stage that difference.

### Chapter II — The Hollow Duchess, Seraphine

| Category | Current value |
|---|---:|
| HP | 220 |
| Phase 2 threshold | 55% / 121 HP |
| Phase 1 Poise | 60 |
| Phase 2 Poise | 80 |
| Phase 1 incoming damage | 1.00× |
| Phase 2 incoming damage | 0.85× |
| Phase 1/2 Stagger | 0.56 / 0.48 s |
| Phase 1/2 Stagger protection | 2.5 / 3.0 s |
| Rapier Thrust | 11 / 13 |
| Fan Slash | 13 / 16 |
| Backstep Riposte | 12 / 14 |
| Side-Step Cut | 12 / 14 |
| Double Lunge | 10 then 14 |
| Phantom route | 12 |
| Final Waltz | 10 |

### Player at Chapter III start

| Item | Normal | Dash Attack |
|---|---:|---:|
| Veilbound Daggers / 暮帷双匕 | 10 | 20 |
| Ravenfang Daggers / 鸦牙双匕 | 12 | 24 |
| Crimson Masque Stilettos / 绯幕礼刺 | 14 | 28 |

The Chapter III Start Profile requires all three weapons and formally equips `crimson_masque_stilettos`. Player max HP is 100. Chapter III enemy combat currently uses 14 Poise damage for a normal attack and 28 for Dash Attack; Edran will adopt these same Chapter III impact values in his Boss Data Resource so the values are explicit at the target rather than inferred from weapon HP damage.

## 5. Final Edran combat values

| Parameter | Phase 1 | Phase 2 |
|---|---:|---:|
| Total HP | 360 shared | 360 shared |
| Transition threshold | 55% remaining | starts at `current_hp <= 198` |
| Incoming damage multiplier | 0.88 | 0.80 |
| Damage reduction equivalent | 12% | 20% |
| Max Poise | 110 | 145 |
| Stagger duration | 0.52 s | 0.44 s |
| Stagger protection | 3.0 s | 3.5 s |
| Attack gap | 0.88–1.08 s | 0.74–0.94 s |
| Max chain | 2 | 2 |
| Mandatory recovery | 1.08–1.28 s | 0.96–1.16 s |
| Turn duration | 0.68–0.82 s | 0.50–0.66 s |

Only one `EnemyHitPolicyComponent`-derived Boss policy may apply the phase multiplier. There is no separate armor subtraction, hidden Defense field or second multiplier. Damage resolves once as:

```text
resolved_damage = max(1, round(player_weapon_damage * phase_multiplier))
```

With the formal 14/28 Chapter III weapon this yields 12/25 damage in Phase 1 and 11/22 in Phase 2. Expected full-fight bounds from full HP are approximately 32 normal attacks or 16 Dash Attacks when using only one attack type and crossing the threshold normally. Exact mixed-input counts vary because the hit that crosses 198 HP is resolved with the Phase 1 multiplier.

Poise is independent of HP reduction. Phase 1 breaks after 8 normal impacts or 4 Dash impacts; Phase 2 breaks after 11 normal impacts or 6 Dash impacts. Protection prevents permanent J-pressure but does not create permanent super armour.

These values deliberately exceed Chapter II without multiplying several opaque defenses: Edran has 1.64× Seraphine's raw HP, one transparent phase multiplier, higher Poise and summons. Difficulty must come from readable target priority and space control, not untelegraphed speed.

## 6. Phase 1 skill table

| Skill | Damage | Timing | Range/selection | Recovery and fairness contract |
|---|---:|---|---|---|
| Pontifical Sweep / 教宗权杖横扫 | 15 | 0.58 windup / 0.14 active / 0.72 recovery | Near–mid; forward arc only | Facing locks before active; rear remains safe; jump/backstep/cross-up valid |
| Hollow Crozier Thrust / 空钟权杖突刺 | 14 | 0.48 windup / 0.16 direction lock / 0.11 active / 0.64 recovery | Mid-range straight line | No active tracking; world collision blocks reach; clear whiff punish |
| Censer Procession / 香炉巡礼 | 13 | 0.64 / 0.16 / 0.80 | Low forward arc; 2.8–3.5 s cooldown | Jump answer; one hit per attack ID; chain length stays authored |
| Litany of Burial / 葬仪祷文 | 12 | 0.80–1.00 seal delay | 2–3 floor seals, max 3 active | Every seal has a boundary and single settlement; at least one safe route remains |
| Raise the Absolved / 唤起赦免者 | — | 1.15 windup / 0.72 recovery | Fixed valid niches only; 8.5–10 s cooldown | Interruptible at 36 accumulated Poise; never consecutive; disabled at summon cap |
| Thirteenfold Sentence / 十三重判词 | 14 | Three separately telegraphed waves | Low-frequency arena pattern | 5.5–7.0 s cooldown; no thirteen simultaneous Hitboxes; cannot follow summon immediately |

## 7. Phase 2 skill table

| Skill | Damage | Timing | Range/selection | Recovery and fairness contract |
|---|---:|---|---|---|
| Bell-Bound Cleave / 钟缚横断 | 18 | 0.52 windup / 0.15 active / 0.68 recovery | Forward mid-range | No active tracking; rear safe zone remains |
| Hollow Toll / 空钟震鸣 | 16 | At least 0.72 windup; one wave | Single ground sound wave | Jump or pre-position answer; one settlement; not full-screen guaranteed |
| Censer Chain Judgment / 香炉链刑 | 14 then 17 | Low sweep then announced ground impact | Two authored stages | Separate child attack IDs; second landing marker fixed before impact; no retarget after stage one |
| Scripture Burial / 祷文葬仪 | 14 | 0.85 activation delay | Max 2 large floor zones | Short duration; cannot combine with Hollow Toll into full-arena denial |
| Procession of the Unburied / 未葬者行列 | — | Uses bounded summon sequence | 2 Penitents or Penitent + Husk | 6.8–8.0 s cooldown; max 3 active; never produces all three in one cast |
| The Fourteenth Seat / 第十四席 | 20 | 0.95–1.15 telegraph | Unlocks below 25% HP; marked local burst | At least 6.5 s cooldown; cannot overlap summon completion or another major area lock |

Attack choice must consider Player distance/height, current summons, active danger zones, previous skill, cooldown, phase and HP. The selector must enforce no consecutive summons, no consecutive large area locks, no consecutive Hollow Toll, zero summon weight at cap, max two active danger zones and mandatory recovery after two attacks.

## 8. Summon contract

### Global rules

- Summons are Boss-owned temporary actors in group `chapter_03_boss_summon`; they are not Chapter III normal enemies.
- They drop no coin, health or item; do not count toward Encounter clearance; are not persisted; and emit death/cleanup once.
- Phase transition and Boss death force every living summon into `ForcedDissolve` and clear its Hitboxes before visual cleanup.
- Each summon has a 14–18 second lifetime. Expiry forces dissolve rather than accumulating corpses.
- Spawn candidates are fixed ossuary niches, floor crypt cracks, thirteen-confession positions or altar-side graves. The director rejects overlaps, walls, invalid floor and any candidate closer than the configured safe distance to Player or Boss.
- Telegraph is 0.85–1.10 seconds. Hurtbox enables only after the body is visibly risen; attack Hitboxes remain off until a later attack state.

### Phase limits

| Rule | Phase 1 | Phase 2 |
|---|---:|---:|
| Maximum concurrent summons | 2 | 3 |
| Maximum Choir Husks | 1 | 1 |
| Cooldown | 8.5–10.0 s | 6.8–8.0 s |
| One cast produces | 1 Penitent, or Penitent + Husk | 2 Penitents, or Penitent + Husk |
| Third actor | Not allowed | Rare later Penitent only; never all three from one cast |

### Interrupt contract

`Raise the Absolved` has a 1.15 second windup. Accumulating 36 Poise damage during that windup cancels the cast, creates no summon, clears all pending telegraphs, applies 0.65 seconds of ritual imbalance and starts a partial summon cooldown. With Chapter III Poise impacts the threshold is reachable by 3 normal attacks, 2 Dash Attacks, or one of each. The Boss is never invulnerable during the ritual, but receives limited cast stability through this explicit threshold rather than hidden immunity.

### Ossuary Penitent / 圣骨忏者

| Parameter | Value |
|---|---:|
| HP | 42 |
| Poise | 20 |
| Corpse Claw | 8 |
| Falling Lunge | 9 |
| Expected Crimson Masque hits | 3 normal / 2 Dash |

States: `Dormant`, `SummonTelegraph`, `Rise`, `Idle`, `Approach`, `ClawWindup`, `ClawActive`, `ClawRecovery`, `LungeWindup`, `LungeActive`, `LungeRecovery`, `Hurt`, `Stagger`, `Death`, `ForcedDissolve`.

### Choir Husk / 唱诗尸壳

| Parameter | Value |
|---|---:|
| HP | 34 |
| Poise | 16 |
| Dead Hymn Projectile | 7 |
| Projectile | Slow, non-homing, world-blocked, single-hit |
| Expected Crimson Masque hits | 3 normal / 2 Dash |

States: `Dormant`, `SummonTelegraph`, `Rise`, `Idle`, `Reposition`, `CastWindup`, `CastActive`, `CastRecovery`, `Hurt`, `Stagger`, `Death`, `ForcedDissolve`.

## 9. Planned file ownership

No file below is created in B0; these paths are the mandatory destination plan for the owning later stage.

### Concept and pixel art

```text
assets/boss/thirteenth_pontiff_edran/
├── concept_art/
│   ├── edran_phase_01_concept.png
│   ├── edran_phase_02_concept.png
│   ├── edran_phase_comparison.png
│   ├── edran_silhouette_sheet.png
│   ├── edran_crown_design.png
│   ├── edran_vestment_design.png
│   ├── pontifical_hollow_bell_crozier_design.png
│   ├── thurible_of_absolution_design.png
│   └── edran_attack_pose_sheet.png
├── sprites/
│   ├── phase_01/<animation_name>/*.png
│   ├── phase_transition/<animation_name>/*.png
│   └── phase_02/<animation_name>/*.png
├── effects/
│   ├── seals/
│   ├── bell_toll/
│   ├── censer/
│   ├── summoning/
│   └── death/
└── animations/
    ├── edran_phase_01_sprite_frames.tres
    ├── edran_phase_transition_sprite_frames.tres
    └── edran_phase_02_sprite_frames.tres

assets/boss_summons/
├── ossuary_penitent/{concept_art,sprites,effects,animations}/
└── choir_husk/{concept_art,sprites,effects,animations}/
```

All formal images are chapter-local, transparent, nearest-neighbour and source-controlled. Concept images may use larger boards; gameplay frames must use one declared canvas/foot anchor per actor.

### Runtime scenes, scripts and Resources

```text
scenes/boss/
├── thirteenth_pontiff_edran.tscn
├── summons/ossuary_penitent.tscn
└── summons/choir_husk.tscn

scenes/tests/thirteenth_pontiff_edran_test_room.tscn

scripts/boss/
├── thirteenth_pontiff_edran.gd
├── thirteenth_pontiff_edran_config.gd
├── thirteenth_pontiff_hit_policy.gd
├── thirteenth_pontiff_summon_director.gd
├── thirteenth_pontiff_boss_hud.gd
└── summons/{ossuary_penitent.gd,choir_husk.gd,boss_summon_config.gd}

resources/boss/
├── thirteenth_pontiff_edran_data.tres
└── summons/{ossuary_penitent_data.tres,choir_husk_data.tres}

tests/boss/
├── test_thirteenth_pontiff_config.gd
├── test_thirteenth_pontiff_combat.gd
├── test_thirteenth_pontiff_summons.gd
├── test_thirteenth_pontiff_main_integration.gd
└── test_thirteenth_pontiff_full_fights.gd
```

Paths above are relative to `res://chapters/chapter_03_chapel_of_thirteen_echoes/`.

## 10. Legacy-resource handling

The audit found no old Edran combat scene, Boss script, Data Resource, SpriteFrames, Hitbox, Hurtbox or state machine, so there is no legacy combat asset to delete in B0.

- `Bell Confessor / 钟忏司祭` remains Edran's historical office and is not a second character.
- The environment-only title in `ch3_boss_sanctum.tscn` is the only saved runtime presentation using the former office as the main title. B6 must update it to the formal Phase 1 title while preserving the historical identity in dialogue/lore.
- `BossIntegrationAnchor` is retained and becomes the authoritative spawn/integration point; no duplicate Boss is placed elsewhere.
- The retired `chapter_03_entry_placeholder.tscn` remains outside `ChapterRegistry` and is not a valid Main integration target. It must never receive the formal Boss.
- Existing Boss-room environment assets and lifecycle hooks are reused. B7 performs a full resource-reference scan; only genuinely superseded generated art may then be archived under `reference/` or deleted with explicit QA evidence.

## 11. Main/F5 implementation and test plan

1. Keep `run/main_scene` on `main_bootstrap.tscn` and Chapter III registered to `chapter_03_route.tscn`.
2. Instantiate exactly one Edran scene under `Ch3BossSanctumRoom/BossSanctum/BossIntegrationAnchor` or an explicit sibling container anchored to that marker; effective actor z must follow the render-layer contract.
3. Bind `intro_environment_finished` to combat activation, Boss `boss_defeated` to `notify_boss_defeated()`, and Player respawn to complete Boss/summon reset without duplicating signals.
4. Use the existing Debug Chapter Start with chapter `CHAPTER_03_CHAPEL_OF_THIRTEEN_ECHOES` and spawn `CH3_BOSS` for fast F5 iteration. F6 remains supplemental only.
5. Verify Phase 1, summon interrupt, summon limits, transition cleanup, Phase 2, under-25% skill, death cleanup, environment collapse, reward interface and post-Boss exit in Main.
6. Run deterministic tests for threshold rounding, one-hit-per-attack-ID, single multiplier application, Poise protection, summon cap/lifetime/no-loot/no-Encounter-count and death/reset idempotency.
7. Run long simulations and manual fights with normal-only, Dash-heavy and mixed inputs; record duration, damage counts, stagger cadence and unavoidable-overlap failures.
8. B7 must capture all required evidence from F5/Main, scan for legacy references, run exact Godot 4.7.1 import/parse, verify Output/Debugger and retain honest `PARTIAL` status for any absent reward or Chapter IV implementation until B6 owns it.

## 12. Stage gates

- **B0 complete:** audit, final numbers, identity, skills, summons, file plan and Main test plan only.
- **B1 complete:** Phase 1 concept/equipment art and 114-frame formal 96×96 Phase 1 Sprite set.
- **B2 complete:** typed Phase 1 Boss/Data/policy/HUD scene, five attack families, Poise/stagger, saved Boss-sanctum/Main integration and F5 evidence. The 198 HP boundary intentionally locks in `transition_pending`; B4 still owns the actual transition.
- **B3 complete:** original concept boards plus 108 formal 64×64 runtime frames for Ossuary Penitent and Choir Husk; typed summon scenes/AI/Data; safe telegraph/rise; bounded lifetime; two-actor/one-of-each Phase 1 caps; no loot/Encounter/persistence; interruptible 1.15-second Boss ritual; transition/death forced cleanup; saved Boss-room/MainBootstrap integration and graphical evidence.
- **B4:** full structural Phase Transition.
- **B5:** Phase 2 concept/Sprite/animation/combat and F5 test.
- **B6:** intro, dialogue, death, authoritative reward and Chapter IV hand-off.
- **B7:** full regression, summon stress, forced QA and final report.

Current approved execution stops after B3. B4 and later remain unimplemented and require a new approval.
