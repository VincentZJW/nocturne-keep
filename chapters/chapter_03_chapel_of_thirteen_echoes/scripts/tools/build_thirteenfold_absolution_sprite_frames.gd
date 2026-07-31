extends SceneTree

const Builder: Script = preload("res://scripts/tools/player_sprite_frames_builder.gd")
const PLAYER_ROOT: String = (
	"res://chapters/chapter_03_chapel_of_thirteen_echoes/assets/weapons/"
	+ "thirteenfold_absolution/animations/player"
)
const RESOURCE_PATH: String = (
	"res://chapters/chapter_03_chapel_of_thirteen_echoes/resources/weapons/"
	+ "thirteenfold_absolution_player_sprite_frames.tres"
)


func _init() -> void:
	var sprite_frames: SpriteFrames = Builder.build_from_root(PLAYER_ROOT)
	if DirAccess.make_dir_recursive_absolute(
		ProjectSettings.globalize_path(RESOURCE_PATH.get_base_dir())
	) != OK:
		push_error("THIRTEENFOLD_W2_FRAMES: unable to create Resource directory")
		quit(1)
		return
	var save_error: Error = ResourceSaver.save(sprite_frames, RESOURCE_PATH)
	if save_error != OK:
		push_error("THIRTEENFOLD_W2_FRAMES: %s" % error_string(save_error))
		quit(1)
		return
	print(
		"THIRTEENFOLD_W2_FRAMES: PASS animations=%d frames=97"
		% sprite_frames.get_animation_names().size()
	)
	quit(0)
