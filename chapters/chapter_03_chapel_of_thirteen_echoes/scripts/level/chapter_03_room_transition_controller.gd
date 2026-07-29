class_name Chapter03RoomTransitionController
extends Node

signal room_changed(room_id: StringName, room: Chapter03Room)

const ROOM_SCENES: Dictionary[StringName, String] = {
	&"CH3_CHAPEL_VESTIBULE": "res://chapters/chapter_03_chapel_of_thirteen_echoes/scenes/rooms/ch3_chapel_vestibule.tscn",
	&"CH3_NAVE_ENTRY": "res://chapters/chapter_03_chapel_of_thirteen_echoes/scenes/rooms/ch3_nave_entry.tscn",
	&"CH3_CHOIR_GALLERY": "res://chapters/chapter_03_chapel_of_thirteen_echoes/scenes/rooms/ch3_choir_gallery.tscn",
	&"CH3_BOSS_CHECKPOINT": "res://chapters/chapter_03_chapel_of_thirteen_echoes/scenes/rooms/ch3_boss_checkpoint.tscn",
	&"CH3_BOSS_ANTE": "res://chapters/chapter_03_chapel_of_thirteen_echoes/scenes/rooms/ch3_boss_ante_room.tscn",
	&"CH3_BOSS": "res://chapters/chapter_03_chapel_of_thirteen_echoes/scenes/rooms/ch3_boss_sanctum_room.tscn",
	&"CH3_POST_BOSS": "res://chapters/chapter_03_chapel_of_thirteen_echoes/scenes/rooms/ch3_post_boss_room.tscn",
	&"CH3_UNDERKEEP_DESCENT": "res://chapters/chapter_03_chapel_of_thirteen_echoes/scenes/rooms/ch3_underkeep_room.tscn",
}

@export_node_path("Node2D") var room_host_path: NodePath = NodePath("../RoomHost")
@export_node_path("Player") var player_path: NodePath = NodePath("../PersistentRuntime/ChapterRuntime/Player")
@export_node_path("PlayerRespawnController") var respawn_controller_path: NodePath = NodePath("../PersistentRuntime/ChapterRuntime/PlayerRespawnController")
@export_node_path("Marker2D") var respawn_anchor_path: NodePath = NodePath("../PersistentRuntime/ActiveRespawn")
@export_node_path("ColorRect") var fade_rect_path: NodePath = NodePath("../PersistentRuntime/ChapterRuntime/HUD/RoomFade")
@export_node_path("Label") var room_name_label_path: NodePath = NodePath("../PersistentRuntime/ChapterRuntime/HUD/RoomName")

@onready var room_host: Node2D = get_node(room_host_path) as Node2D
@onready var player: Player = get_node(player_path) as Player
@onready var respawn_controller: PlayerRespawnController = get_node(respawn_controller_path) as PlayerRespawnController
@onready var respawn_anchor: Marker2D = get_node(respawn_anchor_path) as Marker2D
@onready var fade_rect: ColorRect = get_node(fade_rect_path) as ColorRect
@onready var room_name_label: Label = get_node(room_name_label_path) as Label

var active_room: Chapter03Room
var active_room_id: StringName = &""
var _transitioning: bool = false


func _ready() -> void:
	player.z_index = Chapter03LayerContract.PLAYER
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
	if active_room != null:
		active_room.process_mode = Node.PROCESS_MODE_DISABLED
	fade_rect.visible = true
	fade_rect.modulate.a = 0.0
	var fade_out: Tween = create_tween()
	fade_out.tween_property(fade_rect, "modulate:a", 1.0, 0.22)
	await fade_out.finished
	var did_swap: bool = _swap_room(room_id, spawn_id)
	await get_tree().physics_frame
	var fade_in: Tween = create_tween()
	fade_in.tween_property(fade_rect, "modulate:a", 0.0, 0.22)
	await fade_in.finished
	fade_rect.visible = false
	if not did_swap and active_room != null:
		active_room.process_mode = Node.PROCESS_MODE_INHERIT
	if did_swap and room_id == &"CH3_BOSS":
		await play_active_boss_intro()
	if player.hurtbox != null and not was_invulnerable:
		player.hurtbox.set_invulnerable(false)
	player.set_input_profile(Player.InputProfile.FULL if did_swap else previous_profile)
	_transitioning = false


func _swap_room(room_id: StringName, spawn_id: StringName) -> bool:
	var path: String = ROOM_SCENES.get(room_id, "")
	if path.is_empty():
		push_error("Unknown Chapter III room: %s" % room_id)
		return false
	var packed: PackedScene = ResourceLoader.load(path, "PackedScene") as PackedScene
	if packed == null:
		push_error("Unable to load Chapter III room: %s" % path)
		return false
	var new_room: Chapter03Room = packed.instantiate() as Chapter03Room
	if new_room == null:
		push_error("Chapter III room root must be Chapter03Room: %s" % path)
		return false
	if active_room != null:
		active_room.queue_free()
	active_room = new_room
	active_room_id = room_id
	room_host.add_child(active_room)
	active_room.transition_requested.connect(request_room_change)
	active_room.checkpoint_requested.connect(_on_checkpoint_requested)
	var spawn: Marker2D = active_room.get_spawn(spawn_id)
	if spawn == null:
		push_error("Chapter III room has no valid spawn: %s / %s" % [room_id, spawn_id])
		return false
	player.global_position = spawn.global_position
	player.velocity = Vector2.ZERO
	respawn_anchor.global_position = spawn.global_position
	respawn_controller.set_spawn_point(respawn_anchor)
	if player.player_camera != null:
		player.player_camera.limit_left = 0
		player.player_camera.limit_right = active_room.room_size.x
		player.player_camera.limit_top = 0
		player.player_camera.limit_bottom = active_room.room_size.y
		player.player_camera.reset_smoothing()
	room_name_label.text = active_room.bilingual_name
	room_changed.emit(room_id, active_room)
	return true


func play_active_boss_intro() -> void:
	if active_room_id != &"CH3_BOSS" or active_room == null:
		return
	var sanctum: Chapter03BossSanctum = active_room.find_child(
		"BossSanctum", true, false
	) as Chapter03BossSanctum
	if sanctum == null or sanctum.is_intro_complete():
		return
	sanctum.play_intro_environment(player)
	await sanctum.intro_environment_finished


func _on_checkpoint_requested(_checkpoint_id: StringName, spawn_marker: Marker2D) -> void:
	if spawn_marker == null:
		return
	respawn_anchor.global_position = spawn_marker.global_position
	respawn_controller.set_spawn_point(respawn_anchor)
	var session: ChapterSessionState = get_node_or_null("/root/ChapterSession") as ChapterSessionState
	if session != null:
		session.set_story_flag(&"chapter_03_boss_checkpoint_activated")
