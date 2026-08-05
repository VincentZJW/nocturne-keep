extends SceneTree

const PLAYER_SCENE: PackedScene = preload("res://scenes/player/player.tscn")
const SEQUENCE_SCENE: PackedScene = preload(
	"res://chapters/chapter_03_chapel_of_thirteen_echoes/scenes/transitions/"
	+ "chapter_03_reward_sequence_controller.tscn"
)
const POST_BOSS_ROOM: PackedScene = preload(
	"res://chapters/chapter_03_chapel_of_thirteen_echoes/scenes/rooms/"
	+ "ch3_post_boss_room.tscn"
)
const WEAPON_ID: StringName = &"thirteenfold_absolution_blades"
const RELIQUARY_EMPTY: String = (
	"res://chapters/chapter_03_chapel_of_thirteen_echoes/assets/weapons/"
	+ "thirteenfold_absolution/sprites/reliquary_empty.png"
)
const REFORGING_FRAGMENT: String = (
	"res://chapters/chapter_03_chapel_of_thirteen_echoes/assets/weapons/"
	+ "thirteenfold_absolution/effects/reforging_fragment.png"
)
const EXTINGUISHED_SEAL: String = (
	"res://chapters/chapter_03_chapel_of_thirteen_echoes/assets/weapons/"
	+ "thirteenfold_absolution/effects/extinguished_seal_node.png"
)

var _failures: Array[String] = []
var _formation_finish_count: int = 0
var _stages: Array[StringName] = []
var _full_flow_count: int = 0
var _uncollected_reload_count: int = 0
var _collected_reload_count: int = 0


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	_test_w4_assets()
	for flow_index: int in range(10):
		_reset_runtime()
		await _test_formation_sequence()
		if flow_index == 0:
			await _test_uncollected_reloads(5)
		await _test_pickup_and_gate_transaction(1)
		_full_flow_count += 1
	_reset_runtime()
	_finish()


func _test_w4_assets() -> void:
	_expect_image(RELIQUARY_EMPTY, Vector2i(96, 64))
	_expect_image(REFORGING_FRAGMENT, Vector2i(16, 16))
	_expect_image(EXTINGUISHED_SEAL, Vector2i(12, 12))


func _test_formation_sequence() -> void:
	_formation_finish_count = 0
	_stages.clear()
	var player: Player = PLAYER_SCENE.instantiate() as Player
	var sequence: Chapter03RewardSequenceController = (
		SEQUENCE_SCENE.instantiate() as Chapter03RewardSequenceController
	)
	root.add_child(player)
	root.add_child(sequence)
	await process_frame
	sequence.fragment_duration = 0.10
	sequence.seal_duration = 0.10
	sequence.forge_duration = 0.10
	sequence.hold_duration = 0.10
	sequence.formation_stage_changed.connect(_on_formation_stage_changed)
	sequence.formation_finished.connect(_on_formation_finished)
	var profile_before: Player.InputProfile = player.get_input_profile()
	_expect(sequence.play_sequence(player), "Formation did not start")
	_expect(not sequence.play_sequence(player), "Formation started a duplicate sequence")
	await process_frame
	_expect(not sequence.weapon.visible, "Boss-room sequence exposed a duplicate weapon visual")
	_expect(player.get_input_profile() == Player.InputProfile.LOCKED, "Formation did not lock Player input")
	_expect(player.hurtbox.is_invulnerable, "Formation did not protect Player")
	await sequence.formation_finished
	_expect(_formation_finish_count == 1, "Formation completion did not emit exactly once")
	_expect(_stages == [
		&"fragments_converge", &"thirteen_seals_extinguish", &"reliquary_unsealed", &"reliquary_ready",
	], "Formation stages are missing or out of order")
	_expect(sequence.is_complete() and not sequence.is_running(), "Formation terminal state is incorrect")
	_expect(not sequence.visible and not sequence.weapon.visible, "Boss-room duplicate visual survived formation")
	_expect(player.get_input_profile() == profile_before, "Formation did not restore Player input")
	_expect(not player.hurtbox.is_invulnerable, "Formation did not restore Player vulnerability")
	var session: ChapterSessionState = _session()
	_expect(session.boss_reward_spawned, "Formation did not set runtime spawned state")
	_expect(session.has_story_flag(Chapter03RewardSequenceController.FLAG_REWARD_SPAWNED), "Formation spawned flag missing")
	# The signal resumes this coroutine while the emitter is still locked. Wait until
	# the next idle/physics boundary before deterministic teardown.
	await process_frame
	await physics_frame
	await _dispose_node(sequence)
	await _dispose_node(player)


func _test_uncollected_reloads(reload_count: int) -> void:
	for reload_index: int in range(reload_count):
		var room: Chapter03PostBossRoom = POST_BOSS_ROOM.instantiate() as Chapter03PostBossRoom
		root.add_child(room)
		await process_frame
		await physics_frame
		_expect(room.reliquary.is_reward_available(), "Uncollected reload %d lost the reward" % (reload_index + 1))
		_expect(not room.underkeep_exit.monitoring, "Uncollected reload %d opened the gate" % (reload_index + 1))
		await _dispose_node(room)
		_uncollected_reload_count += 1


func _test_pickup_and_gate_transaction(collected_reload_count: int) -> void:
	var room: Chapter03PostBossRoom = POST_BOSS_ROOM.instantiate() as Chapter03PostBossRoom
	root.add_child(room)
	await process_frame
	await physics_frame
	_expect(room.reliquary.is_reward_available(), "Post-Boss weapon is not available")
	_expect(not room.underkeep_exit.monitoring, "Underkeep exit opened before collection")
	_expect(not room.reliquary.descent_blocker.disabled, "Physical descent blocker opened early")
	var inventory: PlayerWeaponInventory = _inventory()
	var equipment: PlayerEquipmentManager = _equipment()
	var owned_before: int = inventory.get_owned_weapon_ids().size()
	_expect(room.reliquary.pickup.collect(), "Formal WeaponPickup could not collect")
	await process_frame
	await physics_frame
	_expect(inventory.owns_weapon(WEAPON_ID), "Collected weapon is absent from unique inventory")
	_expect(equipment.equipped_weapon_id == WEAPON_ID, "Collected weapon did not auto-equip")
	_expect(equipment.get_normal_attack_damage() == 14, "Normal damage is not 14 after pickup")
	_expect(equipment.get_dash_attack_damage() == 28, "Dash damage is not 28 after pickup")
	_expect(inventory.get_owned_weapon_ids().size() == owned_before + 1, "Inventory count did not increase exactly once")
	_expect(not room.reliquary.pickup.collect(), "Repeated pickup interaction was accepted")
	_expect(inventory.get_owned_weapon_ids().size() == owned_before + 1, "Repeated pickup duplicated inventory")
	_expect(room.reliquary.is_reward_collected(), "Reliquary did not enter collected state")
	_expect(room.underkeep_exit.monitoring, "Underkeep exit remained closed after collection")
	_expect(room.reliquary.descent_blocker.disabled, "Physical blocker remained closed after collection")
	_expect(room.acquisition_panel.visible, "Acquisition panel was not presented")
	var session: ChapterSessionState = _session()
	_expect(session.has_story_flag(Chapter03PostBossReliquary.FLAG_REWARD_COLLECTED), "Collected flag missing")
	_expect(session.has_story_flag(Chapter03PostBossReliquary.FLAG_UNDERKEEP_UNLOCKED), "Underkeep flag missing")
	_expect(session.is_chapter_completed(ChapterRegistry.CHAPTER_03_CHAPEL_OF_THIRTEEN_ECHOES), "Chapter completion missing")
	await _dispose_node(room)

	for reload_index: int in range(collected_reload_count):
		var restored_room: Chapter03PostBossRoom = POST_BOSS_ROOM.instantiate() as Chapter03PostBossRoom
		root.add_child(restored_room)
		await process_frame
		await physics_frame
		_expect(restored_room.reliquary.is_reward_collected(), "Collected reload %d did not stay empty" % (reload_index + 1))
		_expect(not restored_room.reliquary.is_reward_available(), "Collected reload %d duplicated the weapon" % (reload_index + 1))
		_expect(restored_room.underkeep_exit.monitoring, "Collected reload %d did not keep the gate open" % (reload_index + 1))
		await _dispose_node(restored_room)
		_collected_reload_count += 1


func _dispose_node(node: Node) -> void:
	if node == null:
		return
	if node.get_parent() != null:
		node.get_parent().remove_child(node)
	node.free()
	await process_frame
	await physics_frame


func _on_formation_stage_changed(stage_name: StringName) -> void:
	_stages.append(stage_name)


func _on_formation_finished() -> void:
	_formation_finish_count += 1


func _reset_runtime() -> void:
	var session: ChapterSessionState = _session()
	if session != null:
		session.begin_debug_run()
	var equipment: PlayerEquipmentManager = _equipment()
	if equipment != null:
		equipment.reset_for_new_run()


func _session() -> ChapterSessionState:
	return root.get_node_or_null("ChapterSession") as ChapterSessionState


func _inventory() -> PlayerWeaponInventory:
	return root.get_node_or_null("WeaponInventory") as PlayerWeaponInventory


func _equipment() -> PlayerEquipmentManager:
	return root.get_node_or_null("EquipmentManager") as PlayerEquipmentManager


func _expect(condition: bool, message: String) -> void:
	if not condition:
		_failures.append(message)


func _expect_image(path: String, expected_size: Vector2i) -> void:
	var texture: Texture2D = load(path) as Texture2D
	var image: Image = texture.get_image() if texture != null else null
	_expect(texture != null, "W4 texture could not load: %s" % path)
	if image == null:
		return
	_expect(not image.is_empty(), "W4 asset could not load: %s" % path)
	if not image.is_empty():
		_expect(image.get_size() == expected_size, "W4 asset size mismatch: %s" % path)


func _finish() -> void:
	if _failures.is_empty():
		print(
			"THIRTEENFOLD_W4_REWARD | PASS full_flows=%d uncollected_reloads=%d collected_reloads=%d unique=1 damage=14/28"
			% [_full_flow_count, _uncollected_reload_count, _collected_reload_count]
		)
		quit(0)
		return
	for failure: String in _failures:
		push_error(failure)
	print("THIRTEENFOLD_W4_REWARD | FAIL count=%d" % _failures.size())
	quit(1)
