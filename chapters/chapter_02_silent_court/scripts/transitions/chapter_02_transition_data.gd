class_name Chapter02TransitionData
extends Resource

## Authored Chapter II exit contract. Runtime controllers consume this Resource;
## the Boss owns no destination paths or story-state decisions.

@export_file("*.tscn") var passage_scene_path: String
@export var passage_spawn_id: StringName = &"royal_processional_passage_start"
@export var target_chapter_id: StringName = ChapterRegistry.CHAPTER_03_CHAPEL_OF_THIRTEEN_ECHOES
@export var target_spawn_id: StringName = &"chapter_03_start"
@export_range(0.2, 1.0, 0.05) var fade_out_duration: float = 0.50
@export_range(0.2, 1.0, 0.05) var fade_in_duration: float = 0.50
@export_range(1.0, 4.0, 0.1) var mirror_reveal_duration: float = 2.20
@export_range(0.5, 2.0, 0.1) var door_open_duration: float = 1.10
@export var missing_reward_prompt: String = "公爵夫人的遗物仍留在舞厅中。"


func is_valid() -> bool:
	return (
		not passage_scene_path.is_empty()
		and ResourceLoader.exists(passage_scene_path, "PackedScene")
		and not passage_spawn_id.is_empty()
		and not target_chapter_id.is_empty()
		and not target_spawn_id.is_empty()
	)
