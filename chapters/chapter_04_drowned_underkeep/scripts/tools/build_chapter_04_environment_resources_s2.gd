extends SceneTree

const OUTPUT_ROOT: String = "res://chapters/chapter_04_drowned_underkeep/resources/environment"


func _initialize() -> void:
	var failures: Array[String] = []
	_build_water_frames(failures)
	_build_environment_motion_frames(failures)
	if failures.is_empty():
		print("CH4 S2 ENVIRONMENT RESOURCE BUILD | PASS | resources=2")
		quit(0)
		return
	for failure: String in failures:
		push_error(failure)
	print("CH4 S2 ENVIRONMENT RESOURCE BUILD | FAIL | errors=%d" % failures.size())
	quit(1)


func _build_water_frames(failures: Array[String]) -> void:
	var frames := SpriteFrames.new()
	frames.remove_animation(&"default")
	_add_sequence(frames, &"rear_water", "res://chapters/chapter_04_drowned_underkeep/assets/fx/water/rear_water_body_%02d.png", 4, 4.0, true, failures)
	_add_sequence(frames, &"local_highlight", "res://chapters/chapter_04_drowned_underkeep/assets/fx/water/local_highlight_%02d.png", 4, 4.0, true, failures)
	_add_sequence(frames, &"front_lip", "res://chapters/chapter_04_drowned_underkeep/assets/fx/water/front_lip_%02d.png", 6, 6.0, true, failures)
	_add_sequence(frames, &"flow_strip", "res://chapters/chapter_04_drowned_underkeep/assets/fx/water/flow_strip_%02d.png", 4, 5.0, true, failures)
	_add_sequence(frames, &"drain_foam", "res://chapters/chapter_04_drowned_underkeep/assets/fx/water/drain_foam_%02d.png", 4, 5.0, true, failures)
	_add_sequence(frames, &"step_ripple", "res://chapters/chapter_04_drowned_underkeep/assets/fx/ripples/step_%02d.png", 5, 18.0, false, failures)
	_add_sequence(frames, &"landing_splash", "res://chapters/chapter_04_drowned_underkeep/assets/fx/ripples/landing_%02d.png", 5, 18.0, false, failures)
	_add_sequence(frames, &"dash_splash", "res://chapters/chapter_04_drowned_underkeep/assets/fx/ripples/dash_%02d.png", 5, 20.0, false, failures)
	_add_sequence(frames, &"enemy_wake", "res://chapters/chapter_04_drowned_underkeep/assets/fx/ripples/enemy_wake_%02d.png", 4, 12.0, false, failures)
	_add_sequence(frames, &"idle_ripple", "res://chapters/chapter_04_drowned_underkeep/assets/fx/ripples/idle_ripple_%02d.png", 4, 5.0, true, failures)
	_save_frames(frames, OUTPUT_ROOT + "/chapter_04_water_fx_frames.tres", failures)


func _build_environment_motion_frames(failures: Array[String]) -> void:
	var frames := SpriteFrames.new()
	frames.remove_animation(&"default")
	_add_sequence(frames, &"waterwheel", "res://chapters/chapter_04_drowned_underkeep/assets/environment/floodgate/gothic_waterwheel_%02d.png", 8, 8.0, true, failures)
	_add_sequence(frames, &"gear_train", "res://chapters/chapter_04_drowned_underkeep/assets/environment/floodgate/main_gear_train_%02d.png", 4, 6.0, true, failures)
	_add_sequence(frames, &"rear_chain_sway", "res://chapters/chapter_04_drowned_underkeep/assets/fx/chains/rear_chain_sway_%02d.png", 4, 4.0, true, failures)
	_add_sequence(frames, &"drip", "res://chapters/chapter_04_drowned_underkeep/assets/fx/drips/droplet_%02d.png", 4, 12.0, true, failures)
	_add_sequence(frames, &"soul_flame", "res://chapters/chapter_04_drowned_underkeep/assets/fx/soul_fire/idle_soul_flame_%02d.png", 6, 8.0, true, failures)
	_add_sequence(frames, &"cage_contained", "res://chapters/chapter_04_drowned_underkeep/assets/fx/soul_cage/contained_drift_%02d.png", 4, 5.0, true, failures)
	_add_sequence(frames, &"cage_strain", "res://chapters/chapter_04_drowned_underkeep/assets/fx/soul_cage/cage_strain_%02d.png", 4, 8.0, true, failures)
	_add_sequence(frames, &"cage_crack_leak", "res://chapters/chapter_04_drowned_underkeep/assets/fx/soul_cage/crack_leak_%02d.png", 4, 7.0, true, failures)
	_add_sequence(frames, &"cage_release", "res://chapters/chapter_04_drowned_underkeep/assets/fx/soul_cage/post_boss_release_%02d.png", 4, 8.0, false, failures)
	_add_sequence(frames, &"memory_water", "res://chapters/chapter_04_drowned_underkeep/assets/environment/memory_transition/memory_water_%02d.png", 6, 5.0, true, failures)
	_add_sequence(frames, &"boss_gate_seal", "res://chapters/chapter_04_drowned_underkeep/assets/fx/floodgate/gate_seal_%02d.png", 4, 8.0, true, failures)
	_add_sequence(frames, &"floodgate_chain_strain", "res://chapters/chapter_04_drowned_underkeep/assets/fx/floodgate/chain_strain_%02d.png", 4, 8.0, true, failures)
	_add_sequence(frames, &"floodgate_gear_dust", "res://chapters/chapter_04_drowned_underkeep/assets/fx/floodgate/gear_dust_%02d.png", 4, 10.0, false, failures)
	_add_sequence(frames, &"floodgate_lock_spark", "res://chapters/chapter_04_drowned_underkeep/assets/fx/floodgate/lock_spark_%02d.png", 4, 14.0, false, failures)
	_add_sequence(frames, &"floodgate_water_surge", "res://chapters/chapter_04_drowned_underkeep/assets/fx/floodgate/water_surge_%02d.png", 4, 10.0, false, failures)
	_save_frames(frames, OUTPUT_ROOT + "/chapter_04_environment_motion_frames.tres", failures)


func _add_sequence(
	frames: SpriteFrames,
	animation_name: StringName,
	path_pattern: String,
	frame_count: int,
	fps: float,
	looped: bool,
	failures: Array[String]
) -> void:
	frames.add_animation(animation_name)
	frames.set_animation_speed(animation_name, fps)
	frames.set_animation_loop(animation_name, looped)
	for frame_index: int in range(1, frame_count + 1):
		var path: String = path_pattern % frame_index
		var texture: Texture2D = load(path) as Texture2D
		if texture == null:
			failures.append("Missing imported texture: %s" % path)
			continue
		frames.add_frame(animation_name, texture)


func _save_frames(frames: SpriteFrames, path: String, failures: Array[String]) -> void:
	var error: Error = ResourceSaver.save(frames, path)
	if error != OK:
		failures.append("Could not save %s: error %d" % [path, error])
