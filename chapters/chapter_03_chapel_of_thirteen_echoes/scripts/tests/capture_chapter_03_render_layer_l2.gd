extends SceneTree

## MainBootstrap-only visual evidence driver for Chapter III render-layer L2.
## It changes runtime state only: no scene/resource is saved by this script.

const BOOTSTRAP_PATH: String = "res://scenes/bootstrap/main_bootstrap.tscn"
const OUTPUT_DIRECTORY: String = "res://docs/qa/chapter_03_render_layer_l2"
const PROJECTILE_SCENE: PackedScene = preload(
	"res://chapters/chapter_03_chapel_of_thirteen_echoes/scenes/projectiles/"
	+ "chapter_03_enemy_projectile.tscn"
)
const FIELD_SCENE: PackedScene = preload(
	"res://chapters/chapter_03_chapel_of_thirteen_echoes/scenes/projectiles/"
	+ "chapter_03_timed_field.tscn"
)

var _config: DebugRunConfigState
var _route: Chapter03Route
var _controller: Chapter03RoomTransitionController
var _player: Player
var _capture_count: int = 0
var _index_rows: Array[String] = [
	(
		"capture\troom_id\tspawn_id\tposition\tcamera_center\tcamera_limit_right\tplayer_visible\t"
		+ "action\tdoor_state\tacceptance_target\tstatus"
	)
]
var _runtime_rows: Array[String] = [
	"room_id\tnode_path\ttype\tparent\tz_index\teffective_z\tz_as_relative\ty_sort_enabled\tcanvas_layer\tvisible\tglobal_position"
]
var _audited_rooms: Dictionary[StringName, bool] = {}


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	DisplayServer.window_set_size(Vector2i(1280, 720))
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUTPUT_DIRECTORY))
	_config = root.get_node_or_null("DebugRunConfig") as DebugRunConfigState
	if _config == null:
		_fail("missing DebugRunConfig")
		return
	_config.debug_chapter_start_enabled = true
	_config.debug_start_chapter_id = ChapterRegistry.CHAPTER_03_CHAPEL_OF_THIRTEEN_ECHOES
	_config.debug_start_spawn_id = &"chapter_03_start"
	_config.debug_reset_chapter_state_on_run = true
	debug_collisions_hint = true
	if change_scene_to_file(BOOTSTRAP_PATH) != OK:
		_fail("unable to load MainBootstrap")
		return
	_route = await _wait_for_route()
	if _route == null:
		_fail("MainBootstrap did not resolve Chapter03Route")
		return
	_controller = _route.transition_controller
	_player = _controller.player
	_prepare_player_for_visual_qa()
	await _ensure_room(&"CH3_CHAPEL_VESTIBULE")
	await _pose_at(Vector2(1468, 584), &"ready_idle", 1)
	await _capture(
		"00_vestibule_runtime_collisions.png",
		"NaveDoor",
		"collision_debug",
		"closed",
		"runtime collision overlay"
	)
	debug_collisions_hint = false
	if change_scene_to_file(BOOTSTRAP_PATH) != OK:
		_fail("unable to reload clean MainBootstrap after collision capture")
		return
	await process_frame
	_route = await _wait_for_route()
	if _route == null:
		_fail("clean MainBootstrap reload did not resolve Chapter03Route")
		return
	_controller = _route.transition_controller
	_player = _controller.player
	_prepare_player_for_visual_qa()

	await _capture_vestibule()
	await _capture_nave()
	await _capture_choir()
	await _capture_checkpoint()
	await _capture_antechamber_and_gate()
	await _capture_boss_room()
	await _capture_post_boss()
	await _capture_underkeep()
	var stability_cycles: int = await _run_reload_stability()
	_write_text("screenshot_index.tsv", "\n".join(_index_rows) + "\n")
	_write_text("runtime_layer_samples.tsv", "\n".join(_runtime_rows) + "\n")
	_write_text(
		"run_result.txt",
		(
			"CH3_RENDER_LAYER_L2_CAPTURE PASS captures=%d rooms=%d reloads=%d "
			+ "main_bootstrap=true boss_entity=partial reward=partial chapter4=partial\n"
		) % [_capture_count, _audited_rooms.size(), stability_cycles]
	)
	_config.reset_to_defaults()
	print(
		(
			"CH3_RENDER_LAYER_L2_CAPTURE PASS captures=%d rooms=%d reloads=%d "
			+ "main_bootstrap=true boss_entity=partial reward=partial chapter4=partial"
		) % [_capture_count, _audited_rooms.size(), stability_cycles]
	)
	quit(0)


func _prepare_player_for_visual_qa() -> void:
	_player.set_input_profile(Player.InputProfile.LOCKED)
	_player.set_physics_process(false)
	_player.velocity = Vector2.ZERO
	if _player.hurtbox != null:
		_player.hurtbox.set_invulnerable(true)
	if _player.player_camera != null:
		_player.player_camera.zoom = Vector2.ONE
		_player.player_camera.position_smoothing_enabled = false
		_player.player_camera.reset_smoothing()


func _capture_vestibule() -> void:
	await _ensure_room(&"CH3_CHAPEL_VESTIBULE")
	await _pose_at(Vector2(160, 584), &"idle", 1)
	await _capture("01_vestibule_v01_entry_idle.png", "EntryWest", "idle", "closed", "V1 entrance")
	await _pose_at(Vector2(1468, 584), &"idle", 1)
	await _capture("02_vestibule_v02_door_center.png", "NaveDoor", "idle", "closed", "V2 door center")
	await _pose_at(Vector2(1404, 584), &"ready_idle", 1)
	await _capture("03_vestibule_v03_door_left.png", "NaveDoorLeft", "idle", "closed", "V3 left frame")
	await _pose_at(Vector2(1532, 584), &"ready_idle", 1)
	await _capture("04_vestibule_v04_door_right.png", "NaveDoorRight", "idle", "closed", "V4 right frame")
	await _pose_at(Vector2(476, 584), &"idle", 2)
	await _capture("05_vestibule_v05_bench.png", "LeftBench", "idle", "closed", "V5 bench")
	await _pose_at(Vector2(1952, 644), &"fall", 1)
	await _capture("06_vestibule_v06_stairs.png", "EastStair", "fall", "closed", "V6 stair edge")
	await _pose_at(Vector2(1468, 520), &"jump_start", 1)
	await _capture("07_vestibule_v07_jump.png", "NaveDoor", "jump", "closed", "V7 jump")
	await _pose_at(Vector2(1468, 584), &"attack", 2)
	await _capture("08_vestibule_v08_attack.png", "NaveDoor", "normal_attack", "closed", "V8 weapon active")
	await _pose_at(Vector2(1468, 584), &"dash_attack", 2)
	await _capture("09_vestibule_v09_dash_attack.png", "NaveDoor", "dash_attack", "closed", "V9 dash attack")
	var door: Chapter03RoomDoor = _controller.active_room.get_node("Doors/NaveDoor") as Chapter03RoomDoor
	await _capture_ordinary_door_states(door, "10_vestibule", "NaveDoor", Vector2(1468, 584))


func _capture_nave() -> void:
	await _ensure_room(&"CH3_NAVE_ENTRY")
	await _pose_at(Vector2(160, 584), &"run", 2)
	await _capture("14_nave_entry_run.png", "EntryWest", "run", "closed", "room entrance")
	await _pose_at(Vector2(780, 584), &"dash_loop", 1)
	await _capture("15_nave_ground_dash.png", "NaveFloor", "ground_dash", "closed", "ground dash")
	await _pose_at(Vector2(1120, 500), &"air_dash_loop", 1)
	await _capture("16_nave_air_dash.png", "NaveAir", "air_dash", "closed", "air dash")
	await _pose_at(Vector2(1420, 584), &"fall", 1)
	await _capture("17_nave_fall.png", "NaveCenter", "fall", "closed", "fall silhouette")
	await _capture_formal_enemies("nave")
	var door: Chapter03RoomDoor = _controller.active_room.get_node("Doors/ChoirDoor") as Chapter03RoomDoor
	await _capture_ordinary_door_states(door, "18_nave", "ChoirDoor", Vector2(2180, 584))


func _capture_choir() -> void:
	await _ensure_room(&"CH3_CHOIR_GALLERY")
	await _pose_at(Vector2(160, 584), &"idle", 1)
	await _capture("22_choir_entry.png", "EntryWest", "idle", "closed", "room entrance")
	await _pose_at(Vector2(1808, 402), &"jump_apex", 1)
	await _capture("23_choir_platform_jump.png", "UpperGallery", "jump_apex", "closed", "platform actor")
	await _pose_at(Vector2(1808, 402), &"attack", 2)
	await _capture("24_choir_platform_attack.png", "UpperGallery", "normal_attack", "closed", "platform weapon")
	await _capture_formal_enemies("choir")
	await _capture_drop_and_combat_fx()
	var door: Chapter03RoomDoor = _controller.active_room.get_node("Doors/CheckpointDoor") as Chapter03RoomDoor
	await _capture_ordinary_door_states(door, "25_choir", "CheckpointDoor", Vector2(2304, 584))


func _capture_checkpoint() -> void:
	await _ensure_room(&"CH3_BOSS_CHECKPOINT")
	await _pose_at(Vector2(214, 584), &"idle", 1)
	await _capture("29_checkpoint_c01_left.png", "CheckpointLeft", "idle", "closed", "C1 left")
	await _pose_at(Vector2(298, 584), &"idle", 1)
	await _capture("30_checkpoint_c02_front.png", "CheckpointFront", "idle", "closed", "C2 front")
	await _pose_at(Vector2(382, 584), &"ready_idle", 1)
	await _capture("31_checkpoint_c03_right.png", "CheckpointRight", "idle", "closed", "C3 right")
	var checkpoint: Chapter03RoomCheckpoint = _controller.active_room.get_node("CheckpointArea") as Chapter03RoomCheckpoint
	checkpoint._on_body_entered(_player)
	await _pose_at(Vector2(298, 584), &"ready_idle", 1)
	await _capture("32_checkpoint_c04_interaction.png", "CheckpointFront", "interact", "closed", "C4 interaction")
	await _pose_at(Vector2(298, 520), &"double_jump", 2)
	await _capture("33_checkpoint_c05_jump.png", "CheckpointFront", "double_jump", "closed", "C5 jump")
	await _pose_at(Vector2(298, 584), &"attack", 2)
	await _capture("34_checkpoint_c06_attack.png", "CheckpointFront", "normal_attack", "closed", "C6 attack")
	await _pose_at(Vector2(298, 584), &"hurt_heavy", 2)
	await _capture("35_checkpoint_c07_hurt.png", "CheckpointOverlap", "hurt", "closed", "C7 overlap and hurt")
	await _capture_death_ghost_and_respawn()
	var door: Chapter03RoomDoor = _controller.active_room.get_node("Doors/ConfessionDoor") as Chapter03RoomDoor
	await _capture_ordinary_door_states(door, "39_checkpoint", "ConfessionDoor", Vector2(790, 584))


func _capture_antechamber_and_gate() -> void:
	await _ensure_room(&"CH3_BOSS_ANTE")
	await _pose_at(Vector2(160, 584), &"idle", 1)
	await _capture("43_ante_t01_statue.png", "Statue", "idle", "closed", "T1 statue")
	await _pose_at(Vector2(214, 584), &"ready_idle", 1)
	await _capture("44_ante_t02_shrine.png", "CheckpointShrine", "idle", "closed", "T2 shrine")
	await _pose_at(Vector2(510, 584), &"run", 2)
	await _capture("45_ante_t03_confession_boards.png", "ConfessionBoards01", "run", "closed", "T3 boards")
	await _pose_at(Vector2(780, 584), &"idle", 2)
	await _capture("46_ante_t04_lectern_front.png", "Lectern", "idle", "closed", "T4 lectern")
	await _pose_at(Vector2(850, 584), &"jump_apex", 1)
	await _capture("47_ante_t05_lectern_jump.png", "Lectern", "jump", "closed", "T5/T8 lectern overlap")
	await _pose_at(Vector2(1060, 584), &"attack", 2)
	await _capture("48_ante_t06_attack.png", "ConfessionBoards02", "normal_attack", "closed", "T6/T9 weapon")
	await _pose_at(Vector2(1120, 584), &"dash_attack", 2)
	await _capture("49_ante_t07_dash_attack.png", "GroundDetail", "dash_attack", "closed", "T7/T10 ground detail")
	await _capture_boss_gate_states()


func _capture_boss_room() -> void:
	if _controller.active_room_id != &"CH3_BOSS":
		await _ensure_room(&"CH3_BOSS")
	var boss_room: Chapter03BossSanctumRoom = _controller.active_room as Chapter03BossSanctumRoom
	if boss_room != null:
		await _wait_for_boss_intro_and_player_camera(boss_room.sanctum)
	await _pose_at(Vector2(160, 584), &"idle", 1)
	await _capture("57_boss_room_entry.png", "EntryWest", "idle", "open", "Boss room entrance")
	await _pose_at(Vector2(1180, 584), &"attack", 2)
	await _capture("58_boss_room_center_attack.png", "SanctumCenter", "normal_attack", "open", "Boss arena center")
	await _pose_at(Vector2(1900, 520), &"air_dash_loop", 1)
	await _capture("59_boss_room_air_dash.png", "SanctumEast", "air_dash", "open", "Boss arena east")


func _capture_post_boss() -> void:
	await _ensure_room(&"CH3_POST_BOSS")
	await _pose_at(Vector2(160, 584), &"idle", 1)
	await _capture("60_post_boss_entry.png", "EntryWest", "idle", "open", "post-Boss entrance")
	await _pose_at(Vector2(660, 584), &"ready_idle", 1)
	await _capture("61_post_boss_reliquary.png", "Reliquary", "interact", "open", "reward boundary")
	await _pose_at(Vector2(1120, 584), &"run", 3)
	await _capture("62_post_boss_exit.png", "UnderkeepExit", "run", "open", "post-Boss exit")


func _capture_underkeep() -> void:
	await _ensure_room(&"CH3_UNDERKEEP_DESCENT")
	await _pose_at(Vector2(160, 584), &"idle", 1)
	await _capture("63_underkeep_entry.png", "EntryWest", "idle", "open", "underkeep entrance")
	await _pose_at(Vector2(1040, 584), &"idle", 2)
	await _capture("64_underkeep_water_idle.png", "WaterSurface01", "idle", "open", "4px water edge")
	await _pose_at(Vector2(1040, 520), &"jump_apex", 1)
	await _capture("65_underkeep_water_jump.png", "WaterSurface01", "jump", "open", "water jump")
	await _pose_at(Vector2(1600, 584), &"attack", 2)
	await _capture("66_underkeep_water_attack.png", "WaterSurface02", "normal_attack", "open", "water weapon")
	await _pose_at(Vector2(2100, 584), &"ready_idle", 1)
	await _capture("67_underkeep_chapter4_boundary.png", "Chapter04Boundary", "interact", "open", "planned terminal")


func _capture_ordinary_door_states(
	door: Chapter03RoomDoor,
	prefix: String,
	door_id: String,
	position: Vector2
) -> void:
	await _pose_at(position, &"ready_idle", 1)
	await _capture(prefix + "_door_closed.png", door_id, "idle", "closed", "door closed")
	door.transition_on_open = false
	door._open()
	await create_timer(door.opening_duration * 0.28).timeout
	await _capture(prefix + "_door_open_25.png", door_id, "idle", "25%", "door partial")
	await create_timer(door.opening_duration * 0.27).timeout
	await _capture(prefix + "_door_open_50.png", door_id, "idle", "50%", "door partial")
	await create_timer(door.opening_duration * 0.55).timeout
	await _pose_at(position, &"run", 2)
	await _capture(prefix + "_door_open_pass.png", door_id, "run", "100%", "door pass-through")


func _capture_boss_gate_states() -> void:
	var gate: Chapter03BossGate = _controller.active_room.get_node("BossGate") as Chapter03BossGate
	var gate_center: Vector2 = Vector2(1472, 584)
	await _pose_at(gate_center, &"ready_idle", 1)
	await _capture("50_gate_b01_closed_front.png", "BossGate", "idle", "closed", "B1 closed")
	await _pose_at(Vector2(1398, 584), &"idle", 1)
	await _capture("51_gate_b02_closed_left.png", "BossGateLeft", "idle", "closed", "B2 left")
	await _pose_at(Vector2(1546, 584), &"idle", 1)
	await _capture("52_gate_b03_closed_right.png", "BossGateRight", "idle", "closed", "B3 right")
	await _pose_at(Vector2(1472, 508), &"double_jump", 2)
	await _capture("53_gate_b04_jump.png", "BossGateLintel", "double_jump", "closed", "B4 lintel")
	await _pose_at(Vector2(1222, 584), &"ready_idle", 1)
	gate._on_trigger_body_entered(_player)
	await _capture("54_gate_b05_prompt.png", "BossGateTrigger", "interact", "closed", "B5 prompt")
	_disconnect_gate_crossing(gate)
	gate.run_sequence_for_player(_player)
	await create_timer(gate.bell_step_duration * 13.0 + 0.16).timeout
	await _pose_at(gate_center, &"ready_idle", 1)
	await _capture("55_gate_b07_lit_and_cracked.png", "BossGate", "idle", "lit", "B6/B7 sequence")
	await create_timer(gate.door_open_duration * 0.28).timeout
	await _capture("55a_gate_b08_open_25.png", "BossGate", "idle", "25%", "B8 partial")
	await create_timer(gate.door_open_duration * 0.27).timeout
	await _capture("55b_gate_b09_open_50.png", "BossGate", "idle", "50%", "B9 partial")
	await create_timer(gate.door_open_duration * 0.60).timeout
	await _pose_at(gate_center, &"run", 2)
	await _capture("56_gate_b10_open_pass.png", "BossGate", "run", "100%", "B10 pass-through")
	if not _controller.request_room_change(&"CH3_BOSS", &"EntryWest"):
		_fail("Boss gate Fade transition was rejected")
		return
	await create_timer(0.11).timeout
	await _capture("56a_gate_b11_fade.png", "BossGate", "run", "fade", "B11 CanvasLayer Fade")
	await _wait_for_active_room(&"CH3_BOSS")


func _disconnect_gate_crossing(gate: Chapter03BossGate) -> void:
	for connection: Dictionary in gate.crossing_requested.get_connections():
		var callable: Callable = connection.get("callable", Callable()) as Callable
		if callable.is_valid():
			gate.crossing_requested.disconnect(callable)


func _capture_formal_enemies(prefix: String) -> void:
	var enemies: Array[Node] = _controller.active_room.find_children("*", "CharacterBody2D", true, false)
	var captured_types: Dictionary[String, bool] = {}
	for node: Node in enemies:
		var enemy: Node2D = node as Node2D
		if enemy == null or enemy == _player or not enemy.has_method("get_enemy_type_name"):
			continue
		var type_name: String = str(enemy.call("get_enemy_type_name"))
		if captured_types.has(type_name):
			continue
		captured_types[type_name] = true
		enemy.set_physics_process(false)
		var player_position: Vector2 = enemy.global_position + Vector2(-96, 0)
		await _pose_at(player_position, &"ready_idle", 1)
		var safe_name: String = type_name.to_snake_case().replace(" ", "_")
		await _capture(
			"enemy_%s_%s.png" % [prefix, safe_name],
			type_name,
			"enemy_idle",
			"n/a",
			"formal enemy actor layer"
		)


func _capture_drop_and_combat_fx() -> void:
	var enemies: Array[Node] = _controller.active_room.find_children("*", "CharacterBody2D", true, false)
	for node: Node in enemies:
		var enemy: Node2D = node as Node2D
		if enemy == null or not enemy.has_node("LootDropComponent"):
			continue
		var loot: LootDropComponent = enemy.get_node("LootDropComponent") as LootDropComponent
		loot._spawn_pickup(&"coin", 1)
		await process_frame
		var pickup: Node2D = _find_node2d_by_name(_controller.active_room, "CoinPickup")
		if pickup != null:
			pickup.set_physics_process(false)
			_record_canvas_subtree(&"CH3_CHOIR_GALLERY_DYNAMIC_DROP", pickup)
			await _pose_at(pickup.global_position + Vector2(-72, 8), &"idle", 1)
			await _capture("drop_coin_runtime_z13.png", "CoinPickup", "idle", "n/a", "Drop z=13")
		break
	var projectile: Chapter03EnemyProjectile = PROJECTILE_SCENE.instantiate() as Chapter03EnemyProjectile
	_controller.active_room.add_child(projectile)
	projectile.z_index = Chapter03LayerContract.COMBAT_FX
	projectile.global_position = Vector2(1500, 520)
	projectile.set_physics_process(false)
	var field: Chapter03TimedField = FIELD_SCENE.instantiate() as Chapter03TimedField
	_controller.active_room.add_child(field)
	field.z_index = Chapter03LayerContract.COMBAT_FX
	field.global_position = Vector2(1580, 570)
	field.set_physics_process(false)
	_record_canvas_subtree(&"CH3_CHOIR_GALLERY_DYNAMIC_FX", projectile)
	_record_canvas_subtree(&"CH3_CHOIR_GALLERY_DYNAMIC_FX", field)
	await _pose_at(Vector2(1420, 584), &"dash_attack", 2)
	await _capture("combat_fx_runtime_z16.png", "ProjectileAndField", "dash_attack", "n/a", "CombatFX z=16")


func _capture_death_ghost_and_respawn() -> void:
	var respawn: PlayerRespawnController = _controller.respawn_controller
	respawn.enabled = false
	_player.animation_controller.reset_to_idle()
	_player.set_physics_process(true)
	if _player.hurtbox != null:
		_player.hurtbox.set_invulnerable(false)
	_player.health_component.reset_to_full()
	_player.health_component.take_damage(_player.health_component.max_health)
	var death_sequence: PlayerDeathSequence = _player.get_node("DeathSequence") as PlayerDeathSequence
	await _wait_for_death_frame(death_sequence, 4)
	await _capture("36_checkpoint_death_body.png", "CheckpointFront", "death", "closed", "death body and daggers")
	await _wait_for_death_phase(death_sequence, &"GhostPause")
	await _capture("37_checkpoint_ghost_release.png", "CheckpointFront", "ghost_release", "closed", "ghost above corpse")
	var spawn_position: Vector2 = _controller.respawn_anchor.global_position
	if not _player.respawn_at(spawn_position):
		_fail("manual QA respawn failed")
		return
	respawn.enabled = true
	_prepare_player_for_visual_qa()
	await _pose_at(spawn_position, &"idle", 1)
	await _capture("38_checkpoint_respawn.png", "CheckpointFront", "respawn", "closed", "C8 respawn stability")


func _wait_for_death_frame(death_sequence: PlayerDeathSequence, target_frame: int) -> void:
	for _frame: int in range(240):
		await process_frame
		if (
			death_sequence.get_phase_name() == &"BodyFall"
			and _player.animation_controller.animated_sprite.frame >= target_frame
		):
			return
	_fail("death body frame timeout")


func _wait_for_death_phase(death_sequence: PlayerDeathSequence, target_phase: StringName) -> void:
	for _frame: int in range(240):
		await process_frame
		if death_sequence.get_phase_name() == target_phase:
			return
	_fail("death phase timeout: %s" % target_phase)


func _run_reload_stability() -> int:
	var critical_rooms: Array[StringName] = [
		&"CH3_CHAPEL_VESTIBULE",
		&"CH3_BOSS_CHECKPOINT",
		&"CH3_BOSS_ANTE",
		&"CH3_UNDERKEEP_DESCENT",
	]
	var completed: int = 0
	for room_id: StringName in critical_rooms:
		for _cycle: int in range(20):
			if not _controller._swap_room(room_id, &"EntryWest"):
				_fail("reload failed: %s" % room_id)
				return completed
			for _frame: int in range(3):
				await process_frame
			if _controller.room_host.get_child_count() != 1:
				_fail("duplicate room after reload: %s" % room_id)
				return completed
			if _effective_z(_player) != Chapter03LayerContract.PLAYER:
				_fail("Player z drift after reload: %s" % room_id)
				return completed
			completed += 1
	return completed


func _ensure_room(room_id: StringName) -> void:
	if _controller.active_room_id != room_id:
		if not _controller._swap_room(room_id, &"EntryWest"):
			_fail("unable to load room %s" % room_id)
			return
		for _frame: int in range(8):
			await process_frame
	await _disable_automatic_room_exits()
	_prepare_player_for_visual_qa()
	_record_room_runtime_once(room_id)


func _disable_automatic_room_exits() -> void:
	var areas: Array[Node] = _controller.active_room.find_children("*", "Area2D", true, false)
	for node: Node in areas:
		if node is Chapter03RoomExit:
			var exit_area: Area2D = node as Area2D
			exit_area.set_deferred("monitoring", false)
			exit_area.set_deferred("monitorable", false)
	await physics_frame


func _wait_for_active_room(room_id: StringName) -> void:
	for _frame: int in range(240):
		await process_frame
		if _controller.active_room_id == room_id and not _controller.fade_rect.visible:
			_prepare_player_for_visual_qa()
			_record_room_runtime_once(room_id)
			return
	_fail("room transition timeout: %s" % room_id)


func _wait_for_boss_intro_and_player_camera(sanctum: Chapter03BossSanctum) -> void:
	for _frame: int in range(720):
		await process_frame
		if (
			sanctum.is_intro_complete()
			and _player.player_camera != null
			and _player.player_camera.enabled
		):
			_prepare_player_for_visual_qa()
			return
	_fail("Boss intro did not restore the Player Camera")


func _pose_at(position: Vector2, animation_name: StringName, frame_index: int) -> void:
	_player.global_position = position
	_player.velocity = Vector2.ZERO
	var sprite: AnimatedSprite2D = _player.animation_controller.animated_sprite
	if sprite.sprite_frames.has_animation(animation_name):
		sprite.play(animation_name)
		sprite.pause()
		sprite.frame = mini(frame_index, maxi(0, sprite.sprite_frames.get_frame_count(animation_name) - 1))
	await process_frame
	if _player.player_camera != null:
		_player.player_camera.align()
		_player.player_camera.reset_smoothing()
		_player.player_camera.force_update_scroll()
	for _frame: int in range(4):
		await process_frame


func _capture(
	file_name: String,
	spawn_id: String,
	action: String,
	door_state: String,
	target: String
) -> void:
	for _frame: int in range(3):
		await process_frame
	RenderingServer.force_draw(false)
	var image: Image = root.get_texture().get_image()
	var path: String = OUTPUT_DIRECTORY.path_join(file_name)
	var error: Error = image.save_png(ProjectSettings.globalize_path(path))
	if error != OK:
		_fail("unable to save %s: %s" % [path, error_string(error)])
		return
	_index_rows.append(
		"%s\t%s\t%s\t%s\t%s\t%d\t%s\t%s\t%s\t%s\tCAPTURED"
		% [
			file_name,
			_controller.active_room_id,
			spawn_id,
			_player.global_position,
			(
				_player.player_camera.get_screen_center_position()
				if _player.player_camera != null
				else Vector2.ZERO
			),
			_player.player_camera.limit_right if _player.player_camera != null else 0,
			_player.visible,
			action,
			door_state,
			target,
		]
	)
	_capture_count += 1


func _record_room_runtime_once(room_id: StringName) -> void:
	if _audited_rooms.has(room_id):
		return
	_audited_rooms[room_id] = true
	_record_canvas_subtree(room_id, _controller.active_room)
	_record_canvas_subtree(room_id, _player)
	_record_canvas_subtree(room_id, _controller.fade_rect)


func _record_canvas_subtree(room_id: StringName, subtree: Node) -> void:
	var nodes: Array[Node] = [subtree]
	nodes.append_array(subtree.find_children("*", "", true, false))
	for node: Node in nodes:
		var item: CanvasItem = node as CanvasItem
		if item == null:
			continue
		_runtime_rows.append(
			"%s\t%s\t%s\t%s\t%d\t%d\t%s\t%s\t%d\t%s\t%s"
			% [
				room_id,
				str(item.get_path()),
				item.get_class(),
				str(item.get_parent().get_path()) if item.get_parent() != null else "",
				item.z_index,
				_effective_z(item),
				str(item.z_as_relative),
				str(item.y_sort_enabled),
				_canvas_layer(item),
				str(item.visible),
				_canvas_global_position(item),
			]
		)


func _effective_z(item: CanvasItem) -> int:
	var total: int = item.z_index
	if not item.z_as_relative:
		return total
	var parent: Node = item.get_parent()
	while parent is CanvasItem:
		var parent_item: CanvasItem = parent as CanvasItem
		total += parent_item.z_index
		if not parent_item.z_as_relative:
			break
		parent = parent_item.get_parent()
	return total


func _canvas_layer(item: CanvasItem) -> int:
	var parent: Node = item
	while parent != null:
		var layer: CanvasLayer = parent as CanvasLayer
		if layer != null:
			return layer.layer
		parent = parent.get_parent()
	return 0


func _canvas_global_position(item: CanvasItem) -> String:
	var node_2d: Node2D = item as Node2D
	if node_2d != null:
		return str(node_2d.global_position)
	var control: Control = item as Control
	if control != null:
		return str(control.global_position)
	return "n/a"


func _find_node2d_by_name(subtree: Node, target_name: String) -> Node2D:
	var matches: Array[Node] = subtree.find_children(target_name, "Node2D", true, false)
	return matches[0] as Node2D if not matches.is_empty() else null


func _write_text(file_name: String, text: String) -> void:
	var file: FileAccess = FileAccess.open(
		ProjectSettings.globalize_path(OUTPUT_DIRECTORY.path_join(file_name)),
		FileAccess.WRITE
	)
	if file == null:
		_fail("unable to write %s" % file_name)
		return
	file.store_string(text)
	file.close()


func _wait_for_route() -> Chapter03Route:
	for _frame: int in range(420):
		await process_frame
		var route: Chapter03Route = current_scene as Chapter03Route
		if route != null:
			return route
	return null


func _fail(message: String) -> void:
	push_error("CH3_RENDER_LAYER_L2_CAPTURE: %s" % message)
	if _config != null:
		_config.reset_to_defaults()
	quit(1)
