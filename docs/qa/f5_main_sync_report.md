# F5 Main Scene Synchronization Audit

Date: 2026-07-23
Engine: `4.7.1.stable.official.a13da4feb`
Audited commit baseline: `04c8769 fix: defer hurtbox physics state changes`

## Authoritative entry point

`project.godot` sets:

```text
run/main_scene="res://chapters/chapter_01_ravenmourn_outskirts/scenes/level/ravenmourn_outskirts.tscn"
```

No filename inference or editor-current-scene assumption was used for this result.

## Saved Main composition

- `Main/World/Player` — instance of `res://scenes/player/player.tscn`.
- `Main/World/SpawnPoint` — single current respawn `Marker2D` at `(320, 612)`.
- `Main/PlayerRespawnController` — bound to the saved Player, SpawnPoint, and Player DeathSequence.
- `Main/HUD/HealthContainer` — signal-bound to `Main/World/Player/HealthComponent`.
- `Main/HUD/StaminaContainer` — driven by `Main/World/Player/StaminaComponent`.
- `Main/World/Encounters/EncounterGroup01/Enemies/CursedGuard01` — `(500, 610)`.
- `Main/World/Encounters/EncounterGroup02/Enemies/CursedGuard02` — `(1030, 610)`.
- `Main/World/Encounters/EncounterGroup03/Enemies/CursedGuard03` — `(1500, 610)`.
- `Main/World/Encounters/EncounterGroup04/Enemies/CursedGuard04A` — `(2070, 610)`.
- `Main/World/Encounters/EncounterGroup04/Enemies/CursedGuard04B` — `(2310, 610)`.

All five Guards instance `res://chapters/chapter_01_ravenmourn_outskirts/scenes/enemies/castle_guard.tscn`; no Main instance overrides the Guard script, SpriteFrames, configuration, Health, or sword damage.

## Latest runtime resources verified in Main

- Player PackedScene: `res://scenes/player/player.tscn`
- Player SpriteFrames: `res://resources/player/player_sprite_frames.tres`
- Player movement config: `res://resources/player/player_movement_config.tres`
- Player action config: `res://resources/player/player_action_prototype_config.tres`
- Player Hurt config: `res://resources/player/player_hurt_config.tres`
- Guard PackedScene: `res://chapters/chapter_01_ravenmourn_outskirts/scenes/enemies/castle_guard.tscn`
- Guard SpriteFrames: `res://chapters/chapter_01_ravenmourn_outskirts/resources/enemies/castle_guard_sprite_frames.tres`
- Guard config: `res://chapters/chapter_01_ravenmourn_outskirts/resources/enemies/castle_guard_config.tres`
- Guard sword damage from current config: `5`

## Main runtime acceptance

The strengthened `tests/combat/test_main_enemy_integration.gd` instantiates the configured F5 Main and verifies:

- four saved one-shot activation groups with authored sizes `1/1/1/2` and five floor-safe spawns;
- current Player/Guard PackedScene, SpriteFrames, action/Hurt/Guard configuration resource paths;
- live Health and Stamina HUD signal bindings and value changes;
- action/enemy debug overlays can be disabled without disabling gameplay;
- first encounter activates while later groups remain paused until Player entry;
- all later groups activate on Player entry and retain their one-shot state;
- Guard AI delivers one five-point sword hit after its windup;
- Player enters Hurt, records the source/damage, rejects a second hit during 0.50-second invulnerability, and returns to Alive;
- Main Player normal Attack opens its real Hitbox and deals `1` to a Main Guard;
- Main Player Dash Attack opens its separate real Hitbox and deals `2` to the same Guard;
- the defeated Guard enters Death, disables combat areas, completes grounded dissolve, and leaves the SceneTree;
- Player Camera2D is active and follows the Main Player instance.

Main-backed `test_player_respawn.gd` additionally verifies the full body fall, hooded ghost sequence, 0.50-second ghost pause, SpawnPoint return, Health/Stamina restoration, HUD restoration, Camera continuity, input recovery, and repeat-death protection.

## Commands and results

1. Fresh import/parse:
   - `Godot --headless --editor --path . --import --quit`
   - Exit `0`; no parse/resource/error/warning diagnostics.
2. Focused configured-Main integration:
   - `Godot --headless --path . --script tests/combat/test_main_enemy_integration.gd`
   - PASS: `5 Guards, 4 activations, Hurt, 5 damage, Death`, including actual Main Player Attack/Dash Attack damage.
3. Standalone scene startup:
   - configured F5 Main via `Godot --headless --path . --quit-after 180`: exit `0`;
   - `combat_test_room.tscn` via explicit scene path: exit `0`.
4. Focused Player checks:
   - M1 movement: PASS;
   - Hurt reaction: PASS;
   - death presentation: PASS;
   - Main respawn/HUD/input recovery: PASS as part of the full suite.
5. Full repository regression:
   - all `22` scripts under `tests/` passed individually;
   - no `SCRIPT ERROR`, `ERROR:`, `WARNING:`, parse error, missing resource, or blocked PhysicsServer call in preserved logs.
6. Graphical configured-Main run:
   - `Godot --path . --write-movie docs/qa/f5_main_sync_runtime.png --fixed-fps 1 --quit-after 3 --audio-driver Dummy`
   - Exit `0`; GL Compatibility renderer on Apple M4; three 1280×720 frames recorded from the configured Main.

## Visual evidence

- Final inspected frame: `docs/qa/f5_main_sync_runtime00000002.png`
- Graphical run log: `docs/qa/f5_main_sync_graphical.log`
- Main integration log: `docs/qa/f5_main_sync_integration.log`
- Player death presentation log: `docs/qa/f5_main_sync_death_presentation.log`
- Main Player respawn log: `docs/qa/f5_main_sync_respawn.log`
- Import log: `docs/qa/f5_main_sync_import.log`
- Headless configured-Main log: `docs/qa/f5_main_sync_headless.log`
- Standalone combat-room log: `docs/qa/f5_main_sync_combat_room.log`

The inspected frame visibly contains the Main Player, the active first Guard encounter, five live Guard debug rows with five-point damage, fixed Health/Stamina HUD, current Player action state, and four encounter activation rows. Debug overlays default on for laboratory visibility and can be switched off independently; automated runtime checks assert that their processing stops while gameplay nodes remain active.

## Manual feel checks still owned by the user

Automation proves composition, state transitions, damage values, collision-backed Hitboxes, and saved resources. Human acceptance is still required for movement feel, attack readability, knockback strength, camera-shake comfort, multi-enemy fairness, and visual quality at gameplay scale.
