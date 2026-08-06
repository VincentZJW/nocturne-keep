extends SceneTree

const BOOTSTRAP: String = "res://scenes/bootstrap/main_bootstrap.tscn"
const LEVEL: String = "res://chapters/chapter_04_drowned_underkeep/scenes/level/drowned_underkeep.tscn"
const MAX_TRANSITION_USEC: int = 1_000_000
const MAX_POST_FADE_RESOURCE_WAIT_USEC: int = 400_000

var _failures: PackedStringArray = []
var _transition_count: int = 0
var _peak_transition_usec: int = 0
var _peak_wait_usec: int = 0
var _peak_instantiation_usec: int = 0
var _encounter_activation_checks: int = 0
var _movement_state_checks: int = 0
var _action_state_checks: int = 0
var _shallow_water_checks: int = 0
var _checked_enemy_types: Dictionary = {}


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var debug: DebugRunConfigState = root.get_node_or_null("DebugRunConfig") as DebugRunConfigState
	if debug == null:
		_failures.append("DebugRunConfig missing")
		await _finish()
		return
	debug.debug_chapter_start_enabled = true
	debug.debug_start_chapter_id = ChapterRegistry.CHAPTER_04_DROWNED_UNDERKEEP
	debug.debug_start_spawn_id = &"CH4_START"
	debug.debug_skip_chapter_intro = true
	if change_scene_to_file(BOOTSTRAP) != OK:
		_failures.append("MainBootstrap launch failed")
		await _finish()
		return
	var level: Node = await _wait_for_level()
	if level == null:
		_failures.append("formal Chapter IV level did not load")
		await _finish()
		return
	var controller: Chapter04RoomTransitionController = level.get_node_or_null("RoomTransitionController") as Chapter04RoomTransitionController
	var player: Player = level.get_node_or_null("ChapterRuntime/Player") as Player
	var hud: CanvasLayer = level.get_node_or_null("ChapterRuntime/HUD") as CanvasLayer
	var room_host: Node2D = level.get_node_or_null("RoomHost") as Node2D
	if controller == null or player == null or hud == null or room_host == null:
		_failures.append("persistent Main runtime contract is incomplete")
		await _finish()
		return
	var player_id: int = player.get_instance_id()
	var hud_id: int = hud.get_instance_id()
	if player.hurtbox != null:
		player.hurtbox.set_invulnerable(true)
	for room_index: int in range(1, 17):
		await _transition_and_check(controller, player, hud, room_host, player_id, hud_id, room_index, &"EntryWest")
	for room_index: int in range(15, -1, -1):
		await _transition_and_check(controller, player, hud, room_host, player_id, hud_id, room_index, &"EntryEast")
	_check(_transition_count == 32, "expected 32 forward/backward transitions")
	debug.reset_to_defaults()
	await _finish(level)


func _transition_and_check(
		controller: Chapter04RoomTransitionController,
		player: Player,
		hud: CanvasLayer,
		room_host: Node2D,
		player_id: int,
		hud_id: int,
		room_index: int,
		spawn_id: StringName
) -> void:
	var destination: StringName = StringName("CH4_AREA_%02d" % room_index)
	var outgoing: WeakRef = weakref(controller.active_room)
	_check(controller.request_room_change(destination, spawn_id), "request rejected for %s" % destination)
	for _frame: int in 180:
		await process_frame
		if not controller.is_transitioning() and controller.active_room_id == destination:
			break
	_check(not controller.is_transitioning(), "%s transition exceeded frame timeout" % destination)
	await process_frame
	await process_frame
	var metrics: Dictionary = controller.get_transition_metrics()
	var transition_usec: int = int(metrics.get("transition_usec", 0))
	var wait_usec: int = int(metrics.get("resource_wait_usec", 0))
	var instantiate_usec: int = int(metrics.get("instantiation_usec", 0))
	_peak_transition_usec = maxi(_peak_transition_usec, transition_usec)
	_peak_wait_usec = maxi(_peak_wait_usec, wait_usec)
	_peak_instantiation_usec = maxi(_peak_instantiation_usec, instantiate_usec)
	_check(transition_usec > 0 and transition_usec < MAX_TRANSITION_USEC, "%s transition duration out of contract: %dus" % [destination, transition_usec])
	_check(wait_usec < MAX_POST_FADE_RESOURCE_WAIT_USEC, "%s resource wait exceeded budget: %dus" % [destination, wait_usec])
	_check(room_host.get_child_count() == 1, "%s left more than one room instance" % destination)
	_check(outgoing.get_ref() == null, "%s outgoing room was not released" % destination)
	_check(player.get_instance_id() == player_id, "%s replaced persistent Player" % destination)
	_check(hud.get_instance_id() == hud_id, "%s replaced persistent HUD" % destination)
	_check(player.player_camera.limit_right == controller.active_room.get("room_size").x, "%s Camera bounds mismatch" % destination)
	var expected_spawn: Marker2D = controller.active_room.call("get_spawn", spawn_id) as Marker2D
	_check(expected_spawn != null and player.global_position == expected_spawn.global_position, "%s Player spawn mismatch" % destination)
	var spawner: Chapter04EncounterSpawner = controller.active_room.get_node_or_null("EncounterSpawner") as Chapter04EncounterSpawner
	if spawner != null:
		var groups: Array[EncounterGroup] = spawner.get_encounter_groups()
		for group: EncounterGroup in groups:
			_check(not group.is_activated, "%s %s encounter activated beneath transition fade" % [destination, group.encounter_name])
		if not groups.is_empty():
			await _exercise_formal_encounters(player, spawner, groups, destination)
	_transition_count += 1


func _exercise_formal_encounters(
	player: Player,
	spawner: Chapter04EncounterSpawner,
	groups: Array[EncounterGroup],
	destination: StringName
) -> void:
	for expected: EncounterGroup in groups:
		var activation_shape: CollisionShape2D = expected.activation_area.get_node_or_null("CollisionShape2D") as CollisionShape2D
		_check(activation_shape != null, "%s %s lacks activation shape" % [destination, expected.encounter_name])
		if activation_shape == null:
			continue
		player.global_position = activation_shape.global_position
		player.velocity = Vector2.ZERO
		for _frame: int in 3:
			await physics_frame
		_check(expected.is_activated, "%s %s did not activate from real Player overlap" % [destination, expected.encounter_name])
		_check(spawner.get_active_encounter_id() == expected.encounter_name, "%s registered an incorrect active encounter" % destination)
		var active_count: int = 0
		for group: EncounterGroup in groups:
			if group.is_activated and not group.is_cleared:
				active_count += 1
		_check(active_count == 1, "%s activated %d uncleared encounter groups" % [destination, active_count])
		for combatant: EnemyCombatant in expected.get_enemies():
			_check(combatant.process_mode == Node.PROCESS_MODE_INHERIT, "%s active enemy process remained suspended" % destination)
			_check(combatant.is_ai_active(), "%s active enemy AI remained dormant" % destination)
			var enemy: Chapter04Enemy = combatant as Chapter04Enemy
			_check(enemy != null, "%s formal encounter owns a non-Chapter04Enemy" % destination)
			if enemy != null:
				await _exercise_enemy_motion_and_state(player, enemy, destination)
		_encounter_activation_checks += 1
		for enemy: EnemyCombatant in expected.get_enemies():
			enemy.queue_free()
		await process_frame
		expected.call("_check_cleared")
		await process_frame
		for _frame: int in 2:
			await physics_frame
		_check(expected.is_cleared, "%s %s did not clear after its enemies were removed" % [destination, expected.encounter_name])


func _exercise_enemy_motion_and_state(player: Player, enemy: Chapter04Enemy, destination: StringName) -> void:
	var data: Chapter04EnemyConfig = enemy.config as Chapter04EnemyConfig
	_check(data != null, "%s enemy lacks Chapter04EnemyConfig" % destination)
	if data == null:
		return
	_checked_enemy_types[String(enemy.get_enemy_type_name())] = true
	if StringName(enemy.get_meta(&"spawn_role", &"")) == &"shallow_water":
		_shallow_water_checks += 1
	if data.starts_hidden:
		enemy.set_target(player)
		if enemy.current_state != Chapter04Enemy.HIDDEN:
			enemy._process_enemy_state(0.0)
		enemy._process_hidden(data.hidden_duration + 0.01)
		_check(
			enemy.current_state == Chapter04Enemy.ALERT,
			"%s hidden enemy did not emerge into Alert (state=%s target=%s timer=%.3f)"
			% [destination, enemy.current_state, enemy.has_valid_target(), enemy.state_timer]
		)
	var direction: float = _find_advancing_direction(enemy)
	_check(not is_zero_approx(direction), "%s %s cannot advance on its formal floor" % [destination, enemy.name])
	if is_zero_approx(direction):
		return
	var movement_distance: float = minf(enemy.get_detection_range() - 8.0, enemy.config.attack_range + 64.0)
	player.global_position = enemy.global_position + Vector2(direction * movement_distance, 0.0)
	player.velocity = Vector2.ZERO
	enemy.set_target(player)
	enemy.set_facing_direction(direction)
	enemy.transition_state(Chapter04Enemy.APPROACH)
	enemy._process_approach(0.1)
	_check(enemy.velocity.x * direction > 0.0, "%s %s did not produce chase velocity" % [destination, enemy.name])
	_check(enemy.current_state == Chapter04Enemy.APPROACH, "%s %s left Approach before moving" % [destination, enemy.name])
	_movement_state_checks += 1

	player.global_position = enemy.global_position + Vector2(direction * maxf(8.0, enemy.config.attack_range * 0.5), 0.0)
	player.velocity = Vector2.ZERO
	enemy.velocity = Vector2.ZERO
	enemy.set_target(player)
	enemy.set_facing_direction(direction)
	enemy.transition_state(Chapter04Enemy.APPROACH)
	enemy._process_approach(0.016)
	_check(enemy.attack_phase == &"Windup", "%s %s did not enter attack Windup" % [destination, enemy.name])
	if enemy.attack_phase != &"Windup":
		return
	enemy._process_action(enemy.action_timer + 0.01)
	_check(enemy.attack_phase == &"Active", "%s %s did not enter attack Active" % [destination, enemy.name])
	enemy._process_action(enemy.action_timer + 0.01)
	_check(enemy.attack_phase == &"Recovery", "%s %s did not enter attack Recovery" % [destination, enemy.name])
	enemy._process_action(enemy.action_timer + 0.01)
	_check(enemy.attack_phase == &"None", "%s %s did not exit attack state" % [destination, enemy.name])
	_check(enemy.current_state == Chapter04Enemy.APPROACH, "%s %s did not recover to Approach" % [destination, enemy.name])
	_action_state_checks += 1
	for projectile: Node in get_nodes_in_group(&"chapter_04_enemy_projectile"):
		projectile.queue_free()


func _find_advancing_direction(enemy: Chapter04Enemy) -> float:
	for direction: float in [1.0, -1.0]:
		if enemy.can_advance(direction):
			return direction
	return 0.0


func _wait_for_level() -> Node:
	for _frame: int in 480:
		await process_frame
		if current_scene != null and current_scene.scene_file_path == LEVEL:
			return current_scene
	return null


func _check(condition: bool, message: String) -> void:
	if not condition:
		_failures.append(message)


func _finish(level: Node = null) -> void:
	_check(_checked_enemy_types.size() == 8, "formal Main state coverage reached %d/8 enemy types" % _checked_enemy_types.size())
	if _failures.is_empty():
		print("CH4 S5 TRANSITIONS | PASS transitions=%d encounter_activations=%d movement_states=%d action_states=%d shallow_water=%d roles=%d peak_total_us=%d peak_wait_us=%d peak_instantiate_us=%d room_instances=1" % [
			_transition_count, _encounter_activation_checks, _movement_state_checks, _action_state_checks, _shallow_water_checks, _checked_enemy_types.size(), _peak_transition_usec, _peak_wait_usec, _peak_instantiation_usec,
		])
	else:
		for failure: String in _failures:
			push_error("CH4 S5 TRANSITIONS: %s" % failure)
	if level != null:
		unload_current_scene()
		for _frame: int in 12:
			await process_frame
		for _frame: int in 4:
			await physics_frame
		# Give Godot's threaded ResourceLoader one real-time cleanup window before
		# ending this short-lived headless process. The running game naturally has
		# this lifetime; the test otherwise exits in only a few milliseconds.
		await create_timer(0.5, true, false, true).timeout
	quit(0 if _failures.is_empty() else 1)
