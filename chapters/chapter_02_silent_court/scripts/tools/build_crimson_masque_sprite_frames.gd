extends SceneTree

const Builder: Script = preload("res://scripts/tools/player_sprite_frames_builder.gd")
const OUTPUT_ROOT: String = (
	"res://shared/assets/player/animations/crimson_masque"
)
const RESOURCE_PATH: String = (
	"res://chapters/chapter_02_silent_court/resources/weapons/crimson_masque_player_sprite_frames.tres"
)


func _init() -> void:
	var sprite_frames: SpriteFrames = Builder.build_from_root(OUTPUT_ROOT)
	var directory_error: Error = DirAccess.make_dir_recursive_absolute(
		ProjectSettings.globalize_path(RESOURCE_PATH.get_base_dir())
	)
	if directory_error != OK:
		push_error("Unable to create Crimson Masque resource directory")
		quit(1)
		return
	var error: Error = ResourceSaver.save(sprite_frames, RESOURCE_PATH)
	if error != OK:
		push_error("Unable to save Crimson Masque SpriteFrames: %s" % error_string(error))
		quit(1)
		return
	print("CRIMSON_MASQUE_SPRITE_FRAMES: PASS animations=%d" % sprite_frames.get_animation_names().size())
	quit(0)
