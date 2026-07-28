extends SceneTree

## Stage 3 contract for the Prologue Candle Warden art and acting system.

const WARDEN_SCENE: PackedScene = preload("res://scenes/npcs/candle_warden.tscn")
const CATACOMB_SCENE: PackedScene = preload("res://scenes/levels/veilbound_catacomb.tscn")
const WARDEN_FRAMES: SpriteFrames = preload(
	"res://chapters/prologue_veilbound_catacomb/assets/npcs/candle_warden/candle_warden_sprite_frames.tres"
)
const FLAME_FRAMES: SpriteFrames = preload(
	"res://chapters/prologue_veilbound_catacomb/assets/npcs/candle_warden/candle_warden_soul_flame_sprite_frames.tres"
)
const PLAYER_FRAMES: SpriteFrames = preload("res://resources/player/player_sprite_frames.tres")
const CONCEPT_ROOT: String = "res://chapters/prologue_veilbound_catacomb/assets/npcs/candle_warden/concept_art"

var _failures: Array[String] = []


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	_test_concept_delivery()
	_test_runtime_frames()
	_test_visual_scale()
	await _test_scene_structure_and_states()
	await _test_formal_prologue_integration()
	# Let scene-local revival timers retire before SceneTree teardown.
	await create_timer(2.6).timeout
	_finish()


func _test_concept_delivery() -> void:
	for file_name: String in [
		"candle_warden_front_concept.png",
		"candle_warden_side_concept.png",
		"candle_warden_back_concept.png",
		"candle_warden_silhouette.png",
		"candle_warden_mask_design.png",
		"candle_warden_lantern_design.png",
		"candle_warden_key_design.png",
		"candle_warden_gesture_sheet.png",
		"candle_warden_scale_with_player.png",
		"candle_warden_scene_composition.png",
	]:
		var path: String = CONCEPT_ROOT.path_join(file_name)
		_expect(FileAccess.file_exists(path), "Missing concept delivery: %s" % path)
		if FileAccess.file_exists(path):
			_expect(FileAccess.get_file_as_bytes(path).size() > 10000, "Concept crop is unexpectedly small: %s" % path)


func _test_runtime_frames() -> void:
	var expected: Dictionary[StringName, int] = {
		&"seated": 2,
		&"rising": 5,
		&"idle": 4,
		&"lantern_idle": 6,
		&"look_at_player": 3,
		&"talk": 4,
		&"talk_emphasis": 4,
		&"gesture_point": 4,
		&"gesture_warn": 4,
		&"offer_key": 4,
		&"open_door": 5,
		&"slow_walk": 6,
		&"raise_lantern": 4,
		&"turn_away": 4,
		&"return_to_shadow": 6,
	}
	_expect(WARDEN_FRAMES.get_animation_names().size() == expected.size(), "Unexpected Candle Warden animation count")
	for animation_name: StringName in expected:
		_expect(WARDEN_FRAMES.has_animation(animation_name), "Missing animation %s" % animation_name)
		if not WARDEN_FRAMES.has_animation(animation_name):
			continue
		_expect(
			WARDEN_FRAMES.get_frame_count(animation_name) == expected[animation_name],
			"Wrong frame count for %s" % animation_name,
		)
		for frame_index: int in range(WARDEN_FRAMES.get_frame_count(animation_name)):
			var texture: Texture2D = WARDEN_FRAMES.get_frame_texture(animation_name, frame_index)
			_expect(texture != null and texture.get_size() == Vector2(80, 80), "Invalid 80x80 frame in %s" % animation_name)
	_expect(FLAME_FRAMES.has_animation(&"soul_flame"), "Missing soul flame animation")
	_expect(FLAME_FRAMES.get_frame_count(&"soul_flame") == 6, "Soul flame is not six frames")
	_expect(FLAME_FRAMES.get_animation_loop(&"soul_flame"), "Soul flame does not loop")


func _test_visual_scale() -> void:
	var warden_height: int = _opaque_height(WARDEN_FRAMES.get_frame_texture(&"idle", 0))
	var player_height: int = _opaque_height(PLAYER_FRAMES.get_frame_texture(&"idle", 0))
	var ratio: float = float(warden_height) / float(maxi(1, player_height))
	_expect(warden_height > 0 and player_height > 0, "Could not measure visual height")
	_expect(ratio >= 1.05 and ratio <= 1.20, "Warden/Player visual height ratio %.3f is outside 1.05-1.20" % ratio)


func _test_scene_structure_and_states() -> void:
	var warden: CandleWarden = WARDEN_SCENE.instantiate() as CandleWarden
	root.add_child(warden)
	await process_frame
	_expect(warden != null, "Candle Warden scene did not instantiate")
	if warden == null:
		return
	_expect(warden.has_node("VisualRoot/Body"), "Missing formal body AnimatedSprite2D")
	_expect(warden.has_node("VisualRoot/Lantern/SoulFlame"), "Missing independent soul flame layer")
	_expect(warden.has_node("VisualRoot/Lantern/SoulLight"), "Missing lantern PointLight2D")
	_expect(warden.has_node("VisualRoot/Lantern/SoulMotes"), "Missing restrained soul motes")
	_expect(warden.body.texture_filter == CanvasItem.TEXTURE_FILTER_NEAREST, "Body does not use nearest filtering")
	warden.set_presentation_state(CandleWarden.PresentationState.GESTURE_WARN)
	_expect(warden.get_current_animation() == &"gesture_warn", "Warn state did not select its animation")
	warden.facing_left = false
	_expect(warden.body.flip_h, "Facing did not use horizontal flip")
	warden.pulse_soul_flame(1.2, 0.05)
	await create_timer(0.08).timeout
	warden.queue_free()
	await process_frame


func _test_formal_prologue_integration() -> void:
	_expect(
		ProjectSettings.get_setting("application/run/main_scene", "") == "res://scenes/bootstrap/main_bootstrap.tscn",
		"F5 authority is not MainBootstrap",
	)
	var catacomb: VeilboundCatacombController = CATACOMB_SCENE.instantiate() as VeilboundCatacombController
	root.add_child(catacomb)
	current_scene = catacomb
	for _frame: int in range(4):
		await process_frame
	_expect(catacomb.get_node_or_null("World/CandleWarden") is CandleWarden, "Formal Prologue does not instance the new Warden")
	var wardens: Array[Node] = catacomb.find_children("*", "CandleWarden", true, false)
	_expect(wardens.size() == 1, "Formal Prologue must contain exactly one Candle Warden")
	_expect(catacomb.dialogue_zh.get_line_count() == 27, "Chinese Warden dialogue text count changed")
	_expect(catacomb.dialogue_en.get_line_count() == 27, "English Warden dialogue text count changed")
	var cues: Array[StringName] = catacomb.dialogue_zh.cues
	for required_cue: StringName in [
		&"warden_contemplate",
		&"warden_key_emphasis",
		&"warden_raise_lantern",
		&"warden_warn",
		&"warden_point",
		&"warden_fourteenth",
		&"warden_talk_emphasis",
	]:
		_expect(cues.has(required_cue), "Dialogue choreography is missing %s" % required_cue)
	_expect(catacomb.player_camera != null, "Prologue camera handoff has no Player Camera2D")
	catacomb.skip_revival_for_test()
	_expect(catacomb.candle_warden.visible, "Completed Prologue does not retain the Warden")
	_expect(catacomb.candle_warden.get_current_animation() == &"lantern_idle", "Completed Prologue does not settle to lantern idle")
	catacomb.queue_free()
	current_scene = null
	await process_frame


func _opaque_height(texture: Texture2D) -> int:
	if texture == null:
		return 0
	var image: Image = texture.get_image()
	if image == null or image.is_empty():
		return 0
	return image.get_used_rect().size.y


func _expect(condition: bool, message: String) -> void:
	if not condition:
		_failures.append(message)


func _finish() -> void:
	if _failures.is_empty():
		print("CANDLE_WARDEN_STAGE_3_TEST: PASS (10 concepts, 65 body frames, lantern FX, acting cues, formal Prologue)")
		quit(0)
		return
	for failure: String in _failures:
		push_error(failure)
	print("CANDLE_WARDEN_STAGE_3_TEST: FAIL (%d issues)" % _failures.size())
	quit(1)
