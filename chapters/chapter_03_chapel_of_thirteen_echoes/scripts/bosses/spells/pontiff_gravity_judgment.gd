class_name PontiffGravityJudgment
extends Node2D

@export var cast_duration: float = 1.70

@onready var bell_audio: AudioStreamPlayer2D = $BellAudio as AudioStreamPlayer2D

var target: Player
var elapsed: float = 0.0
var final_seal: bool = false
var resolved: bool = false
var compressed_branch: bool = false


func initialize(player: Player, duration: float) -> void:
	target = player
	cast_duration = duration


func _process(delta: float) -> void:
	elapsed = minf(cast_duration, elapsed + delta)
	if target != null and is_instance_valid(target):
		global_position = target.global_position + Vector2(0.0, -22.0)
	queue_redraw()


func set_final_seal() -> void:
	final_seal = true
	if bell_audio != null and not bell_audio.playing:
		bell_audio.play()
	queue_redraw()


func show_resolution(was_compressed: bool) -> void:
	resolved = true
	compressed_branch = was_compressed
	queue_redraw()


func finish() -> void:
	queue_free()


func _draw() -> void:
	var progress: float = clampf(elapsed / maxf(0.01, cast_duration), 0.0, 1.0)
	var black_blue: Color = Color("11172b")
	var muted_violet: Color = Color("665777")
	var pale_silver: Color = Color("c4d0dc")
	var dark_gold: Color = Color("867044")
	if progress >= 0.22:
		var bell_alpha: float = clampf((progress - 0.22) / 0.22, 0.0, 1.0) * 0.72
		var bell: PackedVector2Array = PackedVector2Array([
			Vector2(-24.0, -58.0), Vector2(-19.0, -76.0), Vector2(-8.0, -86.0),
			Vector2(8.0, -86.0), Vector2(19.0, -76.0), Vector2(24.0, -58.0),
			Vector2(29.0, -50.0), Vector2(-29.0, -50.0), Vector2(-24.0, -58.0),
		])
		draw_colored_polygon(bell, Color(black_blue, bell_alpha * 0.70))
		draw_polyline(bell, Color(pale_silver, bell_alpha), 2.0)
		draw_circle(Vector2(0.0, -47.0), 4.0, Color(dark_gold, bell_alpha))
	if progress >= 0.46:
		var seal_alpha: float = clampf((progress - 0.46) / 0.20, 0.0, 1.0)
		for index: int in range(13):
			var radius: float = 7.0 + float(index) * 2.25
			draw_arc(Vector2(0.0, 23.0), radius, 0.0, TAU, 28, Color(muted_violet, seal_alpha * (0.20 + index * 0.025)), 1.0)
		if final_seal:
			draw_arc(Vector2(0.0, 23.0), 36.0, 0.0, TAU, 32, Color(pale_silver, 0.80), 2.0)
	if progress >= 0.70:
		var pressure: float = clampf((progress - 0.70) / 0.30, 0.0, 1.0)
		for index: int in range(5):
			var x: float = -28.0 + float(index) * 14.0
			draw_line(Vector2(x, -30.0), Vector2(x * 0.55, 16.0), Color(muted_violet, pressure * 0.65), 2.0)
	if resolved:
		var resolve_color: Color = pale_silver if compressed_branch else Color("7d263d")
		draw_circle(Vector2(0.0, 4.0), 38.0, Color(resolve_color, 0.24))
		draw_arc(Vector2(0.0, 4.0), 42.0, 0.0, TAU, 40, Color(resolve_color, 0.85), 3.0)
