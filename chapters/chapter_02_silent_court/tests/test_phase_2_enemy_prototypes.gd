extends SceneTree

const ENEMY_ROOT: String = "res://chapters/chapter_02_silent_court"
const ENEMIES: Array[Dictionary] = [
	{"slug": "hollow_retainer", "class": "SilentCourtGroundEnemy", "hp": 48, "damage": 7, "animations": [&"idle", &"walk", &"alert", &"attack_single_stab", &"attack_combo", &"hurt", &"death"]},
	{"slug": "court_halberdier", "class": "SilentCourtGroundEnemy", "hp": 72, "damage": 10, "animations": [&"idle", &"walk", &"turn", &"attack_thrust", &"attack_sweep", &"attack_shaft_push", &"hurt", &"death"]},
	{"slug": "mourning_armor", "class": "SilentCourtGroundEnemy", "hp": 96, "damage": 14, "animations": [&"idle", &"walk", &"turn", &"attack_overhead", &"attack_shoulder_bash", &"attack_heavy_sweep", &"stagger", &"hurt", &"death"]},
	{"slug": "blood_candle_acolyte", "class": "SilentCourtGroundEnemy", "hp": 60, "damage": 8, "animations": [&"idle", &"walk", &"attack_cast", &"buff_channel", &"hurt", &"death"]},
	{"slug": "hanging_stalker", "class": "HangingStalker", "hp": 48, "damage": 9, "animations": [&"hang", &"telegraph", &"drop", &"ground_recovery", &"claw", &"retreat", &"return_to_anchor", &"hurt", &"death"]},
]

var _failures: Array[String] = []


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	_test_saved_contracts()
	await _test_scene_instantiation()
	await _test_mourning_armor_policy()
	await _test_retainer_attack_cadence()
	await _test_acolyte_projectile_and_buff()
	await _test_stalker_direction_lock()
	await _finish()


func _test_saved_contracts() -> void:
	for entry: Dictionary in ENEMIES:
		var slug: String = entry["slug"] as String
		var scene_path: String = "%s/scenes/enemies/%s.tscn" % [ENEMY_ROOT, slug]
		var frames_path: String = "%s/assets/enemies/%s/animations/%s_sprite_frames.tres" % [ENEMY_ROOT, slug, slug]
		var concept_path: String = "%s/assets/enemies/%s/concept_art/%s_concept.svg" % [ENEMY_ROOT, slug, slug]
		_expect(ResourceLoader.exists(scene_path, "PackedScene"), "Missing scene %s" % slug)
		_expect(ResourceLoader.exists(frames_path, "SpriteFrames"), "Missing SpriteFrames %s" % slug)
		_expect(ResourceLoader.exists(concept_path), "Missing concept source %s" % slug)
		var frames: SpriteFrames = ResourceLoader.load(frames_path, "SpriteFrames") as SpriteFrames
		if frames != null:
			for animation: StringName in entry["animations"] as Array[StringName]:
				_expect(frames.has_animation(animation), "%s missing %s" % [slug, animation])
				if frames.has_animation(animation):
					_expect(frames.get_frame_count(animation) >= 2, "%s/%s has too few frames" % [slug, animation])
		var idle_animation: String = "hang" if slug == "hanging_stalker" else "idle"
		var png_path: String = "%s/assets/enemies/%s/sprites/%s/%s_01.png" % [ENEMY_ROOT, slug, idle_animation, idle_animation]
		var texture: Texture2D = ResourceLoader.load(png_path, "Texture2D") as Texture2D
		_expect(texture != null and texture.get_width() == 64 and texture.get_height() == 64, "%s source frame is not 64x64" % slug)
		var image: Image = texture.get_image() if texture != null else Image.new()
		_expect(not image.is_empty() and image.detect_alpha() != Image.ALPHA_NONE, "%s source frame lacks transparency" % slug)
		image = null
		texture = null
	_expect(ResourceLoader.exists("%s/scenes/tests/phase_2_enemy_prototype_room.tscn" % ENEMY_ROOT, "PackedScene"), "Prototype room is missing")


func _test_scene_instantiation() -> void:
	var fixture: Node2D = _make_fixture()
	root.add_child(fixture)
	await process_frame
	for entry: Dictionary in ENEMIES:
		var slug: String = entry["slug"] as String
		var packed: PackedScene = ResourceLoader.load("%s/scenes/enemies/%s.tscn" % [ENEMY_ROOT, slug], "PackedScene") as PackedScene
		var enemy: EnemyCombatant = packed.instantiate() as EnemyCombatant if packed != null else null
		_expect(enemy != null, "%s did not instantiate as EnemyCombatant" % slug)
		if enemy == null:
			continue
		fixture.add_child(enemy)
		enemy.global_position = Vector2(180.0 + fixture.get_child_count() * 120.0, 584.0)
		await process_frame
		enemy.set_ai_active(false)
		var health: HealthComponent = enemy.get_health_component()
		_expect(health != null and health.max_health == int(entry["hp"]), "%s HP mismatch" % slug)
		_expect(enemy.get_attack_damage() == int(entry["damage"]), "%s primary damage mismatch" % slug)
		_expect(enemy.get_current_animation_name() != &"", "%s has no current animation" % slug)
	await _dispose_fixture(fixture)


func _test_mourning_armor_policy() -> void:
	var fixture: Node2D = _make_fixture()
	root.add_child(fixture)
	var armor: SilentCourtGroundEnemy = _instantiate_enemy("mourning_armor") as SilentCourtGroundEnemy
	fixture.add_child(armor)
	armor.global_position = Vector2(500, 584)
	var source: Node2D = Node2D.new()
	fixture.add_child(source)
	var hitbox: HitboxComponent = HitboxComponent.new()
	hitbox.faction = &"player"
	hitbox.attack_kind = &"normal_attack"
	fixture.add_child(hitbox)
	await process_frame
	armor.set_ai_active(false)
	var hurtbox: HurtboxComponent = armor.get_node("Hurtbox") as HurtboxComponent
	source.global_position = armor.global_position + Vector2(-50, 0)
	hitbox.begin_attack(101, 12, 1.0, source)
	_expect(hurtbox.receive_hit(hitbox), "Mourning Armor rejected frontal Normal")
	_expect(armor.health_component.current_health == 87, "Frontal Normal must resolve 12 to 9")
	hitbox.end_attack()
	source.global_position = armor.global_position + Vector2(50, 0)
	hitbox.begin_attack(102, 12, -1.0, source)
	_expect(hurtbox.receive_hit(hitbox), "Mourning Armor rejected rear Normal")
	_expect(armor.health_component.current_health == 75, "Rear Normal must resolve full 12")
	await _dispose_fixture(fixture)


func _test_retainer_attack_cadence() -> void:
	var fixture: Node2D = _make_fixture()
	root.add_child(fixture)
	var retainer: SilentCourtGroundEnemy = _instantiate_enemy("hollow_retainer") as SilentCourtGroundEnemy
	fixture.add_child(retainer)
	retainer.global_position = Vector2(500, 584)
	await process_frame
	retainer.set_ai_active(false)
	retainer._start_attack(&"single_stab", 7, 0.18, 0.09, 0.30)
	var saw_active: bool = false
	var saw_recovery: bool = false
	for _step: int in range(20):
		retainer._process_action(0.05)
		saw_active = saw_active or retainer.is_attack_window_active()
		saw_recovery = saw_recovery or retainer.get_attack_phase_name() == &"Recovery"
	_expect(saw_active, "Retainer never opened a melee attack window")
	_expect(saw_recovery, "Retainer attack never entered bounded Recovery")
	await _dispose_fixture(fixture)


func _test_acolyte_projectile_and_buff() -> void:
	var fixture: Node2D = _make_fixture()
	root.add_child(fixture)
	var acolyte: SilentCourtGroundEnemy = _instantiate_enemy("blood_candle_acolyte") as SilentCourtGroundEnemy
	fixture.add_child(acolyte)
	acolyte.global_position = Vector2(500, 584)
	await process_frame
	acolyte.set_ai_active(false)
	acolyte._spawn_projectile()
	await process_frame
	_expect(acolyte.active_projectiles == 1, "Acolyte did not release exactly one straight projectile")
	var ally: SilentCourtGroundEnemy = _instantiate_enemy("hollow_retainer") as SilentCourtGroundEnemy
	fixture.add_child(ally)
	ally.global_position = Vector2(540, 584)
	await process_frame
	_expect(ally.set_acolyte_buff(acolyte.get_instance_id(), 0.90), "Acolyte buff was not accepted")
	_expect(is_equal_approx(ally.windup_multiplier, 0.90), "Acolyte buff multiplier mismatch")
	_expect(not ally.set_acolyte_buff(acolyte.get_instance_id() + 1, 0.80), "A second Acolyte buff stacked")
	ally.clear_acolyte_buff(acolyte.get_instance_id())
	_expect(is_equal_approx(ally.windup_multiplier, 1.0), "Acolyte buff did not clear")
	await _dispose_fixture(fixture)


func _test_stalker_direction_lock() -> void:
	var fixture: Node2D = _make_fixture()
	root.add_child(fixture)
	var stalker: HangingStalker = _instantiate_enemy("hanging_stalker") as HangingStalker
	fixture.add_child(stalker)
	stalker.global_position = Vector2(500, 170)
	await process_frame
	stalker.set_ai_active(false)
	stalker._transition(HangingStalker.ALERT_TELEGRAPH)
	stalker.locked_drop_x = 560.0
	stalker._direction_locked = true
	stalker._transition(HangingStalker.DROP)
	stalker.velocity = stalker.global_position.direction_to(Vector2(stalker.locked_drop_x, 590.0)) * stalker.config.drop_speed
	var locked_velocity_x: float = stalker.velocity.x
	stalker._process_drop()
	_expect(stalker.get_state_name() == HangingStalker.DROP, "Stalker did not enter its drop")
	_expect(signf(stalker.velocity.x) == signf(locked_velocity_x), "Stalker changed its locked drop direction")
	_expect(is_equal_approx(stalker.config.telegraph_duration, 0.55), "Stalker telegraph duration mismatch")
	await _dispose_fixture(fixture)


func _make_fixture() -> Node2D:
	var fixture: Node2D = Node2D.new()
	var floor: StaticBody2D = StaticBody2D.new()
	floor.collision_layer = 1
	floor.collision_mask = 0
	var shape_node: CollisionShape2D = CollisionShape2D.new()
	var shape: RectangleShape2D = RectangleShape2D.new()
	shape.size = Vector2(1600, 108)
	shape_node.shape = shape
	shape_node.position = Vector2(800, 666)
	floor.add_child(shape_node)
	fixture.add_child(floor)
	return fixture


func _instantiate_enemy(slug: String) -> EnemyCombatant:
	var packed: PackedScene = ResourceLoader.load("%s/scenes/enemies/%s.tscn" % [ENEMY_ROOT, slug], "PackedScene") as PackedScene
	return packed.instantiate() as EnemyCombatant if packed != null else null


func _dispose_fixture(fixture: Node2D) -> void:
	if fixture != null and is_instance_valid(fixture):
		if fixture.get_parent() != null:
			fixture.get_parent().remove_child(fixture)
		fixture.free()
	await process_frame


func _expect(condition: bool, message: String) -> void:
	if not condition:
		_failures.append(message)


func _finish() -> void:
	await process_frame
	await process_frame
	if _failures.is_empty():
		print("CH2_PHASE2_ENEMY_PROTOTYPES_TEST: PASS enemies=5 assets=original combat=validated")
		quit(0)
		return
	for failure: String in _failures:
		push_error(failure)
	push_error("CH2_PHASE2_ENEMY_PROTOTYPES_TEST: FAIL count=%d" % _failures.size())
	quit(1)
