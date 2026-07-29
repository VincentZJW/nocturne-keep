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
@onready var boss_antechamber: Chapter03BossAntechamber = (
	$GameplayWorld/Chapter03BossAreas/BossAntechamber as Chapter03BossAntechamber
)
@onready var boss_gate: Chapter03BossGate = (
	$GameplayWorld/Chapter03BossAreas/BossGateTransition as Chapter03BossGate
)
@onready var boss_sanctum: Chapter03BossSanctum = (
	$GameplayWorld/Chapter03BossAreas/BossSanctum as Chapter03BossSanctum
)
@onready var post_boss_reliquary: Chapter03PostBossReliquary = (
	$GameplayWorld/Chapter03BossAreas/PostBossReliquary as Chapter03PostBossReliquary
)
@onready var underkeep_descent: Chapter03UnderkeepDescent = (
	$GameplayWorld/Chapter03BossAreas/UnderkeepDescent as Chapter03UnderkeepDescent
)

var _title_shown: bool = false


func _ready() -> void:
	title_trigger.body_entered.connect(_on_title_body_entered)
	boss_antechamber.checkpoint_activated.connect(_on_boss_checkpoint_activated)
	boss_gate.crossing_requested.connect(_on_boss_gate_crossing_requested)
	post_boss_reliquary.reward_collection_requested.connect(_on_reward_collection_requested)
	underkeep_descent.chapter_four_transition_requested.connect(
		_on_chapter_four_transition_requested
	)
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
	_apply_boss_area_debug_state(selected_spawn_id)
	if player.player_camera != null:
		player.player_camera.limit_left = 0
		player.player_camera.limit_right = 12784
		player.player_camera.limit_top = 0
		player.player_camera.limit_bottom = 720
		player.player_camera.reset_smoothing()


func _apply_boss_area_debug_state(selected_spawn_id: StringName) -> void:
	var boss_checkpoint: Marker2D = boss_antechamber.get_node("CP_CH3_BOSS") as Marker2D
	if selected_spawn_id in [
		&"CH3_BOSS_ANTE", &"CH3_BOSS", &"CH3_POST_BOSS", &"CH3_UNDERKEEP_DESCENT"
	]:
		respawn_controller.set_spawn_point(boss_checkpoint)
	else:
		respawn_controller.set_spawn_point($Checkpoints/Chapter03CP01 as Marker2D)
	if selected_spawn_id in [&"CH3_BOSS", &"CH3_POST_BOSS", &"CH3_UNDERKEEP_DESCENT"]:
		boss_gate.open_immediately()
	if selected_spawn_id in [&"CH3_POST_BOSS", &"CH3_UNDERKEEP_DESCENT"]:
		boss_sanctum.skip_intro_to_combat_state()
		boss_sanctum.notify_boss_defeated()
		post_boss_reliquary.reveal_after_boss()
	if selected_spawn_id == &"CH3_UNDERKEEP_DESCENT":
		post_boss_reliquary.notify_reward_collected()
	var room_name: Label = get_node_or_null(
		"GameplayWorld/ChapterRuntime/HUD/RoomName"
	) as Label
	if room_name == null:
		return
	match selected_spawn_id:
		&"CH3_BOSS_ANTE":
			room_name.text = "CHAPTER III · THIRTEEN CONFESSIONS / 十三忏前厅"
		&"CH3_BOSS":
			room_name.text = "CHAPTER III · THIRTEENTH ECHO SANCTUM / 第十三回响圣所"
		&"CH3_POST_BOSS":
			room_name.text = "CHAPTER III · LAST CONFESSION RELIQUARY / 末次忏悔遗物室"
		&"CH3_UNDERKEEP_DESCENT":
			room_name.text = "CHAPTER III · DROWNED SAINTS DESCENT / 溺圣下行道"


func _on_boss_checkpoint_activated(spawn_marker: Marker2D) -> void:
	respawn_controller.set_spawn_point(spawn_marker)


func _on_boss_gate_crossing_requested(crossing_player: Player) -> void:
	var destination: Marker2D = $SpawnPoints/CH3_BOSS as Marker2D
	crossing_player.global_position = destination.global_position
	crossing_player.velocity = Vector2.ZERO
	if crossing_player.player_camera != null:
		crossing_player.player_camera.reset_smoothing()


func _on_reward_collection_requested(_requesting_player: Player) -> void:
	# No authoritative Chapter III Boss reward exists yet. Keep this a visible,
	# typed hand-off rather than inventing inventory state in the environment.
	print("CH3 BOSS REWARD HOOK | waiting for authoritative Edran reward resource")


func _on_chapter_four_transition_requested(_transitioning_player: Player) -> void:
	print("CH3 -> CH4 TRANSITION HOOK | Chapter IV scene is now available")


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
