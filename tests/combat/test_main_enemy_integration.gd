extends SceneTree

## Runtime composition, encounter activation, and damage proof for configured F5 Main.

const MAIN_SCENE: PackedScene = preload("res://scenes/main/main.tscn")
const EXPECTED_MAIN_PATH: String = "res://scenes/main/main.tscn"
const EXPECTED_PLAYER_SCENE_PATH: String = "res://scenes/player/player.tscn"
const EXPECTED_GUARD_SCENE_PATH: String = "res://scenes/enemies/castle_guard.tscn"
const EXPECTED_PLAYER_FRAMES_PATH: String = "res://resources/player/player_sprite_frames.tres"
const EXPECTED_GUARD_FRAMES_PATH: String = "res://resources/enemies/castle_guard_sprite_frames.tres"
const EXPECTED_PLAYER_MOVEMENT_CONFIG_PATH: String = "res://resources/player/player_movement_config.tres"
const EXPECTED_PLAYER_ACTION_CONFIG_PATH: String = "res://resources/player/player_action_prototype_config.tres"
const EXPECTED_PLAYER_HURT_CONFIG_PATH: String = "res://resources/player/player_hurt_config.tres"
const EXPECTED_GUARD_CONFIG_PATH: String = "res://resources/enemies/castle_guard_config.tres"
const EXPECTED_GHOST_TEXTURE_PATH: String = "res://assets/sprites/player/assassin/death/ghost_hooded_face.png"
const GROUP_NAMES: Array[StringName] = [
	&"EncounterGroup01", &"EncounterGroup02", &"EncounterGroup03", &"EncounterGroup04",
]
const GROUP_SIZES: Array[int] = [1, 1, 1, 2]
const ACTIVATION_POSITIONS: Array[Vector2] = [
	Vector2(430.0, 612.0),
	Vector2(850.0, 612.0),
	Vector2(1300.0, 612.0),
	Vector2(1840.0, 612.0),
]
const GUARD_SPAWNS: Array[Vector2] = [
	Vector2(500.0, 610.0),
	Vector2(1030.0, 610.0),
	Vector2(1500.0, 610.0),
	Vector2(2070.0, 610.0),
	Vector2(2310.0, 610.0),
]

var _failures: Array[String] = []
var _guard_presentation_finished: bool = false
var _guard_tree_exited: bool = false


func _initialize() -> void:
	call_deferred("_run_tests")


func _run_tests() -> void:
	_expect(
		ProjectSettings.get_setting("application/run/main_scene", "") == EXPECTED_MAIN_PATH,
		"F5 project Main does not resolve to %s" % EXPECTED_MAIN_PATH
	)
	var main: Node2D = MAIN_SCENE.instantiate() as Node2D
	var player: Player = main.get_node_or_null("World/Player") as Player
	var encounters_root: Node2D = main.get_node_or_null("World/Encounters") as Node2D
	_expect(player != null, "Main is missing Player")
	_expect(encounters_root != null, "Main is missing the Encounters container")
	if player == null or encounters_root == null:
		main.queue_free()
		_finish()
		return
	get_root().add_child(main)
	var groups: Array[EncounterGroup] = _collect_groups(encounters_root)
	var guards: Array[CastleGuard] = _collect_guards(groups)
	_expect(groups.size() == 4, "Main does not contain four EncounterGroups")
	_expect(guards.size() == 5, "Main does not contain five Castle Guards")
	if groups.size() != 4 or guards.size() != 5:
		main.queue_free()
		_finish()
		return
	_test_saved_composition(groups, guards)
	await _wait_physics_frames(8)
	_test_runtime_composition(main, player, groups, guards)
	await _test_latest_resource_and_hud_wiring(main, player, guards)
	await _test_main_ai_attack(player, guards[0])
	await _test_encounter_activation(player, groups)
	await _test_guard_damage_and_death(player, guards[4])
	main.queue_free()
	await process_frame
	_finish()


func _test_saved_composition(
	groups: Array[EncounterGroup],
	guards: Array[CastleGuard]
) -> void:
	for index: int in range(groups.size()):
		_expect(groups[index].encounter_name == GROUP_NAMES[index], "EncounterGroup name mismatch")
		_expect(groups[index].get_guards().size() == GROUP_SIZES[index], "EncounterGroup size mismatch")
	for index: int in range(guards.size()):
		_expect(guards[index].position == GUARD_SPAWNS[index], "Castle Guard spawn position mismatch")


func _test_runtime_composition(
	main: Node2D,
	player: Player,
	groups: Array[EncounterGroup],
	guards: Array[CastleGuard]
) -> void:
	_expect(player.player_camera.enabled, "Player Camera2D is not enabled")
	_expect(main.get_viewport().get_camera_2d() == player.player_camera, "Player Camera2D is not active")
	_expect(main.has_node("Interface/EnemyDebugPanel/EnemyDebug"), "Encounter debug display is missing")
	_expect(groups[0].is_activated, "Spawn encounter did not activate after Player entered its area")
	for index: int in range(1, groups.size()):
		_expect(not groups[index].is_activated, "%s activated before Player entered" % groups[index].name)
	for index: int in range(guards.size()):
		var guard: CastleGuard = guards[index]
		_expect(guard.visible and not guard.is_dead(), "%s started hidden or dead" % guard.name)
		_expect(guard.health_component.current_health == 3, "%s did not start at 3 Health" % guard.name)
		_expect(guard.get_attack_damage() == 5, "%s is not configured for five damage" % guard.name)
		_expect(guard.is_ai_active() == (index == 0), "%s activation state is incorrect" % guard.name)
	_expect(guards[0].target == player, "First Guard did not acquire Player at the detection boundary")
	print(
		"MAIN_RUNTIME_AUDIT: groups=%d guards=%d spawns=%s damage=%d first_active=%s later_active=%s" % [
			groups.size(), guards.size(), GUARD_SPAWNS, guards[0].get_attack_damage(),
			groups[0].is_activated, groups[1].is_activated,
		]
	)


func _test_latest_resource_and_hud_wiring(
	main: Node2D,
	player: Player,
	guards: Array[CastleGuard]
) -> void:
	_expect(player.scene_file_path == EXPECTED_PLAYER_SCENE_PATH, "Main Player uses an unexpected PackedScene")
	_expect(
		player.animation_controller.animated_sprite.sprite_frames.resource_path == EXPECTED_PLAYER_FRAMES_PATH,
		"Main Player does not use the latest SpriteFrames resource"
	)
	_expect(
		player.movement_config.resource_path == EXPECTED_PLAYER_MOVEMENT_CONFIG_PATH,
		"Main Player does not use the latest movement configuration"
	)
	_expect(
		player.action_controller.action_config.resource_path == EXPECTED_PLAYER_ACTION_CONFIG_PATH,
		"Main Player does not use the latest action configuration"
	)
	_expect(
		player.hurt_controller.config.resource_path == EXPECTED_PLAYER_HURT_CONFIG_PATH,
		"Main Player does not use the latest Hurt configuration"
	)
	_expect(player.health_component != null and player.stamina_component != null, "Main Player lacks Health or Stamina")
	_expect(player.hurtbox != null and player.hurt_controller != null, "Main Player lacks Hurt composition")
	_expect(player.action_controller.attack_hitbox != null, "Main Player lacks the normal Attack Hitbox")
	_expect(player.action_controller.dash_attack_hitbox != null, "Main Player lacks the Dash Attack Hitbox")
	var death_sequence: PlayerDeathSequence = player.get_node_or_null("DeathSequence") as PlayerDeathSequence
	_expect(death_sequence != null, "Main Player lacks the death/ghost sequence")
	if death_sequence != null:
		_expect(
			death_sequence.ghost_sprite.texture.resource_path == EXPECTED_GHOST_TEXTURE_PATH,
			"Main Player death sequence uses an unexpected ghost texture"
		)
	for guard: CastleGuard in guards:
		_expect(guard.scene_file_path == EXPECTED_GUARD_SCENE_PATH, "%s uses an unexpected PackedScene" % guard.name)
		_expect(guard.config.resource_path == EXPECTED_GUARD_CONFIG_PATH, "%s uses an old Guard config" % guard.name)
		_expect(
			guard.animated_sprite.sprite_frames.resource_path == EXPECTED_GUARD_FRAMES_PATH,
			"%s uses old Guard SpriteFrames" % guard.name
		)
	var health_hud: PlayerHealthHud = main.get_node_or_null("HUD/HealthContainer") as PlayerHealthHud
	var stamina_hud: PlayerStaminaHud = main.get_node_or_null("HUD") as PlayerStaminaHud
	var respawn_controller: PlayerRespawnController = main.get_node_or_null(
		"PlayerRespawnController"
	) as PlayerRespawnController
	_expect(health_hud != null and health_hud.health_component == player.health_component, "Main Health HUD is not bound to Player Health")
	_expect(stamina_hud != null and stamina_hud.stamina_component == player.stamina_component, "Main Stamina HUD is not bound to Player Stamina")
	_expect(
		respawn_controller != null
		and respawn_controller.player == player
		and respawn_controller.spawn_point == main.get_node_or_null("World/SpawnPoint"),
		"Main respawn coordinator is not wired to the saved Player and SpawnPoint"
	)
	player.health_component.take_damage(7)
	player.stamina_component.try_consume_dash()
	await process_frame
	_expect(health_hud.health_bar.value == 93.0, "Main Health HUD did not display live Player Health")
	_expect(stamina_hud.stamina_bar.value == 75.0, "Main Stamina HUD did not display live Player Stamina")
	player.health_component.reset_to_full()
	player.stamina_component.reset_to_full()
	await process_frame
	_expect(health_hud.health_bar.value == 100.0, "Main Health HUD did not restore to full")
	_expect(stamina_hud.stamina_bar.value == 100.0, "Main Stamina HUD did not restore to full")
	var action_debug: PlayerActionDebugOverlay = main.get_node_or_null(
		"Interface/Panel/ActionDebug"
	) as PlayerActionDebugOverlay
	var action_toggle: CheckButton = main.get_node_or_null("Interface/Panel/DebugToggle") as CheckButton
	var enemy_debug: MainEnemyDebugOverlay = main.get_node_or_null(
		"Interface/EnemyDebugPanel/EnemyDebug"
	) as MainEnemyDebugOverlay
	var enemy_toggle: CheckButton = main.get_node_or_null(
		"Interface/EnemyDebugPanel/EnemyDebugToggle"
	) as CheckButton
	_expect(action_debug != null and action_toggle != null, "Main action debug controls are incomplete")
	_expect(enemy_debug != null and enemy_toggle != null, "Main enemy debug controls are incomplete")
	if action_debug != null and action_toggle != null:
		action_toggle.toggled.emit(false)
		_expect(not action_debug.visible and not action_debug.is_processing(), "Action debug cannot be disabled")
		action_toggle.toggled.emit(true)
	if enemy_debug != null and enemy_toggle != null:
		enemy_toggle.toggled.emit(false)
		_expect(not enemy_debug.visible and not enemy_debug.is_processing(), "Enemy debug cannot be disabled")
		enemy_toggle.toggled.emit(true)


func _test_main_ai_attack(player: Player, guard: CastleGuard) -> void:
	var health_before: int = player.health_component.current_health
	for _frame_index: int in range(180):
		if player.health_component.current_health < health_before:
			break
		await physics_frame
	_expect(
		player.health_component.current_health == health_before - 5,
		"First Guard AI did not deliver exactly one five-damage sword hit"
	)
	_expect(player.get_life_state_name() == &"Hurt", "AI sword hit did not enter Player Hurt")
	_expect(player.hurt_controller.get_last_damage() == 5, "Player debug context did not record five damage")
	var invulnerable_health: int = player.health_component.current_health
	var extra_hitbox: HitboxComponent = guard.attack_hitbox
	extra_hitbox.begin_attack(9901, guard.get_attack_damage())
	_expect(not extra_hitbox.try_hit(player.hurtbox), "Invulnerability accepted a second immediate Guard hit")
	_expect(player.health_component.current_health == invulnerable_health, "Immediate second Guard hit changed Health")
	extra_hitbox.end_attack()
	await _wait_physics_frames(34)
	guard.set_ai_active(false)


func _test_encounter_activation(
	player: Player,
	groups: Array[EncounterGroup]
) -> void:
	for group_index: int in range(1, groups.size()):
		player.global_position = ACTIVATION_POSITIONS[group_index]
		await _wait_physics_frames(4)
		_expect(groups[group_index].is_activated, "%s did not activate on Player entry" % groups[group_index].name)
		for guard: CastleGuard in groups[group_index].get_guards():
			_expect(guard.is_ai_active(), "%s Guard AI remained paused after activation" % groups[group_index].name)
			guard.set_ai_active(false)
		_expect(groups[group_index].is_activated, "%s did not retain one-shot activation state" % groups[group_index].name)
	var maximum_group_size: int = 0
	for group: EncounterGroup in groups:
		maximum_group_size = maxi(maximum_group_size, group.get_alive_enemy_count())
	_expect(maximum_group_size <= 2, "A Main encounter exceeds the two-enemy authored cap")


func _test_guard_damage_and_death(player: Player, guard: CastleGuard) -> void:
	guard.presentation_finished.connect(_on_guard_presentation_finished)
	guard.tree_exited.connect(_on_guard_tree_exited)
	guard.set_physics_process(false)
	player.health_component.reset_to_full()
	player.hurt_controller.reset_after_respawn()
	guard.attack_hitbox.global_position = player.hurtbox.global_position
	guard.attack_hitbox.begin_attack(8801, guard.get_attack_damage())
	_expect(guard.attack_hitbox.try_hit(player.hurtbox), "Main Guard sword did not hit Player Hurtbox")
	_expect(player.health_component.current_health == 95, "Main Guard sword did not deal exactly five damage")
	guard.attack_hitbox.end_attack()
	await _wait_physics_frames(20)
	_expect(player.get_life_state_name() == &"Alive", "Main Player did not recover from Hurt")
	player.set_physics_process(false)
	var player_sprite: AnimatedSprite2D = player.animation_controller.animated_sprite
	var normal_started: bool = player.action_controller.try_start_actions(true, false, true, 0.0, false)
	_expect(normal_started, "Main Player normal Attack did not start")
	player_sprite.frame = 1
	player_sprite.frame_changed.emit()
	_expect(player.action_controller.attack_hitbox.is_active, "Main Player normal Attack Hitbox did not open")
	_expect(player.action_controller.attack_hitbox.try_hit(guard.hurtbox), "Main Player normal Attack missed Guard Hurtbox")
	_expect(guard.health_component.current_health == 2, "Main Player normal Attack did not deal one damage")
	player_sprite.frame = 3
	player_sprite.animation_finished.emit()
	var dash_attack_started: bool = player.action_controller.try_start_actions(
		true, true, true, 1.0, false
	)
	_expect(dash_attack_started, "Main Player Dash Attack did not start")
	player_sprite.frame = 2
	player_sprite.frame_changed.emit()
	_expect(player.action_controller.dash_attack_hitbox.is_active, "Main Player Dash Attack Hitbox did not open")
	_expect(player.action_controller.dash_attack_hitbox.try_hit(guard.hurtbox), "Main Player Dash Attack missed Guard Hurtbox")
	_expect(guard.health_component.current_health == 0, "Main Player Dash Attack did not deal two damage")
	_expect(guard.get_state_name() == &"Death", "Lethal damage did not enter Guard Death")
	_expect(not guard.hurtbox.is_enabled and not guard.attack_hitbox.is_active, "Dead Guard retained a combat area")
	player_sprite.frame = 4
	player_sprite.animation_finished.emit()
	guard.set_physics_process(true)
	player.set_physics_process(true)
	await _wait_physics_frames(50)
	_expect(_guard_presentation_finished, "Main Guard Death/dissolve did not complete")
	_expect(_guard_tree_exited, "Completed Main Guard did not leave the SceneTree")
	_expect(not is_instance_valid(guard), "Completed Main Guard node was not freed")


func _collect_groups(root: Node2D) -> Array[EncounterGroup]:
	var groups: Array[EncounterGroup] = []
	for child: Node in root.get_children():
		var group: EncounterGroup = child as EncounterGroup
		if group != null:
			groups.append(group)
	return groups


func _collect_guards(groups: Array[EncounterGroup]) -> Array[CastleGuard]:
	var guards: Array[CastleGuard] = []
	for group: EncounterGroup in groups:
		guards.append_array(group.get_guards())
	return guards


func _wait_physics_frames(count: int) -> void:
	for _frame_index: int in range(count):
		await physics_frame


func _expect(condition: bool, message: String) -> void:
	if not condition:
		_failures.append(message)


func _on_guard_presentation_finished() -> void:
	_guard_presentation_finished = true


func _on_guard_tree_exited() -> void:
	_guard_tree_exited = true


func _finish() -> void:
	if _failures.is_empty():
		print("MAIN_ENEMY_INTEGRATION_TEST: PASS (latest resources/HUD, 5 Guards, 4 activations, 1/2/5 damage, Hurt, Death)")
		quit(0)
		return
	for failure: String in _failures:
		push_error(failure)
	print("MAIN_ENEMY_INTEGRATION_TEST: FAIL (%d issues)" % _failures.size())
	quit(1)
