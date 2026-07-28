# Chapter III Enemy Combat Specification / 第三章敌人战斗规格

Status: **Phase 2A implemented — Bellchain Penitent complete; Phase 2B not started**

## Required project audit ledger

| Audit item | Verified result |
|---|---|
| `run/main_scene` | `res://scenes/bootstrap/main_bootstrap.tscn` |
| Main script | `res://scripts/core/main_bootstrap.gd` |
| Chapter Registry | `res://scripts/systems/chapter/chapter_registry.gd` |
| Debug Chapter Start | `res://scripts/systems/debug_run_config.gd` + `res://scripts/core/chapter_start_router.gd` |
| Chapter III registered | yes, `CHAPTER_03_CHAPEL_OF_THIRTEEN_ECHOES` |
| Current Chapter III scene | `res://chapters/chapter_03_chapel_of_thirteen_echoes/scenes/level/chapter_03_entry_placeholder.tscn` |
| Chapter III profile | `res://chapters/chapter_03_chapel_of_thirteen_echoes/resources/chapter/chapter_03_start_profile.tres`, `debug_ready=true` |
| Chapter III profile target/spawns | entry prototype; `chapter_03_start`, `Chapter03PlayerSpawn`, `CH3_BELLCHAIN_TEST` |
| Boss reward weapon | Crimson Masque Stilettos / 绯幕礼刺 |
| WeaponData | `res://chapters/chapter_02_silent_court/resources/weapons/crimson_masque_stilettos.tres` |
| Chapter III equipment | owns Veilbound/Ravenfang/Crimson Masque and equips `crimson_masque_stilettos` |
| Actual damage | 14 Normal / 28 Dash Attack |
| Player Health | 100 max |
| Player movement | 220 speed; 1400 ground accel; 1700 ground decel; 850 air accel; −420 jump; 1100 gravity; 0.10 coyote; 0.12 jump buffer |
| Jump capability | formal `has_double_jump=false`; current Debug Player `debug_enable_double_jump=true` |
| Dash | 480 speed; 0.18 s; 25 stamina; buffered repeated presses; no hold-auto-repeat |
| Normal Attack time | 4 frames / 20 FPS = 0.20 s visual; 0.32 s minimum start cadence, 3-hit cap, 0.34 s chain-end recovery |
| Dash Attack time | 5 frames / 20 FPS = 0.25 s; 0.15 s movement + 0.10 s recovery |
| Shared enemy root | `res://shared/scripts/enemies/enemy_combatant.gd` |
| Shared ground base | `res://shared/scripts/enemies/ground_enemy_base.gd` |
| Health/Hitbox/Hurtbox | `res://scripts/combat/health_component.gd`, `hitbox_component.gd`, `hurtbox_component.gd` |
| AttackContext | absent; `HitboxComponent` owns runtime id/source/faction/dedup data |
| Poise/Stagger | Chapter III owns `Chapter03PoiseComponent`; Chapter II remains unchanged |
| Loot | `res://scripts/items/loot_drop_component.gd`; one roll on `enemy_died` |
| Encounter | `res://scripts/encounters/encounter_group.gd`; one-shot group, up to 4 attackers by authored limit |
| Edge handling | GroundEnemyBase floor/wall RayCasts plus optional movement bounds |
| Projectile base | absent; Crossbow Bolt and Blood-Candle Projectile are concrete implementations |
| Existing balance | Chapter I approximately 30–50 HP / 5–10 damage; Chapter II 48–96 HP / 4–14 damage |
| Enemy pixels/FPS | saved enemy PNGs are 64×64; idle 4, walk 8, attacks usually 10–12, hurt 12–16.67, death 8–9 FPS |
| Texture filtering | project default `textures/canvas_textures/default_texture_filter=0` (Nearest); enemy Sprite nodes explicitly use `texture_filter=1` (Nearest) |
| Baseline errors | exact Godot 4.7.1 headless import exit 0; no parser/resource/autoload error |

## Current architecture audit

| Concern | Actual project contract | Phase 0 decision |
|---|---|---|
| Mixed enemy API | `res://shared/scripts/enemies/enemy_combatant.gd` | reuse; every enemy must satisfy it |
| Ground lifecycle | `res://shared/scripts/enemies/ground_enemy_base.gd` | reuse for Penitent, Executioner and Scribe where practical |
| Health | `res://scripts/combat/health_component.gd` | reuse unchanged |
| Hitbox | `res://scripts/combat/hitbox_component.gd` | reuse; unique ids, source, faction and per-hitbox target ledger |
| Hurtbox | `res://scripts/combat/hurtbox_component.gd` | reuse; optional typed hit policy |
| Hit policy | `res://scripts/combat/enemy_hit_policy_component.gd` | extend only for Paper Ward/special resistance |
| Loot | `res://scripts/items/loot_drop_component.gd` | reuse existing dynamic probabilities unchanged |
| Encounter | `res://scripts/encounters/encounter_group.gd` | reuse for Trial Hall groups; do not create formal map encounters |
| Edge detection | GroundEnemyBase `WallCheck`, `FloorCheck`, authored movement bounds | reuse for grounded enemies |
| Projectile | no generic base; only concrete Crossbow/Blood-Candle scripts | create a Chapter III-local typed projectile contract when first required |
| AttackContext | no class/resource exists | do not claim or duplicate a global context; Hitbox remains runtime context |
| Poise/Stagger | Chapter II-local counters and hit policy only | create one Chapter III-local composed Poise component in Phase 2A |
| Detection component | no standalone component; Area2D is composed per enemy | retain composition; specialized air/ambush detection stays chapter-local |

`EnemyGroundConfig.max_health` currently exposes an inspector range of 1–100, while Executioner requires 126. Phase 2B must either widen only this editor hint without changing existing values or provide a compatible chapter-local data contract; it must not silently clamp the heavy enemy or duplicate Health truth.

## Planned Chapter III composition

Common future scripts/resources, created only when their owning phase begins:

```text
scripts/enemies/
├── components/chapter_03_poise_component.gd
├── components/chapter_03_attack_ledger.gd
├── chapter_03_attack_data.gd
├── chapter_03_enemy_data.gd
├── chapter_03_ground_enemy_base.gd
├── chapter_03_air_enemy_base.gd
└── <six type-specific controllers>.gd
```

Composition rules:

- common bodies use `HealthComponent`, `HurtboxComponent`, one or more `HitboxComponent`, `LootDropComponent`, `AnimatedSprite2D` and a narrow Poise node;
- state, attack and presentation signals remain typed and `snake_case`;
- the shared base owns lifecycle/attack phase plumbing, but each type script owns only its unique selection/movement/mechanic;
- no gameplay logic enters an Autoload; cross-scene session/profile state remains unchanged;
- Projectiles/fields own their lifetime, world collision and attack ledger and clean themselves with `queue_free()`;
- every saved enemy scene must run in isolation without a parent-specific absolute NodePath.

## Universal attack contract

Every action follows:

```text
Select → lock facing/target point → Windup → Active → Recovery → decision gap
```

Rules:

1. consume one monotonically increasing positive `attack_id` when the Active/sub-attack begins;
2. keep the same id across multiple active frames of one hit; use explicit sub-ids for intended ticks;
3. call `begin_attack(id, damage, facing, self)` only during Active and `end_attack()` on every exit, Hurt, Stagger, Death and reset path;
4. lock direction or target point before Active; no infinite Active tracking;
5. match collision shape, position and lifetime to the Sprite/FX silhouette;
6. body contact is never damage;
7. Death disables Hurtbox/detection/all attacks before emitting the one-shot death count/loot signal;
8. reset returns spawn, HP, Poise, cooldowns, fields/projectiles, target and state to authored defaults;
9. Player invulnerability remains authoritative; no enemy bypasses it;
10. no enemy crosses authored room/floor bounds to pursue.

Because each Hitbox has a local target ledger, multi-projectile volleys and multi-node hazards require a shared Chapter III attack ledger. This is essential for Seraph Volley's “one primary damage per round” and cannot be solved by merely assigning the same id to separate Hitbox nodes.

## Bellchain Penitent state machine

```text
Idle ↔ Patrol → Alert → Approach
Approach → ChainLashWindup → Active → Recovery → Approach
Approach → BellSlamWindup → Active → Recovery → Approach
Approach → ChainPullWindup → Active → Recovery → Approach
any interruptible state → LightHitReaction / Hurt
Poise zero → Stagger → Approach
HP zero → Death
```

- Lash: 0.42/0.12/0.52 s, 11 damage, horizontal front-only lane.
- Slam: 0.62/0.14/0.76 s, 13 damage, ground/close lane with jump counter.
- Pull: 8 damage, 3.0 s cooldown, same-floor precheck, 20–30 px collision-safe pull. The later Player-facing pull API is a scoped dependency and may not alter base movement values.
- The saved Chapter III entry prototype now contains one solo Penitent EncounterGroup and a `CH3_BELLCHAIN_TEST` direct spawn. This is a Phase 2A F5 acceptance encounter, not the later formal map population.

### Phase 2A implementation paths

- scene: `res://chapters/chapter_03_chapel_of_thirteen_echoes/scenes/enemies/bellchain_penitent.tscn`
- AI/config: `scripts/enemies/bellchain_penitent.gd`, `bellchain_penitent_config.gd`
- composed Poise: `scripts/enemies/components/chapter_03_poise_component.gd`
- tuning/loot: `resources/enemies/bellchain_penitent_data.tres`, `bellchain_penitent_loot.tres`
- SpriteFrames: `assets/enemies/bellchain_penitent/animations/bellchain_penitent_sprite_frames.tres`
- independent room: `scenes/tests/bellchain_penitent_test_room.tscn`

Short Chain Pull applies a 100 px/s horizontal velocity only after a confirmed same-floor hit. Player displacement remains under `CharacterBody2D.move_and_slide()`; the enemy never writes Player `global_position` or vertical velocity. The final 20–30 px feel remains `[PLAYTEST_REQUIRED]`.

## Censer Executioner state machine

```text
Idle ↔ Patrol → Alert → HeavyApproach
HeavyApproach → CenserSweepWindup → Active → Recovery
HeavyApproach → OverheadWindup → Active → Recovery
HeavyApproach → SmokeReleaseWindup → Active/field → SmokeRecovery
LightHitReaction only when not protected
Poise zero → Stagger
HP zero → Death
```

- Sweep: 0.66/0.18/0.90 s, 14 damage.
- Overhead: 0.82/0.16/1.05 s, 17 damage, localized impact only.
- Smoke: visible ~2.0 s bounded Area2D; 4 damage per accepted tick, max 3 per Player per release, explicit interval and sub-ids.
- Active resists light interruption; Recovery is always punishable. Slow Turn, wide-floor authored bounds and no narrow stairs/platforms are placement requirements.

## Silent Chorister state machine

```text
Dormant → Hover → Alert → Reposition
Reposition → SilentWaveWindup → projectile → Recovery
Reposition → CrescentHymnWindup → projectile → Recovery
Reposition → HushFieldCast → HushFieldActive → Reposition
too close → Retreat
hit → LightHit / Stagger / Hurt
HP zero → Death + immediate field cleanup
```

- Silent Wave: 10 damage, 0.55 s warning, slow straight and nontracking.
- Crescent Hymn: 12 damage, 0.68 s warning, crescent collision matching a visible path and blocked by thick world geometry.
- Hush Field: 2.5 s, keyed nonstacking ×0.65 stamina-regen modifier; never disables Dash.
- Hover bounds keep it on reachable mid/upper platforms and inside Camera/room limits.

## Stained-Glass Seraph state machine

```text
DormantWindow → Detach → Hover/Track
Track → ShardVolleyWindup → Active → Recovery
Track → DiveWindup (marker + lock) → DiveActive → GroundCrash
GroundCrash → GroundVulnerable (0.70 s) → ReturnToAir
Poise zero in air → StaggerFall → GroundVulnerable
HP zero → GlassDeath
```

- Volley: 9 damage primary result; 3–5 shards with safe fan gaps and one shared target ledger.
- Dive: 13 damage, no post-lock tracking or wall phasing; miss and Poise break expose the ground punish.
- Shatter Burst: 8 damage only if a separately telegraphed living action uses it; Death creates visual fragments only and never surprise damage.
- Flight bounds prevent permanent unreachable height, Camera escape and wall crossing.

## Confessional Wraith state machine

```text
Hidden → DoorTelegraph → Emerge
Emerge → EmergingSlashWindup → Active → Recovery
Emerge → SpectralDashWindup → Active → Recovery
Emerge → ScreamWindup → Active → Recovery
Recovery → RetreatToConfessional → Hidden
visible states → LightHit / Stagger / Hurt
HP zero → Death
```

- Hidden booth door moves/sounds before Emerge; no Active hit occurs during reveal.
- Dash is short, direction-locked and ray-tested against world/room limits.
- Hurtbox may be disabled only while fully Hidden and during the short authored retreat transition. Emerge, Attack, Hurt and Stagger are vulnerable/opaque enough to read.
- Tether radius prevents cross-room/floor pursuit.

## Thirteenth Scribe state machine

```text
Idle ↔ Patrol → Alert → Reposition
Reposition → InkLanceWindup → projectile → Recovery
Reposition → SealWriteWindup → SealDelay → SealActivate → Recovery
Reposition → BindingScriptWindup → Active → Recovery
melee pressure + ward cooldown ready → PaperWard → Reposition
hit → LightHit / Stagger / Hurt
HP zero → Death + seal/ward cleanup
```

- Ink Lance: 10 damage, 0.52 s windup, straight, world-blocked.
- Seal: 13 damage once, target snapshot at write time, 0.75–0.90 s stable warning and max two live seals.
- Binding: 8 damage, keyed 20% slow for ~1.0 s, no jump/Dash lock, no stacking, 3.0 s cooldown.
- Ward: one Normal absorption/reduction, broken by Dash Attack, about 4.0 s cooldown. Hit policy decides before Health; visuals and logic clear together.

## Player-system dependencies to approve in owning phases

- Phase 2A Pull: a typed collision-safe short external-motion request; no direct global-position teleport.
- Phase 2C Hush: keyed stamina-regeneration modifier API with source cleanup; base 35/14 per-second rates remain unchanged outside the field.
- Phase 2F Binding: keyed movement-speed modifier API; base speed/jump/gravity/Dash values remain unchanged.

These interfaces are not implemented in Phase 0. If they cannot be added without affecting unrelated movement feel, the specific control effect must pause for approval rather than use a brittle direct mutation.

## Reset, loot and encounter rules

- Each enemy scene composes the current LootDropComponent and a chapter-owned quantity profile while reusing `default_dynamic_loot_profile.tres`; probabilities are not changed.
- Loot and encounter death counts observe the one-shot `enemy_died` signal only.
- Trial Hall reset replaces/reinitializes the enemy instance and cleans projectiles/fields before reuse.
- Encounter concurrency must respect the later 1 Executioner / 1 Scribe / nonstacking Hush constraints.
- Existing `EncounterGroup` debug counters may require a presentation-only state list extension during Phase 3; it must not become the enemy AI authority.

## Required implementation tests per enemy phase

F6 standalone and Main/F5 must cover: Idle, movement/hover, Alert, approach/reposition, every Windup/Active/Recovery, direction lock, both facings, light hit, Stagger, Hurt, Death, dedup, loot, reset, death count, walls and vertical/platform bounds. Each phase stops after its single enemy and does not wait until Phase 4 to discover composition errors.
