extends SceneTree

const ROOT: String = "res://chapters/chapter_02_silent_court"
const OUTPUT: String = "res://docs/qa/chapter_02_character_replication/chapter_02_replication_roster.png"
const SAMPLES: Array[Dictionary] = [
	{"role": "hollow_retainer", "paths": ["idle/idle_01.png", "stab_active/stab_active_01.png", "death/death_04.png"]},
	{"role": "court_halberdier", "paths": ["idle/idle_01.png", "long_thrust_active/long_thrust_active_01.png", "death/death_04.png"]},
	{"role": "mourning_armor", "paths": ["idle/idle_01.png", "overhead_active/overhead_active_01.png", "death_collapse/death_collapse_04.png"]},
	{"role": "blood_candle_acolyte", "paths": ["idle/idle_01.png", "projectile_cast_active/projectile_cast_active_01.png", "death/death_04.png"]},
	{"role": "hanging_stalker", "paths": ["hang/hang_01.png", "drop_attack/drop_attack_02.png", "death_fall/death_fall_03.png"]},
	{"role": "hollow_duchess", "boss": true, "paths": ["phase_01/idle/idle_01.png", "phase_02_unmasked/phase_02_idle/phase_02_idle_01.png", "phase_02_unmasked/final_waltz_crossing/final_waltz_crossing_05.png"]},
]
const BG: Color = Color("0a0710")
const PANEL: Color = Color("18101d")
const BORDER: Color = Color("6d566c")


func _initialize() -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUTPUT.get_base_dir()))
	var board: Image = Image.create(1536, 768, false, Image.FORMAT_RGBA8)
	board.fill(BG)
	var failures: int = 0
	for index: int in range(SAMPLES.size()):
		var entry: Dictionary = SAMPLES[index]
		var role: String = entry["role"] as String
		var base: String = ROOT + ("/assets/boss/hollow_duchess/" if bool(entry.get("boss", false)) else "/assets/enemies/%s/sprites/" % role)
		var rect: Rect2i = Rect2i(18 + (index % 3) * 506, 18 + (index / 3) * 375, 488, 357)
		board.fill_rect(rect, BORDER)
		board.fill_rect(Rect2i(rect.position + Vector2i(3, 3), rect.size - Vector2i(6, 6)), PANEL)
		var paths: Array = entry["paths"] as Array
		for pose: int in range(paths.size()):
			var source: Image = Image.load_from_file(ProjectSettings.globalize_path(base + (paths[pose] as String)))
			if source == null or source.is_empty():
				failures += 1
				continue
			_blit_fit(board, source, Rect2i(rect.position + Vector2i(8 + pose * 156, 12), Vector2i(148, 333)))
	var error: Error = board.save_png(ProjectSettings.globalize_path(OUTPUT))
	if error != OK:
		failures += 1
	print("CH2 CHARACTER REPLICATION EVIDENCE | %s" % ("PASS" if failures == 0 else "FAIL %d" % failures))
	quit(0 if failures == 0 else 1)


func _blit_fit(target: Image, source: Image, rect: Rect2i) -> void:
	var copy: Image = source.duplicate()
	var scale_factor: float = minf(float(rect.size.x) / float(copy.get_width()), float(rect.size.y) / float(copy.get_height()))
	var size: Vector2i = Vector2i(maxi(1, roundi(copy.get_width() * scale_factor)), maxi(1, roundi(copy.get_height() * scale_factor)))
	copy.resize(size.x, size.y, Image.INTERPOLATE_NEAREST)
	target.blend_rect(copy, Rect2i(Vector2i.ZERO, size), rect.position + (rect.size - size) / 2)
