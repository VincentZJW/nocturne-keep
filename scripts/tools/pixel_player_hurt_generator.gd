class_name PixelPlayerHurtGenerator
extends RefCounted

## Generates the production three-frame Night Warden hit reaction and archives placeholders.

const Pose: Script = preload("res://scripts/tools/pixel_assassin_pose.gd")
const Renderer: Script = preload("res://scripts/tools/pixel_assassin_renderer.gd")

const OUTPUT_ROOT: String = "res://assets/sprites/player/assassin/hurt"
const PLACEHOLDER_ROOT: String = "res://assets/sprites/player/assassin/placeholder"
const ARCHIVE_ROOT: String = (
	"res://assets/sprites/player/assassin/reference/deprecated_hurt_placeholder"
)


static func generate_frames(weapon_style: StringName = &"veilbound") -> Array[Image]:
	var frames: Array[Image] = []
	for pose: PixelAssassinPose in _hurt_poses():
		frames.append(Renderer.draw(pose, weapon_style))
	return frames


static func save_all() -> Dictionary[String, int]:
	var results: Dictionary[String, int] = {}
	var output_error: Error = DirAccess.make_dir_recursive_absolute(
		ProjectSettings.globalize_path(OUTPUT_ROOT)
	)
	var archive_error: Error = DirAccess.make_dir_recursive_absolute(
		ProjectSettings.globalize_path(ARCHIVE_ROOT)
	)
	if output_error != OK:
		results[OUTPUT_ROOT] = output_error
		return results
	if archive_error != OK:
		results[ARCHIVE_ROOT] = archive_error
		return results
	var frames: Array[Image] = generate_frames()
	for frame_index: int in range(frames.size()):
		var output_path: String = OUTPUT_ROOT.path_join("hurt_%02d.png" % (frame_index + 1))
		results[output_path] = frames[frame_index].save_png(output_path)
		var placeholder_name: String = "placeholder_hurt_%02d.png" % (frame_index + 1)
		var source_path: String = PLACEHOLDER_ROOT.path_join(placeholder_name)
		var archive_path: String = ARCHIVE_ROOT.path_join(placeholder_name)
		results[archive_path] = _copy_file(source_path, archive_path)
	return results


static func _hurt_poses() -> Array[PixelAssassinPose]:
	return [
		Pose.new(
			Vector2i(25, 25), Vector2i(-2, -1),
			Vector2i(43, 36), Vector2i(18, 35),
			Vector2i(40, 49), Vector2i(47, 58),
			Vector2i(28, 49), Vector2i(22, 58),
			Vector2i(54, 41), Vector2i(8, 30), Vector2i(12, 27)
		),
		Pose.new(
			Vector2i(23, 23), Vector2i(-3, -2),
			Vector2i(40, 35), Vector2i(16, 33),
			Vector2i(38, 48), Vector2i(45, 57),
			Vector2i(26, 48), Vector2i(19, 58),
			Vector2i(51, 43), Vector2i(6, 27), Vector2i(9, 25)
		),
		Pose.new(
			Vector2i(26, 25), Vector2i(-1, 0),
			Vector2i(46, 35), Vector2i(20, 37),
			Vector2i(41, 49), Vector2i(47, 58),
			Vector2i(29, 49), Vector2i(23, 58),
			Vector2i(58, 31), Vector2i(9, 45), Vector2i(14, 30)
		),
	]


static func _copy_file(source_path: String, destination_path: String) -> Error:
	var bytes: PackedByteArray = FileAccess.get_file_as_bytes(source_path)
	if bytes.is_empty():
		return ERR_FILE_CANT_READ
	var destination: FileAccess = FileAccess.open(destination_path, FileAccess.WRITE)
	if destination == null:
		return FileAccess.get_open_error()
	destination.store_buffer(bytes)
	return OK
