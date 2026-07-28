class_name ReliquaryWeaponDisplay
extends Node2D


func _draw() -> void:
	# Two court stilettos cross as readable weapons rather than thin metal rods.
	_draw_stiletto(Vector2(-34, 22), Vector2(38, -20), true)
	_draw_stiletto(Vector2(32, 23), Vector2(-32, -18), false)


func _draw_stiletto(pommel: Vector2, tip: Vector2, primary: bool) -> void:
	var direction: Vector2 = (tip - pommel).normalized()
	var normal: Vector2 = Vector2(-direction.y, direction.x)
	var guard_center: Vector2 = pommel + direction * (17.0 if primary else 15.0)
	var blade_base: Vector2 = guard_center + direction * 5.0
	var blade_half_width: float = 4.0 if primary else 3.5
	var blade: PackedVector2Array = PackedVector2Array([
		blade_base + normal * blade_half_width,
		tip,
		blade_base - normal * blade_half_width,
	])
	var handle_start: Vector2 = pommel + direction * 3.0
	var handle: PackedVector2Array = PackedVector2Array([
		handle_start + normal * 3.0,
		guard_center + normal * 3.0,
		guard_center - normal * 3.0,
		handle_start - normal * 3.0,
	])
	draw_colored_polygon(handle, Color("282631"))
	draw_line(handle_start, guard_center, Color("78404c"), 2.0)
	draw_line(guard_center + normal * 10.0, guard_center - normal * 10.0, Color("a44a5f"), 4.0)
	draw_circle(pommel, 4.0, Color("b78a58"))
	draw_colored_polygon(blade, Color("d8dfe3"))
	draw_line(blade_base, tip - direction * 2.0, Color("71879a"), 1.0)
	draw_line(blade_base + normal * blade_half_width, tip, Color("f0f1eb"), 1.0)
