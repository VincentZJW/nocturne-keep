class_name PontiffLightningStrike
extends Node2D

signal finished(attack_id: int)

@export var telegraph_duration: float = 0.65
@export var active_duration: float = 0.18
@export var visual_duration: float = 0.32
@export var seal_radius: float = 24.0
@export_node_path("HitboxComponent") var hitbox_path: NodePath = NodePath("Hitbox")

@onready var hitbox: HitboxComponent = get_node_or_null(hitbox_path) as HitboxComponent
@onready var strike_audio: AudioStreamPlayer2D = $StrikeAudio as AudioStreamPlayer2D

var _attack_id: int = 0
var _damage: int = 18
var _attacker: Node2D
var _elapsed: float = 0.0
var _strike_started: bool = false
var _strike_finished: bool = false


func initialize(attack_id: int, damage: int, attacker: Node2D) -> void:
	_attack_id = attack_id
	_damage = damage
	_attacker = attacker


func _ready() -> void:
	add_to_group(&"chapter_03_boss_danger_zone")
	queue_redraw()


func _process(delta: float) -> void:
	_elapsed += delta
	if not _strike_started and _elapsed >= telegraph_duration:
		_strike_started = true
		if hitbox != null:
			hitbox.begin_attack(_attack_id, _damage, 0.0, _attacker)
		if strike_audio != null:
			strike_audio.play()
	if _strike_started and not _strike_finished and _elapsed >= telegraph_duration + active_duration:
		_strike_finished = true
		if hitbox != null:
			hitbox.end_attack()
	if _elapsed >= telegraph_duration + visual_duration:
		finished.emit(_attack_id)
		queue_free()
		return
	queue_redraw()


func cancel() -> void:
	if hitbox != null:
		hitbox.end_attack()
	queue_free()


func _draw() -> void:
	var cold_white: Color = Color("e7f4ff")
	var pale_blue: Color = Color("8ebbd6")
	var muted_gold: Color = Color("a98f55")
	var dark_edge: Color = Color("162b4b")
	if _elapsed < telegraph_duration:
		var progress: float = clampf(_elapsed / telegraph_duration, 0.0, 1.0)
		var pulse: float = 0.45 + sin(_elapsed * 18.0) * 0.10
		draw_arc(Vector2.ZERO, seal_radius, 0.0, TAU, 32, Color(pale_blue, 0.18 + progress * 0.46), 2.0)
		draw_arc(Vector2.ZERO, seal_radius * 0.62, 0.0, TAU, 26, Color(muted_gold, 0.12 + progress * 0.36), 1.0)
		for index: int in range(13):
			var angle: float = TAU * float(index) / 13.0
			var outer: Vector2 = Vector2(cos(angle), sin(angle) * 0.36) * seal_radius
			draw_circle(outer, 1.0 + progress, Color(cold_white, pulse * progress))
		var spire: PackedVector2Array = PackedVector2Array([
			Vector2(-10.0, -6.0), Vector2(0.0, -18.0), Vector2(10.0, -6.0)
		])
		draw_polyline(spire, Color(pale_blue, 0.20 + progress * 0.65), 2.0)
		draw_circle(Vector2.ZERO, 2.0 + progress * 3.0, Color(cold_white, progress))
		return
	var strike_age: float = _elapsed - telegraph_duration
	var fade: float = 1.0 - clampf(strike_age / visual_duration, 0.0, 1.0)
	var bolt: PackedVector2Array = PackedVector2Array([
		Vector2(-5.0, -176.0), Vector2(5.0, -138.0), Vector2(-3.0, -104.0),
		Vector2(8.0, -70.0), Vector2(-2.0, -34.0), Vector2.ZERO,
	])
	draw_polyline(bolt, Color(dark_edge, fade), 9.0)
	draw_polyline(bolt, Color(pale_blue, fade), 5.0)
	draw_polyline(bolt, Color(cold_white, fade), 2.0)
	draw_circle(Vector2.ZERO, seal_radius * (1.0 + strike_age * 2.0), Color(pale_blue, 0.42 * fade))
	draw_arc(Vector2.ZERO, seal_radius + strike_age * 18.0, 0.0, TAU, 32, Color(muted_gold, 0.65 * fade), 2.0)
	for index: int in range(7):
		var angle: float = TAU * float(index) / 7.0 + strike_age * 3.0
		var start: Vector2 = Vector2(cos(angle), sin(angle) * 0.35) * 10.0
		var end: Vector2 = Vector2(cos(angle), sin(angle) * 0.35) * (32.0 + index * 2.0)
		draw_line(start, end, Color(cold_white, fade), 1.0)
