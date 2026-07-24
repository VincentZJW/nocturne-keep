class_name ChapterObjectiveUI
extends Control

## Small transient objective toast; it owns presentation only.

@onready var title_label: Label = $Panel/Margin/Rows/Title
@onready var body_label: Label = $Panel/Margin/Rows/Body

var _tween: Tween


func _ready() -> void:
	visible = false
	modulate.a = 0.0


func show_objective(title_zh: String, title_en: String, duration: float = 2.6) -> void:
	title_label.text = "MAIN OBJECTIVE / 主线目标"
	body_label.text = "%s\n%s" % [title_zh, title_en]
	if _tween != null and _tween.is_valid():
		_tween.kill()
	visible = true
	modulate.a = 0.0
	_tween = create_tween()
	_tween.tween_property(self, "modulate:a", 1.0, 0.18)
	_tween.tween_interval(duration)
	_tween.tween_property(self, "modulate:a", 0.0, 0.22)
	_tween.tween_callback(hide)
