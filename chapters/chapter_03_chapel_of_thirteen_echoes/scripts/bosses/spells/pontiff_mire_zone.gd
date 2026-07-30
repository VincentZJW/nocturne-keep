class_name PontiffMireZone
extends Area2D

signal expired

@export var duration: float = 4.5
@export var movement_multiplier: float = 0.35
@export var dash_multiplier: float = 0.70

@onready var zone_sprite: AnimatedSprite2D = $ZoneSprite as AnimatedSprite2D

var _remaining: float = 0.0
var _source_id: StringName = &""
var _players_inside: Array[Player] = []
var _ending: bool = false


func _ready() -> void:
	_remaining = duration
	_source_id = StringName("edran_mire_%d" % get_instance_id())
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	zone_sprite.play(&"active")


func _physics_process(delta: float) -> void:
	if _ending:
		return
	_remaining = maxf(0.0, _remaining - delta)
	for player: Player in _players_inside.duplicate():
		if not is_instance_valid(player):
			_players_inside.erase(player)
			continue
		if player.status_effect_controller != null:
			player.status_effect_controller.apply_mire(
				_source_id, 0.12, movement_multiplier, dash_multiplier
			)
	if is_zero_approx(_remaining):
		_end_zone()


func get_remaining() -> float:
	return _remaining


func force_expire() -> void:
	_end_zone()


func _on_body_entered(body: Node2D) -> void:
	var player: Player = body as Player
	if player == null or player in _players_inside:
		return
	_players_inside.append(player)
	if player.status_effect_controller != null:
		player.status_effect_controller.apply_mire(_source_id, 0.12, movement_multiplier, dash_multiplier)


func _on_body_exited(body: Node2D) -> void:
	var player: Player = body as Player
	if player == null:
		return
	_players_inside.erase(player)
	if is_instance_valid(player.status_effect_controller):
		player.status_effect_controller.clear_effect(PlayerStatusEffectController.MIRE_SLOW, _source_id)


func _end_zone() -> void:
	if _ending:
		return
	_ending = true
	set_deferred("monitoring", false)
	for player: Player in _players_inside:
		if is_instance_valid(player) and player.status_effect_controller != null:
			player.status_effect_controller.clear_effect(PlayerStatusEffectController.MIRE_SLOW, _source_id)
	_players_inside.clear()
	var disappear_frames: SpriteFrames = load(
		"res://chapters/chapter_03_chapel_of_thirteen_echoes/assets/bosses/thirteenth_pontiff_edran/effects/mire/disappear/disappear_frames.tres"
	) as SpriteFrames
	if disappear_frames != null:
		zone_sprite.sprite_frames = disappear_frames
		zone_sprite.play(&"active")
	await get_tree().create_timer(0.36).timeout
	expired.emit()
	queue_free()
