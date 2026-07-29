extends SceneTree

const ROOT_PATH: String = "res://chapters/chapter_03_chapel_of_thirteen_echoes"
const LEVEL_PATH: String = ROOT_PATH + "/scenes/level/chapter_03_entry_placeholder.tscn"
const PROFILE_PATH: String = ROOT_PATH + "/resources/chapter/chapter_03_start_profile.tres"
const SPAWN_POSITIONS: Dictionary[StringName, Vector2] = {
	&"CH3_BOSS_ANTE": Vector2(4414.0, 584.0),
	&"CH3_BOSS": Vector2(6160.0, 584.0),
	&"CH3_POST_BOSS": Vector2(9360.0, 584.0),
	&"CH3_UNDERKEEP_DESCENT": Vector2(10640.0, 584.0),
}

var _failures: Array[String] = []


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var profile: ChapterStartProfile = load(PROFILE_PATH) as ChapterStartProfile
	var session: ChapterSessionState = root.get_node_or_null("ChapterSession") as ChapterSessionState
	_expect(profile != null, "Chapter III start profile is missing")
	_expect(session != null, "ChapterSession autoload is missing")
	if profile == null or session == null:
		_finish()
		return
	for spawn_id: StringName in SPAWN_POSITIONS:
		var level: Chapter03EntryPlaceholder = await _instantiate_at_spawn(
			profile, session, spawn_id
		)
		if level == null:
			continue
		var player: Player = level.get_node("GameplayWorld/ChapterRuntime/Player") as Player
		var marker: Marker2D = level.get_node("SpawnPoints/%s" % spawn_id) as Marker2D
		var respawn: PlayerRespawnController = level.get_node(
			"GameplayWorld/ChapterRuntime/PlayerRespawnController"
		) as PlayerRespawnController
		_expect(marker.global_position == SPAWN_POSITIONS[spawn_id], "spawn moved unexpectedly: %s" % spawn_id)
		_expect(player.global_position.distance_to(marker.global_position) < 1.0, "player did not start at %s" % spawn_id)
		_expect(respawn.spawn_point != null, "respawn checkpoint missing at %s" % spawn_id)
		level.queue_free()
		await process_frame

	var route_level: Chapter03EntryPlaceholder = await _instantiate_at_spawn(
		profile, session, &"CH3_BOSS_ANTE"
	)
	if route_level != null:
		var route_player: Player = route_level.get_node(
			"GameplayWorld/ChapterRuntime/Player"
		) as Player
		var gate: Chapter03BossGate = route_level.get_node(
			"GameplayWorld/Chapter03BossAreas/BossGateTransition"
		) as Chapter03BossGate
		var sanctum: Chapter03BossSanctum = route_level.get_node(
			"GameplayWorld/Chapter03BossAreas/BossSanctum"
		) as Chapter03BossSanctum
		var boss_spawn: Marker2D = route_level.get_node("SpawnPoints/CH3_BOSS") as Marker2D
		gate.auto_trigger = false
		sanctum.intro_trigger.set_deferred("monitoring", false)
		await physics_frame
		gate.run_sequence_for_player(route_player)
		await gate.gate_sequence_finished
		_expect(gate.is_gate_open(), "thirteen-bell gate sequence did not open the gate")
		_expect(route_player.global_position.distance_to(boss_spawn.global_position) < 1.0, "gate sequence did not cross to the sanctum")
		_expect(route_player.get_input_profile() == Player.InputProfile.FULL, "gate sequence did not restore player input")
		sanctum.play_intro_environment(route_player)
		await sanctum.intro_environment_finished
		_expect(sanctum.is_intro_complete(), "sanctum environment intro did not finish")
		_expect(not sanctum.intro_camera.enabled, "sanctum intro camera stayed active")
		_expect(route_player.get_input_profile() == Player.InputProfile.FULL, "sanctum intro did not restore player input")
		route_level.queue_free()
		await process_frame
	session.begin_debug_run()
	_finish()


func _instantiate_at_spawn(
	profile: ChapterStartProfile,
	session: ChapterSessionState,
	spawn_id: StringName
) -> Chapter03EntryPlaceholder:
	session.begin_debug_run()
	session.apply_start_profile(profile, spawn_id)
	var packed: PackedScene = load(LEVEL_PATH) as PackedScene
	if packed == null:
		_failures.append("cannot load Chapter III level")
		return null
	var level: Chapter03EntryPlaceholder = packed.instantiate() as Chapter03EntryPlaceholder
	root.add_child(level)
	await process_frame
	await physics_frame
	return level


func _expect(condition: bool, message: String) -> void:
	if not condition:
		_failures.append(message)


func _finish() -> void:
	if _failures.is_empty():
		print("CH3_BOSS_ROUTE_TEST: PASS spawns=4 gate_sequence=true sanctum_intro=true crossing=true input_restored=true")
		quit(0)
		return
	for failure: String in _failures:
		push_error("CH3_BOSS_ROUTE_TEST: %s" % failure)
	print("CH3_BOSS_ROUTE_TEST: FAIL count=%d" % _failures.size())
	quit(1)
