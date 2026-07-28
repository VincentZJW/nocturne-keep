class_name Chapter02WallSconce
extends Node2D

## Pauses the two tiny flame sprites while this reusable fixture is off-screen.

@export_node_path("AnimatedSprite2D") var left_flame_path: NodePath = NodePath("LeftFlame")
@export_node_path("AnimatedSprite2D") var right_flame_path: NodePath = NodePath("RightFlame")
@export_node_path("VisibleOnScreenNotifier2D") var notifier_path: NodePath = NodePath("VisibilityNotifier")

@onready var left_flame: AnimatedSprite2D = get_node_or_null(left_flame_path) as AnimatedSprite2D
@onready var right_flame: AnimatedSprite2D = get_node_or_null(right_flame_path) as AnimatedSprite2D
@onready var notifier: VisibleOnScreenNotifier2D = get_node_or_null(
	self.notifier_path
) as VisibleOnScreenNotifier2D


func _ready() -> void:
	if left_flame == null or right_flame == null or notifier == null:
		push_error("Chapter02WallSconce scene composition is incomplete")
		return
	notifier.screen_entered.connect(_set_flames_playing.bind(true))
	notifier.screen_exited.connect(_set_flames_playing.bind(false))
	_set_flames_playing(notifier.is_on_screen())


func _set_flames_playing(playing: bool) -> void:
	if playing:
		left_flame.play(&"burn")
		right_flame.play(&"burn")
	else:
		left_flame.pause()
		right_flame.pause()
