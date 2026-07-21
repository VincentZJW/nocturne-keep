extends SceneTree

## Reproducible command-line builder for placeholder PNGs and SpriteFrames.

const PlaceholderGenerator: Script = preload("res://scripts/tools/player_placeholder_animation_generator.gd")
const SpriteFramesBuilder: Script = preload("res://scripts/tools/player_sprite_frames_builder.gd")
const ProductionGenerator: Script = preload("res://scripts/tools/pixel_player_animation_generator.gd")
const ContactSheet: Script = preload("res://scripts/tools/player_animation_contact_sheet.gd")


func _initialize() -> void:
	call_deferred("_build")


func _build() -> void:
	if OS.get_cmdline_user_args().has("--production-only"):
		var sequences: Dictionary[String, Array] = ProductionGenerator.generate_all()
		var production_results: Dictionary[String, int] = ProductionGenerator.save_all(sequences)
		var contact_sheet_error: Error = ContactSheet.export(sequences)
		var production_failures: int = _count_failures(production_results)
		if contact_sheet_error != OK:
			production_failures += 1
		print("PLAYER_PRODUCTION_EXPORT: %d files, %d failures" % [production_results.size(), production_failures])
		quit(0 if production_failures == 0 else 1)
		return
	if OS.get_cmdline_user_args().has("--placeholders-only"):
		var placeholder_results: Dictionary[String, int] = PlaceholderGenerator.generate_and_save()
		var placeholder_failures: int = _count_failures(placeholder_results)
		print("PLAYER_PLACEHOLDER_EXPORT: %d files, %d failures" % [placeholder_results.size(), placeholder_failures])
		quit(0 if placeholder_failures == 0 else 1)
		return
	var resource_error: Error = SpriteFramesBuilder.save()
	print("PLAYER_SPRITE_FRAMES_BUILD: %s" % error_string(resource_error))
	quit(0 if resource_error == OK else 1)


func _count_failures(results: Dictionary[String, int]) -> int:
	var failures: int = 0
	for path: String in results:
		if results[path] != OK:
			failures += 1
	return failures
