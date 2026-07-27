class_name CrimsonMasqueAcquisitionPanel
extends Control

@export_node_path("Label") var title_path: NodePath = NodePath("Panel/Margin/VBox/Title")
@export_node_path("Label") var detail_path: NodePath = NodePath("Panel/Margin/VBox/Detail")
@onready var title: Label = get_node_or_null(title_path) as Label
@onready var detail: Label = get_node_or_null(detail_path) as Label

var _presentation_tween: Tween


func _ready() -> void:
	visible = false


func present(weapon: WeaponData, duration: float = 2.25) -> void:
	if weapon == null or title == null or detail == null:
		return
	if _presentation_tween != null and _presentation_tween.is_valid():
		_presentation_tween.kill()
	title.text = "%s  ·  %s" % [weapon.display_name_zh, weapon.display_name_en]
	detail.text = "TIER %d  |  ATTACK %d  |  DASH %d\n已加入武器栏并自动装备" % [
		weapon.tier, weapon.normal_attack_damage, weapon.dash_attack_damage,
	]
	visible = true
	modulate.a = 0.0
	position.y = -8.0
	_presentation_tween = create_tween()
	_presentation_tween.set_parallel(true)
	_presentation_tween.tween_property(self, "modulate:a", 1.0, 0.12)
	_presentation_tween.tween_property(self, "position:y", 0.0, 0.12)
	_presentation_tween.chain().tween_interval(duration)
	_presentation_tween.chain().tween_property(self, "modulate:a", 0.0, 0.32)
	_presentation_tween.chain().tween_callback(func() -> void: visible = false)
