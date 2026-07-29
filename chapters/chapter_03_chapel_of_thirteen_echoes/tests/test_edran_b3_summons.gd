extends SceneTree

const BOSS_SCENE: String = "res://chapters/chapter_03_chapel_of_thirteen_echoes/scenes/bosses/thirteenth_pontiff_edran.tscn"
const PENITENT_SCENE: String = "res://chapters/chapter_03_chapel_of_thirteen_echoes/scenes/bosses/ossuary_penitent.tscn"
const HUSK_SCENE: String = "res://chapters/chapter_03_chapel_of_thirteen_echoes/scenes/bosses/choir_husk.tscn"
const PENITENT_FRAMES: String = "res://chapters/chapter_03_chapel_of_thirteen_echoes/assets/boss_summons/ossuary_penitent/animations/ossuary_penitent_sprite_frames.tres"
const HUSK_FRAMES: String = "res://chapters/chapter_03_chapel_of_thirteen_echoes/assets/boss_summons/choir_husk/animations/choir_husk_sprite_frames.tres"

const PENITENT_ANIMATIONS: Dictionary[StringName, int] = {
	&"summon_telegraph": 4, &"rise": 6, &"idle": 4, &"walk": 6,
	&"claw_windup": 4, &"claw_active": 2, &"claw_recovery": 4,
	&"lunge_windup": 4, &"lunge_active": 2, &"lunge_recovery": 4,
	&"hurt": 3, &"stagger": 4, &"death": 6, &"forced_dissolve": 5,
}
const HUSK_ANIMATIONS: Dictionary[StringName, int] = {
	&"summon_telegraph": 4, &"rise": 6, &"idle": 4, &"drift": 6,
	&"aim": 5, &"shoot": 3, &"recovery": 4,
	&"hurt": 3, &"stagger": 4, &"death": 6, &"forced_dissolve": 5,
}

var _failures: Array[String] = []


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	_validate_sprite_frames(PENITENT_FRAMES, PENITENT_ANIMATIONS, "Penitent")
	_validate_sprite_frames(HUSK_FRAMES, HUSK_ANIMATIONS, "Choir Husk")
	_validate_actor_scene(PENITENT_SCENE, &"ossuary_penitent", 42, 20, 8)
	_validate_actor_scene(HUSK_SCENE, &"choir_husk", 34, 16, 7)

	var boss_scene: PackedScene = load(BOSS_SCENE) as PackedScene
	_check(boss_scene != null, "Edran B3 Boss scene loads")
	if boss_scene == null:
		_finish()
		return
	var boss: ThirteenthPontiffEdran = boss_scene.instantiate() as ThirteenthPontiffEdran
	root.add_child(boss)
	await process_frame
	boss.activate()
	await process_frame
	var director: ThirteenthPontiffSummonDirector = boss.summon_director
	_check(director != null, "formal Boss owns SummonDirector")
	_check(boss.config.phase_1_summon_cap == 2, "Phase 1 summon cap is two")
	_check(boss.config.phase_1_penitent_cap == 1, "Phase 1 Penitent cap is one")
	_check(boss.config.phase_1_choir_husk_cap == 1, "Phase 1 Choir Husk cap is one")
	_check(is_equal_approx(boss.config.summon_windup, 1.15), "summon telegraph lasts 1.15 seconds")
	_check(boss.config.summon_interrupt_poise == 36, "summon interrupt threshold is 36 Poise")
	if director != null:
		_check(director.summon_phase_1(null), "first ritual raises a summon")
		_check(director.summon_phase_1(null), "second ritual raises a summon")
		_check(not director.summon_phase_1(null), "third summon is rejected at Phase 1 cap")
		_check(director.get_active_count() == 2, "active summon count remains two")
		var penitent_count: int = 0
		var husk_count: int = 0
		for summon: EdranBossSummon in director.get_active_summons():
			if summon.config.actor_kind == &"ossuary_penitent":
				penitent_count += 1
			elif summon.config.actor_kind == &"choir_husk":
				husk_count += 1
			_check(summon.is_in_group("chapter_03_boss_summon"), "summon joins dedicated cleanup group")
			_check(not _has_named_descendant(summon, "Loot"), "summons have no loot controller")
		_check(penitent_count == 1, "Phase 1 never owns more than one Penitent")
		_check(husk_count == 1, "Phase 1 never owns more than one Choir Husk")
		director.force_dissolve_all()
		await create_timer(0.52).timeout
		_check(director.get_active_count() == 0, "forced cleanup retires every summon")

	_check(boss.debug_force_attack(&"raise_the_absolved"), "Raise the Absolved can be forced in B3")
	await process_frame
	_check(boss.current_state == ThirteenthPontiffEdran.State.SUMMON, "Boss enters independent summon state")
	var player_hitbox: HitboxComponent = HitboxComponent.new()
	player_hitbox.faction = &"player"
	player_hitbox.attack_kind = &"dash_attack"
	root.add_child(player_hitbox)
	await process_frame
	player_hitbox.begin_attack(31001, 1, 1.0, player_hitbox)
	_check(boss.hurtbox.receive_hit(player_hitbox), "first Dash Attack reaches ritual caster")
	player_hitbox.end_attack()
	_check(boss.get_summon_interrupt_progress() == 28, "first Dash Attack contributes 28 ritual Poise")
	player_hitbox.begin_attack(31002, 1, 1.0, player_hitbox)
	_check(boss.hurtbox.receive_hit(player_hitbox), "second unique Dash Attack reaches ritual caster")
	player_hitbox.end_attack()
	await create_timer(boss.config.summon_interrupt_recovery + 0.08).timeout
	_check(boss.current_state == ThirteenthPontiffEdran.State.IDLE, "36+ Poise interrupt returns Boss to Phase 1 idle")
	_check(boss.get_active_summon_count() == 0, "interrupted ritual creates no summon")

	var profile: ChapterStartProfile = load("res://chapters/chapter_03_chapel_of_thirteen_echoes/resources/chapter/chapter_03_start_profile.tres") as ChapterStartProfile
	_check(profile != null and &"CH3_BOSS_SUMMON_TEST" in profile.available_spawn_ids, "B3 debug spawn is registered")
	var route_text: String = FileAccess.get_file_as_string("res://chapters/chapter_03_chapel_of_thirteen_echoes/scripts/level/chapter_03_route.gd")
	_check("CH3_BOSS_SUMMON_TEST" in route_text, "B3 debug spawn resolves to the formal Boss room")

	player_hitbox.queue_free()
	boss.queue_free()
	await process_frame
	_finish()


func _validate_sprite_frames(path: String, expected: Dictionary[StringName, int], label: String) -> void:
	var frames: SpriteFrames = load(path) as SpriteFrames
	_check(frames != null, "%s SpriteFrames load" % label)
	if frames == null:
		return
	for animation_name: StringName in expected:
		_check(frames.has_animation(animation_name), "%s has %s" % [label, animation_name])
		if frames.has_animation(animation_name):
			_check(frames.get_frame_count(animation_name) == expected[animation_name], "%s %s has expected frame count" % [label, animation_name])
			for frame_index: int in range(frames.get_frame_count(animation_name)):
				var texture: Texture2D = frames.get_frame_texture(animation_name, frame_index)
				_check(texture != null and texture.get_size() == Vector2(64.0, 64.0), "%s %s frame %d is 64x64" % [label, animation_name, frame_index])


func _validate_actor_scene(path: String, kind: StringName, health: int, poise: int, damage: int) -> void:
	var packed: PackedScene = load(path) as PackedScene
	_check(packed != null, "%s scene loads" % kind)
	if packed == null:
		return
	var actor: EdranBossSummon = packed.instantiate() as EdranBossSummon
	root.add_child(actor)
	_check(actor.config.actor_kind == kind, "%s identity is typed" % kind)
	_check(actor.config.max_health == health, "%s health matches B0" % kind)
	_check(actor.config.max_poise == poise, "%s Poise matches B0" % kind)
	_check(actor.config.primary_damage == damage, "%s primary damage matches B0" % kind)
	_check(actor.is_in_group("chapter_03_boss_summon"), "%s enters summon group" % kind)
	actor.queue_free()


func _has_named_descendant(root_node: Node, fragment: String) -> bool:
	for child: Node in root_node.get_children():
		if fragment.to_lower() in child.name.to_lower() or _has_named_descendant(child, fragment):
			return true
	return false


func _check(condition: bool, message: String) -> void:
	if not condition:
		_failures.append(message)


func _finish() -> void:
	if _failures.is_empty():
		print("EDRAN_B3_SUMMONS | PASS actors=2 animations=25 cap=2 penitent_cap=1 interrupt=36 cleanup=true main_spawn=true")
		quit(0)
		return
	for failure: String in _failures:
		push_error(failure)
	print("EDRAN_B3_SUMMONS | FAIL count=%d" % _failures.size())
	quit(1)
