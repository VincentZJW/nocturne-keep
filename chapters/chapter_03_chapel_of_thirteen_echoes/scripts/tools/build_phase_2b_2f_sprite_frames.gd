extends SceneTree

const ROOT: String = "res://chapters/chapter_03_chapel_of_thirteen_echoes/assets/enemies"
const ROLES: Array[String] = [
	"censer_executioner", "silent_chorister", "stained_glass_seraph",
	"confessional_wraith", "thirteenth_scribe",
]


func _initialize() -> void:
	var total: int = 0
	for role: String in ROLES:
		var frames: SpriteFrames = SpriteFrames.new()
		frames.remove_animation(&"default")
		var animations: Dictionary = _animations(role)
		for animation: String in animations:
			var count: int = int(animations[animation])
			var animation_name: StringName = StringName(animation)
			frames.add_animation(animation_name)
			frames.set_animation_loop(animation_name, animation in ["idle", "walk", "hidden"])
			frames.set_animation_speed(animation_name, _fps(animation))
			for index: int in range(count):
				var path: String = "%s/%s/sprites/%s/%s_%02d.png" % [ROOT, role, animation, animation, index + 1]
				var texture: Texture2D = load(path) as Texture2D
				if texture == null:
					push_error("Missing imported frame %s" % path)
					quit(1)
					return
				frames.add_frame(animation_name, texture)
				total += 1
		var output: String = "%s/%s/animations/%s_sprite_frames.tres" % [ROOT, role, role]
		DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(output.get_base_dir()))
		if ResourceSaver.save(frames, output) != OK:
			push_error("Unable to save %s" % output)
			quit(1)
			return
	print("CH3 PHASE2B-2F SPRITEFRAMES | PASS roles=5 frames=%d" % total)
	quit(0)


func _animations(role: String) -> Dictionary:
	var result: Dictionary = {"idle": 4, "walk": 6, "alert": 3, "turn": 3, "light_hit": 2, "stagger": 4, "hurt": 3, "death": 6}
	var actions: Array[String] = []
	match role:
		"censer_executioner": actions = ["primary", "overhead_crush", "smoke_release"]
		"silent_chorister": actions = ["silent_wave", "crescent_hymn", "hush_field"]
		"stained_glass_seraph": actions = ["shard_volley", "dive", "shatter_burst"]
		"confessional_wraith":
			actions = ["emerging_slash", "spectral_dash", "confession_scream"]
			result["hidden"] = 4
		"thirteenth_scribe": actions = ["ink_lance", "binding_script", "thirteenth_seal"]
	for action: String in actions:
		result["%s_windup" % action] = 5 if action != "overhead_crush" else 7
		result["%s_active" % action] = 2 if action != "hush_field" else 4
		result["%s_recovery" % action] = 5 if action != "overhead_crush" else 7
	return result


func _fps(animation: String) -> float:
	if animation == "idle" or animation == "hidden": return 4.0
	if animation == "walk": return 7.0
	if animation == "death": return 8.0
	if animation.contains("active"): return 15.0
	if animation.contains("windup"): return 8.0
	if animation.contains("recovery"): return 8.0
	return 10.0
