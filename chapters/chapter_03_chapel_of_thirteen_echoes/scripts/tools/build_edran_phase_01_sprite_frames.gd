extends SceneTree

const Art: GDScript = preload("res://chapters/chapter_03_chapel_of_thirteen_echoes/scripts/tools/generate_edran_phase_01_art.gd")
const OUTPUT: String = Art.ROOT + "/animations/edran_phase_01_sprite_frames.tres"


func _initialize() -> void:
	var frames: SpriteFrames = SpriteFrames.new()
	if frames.has_animation(&"default"):
		frames.remove_animation(&"default")
	var total: int = 0
	for animation_variant: Variant in Art.ANIMATIONS.keys():
		var animation: StringName = animation_variant as StringName
		var count: int = int(Art.ANIMATIONS[animation])
		frames.add_animation(animation)
		frames.set_animation_loop(animation, animation in [&"prayer_idle", &"phase_01_idle", &"dialogue_idle", &"summon_loop"])
		frames.set_animation_speed(animation, _fps(animation))
		for frame: int in range(count):
			var path: String = "%s/%s/%s_%02d.png" % [Art.SPRITES_ROOT, animation, animation, frame+1]
			var texture: Texture2D = load(path) as Texture2D
			if texture == null:
				push_error("Missing imported Edran frame: %s" % path)
				quit(1)
				return
			frames.add_frame(animation,texture)
			total+=1
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUTPUT.get_base_dir()))
	if ResourceSaver.save(frames,OUTPUT)!=OK:
		push_error("Could not save Edran SpriteFrames")
		quit(1)
		return
	print("EDRAN_PHASE_01_SPRITE_FRAMES | PASS animations=%d frames=%d" % [Art.ANIMATIONS.size(),total])
	quit(0)


func _fps(animation: StringName) -> float:
	if animation in [&"prayer_idle",&"phase_01_idle",&"dialogue_idle",&"summon_loop"]:
		return 5.0
	if animation==&"slow_walk":
		return 7.0
	if animation in [&"pontifical_sweep_active",&"crozier_thrust_active",&"censer_procession_active"]:
		return 14.0
	if animation in [&"summon_interrupt",&"light_hit",&"hurt",&"stagger"]:
		return 10.0
	return 8.0
