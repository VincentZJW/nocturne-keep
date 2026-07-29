extends SceneTree

const Art: GDScript = preload("res://chapters/chapter_02_silent_court/scripts/tools/generate_hollow_duchess_art_v2.gd")
const PHASE_1_OUTPUT: String = Art.PHASE_1_ROOT + "/hollow_duchess_phase_01_sprite_frames.tres"
const PHASE_2_OUTPUT: String = Art.PHASE_2_ROOT + "/hollow_duchess_unmasked_sprite_frames.tres"
const TRANSITION_OUTPUT: String = Art.TRANSITION_ROOT + "/hollow_duchess_transformation_sprite_frames.tres"


func _initialize() -> void:
	var phase_1_frames: int = _build_set(Art.PHASE_1_ROOT, Art.PHASE_1_ANIMATIONS, PHASE_1_OUTPUT)
	var phase_2_frames: int = _build_set(Art.PHASE_2_ROOT, Art.PHASE_2_ANIMATIONS, PHASE_2_OUTPUT)
	var transition_animations: Dictionary = Art.TRANSITION_ANIMATIONS.duplicate()
	transition_animations[&"phase_transition"] = 10
	var transition_frames: int = _build_set(Art.TRANSITION_ROOT, transition_animations, TRANSITION_OUTPUT)
	if phase_1_frames <= 0 or phase_2_frames <= 0 or transition_frames <= 0:
		quit(1)
		return
	print("HOLLOW_DUCHESS_SPRITEFRAMES_V2: PASS phase1=%d phase2=%d transition=%d total=%d" % [phase_1_frames, phase_2_frames, transition_frames, phase_1_frames + phase_2_frames + transition_frames])
	quit(0)


func _build_set(root: String, animations: Dictionary, output: String) -> int:
	var sprite_frames: SpriteFrames = SpriteFrames.new()
	if sprite_frames.has_animation(&"default"):
		sprite_frames.remove_animation(&"default")
	var total: int = 0
	for animation_variant: Variant in animations.keys():
		var animation: StringName = animation_variant as StringName
		var count: int = int(animations[animation])
		sprite_frames.add_animation(animation)
		sprite_frames.set_animation_speed(animation, _animation_fps(animation))
		sprite_frames.set_animation_loop(animation, _animation_loops(animation))
		for frame: int in range(count):
			var path: String = "%s/%s/%s_%02d.png" % [root, animation, animation, frame + 1]
			var texture: Texture2D = load(path) as Texture2D
			if texture == null:
				push_error("Missing Duchess frame: %s" % path)
				return -1
			sprite_frames.add_frame(animation, texture)
			total += 1
	var error: Error = ResourceSaver.save(sprite_frames, output)
	if error != OK:
		push_error("Cannot save Duchess SpriteFrames: %s (%d)" % [output, error])
		return -1
	return total


func _animation_fps(animation: StringName) -> float:
	if animation in [&"idle", &"dormant", &"phase_02_idle"]:
		return 5.0
	if animation in [&"elegant_walk", &"elegant_approach", &"elegant_retreat", &"phase_02_walk"]:
		return 9.0
	if animation in [&"phase_transition", &"freeze_pose", &"candles_out", &"mask_crack", &"mask_break", &"head_distort", &"arms_lengthen", &"dress_tear", &"spine_or_back_expand", &"weapon_transform", &"phase_02_reveal"]:
		return 2.3 if animation == &"phase_transition" else 8.0
	if animation in [&"rapier_thrust_active", &"fan_slash_active", &"phase_02_rapier_thrust", &"phase_02_fan_slash", &"double_lunge", &"double_waltz_lunge", &"final_waltz", &"final_waltz_crossing"]:
		return 12.0
	if animation in [&"death", &"death_start", &"death_mask_shatter", &"death_collapse", &"death_dissolve"]:
		return 7.0
	return 10.0


func _animation_loops(animation: StringName) -> bool:
	return animation in [&"idle", &"dormant", &"elegant_walk", &"phase_02_idle", &"phase_02_walk"]
