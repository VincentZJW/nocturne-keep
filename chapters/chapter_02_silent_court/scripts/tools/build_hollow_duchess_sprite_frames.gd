extends SceneTree

const ROOT: String = "res://chapters/chapter_02_silent_court/assets/boss/hollow_duchess"
const ANIMATIONS: Dictionary = {
	"idle": 4, "intro": 6, "elegant_walk": 6, "turn": 4, "sidestep": 4, "backstep": 4,
	"rapier_thrust_windup": 4, "rapier_thrust_active": 2, "rapier_thrust_recovery": 4,
	"fan_slash_windup": 4, "fan_slash_active": 2, "fan_slash_recovery": 5,
	"riposte": 8, "phase_transition": 8, "double_lunge": 8, "phantom_dance": 6,
	"final_waltz": 8, "light_hit": 2, "stagger": 4, "death": 7,
}


func _initialize() -> void:
	var frames: SpriteFrames = SpriteFrames.new()
	frames.remove_animation(&"default")
	for animation_name: String in ANIMATIONS:
		var animation: StringName = StringName(animation_name)
		frames.add_animation(animation)
		frames.set_animation_speed(animation, _fps(animation_name))
		frames.set_animation_loop(animation, animation_name in ["idle", "elegant_walk"])
		for index: int in range(int(ANIMATIONS[animation_name])):
			var path: String = "%s/sprites/%s/%s_%02d.png" % [ROOT, animation_name, animation_name, index + 1]
			var texture: Texture2D = ResourceLoader.load(path, "Texture2D") as Texture2D
			if texture == null:
				push_error("Missing imported Duchess frame %s" % path)
				quit(1)
				return
			frames.add_frame(animation, texture)
	var directory: String = "%s/animations" % ROOT
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(directory))
	var output: String = "%s/hollow_duchess_sprite_frames.tres" % directory
	var error: Error = ResourceSaver.save(frames, output)
	if error != OK:
		push_error("Failed to save %s: %s" % [output, error_string(error)])
		quit(1)
		return
	print("HOLLOW_DUCHESS_SPRITE_FRAMES: PASS animations=%d" % ANIMATIONS.size())
	quit(0)


func _fps(animation_name: String) -> float:
	match animation_name:
		"idle": return 5.0
		"elegant_walk": return 8.0
		"turn": return 8.0
		"phase_transition": return 7.0
		"death": return 6.0
		"rapier_thrust_windup": return 8.7
		"rapier_thrust_active": return 18.0
		"rapier_thrust_recovery": return 6.7
		"fan_slash_windup": return 7.4
		"fan_slash_active": return 14.3
		"fan_slash_recovery": return 6.9
	return 12.0
