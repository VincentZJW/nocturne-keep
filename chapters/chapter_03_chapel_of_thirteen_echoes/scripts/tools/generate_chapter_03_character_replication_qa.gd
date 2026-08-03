extends SceneTree

const ROOT: String = "res://chapters/chapter_03_chapel_of_thirteen_echoes"
const OUTPUT: String = "res://docs/qa/chapter_03_character_replication/chapter_03_replication_roster.png"
const SAMPLES: Array[Dictionary] = [
	{"role": "bellchain_penitent", "base": "enemies/bellchain_penitent/sprites", "paths": ["idle/idle_01.png", "chain_lash_active/chain_lash_active_01.png"]},
	{"role": "censer_executioner", "base": "enemies/censer_executioner/sprites", "paths": ["idle/idle_01.png", "overhead_crush_active/overhead_crush_active_01.png"]},
	{"role": "silent_chorister", "base": "enemies/silent_chorister/sprites", "paths": ["idle/idle_01.png", "crescent_hymn_active/crescent_hymn_active_01.png"]},
	{"role": "stained_glass_seraph", "base": "enemies/stained_glass_seraph/sprites", "paths": ["idle/idle_01.png", "dive_active/dive_active_01.png"]},
	{"role": "confessional_wraith", "base": "enemies/confessional_wraith/sprites", "paths": ["idle/idle_01.png", "emerging_slash_active/emerging_slash_active_01.png"]},
	{"role": "thirteenth_scribe", "base": "enemies/thirteenth_scribe/sprites", "paths": ["idle/idle_01.png", "thirteenth_seal_active/thirteenth_seal_active_01.png"]},
	{"role": "ossuary_penitent", "base": "boss_summons/ossuary_penitent/sprites", "paths": ["idle/idle_01.png", "claw_active/claw_active_01.png"]},
	{"role": "choir_husk", "base": "boss_summons/choir_husk/sprites", "paths": ["idle/idle_01.png", "shoot/shoot_02.png"]},
	{"role": "thirteenth_pontiff_edran", "base": "bosses/thirteenth_pontiff_edran", "paths": ["phase_01/phase_01_idle/phase_01_idle_01.png", "phase_02/phase_02_idle/phase_02_idle_01.png"]},
]
const BG: Color = Color("080b12")
const PANEL: Color = Color("131821")
const BORDER: Color = Color("66717c")


func _initialize() -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUTPUT.get_base_dir()))
	var board: Image = Image.create(1536, 1152, false, Image.FORMAT_RGBA8)
	board.fill(BG)
	var failures: int = 0
	for index: int in range(SAMPLES.size()):
		var entry: Dictionary = SAMPLES[index]
		var rect: Rect2i = Rect2i(18 + (index % 3) * 506, 18 + (index / 3) * 375, 488, 357)
		board.fill_rect(rect, BORDER)
		board.fill_rect(Rect2i(rect.position + Vector2i(3, 3), rect.size - Vector2i(6, 6)), PANEL)
		var paths: Array = entry["paths"] as Array
		for pose: int in range(paths.size()):
			var path: String = "%s/assets/%s/%s" % [ROOT, entry["base"] as String, paths[pose] as String]
			var source: Image = Image.load_from_file(ProjectSettings.globalize_path(path))
			if source == null or source.is_empty():
				failures += 1
				continue
			_blit_fit(board, source, Rect2i(rect.position + Vector2i(10 + pose * 232, 12), Vector2i(224, 333)))
	var error: Error = board.save_png(ProjectSettings.globalize_path(OUTPUT))
	if error != OK:
		failures += 1
	print("CH3 CHARACTER REPLICATION EVIDENCE | %s" % ("PASS" if failures == 0 else "FAIL %d" % failures))
	quit(0 if failures == 0 else 1)


func _blit_fit(target: Image, source: Image, rect: Rect2i) -> void:
	var copy: Image = source.duplicate()
	var scale_factor: float = minf(float(rect.size.x) / float(copy.get_width()), float(rect.size.y) / float(copy.get_height()))
	var size: Vector2i = Vector2i(maxi(1, roundi(copy.get_width() * scale_factor)), maxi(1, roundi(copy.get_height() * scale_factor)))
	copy.resize(size.x, size.y, Image.INTERPOLATE_NEAREST)
	target.blend_rect(copy, Rect2i(Vector2i.ZERO, size), rect.position + (rect.size - size) / 2)
