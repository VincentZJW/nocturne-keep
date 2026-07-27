extends SceneTree

const ROOM_SCRIPT: Script = preload(
	"res://chapters/chapter_02_silent_court/scripts/level/chapter_02_room_graybox.gd"
)
const CAMERA_BOUNDS_SCRIPT: Script = preload(
	"res://chapters/chapter_02_silent_court/scripts/level/chapter_02_camera_bounds.gd"
)
const SURFACE_TRIM_SCRIPT: Script = preload(
	"res://chapters/chapter_02_silent_court/scripts/level/chapter_02_surface_trim.gd"
)
const OUTPUT_DIRECTORY: String = "res://chapters/chapter_02_silent_court/scenes/rooms"

var _failures: Array[String] = []


func _initialize() -> void:
	var rooms: Array[Dictionary] = _room_definitions()
	for room: Dictionary in rooms:
		_build_room(room)
	if _failures.is_empty():
		print("SILENT_COURT_ROOM_BUILDER: PASS rooms=%d" % rooms.size())
		quit(0)
		return
	for failure: String in _failures:
		push_error(failure)
	quit(1)


func _build_room(data: Dictionary) -> void:
	var root: Node2D = Node2D.new()
	root.name = String(data["node_name"])
	root.set_script(ROOM_SCRIPT)
	root.z_index = -60
	root.z_as_relative = false
	root.set("room_id", StringName(data["room_id"]))
	root.set("bilingual_name", String(data["bilingual_name"]))
	root.set("room_index", int(data["index"]))
	root.set("room_size", Vector2i(int(data["width"]), int(data["bottom"])))
	root.set("vertical_minimum", int(data["top"]))
	root.set("accent_color", data["accent"] as Color)
	root.set("platform_rects", _typed_platforms(data["platforms"] as Array))
	root.set("stair_polygons", _typed_ramps(data["ramps"] as Array))

	var background: Node2D = Node2D.new()
	background.name = "BackgroundPlaceholder"
	root.add_child(background)

	var geometry: Node2D = Node2D.new()
	geometry.name = "Geometry"
	root.add_child(geometry)
	_add_static_rectangle(geometry, "MainFloor", Vector2(float(data["width"]) * 0.5, 666.0), Vector2(float(data["width"]), 108.0))
	var main_floor_collision: CollisionShape2D = geometry.get_node(
		"MainFloor/CollisionShape2D"
	) as CollisionShape2D
	main_floor_collision.one_way_collision = bool(data.get("upper_floor", false))
	main_floor_collision.one_way_collision_margin = 8.0
	var platforms: Array = data["platforms"] as Array
	for platform_index: int in range(platforms.size()):
		var platform: Vector4 = platforms[platform_index] as Vector4
		_add_static_rectangle(
			geometry,
			"UpperPlatform%02d" % (platform_index + 1),
			Vector2(platform.x + platform.z * 0.5, platform.y + platform.w * 0.5),
			Vector2(platform.z, platform.w)
		)
	var ramps: Array = data["ramps"] as Array
	for ramp_index: int in range(ramps.size()):
		_add_static_polygon(geometry, "StairRamp%02d" % (ramp_index + 1), ramps[ramp_index] as PackedVector2Array)

	var surface_trim: Node2D = Node2D.new()
	surface_trim.name = "WalkableSurfaceTrim"
	surface_trim.z_index = 20
	surface_trim.z_as_relative = false
	surface_trim.set_script(SURFACE_TRIM_SCRIPT)
	surface_trim.set("room_width", float(data["width"]))
	surface_trim.set("floor_y", 612.0)
	surface_trim.set("trim_color", (data["accent"] as Color).lightened(0.08))
	surface_trim.set("platform_rects", _typed_platforms(data["platforms"] as Array))
	surface_trim.set("stair_polygons", _typed_ramps(data["ramps"] as Array))
	root.add_child(surface_trim)

	var props: Node2D = Node2D.new()
	props.name = "PropsPlaceholder"
	root.add_child(props)
	_add_marker_group(root, "DoorAnchors", data["doors"] as Dictionary)
	_add_marker_group(root, "CheckpointAnchors", data["checkpoints"] as Dictionary)
	_add_marker_group(root, "EncounterAnchors", data["encounters"] as Dictionary)
	_add_enemy_spawn_group(root, data["encounters"] as Dictionary)
	_add_marker_group(root, "NarrativeAnchors", data["narratives"] as Dictionary)
	_add_marker_group(root, "RouteAnchors", data["routes"] as Dictionary)

	var camera_bounds: Area2D = Area2D.new()
	camera_bounds.name = "CameraBounds"
	camera_bounds.collision_layer = 0
	camera_bounds.collision_mask = 2
	camera_bounds.monitoring = true
	camera_bounds.set_script(CAMERA_BOUNDS_SCRIPT)
	camera_bounds.set("room_id", StringName(data["room_id"]))
	camera_bounds.set("vertical_limits", Vector2i(int(data["top"]), int(data["bottom"])))
	root.add_child(camera_bounds)
	var bounds_shape: CollisionShape2D = CollisionShape2D.new()
	bounds_shape.name = "CollisionShape2D"
	bounds_shape.position = Vector2(float(data["width"]) * 0.5, (float(data["top"]) + float(data["bottom"])) * 0.5)
	var bounds_rectangle: RectangleShape2D = RectangleShape2D.new()
	bounds_rectangle.size = Vector2(float(data["width"]), float(data["bottom"]) - float(data["top"]))
	bounds_shape.shape = bounds_rectangle
	camera_bounds.add_child(bounds_shape)

	var entry: Marker2D = Marker2D.new()
	entry.name = "RoomEntry"
	entry.position = Vector2(64.0, 612.0)
	root.add_child(entry)
	var exit: Marker2D = Marker2D.new()
	exit.name = "RoomExit"
	exit.position = Vector2(float(data["width"]) - 64.0, 612.0)
	root.add_child(exit)

	var label: Label = Label.new()
	label.name = "DebugLabel"
	label.position = Vector2(32.0, float(data["top"]) + 28.0)
	label.text = "%02d · %s" % [int(data["index"]), String(data["bilingual_name"])]
	label.add_theme_font_size_override("font_size", 18)
	label.add_theme_color_override("font_color", Color(0.72, 0.77, 0.86, 0.82))
	label.z_index = 100
	label.z_as_relative = false
	root.add_child(label)

	_set_owner_recursive(root, root)
	var packed_scene: PackedScene = PackedScene.new()
	var pack_error: Error = packed_scene.pack(root)
	if pack_error != OK:
		_failures.append("Unable to pack %s: %s" % [data["file_name"], error_string(pack_error)])
		root.free()
		return
	var save_path: String = "%s/%s.tscn" % [OUTPUT_DIRECTORY, data["file_name"]]
	var save_error: Error = ResourceSaver.save(packed_scene, save_path)
	if save_error != OK:
		_failures.append("Unable to save %s: %s" % [save_path, error_string(save_error)])
	root.free()


func _add_static_rectangle(parent: Node2D, node_name: String, position: Vector2, size: Vector2) -> void:
	var body: StaticBody2D = StaticBody2D.new()
	body.name = node_name
	body.collision_layer = 1
	body.collision_mask = 0
	parent.add_child(body)
	var collision: CollisionShape2D = CollisionShape2D.new()
	collision.name = "CollisionShape2D"
	collision.position = position
	var rectangle: RectangleShape2D = RectangleShape2D.new()
	rectangle.size = size
	collision.shape = rectangle
	body.add_child(collision)


func _add_static_polygon(parent: Node2D, node_name: String, points: PackedVector2Array) -> void:
	var body: StaticBody2D = StaticBody2D.new()
	body.name = node_name
	body.collision_layer = 1
	body.collision_mask = 0
	parent.add_child(body)
	var collision: CollisionPolygon2D = CollisionPolygon2D.new()
	collision.name = "CollisionPolygon2D"
	collision.polygon = points
	body.add_child(collision)


func _add_marker_group(root: Node2D, group_name: String, markers: Dictionary) -> void:
	var group: Node2D = Node2D.new()
	group.name = group_name
	root.add_child(group)
	for marker_name: Variant in markers:
		var marker: Marker2D = Marker2D.new()
		marker.name = String(marker_name)
		marker.position = markers[marker_name] as Vector2
		group.add_child(marker)


func _add_enemy_spawn_group(root: Node2D, encounters: Dictionary) -> void:
	var group: Node2D = Node2D.new()
	group.name = "EnemySpawnAnchors"
	root.add_child(group)
	for encounter_name: Variant in encounters:
		var center: Vector2 = encounters[encounter_name] as Vector2
		for spawn_index: int in range(2):
			var marker: Marker2D = Marker2D.new()
			marker.name = "%s_Spawn_%02d" % [String(encounter_name), spawn_index + 1]
			marker.position = center + Vector2(-56.0 if spawn_index == 0 else 56.0, 0.0)
			group.add_child(marker)


func _set_owner_recursive(node: Node, owner: Node) -> void:
	for child: Node in node.get_children():
		child.owner = owner
		_set_owner_recursive(child, owner)


func _typed_platforms(source: Array) -> Array[Vector4]:
	var result: Array[Vector4] = []
	for value: Variant in source:
		result.append(value as Vector4)
	return result


func _typed_ramps(source: Array) -> Array[PackedVector2Array]:
	var result: Array[PackedVector2Array] = []
	for value: Variant in source:
		result.append(value as PackedVector2Array)
	return result


func _room_definitions() -> Array[Dictionary]:
	return [
		{
			"index": 1, "file_name": "castle_gate_interior", "node_name": "CastleGateInterior",
			"room_id": "CASTLE_GATE_INTERIOR", "bilingual_name": "Castle Gate Interior / 王城门内",
			"width": 1408, "top": 0, "bottom": 720, "accent": Color("52677f"),
			"platforms": [Vector4(760, 508, 384, 24)], "ramps": [],
			"doors": {"GateInteriorExitDoor": Vector2(1344, 612)},
			"checkpoints": {"Chapter02CP01": Vector2(384, 612)}, "encounters": {},
			"narratives": {"Chapter02TitleTrigger": Vector2(640, 612)},
			"routes": {"GateUpperLookout": Vector2(920, 508)},
		},
		{
			"index": 2, "file_name": "grey_banner_corridor", "node_name": "GreyBannerCorridor",
			"room_id": "GREY_BANNER_CORRIDOR", "bilingual_name": "Grey Banner Corridor / 灰旗长廊",
			"width": 1792, "top": 0, "bottom": 720, "accent": Color("687383"),
			"platforms": [Vector4(760, 500, 480, 24)], "ramps": [],
			"doors": {"CorridorEncounterGate": Vector2(1760, 612)}, "checkpoints": {},
			"encounters": {"E01": Vector2(360, 612), "E02": Vector2(920, 612), "E03": Vector2(1480, 612)},
			"narratives": {}, "routes": {"CorridorUpperRoute": Vector2(980, 500)},
		},
		{
			"index": 7, "file_name": "old_armory_safe_room", "node_name": "OldArmorySafeRoom",
			"room_id": "OLD_ARMORY_SAFE_ROOM", "bilingual_name": "Old Armory Safe Room / 旧军械库安全室",
			"width": 1024, "top": 0, "bottom": 720, "accent": Color("70808b"),
			"platforms": [Vector4(520, 500, 320, 24)], "ramps": [],
			"doors": {"ArmoryShortcutDoor": Vector2(960, 612)},
			"checkpoints": {"Chapter02CP04": Vector2(128, 612)}, "encounters": {}, "narratives": {},
			"routes": {"ArmoryMerchantPlaceholder": Vector2(720, 500)},
		},
		{
			"index": 3, "file_name": "last_banquet_hall", "node_name": "LastBanquetHall",
			"room_id": "LAST_BANQUET_HALL", "bilingual_name": "Last Banquet Hall / 末宴大厅",
			"width": 2944, "top": -120, "bottom": 720, "accent": Color("805b62"),
			"platforms": [Vector4(360, 548, 480, 18), Vector4(680, 450, 320, 24)],
			"ramps": [], "doors": {"BanquetEncounterGate": Vector2(260, 612)},
			"checkpoints": {"Chapter02CP02": Vector2(2700, 612)},
			"encounters": {"E04": Vector2(480, 612), "E05": Vector2(1320, 612), "E06": Vector2(2220, 612)},
			"narratives": {"BanquetMemoryTrigger": Vector2(1450, 612)},
			"routes": {"BanquetServiceBranch": Vector2(900, 450), "BanquetBalconyBranch": Vector2(1840, 420), "ChandelierAnchor": Vector2(1500, 40)},
		},
		{
			"index": 6, "file_name": "servant_passage", "node_name": "ServantPassage",
			"room_id": "SERVANT_PASSAGE", "bilingual_name": "Servant Upper Passage / 仆役上层通道",
			"width": 1280, "top": 0, "bottom": 720, "accent": Color("626b65"),
			"upper_floor": true,
			"platforms": [], "ramps": [],
			"doors": {"ServantConnectionDoor": Vector2(48, 612)}, "checkpoints": {},
			"encounters": {"E12": Vector2(840, 612), "E13": Vector2(360, 612)}, "narratives": {},
			"routes": {"KitchenBranch": Vector2(620, 510)},
		},
		{
			"index": 5, "file_name": "blood_candle_chapel", "node_name": "BloodCandleChapel",
			"room_id": "BLOOD_CANDLE_CHAPEL", "bilingual_name": "Blood Candle Chapel / 血烛礼拜堂",
			"width": 2688, "top": -120, "bottom": 720, "accent": Color("7a3343"),
			"upper_floor": true,
			"platforms": [Vector4(920, 400, 440, 24), Vector4(1480, 400, 440, 24), Vector4(2040, 500, 360, 24), Vector4(1080, 560, 520, 52)],
			"ramps": [], "doors": {"ChapelEncounterGate": Vector2(80, 612)},
			"checkpoints": {"Chapter02CP03": Vector2(220, 612)},
			"encounters": {"E09": Vector2(2200, 612), "E10": Vector2(1400, 612), "E11": Vector2(640, 612)},
			"narratives": {"ChapelLoreTrigger": Vector2(1320, 612)},
			"routes": {"ChapelCeilingAnchor": Vector2(1344, 70), "BloodCandleAnchor": Vector2(1344, 510)},
		},
		{
			"index": 4, "file_name": "royal_portrait_gallery", "node_name": "RoyalPortraitGallery",
			"room_id": "ROYAL_PORTRAIT_GALLERY", "bilingual_name": "Royal Portrait Gallery / 王室肖像长廊",
			"width": 3200, "top": 0, "bottom": 720, "accent": Color("75647e"),
			"upper_floor": true,
			"platforms": [Vector4(420, 500, 420, 24), Vector4(1040, 420, 420, 24), Vector4(1720, 420, 420, 24), Vector4(2380, 500, 420, 24)], "ramps": [],
			"doors": {"GalleryConnectionDoor": Vector2(3136, 612)}, "checkpoints": {},
			"encounters": {"E07": Vector2(2460, 612), "E08": Vector2(1320, 612)},
			"narratives": {"ElowenPortraitTrigger": Vector2(1850, 612), "RoyalKeyMemoryTrigger": Vector2(720, 612)},
			"routes": {"GalleryCeilingAnchor": Vector2(2050, 120)},
		},
		{
			"index": 8, "file_name": "silent_ballroom_antechamber", "node_name": "SilentBallroomAntechamber",
			"room_id": "SILENT_BALLROOM_ANTECHAMBER", "bilingual_name": "Silent Ballroom Antechamber / 无声舞厅前室",
			"width": 2688, "top": 0, "bottom": 720, "accent": Color("7f748e"),
			"upper_floor": true,
			"platforms": [Vector4(500, 500, 480, 24), Vector4(1180, 430, 480, 24)], "ramps": [],
			"doors": {"BallroomAntechamberDoor": Vector2(160, 612), "SilentBallroomBossDoor": Vector2(2520, 612)},
			"checkpoints": {"Chapter02CP05": Vector2(2340, 612)},
			"encounters": {"E14": Vector2(760, 612), "E15": Vector2(1680, 612)},
			"narratives": {"BossIntroTrigger": Vector2(2440, 612)}, "routes": {"UpperCourtGallery": Vector2(1280, 430)},
		},
		{
			"index": 9, "file_name": "silent_ballroom", "node_name": "SilentBallroom",
			"room_id": "SILENT_BALLROOM", "bilingual_name": "Silent Ballroom / 无声舞会厅",
			"width": 4480, "top": 0, "bottom": 720, "accent": Color("8a7897"),
			"upper_floor": true,
			"platforms": [], "ramps": [], "doors": {"SilentBallroomExitDoor": Vector2(4400, 612)},
			"checkpoints": {}, "encounters": {}, "narratives": {},
			"routes": {"BossLaneCenter": Vector2(2450, 612)},
		},
	]
