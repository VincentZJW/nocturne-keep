extends SceneTree

const ROOT: String = "res://chapters/chapter_02_silent_court/assets/enemies"
const ANIMATIONS: Dictionary = {
	"hollow_retainer": {"idle": 4, "walk": 6, "alert": 2, "attack_single_stab": 5, "attack_combo": 6, "hurt": 3, "death": 6},
	"court_halberdier": {"idle": 4, "walk": 6, "alert": 2, "turn": 3, "attack_thrust": 5, "attack_sweep": 6, "attack_shaft_push": 4, "hurt": 3, "death": 6},
	"mourning_armor": {"idle": 4, "walk": 6, "alert": 2, "turn": 3, "attack_overhead": 6, "attack_shoulder_bash": 5, "attack_heavy_sweep": 6, "stagger": 4, "hurt": 3, "death": 6},
	"blood_candle_acolyte": {"idle": 4, "walk": 6, "alert": 2, "attack_cast": 6, "buff_channel": 4, "hurt": 3, "death": 6},
	"hanging_stalker": {"hang": 4, "telegraph": 4, "drop": 4, "ground_recovery": 3, "claw": 5, "retreat": 4, "return_to_anchor": 4, "hurt": 3, "death": 6},
}


func _initialize() -> void:
	for enemy_name: String in ANIMATIONS:
		var frames: SpriteFrames = SpriteFrames.new()
		frames.remove_animation(&"default")
		var animation_map: Dictionary = ANIMATIONS[enemy_name] as Dictionary
		for animation_name: String in animation_map:
			var animation_id: StringName = StringName(animation_name)
			frames.add_animation(animation_id)
			frames.set_animation_speed(animation_id, _fps_for(animation_name))
			frames.set_animation_loop(animation_id, _loops(animation_name))
			var frame_count: int = int(animation_map[animation_name])
			for frame_index: int in range(frame_count):
				var path: String = "%s/%s/sprites/%s/%s_%02d.png" % [ROOT, enemy_name, animation_name, animation_name, frame_index + 1]
				var texture: Texture2D = ResourceLoader.load(path, "Texture2D") as Texture2D
				if texture == null:
					push_error("Missing imported texture %s" % path)
					quit(1)
					return
				frames.add_frame(animation_id, texture)
		var directory: String = "%s/%s/animations" % [ROOT, enemy_name]
		DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(directory))
		var output: String = "%s/%s_sprite_frames.tres" % [directory, enemy_name]
		var error: Error = ResourceSaver.save(frames, output)
		if error != OK:
			push_error("Failed to save %s: %s" % [output, error_string(error)])
			quit(1)
			return
	print("CH2_PHASE2_SPRITE_FRAMES: PASS resources=5")
	quit(0)


func _fps_for(animation_name: String) -> float:
	if animation_name == "idle" or animation_name == "hang":
		return 4.0
	if animation_name == "walk":
		return 8.0
	if animation_name == "death":
		return 9.0
	return 12.0


func _loops(animation_name: String) -> bool:
	return animation_name in ["idle", "walk", "hang"]
