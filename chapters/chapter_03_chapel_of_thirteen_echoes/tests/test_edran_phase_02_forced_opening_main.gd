extends SceneTree

const BOOTSTRAP: String = "res://scenes/bootstrap/main_bootstrap.tscn"
const ROUTE_PATH: String = "res://chapters/chapter_03_chapel_of_thirteen_echoes/scenes/level/chapter_03_route.tscn"
const REQUIRED_FLOW: Array[StringName] = [
	&"PHASE_2_THRESHOLD_REACHED",
	&"PHASE_2_TRANSITION_BEGIN",
	&"PHASE_2_DIALOGUE_BEGIN",
	&"PHASE_2_DIALOGUE_END",
	&"GRAVITY_OPENING_REQUESTED",
	&"GRAVITY_STATE_ENTER",
	&"GRAVITY_CAST_ANIMATION_BEGIN",
	&"GRAVITY_FINAL_SEAL",
	&"GRAVITY_HP_RESOLVE",
	&"GRAVITY_RECOVERY_BEGIN",
	&"GRAVITY_COMPLETE",
	&"PHASE_2_NORMAL_AI_BEGIN",
]
const CASES: Array[Dictionary] = [
	{&"name": "above_threshold_60_to_50", &"before": 60, &"after": 50},
	{&"name": "below_threshold_40_to_floor", &"before": 40, &"after": 20},
	{&"name": "below_floor_15_unchanged", &"before": 15, &"after": 15},
]

var _failures: Array[String] = []
var _events: Array[StringName] = []
var _health_change_count: int = 0
var _active_room: Chapter03BossSanctumRoom
var _cast_animation_visible: bool = false
var _final_seal_visible: bool = false
var _gravity_vfx_visible: bool = false
var _dialogue_clear_for_cast: bool = false
var _player_control_restored_for_cast: bool = false


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	Engine.time_scale = 20.0
	var debug: DebugRunConfigState = root.get_node_or_null("DebugRunConfig") as DebugRunConfigState
	_expect(debug != null, "DebugRunConfig autoload is available")
	if debug == null:
		_finish()
		return
	var previous_route_id: int = 0
	for case_index: int in range(CASES.size()):
		var result: Dictionary = await _run_main_case(debug, CASES[case_index], previous_route_id)
		previous_route_id = int(result.get(&"route_id", 0))
	debug.reset_to_defaults()
	Engine.time_scale = 1.0
	var music_manager: MusicManagerService = root.get_node_or_null("MusicManager") as MusicManagerService
	if music_manager != null:
		music_manager.stop_music()
	if current_scene != null:
		current_scene.free()
		current_scene = null
	for _frame: int in range(12):
		await process_frame
	_finish()


func _run_main_case(
	debug: DebugRunConfigState, case_data: Dictionary, previous_route_id: int
) -> Dictionary:
	debug.debug_chapter_start_enabled = true
	debug.debug_start_chapter_id = ChapterRegistry.CHAPTER_03_CHAPEL_OF_THIRTEEN_ECHOES
	debug.debug_start_spawn_id = &"CH3_BOSS"
	debug.debug_skip_chapter_intro = true
	debug.debug_reset_chapter_state_on_run = true
	_expect(change_scene_to_file(BOOTSTRAP) == OK, "%s starts MainBootstrap" % case_data[&"name"])
	var route: Chapter03Route = await _wait_for_fresh_route(previous_route_id, 900)
	_expect(route != null, "%s reaches formal Chapter III route" % case_data[&"name"])
	if route == null:
		return {&"route_id": 0}
	var room: Chapter03BossSanctumRoom = await _wait_for_boss_room(route, 900)
	_expect(room != null, "%s reaches formal saved Boss room" % case_data[&"name"])
	if room == null:
		return {&"route_id": route.get_instance_id()}
	_active_room = room
	var boss: ThirteenthPontiffEdran = room.boss
	var player: Player = route.transition_controller.player
	await _wait_for_boss_activation(boss, 900)
	_expect(boss.current_state != ThirteenthPontiffEdran.State.DORMANT, "%s activates Edran" % case_data[&"name"])
	player.hurtbox.set_invulnerable(true)
	player.health_component.set_current_health(int(case_data[&"before"]))
	_events.clear()
	_health_change_count = 0
	_cast_animation_visible = false
	_final_seal_visible = false
	_gravity_vfx_visible = false
	_dialogue_clear_for_cast = false
	_player_control_restored_for_cast = false
	boss.phase_02_flow_event.connect(_on_phase_02_flow_event)
	player.health_component.health_changed.connect(_on_player_health_changed)
	boss.health_component.set_current_health(boss.config.phase_transition_health)
	for _frame: int in range(1800):
		await process_frame
		if room.find_child("PontiffGravityJudgment", true, false) != null:
			_gravity_vfx_visible = true
		if boss.is_phase_02_normal_ai_enabled():
			break
	var expected_after: int = int(case_data[&"after"])
	_expect(boss.is_phase_02_opening_gravity_completed(), "%s completes mandatory gravity" % case_data[&"name"])
	_expect(boss.is_phase_02_normal_ai_enabled(), "%s gates normal AI until gravity recovery" % case_data[&"name"])
	_expect(player.health_component.current_health == expected_after, "%s resolves %d -> %d (actual %d)" % [case_data[&"name"], case_data[&"before"], expected_after, player.health_component.current_health])
	_expect(_health_change_count == (0 if int(case_data[&"before"]) == expected_after else 1), "%s performs exactly one required HealthComponent mutation" % case_data[&"name"])
	_expect(_has_ordered_flow(REQUIRED_FLOW), "%s emits the complete ordered runtime flow" % case_data[&"name"])
	_expect(_cast_animation_visible, "%s visibly enters the formal cast animation" % case_data[&"name"])
	_expect(_final_seal_visible, "%s visibly reaches Final Seal" % case_data[&"name"])
	_expect(_gravity_vfx_visible, "%s creates the formal gravity VFX" % case_data[&"name"])
	_expect(_dialogue_clear_for_cast, "%s starts casting only after dialogue/title UI clears" % case_data[&"name"])
	_expect(_player_control_restored_for_cast, "%s restores Player control during the avoidable cast presentation" % case_data[&"name"])
	_expect(boss._gravity_cooldown > 19.0, "%s starts the 21-second cooldown only after the forced cast" % case_data[&"name"])
	print("EDRAN_FORCED_OPENING_CASE | name=%s hp_before=%d hp_after=%d flow=%s mutations=%d animation=%s final_seal=%s vfx=%s" % [case_data[&"name"], case_data[&"before"], player.health_component.current_health, _events, _health_change_count, _cast_animation_visible, _final_seal_visible, _gravity_vfx_visible])
	if boss.phase_02_flow_event.is_connected(_on_phase_02_flow_event):
		boss.phase_02_flow_event.disconnect(_on_phase_02_flow_event)
	if player.health_component.health_changed.is_connected(_on_player_health_changed):
		player.health_component.health_changed.disconnect(_on_player_health_changed)
	_active_room = null
	return {&"route_id": route.get_instance_id()}


func _wait_for_fresh_route(previous_route_id: int, maximum_frames: int) -> Chapter03Route:
	for _frame: int in range(maximum_frames):
		await process_frame
		if current_scene != null and current_scene.scene_file_path == ROUTE_PATH:
			var route: Chapter03Route = current_scene as Chapter03Route
			if route != null and route.get_instance_id() != previous_route_id:
				return route
	return null


func _wait_for_boss_room(
	route: Chapter03Route, maximum_frames: int
) -> Chapter03BossSanctumRoom:
	for _frame: int in range(maximum_frames):
		await process_frame
		var room: Chapter03BossSanctumRoom = (
			route.transition_controller.active_room as Chapter03BossSanctumRoom
		)
		if room != null:
			return room
	return null


func _wait_for_boss_activation(boss: ThirteenthPontiffEdran, maximum_frames: int) -> void:
	for _frame: int in range(maximum_frames):
		await process_frame
		if boss.current_state != ThirteenthPontiffEdran.State.DORMANT:
			return


func _on_phase_02_flow_event(event_name: StringName) -> void:
	_events.append(event_name)
	if _active_room == null:
		return
	var boss: ThirteenthPontiffEdran = _active_room.boss
	if event_name == &"GRAVITY_CAST_ANIMATION_BEGIN":
		_cast_animation_visible = boss.sprite.animation == &"weight_of_absolution_windup"
		_dialogue_clear_for_cast = (
			not _active_room.sanctum.dialogue_panel.visible
			and not _active_room.sanctum.phase_title.visible
		)
		_player_control_restored_for_cast = (
			_active_room.get_tree().get_first_node_in_group("player") as Player
		).get_input_profile() == Player.InputProfile.FULL
	elif event_name == &"GRAVITY_FINAL_SEAL":
		_final_seal_visible = (
			boss.current_state == ThirteenthPontiffEdran.State.GRAVITY_FINAL_SEAL
			and boss.sprite.animation == &"weight_of_absolution_final_seal"
		)


func _on_player_health_changed(_current: int, _maximum: int) -> void:
	_health_change_count += 1


func _has_ordered_flow(required: Array[StringName]) -> bool:
	var cursor: int = 0
	for event_name: StringName in _events:
		if cursor < required.size() and event_name == required[cursor]:
			cursor += 1
	return cursor == required.size()


func _expect(condition: bool, message: String) -> void:
	if not condition:
		_failures.append(message)


func _finish() -> void:
	if _failures.is_empty():
		print("EDRAN_PHASE2_FORCED_OPENING_MAIN | PASS main_runs=3 branches=60to50,40to20,15to15 flow=complete")
		quit(0)
		return
	for failure: String in _failures:
		push_error(failure)
	print("EDRAN_PHASE2_FORCED_OPENING_MAIN | FAIL count=%d" % _failures.size())
	quit(1)
