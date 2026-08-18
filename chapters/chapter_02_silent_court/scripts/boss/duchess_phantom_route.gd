class_name DuchessPhantomRoute
extends Node2D

## Telegraphs one fixed ballroom lane, then crosses it once with a deduplicated hitbox.

signal route_finished(route: DuchessPhantomRoute)

@export_node_path("HitboxComponent") var hitbox_path: NodePath = NodePath("Hitbox")
@export_node_path("Line2D") var telegraph_path: NodePath = NodePath("Telegraph")
@export_node_path("Sprite2D") var phantom_path: NodePath = NodePath("Phantom")
@export_node_path("CollisionShape2D") var collision_path: NodePath = NodePath("Hitbox/CollisionShape2D")

@onready var hitbox: HitboxComponent = get_node_or_null(hitbox_path) as HitboxComponent
@onready var telegraph: Line2D = get_node_or_null(telegraph_path) as Line2D
@onready var phantom: Sprite2D = get_node_or_null(phantom_path) as Sprite2D
@onready var collision_shape: CollisionShape2D = get_node_or_null(collision_path) as CollisionShape2D

var _start_position: Vector2 = Vector2.ZERO
var _end_position: Vector2 = Vector2.ZERO
var _telegraph_duration: float = 0.75
var _active_duration: float = 0.72
var _elapsed: float = 0.0
var _attack_id: int = 0
var _damage: int = 10
var _source: Node2D
var _active_started: bool = false
var _configured: bool = false
var _variant_index: int = 0


func configure_route(
	start_position: Vector2,
	end_position: Vector2,
	telegraph_duration: float,
	active_duration: float,
	damage: int,
	attack_id: int,
	source: Node2D,
	variant_index: int = 0,
	shared_target_ledger: Dictionary[int, bool] = {},
	hitbox_size: Vector2 = Vector2(40.0, 34.0)
) -> void:
	_start_position = start_position
	_end_position = end_position
	_telegraph_duration = maxf(0.05, telegraph_duration)
	_active_duration = maxf(0.05, active_duration)
	_damage = maxi(1, damage)
	_attack_id = maxi(1, attack_id)
	_source = source
	_variant_index = clampi(variant_index, 0, 1)
	global_position = _start_position
	_configured = true
	if hitbox != null:
		hitbox.set_shared_target_ledger(shared_target_ledger)
	if collision_shape != null:
		var rectangle: RectangleShape2D = collision_shape.shape as RectangleShape2D
		if rectangle != null:
			rectangle.size = hitbox_size
		collision_shape.position = Vector2(0.0, -hitbox_size.y * 0.5)
	_apply_variant()
	_update_telegraph()


func _ready() -> void:
	if hitbox == null or telegraph == null or phantom == null:
		push_error("DuchessPhantomRoute scene composition is incomplete")
		set_process(false)
		return
	phantom.visible = true
	phantom.modulate = Color(0.72, 0.78, 0.86, 0.14)
	hitbox.end_attack()
	_apply_variant()
	_update_telegraph()


func _process(delta: float) -> void:
	if not _configured:
		return
	_elapsed += delta
	if not _active_started:
		var pulse: float = 0.45 + 0.35 * sin(_elapsed * 18.0)
		telegraph.modulate.a = pulse
		phantom.modulate.a = 0.10 + pulse * 0.14
		phantom.position.y = -54.0 + sin(_elapsed * 13.0 + float(_variant_index)) * 2.0
		if _elapsed < _telegraph_duration:
			return
		_active_started = true
		phantom.visible = true
		phantom.position.y = -54.0
		phantom.modulate = Color(0.88, 0.91, 0.96, 0.94)
		telegraph.modulate.a = 0.22
		var direction: float = signf(_end_position.x - _start_position.x)
		phantom.flip_h = direction < 0.0
		hitbox.begin_attack(_attack_id, _damage, direction, _source)
	var active_elapsed: float = _elapsed - _telegraph_duration
	var ratio: float = clampf(active_elapsed / _active_duration, 0.0, 1.0)
	global_position = _start_position.lerp(_end_position, ratio)
	phantom.modulate.a = 0.94 - ratio * 0.14
	if ratio >= 1.0:
		hitbox.end_attack()
		route_finished.emit(self)
		queue_free()


func _update_telegraph() -> void:
	if telegraph == null:
		return
	telegraph.clear_points()
	telegraph.add_point(Vector2.ZERO)
	telegraph.add_point(_end_position - _start_position)


func _apply_variant() -> void:
	if phantom == null:
		return
	phantom.region_enabled = true
	phantom.region_rect = Rect2(float(_variant_index * 192), 0.0, 192.0, 192.0)
