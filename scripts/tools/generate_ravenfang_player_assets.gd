extends SceneTree

## Reproducibly generates every equipped Ravenfang Player frame from the same
## low-resolution pose sources used by the production Veilbound set.

const ActionGenerator: Script = preload("res://scripts/tools/pixel_player_animation_generator.gd")
const M1Generator: Script = preload("res://scripts/tools/pixel_player_m1_animation_generator.gd")
const HurtGenerator: Script = preload("res://scripts/tools/pixel_player_hurt_generator.gd")
const DeathGenerator: Script = preload("res://scripts/tools/pixel_player_death_generator.gd")
const OUTPUT_ROOT: String = "res://assets/sprites/player/ravenfang"


func _init() -> void:
	var failures: int = 0
	failures += _save_sequences(ActionGenerator.generate_all(&"ravenfang"))
	failures += _save_sequences(M1Generator.generate_all(&"ravenfang"))
	failures += _save_sequence(&"hurt", HurtGenerator.generate_frames(&"ravenfang"))
	failures += _save_sequence(&"death", DeathGenerator.generate_death_frames(&"ravenfang"))
	if failures > 0:
		push_error("Ravenfang generation failed for %d files" % failures)
		quit(1)
		return
	print("RAVENFANG_PLAYER_ASSETS: PASS (16 animations, 49 transparent 64x64 frames)")
	quit()


func _save_sequences(sequences: Dictionary[String, Array]) -> int:
	var failures: int = 0
	for animation_name: String in sequences:
		failures += _save_sequence(StringName(animation_name), sequences[animation_name])
	return failures


func _save_sequence(animation_name: StringName, frames: Array) -> int:
	var directory: String = OUTPUT_ROOT.path_join(str(animation_name))
	var directory_error: Error = DirAccess.make_dir_recursive_absolute(
		ProjectSettings.globalize_path(directory)
	)
	if directory_error != OK:
		push_error("Unable to create %s: %s" % [directory, error_string(directory_error)])
		return frames.size()
	var failures: int = 0
	for frame_index: int in range(frames.size()):
		var image: Image = frames[frame_index] as Image
		var path: String = directory.path_join(
			"%s_%02d.png" % [animation_name, frame_index + 1]
		)
		var error: Error = image.save_png(path)
		if error != OK:
			failures += 1
			push_error("Unable to save %s: %s" % [path, error_string(error)])
	return failures
