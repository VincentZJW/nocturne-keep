extends SceneTree

const ROOT: String = "res://chapters/chapter_03_chapel_of_thirteen_echoes"
const ROLES: Array[String] = [
	"censer_executioner", "silent_chorister", "stained_glass_seraph",
	"confessional_wraith", "thirteenth_scribe",
]
const EXPECTED: Dictionary = {
	"censer_executioner": [126, 82, 14, "overhead_crush", 17, "smoke_release", 4],
	"silent_chorister": [84, 36, 10, "crescent_hymn", 12, "hush_field", 0],
	"stained_glass_seraph": [76, 30, 9, "dive", 13, "shatter_burst", 8],
	"confessional_wraith": [82, 38, 12, "spectral_dash", 11, "confession_scream", 10],
	"thirteenth_scribe": [98, 46, 10, "binding_script", 8, "thirteenth_seal", 13],
}

var _failures: Array[String] = []


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var total_frames: int = 0
	for role: String in ROLES:
		total_frames += await _test_role(role)
	await _test_shared_volley_ledger()
	await _test_scribe_ward()
	_test_player_modifiers()
	await _test_saved_integration()
	_expect(total_frames == 345, "Remaining roster must contain exactly 345 generated frames")
	_finish(total_frames)


func _test_role(role: String) -> int:
	var scene_path: String = "%s/scenes/enemies/%s.tscn" % [ROOT, role]
	var packed: PackedScene = load(scene_path) as PackedScene
	_expect(packed != null, "%s scene missing" % role)
	if packed == null: return 0
	var enemy: Chapter03SpecialistEnemy = packed.instantiate() as Chapter03SpecialistEnemy
	_expect(enemy != null, "%s root type mismatch" % role)
	if enemy == null: return 0
	root.add_child(enemy)
	await process_frame
	var c: Chapter03SpecialistConfig = enemy.config as Chapter03SpecialistConfig
	var expected: Array = EXPECTED[role] as Array
	_expect(c != null, "%s typed config missing" % role)
	if c != null:
		_expect(c.chapter_max_health == int(expected[0]), "%s HP mismatch" % role)
		_expect(c.max_poise == int(expected[1]), "%s Poise mismatch" % role)
		_expect(c.attack_damage == int(expected[2]), "%s primary damage mismatch" % role)
		_expect(c.secondary_action == StringName(expected[3]), "%s secondary name mismatch" % role)
		_expect(c.secondary_damage == int(expected[4]), "%s secondary damage mismatch" % role)
		_expect(c.special_action == StringName(expected[5]), "%s special name mismatch" % role)
		_expect(c.special_damage == int(expected[6]), "%s special damage mismatch" % role)
	_expect(enemy.health_component.max_health == int(expected[0]), "%s runtime HP did not use chapter_max_health" % role)
	_expect(enemy.get_node_or_null("LootDropComponent") is LootDropComponent, "%s LootDropComponent missing" % role)
	_expect(enemy.animated_sprite.texture_filter == CanvasItem.TEXTURE_FILTER_NEAREST, "%s filter is not nearest" % role)
	var frames: SpriteFrames = enemy.animated_sprite.sprite_frames
	var total: int = 0
	for animation: StringName in frames.get_animation_names():
		var count: int = frames.get_frame_count(animation)
		total += count
		for index: int in range(count):
			var texture: Texture2D = frames.get_frame_texture(animation, index)
			var image: Image = texture.get_image() if texture != null else null
			_expect(image != null and image.get_size() == Vector2i(64, 64), "%s/%s frame size mismatch" % [role, animation])
			if image != null:
				_expect(image.get_pixel(0, 0).a < 0.01, "%s/%s lost transparency" % [role, animation])
	for animation: StringName in [&"idle", &"walk", &"alert", &"turn", &"light_hit", &"stagger", &"hurt", &"death"]:
		_expect(frames.has_animation(animation), "%s missing %s" % [role, animation])
	for action: StringName in [c.primary_action, c.secondary_action, c.special_action]:
		for phase: String in ["windup", "active", "recovery"]:
			_expect(frames.has_animation(StringName("%s_%s" % [action, phase])), "%s missing %s %s" % [role, action, phase])
	if role == "confessional_wraith":
		_expect(frames.has_animation(&"hidden"), "Wraith hidden animation missing")
	enemy.queue_free()
	await process_frame
	return total


func _test_shared_volley_ledger() -> void:
	var target_root: Node2D = Node2D.new(); root.add_child(target_root)
	var health: HealthComponent = HealthComponent.new(); health.name = "HealthComponent"; health.max_health = 100; target_root.add_child(health)
	var hurtbox: HurtboxComponent = HurtboxComponent.new(); hurtbox.name = "Hurtbox"; hurtbox.faction = &"player"; target_root.add_child(hurtbox)
	await process_frame
	var ledger: Dictionary[int, bool] = {}
	var first: HitboxComponent = HitboxComponent.new(); first.faction = &"enemy"; root.add_child(first)
	var second: HitboxComponent = HitboxComponent.new(); second.faction = &"enemy"; root.add_child(second)
	await process_frame
	first.set_shared_target_ledger(ledger); second.set_shared_target_ledger(ledger)
	first.begin_attack(77, 9); second.begin_attack(77, 9)
	_expect(first.try_hit(hurtbox), "First Seraph shard was rejected")
	_expect(not second.try_hit(hurtbox), "Shared volley damaged one target twice")
	_expect(health.current_health == 91, "Shared volley damage must settle once")
	first.queue_free(); second.queue_free(); target_root.queue_free(); await process_frame


func _test_scribe_ward() -> void:
	var packed: PackedScene = load("%s/scenes/enemies/thirteenth_scribe.tscn" % ROOT) as PackedScene
	var scribe: Chapter03SpecialistEnemy = packed.instantiate() as Chapter03SpecialistEnemy
	root.add_child(scribe); await process_frame
	var hit: HitboxComponent = HitboxComponent.new(); hit.faction = &"player"; root.add_child(hit); await process_frame
	hit.begin_attack(901, 12, 1.0, hit)
	_expect(hit.try_hit(scribe.hurtbox), "Paper Ward did not consume first normal hit")
	_expect(scribe.health_component.current_health == 98, "Paper Ward did not absorb one hit")
	hit.end_attack()
	await physics_frame
	var second_hit: HitboxComponent = HitboxComponent.new(); second_hit.faction = &"player"; root.add_child(second_hit); await process_frame
	second_hit.begin_attack(902, 12, 1.0, second_hit)
	_expect(second_hit.try_hit(scribe.hurtbox), "Post-ward hit was rejected")
	_expect(scribe.health_component.current_health == 86, "Post-ward hit damage mismatch")
	hit.queue_free(); second_hit.queue_free(); scribe.queue_free(); await process_frame


func _test_player_modifiers() -> void:
	var stamina: PlayerStaminaComponent = PlayerStaminaComponent.new()
	stamina.stamina_regen_rate = 40.0
	stamina.set_regeneration_modifier(&"hush_test", 0.65)
	_expect(is_equal_approx(stamina.get_regeneration_rate(true), 26.0), "Hush multiplier mismatch")
	stamina.clear_regeneration_modifier(&"hush_test")
	_expect(is_equal_approx(stamina.get_regeneration_rate(true), 40.0), "Hush cleanup failed")
	var player: Player = Player.new()
	player.set_movement_speed_modifier(&"binding_test", 0.8)
	_expect(is_equal_approx(player.get_movement_speed_multiplier(), 0.8), "Binding slow multiplier mismatch")
	player.clear_movement_speed_modifier(&"binding_test")
	_expect(is_equal_approx(player.get_movement_speed_multiplier(), 1.0), "Binding cleanup failed")
	stamina.free(); player.free()


func _test_saved_integration() -> void:
	var room: PackedScene = load("%s/scenes/tests/chapter_03_enemy_combination_test_room.tscn" % ROOT) as PackedScene
	_expect(room != null, "Six-enemy combination room missing")
	var main: PackedScene = load("%s/scenes/level/chapter_03_entry_placeholder.tscn" % ROOT) as PackedScene
	_expect(main != null, "Chapter III Main level missing")
	if main == null: return
	var level: Node = main.instantiate(); root.add_child(level); current_scene = level
	await process_frame; await process_frame
	var paths: Array[String] = [
		"GameplayWorld/Phase2AEncounter/Enemies/BellchainPenitent",
		"GameplayWorld/Phase2BEncounter/Enemies/CenserExecutioner",
		"GameplayWorld/Phase2CDEEncounter/Enemies/SilentChorister",
		"GameplayWorld/Phase2CDEEncounter/Enemies/StainedGlassSeraph",
		"GameplayWorld/Phase2CDEEncounter/Enemies/ConfessionalWraith",
		"GameplayWorld/Phase2FEncounter/Enemies/ThirteenthScribe",
	]
	for path: String in paths: _expect(level.get_node_or_null(path) != null, "Main missing %s" % path)
	for spawn: String in ["CH3_BELLCHAIN_TEST", "CH3_EXECUTIONER_TEST", "CH3_CHOIR_TEST", "CH3_SCRIBE_TEST"]:
		_expect(level.get_node_or_null("SpawnPoints/%s" % spawn) != null, "Main missing spawn %s" % spawn)
	level.queue_free(); await process_frame


func _expect(condition: bool, message: String) -> void:
	if not condition: _failures.append(message)


func _finish(total_frames: int) -> void:
	if _failures.is_empty():
		print("CH3_PHASE2_ROSTER_TEST: PASS roles=6 remaining_frames=%d main=6 combination_room=1" % total_frames)
		quit(0); return
	for failure: String in _failures: push_error("CH3_PHASE2_ROSTER_TEST: %s" % failure)
	quit(1)
