class_name Chapter03BossGate
extends Node2D

## Chapter-local threshold controller. It owns only presentation and emits a
## typed request; the level authority performs the collision-safe teleport.

signal crossing_requested(player: Player)
signal gate_sequence_finished

@export_range(0.02, 0.20, 0.01) var bell_step_duration: float = 0.06
@export_range(0.10, 1.00, 0.05) var door_open_duration: float = 0.55
@export_range(0.10, 1.00, 0.05) var fade_duration: float = 0.35
@export var auto_trigger: bool = true
@export var use_internal_fade: bool = true

@onready var trigger: Area2D = $GateTrigger as Area2D
@onready var blocker: CollisionShape2D = $GateBlocker/CollisionShape2D as CollisionShape2D
@onready var closed_sprite: Sprite2D = $Visuals/GateClosed as Sprite2D
@onready var lit_sprite: Sprite2D = $Visuals/GateLit as Sprite2D
@onready var open_sprite: Sprite2D = $Visuals/GateOpen as Sprite2D
@onready var bells: Node2D = $Visuals/Bells as Node2D
@onready var seal_lights: Node2D = $Visuals/SealLights as Node2D
@onready var wax_crack: Sprite2D = $Visuals/WaxCrack as Sprite2D
@onready var fade_rect: ColorRect = $TransitionFade/Fade as ColorRect
@onready var bell_audio: AudioStreamPlayer2D = $Audio/BellSequence as AudioStreamPlayer2D
@onready var wax_audio: AudioStreamPlayer2D = $Audio/WaxBreak as AudioStreamPlayer2D
@onready var door_audio: AudioStreamPlayer2D = $Audio/DoorOpen as AudioStreamPlayer2D
@onready var interaction_prompt: Label = $InteractionPrompt as Label

var _is_open: bool = false
var _sequence_running: bool = false
var _player_in_range: Player = null


func _ready() -> void:
	trigger.body_entered.connect(_on_trigger_body_entered)
	trigger.body_exited.connect(_on_trigger_body_exited)
	_reset_visuals()
	interaction_prompt.visible = false


func _unhandled_input(event: InputEvent) -> void:
	if (
		not auto_trigger
		and event.is_action_pressed(&"interact")
		and _player_in_range != null
		and _player_in_range.can_process_gameplay_interaction()
		and not _is_open
		and not _sequence_running
	):
		run_sequence_for_player(_player_in_range)
		get_viewport().set_input_as_handled()


func open_immediately() -> void:
	_sequence_running = false
	_is_open = true
	closed_sprite.visible = false
	lit_sprite.visible = false
	open_sprite.visible = true
	wax_crack.visible = false
	blocker.set_deferred("disabled", true)
	fade_rect.visible = false
	fade_rect.modulate.a = 0.0
	for child: Node in seal_lights.get_children():
		(child as CanvasItem).visible = true


func reset_gate() -> void:
	_is_open = false
	_sequence_running = false
	blocker.set_deferred("disabled", false)
	_reset_visuals()


func run_sequence_for_player(player: Player) -> void:
	if _sequence_running or _is_open or player == null:
		return
	_sequence_running = true
	interaction_prompt.visible = false
	player.set_input_profile(Player.InputProfile.LOCKED)
	player.velocity = Vector2.ZERO
	var bell_nodes: Array[Node] = bells.get_children()
	var seal_nodes: Array[Node] = seal_lights.get_children()
	bell_audio.play()
	for index: int in range(mini(bell_nodes.size(), seal_nodes.size())):
		var bell: Sprite2D = bell_nodes[index] as Sprite2D
		var seal: CanvasItem = seal_nodes[index] as CanvasItem
		seal.visible = true
		var bell_tween: Tween = create_tween()
		bell_tween.tween_property(bell, "rotation", deg_to_rad(9.0), bell_step_duration * 0.5)
		bell_tween.tween_property(bell, "rotation", deg_to_rad(-7.0), bell_step_duration * 0.5)
		bell_tween.tween_property(bell, "rotation", 0.0, bell_step_duration * 0.35)
		await get_tree().create_timer(bell_step_duration).timeout
	closed_sprite.visible = false
	lit_sprite.visible = true
	wax_crack.visible = true
	wax_crack.modulate.a = 0.0
	wax_audio.play()
	var crack_tween: Tween = create_tween()
	crack_tween.tween_property(wax_crack, "modulate:a", 1.0, 0.12)
	await crack_tween.finished
	door_audio.play()
	var open_tween: Tween = create_tween()
	open_tween.tween_property(lit_sprite, "modulate:a", 0.0, door_open_duration)
	open_tween.parallel().tween_property(open_sprite, "modulate:a", 1.0, door_open_duration)
	await open_tween.finished
	lit_sprite.visible = false
	open_sprite.visible = true
	blocker.set_deferred("disabled", true)
	_is_open = true
	if use_internal_fade:
		fade_rect.visible = true
		fade_rect.modulate.a = 0.0
		var fade_out: Tween = create_tween()
		fade_out.tween_property(fade_rect, "modulate:a", 1.0, fade_duration)
		await fade_out.finished
		crossing_requested.emit(player)
		await get_tree().physics_frame
		var fade_in: Tween = create_tween()
		fade_in.tween_property(fade_rect, "modulate:a", 0.0, fade_duration)
		await fade_in.finished
		fade_rect.visible = false
		player.set_input_profile(Player.InputProfile.FULL)
	else:
		crossing_requested.emit(player)
	_sequence_running = false
	gate_sequence_finished.emit()


func is_gate_open() -> bool:
	return _is_open


func _on_trigger_body_entered(body: Node2D) -> void:
	var player: Player = body as Player
	if player == null:
		return
	_player_in_range = player
	if auto_trigger:
		run_sequence_for_player(player)
	elif not _is_open and not _sequence_running:
		interaction_prompt.visible = true


func _on_trigger_body_exited(body: Node2D) -> void:
	if body != _player_in_range:
		return
	_player_in_range = null
	interaction_prompt.visible = false


func _reset_visuals() -> void:
	closed_sprite.visible = true
	closed_sprite.modulate.a = 1.0
	lit_sprite.visible = false
	lit_sprite.modulate.a = 1.0
	open_sprite.visible = true
	open_sprite.modulate.a = 0.0
	wax_crack.visible = false
	interaction_prompt.visible = false
	fade_rect.visible = false
	fade_rect.modulate.a = 0.0
	for child: Node in seal_lights.get_children():
		(child as CanvasItem).visible = false
