class_name ChapterStartRouterState
extends Node

## Debug-build-only chapter redirect. The authored F5 main scene stays Opening;
## release builds and disabled debug starts fall through without side effects.

const OPENING_SCENE_PATH: String = "res://scenes/cinematics/opening_cinematic.tscn"

var _route_requested: bool = false


func _ready() -> void:
	call_deferred("_route_debug_chapter_if_requested")


func _route_debug_chapter_if_requested() -> void:
	if _route_requested:
		return
	if "--script" in OS.get_cmdline_args():
		return
	var config: DebugRunConfigState = get_node_or_null("/root/DebugRunConfig") as DebugRunConfigState
	if config == null or not config.is_chapter_start_allowed():
		return
	var tree: SceneTree = get_tree()
	if tree.current_scene == null or tree.current_scene.scene_file_path != OPENING_SCENE_PATH:
		return
	var profile: ChapterStartProfile = config.get_target_profile()
	if profile == null or not profile.is_valid_debug_target():
		push_warning("Debug chapter target is not ready: %s" % config.debug_start_chapter_id)
		return
	_route_requested = true
	var error: Error = tree.change_scene_to_file(profile.main_scene_path)
	if error != OK:
		_route_requested = false
		push_error("Unable to route debug chapter: %s" % error_string(error))
