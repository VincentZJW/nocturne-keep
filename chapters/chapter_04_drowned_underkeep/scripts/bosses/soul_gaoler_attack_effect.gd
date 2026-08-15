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
const BLEED_DURATION: float = 5.0
const BLEED_TICK_DAMAGE: int = 1
const BLEED_TICK_INTERVAL: float = 1.0

var kind: EffectKind = EffectKind.GROUND_RIFT
var telegraph_duration: float = 0.0
var active_duration: float = 0.2
var linger_duration: float = 0.16
var visual_size: Vector2 = Vector2(96.0, 18.0)
var velocity: Vector2 = Vector2.ZERO
var source: Node2D
var hitbox: HitboxComponent
var hitbox_shape: CollisionShape2D
var attack_id: int = 0
var damage: int = 1
var attack_kind: StringName = &"ormund_hazard"
var applies_bleed: bool = false
var _telegraph_remaining: float = 0.0
var _active_remaining: float = 0.0
var _linger_remaining: float = 0.0
var _embedded: bool = false
var _started: bool = false
var _pike_emerge_elapsed: float = 0.0
var _pike_hitbox_armed: bool = false
var _pike_hitbox_shapes: Array[CollisionShape2D] = []

const PIKE_EMERGE_DURATION: float = 0.16
const PIKE_RETRACT_DURATION: float = 0.24
const PIKE_DAMAGE_ARM_RATIO: float = 0.40


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
	kind_name: StringName,
	bleed_on_hit: bool = false
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
	applies_bleed = bleed_on_hit
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
	applies_bleed = true
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
	_pike_hitbox_shapes.clear()
	if kind == EffectKind.PRISON_PIKE:
		# Two narrow columns cover the dense left/right weapon groups while the
		# center breathing gap remains genuinely safe.
		for shape_index: int in 2:
			var pike_shape := CollisionShape2D.new()
			pike_shape.name = "CollisionShape2D" if shape_index == 0 else "CollisionShape2DRight"
			var pike_rectangle := RectangleShape2D.new()
			pike_rectangle.size = Vector2(visual_size.x * 0.31, 8.0)
			pike_shape.shape = pike_rectangle
			pike_shape.position.x = visual_size.x * (-0.18 if shape_index == 0 else 0.18)
			hitbox.add_child(pike_shape)
			_pike_hitbox_shapes.append(pike_shape)
		hitbox_shape = _pike_hitbox_shapes[0]
	else:
		hitbox_shape = CollisionShape2D.new()
		hitbox_shape.name = "CollisionShape2D"
		var rectangle := RectangleShape2D.new()
		rectangle.size = Vector2(38.0, 6.0) if kind == EffectKind.JAVELIN else visual_size
		hitbox_shape.shape = rectangle
		hitbox.add_child(hitbox_shape)
	hitbox.set_shared_target_ledger(shared_targets)
	hitbox.hit_confirmed.connect(_on_hit_confirmed)
	hitbox.end_attack()


func _on_hit_confirmed(
	target_hurtbox: HurtboxComponent,
	_damage_value: int,
	_attack_id_value: int
) -> void:
	if not applies_bleed or target_hurtbox == null:
		return
	var target_player: Player = target_hurtbox.get_parent() as Player
	if target_player == null or target_player.status_effect_controller == null:
		return
	target_player.status_effect_controller.apply_bleed(
		attack_kind,
		BLEED_DURATION,
		BLEED_TICK_DAMAGE,
		BLEED_TICK_INTERVAL
	)


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
		if kind == EffectKind.PRISON_PIKE:
			_pike_emerge_elapsed = minf(PIKE_EMERGE_DURATION, _pike_emerge_elapsed + delta)
			_update_pike_hitbox()
			if (
				not _pike_hitbox_armed
				and _pike_emerge_elapsed / PIKE_EMERGE_DURATION >= PIKE_DAMAGE_ARM_RATIO
				and hitbox != null
			):
				_pike_hitbox_armed = true
				hitbox.begin_attack(attack_id, damage, 0.0, source)
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
	_pike_emerge_elapsed = 0.0
	_pike_hitbox_armed = false
	if kind == EffectKind.PRISON_PIKE:
		_update_pike_hitbox()
	elif hitbox != null:
		hitbox.begin_attack(attack_id, damage, signf(velocity.x), source)
	activated.emit(self)
	queue_redraw()


func _end_active() -> void:
	if hitbox != null:
		hitbox.end_attack()
	_pike_hitbox_armed = false
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
	if kind == EffectKind.PRISON_PIKE:
		return _started and _pike_hitbox_armed and _active_remaining > 0.0
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
		# Waterline ripples, disturbed mud, and staggered steel glints reveal a
		# buried arsenal without showing the final weapon positions too early.
		_draw_flat_ellipse(Vector2(0, 4), Vector2(visual_size.x * 0.48, 7.0 + telegraph_ratio * 3.0), Color(0.04, 0.24, 0.29, 0.18 + telegraph_ratio * 0.22))
		draw_polyline(PackedVector2Array([Vector2(-25, 5), Vector2(-17, 0), Vector2(-9, 4), Vector2(-1, -2), Vector2(8, 4), Vector2(17, -1), Vector2(26, 5)]), Color(0.42, 0.75, 0.78, 0.32 + telegraph_ratio * 0.48), 2.0)
		for glint_index: int in 3:
			var glint_x: float = -16.0 + float(glint_index) * 16.0
			var glint_height: float = 2.0 + telegraph_ratio * (4.0 + float(glint_index % 2) * 2.0)
			draw_line(Vector2(glint_x, 2), Vector2(glint_x + (1 if glint_index != 1 else -1), 2 - glint_height), Color(0.68, 0.89, 0.91, 0.28 + telegraph_ratio * 0.58), 1.0)
		if telegraph_ratio >= 0.50:
			# One spear tip and one nicked sword tip breach the waterline during
			# the latter half of the warning, but the hitbox remains disabled.
			var tip_ratio: float = (telegraph_ratio - 0.50) * 2.0
			_draw_buried_weapon(Vector2(-11, 4), 2.0 + tip_ratio * 6.0, deg_to_rad(-6.0), 0, 0.72)
			_draw_buried_weapon(Vector2(12, 4), 2.0 + tip_ratio * 5.0, deg_to_rad(7.0), 2, 0.68)
		return
	var emergence: float = _pike_visual_ratio()
	var fade: float = 1.0 if _active_remaining > 0.0 else clampf(_linger_remaining / maxf(linger_duration, 0.01), 0.0, 1.0)
	_draw_flat_ellipse(Vector2(0, 5), Vector2(visual_size.x * 0.52, 8.0), Color(0.025, 0.18, 0.22, 0.62 * fade))
	var weapon_count: int = 3 + posmod(attack_id, 3)
	var normalized_span: float = visual_size.x * 0.72
	for weapon_index: int in weapon_count:
		var t: float = 0.5 if weapon_count == 1 else float(weapon_index) / float(weapon_count - 1)
		var x: float = lerpf(-normalized_span * 0.5, normalized_span * 0.5, t)
		var variant: int
		if weapon_index == 0:
			variant = 0 if posmod(attack_id, 2) == 0 else 3
		elif weapon_index == 1:
			variant = 1 if posmod(attack_id, 2) == 0 else 2
		else:
			variant = posmod(attack_id + weapon_index * 2, 5)
		var length_ratios := PackedFloat32Array([1.0, 0.74, 0.50, 0.90, 0.82])
		var length_ratio: float = length_ratios[variant]
		var angle_degrees: float = [-12.0, -6.0, 7.0, 14.0, 0.0][posmod(attack_id + weapon_index, 5)]
		_draw_buried_weapon(Vector2(x, 5), visual_size.y * length_ratio * emergence, deg_to_rad(angle_degrees), variant, fade)
	# Soul-blue leakage and short chain links unify the mixed silhouettes as one
	# prison weapon grave rather than unrelated props.
	draw_line(Vector2(-20, -10 * emergence), Vector2(18, -13 * emergence), Color(0.13, 0.48, 0.55, 0.62 * fade), 1.0)
	for link_index: int in 4:
		draw_arc(Vector2(-15 + link_index * 10, -11 * emergence), 3.0, 0.0, TAU, 8, Color(0.29, 0.37, 0.38, 0.75 * fade), 1.0)


func _draw_buried_weapon(base: Vector2, exposed_length: float, angle_radians: float, variant: int, alpha: float) -> void:
	if exposed_length <= 1.0:
		return
	draw_set_transform(base, angle_radians, Vector2.ONE)
	var dark_iron := Color(0.12, 0.16, 0.18, alpha)
	var mid_iron := Color(0.29, 0.35, 0.36, alpha)
	var edge := Color(0.57, 0.70, 0.72, alpha)
	var rust := Color(0.38, 0.20, 0.13, alpha)
	match variant:
		0: # long spear: barbed black-iron head and a chained haft
			var head_y: float = -exposed_length
			draw_line(Vector2(0, 2), Vector2(0, head_y + 12), mid_iron, 3.0)
			draw_colored_polygon(PackedVector2Array([Vector2(0, head_y), Vector2(-5, head_y + 13), Vector2(0, head_y + 10), Vector2(5, head_y + 13)]), dark_iron)
			draw_line(Vector2(0, head_y + 1), Vector2(0, head_y + 11), edge, 1.0)
			draw_line(Vector2(-4, head_y + 12), Vector2(-8, head_y + 17), rust, 2.0)
		1: # gothic longsword: nicked edge and old crossguard
			var tip_y: float = -exposed_length
			draw_colored_polygon(PackedVector2Array([Vector2(0, tip_y), Vector2(-4, tip_y + 8), Vector2(-3, -10), Vector2(3, -10), Vector2(4, tip_y + 8)]), dark_iron)
			draw_line(Vector2(-2, tip_y + 7), Vector2(-1, -11), edge, 1.0)
			draw_line(Vector2(-8, -9), Vector2(8, -9), rust, 3.0)
			draw_line(Vector2(0, -8), Vector2(0, 1), mid_iron, 2.0)
		2: # broken sword: deliberately uneven fracture
			var break_y: float = -exposed_length
			draw_colored_polygon(PackedVector2Array([Vector2(-4, -8), Vector2(-3, break_y + 5), Vector2(1, break_y), Vector2(4, break_y + 7), Vector2(3, -8)]), dark_iron)
			draw_line(Vector2(-2, break_y + 7), Vector2(-2, -9), edge, 1.0)
			draw_line(Vector2(-7, -7), Vector2(7, -7), rust, 2.0)
		3: # prison pike: sharpened cell bar, rivets, and blue fracture
			var pike_y: float = -exposed_length
			var pike_head_base_y: float = minf(pike_y + 12.0, 1.0)
			# Keep the blade and shaft as separate convex primitives.  During the
			# first emergence pixels a combined outline folds over itself and Godot
			# correctly rejects the self-intersecting polygon.
			draw_colored_polygon(PackedVector2Array([
				Vector2(0, pike_y), Vector2(-4, pike_head_base_y),
				Vector2(4, pike_head_base_y),
			]), dark_iron)
			draw_line(Vector2(0, pike_head_base_y), Vector2(0, 2), mid_iron, 6.0)
			draw_line(Vector2(1, pike_y + 3), Vector2(1, 1), Color(0.26, 0.68, 0.73, alpha), 1.0)
			for rivet_y: float in [-16.0, -30.0]:
				if -rivet_y < exposed_length:
					draw_circle(Vector2(-1, rivet_y), 1.5, mid_iron)
		_: # execution blade: broad, clipped point and prison-marked fuller
			var execution_y: float = -exposed_length
			draw_colored_polygon(PackedVector2Array([
				Vector2(-2, execution_y), Vector2(-7, execution_y + 8),
				Vector2(-6, -9), Vector2(5, -9), Vector2(6, execution_y + 6),
				Vector2(2, execution_y),
			]), dark_iron)
			draw_line(Vector2(-3, execution_y + 8), Vector2(-3, -10), edge, 2.0)
			draw_line(Vector2(-9, -8), Vector2(9, -8), rust, 3.0)
			draw_line(Vector2(0, -7), Vector2(0, 2), mid_iron, 3.0)
			draw_circle(Vector2(0, 2), 3.0, rust)
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)


func _pike_visual_ratio() -> float:
	if _started and _active_remaining > 0.0:
		return clampf(_pike_emerge_elapsed / PIKE_EMERGE_DURATION, 0.08, 1.0)
	return clampf(_linger_remaining / maxf(minf(linger_duration, PIKE_RETRACT_DURATION), 0.01), 0.0, 1.0)


func _update_pike_hitbox() -> void:
	if hitbox_shape == null or kind != EffectKind.PRISON_PIKE:
		return
	var ratio: float = clampf(_pike_emerge_elapsed / PIKE_EMERGE_DURATION, 0.08, 1.0)
	var height: float = maxf(8.0, visual_size.y * ratio)
	for shape: CollisionShape2D in _pike_hitbox_shapes:
		var rectangle: RectangleShape2D = shape.shape as RectangleShape2D
		if rectangle == null:
			continue
		rectangle.size = Vector2(visual_size.x * 0.31, height)
		shape.position.y = -height * 0.5 + 4.0


func _draw_flat_ellipse(center: Vector2, radius: Vector2, color: Color) -> void:
	var points := PackedVector2Array()
	for index: int in 20:
		var angle: float = TAU * float(index) / 20.0
		points.append(center + Vector2(cos(angle) * radius.x, sin(angle) * radius.y))
	draw_colored_polygon(points, color)
