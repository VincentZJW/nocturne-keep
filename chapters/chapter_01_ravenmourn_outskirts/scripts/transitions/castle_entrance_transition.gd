class_name CastleEntranceTransition
extends CanvasLayer

## Owns the text-free fade from the opened Chapter I gate into Chapter II.

signal transition_started
signal transition_completed

@export_file("*.tscn") var target_scene_path: String = (
	"res://chapters/chapter_02_silent_court/scenes/level/silent_court.tscn"
)
@export_range(0.2, 1.0, 0.05) var fade_duration: float = 0.55
@export var scene_change_enabled: bool = true

@onready var fade_rect: ColorRect = $FadeRect

var _transition_in_progress: bool = false


func _ready() -> void:
	fade_rect.visible = false
	fade_rect.modulate.a = 0.0


func begin_transition() -> bool:
	if _transition_in_progress:
		return false
	_transition_in_progress = true
	fade_rect.visible = true
	fade_rect.modulate.a = 0.0
	transition_started.emit()
	var tween: Tween = create_tween()
	tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tween.tween_property(fade_rect, "modulate:a", 1.0, fade_duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.finished.connect(_on_fade_completed, CONNECT_ONE_SHOT)
	return true


func is_transition_in_progress() -> bool:
	return _transition_in_progress


func _on_fade_completed() -> void:
	transition_completed.emit()
	if scene_change_enabled and not target_scene_path.is_empty():
		var change_error: Error = get_tree().change_scene_to_file(target_scene_path)
		if change_error != OK:
			push_error("CastleEntranceTransition could not load %s" % target_scene_path)
			_transition_in_progress = false
			fade_rect.visible = false
		return
	_transition_in_progress = false
