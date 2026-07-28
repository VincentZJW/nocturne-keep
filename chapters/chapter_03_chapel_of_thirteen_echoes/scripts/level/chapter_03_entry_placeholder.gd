class_name Chapter03EntryPlaceholder
extends Node2D

const DEFAULT_SPAWN_ID: StringName = &"chapter_03_start"
const FLAG_CHAPTER_03_STARTED: StringName = &"chapter_03_started"

@onready var player: Player = $GameplayWorld/ChapterRuntime/Player as Player
@onready var respawn_controller: PlayerRespawnController = (
	$GameplayWorld/ChapterRuntime/PlayerRespawnController as PlayerRespawnController
)
@onready var player_spawn: Marker2D = $SpawnPoints/Chapter03PlayerSpawn as Marker2D
@onready var bellchain_penitent: BellchainPenitent = (
	$GameplayWorld/Phase2AEncounter/Enemies/BellchainPenitent as BellchainPenitent
)
@onready var specialists: Array[Chapter03SpecialistEnemy] = [
	$GameplayWorld/Phase2BEncounter/Enemies/CenserExecutioner as Chapter03SpecialistEnemy,
	$GameplayWorld/Phase2CDEEncounter/Enemies/SilentChorister as Chapter03SpecialistEnemy,
	$GameplayWorld/Phase2CDEEncounter/Enemies/StainedGlassSeraph as Chapter03SpecialistEnemy,
	$GameplayWorld/Phase2CDEEncounter/Enemies/ConfessionalWraith as Chapter03SpecialistEnemy,
	$GameplayWorld/Phase2FEncounter/Enemies/ThirteenthScribe as Chapter03SpecialistEnemy,
]
@onready var title_trigger: Area2D = $NarrativeTriggers/ChapterTitleTrigger as Area2D
@onready var title_card: Control = $GameplayWorld/ChapterRuntime/HUD/ChapterTitleCard as Control

var _title_shown: bool = false


func _ready() -> void:
	title_trigger.body_entered.connect(_on_title_body_entered)
	title_card.visible = false
	var room_name: Label = get_node_or_null(
		"GameplayWorld/ChapterRuntime/HUD/RoomName"
	) as Label
	if room_name != null:
		room_name.text = "CHAPTER III · CHAPEL VESTIBULE / 十三响礼拜堂前庭"
	var session: ChapterSessionState = get_node_or_null("/root/ChapterSession") as ChapterSessionState
	var selected_spawn_id: StringName = DEFAULT_SPAWN_ID
	if session != null:
		selected_spawn_id = session.consume_pending_spawn(DEFAULT_SPAWN_ID)
		session.current_chapter_id = ChapterRegistry.CHAPTER_03_CHAPEL_OF_THIRTEEN_ECHOES
		session.set_story_flag(FLAG_CHAPTER_03_STARTED)
	var selected_spawn: Marker2D = get_node_or_null(
		"SpawnPoints/%s" % selected_spawn_id
	) as Marker2D
	if selected_spawn == null:
		selected_spawn = player_spawn
	player.global_position = selected_spawn.global_position
	player.velocity = Vector2.ZERO
	bellchain_penitent.configure_movement_bounds(1040.0, 1540.0)
	specialists[0].configure_movement_bounds(1600.0, 2080.0)
	for index: int in range(1, 4):
		specialists[index].configure_movement_bounds(1940.0, 2860.0)
	specialists[4].configure_movement_bounds(3160.0, 3820.0)
	respawn_controller.set_spawn_point($Checkpoints/Chapter03CP01 as Marker2D)
	if player.player_camera != null:
		player.player_camera.limit_left = 0
		player.player_camera.limit_right = 4200
		player.player_camera.limit_top = 0
		player.player_camera.limit_bottom = 720
		player.player_camera.reset_smoothing()


func _on_title_body_entered(body: Node2D) -> void:
	if body != player or _title_shown:
		return
	_title_shown = true
	title_card.visible = true
	title_card.modulate.a = 0.0
	var tween: Tween = create_tween()
	tween.tween_property(title_card, "modulate:a", 1.0, 0.35)
	tween.tween_interval(2.0)
	tween.tween_property(title_card, "modulate:a", 0.0, 0.45)
	tween.tween_callback(func() -> void: title_card.visible = false)
