class_name BossHealthHud
extends Control

## Signal-driven Boss presentation. It never owns or mutates Boss combat data.

@export_node_path("FallenGateKnight") var boss_path: NodePath

@onready var name_label: Label = %BossName
@onready var body_bar: ProgressBar = %BossBodyBar
@onready var body_value: Label = %BossBodyValue
@onready var shield_bar: ProgressBar = %BossShieldBar
@onready var shield_value: Label = %BossShieldValue
@onready var shield_row: Control = %BossShieldRow

var boss: FallenGateKnight
var _fade_tween: Tween


func _ready() -> void:
	visible = false
	var initial_boss: FallenGateKnight = get_node_or_null(boss_path) as FallenGateKnight if not boss_path.is_empty() else null
	if initial_boss != null:
		bind_boss(initial_boss)


func bind_boss(new_boss: FallenGateKnight) -> void:
	_disconnect_boss()
	boss = new_boss
	if boss == null:
		return
	boss.health_component.health_changed.connect(_on_body_health_changed)
	boss.shield_component.shield_health_changed.connect(_on_shield_health_changed)
	boss.combat_started.connect(show_for_combat)
	boss.boss_defeated.connect(_on_boss_defeated)
	name_label.text = "%s / %s" % [boss.config.display_name_en, boss.config.display_name_zh]
	_on_body_health_changed(boss.health_component.current_health, boss.health_component.max_health)
	_on_shield_health_changed(boss.shield_component.shield_current_health, boss.shield_component.shield_max_health)


func show_for_combat() -> void:
	if _fade_tween != null and _fade_tween.is_valid():
		_fade_tween.kill()
	modulate = Color.WHITE
	visible = true


func hide_immediately() -> void:
	if _fade_tween != null and _fade_tween.is_valid():
		_fade_tween.kill()
	visible = false
	modulate = Color.WHITE


func _on_body_health_changed(current: int, maximum: int) -> void:
	body_bar.max_value = float(maximum)
	body_bar.value = float(current)
	body_value.text = "%02d / %02d" % [current, maximum]


func _on_shield_health_changed(current: int, maximum: int) -> void:
	shield_bar.max_value = float(maximum)
	shield_bar.value = float(current)
	shield_value.text = "BROKEN" if current <= 0 else "%02d / %02d" % [current, maximum]
	shield_bar.visible = current > 0


func _on_boss_defeated() -> void:
	_fade_tween = create_tween()
	_fade_tween.tween_property(self, "modulate:a", 0.0, 0.45)
	_fade_tween.tween_callback(hide_immediately)


func _disconnect_boss() -> void:
	if boss == null or not is_instance_valid(boss):
		boss = null
		return
	if boss.health_component.health_changed.is_connected(_on_body_health_changed):
		boss.health_component.health_changed.disconnect(_on_body_health_changed)
	if boss.shield_component.shield_health_changed.is_connected(_on_shield_health_changed):
		boss.shield_component.shield_health_changed.disconnect(_on_shield_health_changed)
	if boss.combat_started.is_connected(show_for_combat):
		boss.combat_started.disconnect(show_for_combat)
	if boss.boss_defeated.is_connected(_on_boss_defeated):
		boss.boss_defeated.disconnect(_on_boss_defeated)
	boss = null
