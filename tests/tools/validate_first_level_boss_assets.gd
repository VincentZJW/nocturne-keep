extends SceneTree

## Source-asset validation for new Gargoyle/Boss pixel production frames.

const ROOTS: Dictionary[String, Vector2i] = {
	"res://assets/sprites/enemies/gargoyle_sentinel": Vector2i(64, 64),
	"res://assets/sprites/bosses/fallen_gate_knight": Vector2i(96, 96),
}

var _failures: Array[String] = []


func _initialize() -> void:
	var total: int = 0
	for root_path: String in ROOTS:
		var files: PackedStringArray = _collect_pngs(root_path)
		total += files.size()
		for path: String in files:
			_validate_png(path, ROOTS[root_path])
	_expect(total == 141, "Expected 141 Gargoyle/Boss source frames, found %d" % total)
	_finish()


func _collect_pngs(root_path: String) -> PackedStringArray:
	var results: PackedStringArray = []
	var directory: DirAccess = DirAccess.open(root_path)
	if directory == null:
		_expect(false, "Missing asset root %s" % root_path)
		return results
	for entry: String in directory.get_directories():
		if entry in ["reference", "deprecated"]:
			continue
		results.append_array(_collect_pngs(root_path.path_join(entry)))
	for entry: String in directory.get_files():
		if entry.ends_with(".png"):
			results.append(root_path.path_join(entry))
	return results


func _validate_png(path: String, expected_size: Vector2i) -> void:
	var image: Image = Image.load_from_file(ProjectSettings.globalize_path(path))
	_expect(image != null and not image.is_empty(), "Cannot load %s" % path)
	if image == null or image.is_empty():
		return
	_expect(image.get_size() == expected_size, "%s size mismatch" % path)
	_expect(image.detect_alpha() != Image.ALPHA_NONE, "%s lacks transparency" % path)
	var import_path: String = "%s.import" % path
	_expect(FileAccess.file_exists(import_path), "%s lacks source import config" % path)
	if FileAccess.file_exists(import_path):
		var import_text: String = FileAccess.get_file_as_string(import_path)
		_expect(import_text.contains("compress/mode=0"), "%s is not lossless imported" % path)
		_expect(import_text.contains("mipmaps/generate=false"), "%s enables mipmaps" % path)


func _expect(condition: bool, message: String) -> void:
	if not condition:
		_failures.append(message)


func _finish() -> void:
	if _failures.is_empty():
		print("FIRST_LEVEL_BOSS_ASSET_TEST: PASS (141 transparent lossless/no-mipmap frames)")
		quit(0)
		return
	for failure: String in _failures:
		push_error(failure)
	print("FIRST_LEVEL_BOSS_ASSET_TEST: FAIL (%d issues)" % _failures.size())
	quit(1)
