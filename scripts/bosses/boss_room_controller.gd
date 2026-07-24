class_name BossRoomController
extends Node

## Owns arena entry, gates, checkpoint selection, Boss reset, and level completion.

signal room_locked
signal room_reset
signal room_cleared
signal level_completed

@export_node_path("Player") var player_path: NodePath = NodePath("../World/Player")
@export_node_path("FallenGateKnight") var boss_path: NodePath = NodePath("../World/BossRoom/FallenGateKnight")
@export_node_path("Area2D") var entry_trigger_path: NodePath = NodePath("../World/BossRoom/EntryTrigger")
@export_node_path("Area2D") var exit_trigger_path: NodePath = NodePath("../World/BossRoom/ExitTrigger")
@export_node_path("StaticBody2D") var entrance_gate_path: NodePath = NodePath("../World/BossRoom/EntranceGate")
@export_node_path("StaticBody2D") var exit_gate_path: NodePath = NodePath("../World/BossRoom/ExitGate")
@export_node_path("Marker2D") var checkpoint_path: NodePath = NodePath("../World/BossRoom/BossCheckpoint")
@export_node_path("PlayerRespawnController") var respawn_controller_path: NodePath = NodePath("../PlayerRespawnController")
@export_node_path("BossHealthHud") var boss_hud_path: NodePath = NodePath("../HUD/BossHealthHud")
@export_node_path("Control") var victory_panel_path: NodePath = NodePath("../HUD/LevelCompletePanel")

@onready var player: Player = get_node_or_null(player_path) as Player
@onready var boss: FallenGateKnight = get_node_or_null(boss_path) as FallenGateKnight
@onready var entry_trigger: Area2D = get_node_or_null(entry_trigger_path) as Area2D
@onready var exit_trigger: Area2D = get_node_or_null(exit_trigger_path) as Area2D
@onready var entrance_gate: StaticBody2D = get_node_or_null(entrance_gate_path) as StaticBody2D
@onready var exit_gate: StaticBody2D = get_node_or_null(exit_gate_path) as StaticBody2D
@onready var checkpoint: Marker2D = get_node_or_null(checkpoint_path) as Marker2D
@onready var respawn_controller: PlayerRespawnController = get_node_or_null(respawn_controller_path) as PlayerRespawnController
@onready var boss_hud: BossHealthHud = get_node_or_null(boss_hud_path) as BossHealthHud
@onready var victory_panel: Control = get_node_or_null(victory_panel_path) as Control

var room_is_locked: bool = false
var room_is_cleared: bool = false
var encounter_started: bool = false


func _ready() -> void:
	if not _validate_dependencies():
		return
	entry_trigger.body_entered.connect(_on_entry_body_entered)
	exit_trigger.body_entered.connect(_on_exit_body_entered)
	boss.boss_defeated.connect(_on_boss_defeated)
	respawn_controller.player_respawned.connect(_on_player_respawned)
	boss_hud.bind_boss(boss)
	victory_panel.visible = false
	_set_gate_open(entrance_gate, true)
	_set_gate_open(exit_gate, false)
	exit_trigger.set_deferred("monitoring", false)


func _on_entry_body_entered(body: Node2D) -> void:
	if body != player or encounter_started or room_is_cleared:
		return
	encounter_started = true
	room_is_locked = true
	respawn_controller.set_spawn_point(checkpoint)
	player.health_component.reset_to_full()
	player.stamina_component.reset_to_full()
	_set_gate_open(entrance_gate, false)
	_set_gate_open(exit_gate, false)
	entry_trigger.set_deferred("monitoring", false)
	boss.activate(player)
	room_locked.emit()


func _on_boss_defeated() -> void:
	if room_is_cleared:
		return
	room_is_cleared = true
	room_is_locked = false
	_set_gate_open(entrance_gate, true)
	_set_gate_open(exit_gate, true)
	exit_trigger.set_deferred("monitoring", true)
	victory_panel.visible = true
	var label: Label = victory_panel.get_node_or_null("Message") as Label
	if label != null:
		label.text = "The gate is open. / 大门已经开启。"
	room_cleared.emit()


func _on_player_respawned(_spawn_position: Vector2) -> void:
	if not encounter_started or room_is_cleared:
		return
	boss.reset_boss()
	encounter_started = false
	room_is_locked = false
	_set_gate_open(entrance_gate, true)
	_set_gate_open(exit_gate, false)
	entry_trigger.set_deferred("monitoring", true)
	exit_trigger.set_deferred("monitoring", false)
	boss_hud.hide_immediately()
	room_reset.emit()


func _on_exit_body_entered(body: Node2D) -> void:
	if body != player or not room_is_cleared:
		return
	var label: Label = victory_panel.get_node_or_null("Message") as Label
	if label != null:
		label.text = "LEVEL COMPLETE / 第一关完成"
	victory_panel.visible = true
	level_completed.emit()


func _set_gate_open(gate: StaticBody2D, open: bool) -> void:
	gate.visible = not open
	gate.collision_layer = 0 if open else 1
	for child: Node in gate.get_children():
		var shape: CollisionShape2D = child as CollisionShape2D
		if shape != null:
			shape.set_deferred("disabled", open)


func _validate_dependencies() -> bool:
	if player == null or boss == null or entry_trigger == null or exit_trigger == null or entrance_gate == null or exit_gate == null or checkpoint == null or respawn_controller == null or boss_hud == null or victory_panel == null:
		push_error("BossRoomController scene composition is incomplete")
		return false
	return true
