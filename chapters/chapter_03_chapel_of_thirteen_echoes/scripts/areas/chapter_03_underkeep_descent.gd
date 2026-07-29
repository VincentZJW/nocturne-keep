class_name Chapter03UnderkeepDescent
extends Node2D

## Chapter III terminal. It intentionally refuses to load Chapter IV until the
## registered planned scene actually exists.

signal chapter_four_transition_requested(player: Player)

const CHAPTER_FOUR_SCENE: String = (
	"res://chapters/chapter_04_drowned_underkeep/scenes/level/drowned_underkeep.tscn"
)

@onready var exit_area: Area2D = $ChapterFourExitArea as Area2D
@onready var prompt: Label = $TransitionPrompt as Label
@onready var water_drip: AudioStreamPlayer2D = $WaterDrip as AudioStreamPlayer2D
@onready var water_drip_timer: Timer = $WaterDripTimer as Timer

var _player_in_range: Player = null


func _ready() -> void:
	exit_area.body_entered.connect(_on_body_entered)
	exit_area.body_exited.connect(_on_body_exited)
	water_drip_timer.timeout.connect(_on_water_drip_timer_timeout)
	prompt.visible = false


func _unhandled_input(event: InputEvent) -> void:
	if not event.is_action_pressed(&"interact") or _player_in_range == null:
		return
	if ResourceLoader.exists(CHAPTER_FOUR_SCENE, "PackedScene"):
		chapter_four_transition_requested.emit(_player_in_range)
	else:
		prompt.text = "CHAPTER IV · DROWNED UNDERKEEP — PLANNED / 第四章·淹没地牢尚未开放"
	get_viewport().set_input_as_handled()


func _on_body_entered(body: Node2D) -> void:
	var player: Player = body as Player
	if player == null:
		return
	_player_in_range = player
	prompt.text = "E · DESCEND TO THE DROWNED UNDERKEEP / 下行至淹没地牢"
	prompt.visible = true


func _on_body_exited(body: Node2D) -> void:
	if body == _player_in_range:
		_player_in_range = null
		prompt.visible = false


func _on_water_drip_timer_timeout() -> void:
	water_drip.play()
