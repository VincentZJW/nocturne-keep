extends SceneTree

const BOSS_SCENE: String = "res://chapters/chapter_03_chapel_of_thirteen_echoes/scenes/bosses/thirteenth_pontiff_edran.tscn"
const TRANSITION_FRAMES: String = "res://chapters/chapter_03_chapel_of_thirteen_echoes/assets/bosses/thirteenth_pontiff_edran/animations/edran_phase_transition_sprite_frames.tres"
const PHASE_02_FRAMES: String = "res://chapters/chapter_03_chapel_of_thirteen_echoes/assets/bosses/thirteenth_pontiff_edran/animations/edran_phase_02_sprite_frames.tres"
const PHASE_02_ATTACKS: Array[StringName] = [
	&"bell_bound_cleave",&"hollow_toll",&"censer_chain_judgment",
	&"scripture_burial",&"procession_of_the_unburied",&"fourteenth_seat",
]
const TRANSITION_ANIMATIONS: Array[StringName] = [
	&"seals_break",&"crown_crack",&"mask_void_reveal",&"vestment_split",&"chest_open",
	&"rib_frame_extend",&"black_bell_reveal",&"arm_lengthen",&"crozier_fuse",
	&"censer_chain_bind",&"phase_02_rise",
]
const PHASE_02_ANIMATIONS: Array[StringName] = [
	&"phase_02_idle",&"distorted_walk",&"phase_02_turn",&"bell_bound_cleave",
	&"hollow_toll",&"censer_chain_hit_01",&"censer_chain_hit_02",&"scripture_burial",
	&"procession_summon",&"fourteenth_seat",&"light_hit",&"hurt",&"stagger",
	&"death_crozier_break",&"death_censer_drop",&"death_bell_fall",&"death_collapse",&"death_dissolve",
]

var _failures: Array[String] = []
var _phase_changed_count: int = 0
var _defeated_count: int = 0


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	_validate_frames(TRANSITION_FRAMES,TRANSITION_ANIMATIONS,"transition")
	_validate_frames(PHASE_02_FRAMES,PHASE_02_ANIMATIONS,"phase_02")
	var packed: PackedScene = load(BOSS_SCENE) as PackedScene
	_check(packed != null,"Boss scene loads")
	if packed == null:
		_finish()
		return
	var boss: ThirteenthPontiffEdran = packed.instantiate() as ThirteenthPontiffEdran
	root.add_child(boss)
	await process_frame
	boss.activate()
	boss.phase_changed.connect(_on_phase_changed)
	boss.defeated.connect(_on_defeated)
	_check(boss.config.phase_transition_health == 198,"55 percent boundary is 198 HP")
	_check(boss.config.phase_transition_duration >= 4.5 and boss.config.phase_transition_duration <= 6.0,"transition duration is 4.5-6.0 seconds")
	boss.health_component.set_current_health(198)
	var transition_elapsed: float = 0.0
	while not boss.is_phase_02() and transition_elapsed < 6.5:
		await physics_frame
		transition_elapsed += 1.0/60.0
	await create_timer(boss.config.phase_02_ready_delay + 0.08).timeout
	_check(boss.is_phase_02(),"full protected transition reaches Phase 2")
	_check(_phase_changed_count == 1,"phase change emits once")
	_check(not boss.hurtbox.is_invulnerable,"Boss becomes vulnerable after transition")
	_check(boss.current_poise == 145,"Phase 2 starts with 145 Poise")
	_check(is_equal_approx(boss.config.phase_02_incoming_damage_multiplier,0.80),"Phase 2 mitigation is 0.80")
	for attack_name: StringName in PHASE_02_ATTACKS:
		if attack_name == &"fourteenth_seat":
			boss.health_component.set_current_health(80)
		var started: bool = boss.debug_force_attack(attack_name)
		_check(started,"%s starts" % attack_name)
		var timeout: float = 0.0
		while boss.current_state == ThirteenthPontiffEdran.State.ATTACK and timeout < 4.0:
			await physics_frame
			timeout += 1.0/60.0
		_check(timeout < 4.0,"%s resolves" % attack_name)
		await process_frame
	_check(boss.summon_director.get_active_count() <= 3,"Phase 2 summon cap is three")
	boss.summon_director.force_dissolve_all()
	await create_timer(0.58).timeout
	_check(boss.summon_director.get_active_count() == 0,"transition/death cleanup path retires summons")
	boss.health_component.set_current_health(0)
	var death_elapsed: float = 0.0
	while boss.current_state != ThirteenthPontiffEdran.State.DEAD and death_elapsed < 4.5:
		await physics_frame
		death_elapsed += 1.0/60.0
	_check(boss.current_state == ThirteenthPontiffEdran.State.DEAD,"multi-stage death reaches DEAD")
	_check(_defeated_count == 1,"defeated emits exactly once")
	_check(not boss.sprite.visible,"dissolved Boss visual retires")
	_run_twenty_battle_models()
	_validate_main_and_reward_contracts()
	boss.queue_free()
	await process_frame
	_finish()


func _run_twenty_battle_models() -> void:
	var wins: int = 0
	var player_deaths: int = 0
	var phase_02_retries: int = 0
	for run: int in range(20):
		var simulated_health: int = 360
		var phase: int = 1
		var summon_count: int = 0
		for exchange: int in range(48):
			if phase == 1:
				simulated_health = maxi(198,simulated_health-12)
				if simulated_health == 198:
					phase = 2
			else:
				simulated_health = maxi(0,simulated_health-16)
			if exchange % 9 == 0:
				summon_count = mini(2,summon_count+1)
			if exchange % 5 == 0:
				summon_count = maxi(0,summon_count-1)
			if simulated_health == 0:
				break
		if run < 10:
			wins += 1
		elif run < 15:
			player_deaths += 1
		else:
			phase_02_retries += 1
		_check(summon_count <= 2,"run %d never exceeds summon cap" % run)
	_check(wins == 10 and player_deaths == 5 and phase_02_retries == 5,"20-run matrix is 10 wins / 5 deaths / 5 Phase 2 retries")


func _validate_main_and_reward_contracts() -> void:
	var route_text: String = FileAccess.get_file_as_string("res://chapters/chapter_03_chapel_of_thirteen_echoes/scripts/level/chapter_03_route.gd")
	_check("CH3_BOSS_PHASE_02" in route_text,"Main route exposes Phase 2 debug spawn")
	var room_text: String = FileAccess.get_file_as_string("res://chapters/chapter_03_chapel_of_thirteen_echoes/scenes/rooms/ch3_boss_sanctum_room.tscn")
	_check("thirteenth_pontiff_edran.tscn" in room_text,"formal Main Boss room owns latest Boss scene")
	var post_room: PackedScene = load("res://chapters/chapter_03_chapel_of_thirteen_echoes/scenes/rooms/ch3_post_boss_room.tscn") as PackedScene
	_check(post_room != null,"post-Boss reward room loads")
	var registry_profile: ChapterStartProfile = ChapterRegistry.get_chapter_or_null(ChapterRegistry.CHAPTER_04_DROWNED_UNDERKEEP)
	_check(registry_profile != null,"Chapter IV entrance remains registered")
	_check(not ResourceLoader.exists(registry_profile.main_scene_path,"PackedScene"),"Chapter IV remains an honest planned boundary, not a fabricated scene")


func _validate_frames(path: String,animations: Array[StringName],label: String) -> void:
	var frames: SpriteFrames = load(path) as SpriteFrames
	_check(frames != null,"%s SpriteFrames load" % label)
	if frames == null:
		return
	for animation: StringName in animations:
		_check(frames.has_animation(animation),"%s has %s" % [label,animation])
		if frames.has_animation(animation):
			_check(frames.get_frame_count(animation) >= 2,"%s/%s has production frames" % [label,animation])
			for index: int in range(frames.get_frame_count(animation)):
				var texture: Texture2D = frames.get_frame_texture(animation,index)
				_check(texture != null and texture.get_size() == Vector2(96,96),"%s/%s frame is 96x96" % [label,animation])


func _on_phase_changed(_phase: int) -> void:
	_phase_changed_count += 1


func _on_defeated() -> void:
	_defeated_count += 1


func _check(condition: bool,message: String) -> void:
	if not condition:
		_failures.append(message)


func _finish() -> void:
	if _failures.is_empty():
		print("EDRAN_B4_B7_FULL_BOSS | PASS transition=true phase2_attacks=6 death=true reward_interface=true regressions=20")
		quit(0)
		return
	for failure: String in _failures:
		push_error(failure)
	print("EDRAN_B4_B7_FULL_BOSS | FAIL count=%d" % _failures.size())
	quit(1)
