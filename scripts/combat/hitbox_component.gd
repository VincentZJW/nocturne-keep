class_name HitboxComponent
extends Area2D

## Active-only damage source with faction filtering and one-hit-per-attack memory.

signal hit_confirmed(target: HurtboxComponent, damage: int, attack_id: int)
signal active_changed(active: bool)

@export_range(1, 9999, 1) var damage: int = 1
@export var faction: StringName = &"neutral"
@export var attack_kind: StringName = &"generic"
@export_range(-1.0, 1.0, 1.0) var attack_direction: float = 0.0
@export var start_enabled: bool = false

var attack_id: int = 0
var is_active: bool = false
var attacker: Node2D
var _hit_target_ids: Dictionary[int, bool] = {}
var _shared_target_ids: Dictionary[int, bool]
var _uses_shared_target_ledger: bool = false


func _ready() -> void:
	monitorable = false
	set_physics_process(false)
	if not area_entered.is_connected(_on_area_entered):
		area_entered.connect(_on_area_entered)
	_set_active_internal(start_enabled)


func begin_attack(
	new_attack_id: int,
	damage_override: int = -1,
	direction_override: float = 0.0,
	attacker_override: Node2D = null
) -> void:
	var previous_source_id: int = get_attack_source_instance_id()
	var next_source_id: int = (
		attacker_override.get_instance_id()
		if attacker_override != null and is_instance_valid(attacker_override)
		else get_instance_id()
	)
	var starts_new_attack: bool = (
		attack_id != new_attack_id or previous_source_id != next_source_id
	)
	attack_id = new_attack_id
	attacker = attacker_override
	if damage_override > 0:
		damage = damage_override
	if not is_zero_approx(direction_override):
		attack_direction = signf(direction_override)
	# Re-opening another active frame with the same action id must not forget a
	# target already consumed by that action. Only a genuinely new action clears
	# the local target ledger.
	if starts_new_attack:
		_hit_target_ids.clear()
	_set_active_internal(true)
	call_deferred("_scan_existing_overlaps")


func end_attack() -> void:
	_set_active_internal(false)


func has_hit_target(target: HurtboxComponent) -> bool:
	if target == null:
		return false
	var target_id: int = target.get_instance_id()
	return _hit_target_ids.has(target_id) or (
		_uses_shared_target_ledger and _shared_target_ids.has(target_id)
	)


func set_shared_target_ledger(shared_target_ids: Dictionary[int, bool]) -> void:
	_shared_target_ids = shared_target_ids
	_uses_shared_target_ledger = true


func get_source_position() -> Vector2:
	if attacker != null and is_instance_valid(attacker):
		return attacker.global_position
	return global_position


func get_attack_source_instance_id() -> int:
	if attacker != null and is_instance_valid(attacker):
		return attacker.get_instance_id()
	return get_instance_id()


func try_hit(target: HurtboxComponent) -> bool:
	if not is_active or target == null or not is_instance_valid(target):
		return false
	var target_id: int = target.get_instance_id()
	if _hit_target_ids.has(target_id) or (
		_uses_shared_target_ledger and _shared_target_ids.has(target_id)
	):
		return false
	if not target.receive_hit(self):
		return false
	_hit_target_ids[target_id] = true
	if _uses_shared_target_ledger:
		_shared_target_ids[target_id] = true
	hit_confirmed.emit(target, damage, attack_id)
	return true


func _set_active_internal(active: bool) -> void:
	var changed: bool = is_active != active or monitoring != active
	is_active = active
	# PhysicsServer rejects synchronous monitoring changes while an overlap
	# signal is being dispatched (for example when a bolt resolves on hit).
	# The logical state changes immediately; the server property follows safely.
	set_deferred("monitoring", active)
	set_physics_process(active)
	for child: Node in get_children():
		var collision_shape: CollisionShape2D = child as CollisionShape2D
		if collision_shape != null:
			collision_shape.set_deferred("disabled", not active)
	if changed:
		active_changed.emit(active)


func _physics_process(_delta: float) -> void:
	_scan_existing_overlaps()


func _scan_existing_overlaps() -> void:
	if not is_active or not monitoring:
		return
	for area: Area2D in get_overlapping_areas():
		var hurtbox: HurtboxComponent = area as HurtboxComponent
		if hurtbox != null:
			try_hit(hurtbox)


func _on_area_entered(area: Area2D) -> void:
	var hurtbox: HurtboxComponent = area as HurtboxComponent
	if hurtbox != null:
		try_hit(hurtbox)
