extends SceneTree

const MANIFEST_PATH: String = "res://chapters/chapter_04_drowned_underkeep/resources/rooms/chapter_04_room_manifest_s3.json"
const LEVEL_PATH: String = "res://chapters/chapter_04_drowned_underkeep/scenes/level/drowned_underkeep.tscn"
const EXPECTED_FUNCTIONS: Array[String] = [
	"transition", "combat", "combat", "traversal_combat", "vertical_combat",
	"ecology_arena", "safe_checkpoint", "ambush_combat", "elite_combat",
	"mixed_combat", "machinery_combat", "combat_exam", "safe_checkpoint",
	"boss_staging", "boss_arena", "reward_revelation", "chapter_transition",
]
const EXPECTED_SLOTS: Array[int] = [0, 4, 5, 4, 5, 5, 0, 4, 5, 4, 5, 5, 0, 0, 0, 0, 0]

var _failures: PackedStringArray = []


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var manifest: Dictionary = _load_json(MANIFEST_PATH)
	_check(int(manifest.get("room_count", 0)) == 17, "manifest room_count must be 17")
	_check(bool(manifest.get("formal_encounters_populated", false)), "S4 must persist formal ordinary encounters")
	_check(int(manifest.get("formal_enemy_count", 0)) == 46, "S4 formal enemy count must be 46")
	_check(int(manifest.get("formal_encounter_group_count", 0)) == 20, "S4 EncounterGroup count must be 20")
	_check(int(manifest.get("encounter_authored_seed", 0)) == 40446, "S4 authored seed must be 40446")
	var rooms: Array = manifest.get("rooms", []) as Array
	_check(rooms.size() == 17, "manifest must contain 17 room records")
	var asset_references: int = 0
	var checkpoint_ids: Array[String] = []
	for index: int in rooms.size():
		var record: Dictionary = rooms[index] as Dictionary
		var path: String = str(record.get("scene", ""))
		var packed: PackedScene = load(path) as PackedScene
		_check(packed != null, "room %02d scene failed to load" % index)
		if packed == null:
			continue
		var room: Chapter04Room = packed.instantiate() as Chapter04Room
		_check(room != null, "room %02d root must use Chapter04Room" % index)
		if room == null:
			continue
		_check(room.room_index == index, "room index mismatch for %02d" % index)
		_check(room.room_id == StringName("CH4_AREA_%02d" % index), "room id mismatch for %02d" % index)
		_check(String(room.room_function) == EXPECTED_FUNCTIONS[index], "room function mismatch for %02d" % index)
		_check(room.room_size.y == 720 and room.room_size.x >= 1536, "room bounds invalid for %02d" % index)
		var floor_shape: CollisionShape2D = room.get_node_or_null("Gameplay/FloorCollision/CollisionShape2D") as CollisionShape2D
		_check(floor_shape != null and floor_shape.shape is RectangleShape2D, "room %02d floor collision missing" % index)
		if floor_shape != null and floor_shape.shape is RectangleShape2D:
			var rectangle: RectangleShape2D = floor_shape.shape as RectangleShape2D
			_check(is_equal_approx(floor_shape.position.y - rectangle.size.y * 0.5, 620.0), "room %02d floor top is not 620" % index)
		var spawns: Node2D = room.get_node_or_null("SpawnPoints") as Node2D
		_check(spawns != null and spawns.has_node("EntryWest") and spawns.has_node("EntryEast") and spawns.has_node("Inspection"), "room %02d spawn contract incomplete" % index)
		var exit_count: int = room.get_node("Transitions").find_children("*", "Chapter04RoomExit", false, false).size()
		var expected_exits: int = 1 if index in [0, 16] else 2
		_check(exit_count == expected_exits, "room %02d exit count mismatch" % index)
		if index == 16:
			_check(room.has_node("Transitions/MemoryExit"), "room 16 must expose the formal Chapter V memory exit")
		var slot_root: Node = room.get_node("FutureEncounterSpawns")
		var ground_slots: int = 0
		for marker: Node in slot_root.get_children():
			if marker.name.begins_with("GroundSlot"):
				ground_slots += 1
		_check(ground_slots == EXPECTED_SLOTS[index], "room %02d future ground slot count mismatch" % index)
		for sprite: Node in room.find_children("*", "Sprite2D", true, false):
			var canvas_sprite: Sprite2D = sprite as Sprite2D
			if canvas_sprite != null and canvas_sprite.texture != null:
				asset_references += 1
				_check(canvas_sprite.texture.resource_path.begins_with("res://chapters/chapter_04_drowned_underkeep/assets/"), "room %02d references non-Chapter-IV texture %s" % [index, canvas_sprite.texture.resource_path])
				_check(canvas_sprite.texture_filter == CanvasItem.TEXTURE_FILTER_NEAREST, "room %02d has non-nearest sprite" % index)
		for platform_shape_node: Node in room.find_children("CollisionShape2D", "CollisionShape2D", true, false):
			var platform_shape: CollisionShape2D = platform_shape_node as CollisionShape2D
			if platform_shape == null or not platform_shape.get_parent().name.begins_with("PlatformCollision"):
				continue
			var platform_rect: RectangleShape2D = platform_shape.shape as RectangleShape2D
			_check(platform_rect != null and platform_rect.size.x >= 64.0, "room %02d platform collision invalid" % index)
			_check(620.0 - (platform_shape.position.y - 6.0) <= 124.0, "room %02d mandatory platform exceeds locked vertical envelope" % index)
		if room.has_node("Gameplay/Checkpoint"):
			checkpoint_ids.append(String((room.get_node("Gameplay/Checkpoint") as Area2D).get("checkpoint_id")))
		var encounter_spawner: Chapter04EncounterSpawner = room.get_node_or_null("EncounterSpawner") as Chapter04EncounterSpawner
		if EXPECTED_SLOTS[index] > 0:
			_check(encounter_spawner != null, "combat room %02d must persist its S4 EncounterSpawner" % index)
		else:
			_check(encounter_spawner == null, "support room %02d must remain enemy-free" % index)
		room.free()
	_check(asset_references >= 500, "17-room route should reference at least 500 formal Sprite nodes")
	_check(checkpoint_ids == ["DRY_GAOLER_CELL", "CP_CH4_BOSS"], "formal checkpoint ids mismatch")
	var level: PackedScene = load(LEVEL_PATH) as PackedScene
	_check(level != null, "formal Chapter IV level failed to load")
	if level != null:
		var level_root: Node = level.instantiate()
		_check(level_root.has_node("RoomHost"), "formal level lacks RoomHost")
		_check(level_root.has_node("RoomTransitionController"), "formal level lacks transition controller")
		_check(level_root.has_node("ChapterRuntime/Player"), "formal level lacks persistent Player")
		_check(not level_root.has_node("CharacterTrial"), "CharacterTrial must remain separate from the formal route")
		level_root.free()
	if _failures.is_empty():
		print("CH4 S3/S4 FORMAL ROUTE | PASS rooms=17 assets=%d checkpoints=2 encounters=20 enemies=46" % asset_references)
		quit(0)
		return
	for failure: String in _failures:
		push_error("CH4 S3 FORMAL ROUTE: %s" % failure)
	quit(1)


func _load_json(path: String) -> Dictionary:
	var file: FileAccess = FileAccess.open(path, FileAccess.READ)
	if file == null:
		_failures.append("unable to read %s" % path)
		return {}
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	file.close()
	return parsed as Dictionary if parsed is Dictionary else {}


func _check(condition: bool, message: String) -> void:
	if not condition:
		_failures.append(message)
