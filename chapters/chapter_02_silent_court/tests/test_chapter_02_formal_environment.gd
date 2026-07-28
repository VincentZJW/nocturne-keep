extends SceneTree

const LEVEL_PATH: String = "res://chapters/chapter_02_silent_court/scenes/level/silent_court.tscn"

var _failures: Array[String] = []


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	Engine.time_scale = 12.0
	var packed: PackedScene = load(LEVEL_PATH) as PackedScene
	var level: SilentCourtLevel = packed.instantiate() as SilentCourtLevel if packed != null else null
	if level == null:
		_fail("Silent Court could not instantiate")
		_finish()
		return
	root.add_child(level)
	current_scene = level
	for _frame: int in range(6):
		await process_frame
	_validate_assets()
	_validate_saved_composition(level)
	await _validate_threshold(level)
	Engine.time_scale = 1.0
	_finish()


func _validate_assets() -> void:
	var required_assets: Array[String] = [
		"res://chapters/chapter_02_silent_court/assets/weapons/crimson_masque_stilettos/world_display.png",
		"res://chapters/chapter_02_silent_court/assets/weapons/crimson_masque_stilettos/pickup_icon.png",
		"res://chapters/chapter_02_silent_court/assets/weapons/crimson_masque_stilettos/pedestal_display.png",
		"res://chapters/chapter_02_silent_court/assets/portraits/lady_secret_smile.png",
		"res://chapters/chapter_02_silent_court/assets/portraits/stern_court_lord.png",
		"res://chapters/chapter_02_silent_court/assets/portraits/royal_reader.png",
		"res://chapters/chapter_02_silent_court/assets/portraits/elder_in_cape.png",
		"res://chapters/chapter_02_silent_court/assets/portraits/rose_maiden.png",
		"res://chapters/chapter_02_silent_court/assets/portraits/court_matron.png",
		"res://chapters/chapter_02_silent_court/assets/doors/armory_iron_door.png",
		"res://chapters/chapter_02_silent_court/assets/doors/blood_candle_chapel_arch.png",
		"res://chapters/chapter_02_silent_court/assets/doors/ballroom_double_door.png",
		"res://chapters/chapter_02_silent_court/assets/props/armory_weapon_rack.png",
		"res://chapters/chapter_02_silent_court/assets/props/ruined_banquet_table.png",
		"res://chapters/chapter_02_silent_court/assets/props/blood_candle_altar.png",
		"res://chapters/chapter_02_silent_court/assets/fx/candle_flame_01.png",
	]
	for path: String in required_assets:
		_expect(FileAccess.file_exists(path), "Missing generated asset %s" % path)
		var texture: Texture2D = load(path) as Texture2D
		_expect(texture != null and texture.get_width() > 0, "Generated asset did not import %s" % path)
	_expect_text_reference(
		"res://chapters/chapter_02_silent_court/scenes/weapons/crimson_masque_stilettos_pickup.tscn",
		"res://chapters/chapter_02_silent_court/assets/weapons/crimson_masque_stilettos/pickup_icon.png"
	)
	_expect_text_reference(
		"res://chapters/chapter_02_silent_court/scenes/transitions/duchess_reliquary.tscn",
		"res://chapters/chapter_02_silent_court/assets/weapons/crimson_masque_stilettos/pedestal_display.png"
	)
	_expect_text_reference(
		"res://chapters/chapter_02_silent_court/resources/weapons/crimson_masque_stilettos.tres",
		"res://chapters/chapter_02_silent_court/assets/weapons/crimson_masque_stilettos/inventory_icon_formal.png"
	)


func _validate_saved_composition(level: SilentCourtLevel) -> void:
	var paths: Array[String] = [
		"GameplayWorld/Geometry/Rooms/OldArmorySafeRoom/PropsPlaceholder/CrossedStilettos",
		"GameplayWorld/Geometry/Rooms/OldArmorySafeRoom/PropsPlaceholder/WeaponRack",
		"GameplayWorld/Geometry/Rooms/LastBanquetHall/PropsPlaceholder/BanquetTable01",
		"GameplayWorld/Geometry/Rooms/RoyalPortraitGallery/BackgroundPlaceholder/Portrait01",
		"GameplayWorld/Geometry/Rooms/RoyalPortraitGallery/BackgroundPlaceholder/Portrait06",
		"GameplayWorld/Geometry/Rooms/BloodCandleChapel/BackgroundPlaceholder/ChapelArch03",
		"GameplayWorld/Geometry/Rooms/BloodCandleChapel/PropsPlaceholder/BloodCandleAltar",
		"GameplayWorld/Geometry/Rooms/SilentBallroomAntechamber/PropsPlaceholder/ArmorStatue02",
		"GameplayWorld/Geometry/Rooms/SilentBallroom/BackgroundPlaceholder/RoyalCrest",
		"GameplayWorld/BossArea/DuchessBossEntrance/ExteriorVisuals/DoorArtwork",
	]
	for path: String in paths:
		_expect(level.get_node_or_null(path) != null, "Saved Main is missing %s" % path)
	for room_name: String in [
		"OldArmorySafeRoom", "LastBanquetHall", "RoyalPortraitGallery",
		"BloodCandleChapel", "SilentBallroomAntechamber", "SilentBallroom",
	]:
		var room: Chapter02RoomGraybox = level.get_node(
			"GameplayWorld/Geometry/Rooms/%s" % room_name
		) as Chapter02RoomGraybox
		_expect(not room.use_legacy_identity, "%s still draws legacy line placeholders" % room_name)


func _validate_threshold(level: SilentCourtLevel) -> void:
	var player: Player = level.get_node(
		"GameplayWorld/PlayerAnchorOrRuntimeActors/ChapterRuntime/Player"
	) as Player
	var threshold: DuchessBossThresholdTransition = level.get_node(
		"ChapterSystems/DuchessBossThresholdTransition"
	) as DuchessBossThresholdTransition
	var room: HollowDuchessRoomController = level.get_node(
		"ChapterSystems/HollowDuchessRoomController"
	) as HollowDuchessRoomController
	var destination: Marker2D = level.get_node(
		"GameplayWorld/BossArea/PlayerBossEntry"
	) as Marker2D
	_expect(threshold.request_entry(), "Formal Boss threshold rejected a legal first entry")
	var saw_blackout: bool = false
	for _frame: int in range(180):
		await process_frame
		saw_blackout = saw_blackout or threshold.get_transition_stage() == &"blackout"
		if not threshold.is_transitioning():
			break
	_expect(saw_blackout, "Formal Boss threshold never reached blackout")
	_expect(player.global_position == destination.global_position, "Player was not relocated behind blackout")
	_expect(room.encounter_started, "Boss intro did not start after fade-in")
	_expect(room.intro_seen, "First-entry presentation was not recorded")


func _expect(condition: bool, message: String) -> void:
	if not condition:
		_fail(message)


func _expect_text_reference(file_path: String, expected_reference: String) -> void:
	var file: FileAccess = FileAccess.open(file_path, FileAccess.READ)
	_expect(file != null, "Could not read %s" % file_path)
	if file == null:
		return
	_expect(
		file.get_as_text().contains(expected_reference),
		"%s does not use %s" % [file_path, expected_reference]
	)


func _fail(message: String) -> void:
	_failures.append(message)


func _finish() -> void:
	if _failures.is_empty():
		print("CHAPTER_02_FORMAL_ENVIRONMENT_TEST: PASS assets=16 portraits=6 weapon_contexts=4 rooms=6 threshold=fade/relocate/intro")
		quit(0)
		return
	for failure: String in _failures:
		push_error("CHAPTER_02_FORMAL_ENVIRONMENT_TEST: %s" % failure)
	quit(1)
