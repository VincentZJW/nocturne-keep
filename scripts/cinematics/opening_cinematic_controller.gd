class_name OpeningCinematicController
extends Node2D

## Structured timeline and skip authority for the Chapter I opening.

signal shot_changed(shot_index: int)
signal cinematic_finished(skipped: bool)

@export var timeline: OpeningCinematicTimeline
@export_file("*.tscn") var target_scene_path: String = "res://scenes/main/main.tscn"
@export_range(0.2, 1.2, 0.05) var transition_duration: float = 0.6
@export_range(0.5, 2.0, 0.1) var skip_unlock_delay: float = 1.5
@export_range(0.3, 1.5, 0.05) var skip_hold_duration: float = 0.75
@export var scene_change_enabled: bool = true
@export var debug_skip_immediately: bool = false
@export_node_path("OpeningCinematicArt") var art_path: NodePath = NodePath("VisualRoot/Art")
@export_node_path("Label") var subtitle_path: NodePath = NodePath("UI/SubtitlePanel/Subtitle")
@export_node_path("Label") var skip_label_path: NodePath = NodePath("UI/SkipPanel/SkipLabel")
@export_node_path("ProgressBar") var skip_progress_path: NodePath = NodePath("UI/SkipPanel/SkipProgress")
@export_node_path("ColorRect") var fade_rect_path: NodePath = NodePath("UI/FadeRect")
@export_node_path("Timer") var shot_timer_path: NodePath = NodePath("ShotTimer")

@onready var art: OpeningCinematicArt = get_node_or_null(art_path) as OpeningCinematicArt
@onready var subtitle: Label = get_node_or_null(subtitle_path) as Label
@onready var skip_label: Label = get_node_or_null(skip_label_path) as Label
@onready var skip_progress: ProgressBar = get_node_or_null(skip_progress_path) as ProgressBar
@onready var fade_rect: ColorRect = get_node_or_null(fade_rect_path) as ColorRect
@onready var shot_timer: Timer = get_node_or_null(shot_timer_path) as Timer

var current_shot: int = -1
var elapsed_time: float = 0.0
var skip_hold_time: float = 0.0
var _finishing: bool = false
var _art_tween: Tween
var _transition_tween: Tween


func _ready() -> void:
	if not _validate_dependencies():
		set_process(false)
		return
	shot_timer.timeout.connect(_on_shot_timeout)
	fade_rect.visible = true
	fade_rect.modulate.a = 1.0
	skip_progress.min_value = 0.0
	skip_progress.max_value = skip_hold_duration
	skip_progress.value = 0.0
	skip_label.text = "按住 ESC / ENTER 跳过  ·  HOLD TO SKIP"
	skip_label.visible = false
	skip_progress.visible = false
	_show_shot(0)
	_transition_tween = create_tween()
	_transition_tween.tween_property(fade_rect, "modulate:a", 0.0, 1.0)
	if debug_skip_immediately:
		call_deferred("finish_cinematic", true)


func _process(delta: float) -> void:
	if _finishing:
		return
	elapsed_time += delta
	var skip_unlocked: bool = elapsed_time >= skip_unlock_delay
	skip_label.visible = skip_unlocked
	skip_progress.visible = skip_unlocked
	var skip_pressed: bool = (
		Input.is_action_pressed(&"ui_cancel") or Input.is_action_pressed(&"ui_accept")
	)
	if skip_unlocked and skip_pressed:
		skip_hold_time = minf(skip_hold_duration, skip_hold_time + delta)
	else:
		skip_hold_time = maxf(0.0, skip_hold_time - delta * 2.0)
	skip_progress.value = skip_hold_time
	if skip_hold_time >= skip_hold_duration:
		finish_cinematic(true)


func get_authored_duration() -> float:
	if timeline == null:
		return 0.0
	return timeline.get_total_duration() + transition_duration * float(maxi(0, timeline.get_shot_count() - 1))


func show_shot_for_qa(index: int) -> void:
	if timeline == null or art == null or subtitle == null:
		return
	shot_timer.stop()
	_show_shot(index)


func finish_cinematic(skipped: bool) -> void:
	if _finishing:
		return
	_finishing = true
	shot_timer.stop()
	_kill_timeline_tweens()
	fade_rect.visible = true
	_transition_tween = create_tween()
	_transition_tween.tween_property(fade_rect, "modulate:a", 1.0, transition_duration)
	_transition_tween.finished.connect(_complete_transition.bind(skipped), CONNECT_ONE_SHOT)


func _on_shot_timeout() -> void:
	if current_shot + 1 >= timeline.get_shot_count():
		finish_cinematic(false)
		return
	if _transition_tween != null and _transition_tween.is_valid():
		_transition_tween.kill()
	_transition_tween = create_tween()
	_transition_tween.tween_property(fade_rect, "modulate:a", 1.0, transition_duration * 0.5)
	_transition_tween.tween_callback(_show_shot.bind(current_shot + 1))
	_transition_tween.tween_property(fade_rect, "modulate:a", 0.0, transition_duration * 0.5)


func _show_shot(index: int) -> void:
	current_shot = clampi(index, 0, timeline.get_shot_count() - 1)
	art.position = Vector2.ZERO
	art.scale = Vector2.ONE
	art.set_shot(current_shot)
	subtitle.text = timeline.get_subtitle(current_shot, TranslationServer.get_locale())
	shot_timer.start(timeline.shot_durations[current_shot])
	shot_changed.emit(current_shot)
	var drift: Vector2 = Vector2(-16.0 if current_shot % 2 == 0 else 12.0, -8.0)
	if _art_tween != null and _art_tween.is_valid():
		_art_tween.kill()
	_art_tween = create_tween()
	_art_tween.set_parallel(true)
	_art_tween.tween_property(art, "position", drift, timeline.shot_durations[current_shot])
	_art_tween.tween_property(art, "scale", Vector2(1.025, 1.025), timeline.shot_durations[current_shot])


func _complete_transition(skipped: bool) -> void:
	cinematic_finished.emit(skipped)
	if not scene_change_enabled:
		_finishing = false
		return
	var error: Error = get_tree().change_scene_to_file(target_scene_path)
	if error != OK:
		push_error("OpeningCinematic could not load %s" % target_scene_path)
		_finishing = false


func _validate_dependencies() -> bool:
	if (
		timeline == null or timeline.get_shot_count() != 8 or art == null or subtitle == null
		or skip_label == null or skip_progress == null or fade_rect == null or shot_timer == null
	):
		push_error("OpeningCinematicController scene composition is incomplete")
		return false
	return true


func _kill_timeline_tweens() -> void:
	if _art_tween != null and _art_tween.is_valid():
		_art_tween.kill()
	if _transition_tween != null and _transition_tween.is_valid():
		_transition_tween.kill()
