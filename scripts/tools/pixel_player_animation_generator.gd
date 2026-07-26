class_name PixelPlayerAnimationGenerator
extends RefCounted

## Generates the production Night Warden locomotion/action animation batch.

const Pose: Script = preload("res://scripts/tools/pixel_assassin_pose.gd")
const Renderer: Script = preload("res://scripts/tools/pixel_assassin_renderer.gd")

const OUTPUT_ROOT: String = "res://assets/sprites/player/assassin"
const REFERENCE_SOURCE: String = "res://assets/sprites/player/concept_c"
const DEPRECATED_ATTACK_ROOT: String = "res://assets/sprites/player/assassin/reference/deprecated_attack_slash"
const DEPRECATED_ATTACK_SIX_FRAME_ROOT: String = (
	"res://assets/sprites/player/assassin/reference/deprecated_attack_six_frame"
)
const DEPRECATED_DASH_ATTACK_SIX_FRAME_ROOT: String = (
	"res://assets/sprites/player/assassin/reference/deprecated_dash_attack_six_frame"
)
const DEPRECATED_GROUND_DASH_ROOT: String = (
	"res://assets/sprites/player/assassin/reference/deprecated_ground_dash_five_frame"
)
const DEPRECATED_AIR_DASH_ROOT: String = (
	"res://assets/sprites/player/assassin/reference/deprecated_air_dash_five_frame"
)
const ANIMATION_ORDER: Array[String] = [
	"idle", "run", "dash_start", "dash_loop", "dash_end", "air_dash_start",
	"air_dash_loop", "air_dash_end", "attack", "dash_attack",
]
const FRAME_COUNTS: Dictionary[String, int] = {
	"idle": 4, "run": 6, "dash_start": 2, "dash_loop": 3, "dash_end": 2,
	"air_dash_start": 2, "air_dash_loop": 3, "air_dash_end": 2, "attack": 4,
	"dash_attack": 5,
}


static func generate_all(weapon_style: StringName = &"veilbound") -> Dictionary[String, Array]:
	return {
		"idle": _render_poses(_idle_poses(), weapon_style),
		"run": _render_poses(_run_poses(), weapon_style),
		"dash_start": _render_poses(_dash_start_poses(), weapon_style),
		"dash_loop": _render_poses(_dash_loop_poses(), weapon_style),
		"dash_end": _render_poses(_dash_end_poses(), weapon_style),
		"air_dash_start": _render_poses(_air_dash_start_poses(), weapon_style),
		"air_dash_loop": _render_poses(_air_dash_loop_poses(), weapon_style),
		"air_dash_end": _render_poses(_air_dash_end_poses(), weapon_style),
		"attack": _render_poses(_attack_poses(), weapon_style),
		"dash_attack": _render_poses(_dash_attack_poses(), weapon_style),
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
		_remove_obsolete_frames(directory, animation_name, frames.size())
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


static func archive_fast_attack_sources() -> Dictionary[String, int]:
	var results: Dictionary[String, int] = {}
	_archive_sequence(
		"attack", 6, DEPRECATED_ATTACK_SIX_FRAME_ROOT, "attack_6f", results
	)
	_archive_sequence(
		"dash_attack", 6, DEPRECATED_DASH_ATTACK_SIX_FRAME_ROOT, "dash_attack_6f", results
	)
	return results


static func archive_ground_dash_source() -> Dictionary[String, int]:
	var results: Dictionary[String, int] = {}
	_archive_sequence(
		"ground_dash", 5, DEPRECATED_GROUND_DASH_ROOT, "ground_dash_5f", results
	)
	return results


static func remove_archived_ground_dash_source() -> Dictionary[String, int]:
	var results: Dictionary[String, int] = {}
	for frame_index: int in range(1, 6):
		var source: String = OUTPUT_ROOT.path_join("ground_dash").path_join(
			"ground_dash_%02d.png" % frame_index
		)
		var archived: String = DEPRECATED_GROUND_DASH_ROOT.path_join(
			"ground_dash_5f_%02d.png" % frame_index
		)
		var source_bytes: PackedByteArray = FileAccess.get_file_as_bytes(source)
		var archived_bytes: PackedByteArray = FileAccess.get_file_as_bytes(archived)
		if source_bytes.is_empty() or source_bytes != archived_bytes:
			results[source] = ERR_INVALID_DATA
			continue
		var absolute_source: String = ProjectSettings.globalize_path(source)
		results[source] = DirAccess.remove_absolute(absolute_source)
		var import_sidecar: String = absolute_source + ".import"
		if FileAccess.file_exists(import_sidecar):
			DirAccess.remove_absolute(import_sidecar)
	return results


static func archive_air_dash_source() -> Dictionary[String, int]:
	var results: Dictionary[String, int] = {}
	_archive_sequence(
		"air_dash", 5, DEPRECATED_AIR_DASH_ROOT, "air_dash_5f", results
	)
	return results


static func remove_archived_air_dash_source() -> Dictionary[String, int]:
	var results: Dictionary[String, int] = {}
	for frame_index: int in range(1, 6):
		var source: String = OUTPUT_ROOT.path_join("air_dash").path_join(
			"air_dash_%02d.png" % frame_index
		)
		var archived: String = DEPRECATED_AIR_DASH_ROOT.path_join(
			"air_dash_5f_%02d.png" % frame_index
		)
		var source_bytes: PackedByteArray = FileAccess.get_file_as_bytes(source)
		var archived_bytes: PackedByteArray = FileAccess.get_file_as_bytes(archived)
		if source_bytes.is_empty() or source_bytes != archived_bytes:
			results[source] = ERR_INVALID_DATA
			continue
		var absolute_source: String = ProjectSettings.globalize_path(source)
		results[source] = DirAccess.remove_absolute(absolute_source)
		var import_sidecar: String = absolute_source + ".import"
		if FileAccess.file_exists(import_sidecar):
			DirAccess.remove_absolute(import_sidecar)
	return results


static func _archive_sequence(
		source_animation: String,
		frame_count: int,
		destination: String,
		destination_prefix: String,
		results: Dictionary[String, int]
	) -> void:
	var directory_error: Error = DirAccess.make_dir_recursive_absolute(
		ProjectSettings.globalize_path(destination)
	)
	if directory_error != OK:
		results[destination] = directory_error
		return
	for frame_index: int in range(1, frame_count + 1):
		var source: String = OUTPUT_ROOT.path_join(source_animation).path_join(
			"%s_%02d.png" % [source_animation, frame_index]
		)
		var target: String = destination.path_join(
			"%s_%02d.png" % [destination_prefix, frame_index]
		)
		if FileAccess.file_exists(ProjectSettings.globalize_path(target)):
			results[target] = OK
			continue
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


static func _remove_obsolete_frames(directory: String, animation_name: String, frame_count: int) -> void:
	var next_index: int = frame_count + 1
	while true:
		var stale_path: String = directory.path_join(
			"%s_%02d.png" % [animation_name, next_index]
		)
		var absolute_path: String = ProjectSettings.globalize_path(stale_path)
		if not FileAccess.file_exists(absolute_path):
			return
		DirAccess.remove_absolute(absolute_path)
		var sidecar_path: String = absolute_path + ".import"
		if FileAccess.file_exists(sidecar_path):
			DirAccess.remove_absolute(sidecar_path)
		next_index += 1


static func _render_poses(
		poses: Array[PixelAssassinPose], weapon_style: StringName = &"veilbound"
	) -> Array[Image]:
	var frames: Array[Image] = []
	for pose: PixelAssassinPose in poses:
		frames.append(Renderer.draw(pose, weapon_style))
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


static func _dash_start_poses() -> Array[PixelAssassinPose]:
	return [
		_pose(Vector2i(27, 29), Vector2i(47, 38), Vector2i(20, 40), Vector2i(42, 49), Vector2i(49, 58), Vector2i(27, 51), Vector2i(18, 58), Vector2i(60, 34), Vector2i(8, 48), Vector2i(14, 34)),
		_pose(Vector2i(29, 28), Vector2i(52, 35), Vector2i(21, 41), Vector2i(45, 48), Vector2i(54, 56), Vector2i(27, 50), Vector2i(14, 58), Vector2i(63, 30), Vector2i(8, 50), Vector2i(12, 32)),
	]


static func _dash_loop_poses() -> Array[PixelAssassinPose]:
	return [
		_pose(Vector2i(29, 28), Vector2i(52, 35), Vector2i(21, 41), Vector2i(45, 48), Vector2i(54, 56), Vector2i(27, 50), Vector2i(14, 58), Vector2i(63, 30), Vector2i(8, 50), Vector2i(12, 32)),
		_pose(Vector2i(31, 31), Vector2i(55, 37), Vector2i(22, 43), Vector2i(47, 49), Vector2i(57, 55), Vector2i(29, 51), Vector2i(11, 58), Vector2i(63, 32), Vector2i(7, 50), Vector2i(13, 34), Vector2i(1, 0)),
		_pose(Vector2i(30, 29), Vector2i(54, 35), Vector2i(21, 41), Vector2i(46, 49), Vector2i(58, 57), Vector2i(28, 50), Vector2i(12, 58), Vector2i(63, 29), Vector2i(7, 48), Vector2i(12, 31)),
	]


static func _dash_end_poses() -> Array[PixelAssassinPose]:
	return [
		_pose(Vector2i(30, 29), Vector2i(54, 35), Vector2i(21, 41), Vector2i(46, 49), Vector2i(58, 57), Vector2i(28, 50), Vector2i(12, 58), Vector2i(63, 29), Vector2i(7, 48), Vector2i(12, 31)),
		_pose(Vector2i(28, 27), Vector2i(50, 35), Vector2i(22, 39), Vector2i(43, 49), Vector2i(51, 58), Vector2i(29, 50), Vector2i(20, 58), Vector2i(63, 30), Vector2i(10, 47), Vector2i(16, 32)),
	]


static func _air_dash_start_poses() -> Array[PixelAssassinPose]:
	return [
		_pose(Vector2i(29, 25), Vector2i(48, 34), Vector2i(23, 39), Vector2i(39, 44), Vector2i(30, 52), Vector2i(29, 45), Vector2i(18, 51), Vector2i(60, 30), Vector2i(12, 47), Vector2i(13, 30)),
		_pose(Vector2i(31, 26), Vector2i(50, 34), Vector2i(24, 40), Vector2i(37, 43), Vector2i(25, 51), Vector2i(29, 44), Vector2i(16, 49), Vector2i(62, 29), Vector2i(12, 47), Vector2i(11, 29), Vector2i(1, -1)),
	]


static func _air_dash_loop_poses() -> Array[PixelAssassinPose]:
	return [
		_pose(Vector2i(31, 26), Vector2i(50, 34), Vector2i(24, 40), Vector2i(37, 43), Vector2i(25, 51), Vector2i(29, 44), Vector2i(16, 49), Vector2i(62, 29), Vector2i(12, 47), Vector2i(11, 29), Vector2i(1, -1)),
		_pose(Vector2i(33, 28), Vector2i(51, 35), Vector2i(26, 41), Vector2i(36, 44), Vector2i(23, 50), Vector2i(29, 44), Vector2i(14, 48), Vector2i(63, 30), Vector2i(13, 47), Vector2i(9, 30), Vector2i(1, -1)),
		_pose(Vector2i(32, 27), Vector2i(50, 34), Vector2i(25, 40), Vector2i(36, 43), Vector2i(24, 49), Vector2i(28, 44), Vector2i(15, 48), Vector2i(62, 29), Vector2i(12, 46), Vector2i(10, 29), Vector2i(1, -1)),
	]


static func _air_dash_end_poses() -> Array[PixelAssassinPose]:
	return [
		_pose(Vector2i(32, 27), Vector2i(50, 34), Vector2i(25, 40), Vector2i(36, 43), Vector2i(24, 49), Vector2i(28, 44), Vector2i(15, 48), Vector2i(62, 29), Vector2i(12, 46), Vector2i(10, 29), Vector2i(1, -1)),
		_pose(Vector2i(29, 25), Vector2i(48, 34), Vector2i(23, 39), Vector2i(41, 46), Vector2i(47, 54), Vector2i(29, 47), Vector2i(21, 54), Vector2i(60, 30), Vector2i(12, 47), Vector2i(14, 31)),
	]


static func _attack_poses() -> Array[PixelAssassinPose]:
	return [
		# Extremely short compression: both elbows gather without a held guard frame.
		_pose(Vector2i(27, 28), Vector2i(36, 34), Vector2i(34, 38), Vector2i(40, 49), Vector2i(46, 58), Vector2i(28, 50), Vector2i(19, 58), Vector2i(50, 31), Vector2i(46, 36), Vector2i(13, 32)),
		# First core frame: both hands and vertically separated blades snap forward.
		_pose(Vector2i(30, 28), Vector2i(50, 34), Vector2i(48, 38), Vector2i(46, 48), Vector2i(54, 58), Vector2i(28, 50), Vector2i(14, 58), Vector2i(63, 30), Vector2i(60, 35), Vector2i(12, 30)),
		# Held extension and maximum lean; this is the chain-open frame.
		_pose(Vector2i(32, 29), Vector2i(52, 34), Vector2i(50, 38), Vector2i(48, 48), Vector2i(56, 58), Vector2i(27, 49), Vector2i(10, 58), Vector2i(63, 30), Vector2i(61, 35), Vector2i(10, 31), Vector2i(1, 0)),
		# Fast retraction restores the compact stance without a long recovery hold.
		_pose(Vector2i(29, 26), Vector2i(46, 35), Vector2i(43, 39), Vector2i(42, 49), Vector2i(48, 58), Vector2i(30, 50), Vector2i(22, 58), Vector2i(58, 31), Vector2i(54, 37), Vector2i(16, 32)),
	]


static func _dash_attack_poses() -> Array[PixelAssassinPose]:
	return [
		# Dash carry-over and fast elbow retraction.
		_pose(Vector2i(31, 31), Vector2i(40, 36), Vector2i(38, 41), Vector2i(46, 50), Vector2i(55, 58), Vector2i(27, 51), Vector2i(10, 58), Vector2i(54, 32), Vector2i(50, 38), Vector2i(9, 32), Vector2i(1, 0)),
		# Both hands start forward while Dash inertia remains visible.
		_pose(Vector2i(33, 29), Vector2i(50, 34), Vector2i(48, 38), Vector2i(48, 48), Vector2i(57, 58), Vector2i(27, 50), Vector2i(8, 58), Vector2i(63, 30), Vector2i(60, 35), Vector2i(8, 29), Vector2i(1, 0)),
		# Core arrow silhouette: two simultaneous, vertically separated forward blades.
		_pose(Vector2i(34, 30), Vector2i(53, 34), Vector2i(51, 38), Vector2i(49, 48), Vector2i(58, 58), Vector2i(26, 49), Vector2i(6, 58), Vector2i(63, 30), Vector2i(62, 35), Vector2i(6, 29), Vector2i(1, 0)),
		# Hold the paired thrust briefly without converting into a lateral slash.
		_pose(Vector2i(34, 30), Vector2i(52, 35), Vector2i(50, 39), Vector2i(49, 49), Vector2i(58, 58), Vector2i(27, 50), Vector2i(7, 58), Vector2i(63, 31), Vector2i(61, 36), Vector2i(7, 31), Vector2i(1, 0)),
		# Retract both blades and shorten the stance for collision-safe recovery.
		_pose(Vector2i(30, 27), Vector2i(47, 35), Vector2i(44, 39), Vector2i(44, 49), Vector2i(52, 58), Vector2i(29, 50), Vector2i(17, 58), Vector2i(60, 31), Vector2i(56, 37), Vector2i(13, 31)),
	]
