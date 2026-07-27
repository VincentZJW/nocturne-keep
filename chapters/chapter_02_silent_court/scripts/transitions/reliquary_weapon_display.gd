class_name ReliquaryWeaponDisplay
extends Node2D


func _draw() -> void:
	# Crimson Needle and shorter Masque Fan Blade cross without becoming one silhouette.
	_draw_stiletto(Vector2(-56, 28), Vector2(58, -30), true)
	_draw_stiletto(Vector2(50, 32), Vector2(-42, -24), false)


func _draw_stiletto(start: Vector2, finish: Vector2, primary: bool) -> void:
	draw_line(start, finish, Color("d8dfe3"), 5.0 if primary else 4.0)
	var direction: Vector2 = (finish - start).normalized()
	var normal: Vector2 = Vector2(-direction.y, direction.x)
	draw_line(start - direction * 16.0, start + direction * 14.0, Color("2b2430"), 8.0)
	draw_line(start + normal * 13.0, start - normal * 13.0, Color("9a3148"), 5.0)
	draw_circle(start, 7.0, Color("d4cbc6"))
	draw_line(finish - direction * 46.0, finish, Color("8f263d"), 2.0)
