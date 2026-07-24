class_name CatacombDialogueUI
extends Control

## Bottom-aligned bilingual subtitle panel for the revival scene.

@onready var speaker_label: Label = $Panel/Margin/Rows/Speaker
@onready var chinese_label: Label = $Panel/Margin/Rows/Chinese
@onready var english_label: Label = $Panel/Margin/Rows/English


func _ready() -> void:
	hide_dialogue()


func show_line(speaker: String, chinese: String, english: String) -> void:
	speaker_label.text = speaker
	chinese_label.text = chinese
	english_label.text = english
	visible = true
	modulate.a = 1.0


func show_ephemeral(chinese: String, english: String, duration: float = 2.4) -> void:
	show_line("夜巡守卫 / THE NIGHT WARDEN", chinese, english)
	var timer: SceneTreeTimer = get_tree().create_timer(duration)
	timer.timeout.connect(hide_dialogue)


func hide_dialogue() -> void:
	visible = false
