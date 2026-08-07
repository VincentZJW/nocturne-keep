extends SceneTree

## CH4-F4 final formal-route gate. This test deliberately exercises the saved
## MainBootstrap rooms instead of isolated enemy fixtures: five full forward /
## reverse passes, every authored Encounter, both checkpoints, movement wake-up
## and repeated death/clear/reload lifecycle.

const BOOTSTRAP: String = "res://scenes/bootstrap/main_bootstrap.tscn"
const LEVEL: String = "res://chapters/chapter_04_drowned_underkeep/scenes/level/drowned_underkeep.tscn"
const ROUTE_PASSES: int = 5
const COMBAT_INDICES: Array[int] = [1, 2, 3, 4, 5, 7, 8, 9, 10, 11]
const CHECKPOINT_INDICES: Array[int] = [6, 12]
const EXPECTED_ROLES: Array[StringName] = [
	&"drowned_gaoler",
	&"chainbound_convict",
	&"mire_harpooner",
	&"sunken_shield_penitent",
	&"mirefin_raider",
	&"bog_toad",
	&"sewer_maw",
	&"underkeep_executioner",
]

var _failures: PackedStringArray = []
var _room_loads: Dictionary[StringName, int] = {}
var _encounter_activations: Dictionary[StringName, int] = {}
var _role_instances: Dictionary[StringName, int] = {}
var _role_deaths: Dictionary[StringName, int] = {}
var _checkpoint_respawns: Dictionary[StringName, int] = {}
var _movement_checks: int = 0
var _enemy_instances: int = 0
var _cistern_mirefin_crossings: int = 0
var _cistern_mirefin_attacks: int = 0
var _natural_cistern_second_group_hits: int = 0


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var debug: DebugRunConfigState = root.get_node_or_null("DebugRunConfig") as DebugRunConfigState
	_check(debug != null, "DebugRunConfig missing")
	if debug == null:
		await _finish()
		return
	debug.debug_chapter_start_enabled = true
	debug.debug_start_chapter_id = ChapterRegistry.CHAPTER_04_DROWNED_UNDERKEEP
	debug.debug_start_spawn_id = &"CH4_START"
	debug.debug_skip_chapter_intro = true
	_check(change_scene_to_file(BOOTSTRAP) == OK, "MainBootstrap launch failed")
	var level: Node = await _wait_for_level()
	_check(level != null, "MainBootstrap did not resolve Chapter IV")
	if level == null:
		debug.reset_to_defaults()
		await _finish()
		return
	var controller: Chapter04RoomTransitionController = level.get_node_or_null("RoomTransitionController") as Chapter04RoomTransitionController
	var player: Player = level.get_node_or_null("ChapterRuntime/Player") as Player
	var hud: CanvasLayer = level.get_node_or_null("ChapterRuntime/HUD") as CanvasLayer
	var room_host: Node2D = level.get_node_or_null("RoomHost") as Node2D
	_check(controller != null and player != null and hud != null and room_host != null, "persistent Main runtime contract is incomplete")
	if controller == null or player == null or hud == null or room_host == null:
		debug.reset_to_defaults()
		await _finish(level)
		return
	var player_id: int = player.get_instance_id()
	var hud_id: int = hud.get_instance_id()
	await _exercise_natural_cistern_route(controller, player)
	player.set_physics_process(false)
	player.hurtbox.set_invulnerable(true)
	for pass_index: int in range(ROUTE_PASSES):
		for room_index: int in range(17):
			await _load_and_exercise(controller, player, hud, room_host, player_id, hud_id, room_index, &"EntryWest", pass_index)
		for room_index: int in range(15, -1, -1):
			await _load_and_exercise(controller, player, hud, room_host, player_id, hud_id, room_index, &"EntryEast", pass_index)
	_validate_totals()
	debug.reset_to_defaults()
	await _finish(level)


func _exercise_natural_cistern_route(
	controller: Chapter04RoomTransitionController,
	player: Player
) -> void:
	_check(controller._swap_room(&"CH4_AREA_05", &"EntryWest"), "natural Cistern route could not load")
	await process_frame
	await physics_frame
	var room: Chapter04Room = controller.active_room as Chapter04Room
	var spawner: Chapter04EncounterSpawner = room.get_node_or_null("EncounterSpawner") as Chapter04EncounterSpawner if room != null else null
	_check(room != null and spawner != null, "natural Cistern route lacks formal room/EncounterSpawner")
	if room == null or spawner == null:
		return
	var groups: Array[EncounterGroup] = spawner.get_encounter_groups()
	_check(groups.size() == 2, "natural Cistern route expected two Encounter groups")
	if groups.size() != 2:
		return
	player.set_physics_process(true)
	player.hurtbox.set_invulnerable(true)
	var crossed_original_blocker: bool = false
	var reached_second_activation: bool = false
	for combatant: EnemyCombatant in groups[1].get_enemies():
		var enemy: Chapter04Enemy = combatant as Chapter04Enemy
		if enemy != null:
			enemy.health_component.health_changed.connect(
				func(_current: int, _maximum: int) -> void:
					_natural_cistern_second_group_hits += 1
			)
	for frame_index: int in range(2400):
		var target: Chapter04Enemy = _nearest_awake_enemy(groups, player)
		var direction: float = 1.0
		var distance: float = INF
		if target != null:
			distance = absf(target.global_position.x - player.global_position.x)
			direction = signf(target.global_position.x - player.global_position.x)
			if is_zero_approx(direction):
				direction = 1.0
		# Keep pressing toward a target even when body collision has closed the
		# remaining gap. Besides proving collision-safe approach, this updates the
		# Player's facing before the real attack input is consumed.
		_set_player_move(direction if target == null or distance > 28.0 else 0.0)
		if target != null and distance <= 68.0 and frame_index % 14 == 0:
			Input.action_press(&"attack")
		if target != null and absf(target.global_position.y - player.global_position.y) > 35.0 and frame_index % 55 == 0:
			Input.action_press(&"player_jump")
		await physics_frame
		Input.action_release(&"attack")
		Input.action_release(&"player_jump")
		crossed_original_blocker = crossed_original_blocker or player.global_position.x > 950.0
		reached_second_activation = reached_second_activation or groups[1].is_activated
		if groups[0].is_cleared and groups[1].is_cleared:
			break
	_release_player_input()
	print("CH4 NATURAL CISTERN COMBAT | x=%.1f first_clear=%s second_active=%s second_clear=%s second_hits=%d" % [
		player.global_position.x,
		groups[0].is_cleared,
		groups[1].is_activated,
		groups[1].is_cleared,
		_natural_cistern_second_group_hits,
	])
	_check(groups[0].is_cleared, "natural Input actions did not clear Cistern Encounter 01")
	_check(crossed_original_blocker, "Player remained blocked before the Cistern second ActivationArea")
	_check(reached_second_activation, "natural traversal never activated Cistern Encounter 02")
	_check(_natural_cistern_second_group_hits > 0, "real Player attack never damaged a Cistern Encounter 02 enemy")
	_check(groups[1].is_cleared, "natural Input actions did not clear Cistern Encounter 02")
	var gate: Chapter04EncounterGate = room.get_node_or_null("Transitions/CisternExitGate") as Chapter04EncounterGate
	var exit: Chapter04RoomExit = room.get_node_or_null("Transitions/ExitEast") as Chapter04RoomExit
	await process_frame
	await physics_frame
	_check(gate != null and not gate.is_locked(), "Cistern exit gate remained locked after natural clear")
	_check(exit != null and not exit.is_locked(), "Cistern ExitEast remained locked after natural clear")
	if exit != null:
		for _frame_index: int in range(300):
			if exit.is_player_in_range():
				break
			_set_player_move(1.0)
			await physics_frame
		_release_player_input()
		_check(exit.is_player_in_range(), "Player could not naturally reach Cistern ExitEast")
		var interact_press: InputEventAction = InputEventAction.new()
		interact_press.action = &"interact"
		interact_press.pressed = true
		Input.parse_input_event(interact_press)
		await process_frame
		var interact_release: InputEventAction = InputEventAction.new()
		interact_release.action = &"interact"
		interact_release.pressed = false
		Input.parse_input_event(interact_release)
		for _frame_index: int in range(360):
			if controller.active_room_id == &"CH4_AREA_06":
				break
			await process_frame
		_check(controller.active_room_id == &"CH4_AREA_06", "natural Cistern interaction did not enter CH4_AREA_06")
		if controller.active_room_id == &"CH4_AREA_06":
			print("CH4 NATURAL CISTERN EXIT | PASS CH4_AREA_05 -> CH4_AREA_06 via interact")


func _nearest_awake_enemy(groups: Array[EncounterGroup], player: Player) -> Chapter04Enemy:
	var nearest: Chapter04Enemy = null
	var nearest_distance: float = INF
	for group: EncounterGroup in groups:
		if not group.is_activated:
			continue
		for combatant: EnemyCombatant in group.get_enemies():
			var enemy: Chapter04Enemy = combatant as Chapter04Enemy
			if enemy == null or enemy.is_dead():
				continue
			var distance: float = player.global_position.distance_to(enemy.global_position)
			if distance < nearest_distance:
				nearest = enemy
				nearest_distance = distance
	return nearest


func _set_player_move(direction: float) -> void:
	Input.action_release(&"player_move_left")
	Input.action_release(&"player_move_right")
	if direction < 0.0:
		Input.action_press(&"player_move_left")
	elif direction > 0.0:
		Input.action_press(&"player_move_right")


func _release_player_input() -> void:
	for action: StringName in [&"player_move_left", &"player_move_right", &"player_jump", &"attack"]:
		Input.action_release(action)


func _load_and_exercise(
	controller: Chapter04RoomTransitionController,
	player: Player,
	hud: CanvasLayer,
	room_host: Node2D,
	player_id: int,
	hud_id: int,
	room_index: int,
	spawn_id: StringName,
	pass_index: int
) -> void:
	var room_id: StringName = StringName("CH4_AREA_%02d" % room_index)
	var outgoing: WeakRef = weakref(controller.active_room)
	_check(controller._swap_room(room_id, spawn_id), "pass %d could not load %s" % [pass_index + 1, room_id])
	await process_frame
	await physics_frame
	var room: Chapter04Room = controller.active_room as Chapter04Room
	_check(room != null, "%s has no active formal room" % room_id)
	if room == null:
		return
	_room_loads[room_id] = _room_loads.get(room_id, 0) + 1
	_check(room_host.get_child_count() == 1, "%s left multiple room instances" % room_id)
	_check(outgoing.get_ref() == null, "%s did not release its outgoing room" % room_id)
	_check(player.get_instance_id() == player_id, "%s replaced persistent Player" % room_id)
	_check(hud.get_instance_id() == hud_id, "%s replaced persistent HUD" % room_id)
	_check(player.player_camera.limit_right == room.room_size.x, "%s Camera bounds mismatch" % room_id)
	_validate_platform_collision_contract(room, room_id)
	var marker: Marker2D = room.get_spawn(spawn_id)
	_check(marker != null and player.global_position == marker.global_position, "%s Player spawn mismatch" % room_id)
	if room_index in CHECKPOINT_INDICES:
		await _exercise_checkpoint(controller, player, room, room_id)
	var spawner: Chapter04EncounterSpawner = room.get_node_or_null("EncounterSpawner") as Chapter04EncounterSpawner
	if room_index in COMBAT_INDICES:
		_check(spawner != null and spawner.manifest != null, "%s lacks formal Encounter data" % room_id)
		if spawner != null:
			await _exercise_encounters(player, spawner, room_id)
	else:
		_check(spawner == null, "%s support room unexpectedly owns ordinary encounters" % room_id)


func _validate_platform_collision_contract(room: Chapter04Room, room_id: StringName) -> void:
	for platform: Node in room.find_children("PlatformCollision_*", "StaticBody2D", true, false):
		var shape_node: CollisionShape2D = platform.get_node_or_null("CollisionShape2D") as CollisionShape2D
		_check(shape_node != null, "%s %s lacks CollisionShape2D" % [room_id, platform.name])
		if shape_node == null:
			continue
		_check(
			shape_node.one_way_collision,
			"%s %s is a two-way side wall that blocks natural Encounter traversal" % [room_id, platform.name]
		)


func _exercise_checkpoint(
	controller: Chapter04RoomTransitionController,
	player: Player,
	room: Chapter04Room,
	room_id: StringName
) -> void:
	if int(_checkpoint_respawns.get(room_id, 0)) >= ROUTE_PASSES:
		return
	var checkpoint: Chapter04Checkpoint = room.get_node_or_null("Gameplay/Checkpoint") as Chapter04Checkpoint
	_check(checkpoint != null, "%s checkpoint node missing" % room_id)
	if checkpoint == null:
		return
	var marker: Marker2D = checkpoint.get_node_or_null("SpawnMarker") as Marker2D
	checkpoint._on_body_entered(player)
	await process_frame
	_check(marker != null and controller.respawn_anchor.global_position == marker.global_position, "%s did not register respawn anchor" % room_id)
	# The existing Boss-route and Broken-Chainway stress gates own the asynchronous
	# death-sequence/reload assertion. F4 repeatedly verifies that each formal
	# Main room registers the correct persistent respawn anchor; starting another
	# death coroutine here would race the following room swap.
	_checkpoint_respawns[room_id] = _checkpoint_respawns.get(room_id, 0) + 1


func _exercise_encounters(
	player: Player,
	spawner: Chapter04EncounterSpawner,
	room_id: StringName
) -> void:
	var groups: Array[EncounterGroup] = spawner.get_encounter_groups()
	_check(groups.size() == 2, "%s expected two formal Encounter groups" % room_id)
	# S5 owns real ActivationArea overlap coverage across all 32 animated room
	# transitions. This repeated reload gate disables queued overlap callbacks and
	# invokes the same public activation contract deterministically, preventing a
	# Player position from auto-waking the next group while the current one clears.
	for candidate: EncounterGroup in groups:
		candidate.activation_area.set_deferred("monitoring", false)
	await physics_frame
	var ordered_groups: Array[EncounterGroup] = []
	for candidate: EncounterGroup in groups:
		if candidate.is_activated:
			ordered_groups.push_front(candidate)
		else:
			ordered_groups.append(candidate)
	for group: EncounterGroup in ordered_groups:
		_check(not group.is_cleared, "%s %s was already cleared on load" % [room_id, group.encounter_name])
		player.global_position = Vector2(0.0, -10_000.0)
		player.velocity = Vector2.ZERO
		if not group.is_activated:
			_check(group.activate(player), "%s %s rejected deterministic activation" % [room_id, group.encounter_name])
		await process_frame
		_check(group.is_activated, "%s %s activation state was not retained" % [room_id, group.encounter_name])
		_check(spawner.get_active_encounter_id() == group.encounter_name, "%s activated the wrong Encounter" % room_id)
		var encounter_key: StringName = StringName("%s/%s" % [room_id, group.encounter_name])
		_encounter_activations[encounter_key] = _encounter_activations.get(encounter_key, 0) + 1
		for combatant: EnemyCombatant in group.get_enemies():
			var enemy: Chapter04Enemy = combatant as Chapter04Enemy
			_check(enemy != null, "%s %s owns a non-Chapter04Enemy" % [room_id, group.encounter_name])
			if enemy == null:
				continue
			_check(enemy.process_mode == Node.PROCESS_MODE_INHERIT and enemy.is_ai_active(), "%s %s enemy remained dormant" % [room_id, enemy.name])
			var role: StringName = StringName(enemy.scene_file_path.get_file().get_basename())
			_role_instances[role] = _role_instances.get(role, 0) + 1
			_enemy_instances += 1
			if (
				room_id == &"CH4_AREA_05"
				and enemy.name == &"CH4_AREA_05_MIREFIN_RAIDER_01"
				and _cistern_mirefin_crossings < ROUTE_PASSES
			):
				await _exercise_cistern_mirefin_crossing(player, enemy, room_id)
			await _exercise_movement(player, enemy, room_id)
			if int(_role_deaths.get(role, 0)) < 10:
				enemy.health_component.take_damage(enemy.health_component.max_health)
				_check(enemy.is_dead() and not enemy.hurtbox.is_enabled, "%s %s death contract failed" % [room_id, enemy.name])
				_role_deaths[role] = _role_deaths.get(role, 0) + 1
			if is_instance_valid(enemy):
				enemy.queue_free()
		player.global_position = Vector2(0.0, -10_000.0)
		await process_frame
		group._check_cleared()
		await process_frame
		_check(group.is_cleared, "%s %s did not clear" % [room_id, group.encounter_name])
		_check(spawner.get_active_encounter_id().is_empty(), "%s retained a cleared active Encounter" % room_id)


func _exercise_movement(player: Player, enemy: Chapter04Enemy, room_id: StringName) -> void:
	enemy.set_physics_process(false)
	var direction: float = _find_advancing_direction(enemy)
	_check(not is_zero_approx(direction), "%s %s cannot advance on authored floor" % [room_id, enemy.name])
	if is_zero_approx(direction):
		return
	var data: Chapter04EnemyConfig = enemy.config as Chapter04EnemyConfig
	var longest_action_range: float = maxf(
		enemy.config.attack_range,
		maxf(data.secondary_range, data.special_range)
	)
	var movement_distance: float = minf(enemy.get_detection_range() - 8.0, longest_action_range + 64.0)
	player.global_position = enemy.global_position + Vector2(direction * movement_distance, 0.0)
	enemy.velocity = Vector2.ZERO
	enemy.set_target(player)
	enemy.set_facing_direction(direction)
	enemy.transition_state(Chapter04Enemy.APPROACH)
	enemy._process_approach(0.1)
	_check(enemy.velocity.x * direction > 0.0, "%s %s produced no chase velocity" % [room_id, enemy.name])
	_movement_checks += 1


func _exercise_cistern_mirefin_crossing(
	player: Player,
	enemy: Chapter04Enemy,
	room_id: StringName
) -> void:
	var attacks_before: int = _cistern_mirefin_attacks
	var callback: Callable = func(active: bool) -> void:
		if active:
			_cistern_mirefin_attacks += 1
	enemy.attack_window_changed.connect(callback)
	player.global_position = Vector2(604.0, 592.0)
	player.velocity = Vector2.ZERO
	enemy.velocity = Vector2.ZERO
	enemy.set_target(player)
	enemy.set_facing_direction(-1.0)
	enemy.transition_state(Chapter04Enemy.APPROACH)
	enemy.set_physics_process(true)
	for frame_index: int in range(360):
		await physics_frame
		if enemy.global_position.x < 688.0 and _cistern_mirefin_attacks > attacks_before:
			break
	_check(enemy.global_position.x < 688.0, "%s Mirefin remained blocked by PlatformCollision_00 at x=%.2f" % [room_id, enemy.global_position.x])
	_check(_cistern_mirefin_attacks > attacks_before, "%s Mirefin crossed the step but never opened an attack window" % room_id)
	if enemy.attack_window_changed.is_connected(callback):
		enemy.attack_window_changed.disconnect(callback)
	_cistern_mirefin_crossings += 1


func _find_advancing_direction(enemy: Chapter04Enemy) -> float:
	for direction: float in [1.0, -1.0]:
		if enemy.can_advance(direction):
			return direction
	return 0.0


func _validate_totals() -> void:
	_check(_room_loads.size() == 17, "formal route reached %d/17 rooms" % _room_loads.size())
	for room_index: int in range(17):
		var room_id: StringName = StringName("CH4_AREA_%02d" % room_index)
		_check(int(_room_loads.get(room_id, 0)) >= ROUTE_PASSES, "%s loaded fewer than %d times" % [room_id, ROUTE_PASSES])
	_check(_encounter_activations.size() == 20, "formal route reached %d/20 Encounters" % _encounter_activations.size())
	for encounter_key: StringName in _encounter_activations:
		_check(int(_encounter_activations[encounter_key]) >= ROUTE_PASSES * 2, "%s activated fewer than 10 times" % encounter_key)
	_check(_enemy_instances == 460, "expected 460 formal enemy instances, got %d" % _enemy_instances)
	for role: StringName in EXPECTED_ROLES:
		_check(int(_role_instances.get(role, 0)) >= 20, "%s formal instance coverage too low" % role)
		_check(int(_role_deaths.get(role, 0)) == 10, "%s expected 10 deaths" % role)
	for room_id: StringName in [&"CH4_AREA_06", &"CH4_AREA_12"]:
		_check(int(_checkpoint_respawns.get(room_id, 0)) == ROUTE_PASSES, "%s expected five checkpoint respawns" % room_id)
	_check(_cistern_mirefin_crossings == ROUTE_PASSES, "Cistern Mirefin crossing ran %d/5 times" % _cistern_mirefin_crossings)
	_check(_cistern_mirefin_attacks >= ROUTE_PASSES, "Cistern Mirefin opened only %d/5 attack windows" % _cistern_mirefin_attacks)


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
	if _failures.is_empty():
		print("CH4 F4 MAIN REGRESSION | PASS route_passes=%d room_loads=%d rooms=%d encounter_activations=%d encounters=%d enemy_instances=%d movement=%d deaths=%d checkpoint_respawns=%d roles=%d" % [
			ROUTE_PASSES, _room_loads.values().reduce(func(total: int, value: int) -> int: return total + value, 0), _room_loads.size(), _encounter_activations.values().reduce(func(total: int, value: int) -> int: return total + value, 0), _encounter_activations.size(), _enemy_instances, _movement_checks, _role_deaths.values().reduce(func(total: int, value: int) -> int: return total + value, 0), _checkpoint_respawns.values().reduce(func(total: int, value: int) -> int: return total + value, 0), _role_instances.size(),
		])
	else:
		for failure: String in _failures:
			push_error("CH4 F4 MAIN REGRESSION: %s" % failure)
	if level != null:
		unload_current_scene()
		for _frame: int in 12:
			await process_frame
		for _frame: int in 4:
			await physics_frame
		await create_timer(0.5, true, false, true).timeout
	quit(0 if _failures.is_empty() else 1)
