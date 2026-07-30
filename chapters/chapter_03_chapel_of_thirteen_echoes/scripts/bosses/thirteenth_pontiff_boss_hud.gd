class_name ThirteenthPontiffBossHud
extends CanvasLayer

@export_node_path("ThirteenthPontiffEdran") var boss_path: NodePath = NodePath("..")

@onready var boss: ThirteenthPontiffEdran = get_node_or_null(boss_path) as ThirteenthPontiffEdran
@onready var panel: Control = $Panel as Control
@onready var name_label: Label = $Panel/Margin/VBox/Name as Label
@onready var health_bar: ProgressBar = $Panel/Margin/VBox/Health as ProgressBar
@onready var poise_bar: ProgressBar = $Panel/Margin/VBox/Poise as ProgressBar
@onready var state_label: Label = $Panel/Margin/VBox/State as Label


func _ready() -> void:
	visible = false
	call_deferred("_bind_boss")


func _bind_boss() -> void:
	if boss == null:
		return
	name_label.text = "%s / %s" % [boss.config.display_name_en, boss.config.display_name_zh]
	health_bar.max_value = boss.config.max_health
	poise_bar.max_value = boss.config.max_poise
	boss.health_component.health_changed.connect(_on_health_changed)
	boss.state_changed.connect(_on_state_changed)
	boss.phase_changed.connect(_on_phase_changed)
	boss.activated.connect(_on_activated)
	boss.defeated.connect(_on_defeated)
	_on_health_changed(boss.health_component.current_health, boss.config.max_health)
	_on_state_changed(boss.get_state_name())
	visible = boss.current_state != ThirteenthPontiffEdran.State.DORMANT


func _process(_delta: float) -> void:
	if boss != null and visible:
		poise_bar.value = boss.get_current_poise()


func _on_health_changed(current: int, maximum: int) -> void:
	health_bar.max_value = maximum
	health_bar.value = current


func _on_state_changed(state_name: StringName) -> void:
	state_label.text = "PHASE %s  |  %s" % ["II" if boss.is_phase_02() else "I",String(state_name).to_upper()]


func _on_phase_changed(phase: int) -> void:
	poise_bar.max_value = boss.config.phase_02_max_poise if phase == 2 else boss.config.max_poise
	name_label.text = (
		"THE HOLLOW PONTIFF, BELL-BOUND / 钟缚空教宗·埃德兰"
		if phase == 2
		else "%s / %s" % [boss.config.display_name_en,boss.config.display_name_zh]
	)
	_on_state_changed(boss.get_state_name())


func _on_activated() -> void:
	visible = true


func _on_defeated() -> void:
	visible = false
