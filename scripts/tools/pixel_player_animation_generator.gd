class_name PixelPlayerAnimationGenerator
extends RefCounted

## Generates the production Night Warden locomotion/action animation batch.

const Pose: Script = preload("res://scripts/tools/pixel_assassin_pose.gd")
const Renderer: Script = preload("res://scripts/tools/pixel_assassin_renderer.gd")

const OUTPUT_ROOT: String = "res://assets/sprites/player/assassin"
const REFERENCE_SOURCE: String = "res://assets/sprites/player/concept_c"
const DEPRECATED_ATTACK_ROOT: String = "res://assets/sprites/player/assassin/reference/deprecated_attack_slash"
const ANIMATION_ORDER: Array[String] = ["idle", "run", "ground_dash", "air_dash", "attack"]
const FRAME_COUNTS: Dictionary[String, int] = {
	"idle": 4, "run": 6, "ground_dash": 5, "air_dash": 5, "attack": 6,
}


static func generate_all() -> Dictionary[String, Array]:
	return {
		"idle": _render_poses(_idle_poses()),
		"run": _render_poses(_run_poses()),
		"ground_dash": _render_poses(_ground_dash_poses()),
		"air_dash": _render_poses(_air_dash_poses()),
		"attack": _render_poses(_attack_poses()),
	}


static func save_all(sequences: Dictionary[String, Array]) -> Dictionary[String, int]:
	var results: Dictionary[String, int] = {}
	for animation_name: String in ANIMATION_ORDER:
		var directory: String = OUTPUT_ROOT.path_join(animation_name)
		var directory_error: Error = DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(directory))
		if directory_error != OK:
			results[directory] = directory_error
			continue
		var frames: Array = sequences[animation_name]
		for index: int in range(frames.size()):
			var image: Image = frames[index] as Image
			var file_name: String = "%s_%02d.png" % [animation_name, index + 1]
			var path: String = directory.path_join(file_name)
			results[path] = image.save_png(path)
	return results


static func archive_references() -> Dictionary[String, int]:
	var destination: String = OUTPUT_ROOT.path_join("reference")
	var results: Dictionary[String, int] = {}
	var directory_error: Error = DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(destination))
	if directory_error != OK:
		results[destination] = directory_error
		return results
	var mapping: Dictionary[String, String] = {
		"assassin_front_64.png": "front_reference.png",
		"assassin_side_64.png": "side_reference.png",
		"assassin_dash_pose.png": "dash_pose_reference.png",
		"assassin_attack_anticipation.png": "attack_pose_reference.png",
	}
	for source_name: String in mapping:
		var source: String = REFERENCE_SOURCE.path_join(source_name)
		var target: String = destination.path_join(mapping[source_name])
		var bytes: PackedByteArray = FileAccess.get_file_as_bytes(source)
		if bytes.is_empty():
			results[target] = ERR_FILE_CANT_READ
			continue
		var file: FileAccess = FileAccess.open(target, FileAccess.WRITE)
		if file == null:
			results[target] = FileAccess.get_open_error()
			continue
		file.store_buffer(bytes)
		results[target] = OK
	return results


static func archive_current_attack() -> Dictionary[String, int]:
	var results: Dictionary[String, int] = {}
	var directory_error: Error = DirAccess.make_dir_recursive_absolute(
		ProjectSettings.globalize_path(DEPRECATED_ATTACK_ROOT)
	)
	if directory_error != OK:
		results[DEPRECATED_ATTACK_ROOT] = directory_error
		return results
	for frame_index: int in range(1, 7):
		var source: String = OUTPUT_ROOT.path_join("attack").path_join(
			"attack_%02d.png" % frame_index
		)
		var target: String = DEPRECATED_ATTACK_ROOT.path_join(
			"attack_slash_%02d.png" % frame_index
		)
		var bytes: PackedByteArray = FileAccess.get_file_as_bytes(source)
		if bytes.is_empty():
			results[target] = ERR_FILE_CANT_READ
			continue
		var file: FileAccess = FileAccess.open(target, FileAccess.WRITE)
		if file == null:
			results[target] = FileAccess.get_open_error()
			continue
		file.store_buffer(bytes)
		results[target] = OK
	return results


static func _render_poses(poses: Array[PixelAssassinPose]) -> Array[Image]:
	var frames: Array[Image] = []
	for pose: PixelAssassinPose in poses:
		frames.append(Renderer.draw(pose))
	return frames


static func _pose(
		body: Vector2i, front_hand: Vector2i, rear_hand: Vector2i,
		front_knee: Vector2i, front_foot: Vector2i,
		rear_knee: Vector2i, rear_foot: Vector2i,
		main_tip: Vector2i, offhand_tip: Vector2i, mantle_tip: Vector2i,
		hood_shift: Vector2i = Vector2i.ZERO
	) -> PixelAssassinPose:
	return Pose.new(body, hood_shift, front_hand, rear_hand, front_knee, front_foot,
		rear_knee, rear_foot, main_tip, offhand_tip, mantle_tip)


static func _idle_poses() -> Array[PixelAssassinPose]:
	return [
		_pose(Vector2i(28, 25), Vector2i(49, 34), Vector2i(22, 37), Vector2i(42, 48), Vector2i(47, 58), Vector2i(30, 49), Vector2i(25, 58), Vector2i(63, 28), Vector2i(11, 46), Vector2i(17, 32)),
		_pose(Vector2i(28, 24), Vector2i(49, 33), Vector2i(22, 36), Vector2i(42, 47), Vector2i(47, 58), Vector2i(30, 48), Vector2i(25, 58), Vector2i(63, 27), Vector2i(11, 45), Vector2i(16, 30)),
		_pose(Vector2i(28, 25), Vector2i(50, 34), Vector2i(22, 37), Vector2i(42, 48), Vector2i(47, 58), Vector2i(30, 49), Vector2i(25, 58), Vector2i(63, 28), Vector2i(11, 46), Vector2i(17, 31)),
		_pose(Vector2i(28, 26), Vector2i(49, 35), Vector2i(22, 38), Vector2i(42, 49), Vector2i(47, 58), Vector2i(30, 50), Vector2i(25, 58), Vector2i(63, 29), Vector2i(11, 47), Vector2i(18, 33)),
	]


static func _run_poses() -> Array[PixelAssassinPose]:
	return [
		_pose(Vector2i(29, 23), Vector2i(51, 32), Vector2i(22, 36), Vector2i(44, 47), Vector2i(54, 57), Vector2i(28, 49), Vector2i(17, 58), Vector2i(63, 27), Vector2i(10, 44), Vector2i(16, 29)),
		_pose(Vector2i(30, 22), Vector2i(52, 31), Vector2i(23, 38), Vector2i(45, 47), Vector2i(50, 58), Vector2i(29, 48), Vector2i(20, 55), Vector2i(63, 26), Vector2i(12, 47), Vector2i(17, 28)),
		_pose(Vector2i(29, 24), Vector2i(50, 34), Vector2i(23, 37), Vector2i(39, 49), Vector2i(42, 58), Vector2i(31, 49), Vector2i(28, 58), Vector2i(63, 29), Vector2i(11, 46), Vector2i(17, 31)),
		_pose(Vector2i(29, 23), Vector2i(48, 35), Vector2i(21, 34), Vector2i(31, 48), Vector2i(18, 58), Vector2i(42, 47), Vector2i(54, 57), Vector2i(61, 31), Vector2i(9, 41), Vector2i(15, 28)),
		_pose(Vector2i(30, 22), Vector2i(49, 36), Vector2i(22, 33), Vector2i(32, 47), Vector2i(21, 55), Vector2i(44, 47), Vector2i(50, 58), Vector2i(62, 32), Vector2i(10, 40), Vector2i(16, 27)),
		_pose(Vector2i(29, 24), Vector2i(50, 34), Vector2i(23, 37), Vector2i(32, 49), Vector2i(28, 58), Vector2i(39, 49), Vector2i(42, 58), Vector2i(63, 29), Vector2i(11, 46), Vector2i(18, 31)),
	]


static func _ground_dash_poses() -> Array[PixelAssassinPose]:
	return [
		_pose(Vector2i(27, 29), Vector2i(47, 38), Vector2i(20, 40), Vector2i(42, 49), Vector2i(49, 58), Vector2i(27, 51), Vector2i(18, 58), Vector2i(60, 34), Vector2i(8, 48), Vector2i(14, 34)),
		_pose(Vector2i(29, 28), Vector2i(52, 35), Vector2i(21, 41), Vector2i(45, 48), Vector2i(54, 56), Vector2i(27, 50), Vector2i(14, 58), Vector2i(63, 30), Vector2i(8, 50), Vector2i(12, 32)),
		_pose(Vector2i(31, 31), Vector2i(55, 37), Vector2i(22, 43), Vector2i(47, 49), Vector2i(57, 55), Vector2i(29, 51), Vector2i(11, 58), Vector2i(63, 32), Vector2i(7, 50), Vector2i(13, 34), Vector2i(1, 0)),
		_pose(Vector2i(30, 29), Vector2i(54, 35), Vector2i(21, 41), Vector2i(46, 49), Vector2i(58, 57), Vector2i(28, 50), Vector2i(12, 58), Vector2i(63, 29), Vector2i(7, 48), Vector2i(12, 31)),
		_pose(Vector2i(28, 27), Vector2i(50, 35), Vector2i(22, 39), Vector2i(43, 49), Vector2i(51, 58), Vector2i(29, 50), Vector2i(20, 58), Vector2i(63, 30), Vector2i(10, 47), Vector2i(16, 32)),
	]


static func _air_dash_poses() -> Array[PixelAssassinPose]:
	return [
		_pose(Vector2i(29, 25), Vector2i(48, 34), Vector2i(23, 39), Vector2i(39, 44), Vector2i(30, 52), Vector2i(29, 45), Vector2i(18, 51), Vector2i(60, 30), Vector2i(12, 47), Vector2i(13, 30)),
		_pose(Vector2i(31, 26), Vector2i(50, 34), Vector2i(24, 40), Vector2i(37, 43), Vector2i(25, 51), Vector2i(29, 44), Vector2i(16, 49), Vector2i(62, 29), Vector2i(12, 47), Vector2i(11, 29), Vector2i(1, -1)),
		_pose(Vector2i(33, 28), Vector2i(51, 35), Vector2i(26, 41), Vector2i(36, 44), Vector2i(23, 50), Vector2i(29, 44), Vector2i(14, 48), Vector2i(63, 30), Vector2i(13, 47), Vector2i(9, 30), Vector2i(1, -1)),
		_pose(Vector2i(32, 27), Vector2i(50, 34), Vector2i(25, 40), Vector2i(36, 43), Vector2i(24, 49), Vector2i(28, 44), Vector2i(15, 48), Vector2i(62, 29), Vector2i(12, 46), Vector2i(10, 29), Vector2i(1, -1)),
		_pose(Vector2i(29, 25), Vector2i(48, 34), Vector2i(23, 39), Vector2i(41, 46), Vector2i(47, 54), Vector2i(29, 47), Vector2i(21, 54), Vector2i(60, 30), Vector2i(12, 47), Vector2i(14, 31)),
	]


static func _attack_poses() -> Array[PixelAssassinPose]:
	return [
		_pose(Vector2i(28, 25), Vector2i(45, 34), Vector2i(41, 38), Vector2i(41, 48), Vector2i(47, 58), Vector2i(30, 49), Vector2i(24, 58), Vector2i(59, 31), Vector2i(53, 36), Vector2i(16, 31)),
		_pose(Vector2i(27, 28), Vector2i(35, 34), Vector2i(33, 38), Vector2i(40, 49), Vector2i(46, 58), Vector2i(28, 50), Vector2i(19, 58), Vector2i(49, 31), Vector2i(44, 36), Vector2i(13, 32)),
		_pose(Vector2i(30, 28), Vector2i(49, 34), Vector2i(47, 37), Vector2i(46, 48), Vector2i(54, 58), Vector2i(28, 50), Vector2i(14, 58), Vector2i(62, 31), Vector2i(58, 35), Vector2i(13, 31)),
		_pose(Vector2i(32, 29), Vector2i(52, 34), Vector2i(50, 37), Vector2i(48, 48), Vector2i(56, 58), Vector2i(27, 49), Vector2i(10, 58), Vector2i(63, 31), Vector2i(60, 34), Vector2i(10, 31), Vector2i(1, 0)),
		_pose(Vector2i(31, 29), Vector2i(51, 35), Vector2i(49, 38), Vector2i(47, 49), Vector2i(55, 58), Vector2i(28, 50), Vector2i(12, 58), Vector2i(63, 32), Vector2i(60, 35), Vector2i(12, 33), Vector2i(1, 0)),
		_pose(Vector2i(29, 26), Vector2i(46, 35), Vector2i(42, 39), Vector2i(42, 49), Vector2i(48, 58), Vector2i(30, 50), Vector2i(22, 58), Vector2i(58, 31), Vector2i(53, 37), Vector2i(16, 32)),
	]
