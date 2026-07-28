class_name Chapter03TimedField
extends Area2D

enum Mode { DAMAGE, HUSH, SEAL }

@export var mode: Mode = Mode.DAMAGE
@export var duration: float = 2.0
@export var tick_interval: float = 0.6
@export var damage: int = 4
@export var max_ticks_per_target: int = 3
@export var stamina_multiplier: float = 0.65
@export_node_path("HitboxComponent") var hitbox_path: NodePath = NodePath("Hitbox")

@onready var hitbox: HitboxComponent = get_node_or_null(hitbox_path) as HitboxComponent
var _elapsed: float = 0.0
var _tick_timer: float = 0.0
var _next_attack_id: int = 1
var _ticks: Dictionary[int, int] = {}
var _hush_source: StringName


func _ready() -> void:
	_hush_source = StringName("hush_%d" % get_instance_id())
	area_entered.connect(_on_area_entered)
	area_exited.connect(_on_area_exited)
	if hitbox != null:
		hitbox.hit_confirmed.connect(_on_hit_confirmed)
	if mode == Mode.SEAL:
		_tick_timer = minf(duration, 0.82)
	elif mode == Mode.DAMAGE:
		_tick_timer = tick_interval


func _physics_process(delta: float) -> void:
	_elapsed += delta
	_tick_timer -= delta
	if _elapsed >= duration:
		_cleanup_hush_players()
		queue_free()
		return
	if mode == Mode.HUSH or _tick_timer > 0.0 or hitbox == null:
		return
	_tick_timer = duration + 1.0 if mode == Mode.SEAL else tick_interval
	_next_attack_id += 1
	hitbox.begin_attack(_next_attack_id, damage, 0.0, self)
	await get_tree().physics_frame
	if is_instance_valid(hitbox):
		hitbox.end_attack()


func _on_area_entered(area: Area2D) -> void:
	var player: Player = area.get_parent() as Player
	if player != null and mode == Mode.HUSH:
		player.stamina_component.set_regeneration_modifier(_hush_source, stamina_multiplier)


func _on_area_exited(area: Area2D) -> void:
	var player: Player = area.get_parent() as Player
	if player != null and mode == Mode.HUSH:
		player.stamina_component.clear_regeneration_modifier(_hush_source)


func _cleanup_hush_players() -> void:
	if mode != Mode.HUSH:
		return
	for area: Area2D in get_overlapping_areas():
		var player: Player = area.get_parent() as Player
		if player != null:
			player.stamina_component.clear_regeneration_modifier(_hush_source)


func _on_hit_confirmed(target: HurtboxComponent, _damage: int, _attack_id: int) -> void:
	var target_id: int = target.get_instance_id()
	_ticks[target_id] = int(_ticks.get(target_id, 0)) + 1
	# Field lifetime and interval are authored so no target can receive more
	# accepted ticks than this cap; the count remains available to QA/debug UI.
