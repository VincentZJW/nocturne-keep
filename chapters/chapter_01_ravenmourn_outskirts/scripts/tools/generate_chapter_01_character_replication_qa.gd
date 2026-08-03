extends SceneTree

const ROOT: String = "res://chapters/chapter_01_ravenmourn_outskirts"
const OUTPUT: String = "res://docs/qa/chapter_01_character_replication/chapter_01_replication_roster.png"
const ROLES: Array[String] = ["castle_guard", "cursed_shield_guard", "decayed_spearman", "fallen_crossbowman", "gargoyle_sentinel", "fallen_gate_knight"]
const BG: Color = Color("080d14")
const PANEL: Color = Color("111b26")
const BORDER: Color = Color("52616b")


func _initialize() -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUTPUT.get_base_dir()))
	var board: Image = Image.create(1536, 768, false, Image.FORMAT_RGBA8)
	board.fill(BG)
	var failures: int = 0
	for index: int in range(ROLES.size()):
		var role: String = ROLES[index]
		var base: String = ROOT + ("/assets/boss/" if role == "fallen_gate_knight" else "/assets/enemies/") + role
		var source: Image = Image.load_from_file(ProjectSettings.globalize_path("%s/concept_art/%s_action_reference.png" % [base, role]))
		if source == null or source.is_empty():
			failures += 1
			continue
		var column: int = index % 3
		var row: int = index / 3
		var rect: Rect2i = Rect2i(18 + column * 506, 18 + row * 375, 488, 357)
		board.fill_rect(rect, BORDER)
		board.fill_rect(Rect2i(rect.position + Vector2i(3, 3), rect.size - Vector2i(6, 6)), PANEL)
		_blit_fit(board, source, Rect2i(rect.position + Vector2i(14, 14), rect.size - Vector2i(28, 28)))
	var error: Error = board.save_png(ProjectSettings.globalize_path(OUTPUT))
	if error != OK:
		failures += 1
	print("CH1 CHARACTER REPLICATION EVIDENCE | %s" % ("PASS" if failures == 0 else "FAIL %d" % failures))
	quit(0 if failures == 0 else 1)


func _blit_fit(target: Image, source: Image, rect: Rect2i) -> void:
	var copy: Image = source.duplicate()
	var scale_factor: float = minf(float(rect.size.x) / float(copy.get_width()), float(rect.size.y) / float(copy.get_height()))
	var size: Vector2i = Vector2i(maxi(1, roundi(copy.get_width() * scale_factor)), maxi(1, roundi(copy.get_height() * scale_factor)))
	copy.resize(size.x, size.y, Image.INTERPOLATE_NEAREST)
	target.blend_rect(copy, Rect2i(Vector2i.ZERO, size), rect.position + (rect.size - size) / 2)
