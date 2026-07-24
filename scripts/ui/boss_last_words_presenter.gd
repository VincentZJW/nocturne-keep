class_name BossLastWordsPresenter
extends Label

## Presents the sole Chapter I Boss line, then yields to the existing gate flow.

@export_node_path("FallenGateKnight") var boss_path: NodePath
@export_node_path("BossRoomController") var room_controller_path: NodePath
@export var display_duration: float = 1.15

@onready var boss: FallenGateKnight = get_node_or_null(boss_path) as FallenGateKnight
@onready var room_controller: BossRoomController = get_node_or_null(
	room_controller_path
) as BossRoomController

var _shown_for_current_fight: bool = false
var _active_tween: Tween


func _ready() -> void:
	visible = false
	modulate.a = 0.0
	if boss == null or room_controller == null:
		push_error("BossLastWordsPresenter requires Boss and BossRoomController")
		return
	boss.health_component.died.connect(_on_boss_died)
	room_controller.room_reset.connect(_on_room_reset)


func _on_boss_died() -> void:
	if _shown_for_current_fight:
		return
	_shown_for_current_fight = true
	text = "钟……认得你。\nThe bell… remembers you."
	visible = true
	modulate.a = 0.0
	_active_tween = create_tween()
	_active_tween.tween_property(self, "modulate:a", 1.0, 0.12)
	_active_tween.tween_interval(display_duration)
	_active_tween.tween_property(self, "modulate:a", 0.0, 0.22)
	_active_tween.tween_callback(func() -> void: visible = false)


func _on_room_reset() -> void:
	_shown_for_current_fight = false
	if _active_tween != null and _active_tween.is_valid():
		_active_tween.kill()
	visible = false
	modulate.a = 0.0
