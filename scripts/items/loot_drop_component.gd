class_name LootDropComponent
extends Node

## One-roll normal-enemy loot selected from a death-time Player Health snapshot.

signal drop_resolved(kind: StringName, amount: int, roll: float, killed_by_player: bool)
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
@export var dynamic_profile: DynamicLootProfile
@export var force_drop: ForceDrop = ForceDrop.NORMAL
@export var deterministic_debug_seed: int = 0
@export_range(-1.0, 99.99, 0.01) var debug_forced_next_roll: float = -1.0
@export_node_path("HealthComponent") var health_path: NodePath = NodePath("../HealthComponent")
@export_node_path("HurtboxComponent") var hurtbox_path: NodePath = NodePath("../Hurtbox")

@onready var health: HealthComponent = get_node_or_null(health_path) as HealthComponent
@onready var hurtbox: HurtboxComponent = get_node_or_null(hurtbox_path) as HurtboxComponent

var selected_health_tier: StringName = &"UNRESOLVED"
var selected_drop_result: StringName = &"unrolled"
var drop_roll: float = -1.0
var player_health_ratio_at_kill: float = 1.0
var killed_by_player: bool = false

# Compatibility aliases retained for existing QA/capture tooling.
var last_result: StringName = &"unrolled"
var last_roll: float = -1.0

var _resolved: bool = false
var _rng: RandomNumberGenerator = RandomNumberGenerator.new()
var _loot_statistics: Dictionary[StringName, int] = {
	&"coin": 0,
	&"small_health": 0,
	&"large_health": 0,
	&"none": 0,
}


func _ready() -> void:
	if profile == null or dynamic_profile == null or health == null or hurtbox == null:
		push_error(
			"LootDropComponent requires quantity/dynamic profiles, HealthComponent, and HurtboxComponent"
		)
		return
	if not dynamic_profile.is_valid_profile():
		push_error("LootDropComponent dynamic profile requires four tables totaling exactly 100")
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
	var bounded_ratio: float = clampf(player_health_ratio, 0.0, 1.0)
	var tier: DynamicLootProfile.HealthTier = dynamic_profile.get_health_tier_from_ratio(
		bounded_ratio
	)
	return _resolve_for_tier(tier, bounded_ratio, source_is_player)


func resolve_roll_for_health(
	current_health: int, max_health: int, source_is_player: bool
) -> Dictionary:
	var safe_maximum: int = maxi(1, max_health)
	var ratio: float = clampf(float(maxi(0, current_health)) / float(safe_maximum), 0.0, 1.0)
	var tier: DynamicLootProfile.HealthTier = dynamic_profile.get_health_tier(
		current_health, max_health
	)
	return _resolve_for_tier(tier, ratio, source_is_player)


func collect_statistics(
	sample_count: int, player_health_ratio: float, seed_value: int
) -> Dictionary:
	return collect_statistics_for_health(
		sample_count, roundi(clampf(player_health_ratio, 0.0, 1.0) * 100.0), 100, seed_value
	)


func collect_statistics_for_health(
	sample_count: int, current_health: int, max_health: int, seed_value: int
) -> Dictionary:
	var saved_state: int = _rng.state
	var saved_forced_roll: float = debug_forced_next_roll
	var saved_statistics: Dictionary[StringName, int] = _loot_statistics.duplicate()
	_rng.seed = seed_value
	debug_forced_next_roll = -1.0
	var counts: Dictionary[StringName, int] = _empty_statistics()
	for _index: int in range(maxi(0, sample_count)):
		var result: Dictionary = resolve_roll_for_health(current_health, max_health, true)
		var kind: StringName = result["kind"] as StringName
		counts[kind] = counts.get(kind, 0) + 1
	_rng.state = saved_state
	debug_forced_next_roll = saved_forced_roll
	_loot_statistics = saved_statistics
	return counts


func force_next_drop_roll(value: float) -> void:
	debug_forced_next_roll = clampf(value, 0.0, 99.99)


func reset_loot_statistics() -> void:
	_loot_statistics = _empty_statistics()


func get_loot_statistics() -> Dictionary[StringName, int]:
	return _loot_statistics.duplicate()


func reset_drop_state() -> void:
	_resolved = false
	selected_health_tier = &"UNRESOLVED"
	selected_drop_result = &"unrolled"
	drop_roll = -1.0
	player_health_ratio_at_kill = 1.0
	killed_by_player = false
	last_result = selected_drop_result
	last_roll = drop_roll


func suppress_drop() -> void:
	_resolved = true
	selected_drop_result = &"debug_suppressed"
	last_result = selected_drop_result


func get_selected_weights_summary() -> String:
	if selected_health_tier == &"UNRESOLVED" or dynamic_profile == null:
		return "unresolved"
	var tier: DynamicLootProfile.HealthTier = dynamic_profile.get_health_tier_from_ratio(
		player_health_ratio_at_kill
	)
	var weights: LootProbabilityWeights = dynamic_profile.get_weights(tier)
	return weights.get_debug_summary() if weights != null else "invalid"


func _resolve_for_tier(
	tier: DynamicLootProfile.HealthTier,
	health_ratio: float,
	source_is_player: bool
) -> Dictionary:
	var weights: LootProbabilityWeights = dynamic_profile.get_weights(tier)
	var roll: float = _next_drop_roll()
	var kind: StringName
	if force_drop == ForceDrop.NORMAL:
		kind = (
			weights.get_drop_kind(roll)
			if source_is_player
			else _get_environment_drop_kind(roll, weights)
		)
	else:
		kind = _forced_kind()
	var amount: int = profile.get_coin_amount(_rng) if kind == &"coin" else 0
	_loot_statistics[kind] = _loot_statistics.get(kind, 0) + 1
	return {
		"kind": kind,
		"amount": amount,
		"roll": roll,
		"tier": dynamic_profile.get_tier_name(tier),
		"health_ratio": health_ratio,
	}


func _next_drop_roll() -> float:
	if debug_forced_next_roll >= 0.0:
		var forced_roll: float = clampf(debug_forced_next_roll, 0.0, 99.99)
		debug_forced_next_roll = -1.0
		return forced_roll
	return minf(_rng.randf_range(0.0, 100.0), 99.9999)


func _get_environment_drop_kind(
	roll: float, weights: LootProbabilityWeights
) -> StringName:
	# The existing environment rule is represented in the same single category roll:
	# no healing, half the selected tier's coin probability, all remainder becomes none.
	return &"coin" if roll < float(weights.coin_weight) * 0.5 else &"none"


func _on_hit_resolving(hitbox: HitboxComponent) -> void:
	if hitbox != null:
		killed_by_player = hitbox.faction == &"player"


func _on_enemy_died() -> void:
	if _resolved:
		return
	_resolved = true
	var health_snapshot: Vector2i = _get_player_health_snapshot()
	var result: Dictionary = resolve_roll_for_health(
		health_snapshot.x, health_snapshot.y, killed_by_player
	)
	selected_health_tier = result["tier"] as StringName
	selected_drop_result = result["kind"] as StringName
	drop_roll = result["roll"] as float
	player_health_ratio_at_kill = result["health_ratio"] as float
	last_result = selected_drop_result
	last_roll = drop_roll
	var amount: int = result["amount"] as int
	drop_resolved.emit(selected_drop_result, amount, drop_roll, killed_by_player)
	if selected_drop_result == &"none":
		return
	call_deferred("_spawn_pickup", selected_drop_result, amount)


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


func _get_player_health_snapshot() -> Vector2i:
	var player: Player = get_tree().get_first_node_in_group("player") as Player
	if player == null or player.health_component == null:
		return Vector2i(100, 100)
	return Vector2i(
		player.health_component.current_health,
		player.health_component.max_health,
	)


func _forced_kind() -> StringName:
	match force_drop:
		ForceDrop.COIN:
			return &"coin"
		ForceDrop.SMALL_HEALTH:
			return &"small_health"
		ForceDrop.LARGE_HEALTH:
			return &"large_health"
	return &"none"


func _empty_statistics() -> Dictionary[StringName, int]:
	return {
		&"coin": 0,
		&"small_health": 0,
		&"large_health": 0,
		&"none": 0,
	}
