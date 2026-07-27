extends SceneTree

const LEVEL_PATH: String = "res://chapters/chapter_02_silent_court/scenes/level/silent_court.tscn"

var _failures: Array[String] = []
var _dialogue_count: int = 0
var _title_count: int = 0
var _phase_started_count: int = 0
var _phase_completed_count: int = 0


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	Engine.time_scale = 20.0
	var packed: PackedScene = load(LEVEL_PATH) as PackedScene
	var level: Node = packed.instantiate() if packed != null else null
	if level == null:
		_fail("Silent Court could not instantiate")
		_finish()
		return
	root.add_child(level)
	current_scene = level
	for _frame: int in range(5):
		await process_frame
	var boss: HollowDuchess = level.get_node("GameplayWorld/BossArea/HollowDuchess") as HollowDuchess
	var player: Player = level.get_node("GameplayWorld/PlayerAnchorOrRuntimeActors/ChapterRuntime/Player") as Player
	var presentation: DuchessEncounterPresentation = level.get_node(
		"GameplayWorld/BossArea/DuchessEncounterPresentation"
	) as DuchessEncounterPresentation
	_expect(presentation.broken_waltz_player != null, "Saved presentation is missing BrokenWaltzPlayer")
	_expect(presentation.broken_waltz_player.stream is AudioStreamWAV, "Broken waltz must use the saved original WAV stream")
	var waltz_stream: AudioStreamWAV = presentation.broken_waltz_player.stream as AudioStreamWAV
	_expect(waltz_stream.loop_mode == AudioStreamWAV.LOOP_FORWARD, "Broken waltz must loop through Phase 1")
	presentation.dialogue_requested.connect(func(_speaker: String, _text: String, _duration: float) -> void: _dialogue_count += 1)
	presentation.title_requested.connect(func(_title: String, _subtitle: String) -> void: _title_count += 1)
	for iteration: int in range(5):
		presentation.play_intro(iteration > 0)
		await _wait_animation(presentation.animation_player, 180)
	_expect(_dialogue_count == 5, "Only the first intro should emit the five dialogue lines")
	_expect(_title_count == 5, "Five intro plays should each show one title")
	_expect(is_equal_approx(boss.config.phase_transition_duration, 4.4), "Saved transition must be 4.4 seconds")
	_expect(boss.config.intro_full_duration >= 5.0 and boss.config.intro_full_duration <= 8.0, "Full intro duration outside 5–8 seconds")
	_expect(boss.config.intro_retry_duration >= 1.0 and boss.config.intro_retry_duration <= 1.5, "Retry intro duration outside 1–1.5 seconds")
	boss.config = boss.config.duplicate(true) as HollowDuchessConfig
	boss.config.intro_retry_duration = 0.03
	boss.config.phase_transition_duration = 0.16
	boss.config.phase_2_sprite_reveal_time = 0.08
	boss.phase_transition_started.connect(func() -> void: _phase_started_count += 1)
	boss.phase_transition_completed.connect(func() -> void: _phase_completed_count += 1)
	player.hurtbox.set_invulnerable(true)
	for iteration: int in range(10):
		presentation.reset_presentation()
		boss.reset_boss()
		boss.activate(player, true)
		await _wait_boss_state(boss, &"Idle", 120)
		boss.debug_set_health(121)
		await _wait_phase(boss, 2, 180)
		_expect(boss.health_component.current_health == 121, "Transition %d restored HP" % iteration)
		_expect(boss.get_current_poise() == 80, "Transition %d did not set 80 Poise" % iteration)
		_expect(boss.animated_sprite.sprite_frames == boss.phase_2_sprite_frames, "Transition %d did not switch SpriteFrames" % iteration)
	_expect(_phase_started_count == 10, "Phase transition did not start exactly ten times")
	_expect(_phase_completed_count == 10, "Phase transition did not complete exactly ten times")
	var probe := HitboxComponent.new()
	probe.damage = 20
	_expect(boss.hurtbox.hit_policy.resolve_damage(probe) == 17, "Phase 2 0.85 damage multiplier failed")
	_expect(boss.get_attack_damage(&"rapier_thrust") == 13, "Phase 2 Rapier runtime damage mismatch")
	_expect(boss.get_attack_damage(&"fan_slash") == 16, "Phase 2 Fan runtime damage mismatch")
	_expect(boss.get_attack_damage(&"backstep_riposte") == 14, "Phase 2 Riposte runtime damage mismatch")
	_expect(boss.get_attack_damage(&"side_step_cut") == 14, "Phase 2 Side Cut runtime damage mismatch")
	_expect(boss.get_attack_damage(&"double_waltz_lunge", 1) == 10, "Phase 2 Double Lunge 1 damage mismatch")
	_expect(boss.get_attack_damage(&"double_waltz_lunge", 2) == 14, "Phase 2 Double Lunge 2 damage mismatch")
	_expect(boss.get_attack_damage(&"phantom_dancer_sweep") == 12, "Phase 2 Phantom damage mismatch")
	_expect(boss.get_attack_damage(&"final_waltz_crossing") == 10, "Phase 2 Final Waltz damage mismatch")
	probe.queue_free()
	Engine.time_scale = 1.0
	_finish()


func _wait_animation(player: AnimationPlayer, maximum_frames: int) -> void:
	for _frame: int in range(maximum_frames):
		await process_frame
		if not player.is_playing():
			return
	_fail("Presentation animation timed out")


func _wait_boss_state(boss: HollowDuchess, target: StringName, maximum_frames: int) -> void:
	for _frame: int in range(maximum_frames):
		await physics_frame
		if boss.get_state_name() == target:
			return
	_fail("Boss did not reach %s" % target)


func _wait_phase(boss: HollowDuchess, phase: int, maximum_frames: int) -> void:
	for _frame: int in range(maximum_frames):
		await physics_frame
		if boss.get_phase() == phase:
			return
	_fail("Boss did not reach Phase %d" % phase)


func _expect(condition: bool, message: String) -> void:
	if not condition:
		_fail(message)


func _fail(message: String) -> void:
	_failures.append(message)


func _finish() -> void:
	if _failures.is_empty():
		print("HOLLOW_DUCHESS_PRESENTATION_PHASE_TEST: PASS intro=5 transition=10 phase2=0.85/80")
		quit(0)
		return
	for failure: String in _failures:
		push_error("HOLLOW_DUCHESS_PRESENTATION_PHASE_TEST: %s" % failure)
	quit(1)
