extends SceneTree

const ROOT: String = "res://chapters/chapter_04_drowned_underkeep"
const ROLES: Array[String] = [
	"drowned_gaoler", "chainbound_convict", "mire_harpooner",
	"sunken_shield_penitent", "mirefin_raider", "bog_toad", "sewer_maw",
	"underkeep_executioner",
]

var _failures: int = 0


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var host: Node2D = Node2D.new()
	root.add_child(host)
	for role: String in ROLES:
		var path: String = "%s/scenes/enemies/%s.tscn" % [ROOT, role]
		var scene: PackedScene = load(path) as PackedScene
		_expect(scene != null, "%s scene loads" % role)
		if scene == null:
			continue
		var enemy: Chapter04Enemy = scene.instantiate() as Chapter04Enemy
		_expect(enemy != null, "%s instantiates as Chapter04Enemy" % role)
		if enemy == null:
			continue
		host.add_child(enemy)
		await process_frame
		var data: Chapter04EnemyConfig = enemy.config as Chapter04EnemyConfig
		_expect(data != null, "%s owns Chapter04EnemyConfig" % role)
		_expect(enemy.health_component.current_health == data.chapter_max_health, "%s runtime HP matches chapter data" % role)
		_expect(enemy.animated_sprite.sprite_frames.get_animation_names().size() >= 17, "%s has full animation set" % role)
		_expect(enemy.primary_hitbox != null and enemy.secondary_hitbox != null, "%s combat hitboxes exist" % role)
		for action: StringName in [data.primary_action, data.secondary_action, data.special_action]:
			for phase: String in ["windup", "active", "recovery"]:
				var animation: StringName = StringName("%s_%s" % [action, phase])
				_expect(enemy.animated_sprite.sprite_frames.has_animation(animation), "%s owns %s" % [role, animation])
		var idle_texture: Texture2D = enemy.animated_sprite.sprite_frames.get_frame_texture(&"idle", 0)
		var idle_image: Image = idle_texture.get_image()
		_expect(idle_image.get_size() == Vector2i(96, 96), "%s runtime frame is 96x96" % role)
		_expect(is_zero_approx(idle_image.get_pixel(0, 0).a), "%s frame keeps transparent background" % role)
		enemy.queue_free()
		await process_frame
	print("CH4 ENEMY RUNTIME TEST | %s" % ("PASS" if _failures == 0 else "FAIL %d" % _failures))
	quit(0 if _failures == 0 else 1)


func _expect(condition: bool, message: String) -> void:
	if condition:
		return
	_failures += 1
	push_error(message)
