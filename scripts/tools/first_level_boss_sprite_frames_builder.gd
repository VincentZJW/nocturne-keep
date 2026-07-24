extends SceneTree

## Builds persistent SpriteFrames resources after deterministic PNG import.

const ROOT: String = "res://assets/sprites"
const OUTPUT: String = "res://resources"
const GARGOYLE: Dictionary[String, Array] = {
	"dormant": [4, 3.0, true], "wake": [4, 8.0, false], "hover": [4, 6.0, true],
	"dive_windup": [4, 8.888889, false], "dive": [4, 16.0, true],
	"ground_stun": [4, 6.153846, true], "return_to_air": [4, 8.0, true],
	"hurt": [3, 16.666667, false], "death_fall": [5, 10.0, false],
	"death_shatter": [5, 10.0, false],
}
const BOSS: Dictionary[String, Array] = {
	"idle_shielded": [4, 4.0, true], "walk_shielded": [6, 7.0, true],
	"turn_shielded": [3, 23.076923, false],
	"shield_block": [4, 8.0, false], "shield_bash": [5, 9.8, false],
	"sword_slash": [5, 9.8, false], "heavy_overhead": [6, 8.8, false],
	"hurt_shielded": [3, 12.0, false], "shield_break": [5, 5.555556, false],
	"phase_transition": [5, 4.545455, false], "idle_unshielded": [4, 5.0, true],
	"walk_unshielded": [6, 8.0, true], "turn_unshielded": [3, 23.076923, false],
	"combo_slash_1": [5, 12.0, false],
	"combo_slash_2": [5, 12.0, false], "jump_smash": [6, 9.8, false],
	"charge_thrust": [5, 11.0, false], "shockwave_strike": [6, 8.8, false],
	"hurt_unshielded": [3, 14.0, false], "death": [7, 7.0, false],
}
const BOSS_SHIELD_DAMAGE: Dictionary[String, Array] = {
	"intact": [1, 1.0, true], "damaged": [1, 1.0, true],
	"critical": [1, 1.0, true], "broken": [1, 1.0, true],
}


func _initialize() -> void:
	var failures: int = 0
	failures += _save_set(
		"enemies/gargoyle_sentinel", GARGOYLE,
		"enemies/gargoyle_sentinel_sprite_frames.tres"
	)
	failures += _save_set(
		"bosses/fallen_gate_knight", BOSS,
		"bosses/fallen_gate_knight_sprite_frames.tres"
	)
	failures += _save_set(
		"bosses/fallen_gate_knight/shield_damage", BOSS_SHIELD_DAMAGE,
		"bosses/fallen_gate_knight_shield_damage_sprite_frames.tres"
	)
	print("FIRST_LEVEL_BOSS_SPRITE_FRAMES_BUILD: %s" % ("OK" if failures == 0 else "FAIL"))
	quit(0 if failures == 0 else 1)


func _save_set(asset_root: String, definitions: Dictionary[String, Array], output_path: String) -> int:
	var frames: SpriteFrames = SpriteFrames.new()
	frames.remove_animation(&"default")
	for animation_key: String in definitions:
		var metadata: Array = definitions[animation_key]
		var animation_name: StringName = StringName(animation_key)
		var count: int = metadata[0] as int
		frames.add_animation(animation_name)
		frames.set_animation_speed(animation_name, metadata[1] as float)
		frames.set_animation_loop(animation_name, metadata[2] as bool)
		for frame: int in range(count):
			var texture_path: String = ROOT.path_join(asset_root).path_join(animation_key).path_join(
				"%s_%02d.png" % [animation_key, frame + 1]
			)
			var texture: Texture2D = load(texture_path) as Texture2D
			if texture == null:
				push_error("Missing imported frame %s" % texture_path)
				continue
			frames.add_frame(animation_name, texture)
	var full_output: String = OUTPUT.path_join(output_path)
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(full_output.get_base_dir()))
	return 0 if ResourceSaver.save(frames, full_output) == OK else 1
