class_name DuchessReliquary
extends Node2D

## Persistent presentation shell; pickup/inventory ownership remains in the transition controller.

signal pickup_requested

@export_node_path("Node2D") var weapon_display_path: NodePath = NodePath("WeaponDisplay")
@export_node_path("Marker2D") var pickup_anchor_path: NodePath = NodePath("WeaponDisplay/PickupAnchor")
@export_node_path("Area2D") var interaction_area_path: NodePath = NodePath("InteractionArea")
@export_node_path("Label") var prompt_path: NodePath = NodePath("InteractionPrompt")
@export_node_path("ReliquaryCandleFlames") var candle_flames_path: NodePath = NodePath("CandleFlames")

@onready var weapon_display: Node2D = get_node_or_null(weapon_display_path) as Node2D
@onready var pickup_anchor: Marker2D = get_node_or_null(pickup_anchor_path) as Marker2D
@onready var interaction_area: Area2D = get_node_or_null(interaction_area_path) as Area2D
@onready var prompt: Label = get_node_or_null(prompt_path) as Label
@onready var candle_flames: ReliquaryCandleFlames = get_node_or_null(
	candle_flames_path
) as ReliquaryCandleFlames

var is_unlocked: bool = false
var is_collected: bool = false
var _player_in_range: Player
var unlock_progress: float = 0.0:
	set(value):
		unlock_progress = clampf(value, 0.0, 1.0)
		queue_redraw()


func _ready() -> void:
	if (
		weapon_display == null or pickup_anchor == null or interaction_area == null
		or prompt == null or candle_flames == null
	):
		push_error("DuchessReliquary scene composition is incomplete")
		return
	interaction_area.body_entered.connect(_on_body_entered)
	interaction_area.body_exited.connect(_on_body_exited)
	prompt.visible = false
	candle_flames.set_active(false)


func _unhandled_input(event: InputEvent) -> void:
	if (
		not is_unlocked or is_collected or _player_in_range == null
		or _player_in_range.is_dead() or not event.is_action_pressed("interact")
	):
		return
	pickup_requested.emit()
	get_viewport().set_input_as_handled()


func set_unlocked(unlocked: bool, immediate: bool = false) -> void:
	is_unlocked = unlocked
	if candle_flames != null:
		candle_flames.set_active(unlocked)
	if not unlocked:
		unlock_progress = 0.0
		_update_prompt()
		return
	if immediate:
		unlock_progress = 1.0
		return
	var tween: Tween = create_tween()
	tween.tween_property(self, "unlock_progress", 1.0, 0.72).set_trans(Tween.TRANS_SINE)
	_update_prompt()


func set_collected(collected: bool) -> void:
	is_collected = collected
	if weapon_display != null:
		weapon_display.visible = not collected
	_update_prompt()
	queue_redraw()


func get_interaction_radius() -> float:
	var shape_node: CollisionShape2D = interaction_area.get_node_or_null(
		"CollisionShape2D"
	) as CollisionShape2D if interaction_area != null else null
	var circle: CircleShape2D = shape_node.shape as CircleShape2D if shape_node != null else null
	return circle.radius if circle != null else 0.0


func _on_body_entered(body: Node2D) -> void:
	var player: Player = body as Player
	if player == null:
		return
	_player_in_range = player
	_update_prompt()


func _on_body_exited(body: Node2D) -> void:
	if body != _player_in_range:
		return
	_player_in_range = null
	_update_prompt()


func _update_prompt() -> void:
	if prompt == null:
		return
	prompt.visible = is_unlocked and not is_collected and _player_in_range != null


func _draw() -> void:
	# Compact stone-and-dark-oak court pedestal, slightly taller than the Player.
	draw_rect(Rect2(-86, -18, 172, 18), Color("38343b"), true)
	draw_rect(Rect2(-76, -76, 152, 58), Color("21191f"), true)
	draw_rect(Rect2(-68, -70, 136, 46), Color("3b252b"), true)
	draw_rect(Rect2(-88, -90, 176, 18), Color("5a4a3f"), true)
	draw_line(Vector2(-78, -84), Vector2(78, -84), Color("9a7d4b"), 3.0)
	var backplate: PackedVector2Array = PackedVector2Array([
		Vector2(-66, -88), Vector2(-66, -117), Vector2(-42, -140),
		Vector2(0, -151), Vector2(42, -140), Vector2(66, -117), Vector2(66, -88),
	])
	draw_colored_polygon(backplate, Color("18131b"))
	draw_polyline(backplate, Color("75603d"), 4.0, true)
	draw_circle(Vector2(0, -138), 9.0, Color("8b7043"))
	draw_arc(Vector2(0, -136), 5.0, PI, TAU, 12, Color("1b171d"), 2.0)
	# Small candles flank the pedestal without becoming foreground blockers.
	for side: int in [-1, 1]:
		var x: float = float(side) * 98.0
		draw_rect(Rect2(x - 3, -69, 6, 45), Color("b5a18a"), true)
		draw_rect(Rect2(x - 9, -25, 18, 5), Color("66513b"), true)
	if not is_unlocked:
		draw_circle(Vector2(0, -111), 24.0, Color(0.30, 0.08, 0.20, 0.46))
		draw_line(Vector2(-52, -128), Vector2(52, -94), Color("7c3553"), 3.0)
		draw_line(Vector2(-52, -94), Vector2(52, -128), Color("7c3553"), 3.0)
	elif unlock_progress < 1.0:
		for spark: int in range(6):
			var angle: float = TAU * float(spark) / 6.0
			draw_circle(Vector2(0, -111) + Vector2(34.0, 20.0).rotated(angle) * unlock_progress, 2.0, Color("d7c1a0"))
	if is_collected:
		draw_string(ThemeDB.fallback_font, Vector2(-55, -103), "EMPTY", HORIZONTAL_ALIGNMENT_CENTER, 110, 10, Color(0.66, 0.61, 0.58, 0.72))
