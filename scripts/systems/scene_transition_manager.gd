class_name SceneTransitionManagerState
extends CanvasLayer

## Cross-scene fade authority. It resolves chapters through ChapterRegistry and
## stores only the destination contract in ChapterSession before changing scenes.

signal transition_started(target_scene_path: String, spawn_id: StringName)
signal screen_blacked_out(target_scene_path: String)
signal transition_completed(target_scene_path: String, spawn_id: StringName)
signal transition_failed(target_scene_path: String, reason: String)

@export_range(0.2, 1.0, 0.05) var default_fade_out_duration: float = 0.50
@export_range(0.2, 1.0, 0.05) var default_fade_in_duration: float = 0.50

var _fade_rect: ColorRect
var _transitioning: bool = false
var _target_scene_path: String = ""
var _target_spawn_id: StringName = &""
var _target_chapter_id: StringName = &""
var _fade_in_duration: float = 0.50


func _ready() -> void:
	layer = 1000
	process_mode = Node.PROCESS_MODE_ALWAYS
	_fade_rect = ColorRect.new()
	_fade_rect.name = "ChapterFade"
	_fade_rect.color = Color(0.004, 0.003, 0.008, 1.0)
	_fade_rect.mouse_filter = Control.MOUSE_FILTER_STOP
	_fade_rect.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_fade_rect.modulate.a = 0.0
	_fade_rect.visible = false
	add_child(_fade_rect)


func transition_to_chapter(
	chapter_id: StringName,
	spawn_id: StringName,
	fade_out_duration: float = -1.0,
	fade_in_duration: float = -1.0
) -> bool:
	var profile: ChapterStartProfile = ChapterRegistry.get_chapter_or_null(chapter_id)
	if profile == null:
		transition_failed.emit("", "Unknown chapter: %s" % chapter_id)
		return false
	return transition_to_scene(
		profile.main_scene_path,
		spawn_id,
		chapter_id,
		fade_out_duration,
		fade_in_duration
	)


func transition_to_scene(
	target_scene_path: String,
	spawn_id: StringName,
	chapter_id: StringName = &"",
	fade_out_duration: float = -1.0,
	fade_in_duration: float = -1.0
) -> bool:
	if _transitioning:
		return false
	if not ResourceLoader.exists(target_scene_path, "PackedScene"):
		transition_failed.emit(target_scene_path, "Target PackedScene does not exist")
		return false
	_transitioning = true
	_target_scene_path = target_scene_path
	_target_spawn_id = spawn_id
	_target_chapter_id = chapter_id
	_fade_in_duration = (
		default_fade_in_duration if fade_in_duration < 0.0 else fade_in_duration
	)
	var session: ChapterSessionState = get_node_or_null("/root/ChapterSession") as ChapterSessionState
	if session != null:
		session.set_transition_target(chapter_id, spawn_id)
	_fade_rect.visible = true
	_fade_rect.modulate.a = 0.0
	transition_started.emit(target_scene_path, spawn_id)
	var duration: float = (
		default_fade_out_duration if fade_out_duration < 0.0 else fade_out_duration
	)
	var tween: Tween = create_tween()
	tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tween.tween_property(_fade_rect, "modulate:a", 1.0, duration).set_trans(
		Tween.TRANS_SINE
	).set_ease(Tween.EASE_IN_OUT)
	tween.tween_callback(_perform_scene_change)
	return true


func is_transitioning() -> bool:
	return _transitioning


func get_fade_alpha() -> float:
	return _fade_rect.modulate.a if _fade_rect != null else 0.0


func _perform_scene_change() -> void:
	screen_blacked_out.emit(_target_scene_path)
	get_tree().scene_changed.connect(_on_scene_changed, CONNECT_ONE_SHOT)
	var error: Error = get_tree().change_scene_to_file(_target_scene_path)
	if error != OK:
		if get_tree().scene_changed.is_connected(_on_scene_changed):
			get_tree().scene_changed.disconnect(_on_scene_changed)
		_fail_transition(error_string(error))


func _on_scene_changed() -> void:
	var completed_path: String = _target_scene_path
	var completed_spawn: StringName = _target_spawn_id
	var tween: Tween = create_tween()
	tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tween.tween_property(_fade_rect, "modulate:a", 0.0, _fade_in_duration).set_trans(
		Tween.TRANS_SINE
	).set_ease(Tween.EASE_IN_OUT)
	tween.tween_callback(func() -> void:
		_fade_rect.visible = false
		_transitioning = false
		transition_completed.emit(completed_path, completed_spawn)
	)


func _fail_transition(reason: String) -> void:
	var failed_path: String = _target_scene_path
	_fade_rect.visible = false
	_fade_rect.modulate.a = 0.0
	_transitioning = false
	transition_failed.emit(failed_path, reason)
