extends SceneTree

const ROOM_PATHS: Array[String] = [
	"res://chapters/chapter_04_drowned_underkeep/scenes/rooms/ch4_00_drowned_threshold.tscn",
	"res://chapters/chapter_04_drowned_underkeep/scenes/rooms/ch4_01_flooded_intake.tscn",
	"res://chapters/chapter_04_drowned_underkeep/scenes/rooms/ch4_02_rusted_cellblock.tscn",
	"res://chapters/chapter_04_drowned_underkeep/scenes/rooms/ch4_03_broken_chainway.tscn",
	"res://chapters/chapter_04_drowned_underkeep/scenes/rooms/ch4_04_harpoon_watch_gallery.tscn",
	"res://chapters/chapter_04_drowned_underkeep/scenes/rooms/ch4_05_cistern_of_the_changed.tscn",
	"res://chapters/chapter_04_drowned_underkeep/scenes/rooms/ch4_06_dry_gaolers_cell.tscn",
	"res://chapters/chapter_04_drowned_underkeep/scenes/rooms/ch4_07_leech_sluice.tscn",
	"res://chapters/chapter_04_drowned_underkeep/scenes/rooms/ch4_08_gaolers_workshop.tscn",
	"res://chapters/chapter_04_drowned_underkeep/scenes/rooms/ch4_09_soul_cage_registry.tscn",
	"res://chapters/chapter_04_drowned_underkeep/scenes/rooms/ch4_10_floodgate_engine_hall.tscn",
	"res://chapters/chapter_04_drowned_underkeep/scenes/rooms/ch4_11_final_lock_approach.tscn",
	"res://chapters/chapter_04_drowned_underkeep/scenes/rooms/ch4_12_last_gaol_checkpoint.tscn",
	"res://chapters/chapter_04_drowned_underkeep/scenes/rooms/ch4_13_soul_lock_antechamber.tscn",
	"res://chapters/chapter_04_drowned_underkeep/scenes/rooms/ch4_14_core_of_drowned_gaol.tscn",
	"res://chapters/chapter_04_drowned_underkeep/scenes/rooms/ch4_15_broken_soul_reservoir.tscn",
	"res://chapters/chapter_04_drowned_underkeep/scenes/rooms/ch4_16_hall_of_drowned_memories.tscn",
]


func _initialize() -> void:
	var total_load_usec: int = 0
	var total_instantiate_usec: int = 0
	var peak_load_usec: int = 0
	var peak_instantiate_usec: int = 0
	for path: String in ROOM_PATHS:
		var load_started: int = Time.get_ticks_usec()
		var packed: PackedScene = ResourceLoader.load(path, "PackedScene", ResourceLoader.CACHE_MODE_IGNORE) as PackedScene
		var load_usec: int = Time.get_ticks_usec() - load_started
		if packed == null:
			push_error("CH4 S5 SYNC BASELINE: unable to load %s" % path)
			quit(1)
			return
		var instantiate_started: int = Time.get_ticks_usec()
		var room: Node = packed.instantiate()
		var instantiate_usec: int = Time.get_ticks_usec() - instantiate_started
		room.free()
		total_load_usec += load_usec
		total_instantiate_usec += instantiate_usec
		peak_load_usec = maxi(peak_load_usec, load_usec)
		peak_instantiate_usec = maxi(peak_instantiate_usec, instantiate_usec)
	print("CH4 S5 SYNC BASELINE | PASS rooms=17 load_total_us=%d load_peak_us=%d instantiate_total_us=%d instantiate_peak_us=%d" % [
		total_load_usec, peak_load_usec, total_instantiate_usec, peak_instantiate_usec,
	])
	quit(0)
