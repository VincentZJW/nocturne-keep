class_name DrownedUnderkeepThreshold
extends Node2D

const DEFAULT_SPAWN_ID: StringName = &"CH4_START"

@onready var player: Player = $ChapterRuntime/Player as Player
@onready var respawn_controller: PlayerRespawnController = (
	$ChapterRuntime/PlayerRespawnController as PlayerRespawnController
)
@onready var room_name: Label = $ChapterRuntime/HUD/RoomName as Label


func _ready() -> void:
	var session: ChapterSessionState = get_node_or_null("/root/ChapterSession") as ChapterSessionState
	var spawn_id: StringName = DEFAULT_SPAWN_ID
	if session != null:
		spawn_id = session.consume_pending_spawn(DEFAULT_SPAWN_ID)
		session.current_chapter_id = ChapterRegistry.CHAPTER_04_DROWNED_UNDERKEEP
	var spawn_point: Marker2D = $SpawnPoints.get_node_or_null(NodePath(String(spawn_id))) as Marker2D
	if spawn_point == null:
		spawn_point = $SpawnPoints/CH4_START as Marker2D
	player.global_position = spawn_point.global_position
	player.velocity = Vector2.ZERO
	player.z_index = 12
	player.z_as_relative = false
	respawn_controller.set_spawn_point(spawn_point)
	room_name.text = "CHAPTER IV · THE DROWNED UNDERKEEP / 沉没下堡"
	if player.player_camera != null:
		player.player_camera.limit_left = 0
		player.player_camera.limit_right = 9280
		player.player_camera.limit_top = 0
		player.player_camera.limit_bottom = 720
		player.player_camera.reset_smoothing()
	if spawn_id == &"CH4_BOSS_PHASE_01" or spawn_id == &"CH4_BOSS_PHASE_02":
		_configure_boss_debug_start.call_deferred(spawn_id)


func _configure_boss_debug_start(spawn_id: StringName) -> void:
	var encounter: EncounterGroup = get_node_or_null(
		"CharacterTrial/OrmundBossEncounter"
	) as EncounterGroup
	var boss: SoulGaolerOrmund = get_node_or_null(
		"CharacterTrial/OrmundBossEncounter/Enemies/SoulGaolerOrmund"
	) as SoulGaolerOrmund
	if encounter == null or boss == null:
		push_error("Chapter IV Boss debug start is missing the Ormund encounter.")
		return
	encounter.activate(player)
	boss.set_target(player)
	if spawn_id != &"CH4_BOSS_PHASE_02":
		return
	boss.health_component.set_current_health(308)
	# The health threshold still owns the transition contract; the debug spawn
	# only skips its presentation delay to open F5 on the requested phase.
	await get_tree().create_timer(0.05).timeout
	if is_instance_valid(boss):
		boss.complete_debug_phase_transition()
