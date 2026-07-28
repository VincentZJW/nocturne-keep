extends SceneTree

## Deterministically generates original Chapter II castle pixel assets.

const PixelCanvas: Script = preload("res://scripts/tools/pixel_art_canvas.gd")

const ROOT: String = "res://chapters/chapter_02_silent_court/assets"
const STONE_DARK: Color = Color("171923")
const STONE: Color = Color("343844")
const STONE_LIGHT: Color = Color("626875")
const OAK_DARK: Color = Color("24181b")
const OAK: Color = Color("4b2f2d")
const OAK_LIGHT: Color = Color("795148")
const IRON: Color = Color("59636e")
const STEEL: Color = Color("d8e0e4")
const GOLD_DARK: Color = Color("6d552c")
const GOLD: Color = Color("ad8d4f")
const CRIMSON: Color = Color("762f3f")
const BLOOD: Color = Color("4a1724")
const VELVET: Color = Color("332136")
const FLAME: Color = Color("f0b35f")
const FLAME_CORE: Color = Color("ffe6a0")

var _saved_count: int = 0


func _init() -> void:
	var failures: int = 0
	failures += _generate_weapon_assets()
	failures += _generate_portraits()
	failures += _generate_architecture()
	failures += _generate_props()
	failures += _generate_flames()
	if failures > 0:
		push_error("Chapter II castle asset generation failed for %d files" % failures)
		quit(1)
		return
	print("CHAPTER_02_CASTLE_ASSETS: PASS files=%d portraits=6 flames=3" % _saved_count)
	quit(0)


func _generate_weapon_assets() -> int:
	var failures: int = 0
	var world_display: Image = _new_image(Vector2i(128, 96))
	_draw_crossed_stilettos(world_display, Vector2i(64, 48), 1)
	failures += _save(world_display, "weapons/crimson_masque_stilettos/world_display.png")

	var pedestal: Image = _new_image(Vector2i(128, 96))
	_draw_crossed_stilettos(pedestal, Vector2i(64, 40), 1)
	_draw_pedestal_base(pedestal, 20, 72, 88)
	failures += _save(pedestal, "weapons/crimson_masque_stilettos/pedestal_display.png")

	var pickup: Image = _new_image(Vector2i(64, 64))
	_draw_crossed_stilettos(pickup, Vector2i(32, 31), 0)
	_draw_mask_fragment(pickup, Vector2i(32, 39))
	failures += _save(pickup, "weapons/crimson_masque_stilettos/pickup_icon.png")

	var inventory: Image = _new_image(Vector2i(32, 32))
	_draw_crossed_stilettos(inventory, Vector2i(16, 15), -1)
	failures += _save(inventory, "weapons/crimson_masque_stilettos/inventory_icon_formal.png")
	return failures


func _generate_portraits() -> int:
	var failures: int = 0
	var names: Array[String] = [
		"lady_secret_smile", "stern_court_lord", "royal_reader",
		"elder_in_cape", "rose_maiden", "court_matron",
	]
	for portrait_index: int in range(names.size()):
		var portrait: Image = _draw_portrait(portrait_index)
		failures += _save(portrait, "portraits/%s.png" % names[portrait_index])
	return failures


func _generate_architecture() -> int:
	var failures: int = 0
	failures += _save(_draw_stone_arch(false), "doors/stone_arch.png")
	failures += _save(_draw_stone_arch(true), "doors/blood_candle_chapel_arch.png")
	failures += _save(_draw_armory_door(), "doors/armory_iron_door.png")
	failures += _save(_draw_ballroom_door(), "doors/ballroom_double_door.png")
	failures += _save(_draw_corridor_door(), "doors/royal_corridor_door.png")
	failures += _save(_draw_pillar(), "environment/architecture/stone_pillar.png")
	failures += _save(_draw_wall_niche(), "environment/architecture/wall_niche.png")
	return failures


func _generate_props() -> int:
	var failures: int = 0
	failures += _save(_draw_weapon_rack(false), "props/armory_weapon_rack.png")
	failures += _save(_draw_weapon_rack(true), "props/armory_spear_rack.png")
	failures += _save(_draw_shield_display(), "props/wall_shield_display.png")
	failures += _save(_draw_knight_armor(), "props/knight_armor_statue.png")
	failures += _save(_draw_banquet_table(), "props/ruined_banquet_table.png")
	failures += _save(_draw_bench(), "props/oak_bench.png")
	failures += _save(_draw_crates(), "props/crate_stack.png")
	failures += _save(_draw_banner(), "props/royal_mourning_banner.png")
	failures += _save(_draw_altar(), "props/blood_candle_altar.png")
	failures += _save(_draw_bookshelf(), "props/royal_bookshelf.png")
	failures += _save(_draw_barrels(), "props/wine_barrel_stack.png")
	failures += _save(_draw_drape(), "props/ballroom_velvet_drape.png")
	failures += _save(_draw_wall_sconce(), "props/wall_candle_sconce.png")
	failures += _save(_draw_floor_candelabrum(), "props/floor_candelabrum.png")
	failures += _save(_draw_royal_crest(), "props/silent_court_royal_crest.png")
	return failures


func _generate_flames() -> int:
	var failures: int = 0
	for frame_index: int in range(3):
		var flame: Image = _new_image(Vector2i(16, 24))
		var lean: int = frame_index - 1
		_rect(flame, Rect2i(6 + lean, 8, 5, 9), FLAME)
		_rect(flame, Rect2i(7 + lean, 4, 3, 6), FLAME)
		_rect(flame, Rect2i(8 + lean, 2 + (frame_index % 2), 2, 4), FLAME_CORE)
		_rect(flame, Rect2i(7 + lean, 11, 3, 5), FLAME_CORE)
		_rect(flame, Rect2i(5, 17, 7, 2), Color(0.79, 0.32, 0.18, 0.55))
		failures += _save(flame, "fx/candle_flame_%02d.png" % (frame_index + 1))
	return failures


func _draw_crossed_stilettos(image: Image, center: Vector2i, size_mode: int) -> void:
	var reach: int = 44 if size_mode > 0 else (23 if size_mode == 0 else 11)
	var rise: int = 31 if size_mode > 0 else (18 if size_mode == 0 else 9)
	var main_tip: Vector2i = center + Vector2i(reach, -rise)
	var main_pommel: Vector2i = center - Vector2i(reach - 4, -rise + 5)
	var off_tip: Vector2i = center + Vector2i(reach - 4, rise - 5)
	var off_pommel: Vector2i = center - Vector2i(reach, rise)
	_draw_stiletto(image, main_pommel, main_tip, size_mode)
	_draw_stiletto(image, off_pommel, off_tip, size_mode)
	var mask_size: int = 8 if size_mode > 0 else (5 if size_mode == 0 else 3)
	_rect(image, Rect2i(center.x - mask_size / 2, center.y - 2, mask_size, 5), Color("d9d2c9"))
	_line(image, center + Vector2i(-1, -3), center + Vector2i(2, 4), CRIMSON, 1)


func _draw_stiletto(image: Image, pommel: Vector2i, tip: Vector2i, size_mode: int) -> void:
	var direction: Vector2 = Vector2(tip - pommel).normalized()
	var normal: Vector2 = Vector2(-direction.y, direction.x)
	var grip_length: int = 13 if size_mode > 0 else (7 if size_mode == 0 else 4)
	var guard_half: int = 7 if size_mode > 0 else (4 if size_mode == 0 else 2)
	var blade_width: int = 5 if size_mode > 0 else (3 if size_mode == 0 else 2)
	var guard_center: Vector2i = pommel + Vector2i(
		roundi(direction.x * float(grip_length)), roundi(direction.y * float(grip_length))
	)
	# Pommel and wrapped grip are intentionally darker than the blade.
	_rect(image, Rect2i(pommel.x - 2, pommel.y - 2, 5, 5), CRIMSON)
	_line(image, pommel, guard_center, Color("16131a"), blade_width)
	_line(image, pommel, guard_center, OAK_LIGHT, 1)
	var guard_a: Vector2i = guard_center + Vector2i(
		roundi(normal.x * float(guard_half)), roundi(normal.y * float(guard_half))
	)
	var guard_b: Vector2i = guard_center - Vector2i(
		roundi(normal.x * float(guard_half)), roundi(normal.y * float(guard_half))
	)
	_line(image, guard_a, guard_b, GOLD, 3 if size_mode > 0 else 2)
	var blade_start: Vector2i = guard_center + Vector2i(
		roundi(direction.x * 3.0), roundi(direction.y * 3.0)
	)
	_line(image, blade_start, tip, IRON, blade_width)
	_line(image, blade_start, tip, STEEL, 2 if size_mode > 0 else 1)
	var ridge_end: Vector2i = tip - Vector2i(roundi(direction.x * 4.0), roundi(direction.y * 4.0))
	_line(image, blade_start, ridge_end, Color("8f9aa4"), 1)
	_rect(image, Rect2i(tip.x - 1, tip.y - 1, 3, 3), STEEL)


func _draw_mask_fragment(image: Image, center: Vector2i) -> void:
	_rect(image, Rect2i(center.x - 7, center.y - 4, 14, 8), Color("d7d0c9"))
	_rect(image, Rect2i(center.x - 5, center.y + 4, 8, 3), Color("bdb6b1"))
	_rect(image, Rect2i(center.x - 3, center.y - 1, 2, 1), STONE_DARK)
	_line(image, center + Vector2i(1, -4), center + Vector2i(4, 6), CRIMSON, 1)


func _draw_pedestal_base(image: Image, x: int, y: int, width: int) -> void:
	_rect(image, Rect2i(x + 8, y - 8, width - 16, 8), GOLD_DARK)
	_rect(image, Rect2i(x, y, width, 7), STONE_LIGHT)
	_rect(image, Rect2i(x + 7, y + 7, width - 14, 13), STONE)
	_rect(image, Rect2i(x + 18, y + 20, width - 36, 4), STONE_DARK)


func _draw_portrait(variant: int) -> Image:
	var image: Image = _new_image(Vector2i(72, 104))
	# Carved frame, canvas and inner bevel.
	_rect(image, Rect2i(2, 2, 68, 100), GOLD_DARK)
	_rect(image, Rect2i(6, 6, 60, 92), GOLD)
	_rect(image, Rect2i(10, 10, 52, 84), Color("271d28"))
	_rect(image, Rect2i(13, 13, 46, 78), Color("413243"))
	for corner: Vector2i in [Vector2i(4, 4), Vector2i(62, 4), Vector2i(4, 94), Vector2i(62, 94)]:
		_rect(image, Rect2i(corner.x, corner.y, 6, 6), Color("c2a464"))
	# Six distinct faces, hair silhouettes and garments.
	var skin: Color = [Color("c79b7a"), Color("a97861"), Color("d0a889"), Color("a88773"), Color("d9ae8d"), Color("b88570")][variant]
	var hair: Color = [Color("39222a"), Color("24232a"), Color("6b4f3a"), Color("b5ad9d"), Color("5a332c"), Color("251c27")][variant]
	var garment: Color = [Color("6d314b"), Color("283c50"), Color("3f5262"), Color("4c344d"), Color("7a3741"), Color("51405f")][variant]
	var head_x: int = 36 + [-2, 1, 0, 2, -1, 1][variant]
	var head_y: int = 34 + [1, 0, -1, 2, 0, 1][variant]
	_fill_circle(image, Vector2i(head_x, head_y), 10, hair)
	_rect(image, Rect2i(head_x - 7, head_y - 6, 14, 16), skin)
	_rect(image, Rect2i(head_x - 8, head_y - 8, 16, 5), hair)
	if variant in [0, 2, 4, 5]:
		_rect(image, Rect2i(head_x - 10, head_y - 4, 4, 20), hair)
		_rect(image, Rect2i(head_x + 7, head_y - 4, 4, 20), hair)
	else:
		_rect(image, Rect2i(head_x - 9, head_y - 5, 3, 13), hair)
		_rect(image, Rect2i(head_x + 7, head_y - 5, 3, 13), hair)
	# Actual eyes, nose and variant expression.
	_rect(image, Rect2i(head_x - 4, head_y, 2, 2), Color("17151b"))
	_rect(image, Rect2i(head_x + 3, head_y, 2, 2), Color("17151b"))
	_rect(image, Rect2i(head_x, head_y + 3, 1, 3), Color("8e5f55"))
	if variant in [0, 4]:
		_line(image, Vector2i(head_x - 3, head_y + 8), Vector2i(head_x + 3, head_y + 9), Color("7d3f48"), 1)
	else:
		_rect(image, Rect2i(head_x - 3, head_y + 8, 6, 1), Color("6a3541"))
	# Neck, shoulders, sleeves and hands form a readable half-body portrait.
	_rect(image, Rect2i(head_x - 3, head_y + 10, 6, 7), skin)
	_rect(image, Rect2i(19, 53, 34, 34), garment)
	_rect(image, Rect2i(15, 59, 8, 24), garment.darkened(0.18))
	_rect(image, Rect2i(49, 59, 8, 24), garment.darkened(0.18))
	_rect(image, Rect2i(27, 54, 18, 5), Color("d7c2a1"))
	_draw_portrait_prop(image, variant, skin)
	return image


func _draw_portrait_prop(image: Image, variant: int, skin: Color) -> void:
	match variant:
		0: # folded hands and pendant
			_rect(image, Rect2i(29, 72, 6, 4), skin)
			_rect(image, Rect2i(37, 72, 6, 4), skin)
			_rect(image, Rect2i(35, 62, 3, 5), GOLD)
		1: # court sash and seal
			_line(image, Vector2i(23, 57), Vector2i(47, 84), Color("8d2436"), 4)
			_rect(image, Rect2i(42, 75, 6, 6), GOLD)
		2: # open book
			_rect(image, Rect2i(22, 70, 14, 10), Color("c8b38d"))
			_rect(image, Rect2i(36, 70, 14, 10), Color("b9a27e"))
			_line(image, Vector2i(36, 70), Vector2i(36, 81), OAK_DARK, 1)
		3: # cloak clasp and beard
			_rect(image, Rect2i(30, 43, 14, 10), Color("d2c7b3"))
			_rect(image, Rect2i(34, 60, 5, 5), GOLD)
		4: # rose
			_line(image, Vector2i(29, 77), Vector2i(42, 62), Color("517044"), 2)
			_fill_circle(image, Vector2i(44, 60), 4, Color("9b3d55"))
			_rect(image, Rect2i(26, 76, 6, 4), skin)
		5: # fan and pearl row
			for bead_x: int in range(27, 47, 4):
				_rect(image, Rect2i(bead_x, 58, 2, 2), Color("ddd4c4"))
			for ray: int in range(5):
				_line(image, Vector2i(39, 78), Vector2i(30 + ray * 4, 67), Color("c1a875"), 1)


func _draw_stone_arch(blood_variant: bool) -> Image:
	var image: Image = _new_image(Vector2i(192, 224))
	var outer: Color = Color("5a3b44") if blood_variant else STONE_LIGHT
	var inner: Color = Color("2a1b23") if blood_variant else STONE
	# Pixel-stepped arch blocks create a thick structural silhouette.
	for layer: int in range(5):
		var inset: int = layer * 8
		var color: Color = outer.darkened(float(layer) * 0.08)
		_rect(image, Rect2i(8 + inset, 72 + inset / 2, 24, 152 - inset / 2), color)
		_rect(image, Rect2i(160 - inset, 72 + inset / 2, 24, 152 - inset / 2), color)
		_line(image, Vector2i(20 + inset, 84), Vector2i(58 + inset / 2, 28 + inset / 2), color, 17)
		_line(image, Vector2i(172 - inset, 84), Vector2i(134 - inset / 2, 28 + inset / 2), color, 17)
		_rect(image, Rect2i(58 + inset / 2, 16 + inset / 2, 76 - inset, 20), color)
	_rect(image, Rect2i(32, 82, 128, 142), Color("11121a"))
	_rect(image, Rect2i(32, 210, 128, 14), inner)
	for joint_y: int in [92, 126, 160, 194]:
		_rect(image, Rect2i(10, joint_y, 22, 3), STONE_DARK)
		_rect(image, Rect2i(160, joint_y, 22, 3), STONE_DARK)
	if blood_variant:
		_rect(image, Rect2i(44, 94, 104, 116), BLOOD)
		for panel_x: int in [50, 84, 118]:
			_rect(image, Rect2i(panel_x, 102, 24, 98), Color("642635"))
			_rect(image, Rect2i(panel_x + 5, 108, 14, 84), Color("2e1a23"))
		_rect(image, Rect2i(34, 205, 124, 7), GOLD_DARK)
	return image


func _draw_armory_door() -> Image:
	var image: Image = _new_image(Vector2i(128, 224))
	_rect(image, Rect2i(10, 8, 108, 216), STONE_LIGHT)
	_rect(image, Rect2i(18, 16, 92, 208), STONE_DARK)
	_rect(image, Rect2i(24, 22, 80, 202), OAK_DARK)
	for plank_x: int in [40, 60, 80]:
		_rect(image, Rect2i(plank_x, 22, 4, 202), OAK)
	for strap_y: int in [48, 108, 168]:
		_rect(image, Rect2i(22, strap_y, 84, 8), IRON)
		for rivet_x: int in range(28, 102, 18):
			_rect(image, Rect2i(rivet_x, strap_y + 2, 3, 3), STEEL)
	_rect(image, Rect2i(84, 116, 8, 12), GOLD_DARK)
	return image


func _draw_ballroom_door() -> Image:
	var image: Image = _new_image(Vector2i(256, 256))
	_rect(image, Rect2i(4, 70, 248, 186), Color("382332"))
	_line(image, Vector2i(10, 80), Vector2i(70, 20), GOLD_DARK, 18)
	_line(image, Vector2i(246, 80), Vector2i(186, 20), GOLD_DARK, 18)
	_rect(image, Rect2i(70, 10, 116, 22), GOLD_DARK)
	_rect(image, Rect2i(22, 78, 102, 178), BLOOD)
	_rect(image, Rect2i(132, 78, 102, 178), BLOOD)
	for side_x: int in [30, 140]:
		_rect(image, Rect2i(side_x, 86, 86, 160), Color("281925"))
		_rect(image, Rect2i(side_x + 8, 96, 70, 62), Color("4e2739"))
		_rect(image, Rect2i(side_x + 8, 170, 70, 66), Color("4e2739"))
		for stud_y: int in [104, 148, 180, 224]:
			_rect(image, Rect2i(side_x + 5, stud_y, 4, 4), GOLD)
			_rect(image, Rect2i(side_x + 77, stud_y, 4, 4), GOLD)
	_fill_circle(image, Vector2i(128, 69), 26, Color("d5d0c9"))
	_line(image, Vector2i(126, 44), Vector2i(134, 91), CRIMSON, 3)
	_rect(image, Rect2i(119, 166, 8, 12), GOLD)
	_rect(image, Rect2i(129, 166, 8, 12), GOLD)
	return image


func _draw_corridor_door() -> Image:
	var image: Image = _new_image(Vector2i(112, 176))
	_rect(image, Rect2i(4, 4, 104, 172), STONE_LIGHT)
	_rect(image, Rect2i(12, 12, 88, 164), Color("231a21"))
	_rect(image, Rect2i(18, 18, 76, 158), OAK)
	for panel_y: int in [28, 78, 128]:
		_rect(image, Rect2i(25, panel_y, 62, 38), OAK_DARK)
		_rect(image, Rect2i(30, panel_y + 5, 52, 28), OAK_LIGHT.darkened(0.28))
	_rect(image, Rect2i(76, 89, 6, 8), GOLD)
	return image


func _draw_pillar() -> Image:
	var image: Image = _new_image(Vector2i(48, 192))
	_rect(image, Rect2i(4, 0, 40, 15), STONE_LIGHT)
	_rect(image, Rect2i(8, 15, 32, 156), STONE)
	_rect(image, Rect2i(12, 18, 7, 148), STONE_LIGHT.darkened(0.18))
	_rect(image, Rect2i(29, 18, 7, 148), STONE_DARK)
	for y: int in range(28, 165, 28):
		_rect(image, Rect2i(8, y, 32, 2), Color("242832"))
	_rect(image, Rect2i(4, 171, 40, 21), STONE_LIGHT)
	return image


func _draw_wall_niche() -> Image:
	var image: Image = _new_image(Vector2i(96, 144))
	_rect(image, Rect2i(2, 44, 18, 100), STONE_LIGHT)
	_rect(image, Rect2i(76, 44, 18, 100), STONE_LIGHT)
	_line(image, Vector2i(10, 48), Vector2i(36, 14), STONE_LIGHT, 14)
	_line(image, Vector2i(86, 48), Vector2i(60, 14), STONE_LIGHT, 14)
	_rect(image, Rect2i(36, 6, 24, 16), STONE_LIGHT)
	_rect(image, Rect2i(20, 50, 56, 94), Color("10131b"))
	_rect(image, Rect2i(14, 132, 68, 12), STONE)
	return image


func _draw_weapon_rack(spears: bool) -> Image:
	var image: Image = _new_image(Vector2i(128, 112))
	_rect(image, Rect2i(12, 20, 9, 86), OAK_DARK)
	_rect(image, Rect2i(107, 20, 9, 86), OAK_DARK)
	_rect(image, Rect2i(8, 28, 112, 9), OAK)
	_rect(image, Rect2i(8, 79, 112, 9), OAK)
	if spears:
		for x: int in [26, 48, 70, 92]:
			_line(image, Vector2i(x, 100), Vector2i(x + 8, 5), OAK_LIGHT, 3)
			var tip: PackedVector2Array = PackedVector2Array([
				Vector2(x + 4, 4), Vector2(x + 13, 16), Vector2(x + 6, 18),
			])
			_fill_polygon(image, tip, STEEL)
	else:
		for index: int in range(3):
			var x: int = 26 + index * 32
			_line(image, Vector2i(x, 82), Vector2i(x + 20, 20), STEEL, 4)
			_line(image, Vector2i(x - 4, 70), Vector2i(x + 8, 74), GOLD_DARK, 3)
			_line(image, Vector2i(x - 1, 78), Vector2i(x - 6, 94), OAK_DARK, 4)
	return image


func _draw_shield_display() -> Image:
	var image: Image = _new_image(Vector2i(64, 72))
	var shield: PackedVector2Array = PackedVector2Array([
		Vector2(10, 10), Vector2(54, 10), Vector2(57, 39), Vector2(32, 66), Vector2(7, 39),
	])
	_fill_polygon(image, shield, IRON)
	var inner: PackedVector2Array = PackedVector2Array([
		Vector2(15, 15), Vector2(49, 15), Vector2(51, 36), Vector2(32, 58), Vector2(13, 36),
	])
	_fill_polygon(image, inner, CRIMSON)
	_rect(image, Rect2i(28, 13, 8, 42), GOLD_DARK)
	_rect(image, Rect2i(14, 28, 36, 7), GOLD_DARK)
	_fill_circle(image, Vector2i(32, 32), 6, GOLD)
	return image


func _draw_knight_armor() -> Image:
	var image: Image = _new_image(Vector2i(80, 144))
	_rect(image, Rect2i(26, 12, 28, 23), IRON)
	_rect(image, Rect2i(23, 16, 34, 7), STONE_LIGHT)
	_rect(image, Rect2i(28, 24, 24, 4), Color("11131a"))
	_rect(image, Rect2i(21, 36, 38, 49), STONE_LIGHT)
	_rect(image, Rect2i(27, 43, 26, 36), IRON)
	_fill_circle(image, Vector2i(18, 45), 10, IRON)
	_fill_circle(image, Vector2i(62, 45), 10, IRON)
	_rect(image, Rect2i(12, 52, 10, 42), STONE)
	_rect(image, Rect2i(58, 52, 10, 42), STONE)
	_rect(image, Rect2i(22, 84, 36, 12), OAK_DARK)
	_rect(image, Rect2i(24, 96, 13, 34), STONE)
	_rect(image, Rect2i(43, 96, 13, 34), STONE)
	_rect(image, Rect2i(18, 130, 22, 8), IRON)
	_rect(image, Rect2i(40, 130, 22, 8), IRON)
	_rect(image, Rect2i(10, 138, 60, 6), STONE_LIGHT)
	return image


func _draw_banquet_table() -> Image:
	var image: Image = _new_image(Vector2i(192, 88))
	_rect(image, Rect2i(4, 28, 184, 15), OAK_LIGHT)
	_rect(image, Rect2i(8, 43, 176, 9), OAK_DARK)
	_rect(image, Rect2i(20, 52, 14, 36), OAK)
	_rect(image, Rect2i(158, 52, 14, 36), OAK)
	_rect(image, Rect2i(14, 20, 38, 8), Color("703043"))
	_rect(image, Rect2i(140, 20, 38, 8), Color("703043"))
	# Abandoned plates, goblets and fruit read as banquet remnants.
	_rect(image, Rect2i(72, 22, 26, 4), Color("aaa59e"))
	_rect(image, Rect2i(111, 12, 4, 15), GOLD)
	_rect(image, Rect2i(107, 10, 12, 4), GOLD)
	_fill_circle(image, Vector2i(55, 22), 6, Color("7f3c38"))
	_fill_circle(image, Vector2i(128, 21), 5, Color("805f2f"))
	return image


func _draw_bench() -> Image:
	var image: Image = _new_image(Vector2i(128, 48))
	_rect(image, Rect2i(4, 10, 120, 12), OAK_LIGHT)
	_rect(image, Rect2i(12, 22, 10, 26), OAK)
	_rect(image, Rect2i(106, 22, 10, 26), OAK)
	_rect(image, Rect2i(20, 30, 88, 5), OAK_DARK)
	return image


func _draw_crates() -> Image:
	var image: Image = _new_image(Vector2i(96, 80))
	_draw_crate(image, Rect2i(4, 34, 43, 43))
	_draw_crate(image, Rect2i(49, 28, 43, 49))
	_draw_crate(image, Rect2i(28, 2, 42, 34))
	return image


func _draw_crate(image: Image, rect: Rect2i) -> void:
	_rect(image, rect, OAK)
	_rect(image, Rect2i(rect.position + Vector2i(4, 4), rect.size - Vector2i(8, 8)), OAK_DARK)
	_line(image, rect.position + Vector2i(5, 5), rect.end - Vector2i(5, 5), OAK_LIGHT, 3)
	_line(image, Vector2i(rect.end.x - 5, rect.position.y + 5), Vector2i(rect.position.x + 5, rect.end.y - 5), OAK_LIGHT, 3)


func _draw_banner() -> Image:
	var image: Image = _new_image(Vector2i(64, 144))
	_rect(image, Rect2i(5, 2, 54, 8), GOLD_DARK)
	var cloth: PackedVector2Array = PackedVector2Array([
		Vector2(10, 10), Vector2(54, 10), Vector2(52, 124), Vector2(32, 142), Vector2(12, 124),
	])
	_fill_polygon(image, cloth, VELVET)
	_rect(image, Rect2i(16, 20, 32, 92), Color("51283f"))
	_draw_crest_mark(image, Vector2i(32, 63), 1)
	return image


func _draw_altar() -> Image:
	var image: Image = _new_image(Vector2i(160, 104))
	_rect(image, Rect2i(6, 32, 148, 16), STONE_LIGHT)
	_rect(image, Rect2i(14, 48, 132, 48), STONE)
	_rect(image, Rect2i(28, 58, 104, 29), BLOOD)
	_rect(image, Rect2i(2, 96, 156, 8), STONE_LIGHT)
	for x: int in [35, 80, 125]:
		_rect(image, Rect2i(x - 3, 12, 6, 20), Color("d6c3a2"))
		_rect(image, Rect2i(x - 5, 9, 10, 4), CRIMSON)
		_fill_circle(image, Vector2i(x, 6), 4, FLAME)
	_draw_crest_mark(image, Vector2i(80, 72), 1)
	return image


func _draw_bookshelf() -> Image:
	var image: Image = _new_image(Vector2i(128, 160))
	_rect(image, Rect2i(4, 4, 120, 156), OAK_DARK)
	_rect(image, Rect2i(12, 12, 104, 140), OAK)
	for shelf_y: int in [46, 86, 126]:
		_rect(image, Rect2i(10, shelf_y, 108, 8), OAK_LIGHT)
	var book_colors: Array[Color] = [CRIMSON, Color("3d5265"), Color("746032"), Color("4f3359")]
	for row: int in range(3):
		for book: int in range(7):
			var book_height: int = 20 + ((book + row * 2) % 4) * 3
			var x: int = 17 + book * 13
			var bottom: int = 46 + row * 40
			_rect(image, Rect2i(x, bottom - book_height, 9, book_height), book_colors[(book + row) % book_colors.size()])
	return image


func _draw_barrels() -> Image:
	var image: Image = _new_image(Vector2i(96, 96))
	_draw_barrel(image, Vector2i(8, 38))
	_draw_barrel(image, Vector2i(48, 38))
	_draw_barrel(image, Vector2i(28, 4))
	return image


func _draw_barrel(image: Image, position: Vector2i) -> void:
	_rect(image, Rect2i(position.x + 4, position.y, 32, 50), OAK)
	_rect(image, Rect2i(position.x, position.y + 7, 40, 36), OAK_LIGHT.darkened(0.18))
	for band_y: int in [position.y + 10, position.y + 34]:
		_rect(image, Rect2i(position.x, band_y, 40, 5), IRON)
	_rect(image, Rect2i(position.x + 5, position.y + 45, 30, 5), OAK_DARK)


func _draw_drape() -> Image:
	var image: Image = _new_image(Vector2i(128, 192))
	_rect(image, Rect2i(4, 4, 120, 10), GOLD_DARK)
	var cloth: PackedVector2Array = PackedVector2Array([
		Vector2(10, 14), Vector2(118, 14), Vector2(112, 168), Vector2(94, 188),
		Vector2(72, 172), Vector2(50, 190), Vector2(30, 170), Vector2(14, 186),
	])
	_fill_polygon(image, cloth, VELVET)
	for x: int in [28, 52, 76, 100]:
		_line(image, Vector2i(x, 18), Vector2i(x - 5, 166), Color("55334f"), 5)
	_rect(image, Rect2i(8, 22, 112, 8), CRIMSON.darkened(0.25))
	return image


func _draw_wall_sconce() -> Image:
	var image: Image = _new_image(Vector2i(40, 64))
	_rect(image, Rect2i(17, 27, 6, 31), IRON)
	_rect(image, Rect2i(8, 52, 24, 8), IRON)
	_line(image, Vector2i(20, 45), Vector2i(7, 35), IRON, 4)
	_line(image, Vector2i(20, 45), Vector2i(33, 35), IRON, 4)
	_rect(image, Rect2i(4, 31, 10, 5), GOLD_DARK)
	_rect(image, Rect2i(26, 31, 10, 5), GOLD_DARK)
	_rect(image, Rect2i(7, 20, 4, 11), Color("d6c3a2"))
	_rect(image, Rect2i(29, 20, 4, 11), Color("d6c3a2"))
	return image


func _draw_floor_candelabrum() -> Image:
	var image: Image = _new_image(Vector2i(56, 112))
	_rect(image, Rect2i(25, 28, 6, 72), GOLD_DARK)
	_rect(image, Rect2i(15, 100, 26, 7), GOLD)
	_rect(image, Rect2i(7, 107, 42, 5), GOLD_DARK)
	for offset_x: int in [-17, 0, 17]:
		_line(image, Vector2i(28, 54), Vector2i(28 + offset_x, 42), GOLD_DARK, 4)
		_rect(image, Rect2i(25 + offset_x, 23, 6, 19), Color("d7c4a4"))
		_fill_circle(image, Vector2i(28 + offset_x, 18), 5, FLAME)
	return image


func _draw_royal_crest() -> Image:
	var image: Image = _new_image(Vector2i(72, 80))
	var shield: PackedVector2Array = PackedVector2Array([
		Vector2(9, 12), Vector2(63, 12), Vector2(60, 49), Vector2(36, 75), Vector2(12, 49),
	])
	_fill_polygon(image, shield, GOLD_DARK)
	var center: PackedVector2Array = PackedVector2Array([
		Vector2(16, 18), Vector2(56, 18), Vector2(53, 45), Vector2(36, 66), Vector2(19, 45),
	])
	_fill_polygon(image, center, CRIMSON)
	_draw_crest_mark(image, Vector2i(36, 39), 1)
	return image


func _draw_crest_mark(image: Image, center: Vector2i, scale: int) -> void:
	var s: int = maxi(1, scale)
	_line(image, center + Vector2i(-10 * s, 10 * s), center + Vector2i(0, -12 * s), STEEL, 2 * s)
	_line(image, center + Vector2i(10 * s, 10 * s), center + Vector2i(0, -12 * s), STEEL, 2 * s)
	_rect(image, Rect2i(center.x - 3 * s, center.y + 4 * s, 6 * s, 8 * s), GOLD)


func _new_image(size: Vector2i) -> Image:
	return PixelCanvas.create_transparent(size)


func _save(image: Image, relative_path: String) -> int:
	var resource_path: String = ROOT.path_join(relative_path)
	var directory: String = resource_path.get_base_dir()
	var directory_error: Error = DirAccess.make_dir_recursive_absolute(
		ProjectSettings.globalize_path(directory)
	)
	if directory_error != OK:
		return 1
	var error: Error = image.save_png(ProjectSettings.globalize_path(resource_path))
	if error != OK:
		return 1
	_saved_count += 1
	return 0


func _rect(image: Image, rect: Rect2i, color: Color) -> void:
	PixelCanvas.fill_rect(image, rect, color)


func _line(image: Image, start: Vector2i, end: Vector2i, color: Color, thickness: int) -> void:
	PixelCanvas.draw_line(image, start, end, color, thickness)


func _fill_circle(image: Image, center: Vector2i, radius: int, color: Color) -> void:
	for y: int in range(center.y - radius, center.y + radius + 1):
		for x: int in range(center.x - radius, center.x + radius + 1):
			var offset: Vector2i = Vector2i(x, y) - center
			if offset.length_squared() <= radius * radius:
				if x >= 0 and y >= 0 and x < image.get_width() and y < image.get_height():
					image.set_pixel(x, y, color)


func _fill_polygon(image: Image, points: PackedVector2Array, color: Color) -> void:
	if points.size() < 3:
		return
	var min_x: int = image.get_width() - 1
	var max_x: int = 0
	var min_y: int = image.get_height() - 1
	var max_y: int = 0
	for point: Vector2 in points:
		min_x = mini(min_x, floori(point.x))
		max_x = maxi(max_x, ceili(point.x))
		min_y = mini(min_y, floori(point.y))
		max_y = maxi(max_y, ceili(point.y))
	for y: int in range(maxi(0, min_y), mini(image.get_height() - 1, max_y) + 1):
		for x: int in range(maxi(0, min_x), mini(image.get_width() - 1, max_x) + 1):
			if Geometry2D.is_point_in_polygon(Vector2(x + 0.5, y + 0.5), points):
				image.set_pixel(x, y, color)
