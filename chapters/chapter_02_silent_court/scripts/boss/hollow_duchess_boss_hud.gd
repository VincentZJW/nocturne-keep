class_name HollowDuchessBossHud
extends Control

## Signal-driven Duchess HP/phase/poise display. It never owns combat data.

@onready var name_label: Label = %BossName
@onready var health_bar: ProgressBar = %HealthBar
@onready var health_value: Label = %HealthValue
@onready var phase_label: Label = %PhaseLabel
@onready var poise_bar: ProgressBar = %PoiseBar

var boss: HollowDuchess
var _fade_tween: Tween


func _ready() -> void:
	visible = false


func bind_boss(new_boss: HollowDuchess) -> void:
	_disconnect_boss()
	boss = new_boss
	if boss == null:
		return
	boss.health_component.health_changed.connect(_on_health_changed)
	boss.phase_changed.connect(_on_phase_changed)
	boss.poise_changed.connect(_on_poise_changed)
	boss.combat_started.connect(show_for_combat)
	boss.boss_defeated.connect(_on_boss_defeated)
	name_label.text = "%s / %s" % [boss.config.display_name_en, boss.config.display_name_zh]
	_on_health_changed(boss.health_component.current_health, boss.health_component.max_health)
	_on_phase_changed(boss.get_phase())
	_on_poise_changed(boss.get_current_poise(), boss.get_max_poise())


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


func _on_health_changed(current: int, maximum: int) -> void:
	health_bar.max_value = float(maximum)
	health_bar.value = float(current)
	health_value.text = "%03d / %03d" % [current, maximum]


func _on_phase_changed(phase: int) -> void:
	phase_label.text = "PHASE 2 · UNMASKED" if phase >= 2 else "PHASE 1"


func _on_poise_changed(current: int, maximum: int) -> void:
	poise_bar.max_value = float(maximum)
	poise_bar.value = float(current)


func _on_boss_defeated() -> void:
	_fade_tween = create_tween()
	_fade_tween.tween_property(self, "modulate:a", 0.0, 0.45)
	_fade_tween.tween_callback(hide_immediately)


func _disconnect_boss() -> void:
	if boss == null or not is_instance_valid(boss):
		boss = null
		return
	if boss.health_component.health_changed.is_connected(_on_health_changed):
		boss.health_component.health_changed.disconnect(_on_health_changed)
	if boss.phase_changed.is_connected(_on_phase_changed):
		boss.phase_changed.disconnect(_on_phase_changed)
	if boss.poise_changed.is_connected(_on_poise_changed):
		boss.poise_changed.disconnect(_on_poise_changed)
	if boss.combat_started.is_connected(show_for_combat):
		boss.combat_started.disconnect(show_for_combat)
	if boss.boss_defeated.is_connected(_on_boss_defeated):
		boss.boss_defeated.disconnect(_on_boss_defeated)
	boss = null
