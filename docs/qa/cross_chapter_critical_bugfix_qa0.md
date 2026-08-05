# Cross-Chapter Critical Bugfix QA0 Audit

Date: 2026-08-05
Engine: Godot 4.7.1 Standard
Scope: read-only investigation for the eleven supplied screenshots; no gameplay, scene, art, collision, AI, or balance change is included in QA0.

## QA0 result

| Audit item | Status | Evidence-based conclusion |
|---|---|---|
| Formal F5 entry and Chapter 01-04 routing | PASS | `project.godot` runs `res://scenes/bootstrap/main_bootstrap.tscn`; the chapter registry resolves the four formal level scenes listed below. |
| Eleven-image identity mapping | PARTIAL | Every subject/resource family is identified. Screenshots 2 and 3 are cropped too tightly to distinguish one of several instances that share the same formal scene; this report lists every possible formal instance instead of guessing. |
| Chapter 01 boss greatsword requirement | FAIL | The sword is embedded in every animation frame and its diagonal resting blade is perceptually too short beside the boss. |
| Chapter 02 Hanging Stalker repeat loop | FAIL | `ReturnToAnchor -> Hang` leaves the same target assigned; subsequent detection calls exit early and cannot start a new telegraph/drop cycle. |
| Chapter 03 visible enemy killability | FAIL | The Confessional Wraith can remain visibly rendered while its Hurtbox is disabled in `Hidden`, especially without a valid target. |
| Chapter 03 single reward presentation | FAIL | Inventory ownership has one collectible, but the boss presentation weapon remains visible while the post-boss reliquary also contains the real pickup. |
| Chapter 04 ordinary/elite enemy combat lifecycle | FAIL | Shared `LIGHT_HIT` and `GUARD_BREAK` reactions never transition out when their timers expire, freezing affected enemies. |
| Chapter 04 boss in formal Main route | FAIL | Ormund exists in a character trial only; the formal boss room contains `FutureEncounterSpawns/BossSlot`, not a boss instance. |
| Chapter 04 shield proportion/visual contract | FAIL | The runtime overlay is a compact heraldic shield that obscures the body and does not match the tall prison-door concept. |
| Chapter 04 Chainbound Convict concept fidelity | FAIL | Runtime art lacks the concept sheet's muscular prisoner, iron mask, timber yoke, weighted chains, and readable legs. |
| Chapter 04 Broken Chainway exit readability | PARTIAL | A valid east-edge transition to Area 04 exists, but it is an invisible automatic trigger with no prompt or readable doorway. Main lifecycle needs live QA. |
| Cross-chapter actor top bounds | FAIL | Camera top limits exist in later chapters, but no unified gameplay ceiling/actor clamp exists across Chapter 01-04. |
| Parser/import and opening MainBootstrap smoke check | PASS | Exact Godot 4.7.1 commands exited successfully without a red parser/resource error; this does not constitute chapter gameplay acceptance. |

Overall product acceptance: **FAIL**. QA0 audit coverage: **PASS**.

## Formal F5 route

| Chapter | Formal level scene |
|---|---|
| Chapter 01 | `res://chapters/chapter_01_ravenmourn_outskirts/scenes/level/ravenmourn_outskirts.tscn` |
| Chapter 02 | `res://chapters/chapter_02_silent_court/scenes/level/silent_court.tscn` |
| Chapter 03 | `res://chapters/chapter_03_chapel_of_thirteen_echoes/scenes/level/chapter_03_route.tscn` |
| Chapter 04 | `res://chapters/chapter_04_drowned_underkeep/scenes/level/drowned_underkeep.tscn` |

Authority for final acceptance is the formal MainBootstrap/F5 route. Standalone rooms and structural tests are supporting evidence only.

## Screenshot-to-runtime map

| Image | Identity | Formal scene/instance evidence | Status |
|---|---|---|---|
| 1 | Fallen Gate Knight / 堕落守门骑士 | `ravenmourn_outskirts.tscn` -> `World/CastleEntranceArea/FallenGateKnight`; packed scene `scenes/boss/fallen_gate_knight.tscn` | PASS |
| 2 | Hanging Stalker / 倒悬猎手 | Packed scene `chapter_02_silent_court/scenes/enemies/hanging_stalker.tscn`; formal markers `E08_CeilingSpawn_01`, `E10_CeilingSpawn_01`, `E11_CeilingSpawn_03`, `E14_CeilingSpawn_03`. Crop does not reveal which one. | PARTIAL |
| 3 | Confessional Wraith / 告解幽魂 | Packed scene `chapter_03_chapel_of_thirteen_echoes/scenes/enemies/confessional_wraith.tscn`; used in six formal room manifests listed below. Crop does not identify the room. | PARTIAL |
| 4-5 | Duplicate Thirteenfold Absolution presentation | Boss room `RewardSequence/Weapon` plus post-boss `PostBossReliquary/ThirteenfoldAbsolutionPickup` | PASS |
| 6 | Mire Harpooner + Mirefin Raider | `ch4_01_flooded_intake.tscn`, Encounter Group 2 | PASS |
| 7 | Drowned Gaoler + Sunken Shield Penitent + Sewer Maw | `ch4_02_rusted_cellblock.tscn`, Encounter Group 2 | PASS |
| 8 | Chainbound Convict / 锁缚囚徒 | `ch4_02_rusted_cellblock.tscn`, Encounter Group 1 | PASS |
| 9-10 | Mirefin Raider + Bog Toad | `ch4_03_broken_chainway.tscn`, Encounter Group 2 | PASS |
| 11 | External visual reference | User-supplied sword/character style reference; not a repository runtime asset | PASS |

## Chapter 01: Fallen Gate Knight

### Runtime files and nodes

- Boss scene: `res://chapters/chapter_01_ravenmourn_outskirts/scenes/boss/fallen_gate_knight.tscn`
- Script: `res://chapters/chapter_01_ravenmourn_outskirts/scripts/boss/fallen_gate_knight.gd`
- Data: `res://chapters/chapter_01_ravenmourn_outskirts/resources/boss/fallen_gate_knight_config.tres`
- SpriteFrames: `res://chapters/chapter_01_ravenmourn_outskirts/resources/boss/fallen_gate_knight_sprite_frames.tres`
- Formal node: `World/CastleEntranceArea/FallenGateKnight`
- Visual node: `FallenGateKnight/VisualRoot/AnimatedSprite2D`
- Generation source: `res://chapters/chapter_01_ravenmourn_outskirts/scripts/tools/generate_fallen_gate_knight_art_v3.gd`

### Current weapon proportion

The authored body anchor is `(66, 7)` in Phase 1 or `(61, 7)` in Phase 2. Feet end at `y + 84`, giving an authored standing figure height of about 84-91 pixels inside the 128x96 source cell. The default resting pose uses grip `(x + 10, y + 32)` and tip `(x + 46, y + 87)`: grip-to-tip length is about 65.8 pixels. The drawing function adds a 16-pixel hilt/pommel behind the grip, so total authored weapon length is about 82 pixels, approximately 90% of the standing authored figure.

That nominal ratio does not satisfy the screenshot-level visual requirement. In the diagonal Phase 1 stance, the shield/arm occludes much of the hilt and blade base, leaving a visibly exposed blade closer to roughly 70-77% of the figure height. The weapon is baked into each frame rather than attached as a separate Sprite, so every relevant frame must be regenerated and visually rechecked; scaling one node cannot solve it.

Phase 2 is structurally authored with a second hand (`second_grip`) and a redrawn exposed left arm. Status: **PARTIAL** because two-hand intent exists in generation code, but formal F5 visual consistency has not been accepted and the weapon still reads too short.

Current gameplay values remain untouched: body HP 180; shield HP 100. QA1 must not change these unless separately approved.

## Chapter 02: Hanging Stalker

### Runtime files and nodes

- Scene: `res://chapters/chapter_02_silent_court/scenes/enemies/hanging_stalker.tscn`
- Script: `res://chapters/chapter_02_silent_court/scripts/enemies/hanging_stalker.gd`
- Data: `res://chapters/chapter_02_silent_court/resources/enemies/hanging_stalker_data.tres`
- Runtime nodes: `VisualRoot/AnimatedSprite2D`, `HealthComponent`, `Hurtbox`, `FacingRoot/DropHitbox`, `FacingRoot/ClawHitbox`, `DetectionArea`, `TelegraphShadow`

States are Hang, AlertTelegraph, Drop, GroundRecovery, ClawWindup, ClawActive, Retreat, ReturnToAnchor, Hurt, and Death.

Confirmed root cause: `_process_return()` reaches the anchor, enters Hang, and plays the hanging animation, but retains the same Player target. A later detection callback calls `set_target()` with that same object; the method returns early because `target == new_target`, so no new telegraph/drop cycle begins. The enemy is therefore capable of one cycle and can remain hanging indefinitely. Status: **FAIL**.

Current data: HP 48, drop damage 9, claw damage 6, detection range 230. No values were changed.

## Chapter 03: Confessional Wraith and boss reward

### Confessional Wraith identity and damage contract

- Canonical type: `ConfessionalWraith`
- Display identity: Confessional Wraith / 告解幽魂
- Scene: `res://chapters/chapter_03_chapel_of_thirteen_echoes/scenes/enemies/confessional_wraith.tscn`
- Script: `res://chapters/chapter_03_chapel_of_thirteen_echoes/scripts/enemies/chapter_03_specialist_enemy.gd`
- Data: `res://chapters/chapter_03_chapel_of_thirteen_echoes/resources/enemies/confessional_wraith_data.tres`
- SpriteFrames: `res://chapters/chapter_03_chapel_of_thirteen_echoes/assets/enemies/confessional_wraith/animations/confessional_wraith_sprite_frames.tres`
- Formal room references: `ch3_nave_entry.tscn`, `ch3_main_nave_rear.tscn`, `ch3_confessionals.tscn`, `ch3_archive_reliquary.tscn`, `ch3_blood_candle_chapel.tscn`, `ch3_pre_boss_combat.tscn`

Current HP is 82 and poise is 38. There is no defense component or damage multiplier that intentionally nullifies player damage. The body collider is 26x50 at y=5. Hurtbox is collision layer 16/mask 32 with a 30x52 collider at y=5, which matches the Player attack layer/mask contract.

Confirmed root cause candidate with direct code evidence: `starts_hidden=true`. `_enter_hidden()` disables the Hurtbox but the `hidden` animation remains visibly rendered. `_process_hidden()` only restores the Hurtbox after the hidden timer expires **and** a valid target exists. This permits a visible, apparently attackable enemy to remain invulnerable. Status: **FAIL**.

### Reward duplication

- Boss room: `res://chapters/chapter_03_chapel_of_thirteen_echoes/scenes/rooms/ch3_boss_sanctum_room.tscn`
- Presentation node: `RewardSequence/Weapon`
- Presentation controller: `res://chapters/chapter_03_chapel_of_thirteen_echoes/scripts/transitions/chapter_03_reward_sequence_controller.gd`
- Post-boss room: `res://chapters/chapter_03_chapel_of_thirteen_echoes/scenes/rooms/ch3_post_boss_room.tscn`
- Reliquary node: `PostBossReliquary/ThirteenfoldAbsolutionPickup`
- Reliquary controller: `res://chapters/chapter_03_chapel_of_thirteen_echoes/scripts/areas/chapter_03_post_boss_reliquary.gd`
- Pickup scene: `res://chapters/chapter_03_chapel_of_thirteen_echoes/scenes/weapons/thirteenfold_absolution_pickup.tscn`

There is exactly one real collectible pickup. However, the boss reward sequence makes its presentation `Weapon` visible and never hides it, while the post-boss reliquary holds the real pickup. Inventory uniqueness tests therefore pass even though the world presents two persistent reward representations. Status: **FAIL**.

## Chapter 04: enemies and boss

### Shared collision contract

All eight formal Chapter 04 enemy scenes use:

- Body: layer 4, mask 3
- Hurtbox: layer 16, mask 32
- Primary/Secondary enemy hitboxes: layer 64, mask 8
- Detection: mask 2

The Player uses body layer 2/mask 5, Hurtbox layer 8/mask 320, and attack hitboxes layer 32/mask 16. The layer/mask contract is therefore structurally compatible. The failure is not explained by a simple global mask inversion.

Common runtime node pattern:

`RoomHost/<ActiveRoom>/EncounterSpawner/<EncounterID>/Enemies/<SpawnRecordID>`

with children `VisualRoot/AnimatedSprite2D`, `HealthComponent`, `PoiseComponent`, `Hurtbox`, `FacingRoot/PrimaryHitbox`, `FacingRoot/SecondaryHitbox`, and `DetectionArea`.

### Enemy inventory

| Enemy | Canonical resource | HP / Poise | Damage | Detection / attack range | Audit status |
|---|---|---:|---:|---:|---|
| Drowned Gaoler | `drowned_gaoler_data.tres` | 104 / 44 | 12 | 225 / 56 | FAIL |
| Chainbound Convict | `chainbound_convict_data.tres` | 152 / 92 | 16 | 220 / 72 | FAIL |
| Mire Harpooner | `mire_harpooner_data.tres` | 96 / 38 | 13 | 290 / 235 | FAIL |
| Sunken Shield Penitent | `sunken_shield_penitent_data.tres` | 132 / 70 | 14 | 215 / 50 | FAIL |
| Mirefin Raider | `mirefin_raider_data.tres` | 116 / 50 | 13 | 235 / configured melee | FAIL |
| Bog Toad | `bog_toad_data.tres` | 142 / 76 | 17 | 245 / 105 | FAIL |
| Sewer Maw | `sewer_maw_data.tres` | 82 / 26 | 10 | 175 / 46 | FAIL |
| Underkeep Executioner | `underkeep_executioner_data.tres` | 244 / 126 | 20 | 250 / 88 | FAIL |

All share `res://chapters/chapter_04_drowned_underkeep/scripts/enemies/chapter_04_enemy.gd`.

Confirmed shared reaction defect: `_process_reaction()` processes `LIGHT_HIT`, `STAGGER`, and `GUARD_BREAK`, but when the timer reaches zero it transitions out only when the state is `STAGGER`. `LIGHT_HIT` and `GUARD_BREAK` can therefore persist forever after the first qualifying hit. This explains enemies that appear active initially but stop moving, attacking, or reacting after combat begins. Existing runtime tests only check structure and exported fields; they do not execute damage-to-recovery or detection-to-attack cycles. Status: **FAIL**.

### Soul Gaoler Ormund

- Boss scene: `res://chapters/chapter_04_drowned_underkeep/scenes/bosses/soul_gaoler_ormund.tscn`
- Script: `res://chapters/chapter_04_drowned_underkeep/scripts/bosses/soul_gaoler_ormund.gd`
- Data: `res://chapters/chapter_04_drowned_underkeep/resources/bosses/soul_gaoler_ormund_data.tres`
- Runtime nodes: `VisualRoot/AnimatedSprite2D`, `HealthComponent`, `PoiseComponent`, `DamagePolicy`, `Hurtbox`, `FacingRoot/MeleeHitbox`, `FacingRoot/AreaHitbox`, `DetectionArea`
- Current HP: 560

The formal room `ch4_14_core_of_drowned_gaol.tscn` contains `FutureEncounterSpawns/BossSlot`, not an Ormund instance. The actual Ormund scene is referenced by `chapter_04_character_trial.tscn` only. Debug spawn IDs for Phase 1/2 resolve to Area 14 EntryWest but do not instantiate the boss. Consequently, standalone character-trial tests can pass while the formal Main route has no boss. Status: **FAIL**.

### Sunken Shield Penitent proportion

- Scene: `res://chapters/chapter_04_drowned_underkeep/scenes/enemies/sunken_shield_penitent.tscn`
- Body visual: `VisualRoot/AnimatedSprite2D`, 128x128 at `(0, -38)`
- Shield visual: `VisualRoot/ShieldVisual`, 128x128 at `(-18, -38)`
- Shield states: `shield/intact.png`, cracked, critical, and broken variants
- Concept: `assets/enemies/sunken_shield_penitent/concept_art/sunken_shield_penitent_concept_sheet.png`

The runtime shield is a separate full-size overlay and reads as a broad heraldic plate that hides the body. The concept calls for a tall, prison-door-like shield with leg/body visibility and a narrower silhouette. Repository QA text claiming a 95% match conflicts with direct screenshot evidence and must be re-scored after replacement. Status: **FAIL**.

### Chainbound Convict fidelity

- Scene: `res://chapters/chapter_04_drowned_underkeep/scenes/enemies/chainbound_convict.tscn`
- Active art root: `res://chapters/chapter_04_drowned_underkeep/assets/enemies/chainbound_convict/`
- Concept: `concept_art/chainbound_convict_concept_sheet.png`

The current runtime silhouette is dominated by a broad brown torso/yoke, tiny legs, and thin loop chains. It does not reproduce the concept's muscular prisoner, iron mask, timber yoke, weighted chain/ball, and readable limb structure. The previous internal 95.2 score is not accepted by this evidence audit. Status: **FAIL**.

## Broken Chainway east exit

- Room: `res://chapters/chapter_04_drowned_underkeep/scenes/rooms/ch4_03_broken_chainway.tscn`
- Node: `Transitions/ExitEast`
- Script: `res://chapters/chapter_04_drowned_underkeep/scripts/level/chapter_04_room_exit.gd`
- Position/shape: `(2024, 550)`, 72x160 trigger in a 2048-pixel-wide room
- Target: `CH4_AREA_04`, spawn `EntryWest`

The transition resource and target are valid, and the structural transition test can activate it. The player-facing problem is that the trigger sits at the extreme edge with no doorway, prompt, or interaction cue. It is automatic only, so it looks like a dead end. Whether body entry is also failing in the formal graphical lifecycle must be tested in QA5. Status: **PARTIAL**.

## Cross-chapter top bounds and flyers

No shared `WorldBounds2D`, `RoomBounds2D`, flight rectangle, or actor top clamp exists across Chapter 01-04.

| Chapter | Current top-limit behavior | Flying/ceiling roster | Status |
|---|---|---|---|
| 01 | Local ceiling geometry only; no global actor top bound | Gargoyle Sentinel (4 formal instances) | FAIL |
| 02 | Camera limits per floor; `WorldBounds` has side walls only | Hanging Stalker (4), shared Gargoyle Sentinel (1) | FAIL |
| 03 | Transition controller sets Camera top=0; no actor ceiling | Silent Chorister, Stained-Glass Seraph; Choir Husk summon included in boundary audit | FAIL |
| 04 | Transition controller limits Camera only; no actor ceiling | No ordinary config currently sets `airborne=true`; boss/projectile vertical motion still requires bound policy | FAIL |

The Player resolves a ceiling collision only when a real collider is present. Gargoyles return to a home Y, Hanging Stalkers return to their anchor, and Chapter 03 flyers bob around a hover origin, but none uses a chapter-wide upper gameplay boundary. Camera clipping is not gameplay containment.

## Planned modification ownership by approved future stage

No file below was modified in QA0.

### QA1 — Chapter 01 boss weapon

- Fallen Gate Knight generator, active frame assets, SpriteFrames, and visual QA captures
- Boss scene/config hitbox review only if the longer visual would otherwise disagree with gameplay reach
- Formal Chapter 01 boss encounter Main evidence

### QA2 — Chapter 02 Hanging Stalker

- `hanging_stalker.gd`, focused state-cycle tests, and formal Silent Court Main capture
- Data/scene only if a state contract requires a serialized setting

### QA3 — Chapter 03 enemy and reward

- `chapter_03_specialist_enemy.gd`, Confessional Wraith hidden animation/visibility contract, and damage/recovery tests
- `chapter_03_reward_sequence_controller.gd` and/or its scene presentation lifecycle
- Post-boss reliquary ownership tests and formal route captures

### QA4 — Chapter 04 combat and art

- Shared `chapter_04_enemy.gd` reaction exit logic and full attack/hurt/death cycle tests for all eight enemies
- Shield Penitent visual assets, scene offsets, all damage-state visuals, and hitbox/visual alignment evidence
- Chainbound Convict active art/animations plus re-scored concept comparison
- Formal Ormund boss-room instantiation, activation, HUD/reward/transition integration, and Main captures

### QA5 — Broken Chainway exit

- `ch4_03_broken_chainway.tscn`, exit script or room presentation assets, readable prompt/doorway, and actual Main traversal test

### QA6 — cross-chapter gameplay bounds

- A small reusable typed bound component/resource or equivalent explicit per-level contract
- Player, every listed flyer/ceiling enemy, relevant projectiles/summons, all four formal level roots, and boundary regression tests
- Camera limits remain presentation; they do not replace gameplay bounds

### QA7 — full regression

- Formal MainBootstrap route, chapter debug starts, combat loops, transitions, HUD, reward uniqueness, top bounds, Output/Debugger, screenshot inventory, and only defect-driven follow-up edits

## Per-stage F5/Main acceptance plan

| Stage | Required formal Main test |
|---|---|
| QA1 | Debug-start Chapter 01 boss; capture idle, Phase 1 slash/thrust/heavy, shielded overlap, Phase 2 two-hand attacks, hurt/death; compare sword/player/boss proportions. |
| QA2 | Start each Hanging Stalker encounter; observe at least three complete Hang -> telegraph -> drop/claw -> retreat -> return -> Hang cycles, then kill and reload. |
| QA3 | Hit Confessional Wraith before/after reveal from both directions; verify every visible attackable frame has an enabled Hurtbox. Defeat Edran, traverse post-boss route, and confirm exactly one world reward representation at a time. |
| QA4 | For every ordinary/elite archetype: acquire, attack, take normal hit, take stagger/guard-break where supported, recover, attack again, die. Enter Area 14 through Main and complete Ormund encounter. |
| QA5 | Enter Broken Chainway from both directions, see a readable exit cue, traverse to Area 04 and return without edge pushing or invisible dead-end behavior. |
| QA6 | Jump/dash against the upper player limit in every chapter; force every flyer/ceiling archetype to chase/return near the top edge and verify neither player nor enemies leave the gameplay volume. |
| QA7 | Start at opening MainBootstrap, run representative Chapter 01-04 routes plus every targeted debug start; inspect formal HUD/camera/collision/reward/boss transitions and collect final evidence. |

## Commands actually run in QA0

```text
/Users/vincentz/Downloads/Godot.app/Contents/MacOS/Godot --version
=> 4.7.1.stable.official

/Users/vincentz/Downloads/Godot.app/Contents/MacOS/Godot --headless --path . --editor --quit
=> exit 0; no red parser/resource error

/Users/vincentz/Downloads/Godot.app/Contents/MacOS/Godot --headless --path . --script res://chapters/chapter_04_drowned_underkeep/tests/test_chapter_04_enemy_runtime.gd
=> PASS, but structural only; no hit-to-recovery cycle

/Users/vincentz/Downloads/Godot.app/Contents/MacOS/Godot --headless --path . --script res://chapters/chapter_04_drowned_underkeep/tests/test_chapter_04_main_integration.gd
=> PASS, but the test explicitly accepts Ormund in CharacterTrial rather than formal Area 14

/Users/vincentz/Downloads/Godot.app/Contents/MacOS/Godot --headless --path . --script res://chapters/chapter_04_drowned_underkeep/tests/test_chapter_04_transitions_s5.gd
=> PASS, 32 structural/automatic transitions; no player-facing prompt/readability assertion

/Users/vincentz/Downloads/Godot.app/Contents/MacOS/Godot --headless --path . --script res://chapters/chapter_03_chapel_of_thirteen_echoes/tests/test_thirteenfold_absolution_w4_reward.gd
=> PASS, collectible uniqueness=1; does not reject two persistent visual representations

/Users/vincentz/Downloads/Godot.app/Contents/MacOS/Godot --headless --path . --quit-after 180
=> exit 0; MainBootstrap opening smoke check only
```

## QA0 stop condition

QA0 is complete. The findings above require gameplay and asset changes, but none is authorized within this audit-only stage. No commit is warranted for a read-only audit. Proceed only after explicit approval of QA1.
