class_name SoulGaolerOrmundHUD
extends Control

@export_node_path("SoulGaolerOrmund") var boss_path: NodePath = NodePath("../../CharacterTrial/OrmundBossEncounter/Enemies/SoulGaolerOrmund")

@onready var name_label: Label = $Panel/Name
@onready var phase_label: Label = $Panel/Phase
@onready var health_bar: ProgressBar = $Panel/HealthBar
@onready var health_value: Label = $Panel/HealthValue

var boss: SoulGaolerOrmund


func _ready() -> void:
	boss = get_node_or_null(boss_path) as SoulGaolerOrmund
	if boss == null:
		push_error("SoulGaolerOrmundHUD cannot resolve Boss")
		visible = false
		return
	boss.health_component.health_changed.connect(_on_health_changed)
	boss.phase_changed.connect(_on_phase_changed)
	boss.tree_exiting.connect(_on_boss_exiting)
	health_bar.max_value = boss.health_component.max_health
	_on_health_changed(boss.health_component.current_health, boss.health_component.max_health)
	_on_phase_changed(boss.phase)
	visible = false


func _process(_delta: float) -> void:
	if boss != null and is_instance_valid(boss):
		visible = boss.target != null and not boss.is_dead()


func _on_health_changed(current: int, maximum: int) -> void:
	health_bar.max_value = maximum
	health_bar.value = current
	health_value.text = "%d / %d" % [current, maximum]


func _on_phase_changed(phase: int) -> void:
	phase_label.text = "PHASE %d · %s" % [phase, "THE BROKEN CAGE" if phase == 2 else "THE LAST GAOLER"]


func _on_boss_exiting() -> void:
	boss = null
	visible = false
