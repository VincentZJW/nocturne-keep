class_name DuchessReliquary
extends Node2D

## Persistent presentation shell; pickup/inventory ownership remains in the transition controller.

@export_node_path("Node2D") var weapon_display_path: NodePath = NodePath("WeaponDisplay")
@export_node_path("Marker2D") var pickup_anchor_path: NodePath = NodePath("WeaponDisplay/PickupAnchor")

@onready var weapon_display: Node2D = get_node_or_null(weapon_display_path) as Node2D
@onready var pickup_anchor: Marker2D = get_node_or_null(pickup_anchor_path) as Marker2D

var is_unlocked: bool = false
var is_collected: bool = false
var unlock_progress: float = 0.0:
	set(value):
		unlock_progress = clampf(value, 0.0, 1.0)
		queue_redraw()


func set_unlocked(unlocked: bool, immediate: bool = false) -> void:
	is_unlocked = unlocked
	if not unlocked:
		unlock_progress = 0.0
		return
	if immediate:
		unlock_progress = 1.0
		return
	var tween: Tween = create_tween()
	tween.tween_property(self, "unlock_progress", 1.0, 0.72).set_trans(Tween.TRANS_SINE)


func set_collected(collected: bool) -> void:
	is_collected = collected
	if weapon_display != null:
		weapon_display.visible = not collected
	queue_redraw()


func _draw() -> void:
	# Medieval stone/oxidized-gold cabinet, velvet lining, old glass and family crest.
	draw_rect(Rect2(-176, -276, 352, 276), Color("1b171d"), true)
	draw_rect(Rect2(-162, -260, 324, 244), Color("56482f"), false, 12.0)
	draw_rect(Rect2(-136, -224, 272, 178), Color("3a101c"), true)
	draw_rect(Rect2(-128, -216, 256, 162), Color(0.34, 0.39, 0.43, 0.16), true)
	draw_circle(Vector2(0, -246), 24.0, Color("80704d"))
	draw_arc(Vector2(0, -240), 12.0, PI, TAU, 18, Color("1b171d"), 4.0)
	for side: int in [-1, 1]:
		var x: float = float(side) * 210.0
		draw_rect(Rect2(x - 8, -90, 16, 90), Color("65543e"), true)
		draw_circle(Vector2(x, -104), 10.0, Color("d19458") if is_unlocked else Color("514442"))
	# Porcelain fragments and soul lock communicate Boss provenance and locked state.
	for shard: int in range(7):
		var x: float = -88.0 + float(shard) * 28.0
		draw_colored_polygon(PackedVector2Array([Vector2(x, -62), Vector2(x + 11, -75), Vector2(x + 18, -57)]), Color("d0cbc8"))
	if not is_unlocked:
		draw_circle(Vector2(0, -132), 46.0, Color(0.30, 0.08, 0.20, 0.50))
		for chain: int in range(4):
			draw_line(Vector2(-120, -206 + chain * 46), Vector2(120, -70 - chain * 18), Color("7c3553"), 5.0)
	elif unlock_progress < 1.0:
		for spark: int in range(8):
			var angle: float = TAU * float(spark) / 8.0
			draw_circle(Vector2(0, -132) + Vector2(58.0, 35.0).rotated(angle) * unlock_progress, 4.0, Color("d7c1a0"))
	if is_collected:
		draw_string(ThemeDB.fallback_font, Vector2(-80, -126), "RELIQUARY EMPTY", HORIZONTAL_ALIGNMENT_CENTER, 160, 12, Color(0.66, 0.61, 0.58, 0.72))
