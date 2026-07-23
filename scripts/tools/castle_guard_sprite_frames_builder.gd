class_name CastleGuardSpriteFramesBuilder
extends RefCounted

## Builds the persistent Cursed Castle Guard SpriteFrames resource after PNG import.

const RESOURCE_PATH: String = "res://resources/enemies/castle_guard_sprite_frames.tres"
const ASSET_ROOT: String = "res://assets/sprites/enemies/castle_guard"
const CONFIG_PATH: String = "res://resources/enemies/castle_guard_config.tres"
const ANIMATION_ORDER: Array[StringName] = [&"idle", &"walk", &"attack", &"hurt", &"death"]
const FRAME_COUNTS: Dictionary[StringName, int] = {
	&"idle": 4,
	&"walk": 6,
	&"attack": 5,
	&"hurt": 3,
	&"death": 6,
}
const SPEEDS: Dictionary[StringName, float] = {
	&"idle": 4.0,
	&"walk": 8.0,
	&"attack": 10.0,
	&"hurt": 16.666667,
	&"death": 8.0,
}
const LOOPING: Dictionary[StringName, bool] = {
	&"idle": true,
	&"walk": true,
	&"attack": false,
	&"hurt": false,
	&"death": false,
}


static func build() -> SpriteFrames:
	var sprite_frames: SpriteFrames = SpriteFrames.new()
	var config: CastleGuardConfig = load(CONFIG_PATH) as CastleGuardConfig
	if config == null:
		push_error("CastleGuardSpriteFramesBuilder: missing CastleGuardConfig")
		return sprite_frames
	var attack_duration_ratios: Array[float] = [
		config.attack_windup * SPEEDS[&"attack"] * 0.5,
		config.attack_windup * SPEEDS[&"attack"] * 0.5,
		config.attack_active_duration * SPEEDS[&"attack"] * 0.5,
		config.attack_active_duration * SPEEDS[&"attack"] * 0.5,
		config.attack_recovery * SPEEDS[&"attack"],
	]
	sprite_frames.remove_animation(&"default")
	for animation_name: StringName in ANIMATION_ORDER:
		sprite_frames.add_animation(animation_name)
		sprite_frames.set_animation_speed(animation_name, SPEEDS[animation_name])
		sprite_frames.set_animation_loop(animation_name, LOOPING[animation_name])
		for frame_index: int in range(FRAME_COUNTS[animation_name]):
			var texture_path: String = ASSET_ROOT.path_join(str(animation_name)).path_join(
				"%s_%02d.png" % [animation_name, frame_index + 1]
			)
			var texture: Texture2D = load(texture_path) as Texture2D
			if texture == null:
				push_error("CastleGuardSpriteFramesBuilder: missing texture %s" % texture_path)
				continue
			var duration_ratio: float = (
				attack_duration_ratios[frame_index] if animation_name == &"attack" else 1.0
			)
			sprite_frames.add_frame(animation_name, texture, duration_ratio)
	return sprite_frames


static func save() -> Error:
	var directory_error: Error = DirAccess.make_dir_recursive_absolute(
		ProjectSettings.globalize_path(RESOURCE_PATH.get_base_dir())
	)
	if directory_error != OK:
		return directory_error
	return ResourceSaver.save(build(), RESOURCE_PATH)
