extends SceneTree

const ROOM_PATH: String = "res://chapters/chapter_04_drowned_underkeep/scenes/rooms/ch4_01_flooded_intake.tscn"

var _failures: PackedStringArray = []


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var first_positions: Array[Vector2] = await _exercise_room_once(true)
	var second_positions: Array[Vector2] = await _exercise_room_once(false)
	_check(first_positions == second_positions, "saved spawn positions changed after room reload")
	if _failures.is_empty():
		print("CH4 S4 RUNTIME | PASS groups=2 serialized=true rearms=true reload_deterministic=true")
		quit(0)
		return
	for failure: String in _failures:
		push_error("CH4 S4 RUNTIME: %s" % failure)
	quit(1)


func _exercise_room_once(exercise_clear: bool) -> Array[Vector2]:
	var packed: PackedScene = load(ROOM_PATH) as PackedScene
	var room: Chapter04Room = packed.instantiate() as Chapter04Room if packed != null else null
	_check(room != null, "formal room failed to instantiate")
	if room == null:
		return []
	root.add_child(room)
	await process_frame
	await process_frame
	var spawner: Chapter04EncounterSpawner = room.get_node_or_null("EncounterSpawner") as Chapter04EncounterSpawner
	_check(spawner != null, "formal room lacks runtime EncounterSpawner")
	if spawner == null:
		room.queue_free()
		await process_frame
		return []
	var groups: Array[EncounterGroup] = spawner.get_encounter_groups()
	_check(groups.size() == 2, "runtime must build two EncounterGroups")
	var positions: Array[Vector2] = []
	for group: EncounterGroup in groups:
		_check(group.get_enemies().size() == 2, "area 01 groups must each own two enemies")
		for enemy: EnemyCombatant in group.get_enemies():
			positions.append(enemy.position)
			_check(enemy.process_mode == Node.PROCESS_MODE_DISABLED, "dormant enemy should not process before activation")
	if exercise_clear and groups.size() == 2:
		_check(groups[0].activate(), "first group should activate exactly once")
		await process_frame
		await physics_frame
		_check(groups[0].is_activated, "first group activation state missing")
		_check(not groups[0].activate(), "active group must reject restart")
		_check(not groups[1].activation_area.monitoring, "second group must stay disarmed while first group is active")
		for enemy: EnemyCombatant in groups[0].get_enemies():
			enemy.queue_free()
		await process_frame
		groups[0].call("_check_cleared")
		await process_frame
		await physics_frame
		_check(groups[0].is_cleared, "cleared group state missing")
		_check(groups[1].activation_area.monitoring, "remaining group must rearm after clear")
	room.queue_free()
	await process_frame
	return positions


func _check(condition: bool, message: String) -> void:
	if not condition:
		_failures.append(message)
