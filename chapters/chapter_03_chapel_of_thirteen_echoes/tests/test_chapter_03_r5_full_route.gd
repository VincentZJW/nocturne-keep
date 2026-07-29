extends SceneTree

const ROOT_PATH: String = "res://chapters/chapter_03_chapel_of_thirteen_echoes"
const ROUTE_PATH: String = ROOT_PATH + "/scenes/level/chapter_03_route.tscn"
const PROFILE_PATH: String = ROOT_PATH + "/resources/chapter/chapter_03_start_profile.tres"
const MAIN_BOOTSTRAP_PATH: String = "res://scenes/bootstrap/main_bootstrap.tscn"
const STRESS_CYCLES: int = 10
const TRANSITION_TIMEOUT_FRAMES: int = 180

const REQUIRED_STARTS: Array[StringName] = [
	&"chapter_03_start",
	&"CH3_NAVE_ENTRY",
	&"CH3_CHOIR_GALLERY",
	&"CH3_BOSS_CHECKPOINT",
	&"CH3_BOSS_ANTE",
	&"CH3_BOSS",
	&"CH3_POST_BOSS",
	&"CH3_UNDERKEEP_DESCENT",
]

const STRESS_BOUNDARIES: Array[Dictionary] = [
	{
		"source": &"CH3_CHAPEL_VESTIBULE",
		"destination": &"CH3_NAVE_ENTRY",
		"label": "Vestibule->Nave",
	},
	{
		"source": &"CH3_NAVE_ENTRY",
		"destination": &"CH3_CHOIR_GALLERY",
		"label": "Nave->Choir",
	},
	{
		"source": &"CH3_CHOIR_GALLERY",
		"destination": &"CH3_BOSS_CHECKPOINT",
		"label": "Choir->Checkpoint",
	},
	{
		"source": &"CH3_BOSS_ANTE",
		"destination": &"CH3_BOSS",
		"label": "Antechamber->Sanctum",
	},
]

var _failures: Array[String] = []
var _completed_transitions: int = 0


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	_assert_project_contract()
	var session: ChapterSessionState = root.get_node_or_null("ChapterSession") as ChapterSessionState
	var profile: ChapterStartProfile = load(PROFILE_PATH) as ChapterStartProfile
	_expect(session != null, "ChapterSession autoload exists")
	_expect(profile != null, "Chapter III start profile loads")
	if session == null or profile == null:
		_finish()
		return
	_expect(profile.main_scene_path == ROUTE_PATH, "Chapter III profile targets formal route")
	for spawn_id: StringName in REQUIRED_STARTS:
		_expect(profile.available_spawn_ids.has(spawn_id), "profile exposes start: %s" % spawn_id)

	session.begin_debug_run()
	session.apply_start_profile(profile, &"chapter_03_start")
	var packed: PackedScene = load(ROUTE_PATH) as PackedScene
	var route: Chapter03Route = packed.instantiate() as Chapter03Route if packed != null else null
	_expect(route != null, "formal Chapter III route instantiates")
	if route == null:
		_finish()
		return
	root.add_child(route)
	await process_frame
	await physics_frame
	var controller: Chapter03RoomTransitionController = route.transition_controller
	var player: Player = controller.player
	var hud: CanvasLayer = route.get_node("PersistentRuntime/ChapterRuntime/HUD") as CanvasLayer
	var player_id: int = player.get_instance_id()
	var hud_id: int = hud.get_instance_id()
	_expect(controller.active_room_id == &"CH3_CHAPEL_VESTIBULE", "formal route starts in Vestibule")
	_expect(route.get_node("RoomHost").get_child_count() == 1, "route starts with one active room")
	_assert_direct_start_mapping(route)
	_assert_platform_combat_contract()

	for boundary: Dictionary in STRESS_BOUNDARIES:
		var source: StringName = boundary["source"] as StringName
		var destination: StringName = boundary["destination"] as StringName
		var label: String = boundary["label"] as String
		for cycle: int in range(STRESS_CYCLES):
			_expect(controller._swap_room(source, &"EntryWest"), "%s source reset %d" % [label, cycle + 1])
			await process_frame
			await physics_frame
			_expect(controller.request_room_change(destination, &"EntryWest"), "%s accepted %d" % [label, cycle + 1])
			await _wait_for_transition(controller, destination)
			_assert_transition_invariants(route, controller, player_id, hud_id, label, cycle + 1)
			_completed_transitions += 1

	await _assert_terminal_boundaries(controller)
	session.begin_debug_run()
	route.queue_free()
	await process_frame
	_finish()


func _assert_project_contract() -> void:
	var project_text: String = FileAccess.get_file_as_string("res://project.godot")
	_expect(
		project_text.contains("run/main_scene=\"uid://b7olunr0nd51q\"")
		or project_text.contains(MAIN_BOOTSTRAP_PATH),
		"project run/main_scene remains MainBootstrap"
	)
	_expect(ResourceLoader.exists(MAIN_BOOTSTRAP_PATH, "PackedScene"), "MainBootstrap scene exists")
	_expect(ChapterRegistry.CHAPTER_03_SCENE_PATH == ROUTE_PATH, "ChapterRegistry points to formal route")


func _assert_direct_start_mapping(route: Chapter03Route) -> void:
	var expected_rooms: Dictionary[StringName, StringName] = {
		&"chapter_03_start": &"CH3_CHAPEL_VESTIBULE",
		&"CH3_NAVE_ENTRY": &"CH3_NAVE_ENTRY",
		&"CH3_CHOIR_GALLERY": &"CH3_CHOIR_GALLERY",
		&"CH3_BOSS_CHECKPOINT": &"CH3_BOSS_CHECKPOINT",
		&"CH3_BOSS_ANTE": &"CH3_BOSS_ANTE",
		&"CH3_BOSS": &"CH3_BOSS",
		&"CH3_POST_BOSS": &"CH3_POST_BOSS",
		&"CH3_UNDERKEEP_DESCENT": &"CH3_UNDERKEEP_DESCENT",
	}
	for spawn_id: StringName in expected_rooms:
		var resolved: Dictionary = route._resolve_start(spawn_id)
		_expect(
			resolved.get("room_id", &"") == expected_rooms[spawn_id],
			"direct Main start resolves %s" % spawn_id
		)


func _assert_platform_combat_contract() -> void:
	for room_path: String in [
		ROOT_PATH + "/scenes/rooms/ch3_nave_entry.tscn",
		ROOT_PATH + "/scenes/rooms/ch3_choir_gallery.tscn",
	]:
		var packed: PackedScene = load(room_path) as PackedScene
		var room: Chapter03Room = packed.instantiate() as Chapter03Room if packed != null else null
		_expect(room != null, "combat room instantiates: %s" % room_path)
		if room == null:
			continue
		root.add_child(room)
		await process_frame
		var enemies: Node = room.get_node_or_null("Enemies")
		_expect(enemies != null, "combat room owns Enemies: %s" % room_path)
		if enemies != null:
			_expect(enemies.get_child_count() == 3, "combat room contains three readable roles: %s" % room_path)
			var horizontal_bands: Dictionary[int, int] = {}
			for child: Node in enemies.get_children():
				var enemy: EnemyCombatant = child as EnemyCombatant
				_expect(enemy != null, "%s is a live EnemyCombatant" % child.name)
				if enemy == null:
					continue
				_expect(enemy.z_index == Chapter03LayerContract.ENEMIES, "%s stays above platforms" % child.name)
				_expect(
					enemy.get_health_component() != null,
					"%s exposes authoritative combat health" % child.name
				)
				_expect(
					not enemy.find_children("*", "HurtboxComponent", true, false).is_empty(),
					"%s exposes a combat Hurtbox" % child.name
				)
				horizontal_bands[int(roundf(enemy.position.y / 64.0))] = 1
			_expect(horizontal_bands.size() >= 2, "combat roles occupy ground/platform bands: %s" % room_path)
		room.queue_free()
		await process_frame


func _wait_for_transition(
	controller: Chapter03RoomTransitionController,
	destination: StringName
) -> void:
	for _frame: int in range(TRANSITION_TIMEOUT_FRAMES):
		await process_frame
		if controller.active_room_id == &"CH3_BOSS" and controller.active_room != null:
			var boss_room: Chapter03BossSanctumRoom = controller.active_room as Chapter03BossSanctumRoom
			if boss_room != null and not boss_room.sanctum.is_intro_complete():
				boss_room.sanctum.skip_intro_to_combat_state()
		if (
			controller.active_room_id == destination
			and not controller.fade_rect.visible
			and controller.player.get_input_profile() == Player.InputProfile.FULL
		):
			return
	_failures.append("transition timeout: %s" % destination)


func _assert_transition_invariants(
	route: Chapter03Route,
	controller: Chapter03RoomTransitionController,
	player_id: int,
	hud_id: int,
	label: String,
	cycle: int
) -> void:
	var prefix: String = "%s cycle %d" % [label, cycle]
	_expect(route.get_node("RoomHost").get_child_count() == 1, "%s has one active room" % prefix)
	_expect(controller.player.get_instance_id() == player_id, "%s preserves Player" % prefix)
	_expect(
		route.get_node("PersistentRuntime/ChapterRuntime/HUD").get_instance_id() == hud_id,
		"%s preserves HUD" % prefix
	)
	_expect(not controller.fade_rect.visible, "%s leaves no stuck Fade" % prefix)
	_expect(controller.player.get_input_profile() == Player.InputProfile.FULL, "%s restores input" % prefix)
	_expect(controller.player.velocity == Vector2.ZERO, "%s resets transition velocity" % prefix)
	if controller.player.player_camera != null:
		_expect(
			controller.player.player_camera.limit_right == controller.active_room.room_size.x,
			"%s updates horizontal camera bound" % prefix
		)
		_expect(
			controller.player.player_camera.limit_bottom == controller.active_room.room_size.y,
			"%s updates vertical camera bound" % prefix
		)


func _assert_terminal_boundaries(controller: Chapter03RoomTransitionController) -> void:
	_expect(controller._swap_room(&"CH3_BOSS", &"EntryWest"), "Boss room reset for terminal audit")
	await process_frame
	var boss_room: Chapter03BossSanctumRoom = controller.active_room as Chapter03BossSanctumRoom
	_expect(boss_room != null, "Boss Sanctum room is available")
	if boss_room != null:
		_expect(
			boss_room.sanctum.get_node_or_null("BossIntegrationAnchor") is Marker2D,
			"Edran integration anchor is typed and saved"
		)
		_expect(
			boss_room.sanctum.find_children("*", "EnemyCombatant", true, false).is_empty(),
			"no placeholder combatant is misrepresented as Edran"
		)
	_expect(controller._swap_room(&"CH3_POST_BOSS", &"EntryWest"), "post-Boss room loads")
	await process_frame
	var post_room: Chapter03PostBossRoom = controller.active_room as Chapter03PostBossRoom
	_expect(post_room != null, "post-Boss reward interface is saved")
	if post_room != null:
		_expect(not post_room.underkeep_exit.monitoring, "descent remains reward-gated")
	_expect(
		not ResourceLoader.exists(ChapterRegistry.CHAPTER_04_SCENE_PATH, "PackedScene"),
		"Chapter IV remains an explicit planned boundary"
	)


func _expect(condition: bool, message: String) -> void:
	if not condition:
		_failures.append(message)


func _finish() -> void:
	if _failures.is_empty():
		print((
			"CH3_R5_FULL_ROUTE PASS transitions=%d cycles=%d persistent_runtime=true "
			+ "platform_combat=true boss_entity=partial reward=partial chapter4=partial"
		) % [_completed_transitions, STRESS_CYCLES])
		quit(0)
		return
	for failure: String in _failures:
		push_error("CH3_R5_FULL_ROUTE FAIL: %s" % failure)
	print("CH3_R5_FULL_ROUTE FAIL count=%d" % _failures.size())
	quit(1)
