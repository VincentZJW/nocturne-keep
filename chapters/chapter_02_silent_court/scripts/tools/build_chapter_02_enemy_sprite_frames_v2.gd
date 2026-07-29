extends SceneTree

const ART_SOURCE = preload("res://chapters/chapter_02_silent_court/scripts/tools/generate_chapter_02_enemy_art_v2.gd")
const ROOT: String = "res://chapters/chapter_02_silent_court/assets/enemies"


func _initialize() -> void:
	var total: int = 0
	for role: String in ART_SOURCE.ROLES:
		var sprite_frames: SpriteFrames = SpriteFrames.new()
		sprite_frames.remove_animation(&"default")
		var definitions: Dictionary = ART_SOURCE.ANIMATIONS[role] as Dictionary
		for animation: String in definitions:
			var name: StringName = StringName(animation)
			var count: int = int(definitions[animation])
			sprite_frames.add_animation(name)
			sprite_frames.set_animation_loop(name, _loops(animation))
			sprite_frames.set_animation_speed(name, _fps(animation))
			for index: int in range(count):
				var path: String = "%s/%s/sprites/%s/%s_%02d.png" % [ROOT, role, animation, animation, index + 1]
				var texture: Texture2D = load(path) as Texture2D
				if texture == null:
					push_error("Missing imported Chapter II frame: %s" % path)
					quit(1)
					return
				sprite_frames.add_frame(name, texture)
				total += 1
		var output: String = "%s/%s/animations/%s_sprite_frames.tres" % [ROOT, role, role]
		if ResourceSaver.save(sprite_frames, output) != OK:
			push_error("Unable to save Chapter II SpriteFrames: %s" % output)
			quit(1)
			return
	print("CH2 ENEMY SPRITEFRAMES V2 | PASS roles=%d frames=%d" % [ART_SOURCE.ROLES.size(), total])
	quit(0)


func _loops(animation: String) -> bool:
	return animation in [
		"idle", "bow_or_service_idle", "patrol", "walk", "approach", "retreat",
		"idle_guard", "dormant", "heavy_walk", "prayer_idle", "walk_or_reposition",
		"ally_buff_loop", "ceiling_hidden", "ceiling_idle", "ceiling_track", "hang",
		"short_chase",
	]


func _fps(animation: String) -> float:
	if animation in ["idle", "bow_or_service_idle", "idle_guard", "dormant", "prayer_idle", "ceiling_hidden", "ceiling_idle", "hang"]:
		return 4.0
	if animation in ["patrol", "walk", "approach", "retreat", "heavy_walk", "walk_or_reposition", "short_chase"]:
		return 7.0
	if animation.contains("windup"):
		return 8.0
	if animation.contains("active") or animation in ["combo_hit_01", "combo_hit_02", "shaft_push", "shoulder_charge", "armor_sweep", "ember_cast", "emerging_claw", "drop_attack"]:
		return 14.0
	if animation.contains("recovery"):
		return 8.0
	if animation.contains("death") or animation in ["hollow_armor_break", "candle_extinguish"]:
		return 8.0
	return 10.0
