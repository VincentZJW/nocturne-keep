extends SceneTree

const ROOT: String = "res://chapters/chapter_02_silent_court/assets/boss/hollow_duchess/phase_02_unmasked"
const OUTPUT: String = ROOT + "/hollow_duchess_unmasked_sprite_frames.tres"
const TRANSITION_ROOT: String = "res://chapters/chapter_02_silent_court/assets/boss/hollow_duchess/phase_transition"
const TRANSITION_OUTPUT: String = TRANSITION_ROOT + "/hollow_duchess_transformation_sprite_frames.tres"
const ANIMATIONS: Dictionary = {
	"idle": [4, 5.0, true], "intro": [6, 8.0, false], "elegant_walk": [6, 9.0, true],
	"turn": [4, 9.0, false], "sidestep": [4, 12.0, false], "backstep": [4, 12.0, false],
	"rapier_thrust_windup": [4, 9.0, false], "rapier_thrust_active": [2, 14.0, false],
	"rapier_thrust_recovery": [4, 8.0, false], "fan_slash_windup": [4, 8.0, false],
	"fan_slash_active": [2, 14.0, false], "fan_slash_recovery": [5, 8.0, false],
	"riposte": [8, 11.0, false], "phase_transition": [8, 7.0, false],
	"double_lunge": [8, 11.0, false], "phantom_dance": [6, 10.0, false],
	"final_waltz": [8, 12.0, false], "light_hit": [2, 12.0, false],
	"stagger": [4, 9.0, false], "death": [7, 8.0, false],
}


func _initialize() -> void:
	var frames := SpriteFrames.new()
	frames.remove_animation(&"default")
	var total: int = 0
	for animation_name: String in ANIMATIONS:
		var data: Array = ANIMATIONS[animation_name]
		var animation := StringName(animation_name)
		frames.add_animation(animation)
		frames.set_animation_speed(animation, float(data[1]))
		frames.set_animation_loop(animation, bool(data[2]))
		for index: int in range(int(data[0])):
			var path: String = "%s/%s/%s_%02d.png" % [ROOT, animation_name, animation_name, index + 1]
			var texture: Texture2D = load(path) as Texture2D
			if texture == null:
				push_error("Missing Phase 2 texture: %s" % path)
				quit(1)
				return
			frames.add_frame(animation, texture)
			total += 1
	var error: Error = ResourceSaver.save(frames, OUTPUT)
	if error != OK:
		push_error("Could not save Phase 2 SpriteFrames: %s" % error_string(error))
		quit(1)
		return
	var transition_frames := SpriteFrames.new()
	transition_frames.remove_animation(&"default")
	transition_frames.add_animation(&"phase_transition")
	transition_frames.set_animation_speed(&"phase_transition", 1.15)
	transition_frames.set_animation_loop(&"phase_transition", false)
	for stage: String in ["mask_crack", "mask_break", "body_distort", "dress_tear", "phase_2_reveal"]:
		var texture: Texture2D = load("%s/%s.png" % [TRANSITION_ROOT, stage]) as Texture2D
		if texture == null:
			push_error("Missing named transition texture: %s" % stage)
			quit(1)
			return
		transition_frames.add_frame(&"phase_transition", texture)
	var transition_error: Error = ResourceSaver.save(transition_frames, TRANSITION_OUTPUT)
	if transition_error != OK:
		push_error("Could not save transformation SpriteFrames")
		quit(1)
		return
	print("HOLLOW_DUCHESS_PHASE_2_FRAMES: PASS animations=%d frames=%d" % [ANIMATIONS.size(), total])
	quit(0)
