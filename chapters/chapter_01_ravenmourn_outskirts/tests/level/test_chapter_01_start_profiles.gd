extends SceneTree

const LEVEL_PATH: String = (
	"res://chapters/chapter_01_ravenmourn_outskirts/scenes/level/ravenmourn_outskirts.tscn"
)
const EXPECTED_SPAWNS: Dictionary[StringName, NodePath] = {
	&"dark_forest_tutorial_spawn": NodePath("World/DarkForestTutorialSpawn"),
	&"after_tutorial": NodePath("World/Checkpoints/AfterTutorial/SpawnMarker"),
	&"after_forest": NodePath("World/Checkpoints/AfterForest/SpawnMarker"),
	&"after_outskirts": NodePath("World/Checkpoints/AfterOutskirts/SpawnMarker"),
	&"boss_checkpoint": NodePath("World/CastleEntranceArea/BossCheckpoint"),
}

var _failures: Array[String] = []


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var config: DebugRunConfigState = root.get_node_or_null("DebugRunConfig") as DebugRunConfigState
	_expect(config != null, "DebugRunConfig is missing")
	if config == null:
		_finish()
		return
	config.debug_chapter_start_enabled = true
	config.debug_start_chapter_id = ChapterRegistry.CHAPTER_01_RAVENMOURN_OUTSKIRTS
	for spawn_id: StringName in EXPECTED_SPAWNS:
		config.debug_start_spawn_id = spawn_id
		var packed: PackedScene = load(LEVEL_PATH) as PackedScene
		var level: RavenmournOutskirtsLevel = packed.instantiate() as RavenmournOutskirtsLevel
		root.add_child(level)
		await process_frame
		await process_frame
		var marker: Marker2D = level.get_node(EXPECTED_SPAWNS[spawn_id]) as Marker2D
		var player: Player = level.get_node("World/Player") as Player
		var respawn: PlayerRespawnController = level.get_node("PlayerRespawnController") as PlayerRespawnController
		_expect(player.global_position.distance_to(marker.global_position) < 1.0, "Spawn failed: %s" % spawn_id)
		_expect(respawn.spawn_point == marker, "Respawn marker failed: %s" % spawn_id)
		level.queue_free()
		await process_frame
	config.reset_to_defaults()
	var transition_script: Script = load(
		"res://chapters/chapter_01_ravenmourn_outskirts/scripts/transitions/castle_entrance_transition.gd"
	) as Script
	var transition: CastleEntranceTransition = transition_script.new() as CastleEntranceTransition
	_expect(
		transition.target_scene_path == ChapterRegistry.CHAPTER_02_SCENE_PATH,
		"Castle entrance does not target Chapter II"
	)
	transition.free()
	_finish()


func _expect(condition: bool, message: String) -> void:
	if not condition:
		_failures.append(message)


func _finish() -> void:
	if _failures.is_empty():
		print("CHAPTER_01_START_PROFILE_TEST: PASS (5 spawns, Chapter II transition)")
		quit(0)
		return
	for failure: String in _failures:
		push_error(failure)
	print("CHAPTER_01_START_PROFILE_TEST: FAIL (%d issues)" % _failures.size())
	quit(1)
