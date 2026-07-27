extends SceneTree

const LEVEL_PATH: String = "res://chapters/chapter_02_silent_court/scenes/level/silent_court.tscn"
const BOOTSTRAP_PATH: String = "res://scenes/bootstrap/main_bootstrap.tscn"
const ROOM_FILES: Array[String] = [
	"castle_gate_interior", "grey_banner_corridor", "last_banquet_hall",
	"royal_portrait_gallery", "blood_candle_chapel", "servant_passage",
	"old_armory_safe_room", "silent_ballroom_antechamber", "silent_ballroom",
]
const ROOM_NODES: Array[String] = [
	"CastleGateInterior", "GreyBannerCorridor", "LastBanquetHall",
	"RoyalPortraitGallery", "BloodCandleChapel", "ServantPassage",
	"OldArmorySafeRoom", "SilentBallroomAntechamber", "SilentBallroom",
]
const ROOM_X: Array[float] = [0.0, 1408.0, 4224.0, 3968.0, 1280.0, 0.0, 3200.0, 0.0, 2688.0]
const ROOM_Y: Array[float] = [0.0, 0.0, 0.0, -900.0, -900.0, -900.0, 0.0, -1800.0, -1800.0]
const EXPECTED_PLATFORM_COUNTS: Array[int] = [1, 1, 2, 4, 4, 0, 1, 2, 0]
const EXPECTED_STAIR_COUNTS: Array[int] = [0, 0, 0, 0, 0, 0, 0, 0, 0]
const MAX_REQUIRED_TIER_RISE: float = 120.0
const SPAWN_IDS: Array[StringName] = [
	&"CH2_START", &"CH2_BANQUET", &"CH2_GALLERY", &"CH2_CHAPEL", &"CH2_ARMORY", &"CH2_BOSS",
	&"CH2_FLOOR_1_START", &"CH2_FLOOR_1_BANQUET", &"CH2_FLOOR_2_START",
	&"CH2_FLOOR_2_CHAPEL", &"CH2_FLOOR_3_START",
	&"CH2_FLOOR_1_STAIRS", &"CH2_FLOOR_2_STAIRS", &"CH2_ANTECHAMBER",
]

var _failures: Array[String] = []


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var config: DebugRunConfigState = root.get_node_or_null("DebugRunConfig") as DebugRunConfigState
	if config != null:
		config.debug_chapter_start_enabled = true
		config.debug_start_chapter_id = ChapterRegistry.CHAPTER_02_SILENT_COURT
		config.debug_start_spawn_id = &"CH2_START"
	_test_resources_and_profile()
	await _test_composed_level()
	await _test_all_debug_spawns()
	_finish()


func _test_resources_and_profile() -> void:
	_expect(ProjectSettings.get_setting("application/run/main_scene", "") == BOOTSTRAP_PATH, "run/main_scene is not MainBootstrap")
	_expect(ResourceLoader.exists(LEVEL_PATH, "PackedScene"), "Silent Court level is missing")
	for file_name: String in ROOM_FILES:
		var path: String = "res://chapters/chapter_02_silent_court/scenes/rooms/%s.tscn" % file_name
		_expect(ResourceLoader.exists(path, "PackedScene"), "Missing room: %s" % path)
	var profile: ChapterStartProfile = ChapterRegistry.get_chapter(ChapterRegistry.CHAPTER_02_SILENT_COURT)
	_expect(profile.is_valid_debug_target(), "Chapter II profile is not debug-ready")
	_expect(profile.default_spawn_id == &"CH2_START", "Wrong default spawn")
	_expect(profile.available_spawn_ids == SPAWN_IDS, "Spawn selector list mismatch")
	_expect(profile.equipped_weapon == &"ravenfang_daggers", "Ravenfang is not configured")


func _test_composed_level() -> void:
	var level: Node = _instantiate_level()
	if level == null:
		return
	root.add_child(level)
	await process_frame
	_expect(_count_players(level) == 1, "Level does not contain exactly one Player")
	_expect(_count_stamina_huds(level) == 1, "Level does not contain exactly one stamina HUD")
	_expect(level.get_node_or_null("GameplayWorld/PlayerAnchorOrRuntimeActors/ChapterRuntime/HUD/HealthContainer") is PlayerHealthHud, "Health HUD is missing")
	_expect(level.get_node_or_null("GameplayWorld/PlayerAnchorOrRuntimeActors/ChapterRuntime/PlayerRespawnController") is PlayerRespawnController, "Respawn controller is missing")
	for index: int in range(ROOM_NODES.size()):
		var room: Node2D = level.get_node_or_null("GameplayWorld/Geometry/Rooms/%s" % ROOM_NODES[index]) as Node2D
		_expect(room != null, "Missing room instance: %s" % ROOM_NODES[index])
		if room != null:
			_expect(is_equal_approx(room.position.x, ROOM_X[index]), "Room x mismatch: %s" % ROOM_NODES[index])
			_expect(is_equal_approx(room.position.y, ROOM_Y[index]), "Room y mismatch: %s" % ROOM_NODES[index])
			_expect(room.z_index == -60 and not room.z_as_relative, "Room backdrop layer mismatch: %s" % ROOM_NODES[index])
			_expect(room.get_node_or_null("Geometry/MainFloor/CollisionShape2D") is CollisionShape2D, "Missing floor: %s" % ROOM_NODES[index])
			_expect(room.get_node_or_null("CameraBounds") is Chapter02CameraBounds, "Missing CameraBounds: %s" % ROOM_NODES[index])
			_test_room_vertical_geometry(room as Chapter02RoomGraybox, index)
	_expect(level.get_node_or_null("GameplayWorld/Geometry/GrandServiceStair/Geometry/CollisionPolygon2D") is CollisionPolygon2D, "Grand Service Stair collision is missing")
	_expect(level.get_node_or_null("GameplayWorld/Geometry/ServantSideStair/Geometry/CollisionPolygon2D") is CollisionPolygon2D, "Servant Side Stair collision is missing")
	_test_floor_transitions(level)
	_test_stair_terminals(level)
	_expect(level.get_node_or_null("GameplayWorld/Geometry/Rooms/LastBanquetHall/Geometry/UpperPlatform01/CollisionShape2D") is CollisionShape2D, "Banquet table collision is missing")
	_expect(level.get_node_or_null("GameplayWorld/Geometry/Rooms/BloodCandleChapel/Geometry/UpperPlatform04/CollisionShape2D") is CollisionShape2D, "Chapel altar collision is missing")
	_test_required_anchors(level)
	_expect(_count_enemy_bodies(level) == 38, "Chapter II must contain exactly 38 ordinary enemies")
	_test_spawn_distribution(level)
	_expect((level.get_node("GameplayWorld/Enemies") as Node2D).z_index == 10, "Enemy layer must be z=10")
	var player: Player = level.get_node("GameplayWorld/PlayerAnchorOrRuntimeActors/ChapterRuntime/Player") as Player
	_expect(player.z_index == 12 and not player.z_as_relative, "Player layer must be z=12")
	_expect(player.player_camera.limit_left == 0 and player.player_camera.limit_right == 7040, "Floor 1 camera terminal limit mismatch")
	var wallet: CurrencyWallet = root.get_node_or_null("CurrencyManager") as CurrencyWallet
	var equipment: PlayerEquipmentManager = root.get_node_or_null("EquipmentManager") as PlayerEquipmentManager
	_expect(wallet != null and wallet.current_coins == 30, "Debug currency was not applied")
	_expect(equipment != null and equipment.equipped_weapon_id == &"ravenfang_daggers", "Ravenfang was not equipped")
	level.queue_free()
	await process_frame


func _test_floor_transitions(level: Node) -> void:
	var grand_stair: Chapter02Stair = level.get_node_or_null(
		"GameplayWorld/Geometry/GrandServiceStair"
	) as Chapter02Stair
	var side_stair: Chapter02Stair = level.get_node_or_null(
		"GameplayWorld/Geometry/ServantSideStair"
	) as Chapter02Stair
	_expect(grand_stair != null and grand_stair.surface_points.size() == 2, "Grand short stair is missing")
	_expect(side_stair != null and side_stair.surface_points.size() == 2, "Servant short stair is missing")
	if grand_stair != null:
		_expect(grand_stair.surface_points[0].distance_to(grand_stair.surface_points[1]) < 650.0, "Grand stair is still a long ramp")
	if side_stair != null:
		_expect(side_stair.surface_points[0].distance_to(side_stair.surface_points[1]) < 650.0, "Servant stair is still a long ramp")
	var first_transition: Chapter02FloorTransition = level.get_node_or_null(
		"TransitionAreas/Floor1ToFloor2"
	) as Chapter02FloorTransition
	var second_transition: Chapter02FloorTransition = level.get_node_or_null(
		"TransitionAreas/Floor2ToFloor3"
	) as Chapter02FloorTransition
	_expect(first_transition != null and first_transition.destination_spawn_id == &"CH2_FLOOR_2_START", "F1-to-F2 trigger is invalid")
	_expect(second_transition != null and second_transition.destination_spawn_id == &"CH2_FLOOR_3_START", "F2-to-F3 trigger is invalid")
	_expect(level.get_node_or_null("ChapterSystems/FloorTransitionController") is Chapter02FloorTransitionController, "Floor transition controller is missing")
	_expect(level.get_node_or_null("GameplayWorld/PlayerAnchorOrRuntimeActors/ChapterRuntime/HUD/FloorTransitionFade") is ColorRect, "Floor transition fade is missing")


func _test_stair_terminals(level: Node) -> void:
	var grand_terminal: Node2D = level.get_node_or_null(
		"GameplayWorld/Geometry/GrandServiceStairTerminal"
	) as Node2D
	var servant_terminal: Node2D = level.get_node_or_null(
		"GameplayWorld/Geometry/ServantSideStairTerminal"
	) as Node2D
	_expect(grand_terminal != null, "Grand stair terminal is missing")
	_expect(servant_terminal != null, "Servant stair terminal is missing")
	_expect(
		level.get_node_or_null("GameplayWorld/Geometry/GrandServiceStairTerminal/Geometry/EndWall/CollisionShape2D") is CollisionShape2D,
		"Grand stair end wall collision is missing"
	)
	_expect(
		level.get_node_or_null("GameplayWorld/Geometry/ServantSideStairTerminal/Geometry/EndWall/CollisionShape2D") is CollisionShape2D,
		"Servant stair end wall collision is missing"
	)
	_expect(level.get_node_or_null("GameplayWorld/Geometry/Floor2ArrivalVestibule/ClosedDoor") is Polygon2D, "Floor 2 arrival door is missing")
	_expect(level.get_node_or_null("GameplayWorld/Geometry/Floor3ArrivalVestibule/ClosedDoor") is Polygon2D, "Floor 3 arrival door is missing")
	var banquet_floor: CollisionShape2D = level.get_node(
		"GameplayWorld/Geometry/Rooms/LastBanquetHall/Geometry/MainFloor/CollisionShape2D"
	) as CollisionShape2D
	var banquet_shape: RectangleShape2D = banquet_floor.shape as RectangleShape2D
	_expect(is_equal_approx(banquet_shape.size.x, 2096.0), "Banquet floor still extends beyond the grand stair")
	var servant_floor: CollisionShape2D = level.get_node(
		"GameplayWorld/Geometry/Rooms/ServantPassage/Geometry/MainFloor/CollisionShape2D"
	) as CollisionShape2D
	var servant_shape: RectangleShape2D = servant_floor.shape as RectangleShape2D
	_expect(is_equal_approx(servant_shape.size.x, 512.0), "Servant floor still extends beyond the side stair")


func _test_spawn_distribution(level: Node) -> void:
	var spawn_root: Node2D = level.get_node_or_null("EnemySpawnPoints") as Node2D
	_expect(spawn_root != null, "Formal EnemySpawnPoints root is missing")
	if spawn_root == null:
		return
	var ground_count: int = 0
	var platform_count: int = 0
	var air_count: int = 0
	for child: Node in spawn_root.get_children():
		var spawn: Chapter02EnemySpawnPoint = child as Chapter02EnemySpawnPoint
		_expect(spawn != null and spawn.is_valid_spawn(), "Invalid formal spawn: %s" % child.name)
		if spawn == null:
			continue
		match spawn.placement:
			Chapter02EnemySpawnPoint.Placement.GROUND:
				ground_count += 1
			Chapter02EnemySpawnPoint.Placement.PLATFORM:
				platform_count += 1
			Chapter02EnemySpawnPoint.Placement.CEILING_AIR:
				air_count += 1
		if spawn.placement == Chapter02EnemySpawnPoint.Placement.PLATFORM:
			_expect(spawn.platform_right_bound > spawn.platform_left_bound, "Platform spawn lacks movement bounds: %s" % spawn.name)
	_expect(spawn_root.get_child_count() == 38, "Formal spawn count must remain 38")
	_expect(ground_count == 22, "Expected 22 ground enemies, got %d" % ground_count)
	_expect(platform_count == 11, "Expected 11 platform enemies, got %d" % platform_count)
	_expect(air_count == 5, "Expected 5 ceiling/air enemies, got %d" % air_count)


func _test_room_vertical_geometry(room: Chapter02RoomGraybox, room_index: int) -> void:
	if room == null:
		return
	_expect(room.platform_rects.size() == EXPECTED_PLATFORM_COUNTS[room_index], "%s platform count mismatch" % ROOM_NODES[room_index])
	_expect(room.stair_polygons.size() == EXPECTED_STAIR_COUNTS[room_index], "%s stair count mismatch" % ROOM_NODES[room_index])
	var geometry: Node = room.get_node_or_null("Geometry")
	if geometry == null:
		return
	for platform_index: int in range(room.platform_rects.size()):
		var platform: Vector4 = room.platform_rects[platform_index]
		_expect(platform.z >= 192.0, "%s platform %d is too narrow for stable landing" % [ROOM_NODES[room_index], platform_index + 1])
		_expect(geometry.get_node_or_null("UpperPlatform%02d/CollisionShape2D" % (platform_index + 1)) is CollisionShape2D, "%s platform %d has no collision" % [ROOM_NODES[room_index], platform_index + 1])
	for stair_index: int in range(room.stair_polygons.size()):
		_expect(geometry.get_node_or_null("StairRamp%02d/CollisionPolygon2D" % (stair_index + 1)) is CollisionPolygon2D, "%s stair %d has no collision" % [ROOM_NODES[room_index], stair_index + 1])
	var surface_levels: Array[float] = [612.0]
	for platform: Vector4 in room.platform_rects:
		if not surface_levels.has(platform.y):
			surface_levels.append(platform.y)
	surface_levels.sort()
	for level_index: int in range(surface_levels.size() - 1):
		var rise: float = surface_levels[level_index + 1] - surface_levels[level_index]
		_expect(rise <= MAX_REQUIRED_TIER_RISE, "%s tier rise %.1f exceeds %.1f px" % [ROOM_NODES[room_index], rise, MAX_REQUIRED_TIER_RISE])
	if room_index == 8:
		_expect(room.platform_rects.is_empty() and room.stair_polygons.is_empty(), "Silent Ballroom must remain a flat combat lane")


func _test_required_anchors(level: Node) -> void:
	var paths: Array[String] = [
		"GameplayWorld/Geometry/Rooms/CastleGateInterior/DoorAnchors/GateInteriorExitDoor",
		"GameplayWorld/Geometry/Rooms/GreyBannerCorridor/DoorAnchors/CorridorEncounterGate",
		"GameplayWorld/Geometry/Rooms/LastBanquetHall/DoorAnchors/BanquetEncounterGate",
		"GameplayWorld/Geometry/Rooms/RoyalPortraitGallery/DoorAnchors/GalleryConnectionDoor",
		"GameplayWorld/Geometry/Rooms/BloodCandleChapel/DoorAnchors/ChapelEncounterGate",
		"GameplayWorld/Geometry/Rooms/ServantPassage/DoorAnchors/ServantConnectionDoor",
		"GameplayWorld/Geometry/Rooms/OldArmorySafeRoom/DoorAnchors/ArmoryShortcutDoor",
		"GameplayWorld/Geometry/Rooms/SilentBallroomAntechamber/DoorAnchors/BallroomAntechamberDoor",
		"GameplayWorld/Geometry/Rooms/SilentBallroomAntechamber/DoorAnchors/SilentBallroomBossDoor",
		"GameplayWorld/Geometry/Rooms/SilentBallroom/DoorAnchors/SilentBallroomExitDoor",
		"GameplayWorld/BossArea/BossSpawn", "GameplayWorld/BossArea/PlayerBossEntry", "GameplayWorld/BossArea/BossActivationArea",
		"GameplayWorld/BossArea/BossCameraBounds", "GameplayWorld/BossArea/BossDoorRear", "GameplayWorld/BossArea/BossExitDoor",
	]
	for path: String in paths:
		_expect(level.get_node_or_null(path) != null, "Missing required anchor: %s" % path)
	for encounter_index: int in range(1, 16):
		var encounter_name: String = "E%02d" % encounter_index
		var found: bool = false
		for room_name: String in ROOM_NODES:
			if level.get_node_or_null("GameplayWorld/Geometry/Rooms/%s/EncounterAnchors/%s" % [room_name, encounter_name]) != null:
				found = true
				break
		_expect(found, "Missing encounter anchor: %s" % encounter_name)
	for spawn_id: StringName in SPAWN_IDS:
		_expect(level.get_node_or_null("PlayerSpawnPoints/%s" % spawn_id) is Marker2D, "Missing debug spawn: %s" % spawn_id)


func _test_all_debug_spawns() -> void:
	var config: DebugRunConfigState = root.get_node_or_null("DebugRunConfig") as DebugRunConfigState
	if config == null:
		_failures.append("DebugRunConfig is missing")
		return
	config.debug_start_chapter_id = ChapterRegistry.CHAPTER_02_SILENT_COURT
	for spawn_id: StringName in SPAWN_IDS:
		config.debug_start_spawn_id = spawn_id
		var level: Node = _instantiate_level()
		if level == null:
			return
		root.add_child(level)
		await process_frame
		var marker: Marker2D = level.get_node("PlayerSpawnPoints/%s" % spawn_id) as Marker2D
		var player: Player = level.get_node("GameplayWorld/PlayerAnchorOrRuntimeActors/ChapterRuntime/Player") as Player
		if player.global_position.distance_to(marker.global_position) >= 5.0:
			print("CH2_DEBUG_SPAWN_DRIFT id=%s marker=%s player=%s" % [spawn_id, marker.global_position, player.global_position])
		_expect(player.global_position.distance_to(marker.global_position) < 5.0, "Debug spawn failed: %s" % spawn_id)
		level.queue_free()
		await process_frame
	config.reset_to_defaults()


func _instantiate_level() -> Node:
	var packed: PackedScene = ResourceLoader.load(LEVEL_PATH, "PackedScene") as PackedScene
	if packed == null:
		_failures.append("Unable to load Silent Court")
		return null
	return packed.instantiate()


func _count_players(node: Node) -> int:
	var count: int = 1 if node is Player else 0
	for child: Node in node.get_children():
		count += _count_players(child)
	return count


func _count_stamina_huds(node: Node) -> int:
	var count: int = 1 if node is PlayerStaminaHud else 0
	for child: Node in node.get_children():
		count += _count_stamina_huds(child)
	return count


func _count_enemy_bodies(node: Node) -> int:
	var count: int = 1 if node is EnemyCombatant else 0
	for child: Node in node.get_children():
		count += _count_enemy_bodies(child)
	return count


func _expect(condition: bool, message: String) -> void:
	if not condition:
		_failures.append(message)


func _finish() -> void:
	if _failures.is_empty():
		print("SILENT_COURT_GRAYBOX_TEST: PASS rooms=9 floors=3 spawns=14 encounters=15 enemies=38 player=1 hud=1")
		quit(0)
		return
	for failure: String in _failures:
		push_error(failure)
	print("SILENT_COURT_GRAYBOX_TEST: FAIL issues=%d" % _failures.size())
	quit(1)
