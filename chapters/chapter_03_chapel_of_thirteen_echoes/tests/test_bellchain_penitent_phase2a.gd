extends SceneTree

const ENEMY_SCENE_PATH: String = (
	"res://chapters/chapter_03_chapel_of_thirteen_echoes/scenes/enemies/bellchain_penitent.tscn"
)
const TEST_ROOM_PATH: String = (
	"res://chapters/chapter_03_chapel_of_thirteen_echoes/scenes/tests/bellchain_penitent_test_room.tscn"
)
const MAIN_LEVEL_PATH: String = (
	"res://chapters/chapter_03_chapel_of_thirteen_echoes/scenes/level/chapter_03_entry_placeholder.tscn"
)

var _failures: Array[String] = []


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	_test_standalone_enemy_contract()
	await _test_death_and_loot_contract()
	await _test_runtime_actions()
	await _test_main_integration()
	_finish()


func _test_standalone_enemy_contract() -> void:
	var packed: PackedScene = load(ENEMY_SCENE_PATH) as PackedScene
	_expect(packed != null, "Bellchain enemy scene must load")
	if packed == null:
		return
	var enemy: BellchainPenitent = packed.instantiate() as BellchainPenitent
	_expect(enemy != null, "Bellchain enemy root type mismatch")
	if enemy == null:
		return
	root.add_child(enemy)
	var tuning: BellchainPenitentConfig = enemy.config as BellchainPenitentConfig
	_expect(tuning != null, "Bellchain typed config missing")
	if tuning != null:
		_expect(tuning.max_health == 70, "Bellchain HP must be 70")
		_expect(tuning.max_poise == 32, "Bellchain Poise must be 32")
		_expect(tuning.attack_damage == 11, "Chain Lash damage must be 11")
		_expect(tuning.bell_slam_damage == 13, "Bell Slam damage must be 13")
		_expect(tuning.chain_pull_damage == 8, "Short Chain Pull damage must be 8")
		_expect(is_equal_approx(tuning.chain_pull_cooldown, 3.0), "Pull cooldown must be 3 seconds")
	var frames: SpriteFrames = enemy.animated_sprite.sprite_frames
	var required: Dictionary[StringName, int] = {
		&"idle": 4, &"walk": 6, &"alert": 3, &"turn": 3,
		&"chain_lash_windup": 5, &"chain_lash_active": 2, &"chain_lash_recovery": 5,
		&"bell_slam_windup": 7, &"bell_slam_active": 2, &"bell_slam_recovery": 6,
		&"chain_pull_windup": 5, &"chain_pull_active": 2, &"chain_pull_recovery": 5,
		&"light_hit": 2, &"stagger": 4, &"hurt": 3, &"death": 6,
	}
	var total_frames: int = 0
	for animation_name: StringName in required:
		_expect(frames.has_animation(animation_name), "Missing animation %s" % animation_name)
		if frames.has_animation(animation_name):
			_expect(
				frames.get_frame_count(animation_name) == required[animation_name],
				"Animation %s frame count mismatch" % animation_name
			)
			for frame_index: int in range(frames.get_frame_count(animation_name)):
				var texture: Texture2D = frames.get_frame_texture(animation_name, frame_index)
				var image: Image = texture.get_image() if texture != null else null
				_expect(image != null, "%s frame %d texture missing" % [animation_name, frame_index])
				if image != null:
					_expect(
						image.get_size() == Vector2i(64, 64),
						"%s frame %d must be 64x64" % [animation_name, frame_index]
					)
					_expect(
						image.get_used_rect().has_area(),
						"%s frame %d has no visible pixels" % [animation_name, frame_index]
					)
					_expect(
						image.get_pixel(0, 0).a < 0.01,
						"%s frame %d lost transparent background" % [animation_name, frame_index]
					)
				total_frames += 1
	_expect(total_frames == 70, "Bellchain production frame total must be 70")
	_expect(frames.get_animation_loop(&"idle"), "Idle must loop")
	_expect(frames.get_animation_loop(&"walk"), "Walk must loop")
	_expect(not frames.get_animation_loop(&"death"), "Death must not loop")
	_expect(enemy.animated_sprite.texture_filter == CanvasItem.TEXTURE_FILTER_NEAREST, "Enemy texture filter must be Nearest")
	_expect(enemy.chain_lash_hitbox.attack_kind == &"enemy_chain_lash", "Lash hitbox kind mismatch")
	_expect(enemy.bell_slam_hitbox.attack_kind == &"enemy_bell_slam", "Slam hitbox kind mismatch")
	_expect(enemy.chain_pull_hitbox.attack_kind == &"enemy_chain_pull", "Pull hitbox kind mismatch")
	var normal_hit: HitboxComponent = HitboxComponent.new()
	normal_hit.attack_kind = &"normal_attack"
	enemy._on_hit_resolving(normal_hit)
	_expect(enemy.poise_current == 18, "Normal attack Poise damage mismatch")
	var dash_hit: HitboxComponent = HitboxComponent.new()
	dash_hit.attack_kind = &"dash_attack"
	enemy._on_hit_resolving(dash_hit)
	_expect(enemy.get_state_name() == &"Stagger", "Poise break must enter Stagger")
	normal_hit.free()
	dash_hit.free()
	enemy.queue_free()


func _test_death_and_loot_contract() -> void:
	var packed: PackedScene = load(ENEMY_SCENE_PATH) as PackedScene
	if packed == null:
		return
	var enemy: BellchainPenitent = packed.instantiate() as BellchainPenitent
	root.add_child(enemy)
	var death_count: Array[int] = [0]
	var drop_count: Array[int] = [0]
	enemy.enemy_died.connect(func() -> void: death_count[0] += 1)
	var loot: LootDropComponent = enemy.get_node_or_null("LootDropComponent") as LootDropComponent
	_expect(loot != null, "Bellchain LootDropComponent missing")
	if loot != null:
		loot.force_drop = LootDropComponent.ForceDrop.NONE
		loot.drop_resolved.connect(
			func(_kind: StringName, _amount: int, _roll: float, _player_kill: bool) -> void:
				drop_count[0] += 1
		)
	enemy.health_component.take_damage(70)
	await process_frame
	_expect(enemy.get_state_name() == &"Death", "Lethal damage must enter Death")
	_expect(not enemy.hurtbox.is_enabled, "Death must disable Hurtbox")
	_expect(not enemy.is_attack_window_active(), "Death must close every attack hitbox")
	_expect(death_count[0] == 1, "enemy_died must emit exactly once")
	_expect(drop_count[0] == 1, "Death must resolve exactly one loot roll")
	enemy.health_component.take_damage(70)
	_expect(death_count[0] == 1, "Repeated lethal damage duplicated enemy_died")
	for _frame: int in range(90):
		await physics_frame
		if not is_instance_valid(enemy):
			break
	_expect(not is_instance_valid(enemy), "Death animation must clean the enemy instance")


func _test_runtime_actions() -> void:
	var packed: PackedScene = load(TEST_ROOM_PATH) as PackedScene
	_expect(packed != null, "Bellchain test room must load")
	if packed == null:
		return
	var room: Node = packed.instantiate()
	root.add_child(room)
	current_scene = room
	for _frame: int in range(5):
		await process_frame
	var enemy: BellchainPenitent = room.get_node_or_null("Enemies/BellchainPenitent") as BellchainPenitent
	var player: Player = room.get_node_or_null("ChapterRuntime/Player") as Player
	_expect(enemy != null and player != null, "Test room actors missing")
	if enemy != null and player != null:
		enemy.set_facing_direction(-1.0)
		player.global_position = enemy.global_position + Vector2(-40.0, 0.0)
		player.health_component.reset_to_full()
		player.hurtbox.set_invulnerable(false)
		enemy.set_target(player)
		var visited_states: Dictionary[StringName, bool] = {}
		enemy.state_changed.connect(
			func(_previous: StringName, current: StringName) -> void: visited_states[current] = true
		)
		enemy._start_attack(&"chain_lash", 11, 0.42, 0.12, 0.52)
		for _frame: int in range(85):
			await physics_frame
		_expect(
			player.health_component.current_health == 89,
			"Chain Lash must deal exactly 11 once across its two active frames"
		)
		player.global_position = enemy.global_position + Vector2(-26.0, 0.0)
		player.velocity = Vector2.ZERO
		player.health_component.reset_to_full()
		player.hurtbox.set_invulnerable(false)
		enemy.set_facing_direction(-1.0)
		enemy._start_attack(&"bell_slam", 13, 0.62, 0.14, 0.76)
		for _frame: int in range(110):
			await physics_frame
		_expect(
			player.health_component.current_health == 87,
			"Bell Slam must deal exactly 13 once"
		)
		player.global_position = enemy.global_position + Vector2(-58.0, 0.0)
		player.velocity = Vector2.ZERO
		player.health_component.reset_to_full()
		player.hurtbox.set_invulnerable(false)
		enemy.set_facing_direction(-1.0)
		enemy._start_attack(&"chain_pull", 8, 0.48, 0.10, 0.60)
		for _frame: int in range(95):
			await physics_frame
		_expect(
			player.health_component.current_health == 92,
			"Short Chain Pull must deal exactly 8 once"
		)
		_expect(
			visited_states.has(&"chain_pullWindup")
			or visited_states.has(&"chain_lashWindup")
			or visited_states.has(&"bell_slamWindup"),
			"Runtime AI never entered an attack windup"
		)
		_expect(not enemy.is_dead(), "Bellchain died during passive runtime test")
	room.queue_free()
	await process_frame


func _test_main_integration() -> void:
	var packed: PackedScene = load(MAIN_LEVEL_PATH) as PackedScene
	_expect(packed != null, "Chapter III F5 level must load")
	if packed == null:
		return
	var level: Node = packed.instantiate()
	root.add_child(level)
	current_scene = level
	for _frame: int in range(5):
		await process_frame
	var enemy: BellchainPenitent = level.get_node_or_null(
		"GameplayWorld/Phase2AEncounter/Enemies/BellchainPenitent"
	) as BellchainPenitent
	var encounter: EncounterGroup = level.get_node_or_null(
		"GameplayWorld/Phase2AEncounter"
	) as EncounterGroup
	_expect(enemy != null, "Chapter III Main is missing Bellchain instance")
	_expect(encounter != null, "Chapter III Main is missing Phase2A encounter")
	_expect(level.get_node_or_null("SpawnPoints/CH3_BELLCHAIN_TEST") != null, "Debug spawn missing")
	if enemy != null:
		_expect(enemy.get_movement_bounds() == Vector2(1040, 1540), "Main movement bounds mismatch")
		_expect(not enemy.is_ai_active(), "Main prototype encounter must wait for activation")
	level.queue_free()
	await process_frame


func _expect(condition: bool, message: String) -> void:
	if not condition:
		_failures.append(message)


func _finish() -> void:
	if _failures.is_empty():
		print(
			"BELLCHAIN_PHASE2A_TEST: PASS animations=17 frames=70 hp=70 poise=32 "
			+ "attacks=3 solo_test=1 main_encounter=1 spawn=CH3_BELLCHAIN_TEST"
		)
		quit(0)
		return
	for failure: String in _failures:
		push_error("BELLCHAIN_PHASE2A_TEST: %s" % failure)
	quit(1)
