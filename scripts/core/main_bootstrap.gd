class_name MainBootstrap
extends Node

## Sole F5 startup authority. It selects exactly one route, validates the
## PackedScene, and then leaves all later story transitions to their scene-local
## controllers.

const DEFAULT_OPENING_SCENE_PATH: String = "res://scenes/cinematics/opening_cinematic.tscn"

@export_file("*.tscn") var opening_scene_path: String = DEFAULT_OPENING_SCENE_PATH
@export var auto_start: bool = true

var _startup_requested: bool = false


func _ready() -> void:
	if auto_start:
		call_deferred("start_startup_flow")


func start_startup_flow() -> void:
	if _startup_requested:
		return
	_startup_requested = true
	var router: ChapterStartRouterState = get_node_or_null(
		"/root/ChapterStartRouter"
	) as ChapterStartRouterState
	var debug_profile: ChapterStartProfile = (
		router.get_debug_target_profile() if router != null else null
	)
	if debug_profile != null:
		_prepare_session(true, debug_profile)
		print(
			"DEBUG CHAPTER START ACTIVE | %s | %s"
			% [debug_profile.chapter_id, debug_profile.main_scene_path]
		)
		_change_to_scene(debug_profile.main_scene_path, "Debug Chapter Start")
		return
	start_new_game_flow()


func start_new_game_flow() -> void:
	_prepare_session(false)
	print("MAIN BOOTSTRAP | FORMAL NEW GAME | %s" % opening_scene_path)
	_change_to_scene(opening_scene_path, "Opening Cinematic")


func get_selected_start_scene_path() -> String:
	var router: ChapterStartRouterState = get_node_or_null(
		"/root/ChapterStartRouter"
	) as ChapterStartRouterState
	if router != null:
		var debug_path: String = router.get_debug_target_scene_path()
		if not debug_path.is_empty():
			return debug_path
	return opening_scene_path


func _prepare_session(debug_run: bool, profile: ChapterStartProfile = null) -> void:
	var session: ChapterSessionState = get_node_or_null("/root/ChapterSession") as ChapterSessionState
	var save_service: PlayerProgressSaveServiceState = get_node_or_null(
		"/root/PlayerProgressSaveService"
	) as PlayerProgressSaveServiceState
	if session == null:
		push_warning("MainBootstrap could not find ChapterSession; continuing without session reset")
		return
	if debug_run:
		if save_service != null:
			save_service.begin_debug_session()
		session.begin_debug_run()
		var config: DebugRunConfigState = get_node_or_null(
			"/root/DebugRunConfig"
		) as DebugRunConfigState
		var spawn_override: StringName = config.debug_start_spawn_id if config != null else &""
		session.apply_start_profile(profile, spawn_override)
	else:
		if save_service != null:
			var clear_error: Error = save_service.begin_new_game()
			if clear_error != OK:
				push_warning("MainBootstrap could not clear prior progress save: %s" % error_string(clear_error))
		session.begin_formal_new_game()
		if save_service != null:
			var enable_error: Error = save_service.enable_formal_persistence()
			if enable_error != OK:
				push_warning("MainBootstrap could not enable formal progress save: %s" % error_string(enable_error))


func _change_to_scene(scene_path: String, route_name: String) -> void:
	if not ResourceLoader.exists(scene_path, "PackedScene"):
		_startup_requested = false
		push_error("MainBootstrap failed to load %s: %s" % [route_name, scene_path])
		return
	var packed_scene: PackedScene = ResourceLoader.load(scene_path, "PackedScene") as PackedScene
	if packed_scene == null:
		_startup_requested = false
		push_error("MainBootstrap loaded a null PackedScene for %s: %s" % [route_name, scene_path])
		return
	var error: Error = get_tree().change_scene_to_packed(packed_scene)
	if error != OK:
		_startup_requested = false
		push_error(
			"MainBootstrap could not start %s (%s): %s"
			% [route_name, scene_path, error_string(error)]
		)
