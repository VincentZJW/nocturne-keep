class_name ChapterStartRouterState
extends Node

## Side-effect-free debug chapter target resolver. MainBootstrap is the sole
## startup authority and decides whether to consume this optional target.


func get_debug_target_profile() -> ChapterStartProfile:
	var config: DebugRunConfigState = get_node_or_null("/root/DebugRunConfig") as DebugRunConfigState
	if config == null or not config.is_chapter_start_allowed():
		return null
	var profile: ChapterStartProfile = config.get_target_profile()
	if profile == null or not profile.is_valid_debug_target():
		push_warning("Debug chapter target is not ready: %s" % config.debug_start_chapter_id)
		return null
	return profile


func get_debug_target_scene_path() -> String:
	var profile: ChapterStartProfile = get_debug_target_profile()
	return "" if profile == null else profile.main_scene_path
