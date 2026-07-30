extends SceneTree

const Art: GDScript = preload("res://chapters/chapter_03_chapel_of_thirteen_echoes/scripts/tools/generate_edran_elemental_magic_art.gd")
const BOSS_ROOT: String = Art.BOSS_ROOT
const EFFECT_ROOT: String = Art.EFFECT_ROOT
const STATUS_ROOT: String = Art.SHARED_STATUS_ROOT


func _initialize() -> void:
	var total: int = 0
	for phase: int in [1, 2]:
		var output: String = "%s/animations/edran_phase_%02d_sprite_frames.tres" % [BOSS_ROOT, phase]
		var frames: SpriteFrames = load(output) as SpriteFrames
		if frames == null:
			push_error("Unable to load Edran SpriteFrames: %s" % output)
			quit(1)
			return
		for animation: StringName in Art.BOSS_MAGIC_ANIMATIONS:
			if frames.has_animation(animation):
				frames.remove_animation(animation)
			frames.add_animation(animation)
			frames.set_animation_loop(animation, false)
			frames.set_animation_speed(animation, 10.0)
			for index: int in range(Art.BOSS_MAGIC_ANIMATIONS[animation]):
				var path: String = "%s/magic_phase_%02d/%s/%s_%02d.png" % [BOSS_ROOT, phase, animation, animation, index + 1]
				var texture: Texture2D = load(path) as Texture2D
				if texture == null:
					push_error("Missing Boss magic frame: %s" % path)
					quit(1)
					return
				frames.add_frame(animation, texture)
				total += 1
		if ResourceSaver.save(frames, output) != OK:
			push_error("Unable to update Boss magic SpriteFrames: %s" % output)
			quit(1)
			return
	for relative_path: String in Art.FX_ANIMATIONS:
		var spec: Dictionary = Art.FX_ANIMATIONS[relative_path]
		var output_path: String = "%s/%s/%s_frames.tres" % [EFFECT_ROOT, relative_path, relative_path.get_file()]
		if not _save_frames(output_path, "%s/%s" % [EFFECT_ROOT, relative_path], relative_path.get_file(), int(spec.frames), true, 10.0):
			quit(1)
			return
		total += int(spec.frames)
	for effect_id: String in Art.STATUS_ANIMATIONS:
		var status_spec: Dictionary = Art.STATUS_ANIMATIONS[effect_id]
		var output_path: String = "%s/%s/%s_frames.tres" % [STATUS_ROOT, effect_id, effect_id]
		if not _save_frames(
			output_path,
			"%s/%s" % [STATUS_ROOT, effect_id],
			effect_id,
			int(status_spec.frames),
			true,
			8.0
		):
			quit(1)
			return
		total += int(status_spec.frames)
		var status_frames: SpriteFrames = load(output_path) as SpriteFrames
		var exit_spec: Dictionary = Art.STATUS_EXIT_ANIMATIONS[effect_id]
		var exit_name: StringName = StringName(exit_spec.animation as String)
		status_frames.add_animation(exit_name)
		status_frames.set_animation_loop(exit_name, false)
		status_frames.set_animation_speed(exit_name, 12.0)
		for index: int in range(int(exit_spec.frames)):
			var exit_path: String = "%s/%s/%s_%02d.png" % [STATUS_ROOT, effect_id, exit_name, index + 1]
			var exit_texture: Texture2D = load(exit_path) as Texture2D
			if exit_texture == null:
				push_error("Missing status exit frame: %s" % exit_path)
				quit(1)
				return
			status_frames.add_frame(exit_name, exit_texture)
			total += 1
		if ResourceSaver.save(status_frames, output_path) != OK:
			push_error("Unable to save status exit animation: %s" % output_path)
			quit(1)
			return
	print("EDRAN_ELEMENTAL_MAGIC_RESOURCES | PASS frames=%d" % total)
	quit(0)


func _save_frames(output: String, root: String, stem: String, count: int, loop: bool, fps: float) -> bool:
	var frames: SpriteFrames = SpriteFrames.new()
	frames.rename_animation(&"default", &"active")
	frames.set_animation_loop(&"active", loop)
	frames.set_animation_speed(&"active", fps)
	for index: int in range(count):
		var texture_path: String = "%s/%s_%02d.png" % [root, stem, index + 1]
		var texture: Texture2D = load(texture_path) as Texture2D
		if texture == null:
			push_error("Missing effect frame: %s" % texture_path)
			return false
		frames.add_frame(&"active", texture)
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(output.get_base_dir()))
	return ResourceSaver.save(frames, output) == OK
