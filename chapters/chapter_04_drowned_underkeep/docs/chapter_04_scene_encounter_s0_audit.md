# Chapter IV Scene & Encounter S0 Audit / 第四章场景与遭遇 S0 审计

- Chapter: `Chapter IV: Drowned Underkeep / 第四章：淹没地牢`
- Milestone: `CH4-S0`
- Status: **AUDIT AND PRODUCTION PLAN COMPLETE / 正式场景生产尚未开始**
- Audit baseline: 2026-08-03, `master@96e59c89e0e96f6c086591048d8f721e370f6cef` plus preserved pre-existing worktree changes
- Fixed encounter seed: `40446`

This document records the real project state and locks the future Chapter IV scene/Encounter production plan. It does not claim that the 17-room route, environment assets, spawn manifests, water presentation, transitions or Boss arena have already been built.

## 1. Formal Main and chapter entry audit

| Item | Current authority |
|---|---|
| `run/main_scene` | `res://scenes/bootstrap/main_bootstrap.tscn` |
| Chapter registry ID | `ChapterRegistry.CHAPTER_04_DROWNED_UNDERKEEP` |
| Registered Chapter IV scene | `res://chapters/chapter_04_drowned_underkeep/scenes/level/drowned_underkeep.tscn` |
| Chapter IV start profile | `res://chapters/chapter_04_drowned_underkeep/resources/chapter/chapter_04_start_profile.tres` |
| Default spawn | `CH4_START` |
| Chapter III handoff scene | `res://chapters/chapter_03_chapel_of_thirteen_echoes/scenes/rooms/ch3_underkeep_room.tscn` |
| Chapter III handoff area | `res://chapters/chapter_03_chapel_of_thirteen_echoes/scenes/areas/ch3_underkeep_descent.tscn` (`ChapterFourExitArea`, `DrownedUnderkeepGate`) |
| Handoff controller | `res://chapters/chapter_03_chapel_of_thirteen_echoes/scripts/level/chapter_03_underkeep_room.gd` |
| Handoff contract | `SceneTransitionManager.transition_to_chapter(CHAPTER_04_DROWNED_UNDERKEEP, CH4_START, 0.45, 0.45)` |

The Chapter III → IV route is therefore real and registered. Chapter V is only a planned registry destination; no formal Chapter V scene currently exists. Chapter IV's eventual final exit must remain a sealed/transition endpoint until Chapter V production exists.

## 2. Current Chapter IV directory and scene inventory

### 2.1 Existing playable scenes

| Scene | Current purpose | S0 finding |
|---|---|---|
| `scenes/level/drowned_underkeep.tscn` | Formal registered Chapter IV level | A threshold shell with one long floor, shared Player/HUD runtime, debug markers and a CharacterTrial instance; not the 17-area chapter |
| `scenes/trials/chapter_04_character_trial.tscn` | Character/AI test gallery | Six hand-authored EncounterGroups across a long flat gallery; useful as a regression tool, not a production route |
| `scenes/enemies/*.tscn` | Eight ordinary/elite enemy scenes | Formal, independently instantiable runtime enemies |
| `scenes/bosses/soul_gaoler_ormund.tscn` | Two-phase Chapter IV Boss | Formal runtime Boss |
| `scenes/projectiles/chapter_04_enemy_projectile.tscn` | Swept enemy projectile | Shared by Chapter IV ranged actions |

The formal level currently instances these trial groups:

1. `GaolerIntake`: Drowned Gaoler + Sewer Maw;
2. `HarpoonGallery`: Mire Harpooner;
3. `PenitentFloodway`: Sunken Shield Penitent + Mirefin Raider;
4. `ConvictCistern`: Chainbound Convict + Bog Toad;
5. `ExecutionBlock`: Underkeep Executioner;
6. `OrmundBossEncounter`: Soul Gaoler Ormund.

This gives one sample of every role, but does not satisfy room pacing, safe spaces, ranged platform placement, fixed 46-enemy distribution or chapter traversal.

### 2.2 Existing environment assets

Only two formal Chapter IV environment PNGs currently exist:

| Asset | Purpose | Limitation |
|---|---|---|
| `assets/environment/threshold/drowned_underkeep_threshold.png` | Chapter-entry threshold backdrop | Entry-only composition |
| `assets/environment/character_trial/drowned_cellblock_gallery.png` | Character trial gallery backdrop | Test-gallery composition, not a modular room kit |

There are no Chapter IV-owned formal wall/floor kits, flooded-cell modules, prison bars, catwalks, cistern pieces, floodgates, Boss architecture, Chapter V memory transition pieces, props, doors or water/chain/soul FX. Existing enemy/Boss concepts, sprites and effects remain approved character assets and are outside this scene-art milestone.

## 3. Existing Enemy and Encounter architecture

### 3.1 Reusable systems

- `EnemyCombatant` and `Chapter04Enemy` own targeting, AI states, attacks, Poise, Hurt/Death and debug contracts.
- `HealthComponent`, `HitboxComponent` and `HurtboxComponent` own health, faction filtering, attack IDs and one-hit-per-attack routing.
- `EncounterGroup` owns a one-shot `ActivationArea`, initially disables enemy processing/AI, activates saved child enemies when the Player enters and emits `encounter_cleared`.
- `ChapterGameplayRuntime` supplies the formal Player, HUD, respawn and shared chapter services.
- Ground enemies use wall and floor probes and do not jump between platforms. This is a placement constraint, not an AI defect to hide with unreachable spawns.

### 3.2 Gaps that future scene production must fill

- No typed Chapter IV room definition, SpawnPoint tag data, saved spawn manifest or Encounter manifest exists.
- No seed-driven development generator exists.
- `EncounterGroup.simultaneous_attack_limit` is stored and displayed, but this script does not itself schedule attackers; room/Encounter orchestration must not claim a hard attack-token limit until enforced and tested.
- No room-scoped activation/unload/reset controller prevents cross-room target tracking.
- Current encounters are direct child scene instances, not persisted generated data.
- Current camera limits are one flat `0..9280` strip, not room-aware bounds.

The production architecture will compose around the existing combat systems rather than copy eight enemy controllers or invent a second Hitbox/Hurtbox stack.

## 4. Player traversal envelope measured from the real build

Authoritative tuning:

| Parameter | Current value |
|---|---:|
| Move speed | 220 px/s |
| Ground acceleration / deceleration | 1400 / 1700 px/s² |
| Air acceleration | 850 px/s² |
| Jump velocity | -420 px/s |
| Gravity | 1100 px/s² |
| Coyote / jump buffer | 0.10 / 0.12 s |
| Dash speed / motion duration | 480 px/s / 0.18 s |
| Nominal dash segment | 86.4 px |
| Dash stamina cost | 25 of 100 |
| Airborne stamina regeneration | 40% of ground regeneration after the shared delay |

Exact Godot 4.7.1 measurement on this audit baseline:

| Metric | Measured result |
|---|---:|
| Standing single-jump rise | 83.77 px |
| Standing double-jump rise | 167.10 px |
| Single-jump horizontal range | 153.59 px |
| Double-jump horizontal range | 281.92 px |
| Single jump + air dash range | 192.92 px |
| Double jump + air dash range | 324.92 px |
| Four chained air dashes | 344.00 px horizontal; 360.33 px total until landing |
| Player foot offset | 28 px |
| Platform centre-to-safe-edge allowance | 98 px |
| Minimum safe landing width | 48 px |

Production safety rules:

- Mandatory route vertical steps target ≤62 px (about 75% of measured single-jump rise); larger total elevations use intermediate landings.
- Mandatory horizontal gaps target ≤145 px without Dash and ≤185 px where Dash is explicitly taught/expected.
- Optional reward routes may use double jump or chained Dash, but every ranged-enemy platform remains reachable by a stable route.
- Combat platforms target at least 96 px width; heavy units and Harpooner firing positions target 128–160 px.
- Shallow water remains presentation and enemy-context terrain. Player movement, jump, attack and Dash physics are not changed in this milestone.

## 5. Locked 17-area route

| # | Area | Function | Ordinary enemies | Encounter intent |
|---:|---|---|---:|---|
| 00 | Drowned Threshold / 淹没门槛 | Chapter III handoff, title reveal | 0 | Transition and visual premise |
| 01 | Flooded Intake / 淹水入口 | First Chapter IV combat tutorial | 4 | Basic melee + readable Harpooner + water raider |
| 02 | Rusted Cellblock / 锈蚀牢区 | Vertical cellblock combat | 5 | Split floor/elevated pressure, first shield |
| 03 | Broken Chainway / 断链通道 | Traversal-combat bridge | 4 | Broken platforms, ranged lane, first Toad |
| 04 | Harpoon Watch Gallery / 鱼叉瞭望廊 | Ranged-platform mastery | 5 | Two reachable Harpooners at staggered heights |
| 05 | Cistern of the Changed / 异变蓄水池 | Creature ecology arena | 5 | Water creatures + Convict + Maw ambush |
| 06 | Dry Gaoler's Cell / 干燥狱卒牢房 | Safe room and narrative rest | 0 | No aggro, checkpoint/record space |
| 07 | Leech Sluice / 水蛭泄渠 | Ambush corridor | 4 | Two telegraphed Maws, no ranged crossfire |
| 08 | Gaoler's Workshop / 狱卒工坊 | Elite introduction | 5 | One Executioner plus controlled support |
| 09 | Soul-Cage Registry / 魂笼登记处 | Mixed vertical records hall | 4 | Ranged archive platform and deliberate flanks |
| 10 | Floodgate Engine Hall / 闸门机轮厅 | Dynamic machinery combat | 5 | Moving waterwheel/gates; Toad pair without ranged clutter |
| 11 | Final Lock Approach / 终锁进路 | Final ordinary-enemy exam | 5 | One of each core prison role + Executioner |
| 12 | Last Gaol Checkpoint / 最终牢狱检查点 | Pre-Boss recovery | 0 | No pursuit across boundary |
| 13 | Soul Lock Antechamber / 锁魂前室 | Boss staging and narrative | 0 | Boss gate, no ordinary enemy |
| 14 | Core of Drowned Gaol / 淹没魂狱核心 | Ormund Boss arena | 0 ordinary | Boss only; never part of the 46 count |
| 15 | Broken Soul Reservoir / 破裂魂池 | Post-Boss reward and decompression | 0 | No enemy, reward/aftermath |
| 16 | Hall of Drowned Memories / 溺忆回廊 | Chapter IV → V transition | 0 | Sealed formal transition until Chapter V exists |

There are **six enemy-free support spaces** outside combat/Boss gameplay: 00, 06, 12, 13, 15 and 16. The Boss arena (14) is a seventh zone with zero ordinary enemies, but is counted separately because Ormund is its combat occupant. This resolves the apparent “six safe/transition/Boss areas” wording without hiding the Boss-only room.

Reasons for the six support spaces:

1. Threshold: protects the Chapter III handoff and establishes visual grammar before combat.
2. Dry Cell: breaks the five-room opening pressure and provides narrative/route comprehension.
3. Last Checkpoint: prevents attrition from invalidating Boss learning.
4. Antechamber: preserves silhouette, music and gate staging without stray AI.
5. Reservoir: guarantees reward/dialogue readability after Ormund dies.
6. Memory Hall: prevents enemies from following into a future chapter transition.

## 6. Fixed ordinary-enemy roster and room distribution

Totals are locked and must be validated from the persisted manifest, not inferred from visible editor nodes.

| Combat room | Gaoler | Convict | Harpooner | Penitent | Raider | Toad | Maw | Executioner | Total |
|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|
| Flooded Intake | 2 | 0 | 1 | 0 | 1 | 0 | 0 | 0 | 4 |
| Rusted Cellblock | 2 | 1 | 0 | 1 | 0 | 0 | 1 | 0 | 5 |
| Broken Chainway | 1 | 0 | 1 | 0 | 1 | 1 | 0 | 0 | 4 |
| Harpoon Watch Gallery | 1 | 0 | 2 | 1 | 1 | 0 | 0 | 0 | 5 |
| Cistern of the Changed | 0 | 1 | 0 | 0 | 2 | 1 | 1 | 0 | 5 |
| Leech Sluice | 1 | 0 | 0 | 0 | 1 | 0 | 2 | 0 | 4 |
| Gaoler's Workshop | 1 | 1 | 1 | 1 | 0 | 0 | 0 | 1 | 5 |
| Soul-Cage Registry | 1 | 1 | 1 | 1 | 0 | 0 | 0 | 0 | 4 |
| Floodgate Engine Hall | 0 | 1 | 0 | 1 | 1 | 2 | 0 | 0 | 5 |
| Final Lock Approach | 1 | 1 | 1 | 1 | 0 | 0 | 0 | 1 | 5 |
| **Chapter total** | **10** | **6** | **7** | **6** | **7** | **4** | **4** | **2** | **46** |

Every combat room is split into two sequential EncounterGroups, producing 20 groups total. Planned group sizes are 2+2 for four-enemy rooms and 2+3 for five-enemy rooms. Normal simultaneous activation is 2–4; the project maximum of 5 remains an exceptional cap, not a default composition. Room boundaries deactivate or release targets before the next room can activate, preventing cross-room trains.

## 7. Harpooner platform plan

All seven Mire Harpooners use `platform_ranged` spawn tags and have a documented collision-safe access route.

| ID | Room / platform | Elevation from room floor | Top width | Player access | LOS/fairness rule |
|---|---|---:|---:|---|---|
| H01 | Flooded Intake maintenance catwalk | 56 px | 128 px | Single jump from intake curb | First ranged lesson; unobstructed retreat lane |
| H02 | Broken Chainway chain-bridge watch | 72 px total | 144 px | 40 px pier then 32 px upper step | Cannot shoot through bridge masonry |
| H03 | Harpoon Gallery west cell ledge | 60 px | 144 px | Single jump from central plinth | Activates before H04, not simultaneously from offscreen |
| H04 | Harpoon Gallery east hoist gallery | 124 px total | 160 px | 56 px lower ledge + 62 px upper step | Double jump is optional shortcut; normal staged route exists |
| H05 | Gaoler's Workshop sluice platform | 80 px total | 160 px | 42 px crate step + 38 px deck | Executioner cannot occupy the same platform |
| H06 | Soul-Cage Registry archive catwalk | 72 px total | 144 px | 36 px cabinet + 36 px catwalk | Shelves block rear shots; front approach remains visible |
| H07 | Final Lock keeper gallery | 112 px total | 160 px | 54 px lock plinth + 58 px gallery | Final exam; no other ranged unit in the room |

No Harpooner platform requires an impossible jump, hidden one-way collision or out-of-bounds Air Dash. Harpooners cannot walk off because their existing FloorCheck owns edge safety.

## 8. Elevated-enemy quota

The fixed layout plans **13 elevated initial spawns** (28.3% of the 46), meeting the required 12–14 target:

- 7 Mire Harpooners: H01–H07 above;
- 2 Drowned Gaolers: Rusted Cellblock upper patrol and Soul-Cage Registry upper archive aisle;
- 2 Sunken Shield Penitents: Harpoon Gallery wide mid dais and Gaoler's Workshop execution staging deck;
- 1 Underkeep Executioner: Gaoler's Workshop broad execution platform;
- 1 Chainbound Convict: Floodgate Engine Hall maintenance deck.

Heavy elevated platforms are at least 160 px wide, have wall/floor probe margins and do not require the AI to jump. Other planned ecological starts are 11 shallow-water creature positions (7 Raiders + 4 Toads) and 4 telegraphed Maw ambush positions; categories are deliberately not stacked on unreachable geometry.

## 9. Fixed-seed authoring and runtime persistence plan

The generator is a development tool only. Runtime must never reroll encounters.

Planned typed data:

- `Chapter04SpawnPointData`: ID, room ID, semantic tag (`ground`, `shallow_water`, `platform_ranged`, `platform_heavy`, `ambush_drain`, `boss`), saved position, facing, platform bounds and access-route metadata.
- `Chapter04EnemySpawnData`: enemy ID/PackedScene, SpawnPoint ID, Encounter ID, facing and optional presentation flags.
- `Chapter04EncounterData`: Encounter ID, room ID, activation bounds, saved spawn array and active-attacker cap.
- `Chapter04RoomDefinition`: room type, PackedScene, camera bounds, transitions, checkpoints and saved Encounter manifest.

Development generation flow:

1. Load the 17-room candidate SpawnPoints and fixed quotas.
2. Set `RandomNumberGenerator.seed = 40446`.
3. Filter candidates by enemy role, platform size, exclusion zones, water/ground compatibility and proven Player access route.
4. Allocate the exact room matrix above and exactly 20 EncounterGroups.
5. Reject layouts with unreachable Harpooners, more than one heavy core per group, overlapping body shapes, blocked door zones or quota mismatch.
6. Save deterministic `.tres` room/Encounter manifests and a human-readable audit table.
7. Build or update formal saved scenes from those manifests.

Runtime flow:

1. Room controller loads the saved manifest; no RNG call occurs.
2. Spawn controller instances saved PackedScenes at saved SpawnPoints with AI disabled.
3. Existing `EncounterGroup` activation enables only the current group.
4. Clearing/transitioning the room releases target references and cannot awaken another room early.
5. Reload uses the same manifest and positions. A new random layout requires an explicit editor/tool regeneration followed by review and source control.

## 10. New environment asset production list

Future assets must be original, nearest-neighbour Chapter IV-owned PNGs and cannot be replaced by permanent Polygon/Line2D greybox art.

```text
assets/
  environment/
    walls/              drowned masonry, cell arches, drainage brick, collapsed vaults
    floors/             wet flagstone, grated drains, execution slabs, broken walkways
    flooded_cells/      cell alcoves, waterline trims, barred recesses, submerged debris
    platforms/          stone ledges, prison balconies, maintenance steps
    catwalks/           rusted decks, brackets, ladders, hoist galleries
    cistern/            reservoir walls, sluices, channels, spillways
    floodgate/          wheel housings, gear walls, lock machinery, gate channels
    boss_area/          soul-gaol core, prison crown, Boss gate, chained reservoir
    memory_transition/  drowned-memory arches, reflective basin, sealed Chapter V door
  props/
    prison_bars/        doors, loose bars, grates, cell fronts
    chains/             hanging, wall-bound, snapped and hoist chains
    keys/               wall rings, key cabinets, ceremonial lock keys
    torture_tools/      racks, restraint tables, execution blocks, hooks
    soul_cages/         intact, cracked, empty and active cage modules
    drainage/           pipes, gutters, valves, drain mouths
    waterwheels/        wheel, axle, paddles and gear overlays
    crates/             prison stores, wet boxes, barrel variants
    corpses/            restrained silhouettes and covered remains; non-interactive
    records/            ledgers, shelves, prisoner plaques, registry desks
  doors/
    cell_doors/ rusted_gates/ floodgates/ boss_gate/ chapter_exit/
  fx/
    water/ drips/ ripples/ chains/ soul_fire/ soul_cage/ floodgate/
```

Existing formal character art is reused. Shared Player/HUD and reusable hit/water ripple primitives may be reused only where their provenance and render contract are already accepted; Chapter IV narrative architecture remains Chapter IV-owned.

## 11. Dynamic environment plan

- Layered shallow-water body behind actors; a 0–4 px translucent front lip may cross feet only.
- Player footsteps, landing and Dash splashes; enemy-sized variants where needed.
- Deterministic local drips and drain foam, not full-screen particle noise.
- Low-amplitude chain sway on selected props; no collision-changing pendulums in ordinary rooms.
- Animated cell/rusted/flood/Boss gates with collision synchronized to the visible gate.
- Floodgate Engine Hall waterwheel, axle and water-flow strips with a reduced-motion-safe speed.
- Soul cages with contained soul-fire motion and clear attack telegraph priority.
- Boss gate seal, Ormund arena water response and post-death Broken Soul Reservoir transition.
- Hall of Drowned Memories reflection/memory water, without implementing Chapter V itself.

Render contract: WorldRear/opaque architecture below platforms and actors; gameplay platforms at `z=0`; Enemies `z=10`; Player `z=12`; gameplay FX and telegraphs above actors; water body behind actors; only the narrow front water edge may use the foreground foot-overlap band. No wall, door leaf, statue, soul cage or water rectangle may cover the Player body.

## 12. Expected files in later production phases

The following are planned, not created in S0:

- 17 room scenes under `scenes/rooms/`, plus the revised `scenes/level/drowned_underkeep.tscn` route host.
- Modular architecture/prop/door/FX PNGs in the Chapter IV asset folders listed above.
- Typed level data scripts under `scripts/level/data/` and saved manifests under `resources/level/` and `resources/encounters/`.
- Development-only `scripts/tools/generate_chapter_04_encounter_layout.gd` and environment-asset production tools.
- Runtime `scripts/level/chapter_04_room_controller.gd`, `chapter_04_encounter_spawner.gd`, room transition/water/door/FX controllers, composed with existing combat code.
- Updated Chapter IV profile spawn IDs for room/checkpoint/Boss testing; no change to Bootstrap authority.
- Automated tests for count/seed persistence, role tags, platform access, render layers, collisions, transitions, Encounter isolation, Main integration and Boss flow.
- QA capture scripts/evidence under `docs/qa/chapter_04_scene_production/`.
- Later documentation updates to README, development log, scene/Encounter spec and QA report.

Expected existing-file modifications later: `drowned_underkeep.tscn`, `drowned_underkeep.gd`, `chapter_04_start_profile.tres`, registry/profile metadata only if new saved spawns require it, and Chapter III handoff only if the already-correct `CH4_START` contract needs a tested presentation refinement. Enemy/Boss Data, Player tuning and Chapters I–III gameplay remain out of scope.

## 13. Main/F5 production test plan

Future completion must be proven from `res://scenes/bootstrap/main_bootstrap.tscn`, not only F6 room scenes:

1. Select Chapter IV debug start through the existing bootstrap/profile route; enter at `CH4_START`.
2. Traverse all 17 areas in order and verify door/room handoffs, camera bounds and respawn/checkpoint positions.
3. Count exactly 46 ordinary/elite enemies and one Ormund Boss from saved manifests.
4. Verify 20 EncounterGroups activate sequentially; no AI tracks the Player across a room boundary.
5. Reach and defeat all seven Harpooners through documented platforms; test Player single jump, double jump and Dash routes.
6. Confirm at least 13 elevated initial spawns, with no heavy unit falling or walking off its platform.
7. Verify all shallow-water areas preserve Player movement/jump/attack/Dash and present readable splashes without actor occlusion.
8. Check all four Maws telegraph before emerging and all ranged projectiles collide with world geometry.
9. Validate the six support rooms contain no ordinary enemy and that the Boss arena contains only Ormund.
10. Complete Ormund, post-Boss reservoir and the sealed Chapter V transition without implementing Chapter V.
11. Reload/restart twice and compare spawn IDs/positions to prove seed persistence and no runtime reroll.
12. Run exact Godot 4.7.1 import/parse, deterministic tests, MainBootstrap smoke and graphical captures; investigate every Output/Debugger error.

## 14. S0 verification record and stop gate

Commands executed with `/Users/vincentz/Downloads/Godot.app/Contents/MacOS/Godot` (4.7.1):

- `--headless --path . --script res://chapters/chapter_04_drowned_underkeep/tests/characters/test_chapter_04_enemy_runtime.gd` — PASS.
- `--headless --path . --script res://chapters/chapter_04_drowned_underkeep/tests/characters/test_chapter_04_main_integration.gd` — PASS.
- `--headless --path . --script res://chapters/chapter_04_drowned_underkeep/tests/characters/test_soul_gaoler_ormund_runtime.gd` — PASS.
- `--headless --path . --script res://tests/player/measure_player_level_metrics.gd` — PASS; metrics recorded in section 4.
- `--headless --editor --path . --quit-after 1` — project import/parse PASS; Godot emitted only `Scan thread aborted` during forced editor shutdown, with no script/resource error.

S0 result: **PASS for audit/design lock; NOT IMPLEMENTED for scene production.** The next phase may create assets only after explicit approval. No asset, scene, gameplay, enemy, Boss, profile or Main route file was modified in this phase.
