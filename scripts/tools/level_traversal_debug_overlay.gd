class_name LevelTraversalDebugOverlay
extends Label

## Optional read-only Main traversal telemetry. F4 toggles it; it never owns physics.

const TOGGLE_ACTION: StringName = &"debug_toggle_level_traversal"
const MAIN_ROUTE_LIMIT: float = 133.68
const CHALLENGE_LIMIT: float = 150.39
const HIDDEN_LIMIT: float = 158.75

@export var debug_visible: bool = false
@export_node_path("Player") var player_path: NodePath = NodePath("../../../World/Player")
@export_node_path("Node2D") var world_path: NodePath = NodePath("../../../World")

@onready var player: Player = get_node_or_null(player_path) as Player
@onready var world: Node2D = get_node_or_null(world_path) as Node2D

var _surfaces: Array[StaticBody2D] = []
var _was_on_floor: bool = true
var _jump_start_foot_y: float = 0.0
var _jump_start_x: float = 0.0
var _current_max_rise: float = 0.0
var _single_jump_max_rise: float = 0.0
var _double_jump_max_rise: float = 0.0
var _used_double_jump: bool = false


func _ready() -> void:
	if player == null or world == null:
		push_error("LevelTraversalDebugOverlay requires Main World and Player")
		set_process(false)
		set_process_unhandled_input(false)
		return
	_collect_surfaces()
	player.double_jump_performed.connect(_on_double_jump_performed)
	visible = debug_visible
	_was_on_floor = player.is_on_floor()
	_jump_start_foot_y = _get_player_foot_y()
	_jump_start_x = player.global_position.x
	_refresh_text()


func _process(_delta: float) -> void:
	if not debug_visible or not is_visible_in_tree():
		return
	var grounded: bool = player.is_on_floor()
	if _was_on_floor and not grounded:
		_jump_start_foot_y = _get_player_foot_y()
		_jump_start_x = player.global_position.x
		_current_max_rise = 0.0
		_used_double_jump = false
	elif not _was_on_floor and grounded:
		if _used_double_jump:
			_double_jump_max_rise = maxf(_double_jump_max_rise, _current_max_rise)
		else:
			_single_jump_max_rise = maxf(_single_jump_max_rise, _current_max_rise)
	_current_max_rise = maxf(_current_max_rise, _jump_start_foot_y - _get_player_foot_y())
	_was_on_floor = grounded
	_refresh_text()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed(TOGGLE_ACTION):
		debug_visible = not debug_visible
		visible = debug_visible
		if debug_visible:
			_refresh_text()
		get_viewport().set_input_as_handled()


func _collect_surfaces() -> void:
	for child: Node in world.get_children():
		var body: StaticBody2D = child as StaticBody2D
		if body == null:
			continue
		if body.name == &"Floor" or body.name.begins_with("Platform") or body.name == &"GargoylePerch":
			_surfaces.append(body)


func _refresh_text() -> void:
	var nearest: StaticBody2D = _get_nearest_elevated_surface()
	var nearest_name: String = "--"
	var vertical_difference: float = 0.0
	var horizontal_difference: float = 0.0
	var rating: String = "--"
	if nearest != null:
		nearest_name = String(nearest.name)
		var shape: RectangleShape2D = _get_rectangle_shape(nearest)
		var top_y: float = _get_surface_top_y(nearest)
		vertical_difference = maxf(0.0, _get_floor_top_y() - top_y)
		var half_width: float = shape.size.x * 0.5 if shape != null else 0.0
		horizontal_difference = maxf(
			0.0,
			absf(player.global_position.x - nearest.global_position.x) - half_width
		)
		rating = _classify_rise(vertical_difference)
	text = (
		"TRAVERSAL [F4]  FOOT Y %.0f | START %.0f | RISE %.1f | DX %.1f\n"
		+ "PEAK S %.1f D %.1f | NEAR %s | DY %.0f DX %.0f | %s"
	) % [
		_get_player_foot_y(), _jump_start_foot_y, _current_max_rise,
		absf(player.global_position.x - _jump_start_x), _single_jump_max_rise,
		_double_jump_max_rise, nearest_name, vertical_difference,
		horizontal_difference, rating,
	]


func _get_nearest_elevated_surface() -> StaticBody2D:
	var nearest: StaticBody2D
	var nearest_distance: float = INF
	for surface: StaticBody2D in _surfaces:
		if surface.name == &"Floor":
			continue
		var distance: float = absf(player.global_position.x - surface.global_position.x)
		if distance < nearest_distance:
			nearest = surface
			nearest_distance = distance
	return nearest


func _get_player_foot_y() -> float:
	var collision: CollisionShape2D = player.get_node_or_null("CollisionShape2D") as CollisionShape2D
	var shape: RectangleShape2D = collision.shape as RectangleShape2D if collision != null else null
	if collision == null or shape == null:
		return player.global_position.y
	return player.global_position.y + collision.position.y + shape.size.y * 0.5


func _get_floor_top_y() -> float:
	for surface: StaticBody2D in _surfaces:
		if surface.name == &"Floor":
			return _get_surface_top_y(surface)
	return 640.0


func _get_surface_top_y(body: StaticBody2D) -> float:
	var collision: CollisionShape2D = body.get_node_or_null("CollisionShape2D") as CollisionShape2D
	var shape: RectangleShape2D = collision.shape as RectangleShape2D if collision != null else null
	if collision == null or shape == null:
		return body.global_position.y
	return body.global_position.y + collision.position.y - shape.size.y * 0.5


func _get_rectangle_shape(body: StaticBody2D) -> RectangleShape2D:
	var collision: CollisionShape2D = body.get_node_or_null("CollisionShape2D") as CollisionShape2D
	return collision.shape as RectangleShape2D if collision != null else null


func _classify_rise(rise: float) -> String:
	if rise <= MAIN_ROUTE_LIMIT:
		return "REACHABLE"
	if rise <= CHALLENGE_LIMIT:
		return "RISKY"
	if rise <= HIDDEN_LIMIT:
		return "HIDDEN/AIR DASH"
	return "UNREACHABLE"


func _on_double_jump_performed(_air_jumps_remaining: int) -> void:
	_used_double_jump = true
