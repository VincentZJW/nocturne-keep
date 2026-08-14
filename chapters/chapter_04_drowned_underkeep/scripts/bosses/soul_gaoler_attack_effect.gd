class_name SoulGaolerAttackEffect
extends Node2D

## Boss-owned telegraph/projectile/hazard presentation with one shared damage gate.

signal activated(effect: SoulGaolerAttackEffect)
signal finished(effect: SoulGaolerAttackEffect)

enum EffectKind {
	GROUND_RIFT,
	PRISON_PIKE,
	JAVELIN,
}

const ENEMY_HITBOX_LAYER: int = 64
const PLAYER_HURTBOX_MASK: int = 8
const WORLD_MASK: int = 1

var kind: EffectKind = EffectKind.GROUND_RIFT
var telegraph_duration: float = 0.0
var active_duration: float = 0.2
var linger_duration: float = 0.16
var visual_size: Vector2 = Vector2(96.0, 18.0)
var velocity: Vector2 = Vector2.ZERO
var source: Node2D
var hitbox: HitboxComponent
var attack_id: int = 0
var damage: int = 1
var attack_kind: StringName = &"ormund_hazard"
var _telegraph_remaining: float = 0.0
var _active_remaining: float = 0.0
var _linger_remaining: float = 0.0
var _embedded: bool = false
var _started: bool = false


func configure_zone(
	effect_kind: EffectKind,
	size: Vector2,
	telegraph: float,
	active: float,
	linger: float,
	damage_value: int,
	new_attack_id: int,
	owner_source: Node2D,
	shared_targets: Dictionary[int, bool],
	kind_name: StringName
) -> void:
	kind = effect_kind
	visual_size = size
	telegraph_duration = maxf(0.0, telegraph)
	active_duration = maxf(0.02, active)
	linger_duration = maxf(0.0, linger)
	damage = damage_value
	attack_id = new_attack_id
	source = owner_source
	attack_kind = kind_name
	_build_hitbox(shared_targets)
	_telegraph_remaining = telegraph_duration
	queue_redraw()
	set_physics_process(true)


func configure_javelin(
	direction: Vector2,
	speed: float,
	damage_value: int,
	new_attack_id: int,
	owner_source: Node2D,
	shared_targets: Dictionary[int, bool]
) -> void:
	kind = EffectKind.JAVELIN
	visual_size = Vector2(44.0, 8.0)
	active_duration = 2.4
	linger_duration = 1.5
	damage = damage_value
	attack_id = new_attack_id
	source = owner_source
	attack_kind = &"drowned_javelin"
	velocity = direction.normalized() * speed
	rotation = velocity.angle()
	_build_hitbox(shared_targets)
	_begin_active()
	set_physics_process(true)


func _build_hitbox(shared_targets: Dictionary[int, bool]) -> void:
	hitbox = HitboxComponent.new()
	hitbox.name = "Hitbox"
	hitbox.collision_layer = ENEMY_HITBOX_LAYER
	hitbox.collision_mask = PLAYER_HURTBOX_MASK
	hitbox.faction = &"enemy"
	hitbox.attack_kind = StringName("enemy_%s" % attack_kind)
	add_child(hitbox)
	var collision_shape := CollisionShape2D.new()
	collision_shape.name = "CollisionShape2D"
	var rectangle := RectangleShape2D.new()
	if kind == EffectKind.JAVELIN:
		rectangle.size = Vector2(38.0, 6.0)
	else:
		rectangle.size = visual_size
	collision_shape.shape = rectangle
	hitbox.add_child(collision_shape)
	hitbox.set_shared_target_ledger(shared_targets)
	hitbox.end_attack()


func _physics_process(delta: float) -> void:
	if kind == EffectKind.JAVELIN and not _embedded:
		_process_javelin(delta)
	if not _started:
		_telegraph_remaining = maxf(0.0, _telegraph_remaining - delta)
		if _telegraph_remaining <= 0.0:
			_begin_active()
		queue_redraw()
		return
	if not _embedded and _active_remaining > 0.0:
		_active_remaining = maxf(0.0, _active_remaining - delta)
		if _active_remaining <= 0.0:
			_end_active()
		queue_redraw()
		return
	_linger_remaining = maxf(0.0, _linger_remaining - delta)
	queue_redraw()
	if _linger_remaining <= 0.0:
		finished.emit(self)
		queue_free()


func _process_javelin(delta: float) -> void:
	var from: Vector2 = global_position
	var to: Vector2 = from + velocity * delta
	var query := PhysicsRayQueryParameters2D.create(from, to, WORLD_MASK)
	if source != null and is_instance_valid(source):
		query.exclude = [source.get_rid()]
	var result: Dictionary = get_world_2d().direct_space_state.intersect_ray(query)
	if not result.is_empty():
		global_position = result["position"] as Vector2
		_embed()
		return
	global_position = to


func _begin_active() -> void:
	if _started:
		return
	_started = true
	_active_remaining = active_duration
	if hitbox != null:
		hitbox.begin_attack(attack_id, damage, signf(velocity.x), source)
	activated.emit(self)
	queue_redraw()


func _end_active() -> void:
	if hitbox != null:
		hitbox.end_attack()
	_linger_remaining = linger_duration


func _embed() -> void:
	_embedded = true
	velocity = Vector2.ZERO
	if hitbox != null:
		hitbox.end_attack()
	_linger_remaining = linger_duration
	queue_redraw()


func cancel() -> void:
	if hitbox != null:
		hitbox.end_attack()
	queue_free()


func is_telegraphing() -> bool:
	return not _started


func is_damage_active() -> bool:
	return _started and not _embedded and _active_remaining > 0.0


func _draw() -> void:
	match kind:
		EffectKind.JAVELIN:
			_draw_javelin()
		EffectKind.PRISON_PIKE:
			_draw_pike()
		EffectKind.GROUND_RIFT:
			_draw_ground_rift()


func _draw_javelin() -> void:
	var fade: float = 1.0 if not _embedded else clampf(_linger_remaining / maxf(linger_duration, 0.01), 0.0, 1.0)
	draw_colored_polygon(
		PackedVector2Array([Vector2(-21, -3), Vector2(15, -3), Vector2(22, 0), Vector2(15, 3), Vector2(-21, 3)]),
		Color(0.18, 0.25, 0.29, fade)
	)
	draw_polyline(PackedVector2Array([Vector2(-19, -2), Vector2(16, -2), Vector2(22, 0)]), Color(0.67, 0.89, 0.94, fade), 2.0)
	draw_line(Vector2(-16, -5), Vector2(-16, 5), Color(0.38, 0.56, 0.59, fade), 2.0)


func _draw_ground_rift() -> void:
	var telegraph_ratio: float = 1.0 - (_telegraph_remaining / maxf(telegraph_duration, 0.01))
	var active_alpha: float = 0.82 if is_damage_active() else 0.38
	var alpha: float = active_alpha if _started else lerpf(0.15, 0.62, telegraph_ratio)
	var half: Vector2 = visual_size * 0.5
	draw_rect(Rect2(-half, visual_size), Color(0.04, 0.25, 0.31, alpha * 0.45), true)
	var segments: int = maxi(2, floori(visual_size.x / 42.0))
	for index: int in segments:
		var x: float = -half.x + 12.0 + float(index) * (visual_size.x - 24.0) / float(maxi(1, segments - 1))
		var crest: float = -5.0 - sin(float(index) * 1.7) * (4.0 + telegraph_ratio * 6.0)
		draw_polyline(PackedVector2Array([Vector2(x - 12, 3), Vector2(x, crest), Vector2(x + 12, 3)]), Color(0.35, 0.88, 0.93, alpha), 2.0)
	if is_damage_active():
		draw_line(Vector2(-half.x, -half.y), Vector2(half.x, -half.y), Color(0.70, 0.96, 1.0, 0.9), 3.0)


func _draw_pike() -> void:
	var telegraph_ratio: float = 1.0 - (_telegraph_remaining / maxf(telegraph_duration, 0.01))
	if not _started:
		draw_circle(Vector2.ZERO, 11.0 + telegraph_ratio * 5.0, Color(0.08, 0.45, 0.53, 0.16 + telegraph_ratio * 0.28))
		draw_polyline(PackedVector2Array([Vector2(-13, 4), Vector2(-5, -2), Vector2(1, 4), Vector2(9, -3), Vector2(14, 4)]), Color(0.49, 0.85, 0.88, 0.35 + telegraph_ratio * 0.5), 2.0)
		return
	var fade: float = 1.0 if is_damage_active() else clampf(_linger_remaining / maxf(linger_duration, 0.01), 0.0, 1.0)
	var half_width: float = visual_size.x * 0.42
	draw_colored_polygon(PackedVector2Array([Vector2(-half_width, 8), Vector2(-6, -visual_size.y * 0.5), Vector2(0, -visual_size.y * 0.75), Vector2(6, -visual_size.y * 0.5), Vector2(half_width, 8)]), Color(0.18, 0.27, 0.30, fade))
	draw_polyline(PackedVector2Array([Vector2(-half_width, 7), Vector2(0, -visual_size.y * 0.75), Vector2(half_width, 7)]), Color(0.61, 0.87, 0.89, fade), 2.0)
