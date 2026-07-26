class_name PixelPlayerM1AnimationGenerator
extends RefCounted

## Generates formal M1-only jump, fall, and landing frames.

const Pose: Script = preload("res://scripts/tools/pixel_assassin_pose.gd")
const Renderer: Script = preload("res://scripts/tools/pixel_assassin_renderer.gd")

const OUTPUT_ROOT: String = "res://assets/sprites/player/assassin"
const ANIMATION_ORDER: Array[String] = ["jump_start", "jump_loop", "fall", "land"]
const FRAME_COUNTS: Dictionary[String, int] = {
	"jump_start": 2,
	"jump_loop": 2,
	"fall": 2,
	"land": 2,
}


static func generate_all(weapon_style: StringName = &"veilbound") -> Dictionary[String, Array]:
	return {
		"jump_start": _render_poses(_jump_start_poses(), weapon_style),
		"jump_loop": _render_poses(_jump_loop_poses(), weapon_style),
		"fall": _render_poses(_fall_poses(), weapon_style),
		"land": _render_poses(_land_poses(), weapon_style),
	}


static func save_all(sequences: Dictionary[String, Array]) -> Dictionary[String, int]:
	var results: Dictionary[String, int] = {}
	for animation_name: String in ANIMATION_ORDER:
		var directory: String = OUTPUT_ROOT.path_join(animation_name)
		var directory_error: Error = DirAccess.make_dir_recursive_absolute(
			ProjectSettings.globalize_path(directory)
		)
		if directory_error != OK:
			results[directory] = directory_error
			continue
		var frames: Array = sequences[animation_name]
		for index: int in range(frames.size()):
			var image: Image = frames[index] as Image
			var path: String = directory.path_join("%s_%02d.png" % [animation_name, index + 1])
			results[path] = image.save_png(path)
	return results


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


static func _jump_start_poses() -> Array[PixelAssassinPose]:
	return [
		_pose(Vector2i(28, 29), Vector2i(46, 37), Vector2i(24, 39), Vector2i(41, 50), Vector2i(47, 58), Vector2i(30, 51), Vector2i(24, 58), Vector2i(58, 33), Vector2i(14, 45), Vector2i(18, 35)),
		_pose(Vector2i(29, 25), Vector2i(47, 34), Vector2i(24, 36), Vector2i(42, 47), Vector2i(46, 58), Vector2i(31, 47), Vector2i(27, 58), Vector2i(59, 30), Vector2i(14, 42), Vector2i(18, 34)),
	]


static func _jump_loop_poses() -> Array[PixelAssassinPose]:
	return [
		_pose(Vector2i(29, 24), Vector2i(47, 33), Vector2i(24, 36), Vector2i(42, 44), Vector2i(47, 50), Vector2i(31, 45), Vector2i(26, 51), Vector2i(59, 29), Vector2i(14, 43), Vector2i(18, 36)),
		_pose(Vector2i(29, 23), Vector2i(48, 33), Vector2i(24, 35), Vector2i(43, 44), Vector2i(49, 51), Vector2i(31, 44), Vector2i(26, 49), Vector2i(60, 29), Vector2i(14, 42), Vector2i(17, 35)),
	]


static func _fall_poses() -> Array[PixelAssassinPose]:
	return [
		_pose(Vector2i(29, 24), Vector2i(51, 35), Vector2i(21, 35), Vector2i(42, 48), Vector2i(45, 58), Vector2i(31, 48), Vector2i(28, 58), Vector2i(63, 31), Vector2i(10, 42), Vector2i(15, 27)),
		_pose(Vector2i(29, 25), Vector2i(52, 36), Vector2i(21, 34), Vector2i(43, 49), Vector2i(47, 58), Vector2i(31, 49), Vector2i(26, 58), Vector2i(63, 32), Vector2i(9, 40), Vector2i(14, 26)),
	]


static func _land_poses() -> Array[PixelAssassinPose]:
	return [
		_pose(Vector2i(28, 30), Vector2i(48, 39), Vector2i(21, 41), Vector2i(43, 50), Vector2i(50, 58), Vector2i(29, 52), Vector2i(20, 58), Vector2i(60, 35), Vector2i(10, 48), Vector2i(15, 34)),
		_pose(Vector2i(28, 27), Vector2i(49, 36), Vector2i(22, 39), Vector2i(42, 49), Vector2i(48, 58), Vector2i(30, 50), Vector2i(23, 58), Vector2i(62, 31), Vector2i(11, 47), Vector2i(17, 33)),
	]
