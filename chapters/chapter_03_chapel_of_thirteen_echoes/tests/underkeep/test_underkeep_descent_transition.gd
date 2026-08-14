extends SceneTree

const AREA_SCENE: String = "res://chapters/chapter_03_chapel_of_thirteen_echoes/scenes/areas/ch3_underkeep_descent.tscn"
const ROOM_SCENE: String = "res://chapters/chapter_03_chapel_of_thirteen_echoes/scenes/rooms/ch3_underkeep_room.tscn"
const CH4_SCENE: String = "res://chapters/chapter_04_drowned_underkeep/scenes/level/drowned_underkeep.tscn"

var _failures: int = 0


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	_expect(not _repository_contains_placeholder_reference(), "runtime/source still references ossuary stairs")
	var area_packed: PackedScene = load(AREA_SCENE) as PackedScene
	_expect(area_packed != null, "underkeep area loads")
	if area_packed != null:
		var area: Chapter03UnderkeepDescent = area_packed.instantiate() as Chapter03UnderkeepDescent
		root.add_child(area)
		await process_frame
		_expect(area.get_node_or_null("WaterLayers/Body01") is UnderkeepAnimatedSprite, "animated deep-water body exists")
		_expect(area.get_node_or_null("WaterLayers/SurfaceBack01") is UnderkeepAnimatedSprite, "animated rear surface exists")
		_expect(area.get_node_or_null("WaterLayers/SurfaceFront01") is UnderkeepAnimatedSprite, "four-pixel front edge exists")
		var water_area: Area2D = area.get_node("WaterInteractionArea") as Area2D
		_expect(water_area.collision_layer == 0 and water_area.collision_mask == 2, "shallow water detects Player without blocking")
		_expect(area.get_node_or_null("Floor/CollisionShape2D") is CollisionShape2D, "continuous floor collision remains")
		_expect(area.get_node_or_null("MidgroundNarrativeProps/DrownedUnderkeepGate") is Sprite2D, "formal Chapter IV gate is composed")
		_expect(area.get_node_or_null("OssuaryStairs") == null, "chart-like stairs node removed")
		_expect(area.get_node("WaterLayers/SurfaceBack01").z_index < 12, "rear water renders behind Player")
		_expect(area.get_node("WaterLayers/SurfaceFront01").z_index > 12, "thin front edge renders above Player")
		area.queue_free()
		await process_frame
	_expect(load(ROOM_SCENE) is PackedScene, "formal underkeep room loads")
	var chapter_four_packed: PackedScene = load(CH4_SCENE) as PackedScene
	_expect(chapter_four_packed != null, "Chapter IV threshold loads")
	if chapter_four_packed != null:
		var chapter_four: Node = chapter_four_packed.instantiate()
		root.add_child(chapter_four)
		await process_frame
		_expect(chapter_four.get_node_or_null("ChapterRuntime/Player") is Player, "Chapter IV threshold has formal Player runtime")
		var room_host: Node = chapter_four.get_node_or_null("RoomHost")
		var active_room: Node = room_host.get_child(0) if room_host != null and room_host.get_child_count() == 1 else null
		_expect(
			active_room != null and active_room.get_node_or_null("SpawnPoints/EntryWest") is Marker2D,
			"Chapter IV CH4_START resolves to the formal Area 00 EntryWest spawn"
		)
		chapter_four.queue_free()
		await process_frame
	if _failures > 0:
		push_error("UNDERKEEP_TRANSITION_TEST FAIL count=%d" % _failures)
		quit(1)
		return
	print("UNDERKEEP_TRANSITION_TEST PASS placeholder=false water=animated interaction=nonblocking chapter4=reachable")
	quit(0)


func _repository_contains_placeholder_reference() -> bool:
	var paths: Array[String] = [
		AREA_SCENE,
		"res://chapters/chapter_03_chapel_of_thirteen_echoes/scripts/tools/generate_chapter_03_boss_environment_assets.gd",
		"res://chapters/chapter_03_chapel_of_thirteen_echoes/scripts/tools/generate_chapter_03_r3_grid_assets.gd",
	]
	for path: String in paths:
		var file: FileAccess = FileAccess.open(path, FileAccess.READ)
		if file != null and "ossuary_stairs" in file.get_as_text().to_lower():
			return true
	return false


func _expect(condition: bool, message: String) -> void:
	if condition:
		return
	_failures += 1
	push_error("UNDERKEEP_TRANSITION_TEST: %s" % message)
