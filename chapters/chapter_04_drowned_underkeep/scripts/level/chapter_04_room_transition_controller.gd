class_name Chapter04RoomTransitionController
extends Node

signal room_changed(room_id: StringName, room: Node2D)
signal room_transition_profiled(room_id: StringName, metrics: Dictionary)

const ROOM_SCRIPT: Script = preload("res://chapters/chapter_04_drowned_underkeep/scripts/level/chapter_04_room.gd")
const LAYER_CONTRACT: Script = preload("res://chapters/chapter_04_drowned_underkeep/scripts/level/chapter_04_layer_contract.gd")

const ROOM_SCENES: Dictionary[StringName, String] = {
	&"CH4_AREA_00": "res://chapters/chapter_04_drowned_underkeep/scenes/rooms/ch4_00_drowned_threshold.tscn",
	&"CH4_AREA_01": "res://chapters/chapter_04_drowned_underkeep/scenes/rooms/ch4_01_flooded_intake.tscn",
	&"CH4_AREA_02": "res://chapters/chapter_04_drowned_underkeep/scenes/rooms/ch4_02_rusted_cellblock.tscn",
	&"CH4_AREA_03": "res://chapters/chapter_04_drowned_underkeep/scenes/rooms/ch4_03_broken_chainway.tscn",
	&"CH4_AREA_04": "res://chapters/chapter_04_drowned_underkeep/scenes/rooms/ch4_04_harpoon_watch_gallery.tscn",
	&"CH4_AREA_05": "res://chapters/chapter_04_drowned_underkeep/scenes/rooms/ch4_05_cistern_of_the_changed.tscn",
	&"CH4_AREA_06": "res://chapters/chapter_04_drowned_underkeep/scenes/rooms/ch4_06_dry_gaolers_cell.tscn",
	&"CH4_AREA_07": "res://chapters/chapter_04_drowned_underkeep/scenes/rooms/ch4_07_leech_sluice.tscn",
	&"CH4_AREA_08": "res://chapters/chapter_04_drowned_underkeep/scenes/rooms/ch4_08_gaolers_workshop.tscn",
	&"CH4_AREA_09": "res://chapters/chapter_04_drowned_underkeep/scenes/rooms/ch4_09_soul_cage_registry.tscn",
	&"CH4_AREA_10": "res://chapters/chapter_04_drowned_underkeep/scenes/rooms/ch4_10_floodgate_engine_hall.tscn",
	&"CH4_AREA_11": "res://chapters/chapter_04_drowned_underkeep/scenes/rooms/ch4_11_final_lock_approach.tscn",
	&"CH4_AREA_12": "res://chapters/chapter_04_drowned_underkeep/scenes/rooms/ch4_12_last_gaol_checkpoint.tscn",
	&"CH4_AREA_13": "res://chapters/chapter_04_drowned_underkeep/scenes/rooms/ch4_13_soul_lock_antechamber.tscn",
	&"CH4_AREA_14": "res://chapters/chapter_04_drowned_underkeep/scenes/rooms/ch4_14_core_of_drowned_gaol.tscn",
	&"CH4_AREA_15": "res://chapters/chapter_04_drowned_underkeep/scenes/rooms/ch4_15_broken_soul_reservoir.tscn",
	&"CH4_AREA_16": "res://chapters/chapter_04_drowned_underkeep/scenes/rooms/ch4_16_hall_of_drowned_memories.tscn",
}

@export_node_path("Node2D") var room_host_path: NodePath = NodePath("../RoomHost")
@export_node_path("Player") var player_path: NodePath = NodePath("../ChapterRuntime/Player")
@export_node_path("PlayerRespawnController") var respawn_controller_path: NodePath = NodePath("../ChapterRuntime/PlayerRespawnController")
@export_node_path("Marker2D") var respawn_anchor_path: NodePath = NodePath("../ActiveRespawn")
@export_node_path("ColorRect") var fade_rect_path: NodePath = NodePath("../ChapterRuntime/HUD/RoomFade")
@export_node_path("Label") var room_name_label_path: NodePath = NodePath("../ChapterRuntime/HUD/RoomName")

@onready var room_host: Node2D = get_node(room_host_path) as Node2D
@onready var player: Player = get_node(player_path) as Player
@onready var respawn_controller: PlayerRespawnController = get_node(respawn_controller_path) as PlayerRespawnController
@onready var respawn_anchor: Marker2D = get_node(respawn_anchor_path) as Marker2D
@onready var fade_rect: ColorRect = get_node(fade_rect_path) as ColorRect
@onready var room_name_label: Label = get_node(room_name_label_path) as Label

var active_room: Node2D
var active_room_id: StringName = &""
var _transitioning: bool = false
var _prepared_rooms: Dictionary[StringName, PackedScene] = {}
var _loader_thread: Thread = Thread.new()
var _loading_room_id: StringName = &""
var _transition_started_usec: int = 0
var last_resource_wait_usec: int = 0
var last_instantiation_usec: int = 0
var last_transition_usec: int = 0
var peak_resource_wait_usec: int = 0
var peak_instantiation_usec: int = 0


func _ready() -> void:
	player.z_index = LAYER_CONTRACT.PLAYER
	player.z_as_relative = true


func _exit_tree() -> void:
	_collect_loader_thread()
	_prepared_rooms.clear()


func initialize(room_id: StringName, spawn_id: StringName) -> bool:
	if active_room != null:
		return false
	return _swap_room(room_id, spawn_id)


func request_room_change(room_id: StringName, spawn_id: StringName) -> bool:
	if _transitioning or room_id == active_room_id or not ROOM_SCENES.has(room_id):
		return false
	_transitioning = true
	_transition_started_usec = Time.get_ticks_usec()
	_request_room_prepare(room_id)
	_run_transition(room_id, spawn_id)
	return true


func request_room_restart(spawn_id: StringName) -> bool:
	if _transitioning or active_room_id.is_empty() or not ROOM_SCENES.has(active_room_id):
		return false
	_transitioning = true
	_transition_started_usec = Time.get_ticks_usec()
	_request_room_prepare(active_room_id)
	_run_transition(active_room_id, spawn_id)
	return true


func _run_transition(room_id: StringName, spawn_id: StringName) -> void:
	var previous_profile: Player.InputProfile = player.get_input_profile()
	var was_invulnerable: bool = player.hurtbox != null and player.hurtbox.is_invulnerable
	player.set_input_profile(Player.InputProfile.LOCKED)
	player.velocity = Vector2.ZERO
	if player.hurtbox != null:
		player.hurtbox.set_invulnerable(true)
	fade_rect.visible = true
	fade_rect.modulate.a = 0.0
	var fade_out: Tween = create_tween()
	fade_out.tween_property(fade_rect, "modulate:a", 1.0, 0.18)
	await fade_out.finished
	var packed: PackedScene = await _await_prepared_room(room_id)
	var did_swap: bool = _swap_room_from_packed(room_id, spawn_id, packed)
	await get_tree().physics_frame
	var fade_in: Tween = create_tween()
	fade_in.tween_property(fade_rect, "modulate:a", 0.0, 0.18)
	await fade_in.finished
	fade_rect.visible = false
	var room_owns_player_lock: bool = (
		did_swap
		and active_room != null
		and bool(active_room.get_meta(&"boss_intro_controls_player", false))
	)
	if not room_owns_player_lock:
		if player.hurtbox != null and not was_invulnerable:
			player.hurtbox.set_invulnerable(false)
		player.set_input_profile(Player.InputProfile.FULL if did_swap else previous_profile)
	if did_swap:
		_resume_active_room_encounters()
	_transitioning = false
	last_transition_usec = Time.get_ticks_usec() - _transition_started_usec
	if did_swap:
		_prune_prepared_rooms(room_id)
	room_transition_profiled.emit(room_id, get_transition_metrics())


func _swap_room(room_id: StringName, spawn_id: StringName) -> bool:
	var wait_started_usec: int = Time.get_ticks_usec()
	var packed: PackedScene = _get_prepared_room_blocking(room_id)
	last_resource_wait_usec = Time.get_ticks_usec() - wait_started_usec
	peak_resource_wait_usec = maxi(peak_resource_wait_usec, last_resource_wait_usec)
	var did_swap: bool = _swap_room_from_packed(room_id, spawn_id, packed)
	if did_swap:
		_resume_active_room_encounters()
	return did_swap


func _swap_room_from_packed(room_id: StringName, spawn_id: StringName, packed: PackedScene) -> bool:
	var path: String = ROOM_SCENES.get(room_id, "")
	if packed == null:
		push_error("Unable to load Chapter IV room: %s" % path)
		return false
	var instantiate_started_usec: int = Time.get_ticks_usec()
	var new_room: Node2D = packed.instantiate() as Node2D
	last_instantiation_usec = Time.get_ticks_usec() - instantiate_started_usec
	peak_instantiation_usec = maxi(peak_instantiation_usec, last_instantiation_usec)
	if new_room == null:
		push_error("Unable to instantiate Chapter IV room: %s" % path)
		return false
	if new_room.get_script() != ROOM_SCRIPT:
		push_error("Chapter IV room root must be Chapter04Room: %s" % path)
		new_room.free()
		return false
	# Child _ready callbacks run while the room enters the tree, before this
	# controller can resolve the destination spawn.  Mark the room first so its
	# encounter spawner cannot activate against the persistent Player's old
	# world-space position during that window.
	new_room.set_meta(&"chapter_04_activation_suspended", true)
	new_room.process_mode = Node.PROCESS_MODE_DISABLED
	room_host.add_child(new_room)
	var encounter_spawner: Chapter04EncounterSpawner = new_room.get_node_or_null("EncounterSpawner") as Chapter04EncounterSpawner
	if encounter_spawner != null:
		encounter_spawner.set_activation_suspended(true)
	var spawn: Marker2D = new_room.call("get_spawn", spawn_id) as Marker2D
	if spawn == null:
		push_error("Chapter IV room has no valid spawn: %s / %s" % [room_id, spawn_id])
		room_host.remove_child(new_room)
		new_room.free()
		return false
	if active_room != null:
		active_room.process_mode = Node.PROCESS_MODE_DISABLED
		room_host.remove_child(active_room)
		active_room.queue_free()
	if player.status_effect_controller != null:
		player.status_effect_controller.clear_all()
	active_room = new_room
	active_room_id = room_id
	active_room.process_mode = Node.PROCESS_MODE_INHERIT
	active_room.connect("transition_requested", request_room_change)
	active_room.connect("checkpoint_requested", _on_checkpoint_requested)
	player.global_position = spawn.global_position
	player.velocity = Vector2.ZERO
	_set_respawn(spawn.global_position)
	if player.player_camera != null:
		player.player_camera.limit_left = 0
		player.player_camera.limit_right = (active_room.get("room_size") as Vector2i).x
		player.player_camera.limit_top = 0
		player.player_camera.limit_bottom = (active_room.get("room_size") as Vector2i).y
		player.player_camera.reset_smoothing()
	room_name_label.text = str(active_room.get("bilingual_name"))
	room_changed.emit(room_id, active_room)
	return true


func _resume_active_room_encounters() -> void:
	if active_room == null:
		return
	var encounter_spawner: Chapter04EncounterSpawner = active_room.get_node_or_null("EncounterSpawner") as Chapter04EncounterSpawner
	if encounter_spawner != null:
		encounter_spawner.set_activation_suspended(false)
	active_room.set_meta(&"chapter_04_activation_suspended", false)


func get_transition_metrics() -> Dictionary:
	return {
		"room_id": active_room_id,
		"resource_wait_usec": last_resource_wait_usec,
		"instantiation_usec": last_instantiation_usec,
		"transition_usec": last_transition_usec,
		"peak_resource_wait_usec": peak_resource_wait_usec,
		"peak_instantiation_usec": peak_instantiation_usec,
		"prepared_room_count": _prepared_rooms.size(),
		"thread_request_count": 1 if _loader_thread.is_started() else 0,
	}


func is_transitioning() -> bool:
	return _transitioning


func is_room_prepared(room_id: StringName) -> bool:
	return _prepared_rooms.has(room_id)


func _request_room_prepare(room_id: StringName) -> void:
	if _prepared_rooms.has(room_id) or room_id == _loading_room_id or not ROOM_SCENES.has(room_id):
		return
	_collect_loader_thread()
	var path: String = ROOM_SCENES[room_id]
	_loading_room_id = room_id
	var error: Error = _loader_thread.start(_load_packed_scene_on_worker.bind(path))
	if error == OK:
		return
	else:
		_loading_room_id = &""
		push_warning("Unable to prepare Chapter IV room on loader thread: %s (%s)" % [path, error_string(error)])


func _await_prepared_room(room_id: StringName) -> PackedScene:
	var wait_started_usec: int = Time.get_ticks_usec()
	_request_room_prepare(room_id)
	while room_id == _loading_room_id and _loader_thread.is_alive():
		await get_tree().process_frame
	if room_id == _loading_room_id:
		_collect_loader_thread()
	last_resource_wait_usec = Time.get_ticks_usec() - wait_started_usec
	peak_resource_wait_usec = maxi(peak_resource_wait_usec, last_resource_wait_usec)
	if _prepared_rooms.has(room_id):
		return _prepared_rooms[room_id]
	return _load_room_sync(room_id)


func _get_prepared_room_blocking(room_id: StringName) -> PackedScene:
	if _prepared_rooms.has(room_id):
		return _prepared_rooms[room_id]
	if room_id == _loading_room_id:
		_collect_loader_thread()
		if _prepared_rooms.has(room_id):
			return _prepared_rooms[room_id]
	return _load_room_sync(room_id)


func _collect_loader_thread() -> void:
	if not _loader_thread.is_started():
		return
	var completed_room_id: StringName = _loading_room_id
	var packed: PackedScene = _loader_thread.wait_to_finish() as PackedScene
	_loading_room_id = &""
	if packed != null and not completed_room_id.is_empty():
		_prepared_rooms[completed_room_id] = packed


static func _load_packed_scene_on_worker(path: String) -> PackedScene:
	return ResourceLoader.load(path, "PackedScene", ResourceLoader.CACHE_MODE_IGNORE) as PackedScene


func _load_room_sync(room_id: StringName) -> PackedScene:
	if not ROOM_SCENES.has(room_id):
		return null
	var packed: PackedScene = ResourceLoader.load(ROOM_SCENES[room_id], "PackedScene") as PackedScene
	if packed != null:
		_prepared_rooms[room_id] = packed
	return packed


func _prune_prepared_rooms(room_id: StringName) -> void:
	for prepared_id: StringName in _prepared_rooms.keys():
		if prepared_id != room_id:
			_prepared_rooms.erase(prepared_id)


func _set_respawn(position: Vector2) -> void:
	respawn_anchor.global_position = position
	respawn_controller.set_spawn_point(respawn_anchor)


func _on_checkpoint_requested(checkpoint_id: StringName, marker: Marker2D) -> void:
	if marker == null:
		return
	_set_respawn(marker.global_position)
	var session: ChapterSessionState = get_node_or_null("/root/ChapterSession") as ChapterSessionState
	if session != null:
		session.set_story_flag(StringName("chapter_04_checkpoint_%s" % checkpoint_id.to_lower()))
