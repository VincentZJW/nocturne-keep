class_name BossRoomController
extends Node

## Coordinates the saved Main bridge encounter without owning Player or Boss combat data.

signal room_locked
signal room_reset
signal room_cleared
signal level_completed

@export_node_path("Player") var player_path: NodePath = NodePath("../World/Player")
@export_node_path("FallenGateKnight") var boss_path: NodePath = NodePath(
	"../World/CastleEntranceArea/FallenGateKnight"
)
@export_node_path("Area2D") var checkpoint_trigger_path: NodePath = NodePath(
	"../World/CastleEntranceArea/BossCheckpointTrigger"
)
@export_node_path("Area2D") var entry_trigger_path: NodePath = NodePath(
	"../World/CastleEntranceArea/BossEntryTrigger"
)
@export_node_path("Area2D") var castle_entrance_trigger_path: NodePath = NodePath(
	"../World/CastleEntranceArea/CastleEntranceTrigger"
)
@export_node_path("StaticBody2D") var rear_barrier_path: NodePath = NodePath(
	"../World/CastleEntranceArea/RearBattleBarrier"
)
@export_node_path("CastleGateController") var castle_gate_controller_path: NodePath = NodePath(
	"../World/CastleEntranceArea/CastleGate/GateAnimationPlayer"
)
@export_node_path("Marker2D") var checkpoint_path: NodePath = NodePath(
	"../World/CastleEntranceArea/BossCheckpoint"
)
@export_node_path("PlayerRespawnController") var respawn_controller_path: NodePath = NodePath(
	"../PlayerRespawnController"
)
@export_node_path("BossHealthHud") var boss_hud_path: NodePath = NodePath("../HUD/BossHealthHud")
@export_node_path("CastleEntranceTransition") var entrance_transition_path: NodePath = NodePath(
	"../CastleEntranceTransition"
)
@export var boss_camera_limit_left: int = 5340
@export var boss_camera_limit_right: int = 6620

@onready var player: Player = get_node_or_null(player_path) as Player
@onready var boss: FallenGateKnight = get_node_or_null(boss_path) as FallenGateKnight
@onready var checkpoint_trigger: Area2D = get_node_or_null(checkpoint_trigger_path) as Area2D
@onready var entry_trigger: Area2D = get_node_or_null(entry_trigger_path) as Area2D
@onready var castle_entrance_trigger: Area2D = get_node_or_null(
	castle_entrance_trigger_path
) as Area2D
@onready var rear_barrier: StaticBody2D = get_node_or_null(rear_barrier_path) as StaticBody2D
@onready var castle_gate_controller: CastleGateController = get_node_or_null(
	castle_gate_controller_path
) as CastleGateController
@onready var checkpoint: Marker2D = get_node_or_null(checkpoint_path) as Marker2D
@onready var respawn_controller: PlayerRespawnController = get_node_or_null(
	respawn_controller_path
) as PlayerRespawnController
@onready var boss_hud: BossHealthHud = get_node_or_null(boss_hud_path) as BossHealthHud
@onready var entrance_transition: CastleEntranceTransition = get_node_or_null(
	entrance_transition_path
) as CastleEntranceTransition

var room_is_locked: bool = false
var room_is_cleared: bool = false
var encounter_started: bool = false
var gate_open_complete: bool = false
var _default_camera_left: int = 0
var _default_camera_right: int = 0


func _ready() -> void:
	if not _validate_dependencies():
		return
	checkpoint_trigger.body_entered.connect(_on_checkpoint_body_entered)
	entry_trigger.body_entered.connect(_on_entry_body_entered)
	castle_entrance_trigger.body_entered.connect(_on_castle_entrance_body_entered)
	boss.boss_defeated.connect(_on_boss_defeated)
	respawn_controller.player_respawned.connect(_on_player_respawned)
	castle_gate_controller.gate_opened.connect(_on_castle_gate_opened)
	boss_hud.bind_boss(boss)
	_default_camera_left = player.player_camera.limit_left
	_default_camera_right = player.player_camera.limit_right
	_set_rear_barrier_closed(false)
	castle_gate_controller.close_gate()
	castle_entrance_trigger.set_deferred("monitoring", false)


func _on_checkpoint_body_entered(body: Node2D) -> void:
	if body != player:
		return
	respawn_controller.set_spawn_point(checkpoint)
	if not encounter_started and not room_is_cleared:
		player.health_component.reset_to_full()
		player.stamina_component.reset_to_full()


func _on_entry_body_entered(body: Node2D) -> void:
	if body != player or encounter_started or room_is_cleared:
		return
	encounter_started = true
	room_is_locked = true
	respawn_controller.set_spawn_point(checkpoint)
	player.health_component.reset_to_full()
	player.stamina_component.reset_to_full()
	_set_rear_barrier_closed(true)
	castle_gate_controller.close_gate()
	entry_trigger.set_deferred("monitoring", false)
	_lock_camera_to_bridge()
	boss.activate(player)
	room_locked.emit()


func _on_boss_defeated() -> void:
	if room_is_cleared:
		return
	room_is_cleared = true
	room_is_locked = false
	gate_open_complete = false
	_set_rear_barrier_closed(false)
	_release_camera_limits()
	castle_gate_controller.open_gate()
	room_cleared.emit()


func _on_castle_gate_opened() -> void:
	gate_open_complete = true
	castle_entrance_trigger.set_deferred("monitoring", true)


func _on_player_respawned(_spawn_position: Vector2) -> void:
	if not encounter_started or room_is_cleared:
		return
	boss.reset_boss()
	encounter_started = false
	room_is_locked = false
	gate_open_complete = false
	_set_rear_barrier_closed(false)
	castle_gate_controller.close_gate()
	entry_trigger.set_deferred("monitoring", true)
	castle_entrance_trigger.set_deferred("monitoring", false)
	_release_camera_limits()
	boss_hud.hide_immediately()
	room_reset.emit()


func _on_castle_entrance_body_entered(body: Node2D) -> void:
	if body != player or not room_is_cleared or not gate_open_complete:
		return
	level_completed.emit()
	entrance_transition.begin_transition()


func _set_rear_barrier_closed(closed: bool) -> void:
	rear_barrier.visible = closed
	rear_barrier.collision_layer = 1 if closed else 0
	var collision: CollisionShape2D = rear_barrier.get_node_or_null(
		"BarrierCollision"
	) as CollisionShape2D
	if collision != null:
		collision.set_deferred("disabled", not closed)


func _lock_camera_to_bridge() -> void:
	player.player_camera.limit_left = boss_camera_limit_left
	player.player_camera.limit_right = boss_camera_limit_right
	player.player_camera.reset_smoothing()


func _release_camera_limits() -> void:
	player.player_camera.limit_left = _default_camera_left
	player.player_camera.limit_right = _default_camera_right
	player.player_camera.reset_smoothing()


func _validate_dependencies() -> bool:
	if (
		player == null
		or boss == null
		or checkpoint_trigger == null
		or entry_trigger == null
		or castle_entrance_trigger == null
		or rear_barrier == null
		or castle_gate_controller == null
		or checkpoint == null
		or respawn_controller == null
		or boss_hud == null
		or entrance_transition == null
	):
		push_error("BossRoomController scene composition is incomplete")
		return false
	return true
