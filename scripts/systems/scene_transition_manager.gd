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
var _prepared_scene_paths: Dictionary[String, bool] = {}
var _retirement_nodes: Array[Node] = []
const RETIREMENT_BATCH_SIZE: int = 18


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


func prepare_scene(target_scene_path: String) -> bool:
	if not ResourceLoader.exists(target_scene_path, "PackedScene"):
		return false
	if _prepared_scene_paths.has(target_scene_path):
		return true
	var current_status: ResourceLoader.ThreadLoadStatus = ResourceLoader.load_threaded_get_status(
		target_scene_path
	)
	if current_status == ResourceLoader.THREAD_LOAD_INVALID_RESOURCE:
		var request_error: Error = ResourceLoader.load_threaded_request(
			target_scene_path,
			"PackedScene",
			true
		)
		if request_error != OK:
			return false
	_prepared_scene_paths[target_scene_path] = true
	return true


func is_transitioning() -> bool:
	return _transitioning


func is_scene_retirement_in_progress() -> bool:
	return not _retirement_nodes.is_empty()


func get_fade_alpha() -> float:
	return _fade_rect.modulate.a if _fade_rect != null else 0.0


func _perform_scene_change() -> void:
	screen_blacked_out.emit(_target_scene_path)
	if _prepared_scene_paths.has(_target_scene_path):
		_continue_prepared_scene_change()
		return
	_change_scene_from_file()


func _continue_prepared_scene_change() -> void:
	if not _transitioning:
		return
	var status: ResourceLoader.ThreadLoadStatus = ResourceLoader.load_threaded_get_status(
		_target_scene_path
	)
	match status:
		ResourceLoader.THREAD_LOAD_IN_PROGRESS:
			get_tree().process_frame.connect(_continue_prepared_scene_change, CONNECT_ONE_SHOT)
		ResourceLoader.THREAD_LOAD_LOADED:
			var packed: PackedScene = ResourceLoader.load_threaded_get(
				_target_scene_path
			) as PackedScene
			_prepared_scene_paths.erase(_target_scene_path)
			if packed == null:
				_change_scene_from_file()
				return
			_change_to_prepared_scene(packed)
		ResourceLoader.THREAD_LOAD_FAILED:
			_prepared_scene_paths.erase(_target_scene_path)
			_change_scene_from_file()
		_:
			_prepared_scene_paths.erase(_target_scene_path)
			_change_scene_from_file()


func _change_scene_from_file() -> void:
	_connect_scene_changed()
	var error: Error = get_tree().change_scene_to_file(_target_scene_path)
	if error != OK:
		_disconnect_scene_changed()
		_fail_transition(error_string(error))


func _change_to_prepared_scene(packed: PackedScene) -> void:
	var next_scene: Node = packed.instantiate()
	if next_scene == null:
		_fail_transition("Prepared PackedScene could not be instantiated")
		return
	var previous_scene: Node = get_tree().current_scene
	get_tree().root.add_child(next_scene)
	get_tree().current_scene = next_scene
	if previous_scene != null:
		_prepare_scene_for_incremental_retirement(previous_scene)
	_on_scene_changed()


func _prepare_scene_for_incremental_retirement(scene: Node) -> void:
	# A full change_scene teardown produced the only repeatable Chapter II spike.
	# Disable the old world immediately, then retire its leaf-first tree in small
	# batches so resource destruction does not monopolize a rendered frame.
	scene.process_mode = Node.PROCESS_MODE_DISABLED
	var canvas_item: CanvasItem = scene as CanvasItem
	if canvas_item != null:
		canvas_item.visible = false
	for child: Node in scene.find_children("*", "CollisionObject2D", true, false):
		var collision_object: CollisionObject2D = child as CollisionObject2D
		collision_object.collision_layer = 0
		collision_object.collision_mask = 0
		var area: Area2D = collision_object as Area2D
		if area != null:
			area.monitoring = false
			area.monitorable = false
	for child: Node in scene.find_children("*", "AudioStreamPlayer", true, false):
		var audio_player: AudioStreamPlayer = child as AudioStreamPlayer
		audio_player.stop()
	_retirement_nodes.clear()
	var traversal: Array[Node] = [scene]
	while not traversal.is_empty():
		var node: Node = traversal.pop_back()
		_retirement_nodes.append(node)
		for child: Node in node.get_children():
			traversal.append(child)
	call_deferred("_retire_scene_batch")


func _retire_scene_batch() -> void:
	var retired: int = 0
	while not _retirement_nodes.is_empty() and retired < RETIREMENT_BATCH_SIZE:
		var node: Node = _retirement_nodes.pop_back()
		if is_instance_valid(node) and not node.is_queued_for_deletion():
			node.queue_free()
		retired += 1
	if not _retirement_nodes.is_empty():
		get_tree().process_frame.connect(_retire_scene_batch, CONNECT_ONE_SHOT)


func _connect_scene_changed() -> void:
	if not get_tree().scene_changed.is_connected(_on_scene_changed):
		get_tree().scene_changed.connect(_on_scene_changed, CONNECT_ONE_SHOT)


func _disconnect_scene_changed() -> void:
	if get_tree().scene_changed.is_connected(_on_scene_changed):
		get_tree().scene_changed.disconnect(_on_scene_changed)


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
