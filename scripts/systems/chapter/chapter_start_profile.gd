class_name ChapterStartProfile
extends Resource

## Typed chapter-start data contract. Stage 2A stores registry metadata only;
## applying this profile to runtime state belongs to the approved later stages.

@export var profile_id: StringName = &""
@export var chapter_id: StringName = &""
@export var bilingual_name: String = ""
@export var main_scene_path: String = ""
@export var default_spawn_id: StringName = &""
@export var default_checkpoint_id: StringName = &""
@export var available_spawn_ids: Array[StringName] = []
@export var previous_chapters_completed: Array[StringName] = []
@export var required_weapons: Array[StringName] = []
@export var equipped_weapon: StringName = &""
@export_range(0, 999999, 1) var starting_currency: int = 0
@export_range(1.0, 10000.0, 1.0) var starting_hp: float = 100.0
@export var start_full_health: bool = true
@export var chapter_boss_defeated: bool = false
@export var chapter_shortcuts: Dictionary[StringName, bool] = {}
@export var chapter_story_flags: Dictionary[StringName, bool] = {}
@export var debug_ready: bool = false


func get_validation_errors(require_existing_scene: bool = false) -> Array[String]:
	var errors: Array[String] = []
	if profile_id.is_empty():
		errors.append("profile_id is empty")
	if chapter_id.is_empty():
		errors.append("chapter_id is empty")
	if bilingual_name.is_empty():
		errors.append("bilingual_name is empty")
	if main_scene_path.is_empty():
		errors.append("main_scene_path is empty")
	elif not main_scene_path.begins_with("res://"):
		errors.append("main_scene_path must use res://")
	elif require_existing_scene and not ResourceLoader.exists(main_scene_path, "PackedScene"):
		errors.append("main_scene_path does not resolve to a PackedScene")
	if default_spawn_id.is_empty():
		errors.append("default_spawn_id is empty")
	if default_checkpoint_id.is_empty():
		errors.append("default_checkpoint_id is empty")
	if starting_hp <= 0.0:
		errors.append("starting_hp must be positive")
	return errors


func is_valid_registry_entry() -> bool:
	return get_validation_errors(false).is_empty()


func is_valid_debug_target() -> bool:
	return debug_ready and get_validation_errors(true).is_empty()
