# Development Log

## Current authoritative status

- Last audited: 2026-07-24
- Implementation baseline before this revision: `master` at `b62b7a2 fix: rebalance first enemy roster`
- Engine verified in this audit: `4.7.1.stable.official.a13da4feb`

This section is the current project snapshot. The dated entries below are retained as historical records of what was planned, implemented, tested, and still awaiting approval at each point in time. A historical plan or an earlier test result is not, by itself, evidence that a later feature exists or still passes.

### Status vocabulary

- **Implemented and re-verified** — the referenced files exist and the current HEAD passed the listed automated check during the 2026-07-22 documentation audit.
- **Implemented; manual acceptance pending** — code/assets and automated coverage exist, but player feel or visual acceptance still requires a human playtest.
- **Placeholder** — a deliberately temporary asset or presentation exists and must not be treated as final content.
- **Planned / not implemented** — described by design or architecture documents but absent from the current runtime scene/code path.
- **Pending verification** — the repository contains related material, but this audit did not establish runtime acceptance.

### Current delivery matrix

| Area | Current status | Repository evidence |
| --- | --- | --- |
| M0 project baseline | Implemented and re-verified | `project.godot` targets Godot 4.7 GL Compatibility and `scenes/main/main.tscn`; current headless import and Main startup passed. |
| Pixel character concept tool | Implemented and re-verified | Runnable design lab, eleven concept PNGs, 1600×1000 board, generator scripts, and asset validator are present. |
| Player animation presentation | Implemented and re-verified | `AnimatedSprite2D`, `PlayerAnimationController`, a 16-animation `SpriteFrames` resource, production/reference assets, and preview tooling are present. `death` is a five-frame production body fall; `hurt` is now a three-frame, 16 FPS production recoil sequence. |
| M1 locomotion | Implemented and re-verified | `CharacterBody2D` movement, ground/air acceleration, gravity, jump, 0.10 s coyote time, 0.12 s jump buffer, Camera2D, facing, and six locomotion animations passed the current regression. |
| Debug double jump | Implemented for testing; formal unlock pending | `has_double_jump` defaults false, while `debug_enable_double_jump` defaults true in `Player`; no ability-unlock/session system exists. |
| M1.5 actions | Implemented and re-verified; manual feel approval pending | Four-frame Attack, Ground/Air Dash chains, Dash Attack, input buffers, collision-safe motion, stamina component/HUD, and configurable airborne regeneration passed current automated tests. Attack now drives one-damage and Dash Attack two-damage composed Hitboxes only on their approved frames. |
| Player Health HUD | Implemented and re-verified | `Main/HUD/HealthContainer` observes the composed Player `HealthComponent`, initializes without polling, displays current/maximum values, and supports explicit signal-safe rebinding. It does not own Health data or death behavior. |
| Player death state | Implemented and re-verified; manual visual acceptance pending | `Player` enters one explicit `LifeState.DEAD`, cancels action/input/Stamina processing, and delegates a five-frame flat-body fall plus detached daggers and hooded ghost rise/pause to `PlayerDeathSequence`. |
| Player respawn | Implemented and re-verified; single test spawn only | After the approximately 1.30-second presentation completes, Main's typed coordinator returns the same Player instance to one `Marker2D`, restores Health/Stamina and control state, hides the prompt, and retains Camera2D following. No checkpoint/session selection exists. |
| Combat foundation | Implemented minimum; manual feedback acceptance pending | Typed Health/Hitbox/Hurtbox responsibilities, named layers, faction/dedup rejection, Player 1/2-point attacks, and one five-point sword source are tested. Player non-lethal Hurt now cancels actions, uses source-derived collision-safe knockback, and grants a 0.50-second multi-source grace window. Attributes, armor, and game-over flow do not exist. |
| Enemies and boss | Four normal enemy prototypes implemented in Main; manual acceptance pending | Castle Guard plus Shield Guard, Spearman, and Crossbowman have original art, typed configs/scenes/AI, shared combat contracts, Hurt/Death, 9 staged Main instances, and mixed test-room coverage. Shield Guard now has a permanent frontal Dash shield break, 0.70-second GuardBreak, readable fragments/flash, and persistent unshielded actions. Flying, elite, and Boss enemies remain unimplemented. |
| Level and game flow | Mixed Main combat laboratory implemented; formal rooms planned | Main has floor, two platforms, walls, one respawn marker, Player/HUD, and nine mixed enemies in four one-shot groups (2/2/2/3). The planned three rooms, checkpoint selection, elite unlock, boss arena, victory flow, menu, and save/session state do not exist. |
| Export/release | Pending verification / not configured | No `export_presets.cfg` was found during the audit. |

### Current validation baseline

On 2026-07-24, the exact Godot 4.7.1 executable completed a fresh import, started the updated Shield Guard independently and configured Main, and passed all 28 repository test scripts without final `SCRIPT ERROR`, `ERROR:`, or `WARNING:` output. Coverage retains the Health/HUD/death/respawn/movement/action/assets/Hurt baseline plus all four enemy roles, centralized current balance, encounter activation, and Main Debug behavior. Shield-specific coverage now proves front Block, back damage, one-time frontal Dash break, 0.70-second state lock, permanent post-break vulnerability, unshielded action/death presentation, live Main instances, and truthful Debug fields. Main still records groups sized 2/2/2/3 with three Castle Guards, two Shield Guards, two Spearmen, and two Crossbowmen; Group01 is active and later groups are paused at startup.

The stable measured envelopes are 153.59 px single-jump horizontal range / 83.77 px rise, 281.92 px debug-double-jump range / 167.10 px rise, and 344.00 px of four-Air-Dash action travel. The total takeoff-to-landing Air-Dash measurement alternated between 360.33 px and 362.22 px across three consecutive audit runs; this approximately one-physics-frame variation is recorded as a test determinism issue rather than a changed movement parameter.

### Documentation responsibility

- `docs/development_log.md` is the single primary development record and current-status source.
- `README.md` accurately identifies the current build as an M1.5 prototype and links here.
- `docs/game_design.md` and `docs/technical_architecture.md` are M0-era target/baseline documents. Their combat, level, enemy, checkpoint, and flow descriptions are plans, not delivered functionality.
- `docs/known_issues.md` was last reviewed at M0 and is stale. It must not be used alone to assess the current build.
- No separate `PLAN.md`, `ROADMAP.md`, `PROJECT_PLAN.md`, `PROGRESS.md`, `WORKLOG.md`, or equivalent primary progress file was found. Creating a duplicate development log is therefore unnecessary.

### Open issues and improvement needs

1. Complete a manual Godot editor/playtest acceptance pass for the latest continuous Ground/Air Dash, Attack chaining, Dash Attack handoff, stamina recovery, wall contact, both facings, HUD behavior, and animation readability.
2. Decide whether continuous airborne Dash and the current 100/25 stamina economy are accepted design baselines before building levels around the measured reach.
3. Replace the debug-default double jump with the planned ability-unlock/session-state path before treating progression as implemented.
4. Manually accept the new production Hurt silhouettes, flash strength, 2.5-pixel Camera shake, 180/-110 knockback, and existing death body/ghost readability at gameplay scale.
5. Resolve or tolerance-bound the 360.33–362.22 px landing-total measurement variation; the 344.00 px Dash-only envelope is currently stable.
6. Bring the M0 metadata/status in `game_design.md`, `technical_architecture.md`, and `known_issues.md` up to date in a separate documentation-only task.
7. Manually tune the four prototype enemy roles, especially Shield durability/break, Spear close dead zone, Crossbow Aim visibility, projectile pressure, Group04 spacing, and dissolve contrast; automated correctness does not establish encounter feel.
8. Keep Main and the dedicated combat room classified as laboratory/placeholder presentation, not finished room or UI content.

### Next-stage plan — requires explicit approval

1. **M1.5 acceptance gate:** perform manual feel/visual checks, record accepted tuning, and freeze movement/action metrics used for level construction.
2. **Documentation alignment:** update the stale M0 design/architecture/known-issues metadata without changing gameplay, and decide whether a separate project plan is needed.
3. **Enemy-variety acceptance gate:** manually verify Shield front/back/GuardBreak, Spear range/dead zone, Crossbow Aim/bolt/reload, all facings, Player evasion verbs, Hurt/Death, and the 2/2/2/3 Main route before any retuning.
4. **Scope reconciliation after explicit approval:** select or merge prototype roles back toward the fixed two-normal-enemy production scope before elite/Boss/content work. Flying enemy, elite, three main rooms, boss arena, Boss, drops, and progression remain unauthorized and unstarted.

## 2026-07-23 — First enemy variety batch (preflight)

Status: complete — implementation, 26-script regression, standalone/F5 startup, and graphical inspection passed; manual combat-feel acceptance pending

### Read-only findings

- Git preflight: clean `master` at `707f043 test: enforce F5 main scene synchronization`, one local commit ahead of `origin/master`.
- `project.godot` still explicitly sets `run/main_scene="res://scenes/main/main.tscn"`.
- The existing Cursed Castle Guard is `res://scenes/enemies/castle_guard.tscn`, driven by `scripts/enemies/castle_guard.gd`, `CastleGuardStateMachine`, `HealthComponent`, `HurtboxComponent`, one sword `HitboxComponent`, Player `DetectionArea`, forward wall/floor RayCasts, and production `castle_guard_sprite_frames.tres`.
- `HealthComponent`, `HitboxComponent`, and `HurtboxComponent` are already faction-safe reusable combat composition. Player normal/Dash Attack sources are separate Hitboxes but do not yet expose a typed attack-kind label required by frontal shield policy.
- Castle Guard owns its gravity, target acquisition, patrol/chase/edge handling, Hurt interruption/knockback, facing, attack-frame gating, Death/dissolve, and debug API in one script. Those behaviors are stable but should not be copied three times.
- `EncounterGroup` and `MainEnemyDebugOverlay` are currently hard-coded to `CastleGuard`; they must be generalized to a narrow enemy contract before mixed groups can activate and report correctly.
- Collision layers currently name World, Player/Enemy Body, Player/Enemy Hurtbox, Player/Enemy Hitbox, and Detection. A ninth explicit Projectile layer is required; Player Hurtbox must accept both EnemyHitbox and Projectile while enemy Hurtboxes continue accepting PlayerHitbox only.
- Main currently has four one-shot groups and five Castle Guards. The current 2600-pixel gray-box floor and two platforms can host four staged mixed groups without adding a production room or exceeding the fixed game scope.

### Reuse plan

- Add a thin `EnemyCombatant` contract for mixed encounter activation/debug and a `GroundEnemyBase` for the three new grounded enemies' common detection, gravity, edge checks, facing, Hurt, Death/dissolve, Health/Hurtbox, and AI enable/disable lifecycle.
- Keep Castle Guard's proven AI logic; change only its parent contract and add generic type/debug/detection methods.
- Extend `HitboxComponent` with a typed `attack_kind` and `HurtboxComponent` with an optional typed `EnemyHitPolicyComponent`. Implement frontal shield behavior in `ShieldBlockComponent`; blocked hits are consumed once without mutating Health.
- Add separate typed configs, scenes, AI scripts, original Godot-Image pixel generators, SpriteFrames resources, and deterministic tests for Cursed Shield Guard, Decayed Spearman, Fallen Crossbowman, and `crossbow_bolt.tscn`.
- Generalize `EncounterGroup` and Main debug to `EnemyCombatant`, create `enemy_variety_test_room.tscn`, and replace Main's homogeneous layout with four authored mixed groups of sizes `2/2/2/3` containing all four enemy types.

### Planned files and verification

- Gameplay: common enemy contract/base/config/hit policy, three enemy scripts/configs/scenes/resources, projectile script/scene, generalized encounters/debug, Player/Hitbox/Hurtbox collision metadata, and Main mixed instances.
- Assets/tooling: 64×64 transparent original pixel frames under the three requested directories, one Godot generator, one SpriteFrames builder, and one variety contact sheet/QA frame.
- Tests: focused combat-policy/projectile/enemy AI/assets/variety-room/Main mixed-encounter coverage plus the full existing suite.
- Run exact Godot 4.7.1 fresh import, each enemy scene standalone, projectile/variety/combat rooms, configured F5 Main headless and graphical, all tests, log diagnostics, visual inspection, and `git diff --check`.

### Scope check

- Authorized: three normal grounded enemy types, one bolt projectile, necessary shared combat/AI contracts, one test room, mixed Main encounters, documentation, and tests.
- Excluded: flying enemies, elite, Boss, drops, experience, equipment, new Player damage/tuning, complex combo trees, or production-room expansion.

## 2026-07-23 — F5 Main scene synchronization acceptance (preflight)

Status: complete — configured Main, standalone combat room, graphical evidence, and full regression passed

### Read-only findings

- Git preflight: clean `master` at `04c8769 fix: defer hurtbox physics state changes`, synchronized with `origin/master`.
- `project.godot` explicitly sets `run/main_scene="res://scenes/main/main.tscn"`; this path was read from project settings rather than inferred from filenames.
- Main directly instances `res://scenes/player/player.tscn` at `Main/World/Player` and `res://scenes/enemies/castle_guard.tscn` five times beneath `Main/World/Encounters/EncounterGroup01..04/Enemies`.
- The saved Main composition contains one `Marker2D` spawn, the typed respawn coordinator, signal-driven Health/Stamina HUD, Player action/death debug controls, four authored activation areas, and one/two-enemy group sizes of `1/1/1/2`.
- The current Player PackedScene composes the latest Player SpriteFrames, movement/action/Hurt configurations, AnimationController, Stamina/Health/Hurtbox, normal and Dash Attack Hitboxes, Camera2D, HurtController, and death/ghost sequence.
- The current Guard PackedScene composes the latest Guard SpriteFrames/configuration and centralized sword damage is `5`. No Main instance overrides the PackedScene with an older script, SpriteFrames resource, or damage value.
- Existing Main-specific coverage proves group activation, five-point Guard damage, Player Hurt/invulnerability, and Guard Death cleanup; separate Player tests exercise movement/actions and Main-backed death/ghost/respawn. This task will add a saved/runtime resource-path and HUD/debug-state guard so future tool-scene-only integrations fail CI-style verification.

### Goals, planned files, and tests

- Strengthen `tests/combat/test_main_enemy_integration.gd` with explicit checks for the configured F5 path, Player/Guard source PackedScenes, latest SpriteFrames/config resources, composed gameplay controllers, live Health/Stamina HUD binding, respawn wiring, and closable debug presentation.
- Do not alter Player feel, input mapping, combat values, enemy placement, encounter count, AI, animation art, collision shapes, or the Main node tree unless runtime evidence exposes a real synchronization defect.
- Run the exact Godot `4.7.1.stable.official.a13da4feb` executable for fresh import, focused Main integration, Player movement/actions, Hurt, death/respawn, Guard/combat room, full repository regression, configured F5 graphical startup, and diagnostic-log scanning.
- Preserve Main graphical evidence and a concise audit report under `docs/qa/`; update README only if the verified F5 route differs from its current instructions.

### Scope check

- This is an integration/acceptance hardening task for already approved Player, Guard, encounter, HUD, death, and respawn work.
- It adds no new gameplay verb, enemy type, damage rule, room, Boss, item, drop, animation, or tuning change.

### Delivered acceptance hardening

- Strengthened `test_main_enemy_integration.gd` so it fails if configured F5 stops targeting `scenes/main/main.tscn`, if Main switches to an outdated Player/Guard PackedScene, SpriteFrames, action/Hurt/Guard config, or if any saved Guard overrides the centralized five-point damage.
- Added Main-runtime checks for the exact Player gameplay composition, live signal-bound Health/Stamina HUD, SpawnPoint/respawn wiring, active Player Camera2D, and independently closable action/enemy debug overlays.
- Replaced the previous direct terminal Guard damage in the Main test with the Main Player's actual action controller and composed Hitboxes: the real four-frame normal Attack deals one point, then the real Dash Attack deals two points and causes the three-Health Guard's Death/dissolve cleanup.
- Preserved the first Guard's natural AI sword path and now also proves Hurt recovery before Player control resumes. The Guard still deals exactly five points, the immediate second hit is rejected during the 0.50-second invulnerability window, and the Player returns to Alive.
- No runtime scene, art, parameter, input, Player code, enemy code, HUD code, collision, or encounter placement changed because the saved Main was already synchronized. The only executable change is stronger regression coverage preventing future tool-scene-only delivery.
- Added `docs/qa/f5_main_sync_report.md`, an inspected 1280×720 configured-Main frame, and focused import/Main/combat-room logs. The Movie Maker's duplicate first two frames and generated silent WAV were discarded; the final evidence frame remains.

### Commands and actual results

1. Exact engine and parsing:
   - `/Users/vincentz/Downloads/Godot.app/Contents/MacOS/Godot --version`: `4.7.1.stable.official.a13da4feb`.
   - Fresh headless editor import: exit 0; no parse, resource, script, error, or warning diagnostics.
2. Configured F5 Main:
   - `Godot --headless --path . --quit-after 180`: exit 0 with no diagnostics.
   - `test_main_enemy_integration.gd`: PASS for latest resource paths, live HUD, debug toggles, four activation groups/five Guards, natural five-point Guard Attack, Player Hurt/invulnerability/recovery, real one-point Player Attack, real two-point Dash Attack, Guard Death/dissolve, and active Camera2D.
3. Independent scene and focused behavior:
   - Explicit `combat_test_room.tscn` startup: exit 0.
   - `test_m1_player_movement.gd`: PASS for movement, jump assists, collision, Camera, and six locomotion animations.
   - `test_player_hurt_reaction.gd`: PASS for production Hurt, action interruption, collision-safe knockback, invulnerability, airborne handling, and Death precedence.
   - `test_player_death_presentation.gd`: PASS for flat body, released daggers, ghost rise/pause, and cleanup.
   - Main-backed `test_player_respawn.gd`: PASS in its preserved focused run for delayed ghost-complete respawn, SpawnPoint return, Health/Stamina/HUD reset, Camera continuity, and input recovery.
4. Full regression:
   - All 22 repository test scripts passed individually. Preserved log scan contains no `SCRIPT ERROR`, `ERROR:`, `WARNING:`, parse error, missing resource, or blocked PhysicsServer call.
5. Graphical F5-equivalent run:
   - `Godot --path . --write-movie docs/qa/f5_main_sync_runtime.png --fixed-fps 1 --quit-after 3 --audio-driver Dummy`: exit 0 using GL Compatibility on Apple M4.
   - Inspected `docs/qa/f5_main_sync_runtime00000002.png` at 1280×720. It visibly shows the Main Player, first Guard encounter, four group/five Guard rows with damage 5, and live Health/Stamina/action HUD.

### Manual acceptance still required

- Use F5 with both debug toggles disabled and judge Player movement/jump/double-jump/continuous-Dash feel, Attack/Dash Attack readability, Hurt knockback/shake comfort, Guard windup fairness, late two-enemy pressure, and death/ghost visual quality. Automated results establish correctness and persistence, not subjective feel.
- Rerun F5 after closing/reopening the editor to confirm the same saved Main presentation in the user's local editor workflow; resource-path and serialized-scene checks already prove persistence at file level.

## 2026-07-23 — Godot Debugger five-error repair (preflight)

Status: complete — five repeated Debugger errors identified and fixed; full regression passed

### Read-only findings

- Git preflight: clean `master` at `eb1e4fd feat: add player hurt and grouped encounters`, two commits ahead of `origin/master`.
- The latest project `user://logs/godot.log` contains exactly five `ERROR:` entries. All five are the same Godot 4.7.1 engine guard: `Function blocked during in/out signal. Use set_deferred("monitorable", true/false).`
- Each stack is identical: Player Hitbox `area_entered` → `HitboxComponent.try_hit()` → Guard `HurtboxComponent.receive_hit()` → Health reaches zero → `CastleGuard._enter_death()` → `HurtboxComponent.set_enabled(false)` → synchronous `Area2D.monitorable` assignment.
- The error repeats once for each of the five Main Guards killed during the user's run; there are not five independent code defects.
- `set_enabled()` already changes collision-shape disabled state with `set_deferred()`, but line 53 still writes `monitorable = enabled` synchronously. The component's immediate `is_enabled` flag already rejects any late contact in the same frame, so deferring the physics-server property is both safe and the Godot-required lifecycle behavior.
- Previous automated tests did not reproduce this because most lethal tests call `try_hit()` directly rather than letting PhysicsServer emit a real `area_entered` callback.

### Goals, planned files, and tests

- Change only `scripts/combat/hurtbox_component.gd` so monitorability is queued with `set_deferred()` while logical enable/disable remains immediate.
- Add a focused regression to `tests/combat/test_hitbox_hurtbox_components.gd` that creates overlapping areas, lets the physics engine emit `area_entered`, kills the target inside that callback chain, and verifies one death with no debugger error.
- Re-run exact Godot 4.7.1 import, the focused component/Guard/Main tests, all repository tests, configured Main, and scan preserved logs for `ERROR:`/warnings.
- Update only this development record beyond the focused code/test change; do not alter combat values, Player feel, enemy count, scene layout, art, or milestone scope.

### Scope check

- This is a lifecycle correctness fix for the existing Hurtbox composition.
- It adds no enemy, skill, damage rule, animation, UI, encounter, Boss, drop, or progression content.

### Delivered repair

- Replaced the synchronous `monitorable = enabled` write in `HurtboxComponent.set_enabled()` with `set_deferred("monitorable", enabled)`, matching Godot 4.7.1's PhysicsServer lifecycle rule for Area2D enter/exit callbacks.
- Kept `is_enabled` immediate. Therefore a lethal contact closes logical damage acceptance in the same call stack, while only the server-backed monitorability and CollisionShape2D state wait for the safe deferred phase.
- Added a PhysicsServer-driven regression to `test_hitbox_hurtbox_components.gd`: overlapping hostile areas now let the engine emit `area_entered`, lethal damage disables the Hurtbox inside the callback chain, and the test verifies one death plus final non-monitorability. This covers the path that direct `try_hit()` tests previously missed.
- No combat number, state priority, animation, scene, enemy placement, or Player input behavior changed.

### Commands and actual results

1. Historical evidence:
   - Read the latest `user://logs/godot.log`; it contained exactly five copies of the same blocked `set_monitorable` stack, each ending at `HurtboxComponent.set_enabled()` during `CastleGuard._enter_death()`.
2. Focused verification with exact Godot `4.7.1.stable.official.a13da4feb`:
   - `Godot --headless --path . --script tests/combat/test_hitbox_hurtbox_components.gd`: PASS, including deferred physics disable; preserved log contains no error/warning.
   - Fresh headless editor import: exit 0, no parse/resource/error/warning output.
   - `test_castle_guard.gd`: PASS for patrol, Chase, fair Attack, Hurt, and Death.
   - `test_main_enemy_integration.gd`: PASS for four groups, five Guards, Hurt, five-point damage, and Death.
3. Full regression:
   - All 22 repository test scripts exited 0.
   - Exact stdout/log scan found no `SCRIPT ERROR`, `ERROR:`, `WARNING:`, or blocked in/out-signal diagnostic.
   - Movement/action metrics remain unchanged: 153.59 px single-jump range, 281.92 px debug-double-jump range, 344.00 px four-Air-Dash action travel.
4. Runtime startup:
   - Configured Main completed a non-headless 120-frame GL Compatibility launch on Apple M4 with exit 0 and no diagnostics.

### Manual acceptance

- Clear the Godot Debugger's historical error list (or restart the editor), run F5, and defeat the five Guards again. The previous five entries remain visible until cleared, but no new `Function blocked during in/out signal` entry should be added.

## 2026-07-23 — Player Hurt feedback, Guard damage, and gray-box encounter density (preflight)

Status: complete — implementation and automated regression passed; manual feel/visual acceptance pending

### Read-only findings

- Git preflight: clean `master` at `37d116c feat: integrate cursed guards into main scene`, one local commit ahead of `origin/master`.
- Player Health is composed through `HealthComponent` with the unchanged default/runtime maximum and current value of 100/100. The Player has only `ALIVE` and `DEAD` life states; accepted Hurtbox contacts currently emit `damage_received` but do not enter a Hurt state, cancel actions, apply knockback, grant invulnerability, flash the sprite, or shake Camera2D.
- `hurt` already exists in the Player SpriteFrames contract as three non-looping frames, but it runs at 12 FPS and references `placeholder_hurt_01..03.png`. Those images are generated by shifting existing Attack/reference frames; they are explicitly placeholder art, not a production recoil sequence.
- Cursed Castle Guard sword damage has one tuning authority: `resources/enemies/castle_guard_config.tres` currently sets `attack_damage = 1`; `castle_guard.gd` copies that value into the sword Hitbox and uses it for each new active window. No separate gameplay script hardcodes the production sword value.
- Hitbox target memory already prevents one `attack_id` from damaging the same Hurtbox on multiple active frames. There is no Player-side invulnerability, so different attack ids or multiple enemies can currently apply damage without a shared grace window.
- F5 Main contains exactly two Guard instances at `(500, 610)` and `(850, 610)`, directly under `World/Enemies`. There is no encounter group, ActivationArea, persistent activation flag, active-enemy cap, or encounter debug authority.
- The gray-box floor spans approximately 2600 horizontal pixels (`-100..2500`), about 2.03 viewports at 1280px rather than the suggested 3–5-screen case. The density target is therefore five Guards across four hand-authored groups (1/1/1/2), not six to eight.
- Pre-change runtime audit passed: configured Main loaded both Guards and the active Player Camera, with the near Guard in Chase and the far Guard Idle; no baseline Godot error or warning was emitted.

### Goals and planned files

- Replace the three placeholder Hurt frames with original 64×64 production pixel poses at 16 FPS, archive the exact placeholder sources under `reference/deprecated_hurt_placeholder/`, rebuild SpriteFrames, and retain Nearest/lossless/mipmap-free imports.
- Add a focused typed Player Hurt reaction component/config for one accepted hit: source-derived knockback, 0.16-second stun plus 0.08-second recovery, 0.50-second invulnerability, action/buffer/Hitbox cancellation, non-lethal Hurt arbitration, restrained flash and Camera shake, and safe death/respawn cleanup. Global Hit Stop will remain disabled unless tests establish a safe local implementation.
- Change the single Guard damage resource value from 1 to 5 and expose the actual damage in debug output without duplicating it in AI code.
- Replace Main's flat two-enemy container with four hand-authored activation groups containing five total instances. Add one reusable encounter controller/scene contract that keeps inactive AI paused, activates once when Player enters, and reports group/active/alive/attacking counts.
- Planned implementation areas: Player scene/scripts/resource, Hurtbox invulnerability support, Player asset tooling/resources/tests, Guard config/debug/tests, Main encounter composition/controller/tests, README, five existing design/log documents, and new `docs/design/encounter_design_spec.md`.

### Verification plan

1. Generate/archive/import Hurt PNGs and rebuild Player SpriteFrames with exact Godot 4.7.1; validate frame count, 16 FPS, binary transparency, common baseline, distinct recoil silhouettes, and 48px readability.
2. Test grounded/airborne source-directed knockback, wall collision, Attack/Dash/Dash-Attack cancellation, buffer/Hitbox cleanup, 0.50-second multi-source rejection, flash/Camera restoration, lethal Death priority, and respawn reset.
3. Verify Guard windup remains damage-free, `attack_03/04` deal one deduplicated 5-point hit, body contact remains harmless, and 100 Health permits exactly twenty such hits.
4. Verify five saved Main Guards, four persistent activation groups, staged activation, no opening whole-map aggro, no spawn overlap, maximum two attackers per group, safe floor positions, and one-enemy combat-room preservation.
5. Run all repository scripts, isolated Player/Guard/combat-room scenes, configured Main, graphical captures, log scans, and `git diff --check`.

### Scope check

- This revision changes only Player Hurt feedback, the existing Cursed Castle Guard damage value, and first-enemy gray-box encounter density/activation.
- It does not add another enemy type, elite, Boss, drop, experience, random/infinite spawning, object pooling, complex squad tactics, new Player skill, or formal production level.

### Delivered implementation

- Replaced the placeholder Hurt contract with three original 64×64 frames at 16 FPS. The sequence uses a real rearward torso/hood shift, unstable dagger arms, a lifted/recovering stance, common y=60 ground baseline, binary transparency, and Nearest imports. The exact former placeholder PNGs remain under `assets/sprites/player/assassin/reference/deprecated_hurt_placeholder/`.
- Added typed `PlayerHurtConfig` and `PlayerHurtController`, composed as `Player/HurtController`. Accepted non-lethal hits cancel all action state/buffers/Hitboxes, enter `LifeState.HURT`, play the production animation, apply 180 px/s source-opposed horizontal and -110 px/s vertical knockback (70% vertical in air), lock control for 0.16 seconds plus 0.08-second recovery, and move only through Player velocity plus `move_and_slide()`.
- Extended `HurtboxComponent` with synchronous invulnerability rejection and a typed state signal. One accepted hit grants 0.50 seconds; distinct sources in the same or later physics frames are rejected until expiry. Death cancels Hurt feedback, and respawn clears invulnerability, sprite modulation, camera offset, timers, and history.
- Added 0.08-second pale-red flash/flicker and a deterministic decaying 2.5-pixel, 0.10-second Camera2D shake. Reserved `hurt_audio_requested`; no fake audio was added. Global Hit Stop remains disabled because existing death/ghost/respawn timers must not be frozen by a global time-scale mutation.
- Changed the one Guard tuning authority to `attack_damage = 5`; AI active windows and both debug views read the same resource value. Player maximum Health stays 100, so hits 1–19 are survivable and hit 20 is lethal from full Health.
- Added reusable `EncounterGroup` activation gating and replaced flat `World/Enemies` with four Main groups containing five total Guards (1/1/1/2). Inactive groups keep their Guard visuals in Idle while AI/detection are paused; Player entry activates once for the scene run. Authored spacing and the 260-pixel lose range prevent startup whole-map aggro, while the only two-enemy group caps local participation at two.
- Expanded closable diagnostics with Player Health/LifeState, invulnerability/stun remaining, last damage/source/knockback and encounter activation/engaged/alive/attacking counts plus actual Guard damage. The dedicated combat room still contains exactly one Guard.

### Commands and actual results

1. Asset and parse pipeline with exact `4.7.1.stable.official.a13da4feb`:
   - `Godot --headless --path . --script scripts/tools/build_player_animation_assets.gd -- --hurt-production-only`: exit 0; six outputs (three production frames plus three archived placeholders), zero failures.
   - `Godot --headless --editor --path . --import --quit`: exit 0; all six PNGs imported and new classes registered without diagnostics.
   - `Godot --headless --path . --script scripts/tools/build_player_animation_assets.gd`: exit 0; `PLAYER_SPRITE_FRAMES_BUILD: OK`.
2. Focused runtime checks:
   - `test_player_hurt_reaction.gd`: PASS for production art, action interruption, collision wall knockback, multi-source invulnerability, airborne scaling, and Death precedence.
   - `test_castle_guard.gd`: PASS with 0.35-second safe windup and one deduplicated five-point active hit.
   - `test_main_enemy_integration.gd`: PASS for configured F5 scene, four groups/five Guards, staged activation, Hurt, five-point damage, and enemy Death cleanup.
   - `test_combat_test_room.gd`: PASS; its one Guard still drives damage, Player death presentation, and respawn.
3. Full regression:
   - All 22 `tests/**/*.gd` scripts exited 0. Log scan found no `SCRIPT ERROR`, `ERROR:`, `WARNING:`, parse error, or missing resource.
   - Stable movement metrics remain single jump 153.59 px / 83.77 px rise, debug double jump 281.92 px / 167.10 px rise, four-Air-Dash action travel 344.00 px; this run's landing total was 362.22 px.
4. Startup checks:
   - Configured Main, independent `combat_test_room.tscn`, and independent `castle_guard.tscn` each exited 0 under `--headless --quit-after 3` with no diagnostics.
   - Configured Main also completed a non-headless 120-frame launch on GL Compatibility / Apple M4 (`OpenGL API 4.1 Metal`) with exit 0 and no error/warning output.
   - Final PNG audit: all three Hurt sources are distinct 64×64 files (808/830/819 bytes), imported Lossless with mipmaps disabled; the focused test also passed byte-identical placeholder archival and 48×48 nearest-neighbor readability.

### Manual acceptance still required

- At gameplay scale, judge whether all three Hurt poses, flash, and shake communicate impact without reading as Death or excessive screen motion.
- Verify grounded and airborne knockback feel fair from both sides, especially next to walls and during Player Attack/Dash/Dash Attack.
- Traverse all four groups and confirm the 1/1/1/2 pacing leaves enough stamina recovery space and the final pair does not feel like unavoidable synchronized pressure.

## 2026-07-23 — Main scene Cursed Castle Guard integration audit (preflight)

Status: complete — implementation, runtime audit, full regression, and graphical verification passed; manual combat-feel acceptance pending

### Read-only findings

- Git preflight: clean `master` at `5e897f6 feat: refine cursed castle guard animations`, tracking `origin/master` with no uncommitted files.
- Godot 4.7.1 reports `run/main_scene="res://scenes/main/main.tscn"`; the saved editor layout also has `res://scenes/main/main.tscn` as its current scene, so both F5 and the editor's current F6 route enter Main in the audited editor state.
- `scenes/main/main.tscn` contains Player, movement geometry, HUD, and respawn composition but no Cursed Castle Guard resource reference, `Enemies` container, enemy instance, or runtime enemy-spawn script.
- `scenes/tools/combat_test_room.tscn` is the only gameplay scene that currently instances `res://scenes/enemies/castle_guard.tscn`; this explains why the enemy exists in the repository and passes isolated tests while remaining absent from the user's normal F5/F6 run.
- The reusable enemy is not placeholder-only: the scene composes body collision, Player detection, Health, Hurtbox, sword Hitbox, wall/floor probes, typed state authority, and the production five-animation SpriteFrames resource. All 24 expected 64×64 source frames and their imports exist.
- Baseline Godot checks passed before any change: headless editor import, configured Main startup, independent combat-room startup, Castle Guard state/combat test, and combat-room player-death/respawn test. No `SCRIPT ERROR`, `ERROR:`, or `WARNING:` entries were found in the preserved logs.

### Goals and planned files

- Instance at least two existing Cursed Castle Guards under a dedicated `Main/World/Enemies` container, on valid floor positions with staged spacing for immediate and later encounter testing.
- Add one Main-only, closable enemy debug panel showing each valid guard's state, Health, animation/frame, target state, sword active window, position, and horizontal speed; do not copy enemy behavior into Main.
- Add an automated Main integration/runtime audit that proves both enemy node paths exist and remain alive/visible with valid runtime data, while retaining the independent combat room and existing combat tests.
- Planned implementation files: `scenes/main/main.tscn`, one focused `scripts/tools/` Main combat-debug controller, one focused `tests/combat/` Main integration test, README, combat/enemy specifications, and this development log. Final graphical evidence will be retained under `docs/qa/`.

### Verification plan

1. Run a fresh Godot 4.7.1 headless editor import/parse check.
2. Run the configured F5 Main and the independent `combat_test_room.tscn`, checking their logs for any error or warning.
3. Assert the Main runtime Player, active Camera2D, both enemy node paths, positions, visibility, animation/frame, Health, AI state, target status, Hitbox/Hurtbox state, and collision contracts.
4. Exercise Player normal Attack (1 damage), Dash Attack (2 damage), guard sword damage (1), Hurt interruption, Death/dissolve cleanup, edge safety, and Player death/respawn through deterministic tests.
5. Render and directly inspect a 1280×720 Main screenshot proving enemy visibility, then run all repository tests and `git diff --check`.

### Scope check

- This repair uses the existing first melee enemy and shared combat components only.
- It does not add a second enemy type, elite, Boss, drop, item, new skill, formal map, or unrelated Player tuning.
- The dedicated combat room remains independently runnable and is not promoted to the project Main scene.

### Delivered implementation

- Added one reusable enemy PackedScene dependency to Main and exactly two instances under `Main/World/Enemies`: `CursedGuardNear` at `(500, 610)` and `CursedGuardFar` at `(850, 610)`. The Player remains at `(320, 612)`, so the near Guard begins at the requested 180-pixel test distance while the far Guard stays outside initial detection.
- Added a Main-only `ENEMY DEBUG` toggle and typed overlay. For every live direct child of `Enemies`, it reports AI state, current/max Health, animation and one-based frame, Player-target acquisition, sword Hitbox activity, position, horizontal speed, facing, and visibility. It is presentation/debug code and owns no AI or Health state.
- Added `test_main_enemy_integration.gd`. It verifies the configured F5 path, saved/runtime node paths, active Player Camera2D, exact spawns, visibility, animation playback, Health, staged target acquisition, concrete collision layers/masks, a natural Main AI sword hit, Player one-point Attack, Player two-point Dash Attack, lethal Hurtbox forwarding, and Death/dissolve cleanup.
- Tightened Castle Guard's existing Death completion boundary: after the final dissolve frame it emits `presentation_finished` and calls `queue_free()`. The independent combat room now safely reports `GUARD CLEARED AFTER DEATH/DISSOLVE`; no invalid enemy reference is polled or drawn.
- Updated Main's visible title/instructions, README F5/F6 guidance, collision contract, enemy deployment specification, and retained two 1280×720 Main runtime frames under `docs/qa/`.

### Commands and actual results

1. Pre-change baseline with exact `4.7.1.stable.official.a13da4feb`:
   - Headless editor import, configured Main startup, and independent combat-room startup: all exit 0.
   - `test_castle_guard.gd`: PASS for patrol, edge, Chase, fair Attack, Hurt, and Death.
   - `test_combat_test_room.gd`: PASS for composition, contact safety, enemy damage, Player death, and respawn.
2. Main runtime audit:
   - `Godot --headless --path . --script res://tests/combat/test_main_enemy_integration.gd`: exit 0; `MAIN_ENEMY_INTEGRATION_TEST: PASS`.
   - Runtime SceneTree paths: `/root/Main/World/Enemies/CursedGuardNear` and `/root/Main/World/Enemies/CursedGuardFar`.
   - Eight physics frames after start: Player `/root/Main/World/Player`; active Camera `/root/Main/World/Player/Camera2D`; near Guard `(496.7333, 609.9252)`, visible, Chase, `walk:2`, 3/3, target true; far Guard `(850, 610)`, visible, Idle, `idle:1`, 3/3, target false.
   - The same test observed a natural near-Guard AI Attack reduce Player Health by exactly one, then verified Player Attack 1, Dash Attack 2, and terminal Guard cleanup.
3. Full regression and startup:
   - All 21 scripts under `tests/` exited 0; combined log scan found no `SCRIPT ERROR`, `ERROR:`, `WARNING:`, parse error, or missing resource.
   - Configured Main, independent `combat_test_room.tscn`, and independent `castle_guard.tscn` each started and exited 0 without diagnostics.
   - Movement metrics remained 153.59/83.77 single jump, 281.92/167.10 debug double jump, 344.00 four-Air-Dash action travel, and 362.22 through landing.
4. Graphical evidence:
   - `Godot --path . --write-movie docs/qa/main_cursed_guard_runtime.png --fixed-fps 1 --quit-after 2 --audio-driver Dummy`: exit 0; two 1280×720 frames rendered through GL Compatibility on Apple M4.
   - `docs/qa/main_cursed_guard_runtime00000001.png` was inspected at original resolution. It visibly contains Player, both distinct Guard instances, fixed Health/Stamina HUD, and live near/far enemy debug rows without blocking the ground combat silhouettes.
   - A separate 90-frame, fixed-60-FPS `combat_test_room` death demo completed without diagnostics. The last frame was inspected and shows no Guard/ghost, no stale collision drawing, and the safe `GUARD CLEARED AFTER DEATH/DISSOLVE` status.

### Manual acceptance requested

1. Press F5 and confirm both Guard silhouettes appear immediately: the near Guard should acquire/approach, while the far Guard patrols separately.
2. Toggle `ENEMY DEBUG` off/on and confirm Gameplay continues while only the diagnostic rows hide/show.
3. Test J, Shift, Shift→J, jump, Ground/Air Dash, both facings, wall contact, and platform-edge behavior against both Guards.
4. Defeat each Guard and judge Hurt, grounded Death, and dissolve readability; confirm no enemy ghost appears and no invisible body blocks movement afterward.
5. Allow the sword to deplete Player Health or use the existing development damage button, then confirm the Player death/ghost/respawn sequence and both HUD bars remain correct.

### Known limitations

- Main remains a gray-box combat laboratory, not one of the planned three production rooms. It has no encounter reset button; rerun F5 to restore freed Guards.
- Player has no invulnerability frames or production Hurt state, so separate enemy attacks can remove Health on separate attack ids. The two Guards are spaced to avoid immediate simultaneous acquisition, but future encounter tuning still needs manual approval.
- F6 always follows whichever scene is currently open in the editor. The saved audited editor state points to Main, but opening another scene intentionally changes F6 behavior; F5 remains the authoritative complete Main route.

## M0 — Environment and repository initialization

Date: 2026-07-20
Status: complete — awaiting approval for M1

### Preflight

- Repository audit: directory was empty; no Git metadata or user files were present.
- Godot discovery: PATH aliases `godot` and `godot4` were absent; application found at the developer's local Godot application path.
- Confirmed engine: `4.7.1.stable.official.a13da4feb`.
- Confirmed OS: macOS 26.5.2 (Build 25F84).
- Confirmed Git: 2.54.0; repository not initialized at preflight.

### Goals

- Initialize a Godot 4.7.1 project and Git repository.
- Establish the required directory layout and agent conventions.
- Create one dependency-free Main scene that starts safely.
- Document architecture, design baseline, test method, and known issues.

### Planned files

- Root: `project.godot`, `.gitignore`, `README.md`, `AGENTS.md`.
- Scene: `scenes/main/main.tscn`.
- Docs: technical architecture, game design baseline, development log, known issues.
- Placeholder files for required empty directories.

### Test plan

1. Verify exact Godot executable and version.
2. Run `--headless --editor --path . --import --quit` for project import/resource parsing.
3. Run `--headless --path . --quit-after 5` for main-scene startup.
4. Launch the graphical project briefly and capture startup evidence if the environment permits.
5. Review Godot output for errors and warnings and inspect Git status.

### Scope check

M0 contains no player controller, movement, input actions, combat, enemies, levels, checkpoint, or menu behavior. The static Main screen exists only to prove project startup.

### Commands and results

1. `Godot --version`
   - Result: exit 0; `4.7.1.stable.official.a13da4feb`.
2. `sw_vers` and `git --version`
   - Result: macOS 26.5.2 (Build 25F84); Git 2.54.0.
3. `Godot --headless --editor --path . --import --quit`
   - Result: exit 0; filesystem scan and editor initialization completed; no resource or parser errors in output.
4. `Godot --headless --path . --quit-after 5`
   - Result: exit 0; configured Main scene started and stopped without errors.
5. `Godot --path . --write-movie docs/qa/m0_startup.png --fixed-fps 30 --quit-after 3 --audio-driver Dummy --log-file docs/qa/m0_graphical_run.log`
   - Result: exit 0; OpenGL Compatibility renderer initialized on Apple M4 and wrote three 1280×720 frames.
   - Reviewed evidence: `docs/qa/m0_startup00000002.png`; the title, Chinese subtitle, procedural moon/spires, and M0 status are visible and correctly laid out.
6. `git status --short --branch`
   - Result: repository contents reviewed before the milestone commit; `.godot/` is correctly ignored.

No scripts exist in M0, so script-unit tests and GDScript static analysis have no applicable targets yet.

### Delivered

- Godot project configuration with `scenes/main/main.tscn` as the main scene.
- Required scene, script, resource, asset, test, documentation, and add-on directories.
- Repository/agent conventions, technical architecture, design baseline, known-issue log, and visual QA evidence.
- Main scene uses only Godot native nodes and procedural polygons; no third-party assets were introduced.

### Manual acceptance

1. Open the project with Godot 4.7.1 Standard.
2. Press `F5` and confirm a 1280×720 window opens.
3. Confirm `NOCTURNE KEEP`, `夜幕古堡`, and `M0 · PROJECT INITIALIZED` are visible.
4. Stop the project and confirm the editor Output/Debugger shows no error.

### M0 tuning changes

None. Gameplay values were not implemented or altered in this milestone.

## M0 — Final project baseline

Date: 2026-07-20
Status: complete

### Preflight and scope

- This pass is limited to M0 project settings, Godot import boundaries, documentation, verification, and Git cleanup.
- No input action, player node, gameplay script, level geometry, collision, or other M1 feature is included.
- Preflight Git state contained an editor-normalized `project.godot` plus four untracked `.import` sidecars for the QA movie output.

### `project.godot` review

- Godot replaced the custom file header with its standard generated header.
- Godot removed `rendering/textures/default_filters/use_nearest_mipmap_filter=false` from the serialized project file.
- A Godot 4.7.1 runtime query confirmed that setting is registered and its effective default remains `false`; omitting a value equal to that default does not change behavior.
- That setting controls whether mipmapped textures prefer nearest mipmap filtering. It does not select nearest filtering for ordinary CanvasItem textures.
- Godot 4.7.1 reports `rendering/textures/canvas_textures/default_texture_filter` with enum values `Nearest, Linear, Linear Mipmap, Nearest Mipmap`. The prior effective value was `1` (`Linear`).
- The project now explicitly sets `textures/canvas_textures/default_texture_filter=0` under `[rendering]`, giving future 2D pixel textures a nearest-filtered default.

### QA import sidecars

- The three PNGs and WAV under `docs/qa/` are test evidence, are not referenced by the Main scene, and are not runtime source assets.
- Their `.import` files contained default importer metadata and generated UIDs. In this context they were reproducible metadata that should not be part of the runtime asset graph.
- Added `docs/qa/.gdignore` so Godot excludes the QA evidence directory from resource scanning.
- Removed only the four untracked `.import` sidecars. The original PNG, WAV, log, and report files remain unchanged.
- A fresh Godot editor import did not recreate the sidecars and no longer listed the QA media in `filesystem_cache10`.

### Ignore rules

- `.godot/` is ignored.
- `.DS_Store` is ignored.
- `builds/`, `exports/`, and common exported package types (`*.app`, `*.dmg`, `*.pck`, `*.zip`) are ignored.
- No `.gitignore` edit was necessary in this pass.

### Commands and results

1. `Godot --headless --path . --script /tmp/nocturne_keep_project_settings_audit.gd`
   - First attempt: failed because the temporary audit script called a nonexistent `ProjectSettings.get_initial_value()` API. This was an audit-script parse failure, not a project error.
   - Corrected attempt: exit 0; confirmed both setting names, the old mipmap-filter value `false`, and Canvas default filter `0` after the project update.
2. `Godot --headless --editor --path . --import --quit --log-file /tmp/nocturne_keep_m0_import.log`
   - Result: exit 0; filesystem scan and editor initialization completed without script or resource errors.
3. `Godot --headless --path . --quit-after 5 --log-file /tmp/nocturne_keep_m0_startup.log`
   - Result: exit 0; the configured Main scene started and exited without error.
4. `Godot --path . --write-movie /tmp/nocturne_keep_m0_final.png --fixed-fps 30 --quit-after 2 --audio-driver Dummy`
   - Result: exit 0; OpenGL Compatibility initialized on Apple M4 and rendered two 1280×720 frames. The reviewed frame shows the intact M0 title scene.
5. `find docs/qa -maxdepth 1 -type f -name '*.import' -print`
   - Result: no output after import; the four QA sidecars were not recreated.
6. `git diff --check`
   - Result: no whitespace errors.

### Manual acceptance

1. Open the project in Godot 4.7.1 and confirm `docs/qa/` is excluded from the FileSystem asset index.
2. Run the project with `F5` and confirm the M0 title scene remains visible.
3. Confirm Project Settings → Rendering → Textures → Canvas Textures → Default Texture Filter is `Nearest`.

### Known limitations

- M0 contains no pixel-art textures, so the setting value is verified programmatically; its visual effect will first be observable when a pixel texture is introduced in an approved later milestone.
- This pass does not add or test any M1 gameplay behavior.

## Pre-M1 tool — Pixel character concept generator

Date: 2026-07-21
Status: complete — awaiting visual approval; M1 remains paused

### Goals and scope

- Replace the unavailable Figma workflow with a local Godot 4.7.1/GDScript pixel-character tool.
- Generate an original 16-bit-inspired Concept C for The Night Warden at 64px plus a 48px readability floor.
- Deliver front, side, silhouette, dagger, palette, key-pose, preview, and 1600×1000 board PNGs.
- Keep the formal Main scene and all M1 movement/gameplay behavior unchanged.
- Use no downloaded assets, online image generators, or paid external services.

### Files planned

- Tool scene: `scenes/tools/character_design_lab.tscn`.
- Tool scripts: pixel canvas, character generator, board exporter, and preview orchestrator under `scripts/tools/`.
- Generated sources: `assets/sprites/player/concept_c/`.
- Design/QA: `docs/design/pixel_character_spec.md`, character board, lab preview, and QA report.
- Validation: `tests/tools/validate_pixel_character_assets.gd`.

### Scope check

- No `CharacterBody2D`, movement, input action, collision, combat system, combo state, enemy, map, or level behavior was added.
- `project.godot` and `scenes/main/main.tscn` were not modified.
- The concept lab is independently runnable and is not configured as the project Main scene.
- The attack drawings describe one basic attack only: main-hand slash followed by an offhand visual follow-through.

### Implementation notes

- Character pixels are authored directly on low-resolution `Image` canvases through clipped `fill_rect`, `set_pixel`, and Bresenham line operations.
- 48px studies use nearest-neighbor resizing; board and lab previews use exact integer scaling.
- The fixed requested five-color palette was retained without adjustment.
- Import sidecars are retained for source assets because they record `compress/mode=0` and `mipmaps/generate=false`; `.godot/` remains ignored.
- The board is composed inside an isolated 1600×1000 `SubViewport`; it does not alter the project viewport or formal UI.

### Commands and actual results

1. `Godot --headless --editor --path . --import --quit`
   - Initial parse/import completed and registered the four tool classes without parser errors.
   - The surrounding zsh wrapper initially attempted to assign the reserved variable `status`; the editor command itself exited successfully. The wrapper was corrected to task-specific variable names for later commands.
2. `Godot --headless --path . scenes/tools/character_design_lab.tscn -- --generate-only --skip-board`
   - First attempt exposed empty exported NodePaths in the hand-authored scene; switched the scene to typed unique-node references.
   - Second attempt exposed GDScript typed-array literal conversion errors; replaced calls with explicitly typed local arrays.
   - Corrected result: exit 0; all eleven transparent asset PNGs generated without warnings or errors.
3. `Godot --path . scenes/tools/character_design_lab.tscn --audio-driver Dummy -- --generate-only`
   - Result: exit 0 under the GL Compatibility renderer on Apple M4; the 1600×1000 design board was generated.
4. `Godot --headless --editor --path . --import --quit`
   - Result: exit 0; all generated PNGs imported as textures, with no script or resource errors.
5. `Godot --headless --path . --script res://tests/tools/validate_pixel_character_assets.gd`
   - First validation compared all raw bytes and correctly revealed that the importer normalizes RGB channels beneath fully transparent pixels. The check was narrowed to alpha plus visible RGBA pixels.
   - Final result: exit 0; `PIXEL_CHARACTER_VALIDATION: PASS (11 assets + board)` with no warnings or errors.
6. `Godot --path . scenes/tools/character_design_lab.tscn --write-movie /tmp/nocturne_keep_character_lab_final.png --fixed-fps 1 --quit-after 6 --audio-driver Dummy`
   - Result: exit 0; six deterministic preview frames rendered. The final completed frame was preserved as `docs/qa/character_design_lab_preview.png`.
   - Visual review found the first layout used native texture size despite integer-sized containers; `TextureRect` was corrected to explicit Nearest scaling and the QA image was regenerated.
7. `Godot --headless --path . --quit-after 5`
   - Final result: exit 0; the configured formal Main scene started and stopped without warnings or errors.
8. `Godot --headless --path . scenes/tools/character_design_lab.tscn -- --generate-only --skip-board`
   - Final result: exit 0; the independent lab generated all low-resolution PNG sources without a rendering display.
9. Final parallel check: Main startup, pixel asset validator, and headless lab generation.
   - Result: all three processes exited 0; validator reported `PASS (11 assets + board)`.

### Visual acceptance results

- The 64px front/side views read as the same character.
- The pointed hood, pale eye, segmented torso, separate legs, short mantle, and warm clasp remain visible.
- The main dagger clearly establishes right-facing orientation; the shorter offhand blade remains behind the body.
- The 48px side view remains recognizable without anti-aliased or partial-alpha pixels.
- The black silhouette retains hood, posture, weapon directions, mantle projection, and leg gap.
- Board and lab screenshots were reviewed directly and are linked from `docs/qa/pixel_character_report.md`.

### Manual acceptance

1. Open `scenes/tools/character_design_lab.tscn` in Godot 4.7.1 and press `F6`.
2. Confirm the status reaches `Export complete` and every preview group is visible by scrolling.
3. Confirm character and dagger edges remain sharp and the 48px views are readable.
4. Press the regenerate button and confirm the PNG/board timestamps update without changing the Main scene.
5. Review the decisions listed at the end of `docs/design/pixel_character_spec.md` before approving any animation or M1 work.

### Known limitations

- The output is a concept baseline and three static key poses, not a final sprite sheet.
- Board text uses system fonts, so a regenerated board may have small cross-platform typography differences; the character pixel data is deterministic.
- M1 player movement remains intentionally unstarted in this pass.

## Pre-M1 art production — Player pixel animation batch 01

Date: 2026-07-21
Status: complete — awaiting animation approval; M1 remains paused

### Goals and scope

- Preserve the approved front, side, dash, and attack static art as reference material instead of deleting it.
- Extend the black-hooded dual-dagger design into 21 usable transparent 64×64 frames: Idle 4, Run 6, Dash 5, Attack 6.
- Provide an independently runnable `AnimatedSprite2D` preview with manual action switching.
- Validate a 48×48 readability floor without creating gameplay code, player controllers, enemies, bosses, maps, or formal Main integration.

### Files planned and delivered

- Animation outputs and reference copies: `assets/sprites/player/assassin/`.
- Pose, renderer, sequence generator, QA sheet, and preview controller: `scripts/tools/`.
- Independent preview: `scenes/tools/player_animation_preview.tscn`.
- Automated validation: `tests/tools/validate_player_animation_assets.gd`.
- Visual QA and updated specification: `docs/qa/player_animation_*` and `docs/design/pixel_character_spec.md`.

### Preflight version-control state

- Before this batch, `project.godot` was the only modified file.
- Its sole diff moved `textures/canvas_textures/default_texture_filter=0` above the renderer keys. The key and value were unchanged, so the diff was an editor-normalized ordering change with no rendering behavior change.
- The Nearest filter remained active. No additional project setting or formal Main change was made for this batch.

### Implementation notes

- A typed pose object stores the torso, hood, hands, knees, feet, blade tips, and mantle tip for each frame.
- One renderer draws every pose with the same anatomy construction, proportions, dagger language, and fixed five-color palette.
- The first animation pass exports separate PNGs rather than an atlas, keeping every frame directly inspectable and replaceable.
- The original four reference images are copied byte-for-byte into `reference/`; the original `concept_c/` files remain in place.
- Preview textures are created from the generated images and explicitly use Nearest filtering at 6× integer scale.
- Source `.import` sidecars retain Lossless compression and disabled mipmaps; `.godot/` remains ignored.

### Commands and actual results

1. `Godot --version`
   - Result: `4.7.1.stable.official.a13da4feb`.
2. `Godot --headless --path . scenes/tools/player_animation_preview.tscn -- --generate-only`
   - First attempt ran before the editor class scan and could not resolve the newly added global pose class. No assets were lost; the process was stopped.
   - After the required editor import, result: exit 0; `PLAYER_ANIMATION_EXPORT: 21 frames + 4 references`.
3. `Godot --headless --editor --path . --quit`
   - Result: exit 0; registered new global classes and imported all 25 animation/reference PNGs without resource errors.
4. `Godot --headless --path . --script tests/tools/validate_player_animation_assets.gd`
   - Result: exit 0; `PLAYER_ANIMATION_VALIDATION: PASS (21 frames + 4 byte-identical references)`.
5. `Godot --headless --path . scenes/tools/player_animation_preview.tscn --quit-after 3`
   - Result: exit 0; independent animation preview loaded, generated frames, and played without script/resource errors.
6. `Godot --headless --path . --quit-after 3`
   - Result: exit 0; configured formal Main loaded and exited without errors.

### Visual acceptance results

- The 21-frame QA contact sheet was reviewed directly at original resolution.
- Idle remains deliberately subtle; Run uses a readable six-frame alternating stride.
- Dash uses a lower, longer travel silhouette with rear-leg extension.
- Attack uses a planted lunge, extended main-hand thrust, rear support dagger, and distinct follow-through.
- All four representative 48px checks retain hood, eye, legs, and both weapon directions without smoothing.

### Scope check and known limitations

- No formal gameplay scene, input action, movement state, collision, combat logic, combo system, enemy, boss, or map was added.
- The preview is a design tool and is not configured as the project Main scene.
- No atlas or `.tres` SpriteFrames resource is delivered yet; this batch uses individual PNGs and runtime-built preview frames.
- Motion timing is an initial art-production cadence and still requires user approval before formal player integration.

## Pre-M1 presentation integration — Player animation system

Date: 2026-07-21
Status: complete — awaiting animation-system approval; M1 gameplay remains paused

### Goals and scope

- Integrate the existing 21 production frames into one persistent `SpriteFrames` resource with exact names, FPS values, and loop flags.
- Add clearly marked temporary frames for the six not-yet-authored actions: jump start, jump loop, fall, land, hurt, and death.
- Build a typed, presentation-only `PlayerAnimationController` with priority, one-shot, direction-lock, and completion-signal behavior.
- Upgrade the independent preview to expose all ten animations, playback controls, direction flipping, and live metadata.
- Preserve all existing concept and reference PNGs and keep the formal Main scene unchanged.

### Planned files

- `scripts/player/player_animation_controller.gd` for animation selection and presentation locks only.
- `resources/player/player_sprite_frames.tres` for persistent animation configuration.
- `assets/sprites/player/assassin/placeholder/` for explicitly temporary PNG frames.
- Updated `scenes/tools/player_animation_preview.tscn` and its tool controller.
- `docs/design/player_animation_spec.md`, this log, and focused automated tests.

### Planned validation

- Headless editor import/parse with Godot 4.7.1.
- Resource assertions for all names, counts, speeds, loop flags, texture imports, and shared foot baseline.
- Controller assertions for priority, idempotent replay prevention, one-shot completion, loop behavior, and facing locks.
- Independent preview startup and configured formal Main startup.

### Scope guard

- No movement physics, collision, input map, health, damage, hitbox implementation, combo, enemy, boss, level, or formal player scene integration is authorized in this batch.

### Delivered architecture

- Persistent `SpriteFrames`: ten snake_case animations with the requested counts, rates, and loop flags.
- Composition: `PreviewRoot / Player / VisualRoot / AnimatedSprite2D` plus sibling `AnimationController`.
- Presentation controller: typed signals, one-shot priority locks, Attack/Dash direction locks, queued facing, idempotent replay prevention, pause/resume/restart, and explicit reset.
- Attack timing interface: zero-based frames `2` and `3`, corresponding to `attack_03` and `attack_04`; no hitbox or damage behavior was added.
- Missing art: 19 PNGs under the dedicated `placeholder/` directory, with `placeholder_` prefixes and documentation labels.
- Reference preservation: all four reference PNGs remain present and unchanged.

### Commands and actual results

1. `Godot --headless --editor --path . --quit`
   - Initial pass registered the new builder/controller classes and imported assets.
   - It exposed that a constructed `PackedInt32Array` is not a valid constant expression in Godot 4.7.1. The Attack window constant was corrected to a typed `Array[int]`, and the following import completed without parser/resource errors.
2. `Godot --headless --path . --script scripts/tools/build_player_animation_assets.gd -- --placeholders-only`
   - Result: exit 0; `PLAYER_PLACEHOLDER_EXPORT: 19 files, 0 failures`.
3. `Godot --headless --path . --script scripts/tools/build_player_animation_assets.gd`
   - Result: exit 0; `PLAYER_SPRITE_FRAMES_BUILD: OK`.
4. `Godot --headless --path . scenes/tools/player_animation_preview.tscn --quit-after 3`
   - Result: exit 0 after the constant fix; the independently runnable preview loaded the persistent SpriteFrames without errors.
5. `Godot --headless --path . --script tests/player/test_player_animation_system.gd`
   - First run revealed a test-side API type mismatch (`get_animation_names()` returns `PackedStringArray`) and a real one-pixel baseline mismatch in `dash_03`.
   - The test type was corrected. The Dash core source pose was shifted down one pixel, and production/placeholder assets were regenerated.
   - Final result: exit 0; `PLAYER_ANIMATION_SYSTEM_TEST: PASS (10 animations, controller locks/signals verified)`.
6. `Godot --path . scenes/tools/player_animation_preview.tscn --write-movie /tmp/nocturne_keep_spriteframes_preview.png --fixed-fps 10 --quit-after 3 --audio-driver Dummy`
   - Result: exit 0; GL Compatibility rendered the preview at 1280×720 on Apple M4.
   - Visual review confirmed sharp 6× pixel scaling, complete metadata, ten action buttons, playback controls, and explicit placeholder labels. The ground guide was moved above the metadata after this review.
7. Final regression: legacy concept validator, 21-frame source validator, 40-frame system/controller test, independent preview startup, configured Main startup, and `git diff --check`.
   - Result: all commands exited 0. Reports: `PIXEL_CHARACTER_VALIDATION: PASS`, `PLAYER_ANIMATION_VALIDATION: PASS`, `PLAYER_ANIMATION_SYSTEM_TEST: PASS`, and `FINAL_PLAYER_ANIMATION_REGRESSION:PASS`.
8. Priority tightening regression: editor parse, system/controller test, preview startup, Main startup, and whitespace check.
   - Result: all commands exited 0; the system test remained `PASS` after adding explicit loop-priority release behavior.

### Automated acceptance results

- Exactly the ten required animation names exist; no extra animation is present.
- Counts, FPS, and loop flags match the specification.
- All 40 integrated frames are 64×64, binary-alpha, imported textures without mipmaps.
- Idle/Run/Dash/Attack/Land/Hurt share visible ground row `y=60`.
- Dash's first four frames span 0.20 seconds and its fifth frame completes before `one_shot_finished`.
- Attack reaches frame six; `attack_03` and `attack_04` are the only reserved hit-window frames.
- Same-animation requests do not rewind; looping actions do not emit one-shot completion.
- Priority, Death persistence, Attack/Dash facing locks, queued flip, and unchanged sprite position all pass.
- Lower-priority loops cannot overwrite higher-priority loops unless the caller explicitly authorizes a completed state transition.

### Manual acceptance

1. Run `scenes/tools/player_animation_preview.tscn` with `F6`.
2. Select all ten buttons and confirm the production/placeholder label, frame count, FPS, and mode.
3. During Dash or Attack, request the opposite facing and confirm it applies only after completion.
4. Pause, resume, and restart both a loop and a one-shot.
5. Confirm `attack_03` and `attack_04` display `HIT WINDOW` only as preview metadata.

### Known limitations and scope check

- Jump Start, Jump Loop, Fall, Land, Hurt, and Death use integration placeholders and require authored final frames later.
- This system does not decide locomotion state; a future approved player state machine will call the presentation API.
- `one_shot_finished` is an animation event only and has no damage, invulnerability, physics, or gameplay side effects.
- Formal Main and its startup scene remain unchanged; no M1, enemy, boss, level, or combat functionality was added.

## M1 — Animation completion and player movement integration

Date: 2026-07-21
Status: complete — awaiting M1 gameplay approval

### Goals and scope

- Replace only the Jump Start, Jump Loop, Fall, and Land placeholder art with formal 64×64 five-color pixel frames.
- Revalidate the existing four-frame Idle and six-frame Run loops, preserving them unless a concrete anchor/readability defect is found.
- Add the formal `CharacterBody2D` player with horizontal acceleration/deceleration, air control, gravity, jumping, 0.10-second coyote time, and 0.12-second jump buffering.
- Add dedicated player movement input actions, a following `Camera2D`, collision, facing, and the six-state M1 animation flow.
- Integrate the Player into Main with only minimal collision geometry needed to exercise M1 movement.

### Planned files

- Formal M1 animation PNGs under `assets/sprites/player/assassin/{jump_start,jump_loop,fall,land}/`.
- Updated SpriteFrames builder/resource and preview metadata.
- Player movement config resource, `scripts/player/player.gd`, and `scenes/player/player.tscn`.
- M1 input entries in `project.godot` and a minimal movement test space in `scenes/main/main.tscn`.
- Deterministic animation/movement tests, QA evidence, this log, and `docs/design/player_animation_spec.md`.

### Baseline tuning from the Master Prompt

- `move_speed=220`, `ground_acceleration=1400`, `ground_deceleration=1700`, `air_acceleration=850`.
- `jump_velocity=-420`, `gravity=1100`, `coyote_time=0.10`, `jump_buffer_time=0.12`.
- No tuning changes are planned before actual runtime evidence.

### Planned validation

- Exact animation names/counts/FPS/loop flags, transparency, no mipmaps, 48px readability, anchor and grounded baseline checks.
- Deterministic movement acceleration/deceleration, collision, jump, coyote-time, jump-buffer, facing, camera, and animation-state checks.
- Independent Player scene, animation preview, and formal Main startup/render checks with Godot 4.7.1.

### M2 exclusion guard

- Dash and Attack art/resource entries remain available in the preview only; the formal M1 Player must never request them.
- Hurt and Death remain explicitly marked placeholders and are not called by M1 gameplay.
- No hitbox, damage, health, invulnerability, dash movement, attack input, hurt/death flow, enemy, boss, or level-production system is authorized.

### Delivered animation art

- Replaced the eight temporary Jump Start, Jump Loop, Fall, and Land PNGs with authored 64×64 transparent five-color pixel frames in dedicated production directories.
- Removed only the superseded M1 placeholder PNGs and their import sidecars after verifying that the rebuilt SpriteFrames resource no longer referenced them. Hurt and Death placeholders remain intact.
- Revalidated the approved four-frame Idle and six-frame Run loops without overwriting them; their feet, alternating strides, dagger separation, and shared canvas anchor remained suitable for M1.
- Generated `docs/qa/m1_player_animation_contact_sheet.png`, including nearest-neighbor 64px presentation and 48px readability samples.
- Kept every Dash, Attack, concept, and `reference/` image unchanged.

### Delivered Player integration

- Added a reusable `CharacterBody2D` Player scene with `VisualRoot/AnimatedSprite2D`, `CollisionShape2D`, following `Camera2D`, and the existing `PlayerAnimationController` as `AnimationController`.
- Added a typed movement configuration resource using the approved tuning values and no terminal-velocity cap.
- Added dedicated A/D, arrow-key, and Space input actions through a reproducible InputMap configuration script.
- Implemented ground acceleration/deceleration, air control, gravity, single jump, 0.10-second coyote time, 0.12-second input buffering, collision via `move_and_slide()`, and controller-owned horizontal facing.
- Implemented an explicit six-state M1 animation flow. One-shot completion now releases presentation locks before notifying the Player, allowing Jump Start and Land callbacks to select their next locomotion state without replaying frame zero.
- Replaced the M0 title-only Main contents with a minimal M1 movement test room, static collision floor/platforms, the instanced Player, and controls legend. The configured Main path itself was not changed.

### Commands and actual results

1. `Godot --headless --path . --script scripts/tools/build_player_animation_assets.gd -- --m1-animation-only`
   - Result: exit 0; `PLAYER_M1_ANIMATION_EXPORT: 8 files, 0 failures`.
2. `Godot --headless --editor --path . --quit`
   - Result: exit 0; imported the new PNGs and parsed the new scene/scripts without resource errors.
3. `Godot --headless --path . --script scripts/tools/build_player_animation_assets.gd`
   - Result: exit 0; `PLAYER_SPRITE_FRAMES_BUILD: OK`; formal M1 paths replaced the old placeholder references.
4. `Godot --headless --path . --script scripts/tools/configure_m1_input_map.gd`
   - Result: exit 0; `M1_INPUT_MAP_CONFIG: OK`.
5. `Godot --headless --path . --script tests/player/test_m1_player_movement.gd`
   - The first test revision released its synthetic jump input before the Player's physics callback and therefore did not exercise the jump. The harness was corrected to hold input across physics frames.
   - Final result: exit 0; `M1_PLAYER_MOVEMENT_TEST: PASS (movement, jump assists, collision, camera, six animations)`.
6. Consolidated regression: concept asset validator, 21-frame source validator, ten-animation/controller test, M1 movement test, standalone Player startup, animation preview startup, and configured Main startup.
   - Result: every command exited 0. Reports: `PIXEL_CHARACTER_VALIDATION: PASS`, `PLAYER_ANIMATION_VALIDATION: PASS`, `PLAYER_ANIMATION_SYSTEM_TEST: PASS`, and `M1_PLAYER_MOVEMENT_TEST: PASS`.
7. `Godot --path . --write-movie /tmp/nocturne_keep_m1_main.png --fixed-fps 30 --quit-after 3 --audio-driver Dummy`
   - Result: exit 0 using GL Compatibility on Apple M4. Visual review confirmed the Player on collision ground, sharp pixels, intact camera presentation, and readable M1 controls.
8. `Godot --path . scenes/tools/player_animation_preview.tscn --write-movie /tmp/nocturne_keep_m1_preview.png --fixed-fps 10 --quit-after 3 --audio-driver Dummy`
   - Result: exit 0. Visual review confirmed Jump Start/Loop/Fall/Land are shown as production art while only Hurt and Death retain placeholder labels.

### Automated acceptance results

- All six M1 animation groups have the required counts, FPS, and loop flags; the four newly authored groups use formal paths rather than `placeholder/`.
- Jump Start, Jump Loop, Fall, and Land have distinct image hashes and visually distinct silhouettes.
- All tested frames are 64×64, transparent, imported without mipmaps, and retain readable 48×48 nearest-neighbor reductions.
- Ground acceleration reaches 220 px/s, deceleration returns to zero, left-facing uses `flip_h`, and the sprite node does not move while flipping.
- The runtime sequence reaches Jump Start, Jump Loop, Fall, Land, and the correct grounded loop without per-frame restarts.
- Coyote-time jump and buffered-on-landing jump both pass with real physics-frame input and collision.
- Player settles on the floor without penetration; its enabled child Camera2D follows the Player.
- Horizontal input or a new accepted jump can interrupt Land.
- Formal Player state constants and animation requests contain no Dash, Attack, Hurt, or Death entry.

### Manual acceptance requested

1. Run the configured project and evaluate horizontal acceleration/deceleration feel with A/D and arrow keys.
2. Walk off a platform and press Space within 0.10 seconds to judge coyote-time feel rather than only functional correctness.
3. Press Space just before landing to judge the 0.12-second input-buffer feel.
4. Check Jump Start, rising loop, Fall, and Land transitions at normal speed in both facing directions.
5. Run `scenes/tools/player_animation_preview.tscn` and confirm Dash/Attack still play there but never activate during formal movement.

### Known limitations and handoff

- Main is an intentionally minimal movement laboratory, not a production level.
- Jump Loop and Fall use two frames each by design; they prioritize readable poses over ornamental motion.
- Hurt and Death remain explicit preview placeholders.
- Dash, Attack, Hurt, Death gameplay, health/damage, hitboxes, enemies, bosses, and level production remain deferred to M2 or later and require separate approval.

## M1.5 — Player action prototype

Date: 2026-07-21
Status: complete — awaiting M1.5 prototype approval

### Goals and scope

- Audit the committed Attack/Dash PNGs, persistent SpriteFrames entries, and independent preview controls before changing gameplay.
- Add debug-enabled double-jump capability with a locked-by-default formal ability flag, one recoverable air jump, and no third jump.
- Add one ground-only Dash prototype with fixed motion timing/cooldown and no invulnerability.
- Add one Attack animation trigger with no damage, hitbox, combo, or enemy interaction.
- Preserve the M1 locomotion flow, all reference art, the preview tool, and the existing Commit history.

### Preflight audit

- Git worktree was clean at milestone start; baseline commit: `cda7bdc feat: complete M1 player movement and animations`.
- Both `assets/sprites/player/assassin/attack/` and `assets/sprites/player/assassin/dash/` exist.
- All requested source frames exist: `attack_01.png` through `attack_06.png` and `dash_01.png` through `dash_05.png`.
- `resources/player/player_sprite_frames.tres` contains non-looping `attack` at 12 FPS and non-looping `dash` at 20 FPS with the complete frame paths.
- `scenes/tools/player_animation_preview.tscn` exposes dedicated Dash and Attack buttons. Its controller maps keys 7 and 8 to the same animations and calls the shared `PlayerAnimationController`.
- Formal M1 gameplay did not show either action because `scripts/player/player.gd` intentionally contained only the six M1 locomotion states and `project.godot` contained no Dash or Attack input actions.
- No missing art or SpriteFrames repair is required.

### Planned implementation

- Extend the reproducible Input Map with physical Shift for Dash and J for Attack.
- Store Dash speed, duration, and cooldown in a typed action-prototype Resource.
- Compose a focused `PlayerActionController` node beside the existing presentation controller; it will own action mutual exclusion, Dash timing, cooldown, and action completion signals.
- Keep jump/coyote/buffer physics in the Player, with explicit `has_double_jump`, `debug_enable_double_jump`, and `air_jumps_remaining` state.
- Add deterministic tests for asset audit, preview selection, double-jump consumption/recovery, third-jump rejection, Dash timing/cooldown, Attack completion, facing locks, and locomotion non-overwrite.

### M2 exclusion guard

- No enemy, boss, health, damage, invulnerability, hitbox, hurtbox, combo, or completed Hurt/Death gameplay is authorized.
- `attack_03` and `attack_04` remain metadata-only future hit-window frames.
- `double_jump` is reserved as a future animation name; this prototype may reuse existing Jump Start/Loop art and must not label that fallback as final art.

### Delivered architecture and behavior

- Added physical Shift and J input actions without altering the existing movement/jump bindings.
- Added `PlayerActionPrototypeConfig` with Dash speed 480 px/s, motion duration 0.20 seconds, and cooldown 0.45 seconds.
- Added a composed `PlayerActionController` sibling node. It owns only Attack/Dash mutual exclusion, the Dash motion/cooldown timers, and typed `action_started`/`action_finished` signals.
- Extended Player with `has_double_jump=false`, `debug_enable_double_jump=true`, and `air_jumps_remaining`. Ground/coyote jumps preserve the air jump, the independent air path consumes one, landing restores it, and a third airborne jump is rejected.
- The existing 0.12-second buffer is shared by legal ground and air jump paths. The pre-move/landing guard prevents one input edge from producing two jumps in one frame.
- Reserved `double_jump` as the future animation name. The prototype explicitly resets and replays Jump Start as fallback art.
- Dash starts only while grounded, locks facing, blocks ordinary horizontal control, applies motion only during the first four 20-FPS frames, uses the fifth frame as recovery, and provides no invulnerability.
- Attack is animation-only, locks facing, cannot be restarted while active, and returns to the correct locomotion animation after frame six.
- Simultaneous Attack/Dash input selects Attack. Once either action begins, the component rejects the other until completion.
- Updated Main's internal test panel with all controls and an explicit debug-double-jump notice. The independent ten-animation preview remains intact.

### Commands and actual results

1. Filesystem/SpriteFrames/scene audit using `find`, `stat`, `shasum`, and `rg`.
   - Result: both action directories and all 11 PNGs present; SpriteFrames entries complete; preview buttons/key mappings present; formal M1 absence traced to deliberate Player/Input scope rather than missing art.
2. `Godot --headless --editor --path . --quit`
   - Result: exit 0; registered the new typed Resource/controller classes and parsed the updated Player scene without script/resource errors.
3. `Godot --headless --path . --script scripts/tools/configure_m1_input_map.gd`
   - Result: exit 0; `M15_INPUT_MAP_CONFIG: OK`; physical Shift and J serialized into `project.godot`.
4. `Godot --headless --path . --script tests/player/test_m1_player_movement.gd`
   - Initial regression inherited the new debug capability and therefore correctly treated the old buffered-air test as a double jump. The M1-only harness was made explicit by disabling the debug override for that suite.
   - Final result: exit 0; `M1_PLAYER_MOVEMENT_TEST: PASS (movement, jump assists, collision, camera, six animations)`.
5. `Godot --headless --path . --script tests/player/test_m15_player_actions.gd`
   - The first integrated version passed. During the full regression, a fixed-frame assertion occasionally sampled after Dash completion; it was replaced with direct motion-timer/completion-state observation and then passed three consecutive runs.
   - Final result: exit 0; `M15_PLAYER_ACTION_TEST: PASS (assets, preview, double jump, dash, attack)`.
6. `Godot --path . --write-movie /tmp/nocturne_keep_m15_main.png --fixed-fps 30 --quit-after 3 --audio-driver Dummy`
   - Result: exit 0; rendered 1280×720 with GL Compatibility on Apple M4. Visual review confirmed sharp Player pixels and readable Move/Jump×2/Dash/Attack instructions.
7. `Godot --path . scenes/tools/player_animation_preview.tscn --write-movie /tmp/nocturne_keep_m15_preview.png --fixed-fps 10 --quit-after 2 --audio-driver Dummy`
   - Result: exit 0; preview retained its ten controls, production Attack/Dash entries, nearest-neighbor scaling, and placeholder labels only for Hurt/Death.
8. Final consolidated regression: editor import, concept validator, 21-frame/reference validator, ten-animation controller test, M1 movement test, M1.5 action test, standalone Player, preview, configured Main, and `git diff --check`.
   - Result: every command exited 0; `M15_FINAL_REGRESSION:PASS`.

### Automated acceptance results

- All 11 Attack/Dash files exist and the persistent resource exposes the correct counts, rates, and non-looping flags.
- Preview Dash and Attack buttons select and play the corresponding SpriteFrames animations.
- Formal ability flag defaults false while the current debug trial supplies exactly one air jump.
- Ground jump does not consume it; coyote applies only to the first jump; second jump consumes it; third jump is rejected; landing restores it.
- Air Dash is rejected. Ground Dash speed, motion window, recovery, facing lock, input blocking, completion, and cooldown pass.
- Attack wins simultaneous action input, survives ordinary movement requests, rejects restart spam, completes all six frames, and returns to Idle or Run.
- Existing controller validation still confirms only `attack_03` and `attack_04` report the reserved future hit window.
- Four original reference PNGs remain byte-identical.
- No new health, damage, invulnerability, combo, enemy, boss, hitbox, or hurtbox behavior exists.

### Manual acceptance requested

1. Press Space twice during one airborne arc, then press a third time and confirm only the first two jumps occur.
2. Land and repeat to confirm the debug air jump recovers.
3. Press Shift on the ground, judge the 0.20-second travel plus recovery feel, and verify rapid Shift presses respect cooldown.
4. Hold a direction and press J; confirm all six Attack frames finish before Run resumes and facing remains locked during the action.
5. Press J and Shift together; confirm Attack wins once without action restart loops.
6. Watch the Godot Output/Debugger during a normal manual session and report any environment-specific red error not reproduced by the automated suite.

### Known limitations and handoff

- `double_jump` has only a reserved name; Jump Start is temporary fallback art.
- Dash and Attack are prototypes, not a combat system. Dash has no invulnerability and Attack has no gameplay hit detection.
- Attack may play while airborne; on completion it returns to Jump Loop/Fall rather than forcing an invalid grounded animation.
- Main remains an internal movement/action laboratory rather than a production level.
- Hurt and Death remain preview placeholders with no formal Player trigger.

## M1.5 revision — Air Dash and dual-dagger thrust

Date: 2026-07-22
Status: complete — awaiting manual approval

### Goals and scope

- Replace the current ground-only Dash restriction with one horizontal air Dash per airborne cycle while retaining the existing ground Dash.
- Change the Input Map action from the provisional `player_dash` name to the approved `dash` action and bind physical Left Shift plus optional Right Shift.
- Split presentation names into `ground_dash` and `air_dash`, with clearly different grounded and airborne silhouettes.
- Archive all six pre-revision Attack PNGs before replacing the production sequence with a synchronous dual-dagger lunging thrust.
- Preserve the Attack hit-window metadata at frames three and four without creating a Hitbox, Hurtbox, damage, enemy, boss, or combo system.

### Preflight audit

- Git worktree was clean; baseline commit: `0e7be18 feat: add M1.5 player action prototype`.
- Existing ground Dash source contains five 64×64 transparent frames under `assets/sprites/player/assassin/dash/`; the persistent animation is named `dash` at 20 FPS.
- Existing Attack contains six 64×64 transparent frames under `assets/sprites/player/assassin/attack/`; its second, fifth, and related transition poses do not maintain a synchronous two-blade forward thrust.
- `PlayerActionController` currently rejects all airborne Dash attempts and stores only one generic Dash action state.
- `Player` currently reads the Input Map action `player_dash`; Gameplay contains no direct Shift-key polling.
- `docs/design/player_movement_spec.md` does not yet exist and will be created in this revision.

### Planned files and tests

- Update the procedural pose generator, production contact sheet, SpriteFrames builder/resource, animation controller, preview controller/scene, Player action component, Player integration, and reproducible Input Map writer.
- Add archived old Attack PNGs under a reference/deprecated directory and new `air_dash` production PNGs.
- Extend resource/controller tests for `ground_dash`, `air_dash`, frame counts, locks, hit-window metadata, and visual/action distinction.
- Extend Gameplay tests for rising/falling air Dash, direction selection, vertical freeze, single-use/reset, shared cooldown, gravity restoration, repeat rejection, and correct post-Dash locomotion.
- Run editor import, all existing regressions, standalone Player/preview/Main startup, and GL Compatibility visual captures with Godot 4.7.1.

### Scope guard

- No Attack movement will be added unless collision-safe behavior is clearly justified; this revision defaults to animation-only thrust.
- No actual hitbox node, hit detection, damage, health, invulnerability, enemy, boss, or combo behavior is authorized.
- Air Dash remains horizontal only; there is no vertical or diagonal Dash.

### Delivered implementation

- Replaced the provisional `player_dash` Input Map action with `dash`. It contains two physical Shift events distinguished by Left/Right key location. Gameplay reads only `Input.is_action_just_pressed(DASH_ACTION)` and contains no direct key polling.
- Split the former generic presentation name into non-looping `ground_dash` and `air_dash`, both five frames at 20 FPS. The old generic `dash` SpriteFrames alias was removed to prevent ambiguous state selection.
- Renamed the pre-existing five Ground Dash PNGs without art loss. Hash comparison confirmed each new `ground_dash_01`–`05` PNG is byte-identical to its corresponding former `dash_01`–`05` source; the duplicate old path was removed after verification.
- Added five original 64×64 Air Dash frames with a horizontal airborne body, retracted legs, close arms/blades, trailing mantle, transparent background, fixed canvas anchor, Nearest import, and no mipmaps.
- Archived all six previous Attack PNGs before production overwrite under `assets/sprites/player/assassin/reference/deprecated_attack_slash/`. SHA-256 evidence was captured before replacement and the archive files remain independently importable.
- Replaced Attack with six original 64×64 synchronous dual-dagger thrust frames: guard, compression, drive, core strike, held extension, and recovery. The two forward blades are vertically separated and no sweeping arc is present.
- Preserved `attack_03` and `attack_04` as query-only future hit-window metadata. No Hitbox, Hurtbox, damage, enemy, invulnerability, or combo node/logic was created.
- Extended `PlayerActionController` with explicit Ground Dash and Air Dash states, a stored horizontal direction, mutual exclusion, the existing 480 px/s travel speed, 0.20-second motion timer, and shared 0.45-second cooldown.
- Added `air_dash_available`. Air Dash can start while rising or falling, consumes the flag immediately, zeros vertical velocity, suspends gravity during the one-shot, rejects repeats, and resumes normal gravity afterward. Only an actual landing resets the flag; coyote time does not.
- Direction uses live horizontal input when present because facing is updated immediately before action dispatch; otherwise it uses current facing. Ground/Air Dash and Attack lock facing until completion and flip with `AnimatedSprite2D.flip_h` only.
- Updated the independent preview to eleven buttons/animations, the Main test overlay, reproducible asset/Input/SpriteFrames builders, placeholder regeneration references, asset validation, movement/animation specifications, README, and QA contact sheet/report.

### Commands and actual results

1. `Godot --headless --editor --path . --quit`
   - Exit 0. Godot 4.7.1 imported the new PNGs and parsed all typed scripts/scenes without errors.
2. `Godot --headless --path . --script scripts/tools/build_player_animation_assets.gd -- --archive-legacy-attack`
   - Exit 0; `PLAYER_ATTACK_ARCHIVE: 6 files, 0 failures`. This ran before overwriting production Attack.
3. `Godot --headless --path . --script scripts/tools/build_player_animation_assets.gd`
   - Exit 0; `PLAYER_PRODUCTION_EXPORT: 26 files, 0 failures`.
4. `Godot --headless --path . --script scripts/tools/configure_m1_input_map.gd`
   - Exit 0; `M15_INPUT_MAP_CONFIG: OK`. `dash` has Left and Right Shift; `player_dash` is absent.
5. `Godot --headless --path . --script scripts/tools/player_sprite_frames_builder.gd`
   - Exit 0; `PLAYER_SPRITE_FRAMES_BUILD: OK`.
6. `Godot --headless --path . --script tests/tools/validate_player_animation_assets.gd`
   - Exit 0; `PLAYER_ANIMATION_VALIDATION: PASS (26 frames + 4 byte-identical references)`.
7. `Godot --headless --path . --script tests/player/test_player_animation_system.gd`
   - Exit 0; `PLAYER_ANIMATION_SYSTEM_TEST: PASS (11 animations, controller locks/signals verified)`.
8. `Godot --headless --path . --script tests/player/test_m1_player_movement.gd`
   - Exit 0; `M1_PLAYER_MOVEMENT_TEST: PASS (movement, jump assists, collision, camera, six animations)`.
9. `Godot --headless --path . --script tests/player/test_m15_player_actions.gd`
   - Exit 0; `M15_PLAYER_ACTION_TEST: PASS (ground/air Dash, reset/cooldown, thrust Attack)`.
10. `Godot --path . --write-movie /tmp/nocturne_keep_air_dash_main.png --fixed-fps 30 --quit-after 2 --audio-driver Dummy`
    - Exit 0; Main rendered at 1280×720 through GL Compatibility with the Player, camera view, and updated Ground/Air Dash controls visible. No red Output/Debugger errors appeared.
11. `Godot --path . scenes/tools/player_animation_preview.tscn --write-movie /tmp/nocturne_keep_air_dash_preview.png --fixed-fps 10 --quit-after 2 --audio-driver Dummy`
    - Exit 0; preview rendered at 1280×720 with eleven controls including Ground Dash, Air Dash, and Attack. No red Output/Debugger errors appeared.
12. Original-resolution inspection of `docs/qa/player_animation_contact_sheet.png` plus `git diff --check`.
    - Visual result: Ground Dash reads planted, Air Dash reads airborne, Attack reads as two-blade forward thrust; pixel edges remain sharp. Diff check returned no whitespace errors.
13. Final consolidated regression also ran `tests/tools/validate_pixel_character_assets.gd` before every animation and movement suite.
    - Every command exited 0. Final reports: `PIXEL_CHARACTER_VALIDATION: PASS (11 assets + board)`, `PLAYER_ANIMATION_VALIDATION: PASS (26 frames + 4 byte-identical references)`, `PLAYER_ANIMATION_SYSTEM_TEST: PASS (11 animations, controller locks/signals verified)`, `M1_PLAYER_MOVEMENT_TEST: PASS (movement, jump assists, collision, camera, six animations)`, and `M15_PLAYER_ACTION_TEST: PASS (ground/air Dash, reset/cooldown, thrust Attack)`.

### Automated acceptance results

- Rising and falling Air Dash both start successfully; no-input direction uses facing and held input selects the matching direction.
- Air Dash zeros vertical velocity, pauses gravity, plays `air_dash`, consumes one availability flag, rejects a second airborne Dash, and restores normal gravity after completion.
- Landing restores exactly one Air Dash. Coyote time does not alter availability. Ground Dash does not consume the Air Dash.
- Ground and Air Dash share cooldown, cannot restart from repeated Shift edges, apply horizontal motion for the first four frames, and lock facing.
- The new Attack core has two separated forward Pale Steel blade bands and extends to the front edge of the 64×64 action silhouette. It differs from every archived slash frame.
- Attack rejects repeat input, cannot be overwritten by locomotion, preserves frames three/four as metadata-only, and recovers to grounded or airborne locomotion appropriately.
- Left-facing presentation uses `flip_h` without changing the player transform, collision, or sprite anchor.
- Main, preview, M1 locomotion, reference assets, and debug double jump remain intact.

### Manual acceptance requested

1. In Main, try Shift during both ascent and descent, then attempt a second Air Dash before landing.
2. Land and immediately retry to confirm availability resets reliably.
3. Compare Ground Dash and Air Dash at full speed, especially the legs and perceived ground contact.
4. Press J facing right and left and confirm both dagger tips read as a simultaneous thrust rather than a swing.
5. Hold movement during action completion and confirm Ground Dash/Attack recover to Run while Air Dash recovers to Fall/Jump Loop.

### Known limitations and handoff

- The Air Dash is deliberately horizontal-only and provides no invulnerability.
- Attack is presentation-only and adds no movement impulse; the future narrow forward Hitbox remains metadata, not a node.
- Hurt and Death remain explicitly labeled preview placeholders.
- Main remains an internal action laboratory, not a production level.
- No enemy, damage, Hitbox, Hurtbox, combo, Boss, or other M2 combat work was started.

## M1.5 extension — Dash Attack input chain

Date: 2026-07-22
Status: complete — awaiting manual feel approval

### Goals and scope

- Add one `dash_attack` action reachable from Ground Dash or Air Dash by buffered Shift/J input without requiring a same-frame chord.
- Preserve standalone Dash and standalone dual-dagger Attack behavior while introducing a configurable pairing window and attack-input buffer.
- Add one six-frame, 16-FPS, non-looping shared Dash Attack animation with distinct high-speed dual-thrust readability at 64×64 and 48×48.
- Apply inherited Dash direction and collision-safe CharacterBody2D movement, with reduced speed and recovery deceleration rather than a second full Dash.
- Expose metadata-only future hit-window frames three through five and add an optional test-scene debug overlay.

### Preflight audit

- Git worktree was clean; baseline commit: `ad94391 feat: add air dash and dual-dagger thrust`.
- Existing action state is one of None, Ground Dash, Air Dash, or Attack; Attack currently wins same-frame Shift/J and there is no cross-frame combination window.
- Input Map currently uses `dash` for Left/Right Shift and the legacy project-local name `player_attack` for J. This milestone will adopt the requested `attack` action and remove the old alias.
- `PlayerActionPrototypeConfig` currently centralizes Dash speed/duration/cooldown only; all Dash Attack timing and movement values will be added there.
- Ground/Air Dash and Attack are separate one-shots with facing locks. SpriteFrames currently contains eleven animations; no `dash_attack` source or resource entry exists.
- Existing Ground Dash, Air Dash, Attack, deprecated slash frames, concept references, M1 locomotion, debug double jump, and commit history must remain intact.

### Planned implementation and tests

- Extend the procedural animation generator, contact sheet, SpriteFrames builder/resource, animation controller, preview scene/controller, action configuration, action state component, Player physics integration, Main debug overlay, tests, and specifications.
- Use a 0.18-second post-Dash combination window and 0.12-second pre-Dash Attack buffer. The latter deliberately adds at most 120 ms to a standalone Attack so an Attack-first near-chord can resolve without briefly playing/canceling the normal Attack.
- Configure Dash Attack at 320 px/s with 0.18 seconds of sustained movement and 0.195 seconds of linear recovery, matching the complete 6/16-second animation while remaining below the 480 px/s Dash speed.
- Test standalone inputs, both chord orders, late rejection, one-use/restart protection, ground/air recovery, Air Dash preservation rules, collision against a wall, facing, metadata, scene startup, and all existing regressions.

### Scope guard

- No Hitbox node, target tracking, enemy, health, damage, invulnerability, combo tree, Hurt/Death Gameplay, or Boss behavior is authorized.
- Dash Attack may expose only a presentation query/signal contract for future frames three through five.
- Ground and Air Dash Attack share one animation in this first pass; code retains the airborne-origin flag for distinct gravity and recovery behavior.

### Delivered implementation

- Replaced the legacy Input Map name `player_attack` with the requested `attack` action bound to physical J. Dash remains `dash` with Left/Right Shift. Gameplay reads only named Input Map actions.
- Extended the typed action Resource with a 0.18-second post-Dash combination window, 0.12-second Attack-first buffer, 320 px/s Dash Attack speed, 0.18-second sustained movement, and 0.195-second recovery. The latter two total the full 0.375-second animation.
- Added explicit `DashAttack` state, `dash_attack_used`, Ground/Air origin tracking, window/buffer timers, inherited direction, direct near-chord start, Dash-to-Dash-Attack transition, and typed `action_transitioned` signal.
- Shift alone still starts Ground/Air Dash. J alone waits for the short pairing grace then starts normal Attack. J during the open Dash window transitions; J then Shift inside the buffer and same-frame Shift/J start Dash Attack directly.
- Late J during Dash is rejected instead of leaking into a later Attack. Dash Attack blocks normal Attack and Dash, ignores repeat input, and cannot restart its first frame.
- Dash Attack uses `CharacterBody2D.velocity` plus `move_and_slide()`: 320 px/s during the first 0.18 seconds, followed by linear deceleration for 0.195 seconds. It never writes `global_position` and passes a solid-wall collision test.
- Air Dash Attack consumes the existing Air Dash opportunity, holds vertical velocity at zero while active, then restores gravity and enters Fall unless an actual landing occurred. It never refreshes `air_dash_available`; only landing does.
- Added six original transparent 64×64 `dash_attack` PNGs, integrated them at 16 FPS non-looping, and preserved all existing Dash/Attack/reference/deprecated resources.
- Added `is_dash_attack_hit_window()` for metadata-only frames three through five. No Hitbox node, target memory, damage, enemy, combo, or Boss implementation exists.
- Added an optional Main action debug HUD showing current state, window/open time, use flag, Air Dash availability, and horizontal speed. Its checkbox disables the display without changing Gameplay.
- Updated the twelve-animation preview, production generator/contact sheet, SpriteFrames resource, validation suites, README, animation/movement specifications, and QA report.

### Commands and actual results

1. Preflight reads of `AGENTS.md`, README, development log, technical architecture, relevant scripts/resources/scenes/tests, plus `git status` and recent history.
   - Result: clean baseline `ad94391`; no prior Dash Attack art/state; existing Dash/Attack/reference assets intact.
2. Initial `Godot --headless --path . --script scripts/tools/build_player_animation_assets.gd` before production generation.
   - Result: the default SpriteFrames mode correctly reported six missing new Dash Attack textures. Existing source/reference PNGs were untouched; the temporarily incomplete SpriteFrames resource was rebuilt after import. The sequence was corrected rather than ignoring the errors.
3. `Godot --headless --path . --script scripts/tools/build_player_animation_assets.gd -- --production-only`
   - Exit 0; `PLAYER_PRODUCTION_EXPORT: 32 files, 0 failures`.
4. `Godot --headless --editor --path . --quit`, followed by the default SpriteFrames build.
   - Exit 0; six new PNGs imported without errors; `PLAYER_SPRITE_FRAMES_BUILD: OK`.
5. `Godot --headless --path . --script scripts/tools/configure_m1_input_map.gd`
   - Exit 0; `M15_INPUT_MAP_CONFIG: OK`; `dash` and `attack` are present, deprecated `player_dash`/`player_attack` are absent.
6. `Godot --headless --path . --script tests/tools/validate_pixel_character_assets.gd`
   - Exit 0; `PIXEL_CHARACTER_VALIDATION: PASS (11 assets + board)`.
7. `Godot --headless --path . --script tests/tools/validate_player_animation_assets.gd`
   - Exit 0; `PLAYER_ANIMATION_VALIDATION: PASS (32 frames + 4 byte-identical references)`.
8. `Godot --headless --path . --script tests/player/test_player_animation_system.gd`
   - Exit 0; `PLAYER_ANIMATION_SYSTEM_TEST: PASS (12 animations, controller locks/signals verified)`.
9. `Godot --headless --path . --script tests/player/test_m1_player_movement.gd`
   - Exit 0; `M1_PLAYER_MOVEMENT_TEST: PASS (movement, jump assists, collision, camera, six animations)`.
10. `Godot --headless --path . --script tests/player/test_m15_player_actions.gd`
    - Exit 0; `M15_PLAYER_ACTION_TEST: PASS (ground/air Dash, reset/cooldown, thrust Attack)`.
11. `Godot --headless --path . --script tests/player/test_dash_attack.gd`
    - The first timing assertion sampled one physics tick before the 0.18-second window closed; the test was corrected to sample the exact closed-window interval.
    - Final exit 0; `DASH_ATTACK_TEST: PASS (buffer, transitions, air recovery, collision, debug HUD)`.
12. `Godot --path . --write-movie /tmp/nocturne_keep_dash_attack_main.png --fixed-fps 30 --quit-after 2 --audio-driver Dummy`
    - Exit 0; Main rendered 1280×720 through GL Compatibility with complete controls and the action debug HUD. No red Output/Debugger errors appeared.
13. `Godot --path . scenes/tools/player_animation_preview.tscn --write-movie /tmp/nocturne_keep_dash_attack_preview.png --fixed-fps 10 --quit-after 2 --audio-driver Dummy`
    - Exit 0; preview rendered 1280×720 with twelve animation buttons including Dash Attack. No red Output/Debugger errors appeared.
14. Original-resolution review of `docs/qa/player_animation_contact_sheet.png` and `git diff --check`.
    - Result: Dash Attack reads as a low high-speed dual thrust distinct from regular Dash and Attack; its 48×48 check remains readable; no whitespace errors.

### Automated acceptance results

- Standalone Shift, standalone J, Dash-then-J, J-then-Shift, and same-frame Shift/J all resolve to the intended action.
- J after the 0.18-second combination window does not trigger Dash Attack or leak into a later Attack.
- Each Dash produces at most one Dash Attack; repeated J/Shift cannot restart, cancel, or nest it.
- Ground recovery reaches Run/Idle. Air recovery restores gravity, reaches Fall, keeps Air Dash spent, and restores it only on actual landing.
- Dash Attack inherits direction, locks facing, flips correctly, moves below full Dash speed, decelerates, and cannot pass through the test wall.
- SpriteFrames contains twelve correctly configured animations. Dash Attack frames are 64×64, binary-alpha, mipmap-free, palette-valid, and readable after 48×48 nearest-neighbor conversion.
- Future Dash Attack hit-window queries return true only on frames three, four, and five.
- Main and the preview scene remain independently runnable; all earlier movement, animation, double-jump, Dash, and Attack regressions pass.

### Manual acceptance requested

1. Press J alone repeatedly and judge whether the intentional 0.12-second pairing delay remains responsive enough.
2. Try Shift then J at the beginning and near the end of the 0.18-second window on ground and in air.
3. Compare the 320 px/s Dash Attack movement and recovery against the 480 px/s ordinary Dash.
4. Inspect frames three through five facing both directions and confirm both dagger tips remain distinct at gameplay scale.
5. Disable `ACTION DEBUG HUD` and confirm the laboratory view remains uncluttered.

### Known limitations and handoff

- Ground and Air Dash Attack intentionally share one animation; airborne origin is represented by world position and physics rather than a second art set.
- Supporting Attack-first pairing adds up to 0.12 seconds of latency to standalone Attack; this requires manual feel approval.
- Dash Attack has no invulnerability, gameplay Hitbox, target memory, damage, enemy interaction, or combo follow-up.
- Hurt and Death remain preview-only placeholders; Main remains an internal action laboratory.
- No enemy, formal damage settlement, combo tree, or Boss work was started.

## M1.5 refinement — Fast Attack response and buffering

Date: 2026-07-22
Status: complete — awaiting manual feel approval

### Goals and scope

- Compress the production `attack` animation from six frames at 12 FPS to four frames at 20 FPS, preserving a synchronous dual-dagger forward thrust and reducing input-to-core-pose latency to approximately 0.05 seconds.
- Add a single-entry, 0.10-second Attack input buffer that may restart the same basic Attack only from frame three onward or at natural completion; rapid J input must never restart frame one immediately.
- Compress `dash_attack` from six frames at 16 FPS to five frames at 20 FPS and align its future metadata-only hit window to frames three and four.
- Archive both superseded six-frame animation sequences before production overwrite and retain all earlier references/deprecated assets.
- Extend the optional debug HUD and deterministic tests with Attack frame, buffer timer, chain readiness, and measured input-to-effective-frame latency.

### Preflight audit

- Git worktree is clean at baseline commit `753003f feat: add buffered dash attack`.
- Standalone J currently waits up to 0.12 seconds in order to support the older J-first near-chord path. This conflicts with the new immediate-Attack requirement and will be removed.
- Same-frame Shift+J and Dash-then-J can remain Dash Attack paths. J-first will now start Attack immediately; the existing policy that Dash does not cancel Attack remains unchanged.
- Production `attack` and `dash_attack` each currently contain six transparent 64×64 PNG frames. SpriteFrames configures them at 12 FPS and 16 FPS respectively.
- Current future window metadata is Attack frames three/four and Dash Attack frames three/four/five. It will change to Attack frames two/three and Dash Attack frames three/four.

### Planned files and tests

- Update the pixel pose generator, archive/export tool, SpriteFrames builder/resource, animation controller, action config/controller, debug overlay, contact-sheet/asset validation, and affected Gameplay tests.
- Add `docs/design/player_combat_spec.md`; update README, animation specification, movement specification where its input contract is affected, QA report, and this development log.
- Verify immediate single Attack, approximately 0.05-second effective pose, one-entry buffer consumption, repeated complete attacks without frame-one starvation, movement/facing locks, five-frame Dash Attack duration, 48×48 readability, Main/preview startup, and all existing regressions with the exact Godot 4.7.1 executable.

### Scope guard

- This is one repeatable basic Attack animation, not a multi-animation combo tree.
- Dash still cannot cancel an active Attack; no new cancel matrix is introduced.
- No Hitbox node, target tracking, enemy, health, damage, invulnerability, Boss, Hurt Gameplay, or Death Gameplay is authorized.

### Delivered implementation

- Archived the immediately preceding six production Attack frames to `assets/sprites/player/assassin/reference/deprecated_attack_six_frame/` and six Dash Attack frames to `reference/deprecated_dash_attack_six_frame/`. Pre-overwrite SHA-256 comparison confirmed all twelve archive files are byte-identical to their production sources.
- Rebuilt Attack as four distinct 64×64 frames at 20 FPS: short compression, first dual-thrust core, held maximum extension/chain window, and rapid retraction. Future metadata is now exactly `attack_02` and `attack_03`.
- Rebuilt Dash Attack as five distinct 64×64 frames at 20 FPS: Dash carry-over, initial extension, arrow-shaped core, held thrust, and recovery. Future metadata is now exactly `dash_attack_03` and `dash_attack_04`.
- Removed the 0.12-second standalone-Attack pairing delay. J now dispatches Attack immediately; the effective `attack_02` timeline begins after one 20-FPS frame (`0.05 seconds`).
- Added a centralized `attack_buffer_time=0.10`. An active Attack stores at most one later J, never extends that entry from repeat spam, and consumes it only from frame three onward or at natural completion.
- Added an animation-controller-authorized same-one-shot restart that preserves animation/facing locks. Each consumed buffer restarts the same basic Attack exactly once and emits a new action-start event; it does not define a combo branch.
- Preserved the existing cancellation policy: Dash does not cancel Attack. Same-frame Shift+J and Dash-then-J still start Dash Attack, but J-first on an earlier frame is now an immediate normal Attack.
- Shortened Dash Attack movement to 0.15 seconds at 320 px/s plus 0.10 seconds of linear recovery, totaling the five-frame 0.25-second presentation.
- Extended the optional Main HUD with current Attack frame, buffer flag/timer, chain readiness, and input-to-first-effective-frame timeline. Updated Main labeling, SpriteFrames, preview data, procedural builders, placeholder dependencies, QA sheet/reports, README, animation/movement specifications, and the new combat-interface specification.

### Commands and actual results

1. `Godot --headless --path . --script scripts/tools/build_player_animation_assets.gd -- --archive-fast-attack-source`
   - Exit 0; `PLAYER_FAST_ATTACK_ARCHIVE: 12 files, 0 failures`.
   - `shasum -a 256` comparison before overwrite produced matching source/archive hashes for every old Attack and Dash Attack frame.
2. `Godot --headless --path . --script scripts/tools/build_player_animation_assets.gd -- --production-only`
   - Exit 0; `PLAYER_PRODUCTION_EXPORT: 29 files, 0 failures`. Obsolete production `attack_05`, `attack_06`, and `dash_attack_06` plus their import sidecars were removed only after archival.
3. First editor import after source compression
   - The editor reported the three removed frame paths because the persistent SpriteFrames resource still contained its old references. This was not ignored: the resource was immediately rebuilt with the new counts, and the final clean import below produced no error.
4. `Godot --headless --path . --script scripts/tools/build_player_animation_assets.gd`
   - Exit 0; `PLAYER_SPRITE_FRAMES_BUILD: OK` with Attack 4/20 FPS and Dash Attack 5/20 FPS.
5. Final `Godot --headless --editor --path . --import --quit --log-file /tmp/nocturne_keep_fast_attack_import.log`
   - Exit 0; no script/resource error or warning.
6. Serial automated suites with exact Godot 4.7.1 executable:
   - `validate_pixel_character_assets.gd`: `PASS (11 assets + board)`.
   - `validate_player_animation_assets.gd`: `PASS (29 frames + 4 byte-identical references)`; additionally validates both new six-frame archive directories.
   - `test_player_animation_system.gd`: `PASS (12 animations, controller locks/signals verified)`.
   - `test_m1_player_movement.gd`: `PASS (movement, jump assists, collision, camera, six animations)`.
   - `test_m15_player_actions.gd`: `PASS (ground/air Dash, reset/cooldown, thrust Attack)`.
   - `test_dash_attack.gd`: `PASS (immediate J, transitions, air recovery, collision, debug HUD)`.
   - `test_fast_attack.gd`: `PASS (immediate response, single buffer, four-repeat chain, 0.25s Dash Attack)`; repeated three consecutive runs also passed.
7. `Godot --path . --write-movie /tmp/nocturne_keep_fast_attack_main.png --fixed-fps 30 --quit-after 2 --audio-driver Dummy`
   - Exit 0; GL Compatibility initialized on Apple M4 and rendered two 1280×720 Main frames. The expanded two-line HUD fits the panel and the project Main remains intact.
8. `Godot --path . scenes/tools/player_animation_preview.tscn --write-movie /tmp/nocturne_keep_fast_attack_preview.png --fixed-fps 20 --quit-after 2 --audio-driver Dummy`
   - Exit 0; the independent twelve-animation preview rendered two 1280×720 frames without red Output/Debugger errors.
9. Original-resolution review of `docs/qa/player_animation_contact_sheet.png` and `git diff --check`
   - The new Attack row shows two separate forward blades on frames two/three; Dash Attack shows the longer arrow silhouette on frames three/four. Both 48px checks retain hood, legs, and two weapon bands. Diff check passed.

### Automated acceptance results

- A normal Attack enters the action state synchronously on its accepted J edge. It never waits for J release or a chord timeout.
- The timeline from accepted input to `attack_02` is exactly one 20-FPS frame (`0.05 seconds`) at normal speed.
- One early repeat J remains buffered through the locked first half, does not restart frame one, and is consumed once when `attack_03` opens the chain window.
- Four deliberately repeated Attacks each reached `attack_02` and `attack_03`; the action-start count matched the accepted input count, and stopping J allowed the final `attack_04` recovery to finish.
- Movement presentation and facing cannot overwrite active Attack. The preserved Dash-during-Attack request is rejected.
- Dash Attack retains collision-safe CharacterBody2D motion, reaches half speed midway through its 0.10-second recovery, and reaches zero at 0.25 seconds.
- Both actions remain dual-hand forward thrusts with vertically separated blades and no lateral arc. Their 48×48 nearest-neighbor checks remain readable.
- No Hitbox, Hurtbox, enemy, target memory, damage, health, invulnerability, Boss, or formal combo tree was added.

### Manual acceptance requested

1. Tap J once and judge whether the short frame-one compression and approximately 0.05-second first thrust feel immediate.
2. Tap J repeatedly at slow, medium, and rapid rhythms; confirm the character finishes readable thrust cycles instead of sticking on frame one.
3. Stop J after several repeats and confirm the final Attack retracts immediately into Idle/Run/air locomotion.
4. Compare normal Attack (compact, stationary, 0.20 seconds) with Dash Attack (longer silhouette, inherited movement, 0.25 seconds) facing both directions.
5. Confirm the chosen preserved rule—Shift cannot cancel an active Attack—matches the desired feel before any later cancel matrix is designed.

### Known limitations and handoff

- The one-entry buffer repeats one identical basic Attack; it has no alternating art, branch, damage scaling, target logic, or formal combo counter.
- Input-to-effective-frame diagnostics report the SpriteFrames timeline at current `speed_scale`; they are deterministic presentation timing, not operating-system input-latency profiling.
- The earlier J-first Dash Attack pairing was intentionally removed to satisfy immediate J response. Same-frame Shift+J and Dash-then-J remain supported.
- Dash Attack still has no damage, invulnerability, or gameplay Hitbox. Hurt/Death remain preview placeholders.
- No enemy, damage settlement, formal combo tree, or Boss work was started.
## 2026-07-22 — Continuous Dash and stamina milestone (preflight)

### Goal

- Replace the legacy long Dash cooldown with one-entry, edge-triggered Ground Dash chaining limited by stamina.
- Preserve one Air Dash per airborne cycle and keep Dash Attack compatible without charging stamina twice.
- Add a presentation-only stamina HUD and optional diagnostics while keeping stamina ownership in a dedicated player component.

### Planned files and tests

- Add a typed `PlayerStaminaComponent`, connect it to `PlayerActionController`, `Player`, and a signal-driven Main HUD.
- Split the Ground Dash presentation into `dash_start`, `dash_loop`, and `dash_end`; archive the current five-frame `ground_dash` source before replacement.
- Update production generators, SpriteFrames, animation preview, automated tests, README, movement/combat specifications, and add `docs/design/stamina_system_spec.md`.
- Verify independent Shift edges, one-entry Dash buffering, four full-stamina Dash starts, rejected fifth Dash without a charge, delayed/rate-limited regeneration, one Air Dash per airtime, Dash Attack compatibility, collision-safe movement, HUD synchronization, Main/preview startup, and a clean Godot 4.7.1 import.

### Scope guard

- This milestone adds no enemy, Boss, Hitbox, Hurtbox, health, damage, invulnerability, or additional skill system.
- Holding Shift will never synthesize repeated Dash input; every segment requires a new `dash` action edge.
- Landing restores only Air Dash eligibility. It neither refills stamina nor bypasses the regeneration delay.

### Delivered implementation

- Replaced the legacy 0.45-second Dash cooldown with 0.18-second paid segments, a 0.10-second one-entry Ground Dash buffer, and a 0.03-second minimum segment interval. Gameplay still reads only `Input.is_action_just_pressed("dash")`; holding Shift produces exactly one segment.
- Added the composed, typed `PlayerStaminaComponent`: 100 maximum, 25 per successful Ground/Air Dash, 0.60-second post-spend delay, 35 points/second regeneration, clamping, and `stamina_changed`, `stamina_depleted`, and `stamina_insufficient` signals.
- Ground Dash now moves through `dash_start` (2 frames), locked looping `dash_loop` (3 frames), and `dash_end` (2 frames), all at 20 FPS. A live paid chain resets only the collision-safe motion segment and remains in `dash_loop`, avoiding a standing recovery between segments.
- Archived the prior five Ground Dash PNGs byte-identically under `assets/sprites/player/assassin/reference/deprecated_ground_dash_five_frame/` before removing their obsolete production paths. SHA-256 comparison matched all five source/archive pairs.
- Preserved one Air Dash per airborne cycle. It costs stamina, ignores chained Shift, is restored only by landing, and never receives availability from Dash Attack or coyote time. Landing does not alter stamina.
- Dash Attack continues to inherit direction and collision-safe movement, clears a pending Dash request, and never charges the already-paid Dash again. Same-frame legal Shift+J pays exactly one Dash charge.
- Added a signal-driven fixed `Main/HUD/StaminaContainer` with 0–100 bar, numeric value, and one-shot insufficient feedback. Added optional diagnostics for stamina, regeneration timer, Dash buffer/time, segment number, Air Dash availability, action state, animation, and horizontal speed.
- Updated the fourteen-animation preview, 31-frame production generator/contact sheet, SpriteFrames resource, animation/action regressions, README, movement/animation/combat specifications, and the new stamina specification. No enemy, health, damage, Hitbox, Hurtbox, invulnerability, Boss, or other skill system was added.

### Commands and actual results

1. `Godot --headless --path . --script scripts/tools/build_player_animation_assets.gd -- --archive-ground-dash-source`
   - Exit 0; `PLAYER_GROUND_DASH_ARCHIVE: 5 files, 0 failures`.
   - `shasum -a 256` reported identical hashes for every old production frame and archived counterpart.
2. `Godot --headless --path . --script scripts/tools/build_player_animation_assets.gd -- --production-only`
   - Exit 0; `PLAYER_PRODUCTION_EXPORT: 31 files, 0 failures` and regenerated `docs/qa/player_animation_contact_sheet.png`.
3. `Godot --headless --path . --script scripts/tools/build_player_animation_assets.gd`
   - Exit 0; `PLAYER_SPRITE_FRAMES_BUILD: OK` with fourteen named animations.
4. `Godot --headless --path . --script scripts/tools/build_player_animation_assets.gd -- --remove-archived-ground-dash-source`
   - Exit 0; five exact obsolete sources removed only after byte comparison against the archive.
5. Final `Godot --headless --editor --path . --import --quit --log-file /tmp/nocturne_keep_chain_dash_final_import.log`
   - Exit 0; no script/resource error or warning.
6. Exact Godot 4.7.1 serial regression suite:
   - `validate_pixel_character_assets.gd`: `PASS (11 assets + board)`.
   - `validate_player_animation_assets.gd`: `PASS (31 frames + 4 byte-identical references)` and validates the five-frame Dash archive.
   - `test_player_animation_system.gd`: `PASS (14 animations, segmented Dash locks/signals verified)`.
   - `test_m1_player_movement.gd`: `PASS (movement, jump assists, collision, camera, six animations)`.
   - `test_m15_player_actions.gd`: `PASS (split Ground Dash, Air Dash reset, thrust Attack)`.
   - `test_dash_attack.gd`: `PASS (immediate J, transitions, air recovery, collision, debug HUD)`.
   - `test_fast_attack.gd`: `PASS (immediate response, single buffer, four-repeat chain, 0.25s Dash Attack)`.
   - `test_chain_dash_stamina.gd`: `PASS (edge chaining, four charges, air limit, HUD, collision)`.
7. `Godot --path . --write-movie /tmp/nocturne_keep_stamina_main.png --fixed-fps 30 --quit-after 2 --audio-driver Dummy`
   - Exit 0; GL Compatibility initialized on Apple M4 and rendered two 1280×720 Main frames. The fixed stamina HUD and three-line optional diagnostics fit without following the camera.
8. `Godot --path . scenes/tools/player_animation_preview.tscn --write-movie /tmp/nocturne_keep_stamina_preview.png --fixed-fps 20 --quit-after 2 --audio-driver Dummy`
   - Exit 0; independent fourteen-animation preview rendered two frames without red Output/Debugger errors.
9. Original-resolution review of Main, preview, and `docs/qa/player_animation_contact_sheet.png`, plus `git diff --check`
   - HUD values/layout are readable; all three Ground Dash phases retain crisp nearest-neighbor pixels and the common baseline; diff check passed.

### Automated acceptance results

- One Shift edge starts one Dash. Holding Shift across completion produced one action-start event and one 25-point charge.
- Four timed independent edges from full stamina produced four collision-safe Ground Dash segments and zero stamina. A fifth request started no action, spent nothing, and emitted one insufficient event.
- Each accepted chained segment stayed in the low `dash_loop`; only final/rejected continuation entered `dash_end`. All motion used `CharacterBody2D.velocity` and `move_and_slide()`, and the chained wall test stopped at the collider boundary.
- Regeneration remained zero through 0.59 seconds after spend, began after the 0.60-second threshold at 35 points/second, remained blocked during Dash/Dash Attack, and clamped to the configured maximum.
- Air Dash charged once and disabled `air_dash_available`; a second airborne Shift spent nothing. Air Dash Attack spent nothing extra, did not restore availability, and landing restored only availability while the zero-regeneration test value remained 75.
- The Main ProgressBar and numeric label updated to 75 immediately from the component signal. Insufficient feedback is a bounded tween, not a persistent flash.
- Existing immediate Attack buffering, Dash Attack transition/motion, locomotion, animation locks, Main startup, and preview startup all remain green.

### Manual acceptance requested

1. Tap Shift four times with the next tap late in each Dash and judge whether chained `dash_loop` motion feels seamless rather than visually restarting.
2. Hold Shift through a complete Dash and confirm it never repeats; then release and tap again to confirm a fresh edge is required.
3. Spend all four charges and judge the one-shot insufficient bar feedback; wait and confirm the bar starts climbing after the configured delay.
4. Verify one Air Dash per airtime, Air Dash-to-J Dash Attack, both facing directions, and wall contact in the Main trial scene.
5. Toggle `ACTION DEBUG HUD` off and confirm the production-facing stamina bar remains visible and camera-independent.

### Known limitations and handoff

- The stamina bar uses replaceable pixel-style `StyleBoxFlat` placeholders, not final UI art.
- Ground Dash chaining preserves the original direction and facing for the entire chain; a future explicit design decision is required before permitting per-segment turnarounds.
- Air Dash remains a single non-looping five-frame presentation and cannot chain regardless of spare stamina.
- Stamina currently pays only Dash-family starts. There are no upgrades, equipment modifiers, saves, consumables, enemies, damage, invulnerability, or formal skill framework.

## 2026-07-22 — Continuous Air Dash and ground-only stamina recovery (preflight)

### Goal

- Remove the one-Air-Dash-per-airtime qualification and make Ground/Air Dash chains share the same 100-point stamina pool as their only count limit.
- Add one-entry Air Dash and Dash Attack follow-up buffering, with per-segment direction selection and locked direction within each segment.
- Restrict regeneration and its delay countdown to grounded, non-Dash, non-Dash-Attack, non-Attack time.
- Split Air Dash presentation into `air_dash_start`, `air_dash_loop`, and `air_dash_end`, preserving the replaced five-frame source as a deprecated reference.

### Baseline audit

- Worktree is clean at `88118d4 feat: add chained dash stamina system`.
- `Player.air_dash_available` currently hard-limits Air Dash to one use and is reset on landing; `PlayerActionController.try_start_actions()` rejects airborne Dash when that flag is false.
- Ground Dash already supports one-entry edge-triggered chaining and spends 25 stamina per accepted segment, but Air Dash ignores later Shift edges.
- Stamina currently decrements its 0.60-second timer even while airborne/action-blocked, so a long airtime may permit immediate recovery on landing. This conflicts with the newly required grounded-only recovery timeline.
- Dash Attack currently rejects Shift entirely and clears the Dash buffer, so it cannot transition into a paid follow-up Ground/Air Dash.
- Production presentation contains segmented Ground Dash but only one five-frame `air_dash` one-shot.

### Planned files and tests

- Refactor the action controller and Player integration to remove Air Dash qualification, unify Ground/Air chain resolution, store one buffered per-segment direction, and continue from Dash Attack according to actual floor contact.
- Update stamina advancement, debug HUD, animation controller/builders/generator/preview, archive tooling, and all affected regressions.
- Add deterministic continuous-Air-Dash coverage and a repeatable movement-metrics runner; record single jump, debug double jump, four-Air-Dash reach, and current Main platform implications in `docs/design/level_metrics.md`.
- Run exact Godot 4.7.1 import, all existing regression suites, Main/preview rendering, collision tests, and diff checks.

### Scope guard

- No enemy, Boss, health, damage settlement, Hitbox/Hurtbox implementation, invulnerability, new attack, or map redesign is authorized.
- Continuous Dash remains edge-triggered; held Shift must never synthesize additional segments.
- Existing platforms will be measured and documented, not moved or globally raised.

### Delivered implementation

- Removed `Player.air_dash_available` and every landing/coyote qualification for Air Dash. Ground and Air now share the same paid segment path, 100-point pool, 25-point cost, 0.18-second motion time, 0.10-second one-entry Shift buffer, and 0.03-second minimum interval.
- Air Dash can chain repeatedly in one airtime while stamina can pay. Each buffered segment samples its own left/right direction, locks velocity/facing for that segment, zeros vertical velocity, and preserves gravity suspension across a successful continuation. Held Shift produces no new input edge.
- Split presentation into `air_dash_start` (2 frames, one-shot), `air_dash_loop` (3, looping), and `air_dash_end` (2, one-shot), all 20 FPS. A chain plays start once, loop through paid continuations, and end once. The superseded five PNGs were archived byte-identically under `assets/sprites/player/assassin/reference/deprecated_air_dash_five_frame/` before their production paths were removed.
- `PlayerStaminaComponent.advance()` now accepts positive recovery permission. Airborne/action-blocked time neither regenerates stamina nor decrements the 0.60-second delay. Landing does not refill or clear the timer; only grounded, action-free time advances toward 35 points/second recovery.
- Dash Attack clears pre-transition Dash input, accepts one new Shift edge during its action, and on completion starts a paid Ground/Air Dash from actual `CharacterBody2D.is_on_floor()` contact. The transition into Dash Attack is still free after its source Dash; the next segment costs exactly 25.
- Expanded optional diagnostics with floor contact, locomotion/action state, Ground/Air Dash type, chain number, buffered request/time, stamina/recovery state, direction, horizontal/vertical velocity, animation, and existing Attack data. The fixed stamina HUD remains signal-driven and camera-independent.
- Updated the production generator, archive/removal tooling, contact sheet, 16-animation SpriteFrames resource/controller/preview, Main laboratory copy, README, movement/animation/combat/stamina specifications, and tests. The preview layout was raised 50 px so all 16 selection and playback controls fit at 1280×720.
- Added `tests/player/measure_player_level_metrics.gd` and `docs/design/level_metrics.md`. At 60 physics ticks/s, measured from the real Player scene: single jump 153.59 px horizontal / 83.77 px rise; debug double jump 281.92 / 167.10; four paid Air Dashes 344.00 px action-only and 362.22 px from Dash-entry takeoff position to landing.
- Audited Main platforms without modifying them. Platform A/B widths (220/190 px) and the A→B edge gap (205 px) are below the 344 px chain envelope, so an already-elevated player can bypass their intermediate landing rhythm. Air Dash adds no lift: floor→B still exceeds the measured double-jump rise, and the continuous floor already makes both test platforms optional.

### Commands and actual results

1. `$GODOT_BIN --headless --path . --script scripts/tools/build_player_animation_assets.gd -- --archive-air-dash-source`
   - Exit 0; `PLAYER_AIR_DASH_ARCHIVE: 5 files, 0 failures`.
   - SHA-256 of the five archived sources: `7671ec…`, `1034bc…`, `3ac64f…`, `11584a…`, and `8b8727…`; each matched its former production file before deletion.
2. First `--production-only` generation attempt exposed an out-of-range contact-sheet row-color access. Godot printed a `SCRIPT ERROR` even though the script process returned 0; this run was not accepted.
   - Fixed the contact sheet for ten production rows and 1200×1840 output.
   - Rerun: `PLAYER_PRODUCTION_EXPORT: 33 files, 0 failures`, with no script error.
3. Exact Godot editor import, SpriteFrames build, and guarded obsolete-source removal:
   - `--headless --editor --path . --import --quit`: exit 0.
   - animation asset build: `PLAYER_SPRITE_FRAMES_BUILD: OK`, 16 names.
   - `--remove-archived-air-dash-source`: `5 files, 0 failures`; removal occurred only after byte comparison.
4. The first movement-metrics run found a pre-tree `@onready` access, and the next found an incorrectly parenthesized format expression. Both emitted `SCRIPT ERROR` and were rejected. After fixes, the exact runner produced:
   - `PLAYER_LEVEL_METRICS: PASS physics_fps=60 single_jump_range=153.59 single_jump_rise=83.77 double_jump_range=281.92 double_jump_rise=167.10 four_air_dash_range=344.00 four_air_dash_total_to_landing=362.22`.
5. Final exact Godot 4.7.1 import:
   - `$GODOT_BIN --headless --editor --path . --import --quit --log-file /tmp/nocturne_keep_air_chain_commit_import.log`
   - Exit 0; no parse, script, or resource errors.
6. Final serial regression suite using the same executable:
   - `validate_pixel_character_assets.gd`: `PASS (11 assets + board)`.
   - `validate_player_animation_assets.gd`: `PASS (33 frames + 4 byte-identical references)`; also validates both five-frame Dash archives.
   - `test_player_animation_system.gd`: `PASS (16 animations, segmented Ground/Air Dash verified)`.
   - `test_m1_player_movement.gd`: `PASS (movement, jump assists, collision, camera, six animations)`.
   - `test_m15_player_actions.gd`: `PASS (split Ground Dash, chained Air Dash, thrust Attack)`.
   - `test_dash_attack.gd`: `PASS (immediate J, transitions, air recovery, collision, debug HUD)`.
   - `test_fast_attack.gd`: `PASS (immediate response, single buffer, four-repeat chain, 0.25s Dash Attack)`.
   - `test_chain_dash_stamina.gd`: `PASS (edge chaining, four charges, shared Air/Ground pool, HUD, collision)`.
   - `test_continuous_air_dash.gd`: `PASS (four Air segments, mixed pool, direction, gravity, collision)`.
   - `measure_player_level_metrics.gd`: PASS with the values recorded above.
7. Main and preview runtime rendering:
   - Main: `--path . --write-movie /tmp/nocturne_keep_continuous_air_main.png --fixed-fps 30 --quit-after 2 --audio-driver Dummy`; exit 0, GL Compatibility on Apple M4, two 1280×720 frames.
   - Preview after layout correction: `--path . scenes/tools/player_animation_preview.tscn --write-movie /tmp/nocturne_keep_continuous_air_preview_v2.png --fixed-fps 20 --quit-after 2 --audio-driver Dummy`; exit 0, two 1280×720 frames.
   - Log search found no `ERROR`, `SCRIPT ERROR`, parse error, or warning. Original-resolution review confirmed crisp nearest-neighbor art, readable HUD/debug rows, and fully visible preview controls.
8. `git diff --check`: passed after removing documentation trailing whitespace.

### Automated acceptance results

1. Ground Dash chains from independent Shift edges: PASS.
2. Air Dash chains repeatedly in one airtime: PASS.
3. Full stamina accepts exactly four paid segments: PASS for Ground, Air, and 2+2 mixed use.
4. Fifth zero-stamina request is rejected: PASS.
5. Every accepted segment costs exactly 25: PASS.
6. Failed request spends nothing and signals insufficient once: PASS.
7. Airborne waiting leaves stamina and the 0.60-second timer unchanged: PASS.
8. Landing does not refill; recovery begins after 0.60 eligible grounded seconds: PASS.
9. Held Shift produces one segment/charge: PASS.
10. Timed independent Shift edges continue without an inserted standing/Fall phase: PASS.
11. Next Air segment can reverse direction: PASS.
12. Current Air segment ignores ordinary direction changes and keeps velocity/facing locked: PASS.
13. Air animation uses start once, loop during continuation, end once: PASS; contact sheet visually checked.
14. Air Dash→Dash Attack→buffered Air Dash: PASS.
15. Dash Attack source transition costs zero extra; follow-up costs one charge: PASS for grounded and airborne completion.
16. Continuous Air Dash stops at a wall through `move_and_slide()`: PASS.
17. Signal-driven bar and numeric label match the component: PASS.
18. Final import, all headless suites, Main, and preview contain no red errors: PASS.

### Manual acceptance requested

1. Jump and tap Shift four times near each segment end; judge whether `air_dash_start → air_dash_loop … → air_dash_end` feels continuous at 20 FPS.
2. During the next segment buffer, hold the opposite horizontal direction and confirm only the next paid segment flips; confirm the current segment never turns early.
3. Try Ground/Air mixed spending and verify the HUD reaches 75/50/25/0, then wait airborne and confirm it remains frozen until 0.60 seconds of eligible ground time.
4. Air Dash, press J, then Shift during Dash Attack; verify the follow-up uses the current contact domain and direction without restarting Dash Attack.
5. Test wall contact in both directions and toggle `ACTION DEBUG HUD` off to confirm the stamina bar remains fixed and readable.

### Known limitations and handoff

- The 0.10-second Dash buffer intentionally rewards a new Shift edge in the latter portion of each 0.18-second segment; earlier inputs expire rather than queue multiple future segments. Manual feel tuning may revise the window later.
- Ground Dash preserves its chain direction. Only Air Dash has approved per-segment turnaround behavior.
- Air Dash end begins gravity restoration during its two-frame recovery; there is no separate upward/downward/diagonal Dash or invulnerability.
- Continuous Air Dash materially widens optional traversal. Current Main remains a laboratory with continuous floor, not a production level; future rooms must preserve a single-jump main route and treat continuous Air Dash as a high-mobility route rather than a mandatory early-game gate.
- Hurt/Death remain preview placeholders. No enemy, health, damage settlement, Hitbox/Hurtbox, invulnerability, combo tree, Boss, or map redesign was added.

## 2026-07-22 — Configurable airborne stamina regeneration (preflight)

### Goal

- Allow stamina recovery during ordinary ascent and free fall at a configurable fraction of the existing grounded rate.
- Continue to block recovery during every stamina-consuming Dash/Dash-Attack action.
- Preserve current movement, gravity, jump, animation, input, collision, Dash cost, and HUD ownership.

### Baseline audit

- Clean worktree at `e8af02b feat: add continuous air dash stamina chains`.
- `PlayerStaminaComponent` owns `max_stamina=100`, `dash_stamina_cost=25`, `stamina_regen_delay=0.60`, `stamina_regen_rate=35`, the current value/timer, and typed UI signals.
- `Player` currently calls `advance(delta, was_on_floor and not action_controller.is_action_active())`; airborne time and all actions therefore freeze both regeneration and its delay.
- Successful Ground/Air Dash segments and direct Dash Attack are the only stamina spenders. Dash-to-Dash-Attack does not double-charge; a follow-up Dash pays normally. Jump, debug double jump, and normal Attack cost zero. No separate evade/dodge action exists.
- `PlayerStaminaHud` only observes `stamina_changed` and `stamina_insufficient`; it owns no resource math.

### Planned files and tests

- Add an exported 0–1 airborne multiplier to `player_stamina_component.gd`, keep the established 35/s ground rate, and derive the default 14/s airborne rate from multiplier 0.40.
- Pass contact state and a narrow stamina-action block from `Player`; expose that block query from `PlayerActionController` without changing action behavior.
- Update optional debug status, README, and stamina/movement specifications.
- Add deterministic component/integration coverage for ground rate, airborne rate, delay progress, Dash/Dash-Attack blocking, zero-cost Attack allowance, and signal-driven HUD updates; rerun all existing movement/action suites and Main startup.

### Scope guard

- Do not modify movement speed/acceleration, gravity, jump velocity/height, coyote time, input buffers, Dash physics, animation frames, collision, enemy/combat systems, or level geometry.
- Do not add stamina costs to Jump, Double Jump, or normal Attack in this task.

### Delivered implementation

- Added exported `airborne_stamina_regen_multiplier=0.40` to `PlayerStaminaComponent`. The existing grounded `stamina_regen_rate=35` is preserved, producing a default derived airborne rate of 14/s. `get_regeneration_rate(is_grounded)` is the single rate calculation path and supports inspector/runtime tuning without business-logic literals.
- Changed stamina advancement to accept `is_grounded` and `regeneration_blocked`. When unblocked, the existing 0.60-second delay now advances on ground or in ordinary air; recovery then uses the contact-appropriate rate. A blocked paid action freezes both value and delay exactly as before.
- Added `PlayerActionController.is_stamina_regeneration_blocked()`, limited to Ground Dash, Air Dash, and Dash Attack—the only current stamina-consuming action states. Zero-cost normal Attack, Jump, Double Jump, Jump Loop, and Fall do not block recovery.
- `Player` now forwards its pre-move floor contact plus that narrow action query. No velocity, gravity, jump, coyote, buffer, collision, animation, or action-transition values changed.
- Kept the functional HUD signal-only. `stamina_changed` continues to update its bar/value for ground and air recovery. Updated optional diagnostics to show `GROUND 35.0/s`, `AIR 14.0/s`, or `BLOCKED`.
- Updated README and movement/combat/stamina specifications. No scene structure or UI calculation ownership changed.

### Commands and actual results

1. Exact Godot 4.7.1 import after implementation:
   - `$GODOT_BIN --headless --editor --path . --import --quit --log-file /tmp/nocturne_keep_airborne_stamina_final_import.log`
   - Exit 0; no parse, script, resource, or warning output.
2. Exact serial regression suite:
   - `validate_pixel_character_assets.gd`: `PASS (11 assets + board)`.
   - `validate_player_animation_assets.gd`: `PASS (33 frames + 4 byte-identical references)`.
   - `test_player_animation_system.gd`: `PASS (16 animations, segmented Ground/Air Dash verified)`.
   - `test_m1_player_movement.gd`: `PASS (movement, jump assists, collision, camera, six animations)`.
   - `test_m15_player_actions.gd`: `PASS (split Ground Dash, chained Air Dash, thrust Attack)`.
   - `test_dash_attack.gd`: `PASS (immediate J, transitions, air recovery, collision, debug HUD)`.
   - `test_fast_attack.gd`: `PASS (immediate response, single buffer, four-repeat chain, 0.25s Dash Attack)`.
   - `test_chain_dash_stamina.gd`: `PASS (edge chaining, four charges, shared Air/Ground pool, HUD, collision)`.
   - `test_continuous_air_dash.gd`: `PASS (four Air segments, mixed pool, direction, gravity, collision)`.
   - `measure_player_level_metrics.gd`: primary envelopes unchanged—single jump 153.59/83.77, double jump 281.92/167.10, four-Air-Dash action range 344.00 px.
3. After adding explicit configurable-multiplier, normal-Attack, and Dash-Attack block assertions, both stamina suites were rerun independently and passed.
4. Main runtime render:
   - `$GODOT_BIN --path . --write-movie /tmp/nocturne_keep_airborne_stamina_main.png --fixed-fps 30 --quit-after 2 --audio-driver Dummy --log-file /tmp/nocturne_keep_airborne_stamina_main.log`
   - Exit 0; GL Compatibility on Apple M4, two 1280×720 frames, no red errors/warnings. Original-resolution inspection confirmed the fixed HUD and `REGEN GROUND 35.0/s` debug status are readable.
5. `git diff --check`: passed.

### Automated acceptance results

- Export default is 0.40 and changing it to 0.50 changes the derived air rate from 14.0 to 17.5 without code-branch edits.
- One unblocked grounded second restores exactly 35; one unblocked airborne second restores exactly 14 at defaults.
- Airborne time advances the 0.60-second delay. No value is restored before expiry; reduced-rate recovery begins afterward.
- Air Dash and Dash Attack leave both current value and delay unchanged throughout their action. Ground Dash uses the same blocking query.
- Zero-cost airborne normal Attack continues reduced-rate recovery. Jump and double jump remain zero-cost and use the ordinary air rule.
- Spend costs, four-segment shared pool, failed fifth Dash, Dash Attack no-double-charge, continuous Dash, wall collision, movement/jump metrics, and animation state tests remain green.
- The signal-driven HUD reflected an airborne component step from 75 to 89 immediately; it still owns no gameplay math.

### Manual acceptance requested

1. Spend stamina, jump/fall without Dashing, and confirm the bar starts rising slowly after the same 0.60-second delay.
2. Compare airborne recovery with grounded recovery and judge whether the default 40% relationship feels appropriate.
3. Air Dash or Dash Attack during the delay/recovery and confirm the bar freezes until the paid action finishes.
4. Use normal Attack in air and confirm it does not freeze the bar under the current zero-cost design.
5. Toggle `ACTION DEBUG HUD` and verify `GROUND 35.0/s`, `AIR 14.0/s`, and `BLOCKED` match the actual state.

### Known limitations and handoff

- Ground recovery remains 35/s rather than the prompt's illustrative 20/s value so this targeted change does not alter established ground recovery feel. The exported property remains configurable.
- Recovery delay is paused during paid Dash/Dash-Attack actions, preserving the prior action-blocking contract; ordinary airborne time now advances it.
- Normal Attack is allowed to recover because it currently costs zero. If later work assigns it a stamina cost, its block state must be changed with that same cost decision.
- No dodge action currently exists. No stamina cost, movement, combat, enemy, Boss, damage, Hitbox/Hurtbox, invulnerability, animation, or level change was added.

## 2026-07-22 — Development log documentation audit

Date: 2026-07-22
Status: complete — documentation-only audit; no Gameplay/content change and no Git commit/push

### Scope and document selection

- Searched the repository for development-log, changelog, progress, worklog, journal, roadmap, plan, and TODO-style filenames and references.
- Confirmed `docs/development_log.md` is the only document fulfilling the primary development-log role and is linked from README.
- Retained every historical entry and added the authoritative status section at the top of this file instead of creating a competing log.
- No `.gd`, scene, project setting, input map, resource, test, asset, import sidecar, plugin, Shader, audio, or export file was intentionally changed.

### Evidence inspected

- Git: clean `master` tracking `origin/master`, fourteen reachable commits through `e11638b`, and the commit subjects/stat history.
- Project/runtime configuration: `project.godot`, Main, Player, both tool scenes, player tuning resources, and the 16-animation SpriteFrames resource.
- Runtime ownership: Player movement, action, animation, stamina, HUD, debug overlay, and their explicit node dependencies/signals.
- Automated coverage: all ten scripts under `tests/player/` and `tests/tools/`.
- Documentation: README, the full historical development log, technical architecture, game-design baseline, known issues, player movement/animation/combat/stamina specifications, level metrics, and QA reports.
- Content inventory: player concept/production/reference/placeholder assets and the empty planned enemy, boss, level, combat, core, and system implementation directories.

### Current automated verification

Commands used the exact executable at the developer's local `GODOT_BIN` path; logs were written under `/tmp`.

1. `Godot --headless --editor --path . --import --quit`
   - Exit 0; no script/resource error or warning detected.
2. `validate_pixel_character_assets.gd`
   - `PIXEL_CHARACTER_VALIDATION: PASS (11 assets + board)`.
3. `validate_player_animation_assets.gd`
   - `PLAYER_ANIMATION_VALIDATION: PASS (33 frames + 4 byte-identical references)`.
4. `test_player_animation_system.gd`
   - `PASS (16 animations, segmented Ground/Air Dash verified)`.
5. `test_m1_player_movement.gd`
   - `PASS (movement, jump assists, collision, camera, six animations)`.
6. `test_m15_player_actions.gd`
   - `PASS (split Ground Dash, chained Air Dash, thrust Attack)`.
7. `test_dash_attack.gd`
   - `PASS (immediate J, transitions, air recovery, collision, debug HUD)`.
8. `test_fast_attack.gd`
   - `PASS (immediate response, single buffer, four-repeat chain, 0.25s Dash Attack)`.
9. `test_chain_dash_stamina.gd`
   - `PASS (edge chaining, four charges, shared Air/Ground pool, HUD, collision)`.
10. `test_continuous_air_dash.gd`
    - `PASS (four Air segments, mixed pool, direction, gravity, collision)`.
11. `measure_player_level_metrics.gd`, run three times
    - All three runs passed. Jump and four-Dash action-range values were identical; takeoff-to-landing totals were `360.33`, `362.22`, and `360.33` px.
12. `Godot --headless --path . --quit-after 2`
    - Exit 0; configured Main scene started and stopped without detected error/warning output.

### Audit conclusions

- Current automated evidence supports the M0, pixel-art tool, animation presentation, M1 locomotion, and M1.5 action/stamina implementation claims listed in the new status matrix.
- It does not establish final player feel, final art approval, editor Debugger cleanliness during an interactive session, export readiness, or full-playthrough quality; those remain pending manual verification.
- M2 combat architecture and all enemy/Boss/room/progression systems remain planned only. Existing Attack and Dash Attack are animation/input/movement prototypes without damage resolution.
- The dated M0 metadata in the design baseline, architecture, and known-issues documents is a documentation-maintenance issue, not evidence that current Gameplay is absent.
- Final document-only diff verification passed: `git diff --check` reported no error, and `git diff --name-only` listed only `docs/development_log.md`.

## 2026-07-22 — PLAYER-HP-001 player health data foundation

Date: 2026-07-22
Status: complete — unified Health mutation contract verified; no damage source or death state added

### Approved scope extension preflight

- The existing working-tree `HealthComponent` is the only Health implementation. It already owns maximum/current values, clamping, reset, and `health_changed`, but has no `take_damage`, `heal`, `died`, or death-signal guard.
- Player uses composed Animation, Action, Stamina, and Health nodes; locomotion uses `MovementState` while actions use a separate `ActionState`. Extending the existing Health node is the smallest architecture-consistent change.
- The current stamina HUD is signal-driven and does not own stamina math. No player health HUD or Gameplay death state exists; preview-only `death` art remains a placeholder.
- This extension will modify only the existing Health component and its isolated test, then update this log. Player scene structure, movement/actions, stamina/HUD, input, presentation, enemies, and levels remain out of scope.

### Goal

- Add a small, independently testable player health component with a configurable maximum, a clamped current value, unified damage/healing methods, reset-to-full behavior, typed change/death signals, and repeated-death protection.
- Attach the component to the existing Player scene without coupling it to movement, actions, animation, stamina, or UI.

### Planned files and tests

- Add `scripts/combat/health_component.gd` and attach `HealthComponent` under `scenes/player/player.tscn`.
- Add `tests/combat/test_health_component.gd` for defaults, custom maximum, lower/upper clamping, damage, healing, reset behavior, signal order, death guarding/rearming, and Player-scene composition.
- Run the exact Godot 4.7.1 editor import, the new isolated test, all ten existing regression scripts, and configured Main startup.

### Scope guard

- This task adds only Health value mutation semantics. It does not add damage sources, a player death/hurt state, invulnerability, knockback, respawn, health UI, Hitbox/Hurtbox, enemies, levels, or new input.
- Existing movement, jump, Dash, Attack, stamina, animation, and Main behavior must remain unchanged.

### Delivered implementation

- Added the statically typed, composition-first `HealthComponent` under `scripts/combat/`. It owns `max_health`, a read/write `current_health` property, clamping to `0...max_health`, `take_damage(amount)`, `heal(amount)`, `reset_to_full()`, `is_dead()`, typed `health_changed(current, maximum)`, and `died` notification.
- The exported maximum defaults to 100 and is sanitized to a minimum of one during `_ready()`. Current health initializes to the resulting maximum and emits its initial value once.
- Non-positive damage/healing requests are ignored. Overkill damage clamps to zero, excess healing clamps to maximum, and post-death damage cannot mutate the value.
- Unchanged assignments do not emit duplicate notifications. A lethal change emits `health_changed` before `died`; repeated zero/damage cannot emit `died` again. Restoring positive health through healing/reset rearms one later death event.
- Both the explicit setter, direct property assignment, damage, healing, and reset use the same clamp/signal path.
- Added a uniquely addressable `HealthComponent` child to the Player scene. `player.gd`, Main, input, movement, action, stamina, animation, and UI code were not changed.
- Added an isolated SceneTree test for default/custom/invalid maximum values, lower/upper clamping, damage/healing limits, lethal event order, death suppression/rearming, reset behavior, and Player scene composition.
- Godot generated tracked UID sidecars for the two new GDScript files during exact editor import.

### Files

- New: `scripts/combat/health_component.gd` and its generated `.uid`.
- Modified: `scenes/player/player.tscn` (one composed node and script resource only).
- New: `tests/combat/test_health_component.gd` and its generated `.uid`.
- Modified: `docs/development_log.md`, preserving the pre-existing documentation-audit changes.

### Commands and actual results

1. Exact engine check and final editor import:
   - `$GODOT_BIN --version` returned `4.7.1.stable.official.a13da4feb`.
   - `Godot --headless --editor --path . --import --quit --log-file /tmp/nocturne_keep_hp_damage_import.log`: exit 0; no parse, script, resource, or warning match.
2. New isolated test:
   - `Godot --headless --path . --script tests/combat/test_health_component.gd --log-file /tmp/nocturne_keep_hp_damage_test.log`.
   - Exit 0; damage, healing, clamping, signal order, death guard/rearm, and Player composition assertions passed.
3. Final serial regression suite using the same executable:
   - `validate_pixel_character_assets.gd`: `PASS (11 assets + board)`.
   - `validate_player_animation_assets.gd`: `PASS (33 frames + 4 byte-identical references)`.
   - `test_player_animation_system.gd`: `PASS (16 animations, segmented Ground/Air Dash verified)`.
   - `test_m1_player_movement.gd`: `PASS (movement, jump assists, collision, camera, six animations)`.
   - `test_m15_player_actions.gd`: `PASS (split Ground Dash, chained Air Dash, thrust Attack)`.
   - `test_dash_attack.gd`: `PASS (immediate J, transitions, air recovery, collision, debug HUD)`.
   - `test_fast_attack.gd`: `PASS (immediate response, single buffer, four-repeat chain, 0.25s Dash Attack)`.
   - `test_chain_dash_stamina.gd`: `PASS (edge chaining, four charges, shared Air/Ground pool, HUD, collision)`.
   - `test_continuous_air_dash.gd`: `PASS (four Air segments, mixed pool, direction, gravity, collision)`.
   - `measure_player_level_metrics.gd`: PASS; unchanged primary values of 153.59/83.77 single jump, 281.92/167.10 debug double jump, and 344.00 four-Air-Dash action range.
4. Configured Main startup:
   - `Godot --headless --path . --quit-after 2 --log-file /tmp/nocturne_keep_hp_damage_main.log`: exit 0.
5. Final suite log scan:
   - No `SCRIPT ERROR`, `ERROR:`, `WARNING:`, parse error, or missing-resource match.

### Verification note

- The first aggregate regression attempt used `status` as a zsh variable and stopped after its first passing test because that name is read-only; the wrapper was corrected without changing project files.
- A subsequent aggregate run observed one transient `Preview did not play dash_start` assertion in `test_m15_player_actions.gd`. The test then passed three consecutive isolated runs and passed again in the final full serial suite. No animation/preview code was changed. This is recorded as an existing one-frame preview-test timing sensitivity, not treated as a Health regression.

### Scope result and handoff

- PLAYER-HP-001 acceptance is satisfied at the reusable component-contract level. There is intentionally no visible health UI, damage source, death state, or current Gameplay caller of the mutation methods.
- No manual player-feel acceptance is required for this isolated contract. A future health HUD, hazard, enemy attack, or death-state task will require separate approval and verification.
- Recommended next task, subject to explicit approval: a signal-driven player Health HUD that observes this component without owning or mutating its values.
- No Git commit or push was performed. The pre-existing uncommitted development-log audit remains in the same working-tree file alongside this incremental record.

## 2026-07-22 — PLAYER-HP-002 signal-driven player Health HUD

Date: 2026-07-22
Status: complete — automated and visual verification passed

### Goal

- Add a fixed player Health bar above the existing Stamina bar in `Main/HUD`, matching its dimensions, margins, typography, and numeric presentation.
- Keep Health data exclusively in `HealthComponent`; the HUD observes `health_changed`, initializes from current state, and supports explicit rebinding without per-frame polling.

### Planned files and tests

- Add `scripts/ui/player_health_hud.gd` as a presentation-only, typed, rebindable observer.
- Modify `scenes/main/main.tscn` to add `HealthContainer`, `HealthValue`, and `HealthBar` while preserving the existing Stamina and debug HUD ownership/paths.
- Add `tests/ui/test_player_health_hud.gd` for initial state, damage/healing/reset signal updates, progress limits, old-signal disconnection during rebinding, and Stamina HUD regression.
- Run exact Godot 4.7.1 import, the new HUD test, all eleven current tests, configured Main startup, and a nearest-neighbor graphical capture for visual inspection.

### Scope guard

- Do not add damage sources, player death state/prompt, respawn, spawn point, enemies, Hitbox/Hurtbox, effects, sound, low-health feedback, or health-bar animation.
- Do not modify player movement/actions, Health mutation semantics, Stamina calculation/HUD script, debug overlay logic, input, collision, or level geometry.

### Delivered implementation

- Added `PlayerHealthHud` as a typed, presentation-only `Control`. It resolves the configured Player `HealthComponent`, subscribes to `health_changed`, and immediately renders the component's current state without `_process()` polling.
- Added `bind_health_component(component)` for future Player replacement. Rebinding disconnects the previous valid component before subscribing to the new one; `_exit_tree()` also disconnects. An explicit unbound state shows `--- / ---` rather than inventing Health data.
- Added `Main/HUD/HealthContainer` above the existing `StaminaContainer`, using the same 224×66 px container, 204×20 px bar, margins, 12 px typography, dark background, cool border, fixed CanvasLayer, and `%03d / %03d` numeric format. Health uses a muted crimson fill; Stamina retains its existing amber fill and node paths.
- Moved only the Stamina container's screen offsets from y=24–90 to y=100–166. `PlayerStaminaHud`, its signal/calculation ownership, and the separate `Interface/Panel/ActionDebug` hierarchy were not changed.
- Added integration coverage for initial 100/100 state, `take_damage(10)`, `heal(10)`, `reset_to_full()`, ProgressBar bounds, Health rebinding, old-signal disconnection, new-signal updates, Stamina consumption/display, and debug-HUD preservation.
- Godot generated `.gd.uid` sidecars for the new HUD and test scripts during editor import.

### Files

- New: `scripts/ui/player_health_hud.gd` and generated `.uid`.
- Modified: `scenes/main/main.tscn` for Health HUD nodes/styles and Stamina vertical placement only.
- New: `tests/ui/test_player_health_hud.gd` and generated `.uid`.
- Modified: `docs/development_log.md`, preserving all pre-existing uncommitted audit and PLAYER-HP-001 history.

### Commands and actual results

1. Exact Godot 4.7.1 editor import:
   - `Godot --headless --editor --path . --import --quit --log-file /tmp/nocturne_keep_hp_hud_import.log`.
   - Exit 0; `PlayerHealthHud` registered and no parse/script/resource warning was detected.
2. New HUD integration test:
   - Initial run correctly passed the Health, Stamina, and rebind assertions but failed the test-only debug path `Interface/ActionDebug`; the actual unchanged path is `Interface/Panel/ActionDebug`.
   - After correcting only that assertion path: `Godot --headless --path . --script tests/ui/test_player_health_hud.gd --log-file /tmp/nocturne_keep_hp_hud_test_v2.log`.
   - Exit 0; `PLAYER_HEALTH_HUD_TEST: PASS (initial, signals, reset, rebind, Stamina regression)`.
3. Final serial suite using the exact executable:
   - `test_health_component.gd`: `PASS (health, damage, healing, death guard, Player composition)`.
   - `test_player_health_hud.gd`: `PASS (initial, signals, reset, rebind, Stamina regression)`.
   - `validate_pixel_character_assets.gd`: `PASS (11 assets + board)`.
   - `validate_player_animation_assets.gd`: `PASS (33 frames + 4 byte-identical references)`.
   - `test_player_animation_system.gd`: `PASS (16 animations, segmented Ground/Air Dash verified)`.
   - `test_m1_player_movement.gd`: `PASS (movement, jump assists, collision, camera, six animations)`.
   - `test_m15_player_actions.gd`: `PASS (split Ground Dash, chained Air Dash, thrust Attack)`.
   - `test_dash_attack.gd`: `PASS (immediate J, transitions, air recovery, collision, debug HUD)`.
   - `test_fast_attack.gd`: `PASS (immediate response, single buffer, four-repeat chain, 0.25s Dash Attack)`.
   - `test_chain_dash_stamina.gd`: `PASS (edge chaining, four charges, shared Air/Ground pool, HUD, collision)`.
   - `test_continuous_air_dash.gd`: `PASS (four Air segments, mixed pool, direction, gravity, collision)`.
   - `measure_player_level_metrics.gd`: PASS with unchanged 153.59/83.77 single-jump, 281.92/167.10 debug-double-jump, and 344.00 four-Air-Dash action envelopes.
4. Configured Main startup:
   - `Godot --headless --path . --quit-after 2 --log-file /tmp/nocturne_keep_hp_hud_main_headless.log`: exit 0.
   - All suite/Main logs scanned clean for script error, error, warning, parse error, and missing resource.
5. Graphical Main capture:
   - `Godot --path . --write-movie /tmp/nocturne_keep_hp_hud_main.png --fixed-fps 30 --quit-after 2 --audio-driver Dummy --log-file /tmp/nocturne_keep_hp_hud_main_graphical.log`.
   - Exit 0; GL Compatibility on Apple M4, two 1280×720 frames. Original-resolution inspection confirmed aligned Health/Stamina blocks, legible values, distinct fills, and no debug-HUD overlap.

### Automated acceptance results

- Main starts at Health 100/100; bar bounds/value and text match the component.
- `take_damage(10)` updates the bar to 90 and text to `090 / 100` synchronously through `health_changed`; `heal(10)` and `reset_to_full()` restore 100/100.
- Rebinding to a 60-maximum replacement initializes 60/60, ignores later signals from the old component, and follows the new component to 45/60.
- Stamina still spends to 75 and renders `075 / 100`; its script and gameplay state are unchanged.
- Debug HUD structure, all movement/action/stamina regressions, Main startup, and measured movement envelopes remain intact.

### Manual acceptance requested

1. Run Main and confirm the upper-right HEALTH block sits directly above STAMINA with equal width/margins and remains fixed while the camera moves.
2. Confirm muted crimson Health and amber Stamina remain distinguishable against the moon/background at the target display.
3. Health mutation currently has no Gameplay input or enemy source; use the automated test or Remote Inspector only if manually checking value changes. Do not interpret the absence of in-game damage as a HUD failure.

### Scope result and handoff

- PLAYER-HP-002 is complete. No death state/prompt, respawn, spawn point, enemy, damage area, Hitbox/Hurtbox, health animation/effect, or sound was added.
- No plan/roadmap document exists to synchronize; this primary development log contains the task status.
- The next ordered task is `PLAYER-DEATH-001`, but it remains unapproved and was not started.
- No Git commit or push was performed; final output will report the complete working-tree diff, including preserved earlier uncommitted changes.

## 2026-07-22 — PLAYER-DEATH-001 player death state

Date: 2026-07-22
Status: complete — automated and graphical death-state verification passed

### Goal

- Enter one explicit Player death state when the existing `HealthComponent.died` signal fires, cancel active movement/actions, block subsequent Gameplay input and Stamina processing, and expose a one-shot one-second delay hook for the future respawn task.
- Add a temporary `YOU DIED / 已阵亡` HUD prompt and one clearly marked development-only button that applies 25 Health damage for manual testing.

### Planned files and tests

- Modify `scripts/player/player.gd` to own the life-state transition and typed death signals while preserving the existing movement/action state split.
- Add a narrow action-controller cancellation method so an in-progress Dash/Attack cannot remain active after death.
- Add presentation-only `scripts/ui/player_death_hud.gd`, test-only `scripts/tools/player_death_test_button.gd`, and their Main scene nodes.
- Add `tests/player/test_player_death_state.gd` for one-shot death entry, action/velocity cancellation, input/Stamina lockout, zero-Health HUD, prompt visibility, delay hook, and repeated-damage protection.
- Run exact Godot 4.7.1 import, the new death test, all twelve current tests, Main startup, and graphical/manual-button verification.

### Scope guard

- The existing eight-frame `death` animation remains explicitly placeholder art; using it does not approve or create a final death animation.
- Do not add respawn movement/reset, spawn points, checkpoints, enemies, Hitbox/Hurtbox, damage areas, invulnerability, knockback, game-over flow, effects, sound, or input-map actions.
- Preserve the unrelated current `player_sprite_frames.tres` UID-normalization diff without editing or reverting it.

### Delivered implementation

- Added a separate `Player.LifeState` (`ALIVE`, `DEAD`) rather than expanding or disturbing the six-state locomotion enum. `HealthComponent.died` is connected once during Player readiness.
- Death entry is guarded and performs one transition: sets the life state, zeros velocity/coyote/jump buffers/pending movement, cancels active action data, clears action buffers, resets presentation arbitration, plays the existing explicitly placeholder `death` animation, and emits `death_state_entered`.
- Dead physics processing advances only the one-second `death_state_delay`, forces zero velocity through the existing `CharacterBody2D.move_and_slide()` path, and returns before input, jump, action, Stamina, and locomotion animation processing. It emits `death_delay_elapsed` once and does not respawn.
- Added `PlayerActionController.cancel_all_actions()` as a narrow non-emitting cancellation path. It clears current Dash/Attack state, timing, buffers, action response data, and chain count without falsely reporting a normal action completion that could resume locomotion.
- Added a temporary fixed `DeathOverlay` displaying `YOU DIED / 已阵亡`; it only observes `Player.death_state_entered`. No health/death state is stored in the HUD.
- Added `Interface/DamageTestButton`, labeled `DEV TEST · TAKE 25 DAMAGE`. Its test-only script resolves the current Player Health component on each independent click and calls `take_damage(25)`; it adds no input action or damage area.
- Added deterministic death coverage that starts a real Dash, spends 25 Stamina, kills through four button presses, verifies Dash cancellation, zero Health HUD, prompt/placeholder animation, blocked movement/jump/Dash/Attack, frozen Stamina, one death event, one delay event, repeated-damage protection, and absence of respawn.
- Godot generated `.gd.uid` sidecars for the new death HUD, test button, and test scripts during editor import.

### Files

- Modified: `scripts/player/player.gd` for life-state ownership and death transition only.
- Modified: `scripts/player/player_action_controller.gd` for the narrow cancellation method.
- New: `scripts/ui/player_death_hud.gd` and generated `.uid`.
- New: `scripts/tools/player_death_test_button.gd` and generated `.uid`.
- Modified: `scenes/main/main.tscn` for the temporary prompt and development-only button.
- New: `tests/player/test_player_death_state.gd` and generated `.uid`.
- Modified: `docs/development_log.md`, retaining all earlier uncommitted task history.
- Unrelated/pre-existing and preserved: `resources/player/player_sprite_frames.tres` UID serialization diff; this task did not edit its animation data.

### Commands and actual results

1. Exact Godot 4.7.1 import:
   - `Godot --headless --editor --path . --import --quit --log-file /tmp/nocturne_keep_player_death_import.log`.
   - Exit 0; `PlayerDeathHud` and `PlayerDeathTestButton` registered with no parse/script/resource warning.
2. Isolated death integration:
   - `Godot --headless --path . --script tests/player/test_player_death_state.gd --log-file /tmp/nocturne_keep_player_death_test.log`.
   - Exit 0; `PLAYER_DEATH_STATE_TEST: PASS (single entry, lockout, HUD, delay, no respawn)`.
3. Final serial suite with the exact executable:
   - `test_health_component.gd`: PASS.
   - `test_player_health_hud.gd`: PASS.
   - `test_player_death_state.gd`: PASS.
   - Both asset validators: PASS.
   - Animation system, M1 movement, M1.5 actions, Dash Attack, fast Attack, chained Stamina Dash, continuous Air Dash, and level-metrics tests: all PASS.
   - Level metrics remain unchanged at 153.59/83.77 single jump, 281.92/167.10 debug double jump, and 344.00 four-Air-Dash action range.
4. Configured Main startup:
   - `Godot --headless --path . --quit-after 2 --log-file /tmp/nocturne_keep_player_death_main_headless.log`: exit 0.
   - All thirteen suite/Main logs scanned clean for script error, error, warning, parse error, and missing resource.
5. Graphical automated button run:
   - `Godot --path . --script tests/player/test_player_death_state.gd --write-movie /tmp/nocturne_keep_player_death_visual.png --fixed-fps 60 --audio-driver Dummy --log-file /tmp/nocturne_keep_player_death_visual.log`.
   - Exit 0; GL Compatibility on Apple M4, 95 frames at 1280×720. Frames 20 and 70 were inspected at original resolution.
   - Visual result: Health `000 / 100`, Stamina frozen at `075 / 100`, debug animation `death`, readable centered prompt, visible development button, and placeholder sprite settling to its final death pose.

### Automated acceptance results

- Four independent button presses cause 25 damage each and enter death exactly once at zero Health.
- A Ground Dash active at the lethal hit is cancelled; velocity becomes and remains zero.
- Held move, jump, Dash, and Attack inputs for twelve physics frames cannot move the Player, restart an action, or spend/regenerate Stamina.
- Post-death damage does not re-enter Player death. The one-second delay signal emits once and remains one after further waiting.
- Health HUD stays at zero and the death prompt stays visible. PLAYER-DEATH-001 intentionally leaves the Player dead after the delay.
- All pre-existing Health, HUD, movement, action, animation, Stamina, collision, and metrics tests remain green.

### Manual acceptance requested

1. In the opened Main window, click `DEV TEST · TAKE 25 DAMAGE` four times; confirm Health steps 100→75→50→25→0 and the prompt appears only at zero.
2. Start moving, Dashing, or attacking before the fourth click; confirm the lethal hit stops the action and subsequent A/D, Space, Shift, and J do nothing.
3. Wait beyond one second and confirm no respawn occurs yet; PLAYER-RESPAWN-001 remains a separate approval gate.
4. Treat the current death frames as placeholder art, not visual approval of the final death animation.

### Scope result and handoff

- PLAYER-DEATH-001 is complete. No spawn point, respawn/reset, enemy, damage area, Hitbox/Hurtbox, invulnerability, checkpoint, game over, effect, sound, or final death animation was added.
- The next ordered task is `PLAYER-RESPAWN-001`, but it remains unapproved and was not started.
- No Git commit or push was performed. Final diff reporting separates this task from the preserved earlier work and unrelated SpriteFrames UID normalization.

## 2026-07-22 — PLAYER-RESPAWN-001 single spawn point and player respawn

Date: 2026-07-22
Status: complete — automated and graphical verification passed; manual acceptance requested

### Approved scope preflight

- `PLAYER-DEATH-001` currently emits `death_delay_elapsed` once after its configured one-second delay, but intentionally leaves the Player dead. There is no spawn point, respawn coordinator, position reset, Health/Stamina restoration, or death-prompt dismissal.
- Player already owns the internal state that must be reset: life state, velocity, coyote/jump buffers, air-jump availability, action controller, movement animation, Health, and Stamina. Main owns the current test-level Player instance and is therefore the narrow scene-level owner for selecting a spawn point.
- The Health and Stamina HUDs already observe their components' typed signals. Calling the existing `reset_to_full()` methods will update both displays without adding polling or UI-owned Gameplay data.
- The existing death integration test explicitly verifies that no respawn occurs. It will retain that isolated contract by disabling the new coordinator before lethal damage; a separate respawn integration test will own death-to-respawn assertions.

### Goal

- Add one `Marker2D` spawn point to the current Main test scene and a typed, composition-based coordinator that responds to the Player's existing death-delay hook.
- Respawn the Player at that point exactly once per death, restore Health and Stamina, clear movement/action/jump/death timers, restore input and idle presentation, dismiss the temporary death prompt, and keep the child Camera2D following the same Player instance.

### Planned files and tests

- Modify `scripts/player/player.gd` with a single public `respawn_at(global_spawn_position)` reset boundary and typed `respawned` signal.
- Add `scripts/systems/player_respawn_controller.gd`; modify `scenes/main/main.tscn` with `World/SpawnPoint` and `PlayerRespawnController` using exported NodePaths.
- Modify `scripts/ui/player_death_hud.gd` to hide on the Player's typed respawn signal.
- Update `tests/player/test_player_death_state.gd` to disable the coordinator for isolated death-state verification; add `tests/player/test_player_respawn.gd` for position, Health, Stamina, actions, prompt, camera, duplicate protection, repeated cycles, and restored movement.
- Run the exact Godot 4.7.1 import, both focused death/respawn tests, the complete existing regression suite, configured Main startup, and a graphical death-to-respawn capture.

### Scope guard

- This task adds only one fixed spawn point and delayed Player reset. It does not add checkpoints, multiple spawn selection, enemies, damage areas, Hitbox/Hurtbox, invulnerability, knockback, game-over flow, final death/respawn art, sound, save state, or new input.
- Preserve all pre-existing uncommitted Health/HUD/death work and the unrelated `player_sprite_frames.tres` UID-normalization diff. Do not change movement feel, action timing, collision shapes, level geometry, Input Map, or animation frame data.

### Delivered implementation

- Added `Player.respawn_at(global_spawn_position)` as the single atomic reset boundary. It rejects calls while alive; for a dead Player it teleports to the approved marker, clears velocity, coyote/jump/input/landing/action/death state, restores the configured air-jump count, resets Health and Stamina through their existing component APIs, restores Idle animation/locomotion, resets Camera2D smoothing, emits typed `movement_state_changed` and `respawned` signals, and returns success.
- Added `PlayerRespawnController` under `scripts/systems/`. It resolves Player and `Marker2D` through typed exported NodePaths, observes the existing one-shot `death_delay_elapsed`, guards re-entry, calls the Player-owned reset once, and emits its own typed level-level notification. Its exported `enabled` switch supports isolated death-state testing without changing production defaults.
- Added `World/SpawnPoint` at the current safe floor spawn `(320, 612)` and a Main-level `PlayerRespawnController`. This is one fixed test spawn, not a checkpoint/session system.
- Updated the presentation-only `PlayerDeathHud` to observe `Player.respawned` and hide itself. Health and Stamina bars continue to update from their component signals; no HUD owns or mutates Gameplay data.
- Preserved the death-state test by disabling the coordinator before lethal damage, so it still proves the one-shot dead-state contract independently. Added a separate respawn integration test that executes two complete death cycles and verifies delay, one respawn per death, position, Health/Stamina/timers, action/jump state, prompt/HUD, Camera parentage, input recovery, and death-signal rearming.
- Godot 4.7.1 import generated UID sidecars for the new controller and respawn test scripts.

### Files

- Modified: `scripts/player/player.gd` for the typed respawn signal, Camera reference, and atomic reset method.
- New: `scripts/systems/player_respawn_controller.gd` and generated `.uid`.
- Modified: `scripts/ui/player_death_hud.gd` to dismiss on respawn.
- Modified: `scenes/main/main.tscn` for one `Marker2D` and the coordinator node.
- Modified: `tests/player/test_player_death_state.gd` to isolate death behavior by disabling the coordinator.
- New: `tests/player/test_player_respawn.gd` and generated `.uid`.
- Modified: `docs/development_log.md`, retaining all prior uncommitted history.
- Preserved unrelated/pre-existing changes, including `resources/player/player_sprite_frames.tres` UID normalization; this task did not edit animation data.

### Commands and actual results

1. Exact engine and editor import:
   - `$GODOT_BIN --version` returned `4.7.1.stable.official.a13da4feb`.
   - `Godot --headless --editor --path . --import --quit --log-file /tmp/nocturne_keep_player_respawn_import.log`: exit 0; the new controller/test classes registered without parse, script, resource, or warning output.
2. Focused contract tests:
   - `Godot --headless --path . --script tests/player/test_player_death_state.gd --log-file /tmp/nocturne_keep_player_death_after_respawn.log`: exit 0; isolated death entry, lockout, prompt, one-shot delay, and no-respawn assertions passed with the coordinator disabled.
   - `Godot --headless --path . --script tests/player/test_player_respawn.gd --log-file /tmp/nocturne_keep_player_respawn_test.log`: exit 0; `PLAYER_RESPAWN_TEST: PASS (delay, reset, HUD, repeat cycle, input recovery)`.
3. Final serial regression suite with the same executable:
   - All fourteen scripts passed: Health component; Health HUD; death state; respawn; both asset validators; animation system; M1 movement; M1.5 actions; Dash Attack; fast Attack; chained Dash/Stamina; continuous Air Dash; and level metrics.
   - Stable metrics remain 153.59/83.77 single jump, 281.92/167.10 debug double jump, and 344.00 four-Air-Dash action range.
4. Scene startup checks:
   - `Godot --headless --path . --quit-after 2 --log-file /tmp/nocturne_keep_respawn_main_v2.log`: exit 0.
   - `Godot --headless --path . res://scenes/player/player.tscn --quit-after 2 --log-file /tmp/nocturne_keep_respawn_player_scene_v2.log`: exit 0, confirming Player remains independently instantiable.
   - Final logs contained no `SCRIPT ERROR`, `ERROR:`, `WARNING:`, parse error, or missing-resource match.
5. Graphical death-to-respawn run:
   - `Godot --path . --script tests/player/test_player_respawn.gd --write-movie /tmp/nocturne_keep_player_respawn_visual.png --fixed-fps 60 --audio-driver Dummy --log-file /tmp/nocturne_keep_player_respawn_visual.log`: exit 0; GL Compatibility on Apple M4, 111 frames at 1280×720.
   - Frames 30 and 75 were inspected at original resolution. Frame 30 shows zero Health, frozen 75 Stamina, death animation/debug state, and the centered prompt. Frame 75 shows the Player back on the safe floor marker, Idle, prompt hidden, and both HUD values restored to 100/100.

### Automated acceptance results

- Lethal damage enters the existing dead state first; no respawn occurs before the configured one-second delay.
- Each delay expiry produces exactly one respawn. Waiting additional frames produces no duplicate, and a second lethal cycle independently respawns exactly once, confirming Health death signaling and Player timers rearm correctly.
- The Player returns to `(320, 612)` with zero velocity, zero death/coyote/jump-buffer timers, one Debug air jump restored, no active Dash/Attack, Idle state/presentation, full Health, full Stamina, and zero Stamina regeneration delay.
- The temporary prompt hides and both signal-driven HUD bars/numbers restore to 100/100. Movement input works again after respawn.
- The same Camera2D remains a child of the same Player instance and smoothing is reset after the teleport. Graphical capture confirms the camera follows the respawned position.
- All prior animation, movement, action, Stamina, collision, asset, and metrics regressions remain green.

### Manual acceptance requested

1. Run Main and move away from the initial floor position.
2. Spend some Stamina, then click `DEV TEST · TAKE 25 DAMAGE` until Health reaches zero; confirm input locks and the death prompt appears.
3. Wait approximately one second; confirm the Player returns to the initial safe floor position, prompt disappears, Health/Stamina both read `100 / 100`, and movement/jump/Dash/Attack work again.
4. Repeat the cycle once to confirm no duplicate or stuck respawn. Treat the current death presentation as placeholder art.

### Known limitations and handoff

- This is one fixed Main-scene spawn with a direct delayed reset. It does not choose checkpoints, persist a spawn across scenes, provide post-respawn invulnerability, reset enemies, or implement a game-over/session flow.
- Because no enemy or damage area exists, immediate repeated damage at the spawn is not yet possible or tested. That protection belongs to a later approved damage/combat-loop task.
- No movement, Input Map, action timing, collision shape, animation frame, enemy, Hitbox/Hurtbox, or damage-source logic was changed.
- `PLAYER-RESPAWN-001` is complete. The next ordered task remains `ENEMY-BASE-001`, but it was not started and requires explicit approval.
- No Git commit or push was performed. Final diff reporting separates this task from preserved earlier work and the unrelated SpriteFrames UID normalization.

## 2026-07-23 — Player death presentation sequence

Date: 2026-07-23
Status: complete — asset, timing, regression, and graphical verification passed; manual visual acceptance requested

### Approved scope preflight

- The active `death` animation is still an eight-frame placeholder assembled from shifted standing art at 8 FPS. It does not show a fall, horizontal corpse, or released daggers.
- `Player` currently starts that placeholder animation and advances a fixed one-second internal death timer. `PlayerRespawnController` listens to `death_delay_elapsed` and respawns immediately when that timer expires; there is no presentation-completion gate.
- Player input/action/Stamina lockout and one-shot death-state entry already exist and pass tests. There is no active Hitbox/Hurtbox or damage shape to disable; cancelling `PlayerActionController` already removes the current attack/dash state and reserved hit-window animation.
- No ghost texture, ghost node, death-sequence component, or `player_respawn_spec.md` exists. The current single Main `SpawnPoint` and atomic `Player.respawn_at()` reset contract are functional and should be preserved.

### Goal

- Replace the placeholder death presentation with five original 64×64 pixel frames that progress from lethal imbalance to a clearly horizontal body, with the main and off-hand daggers visibly released beside it.
- Add one original transparent hooded-face ghost texture and a composed death-sequence controller that waits for the body animation, floats the ghost upward 8–16 pixels, holds it for exactly 0.50 seconds, cleans it up, and only then authorizes the existing respawn coordinator.

### Planned files and tests

- Add a deterministic Godot Image generator under `scripts/tools/` and generate `assets/sprites/player/assassin/death/death_01.png` through `death_05.png` plus `assets/sprites/player/assassin/death/ghost_hooded_face.png`.
- Update `PlayerSpriteFramesBuilder` and the persistent SpriteFrames resource to use five production death frames at approximately 0.45 seconds total.
- Add `scripts/player/player_death_sequence.gd` and compose it with a nearest-neighbor `GhostSprite` in `scenes/player/player.tscn`.
- Narrow `player.gd` to death-state ownership and airborne corpse gravity; change `PlayerRespawnController` to listen to typed death-sequence completion instead of a fixed Player timer.
- Update death/respawn/animation validators and add focused death-presentation timing/cleanup assertions; update `docs/design/player_animation_spec.md`, create `docs/design/player_respawn_spec.md`, and complete this log entry.

### Scope guard

- Do not add enemies, Bosses, damage resolution, Hitbox/Hurtbox nodes, invulnerability, checkpoints, new inputs, sound, particles, RigidBody dagger physics, or unrelated movement/action changes.
- Preserve the current fixed Main spawn, Health/Stamina reset behavior, all reference assets, and every pre-existing uncommitted change. The old placeholder death PNGs remain as unreferenced historical material rather than being deleted.

### Delivered implementation

- Added a deterministic, statically typed Godot Image generator for five original 64×64 death frames and one transparent hooded-face ghost. The active frames move from lethal imbalance through backward collapse to a low horizontal corpse. `death_03` visibly releases both weapons; `death_05` leaves the longer main dagger in front and shorter off-hand dagger on the opposite side without introducing physics bodies.
- Rebuilt `player_sprite_frames.tres` so `death` uses the production `death/death_01...05.png` sequence at 11.111111 FPS, non-looping, for approximately 0.45 seconds. The final wide/low silhouette shares source ground row `y=60`; every body frame also passes the existing nearest-neighbor 48×48 readability path. The previous eight placeholder death PNGs remain unmodified and unreferenced.
- Added a 64×64 pale-blue/white semi-transparent ghost with a front-facing hood, dark face opening, two sharp eye highlights, and a restrained alpha halo. It is a single nearest-neighbor `Sprite2D`, not a particle system or generated runtime blur.
- Added composed `PlayerDeathSequence`. It listens to typed Player life-cycle signals, starts the locked body animation once, reveals the ghost only after `death_05`, floats it upward 14 pixels over 0.35 seconds, holds it visibly for 0.50 seconds, hides it, then emits `sequence_completed`. Its generation guard and single owned Tween prevent late or duplicated completion; respawn cleanup resets the ghost to its hidden default state.
- Removed the parallel fixed one-second Player death timer. Player now owns only `LifeState.DEAD`, action/input/Stamina lockout, and safe dead-body vertical gravity; an airborne dead Player falls without steering. `PlayerRespawnController` listens only to `PlayerDeathSequence.sequence_completed`, so body/ghost presentation must finish before `respawn_at()` can restore the Player.
- Extended automated coverage for five-frame metadata, 64×64/import/mipmap/palette rules, unique frame hashes, final corpse bounds/baseline, ghost partial alpha, sequence phase ordering, 14-pixel rise, 0.50-second pause, no early respawn, duplicate prevention, cleanup, two complete respawn cycles, and restored control/HUD.
- Updated the animation specification and added a dedicated death/respawn ownership, timing, cleanup, and limitation specification.

### Generated PNGs

| Path | Bytes | SHA-256 | Purpose |
| --- | ---: | --- | --- |
| `assets/sprites/player/assassin/death/death_01.png` | 690 | `6f40a823b45b0126cd516281d0052a798af1555df6a6d345f310f60f85aad5b3` | Lethal imbalance |
| `assets/sprites/player/assassin/death/death_02.png` | 664 | `f76d5f44a547e72d3e68aaff8a82919426a9e526c83150cdc56c3f9540dbacf3` | Backward fall |
| `assets/sprites/player/assassin/death/death_03.png` | 579 | `254ad829307a67828e7e502d039a183eec2a53d66f240df1d7e68b5ac2992085` | Near-ground weapon release |
| `assets/sprites/player/assassin/death/death_04.png` | 555 | `4aeffb49fd6bff316d985a07a2af9f54d6396d2a1f814542c576d59b363cad93` | Horizontal impact |
| `assets/sprites/player/assassin/death/death_05.png` | 548 | `4aba4225c45209a42379971f8eb728c8e9729b035c9465016bae1b2d5542b922` | Still corpse and detached daggers |
| `assets/sprites/player/assassin/death/ghost_hooded_face.png` | 483 | `29853c753398a327b18ffb36d9bcdc72308a7bc4cd54f319e6700cdc9128ede9` | Semi-transparent hooded spirit |

All six are 64×64 RGBA PNG sources with transparent backgrounds, no source mipmaps, Lossless Godot import, and Nearest canvas display.

### Files

- New: `scripts/tools/pixel_player_death_generator.gd` and generated UID.
- Modified: `scripts/tools/build_player_animation_assets.gd`, `scripts/tools/player_sprite_frames_builder.gd`, and `resources/player/player_sprite_frames.tres`.
- New: six PNG sources and Godot import sidecars under `assets/sprites/player/assassin/death/`.
- New: `scripts/player/player_death_sequence.gd` and generated UID.
- Modified: `scenes/player/player.tscn`, `scripts/player/player.gd`, and `scripts/systems/player_respawn_controller.gd`.
- New: `tests/player/test_player_death_presentation.gd` and generated UID.
- Modified: death-state, respawn, animation-system, and animation-asset tests.
- Modified: `docs/design/player_animation_spec.md`; new: `docs/design/player_respawn_spec.md`; modified: this log.
- Preserved: all Health/HUD/death/respawn work already present in the uncommitted working tree and the unrelated SpriteFrames UID normalization history. No placeholder/reference asset was deleted.

### Commands and actual results

1. Asset generation and persistent resource build with exact Godot 4.7.1:
   - `Godot --headless --path . --script scripts/tools/build_player_animation_assets.gd -- --death-presentation-only`: exit 0; `PLAYER_DEATH_PRESENTATION_EXPORT: 6 files, 0 failures`.
   - `Godot --headless --editor --path . --import --quit --log-file /tmp/nocturne_keep_death_asset_import.log`: exit 0; six PNGs imported without error/warning.
   - `Godot --headless --path . --script scripts/tools/build_player_animation_assets.gd --log-file /tmp/nocturne_keep_death_frames_build.log`: exit 0; `PLAYER_SPRITE_FRAMES_BUILD: OK`.
2. Focused validation:
   - `validate_player_animation_assets.gd`: PASS, `38 frames + ghost + 4 byte-identical references`.
   - `test_player_animation_system.gd`: PASS, all 16 animations plus production death count/FPS/loop/flat-body metadata.
   - `test_player_death_state.gd`: PASS, single entry, input/action/Stamina lockout, HUD, full presentation, no respawn when disabled.
   - `test_player_death_presentation.gd`: PASS, flat body, released daggers, ghost rise/pause, duplicate prevention, and cleanup.
   - `test_player_respawn.gd`: PASS, two full presentation-gated death/respawn cycles and input recovery.
3. Final serial suite:
   - All fifteen repository scripts passed. Health, HUD, asset, movement, animation, M1.5 action, fast Attack, Dash Attack, chained Stamina, continuous Air Dash, collision, and respawn regressions remain green.
   - Level metrics remain unchanged at 153.59/83.77 single jump, 281.92/167.10 debug double jump, and 344.00 four-Air-Dash action range.
4. Startup and log scan:
   - Configured Main and independently instantiated Player scene both exited 0 under `--headless --quit-after 2`.
   - All final import/suite/startup logs contained no `SCRIPT ERROR`, `ERROR:`, `WARNING:`, parse error, or missing-resource match.
5. Graphical verification:
   - `test_player_death_presentation.gd` with `--write-movie`, fixed 60 FPS: exit 0, 90 frames at 1280×720. Frames 20, 38, 58, and 80 were inspected at original resolution and show the low corpse, both blades, ghost emergence, top pause, and stable prompt/HUD.
   - `test_player_respawn.gd` with `--write-movie`, fixed 60 FPS: exit 0, 212 frames. Frame 90 confirms the first full sequence has cleaned the ghost/prompt and restored the Player and both bars to 100/100 at the spawn.

### Automated acceptance results

- Health zero enters Dead once, cancels ongoing actions, blocks all Gameplay input, and keeps Stamina unchanged through the sequence.
- `death_05` is a clearly horizontal final frame; both daggers are detached and remain static beside the body. Its production source is distinct from all earlier placeholder frames.
- The ghost cannot appear before body completion. It rises from the corpse by 14 pixels, reaches `GhostPause`, remains visible for at least 29 physics frames (approximately 0.50 seconds), then is hidden before completion.
- The full sequence cannot complete before its body/emerge/pause phases; the timing test requires at least 72 physics frames and observed the nominal approximately 1.30-second flow.
- Repeated zero-Health damage cannot spawn another sequence or ghost. The one owned Tween and ghost node are cleaned after completion and again on respawn.
- Respawn occurs only after `sequence_completed`; two consecutive cycles restore the fixed spawn position, full Health/Stamina, Idle, action/jump buffers, Camera following, HUD, and normal input exactly once per death.
- All previous Gameplay metrics and regressions remain unchanged.

### Manual acceptance requested

1. Run Main, click `DEV TEST · TAKE 25 DAMAGE` four times, and watch the complete sequence without pressing further inputs.
2. Confirm the body reads as falling backward and finishes fully horizontal, with the longer blade in front and shorter blade on the other side rather than still in the hands.
3. Confirm the hooded front-face ghost emerges only after the body settles, rises a small readable distance, visibly pauses, then disappears immediately before respawn.
4. Repeat facing left and right, and trigger one death while airborne to verify the dead body falls without steering and the ghost remains centered on the Player.
5. Confirm the approximately 1.30-second duration feels neither abrupt nor sluggish at normal play speed.

### Known limitations and handoff

- Dagger release is authored directly into the death frames; there is no independent trajectory, bounce, or RigidBody simulation.
- The ghost is a deliberately small single Sprite2D with alpha glow, not a particle/VFX stack. Manual approval may request contrast tuning against future room backgrounds.
- Airborne death uses normal vertical gravity while the body animation proceeds; at extreme future room heights, presentation could complete before landing and may require a separate floor-confirmation gate.
- Main still has one fixed test spawn and no respawn invulnerability, enemy reset, checkpoint selection, audio, screen fade, or final game-over flow.
- No enemy, Boss, damage-source, Hitbox/Hurtbox, combat resolution, input, movement tuning, or unrelated Gameplay system was added.
- No Git commit or push was performed. Work stops here for visual approval.
## 2026-07-23 — ENEMY-BASE-001 Castle Guard and minimal combat foundation

Date: 2026-07-23
Status: complete — implementation and automated/graphical verification passed; manual combat-feel acceptance pending

### Goal

- Add one original 16-bit-inspired melee enemy, `Castle Guard / 古堡守卫`, for testing the existing Player Attack, Dash Attack, evasion, Health, death, and respawn flow.
- Add only the reusable combat responsibilities required by this enemy: typed Hitbox/Hurtbox interaction, faction filtering, one-hit-per-attack memory, and Player attack-frame integration.
- Keep the enemy deliberately slower and more telegraphed than the Player: 0.35-second windup, 0.10-second active window, and 0.45-second recovery are initial playtest hypotheses.

### Planned files and responsibilities

- `scripts/combat/`: add composed Hitbox and Hurtbox components while reusing the existing `HealthComponent` as the sole Health authority.
- `scripts/player/player_action_controller.gd` and `scenes/player/player.tscn`: connect the existing Attack/Dash-Attack frame windows to separate narrow forward hitboxes without changing movement, stamina, input buffering, or animation timings.
- `scripts/enemies/`, `resources/enemies/`, and `scenes/enemies/`: add one data-configured Castle Guard actor with Idle, Patrol, Chase, Attack, Hurt, and Death states.
- `scripts/tools/` and `assets/sprites/enemies/castle_guard/`: generate original transparent 64×64 pixel frames and a persistent SpriteFrames resource using nearest-neighbor import/display.
- `scenes/tools/combat_test_room.tscn`: add a flat, bounded, independently runnable combat laboratory with one Player, one Castle Guard, signal-driven debug values, optional collision-shape visualization, and reset control.
- `tests/combat/` and `tests/enemies/`: cover component filtering/deduplication, Player damage windows, AI transitions/edge safety, fair enemy attack timing, Hurt/Death cancellation, and the end-to-end damage loop.
- `docs/design/combat_system_spec.md`, `docs/design/enemy_castle_guard_spec.md`, and `README.md`: document delivered behavior and manual test controls after verification.

### Verification plan

1. Generate/import enemy assets and build SpriteFrames with the exact Godot 4.7.1 executable.
2. Run headless editor import and isolated component, Player-combat, enemy-AI, and combat-room tests.
3. Run every pre-existing regression script to detect movement, stamina, animation, Health HUD, death, or respawn regressions.
4. Start the Player, Castle Guard, combat test room, and configured Main scenes independently under headless Godot.
5. Capture the combat room graphically at fixed FPS and inspect original-resolution frames for silhouette, facing, weapon/Hurtbox placement, HUD readability, and attack telegraph.

### Scope guard

- This milestone adds exactly one normal melee enemy and no ranged/flying/elite enemy, Boss, drop, loot, experience, combo tree, invulnerability system, production room, or complex navigation.
- Enemy body contact causes no damage; only explicitly active weapon hitboxes may mutate Health.
- Player Attack deals 1 and Dash Attack deals 2. Castle Guard sword attacks deal 1. These integer values are prototype hypotheses, not a finalized difficulty curve.
- No existing Player movement, gravity, jump, Dash, stamina, death presentation, or respawn timing may be retuned as part of this work.

### Delivered implementation

- Added typed `HitboxComponent` and `HurtboxComponent` nodes around the existing single `HealthComponent` contract. Hitboxes own damage/faction/attack id/target memory; Hurtboxes own hostile-contact filtering and Health forwarding. Body collision remains damage-free.
- Named all eight current 2D collision responsibilities and separated World, Player/Enemy bodies, Player/Enemy Hurtboxes, Player/Enemy Hitboxes, and detection.
- Added Player Hurtbox plus distinct mirrored normal/Dash Attack rectangles. Existing animation metadata now opens the normal one-damage rectangle only on `attack_02/03` and the two-damage rectangle only on `dash_attack_03/04`. Action cancellation, chaining, transitions, completion, and Player death reliably close both.
- Added one independently instantiable Castle Guard with centralized config, 3 Health, bounded patrol, wall/edge checks, detection hysteresis, same-platform horizontal Chase, frame-timed sword Attack, interruptible Hurt/knockback, and terminal Death cleanup.
- Generated 24 original transparent 64×64 Castle Guard frames through Godot Image operations: four Idle, six Walk, five Attack, three Hurt, and six Death. All imports are Lossless, mipmap-free, nearest-filtered. The generated contact sheet was visually inspected.
- Encoded Castle Guard attack fairness directly in SpriteFrames duration ratios derived from the config: 0.35 seconds across the first two telegraph frames, 0.10 seconds across active frames three/four, and 0.45 seconds on recovery frame five.
- Added an independently runnable flat combat room with the current Player, one Guard, fixed respawn, Player Health/Stamina UI, Player/Guard Health/state/animation diagnostics, optional world-space combat guides, and Reset.
- Added five new automated scripts and updated two historical Player tests whose previous scope assertions intentionally rejected Hitbox nodes.

### Files

- New combat scripts: `scripts/combat/hitbox_component.gd`, `scripts/combat/hurtbox_component.gd` and generated UID sidecars.
- Modified Player integration: `project.godot`, `scenes/player/player.tscn`, `scripts/player/player.gd`, `scripts/player/player_action_controller.gd`.
- New enemy/config/state: `scripts/enemies/castle_guard.gd`, `castle_guard_config.gd`, `castle_guard_state_machine.gd`, `resources/enemies/castle_guard_config.tres`, `scenes/enemies/castle_guard.tscn`.
- New art tooling/resources: `pixel_castle_guard_generator.gd`, `castle_guard_sprite_frames_builder.gd`, `build_castle_guard_assets.gd`, `resources/enemies/castle_guard_sprite_frames.tres`, 24 PNGs/import sidecars under `assets/sprites/enemies/castle_guard/`, and `docs/qa/castle_guard_animation_sheet.png`.
- New test room/tool: `scenes/tools/combat_test_room.tscn`, `scripts/tools/combat_test_room.gd`.
- New tests: `test_hitbox_hurtbox_components.gd`, `test_player_attack_damage.gd`, `test_combat_test_room.gd`, `test_castle_guard.gd`, `validate_castle_guard_assets.gd`, plus generated UID sidecars.
- New/updated docs: `combat_system_spec.md`, `enemy_castle_guard_spec.md`, `player_combat_spec.md`, `player_animation_spec.md`, `README.md`, and this log.

### Commands and actual results

1. Exact engine and asset generation:
   - `$GODOT_BIN --version`: `4.7.1.stable.official.a13da4feb`.
   - `$GODOT_BIN --headless --path . --script scripts/tools/build_castle_guard_assets.gd -- --generate`: exit 0; `CASTLE_GUARD_ASSET_EXPORT: 25 files, 0 failures` (24 frames plus contact sheet).
   - Headless editor import: exit 0; all 24 PNG sources imported.
   - `$GODOT_BIN --headless --path . --script scripts/tools/build_castle_guard_assets.gd`: exit 0; `CASTLE_GUARD_SPRITE_FRAMES_BUILD: OK`.
2. Focused tests after test-fixture corrections:
   - `HITBOX_HURTBOX_TEST`: PASS.
   - `PLAYER_ATTACK_DAMAGE_TEST`: PASS.
   - `CASTLE_GUARD_ASSET_TEST`: PASS.
   - `CASTLE_GUARD_TEST`: PASS.
   - `COMBAT_TEST_ROOM_TEST`: PASS.
3. Full serial regression:
   - Every one of 20 scripts under `tests/` exited 0. No test log contained `SCRIPT ERROR`, `ERROR:`, or `WARNING:`.
   - Existing measured Player envelopes remained 153.59 px single jump, 281.92 px debug double jump, 344.00 px four-Air-Dash action travel, and 362.22 px total-to-landing in the final run.
4. Independent scene startup:
   - Player, Castle Guard, combat test room, player animation preview, and configured Main each exited 0 under two-frame headless startup; no scene log contained an error or warning.
5. Graphical verification:
   - Combat room ran for 180 fixed 60-FPS frames at 1280×720 using GL Compatibility on Apple M4; exit 0 and no error/warning.
   - Original-resolution frames 0, 30, 60, 90, 120, and 150 were inspected. They show Idle→Chase→raised-sword Attack, correct left-facing sword placement, one-point Health changes on separated swings, fixed HUD, and readable dark-armored silhouette.
   - After the two-sided facing fix, a second 120-frame graphical run also exited 0 without diagnostics; inspected frames 0, 60, and 119 show the Guard facing the Player before Attack, the sword window activating only after windup, and Player Health changing from 100 to 99 once.
   - `docs/qa/castle_guard_animation_sheet.png` was inspected at original resolution; Idle breathing, alternating heavy walk, raised-sword windup, forward active extension, recoil, and horizontal collapse are distinct.

### Verification corrections recorded

- The first isolated component run failed because the dynamic test fixture had not named its Health node `HealthComponent`; production scenes were correct. The fixture was named to match the explicit NodePath contract and passed.
- The first asset validator used `Image.load_from_file`, which produced export-safety warnings. It now decodes `FileAccess` PNG bytes and passes warning-free.
- The first AI fixture placed Player inside the 180-pixel detection radius while asserting Idle, correctly causing immediate Chase. The fixture now begins outside perception. The edge assertion was moved to the actual configured boundary. No enemy tuning changed for these test-only corrections.
- A strengthened two-sided attack assertion exposed that a Guard spawned already inside attack range could start its sword sequence before turning toward a Player on the opposite side. Chase now resolves facing from the target offset before entering Attack. Five consecutive focused enemy runs and the final 20-script regression passed after the production fix.

### Manual acceptance requested

1. Run `scenes/tools/combat_test_room.tscn` and approach the Guard from both sides; confirm 0.35-second windup and the narrow sword direction are readable.
2. Avoid attacks using retreat, jump, Ground Dash, and Air Dash; confirm ordinary body contact alone never changes Health.
3. Confirm J removes one Guard Health, Shift→J removes two, and a single animation never double-hits.
4. Interrupt windup/active frames and confirm Hurt cancels the sword; defeat the Guard and confirm it no longer blocks, detects, moves, or attacks.
5. Use the debug toggle and Reset button; judge whether 45/75 px/s movement, 3 Health, 120 px/s knockback, and recovery cadence feel fair.

### Known limitations and handoff

- Player Hurt remains placeholder art with no dedicated Hurt state or invulnerability frames. Accepted enemy hits update Health and can trigger the complete existing Death/respawn flow without interrupting Player actions.
- The Guard hides after Death rather than dropping loot or respawning. Reset reloads the isolated room.
- Natural defeat of the 100-Health Player takes many one-damage sword hits by design of the requested integer contract; automated tests lower Health to verify the death loop deterministically.
- There is no navigation, jumping AI, attack variation, audio, particles, drops, encounter persistence, second enemy, elite, or Boss.
- Work stops at the first Castle Guard and awaits manual combat-feel approval.

## 2026-07-23 — Cursed Castle Guard animation refinement

Date: 2026-07-23
Status: complete — implementation, automated regression, scene startup, and graphical verification passed; manual animation-feel approval pending

### Goal

- Promote the existing first melee enemy's presentation name to `Cursed Castle Guard / 诅咒剑卫（诅咒古堡守卫）` while retaining the stable internal `CastleGuard` resource and scene identifiers.
- Preserve the already functional four-frame Idle, six-frame heavy Walk, five-frame Attack, three-frame Hurt, and six-frame Death animation contracts.
- Redraw the active Attack poses so frames three/four read as a committed one-handed heavy downward sword cut rather than a Player-like horizontal thrust.
- Redraw the last two Death frames so a fully grounded body visibly darkens, fragments, and dissipates without a Player-style ghost; keep animation completion as the existing cleanup signal.
- Add a generated reference asset under the enemy source tree and refresh the QA animation sheet for manual visual review.

### Planned files and responsibilities

- `scripts/tools/pixel_castle_guard_generator.gd`: refine attack/death pixel construction and generate a stable reference image.
- `assets/sprites/enemies/castle_guard/`: regenerate only the deterministic enemy PNG sources and add `reference/`; retain the existing internal path to avoid duplicating or breaking the combat scene.
- `resources/enemies/castle_guard_sprite_frames.tres`: rebuild against the imported frames without changing animation names or gameplay windows.
- `scenes/tools/combat_test_room.tscn` and documentation: update presentation text to the canonical cursed-guard name while retaining `CastleGuard` code identifiers.
- `tests/tools/validate_castle_guard_assets.gd`: add deterministic checks for the reference asset, grounded death pose, visible late-frame pixel reduction, and the absence of any enemy ghost node/resource.
- `docs/design/enemy_castle_guard_spec.md`, `docs/design/combat_system_spec.md`, and this log: document the revised visual language and verified timing.

### Verification plan

1. Generate assets with the exact Godot 4.7.1 executable, run editor import, and rebuild SpriteFrames.
2. Run the Castle Guard asset validator and enemy state/attack/death test in isolation.
3. Start the enemy scene and combat test room independently, then run the complete repository regression suite.
4. Capture the animation sheet and combat room at original resolution to inspect weight, attack readability, left/right flipping, foot baseline, grounded collapse, and dissolve.

### Scope guard

- This milestone changes only the first enemy's authored pixel presentation, persistent animation resource, validation, display naming, and documentation.
- It does not add or retune Player movement/combat, enemy damage, AI ranges/speeds, a second enemy, elite, Boss, drops, audio, particles, navigation, or level content.
- Attack Hitbox activation remains strictly on zero-based frames 2/3 (`attack_03/04`); death still uses no ghost and no physics-driven sword/body debris.

### Delivered implementation

- Kept the existing 24-frame production contract and stable `CastleGuard` scene/class paths, while promoting the visible name to Cursed Castle Guard / 诅咒剑卫. No duplicate enemy scene or asset tree was introduced.
- Re-authored Attack frames one through four. Frames one/two now hold the sword overhead and load the torso backward; frames three/four drive a clearly diagonal downward-forward single-sword cut. The final frame retains the low committed recovery.
- Re-authored all six Death frames into a continuous imbalance→diagonal fall→near-ground→fully grounded→dark fragmented body→sparse semitransparent debris sequence. Sprite completion still hides the actor; no ghost, particle system, RigidBody, or persistent corpse was added.
- Added `assets/sprites/enemies/castle_guard/reference/cursed_castle_guard_reference.png`, a generated integer-scaled six-pose reference board. The existing QA animation sheet was regenerated at integer scale.
- Added asset invariants for the reference/import, shared foot baseline, downward-forward steel pixels in active Attack art, fully grounded `death_04`, reduced/faded `death_05`, sparse `death_06`, and absence of a ghost node.
- Added an internal-only `--guard-death-demo` command-line argument to the existing combat test room for deterministic graphical capture. It applies lethal damage after 0.25 seconds and does not affect normal gameplay.
- Kept timing unchanged: Idle 4 FPS, Walk 8 FPS, Attack 10 FPS base with custom 0.35/0.10/0.45-second phases, Hurt 16.667 FPS matching 0.18 seconds, and Death 8 FPS. AI, damage, Health, collision, Player actions, and Main scene configuration were not retuned.

### Files changed

- Regenerated art: selected Attack and all Death PNGs under `assets/sprites/enemies/castle_guard/`; new generated `reference/` PNG/import; refreshed `docs/qa/castle_guard_animation_sheet.png`.
- Generation/validation: `scripts/tools/pixel_castle_guard_generator.gd`, `tests/tools/validate_castle_guard_assets.gd`.
- Presentation/test tool: `scripts/enemies/castle_guard.gd`, `scripts/tools/castle_guard_sprite_frames_builder.gd`, `scripts/tools/combat_test_room.gd`, `scenes/tools/combat_test_room.tscn`.
- Documentation: `README.md`, `docs/design/enemy_castle_guard_spec.md`, `docs/design/combat_system_spec.md`, and this log.

### Commands and actual results

1. Asset generation and import with exact Godot `4.7.1.stable.official.a13da4feb`:
   - `--script scripts/tools/build_castle_guard_assets.gd -- --generate`: exit 0; `CASTLE_GUARD_ASSET_EXPORT: 26 files, 0 failures` (24 production frames, QA sheet, reference board).
   - Headless editor import: exit 0; changed Attack/Death sources and the new reference imported without script/resource errors or warnings.
   - SpriteFrames rebuild: exit 0; `CASTLE_GUARD_SPRITE_FRAMES_BUILD: OK`.
2. Focused validation:
   - `CASTLE_GUARD_ASSET_TEST`: PASS — 24 frames plus reference, heavy cut, dissolve, exact timing, scene composition, nearest/lossless/mipmap-free imports, shared baseline, and no ghost.
   - `CASTLE_GUARD_TEST`: PASS — patrol, edge safety, chase, both facings, fair active window, Hurt interruption, and Death cleanup.
   - `PLAYER_ATTACK_DAMAGE_TEST`: PASS; `COMBAT_TEST_ROOM_TEST`: PASS.
3. Complete serial regression:
   - All 20 repository test scripts exited 0. Logs contained no `SCRIPT ERROR`, `ERROR:`, or `WARNING:`.
   - Existing Player metrics remained unchanged: 153.59-pixel single-jump range, 281.92-pixel debug double-jump range, 344.00-pixel four-Air-Dash action travel, and 362.22 pixels through landing.
4. Independent startup:
   - Enemy scene, combat test room, and configured Main each exited 0 under two-frame headless startup with no diagnostics.
5. Graphical verification:
   - A 120-frame fixed-60-FPS combat capture showed the raised-sword telegraph, diagonal heavy cut, correct left-facing presentation, one active sword window, and one-point Player Health loss.
   - A separate 90-frame death capture used the test-only demo argument. Inspected frames showed lethal recoil, grounded armor/sword, faded fragmented body, sparse debris, then complete hide. No ghost appeared.
   - The regenerated contact sheet and reference board were inspected at original resolution; Idle/Walk baseline, heavy step alternation, Attack anticipation/cut/recovery, Hurt recoil, and Death stages are visually distinct.

### Manual acceptance requested

1. Run `scenes/tools/combat_test_room.tscn` and judge whether the six-frame Walk feels sufficiently heavy at actual gameplay scale rather than merely slower.
2. Approach from both sides and confirm the overhead sword in `attack_01/02` gives a readable reaction window before the diagonal `attack_03/04` cut.
3. Interrupt Attack with Player damage and verify the visual transition to Hurt feels intentional.
4. Defeat the Guard normally and confirm the final two dissolve frames remain readable against the intended dark room background without resembling a Player ghost.

### Known limitations and handoff

- The guard has a deliberately compact 64×64 prototype silhouette with no subpixel armor motion, sword trail, audio, particles, or shader dissolve. The late Death breakup is authored directly into PNG pixels.
- Hurt runs at 16.667 FPS rather than the suggested 10–12 because three frames must match the already-approved 0.18-second enemy hard-stun window; changing it would retune gameplay rather than only art.
- Animation names and source folder remain `castle_guard` for API stability. This canonical enemy is the Cursed Castle Guard, not a separate un-cursed variant.
- Work stops at the first enemy animation set. No second enemy, elite, Boss, drop, or unrelated Gameplay work was started.

## 2026-07-23 — First enemy variety batch (delivery)

Status: complete — automated/runtime/visual verification passed; manual balance and readability acceptance pending

### Delivered implementation

- Added Cursed Shield Guard, Decayed Spearman, and Fallen Crossbowman as independently instantiable 64×64 pixel enemies with centralized Resources, AnimatedSprite2D animation sets, grounded AI, attacks, Hurt interruption, fall/dissolve Death, and no ghost.
- Added a 24×8 CrossbowBolt projectile with a separate Projectile collision layer, four-point one-hit damage, faction safety, World ray collision, three-second lifetime, and shooter-independent persistence.
- Kept Health/Hitbox/Hurtbox as composed data/interaction authorities. Added `attack_kind`, an optional typed enemy hit policy, directional shield block/GuardBreak, a narrow `EnemyCombatant` encounter contract, and shared `GroundEnemyBase` lifecycle without copying Castle Guard AI three times.
- Generalized `EncounterGroup` and Main debug from CastleGuard-only arrays to mixed `EnemyCombatant` arrays while retaining `get_guards()` for compatibility.
- Generated and imported 85 original transparent enemy frames plus one bolt through Godot Image operations. All sources are lossless, nearest-filtered, mipmap-free, and pass a nearest-neighbor 48×48 readability floor.
- Added `enemy_variety_test_room.tscn` with all four enemy types, a high platform, type-specific diagnostics, toggleable combat geometry, and Reset.
- Replaced Main's homogeneous 1/1/1/2 layout with four mixed groups sized 2/2/2/3: Guard+Shield, Spear+Guard, platform Crossbow+Guard, and Shield+Spear+Crossbow. F5 remains `res://scenes/main/main.tscn`.

### Prototype balance

| Enemy | HP | Damage | Attack distance | Telegraph / recovery | Normal / Dash hits to kill | Hits to defeat 100-HP Player |
| --- | ---: | ---: | ---: | --- | --- | ---: |
| Castle Guard | 3 | 5 | 46 | 0.35 / 0.45 s | 3 / 2 | 20 |
| Shield Guard | 20 | 8 | 46 | 0.40 / 0.55 s | 20 / 10* | 13 |
| Spearman | 10 | 10 | 76 | 0.45 / 0.60 s | 10 / 5 | 10 |
| Crossbowman | 5 | 4 | 260 | 0.60 Aim / 1.50 Reload | 5 / 3 | 25 |

`*` Frontal Dash play requires one prior GuardBreak input, so the practical all-frontal sequence is at least 11. The explicit four-point bolt requirement is used instead of the earlier eight-point parameter suggestion.

### Commands and actual results

1. Exact Godot 4.7.1 asset pipeline:
   - `pixel_enemy_variety_generator.gd`: exit 0; `ENEMY_VARIETY_PIXEL_BUILD: OK (86 files)`.
   - Headless editor import: exit 0 with no parse/resource/diagnostic match.
   - `enemy_variety_sprite_frames_builder.gd`: exit 0; three persistent SpriteFrames resources saved.
2. Focused verification:
   - `ENEMY_VARIETY_ASSET_TEST`: PASS for 85 64×64 sources, transparency, exact frame/FPS/loop metadata, lossless/no mipmaps, and 48px floor.
   - `ENEMY_VARIETY_TEST`: PASS for frontal Block, back damage, Dash GuardBreak, Spear reach/window, Crossbow Aim/Shoot/Reload/bolt creation, Player 1/2-point damage, Death cleanup, and no enemy ghost.
   - `ENEMY_VARIETY_DAMAGE_TEST`: PASS for Shield 8, Spear 10, Bolt 4, and Player Hurt entry.
   - `CROSSBOW_BOLT_TEST`: PASS for one hit, four damage, and World collision cleanup.
   - `MAIN_ENEMY_INTEGRATION_TEST`: PASS for F5 path, four groups, nine typed enemies, platform Crossbowman, activation, current resources, live HUD/respawn, debug toggle, and collision factions.
3. Complete serial regression:
   - Fresh headless editor import exited 0.
   - All 26 scripts under `tests/` exited 0; output scan found no `SCRIPT ERROR`, `ERROR:`, or `WARNING:`.
4. Scene startup:
   - Shield Guard, Spearman, Crossbowman, CrossbowBolt, old combat room, new variety room, and configured F5 Main all exited 0 under bounded headless runs with no diagnostics.
5. Graphical verification:
   - Configured Main recorded three 1280×720 GL Compatibility frames; `docs/qa/enemy_variety_f5_main.png` visibly reports all 4 groups/9 enemies, Group01-only activation, live Health/Stamina, and the first Guard/Shield encounter.
   - Variety room overview recorded two frames; `docs/qa/enemy_variety_test_room.png` shows the Player plus all four distinct silhouettes, including the Crossbowman on its platform. Representative shield attack, spear full extension, crossbow Aim, and final death/dissolve PNGs were inspected at original resolution.

### Manual acceptance and known limitations

1. Verify shield front/back classification under real left/right movement and judge 20 HP/0.60-second break duration.
2. Judge Spear telegraph, 34-pixel close dead zone, and whether its 10 damage/0.60 recovery is fair.
3. Confirm Crossbow Aim visibility, bolt/world collision, platform reach using Air Dash, and retreat behavior near edges.
4. Play Group04 with debug off and judge three-role readability, spacing, and the Player's existing 0.50-second invulnerability.
5. Enemy art and dissolve are authored prototype pixels with no audio, particles, shader dissolve, drops, navigation, jumping, or enemy respawn.
6. The project contract targets two final normal-enemy types. This larger four-type runtime roster is an explicitly requested evaluation batch; a later approval gate must select/merge roles before final scope lock rather than treating all prototypes as committed production content.

## 2026-07-24 — Compact Debug HUD (preflight)

Status: in progress — read-only audit complete; implementation and verification pending

### Goal

- Keep every existing Player and Enemy diagnostic field available while making the F5 Main view default to a compact two-line summary.
- Add independent F1 visibility, F2 compact/expanded, and F3 Enemy-detail controls through Input Map actions.
- Reduce the formal Health/Stamina footprint and the development damage button without changing their data sources or behavior.
- Replace the current fixed large panels with anchored, container-driven layout that remains on-screen from a small test window through 1920×1080.

### Read-only audit

- `run/main_scene` is `res://scenes/main/main.tscn`; the design viewport is 1280×720 with `canvas_items` stretch.
- Main uses two CanvasLayers: `Main/Interface` for development UI and `Main/HUD` for formal vitals/death UI.
- Player Action diagnostics are currently `Main/Interface/Panel/ActionDebug`, a Label driven every frame by `scripts/tools/player_action_debug_overlay.gd` inside a fixed 986×250 ColorRect.
- Enemy diagnostics are currently `Main/Interface/EnemyDebugPanel/EnemyDebug`, a Label driven every frame by `scripts/tools/main_enemy_debug_overlay.gd` inside a fixed 800×250 ColorRect. It serializes all encounter groups and all live enemy summaries every frame.
- Health is `Main/HUD/HealthContainer` (`PlayerHealthHud`, signal-driven); Stamina is `Main/HUD/StaminaContainer` (`PlayerStaminaHud` on the CanvasLayer, signal-driven). Their current fixed width is 224 pixels.
- `Main/Interface/DamageTestButton` is a 204×38 Button using the existing test-only damage script.
- The current panels use fixed offsets and do not provide responsive anchors or Compact/Expanded state. Existing CheckButtons only hide their individual labels.

### Planned files and responsibilities

- `project.godot`: add non-conflicting F1/F2/F3 Input Map actions.
- `scripts/tools/main_debug_hud_controller.gd`: own visibility, compact mode, Enemy detail state, responsive panel sizing, and small fold controls without recreating nodes.
- `scripts/tools/player_action_debug_overlay.gd`: retain the full five-line diagnostic payload and add a two-line compact renderer.
- `scripts/tools/main_enemy_debug_overlay.gd`: retain the full per-enemy payload, add encounter summary rendering, and throttle visible text refresh to 0.15 seconds.
- `scenes/main/main.tscn`: anchor the debug surfaces, place their children in Containers/ScrollContainer, compact formal vitals, and shrink the existing damage button.
- UI/integration tests: verify defaults, toggles, preserved expanded fields, signal-driven formal HUD, responsive bounds, and current Main resource paths.
- `README.md`, `docs/design/debug_hud_spec.md`, and this log: document operation, exact structure, evidence, and acceptance steps.

### Verification plan

1. Run exact Godot 4.7.1 headless import/parse checks and focused HUD/Main integration tests.
2. Run the complete repository test suite serially and scan all logs for errors and warnings.
3. Start the configured Main scene headlessly and graphically; verify Player/enemy systems remain unchanged.
4. Exercise layout at approximately 1280×664, 1280×720, 1920×1080, and a smaller window.
5. Capture and inspect Compact, Expanded, and fully hidden Debug HUD states under `docs/qa/`.

### Scope guard

- No combat values, Player abilities, enemy AI, encounter composition, animation, collision, Health/Stamina authority, or death/respawn behavior will change.
- No existing debug field will be deleted; fields omitted from Compact mode remain available in Expanded mode.
- The work applies to the configured F5 Main scene, not only a tool or preview scene.

### Delivered implementation

- Added `MainDebugHudController` directly to `Main/Interface`. It owns typed visibility/compact/Enemy-detail signals, handles Input Map actions, updates existing controls in place, and recalculates bounded panel geometry when the viewport changes.
- Rebuilt Main's development layout under a full-rect `DebugHudRoot`. Player Debug is a 340×64 top-left surface; Enemy Debug is a 380×68 bottom-left surface; both use MarginContainer plus ScrollContainer and 11-pixel text. Their backgrounds use 66% opacity.
- Added the default two-line Player summary (`PLAYER/STATE/HP/STA` plus `VX/VY/DASH/HURT/INV`) while preserving the original five-line payload exactly in Expanded mode.
- Added the default two-line active-encounter summary (`ENC/ALIVE/ENGAGED/ATK` plus live type counts). The original four-group/per-enemy diagnostic list remains available in Expanded or F3 Enemy-only detail mode.
- Reduced Enemy diagnostic refresh from every rendered frame to once per 0.15 seconds and disabled both overlay processors when F1 hides Debug.
- Registered F1 `debug_toggle_hud`, F2 `debug_toggle_compact`, and F3 `debug_toggle_enemy_details`. Small 20×20 `+`/`−` buttons mirror F2/F3 without rebuilding nodes or reconnecting signals.
- Anchored formal Health and Stamina to the top-right at 196×56 each, kept their signal-driven bindings intact, reduced label type to 11 pixels, and retained visible numeric current/maximum values.
- Anchored the existing development damage button to the lower-left at 120×28, renamed its visible text to `TAKE 25 DMG`, and kept its original 25-damage behavior. It now hides with the Debug root.
- Center-anchored the existing Death overlay so the HUD remains bounded if the viewport changes; no death timing, presentation, or respawn behavior changed.
- Added deterministic command-line-only screenshot states (`--debug-expanded`, `--debug-hidden`) to the Debug presentation controller. These flags affect QA capture only and do not alter the default F5 state.

### Main scene synchronization

- Configured F5 path: `res://scenes/main/main.tscn`.
- Updated instance paths: `Main/Interface`, `Main/Interface/DebugHudRoot/Panel`, `Main/Interface/DebugHudRoot/EnemyDebugPanel`, `Main/Interface/DebugHudRoot/DamageTestButton`, `Main/HUD/HealthContainer`, and `Main/HUD/StaminaContainer`.
- Current overlay resources: `res://scripts/tools/main_debug_hud_controller.gd`, `res://scripts/tools/player_action_debug_overlay.gd`, and `res://scripts/tools/main_enemy_debug_overlay.gd`.
- Main continues to instantiate the current Player plus all four encounter groups/nine mixed enemies. Existing integration tests confirmed live Health/Stamina, respawn, enemy components, projectiles, and activation after the HUD path update.

### Commands and actual results

1. Exact Godot `4.7.1.stable.official.a13da4feb` import/parse:
   - `/Users/vincentz/Downloads/Godot.app/Contents/MacOS/Godot --headless --path . --editor --quit`: exit 0; scripts/classes and Main loaded without errors or warnings.
2. Focused HUD and integration verification:
   - `tests/ui/test_main_debug_hud.gd`: PASS for default Compact, preserved Expanded content, Enemy-only expansion, F1/F2/F3 end-to-end Input events, processor suspension, formal-HUD independence, compact dimensions, and responsive bounds.
   - `test_player_health_hud.gd`, `test_main_enemy_integration.gd`, `test_dash_attack.gd`, `test_player_death_state.gd`, `test_player_respawn.gd`, and `test_chain_dash_stamina.gd`: all PASS after saved Main path changes.
3. Responsive layout:
   - The isolated HUD test temporarily disabled project content scaling and verified compact/expanded surfaces at 800×540, 1280×664, 1280×720, and 1920×1080. Every panel stayed inside the viewport; Player Debug did not overlap Health, Enemy Debug did not overlap its button, and expanded Player/Enemy surfaces did not overlap.
   - Graphical Movie Maker follows the project's 1280×720 logical canvas under `canvas_items`, so physical `--resolution` requests are encoded at the authored logical size. The responsive test therefore performs the additional scale-disabled true-bound check described above.
4. Complete regression:
   - All 27 scripts under `tests/` exited 0. The combined log scan found no `SCRIPT ERROR`, `ERROR:`, or `WARNING:`.
   - Existing Player metrics remained stable: 153.59-pixel single-jump range, 281.92-pixel debug double-jump range, 344.00-pixel four-Air-Dash range, and 360.33 pixels through landing in this run.
5. Scene startup:
   - Configured Main ran headlessly for 120 frames; `combat_test_room.tscn` and `enemy_variety_test_room.tscn` also started independently. All exited 0 without matched diagnostics.
6. Actual GL Compatibility F5 captures on Apple M4:
   - Compact, Expanded, and hidden Main each rendered one fixed-FPS 1280×720 frame and exited 0. Log scans found no errors or warnings.
   - Original-resolution inspection confirmed the Player and first Guard/Shield encounter remain visible in Compact, all legacy text is readable through Expanded scrolling, and hidden Debug leaves only formal HP/STA.
7. `git diff --check`: PASS.

### QA evidence

- `docs/qa/debug_hud_compact00000000.png`: default F5 Compact Player/Enemy summaries, compact damage button, formal vitals.
- `docs/qa/debug_hud_expanded00000000.png`: complete Player fields and all authored group/enemy rows.
- `docs/qa/debug_hud_hidden00000000.png`: Debug root and damage button hidden; formal Health/Stamina remain visible.

### Manual acceptance requested

1. Run F5 and use F1 twice; confirm all development panels/button disappear and return without affecting Health/Stamina or gameplay.
2. Use F2 while moving, attacking, taking damage, and Dashing; confirm the complete original diagnostic values remain live and Compact restores immediately.
3. Use F3 in Compact mode; confirm only Enemy details expand and that the ScrollContainer keeps the lower panel bounded.
4. Resize the project window around 1280×664, 1280×720, and 1920×1080; confirm default engine-font readability and that the authored logical UI scaling is acceptable on the target display.
5. Judge whether 66% Debug backgrounds provide sufficient contrast on future brighter rooms; this is a presentation approval, not a data or combat change.

### Known limitations and handoff

- Expanded mode intentionally occupies more of the left side because it preserves every original diagnostic field. It is an explicit inspection mode, not the startup presentation.
- The project uses a 1280×720 logical canvas with `canvas_items` stretch. Very small or non-16:9 physical windows scale that logical canvas rather than authoring a second breakpoint-specific font size.
- Current controls use Godot's engine font, not a final licensed pixel UI font. The text remains vector-rendered and is independent of nearest-neighbor sprite filtering.
- Enemy Compact selection follows the latest activated authored group in scene order; encounters are currently one-shot and sequential. A future non-linear encounter system may require an explicit focus authority.
- No debug field, combat value, Player ability, enemy AI/state, encounter member, Health/Stamina rule, animation, collision, or death/respawn behavior was removed or retuned.

## 2026-07-24 — First normal-enemy gray-box rebalance (preflight)

Status: complete — centralized balance, F5 Main synchronization, regression, and graphical verification passed; manual feel approval pending

### Goal

- Preserve the Cursed Castle Guard at 3 HP / 5 damage.
- Reduce the Cursed Shield Guard to 7 HP while preserving 8 damage, directional Block, and GuardBreak.
- Reduce the Decayed Spearman to 5 HP while preserving 10 damage, 76 range, and its current windup/active/recovery cadence.
- Reduce the Fallen Crossbowman to 4 HP and raise its bolt to 6 damage while preserving detection, Aim, Reload, movement, projectile speed, and AI behavior.
- Keep Player Health and normal/Dash Attack damage fixed at 100 / 1 / 2.

### Read-only audit

- F5 remains `res://scenes/main/main.tscn`; Main instances all enemy types from their current PackedScenes, and those scenes reference the shared `resources/enemies/*_config.tres` resources rather than Main-local overrides.
- Runtime Health authority is each enemy Config: `CastleGuard._ready()` and `GroundEnemyBase._ready()` copy `config.max_health` into the composed HealthComponent and reset it before combat.
- Runtime melee damage authority is each enemy Config: attack windows call `begin_attack(..., config.attack_damage)`; the scene's saved Hitbox damage is only a redundant prototype copy.
- Crossbow runtime damage authority is `FallenCrossbowmanConfig.projectile_damage`; `_spawn_bolt()` passes it to `CrossbowBolt.initialize()`. The bolt scene nevertheless retains a redundant four-damage prototype default and activates before initialization.
- Saved enemy scenes also retain redundant old HealthComponent maxima (3/20/10/5), and Shield/Spear Hitboxes retain 8/10. They match current runtime values but can conflict after balancing, so this milestone will remove those scene-local copies.
- Existing tests cover factions, one-hit-per-attack memory, Block/GuardBreak, timing, damage, death, Main composition, and Debug summaries, but do not yet assert all requested kill counts from current Main resources.

### Planned files and responsibilities

- Enemy Config resources: apply only the requested HP/bolt changes and preserve all timing/range fields byte-for-byte.
- Enemy/projectile scenes and `crossbow_bolt.gd`: remove redundant saved HP/damage values and make explicit initialization the only way a bolt opens its Hitbox.
- Enemy damage/profile/Main integration tests plus a focused balance test: assert 3/2, 7/4, 5/3, and 4/2 kill counts, six-point one-hit bolts, Player 100/1/2, unchanged cadence, current Main instances, Debug text, and death entry.
- `README.md`, `docs/design/enemy_roster_spec.md`, and this log: record the revised gray-box table and the distinction between mathematical lethal-hit counts and Player survivable hits.

### Verification plan

1. Run exact Godot 4.7.1 import/parse and focused balance/damage/Main tests.
2. Run every repository test serially and scan output for errors or warnings.
3. Start all four enemy scenes, the bolt, both combat test rooms, and configured Main independently.
4. Run configured F5 Main graphically with Expanded Enemy Debug and inspect current HP/damage values plus live death behavior.

### Scope guard

- No Player Health/damage, enemy range/timing/movement/AI, Block/GuardBreak, encounter composition, animation, collision shape, projectile speed, Hurt, death presentation, drop, or new enemy changes are authorized.
- The values will be changed in shared Config resources used by both independent scenes and every F5 Main instance; Main will not receive divergent local overrides.

### Delivered balance

| Enemy | Before HP / damage | Current HP / damage | Normal / Dash hits | Player survives / lethal hit |
| --- | --- | --- | --- | --- |
| Cursed Castle Guard | 3 / 5 | 3 / 5 | 3 / 2 | 19 / 20 |
| Cursed Shield Guard | 20 / 8 | 7 / 8 | 7 / 4 after break/back access | 12 / 13 |
| Decayed Spearman | 10 / 10 | 5 / 10 | 5 / 3 | 9 / 10 |
| Fallen Crossbowman | 5 / 4 bolt | 4 / 6 bolt | 4 / 2 | 16 / 17 |

- Preserved every requested role/timing value: Castle 46 range and 0.35/0.10/0.45 cadence; Shield 46 range, 0.40/0.10/0.55 cadence, directional Block, and 0.60 GuardBreak; Spear 76 range and 0.45/0.10/0.60 cadence; Crossbow 280 detection, 0.60 Aim, 1.50 Reload, 260 projectile speed, and three-second lifetime.
- Preserved Player 100 Health, one-point normal Attack, and two-point Dash Attack.
- Removed saved `HealthComponent.max_health` copies from all four enemy PackedScenes and saved `Hitbox.damage` copies from Shield, Spear, and CrossbowBolt scenes. Shared enemy Config resources are now the only authored balance source.
- CrossbowBolt no longer opens its Hitbox from a scene-local default during `_ready()`. It remains inactive until the shooter passes `FallenCrossbowmanConfig.projectile_damage` to `initialize()`, which assigns six damage and starts the one-hit attack id.
- Kept the inherited Crossbow `attack_damage` equal to `projectile_damage` inside the same Config so generic inspector/debug consumers cannot report a contradictory value; runtime bolt damage continues to use the explicit projectile field.

### F5 Main synchronization

- `run/main_scene` remains `res://scenes/main/main.tscn`.
- Main's 3 Castle Guards, 2 Shield Guards, 2 Spearmen, and 2 Crossbowmen all instance the current enemy PackedScenes; those scenes reference the updated shared Config resources, with no Main-local HP/damage overrides.
- The Main integration test read every live instance and confirmed the expected type profile. It then used the actual Main Player normal/Dash Hitboxes against paired live instances of every enemy type, confirmed 3/2, 7/4, 5/3, and 4/2 hit counts, verified each Death animation, emitted completion, confirmed dissolve/hide cleanup, and confirmed no enemy ghost. The extra third Castle Guard also follows the same Config and is used for a direct lethal-path assertion.
- Expanded Main Enemy Debug reported `HP 3/3 DMG 5`, `HP 7/7 DMG 8`, `HP 5/5 DMG 10`, and `HP 4/4 DMG 6` on the live F5 instances.

### Commands and actual results

1. Exact Godot `4.7.1.stable.official.a13da4feb` editor import/parse: exit 0 without matched errors or warnings.
2. Focused balance checks:
   - `ENEMY_BALANCE_TEST`: PASS — Player 100/1/2, centralized Config values, unchanged ranges/cadences, no scene-local duplicates, kill counts 3/2, 7/4, 5/3, 4/2, and same-attack deduplication on every type.
   - `ENEMY_VARIETY_TEST`: PASS — Shield Block/GuardBreak, Spear reach, Crossbow Aim/Reload, current HP, Player damage totals, Hurt, and non-ghost Death.
   - `ENEMY_VARIETY_DAMAGE_TEST`: PASS — Shield 8, Spear 10, Bolt 6, and Player Hurt entry.
   - `CROSSBOW_BOLT_TEST`: PASS — six damage, single-hit memory, World collision cleanup.
   - `MAIN_ENEMY_INTEGRATION_TEST`: PASS — four groups/nine current Main enemies, latest Debug values, activation, actual Main Player Hitbox kill counts for all four roles, Death animation/dissolve, HUD/respawn, and projectile layer.
   - `PLAYER_ATTACK_DAMAGE_TEST`: PASS — Player Attack remains one, Dash Attack remains two, active windows/dedup/facing unchanged.
3. Complete regression: all 28 test scripts exited 0; combined logs contained no `SCRIPT ERROR`, `ERROR:`, or `WARNING:`. Existing movement metrics remained 153.59 single-jump range, 281.92 double-jump range, 344.00 four-Air-Dash range, and 360.33 pixels through landing.
4. Independent startup: Castle Guard, Shield Guard, Spearman, Crossbowman, CrossbowBolt, combat test room, enemy variety room, and configured Main all exited 0 under bounded headless runs with no matched diagnostics.
5. Graphical configured-Main run:
   - `Godot --path . --write-movie docs/qa/enemy_balance_f5_main.png --fixed-fps 1 --quit-after 1 --audio-driver Dummy -- --debug-expanded`: exit 0 using GL Compatibility on Apple M4.
   - Original-resolution inspection shows the live Player at 100/100 and all nine Main enemies with the current HP/damage values in Expanded Enemy Debug.
6. `git diff --check`: PASS.

### QA evidence and manual acceptance

- `docs/qa/enemy_balance_f5_main00000000.png`: configured F5 Main, current encounter instances, current Expanded Enemy Debug HP/damage, formal Player HUD.
- Manually confirm the seven-hit post-break Shield window feels brief enough before Block returns; the automated kill-count check intentionally disables Block to measure pure post-break/back damage math.
- Manually judge whether six-point bolts plus 0.60 Aim/1.50 Reload create enough pressure without making Group03/04 oppressive.
- The practical all-frontal Shield Dash sequence is five inputs, not four: one Dash Attack is consumed by GuardBreak, followed by four damaging Dash Attacks if the punish opportunities are maintained.

### Known limitations and handoff

- These are deterministic gray-box damage counts, not a final difficulty curve. Enemy group composition and Player invulnerability can materially change encounter time-to-kill and time-to-death.
- Enemy Debug shows the current configured damage source, not predicted DPS or blocked damage.
- Historical development-log entries retain the values that were true when those milestones shipped; this dated section and the current roster/specification supersede them.
- No Player stat, enemy timing/range/AI, encounter placement, animation, collision, Hurt/Death behavior, or new content was changed.
## 2026-07-24 — Shield Guard permanent break feedback (preflight)

Status: complete — implementation, 28-script regression, standalone/F5 startup, and graphical Main evidence passed; manual feel/readability approval pending

### Goal

- Make a frontal Player Dash Attack permanently destroy the Cursed Shield Guard's shield.
- Hold a distinct 0.70-second GuardBreak state with no blocking, attacking, or chasing.
- Replace the intact-shield recovery with readable pixel fragments/flash and persistent unshielded movement, attack, Hurt, and Death presentation.
- Expose `BLOCK ON/OFF`, `SHIELD BROKEN true/false`, and state through the existing Main Enemy Debug detail view.

### Read-only audit

- F5 remains `res://scenes/main/main.tscn`; its `World/Encounters/EncounterGroup01/Enemies/CursedShieldGuard01` and `EncounterGroup04/Enemies/CursedShieldGuard02` both instance `res://scenes/enemies/cursed_shield_guard.tscn` without local shield overrides.
- `ShieldBlockComponent` currently owns only transient `is_blocking`. A frontal Dash Attack emits `guard_broken`, but no permanent broken flag is recorded.
- `CursedShieldGuard._process_reaction()` currently re-enables blocking after the 0.60-second timer, and every Idle/Patrol/Chase/Hurt recovery also requests blocking.
- The current three-frame `guard_break` shifts an intact shield downward. Subsequent `idle`, `walk`, `attack`, `hurt`, and `death` frames all render the full shield again.
- Expanded Main Enemy Debug receives `CursedShieldGuard.get_debug_summary()`, but that summary currently reports only the transient Block and Hitbox flags.

### Planned files and responsibilities

- `shield_block_component.gd`: own the one-way broken state and make all post-break block requests ineffective.
- Shield Guard script/config/scene: enforce GuardBreak priority and duration, drive the break effect, select persistent unshielded animations, and expose truthful Debug fields.
- Shield Guard pixel generator, SpriteFrames builder, assets, and resources: author four GuardBreak poses, a short fragment/flash overlay, and unshielded Idle/Walk/Attack/Hurt/Death variants.
- Shield Guard asset/behavior/Main tests: assert one-time break, 0.70 seconds, permanent frontal vulnerability, visual disappearance, state lock, both facings, and live Main instances.
- Shield Guard, combat, roster, and development documents: record the permanent-break contract without changing 7 HP or 8 damage.

### Verification plan

1. Run exact Godot 4.7.1 asset generation/import and SpriteFrames build.
2. Run focused Shield Guard behavior, asset, combat-damage, balance, and Main integration tests.
3. Run every repository test serially and scan for errors/warnings.
4. Start the Shield Guard scene independently and run configured F5 Main graphically, preserving a QA capture of the live broken state.

### Scope guard

- No other enemy, Player ability/stat, combat damage, encounter composition, HUD layout, Boss, hit-stop, camera shake, or new system is authorized.
- Shield Guard balance remains 7 Health and 8 attack damage. Only the explicitly requested GuardBreak duration changes from 0.60 to 0.70 seconds.

### Delivered implementation

- Added permanent `shield_broken` authority to `ShieldBlockComponent`. The first intact frontal Dash Attack changes it once, emits one break event, consumes that Dash damage, and forces all future block requests off. Back Dash Attacks and every post-break attack resolve as ordinary damage.
- Kept GuardBreak as a dedicated state for 0.70 seconds. Attack, chase, and target-acquisition transitions are rejected while locked; punish damage is accepted without replacing the larger GuardBreak silhouette with ordinary Hurt. Death retains higher priority.
- Re-authored GuardBreak as four 64×64 frames: cracked/white-flashed shield, two fragment/recoil stages, then an unshielded hard-stun hold. Added a separate four-frame 12 FPS pale flash/iron-fragment overlay at `FacingRoot/ShieldBreakEffect`; it hides after completion.
- Added persistent unshielded Idle (4), Walk (6), Attack (5), Hurt (3), and Death (6) production frames. The Shield Guard dynamically resolves only its own post-break presentation to these animations, so the shield cannot reappear during action, damage, AI reset, or death cleanup.
- Added a narrow death-animation hook to `GroundEnemyBase` so the Shield Guard's `death_unshielded` variant completes the existing dissolve/free lifecycle without changing other enemy behavior.
- Expanded Shield Guard debug summary fields to include explicit `STATE`, uppercase `BLOCK ON/OFF`, and `SHIELD BROKEN true/false`. Existing Main Enemy Debug renders the same live string in Expanded mode.
- Preserved 7 Health, 8 attack damage, all attack timing/range/movement values, both authored Main instances, Player values, encounter composition, and every other enemy.

### Commands and actual results

1. Exact engine and resource production:
   - `/Users/vincentz/Downloads/Godot.app/Contents/MacOS/Godot --version`: `4.7.1.stable.official.a13da4feb`.
   - Pixel generator: `ENEMY_VARIETY_PIXEL_BUILD: OK (115 files)`.
   - Fresh headless editor import: exit 0; all new PNGs imported losslessly without mipmaps.
   - SpriteFrames builder: `ENEMY_VARIETY_SPRITE_FRAMES_BUILD: OK`.
2. Focused verification:
   - `ENEMY_VARIETY_TEST`: PASS for front Block, back damage, one-time break, 0.70-second lock, no Attack transition, permanent frontal vulnerability, unshielded Idle/Walk/Attack/Hurt/Death, effect cleanup, and non-ghost Death.
   - `ENEMY_VARIETY_ASSET_TEST`: PASS for 114 64×64 enemy/effect frames plus bolt, transparency, lossless/no-mipmap import, 48×48 readability floor, and exact 0.70-second GuardBreak animation duration.
   - `ENEMY_BALANCE_TEST`: PASS; requested 3/2, 7/4, 5/3, 4/2 kill counts and centralized values remain unchanged.
   - `ENEMY_VARIETY_DAMAGE_TEST`: PASS; Shield damage remains 8.
   - `MAIN_ENEMY_INTEGRATION_TEST`: PASS using both live Main Shield Guards for frontal Block, frontal Dash break, 0.70-second lock, post-break frontal damage, back damage, Debug fields, correct shielded/unshielded Death, and cleanup.
   - The first asset-test run exposed a test-only `frames`/`sprite_frames` identifier typo. It was corrected; the final asset test and subsequent regression are clean.
3. Complete regression:
   - All 28 scripts under `tests/` passed serially. No final run contained `SCRIPT ERROR`, `ERROR:`, or `WARNING:`.
   - Movement metrics remained 153.59-pixel single-jump range, 281.92-pixel debug-double-jump range, 344.00-pixel four-Air-Dash action range, and 360.33 pixels through landing.
4. Runtime startup and graphical Main:
   - Shield Guard standalone startup (`--quit-after 60`): exit 0.
   - Configured F5 Main startup (`Godot --headless --path . --quit-after 120`): exit 0.
   - GL Compatibility Main QA capture on Apple M4: 19 frames at 1280×720/30 FPS, exit 0. It used `Main/World/Player`'s real Dash Hitbox against `EncounterGroup01/Enemies/CursedShieldGuard01` and exposed the broken state in Expanded Enemy Debug.
5. Final `git diff --check`: PASS.

### F5 Main synchronization and QA evidence

- `application/run/main_scene` remains `res://scenes/main/main.tscn`.
- Main nodes `World/Encounters/EncounterGroup01/Enemies/CursedShieldGuard01` and `EncounterGroup04/Enemies/CursedShieldGuard02` both instance the updated `res://scenes/enemies/cursed_shield_guard.tscn`; neither has local behavior, config, SpriteFrames, or shield-state overrides.
- The shared scene now owns `FacingRoot/ShieldBreakEffect` and loads `cursed_shield_guard_sprite_frames.tres` plus `cursed_shield_guard_shield_break_fx_sprite_frames.tres`. Saving/reopening therefore retains the implementation without editing Main-local instance data.
- `docs/qa/shield_guard_break_f5_main.png` is the inspected 1280×720 Main frame. It shows the live break flash, recoiling shield enemy, and Expanded row `STATE GuardBreak ... BLOCK OFF SHIELD BROKEN true`.

### Manual acceptance and known limitations

- Manually test both facings at normal game speed and judge whether the pale flash/fragments remain readable against future brighter rooms; automated and original-resolution inspection establish presence, not subjective impact.
- Confirm the permanent-defense loss makes the seven-Health enemy appropriately vulnerable for the remainder of the encounter. No HP/damage compensation was introduced.
- The break effect is intentionally lightweight: embedded pixel cracks/fragments plus a short overlay. Hit-stop, camera shake, audio, particles, shield physics, shield regeneration, and additional combat systems remain excluded.
- GuardBreak preserves its large recoil animation while accepting punish damage. It does not play the smaller ordinary Hurt animation until after the 0.70-second lock ends.

## 2026-07-24 — Shield break Main readability follow-up (preflight)

Status: complete — Main readability fix, 28-script regression, standalone/F5 startup, and graphical evidence passed; manual approval pending

### Goal

- Make the existing one-time Shield Guard break unmistakable at normal F5 Main camera distance without changing combat balance or shield rules.
- Keep the break flash/fragments readable for the full 0.70-second GuardBreak window and add a compact persistent broken-shield cue during that hard stun.
- Preserve the permanent unshielded animation set after GuardBreak.

### Read-only audit

- F5 still resolves to `res://scenes/main/main.tscn`; both Main Shield Guard instances use the shared current `res://scenes/enemies/cursed_shield_guard.tscn` without local overrides.
- The current `FacingRoot/ShieldBreakEffect` is a 64×64 four-frame overlay played at 12 FPS and 1× scale, so it lasts only about 0.33 seconds while GuardBreak itself lasts 0.70 seconds.
- The previous QA frame proves `STATE GuardBreak`, `BLOCK OFF`, and `SHIELD BROKEN true`, but its only non-debug break cue is a very small pale cross. That is not sufficient visual acceptance evidence.
- Permanent `idle_unshielded`, `walk_unshielded`, `attack_unshielded`, `hurt_unshielded`, and `death_unshielded` resources are already correct and must remain intact.

### Planned files and responsibilities

- Shield break pixel generator/assets/SpriteFrames: enlarge the authored flash/fragments, add a pixel broken-shield marker, and align overlay duration with the 0.70-second state.
- Shield Guard scene/script: show the marker for the entire GuardBreak, apply a brief body flash, and guarantee cleanup on recovery or death.
- Shield behavior/Main/asset tests: assert effect scale/duration, marker lifecycle, persistent broken state, and both live Main instances.
- Shield/combat specs and this log: record the failed acceptance finding and the corrected presentation contract.

### Verification plan

1. Regenerate/import the focused pixel assets and rebuild SpriteFrames with exact Godot 4.7.1.
2. Run focused asset, Shield behavior, and live Main integration tests, then all repository tests.
3. Start the standalone enemy and configured Main, then capture and inspect a new original-resolution Main break frame.

### Scope guard

- No Health, damage, Block direction, GuardBreak duration, AI cadence, encounter placement, Player ability, other enemy, HUD, camera shake, hit-stop, audio, Boss, or unrelated system changes.

### Delivered correction

- Re-authored the four break-overlay frames with a larger eight-direction pale impact, brighter core, and more widely separated metal fragments. The scene displays the 64×64 overlay at integer 2× nearest-neighbor scale.
- Changed the overlay from 12 FPS/about 0.33 seconds to 5.714 FPS/exactly 0.70 seconds so feedback spans the complete GuardBreak window.
- Added `VisualRoot/GuardBreakMarker`, a 20×20 transparent cracked-shield pixel icon above the enemy. It remains visible for the complete hard stun and is removed on recovery or Death.
- Added a restrained 0.12-second body highlight at the break instant. No camera shake, hit-stop, audio, particle system, or gameplay timing change was introduced.
- Kept every permanent unshielded animation and the existing permanent `shield_broken` authority. Health remains 7 and attack damage remains 8.
- Updated the graphical QA utility to preserve the default Compact Main HUD so the cue is judged in normal play space rather than behind Expanded diagnostics.

### Commands and actual results

1. Exact Godot `4.7.1.stable.official.a13da4feb` pixel generation/import/build:
   - `ENEMY_VARIETY_PIXEL_BUILD: OK (116 files)`.
   - `Godot --headless --path . --import`: exit 0; the new marker and four revised effect PNGs imported losslessly without mipmaps.
   - `ENEMY_VARIETY_SPRITE_FRAMES_BUILD: OK`.
2. Focused checks:
   - `ENEMY_VARIETY_ASSET_TEST`: PASS — 64×64 effect frames, 20×20 marker, transparent/lossless imports, and exact 0.70-second overlay duration.
   - `ENEMY_VARIETY_TEST`: PASS — enlarged effect, marker lifecycle, one-time break, 0.70-second lock, permanent unshielded recovery, and Death cleanup.
   - `MAIN_ENEMY_INTEGRATION_TEST`: PASS — both shared live Main Shield instances own the latest effect/marker; frontal Player Dash Hitbox starts both cues and recovery clears them without restoring Block.
3. Complete regression: all 28 repository test scripts exited 0 with no final `SCRIPT ERROR`, `ERROR:`, or `WARNING:`. Player movement metrics remain unchanged at 153.59 single-jump, 281.92 double-jump, 344.00 four-Air-Dash action range, and 360.33 pixels through landing.
4. Runtime startup: standalone Shield Guard and configured F5 Main both exited 0 under bounded headless runs with no diagnostics.
5. Graphical configured-Main capture: 19 frames at 1280×720/30 FPS under GL Compatibility on Apple M4, exit 0. The inspected frame uses the real `Main/World/Player` Dash Attack Hitbox against `EncounterGroup01/Enemies/CursedShieldGuard01` and retains the default Compact HUD.
6. `git diff --check`: PASS.

### F5 Main synchronization and QA evidence

- `application/run/main_scene` remains `res://scenes/main/main.tscn`.
- `World/Encounters/EncounterGroup01/Enemies/CursedShieldGuard01` and `EncounterGroup04/Enemies/CursedShieldGuard02` both instance the revised shared `cursed_shield_guard.tscn`; no Main-local override or stale PackedScene exists.
- The shared scene now loads `FacingRoot/ShieldBreakEffect` at 2× and `VisualRoot/GuardBreakMarker`; saving and reopening Main retains both through the PackedScene reference.
- `docs/qa/shield_guard_break_readable_f5_main.png` is the inspected original 1280×720 Compact-HUD frame. It visibly shows the enlarged break impact, shield fragments, cracked-shield marker, and the unshielded recoil pose.

### Manual acceptance and known limitations

- The break requires a **frontal Dash Attack while the shield is still intact**. A rear Dash Attack is ordinary damage by design and intentionally does not trigger the break cue.
- Manually confirm both facings in the normal F5 encounter and judge whether the new cue is sufficiently strong on the target display. Automated evidence establishes timing and visibility, not personal visual preference.
- The cracked-shield marker communicates the 0.70-second punish window only; it disappears when hard stun ends. The permanent missing shield on every subsequent animation communicates the lasting defense loss.

## 2026-07-24 — Shield Guard independent shield-health redesign (preflight)

Status: complete — independent Shield routing, Main integration, 28-script regression, and visual QA passed; manual feel acceptance pending

### Goal

- Replace the one-input frontal Dash break with an independent three-point shield-health component.
- Route one-point normal and two-point Dash attacks exclusively to the intact shield from the front, while rear/center-overlap attacks bypass it and damage the five-point body.
- Separate the shield from body art, expose intact/cracked/critical/broken states, preserve a 0.65-second GuardBreak, and add a 0.22-second target-side turn delay so rear attacks are practically achievable.
- Deliver the same behavior through both shared Shield Guard instances in configured F5 Main.

### Read-only audit

- `project.godot` sets `run/main_scene="res://scenes/main/main.tscn"`.
- Main instances `World/Encounters/EncounterGroup01/Enemies/CursedShieldGuard01` and `EncounterGroup04/Enemies/CursedShieldGuard02` both instance `res://scenes/enemies/cursed_shield_guard.tscn` without local script/config/art overrides.
- Body Health is currently authored as 7 in `cursed_shield_guard_config.tres`; damage is 8 and Player attack values remain centralized at 1/2.
- `ShieldBlockComponent` owns only transient `is_blocking` plus permanent `shield_broken`; it has no maximum/current shield Health or Health-change signal.
- One shared Hurtbox delegates to `ShieldBlockComponent.resolve_damage()`. Source x-position versus `FacingRoot.scale.x` determines front/back with no center tolerance. A frontal Dash Attack immediately calls `break_shield()`; a frontal normal Attack is consumed without changing persistent state.
- The same shared Hurtbox prevents separate Shield/Body Area overlap, and `HitboxComponent` already remembers one target per attack id. This is the correct single routing boundary to retain.
- Shield pixels are baked into intact Idle/Walk/Block/Attack/Hurt/Death body frames. There is no separate ShieldVisual. Existing `_unshielded` frames and GuardBreak/break-effect resources provide a safe body-only and VFX baseline for the refactor.
- Chase calls `set_facing_direction()` as soon as target x changes side, including again on Attack entry. There is no turn timer or turn state, so a player crossing behind can be mirrored within one physics frame.
- Compact Main Enemy Debug currently reports encounter aggregates only; Expanded Shield summary exposes Block/broken state but not shield Health, side routing, damage split, attack id, overflow, or turn timer.

### Planned files and responsibilities

- New `ShieldComponent`: own max/current/broken state, typed signals, center-tolerant side classification, one-path damage routing, last-hit audit data, zero clamp, and no-overflow break contract.
- Shield Guard config/script/scene: set body 5, shield 3, GuardBreak 0.65, turn delay 0.22; arbitrate ShieldHit/Turn/GuardBreak/Death; drive separated ShieldVisual and feedback.
- Pixel generator/SpriteFrames/assets: convert Shield Guard body animations to shield-free art and author independent intact/cracked/critical/break plus small metal-hit assets.
- Main debug overlay and tests: surface compact shield state and expanded routing details without creating new HUD authority.
- README, Shield/combat/roster/encounter specifications, and this log: replace the superseded one-Dash-break contract.

### Verification plan

1. Generate/import/build assets with exact Godot 4.7.1 and validate transparency, nearest/lossless/no-mipmap imports, cracks, break, and foot baseline.
2. Test front normal 3→2→1→0 with body 5, front Dash 3→1→0 without overflow, rear 1/2 body damage with unchanged shield, center-overlap body routing, deduplication, 0.22-second turn window, 0.65-second GuardBreak, permanent unshielded recovery, and non-ghost Death.
3. Test both live Main instances, compact/expanded Debug, Player/HUD/Hurt/respawn regressions, all independent scenes, and the complete repository test suite.
4. Run configured Main graphically and retain original-resolution QA evidence for intact, cracked/critical, and broken states.

### Scope guard

- No other enemy, Player Health/damage/ability, attack timing, encounter count, Boss, item, drop, equipment, camera shake, hit-stop, audio, or unrelated system change.

### Delivered implementation

- Replaced the boolean-only `ShieldBlockComponent` with a typed `ShieldComponent` that owns `shield_max_health=3`, current Shield Health, broken state, change/hit/break signals, source-side classification, zero clamping, and last-hit audit data.
- Retained one shared enemy Hurtbox. Its policy resolves each accepted Player hit to exactly one destination: front normal/Dash attacks apply 1/2 Shield damage; rear or ±8-pixel center-overlap attacks apply 1/2 Body damage. The breaking hit discards overflow and never starts ordinary Body Hurt.
- Changed Shield Guard Body Health from 7 to 5 while retaining damage 8 and all existing move/attack cadence values. GuardBreak is 0.65 seconds and target-side turning is delayed 0.22 seconds.
- Added an explicit `Turn` state. Chase starts the timer when the target crosses behind, keeps the old facing during the window, and flips only after the delay. Attack, Block/ShieldHit, GuardBreak, Hurt, and Death do not turn.
- Separated body and shield presentation. All 31 shielded body source frames were regenerated without shield pixels; `FacingRoot/ShieldVisual` now owns intact, cracked, critical, and four-frame break art. A three-frame metal-hit flash, two-pixel shield shake, existing large fragment overlay, body flash, and GuardBreak marker provide distinct shield feedback.
- Kept the named shieldless action set for post-break Idle/Walk/Attack/Hurt/Death. Zero Shield immediately disables routing, the break runs once, ShieldVisual hides, and no recovery path restores it.
- Added attack-direction context to `HitboxComponent.begin_attack()` and supplied the actual Player/Shield Guard attack facing without changing damage, windows, movement, or input behavior.
- Compact Main Enemy Debug now adds a third shield summary line with Body, Shield, visual state, side, state, and turn timer while preserving the existing 380×68 panel. Expanded Debug additionally reports attack kind/source/direction/id, Shield/Body applied damage, discarded overflow, and GuardBreak remaining time.
- Moved Main Group01 Shield Guard to `(500, 610)` and Castle Guard to `(690, 610)`. This preserves the same roster/count while making the shield mechanic the first isolated encounter target.

### Commands and actual results

1. Exact engine/resource production:
   - `/Users/vincentz/Downloads/Godot.app/Contents/MacOS/Godot --version`: `4.7.1.stable.official.a13da4feb`.
   - Pixel generator: `ENEMY_VARIETY_PIXEL_BUILD: OK (126 files)`.
   - `Godot --headless --path . --import`: exit 0; new/changed transparent PNGs imported without script or resource diagnostics.
   - SpriteFrames builder: `ENEMY_VARIETY_SPRITE_FRAMES_BUILD: OK`.
2. Focused tests:
   - `ENEMY_VARIETY_TEST`: PASS — 3→2→1→0 normal route, 3→1→0 Dash route, no overflow, rear/center Body routing, single-hit memory, Shield states/VFX, 0.22-second turn, 0.65-second GuardBreak, punish window, permanent unshielded Death, and no ghost.
   - `ENEMY_BALANCE_TEST`: PASS — frontal totals 8 normal / 5 Dash; rear totals 5 normal / 3 Dash; other enemies and Player invariants unchanged.
   - `ENEMY_VARIETY_ASSET_TEST`: PASS — 124 64×64 frames/effects plus bolt; transparent, lossless/no-mipmap imports and 48×48 readability floor.
   - `MAIN_ENEMY_INTEGRATION_TEST`: PASS — both saved Main instances own ShieldComponent/ShieldVisual, use Body 5 and Shield 3, execute both frontal break routes, rear bypass, post-break damage, correct debug, Death, and cleanup.
3. Full regression:
   - First pass stopped at `test_main_debug_hud.gd` because an interim 420×84 panel exceeded the existing compact contract. The panel was restored to 380×68 without dropping fields.
   - Final serial run: all 28 scripts under `tests/` exited 0 with no final `SCRIPT ERROR`, `ERROR:`, or `WARNING:` output.
   - Player level metrics remain 153.59 single-jump range, 281.92 debug-double-jump range, 344.00 four-Air-Dash action range, and 360.33 pixels through landing.
4. Runtime startup:
   - `Godot --headless --path . res://scenes/enemies/cursed_shield_guard.tscn --quit-after 120`: exit 0.
   - `Godot --headless --path . --quit-after 120`: configured F5 Main exit 0.
5. Graphical Main QA:
   - `Godot --path . --script res://scripts/tools/capture_shield_guard_break_main.gd --write-movie docs/qa/shield_guard_independent_main.png --fixed-fps 30 --audio-driver Dummy --log-file docs/qa/shield_guard_independent_main.log`: exit 0 under GL Compatibility on Apple M4; 37 frames at 1280×720.
   - The capture uses the real Main Player Dash Hitbox twice against `EncounterGroup01/Enemies/CursedShieldGuard01`. Selected frames were inspected at original resolution.
6. Final `git diff --check`: PASS.

### F5 Main synchronization and QA evidence

- `application/run/main_scene` remains `res://scenes/main/main.tscn`.
- `World/Encounters/EncounterGroup01/Enemies/CursedShieldGuard01` and `World/Encounters/EncounterGroup04/Enemies/CursedShieldGuard02` both reference the current `res://scenes/enemies/cursed_shield_guard.tscn` with no local script/config/resource override.
- The shared scene owns `ShieldComponent`, one `Hurtbox`, `FacingRoot/ShieldVisual`, `ShieldHitEffect`, `ShieldBreakEffect`, body-only SpriteFrames, and the existing GuardBreak marker. Main therefore cannot retain the removed boolean policy or shield-baked art after reload.
- `docs/qa/shield_guard_critical_f5_main.png` (SHA-256 `2dc545143e9f0a336e5300fd2dff3c2923cae42b630fd3b189bda6b3117e1150`) shows live Main at Body 5/5, Shield 1/3, `critical`, front-side Block.
- `docs/qa/shield_guard_break_f5_main_v2.png` (SHA-256 `62e11d0bacaf02477ae6027d9706f7637e1102a3920f215d2dc6b80f2758ef9f`) shows the second Dash impact, Shield 0/3, `broken`, GuardBreak, flash/fragments, marker, and absent shield body art.
- Main integration and the full suite also preserve live Health/Stamina binding, Player Hurt/invulnerability, death ghost/respawn, encounters, other enemy damage/Death, camera, and movement behavior.

### Manual acceptance and known limitations

- Manually judge the light/severe crack shapes at the user's display scale and test both facings with actual inputs. Automated image inspection establishes that distinct art and state transitions are rendered, not subjective readability on every monitor.
- The 0.22-second turn uses the existing idle body pose rather than new bespoke turn frames. Logic and facing remain truthful throughout the rear window.
- No always-on in-world Shield bar was added; the required visual cracks are authoritative, while Compact/Expanded Debug provides numeric development confirmation.
- Hit-stop, camera shake, audio, rigid shield fragments, shield regeneration, new attacks, and all unrelated enemy/Player systems remain intentionally excluded.

## 2026-07-24 — Shield Guard Dash penetration and break-flash correction (preflight)

Status: complete — unified source routing, two-layer attack-id deduplication, softer shield-local flash, 28-script regression, and configured-Main graphical QA passed; manual feel acceptance pending

### Goal

- Stop one frontal Dash Attack from reaching Shield and Body during the same action, including the frame after a breaking hit.
- Keep rear routing and no-overflow behavior unchanged.
- Replace the current whole-body/high-intensity break flash with a 0.05-second, 0.30-alpha shield-local cue while retaining cracks, fragments, disappearance, and GuardBreak.

### Read-only audit and root cause

- `project.godot` still resolves F5 to `res://scenes/main/main.tscn`; both saved Main Shield Guards instance the current shared `cursed_shield_guard.tscn` without local overrides.
- Shield Guard has exactly one `HurtboxComponent`, which delegates to exactly one `ShieldComponent`; there are no overlapping Shield/Body Hurtboxes and no Area signal-order race between two Health writers.
- Player normal and Dash attacks use separate Hitbox nodes. A Dash Attack action creates one `_current_attack_id`, opens the Dash Hitbox across consecutive frames 03–04, and `HitboxComponent` normally remembers the one target for that active window.
- `ShieldComponent` nevertheless classifies side using `hitbox.global_position`. At body-contact distance the Player remains in front while the 37-pixel-forward Dash Hitbox center reaches the Shield Guard center/other side, so the unified policy can misclassify a visually frontal Dash as Body. Tests previously placed the Hitbox center 30–32 pixels in front and did not reproduce real scene geometry.
- `ShieldComponent` also has no independent consumed-attack ledger. If the same Dash Hitbox is re-enabled/re-scanned with the same `attack_id` after Shield reaches zero, its local target set may be cleared and the now-broken policy can route that continuing action to Body.
- The current break presentation combines a 2× overlay containing a pure-white 9×9 core with whole-body `Color(1.8, 1.65, 1.25)` modulation lasting 0.12 seconds. This makes the auxiliary flash visually dominate the authored cracks/fragments.

### Planned files and scope

- `HitboxComponent` and Player action wiring: carry the typed attacker/root source position while preserving the same stable action id and all animation/input/damage values.
- `ShieldComponent`: classify against attacker position, record the last consumed id per attacker, reject repeated submissions even after break, and expose route/dedup/overflow audit fields.
- Shield Guard config/presentation/generator: configure 0.05/0.30, localize the flash to the shield, soften the overlay core, and keep all existing fragment/GuardBreak timing.
- Shield/Main tests: reproduce actual Player/DashHitbox offsets, both facings, same-id re-entry after break, new-id post-break damage, unchanged rear damage, and saved Main instances.
- Only `development_log.md`, `combat_system_spec.md`, and `enemy_cursed_shield_guard_spec.md` will be updated. No balance, animation timing, Player movement/action, encounter-count, other-enemy, or new-feature changes are in scope.

### Delivered correction

- Extended `HitboxComponent` with a typed attacker reference. Player normal and Dash active windows now retain the Player root as their source, while all existing callers fall back to the Hitbox position. The Shield policy therefore classifies the actor's side rather than the forward weapon volume's center.
- Kept one shared Shield Guard Hurtbox and one `ShieldComponent` decision boundary. A received attack is marked consumed before the policy selects exactly one route: intact/front Player weapon attacks go to Shield; rear, center-source, non-Player-weapon, or already-broken cases go to Body.
- Added a bounded Shield-side ledger keyed by `attacker instance id + attack_id`. It survives shield break and rejects a later active frame or a second detector submission from the same action. `HitboxComponent` also no longer clears its local target memory when the same attack id is merely reopened.
- Retained no-overflow semantics. A two-damage Dash against Shield 1/3 produces Shield 0/3, records one discarded point, enters GuardBreak, and leaves Body 5/5.
- Replaced the 0.12-second whole-body `Color(1.8, 1.65, 1.25)` break highlight with a shield-local 0.05-second alpha-0.30 pale-steel flash. The 9×9 pure-white core and long thick rays were removed from the first two overlay frames; cracks, metal fragments, shield disappearance, marker, and 0.65-second GuardBreak remain.
- Ordinary shield-hit feedback is now lower priority than break: local spark alpha 0.18 and mild ShieldVisual modulation `Color(1.08, 1.06, 0.98)`; the body is never flashed.
- Compact Shield Debug remains inside the existing panel contract and reports Body/Shield, side, route, type/id, broken, and state. Expanded output adds shield/body detector route flags, consumed, duplicate blocked, and discarded overflow.

### Actual route matrix

- Front normal from Shield 3/3: Body remains 5/5 while Shield progresses 2/3 → 1/3 → 0/3.
- Front real-geometry Dash: before `BODY 5 SH 3`; hit 1 `BODY 5 SH 1`; hit 2 `BODY 5 SH 0`.
- Shield 1/3 + front Dash 2: `BODY 5 SH 0`, overflow discarded 1.
- Rear Dash: `BODY 3 SH 3`.
- After break, new ids route normally: new normal changes Body 5→4; the following new Dash changes Body 4→2.
- The regression fixture explicitly places the Player 34 pixels in front while the authored Dash Hitbox center reaches the Shield Guard's ±8-pixel center tolerance. It therefore reproduces the old false Body route and verifies the Player-root correction rather than hiding it by shrinking the Hitbox.

### Commands and actual results

1. Exact Godot 4.7.1 asset production/import:
   - `Godot --headless --path . --script scripts/tools/pixel_enemy_variety_generator.gd`: exit 0; `ENEMY_VARIETY_PIXEL_BUILD: OK (126 files)`.
   - `Godot --headless --path . --editor --quit`: exit 0; two revised break-overlay PNGs reimported without diagnostics.
2. Focused tests:
   - `test_hitbox_hurtbox_components.gd`: PASS, including same-id active-window reopen deduplication.
   - `test_player_attack_damage.gd`: PASS, including stable Dash id across both active frames and Player-root source context.
   - `test_enemy_variety.gd`: PASS and printed `SHIELD_DASH_MATRIX: before B5 SH3; front1 B5 SH1; front2 B5 SH0; rear B3 SH3; post-break normal/dash B4/B2`.
   - `test_enemy_balance.gd`: PASS; Body 5, Shield 3, damage 8, GuardBreak 0.65, turn 0.22, Player 1/2, and all other enemy values remain unchanged.
   - `test_main_enemy_integration.gd`: PASS using the live Main Player/Shield Guard geometry and the shared Main instances.
   - `validate_enemy_variety_assets.gd`: PASS for 124 64×64 frames/effects plus bolt, transparency, lossless/no-mipmap imports, and 48-pixel readability floor.
3. Full serial regression: all 28 scripts under `tests/` exited 0; no captured output contained final `SCRIPT ERROR`, `ERROR:`, or `WARNING:` diagnostics.
4. Runtime startup:
   - Standalone `cursed_shield_guard.tscn --quit-after 120`: exit 0.
   - Configured F5 Main `--quit-after 120`: exit 0.
5. Graphical configured-Main run:
   - `capture_shield_guard_break_main.gd` with `--write-movie`, 1280×720, fixed 30 FPS, GL Compatibility on Apple M4: exit 0, 37 frames.
   - Runtime output: `SHIELD_MAIN_QA: BODY 5 SH 0 ROUTE shield SIDE front DUP false`.
   - Original-resolution inspection confirms Shield 1/3 critical feedback, Shield 0/3 GuardBreak, missing shield, fragments/marker, and no whole-body white flash.

### F5 Main synchronization and QA evidence

- `application/run/main_scene` remains `res://scenes/main/main.tscn`.
- `World/Encounters/EncounterGroup01/Enemies/CursedShieldGuard01` and `World/Encounters/EncounterGroup04/Enemies/CursedShieldGuard02` still instance the updated shared `res://scenes/enemies/cursed_shield_guard.tscn` without local script/config/resource overrides.
- The Player instance `World/Player` uses the revised shared `player.tscn` controller and both Player Hitboxes now submit `World/Player` as attacker. Both Shield Guard instances use the revised shared `ShieldComponent` and flash Config, so no Main-local reauthoring is required or stale.
- Group01 remains the isolated first Shield Guard encounter and the encounter roster/count is unchanged.
- `docs/qa/shield_guard_dash_route_soft_flash_f5_main.png` (SHA-256 `82fbadf79d015a556bd5a0515ef72ee3668db0f84b9febe051ff4286ab3e93c3`) is the inspected configured-Main frame. Its Compact row shows Body 5/5, Shield 0/3, front, shield route, Dash id, broken, and GuardBreak while the body remains normally lit.
- `docs/qa/shield_guard_dash_route_soft_flash_f5_main.log` preserves the graphical run output.

### Manual acceptance and known limitations

- Manually repeat the front Dash test from both sides at normal input speed and judge the reduced flash on the target display. Automated geometry, routing, state, and original-resolution rendering are verified; subjective brightness still requires user acceptance.
- The shared Shield Guard scene intentionally has one Hurtbox detector rather than separate physical Shield/Body Areas. Expanded `SH_DETECT/BODY_DETECT` fields describe the final unified route, not two independent damage writers.
- The consumed-key ledger retains the latest 64 attack keys per Shield Guard, which is ample for the encounter and bounded against unbounded growth. Shield reset clears it; shield break does not.

## 2026-07-24 — First-level enemy roster and Fallen Gate Knight Boss (preflight)

Status: in progress — implementation and acceptance evidence pending

### Goal

- Add the airborne `GargoyleSentinel` normal enemy with a readable Dive → GroundStun → Return loop.
- Add the two-phase `FallenGateKnight` Boss with independently routed Body/Shield Health, five distinct attack families, Boss HUD, arena gates, checkpoint/reset flow, and level-complete exit.
- Expand configured F5 Main from four groups/nine enemies to seven groups/eighteen enemies, then place a separate Boss room after the normal-enemy route.
- Preserve all approved Player, Shield Guard, normal-enemy, HUD, damage, death, and respawn behavior.

### Read-only audit

- `project.godot` resolves F5 to `res://scenes/main/main.tscn`; the authored viewport is 1280×720.
- Main currently ends near x=2500, contains one Player spawn, four one-shot EncounterGroups, and nine normal enemies: Castle Guard ×3, Shield Guard ×2, Spearman ×2, Crossbowman ×2. It has no gargoyle, Boss, Boss room gates, pre-Boss checkpoint, Boss HUD, or level exit.
- Existing combat composition is reusable: `EnemyCombatant`, `GroundEnemyBase`, `HealthComponent`, `HitboxComponent`, `HurtboxComponent`, and the corrected `ShieldComponent` already provide typed contracts, faction filtering, stable attack-id deduplication, and single-route Shield/Body damage.
- Castle Guard, Shield Guard, Spearman, Crossbowman, Player Health, and Player 1/2 attack damage match the approved balance. Spearman lacks the requested 0.15-second late-windup direction lock; Crossbowman tracks continuously through Aim and lacks the requested final 0.18-second aim lock.
- `PlayerRespawnController` currently owns one fixed `Marker2D` reference and has no checkpoint setter or Boss-reset handshake.
- `EncounterGroup` supports mixed `EnemyCombatant` children but limits simultaneous attackers to three and its engaged/attacking state lists do not include Gargoyle states.
- Current Main Debug uses typed enemy queries and compact/expanded text reuse. It needs only bounded Gargoyle/Boss fields; no new gameplay authority belongs in Debug UI.

### Planned files and responsibilities

- Gargoyle config/script/scene, generated transparent pixel frames, SpriteFrames, and focused tests: flight state, dive collision/damage, stun counter-window, return, hurt, and shatter death.
- Fallen Gate Knight config/script/scene and art: Boss AI/presentation, shared ShieldComponent routing, phase transition, distinct attack windows, no-ghost death, and resettable instance lifecycle.
- Boss room controller and Boss HUD: encounter locking, checkpoint selection, Player restore, Boss reset on Player respawn, signal-driven bars, gate-open message, and level-complete exit.
- Main/encounters/debug: extend the graybox, author seven staged groups with eighteen normal enemies, add Gargoyle teaching space and a separate Boss arena, then surface concise debug state.
- Existing Spearman/Crossbowman config and scripts: add only the missing direction/aim lock parameters without changing approved cadence or balance.
- Tests, QA capture scripts/evidence, README, combat/roster/encounter/Boss specs, level metrics, and this log.

### Verification plan

1. Generate/import/build all art with exact Godot 4.7.1; validate frame names, transparency, nearest/lossless/no-mipmap imports, anchors, facings, and 48-pixel readability.
2. Run focused component/enemy/Boss/room tests, updated Main integration tests, every independent scene, and the complete serial repository suite.
3. Run configured F5 Main headlessly and graphically; verify seven encounter activations, all five normal types, Boss lock/phase/death/reset/exit, Player attacks/Hurt/death/respawn, HUD bindings, collision/camera, and zero final errors.
4. Retain original-resolution configured-Main screenshots and log output under `docs/qa/`.

### Scope guard

- No flying-enemy variant, elite enemy, second Boss, third Boss phase, summons, experience, loot, inventory, equipment, save system, second level, or unrelated Player/balance redesign.

### Delivered implementation

- Added `GargoyleSentinelConfig`, a composed `GargoyleSentinel` scene, ten named animations, and 41 original 64×64 source frames. The state loop is Dormant/Wake → Track → 0.45-second DiveWindup with final 0.15-second lock → one-hit Dive → World-impact GroundStun 0.65 → ReturnToAir. Health 3, damage 7, 220-pixel detection, 45 hover speed, 300 Dive speed, 70-pixel return height, and 1.10-second cooldown are centralized in one Config.
- Added a resettable `FallenGateKnight` Boss composed from the existing Health/Hitbox/Hurtbox and corrected ShieldComponent rather than a duplicate routing implementation. Body is 18, Shield is 6; Bash/Slash/Heavy/Charge/Shockwave damage is 8/10/15/12/8. All seven attack families use stable ids, bounded active frames, faction filtering, and CharacterBody collision motion.
- Authored 18 Boss animations and 90 original 96×96 source frames. Phase 1 cycles Shield Bash, Sword Slash, and Heavy Overhead. Shield zero has no Body overflow, plays a 0.90-second ShieldBreak plus 1.10-second PhaseTransition, permanently removes defense, and enters faster Phase 2 with Combo Slash, Jump Smash, Charge Thrust, and Shockwave Strike. Death drops the sword, collapses/dissolves, emits completion, and never creates a ghost.
- Added `BossRoomController`: checkpoint `(5480,612)`, entry x=5600, entrance gate x=5630, Boss `(6120,596)`, exit gate x=6480, and exit trigger x=6540. Entry restores Player Health/Stamina, selects checkpoint, locks the arena, activates Boss, and shows HUD. Player respawn fully resets Boss and rearms entry. Boss death opens the exit and displays the bilingual gate message; exit displays level complete without loading another level.
- Added a signal-driven Boss HUD for name, Body 18, and Shield 6. Shield zero hides the Shield bar and reports `BROKEN`; Boss death fades the panel. The HUD never owns combat values.
- Expanded configured Main floor to x=-100..6600 with seven staged normal encounters and eighteen enemies: Guard 8, Shield 2, Spear 2, Crossbow 3, Gargoyle 3. Group sizes are 2/3/2/2/2/3/4; Group05 isolates Gargoyles, Group06/07 combine mechanics, and the Boss arena contains no normals.
- Added only the missing approved direction rules to existing enemies: Spearman locks the final 0.15 seconds of windup and Crossbowman locks the final 0.18 seconds of Aim. All existing Health, damage, attack cadence, Player, Shield Guard, and HUD balance remains unchanged.
- Extended Main Debug type naming and expanded summaries for Gargoyle Dive/stun/target/height and Boss Phase/Body/Shield/state/Hitbox/room/dead fields. Existing compact panel dimensions, F1/F2/F3 behavior, and Debug-off behavior remain unchanged.
- Added independent Gargoyle/Boss test rooms, deterministic pixel/SpriteFrames builders, focused state/combat/room tests, source-asset validation, and configured-Main graphical capture tooling.

### Commands and actual results

1. Engine and baseline:
   - `/Users/vincentz/Downloads/Godot.app/Contents/MacOS/Godot --version`: `4.7.1.stable.official.a13da4feb`.
   - Baseline configured Main `--headless --path . --quit-after 120`: exit 0, no script/resource diagnostics.
2. Asset production:
   - `--script res://scripts/tools/pixel_first_level_boss_generator.gd`: `FIRST_LEVEL_BOSS_PIXEL_BUILD: OK (131 files)`.
   - `--headless --path . --import`: exit 0.
   - `--script res://scripts/tools/first_level_boss_sprite_frames_builder.gd`: `FIRST_LEVEL_BOSS_SPRITE_FRAMES_BUILD: OK`.
   - `validate_first_level_boss_assets.gd`: PASS — 131 transparent frames, Gargoyle 64×64, Boss 96×96, lossless import, no mipmaps.
3. Focused behavior:
   - `test_gargoyle_sentinel.gd`: PASS — wake, 7-damage one-hit Dive, 0.65 GroundStun, return, death fall/shatter, no ghost.
   - `test_first_level_boss.gd`: PASS — Main nodes/coordinates, entry restore/lock/HUD, Shield 6 routing/no overflow, Phase 2, all seven attack-family active windows and 8/10/15/12/8 damage, one-hit memory, death/exit, and full respawn reset.
   - `test_main_enemy_integration.gd`: PASS — seven groups, eighteen mixed enemies, every saved Main PackedScene/resource, activation, Player 1/2 damage, normal-enemy death, Gargoyle shatter, HUD/respawn, and Boss room.
4. Independent scenes:
   - `gargoyle_sentinel.tscn`, `fallen_gate_knight.tscn`, `gargoyle_test_room.tscn`, and `boss_test_room.tscn` each ran headlessly for 120 frames with exit 0 and no final diagnostics.
5. Complete regression:
   - Exact Godot import plus every `.gd` under `tests/` in sorted serial order: `FINAL_TESTS count=31 failures=0`; captured output contained no final `SCRIPT ERROR`, `ERROR:`, or `WARNING:` diagnostics.
   - Existing measured Player envelope remains unchanged: single jump 153.59 px, debug double jump 281.92 px, four-Air-Dash action range 344.00 px.
6. Configured Main runtime:
   - `Godot --headless --path . --quit-after 120 --log-file docs/qa/first_level_main_headless.log`: exit 0, no red errors.
   - Graphical GL Compatibility run on Apple M4 using `capture_first_level_main.gd`: exit 0 and printed `FIRST_LEVEL_MAIN_QA: groups=7 normals=18 boss=BossIntro locked=true hud=true`.
   - `docs/qa/first_level_main_gargoyle.png`: 1280×720, SHA-256 `80ef35cbcdfe721563267ad7e83d3996560d2c2b393e7a408e3b755d85ff5262`.
   - `docs/qa/first_level_main_boss.png`: 1280×720, SHA-256 `c23d4d53469baa5a373bf1905f1fd4dcd8a8bfdebf9b7cf92bb388cb7a84f867`.
   - Both images were inspected at original resolution: Gargoyle silhouettes, Boss/Player scale, arena gate, 18/6 Boss HUD, formal HP/Stamina HUD, and nearest-neighbor pixel edges are visibly present in the actual configured Main.

### F5 Main synchronization

- `application/run/main_scene` remains `res://scenes/main/main.tscn`.
- Normal enemy instances live at `World/Encounters/EncounterGroup01..07/Enemies/*` and all reference shared current PackedScenes. Gargoyles are Group05 at `(3480,270)` / `(3680,270)` and Group07 at `(4960,300)`.
- Boss integration is saved under `World/BossRoom`: `BossCheckpoint`, `EntryTrigger`, `EntranceGate`, `FallenGateKnight`, `ExitGate`, and `ExitTrigger`. `BossRoomController` is the Main sibling coordinator; `HUD/BossHealthHud` and `HUD/LevelCompletePanel` are the live presentation instances.
- Player Camera limits now cover 0..6600; floor/world collision and the right boundary extend through the exit. Formal Health/Stamina bindings, Debug Canvas, Player death ghost, respawn controller, and all existing shared Player resources remain live.

### Manual acceptance and known limitations

- Manual play should judge Group06/07 multi-enemy fairness, Gargoyle windup/ground-stun readability, and each Boss telegraph at normal input speed. Automated tests prove timing, routing, collision interfaces, and saved integration, not subjective difficulty.
- Boss Phase 2 is a deterministic four-attack cycle for gray-box reproducibility. There is no behavior tree, random weighting, third phase, summon, elite, reward, or audio pass.
- Boss reset currently occurs after the existing complete Player death/ghost sequence; normal enemies already defeated before the checkpoint remain removed. This is intentional for the one-checkpoint first-level gray box.
- The level-complete exit displays a terminal overlay and does not load a second level, as scoped.

## 2026-07-24 — First-level platform reachability audit and repair (preflight)

Status: complete — all elevated Main combat surfaces reachable, three spawn-origin route runs and 33-script regression passed; manual feel acceptance pending

### Goal

- Measure the shipping Player scene through its real Input Map and `CharacterBody2D` path, then repair every unreachable standable surface in configured F5 Main.
- Keep Player movement, stamina, combat, enemy balance/AI, Boss behavior, HUD sizing, and animation art unchanged.
- Make all elevated Crossbow positions and the Gargoyle landing/counter window reachable by stable double jump without requiring chained Air Dash.

### Read-only audit

- `project.godot` resolves F5 to `res://scenes/main/main.tscn`; Main directly instances `res://scenes/player/player.tscn` at `World/Player` with no movement, double-jump, action, or stamina overrides.
- First-level collision is authored directly under `Main/World` as one continuous `StaticBody2D` floor plus `PlatformA..D` and `GargoylePerch`; there is no TileMap or nested stale Level PackedScene.
- Shipping tuning is `move_speed 220`, ground/air acceleration `1400/850`, jump velocity `-420`, gravity `1100`, coyote `0.10`, buffer `0.12`, Dash `480 × 0.18`, and Stamina `100/25`. There is no separate double-jump velocity, variable-height release cut, or maximum-fall clamp. Debug double jump is enabled in the shared Player scene and reuses `-420`.
- Exact Godot 4.7.1 baseline measurement at 60 physics ticks/s: single jump `153.59` horizontal / `83.77` rise; apex-timed double jump `281.92` horizontal / `167.10` rise; four paid Air Dash segments `344.00` action-only range. Player collision is 24×52 at local y=2, so root-to-foot is 28 px.
- Platform top-surface audit: Floor y=640; PlatformA y=508 (132 rise, safe); PlatformB y=426 (214 rise, unreachable); PlatformC y=458 (182 rise, unreachable); PlatformD y=438 (202 rise, unreachable); GargoylePerch y=328 (312 rise, unreachable). The three unreachable combat platforms each host a Crossbowman; the perch intercepts Gargoyle dives above the Player's reachable counter window.

### Planned files, tests, and scope check

- Extend the existing deterministic movement-envelope test to cover standing rise, forward jump/double-jump, one-Air-Dash combinations, full-stamina chain, collision-foot displacement, departure/landing margins, and minimum production landing width.
- Add a focused Main traversal regression that reads saved top surfaces, widths, enemy offsets, and route classification from the actual F5 scene.
- Move only the four invalid Main surfaces and their dependent Crossbow/Gargoyle spawn positions; keep Floor, PlatformA, encounter triggers, Camera limits, checkpoint, gates, Boss arena, and all gameplay tuning unchanged.
- Add a small default-off Level Traversal Debug overlay that observes Player/platform state and shares existing F1 visibility without owning collision or gameplay.
- Update `level_metrics.md`, `first_level_encounter_spec.md`, add `level_traversal_spec.md`, update README and this log; retain configured-Main QA evidence under `docs/qa/`.
- Scope remains limited to first-level traversal repair: no new enemy, Boss skill, second level, equipment, combat tuning, or Player ability change.

### Delivered repair

- Kept the configured F5 source at `res://scenes/main/main.tscn` and changed its direct World geometry rather than creating a parallel level. PlatformB/C/D centers moved from y=438/470/450 to 512/516/520, producing top surfaces y=500/504/508. `GargoylePerch` moved from center y=340 to 504, producing top y=492.
- PlatformA and all four moved surfaces now use downward-facing one-way collision. Their visual top remains exactly aligned with collision top; only the lower stone edge gained a restrained broken-stone silhouette. No invisible collider or TileMap layer was introduced.
- Resulting rises from Floor top y=640 are 132/140/136/132/148 px for PlatformA/B/C/D/Perch: 79.0%/83.8%/81.4%/79.0%/88.6% of measured double-jump rise. Every surface is inside the main/challenge 90% ceiling and 190–240 px wide versus the 48 px production landing minimum.
- Moved the Group04/06/07 Crossbowmen from y=396/428/408 to 470/474/478. Each root remains exactly 30 px above its new top and centered with at least 79 px edge clearance.
- Moved Group05 Gargoyles from `(3480,270)/(3680,270)` to `(3500,402)/(3620,402)`. Both remain 90 px above the reachable perch with 44 px horizontal edge safety, so Dive can produce a reachable GroundStun counter window and ReturnToAir can recover to the saved home height.
- Added a default-off read-only `LevelTraversalDebugOverlay` at `Main/Interface/DebugHudRoot/LevelTraversalDebug`. F4 toggles collision-foot Y, jump start/rise/distance, recorded peaks, nearest platform deltas, and reach rating; F1 still hides its parent Debug root. It creates no geometry and owns no gameplay state.
- Added deterministic platform and route suites. The platform test performs real double-jump landings on all five surfaces. The three-route test starts at the saved spawn and never changes Player position: Floor-only/no-Air-Dash Boss approach, mobility Crossbow route including double jump + one Air Dash, and a novice Gargoyle route with the second jump deliberately delayed until downward velocity reaches 50 px/s.

### Actual measurements and route standards

- Standing/forward single jump: 83.77 px rise; forward range 153.59 px.
- Standing/forward double jump: 167.10 px rise; forward range 281.92 px.
- Single jump + one Air Dash: 192.92–196.59 px; double jump + one Air Dash: 321.26–324.92 px. The small interval is the accepted fixed-step boundary depending on which apex tick consumes input.
- Four paid Air Dashes: 344.00 px action-only; 360.33–362.22 px from jump entry to landing. Full-Stamina chains remain shortcut capacity, not a normal-platform requirement.
- Main safe ceiling is 133.68 px (80%); Challenge ceiling is 150.39 px (90%); Hidden/reward ceiling is 158.75 px (95%).

### Commands and actual results

1. Exact Godot 4.7.1 measurement:
   - `Godot --headless --path . --script tests/player/measure_player_level_metrics.gd`: PASS with the values above, Player foot offset 28 px, 98 px center-to-safe-edge departure difference on a 220 px platform, and 48 px minimum safe landing width.
2. Saved Main geometry/physics:
   - `test_main_platform_reachability.gd`: PASS — five surfaces, one-way collision, aligned enemies, and five real double-jump landings.
   - `test_main_traversal_routes.gd --log-file docs/qa/main_traversal_routes.log`: PASS — all three routes from actual spawn, no teleport.
3. Focused regressions:
   - Main enemy integration, Gargoyle Sentinel, first-level Boss, M1 movement, and Main Debug HUD including F4: all PASS.
4. Complete repository regression:
   - All 33 scripts under `tests/` ran serially through exact Godot 4.7.1 and passed. Captured outputs contained no final `SCRIPT ERROR`, `ERROR:`, or `WARNING:` diagnostics.
5. Configured Main runtime:
   - Headless `Godot --headless --path . --quit-after 300 --log-file docs/qa/main_traversal_f5_headless.log`: exit 0, no diagnostics.
   - Graphical `Godot --path . --quit-after 300 --log-file docs/qa/main_traversal_f5_graphical.log`: exit 0, GL Compatibility on Apple M4, no diagnostics.
   - Graphical Main QA capture script: exit 0 and `MAIN_TRAVERSAL_QA: PlatformB top=500 GargoylePerch top=492 PlatformC/D top=504/508`.

### Configured-Main QA evidence

- `docs/qa/main_traversal_crossbow_platform_b.png`: 1280×720, SHA-256 `6ecb6489f985954541bc89c4533dfd857f66ffe91db100896d1cd23365615346`.
- `docs/qa/main_traversal_gargoyle_perch.png`: 1280×720, SHA-256 `d421ba23ecec23ee52fc2a07c740b2d76d141241032c5fe0b725db0bf2583c33`.
- `docs/qa/main_traversal_platforms_c_d.png`: 1280×720, SHA-256 `3e011f2c96f5566a5caaf9a03b925135821785bb3c0d990129db76ba625f4272`.
- Original-resolution inspection confirms Player/collision-foot alignment on PlatformB/Perch, centered Crossbow/Gargoyle positions, readable broken-stone edges, formal HUD, and compact Debug panels in the actual Main composition.

### Manual acceptance and known limitations

- Manually repeat PlatformB/C/D and GargoylePerch from Floor at normal input speed, including approaching from both directions. Automation proves physics reach and timing tolerance; it cannot decide subjective platform rhythm.
- The first-level Floor remains a continuous gray-box mainline. Lowering the combat surfaces makes them accessible but does not convert this milestone into a finished environmental-art or multi-route level-design pass.
- Traversal classification is based on the current measured Player resource. If Player movement is deliberately retuned later, rerun the measurement and update the overlay thresholds/spec together.
- No intermediate platforms were added because direct lowering and one-way collision fully solved the invalid surfaces with the smallest Main diff.

## 2026-07-24 — Solid platform collision and castle-bridge Boss arena redesign (preflight)

Status: complete — solid collision, configured-Main castle bridge flow, 34-script regression and graphical QA passed; manual feel acceptance pending

### Goal

- Replace the first-level elevated one-way surfaces with real solid world collision so the Player lands from above and is stopped by the underside from below during jump, double jump, Air Dash, and Dash Attack traversal.
- Replace the current flat-floor two-rectangle Boss room with a saved F5 Main route of checkpoint → near bank → moat → continuous old wooden bridge → Fallen Gate Knight battle → closed castle gate → animated gate opening → Chapter I completion trigger.
- Keep Player movement/jump/Dash/Stamina/attack tuning, all enemy and Boss health/damage/attack profiles, enemy AI, and HUD sizes unchanged.

### Read-only audit

- `project.godot` resolves F5 to `res://scenes/main/main.tscn`; Git started clean on `master` at `1f4ab5f` and synchronized with `origin/master`.
- Main authors collision directly under `Main/World`. `PlatformA`, `PlatformB`, `PlatformC`, `PlatformD`, and `GargoylePerch` are `StaticBody2D` nodes whose `CollisionShape2D.one_way_collision` is still `true`; this is the direct cause of underside penetration.
- The shipping Player uses a 24×52 rectangular `CharacterBody2D` collider and `move_and_slide()` for normal movement and action movement. No alternate Dash collider or position teleport was found. The body script does not yet explicitly clear upward velocity after a ceiling collision.
- The current `World/BossRoom` is drawn over the same continuous Floor: checkpoint x=5480, entry trigger x=5600, a narrow `EntranceGate` x=5630, Boss x=6120, narrow `ExitGate` x=6480, and exit trigger x=6540. There is no moat, bridge body, water hazard, visible rear battle barrier, castle facade, animated gate, bridge bounds, or Boss-camera lock.
- `BossRoomController` instantly hides/disables gates. Boss death completion already emits only after the death animation finishes, and Player respawn already resets an uncleared Boss while retaining a cleared Boss; these behaviors will be preserved and extended rather than duplicated.
- Existing traversal and Boss tests explicitly assert the obsolete one-way/two-gate design and must be rewritten against the saved Main composition.

### Planned files, tests, and scope check

- Update `scenes/main/main.tscn`, `scripts/player/player.gd`, `scripts/bosses/fallen_gate_knight.gd`, and `scripts/bosses/boss_room_controller.gd`; add small composed gate and moat controllers rather than embedding the complete sequence in Player or Boss code.
- Rewrite the platform collision tests for underside blocking plus top landing, retain spawn-origin route tests with edge approaches suitable for solid platforms, and extend Boss integration tests for checkpoint, visible rear barrier, bridge bounds, moat death, delayed gate collision release, reset, and completion.
- Add/update the requested traversal, Boss room, encounter, collision-layer, and level-metrics documentation and capture three configured-Main QA frames: underside collision, bridge battle, and opened castle gate.
- Scope excludes new enemies, new Boss attacks/phases, second level, rewards, combat tuning, Player ability changes, and unrelated visual/UI redesign.

### Delivered implementation

- Removed `one_way_collision` from `Main/World/PlatformA`, `PlatformB`, `PlatformC`, `PlatformD`, and `GargoylePerch`. All retain their saved 190–240×24 visual/collision dimensions and now block from top, bottom and sides. Floor, walls, bridge, castle floor/facade, rear barrier and closed gate are also full World bodies.
- Kept the shipping Player 24×52 rectangle at local y=2 for Standing, Hurt, Dash, Dash Attack, Death and Respawn. All action movement still reaches `move_and_slide()`; no action changes `global_position`. A focused post-slide ceiling resolver now guarantees `velocity.y >= 0` on `is_on_ceiling()` and returns unlocked locomotion to Fall without restoring jumps, Stamina or land state.
- Replaced the saved `World/BossRoom/EntranceGate/ExitGate` composition. Main now owns `World/CastleEntranceArea`: checkpoint `(5480,612)`, Floor bank edge x=5520, a marked 40-pixel ordinary-jump moat opening, dark-water hazard x=5520..6360, continuous 800×20 WoodenBridge x=5560..6360, castle floor x=6360..6624, and solid castle facade/80-pixel doorway.
- Moved encounter entry to `(5780,430)` (27.5% into the bridge) and saved a visible chain/curse `RearBattleBarrier` at x=5420 behind the checkpoint. Entry restores HP/Stamina, closes that barrier, retains the visible closed castle gate, activates Boss/HUD and sets Camera limits x=5340..6620. Death or Boss clear releases the limits.
- Kept Fallen Gate Knight at `(6120,596)` with unchanged Body 18, Shield 6, phases, damage and attacks. Main enables logical x bounds 5650..6320; approach, charge and knockback cannot carry it off the bridge, while no boundary collider blocks Player motion.
- Added `CastleGateController`: the visible 48×260 gate remains on World during a 1.00-second vertical lift, plays a quiet runtime-synthesized chain/stone placeholder, and disables collision/enables `CastleEntranceTrigger` only after animation completion. Crossing `(6428,510)` then shows `CHAPTER I COMPLETE / 第一章完成`; no second scene loads.
- Added `MoatHazard`: one trigger per Player life invokes the existing Health → Dead → five-frame body collapse → dagger drop → ghost rise → 0.50-second pause → checkpoint respawn flow. An uncleared encounter resets Boss Body/Shield/phase/position, rear barrier, gate, HUD and Camera. A cleared Boss remains dead and the gate remains open after later Player death. Non-Boss enemies receive one lethal component hit; the bounded Boss is ignored.
- Rewrote the saved-Main traversal contracts for solid geometry. Platform tests now prove single/double-jump underside blocking, non-negative ceiling velocity, Air Dash/Dash Attack side blocking and top landings. Spawn-origin routes approach elevated edges and use a normal jump over the 40-pixel bridge-entry gap. The new castle-flow suite verifies solid bridge underside, live-encounter moat death, complete ghost/respawn, Boss reset and post-clear persistence.
- Added/updated the requested README, traversal, Boss room, encounter, collision-layer and metrics specifications. Original-resolution configured-Main QA capture is reproducible through `scripts/tools/capture_castle_bridge_qa.gd`.

### Commands and actual results

1. Exact engine/import:
   - `/Users/vincentz/Downloads/Godot.app/Contents/MacOS/Godot --version`: `4.7.1.stable.official.a13da4feb` (confirmed during preflight).
   - `Godot --headless --path . --import --quit-after 120`: exit 0; new global classes and Main scene loaded without resource/script diagnostics.
2. Focused saved-Main collision and flow:
   - `tests/level/test_main_platform_reachability.gd`: PASS — five solid platforms, single/double-jump underside blocking, Air Dash/Dash Attack side blocking, top landings and enemy alignment.
   - `tests/level/test_main_traversal_routes.gd`: PASS — spawn-origin mainline with ordinary bridge-entry jump, solid edge approaches to Crossbow surfaces, and delayed Gargoyle route; no post-spawn teleport.
   - `tests/combat/test_first_level_boss.gd`: PASS — saved castle composition, 800×20 bridge, 5650..6320 Boss bounds, unchanged combat profiles, visible rear lock, Camera lock/release, gate collision timing/audio, reset and Chapter I trigger.
   - `tests/level/test_castle_bridge_flow.gd`: PASS — bridge underside, actual physics fall into moat, full death/ghost/respawn, uncleared Boss reset and cleared-Boss persistence.
3. Regression:
   - Exact Godot serial execution of every `.gd` under `tests/`: `FINAL_TESTS count=34 failures=0`. The runner treated nonzero exit, `SCRIPT ERROR`, `ERROR:` and explicit failure summaries as failures; none were present.
   - Existing `boss_test_room.tscn` and `combat_test_room.tscn` each ran independently for 180 headless frames with exit 0, confirming the Main-specific bridge bounds/controller did not break reusable Boss/enemy scenes.
4. Configured F5 Main:
   - `Godot --headless --path . --quit-after 600 --log-file docs/qa/castle_bridge_f5_headless.log`: exit 0, no Script Error/Error/Warning lines.
   - `Godot --path . --quit-after 300 --log-file docs/qa/castle_bridge_f5_graphical.log`: exit 0, GL Compatibility on Apple M4, no Script Error/Error/Warning lines.
   - Graphical configured-Main capture: exit 0 and `CASTLE_BRIDGE_QA: ceiling=true rear_open=true gate_open=true boss_bounds=(5650.0, 6320.0)`.

### Configured-Main QA evidence

- `docs/qa/solid_platform_ceiling_collision.png`: 1280×720, 24,276 bytes, SHA-256 `76f4eff3bd6cac80573ea781937e2383ce311f81bde802e5f72f0bec77def905`.
- `docs/qa/castle_bridge_boss_fight.png`: 1280×720, 29,103 bytes, SHA-256 `8ba583dc57fed814f78facdb51df963e3e2ea7f040d1b13c55ba75dde9d0400a`.
- `docs/qa/castle_gate_open.png`: 1280×720, 29,829 bytes, SHA-256 `4f9e0fba44416a5a91f84ca4a5e1b3f80283558b3307cdca6813f2168e7b3718`.
- Original-resolution inspection confirms Player/PlatformA underside contact, visible rear barrier + closed castle gate + both combatants on the continuous timber bridge, and the raised-gate/open-doorway state with the bilingual message. Computer-use Remote Scene Tree control was unavailable; saved-tree paths were instead instantiated and asserted through exact-Godot Main tests, then rendered graphically from the same configured PackedScene.

### Manual acceptance and known limitations

- Manually judge the 40-pixel near-bank jump readability, bridge combat spacing, Camera framing during every Boss attack, synthesized gate placeholder loudness and the perceived timing between Boss collapse and the 1.00-second gate lift. Automation proves collision/state/timing contracts, not subjective feel.
- The bridge is intentionally continuous across its 800-pixel combat span. The moat is naturally reachable at the marked bank-to-bridge opening and through forced test placement; no hidden gap was inserted into the combat floor.
- Environmental art remains gray-box native Godot polygons. The dark water, old timber, chain posts, barrier and castle facade establish readable function but are not a final tile/art/audio pass.
- No Player tuning, enemy/Boss balance, enemy AI, HUD dimensions, new enemy, Boss skill, equipment or second-level content was changed.

## 2026-07-24 — Fallen Gate Knight turn response and Shield durability (preflight)

Status: complete — configured-Main implementation, 34-script regression and graphical QA passed; manual feel acceptance pending

### Goal

- Raise only the first Boss Shield from 6 to 10 while retaining Body 18, all Boss damage/skills/movement, and Player Normal/Dash Attack damage 1/2.
- Replace the current delayed instantaneous mirror with a readable two-stage turn: 0.07-second reaction plus 0.10-second authored turn animation, followed by a 0.12-second anti-jitter cooldown.
- Keep contact-time front/back Shield routing, no break-hit overflow, reset behavior, signal-driven Boss HUD, and the configured F5 Main instance synchronized.

### Read-only audit

- `project.godot` resolves F5 to `res://scenes/main/main.tscn`. The live Boss is `Main/World/CastleEntranceArea/FallenGateKnight`, instanced from `res://scenes/bosses/fallen_gate_knight.tscn`; the live HUD is `Main/HUD/BossHealthHud`.
- `res://resources/bosses/fallen_gate_knight_config.tres` currently owns Body 18, Shield 6, and one `turn_duration = 0.18`. Main overrides only bridge bounds; it has no Shield or turn Inspector override.
- Turning currently updates only in `ApproachShielded` / `ApproachUnshielded`. The first detection tick initializes 0.18 seconds without consuming that tick, so a 60 Hz free-Approach turn completes in about 0.20 seconds and then instantly changes both `AnimatedSprite2D.flip_h` and `FacingRoot.scale.x`. Attacks, Hurt, ShieldBreak, PhaseTransition, GuardRecovery, ordinary Recovery and Death do not update turning; the perceived delay can therefore stack the remaining locked attack plus 0.48-second Recovery before the 0.20-second turn.
- There is no center-side threshold in Boss turning, no post-turn cooldown, no Turn state, and no turn animation. The shared `ShieldComponent` does classify source side at contact and consumes one attack id before routing, so existing rear/front routing and no-overflow break behavior can be retained.
- `BossHealthHud` listens to `HealthComponent.health_changed` and `ShieldComponent.shield_health_changed`; it does not own combat data. Its saved scene defaults still show 6/6, but binding replaces them with the component's real values.

### Planned files, tests, and scope check

- Update the centralized Boss config, Boss state/presentation script, Boss scene/SpriteFrames and deterministic original pixel generators; add Shield damage overlays for intact/damaged/critical/broken and authored shielded/unshielded turn frames.
- Extend the saved-Main Boss test for 10-point routing, HUD/reset, 0.16–0.20-second turn completion, reaction cancellation, center hysteresis, cooldown and attack-direction locking. Run all repository tests plus exact Godot 4.7.1 import, headless F5 and graphical F5 checks.
- Update only the requested Boss, room, combat and metric specifications plus this log. No Player tuning, Boss Body/damage/skill/movement, other enemy, bridge/moat/gate geometry or completion-flow change is in scope.

### Delivered implementation

- Replaced the single `turn_duration = 0.18` delayed mirror with centralized `boss_turn_reaction_delay = 0.07`, `boss_turn_animation_duration = 0.10`, `boss_turn_cooldown = 0.12`, and `turn_side_threshold = 12`. Added explicit `TurnShielded` / `TurnUnshielded` states and three-frame 30 FPS original pixel animations.
- Idle, Approach, GuardRecovery and Recovery can request a turn. A rear request cancels if the Player returns to the current front or the 12-pixel center zone before reaction completes. All attacks, Hurt, ShieldBreak, PhaseTransition and Death retain locked facing and interrupt/reject turn requests.
- The visual and `FacingRoot` now commit together only after the turn animation. Commit is deferred until the current contact frame completes, so Shield routing on that frame uses the old facing and the next frame uses the new facing. A 0.12-second cooldown prevents center-line oscillation.
- Raised only `boss_shield_max_health` from 6 to 10. Body remains 18, Player Normal/Dash damage remains 1/2, every Boss damage/movement/skill/cadence value remains unchanged, frontal hits remain Shield-only, rear hits remain Body-only, and the breaking attack still discards overflow and cannot hit Body with the same attack id.
- Added a signal-driven full-canvas pixel `ShieldDamageOverlay`: 10–8 intact, 7–5 damaged, 4–1 critical, and 0 broken. Its offsets follow shielded Idle, ShieldBash and Turn frames; the existing restrained shield-break flash/animation remains unchanged.
- The signal-driven Boss HUD now initializes from and displays 10/10, decrements from real Shield signals, shows `BROKEN` at zero, and returns to 10/10 on reset. Main's saved HUD defaults were synchronized for editor/runtime consistency without moving combat ownership into UI.
- `reset_boss()` now restores Body 18, Shield 10, intact overlay, initial left facing, Phase 1, and clears reaction, animation-commit and cooldown state. Main still overrides only bridge bounds and directly instances the shared latest Boss scene/config.

### Measured timing and balance records

- Previous free-Approach behavior: about 0.20 seconds at 60 Hz from first detection to an instantaneous mirror (0.18 configured plus its initialization/fixed-step boundary). During a locked attack it could additionally wait for the remaining attack and up to the 0.48-second Recovery because Recovery did not process turning.
- New free-Approach and GuardRecovery behavior: 0.1833 seconds measured at 60 Hz from clear rear detection to queued contact-frame commit, inside the 0.16–0.20-second target. Authored nominal duration is 0.17 seconds.
- Full Shield break counts: 10 Normal Attacks, 5 Dash Attacks, or any 1/2-damage mix totaling 10 (for example 4 Dash + 2 Normal). Body remains 18 through five frontal Dash hits; a rear Normal + Dash changes Body 18→15 while Shield stays unchanged.
- Deterministic tests found no center-threshold flip, stale reaction after returning front, cooldown bypass, attack-state turn, same-frame rear-to-front routing error, or break-hit overflow. Subjective Phase 1/Phase 2 average duration and average successful rear hit count require manual multi-run play; they were not fabricated from automation. Shield 15 remains documentation-only as a future hard-mode candidate.

### Commands and actual results

1. Exact asset build/import:
   - `Godot --headless --path . --script scripts/tools/pixel_first_level_boss_generator.gd`: PASS, 141 original Gargoyle/Boss PNG files.
   - `Godot --headless --path . --import --quit-after 120`: final rerun exit 0 without diagnostics.
   - `Godot --headless --path . --script scripts/tools/first_level_boss_sprite_frames_builder.gd`: PASS, current Boss and Shield-overlay SpriteFrames saved.
2. Focused saved-Main checks:
   - `tests/combat/test_first_level_boss.gd`: PASS; printed `BOSS_TURN_TIMING: free=0.1833 recovery=0.1833`, 10-point Shield/HUD/front/rear/no-overflow/reset and every unchanged attack profile.
   - `tests/tools/validate_first_level_boss_assets.gd`: PASS, 141 transparent lossless/no-mipmap frames.
   - `tests/level/test_castle_bridge_flow.gd`: PASS, moat death/ghost/respawn and 10-point Boss reset/persistence.
   - `tests/combat/test_main_enemy_integration.gd`: PASS, seven groups/18 normal enemies/Boss room/HUD/respawn unchanged.
   - The first Debug HUD invocation used obsolete `tests/tools/test_main_debug_hud.gd` and correctly failed as missing; the located real command `tests/ui/test_main_debug_hud.gd` then passed compact/expanded/hidden/F1–F4 behavior. The missing-path attempt is not counted as a project failure or a passed test.
3. Complete regression:
   - Exact Godot serial execution of every `.gd` under `tests/`: `FULL_TESTS count=34 failures=0`; runner rejected nonzero exit plus `SCRIPT ERROR`, `ERROR:`, `WARNING:` and explicit failure summaries.
4. Configured F5 Main runtime:
   - Headless `Godot --headless --path . --quit-after 600 --log-file docs/qa/fallen_gate_knight_f5_headless.log`: exit 0, no Script Error/Error/Warning diagnostics.
   - Graphical `Godot --path . --quit-after 300 --log-file docs/qa/fallen_gate_knight_f5_graphical.log`: exit 0, GL Compatibility on Apple M4, no diagnostics.
   - Graphical configured-Main capture script: exit 0 and `FALLEN_GATE_KNIGHT_QA: ... shield=6/10 visual=damaged state=TurnShielded turn_frame=1` from `Main/World/CastleEntranceArea/FallenGateKnight`.

### Configured-Main QA evidence

- `docs/qa/fallen_gate_knight_shield_10_main.png`: 1280×720, SHA-256 `d53cca07279235c754f724a5ccf6e5be017e59b463d683f2752777eb6bfb3888`; live HUD visibly reads Body 18/18 and Shield 10/10.
- `docs/qa/fallen_gate_knight_shield_damaged_main.png`: 1280×720, SHA-256 `dfbcd6393bc5029d49191335defc98c3771e8d1821d8432f6cccd05462e42b02`; four real frontal Normal hits produce Shield 6/10 and the damaged overlay without Body loss.
- `docs/qa/fallen_gate_knight_turn_main.png`: 1280×720, SHA-256 `778f8bee555bbdcfc7730180b104b500532de34f2348128beef35a474bcd3cde`; configured Main shows `TurnShielded` frame 2 before facing/Hitbox commit.
- Original-resolution inspection confirmed sharp nearest-neighbor art, readable shield/sword/body compression during turn, synchronized HUD values, and no full-screen shield flash.

### Manual acceptance and known limitations

- Manually repeat jump, double-jump and Air Dash cross-ups at normal speed, and judge whether the 0.1833-second response leaves one satisfying Normal hit or the start of one Dash Attack without permitting sustained rear output. Automation proves timing/routing/state locks, not perceived pressure.
- Manually record several complete Phase 1/2 durations and rear-hit counts. They depend on human movement/attack choice and are intentionally marked pending instead of inferred from deterministic damage counts.
- The turn is a compact three-frame 96×96 pixel twist rather than skeletal interpolation. The damage overlay uses three visible durability levels plus the existing broken animation; it does not create ten unique Shield sprites.
- No Player value, Boss Body/damage/movement/skill, normal-enemy behavior, bridge/moat/gate geometry, HUD placement or chapter-completion flow changed.

## 2026-07-24 — Boss pressure, Player attack cadence, moat and Gargoyle presentation

Status: complete — implementation, 34-script regression and configured-Main graphical QA passed; manual feel acceptance pending

### Goal

- Increase Fallen Gate Knight pressure through modestly faster existing attack anticipation/recovery only, while preserving every damage value, Body 18, Shield 10, current skills, phases, bounds and encounter flow.
- Replace the Player's frame-three immediate Attack restart with a short, explicit chain-input window plus a minimum recovery beat; retain the same four-frame 20 FPS dual-dagger thrust, damage, range, Stamina and Dash Attack behavior.
- Lengthen the Boss's authored rear-cross turn from the measured 0.1833 seconds to a nominal 0.23 seconds so a clean jump-behind creates one readable Normal Attack opportunity without allowing sustained rear pressure.
- Make the saved F5 Main moat visibly read as deep blue Gothic water without changing `MoatHazard`, bridge collision or castle-flow logic, and redraw the existing three shared Gargoyle Sentinel instances as stone medieval gargoyles without changing their AI/combat contract.

### Read-only audit

- `project.godot` resolves F5 to `res://scenes/main/main.tscn`. Git began on `master` at `ca6c8e9`, two commits ahead of `origin/master`; the only pre-existing untracked path is `scripts/tools/capture_fallen_gate_knight_turn_shield_qa.gd.uid`.
- The live Boss is `Main/World/CastleEntranceArea/FallenGateKnight`, instanced from `res://scenes/bosses/fallen_gate_knight.tscn`. Central config currently owns Body 18, Shield 10, shared `attack_recovery=0.48`, and turn reaction/animation/cooldown values `0.07/0.10/0.12`; recent deterministic measurement is 0.1833 seconds total at 60 Hz.
- Existing Boss attacks use their authored SpriteFrames timing rather than separate per-attack windup variables. First active-frame delays range from 0.1818 to 0.375 seconds; reducing those animation timings by about 8–10% and shared recovery by 12.5% stays inside the requested limited pressure pass without hiding tells.
- The Player Attack is four frames at 20 FPS. `player_action_controller.gd` currently stores one 0.10-second repeat-J input and immediately calls `restart_locked_one_shot()` as soon as frame index 2 (`attack_03`) is reached, so repeated input can skip the last recovery frame and has no minimum gap.
- Main's moat nodes are `Main/World/CastleEntranceArea/Moat/WaterVisual`, `WaterReflection` and unchanged `MoatHazard`; the first two use only one near-black blue rectangle and a five-pixel surface strip. The continuous bridge is the separate `Main/World/CastleEntranceArea/WoodenBridge` body.
- All three saved Main Gargoyles (`EncounterGroup05/.../GargoyleSentinel01`, `...02`, and `EncounterGroup07/.../GargoyleSentinel03`) instance the same `res://scenes/enemies/gargoyle_sentinel.tscn`, SpriteFrames and 64×64 PNG tree. Their state loop and combat parameters are already functional; the current thin line wings and rectangular torso are the presentation defect.

### Planned files, tests, and scope check

- Update centralized Boss/Player action Resources and typed controllers, Boss SpriteFrames timing, Main moat presentation nodes, the deterministic Gargoyle generator, shared Gargoyle PNG/SpriteFrames resources, and focused tests for timing/chain contracts.
- Archive the replaced Gargoyle presentation under its `reference/deprecated_v1` tree while keeping runtime validation limited to production animation folders. Preserve all three Main instance paths and the existing enemy count.
- Run exact Godot 4.7.1 generation/import/build, focused Player/Boss/Gargoyle/Main tests, all repository tests, configured headless and graphical F5 Main, and capture configured-Main Boss bridge, moat and new-Gargoyle QA images under `docs/qa/`.
- Update README plus Boss, combat, Gargoyle and Boss-room specifications. Scope excludes new attacks/phases/enemies, Player or Boss damage/HP/Stamina changes, Dash Attack redesign, MoatHazard/collision changes, encounter-count changes, second-level content and rewards.

### Delivered implementation

- Increased pressure only through existing timing. Shield Bash/Sword Slash are 9.0→9.8 FPS, Heavy Overhead/Shockwave 8.0→8.8, both Combo steps 11.0→12.0, Jump Smash 9.0→9.8 and Charge Thrust 10.0→11.0. Their first active-frame delays are about 8–10% shorter while every authored anticipation and active frame remains. Shared post-attack Recovery is 0.48→0.42 seconds. Body 18, Shield 10, all damage values, movement, bounds, phases and skill selection are unchanged.
- Lengthened the authored Boss cross-up response from 0.07+0.10 seconds to 0.10+0.13 seconds. The three-frame turn now plays at 23.076923 FPS; deterministic 60 Hz measurement is 0.2333 seconds versus the previous 0.1833 seconds. The 12-pixel threshold, 0.12-second cooldown, reaction cancellation, attack direction locks and contact-frame routing remain intact.
- Replaced immediate frame-three Player Attack restart. The first J still starts the same four-frame 20 FPS thrust immediately and reaches `attack_02` in about 0.05 seconds. Only a J edge during 0.15–0.20 seconds can fill one shortened 0.06-second buffer. The current attack always reaches `attack_04`, then holds an exclusive 0.06-second `AttackRecovery` before a valid repeat receives a fresh attack id. Early/out-of-window spam cannot restart frame one; Dash Attack, damage 1/2, range, Stamina and cancellation rules are unchanged.
- Saved nine presentation-only nodes under `Main/World/CastleEntranceArea/Moat`: blue/teal base and depth bands, surface highlight, two cold ripple/reflection layers, bridge shadow and two stone banks. The first capture exposed negative-Z concealment behind the root Backdrop; the final saved Z order renders water above Backdrop and below/around bridge art. `MoatHazard`, its shape/masks/death behavior, `WoodenBridge/BridgeCollision`, route geometry and castle flow were not changed.
- Rebuilt all 41 production Gargoyle frames across `dormant`, `wake`, `hover`, `dive_windup`, `dive`, `ground_stun`, `return_to_air`, `hurt`, `death_fall` and `death_shatter`. The new silhouette uses a hunched stone torso, horn/brow/muzzle, broad membrane bat wings, separate claws, tail, gray/verdigris planes and sparse cracks. AI config, Health 3, Dive damage 7 and all state timings remain unchanged.
- Archived the 41 replaced PNGs under `assets/sprites/enemies/gargoyle_sentinel/reference/deprecated_v1/`; `.gdignore` keeps them out of runtime import and production asset counts. All runtime frames remain under the original animation paths and rebuild the existing shared `gargoyle_sentinel_sprite_frames.tres`.

### Configured F5 Main synchronization

- `run/main_scene` remains `res://scenes/main/main.tscn`. Boss path remains `Main/World/CastleEntranceArea/FallenGateKnight`, using `res://scenes/bosses/fallen_gate_knight.tscn`, `fallen_gate_knight_config.tres` and the rebuilt Boss SpriteFrames timing.
- Gargoyle paths remain `Main/World/Encounters/EncounterGroup05/Enemies/GargoyleSentinel01`, `.../GargoyleSentinel02`, and `Main/World/Encounters/EncounterGroup07/Enemies/GargoyleSentinel03`. Main integration asserts all three use `res://scenes/enemies/gargoyle_sentinel.tscn` plus the same latest `res://resources/enemies/gargoyle_sentinel_sprite_frames.tres`; enemy count remains 18 and no legacy runtime copy exists.
- Moat presentation path is `Main/World/CastleEntranceArea/Moat`; hazard authority remains `Main/World/CastleEntranceArea/Moat/MoatHazard`, and the solid bridge remains `Main/World/CastleEntranceArea/WoodenBridge`.

### Commands and actual results

1. Original assets and resources:
   - Exact 4.7.1 `--script scripts/tools/pixel_first_level_boss_generator.gd`: PASS, 141 production Gargoyle/Boss PNGs generated.
   - Exact 4.7.1 `--import --quit-after 120`: exit 0 without Script Error/Error/Warning diagnostics.
   - Exact 4.7.1 `--script scripts/tools/first_level_boss_sprite_frames_builder.gd`: PASS.
2. Focused contracts:
   - `tests/player/test_fast_attack.gd`: PASS — immediate 0.05-second effective pose, strict final input window, one buffer, complete frame four and 0.06-second recovery across four deliberate repeats.
   - `tests/player/test_dash_attack.gd`: PASS — unchanged Ground/Air Dash Attack behavior.
   - `tests/combat/test_first_level_boss.gd`: PASS and `BOSS_TURN_TIMING: free=0.2333 recovery=0.2333 target=0.22..0.26`; timings, damage, Shield, bridge, moat presentation nodes and room flow passed.
   - `tests/combat/test_gargoyle_sentinel.gd`, `test_main_enemy_integration.gd`, and `validate_first_level_boss_assets.gd`: PASS — unchanged AI/damage/death, all three shared Main instances and 141 transparent lossless/no-mipmap production frames.
3. Complete regression:
   - Serial exact-Godot execution of all test scripts: final `FULL_TESTS count=34 failures=0`. One earlier full run observed the existing death-flow total-duration assertion cross its approximately-one-frame lower bound; the isolated rerun passed and the final complete rerun passed 34/34. No death/respawn implementation or assertion was changed.
4. Configured Main runtime:
   - Exact Godot headless F5 target for 600 frames: exit 0, no Script Error/Error/Warning.
   - Exact Godot graphical F5 target for 300 frames: exit 0, GL Compatibility on Apple M4, no Script Error/Error/Warning.
   - Configured-Main graphical capture script: exit 0 and saved all three required frames from the same Main PackedScene.

### Configured-Main QA evidence

- `docs/qa/fallen_gate_knight_pressure_main.png`: 1280×720, 16,456 bytes, SHA-256 `f773ed8f955957d1af0d6f92c1ed34af74016650f3e6c57e07ddf41864d1bd1c`.
- `docs/qa/gothic_moat_main.png`: 1280×720, 9,603 bytes, SHA-256 `7265ca337a1746d255f60e81b69d1c57ebda10c14791282bc0a705e8a8cdb8b1`.
- `docs/qa/gargoyle_stone_redesign_main.png`: 1280×720, 10,049 bytes, SHA-256 `95bbcc2ae229da073161f99757d5d04fd692a39b2f49874736f03eae31612189`.
- Original-resolution inspection confirms visible deep-teal water and surface bands below the bridge, sharp nearest-neighbor horned stone Gargoyles in Main Group05, and the unchanged Boss/HUD/bridge composition.

### Manual acceptance and known limitations

- Manually judge whether the 8–10% shorter Boss tells plus 0.42-second Recovery feel more pressuring without becoming visually unfair, and whether the 0.2333-second cross-up consistently grants one satisfying normal hit but not sustained rear output.
- Manually compare deliberate J rhythm against random high-frequency spam. Automation proves no active-frame restart and a mandatory 0.06-second gap; subjective cadence still requires play feel approval.
- Gargoyle art is a procedural 64×64 gray-box production pass, not final hand-polished pixel art. In particular, inspect the side-view Dive at motion speed and confirm the swept wing/tail reads as a stone predator rather than a projectile or insect.
- Water is layered native Polygon2D gray-box art with static ripples; it has no shader, particles or downloaded texture. This intentionally avoids changing hazard/collision logic.
- No Player/Boss damage or Health/Stamina value, Boss skill/phase, Gargoyle AI, enemy count/type, encounter activation, Moat death, gate completion, second level, reward or equipment system was added or changed.
