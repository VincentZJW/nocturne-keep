extends SceneTree

const FORMAL_LEVELS: Array[String] = [
	"res://chapters/chapter_01_ravenmourn_outskirts/scenes/level/ravenmourn_outskirts.tscn",
	"res://chapters/chapter_02_silent_court/scenes/level/silent_court.tscn",
	"res://chapters/chapter_03_chapel_of_thirteen_echoes/scenes/level/chapter_03_route.tscn",
	"res://chapters/chapter_04_drowned_underkeep/scenes/level/drowned_underkeep.tscn",
]
const BOUNDS_SCENE_PATH: String = "res://shared/scenes/world/world_bounds_2d.tscn"

var _failures: PackedStringArray = []


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	for level_path: String in FORMAL_LEVELS:
		await _check_level(level_path)
	for _frame: int in 4:
		await process_frame
	if _failures.is_empty():
		print("CROSS CHAPTER ACTOR BOUNDS | PASS chapters=4 physical_walls=16")
		quit(0)
		return
	for failure: String in _failures:
		push_error(failure)
	quit(1)


func _check_level(level_path: String) -> void:
	var file: FileAccess = FileAccess.open(level_path, FileAccess.READ)
	_check(file != null, "%s failed to open" % level_path)
	if file == null:
		return
	var source: String = file.get_as_text()
	file.close()
	_check(source.count(BOUNDS_SCENE_PATH) == 1, "%s must reference shared WorldBounds exactly once" % level_path)
	_check(source.count("name=\"WorldBounds2D\"") == 1, "%s must own exactly one WorldBounds2D instance" % level_path)
	_check(source.contains("actor_bounds = Rect2("), "%s must configure explicit actor bounds" % level_path)

	var packed: PackedScene = load(BOUNDS_SCENE_PATH) as PackedScene
	_check(packed != null, "shared WorldBounds scene failed to load")
	if packed == null:
		return
	var bounds: WorldBounds2D = packed.instantiate() as WorldBounds2D
	root.add_child(bounds)
	await process_frame
	_check(bounds.get_safe_flight_top_y() > bounds.get_top_limit_y(), "%s flight ceiling margin is invalid" % level_path)
	var generated_walls: int = 0
	for child: Node in bounds.get_children():
		if child is StaticBody2D and child.has_meta(&"world_bounds_generated"):
			generated_walls += 1
	_check(generated_walls == 4, "%s shared bounds do not generate four physical walls" % level_path)
	bounds.free()
	packed = null
	await process_frame


func _check(condition: bool, message: String) -> void:
	if not condition:
		_failures.append(message)
