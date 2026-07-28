extends SceneTree

const Builder: Script = preload("res://scripts/tools/player_sprite_frames_builder.gd")
const OUTPUT_ROOT: String = "res://shared/assets/player/animations/ravenfang"
const RESOURCE_PATH: String = "res://resources/player/ravenfang_player_sprite_frames.tres"


func _init() -> void:
	var sprite_frames: SpriteFrames = Builder.build_from_root(OUTPUT_ROOT)
	var error: Error = ResourceSaver.save(sprite_frames, RESOURCE_PATH)
	if error != OK:
		push_error("Unable to save Ravenfang SpriteFrames: %s" % error_string(error))
		quit(1)
		return
	print("RAVENFANG_SPRITE_FRAMES: PASS animations=%d" % sprite_frames.get_animation_names().size())
	quit()
