class_name LootDropComponent
extends Node

## One-roll death loot with deterministic debug modes and low-HP protection.

signal drop_resolved(kind: StringName, amount: int, roll: int, killed_by_player: bool)
signal pickup_spawned(pickup: Node2D)

enum ForceDrop {
	NORMAL,
	NONE,
	COIN,
	SMALL_HEALTH,
	LARGE_HEALTH,
}

const COIN_PICKUP: PackedScene = preload("res://scenes/items/pickups/coin_pickup.tscn")
const SMALL_HEALTH_PICKUP: PackedScene = preload(
	"res://scenes/items/pickups/small_health_pickup.tscn"
)
const LARGE_HEALTH_PICKUP: PackedScene = preload(
	"res://scenes/items/pickups/large_health_pickup.tscn"
)

@export var profile: LootDropProfile
@export var force_drop: ForceDrop = ForceDrop.NORMAL
@export var deterministic_debug_seed: int = 0
@export_node_path("HealthComponent") var health_path: NodePath = NodePath("../HealthComponent")
@export_node_path("HurtboxComponent") var hurtbox_path: NodePath = NodePath("../Hurtbox")

@onready var health: HealthComponent = get_node_or_null(health_path) as HealthComponent
@onready var hurtbox: HurtboxComponent = get_node_or_null(hurtbox_path) as HurtboxComponent

var last_result: StringName = &"unrolled"
var last_roll: int = 0
var killed_by_player: bool = false
var _resolved: bool = false
var _rng: RandomNumberGenerator = RandomNumberGenerator.new()


func _ready() -> void:
	if profile == null or health == null or hurtbox == null:
		push_error("LootDropComponent requires profile, HealthComponent, and HurtboxComponent")
		return
	if deterministic_debug_seed != 0:
		_rng.seed = deterministic_debug_seed
	else:
		_rng.randomize()
	if not hurtbox.hit_resolving.is_connected(_on_hit_resolving):
		hurtbox.hit_resolving.connect(_on_hit_resolving)
	var enemy: EnemyCombatant = get_parent() as EnemyCombatant
	if enemy != null and not enemy.enemy_died.is_connected(_on_enemy_died):
		enemy.enemy_died.connect(_on_enemy_died)


func resolve_roll(player_health_ratio: float, source_is_player: bool) -> Dictionary:
	var roll: int = _rng.randi_range(1, 100)
	var kind: StringName = _forced_kind()
	if force_drop == ForceDrop.NORMAL:
		kind = _kind_for_roll(roll, player_health_ratio)
		if not source_is_player:
			# Environment kills never create healing and halve the original coin chance.
			kind = &"coin" if kind == &"coin" and _rng.randf() <= 0.5 else &"none"
	var amount: int = profile.get_coin_amount(_rng) if kind == &"coin" else 0
	return {"kind": kind, "amount": amount, "roll": roll}


func collect_statistics(sample_count: int, player_health_ratio: float, seed_value: int) -> Dictionary:
	var saved_seed: int = _rng.state
	_rng.seed = seed_value
	var counts: Dictionary[StringName, int] = {
		&"coin": 0, &"small_health": 0, &"large_health": 0, &"none": 0,
	}
	for _index: int in range(maxi(0, sample_count)):
		var result: Dictionary = resolve_roll(player_health_ratio, true)
		var kind: StringName = result["kind"] as StringName
		counts[kind] = counts.get(kind, 0) + 1
	_rng.state = saved_seed
	return counts


func suppress_drop() -> void:
	_resolved = true
	last_result = &"debug_suppressed"


func _on_hit_resolving(hitbox: HitboxComponent) -> void:
	if hitbox != null:
		killed_by_player = hitbox.faction == &"player"


func _on_enemy_died() -> void:
	if _resolved:
		return
	_resolved = true
	var health_ratio: float = _get_player_health_ratio()
	var result: Dictionary = resolve_roll(health_ratio, killed_by_player)
	last_result = result["kind"] as StringName
	last_roll = result["roll"] as int
	var amount: int = result["amount"] as int
	drop_resolved.emit(last_result, amount, last_roll, killed_by_player)
	if last_result == &"none":
		return
	call_deferred("_spawn_pickup", last_result, amount)


func _spawn_pickup(kind: StringName, amount: int) -> void:
	var scene: PackedScene
	match kind:
		&"coin":
			scene = COIN_PICKUP
		&"small_health":
			scene = SMALL_HEALTH_PICKUP
		&"large_health":
			scene = LARGE_HEALTH_PICKUP
		_:
			return
	var pickup: Node2D = scene.instantiate() as Node2D
	if pickup == null:
		return
	if pickup.has_method("set_pickup_amount"):
		pickup.call("set_pickup_amount", amount)
	var enemy: Node2D = get_parent() as Node2D
	var world_parent: Node = enemy.get_parent() if enemy != null else get_tree().current_scene
	world_parent.add_child(pickup)
	var offset_x: float = _rng.randi_range(-10, 10)
	pickup.global_position = enemy.global_position + Vector2(offset_x, -8.0)
	pickup_spawned.emit(pickup)


func _get_player_health_ratio() -> float:
	var player: Player = get_tree().get_first_node_in_group("player") as Player
	if player == null or player.health_component == null:
		return 1.0
	return float(player.health_component.current_health) / float(player.health_component.max_health)


func _kind_for_roll(roll: int, player_health_ratio: float) -> StringName:
	var coin_limit: int = 58
	var small_limit: int = 70
	var large_limit: int = 73
	if player_health_ratio <= 0.30:
		coin_limit = 45
		small_limit = 67
		large_limit = 75
	elif player_health_ratio <= 0.60:
		coin_limit = 52
		small_limit = 68
		large_limit = 73
	if roll <= coin_limit:
		return &"coin"
	if roll <= small_limit:
		return &"small_health"
	if roll <= large_limit:
		return &"large_health"
	return &"none"


func _forced_kind() -> StringName:
	match force_drop:
		ForceDrop.COIN:
			return &"coin"
		ForceDrop.SMALL_HEALTH:
			return &"small_health"
		ForceDrop.LARGE_HEALTH:
			return &"large_health"
	return &"none"
