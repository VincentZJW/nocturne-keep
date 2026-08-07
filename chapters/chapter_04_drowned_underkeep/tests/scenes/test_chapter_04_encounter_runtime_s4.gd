extends SceneTree

const ROOM_PATH: String = "res://chapters/chapter_04_drowned_underkeep/scenes/rooms/ch4_01_flooded_intake.tscn"
const PLAYER_PATH: String = "res://scenes/player/player.tscn"
const FIRST_ENCOUNTER_POSITION: Vector2 = Vector2(500.0, 620.0)
const SECOND_ENCOUNTER_POSITION: Vector2 = Vector2(1200.0, 620.0)

var _failures: PackedStringArray = []


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var first_positions: Array[Vector2] = await _exercise_room_once()
	var second_positions: Array[Vector2] = await _exercise_room_once()
	_check(first_positions == second_positions, "saved spawn positions changed after room reload")
	if _failures.is_empty():
		print("CH4 S4 RUNTIME | PASS groups=2 suspended_safe=true independent_overlap=true concurrent_awake=true reload_deterministic=true")
		quit(0)
		return
	for failure: String in _failures:
		push_error("CH4 S4 RUNTIME: %s" % failure)
	quit(1)


func _exercise_room_once() -> Array[Vector2]:
	var player_packed: PackedScene = load(PLAYER_PATH) as PackedScene
	var player: Player = player_packed.instantiate() as Player if player_packed != null else null
	_check(player != null, "formal Player failed to instantiate")
	if player == null:
		return []
	root.add_child(player)
	player.global_position = SECOND_ENCOUNTER_POSITION
	player.velocity = Vector2.ZERO
	if player.hurtbox != null:
		player.hurtbox.set_invulnerable(true)

	var packed: PackedScene = load(ROOM_PATH) as PackedScene
	var room: Chapter04Room = packed.instantiate() as Chapter04Room if packed != null else null
	_check(room != null, "formal room failed to instantiate")
	if room == null:
		player.queue_free()
		await process_frame
		return []
	room.set_meta(&"chapter_04_activation_suspended", true)
	room.process_mode = Node.PROCESS_MODE_DISABLED
	root.add_child(room)
	await process_frame
	await physics_frame
	var spawner: Chapter04EncounterSpawner = room.get_node_or_null("EncounterSpawner") as Chapter04EncounterSpawner
	_check(spawner != null, "formal room lacks runtime EncounterSpawner")
	if spawner == null:
		room.queue_free()
		player.queue_free()
		await process_frame
		return []
	var groups: Array[EncounterGroup] = spawner.get_encounter_groups()
	_check(groups.size() == 2, "runtime must build two EncounterGroups")
	var positions: Array[Vector2] = []
	for group: EncounterGroup in groups:
		_check(group.get_enemies().size() == 2, "area 01 groups must each own two enemies")
		_check(not group.is_activated, "suspended room activated against Player's stale position")
		_check(not group.activation_area.monitoring, "suspended room left ActivationArea monitoring")
		for enemy: EnemyCombatant in group.get_enemies():
			positions.append(enemy.position)
			_check(enemy.process_mode == Node.PROCESS_MODE_DISABLED, "dormant enemy should not process before activation")
	if groups.size() == 2:
		room.process_mode = Node.PROCESS_MODE_INHERIT
		player.global_position = FIRST_ENCOUNTER_POSITION
		player.velocity = Vector2.ZERO
		await physics_frame
		spawner.set_activation_suspended(false)
		await process_frame
		await _wait_physics_frames(2)
		_check(groups[0].is_activated, "first group activation state missing")
		_check(spawner.get_active_encounter_id() == groups[0].encounter_name, "spawner registered the wrong active group")
		_check(not groups[0].activate(), "active group must reject restart")
		_check(groups[1].activation_area.monitoring, "second group must remain armed while first group is active")
		_check_group_awake(groups[0], "first group")

		# A later authored region has no internal collision gate. Entering it before
		# the first group clears must wake its pre-placed actors instead of exposing
		# visible but invulnerable dormant enemies.
		player.global_position = SECOND_ENCOUNTER_POSITION
		player.velocity = Vector2.ZERO
		await _wait_physics_frames(3)
		_check(groups[1].is_activated, "second overlapping group did not remain activated")
		_check(spawner.get_active_encounter_id() == groups[1].encounter_name, "latest overlapping group was not reported active")
		_check_group_awake(groups[1], "overlapping second group")

		for enemy: EnemyCombatant in groups[0].get_enemies():
			enemy.queue_free()
		await process_frame
		groups[0].call("_check_cleared")
		await process_frame
		await _wait_physics_frames(2)
		_check(groups[0].is_cleared, "cleared group state missing")
		_check(groups[1].is_activated, "second group lost activation when first group cleared")
		_check(spawner.get_active_encounter_id() == groups[1].encounter_name, "active second group was not retained after first clear")
		_check_group_awake(groups[1], "second group")
	room.queue_free()
	player.queue_free()
	await process_frame
	return positions


func _check_group_awake(group: EncounterGroup, label: String) -> void:
	for enemy: EnemyCombatant in group.get_enemies():
		_check(enemy.process_mode == Node.PROCESS_MODE_INHERIT, "%s enemy process did not resume" % label)
		_check(enemy.is_ai_active(), "%s enemy AI did not resume" % label)


func _check_group_dormant(group: EncounterGroup, label: String) -> void:
	for enemy: EnemyCombatant in group.get_enemies():
		_check(enemy.process_mode == Node.PROCESS_MODE_DISABLED, "%s enemy process was not suspended" % label)
		_check(not enemy.is_ai_active(), "%s enemy AI was not suspended" % label)


func _wait_physics_frames(count: int) -> void:
	for _frame: int in count:
		await physics_frame


func _check(condition: bool, message: String) -> void:
	if not condition:
		_failures.append(message)
