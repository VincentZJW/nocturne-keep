extends SceneTree

const ROOT: String = "res://chapters/chapter_02_silent_court/assets/boss/hollow_duchess"
const BOSS_SCENE: String = "res://chapters/chapter_02_silent_court/scenes/boss/hollow_duchess.tscn"
const LEVEL_SCENE: String = "res://chapters/chapter_02_silent_court/scenes/level/silent_court.tscn"
const PHASE_1_FRAMES: String = ROOT + "/phase_01/hollow_duchess_phase_01_sprite_frames.tres"
const PHASE_2_FRAMES: String = ROOT + "/phase_02_unmasked/hollow_duchess_unmasked_sprite_frames.tres"
const TRANSITION_FRAMES: String = ROOT + "/phase_transition/hollow_duchess_transformation_sprite_frames.tres"

const REQUIRED_CONCEPTS: PackedStringArray = [
	"hollow_duchess_phase_01_concept.png",
	"hollow_duchess_phase_02_unmasked_concept.png",
	"hollow_duchess_phase_comparison.png",
	"hollow_duchess_transformation_pose_sheet.png",
	"hollow_duchess_attack_pose_sheet.png",
	"hollow_duchess_rapier_design.png",
	"hollow_duchess_fan_blade_design.png",
	"hollow_duchess_phase_02_weapons.png",
	"hollow_duchess_mask_states.png",
]

const REQUIRED_PHASE_1: Array[StringName] = [
	&"dormant", &"intro_back_facing", &"intro_turn", &"idle", &"elegant_walk",
	&"elegant_approach", &"elegant_retreat", &"turn", &"sidestep", &"backstep",
	&"rapier_thrust_windup", &"rapier_thrust_active", &"rapier_thrust_recovery",
	&"fan_slash_windup", &"fan_slash_active", &"fan_slash_recovery",
	&"backstep_riposte", &"sidestep_cut", &"light_hit", &"stagger", &"hurt",
	&"phase_transition_start", &"death",
]

const REQUIRED_PHASE_2: Array[StringName] = [
	&"phase_02_idle", &"phase_02_walk", &"phase_02_turn", &"phase_02_sidestep",
	&"phase_02_backstep", &"phase_02_rapier_thrust", &"phase_02_fan_slash",
	&"double_waltz_lunge", &"phantom_dancer_sweep", &"final_waltz_crossing",
	&"phase_02_light_hit", &"phase_02_stagger", &"phase_02_hurt", &"death_start",
	&"death_mask_shatter", &"death_collapse", &"death_dissolve",
	&"idle", &"elegant_walk", &"turn", &"double_lunge", &"phantom_dance", &"final_waltz",
]

const REQUIRED_TRANSITION: Array[StringName] = [
	&"freeze_pose", &"candles_out", &"mask_crack", &"mask_break", &"head_distort",
	&"arms_lengthen", &"dress_tear", &"spine_or_back_expand", &"weapon_transform",
	&"phase_02_reveal", &"phase_transition",
]

var _failures: PackedStringArray = []


func _initialize() -> void:
	_check_concepts()
	var phase_1: SpriteFrames = _load_frames(PHASE_1_FRAMES)
	var phase_2: SpriteFrames = _load_frames(PHASE_2_FRAMES)
	var transition: SpriteFrames = _load_frames(TRANSITION_FRAMES)
	_check_animation_set("Phase 1", phase_1, REQUIRED_PHASE_1, 143)
	_check_animation_set("Phase 2", phase_2, REQUIRED_PHASE_2, 180)
	_check_animation_set("Transition", transition, REQUIRED_TRANSITION, 39)
	_check_phase_identity(phase_1, phase_2)
	_check_bindings()
	_check_effects_and_archive()
	if _failures.is_empty():
		print("HOLLOW_DUCHESS_ART_STAGE_2: PASS concepts=9 phase1=143 phase2=180 transition=39 main_binding=1 archive=1")
		quit(0)
		return
	for failure: String in _failures:
		push_error("HOLLOW_DUCHESS_ART_STAGE_2: %s" % failure)
	quit(1)


func _check_concepts() -> void:
	for file_name: String in REQUIRED_CONCEPTS:
		var path: String = "%s/concept_art/%s" % [ROOT, file_name]
		if not FileAccess.file_exists(path):
			_failures.append("missing concept %s" % path)
			continue
		var image: Image = Image.load_from_file(ProjectSettings.globalize_path(path))
		if image.is_empty() or image.get_width() < 256 or image.get_height() < 256:
			_failures.append("concept is empty or undersized: %s" % path)


func _load_frames(path: String) -> SpriteFrames:
	var frames: SpriteFrames = load(path) as SpriteFrames
	if frames == null:
		_failures.append("cannot load SpriteFrames %s" % path)
	return frames


func _check_animation_set(
	label: String,
	frames: SpriteFrames,
	required: Array[StringName],
	expected_total: int
) -> void:
	if frames == null:
		return
	var total: int = 0
	for animation: StringName in frames.get_animation_names():
		total += frames.get_frame_count(animation)
	for animation: StringName in required:
		if not frames.has_animation(animation):
			_failures.append("%s missing animation %s" % [label, animation])
			continue
		if frames.get_frame_count(animation) <= 0:
			_failures.append("%s animation has no frames: %s" % [label, animation])
			continue
		var texture: Texture2D = frames.get_frame_texture(animation, 0)
		if texture == null or texture.get_width() != 96 or texture.get_height() != 96:
			_failures.append("%s animation is not 96x96: %s" % [label, animation])
	if total != expected_total:
		_failures.append("%s expected %d frames, got %d" % [label, expected_total, total])


func _check_phase_identity(phase_1: SpriteFrames, phase_2: SpriteFrames) -> void:
	if phase_1 == null or phase_2 == null:
		return
	var phase_1_texture: Texture2D = phase_1.get_frame_texture(&"idle", 0)
	var phase_2_texture: Texture2D = phase_2.get_frame_texture(&"idle", 0)
	if phase_1_texture == null or phase_2_texture == null:
		return
	var phase_1_image: Image = phase_1_texture.get_image()
	var phase_2_image: Image = phase_2_texture.get_image()
	if phase_1_image.get_data() == phase_2_image.get_data():
		_failures.append("Phase 2 is identical to Phase 1 instead of a redrawn form")
	if phase_1_image.get_used_rect().size.x < 24 or phase_1_image.get_used_rect().size.y < 36:
		_failures.append("Phase 1 silhouette is below authored readability floor")
	if phase_2_image.get_used_rect().size.x < 30 or phase_2_image.get_used_rect().size.y < 40:
		_failures.append("Phase 2 silhouette is below authored readability floor")


func _check_bindings() -> void:
	var boss_text: String = FileAccess.get_file_as_string(BOSS_SCENE)
	for path: String in [PHASE_1_FRAMES, PHASE_2_FRAMES, TRANSITION_FRAMES]:
		if path not in boss_text:
			_failures.append("Boss scene does not bind %s" % path)
	if ROOT + "/animations/hollow_duchess_sprite_frames.tres" in boss_text:
		_failures.append("Boss scene still binds the deprecated Phase 1 SpriteFrames")
	var level_text: String = FileAccess.get_file_as_string(LEVEL_SCENE)
	if BOSS_SCENE not in level_text:
		_failures.append("Chapter II Main level does not instantiate Hollow Duchess scene")
	var packed: PackedScene = load(BOSS_SCENE) as PackedScene
	if packed == null:
		_failures.append("Boss PackedScene cannot load")
		return
	var boss: Node = packed.instantiate()
	var sprite: AnimatedSprite2D = boss.get_node_or_null("VisualRoot/AnimatedSprite2D") as AnimatedSprite2D
	if sprite == null or sprite.sprite_frames != load(PHASE_1_FRAMES):
		_failures.append("Boss runtime sprite does not start with authoritative Phase 1 frames")
	boss.free()


func _check_effects_and_archive() -> void:
	for file_name: String in [
		"phantom_dancer.png", "rapier_glint.png", "mask_shatter_01.png",
		"mask_shatter_02.png", "mask_shatter_03.png", "mask_shatter_04.png", "mask_shatter_05.png",
	]:
		if not FileAccess.file_exists("%s/effects/%s" % [ROOT, file_name]):
			_failures.append("missing effect %s" % file_name)
	if not FileAccess.file_exists(ROOT + "/reference/deprecated_stage1/hollow_duchess_stage1_runtime_art.tar.gz"):
		_failures.append("missing archived Stage 1 runtime art")
