class_name Chapter04RoomTransitionController
extends Node

signal room_changed(room_id: StringName, room: Node2D)

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


func _ready() -> void:
	player.z_index = LAYER_CONTRACT.PLAYER
	player.z_as_relative = true


func initialize(room_id: StringName, spawn_id: StringName) -> bool:
	if active_room != null:
		return false
	return _swap_room(room_id, spawn_id)


func request_room_change(room_id: StringName, spawn_id: StringName) -> bool:
	if _transitioning or room_id == active_room_id or not ROOM_SCENES.has(room_id):
		return false
	_transitioning = true
	_run_transition(room_id, spawn_id)
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
	var did_swap: bool = _swap_room(room_id, spawn_id)
	await get_tree().physics_frame
	var fade_in: Tween = create_tween()
	fade_in.tween_property(fade_rect, "modulate:a", 0.0, 0.18)
	await fade_in.finished
	fade_rect.visible = false
	if player.hurtbox != null and not was_invulnerable:
		player.hurtbox.set_invulnerable(false)
	player.set_input_profile(Player.InputProfile.FULL if did_swap else previous_profile)
	_transitioning = false


func _swap_room(room_id: StringName, spawn_id: StringName) -> bool:
	var path: String = ROOM_SCENES.get(room_id, "")
	var packed: PackedScene = ResourceLoader.load(path, "PackedScene") as PackedScene
	if packed == null:
		push_error("Unable to load Chapter IV room: %s" % path)
		return false
	var new_room: Node2D = packed.instantiate() as Node2D
	if new_room == null or new_room.get_script() != ROOM_SCRIPT:
		push_error("Chapter IV room root must be Chapter04Room: %s" % path)
		return false
	if active_room != null:
		room_host.remove_child(active_room)
		active_room.queue_free()
	if player.status_effect_controller != null:
		player.status_effect_controller.clear_all()
	active_room = new_room
	active_room_id = room_id
	room_host.add_child(active_room)
	active_room.connect("transition_requested", request_room_change)
	active_room.connect("checkpoint_requested", _on_checkpoint_requested)
	var spawn: Marker2D = active_room.call("get_spawn", spawn_id) as Marker2D
	if spawn == null:
		push_error("Chapter IV room has no valid spawn: %s / %s" % [room_id, spawn_id])
		return false
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
