extends SceneTree

const ROOT: String = "res://chapters/chapter_03_chapel_of_thirteen_echoes/assets/bosses/thirteenth_pontiff_edran"
const REQUIRED_CONCEPTS: Array[String] = [
	"concept_art/edran_phase_01_front_concept.png",
	"concept_art/edran_phase_01_side_concept.png",
	"concept_art/edran_phase_01_back_concept.png",
	"concept_art/edran_phase_01_silhouette.png",
	"concept_art/edran_crown_design.png",
	"concept_art/edran_vestment_design.png",
	"concept_art/pontifical_hollow_bell_crozier_design.png",
	"concept_art/thurible_of_absolution_design.png",
	"concept_art/edran_phase_01_attack_pose_sheet.png",
]
const REQUIRED_ANIMATIONS: Dictionary[StringName, int] = {
	&"prayer_idle": 4,
	&"scripture_writing": 5,
	&"intro_back_facing": 4,
	&"intro_turn": 5,
	&"dialogue_idle": 4,
	&"phase_01_idle": 4,
	&"slow_walk": 6,
	&"turn": 4,
	&"pontifical_sweep_windup": 5,
	&"pontifical_sweep_active": 2,
	&"pontifical_sweep_recovery": 5,
	&"crozier_thrust_windup": 4,
	&"crozier_thrust_active": 2,
	&"crozier_thrust_recovery": 4,
	&"censer_procession_windup": 5,
	&"censer_procession_active": 2,
	&"censer_procession_recovery": 5,
	&"litany_cast": 6,
	&"summon_start": 5,
	&"summon_loop": 4,
	&"summon_success": 4,
	&"summon_interrupt": 4,
	&"thirteenfold_sentence": 8,
	&"light_hit": 2,
	&"hurt": 3,
	&"stagger": 4,
	&"phase_transition_start": 4,
}


func _initialize() -> void:
	var failures: Array[String] = []
	for relative_path: String in REQUIRED_CONCEPTS:
		var full_path: String = "%s/%s" % [ROOT, relative_path]
		if not ResourceLoader.exists(full_path):
			failures.append("missing concept: %s" % full_path)

	var sprite_frames_path: String = "%s/animations/edran_phase_01_sprite_frames.tres" % ROOT
	var sprite_frames: SpriteFrames = load(sprite_frames_path) as SpriteFrames
	if sprite_frames == null:
		failures.append("missing SpriteFrames: %s" % sprite_frames_path)
	else:
		for animation_name: StringName in REQUIRED_ANIMATIONS:
			if not sprite_frames.has_animation(animation_name):
				failures.append("missing animation: %s" % animation_name)
				continue
			var expected_count: int = REQUIRED_ANIMATIONS[animation_name]
			var actual_count: int = sprite_frames.get_frame_count(animation_name)
			if actual_count != expected_count:
				failures.append("%s frames expected=%d actual=%d" % [animation_name, expected_count, actual_count])
			for frame_index: int in range(actual_count):
				var texture: Texture2D = sprite_frames.get_frame_texture(animation_name, frame_index)
				if texture == null or texture.get_width() != 96 or texture.get_height() != 96:
					failures.append("%s[%d] must be 96x96" % [animation_name, frame_index])

	if failures.is_empty():
		print("EDRAN_B1_ASSETS | PASS concepts=%d animations=%d" % [REQUIRED_CONCEPTS.size(), REQUIRED_ANIMATIONS.size()])
		quit(0)
		return
	for failure: String in failures:
		push_error(failure)
	print("EDRAN_B1_ASSETS | FAIL count=%d" % failures.size())
	quit(1)
