class_name ThirteenthPontiffSummonDirector
extends Node

signal summon_count_changed(active_count: int)
signal summon_spawned(summon: EdranBossSummon)
signal all_summons_cleared

@export var ossuary_penitent_scene: PackedScene
@export var choir_husk_scene: PackedScene
@export_node_path("ThirteenthPontiffEdran") var boss_path: NodePath = NodePath("..")

@onready var boss: ThirteenthPontiffEdran = get_node_or_null(boss_path) as ThirteenthPontiffEdran

var _active: Array[EdranBossSummon] = []
var _arena_center: Vector2
var _next_kind: StringName = &"ossuary_penitent"


func _ready() -> void:
	_arena_center = boss.global_position if boss != null else Vector2.ZERO


func can_summon_phase_1() -> bool:
	_prune_invalid()
	return boss != null and _active.size() < boss.config.phase_1_summon_cap


func summon_phase_1(player: Player) -> bool:
	if not can_summon_phase_1():
		return false
	return _summon_one(player)


func can_summon_phase_2() -> bool:
	_prune_invalid()
	return boss != null and _active.size() < boss.config.phase_02_summon_cap


func summon_phase_2(player: Player) -> int:
	return 1 if can_summon_phase_2() and _summon_one(player) else 0


func _summon_one(player: Player) -> bool:
	var kind: StringName = _next_kind
	var penitent_cap: int = (
		boss.config.phase_02_penitent_cap if boss.is_phase_02()
		else boss.config.phase_1_penitent_cap
	)
	var husk_cap: int = (
		boss.config.phase_02_choir_husk_cap if boss.is_phase_02()
		else boss.config.phase_1_choir_husk_cap
	)
	if kind == &"ossuary_penitent" and _count_kind(kind) >= penitent_cap:
		kind = &"choir_husk"
	if kind == &"choir_husk" and _count_kind(kind) >= husk_cap:
		kind = &"ossuary_penitent"
	if (
		(kind == &"ossuary_penitent" and _count_kind(kind) >= penitent_cap)
		or (kind == &"choir_husk" and _count_kind(kind) >= husk_cap)
	):
		return false
	var scene: PackedScene = ossuary_penitent_scene if kind == &"ossuary_penitent" else choir_husk_scene
	if scene == null:
		return false
	var summon: EdranBossSummon = scene.instantiate() as EdranBossSummon
	if summon == null:
		return false
	var host: Node = boss.get_parent()
	host.add_child(summon)
	summon.global_position = _select_spawn_position(player)
	summon.z_index = Chapter03LayerContract.ENEMIES
	summon.retired.connect(_on_summon_retired)
	_active.append(summon)
	_next_kind = &"choir_husk" if kind == &"ossuary_penitent" else &"ossuary_penitent"
	summon.initialize_summon(player, randf_range(boss.config.summon_lifetime_min, boss.config.summon_lifetime_max))
	summon_spawned.emit(summon)
	summon_count_changed.emit(_active.size())
	return true


func force_dissolve_all() -> void:
	_prune_invalid()
	for summon: EdranBossSummon in _active.duplicate():
		if is_instance_valid(summon):
			summon.force_dissolve()
	if _active.is_empty():
		all_summons_cleared.emit()


func get_active_count() -> int:
	_prune_invalid()
	return _active.size()


func get_active_summons() -> Array[EdranBossSummon]:
	_prune_invalid()
	return _active.duplicate()


func _select_spawn_position(player: Player) -> Vector2:
	var offsets: Array[float] = [-520.0, -330.0, 310.0, 520.0]
	for offset: float in offsets:
		var candidate: Vector2 = _arena_center + Vector2(offset, 0.0)
		if player == null or absf(candidate.x - player.global_position.x) >= boss.config.summon_safe_distance:
			return candidate
	return _arena_center + Vector2(520.0, 0.0)


func _count_kind(kind: StringName) -> int:
	var result: int = 0
	for summon: EdranBossSummon in _active:
		if is_instance_valid(summon) and summon.config.actor_kind == kind:
			result += 1
	return result


func _prune_invalid() -> void:
	_active = _active.filter(func(summon: EdranBossSummon) -> bool: return is_instance_valid(summon) and not summon.is_queued_for_deletion())


func _on_summon_retired(summon: EdranBossSummon) -> void:
	_active.erase(summon)
	summon_count_changed.emit(_active.size())
	if _active.is_empty():
		all_summons_cleared.emit()
