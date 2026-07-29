extends SceneTree

const ROOT := "res://chapters/chapter_03_chapel_of_thirteen_echoes"

const VARIANTS: Array[Dictionary] = [
	{
		"source": ROOT + "/assets/environment/boss_sanctum/boss_choir_stalls.png",
		"target": ROOT + "/assets/environment/r3_grid_aligned/boss_choir_stalls_304x112.png",
		"size": Vector2i(304, 112),
	},
	{
		"source": ROOT + "/assets/environment/boss_sanctum/boss_pipe_organ.png",
		"target": ROOT + "/assets/environment/r3_grid_aligned/boss_pipe_organ_472x344.png",
		"size": Vector2i(472, 344),
	},
	{
		"source": ROOT + "/assets/props/boss/bell_saint_left.png",
		"target": ROOT + "/assets/props/r3_grid_aligned/bell_saint_left_120x240.png",
		"size": Vector2i(120, 240),
	},
	{
		"source": ROOT + "/assets/environment/water_transition/rusted_gate.png",
		"target": ROOT + "/assets/environment/r3_grid_aligned/rusted_gate_232x264.png",
		"size": Vector2i(232, 264),
	},
	{
		"source": ROOT + "/assets/environment/water_transition/wet_arch.png",
		"target": ROOT + "/assets/environment/r3_grid_aligned/wet_arch_232x304.png",
		"size": Vector2i(232, 304),
	},
	{
		"source": ROOT + "/assets/environment/water_transition/wet_arch.png",
		"target": ROOT + "/assets/environment/r3_grid_aligned/wet_arch_256x336.png",
		"size": Vector2i(256, 336),
	},
	{
		"source": ROOT + "/assets/environment/water_transition/ossuary_stairs.png",
		"target": ROOT + "/assets/environment/r3_grid_aligned/ossuary_stairs_496x200.png",
		"size": Vector2i(496, 200),
	},
	{
		"source": ROOT + "/assets/environment/water_transition/rusted_gate.png",
		"target": ROOT + "/assets/environment/r3_grid_aligned/rusted_gate_264x296.png",
		"size": Vector2i(264, 296),
	},
]


func _init() -> void:
	DirAccess.make_dir_recursive_absolute(
		ProjectSettings.globalize_path(ROOT + "/assets/environment/r3_grid_aligned")
	)
	DirAccess.make_dir_recursive_absolute(
		ProjectSettings.globalize_path(ROOT + "/assets/props/r3_grid_aligned")
	)
	for variant: Dictionary in VARIANTS:
		var source: String = variant["source"] as String
		var target: String = variant["target"] as String
		var size: Vector2i = variant["size"] as Vector2i
		var image: Image = Image.load_from_file(source)
		assert(image != null and not image.is_empty(), "Unable to load %s" % source)
		image.resize(size.x, size.y, Image.INTERPOLATE_NEAREST)
		var error: Error = image.save_png(target)
		assert(error == OK, "Unable to save %s" % target)
	print("CH3_R3_GRID_ASSETS PASS variants=%d integer_grid=true" % VARIANTS.size())
	quit()
