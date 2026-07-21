class_name PlayerSpriteFramesBuilder
extends RefCounted

## Builds the persistent SpriteFrames resource used by the player visual module.

const RESOURCE_PATH: String = "res://resources/player/player_sprite_frames.tres"
const PRODUCTION_ROOT: String = "res://assets/sprites/player/assassin"
const PLACEHOLDER_ROOT: String = "res://assets/sprites/player/assassin/placeholder"

const ANIMATION_ORDER: Array[StringName] = [
	&"idle", &"run", &"jump_start", &"jump_loop", &"fall",
	&"land", &"dash", &"attack", &"hurt", &"death",
]
const FRAME_COUNTS: Dictionary[StringName, int] = {
	&"idle": 4, &"run": 6, &"jump_start": 2, &"jump_loop": 2, &"fall": 2,
	&"land": 2, &"dash": 5, &"attack": 6, &"hurt": 3, &"death": 8,
}
const SPEEDS: Dictionary[StringName, float] = {
	&"idle": 5.0, &"run": 10.0, &"jump_start": 12.0, &"jump_loop": 4.0,
	&"fall": 4.0, &"land": 12.0, &"dash": 20.0, &"attack": 12.0,
	&"hurt": 12.0, &"death": 8.0,
}
const LOOPING: Dictionary[StringName, bool] = {
	&"idle": true, &"run": true, &"jump_start": false, &"jump_loop": true,
	&"fall": true, &"land": false, &"dash": false, &"attack": false,
	&"hurt": false, &"death": false,
}
const PRODUCTION_ANIMATIONS: Array[StringName] = [&"idle", &"run", &"dash", &"attack"]
const M1_PRODUCTION_ANIMATIONS: Array[StringName] = [&"jump_start", &"jump_loop", &"fall", &"land"]


static func build() -> SpriteFrames:
	var sprite_frames: SpriteFrames = SpriteFrames.new()
	sprite_frames.remove_animation(&"default")
	for animation_name: StringName in ANIMATION_ORDER:
		sprite_frames.add_animation(animation_name)
		sprite_frames.set_animation_speed(animation_name, SPEEDS[animation_name])
		sprite_frames.set_animation_loop(animation_name, LOOPING[animation_name])
		for frame_index: int in range(FRAME_COUNTS[animation_name]):
			var path: String = frame_path(animation_name, frame_index)
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
	var one_based_index: int = frame_index + 1
	if animation_name in PRODUCTION_ANIMATIONS or animation_name in M1_PRODUCTION_ANIMATIONS:
		return PRODUCTION_ROOT.path_join(str(animation_name)).path_join(
			"%s_%02d.png" % [animation_name, one_based_index]
		)
	return PLACEHOLDER_ROOT.path_join(
		"placeholder_%s_%02d.png" % [animation_name, one_based_index]
	)


static func is_placeholder(animation_name: StringName) -> bool:
	return animation_name not in PRODUCTION_ANIMATIONS and animation_name not in M1_PRODUCTION_ANIMATIONS
