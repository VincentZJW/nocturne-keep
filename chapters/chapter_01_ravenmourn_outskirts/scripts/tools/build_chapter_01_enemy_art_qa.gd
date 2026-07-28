extends SceneTree

## Deterministic Chapter I art review boards: concept, archived v1, formal v2.

const ROOT: String = "res://chapters/chapter_01_ravenmourn_outskirts/assets"
const OUTPUT: String = "res://docs/qa/chapter_01_enemy_art_rework"
const BACKGROUND: Color = Color("0b0e15")
const CONCEPT_PANEL: Color = Color("201820")
const SPRITE_PANEL: Color = Color("132229")
const ROLES: Array[String] = [
	"castle_guard", "cursed_shield_guard", "decayed_spearman",
	"fallen_crossbowman", "gargoyle_sentinel", "fallen_gate_knight",
]
const IDLES: Dictionary = {
	"castle_guard": "idle", "cursed_shield_guard": "idle",
	"decayed_spearman": "idle", "fallen_crossbowman": "idle",
	"gargoyle_sentinel": "hover", "fallen_gate_knight": "idle_shielded",
}
const ACTIONS: Dictionary = {
	"castle_guard": ["attack", 2], "cursed_shield_guard": ["guard_break", 1],
	"decayed_spearman": ["attack_thrust", 3], "fallen_crossbowman": ["shoot", 1],
	"gargoyle_sentinel": ["dive", 2], "fallen_gate_knight": ["heavy_overhead", 3],
}


func _initialize() -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUTPUT))
	var overview: Image = _board(1536, 768, BACKGROUND)
	for index: int in range(ROLES.size()):
		var role: String = ROLES[index]
		if not _write_role_board(role, index + 1):
			quit(1)
			return
		var idle_name: String = String(IDLES[role])
		var idle: Image = _load("%s/sprites/%s/%s_01.png" % [_role_root(role), idle_name, idle_name])
		var action_data: Array = ACTIONS[role]
		var action_name: String = String(action_data[0])
		var action: Image = _load("%s/sprites/%s/%s_%02d.png" % [_role_root(role), action_name, action_name, int(action_data[1]) + 1])
		var scale_factor: int = 2 if role == "fallen_gate_knight" else 3
		var cell_x: int = (index % 3) * 512
		var cell_y: int = (index / 3) * 384
		_blit_scaled(overview, idle, Vector2i(cell_x + 48, cell_y + 64), scale_factor)
		_blit_scaled(overview, action, Vector2i(cell_x + 256, cell_y + 64), scale_factor)
	if overview.save_png(ProjectSettings.globalize_path(OUTPUT + "/13_chapter_01_formal_roster_overview.png")) != OK:
		push_error("Cannot save Chapter I overview")
		quit(1)
		return
	print("CH1_ENEMY_ART_QA_BOARDS: PASS roles=6 boards=13 old_new=6")
	quit(0)


func _write_role_board(role: String, number: int) -> bool:
	var root_path: String = _role_root(role)
	var concept: Image = _load("%s/concept_art/%s_concept.png" % [root_path, role])
	var idle_name: String = String(IDLES[role])
	var old_idle: Image = _load("%s/reference/deprecated_v1/sprites/%s/%s_01.png" % [root_path, idle_name, idle_name])
	var new_idle: Image = _load("%s/sprites/%s/%s_01.png" % [root_path, idle_name, idle_name])
	var action_reference: Image = _load("%s/concept_art/%s_action_reference.png" % [root_path, role])
	if [concept, old_idle, new_idle, action_reference].has(null):
		push_error("Missing Chapter I QA source for %s" % role)
		return false
	var board: Image = _board(1280, 720, BACKGROUND)
	board.fill_rect(Rect2i(0, 0, 640, 720), CONCEPT_PANEL)
	board.fill_rect(Rect2i(640, 0, 640, 720), SPRITE_PANEL)
	var concept_scaled: Image = concept.duplicate()
	concept_scaled.resize(600, 400, Image.INTERPOLATE_LANCZOS)
	board.blit_rect(concept_scaled, Rect2i(0, 0, 600, 400), Vector2i(20, 20))
	var old_scale: int = 3 if role == "fallen_gate_knight" else 4
	var new_scale: int = 4 if role == "fallen_gate_knight" else 6
	_blit_scaled(board, old_idle, Vector2i(70, 448), old_scale)
	_blit_scaled(board, new_idle, Vector2i(640, 400), new_scale)
	_blit_scaled(board, action_reference, Vector2i(896, 456), 3 if role != "fallen_gate_knight" else 2)
	var path: String = "%s/%02d_%s_concept_old_new.png" % [OUTPUT, number, role]
	if board.save_png(ProjectSettings.globalize_path(path)) != OK:
		push_error("Cannot save %s" % path)
		return false
	var preview: Image = _board(1024, 512, BACKGROUND)
	_blit_scaled(preview, new_idle, Vector2i(64, 64), new_scale)
	_blit_scaled(preview, action_reference, Vector2i(512, 96), 3 if role != "fallen_gate_knight" else 2)
	path = "%s/%02d_%s_sprite_preview.png" % [OUTPUT, number + 6, role]
	return preview.save_png(ProjectSettings.globalize_path(path)) == OK


func _role_root(role: String) -> String:
	if role == "fallen_gate_knight":
		return ROOT + "/boss/fallen_gate_knight"
	return ROOT + "/enemies/" + role


func _load(path: String) -> Image:
	var image: Image = Image.load_from_file(ProjectSettings.globalize_path(path))
	if image != null and image.get_format() != Image.FORMAT_RGBA8:
		image.convert(Image.FORMAT_RGBA8)
	return image


func _board(width: int, height: int, color: Color) -> Image:
	var image: Image = Image.create(width, height, false, Image.FORMAT_RGBA8)
	image.fill(color)
	return image


func _blit_scaled(target: Image, source: Image, position: Vector2i, scale_factor: int) -> void:
	var scaled: Image = source.duplicate()
	scaled.resize(source.get_width() * scale_factor, source.get_height() * scale_factor, Image.INTERPOLATE_NEAREST)
	target.blit_rect(scaled, Rect2i(0, 0, scaled.get_width(), scaled.get_height()), position)
