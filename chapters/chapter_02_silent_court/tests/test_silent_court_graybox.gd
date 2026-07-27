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
const ROOM_X: Array[float] = [0.0, 2304.0, 6912.0, 11520.0, 15616.0, 19456.0, 22784.0, 24832.0, 27520.0]
const SPAWN_IDS: Array[StringName] = [
	&"CH2_START", &"CH2_BANQUET", &"CH2_GALLERY", &"CH2_CHAPEL", &"CH2_ARMORY", &"CH2_BOSS",
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
	_expect(level.get_node_or_null("ChapterRuntime/HUD/HealthContainer") is PlayerHealthHud, "Health HUD is missing")
	_expect(level.get_node_or_null("ChapterRuntime/PlayerRespawnController") is PlayerRespawnController, "Respawn controller is missing")
	for index: int in range(ROOM_NODES.size()):
		var room: Node2D = level.get_node_or_null("Rooms/%s" % ROOM_NODES[index]) as Node2D
		_expect(room != null, "Missing room instance: %s" % ROOM_NODES[index])
		if room != null:
			_expect(is_equal_approx(room.position.x, ROOM_X[index]), "Room x mismatch: %s" % ROOM_NODES[index])
			_expect(room.get_node_or_null("Geometry/MainFloor/CollisionShape2D") is CollisionShape2D, "Missing floor: %s" % ROOM_NODES[index])
			_expect(room.get_node_or_null("Geometry/CeilingBoundary/CollisionShape2D") is CollisionShape2D, "Missing ceiling: %s" % ROOM_NODES[index])
			_expect(room.get_node_or_null("CameraBounds") is Chapter02CameraBounds, "Missing CameraBounds: %s" % ROOM_NODES[index])
	_expect(level.get_node_or_null("Rooms/GreyBannerCorridor/Geometry/StairRamp01/CollisionPolygon2D") is CollisionPolygon2D, "Corridor stair ramp is missing")
	_expect(level.get_node_or_null("Rooms/ServantPassage/Geometry/StairRamp01/CollisionPolygon2D") is CollisionPolygon2D, "Passage up stair is missing")
	_expect(level.get_node_or_null("Rooms/ServantPassage/Geometry/StairRamp02/CollisionPolygon2D") is CollisionPolygon2D, "Passage down stair is missing")
	_expect(level.get_node_or_null("Rooms/LastBanquetHall/Geometry/UpperPlatform01/CollisionShape2D") is CollisionShape2D, "Banquet table collision is missing")
	_expect(level.get_node_or_null("Rooms/BloodCandleChapel/Geometry/UpperPlatform06/CollisionShape2D") is CollisionShape2D, "Chapel altar collision is missing")
	_test_required_anchors(level)
	_expect(_count_enemy_bodies(level) == 0, "Stage 2 graybox unexpectedly contains enemies")
	var player: Player = level.get_node("ChapterRuntime/Player") as Player
	_expect(player.player_camera.limit_left == 0 and player.player_camera.limit_right == 32128, "Camera horizontal limits mismatch")
	var wallet: CurrencyWallet = root.get_node_or_null("CurrencyManager") as CurrencyWallet
	var equipment: PlayerEquipmentManager = root.get_node_or_null("EquipmentManager") as PlayerEquipmentManager
	_expect(wallet != null and wallet.current_coins == 30, "Debug currency was not applied")
	_expect(equipment != null and equipment.equipped_weapon_id == &"ravenfang_daggers", "Ravenfang was not equipped")
	level.queue_free()
	await process_frame


func _test_required_anchors(level: Node) -> void:
	var paths: Array[String] = [
		"Rooms/CastleGateInterior/DoorAnchors/GateInteriorExitDoor",
		"Rooms/GreyBannerCorridor/DoorAnchors/CorridorEncounterGate",
		"Rooms/LastBanquetHall/DoorAnchors/BanquetEncounterGate",
		"Rooms/RoyalPortraitGallery/DoorAnchors/GalleryConnectionDoor",
		"Rooms/BloodCandleChapel/DoorAnchors/ChapelEncounterGate",
		"Rooms/ServantPassage/DoorAnchors/ServantConnectionDoor",
		"Rooms/OldArmorySafeRoom/DoorAnchors/ArmoryShortcutDoor",
		"Rooms/SilentBallroomAntechamber/DoorAnchors/BallroomAntechamberDoor",
		"Rooms/SilentBallroomAntechamber/DoorAnchors/SilentBallroomBossDoor",
		"Rooms/SilentBallroom/DoorAnchors/SilentBallroomExitDoor",
		"Rooms/CastleGateInterior/CheckpointAnchors/Chapter02CP01",
		"Rooms/LastBanquetHall/CheckpointAnchors/Chapter02CP02",
		"Rooms/BloodCandleChapel/CheckpointAnchors/Chapter02CP03",
		"Rooms/OldArmorySafeRoom/CheckpointAnchors/Chapter02CP04",
		"Rooms/SilentBallroomAntechamber/CheckpointAnchors/Chapter02CP05",
		"Rooms/CastleGateInterior/NarrativeAnchors/Chapter02TitleTrigger",
		"Rooms/LastBanquetHall/NarrativeAnchors/BanquetMemoryTrigger",
		"Rooms/RoyalPortraitGallery/NarrativeAnchors/ElowenPortraitTrigger",
		"Rooms/RoyalPortraitGallery/NarrativeAnchors/RoyalKeyMemoryTrigger",
		"Rooms/BloodCandleChapel/NarrativeAnchors/ChapelLoreTrigger",
		"Rooms/SilentBallroomAntechamber/NarrativeAnchors/BossIntroTrigger",
		"BossArea/BossSpawn", "BossArea/PlayerBossEntry", "BossArea/BossActivationArea",
		"BossArea/BossCameraBounds", "BossArea/BossDoorRear", "BossArea/BossExitDoor",
	]
	for path: String in paths:
		_expect(level.get_node_or_null(path) != null, "Missing required anchor: %s" % path)
	for encounter_index: int in range(1, 16):
		var encounter_name: String = "E%02d" % encounter_index
		var found: bool = false
		for room_name: String in ROOM_NODES:
			if level.get_node_or_null("Rooms/%s/EncounterAnchors/%s" % [room_name, encounter_name]) != null:
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
		var player: Player = level.get_node("ChapterRuntime/Player") as Player
		_expect(player.global_position.distance_to(marker.global_position) < 1.0, "Debug spawn failed: %s" % spawn_id)
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
		print("SILENT_COURT_GRAYBOX_TEST: PASS rooms=9 spawns=6 encounters=15 player=1 hud=1")
		quit(0)
		return
	for failure: String in _failures:
		push_error(failure)
	print("SILENT_COURT_GRAYBOX_TEST: FAIL issues=%d" % _failures.size())
	quit(1)
