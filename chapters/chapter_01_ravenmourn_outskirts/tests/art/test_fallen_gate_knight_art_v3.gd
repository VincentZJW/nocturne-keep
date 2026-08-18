extends SceneTree

## Focused, deterministic art/runtime-reference contract for the Chapter I Boss.

const LEVEL: PackedScene = preload(
	"res://chapters/chapter_01_ravenmourn_outskirts/scenes/level/ravenmourn_outskirts.tscn"
)
const ROOT: String = "res://chapters/chapter_01_ravenmourn_outskirts/assets/boss/fallen_gate_knight"
const SPRITE_FRAMES_PATH: String = (
	"res://chapters/chapter_01_ravenmourn_outskirts/resources/boss/fallen_gate_knight_sprite_frames.tres"
)
const EXPECTED_ANIMATIONS: Dictionary = {
	&"charge_thrust": 5, &"combo_slash_1": 5, &"combo_slash_2": 5,
	&"death": 7, &"heavy_overhead": 6, &"hurt_shielded": 3,
	&"hurt_unshielded": 3, &"idle_shielded": 4, &"idle_unshielded": 4,
	&"jump_smash": 6, &"phase_transition": 5, &"shield_bash": 5,
	&"shield_block": 4, &"shield_break": 5, &"shockwave_strike": 10,
	&"shockwave_strike_shielded": 10,
	&"sword_slash": 5, &"turn_shielded": 3, &"turn_unshielded": 3,
	&"walk_shielded": 6, &"walk_unshielded": 6,
	&"dormant": 4, &"intro": 6, &"approach_shielded": 6,
	&"shield_hit": 3, &"shield_bash_windup": 3, &"shield_bash_active": 2,
	&"shield_bash_recovery": 3, &"sword_slash_windup": 3,
	&"sword_slash_active": 2, &"sword_slash_recovery": 3,
	&"thrust_windup": 3, &"thrust_active": 2, &"thrust_recovery": 3,
	&"heavy_overhead_windup": 3, &"heavy_overhead_active": 2,
	&"heavy_overhead_recovery": 3, &"light_hit": 2, &"hurt": 3,
	&"death_start": 3, &"combo_slash": 6, &"stagger": 4,
}
const CONCEPT_FILES: Array[String] = [
	"fallen_gate_knight_phase_01_concept.png",
	"fallen_gate_knight_phase_02_concept.png",
	"fallen_gate_knight_phase_comparison.png",
	"fallen_gate_knight_shield_design.png",
	"fallen_gate_knight_shield_damage_states.png",
	"fallen_gate_knight_greatsword_design.png",
	"fallen_gate_knight_attack_pose_sheet.png",
]

var _failures: Array[String] = []


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	_test_concepts()
	_test_sprite_frames()
	_test_gatewarden_greatsword()
	_test_shield_states()
	_test_main_reference()
	if _failures.is_empty():
		print("FALLEN_GATE_KNIGHT_ART_V3_TEST: PASS animations=42 frames=179 concepts=7 shield_states=4 gate_wave=12 main=true")
		quit(0)
		return
	for failure: String in _failures:
		push_error("FALLEN_GATE_KNIGHT_ART_V3_TEST: %s" % failure)
	quit(1)


func _test_concepts() -> void:
	for file_name: String in CONCEPT_FILES:
		var path: String = ROOT + "/concept_art/" + file_name
		_expect(FileAccess.file_exists(path), "Missing concept deliverable: %s" % file_name)
		var image: Image = Image.load_from_file(ProjectSettings.globalize_path(path))
		_expect(not image.is_empty(), "Unreadable concept deliverable: %s" % file_name)
		_expect(image.get_width() >= 320 and image.get_height() >= 480, "Concept too small: %s" % file_name)


func _test_sprite_frames() -> void:
	var frames: SpriteFrames = load(SPRITE_FRAMES_PATH) as SpriteFrames
	_expect(frames != null, "SpriteFrames resource cannot load")
	if frames == null:
		return
	_expect(frames.get_animation_names().size() == EXPECTED_ANIMATIONS.size(), "SpriteFrames animation count is not 42")
	var total: int = 0
	for animation_variant: Variant in EXPECTED_ANIMATIONS.keys():
		var animation: StringName = animation_variant as StringName
		var expected_count: int = int(EXPECTED_ANIMATIONS[animation])
		_expect(frames.has_animation(animation), "Missing animation: %s" % animation)
		if not frames.has_animation(animation):
			continue
		_expect(frames.get_frame_count(animation) == expected_count, "Frame count mismatch: %s" % animation)
		total += frames.get_frame_count(animation)
		for frame_index: int in range(frames.get_frame_count(animation)):
			var texture: Texture2D = frames.get_frame_texture(animation, frame_index)
			_expect(texture != null, "Null frame: %s[%d]" % [animation, frame_index])
			if texture != null:
				_expect(texture.get_size() == Vector2(128, 96), "Frame is not 128x96: %s[%d]" % [animation, frame_index])
	_expect(total == 179, "Total frame count is not 179")
	var resource_text: String = FileAccess.get_file_as_string(SPRITE_FRAMES_PATH)
	_expect(not resource_text.contains("reference/deprecated"), "Runtime SpriteFrames references archived art")
	for effect_index: int in range(12):
		var effect_path: String = ROOT + "/effects/gate_severance_wave_%02d.png" % (effect_index + 1)
		_expect(FileAccess.file_exists(effect_path), "Missing Gate Severance VFX frame %d" % (effect_index + 1))
		var effect: Image = Image.load_from_file(ProjectSettings.globalize_path(effect_path))
		_expect(effect.get_size() == Vector2i(96, 112), "Gate Severance VFX frame has wrong canvas")


func _test_shield_states() -> void:
	var hashes: Dictionary[String, bool] = {}
	for state: String in ["intact", "damaged", "critical", "broken"]:
		var path: String = ROOT + "/effects/shield_%s_overlay.png" % state
		_expect(FileAccess.file_exists(path), "Missing shield state: %s" % state)
		var image: Image = Image.load_from_file(ProjectSettings.globalize_path(path))
		_expect(not image.is_empty(), "Unreadable shield state: %s" % state)
		if not image.is_empty():
			_expect(image.get_size() == Vector2i(96, 96), "Shield state is not 96x96: %s" % state)
			hashes[str(hash(image.get_data()))] = true
	_expect(hashes.size() == 4, "Shield stages are not visually unique")
	for frame_index: int in range(5):
		var effect_path: String = ROOT + "/effects/shield_break_fx_%02d.png" % (frame_index + 1)
		_expect(FileAccess.file_exists(effect_path), "Missing shield-break FX frame %d" % (frame_index + 1))


func _test_gatewarden_greatsword() -> void:
	var samples: Dictionary[String, int] = {
		"idle_shielded/idle_shielded_01.png": 108,
		"idle_unshielded/idle_unshielded_01.png": 108,
		"sword_slash/sword_slash_03.png": 124,
		"charge_thrust/charge_thrust_04.png": 124,
		"heavy_overhead/heavy_overhead_05.png": 122,
		"death/death_06.png": 122,
	}
	for relative_path: String in samples:
		var path: String = ROOT + "/sprites/" + relative_path
		var image: Image = Image.load_from_file(ProjectSettings.globalize_path(path))
		_expect(not image.is_empty(), "Unreadable sword QA frame: %s" % relative_path)
		if image.is_empty():
			continue
		var used_rect: Rect2i = image.get_used_rect()
		_expect(used_rect.end.x - 1 >= samples[relative_path], "Sword remains too short in %s" % relative_path)
		_expect(not _edge_has_alpha(image, image.get_width() - 1), "Sword clips the right edge in %s" % relative_path)
	var concept: Image = Image.load_from_file(
		ProjectSettings.globalize_path(ROOT + "/concept_art/fallen_gate_knight_greatsword_design.png")
	)
	_expect(concept.get_width() >= 1280 and concept.get_height() >= 900, "Gatewarden Greatsword concept is not production sized")


func _edge_has_alpha(image: Image, x: int) -> bool:
	for y: int in range(image.get_height()):
		if image.get_pixel(x, y).a > 0.01:
			return true
	return false


func _test_main_reference() -> void:
	var main: Node2D = LEVEL.instantiate() as Node2D
	get_root().add_child(main)
	var boss: FallenGateKnight = main.get_node_or_null(
		"World/CastleEntranceArea/FallenGateKnight"
	) as FallenGateKnight
	_expect(boss != null, "Main does not contain the saved Fallen Gate Knight instance")
	if boss != null:
		_expect(boss.scene_file_path.ends_with("/scenes/boss/fallen_gate_knight.tscn"), "Main uses an unexpected Boss PackedScene")
		_expect(boss.animated_sprite.sprite_frames.resource_path == SPRITE_FRAMES_PATH, "Main Boss does not use the v3 SpriteFrames resource")
		_expect(boss.config.max_health == 180 and boss.config.boss_shield_max_health == 100, "Art task changed Boss Body/Shield values")
	main.queue_free()


func _expect(condition: bool, message: String) -> void:
	if not condition:
		_failures.append(message)
