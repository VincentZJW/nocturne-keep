class_name PlayerSpriteFramesBuilder
extends RefCounted

## Builds the persistent SpriteFrames resource used by the player visual module.

const RESOURCE_PATH: String = "res://resources/player/player_sprite_frames.tres"
const PRODUCTION_ROOT: String = "res://shared/assets/player/animations/veilbound"
const PLACEHOLDER_ROOT: String = "res://assets/sprites/player/assassin/placeholder"

const ANIMATION_ORDER: Array[StringName] = [
	&"idle", &"ready_idle", &"walk", &"run", &"turn", &"start_move", &"stop_move",
	&"jump_start", &"jump_rise", &"jump_loop", &"jump_apex", &"fall", &"double_jump",
	&"land", &"dash_start", &"dash_loop", &"dash_end", &"air_dash_start",
	&"air_dash_loop", &"air_dash_end", &"attack", &"attack_1", &"attack_2", &"attack_3",
	&"combo_transition", &"dash_attack", &"hurt", &"hurt_light", &"hurt_heavy", &"death",
]
const FRAME_COUNTS: Dictionary[StringName, int] = {
	&"idle": 4, &"ready_idle": 4, &"walk": 6, &"run": 6, &"turn": 3,
	&"start_move": 3, &"stop_move": 3,
	&"jump_start": 2, &"jump_rise": 2, &"jump_loop": 2, &"jump_apex": 2,
	&"fall": 2, &"double_jump": 4,
	&"land": 2, &"dash_start": 2, &"dash_loop": 3, &"dash_end": 2,
	&"air_dash_start": 2, &"air_dash_loop": 3, &"air_dash_end": 2, &"attack": 4,
	&"attack_1": 4, &"attack_2": 4, &"attack_3": 4, &"combo_transition": 2,
	&"dash_attack": 5, &"hurt": 3, &"hurt_light": 3, &"hurt_heavy": 4, &"death": 5,
}
const SPEEDS: Dictionary[StringName, float] = {
	&"idle": 5.0, &"ready_idle": 5.0, &"walk": 7.0, &"run": 10.0,
	&"turn": 12.0, &"start_move": 12.0, &"stop_move": 12.0,
	&"jump_start": 12.0, &"jump_rise": 4.0, &"jump_loop": 4.0,
	&"jump_apex": 6.0, &"fall": 4.0, &"double_jump": 16.0,
	&"land": 12.0, &"dash_start": 20.0, &"dash_loop": 20.0,
	&"dash_end": 20.0, &"air_dash_start": 20.0, &"air_dash_loop": 20.0,
	&"air_dash_end": 20.0,
	&"attack": 20.0, &"attack_1": 20.0, &"attack_2": 20.0, &"attack_3": 20.0,
	&"combo_transition": 20.0, &"dash_attack": 20.0,
	&"hurt": 16.0, &"hurt_light": 16.0, &"hurt_heavy": 12.0, &"death": 11.111111,
}
const LOOPING: Dictionary[StringName, bool] = {
	&"idle": true, &"ready_idle": true, &"walk": true, &"run": true,
	&"turn": false, &"start_move": false, &"stop_move": false,
	&"jump_start": false, &"jump_rise": true, &"jump_loop": true,
	&"jump_apex": true, &"fall": true, &"double_jump": false,
	&"land": false, &"dash_start": false, &"dash_loop": true,
	&"dash_end": false, &"air_dash_start": false, &"air_dash_loop": true,
	&"air_dash_end": false,
	&"attack": false, &"attack_1": false, &"attack_2": false, &"attack_3": false,
	&"combo_transition": false, &"dash_attack": false,
	&"hurt": false, &"hurt_light": false, &"hurt_heavy": false, &"death": false,
}
const PRODUCTION_ANIMATIONS: Array[StringName] = [
	&"idle", &"ready_idle", &"walk", &"run", &"turn", &"start_move", &"stop_move",
	&"dash_start", &"dash_loop", &"dash_end", &"air_dash_start",
	&"air_dash_loop", &"air_dash_end",
	&"attack", &"attack_1", &"attack_2", &"attack_3", &"combo_transition",
	&"dash_attack", &"hurt", &"hurt_light", &"hurt_heavy",
	&"death",
]
const M1_PRODUCTION_ANIMATIONS: Array[StringName] = [
	&"jump_start", &"jump_rise", &"jump_loop", &"jump_apex", &"fall", &"double_jump", &"land",
]


static func build() -> SpriteFrames:
	return build_from_root(PRODUCTION_ROOT)


static func build_from_root(root: String) -> SpriteFrames:
	var sprite_frames: SpriteFrames = SpriteFrames.new()
	sprite_frames.remove_animation(&"default")
	for animation_name: StringName in ANIMATION_ORDER:
		sprite_frames.add_animation(animation_name)
		sprite_frames.set_animation_speed(animation_name, SPEEDS[animation_name])
		sprite_frames.set_animation_loop(animation_name, LOOPING[animation_name])
		for frame_index: int in range(FRAME_COUNTS[animation_name]):
			var path: String = frame_path_from_root(root, animation_name, frame_index)
			var texture: Texture2D = load(path) as Texture2D
			if texture == null:
				push_error("PlayerSpriteFramesBuilder: missing imported texture %s" % path)
				continue
			sprite_frames.add_frame(animation_name, texture)
	return sprite_frames


static func save() -> Error:
	var directory_error: Error = DirAccess.make_dir_recursive_absolute(
		ProjectSettings.globalize_path(RESOURCE_PATH.get_base_dir())
	)
	if directory_error != OK:
		return directory_error
	return ResourceSaver.save(build(), RESOURCE_PATH)


static func frame_path(animation_name: StringName, frame_index: int) -> String:
	return frame_path_from_root(PRODUCTION_ROOT, animation_name, frame_index)


static func frame_path_from_root(
		root: String, animation_name: StringName, frame_index: int
	) -> String:
	var one_based_index: int = frame_index + 1
	if animation_name in PRODUCTION_ANIMATIONS or animation_name in M1_PRODUCTION_ANIMATIONS:
		return root.path_join(str(animation_name)).path_join(
			"%s_%02d.png" % [animation_name, one_based_index]
		)
	return PLACEHOLDER_ROOT.path_join(
		"placeholder_%s_%02d.png" % [animation_name, one_based_index]
	)


static func is_placeholder(animation_name: StringName) -> bool:
	return animation_name not in PRODUCTION_ANIMATIONS and animation_name not in M1_PRODUCTION_ANIMATIONS
