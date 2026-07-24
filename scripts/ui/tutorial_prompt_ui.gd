class_name TutorialPromptUI
extends Control

## Small, non-blocking bilingual prompt used by the embedded Chapter I tutorial.

@export_node_path("Label") var title_label_path: NodePath = NodePath("Panel/Margin/Rows/Title")
@export_node_path("Label") var body_label_path: NodePath = NodePath("Panel/Margin/Rows/Body")

@onready var title_label: Label = get_node_or_null(title_label_path) as Label
@onready var body_label: Label = get_node_or_null(body_label_path) as Label

var _active_tween: Tween


func _ready() -> void:
	modulate.a = 0.0
	visible = false


func show_prompt(title: String, chinese_text: String, english_text: String) -> void:
	if title_label == null or body_label == null:
		return
	title_label.text = title
	body_label.text = "%s\n%s" % [chinese_text, english_text]
	_fade_to(1.0, 0.16)


func show_location(chinese_text: String, english_text: String, duration: float = 2.0) -> void:
	show_prompt("CHAPTER I", chinese_text, english_text)
	var timer: SceneTreeTimer = get_tree().create_timer(duration)
	timer.timeout.connect(hide_prompt)


func hide_prompt() -> void:
	_fade_to(0.0, 0.18)


func _fade_to(target_alpha: float, duration: float) -> void:
	if _active_tween != null and _active_tween.is_valid():
		_active_tween.kill()
	visible = true
	_active_tween = create_tween()
	_active_tween.tween_property(self, "modulate:a", target_alpha, duration)
	if is_zero_approx(target_alpha):
		_active_tween.tween_callback(func() -> void: visible = false)
