extends SceneTree

const ASSET_ROOT: String = "res://chapters/chapter_04_drowned_underkeep/assets"
const QA_ROOT: String = "res://docs/qa/chapter_04_scene_production/s2"
const BOARD_SIZE: Vector2i = Vector2i(1600, 900)
const BG: Color = Color("080d15")
const PANEL: Color = Color("111a24")
const GRID: Color = Color("202b38")
const LINE: Color = Color("566475")
const WATER: Color = Color("123744")

var _failures: int = 0


func _init() -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(QA_ROOT))
	_save(_build_core_board(), "s2_core_architecture_contact_sheet.png")
	_save(_build_route_board(), "s2_route_props_contact_sheet.png")
	_save(_build_dynamic_board(), "s2_dynamic_water_fx_contact_sheet.png")
	_save(_build_boss_board(), "s2_boss_memory_contact_sheet.png")
	_save(_build_readability_board(), "s2_actor_readability_mockup.png")
	if _failures == 0:
		print("CH4 S2 ENVIRONMENT QA BOARDS | PASS | boards=5")
	else:
		push_error("CH4 S2 ENVIRONMENT QA BOARDS | FAIL | failures=%d" % _failures)
	quit(_failures)


func _board() -> Image:
	var image: Image = Image.create(BOARD_SIZE.x, BOARD_SIZE.y, false, Image.FORMAT_RGBA8)
	image.fill(BG)
	for x: int in range(0, BOARD_SIZE.x, 64):
		image.fill_rect(Rect2i(x, 0, 1, BOARD_SIZE.y), GRID)
	for y: int in range(0, BOARD_SIZE.y, 64):
		image.fill_rect(Rect2i(0, y, BOARD_SIZE.x, 1), GRID)
	return image


func _panel(image: Image, rect: Rect2i) -> void:
	image.fill_rect(rect, PANEL)
	image.fill_rect(Rect2i(rect.position.x, rect.position.y, rect.size.x, 4), LINE)
	image.fill_rect(Rect2i(rect.position.x, rect.end.y - 4, rect.size.x, 4), Color("151a22"))


func _stamp(target: Image, path: String, position: Vector2i, scale: int = 1) -> void:
	var source: Image = Image.load_from_file(ProjectSettings.globalize_path(path))
	if source == null or source.is_empty():
		_failures += 1
		push_error("Missing QA source: %s" % path)
		return
	if scale > 1:
		source.resize(source.get_width() * scale, source.get_height() * scale, Image.INTERPOLATE_NEAREST)
	target.blend_rect(source, source.get_used_rect(), position)


func _stamp_asset(target: Image, relative_path: String, position: Vector2i, scale: int = 1) -> void:
	_stamp(target, ASSET_ROOT + "/" + relative_path, position, scale)


func _stamp_asset_half(target: Image, relative_path: String, position: Vector2i) -> void:
	var path: String = ASSET_ROOT + "/" + relative_path
	var source: Image = Image.load_from_file(ProjectSettings.globalize_path(path))
	if source == null or source.is_empty():
		_failures += 1
		push_error("Missing QA source: %s" % path)
		return
	source.resize(source.get_width() / 2, source.get_height() / 2, Image.INTERPOLATE_NEAREST)
	target.blend_rect(source, source.get_used_rect(), position)


func _save(image: Image, file_name: String) -> void:
	var path: String = QA_ROOT + "/" + file_name
	var error: Error = image.save_png(ProjectSettings.globalize_path(path))
	if error != OK:
		_failures += 1
		push_error("Failed QA board %s: %s" % [path, error_string(error)])


func _build_core_board() -> Image:
	var board: Image = _board()
	_panel(board, Rect2i(32, 32, 760, 380))
	_panel(board, Rect2i(808, 32, 760, 380))
	_panel(board, Rect2i(32, 432, 1536, 436))
	for index: int in range(3):
		_stamp_asset(board, "environment/walls/wet_prison_brick_%02d.png" % (index + 1), Vector2i(48 + index * 240, 60))
	for index: int in range(2):
		_stamp_asset(board, "environment/walls/eroded_chapel_limestone_%02d.png" % (index + 1), Vector2i(824 + index * 352, 60))
	_stamp_asset(board, "environment/walls/thick_pointed_prison_arch_128.png", Vector2i(48, 452))
	_stamp_asset(board, "environment/walls/thick_pointed_prison_arch_176.png", Vector2i(320, 452))
	_stamp_asset(board, "environment/walls/thick_pointed_prison_arch_224.png", Vector2i(592, 452))
	_stamp_asset(board, "environment/flooded_cells/thick_cell_front_intact.png", Vector2i(880, 530), 2)
	_stamp_asset(board, "environment/flooded_cells/thick_cell_front_bent.png", Vector2i(1144, 530), 2)
	_stamp_asset(board, "doors/cell_doors/cell_door_open.png", Vector2i(1408, 536), 2)
	return board


func _build_route_board() -> Image:
	var board: Image = _board()
	_panel(board, Rect2i(32, 32, 1536, 272))
	_panel(board, Rect2i(32, 324, 1536, 256))
	_panel(board, Rect2i(32, 600, 1536, 268))
	var platform_x: int = 48
	for width: int in [96, 128, 160]:
		_stamp_asset(board, "environment/platforms/maintenance_stone_ledge_%03d.png" % width, Vector2i(platform_x, 96), 2)
		platform_x += width * 2 + 40
	_stamp_asset(board, "environment/platforms/wide_prison_dais_224.png", Vector2i(920, 88), 2)
	_stamp_asset(board, "environment/platforms/execution_platform_256.png", Vector2i(48, 366), 2)
	_stamp_asset(board, "environment/cistern/reservoir_regulator_corrupted.png", Vector2i(600, 324))
	_stamp_asset(board, "props/drainage/ambush_drain_telegraph.png", Vector2i(900, 376), 2)
	_stamp_asset(board, "props/drainage/ambush_drain_open.png", Vector2i(1120, 376), 2)
	_stamp_asset(board, "environment/floodgate/gothic_waterwheel_01.png", Vector2i(1320, 324))
	for index: int in range(6):
		_stamp_asset(board, "props/records/record_prop_%02d.png" % (index + 1), Vector2i(56 + index * 200, 660), 2)
	_stamp_asset(board, "props/torture_tools/workshop_prop_01.png", Vector2i(1272, 650), 2)
	return board


func _build_dynamic_board() -> Image:
	var board: Image = _board()
	_panel(board, Rect2i(32, 32, 1536, 180))
	_panel(board, Rect2i(32, 232, 1536, 200))
	_panel(board, Rect2i(32, 452, 1536, 200))
	_panel(board, Rect2i(32, 672, 1536, 196))
	for frame: int in range(4):
		_stamp_asset(board, "fx/water/rear_water_body_%02d.png" % (frame + 1), Vector2i(48 + frame * 376, 76))
	for frame: int in range(5):
		_stamp_asset(board, "fx/ripples/step_%02d.png" % (frame + 1), Vector2i(64 + frame * 288, 294), 3)
		_stamp_asset(board, "fx/ripples/dash_%02d.png" % (frame + 1), Vector2i(48 + frame * 304, 484), 2)
	for frame: int in range(4):
		_stamp_asset(board, "fx/soul_cage/post_boss_release_%02d.png" % (frame + 1), Vector2i(64 + frame * 220, 700), 2)
		_stamp_asset_half(board, "environment/floodgate/gothic_waterwheel_%02d.png" % (frame + 1), Vector2i(960 + frame * 144, 704))
	return board


func _build_boss_board() -> Image:
	var board: Image = _board()
	_panel(board, Rect2i(32, 32, 760, 380))
	_panel(board, Rect2i(808, 32, 760, 380))
	_panel(board, Rect2i(32, 432, 1536, 436))
	_stamp_asset(board, "environment/boss_area/drowned_gaol_core_backdrop.png", Vector2i(48, 52))
	_stamp_asset(board, "environment/boss_area/chained_prison_crown.png", Vector2i(808, 64))
	_stamp_asset(board, "doors/boss_gate/soul_lock_outer_frame.png", Vector2i(1088, 64))
	_stamp_asset(board, "doors/boss_gate/soul_lock_panel_01.png", Vector2i(1344, 84))
	_stamp_asset(board, "environment/memory_transition/broken_soul_reservoir.png", Vector2i(48, 470))
	_stamp_asset(board, "environment/memory_transition/ruined_drowned_corridor_01.png", Vector2i(592, 490))
	_stamp_asset(board, "environment/memory_transition/reflected_royal_corridor_01.png", Vector2i(864, 618), 2)
	_stamp_asset(board, "environment/memory_transition/memory_water_01.png", Vector2i(1392, 602))
	return board


func _build_readability_board() -> Image:
	var board: Image = _board()
	_panel(board, Rect2i(32, 32, 1536, 836))
	for x: int in range(48, 1552, 256):
		_stamp_asset(board, "environment/walls/wet_prison_brick_01.png", Vector2i(x, 48))
		_stamp_asset(board, "environment/walls/wet_prison_brick_02.png", Vector2i(x, 304))
	for x: int in range(48, 1552, 256):
		_stamp_asset(board, "environment/floors/wet_flagstone_strip_01.png", Vector2i(x, 730))
		_stamp_asset(board, "fx/water/rear_water_body_01.png", Vector2i(x, 666))
		_stamp_asset(board, "fx/water/front_lip_01.png", Vector2i(x, 718))
	_stamp_asset(board, "environment/platforms/maintenance_stone_ledge_160.png", Vector2i(910, 500), 2)
	_stamp(board, "res://assets/sprites/player/assassin/idle/idle_01.png", Vector2i(250, 634), 2)
	_stamp(board, "res://chapters/chapter_04_drowned_underkeep/assets/enemies/drowned_gaoler/sprites/idle/idle_01.png", Vector2i(500, 570))
	_stamp(board, "res://chapters/chapter_04_drowned_underkeep/assets/enemies/mire_harpooner/sprites/idle/idle_01.png", Vector2i(1030, 402))
	_stamp(board, "res://chapters/chapter_04_drowned_underkeep/assets/enemies/underkeep_executioner/sprites/idle/idle_01.png", Vector2i(1270, 538))
	return board
