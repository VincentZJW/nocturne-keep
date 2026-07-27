extends SceneTree

## Builds and saves three persistent SpriteFrames resources after PNG import.

const ASSET_ROOTS: Dictionary[String, String] = {
	"cursed_shield_guard": "res://shared/assets/enemies/cursed_shield_guard",
	"decayed_spearman": "res://chapters/chapter_01_ravenmourn_outskirts/assets/enemies/decayed_spearman",
	"fallen_crossbowman": "res://shared/assets/enemies/fallen_crossbowman",
}
const FRAME_OUTPUT_PATHS: Dictionary[String, String] = {
	"cursed_shield_guard": "res://shared/resources/enemies/cursed_shield_guard_sprite_frames.tres",
	"decayed_spearman": "res://chapters/chapter_01_ravenmourn_outskirts/resources/enemies/decayed_spearman_sprite_frames.tres",
	"fallen_crossbowman": "res://shared/resources/enemies/fallen_crossbowman_sprite_frames.tres",
}
const SHIELD_RESOURCE_ROOT: String = "res://shared/resources/enemies"

const DEFINITIONS: Dictionary[String, Dictionary] = {
	"cursed_shield_guard": {
		"idle": [4, 4.0, true], "walk": [6, 7.0, true], "block": [3, 12.0, false],
		"attack": [5, 10.0, false], "guard_break": [4, 10.0, false],
		"hurt": [3, 16.666667, false], "death": [6, 8.0, false],
		"idle_unshielded": [4, 4.0, true], "walk_unshielded": [6, 7.0, true],
		"attack_unshielded": [5, 10.0, false],
		"hurt_unshielded": [3, 16.666667, false], "death_unshielded": [6, 8.0, false],
	},
	"decayed_spearman": {
		"idle": [4, 4.0, true], "walk": [6, 8.0, true],
		"attack_thrust": [6, 10.0, false], "hurt": [3, 16.666667, false],
		"death": [6, 8.0, false],
	},
	"fallen_crossbowman": {
		"idle": [4, 4.0, true], "walk": [6, 8.0, true], "aim": [4, 6.0, true],
		"shoot": [3, 12.0, false], "reload": [4, 4.0, false],
		"hurt": [3, 16.666667, false], "death": [6, 8.0, false],
	},
}


func _initialize() -> void:
	var failures: int = 0
	for enemy_name: String in DEFINITIONS:
		var frames: SpriteFrames = _build_enemy(enemy_name, DEFINITIONS[enemy_name])
		var output_path: String = FRAME_OUTPUT_PATHS[enemy_name]
		var error: Error = ResourceSaver.save(frames, output_path)
		if error != OK:
			push_error("Cannot save %s" % output_path)
			failures += 1
	var effect_error: Error = ResourceSaver.save(
		_build_shield_break_effect(),
		SHIELD_RESOURCE_ROOT.path_join("cursed_shield_guard_shield_break_fx_sprite_frames.tres")
	)
	if effect_error != OK:
		push_error("Cannot save Shield Guard break effect SpriteFrames")
		failures += 1
	var shield_visual_error: Error = ResourceSaver.save(
		_build_shield_visual(),
		SHIELD_RESOURCE_ROOT.path_join("cursed_shield_guard_shield_sprite_frames.tres")
	)
	if shield_visual_error != OK:
		push_error("Cannot save Shield Guard ShieldVisual SpriteFrames")
		failures += 1
	var shield_hit_error: Error = ResourceSaver.save(
		_build_shield_hit_effect(),
		SHIELD_RESOURCE_ROOT.path_join("cursed_shield_guard_shield_hit_fx_sprite_frames.tres")
	)
	if shield_hit_error != OK:
		push_error("Cannot save Shield Guard hit effect SpriteFrames")
		failures += 1
	print("ENEMY_VARIETY_SPRITE_FRAMES_BUILD: %s" % ("OK" if failures == 0 else "FAIL"))
	quit(0 if failures == 0 else 1)


func _build_enemy(enemy_name: String, animations: Dictionary) -> SpriteFrames:
	var frames: SpriteFrames = SpriteFrames.new()
	frames.remove_animation(&"default")
	for animation_key: String in animations:
		var metadata: Array = animations[animation_key] as Array
		var count: int = metadata[0] as int
		var speed: float = metadata[1] as float
		var looping: bool = metadata[2] as bool
		var animation_name: StringName = StringName(animation_key)
		frames.add_animation(animation_name)
		frames.set_animation_speed(animation_name, speed)
		frames.set_animation_loop(animation_name, looping)
		for frame_index: int in range(count):
			var texture_path: String = ASSET_ROOTS[enemy_name].path_join(animation_key).path_join(
				"%s_%02d.png" % [animation_key, frame_index + 1]
			)
			var texture: Texture2D = load(texture_path) as Texture2D
			if texture == null:
				push_error("Missing imported enemy texture %s" % texture_path)
				continue
			frames.add_frame(animation_name, texture, _duration_ratio(enemy_name, animation_key, frame_index, speed))
	return frames


func _build_shield_break_effect() -> SpriteFrames:
	var frames: SpriteFrames = SpriteFrames.new()
	frames.rename_animation(&"default", &"shield_break")
	# Four equal frames span the complete configured GuardBreak readability window.
	var config: CursedShieldGuardConfig = load(
		"res://shared/resources/enemies/cursed_shield_guard_config.tres"
	) as CursedShieldGuardConfig
	frames.set_animation_speed(&"shield_break", 4.0 / config.guard_break_duration)
	frames.set_animation_loop(&"shield_break", false)
	for frame_index: int in range(4):
		var texture_path: String = ASSET_ROOTS["cursed_shield_guard"].path_join(
			"shield_break_fx"
		).path_join("shield_break_fx_%02d.png" % (frame_index + 1))
		var texture: Texture2D = load(texture_path) as Texture2D
		if texture == null:
			push_error("Missing imported Shield Guard break effect %s" % texture_path)
			continue
		frames.add_frame(&"shield_break", texture)
	return frames


func _build_shield_visual() -> SpriteFrames:
	var frames: SpriteFrames = SpriteFrames.new()
	frames.remove_animation(&"default")
	for state_name: String in ["intact", "cracked", "critical"]:
		var animation_name: StringName = StringName(state_name)
		frames.add_animation(animation_name)
		frames.set_animation_speed(animation_name, 1.0)
		frames.set_animation_loop(animation_name, true)
		var texture_path: String = ASSET_ROOTS["cursed_shield_guard"].path_join(
			"shield_visual"
		).path_join("%s.png" % state_name)
		var texture: Texture2D = load(texture_path) as Texture2D
		if texture == null:
			push_error("Missing ShieldVisual texture %s" % texture_path)
			continue
		frames.add_frame(animation_name, texture)
	frames.add_animation(&"shield_break")
	frames.set_animation_speed(&"shield_break", 8.0)
	frames.set_animation_loop(&"shield_break", false)
	for frame_index: int in range(4):
		var break_path: String = ASSET_ROOTS["cursed_shield_guard"].path_join(
			"shield_visual"
		).path_join("shield_break_%02d.png" % (frame_index + 1))
		var break_texture: Texture2D = load(break_path) as Texture2D
		if break_texture == null:
			push_error("Missing ShieldVisual break texture %s" % break_path)
			continue
		frames.add_frame(&"shield_break", break_texture)
	return frames


func _build_shield_hit_effect() -> SpriteFrames:
	var frames: SpriteFrames = SpriteFrames.new()
	frames.rename_animation(&"default", &"shield_hit")
	frames.set_animation_speed(&"shield_hit", 18.0)
	frames.set_animation_loop(&"shield_hit", false)
	for frame_index: int in range(3):
		var texture_path: String = ASSET_ROOTS["cursed_shield_guard"].path_join(
			"shield_hit_fx"
		).path_join("shield_hit_fx_%02d.png" % (frame_index + 1))
		var texture: Texture2D = load(texture_path) as Texture2D
		if texture == null:
			push_error("Missing Shield hit texture %s" % texture_path)
			continue
		frames.add_frame(&"shield_hit", texture)
	return frames


func _duration_ratio(enemy_name: String, animation_name: String, frame: int, speed: float) -> float:
	if (
		enemy_name == "cursed_shield_guard"
		and (animation_name == "attack" or animation_name == "attack_unshielded")
	):
		var config: CursedShieldGuardConfig = load(
			"res://shared/resources/enemies/cursed_shield_guard_config.tres"
		) as CursedShieldGuardConfig
		return [
			config.attack_windup * speed * 0.5,
			config.attack_windup * speed * 0.5,
			config.attack_active_duration * speed * 0.5,
			config.attack_active_duration * speed * 0.5,
			config.attack_recovery * speed,
		][frame]
	if enemy_name == "cursed_shield_guard" and animation_name == "guard_break":
		var shield_config: CursedShieldGuardConfig = load(
			"res://shared/resources/enemies/cursed_shield_guard_config.tres"
		) as CursedShieldGuardConfig
		var frame_seconds: Array[float] = [0.10, 0.10, 0.20, shield_config.guard_break_duration - 0.40]
		return frame_seconds[frame] * speed
	if enemy_name == "decayed_spearman" and animation_name == "attack_thrust":
		var config: DecayedSpearmanConfig = load(
			"res://chapters/chapter_01_ravenmourn_outskirts/resources/enemies/decayed_spearman_config.tres"
		) as DecayedSpearmanConfig
		return [
			config.attack_windup * speed / 3.0,
			config.attack_windup * speed / 3.0,
			config.attack_windup * speed / 3.0,
			config.attack_active_duration * speed * 0.5,
			config.attack_active_duration * speed * 0.5,
			config.attack_recovery * speed,
		][frame]
	if enemy_name == "fallen_crossbowman" and animation_name == "reload":
		var config: FallenCrossbowmanConfig = load(
			"res://shared/resources/enemies/fallen_crossbowman_config.tres"
		) as FallenCrossbowmanConfig
		return config.reload_duration * speed / 4.0
	return 1.0
