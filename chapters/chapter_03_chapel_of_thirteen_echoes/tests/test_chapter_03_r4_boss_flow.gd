extends SceneTree

const ROOT_PATH: String = "res://chapters/chapter_03_chapel_of_thirteen_echoes"
const ROUTE_PATH: String = ROOT_PATH + "/scenes/level/chapter_03_route.tscn"
const PROFILE_PATH: String = ROOT_PATH + "/resources/chapter/chapter_03_start_profile.tres"

var _failures: Array[String] = []


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var session: ChapterSessionState = root.get_node_or_null("ChapterSession") as ChapterSessionState
	var profile: ChapterStartProfile = load(PROFILE_PATH) as ChapterStartProfile
	_expect(session != null, "ChapterSession autoload exists")
	_expect(profile != null, "Chapter III profile loads")
	if session == null or profile == null:
		_finish()
		return
	session.begin_debug_run()
	session.apply_start_profile(profile, &"CH3_BOSS_CHECKPOINT")
	var route: Chapter03Route = (load(ROUTE_PATH) as PackedScene).instantiate() as Chapter03Route
	root.add_child(route)
	await process_frame
	await physics_frame
	var controller: Chapter03RoomTransitionController = route.transition_controller
	var player: Player = controller.player
	_expect(controller.active_room_id == &"CH3_BOSS_CHECKPOINT", "R4 starts in saved checkpoint room")
	var checkpoint: Chapter03RoomCheckpoint = controller.active_room.get_node(
		"CheckpointArea"
	) as Chapter03RoomCheckpoint
	checkpoint._on_body_entered(player)
	await physics_frame
	_expect(checkpoint.is_activated, "Boss checkpoint activates once")
	_expect(
		session.has_story_flag(&"chapter_03_boss_checkpoint_activated"),
		"Boss checkpoint records its session flag"
	)
	_expect(
		controller.respawn_controller.spawn_point == controller.respawn_anchor,
		"persistent respawn authority owns the Boss checkpoint"
	)

	_expect(
		controller.request_room_change(&"CH3_BOSS_ANTE", &"EntryWest"),
		"checkpoint transitions to antechamber"
	)
	await create_timer(0.60).timeout
	_expect(controller.active_room_id == &"CH3_BOSS_ANTE", "antechamber loaded independently")
	var gate: Chapter03BossGate = controller.active_room.get_node("BossGate") as Chapter03BossGate
	gate.bell_step_duration = 0.02
	gate.door_open_duration = 0.10
	_expect(not gate.auto_trigger, "formal Boss gate is E-confirmed")
	gate._on_trigger_body_entered(player)
	await process_frame
	_expect(not gate.is_gate_open(), "proximity alone does not open Boss gate")
	_expect(gate.interaction_prompt.visible, "Boss gate shows explicit E prompt")
	gate.run_sequence_for_player(player)
	await _wait_for_room_ready(controller, &"CH3_BOSS", 12.0)
	_expect(controller.active_room_id == &"CH3_BOSS", "gate request swaps to independent Sanctum")
	_expect(route.get_node("RoomHost").get_child_count() == 1, "Boss swap retains one active room")
	var sanctum_room: Chapter03BossSanctumRoom = controller.active_room as Chapter03BossSanctumRoom
	var sanctum: Chapter03BossSanctum = sanctum_room.sanctum
	_expect(sanctum.is_intro_complete(), "Sanctum intro completes after room Fade")
	_expect(not sanctum.intro_camera.enabled, "intro camera returns authority to Player")
	_expect(not sanctum.boss_title.visible, "Boss title clears before input returns")
	_expect(player.get_input_profile() == Player.InputProfile.FULL, "Boss intro restores Player input")
	_expect(
		sanctum.get_node_or_null("BossIntegrationAnchor") is Marker2D,
		"typed Edran integration anchor remains available"
	)

	sanctum_room.reward_sequence.fragment_duration = 0.10
	sanctum_room.reward_sequence.seal_duration = 0.10
	sanctum_room.reward_sequence.forge_duration = 0.10
	sanctum_room.reward_sequence.hold_duration = 0.10
	sanctum_room.boss.defeated.emit()
	await sanctum.death_environment_finished
	while not sanctum_room.reward_sequence.is_complete():
		await process_frame
	await physics_frame
	_expect(sanctum.is_death_response_complete(), "Boss death environment hook is idempotent-ready")
	_expect(sanctum_room.reward_sequence.is_complete(), "Boss reward formation completes")
	_expect(sanctum_room.post_boss_exit.monitoring, "Boss death and reward formation enable post-Boss exit")
	(sanctum_room.post_boss_exit as Chapter03RoomExit)._on_body_entered(player)
	await _wait_for_room_ready(controller, &"CH3_POST_BOSS", 2.0)
	_expect(controller.active_room_id == &"CH3_POST_BOSS", "death exit reaches dedicated reliquary")
	var post_room: Chapter03PostBossRoom = controller.active_room as Chapter03PostBossRoom
	if post_room == null:
		_finish()
		return
	_expect(post_room.reliquary.visible, "post-Boss reliquary is revealed on entry")
	_expect(not post_room.underkeep_exit.monitoring, "descent stays closed before reward authority")
	_expect(post_room.reliquary.pickup.collect(), "formal WeaponPickup grants the Boss reward")
	await physics_frame
	var equipment: PlayerEquipmentManager = root.get_node_or_null("EquipmentManager") as PlayerEquipmentManager
	_expect(
		equipment != null and equipment.equipped_weapon_id == &"thirteenfold_absolution_blades",
		"Boss reward auto-equips through EquipmentManager"
	)
	_expect(post_room.underkeep_exit.monitoring, "reward completion enables underkeep exit")
	(post_room.underkeep_exit as Chapter03RoomExit)._on_body_entered(player)
	await _wait_for_room_ready(controller, &"CH3_UNDERKEEP_DESCENT", 2.0)
	_expect(
		controller.active_room_id == &"CH3_UNDERKEEP_DESCENT",
		"reward-gated exit reaches dedicated underkeep room"
	)
	var terminal: Chapter03UnderkeepDescent = controller.active_room.get_node(
		"UnderkeepDescent"
	) as Chapter03UnderkeepDescent
	_expect(
		ResourceLoader.exists(terminal.CHAPTER_FOUR_SCENE, "PackedScene"),
		"Chapter IV formal threshold exists"
	)
	session.begin_debug_run()
	route.queue_free()
	await process_frame
	_finish()


func _wait_for_room_ready(
	controller: Chapter03RoomTransitionController,
	room_id: StringName,
	timeout_seconds: float
) -> void:
	var deadline: int = Time.get_ticks_msec() + roundi(timeout_seconds * 1000.0)
	while Time.get_ticks_msec() < deadline:
		await process_frame
		if (
			controller.active_room_id == room_id
			and not controller._transitioning
			and not controller.fade_rect.visible
		):
			return


func _expect(condition: bool, message: String) -> void:
	if not condition:
		_failures.append(message)


func _finish() -> void:
	if _failures.is_empty():
		print(
			"CH3_R4_BOSS_FLOW PASS checkpoint=true e_gate=true room_swap=true "
			+ "intro=true reward_formation=true weapon_pickup=true underkeep_hook=true boss_entity=partial chapter4=partial"
		)
		quit(0)
		return
	for failure: String in _failures:
		push_error("CH3_R4_BOSS_FLOW FAIL: %s" % failure)
	print("CH3_R4_BOSS_FLOW FAIL count=%d" % _failures.size())
	quit(1)
