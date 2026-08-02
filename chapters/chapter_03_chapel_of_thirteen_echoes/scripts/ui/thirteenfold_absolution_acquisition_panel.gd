class_name ThirteenfoldAbsolutionAcquisitionPanel
extends Control

@export_node_path("TextureRect") var icon_path: NodePath = NodePath(
	"Panel/Margin/Layout/Icon"
)
@export_node_path("Label") var title_path: NodePath = NodePath(
	"Panel/Margin/Layout/Text/Title"
)
@export_node_path("Label") var detail_path: NodePath = NodePath(
	"Panel/Margin/Layout/Text/Detail"
)

@onready var icon: TextureRect = get_node_or_null(icon_path) as TextureRect
@onready var title: Label = get_node_or_null(title_path) as Label
@onready var detail: Label = get_node_or_null(detail_path) as Label

var _presentation_tween: Tween
var _rest_position: Vector2


func _ready() -> void:
	_rest_position = position
	visible = false


func present(weapon: WeaponData, duration: float = 2.60) -> void:
	if weapon == null or icon == null or title == null or detail == null:
		return
	if _presentation_tween != null and _presentation_tween.is_valid():
		_presentation_tween.kill()
	icon.texture = weapon.icon
	title.text = "%s  ·  %s" % [weapon.display_name_zh, weapon.display_name_en]
	detail.text = (
		"TIER %d  |  ATTACK %d  |  DASH %d\n"
		+ "十三枚封印已经熄灭；第十四席仍旧空白。\n"
		+ "已加入武器栏并自动装备"
	) % [weapon.tier, weapon.normal_attack_damage, weapon.dash_attack_damage]
	visible = true
	modulate.a = 0.0
	position = _rest_position + Vector2(0.0, -10.0)
	_presentation_tween = create_tween()
	_presentation_tween.set_parallel(true)
	_presentation_tween.tween_property(self, "modulate:a", 1.0, 0.16)
	_presentation_tween.tween_property(self, "position", _rest_position, 0.16)
	_presentation_tween.chain().tween_interval(duration)
	_presentation_tween.chain().tween_property(self, "modulate:a", 0.0, 0.36)
	_presentation_tween.chain().tween_callback(func() -> void: visible = false)
