class_name PlayerDeathSequence
extends Node

## Presentation-only death sequence: body fall, ghost rise, pause, then completion.

signal sequence_started
signal body_animation_completed
signal ghost_emerged
signal ghost_pause_started(duration: float)
signal sequence_completed

enum Phase {
	IDLE,
	BODY_FALL,
	GHOST_EMERGE,
	GHOST_PAUSE,
}

const DEATH_ANIMATION: StringName = &"death"

@export_range(0.05, 2.0, 0.05) var ghost_emerge_duration: float = 0.35
@export_range(0.0, 2.0, 0.05) var ghost_pause_duration: float = 0.50
@export_range(8.0, 16.0, 1.0) var ghost_rise_distance: float = 14.0
@export var ghost_start_offset: Vector2 = Vector2(0.0, 7.0)
@export_node_path("Player") var player_path: NodePath = NodePath("..")
@export_node_path("PlayerAnimationController") var animation_controller_path: NodePath = NodePath(
	"../AnimationController"
)
@export_node_path("Sprite2D") var ghost_sprite_path: NodePath = NodePath(
	"../VisualRoot/DeathEffects/GhostSprite"
)

@onready var player: Player = get_node_or_null(player_path) as Player
@onready var animation_controller: PlayerAnimationController = get_node_or_null(
	animation_controller_path
) as PlayerAnimationController
@onready var ghost_sprite: Sprite2D = get_node_or_null(ghost_sprite_path) as Sprite2D

var _phase: Phase = Phase.IDLE
var _sequence_generation: int = 0
var _ghost_tween: Tween


func _ready() -> void:
	if player == null:
		push_error("PlayerDeathSequence requires a Player target")
		return
	if animation_controller == null:
		push_error("PlayerDeathSequence requires a PlayerAnimationController")
		return
	if ghost_sprite == null:
		push_error("PlayerDeathSequence requires a GhostSprite")
		return
	_reset_presentation()
	player.death_state_entered.connect(_on_player_death_state_entered)
	player.respawned.connect(_on_player_respawned)
	animation_controller.one_shot_finished.connect(_on_one_shot_finished)


func _exit_tree() -> void:
	if player != null and is_instance_valid(player):
		if player.death_state_entered.is_connected(_on_player_death_state_entered):
			player.death_state_entered.disconnect(_on_player_death_state_entered)
		if player.respawned.is_connected(_on_player_respawned):
			player.respawned.disconnect(_on_player_respawned)
	if (
		animation_controller != null
		and is_instance_valid(animation_controller)
		and animation_controller.one_shot_finished.is_connected(_on_one_shot_finished)
	):
		animation_controller.one_shot_finished.disconnect(_on_one_shot_finished)
	_cancel_ghost_tween()


func start_sequence() -> bool:
	if is_active() or animation_controller == null or ghost_sprite == null:
		return false
	_sequence_generation += 1
	_phase = Phase.BODY_FALL
	_reset_ghost_visual()
	animation_controller.reset_to_idle()
	if not animation_controller.play_one_shot(DEATH_ANIMATION):
		_phase = Phase.IDLE
		push_error("PlayerDeathSequence could not start the death animation")
		return false
	sequence_started.emit()
	return true


func is_active() -> bool:
	return _phase != Phase.IDLE


func get_phase_name() -> StringName:
	match _phase:
		Phase.BODY_FALL:
			return &"BodyFall"
		Phase.GHOST_EMERGE:
			return &"GhostEmerge"
		Phase.GHOST_PAUSE:
			return &"GhostPause"
	return &"Idle"


func get_ghost_end_position() -> Vector2:
	return ghost_start_offset + Vector2.UP * ghost_rise_distance


func _on_player_death_state_entered() -> void:
	start_sequence()


func _on_player_respawned(_global_spawn_position: Vector2) -> void:
	_sequence_generation += 1
	_reset_presentation()


func _on_one_shot_finished(animation_name: StringName) -> void:
	if animation_name != DEATH_ANIMATION or _phase != Phase.BODY_FALL:
		return
	body_animation_completed.emit()
	_run_ghost_sequence()


func _run_ghost_sequence() -> void:
	var generation: int = _sequence_generation
	_phase = Phase.GHOST_EMERGE
	ghost_sprite.position = ghost_start_offset
	ghost_sprite.modulate = Color(1.0, 1.0, 1.0, 0.18)
	ghost_sprite.visible = true
	_ghost_tween = create_tween()
	_ghost_tween.set_parallel(true)
	_ghost_tween.set_trans(Tween.TRANS_SINE)
	_ghost_tween.set_ease(Tween.EASE_OUT)
	_ghost_tween.tween_property(
		ghost_sprite, "position", get_ghost_end_position(), ghost_emerge_duration
	)
	_ghost_tween.tween_property(ghost_sprite, "modulate:a", 1.0, ghost_emerge_duration)
	await _ghost_tween.finished
	if generation != _sequence_generation or _phase != Phase.GHOST_EMERGE:
		return
	_ghost_tween = null
	_phase = Phase.GHOST_PAUSE
	ghost_emerged.emit()
	ghost_pause_started.emit(ghost_pause_duration)
	await get_tree().create_timer(ghost_pause_duration, false).timeout
	if generation != _sequence_generation or _phase != Phase.GHOST_PAUSE:
		return
	ghost_sprite.visible = false
	_phase = Phase.IDLE
	sequence_completed.emit()


func _reset_presentation() -> void:
	_cancel_ghost_tween()
	_phase = Phase.IDLE
	_reset_ghost_visual()


func _reset_ghost_visual() -> void:
	if ghost_sprite == null:
		return
	ghost_sprite.visible = false
	ghost_sprite.position = ghost_start_offset
	ghost_sprite.modulate = Color.WHITE


func _cancel_ghost_tween() -> void:
	if _ghost_tween != null and _ghost_tween.is_valid():
		_ghost_tween.kill()
	_ghost_tween = null
