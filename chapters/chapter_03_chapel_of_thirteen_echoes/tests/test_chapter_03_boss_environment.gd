extends SceneTree

const ROOT_PATH: String = "res://chapters/chapter_03_chapel_of_thirteen_echoes"
const MAIN_LEVEL: String = ROOT_PATH + "/scenes/level/chapter_03_entry_placeholder.tscn"
const AREA_SCENES: Array[String] = [
	ROOT_PATH + "/scenes/areas/ch3_boss_antechamber.tscn",
	ROOT_PATH + "/scenes/areas/ch3_boss_gate_transition.tscn",
	ROOT_PATH + "/scenes/areas/ch3_boss_sanctum.tscn",
	ROOT_PATH + "/scenes/areas/ch3_post_boss_reliquary.tscn",
	ROOT_PATH + "/scenes/areas/ch3_underkeep_descent.tscn",
]
const REQUIRED_ASSETS: Dictionary[String, Vector2i] = {
	ROOT_PATH + "/assets/environment/boss_antechamber/boss_antechamber_backdrop.png": Vector2i(1664, 720),
	ROOT_PATH + "/assets/environment/boss_sanctum/boss_apse.png": Vector2i(3200, 720),
	ROOT_PATH + "/assets/environment/boss_sanctum/boss_stained_glass.png": Vector2i(640, 440),
	ROOT_PATH + "/assets/doors/boss/gate_of_thirteenth_echo_closed.png": Vector2i(384, 512),
	ROOT_PATH + "/assets/doors/boss/gate_of_thirteenth_echo_lit.png": Vector2i(384, 512),
	ROOT_PATH + "/assets/doors/boss/gate_of_thirteenth_echo_open.png": Vector2i(384, 512),
	ROOT_PATH + "/assets/environment/boss_reliquary/reliquary_backdrop.png": Vector2i(1280, 720),
	ROOT_PATH + "/assets/environment/water_transition/underkeep_descent_backdrop.png": Vector2i(2304, 720),
}
const REQUIRED_AUDIO: Array[String] = [
	ROOT_PATH + "/assets/audio/boss/gate_bell_sequence.wav",
	ROOT_PATH + "/assets/audio/boss/gate_wax_break.wav",
	ROOT_PATH + "/assets/audio/boss/gate_stone_open.wav",
	ROOT_PATH + "/assets/audio/boss/underkeep_water_drip.wav",
]
const SPAWNS: Array[StringName] = [
	&"CH3_BOSS_ANTE", &"CH3_BOSS", &"CH3_POST_BOSS", &"CH3_UNDERKEEP_DESCENT",
]

var _failures: int = 0


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	_expect(ProjectSettings.get_setting("application/run/main_scene") == "res://scenes/bootstrap/main_bootstrap.tscn", "F5 authority changed")
	_expect(int(ProjectSettings.get_setting("rendering/textures/canvas_textures/default_texture_filter")) == 0, "nearest-neighbour filter is not active")
	for path: String in REQUIRED_ASSETS:
		_expect(FileAccess.file_exists(path), "missing asset %s" % path)
		var image: Image = Image.load_from_file(ProjectSettings.globalize_path(path))
		_expect(image != null and image.get_size() == REQUIRED_ASSETS[path], "invalid asset dimensions %s" % path)
	for scene_path: String in AREA_SCENES:
		var packed: PackedScene = load(scene_path) as PackedScene
		_expect(packed != null, "missing area scene %s" % scene_path)
		if packed != null:
			var instance: Node = packed.instantiate()
			_expect(instance != null, "cannot instantiate %s" % scene_path)
			instance.free()
	for audio_path: String in REQUIRED_AUDIO:
		_expect(FileAccess.file_exists(audio_path), "missing original audio %s" % audio_path)
		_expect(ResourceLoader.exists(audio_path, "AudioStream"), "audio is not importable %s" % audio_path)
	var profile: ChapterStartProfile = load(ROOT_PATH + "/resources/chapter/chapter_03_start_profile.tres") as ChapterStartProfile
	_expect(profile != null, "missing Chapter III start profile")
	if profile != null:
		for spawn_id: StringName in SPAWNS:
			_expect(profile.available_spawn_ids.has(spawn_id), "missing debug spawn %s" % spawn_id)
	var level_packed: PackedScene = load(MAIN_LEVEL) as PackedScene
	_expect(level_packed != null, "missing formal Chapter III Main target")
	if level_packed != null:
		var level: Node = level_packed.instantiate()
		_expect(level.get_node_or_null("GameplayWorld/Chapter03BossAreas/BossAntechamber") is Chapter03BossAntechamber, "Main missing Boss antechamber")
		_expect(level.get_node_or_null("GameplayWorld/Chapter03BossAreas/BossGateTransition") is Chapter03BossGate, "Main missing Boss gate")
		_expect(level.get_node_or_null("GameplayWorld/Chapter03BossAreas/BossSanctum") is Chapter03BossSanctum, "Main missing Boss sanctum")
		_expect(level.get_node_or_null("GameplayWorld/Chapter03BossAreas/PostBossReliquary") is Chapter03PostBossReliquary, "Main missing post-Boss reliquary")
		_expect(level.get_node_or_null("GameplayWorld/Chapter03BossAreas/UnderkeepDescent") is Chapter03UnderkeepDescent, "Main missing Underkeep descent")
		_expect(level.get_node_or_null("GameplayWorld/Chapter03BossAreas/BossSanctum/BossIntegrationAnchor") is Marker2D, "typed Edran integration anchor missing")
		_expect(level.get_node_or_null("GameplayWorld/Chapter03BossAreas/BossSanctum/BossExitBlocker") is StaticBody2D, "Boss death gate missing")
		level.free()
	_expect(not ResourceLoader.exists("res://chapters/chapter_04_drowned_underkeep/scenes/level/drowned_underkeep.tscn", "PackedScene"), "Chapter IV unexpectedly exists; update transition QA")
	if _failures > 0:
		push_error("CH3_BOSS_ENV_TEST: FAIL count=%d" % _failures)
		quit(1)
		return
	print("CH3_BOSS_ENV_TEST: PASS visual_assets=%d audio_assets=%d scenes=5 spawns=4 main=true boss_hook=partial chapter4=planned" % [REQUIRED_ASSETS.size(), REQUIRED_AUDIO.size()])
	quit(0)


func _expect(condition: bool, message: String) -> void:
	if condition:
		return
	_failures += 1
	push_error("CH3_BOSS_ENV_TEST: %s" % message)
