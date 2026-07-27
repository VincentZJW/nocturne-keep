class_name DebugRunConfigState
extends Node

## Central debug-start preferences. This service has no _ready() side effects and
## never changes scenes. ChapterStartRouter consumes it behind a debug-build gate.

@export var debug_chapter_start_enabled: bool = false
@export var debug_start_chapter_id: StringName = ChapterRegistry.CHAPTER_01_RAVENMOURN_OUTSKIRTS
@export var debug_start_spawn_id: StringName = &"dark_forest_tutorial_spawn"
@export var debug_reset_chapter_state_on_run: bool = true
@export var debug_use_test_currency: bool = true
@export_range(0, 999999, 1) var debug_test_currency: int = 30
@export var debug_start_full_health: bool = true
@export var debug_skip_chapter_intro: bool = false
@export var debug_show_chapter_select: bool = false


func is_chapter_start_allowed() -> bool:
	return OS.is_debug_build() and debug_chapter_start_enabled


func get_target_profile() -> ChapterStartProfile:
	return ChapterRegistry.get_chapter_or_null(debug_start_chapter_id)


func reset_to_defaults() -> void:
	debug_chapter_start_enabled = false
	debug_start_chapter_id = ChapterRegistry.CHAPTER_01_RAVENMOURN_OUTSKIRTS
	debug_start_spawn_id = &"dark_forest_tutorial_spawn"
	debug_reset_chapter_state_on_run = true
	debug_use_test_currency = true
	debug_test_currency = 30
	debug_start_full_health = true
	debug_skip_chapter_intro = false
	debug_show_chapter_select = false
