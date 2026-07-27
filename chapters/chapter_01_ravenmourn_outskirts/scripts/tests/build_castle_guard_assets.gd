extends SceneTree

## CLI entry point: generate PNGs/contact sheet, then build SpriteFrames after import.

const Generator: Script = preload("res://chapters/chapter_01_ravenmourn_outskirts/scripts/tests/pixel_castle_guard_generator.gd")
const SpriteFramesBuilder: Script = preload("res://chapters/chapter_01_ravenmourn_outskirts/scripts/tests/castle_guard_sprite_frames_builder.gd")


func _initialize() -> void:
	call_deferred("_build")


func _build() -> void:
	if OS.get_cmdline_user_args().has("--generate"):
		var sequences: Dictionary[StringName, Array] = Generator.generate_all()
		var results: Dictionary[String, int] = Generator.save_all(sequences)
		var failures: int = 0
		for file_path: String in results:
			if results[file_path] != OK:
				failures += 1
		print("CASTLE_GUARD_ASSET_EXPORT: %d files, %d failures" % [results.size(), failures])
		quit(0 if failures == 0 else 1)
		return
	var resource_error: Error = SpriteFramesBuilder.save()
	print("CASTLE_GUARD_SPRITE_FRAMES_BUILD: %s" % error_string(resource_error))
	quit(0 if resource_error == OK else 1)
