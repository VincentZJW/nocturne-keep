extends SceneTree

const Builder: Script = preload("res://scripts/tools/player_sprite_frames_builder.gd")
const PLAYER_ROOT: String = (
	"res://chapters/chapter_04_drowned_underkeep/assets/weapons/"
	+ "soul_lock_twin_keys/animations/player"
)
const RESOURCE_PATH: String = (
	"res://chapters/chapter_04_drowned_underkeep/resources/weapons/"
	+ "soul_lock_twin_keys_player_sprite_frames.tres"
)


func _init() -> void:
	var sprite_frames: SpriteFrames = Builder.build_from_root(PLAYER_ROOT)
	if DirAccess.make_dir_recursive_absolute(
		ProjectSettings.globalize_path(RESOURCE_PATH.get_base_dir())
	) != OK:
		push_error("SOUL_LOCK_W2_FRAMES: unable to create Resource directory")
		quit(1)
		return
	var save_error: Error = ResourceSaver.save(sprite_frames, RESOURCE_PATH)
	if save_error != OK:
		push_error("SOUL_LOCK_W2_FRAMES: %s" % error_string(save_error))
		quit(1)
		return
	print(
		"SOUL_LOCK_W2_FRAMES: PASS animations=%d frames=97"
		% sprite_frames.get_animation_names().size()
	)
	quit(0)
