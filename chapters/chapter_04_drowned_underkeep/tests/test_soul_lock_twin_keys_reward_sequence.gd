extends SceneTree

const ROOM_PATH: String = (
	"res://chapters/chapter_04_drowned_underkeep/scenes/rooms/"
	+ "ch4_15_broken_soul_reservoir.tscn"
)
const PLAYER_SCENE: PackedScene = preload("res://scenes/player/player.tscn")
const GUARD_SCENE: PackedScene = preload(
	"res://chapters/chapter_01_ravenmourn_outskirts/scenes/enemies/castle_guard.tscn"
)

var _failures: Array[String] = []
var _stages: Array[StringName] = []


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var interact_is_e: bool = false
	for event: InputEvent in InputMap.action_get_events(&"interact"):
		var key_event: InputEventKey = event as InputEventKey
		if key_event != null and key_event.physical_keycode == KEY_E:
			interact_is_e = true
	_expect(interact_is_e, "InputMap interact is not bound to physical E")
	var session: ChapterSessionState = root.get_node("ChapterSession") as ChapterSessionState
	var inventory: PlayerWeaponInventory = root.get_node("WeaponInventory") as PlayerWeaponInventory
	var equipment: PlayerEquipmentManager = root.get_node("EquipmentManager") as PlayerEquipmentManager
	session.begin_debug_run()
	session.set_story_flag(&"ch4_boss_defeated", true)
	session.set_story_flag(&"ch4_reward_unlocked", true)
	var packed: PackedScene = load(ROOM_PATH) as PackedScene
	var room: Chapter04Room = packed.instantiate() as Chapter04Room if packed != null else null
	_expect(room != null, "Area 15 formal room could not instantiate")
	if room == null:
		_finish()
		return
	var interaction_player: Player = PLAYER_SCENE.instantiate() as Player
	root.add_child(interaction_player)
	await process_frame
	interaction_player.set_physics_process(false)
	var reward: Chapter04RewardController = room.get_node("RewardController") as Chapter04RewardController
	reward.water_settle_duration = 0.04
	reward.soul_release_duration = 0.04
	reward.chain_pull_duration = 0.04
	reward.reliquary_rise_duration = 0.04
	reward.key_formation_duration = 0.04
	reward.inspection_hold_duration = 0.04
	reward.reward_stage_changed.connect(_on_stage_changed)
	root.add_child(room)
	_expect(await _wait_for_claimable(reward, 2.0), "reward sequence did not become claimable")
	for required: StringName in [
		&"water_settle", &"soul_release", &"chain_pull", &"reliquary_rise",
		&"lockbreaker_forms", &"soulseal_forms", &"claimable",
	]:
		_expect(required in _stages, "missing sequence stage %s" % required)
	_expect(reward.pickup.visible, "formed weapon is not visible")
	_expect(
		reward.pickup.player_interaction_enabled and not reward.pickup.is_collected(),
		"formed weapon is not interactable"
	)
	_expect(
		interaction_player.get_input_profile() == Player.InputProfile.FULL,
		"reward presentation did not restore Player interaction input"
	)
	reward.pickup._on_body_entered(interaction_player)
	_expect(reward.pickup.prompt.visible, "real pickup range did not show the E prompt")
	await _press_interact_once()
	await process_frame
	_expect(reward.is_collected(), "real E input did not collect the reward")
	_expect(inventory.owns_weapon(&"soul_lock_twin_keys"), "reward did not enter inventory")
	_expect(equipment.equipped_weapon_id == &"soul_lock_twin_keys", "reward did not auto-equip")
	_expect(equipment.get_normal_attack_damage() == 16, "reward normal damage mismatch")
	_expect(equipment.get_dash_attack_damage() == 32, "reward Dash damage mismatch")
	for _repeat_press: int in range(10):
		await _press_interact_once()
	_expect(
		inventory.get_owned_weapon_ids().count(&"soul_lock_twin_keys") == 1,
		"repeated E input duplicated the unique reward"
	)
	await _assert_real_hit_damage(room)
	room.queue_free()
	interaction_player.queue_free()
	for _frame: int in 6:
		await process_frame
	session.begin_debug_run()
	_finish()


func _on_stage_changed(stage: StringName) -> void:
	_stages.append(stage)


func _assert_real_hit_damage(parent: Node) -> void:
	var player: Player = PLAYER_SCENE.instantiate() as Player
	var guard: CastleGuard = GUARD_SCENE.instantiate() as CastleGuard
	parent.add_child(player)
	parent.add_child(guard)
	await process_frame
	player.set_physics_process(false)
	guard.set_physics_process(false)
	guard.health_component.max_health = 100
	guard.health_component.reset_to_full()
	var actions: PlayerActionController = player.action_controller
	var sprite: AnimatedSprite2D = player.animation_controller.animated_sprite
	_expect(actions.try_start_actions(true, false, true, 1.0, false), "real normal Attack rejected")
	sprite.frame = 1
	sprite.frame_changed.emit()
	_expect(actions.attack_hitbox.damage == 16, "normal Hitbox damage is not 16")
	_expect(actions.attack_hitbox.try_hit(guard.hurtbox), "normal Hitbox did not resolve")
	_expect(guard.health_component.current_health == 84, "normal Attack did not remove 16 HP")
	actions.cancel_all_actions()
	player.animation_controller.reset_to_idle()
	guard.health_component.reset_to_full()
	_expect(actions.try_start_actions(true, true, true, 1.0, false), "real Dash Attack rejected")
	sprite.frame = 2
	sprite.frame_changed.emit()
	_expect(actions.dash_attack_hitbox.damage == 32, "Dash Hitbox damage is not 32")
	_expect(actions.dash_attack_hitbox.try_hit(guard.hurtbox), "Dash Hitbox did not resolve")
	_expect(guard.health_component.current_health == 68, "Dash Attack did not remove 32 HP")
	actions.cancel_all_actions()
	player.queue_free()
	guard.queue_free()
	await process_frame


func _wait_for_claimable(reward: Chapter04RewardController, timeout_seconds: float) -> bool:
	var deadline: int = Time.get_ticks_msec() + roundi(timeout_seconds * 1000.0)
	while Time.get_ticks_msec() < deadline:
		await process_frame
		if reward.get_current_stage() == &"claimable":
			return true
	return false


func _press_interact_once() -> void:
	var press: InputEventAction = InputEventAction.new()
	press.action = &"interact"
	press.pressed = true
	press.strength = 1.0
	Input.parse_input_event(press)
	await process_frame
	var release: InputEventAction = InputEventAction.new()
	release.action = &"interact"
	release.pressed = false
	Input.parse_input_event(release)
	await process_frame


func _expect(condition: bool, message: String) -> void:
	if not condition:
		_failures.append(message)


func _finish() -> void:
	if _failures.is_empty():
		print("SOUL LOCK REWARD SEQUENCE | PASS stages=7 input=E unique=1 damage=16/32")
		quit(0)
		return
	for failure: String in _failures:
		push_error("SOUL LOCK REWARD SEQUENCE: %s" % failure)
	quit(1)
