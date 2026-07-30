extends SceneTree

const PLAYER_SCENE: String = "res://scenes/player/player.tscn"
const BOSS_SCENE: String = "res://chapters/chapter_03_chapel_of_thirteen_echoes/scenes/bosses/thirteenth_pontiff_edran.tscn"
const FIRE_SCENE: String = "res://chapters/chapter_03_chapel_of_thirteen_echoes/scenes/bosses/spells/pontiff_fireball.tscn"
const ICE_SCENE: String = "res://chapters/chapter_03_chapel_of_thirteen_echoes/scenes/bosses/spells/pontiff_ice_lance.tscn"
const MIRE_SCENE: String = "res://chapters/chapter_03_chapel_of_thirteen_echoes/scenes/bosses/spells/pontiff_mire_zone.tscn"
const MAGIC_ANIMATIONS: Array[StringName] = [
	&"fire_spell_windup", &"fire_spell_release", &"fire_spell_recovery",
	&"ice_spell_windup", &"ice_spell_release", &"ice_spell_recovery",
	&"mire_spell_windup", &"mire_spell_target_lock", &"mire_spell_activate",
	&"mire_spell_recovery",
]

var _failures: Array[String] = []
var _assertions: int = 0


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var player_scene: PackedScene = load(PLAYER_SCENE) as PackedScene
	_expect(player_scene != null, "formal Player scene loads")
	if player_scene == null:
		_finish()
		return
	var player: Player = player_scene.instantiate() as Player
	root.add_child(player)
	await process_frame
	player.set_physics_process(false)
	player.status_effect_controller.set_physics_process(false)
	_test_burn_contract(player)
	_test_freeze_contract(player)
	_test_mire_contract(player)
	_test_spell_resources()
	await _test_boss_contract(player)
	_test_summon_cadence_models()
	_test_main_route_contract()
	player.queue_free()
	await process_frame
	_finish()


func _test_burn_contract(player: Player) -> void:
	var status: PlayerStatusEffectController = player.status_effect_controller
	for trial: int in range(30):
		status.clear_all()
		player.health_component.reset_to_full()
		_expect(status.apply_burn(StringName("burn_%d" % trial), 3.0, 5, 1.0), "burn %d applies" % trial)
		_expect(player.health_component.current_health == 100, "burn %d has no instant DOT tick" % trial)
		status.advance(0.999)
		_expect(player.health_component.current_health == 100, "burn %d waits until second one" % trial)
		status.advance(0.001)
		_expect(player.health_component.current_health == 95, "burn %d tick one is five HP" % trial)
		status.advance(1.0)
		_expect(player.health_component.current_health == 90, "burn %d tick two is five HP" % trial)
		status.advance(1.0)
		_expect(player.health_component.current_health == 85, "burn %d tick three is five HP" % trial)
		_expect(not status.is_burning(), "burn %d expires after three seconds" % trial)
	status.clear_all()
	player.health_component.reset_to_full()
	status.apply_burn(&"refresh_a", 3.0, 5, 1.0)
	status.advance(1.0)
	status.apply_burn(&"refresh_b", 3.0, 5, 1.0)
	status.advance(1.0)
	_expect(player.health_component.current_health == 90, "burn refresh keeps one five-HP timer")
	status.advance(2.0)
	_expect(player.health_component.current_health == 80, "refreshed burn completes only three renewed ticks")


func _test_freeze_contract(player: Player) -> void:
	var status: PlayerStatusEffectController = player.status_effect_controller
	for trial: int in range(30):
		status.clear_all()
		_expect(status.apply_freeze(StringName("freeze_%d" % trial), 3.0, 5.0), "freeze %d applies" % trial)
		_expect(status.is_input_locked(), "freeze %d locks gameplay input" % trial)
		status.advance(2.999)
		_expect(status.is_frozen(), "freeze %d remains through the final physics frame" % trial)
		status.advance(0.001)
		_expect(not status.is_frozen(), "freeze %d expires at three seconds" % trial)
		_expect(status.is_freeze_immune(), "freeze %d grants five-second immunity" % trial)
		_expect(not status.apply_freeze(&"immune_retry", 3.0, 5.0), "freeze %d immunity rejects relock" % trial)
		status.advance(5.0)
		_expect(not status.is_freeze_immune(), "freeze %d immunity expires" % trial)


func _test_mire_contract(player: Player) -> void:
	var status: PlayerStatusEffectController = player.status_effect_controller
	for trial: int in range(30):
		status.clear_all()
		_expect(status.apply_mire(StringName("mire_%d" % trial), 0.20, 0.35, 0.70), "mire %d applies" % trial)
		_expect(is_equal_approx(player.get_movement_speed_multiplier(), 0.35), "mire %d movement is 35 percent" % trial)
		_expect(is_equal_approx(status.get_dash_multiplier(), 0.70), "mire %d dash is 70 percent" % trial)
		_expect(not status.is_input_locked(), "mire %d preserves jump and attack input" % trial)
		status.advance(0.20)
		_expect(not status.is_mired(), "mire %d expires cleanly" % trial)
		_expect(is_equal_approx(player.get_movement_speed_multiplier(), 1.0), "mire %d restores movement" % trial)


func _test_spell_resources() -> void:
	for path: String in [FIRE_SCENE, ICE_SCENE, MIRE_SCENE]:
		_expect(ResourceLoader.exists(path, "PackedScene"), "%s exists" % path.get_file())
	var fire: PontiffStatusProjectile = (load(FIRE_SCENE) as PackedScene).instantiate() as PontiffStatusProjectile
	var ice: PontiffStatusProjectile = (load(ICE_SCENE) as PackedScene).instantiate() as PontiffStatusProjectile
	var mire: PontiffMireZone = (load(MIRE_SCENE) as PackedScene).instantiate() as PontiffMireZone
	_expect(fire != null and fire.impact_damage == 8 and fire.burn_tick_damage == 5, "fireball uses 8 direct plus five-HP burn")
	_expect(ice != null and ice.impact_damage == 7 and is_equal_approx(ice.status_duration, 3.0), "ice lance uses seven damage and three-second freeze")
	_expect(mire != null and is_equal_approx(mire.duration, 4.5), "mire lasts 4.5 seconds")
	if fire != null: fire.free()
	if ice != null: ice.free()
	if mire != null: mire.free()


func _test_boss_contract(player: Player) -> void:
	var boss_scene: PackedScene = load(BOSS_SCENE) as PackedScene
	_expect(boss_scene != null, "formal Edran scene loads")
	if boss_scene == null:
		return
	var boss: ThirteenthPontiffEdran = boss_scene.instantiate() as ThirteenthPontiffEdran
	root.add_child(boss)
	await process_frame
	boss.set_physics_process(false)
	boss.activate(player)
	_expect(boss.fireball_scene != null and boss.ice_lance_scene != null, "formal Boss owns both projectiles")
	_expect(boss.mire_telegraph_scene != null and boss.mire_zone_scene != null, "formal Boss owns mire telegraph and zone")
	_expect(is_equal_approx(boss.config.summon_cooldown_min, 6.2), "Phase 1 summon minimum is 6.2 seconds")
	_expect(is_equal_approx(boss.config.summon_cooldown_max, 7.4), "Phase 1 summon maximum is 7.4 seconds")
	_expect(is_equal_approx(boss.config.phase_02_summon_cooldown_min, 4.8), "Phase 2 summon minimum is 4.8 seconds")
	_expect(is_equal_approx(boss.config.phase_02_summon_cooldown_max, 6.0), "Phase 2 summon maximum is 6.0 seconds")
	_expect(boss.config.phase_1_summon_cap == 2 and boss.config.phase_02_summon_cap == 3, "summon caps are two and three")
	_expect(boss.config.phase_02_choir_husk_cap == 1, "Choir Husk cap remains one")
	_expect(is_equal_approx(boss.config.summon_interrupt_cooldown, 3.0), "interrupted ritual waits three seconds")
	for frames: SpriteFrames in [boss.sprite.sprite_frames, boss.phase_02_frames]:
		for animation: StringName in MAGIC_ANIMATIONS:
			_expect(frames != null and frames.has_animation(animation), "Boss frames include %s" % animation)
			if frames != null and frames.has_animation(animation):
				_expect(frames.get_frame_count(animation) >= 3, "%s has production key frames" % animation)
	boss.queue_free()
	await process_frame


func _test_summon_cadence_models() -> void:
	var config: ThirteenthPontiffEdranConfig = ThirteenthPontiffEdranConfig.new()
	for battle: int in range(20):
		seed(9000 + battle)
		for cast: int in range(8):
			var phase_1_interval: float = randf_range(config.summon_cooldown_min, config.summon_cooldown_max)
			var phase_2_interval: float = randf_range(config.phase_02_summon_cooldown_min, config.phase_02_summon_cooldown_max)
			_expect(phase_1_interval >= 6.2 and phase_1_interval <= 7.4, "battle %d Phase 1 cadence stays bounded" % battle)
			_expect(phase_2_interval >= 4.8 and phase_2_interval <= 6.0, "battle %d Phase 2 cadence stays bounded" % battle)


func _test_main_route_contract() -> void:
	var profile: ChapterStartProfile = load(
		"res://chapters/chapter_03_chapel_of_thirteen_echoes/resources/chapter/chapter_03_start_profile.tres"
	) as ChapterStartProfile
	var debug_spawns: Array[StringName] = [
		&"CH3_BOSS_MAGIC_TEST", &"CH3_BOSS_FIRE_TEST", &"CH3_BOSS_ICE_TEST",
		&"CH3_BOSS_MIRE_TEST", &"CH3_BOSS_SUMMON_MAGIC_COMBO", &"CH3_BOSS",
	]
	for spawn_id: StringName in debug_spawns:
		_expect(profile != null and spawn_id in profile.available_spawn_ids, "Main exposes %s" % spawn_id)
	var room_text: String = FileAccess.get_file_as_string(
		"res://chapters/chapter_03_chapel_of_thirteen_echoes/scenes/rooms/ch3_boss_sanctum_room.tscn"
	)
	_expect("thirteenth_pontiff_edran.tscn" in room_text, "Main Boss sanctum references the formal Edran scene")


func _expect(condition: bool, message: String) -> void:
	_assertions += 1
	if not condition:
		_failures.append(message)


func _finish() -> void:
	if _failures.is_empty():
		print("EDRAN_ELEMENTAL_MAGIC | PASS assertions=%d burn_hits=30 freeze_hits=30 mire_casts=30 cadence_battles=20" % _assertions)
		quit(0)
		return
	for failure: String in _failures:
		push_error(failure)
	print("EDRAN_ELEMENTAL_MAGIC | FAIL count=%d assertions=%d" % [_failures.size(), _assertions])
	quit(1)
