class_name HealthPickup
extends WorldPickup

@export_range(1, 100, 1) var heal_amount: int = 10


func _on_body_entered(body: Node2D) -> void:
	var player: Player = body as Player
	if player == null or player.is_dead() or _consumed or player.health_component == null:
		return
	var health: HealthComponent = player.health_component
	if health.current_health >= health.max_health:
		return
	var before: int = health.current_health
	health.heal(heal_amount)
	var applied: int = health.current_health - before
	if applied <= 0:
		return
	_show_feedback(player, applied)
	_consume()


func _show_feedback(player: Player, applied: int) -> void:
	for index: int in range(6):
		var particle: Polygon2D = Polygon2D.new()
		particle.polygon = PackedVector2Array([
			Vector2(-1, -1), Vector2(1, -1), Vector2(1, 1), Vector2(-1, 1),
		])
		particle.color = Color("8f2638") if index % 2 == 0 else Color("c0525f")
		particle.position = Vector2(float((index % 3) * 5 - 5), float(-33 - (index / 3) * 4))
		player.add_child(particle)
		var direction: float = -1.0 if index % 2 == 0 else 1.0
		var particle_tween: Tween = particle.create_tween()
		particle_tween.set_parallel(true)
		particle_tween.tween_property(
			particle, "position", particle.position + Vector2(direction * float(5 + index), -12.0), 0.55
		)
		particle_tween.tween_property(particle, "modulate:a", 0.0, 0.55)
		particle_tween.chain().tween_callback(particle.queue_free)
	var label: Label = Label.new()
	label.text = "+%d HP" % applied
	label.add_theme_font_size_override("font_size", 11)
	label.add_theme_color_override("font_color", Color("d87979"))
	player.add_child(label)
	label.position = Vector2(-18, -50)
	var tween: Tween = label.create_tween()
	tween.set_parallel(true)
	tween.tween_property(label, "position:y", -64.0, 0.75)
	tween.tween_property(label, "modulate:a", 0.0, 0.75)
	tween.chain().tween_callback(label.queue_free)
