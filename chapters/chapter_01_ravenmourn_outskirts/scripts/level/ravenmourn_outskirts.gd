class_name RavenmournOutskirtsLevel
extends Node2D

## Applies the shared debug chapter-start contract to the authored Chapter I level.
## Formal Opening -> Catacomb -> Chapter I flow is unchanged when Chapter I is
## not the selected debug target.

const DEFAULT_SPAWN_ID: StringName = &"dark_forest_tutorial_spawn"
const SPAWN_PATHS: Dictionary[StringName, NodePath] = {
	&"dark_forest_tutorial_spawn": NodePath("World/DarkForestTutorialSpawn"),
	&"after_tutorial": NodePath("World/Checkpoints/AfterTutorial/SpawnMarker"),
	&"after_forest": NodePath("World/Checkpoints/AfterForest/SpawnMarker"),
	&"after_outskirts": NodePath("World/Checkpoints/AfterOutskirts/SpawnMarker"),
	&"boss_checkpoint": NodePath("World/CastleEntranceArea/BossCheckpoint"),
}

@onready var player: Player = $World/Player as Player
@onready var respawn_controller: PlayerRespawnController = (
	$PlayerRespawnController as PlayerRespawnController
)


func _ready() -> void:
	call_deferred("_apply_debug_start_profile")


func get_spawn_marker(spawn_id: StringName) -> Marker2D:
	var marker_path: NodePath = SPAWN_PATHS.get(spawn_id, NodePath()) as NodePath
	if marker_path.is_empty():
		return null
	return get_node_or_null(marker_path) as Marker2D


func _apply_debug_start_profile() -> void:
	var config: DebugRunConfigState = get_node_or_null("/root/DebugRunConfig") as DebugRunConfigState
	if config == null or config.debug_start_chapter_id != ChapterRegistry.CHAPTER_01_RAVENMOURN_OUTSKIRTS:
		return
	var spawn_id: StringName = config.debug_start_spawn_id
	var marker: Marker2D = get_spawn_marker(spawn_id)
	if marker == null:
		push_warning("Unknown Chapter I spawn '%s'; using chapter start" % spawn_id)
		spawn_id = DEFAULT_SPAWN_ID
		marker = get_spawn_marker(spawn_id)
	if marker == null:
		push_error("RavenmournOutskirts requires DarkForestTutorialSpawn")
		return
	if config.debug_reset_chapter_state_on_run:
		_reset_disposable_debug_state(config)
	player.global_position = marker.global_position
	player.velocity = Vector2.ZERO
	respawn_controller.set_spawn_point(marker)
	if player.player_camera != null:
		player.player_camera.reset_smoothing()


func _reset_disposable_debug_state(config: DebugRunConfigState) -> void:
	var session: ChapterSessionState = get_node_or_null("/root/ChapterSession") as ChapterSessionState
	var wallet: CurrencyWallet = get_node_or_null("/root/CurrencyManager") as CurrencyWallet
	var equipment: PlayerEquipmentManager = get_node_or_null("/root/EquipmentManager") as PlayerEquipmentManager
	if session != null:
		session.reset_revival_state()
		session.mark_opening_completed()
		session.mark_revival_completed()
		session.mark_daggers_recovered()
		session.mark_catacomb_exited()
	if wallet != null:
		wallet.reset_for_new_run()
		if config.debug_use_test_currency:
			wallet.add_coins(config.debug_test_currency)
	if equipment != null:
		equipment.reset_for_new_run()
		equipment.acquire_and_equip(&"veilbound_daggers")
	if config.debug_start_full_health:
		player.health_component.reset_to_full()
	player.stamina_component.reset_to_full()
