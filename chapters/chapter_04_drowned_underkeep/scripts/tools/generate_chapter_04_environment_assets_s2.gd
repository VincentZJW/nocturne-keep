extends SceneTree

const ROOT: String = "res://chapters/chapter_04_drowned_underkeep/assets"
const CATALOG_PATH: String = "res://chapters/chapter_04_drowned_underkeep/resources/environment/chapter_04_environment_asset_catalog_s2.json"

const CLEAR: Color = Color(0.0, 0.0, 0.0, 0.0)
const VOID: Color = Color("080d15")
const STONE_DARK: Color = Color("111a24")
const STONE: Color = Color("202b38")
const STONE_MID: Color = Color("354354")
const STONE_LIGHT: Color = Color("566475")
const MORTAR: Color = Color("0c121b")
const IRON_DARK: Color = Color("151a22")
const IRON: Color = Color("303b46")
const IRON_LIGHT: Color = Color("5b6872")
const RUST: Color = Color("754535")
const RUST_LIGHT: Color = Color("a06a4a")
const OAK_DARK: Color = Color("322525")
const OAK: Color = Color("5c3c32")
const GOLD: Color = Color("8d7545")
const GOLD_LIGHT: Color = Color("b49a5b")
const WATER_DARK: Color = Color("071c27")
const WATER: Color = Color("123744")
const WATER_MID: Color = Color("246070")
const WATER_LIGHT: Color = Color("76b5c1")
const SEDIMENT: Color = Color("283e35")
const SEDIMENT_LIGHT: Color = Color("47614b")
const SOUL_DARK: Color = Color("244d5c")
const SOUL: Color = Color("76b5c1")
const SOUL_LIGHT: Color = Color("b7dce1")
const MEMORY: Color = Color("b7c7d2")
const MEMORY_LIGHT: Color = Color("dce6e9")
const BONE: Color = Color("aaa895")
const BONE_LIGHT: Color = Color("d3cfb8")

var _catalog: Array[Dictionary] = []
var _failures: int = 0


func _init() -> void:
	_generate_walls()
	_generate_floors()
	_generate_flooded_cells()
	_generate_platforms_and_catwalks()
	_generate_cistern_and_drainage()
	_generate_floodgate_machinery()
	_generate_narrative_props()
	_generate_soul_cages()
	_generate_doors()
	_generate_boss_and_memory_environment()
	_generate_dynamic_fx()
	_write_catalog()
	if _failures == 0:
		print("CH4 S2 ENVIRONMENT ASSET GENERATION | PASS | files=%d" % _catalog.size())
	else:
		push_error("CH4 S2 ENVIRONMENT ASSET GENERATION | FAIL | failures=%d" % _failures)
	quit(_failures)


func _image(size: Vector2i, color: Color = CLEAR) -> Image:
	var image: Image = Image.create(size.x, size.y, false, Image.FORMAT_RGBA8)
	image.fill(color)
	return image


func _save(image: Image, relative_path: String, asset_id: String, priority: String, role: String) -> void:
	var full_path: String = ROOT + "/" + relative_path
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(full_path.get_base_dir()))
	var error: Error = image.save_png(ProjectSettings.globalize_path(full_path))
	if error != OK:
		_failures += 1
		push_error("Failed to save %s: %s" % [full_path, error_string(error)])
		return
	_catalog.append({
		"id": asset_id,
		"path": full_path,
		"width": image.get_width(),
		"height": image.get_height(),
		"priority": priority,
		"role": role,
		"provenance": "original_godot_image_api"
	})


func _write_catalog() -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(CATALOG_PATH.get_base_dir()))
	var file: FileAccess = FileAccess.open(CATALOG_PATH, FileAccess.WRITE)
	if file == null:
		_failures += 1
		push_error("Unable to write S2 catalog")
		return
	file.store_string(JSON.stringify({
		"chapter": "chapter_04_drowned_underkeep",
		"milestone": "CH4-S2",
		"grid_detail_px": 16,
		"grid_architecture_px": 32,
		"runtime_filter": "nearest",
		"mipmaps": false,
		"asset_count": _catalog.size(),
		"assets": _catalog
	}, "\t"))


func _rect(image: Image, rect: Rect2i, color: Color) -> void:
	image.fill_rect(rect, color)


func _line(image: Image, from: Vector2i, to: Vector2i, color: Color, width: int = 1) -> void:
	var delta: Vector2i = to - from
	var steps: int = maxi(absi(delta.x), absi(delta.y))
	if steps == 0:
		_rect(image, Rect2i(from - Vector2i(width / 2, width / 2), Vector2i(width, width)), color)
		return
	for step: int in range(steps + 1):
		var point: Vector2i = from + Vector2i(
			roundi(float(delta.x) * float(step) / float(steps)),
			roundi(float(delta.y) * float(step) / float(steps))
		)
		_rect(image, Rect2i(point - Vector2i(width / 2, width / 2), Vector2i(width, width)), color)


func _circle(image: Image, center: Vector2i, radius: int, color: Color) -> void:
	for y: int in range(-radius, radius + 1):
		var half_width: int = floori(sqrt(float(radius * radius - y * y)))
		_rect(image, Rect2i(center + Vector2i(-half_width, y), Vector2i(half_width * 2 + 1, 1)), color)


func _ellipse_outline(image: Image, center: Vector2i, radius_x: int, radius_y: int, color: Color, width: int = 1) -> void:
	for x: int in range(-radius_x, radius_x + 1):
		var factor: float = sqrt(maxf(0.0, 1.0 - float(x * x) / float(radius_x * radius_x)))
		var y: int = roundi(float(radius_y) * factor)
		_rect(image, Rect2i(center + Vector2i(x, y) - Vector2i(width / 2, width / 2), Vector2i(width, width)), color)
		_rect(image, Rect2i(center + Vector2i(x, -y) - Vector2i(width / 2, width / 2), Vector2i(width, width)), color)


func _draw_bricks(image: Image, rect: Rect2i, brick_size: Vector2i, base: Color, mortar: Color, variant: int) -> void:
	_rect(image, rect, base)
	var rows: int = ceili(float(rect.size.y) / float(brick_size.y))
	for row: int in range(rows + 1):
		var y: int = rect.position.y + row * brick_size.y
		_rect(image, Rect2i(rect.position.x, y, rect.size.x, 2), mortar)
		var offset: int = 0 if (row + variant) % 2 == 0 else brick_size.x / 2
		for x: int in range(rect.position.x - offset, rect.end.x, brick_size.x):
			_rect(image, Rect2i(x, y - brick_size.y + 2, 2, brick_size.y - 2), mortar)
			if posmod(int(x / brick_size.x) + row + variant, 5) == 0:
				_rect(image, Rect2i(x + 7, y - 8, maxi(8, brick_size.x / 2), 2), STONE_MID)


func _draw_crack(image: Image, origin: Vector2i, depth: int, direction: int, color: Color) -> void:
	var current: Vector2i = origin
	for segment: int in range(depth):
		var next: Vector2i = current + Vector2i(direction * (4 + segment % 3), 5 + segment % 2)
		_line(image, current, next, color, 2)
		if segment == 1:
			_line(image, next, next + Vector2i(-direction * 6, 4), color, 1)
		current = next


func _draw_pointed_arch(image: Image, rect: Rect2i, stone: Color, inner: Color, trim: Color, damage: int = 0) -> void:
	var cx: int = rect.position.x + rect.size.x / 2
	var base_y: int = rect.end.y
	var shoulder_y: int = rect.position.y + rect.size.y / 3
	var pillar_width: int = maxi(10, rect.size.x / 10)
	_rect(image, Rect2i(rect.position.x, shoulder_y, pillar_width, base_y - shoulder_y), stone)
	_rect(image, Rect2i(rect.end.x - pillar_width, shoulder_y, pillar_width, base_y - shoulder_y), stone)
	_line(image, Vector2i(rect.position.x + pillar_width / 2, shoulder_y), Vector2i(cx, rect.position.y), stone, pillar_width)
	_line(image, Vector2i(rect.end.x - pillar_width / 2, shoulder_y), Vector2i(cx, rect.position.y), stone, pillar_width)
	_line(image, Vector2i(rect.position.x + pillar_width + 4, shoulder_y + 3), Vector2i(cx, rect.position.y + pillar_width), trim, 3)
	_line(image, Vector2i(rect.end.x - pillar_width - 4, shoulder_y + 3), Vector2i(cx, rect.position.y + pillar_width), trim, 3)
	_rect(image, Rect2i(rect.position.x + pillar_width, shoulder_y + 5, rect.size.x - pillar_width * 2, base_y - shoulder_y - 5), inner)
	if damage > 0:
		_rect(image, Rect2i(rect.end.x - pillar_width - 4, shoulder_y + 34, pillar_width + 8, 20 + damage * 7), inner)


func _draw_rivets(image: Image, rect: Rect2i, spacing: int, color: Color) -> void:
	for x: int in range(rect.position.x + spacing / 2, rect.end.x, spacing):
		_rect(image, Rect2i(x - 1, rect.position.y, 3, 3), color)
		_rect(image, Rect2i(x - 1, rect.end.y - 3, 3, 3), color)


func _draw_bars(image: Image, rect: Rect2i, count: int, bent_index: int = -1) -> void:
	_rect(image, Rect2i(rect.position.x, rect.position.y, rect.size.x, 6), IRON_LIGHT)
	_rect(image, Rect2i(rect.position.x, rect.end.y - 6, rect.size.x, 6), IRON_DARK)
	var gap: float = float(rect.size.x - 12) / float(maxi(1, count - 1))
	for index: int in range(count):
		var x: int = rect.position.x + 6 + roundi(gap * float(index))
		if index == bent_index:
			_line(image, Vector2i(x, rect.position.y + 4), Vector2i(x - 6, rect.position.y + rect.size.y / 2), RUST, 5)
			_line(image, Vector2i(x - 6, rect.position.y + rect.size.y / 2), Vector2i(x + 3, rect.end.y - 4), RUST, 5)
		else:
			_rect(image, Rect2i(x - 2, rect.position.y + 4, 5, rect.size.y - 8), IRON)
			_rect(image, Rect2i(x - 1, rect.position.y + 7, 1, rect.size.y - 17), IRON_LIGHT)
	for y: int in [rect.position.y + rect.size.y / 3, rect.position.y + rect.size.y * 2 / 3]:
		_rect(image, Rect2i(rect.position.x + 2, y, rect.size.x - 4, 6), RUST)


func _generate_walls() -> void:
	for variant: int in range(3):
		var wet: Image = _image(Vector2i(256, 256), STONE)
		_draw_bricks(wet, Rect2i(0, 0, 256, 256), Vector2i(64, 32), STONE, MORTAR, variant)
		_rect(wet, Rect2i(0, 198 + variant * 4, 256, 58 - variant * 4), Color("182d36"))
		for x: int in range(16 + variant * 9, 256, 66):
			_rect(wet, Rect2i(x, 202, 3, 40 + posmod(x, 17)), Color("315c60"))
		_save(wet, "environment/walls/wet_prison_brick_%02d.png" % (variant + 1), "WALL-01", "P0", "seamless_wet_prison_masonry")
	for variant: int in range(2):
		var chapel: Image = _image(Vector2i(256, 256), Color("343c43"))
		_draw_bricks(chapel, Rect2i(0, 0, 256, 256), Vector2i(80, 48), Color("48535b"), Color("252c33"), variant)
		_circle(chapel, Vector2i(70 + variant * 116, 76), 30, Color("59636a"))
		_circle(chapel, Vector2i(70 + variant * 116, 76), 19, Color("2b343d"))
		_draw_crack(chapel, Vector2i(128, 18 + variant * 23), 6, -1 if variant == 0 else 1, Color("1a222b"))
		_save(chapel, "environment/walls/eroded_chapel_limestone_%02d.png" % (variant + 1), "WALL-02", "P0", "chapel_runoff_masonry")
	for variant: int in range(2):
		var drainage: Image = _image(Vector2i(256, 256), STONE_DARK)
		_draw_bricks(drainage, Rect2i(0, 0, 256, 256), Vector2i(48, 32), Color("26352f"), MORTAR, variant)
		for x: int in range(22 + variant * 21, 256, 74):
			_rect(drainage, Rect2i(x, 0, 14, 256), Color("172a29"))
			_rect(drainage, Rect2i(x + 4, 0, 3, 256), SEDIMENT_LIGHT)
		_save(drainage, "environment/walls/drainage_masonry_%02d.png" % (variant + 1), "WALL-03", "P0", "cistern_and_sluice_masonry")
	for variant: int in range(2):
		var soul_wall: Image = _image(Vector2i(256, 256), STONE_DARK)
		_draw_bricks(soul_wall, Rect2i(0, 0, 256, 256), Vector2i(64, 40), Color("202938"), MORTAR, variant)
		for y: int in range(38, 238, 68):
			_circle(soul_wall, Vector2i(128 + (variant * 2 - 1) * 44, y), 12, IRON)
			_circle(soul_wall, Vector2i(128 + (variant * 2 - 1) * 44, y), 5, SOUL_DARK)
		_line(soul_wall, Vector2i(16, 224), Vector2i(240, 224), SOUL_DARK, 3)
		_save(soul_wall, "environment/walls/soul_gaol_carved_stone_%02d.png" % (variant + 1), "WALL-04", "P0", "soul_gaol_lock_masonry")
	var arch_widths: Array[int] = [128, 176, 224]
	for index: int in range(arch_widths.size()):
		var arch: Image = _image(Vector2i(256, 256))
		var width: int = arch_widths[index]
		_draw_pointed_arch(arch, Rect2i(128 - width / 2, 18, width, 230), STONE_MID, CLEAR, STONE_LIGHT, index - 1)
		_save(arch, "environment/walls/thick_pointed_prison_arch_%03d.png" % width, "WALL-06", "P0", "structural_prison_arch")
	var transition_arch: Image = _image(Vector2i(320, 256))
	_draw_pointed_arch(transition_arch, Rect2i(18, 22, 284, 226), Color("4d565b"), CLEAR, GOLD, 2)
	_rect(transition_arch, Rect2i(24, 212, 272, 12), Color("233f44"))
	_save(transition_arch, "environment/walls/chapel_prison_transition_arch.png", "WALL-07", "P0", "chapter_transition_arch")


func _generate_floors() -> void:
	for variant: int in range(4):
		var floor_strip: Image = _image(Vector2i(256, 64))
		_rect(floor_strip, Rect2i(0, 0, 256, 7), STONE_LIGHT)
		_rect(floor_strip, Rect2i(0, 7, 256, 57), STONE)
		for x: int in range(-variant * 17, 256, 64):
			_rect(floor_strip, Rect2i(x + 2, 12, 58, 42), STONE_MID if posmod(x / 64 + variant, 2) == 0 else Color("2a3746"))
			_line(floor_strip, Vector2i(x + 8, 48), Vector2i(x + 50, 17), STONE_DARK, 2)
		_rect(floor_strip, Rect2i(0, 54, 256, 10), STONE_DARK)
		_save(floor_strip, "environment/floors/wet_flagstone_strip_%02d.png" % (variant + 1), "FLOOR-01", "P0", "walkable_floor")
	for variant: int in range(3):
		var channel: Image = _image(Vector2i(256, 64), STONE_DARK)
		for x: int in range(0, 256, 64):
			_rect(channel, Rect2i(x + 2, 8, 60, 54), Color("1a2c32"))
			_line(channel, Vector2i(x + 8, 14), Vector2i(x + 54, 50), Color("274148"), 2)
		_rect(channel, Rect2i(0, 0, 256, 6), Color("315c60"))
		for x: int in range(16 + variant * 13, 256, 70):
			_rect(channel, Rect2i(x, 20 + variant * 5, 34, 2), WATER_MID)
		_save(channel, "environment/floors/shallow_water_channel_bed_%02d.png" % (variant + 1), "FLOOR-02", "P0", "water_bed_floor")
	for variant: int in range(3):
		var grate: Image = _image(Vector2i(128, 64), IRON_DARK)
		_rect(grate, Rect2i(4, 5, 120, 54), Color("07131b"))
		for x: int in range(10 + variant * 2, 120, 14):
			_rect(grate, Rect2i(x, 8, 5, 48), IRON)
		_rect(grate, Rect2i(4, 24, 120, 6), RUST)
		_rect(grate, Rect2i(4, 50, 120, 5), IRON_LIGHT)
		_save(grate, "environment/floors/drain_grate_strip_%02d.png" % (variant + 1), "FLOOR-03", "P0", "walkable_drain_grate")
	for variant: int in range(2):
		var dry: Image = _image(Vector2i(256, 64))
		_rect(dry, Rect2i(0, 0, 256, 8), Color("77776f"))
		_rect(dry, Rect2i(0, 8, 256, 56), Color("3b4044"))
		for x: int in range(variant * 24, 256, 80):
			_rect(dry, Rect2i(x, 10, 76, 44), Color("4b5155"))
			_line(dry, Vector2i(x + 12, 48), Vector2i(x + 60, 17), Color("30363c"), 2)
		_save(dry, "environment/floors/dry_checkpoint_stone_%02d.png" % (variant + 1), "FLOOR-05", "P0", "safe_floor")
	for variant: int in range(6):
		var edge: Image = _image(Vector2i(64, 64))
		var direction: int = -1 if variant % 2 == 0 else 1
		for column: int in range(8):
			var x: int = column * 8
			var cut: int = posmod(column * 7 + variant * 5, 26)
			var height: int = 54 - cut if direction > 0 else 32 + cut
			_rect(edge, Rect2i(x, 6, 8, maxi(8, height)), STONE_MID)
		_rect(edge, Rect2i(0, 0, 64, 6), STONE_LIGHT)
		_draw_crack(edge, Vector2i(24 + variant * 3, 8), 4, direction, STONE_DARK)
		_save(edge, "environment/floors/broken_edge_endcap_%02d.png" % (variant + 1), "FLOOR-08", "P0", "broken_walkable_endcap")


func _generate_flooded_cells() -> void:
	var cell_states: Array[String] = ["intact", "open", "bent"]
	for state_index: int in range(cell_states.size()):
		var cell: Image = _image(Vector2i(128, 160))
		_draw_pointed_arch(cell, Rect2i(4, 4, 120, 154), STONE_MID, Color("071018"), STONE_LIGHT)
		if state_index != 1:
			_draw_bars(cell, Rect2i(19, 50, 90, 102), 6, 3 if state_index == 2 else -1)
		else:
			_draw_bars(cell, Rect2i(19, 50, 36, 102), 3)
			_draw_bars(cell, Rect2i(85, 50, 24, 102), 2)
		_rect(cell, Rect2i(10, 136, 108, 16), Color("173841"))
		_save(cell, "environment/flooded_cells/thick_cell_front_%s.png" % cell_states[state_index], "CELL-01", "P0", "cell_front_state")
	for variant: int in range(2):
		var upper: Image = _image(Vector2i(192, 160))
		_draw_pointed_arch(upper, Rect2i(4, 2, 184, 154), STONE_MID, Color("071018"), STONE_LIGHT, variant)
		_draw_bars(upper, Rect2i(34, 48, 124, 86), 8, -1 if variant == 0 else 5)
		_rect(upper, Rect2i(0, 136, 192, 8), STONE_LIGHT)
		_rect(upper, Rect2i(0, 144, 192, 16), STONE_DARK)
		_save(upper, "environment/flooded_cells/upper_inspection_cell_bay_%02d.png" % (variant + 1), "CELL-04", "P0", "elevated_cell_bay")
	for variant: int in range(4):
		var trim: Image = _image(Vector2i(256, 32))
		_rect(trim, Rect2i(0, 3, 256, 7), STONE_MID)
		_rect(trim, Rect2i(0, 10, 256, 12), Color("18353c"))
		for x: int in range(variant * 13, 256, 58):
			_rect(trim, Rect2i(x, 13 + posmod(x, 3), 34, 3), Color("315c60"))
			_rect(trim, Rect2i(x + 8, 21, 4, 8), SEDIMENT)
		_save(trim, "environment/flooded_cells/waterline_wall_trim_%02d.png" % (variant + 1), "CELL-05", "P0", "waterline_trim")


func _draw_walkable_platform(width: int, height: int, material: Color, support: Color, heavy: bool) -> Image:
	var image: Image = _image(Vector2i(width, height))
	_rect(image, Rect2i(0, 0, width, 6), STONE_LIGHT)
	_rect(image, Rect2i(0, 6, width, 12), material)
	for x: int in range(8, width - 8, 32):
		_rect(image, Rect2i(x, 19, 24, 12 if not heavy else 20), support)
		_line(image, Vector2i(x, 31 if not heavy else 39), Vector2i(x + 20, 19), STONE_DARK, 2)
	if heavy:
		_rect(image, Rect2i(8, height - 12, width - 16, 8), IRON_DARK)
	return image


func _generate_platforms_and_catwalks() -> void:
	for width: int in [96, 128, 160]:
		_save(_draw_walkable_platform(width, 32, STONE_MID, STONE, false), "environment/platforms/maintenance_stone_ledge_%03d.png" % width, "PLAT-01", "P0", "walkable_light_platform")
	for width: int in [160, 224]:
		_save(_draw_walkable_platform(width, 48, Color("3e4650"), STONE_MID, true), "environment/platforms/wide_prison_dais_%03d.png" % width, "PLAT-02", "P0", "walkable_heavy_platform")
	var execution: Image = _draw_walkable_platform(256, 64, Color("4a4140"), Color("302c31"), true)
	for x: int in [48, 128, 208]:
		_rect(execution, Rect2i(x, 8, 10, 12), RUST)
		_circle(execution, Vector2i(x + 5, 10), 3, IRON_LIGHT)
	_save(execution, "environment/platforms/execution_platform_256.png", "PLAT-03", "P0", "elite_execution_platform")
	for width: int in [48, 64, 96]:
		var stone: Image = _image(Vector2i(width, 24))
		_rect(stone, Rect2i(0, 4, width, 20), STONE_MID)
		_rect(stone, Rect2i(4, 0, width - 8, 6), STONE_LIGHT)
		_rect(stone, Rect2i(8, 18, width - 16, 6), SEDIMENT)
		_save(stone, "environment/platforms/cistern_stepping_stone_%03d.png" % width, "PLAT-04", "P0", "low_water_stepping_stone")
	for width: int in [96, 128, 160]:
		var catwalk: Image = _image(Vector2i(width, 48))
		_rect(catwalk, Rect2i(0, 0, width, 6), IRON_LIGHT)
		_rect(catwalk, Rect2i(0, 6, width, 12), IRON)
		_draw_rivets(catwalk, Rect2i(0, 3, width, 15), 16, RUST_LIGHT)
		for x: int in range(0, width, 32):
			_line(catwalk, Vector2i(x + 2, 42), Vector2i(x + 28, 18), IRON_DARK, 4)
			_line(catwalk, Vector2i(x + 30, 42), Vector2i(x + 4, 18), RUST, 2)
		_save(catwalk, "environment/catwalks/riveted_iron_catwalk_%03d.png" % width, "CAT-01", "P0", "walkable_ranged_catwalk")
	for variant: int in range(2):
		var oak: Image = _image(Vector2i(128, 48))
		_rect(oak, Rect2i(0, 0, 128, 6), Color("8a7968"))
		for x: int in range(0, 128, 32):
			_rect(oak, Rect2i(x + 2, 6, 28, 18), OAK)
			_line(oak, Vector2i(x + 6, 20), Vector2i(x + 25, 9), OAK_DARK, 2)
		_rect(oak, Rect2i(8, 24, 112, 6), IRON_DARK)
		_line(oak, Vector2i(8, 30), Vector2i(32, 46), RUST, 4)
		_line(oak, Vector2i(120, 30), Vector2i(96, 46), RUST, 4)
		if variant == 1:
			_rect(oak, Rect2i(55, 0, 18, 26), CLEAR)
		_save(oak, "environment/catwalks/oak_prison_walkway_%s.png" % ("intact" if variant == 0 else "cracked"), "CAT-02", "P0", "walkable_oak_catwalk")
	var bridge_states: Array[String] = ["intact", "broken_left", "broken_right"]
	for state_index: int in range(bridge_states.size()):
		var bridge: Image = _image(Vector2i(160, 96))
		for x: int in range(4, 156, 26):
			_rect(bridge, Rect2i(x, 18 + posmod(x, 4), 22, 13), OAK)
		_rect(bridge, Rect2i(0, 12, 160, 5), IRON_LIGHT)
		_line(bridge, Vector2i(8, 0), Vector2i(28, 82), RUST, 4)
		_line(bridge, Vector2i(152, 0), Vector2i(132, 82), RUST, 4)
		if state_index == 1:
			_rect(bridge, Rect2i(0, 12, 52, 28), CLEAR)
		elif state_index == 2:
			_rect(bridge, Rect2i(108, 12, 52, 28), CLEAR)
		_save(bridge, "environment/catwalks/chain_bridge_%s.png" % bridge_states[state_index], "CAT-03", "P0", "chain_bridge_span")
	for direction_index: int in range(2):
		var stairs: Image = _image(Vector2i(128, 96))
		for step: int in range(6):
			var x: int = step * 20 if direction_index == 0 else 128 - (step + 1) * 20
			var y: int = 80 - step * 12
			_rect(stairs, Rect2i(x, y, 28, 8), STONE_LIGHT)
			_rect(stairs, Rect2i(x + 4, y + 8, 20, 8), STONE_MID)
		_save(stairs, "environment/catwalks/maintenance_stairs_%s.png" % ("right" if direction_index == 0 else "left"), "CAT-04", "P0", "mandatory_access_stairs")
	for variant: int in range(8):
		var bracket: Image = _image(Vector2i(64, 64))
		var inset: int = 4 + posmod(variant * 3, 10)
		_rect(bracket, Rect2i(inset, 4, 8, 52), IRON)
		_line(bracket, Vector2i(inset + 7, 12), Vector2i(58, 50 - posmod(variant, 3) * 5), RUST, 6)
		_rect(bracket, Rect2i(inset - 3, 0, 18, 8), IRON_LIGHT)
		_save(bracket, "environment/catwalks/support_bracket_%02d.png" % (variant + 1), "CAT-07", "P0", "platform_support")
	for variant: int in range(3):
		var ledge: Image = _image(Vector2i(128, 32))
		for segment: int in range(8):
			if posmod(segment + variant, 4) != 0:
				_rect(ledge, Rect2i(segment * 16, 5 + posmod(segment * 5 + variant, 6), 13, 16), STONE_MID)
		_rect(ledge, Rect2i(0, 24, 128, 5), STONE_DARK)
		_save(ledge, "environment/catwalks/decorative_broken_ledge_%02d.png" % (variant + 1), "CAT-08", "P1", "non_walkable_rear_ledge")


func _generate_cistern_and_drainage() -> void:
	for variant: int in range(2):
		var shrine: Image = _image(Vector2i(256, 256))
		_draw_pointed_arch(shrine, Rect2i(12, 12, 232, 232), STONE_MID, Color("0a1820"), STONE_LIGHT, variant)
		_circle(shrine, Vector2i(128, 124), 54, IRON_DARK)
		_circle(shrine, Vector2i(128, 124), 42, Color("183840"))
		for spoke: int in range(8):
			var angle: float = float(spoke) * TAU / 8.0
			_line(shrine, Vector2i(128, 124), Vector2i(128 + roundi(cos(angle) * 48.0), 124 + roundi(sin(angle) * 48.0)), RUST, 5)
		if variant == 1:
			_rect(shrine, Rect2i(92, 116, 74, 18), SEDIMENT)
			_draw_crack(shrine, Vector2i(130, 70), 7, 1, SOUL_DARK)
		_save(shrine, "environment/cistern/reservoir_regulator_%s.png" % ("intact" if variant == 0 else "corrupted"), "CIS-01", "P0", "cistern_landmark")
	var drain_states: Array[String] = ["round", "square", "barred"]
	for state_index: int in range(drain_states.size()):
		var drain: Image = _image(Vector2i(96, 96))
		_rect(drain, Rect2i(4, 4, 88, 88), STONE_MID)
		if state_index == 0:
			_circle(drain, Vector2i(48, 51), 35, IRON_DARK)
			_circle(drain, Vector2i(48, 51), 27, Color("071018"))
		else:
			_rect(drain, Rect2i(18, 20, 60, 64), IRON_DARK)
			_rect(drain, Rect2i(25, 27, 46, 50), Color("071018"))
		if state_index == 2:
			_draw_bars(drain, Rect2i(22, 24, 52, 56), 5, 2)
		_save(drain, "environment/cistern/overflow_drain_%s.png" % drain_states[state_index], "CIS-02", "P0", "overflow_drain")
	var ambush_states: Array[String] = ["closed", "telegraph", "open"]
	for state_index: int in range(ambush_states.size()):
		var mouth: Image = _image(Vector2i(96, 80))
		_rect(mouth, Rect2i(2, 8, 92, 70), STONE_MID)
		_rect(mouth, Rect2i(10, 20, 76, 54), IRON_DARK)
		if state_index == 0:
			_draw_bars(mouth, Rect2i(14, 22, 68, 50), 6)
		elif state_index == 1:
			_draw_bars(mouth, Rect2i(14, 22, 68, 50), 6, 3)
			for bubble: int in range(6):
				_ellipse_outline(mouth, Vector2i(24 + bubble * 10, 13 - posmod(bubble, 2) * 5), 3, 2, WATER_LIGHT)
		else:
			_rect(mouth, Rect2i(20, 28, 56, 42), Color("03070b"))
		_save(mouth, "props/drainage/ambush_drain_%s.png" % ambush_states[state_index], "DRAIN-01", "P0", "ambush_drain_state")
	for variant: int in range(3):
		var grate: Image = _image(Vector2i(64, 32))
		_rect(grate, Rect2i(2, 2, 60, 28), IRON_DARK)
		for x: int in range(8, 60, 10):
			var y_offset: int = 4 if variant == 2 and x > 34 else 0
			_line(grate, Vector2i(x, 5 + y_offset), Vector2i(x - (4 if variant == 1 else 0), 27), RUST if variant > 0 else IRON_LIGHT, 3)
		_save(grate, "props/drainage/floor_grate_%s.png" % (["intact", "bent", "broken"][variant]), "DRAIN-04", "P0", "floor_drain_prop")
	for variant: int in range(4):
		var debris: Image = _image(Vector2i(64, 32))
		for piece: int in range(7):
			var x: int = 5 + posmod(piece * 17 + variant * 11, 54)
			var y: int = 18 + posmod(piece * 7, 10)
			_rect(debris, Rect2i(x, y, 7 + posmod(piece, 5), 3 + posmod(piece, 3)), SEDIMENT if piece % 2 == 0 else RUST)
		_save(debris, "props/drainage/sediment_cluster_%02d.png" % (variant + 1), "DRAIN-06", "P2", "small_drainage_dress")


func _draw_wheel(frame: int) -> Image:
	var image: Image = _image(Vector2i(256, 256))
	var center: Vector2i = Vector2i(128, 128)
	_circle(image, center, 110, IRON_DARK)
	_circle(image, center, 99, CLEAR)
	_circle(image, center, 25, IRON)
	_circle(image, center, 12, RUST_LIGHT)
	for spoke: int in range(12):
		var angle: float = (float(spoke) + float(frame) / 8.0) * TAU / 12.0
		var inner: Vector2i = center + Vector2i(roundi(cos(angle) * 20.0), roundi(sin(angle) * 20.0))
		var outer: Vector2i = center + Vector2i(roundi(cos(angle) * 101.0), roundi(sin(angle) * 101.0))
		_line(image, inner, outer, IRON, 8)
		_rect(image, Rect2i(outer - Vector2i(8, 5), Vector2i(16, 10)), RUST)
	return image


func _generate_floodgate_machinery() -> void:
	for frame: int in range(8):
		_save(_draw_wheel(frame), "environment/floodgate/gothic_waterwheel_%02d.png" % (frame + 1), "GATE-01", "P0", "animated_waterwheel")
	for frame: int in range(4):
		var gears: Image = _image(Vector2i(256, 192))
		var centers: Array[Vector2i] = [Vector2i(74, 98), Vector2i(154, 72), Vector2i(196, 138)]
		var radii: Array[int] = [56, 42, 30]
		for index: int in range(centers.size()):
			_circle(gears, centers[index], radii[index], IRON_DARK)
			_circle(gears, centers[index], radii[index] - 10, CLEAR)
			_circle(gears, centers[index], 10, RUST_LIGHT)
			for tooth: int in range(8):
				var angle: float = (float(tooth) + float(frame) * (1.0 if index % 2 == 0 else -1.0) / 4.0) * TAU / 8.0
				var outer: Vector2i = centers[index] + Vector2i(roundi(cos(angle) * float(radii[index])), roundi(sin(angle) * float(radii[index])))
				_rect(gears, Rect2i(outer - Vector2i(6, 6), Vector2i(12, 12)), IRON)
		_save(gears, "environment/floodgate/main_gear_train_%02d.png" % (frame + 1), "GATE-02", "P0", "animated_gear_train")
	for variant: int in range(2):
		var housing: Image = _image(Vector2i(256, 256))
		_draw_pointed_arch(housing, Rect2i(8, 8, 240, 244), STONE_MID, IRON_DARK, STONE_LIGHT, variant)
		_rect(housing, Rect2i(42, 84, 172, 154), IRON)
		for y: int in range(98, 232, 34):
			_rect(housing, Rect2i(48, y, 160, 7), RUST)
		_draw_rivets(housing, Rect2i(42, 82, 172, 158), 24, IRON_LIGHT)
		_save(housing, "environment/floodgate/floodgate_housing_%02d.png" % (variant + 1), "GATE-04", "P0", "floodgate_architecture")
	for variant: int in range(3):
		var channel: Image = _image(Vector2i(256, 96))
		_rect(channel, Rect2i(0, 0, 256, 96), STONE_DARK)
		_rect(channel, Rect2i(0, 8, 256, 14), STONE_MID)
		_rect(channel, Rect2i(0, 28, 256, 62), WATER_DARK)
		for x: int in range(variant * 17, 256, 64):
			_rect(channel, Rect2i(x, 40 + variant * 6, 42, 3), WATER_MID)
		_save(channel, "environment/floodgate/sluice_channel_%02d.png" % (variant + 1), "GATE-05", "P0", "floodgate_water_channel")
	for variant: int in range(2):
		var pier: Image = _image(Vector2i(128, 192))
		_rect(pier, Rect2i(22, 12, 84, 180), STONE_MID)
		_rect(pier, Rect2i(12, 0, 104, 18), STONE_LIGHT)
		for y: int in range(30 + variant * 10, 176, 46):
			_rect(pier, Rect2i(28, y, 72, 4), STONE_DARK)
		_rect(pier, Rect2i(32, 132, 64, 60), Color("213c42"))
		_save(pier, "environment/floodgate/waterwheel_support_pier_%02d.png" % (variant + 1), "GATE-06", "P0", "machinery_support")


func _generate_narrative_props() -> void:
	for variant: int in range(6):
		var bars: Image = _image(Vector2i(64, 128))
		_draw_bars(bars, Rect2i(4, 4, 56, 120), 4 + posmod(variant, 2), 2 if variant == 2 else -1)
		_save(bars, "props/prison_bars/prison_bar_module_%02d.png" % (variant + 1), "BAR-%02d" % (variant + 1), "P0", "prison_bar_module")
	for variant: int in range(8):
		var chain: Image = _image(Vector2i(48, 160 if variant < 5 else 96))
		var links: int = 7 if variant < 5 else 4
		for link: int in range(links):
			var x_offset: int = roundi(sin(float(link + variant) * 0.8) * float(2 + variant % 3))
			_ellipse_outline(chain, Vector2i(24 + x_offset, 12 + link * 20), 7 if link % 2 == 0 else 5, 10, RUST_LIGHT, 2)
		if variant == 4:
			_rect(chain, Rect2i(0, 120, 48, 40), CLEAR)
		_save(chain, "props/chains/chain_module_%02d.png" % (variant + 1), "CHAIN-%02d" % (variant + 1), "P0" if variant < 5 else "P1", "restraint_and_hoist_chain")
	for variant: int in range(6):
		var key_prop: Image = _image(Vector2i(64, 64))
		if variant == 0:
			_rect(key_prop, Rect2i(4, 8, 56, 50), OAK)
			for hook: int in range(3):
				_circle(key_prop, Vector2i(16 + hook * 16, 25), 5, GOLD)
				_line(key_prop, Vector2i(16 + hook * 16, 29), Vector2i(16 + hook * 16, 48), GOLD_LIGHT, 3)
		else:
			_circle(key_prop, Vector2i(20, 22), 9, GOLD if variant < 4 else IRON_LIGHT)
			_circle(key_prop, Vector2i(20, 22), 4, CLEAR)
			_line(key_prop, Vector2i(28, 28), Vector2i(53, 52), GOLD_LIGHT if variant < 4 else RUST, 5)
			_rect(key_prop, Rect2i(46, 45, 8, 12), GOLD)
		_save(key_prop, "props/keys/key_prop_%02d.png" % (variant + 1), "KEY-%02d" % (variant + 1), "P1", "key_and_lock_narrative_prop")
	for variant: int in range(8):
		var record: Image = _image(Vector2i(96, 72))
		if variant in [0, 3, 6]:
			_rect(record, Rect2i(4, 22, 88, 42), OAK)
			_rect(record, Rect2i(12, 8, 72, 20), Color("766452"))
		else:
			_rect(record, Rect2i(10, 12, 76, 52), Color("837560"))
			for y: int in range(20, 58, 10):
				_rect(record, Rect2i(18, y, 54 - posmod(y + variant, 17), 2), OAK_DARK)
		if variant == 5:
			_rect(record, Rect2i(0, 48, 96, 24), Color(0.07, 0.25, 0.29, 0.8))
		_save(record, "props/records/record_prop_%02d.png" % (variant + 1), "REC-%02d" % (variant + 1), "P1", "registry_and_safe_room_prop")
	for variant: int in range(6):
		var tool: Image = _image(Vector2i(128, 96))
		if variant == 0:
			_rect(tool, Rect2i(8, 44, 112, 18), OAK)
			_rect(tool, Rect2i(18, 62, 12, 30), IRON_DARK)
			_rect(tool, Rect2i(98, 62, 12, 30), IRON_DARK)
			for x: int in [32, 96]:
				_circle(tool, Vector2i(x, 52), 7, RUST)
		elif variant == 1:
			_rect(tool, Rect2i(36, 28, 56, 52), OAK_DARK)
			_rect(tool, Rect2i(20, 76, 88, 12), IRON)
		else:
			_rect(tool, Rect2i(12, 12, 104, 72), IRON_DARK)
			for x: int in range(24, 110, 24):
				_line(tool, Vector2i(x, 18), Vector2i(x - 8 + variant * 2, 70), RUST_LIGHT, 4)
		_save(tool, "props/torture_tools/workshop_prop_%02d.png" % (variant + 1), "TOOL-%02d" % (variant + 1), "P1", "rear_layer_workshop_prop")
	for variant: int in range(6):
		var storage: Image = _image(Vector2i(64, 64))
		if variant < 4:
			_rect(storage, Rect2i(5, 15, 54, 44), OAK if variant % 2 == 0 else OAK_DARK)
			_rect(storage, Rect2i(7, 22, 50, 6), IRON_DARK)
			_line(storage, Vector2i(8, 17), Vector2i(56, 54), RUST, 3)
		else:
			_circle(storage, Vector2i(32, 34), 25, OAK_DARK)
			_rect(storage, Rect2i(8, 27, 48, 8), IRON)
		_save(storage, "props/crates/storage_prop_%02d.png" % (variant + 1), "STORE-%02d" % (variant + 1), "P1", "prison_storage_prop")
	for variant: int in range(5):
		var remains: Image = _image(Vector2i(96, 48))
		if variant == 0:
			_line(remains, Vector2i(12, 38), Vector2i(74, 20), Color("5b5f5b"), 16)
			_circle(remains, Vector2i(78, 18), 9, BONE)
		elif variant == 1:
			_rect(remains, Rect2i(10, 24, 76, 16), Color("313f42"))
			_circle(remains, Vector2i(22, 21), 8, BONE)
		else:
			for bone: int in range(5):
				_line(remains, Vector2i(12 + bone * 14, 36), Vector2i(24 + bone * 12, 18 + posmod(bone + variant, 12)), BONE, 3)
		_save(remains, "props/corpses/remains_prop_%02d.png" % (variant + 1), "REMAIN-%02d" % (variant + 1), "P2", "non_gore_environmental_remains")


func _draw_soul_core(frame: int, size: Vector2i = Vector2i(48, 64)) -> Image:
	var image: Image = _image(size)
	var center: Vector2i = Vector2i(size.x / 2, size.y / 2)
	var pulse: int = 7 + posmod(frame, 3)
	_circle(image, center, pulse + 5, Color(0.18, 0.45, 0.54, 0.22))
	_circle(image, center + Vector2i(posmod(frame, 3) - 1, -3 + posmod(frame * 2, 7)), pulse, SOUL)
	_circle(image, center + Vector2i(-2, -5), maxi(2, pulse / 3), SOUL_LIGHT)
	_line(image, center + Vector2i(-4, 5), center + Vector2i(2, 20), SOUL_DARK, 3)
	return image


func _generate_soul_cages() -> void:
	var cage_states: Array[String] = ["intact", "empty", "cracked"]
	for state_index: int in range(cage_states.size()):
		var cage: Image = _image(Vector2i(64, 96))
		_rect(cage, Rect2i(8, 8, 48, 80), IRON_DARK)
		_rect(cage, Rect2i(13, 13, 38, 70), Color("071018"))
		_draw_bars(cage, Rect2i(12, 10, 40, 76), 5, 2 if state_index == 2 else -1)
		_circle(cage, Vector2i(32, 7), 6, RUST)
		if state_index != 1:
			var core: Image = _draw_soul_core(state_index)
			cage.blend_rect(core, core.get_used_rect(), Vector2i(8, 16))
		_save(cage, "props/soul_cages/numbered_soul_cage_%s.png" % cage_states[state_index], "SOUL-01", "P0", "standard_soul_cage")
	for variant: int in range(3):
		var bay: Image = _image(Vector2i(128, 128))
		_draw_pointed_arch(bay, Rect2i(4, 4, 120, 120), STONE_MID, Color("071018"), STONE_LIGHT)
		for cage_index: int in range(3):
			var x: int = 22 + cage_index * 34
			_rect(bay, Rect2i(x, 54, 24, 54), IRON_DARK)
			for bar: int in range(3):
				_rect(bay, Rect2i(x + 5 + bar * 7, 58, 3, 46), IRON)
			_circle(bay, Vector2i(x + 12, 78 + posmod(cage_index + variant, 9)), 5, SOUL)
		_save(bay, "props/soul_cages/registry_wall_cage_bay_%02d.png" % (variant + 1), "SOUL-02", "P0", "registry_cage_bay")
	for state: int in range(4):
		var broken: Image = _image(Vector2i(96, 96))
		_rect(broken, Rect2i(12, 14, 72, 70), IRON_DARK)
		for bar: int in range(6):
			var top: int = 18 + state * (bar % 3) * 4
			var bottom: int = 80 - state * ((bar + 1) % 3) * 5
			_line(broken, Vector2i(20 + bar * 11, top), Vector2i(16 + bar * 12, bottom), RUST if state > 1 else IRON, 4)
		for fragment: int in range(state * 3):
			_rect(broken, Rect2i(8 + fragment * 13, 86 - posmod(fragment * 7, 18), 6, 4), IRON_LIGHT)
		_save(broken, "props/soul_cages/broken_cage_state_%02d.png" % (state + 1), "SOUL-04", "P0", "post_boss_cage_break_state")
	for frame: int in range(6):
		_save(_draw_soul_core(frame), "props/soul_cages/soul_glass_core_%02d.png" % (frame + 1), "SOUL-05", "P0", "contained_soul_motion")


func _draw_gate_panel(size: Vector2i, openness: float, material: Color, accent: Color, barred: bool) -> Image:
	var image: Image = _image(size)
	var panel_height: int = roundi(float(size.y - 12) * (1.0 - openness))
	if panel_height <= 0:
		return image
	var y: int = 6
	_rect(image, Rect2i(6, y, size.x - 12, panel_height), material)
	_rect(image, Rect2i(10, y + 4, size.x - 20, maxi(0, panel_height - 8)), IRON_DARK)
	if barred:
		_draw_bars(image, Rect2i(12, y + 4, size.x - 24, maxi(10, panel_height - 8)), maxi(4, size.x / 18))
	else:
		for x: int in range(18, size.x - 12, 24):
			_rect(image, Rect2i(x, y + 8, 8, maxi(0, panel_height - 16)), material.lightened(0.12))
	for cross_y: int in range(y + 20, y + panel_height, 42):
		_rect(image, Rect2i(8, cross_y, size.x - 16, 5), accent)
	return image


func _generate_doors() -> void:
	var state_names: Array[String] = ["closed", "open", "bent"]
	for state_index: int in range(3):
		var door: Image = _image(Vector2i(96, 144))
		_draw_pointed_arch(door, Rect2i(2, 2, 92, 140), STONE_MID, Color("071018"), STONE_LIGHT)
		if state_index == 0:
			_draw_bars(door, Rect2i(16, 45, 64, 93), 6)
		elif state_index == 1:
			_draw_bars(door, Rect2i(16, 45, 22, 93), 2)
		else:
			_draw_bars(door, Rect2i(16, 45, 64, 93), 6, 3)
		_save(door, "doors/cell_doors/cell_door_%s.png" % state_names[state_index], "DOOR-01", "P0", "cell_door_state")
	var openings: Array[float] = [0.0, 0.48, 1.0]
	for state_index: int in range(3):
		_save(_draw_gate_panel(Vector2i(128, 176), openings[state_index], RUST, IRON_LIGHT, true), "doors/rusted_gates/isolation_gate_%02d.png" % (state_index + 1), "DOOR-02", "P0", "room_isolation_gate_state")
	for state_index: int in range(3):
		_save(_draw_gate_panel(Vector2i(160, 192), openings[state_index], IRON, RUST_LIGHT, false), "doors/floodgates/vertical_floodgate_%02d.png" % (state_index + 1), "DOOR-03", "P0", "floodgate_state")
	var boss_frame: Image = _image(Vector2i(256, 256))
	_draw_pointed_arch(boss_frame, Rect2i(4, 4, 248, 248), STONE_MID, CLEAR, STONE_LIGHT)
	_circle(boss_frame, Vector2i(128, 98), 46, IRON_DARK)
	_circle(boss_frame, Vector2i(128, 98), 34, CLEAR)
	_save(boss_frame, "doors/boss_gate/soul_lock_outer_frame.png", "DOOR-04", "P0", "boss_gate_rear_frame")
	for state_index: int in range(3):
		var panel: Image = _draw_gate_panel(Vector2i(192, 224), openings[state_index], IRON_DARK, SOUL_DARK, false)
		if state_index < 2:
			_circle(panel, Vector2i(96, 110), 28, RUST)
			_circle(panel, Vector2i(96, 110), 16, SOUL_DARK)
		_save(panel, "doors/boss_gate/soul_lock_panel_%02d.png" % (state_index + 1), "DOOR-05", "P0", "boss_gate_moving_panel")
	for frame: int in range(8):
		var seal: Image = _image(Vector2i(96, 96))
		var pulse: int = 28 + posmod(frame, 4) * 2
		_circle(seal, Vector2i(48, 48), pulse, Color(0.15, 0.40, 0.48, 0.28))
		_ellipse_outline(seal, Vector2i(48, 48), 30, 30, SOUL, 3)
		for spoke: int in range(6):
			var angle: float = (float(spoke) + float(frame) / 8.0) * TAU / 6.0
			_line(seal, Vector2i(48, 48), Vector2i(48 + roundi(cos(angle) * 25.0), 48 + roundi(sin(angle) * 25.0)), SOUL_LIGHT, 2)
		_circle(seal, Vector2i(48, 48), 7, MEMORY_LIGHT)
		_save(seal, "doors/boss_gate/soul_lock_seal_%02d.png" % (frame + 1), "DOOR-06", "P0", "boss_gate_seal_animation")


func _generate_boss_and_memory_environment() -> void:
	var core: Image = _image(Vector2i(512, 320), VOID)
	_draw_bricks(core, Rect2i(0, 0, 512, 320), Vector2i(64, 40), STONE_DARK, MORTAR, 1)
	for cx: int in [92, 256, 420]:
		_draw_pointed_arch(core, Rect2i(cx - 70, 26, 140, 272), STONE_MID, Color("071018"), STONE_LIGHT)
		_circle(core, Vector2i(cx, 132), 26, IRON_DARK)
		_circle(core, Vector2i(cx, 132), 10, SOUL_DARK)
	_rect(core, Rect2i(0, 282, 512, 38), Color("12323d"))
	_save(core, "environment/boss_area/drowned_gaol_core_backdrop.png", "BOSSENV-01", "P0", "boss_backdrop_module")
	var crown: Image = _image(Vector2i(256, 256))
	_circle(crown, Vector2i(128, 120), 84, IRON_DARK)
	_circle(crown, Vector2i(128, 120), 65, CLEAR)
	for spike: int in range(9):
		var angle: float = PI + float(spike) * PI / 8.0
		var base: Vector2i = Vector2i(128 + roundi(cos(angle) * 70.0), 120 + roundi(sin(angle) * 70.0))
		var tip: Vector2i = Vector2i(128 + roundi(cos(angle) * 110.0), 120 + roundi(sin(angle) * 110.0))
		_line(crown, base, tip, RUST, 8)
	for chain_x: int in [56, 200]:
		_line(crown, Vector2i(chain_x, 0), Vector2i(128, 214), IRON_LIGHT, 5)
	_circle(crown, Vector2i(128, 120), 22, SOUL_DARK)
	_circle(crown, Vector2i(128, 120), 8, SOUL_LIGHT)
	_save(crown, "environment/boss_area/chained_prison_crown.png", "BOSSENV-02", "P0", "boss_landmark")
	var recess: Image = _image(Vector2i(256, 256))
	_draw_pointed_arch(recess, Rect2i(8, 8, 240, 246), STONE_MID, IRON_DARK, STONE_LIGHT)
	for x: int in range(40, 220, 30):
		_rect(recess, Rect2i(x, 86, 10, 156), IRON)
		_rect(recess, Rect2i(x + 2, 92, 3, 124), RUST)
	_save(recess, "environment/boss_area/monumental_floodgate_recess.png", "BOSSENV-03", "P0", "boss_rear_floodgate")
	var arena_water: Image = _image(Vector2i(256, 64), WATER_DARK)
	for x: int in range(12, 256, 58):
		_rect(arena_water, Rect2i(x, 8 + posmod(x, 9), 44, 2), WATER_MID)
		_rect(arena_water, Rect2i(x + 12, 38 + posmod(x, 7), 28, 1), SOUL_DARK)
	_save(arena_water, "environment/boss_area/boss_shallow_water_bed.png", "BOSSENV-04", "P0", "boss_water_floor")
	var reservoir: Image = _image(Vector2i(512, 256), VOID)
	_draw_bricks(reservoir, Rect2i(0, 0, 512, 220), Vector2i(72, 40), STONE_DARK, MORTAR, 0)
	for x: int in [96, 256, 416]:
		_draw_pointed_arch(reservoir, Rect2i(x - 58, 30, 116, 190), STONE_MID, Color("08131c"), STONE_LIGHT, 2)
		_line(reservoir, Vector2i(x - 24, 76), Vector2i(x + 20, 190), RUST, 4)
	_rect(reservoir, Rect2i(0, 208, 512, 48), WATER_DARK)
	_save(reservoir, "environment/memory_transition/broken_soul_reservoir.png", "MEM-01", "P0", "post_boss_architecture")
	for variant: int in range(2):
		var corridor: Image = _image(Vector2i(256, 256), VOID)
		_draw_bricks(corridor, Rect2i(0, 0, 256, 256), Vector2i(64, 40), STONE_DARK, MORTAR, variant)
		_draw_pointed_arch(corridor, Rect2i(30, 28, 196, 228), STONE_MID, Color("09121c"), STONE_LIGHT, variant + 1)
		_save(corridor, "environment/memory_transition/ruined_drowned_corridor_%02d.png" % (variant + 1), "MEM-02", "P0", "ruined_memory_corridor")
	for variant: int in range(3):
		var reflection: Image = _image(Vector2i(256, 128), Color(0.10, 0.16, 0.22, 0.88))
		_draw_pointed_arch(reflection, Rect2i(26, 8, 204, 118), Color(0.41, 0.49, 0.57, 0.78), Color(0.08, 0.14, 0.20, 0.7), MEMORY, 0)
		for y: int in range(20 + variant * 4, 120, 22):
			_rect(reflection, Rect2i(18, y, 220, 2), Color(0.55, 0.70, 0.77, 0.28))
		_save(reflection, "environment/memory_transition/reflected_royal_corridor_%02d.png" % (variant + 1), "MEM-03", "P0", "chapter_five_reflection_tease")
	for frame: int in range(6):
		var memory_water: Image = _image(Vector2i(256, 96), Color(0.05, 0.16, 0.23, 0.88))
		for row: int in range(4):
			var start: int = posmod(frame * 19 + row * 47, 72)
			for x: int in range(start - 64, 256, 86):
				_rect(memory_water, Rect2i(x, 12 + row * 20, 26 + posmod(x + frame, 38), 2), Color(0.55, 0.72, 0.79, 0.46 - row * 0.05))
		_save(memory_water, "environment/memory_transition/memory_water_%02d.png" % (frame + 1), "MEM-04", "P0", "post_boss_memory_water")


func _draw_water_body(frame: int) -> Image:
	var image: Image = _image(Vector2i(256, 64), Color(0.03, 0.12, 0.17, 0.92))
	_rect(image, Rect2i(0, 6, 256, 58), Color(0.05, 0.20, 0.25, 0.90))
	for row: int in range(4):
		for x: int in range(posmod(frame * 17 + row * 43, 76) - 60, 256, 94):
			_rect(image, Rect2i(x, 14 + row * 13, 28 + posmod(x + frame * 7, 38), 2), WATER_MID if row < 2 else WATER)
	return image


func _draw_ripple(frame: int, size: Vector2i, strength: float) -> Image:
	var image: Image = _image(size)
	var alpha: float = maxf(0.12, strength - float(frame) * 0.13)
	var radius_x: int = 8 + frame * (size.x / 18)
	_ellipse_outline(image, Vector2i(size.x / 2, size.y - 6), mini(size.x / 2 - 2, radius_x), 2 + frame, Color(WATER_LIGHT.r, WATER_LIGHT.g, WATER_LIGHT.b, alpha), 2)
	return image


func _draw_splash(frame: int, size: Vector2i, force: int) -> Image:
	var image: Image = _draw_ripple(frame, size, 0.82)
	var center: Vector2i = Vector2i(size.x / 2, size.y - 6)
	var peak: int = maxi(1, (4 - frame) * (4 + force * 2))
	for drop: int in range(3 + force * 2):
		var direction: int = -1 if drop % 2 == 0 else 1
		var x: int = center.x + direction * (5 + drop * 4 + frame * 2)
		var y: int = center.y - peak + posmod(drop * 5, 11)
		_circle(image, Vector2i(x, y), 1 + force / 2, Color(0.52, 0.82, 0.86, 0.74 - float(frame) * 0.11))
	return image


func _generate_dynamic_fx() -> void:
	var cage_sequence_names: Array[String] = ["contained_drift", "cage_strain", "crack_leak", "post_boss_release"]
	var gate_sequence_names: Array[String] = ["gear_dust", "chain_strain", "water_surge", "gate_seal", "lock_spark"]
	for frame: int in range(4):
		_save(_draw_water_body(frame), "fx/water/rear_water_body_%02d.png" % (frame + 1), "WFX-01", "P0", "rear_water_animation")
		var highlight: Image = _image(Vector2i(256, 16))
		for x: int in range(posmod(frame * 23, 56) - 40, 256, 72):
			_rect(highlight, Rect2i(x, 3 + posmod(x, 5), 30 + posmod(x + frame, 24), 2), Color(0.46, 0.71, 0.76, 0.45))
		_save(highlight, "fx/water/local_highlight_%02d.png" % (frame + 1), "WFX-02", "P0", "water_highlight_animation")
		var flow: Image = _image(Vector2i(256, 24))
		for x: int in range(posmod(frame * 31, 80) - 60, 256, 96):
			_line(flow, Vector2i(x, 4), Vector2i(x + 52, 18), Color(0.25, 0.57, 0.63, 0.58), 2)
		_save(flow, "fx/water/flow_strip_%02d.png" % (frame + 1), "WFX-04", "P0", "water_flow_animation")
		var foam: Image = _image(Vector2i(96, 24))
		for bubble: int in range(7):
			_ellipse_outline(foam, Vector2i(8 + bubble * 13 + posmod(frame + bubble, 3), 14 + posmod(bubble, 2) * 3), 3 + posmod(bubble + frame, 3), 2 + posmod(bubble, 2), Color(0.54, 0.78, 0.78, 0.58))
		_save(foam, "fx/water/drain_foam_%02d.png" % (frame + 1), "WFX-05", "P0", "drain_foam_animation")
	for frame: int in range(6):
		var lip: Image = _image(Vector2i(256, 4))
		for x: int in range(posmod(frame * 11, 42) - 30, 256, 56):
			_rect(lip, Rect2i(x, posmod(x + frame, 2), 22 + posmod(x, 18), 1), Color(0.42, 0.74, 0.78, 0.62))
		_save(lip, "fx/water/front_lip_%02d.png" % (frame + 1), "WFX-03", "P0", "foot_only_foreground_water")
	for frame: int in range(5):
		_save(_draw_ripple(frame, Vector2i(64, 24), 0.78), "fx/ripples/step_%02d.png" % (frame + 1), "RFX-01", "P0", "player_step_ripple")
		_save(_draw_splash(frame, Vector2i(96, 48), 2), "fx/ripples/landing_%02d.png" % (frame + 1), "RFX-02", "P0", "player_landing_splash")
		_save(_draw_splash(frame, Vector2i(128, 48), 3), "fx/ripples/dash_%02d.png" % (frame + 1), "RFX-03", "P0", "player_dash_splash")
	for frame: int in range(4):
		_save(_draw_ripple(frame, Vector2i(96, 32), 0.72), "fx/ripples/enemy_wake_%02d.png" % (frame + 1), "RFX-04", "P0", "enemy_water_wake")
		_save(_draw_ripple(frame, Vector2i(64, 16), 0.48), "fx/ripples/idle_ripple_%02d.png" % (frame + 1), "RFX-05", "P0", "decorative_idle_ripple")
	for frame: int in range(4):
		var drip: Image = _image(Vector2i(16, 32))
		var y: int = 3 + frame * 7
		_line(drip, Vector2i(8, y), Vector2i(8, mini(30, y + 8)), WATER_LIGHT, 2)
		_circle(drip, Vector2i(8, mini(30, y + 8)), 2, WATER_LIGHT)
		_save(drip, "fx/drips/droplet_%02d.png" % (frame + 1), "DFX-01", "P1", "water_droplet_animation")
	for frame: int in range(4):
		var chain_sway: Image = _image(Vector2i(64, 160))
		for link: int in range(7):
			var phase: float = float(frame) * TAU / 4.0 + float(link) * 0.28
			var x: int = 32 + roundi(sin(phase) * float(link + 1) * 0.6)
			_ellipse_outline(chain_sway, Vector2i(x, 12 + link * 20), 7 if link % 2 == 0 else 5, 10, RUST_LIGHT, 2)
		_save(chain_sway, "fx/chains/rear_chain_sway_%02d.png" % (frame + 1), "CFX-01", "P1", "decorative_chain_sway")
	for frame: int in range(6):
		var soul_flame: Image = _image(Vector2i(48, 64))
		var center: Vector2i = Vector2i(24 + posmod(frame, 3) - 1, 42 - posmod(frame * 2, 5))
		_circle(soul_flame, center, 13, Color(0.22, 0.56, 0.64, 0.24))
		_line(soul_flame, center + Vector2i(-8, 5), Vector2i(24, 10 + posmod(frame, 4)), SOUL, 10)
		_circle(soul_flame, center, 7, SOUL_LIGHT)
		_save(soul_flame, "fx/soul_fire/idle_soul_flame_%02d.png" % (frame + 1), "SFX-01", "P0", "soul_flame_animation")
	for sequence: int in range(4):
		for frame: int in range(4):
			var cage_fx: Image = _image(Vector2i(64, 96))
			var drift_x: int = 32 + roundi(sin(float(frame + sequence) * PI / 2.0) * 5.0)
			var drift_y: int = 48 - frame * (2 + sequence)
			_circle(cage_fx, Vector2i(drift_x, drift_y), 8 + sequence, Color(0.25, 0.62, 0.70, 0.18 + sequence * 0.06))
			_circle(cage_fx, Vector2i(drift_x, drift_y), 4 + sequence / 2, SOUL)
			if sequence >= 2:
				_line(cage_fx, Vector2i(drift_x, drift_y), Vector2i(12 + frame * 12, 12), SOUL_LIGHT, 2)
			_save(cage_fx, "fx/soul_cage/%s_%02d.png" % [cage_sequence_names[sequence], frame + 1], "SCFX-%02d" % (sequence + 1), "P0", "soul_cage_fx_sequence")
	for sequence: int in range(5):
		for frame: int in range(4):
			var gate_fx: Image = _image(Vector2i(96, 64))
			for particle: int in range(4 + sequence):
				var x: int = 8 + posmod(particle * 23 + frame * 11, 80)
				var y: int = 12 + posmod(particle * 17 + frame * 7, 42)
				_rect(gate_fx, Rect2i(x, y, 2 + sequence / 2, 2 + sequence / 3), RUST_LIGHT if sequence < 2 else WATER_LIGHT)
			_save(gate_fx, "fx/floodgate/%s_%02d.png" % [gate_sequence_names[sequence], frame + 1], "GFX-%02d" % (sequence + 1), "P1", "floodgate_fx_sequence")
