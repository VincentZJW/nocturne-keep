extends SceneTree

const Art: GDScript = preload("res://chapters/chapter_03_chapel_of_thirteen_echoes/scripts/tools/generate_edran_phase_02_art.gd")
const TRANSITION_OUTPUT: String = Art.ROOT + "/animations/edran_phase_transition_sprite_frames.tres"
const PHASE_02_OUTPUT: String = Art.ROOT + "/animations/edran_phase_02_sprite_frames.tres"


func _initialize() -> void:
	var transition_count: int = _build(Art.TRANSITION_ANIMATIONS,Art.TRANSITION_ROOT,TRANSITION_OUTPUT)
	if transition_count < 0:
		quit(1)
		return
	var phase_02_count: int = _build(Art.PHASE_02_ANIMATIONS,Art.PHASE_02_ROOT,PHASE_02_OUTPUT)
	if phase_02_count < 0:
		quit(1)
		return
	print("EDRAN_PHASE_02_SPRITE_FRAMES | PASS transition=%d phase_02=%d" % [transition_count,phase_02_count])
	quit(0)


func _build(animations: Dictionary[StringName,int], root: String, output: String) -> int:
	var frames: SpriteFrames = SpriteFrames.new()
	if frames.has_animation(&"default"):
		frames.remove_animation(&"default")
	var total: int = 0
	for animation: StringName in animations:
		frames.add_animation(animation)
		frames.set_animation_loop(animation,animation in [&"phase_02_idle"])
		frames.set_animation_speed(animation,_fps(animation))
		for index: int in range(animations[animation]):
			var path: String = "%s/%s/%s_%02d.png" % [root,animation,animation,index+1]
			var texture: Texture2D = load(path) as Texture2D
			if texture == null:
				push_error("Missing Edran Phase 2 frame: %s" % path)
				return -1
			frames.add_frame(animation,texture)
			total += 1
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(output.get_base_dir()))
	if ResourceSaver.save(frames,output) != OK:
		push_error("Unable to save Edran SpriteFrames: %s" % output)
		return -1
	return total


func _fps(animation: StringName) -> float:
	if animation == &"phase_02_idle":
		return 5.0
	if animation == &"distorted_walk":
		return 8.0
	if animation.begins_with("death_"):
		return 8.0
	if animation in [&"bell_bound_cleave",&"censer_chain_hit_01",&"censer_chain_hit_02"]:
		return 12.0
	return 9.0
