extends SceneTree

## Builds deterministic, reviewable QA boards from the authoritative concept and
## formal runtime pixels. This script never changes gameplay resources.

const ROOT: String = "res://chapters/chapter_04_drowned_underkeep/assets/enemies/mirefin_raider"
const OUTPUT: String = "res://docs/qa/chapter_04_character_replication/mirefin_raider"
const CONCEPT: String = ROOT + "/concept_art/mirefin_raider_concept_sheet.png"
const NEW_IDLE: String = ROOT + "/sprites/idle/idle_01.png"
const OLD_IDLE: String = ROOT + "/archive_legacy/c4_96px_v1/sprites/idle/idle_01.png"
const CLEAR: Color = Color(0.0, 0.0, 0.0, 0.0)
const BACKGROUND: Color = Color("111820")
const PANEL: Color = Color("202a32")
const CONCEPT_COLOR: Color = Color(0.91, 0.26, 0.24, 0.62)
const SPRITE_COLOR: Color = Color(0.20, 0.83, 0.88, 0.70)

const ANIMATIONS: Array[String] = [
	"idle", "walk", "alert", "turn", "light_hit", "hurt", "stagger",
	"claw_swipe_windup", "claw_swipe_active", "claw_swipe_recovery",
	"mire_lunge_windup", "mire_lunge_active", "mire_lunge_recovery",
	"fin_bite_windup", "fin_bite_active", "fin_bite_recovery", "death",
]


func _initialize() -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUTPUT))
	var concept: Image = Image.load_from_file(ProjectSettings.globalize_path(CONCEPT))
	var sprite: Image = Image.load_from_file(ProjectSettings.globalize_path(NEW_IDLE))
	var legacy: Image = Image.load_from_file(ProjectSettings.globalize_path(OLD_IDLE))
	if concept == null or concept.is_empty() or sprite == null or sprite.is_empty() or legacy == null or legacy.is_empty():
		push_error("MIRE FIN QA: required image missing")
		quit(1)
		return
	_write_concept_side(concept)
	_write_sprite_zoom(sprite)
	_write_old_new(legacy, sprite)
	_write_silhouette_overlay(concept, sprite)
	_write_palette_board()
	_write_feature_closeups(sprite)
	_write_animation_matrix()
	print("MIRE FIN REPLICATION QA BOARDS | PASS output=%s" % OUTPUT)
	quit(0)


func _write_concept_side(concept: Image) -> void:
	var crop: Image = concept.get_region(Rect2i(550, 0, 565, 500))
	crop.save_png(ProjectSettings.globalize_path(OUTPUT + "/concept_side_reference.png"))


func _write_sprite_zoom(sprite: Image) -> void:
	var zoom: Image = sprite.duplicate()
	zoom.resize(1024, 1024, Image.INTERPOLATE_NEAREST)
	zoom.save_png(ProjectSettings.globalize_path(OUTPUT + "/formal_sprite_idle_8x.png"))


func _write_old_new(legacy: Image, sprite: Image) -> void:
	var board: Image = Image.create(1400, 720, false, Image.FORMAT_RGBA8)
	board.fill(BACKGROUND)
	var old_zoom: Image = legacy.duplicate()
	old_zoom.resize(576, 576, Image.INTERPOLATE_NEAREST)
	var new_zoom: Image = sprite.duplicate()
	new_zoom.resize(576, 576, Image.INTERPOLATE_NEAREST)
	_blit_alpha(board, old_zoom, Vector2i(60, 72))
	_blit_alpha(board, new_zoom, Vector2i(764, 72))
	_draw_border(board, Rect2i(48, 60, 600, 600), Color("754538"), 4)
	_draw_border(board, Rect2i(752, 60, 600, 600), Color("73b7ba"), 4)
	board.save_png(ProjectSettings.globalize_path(OUTPUT + "/legacy_vs_replication.png"))


func _write_silhouette_overlay(concept: Image, sprite: Image) -> void:
	# The concept sheet contains its approved black side silhouette in this crop.
	var concept_crop: Image = concept.get_region(Rect2i(1150, 0, 386, 510))
	var concept_mask: Image = _luminance_mask(concept_crop, 0.22)
	var sprite_mask: Image = _alpha_mask(sprite)
	var concept_bounds: Rect2i = _opaque_bounds(concept_mask)
	var sprite_bounds: Rect2i = _opaque_bounds(sprite_mask)
	var board: Image = Image.create(1024, 640, false, Image.FORMAT_RGBA8)
	board.fill(BACKGROUND)
	_draw_aligned_mask(board, concept_mask, concept_bounds, 480, 96, CONCEPT_COLOR)
	_draw_aligned_mask(board, sprite_mask, sprite_bounds, 480, 544, SPRITE_COLOR)
	# The center pane overlays both at a shared baseline and body height.
	_draw_aligned_mask(board, concept_mask, concept_bounds, 480, 320, CONCEPT_COLOR)
	_draw_aligned_mask(board, sprite_mask, sprite_bounds, 480, 320, SPRITE_COLOR)
	for x: int in range(0, board.get_width()):
		board.set_pixel(x, 544, Color("a8b8b8"))
	board.save_png(ProjectSettings.globalize_path(OUTPUT + "/silhouette_alignment_overlay.png"))


func _write_palette_board() -> void:
	var colors: Array[Color] = [
		Color("071015"), Color("1d3433"), Color("355452"), Color("5f7972"),
		Color("94aaa0"), Color("5f6259"), Color("a7a493"), Color("d0c9b3"),
		Color("391f27"), Color("7d3b42"), Color("2c211c"), Color("86543b"),
		Color("263238"), Color("607178"), Color("a0b0ad"), Color("6eb4ba"),
		Color("c6ece5"),
	]
	var board: Image = Image.create(1024, 384, false, Image.FORMAT_RGBA8)
	board.fill(BACKGROUND)
	for index: int in range(colors.size()):
		var column: int = index % 9
		var row: int = index / 9
		board.fill_rect(Rect2i(44 + column * 104, 48 + row * 144, 82, 96), colors[index])
		_draw_border(board, Rect2i(42 + column * 104, 46 + row * 144, 86, 100), Color("d0c9b3"), 2)
	board.save_png(ProjectSettings.globalize_path(OUTPUT + "/palette_comparison.png"))


func _write_feature_closeups(sprite: Image) -> void:
	var board: Image = Image.create(1600, 400, false, Image.FORMAT_RGBA8)
	board.fill(BACKGROUND)
	var feature_rects: Array[Rect2i] = [
		Rect2i(66, 10, 62, 46), # skull, eye, jaw, teeth, and gill cage
		Rect2i(42, 4, 58, 58), # complete dorsal ridge and wet-scaled back
		Rect2i(74, 56, 54, 50), # near long arm, webbing, and four claws
		Rect2i(0, 70, 58, 48), # rear claw, ankle shackle, and chain
	]
	for index: int in range(feature_rects.size()):
		var crop: Image = sprite.get_region(feature_rects[index])
		var scale: int = mini(6, mini(320 / maxi(1, crop.get_width()), 320 / maxi(1, crop.get_height())))
		crop.resize(crop.get_width() * scale, crop.get_height() * scale, Image.INTERPOLATE_NEAREST)
		var panel: Rect2i = Rect2i(24 + index * 394, 24, 370, 352)
		_draw_border(board, panel, Color("73b7ba"), 3)
		var offset: Vector2i = Vector2i(
			panel.position.x + (panel.size.x - crop.get_width()) / 2,
			panel.position.y + (panel.size.y - crop.get_height()) / 2
		)
		_blit_alpha(board, crop, offset)
	board.save_png(ProjectSettings.globalize_path(OUTPUT + "/feature_detail_closeups.png"))


func _write_animation_matrix() -> void:
	var board: Image = Image.create(128 * 5, 128 * ANIMATIONS.size(), false, Image.FORMAT_RGBA8)
	board.fill(CLEAR)
	for row: int in range(ANIMATIONS.size()):
		var animation: String = ANIMATIONS[row]
		var directory: String = "%s/sprites/%s" % [ROOT, animation]
		var files: PackedStringArray = _png_files(directory)
		for column: int in range(mini(5, files.size())):
			var frame: Image = Image.load_from_file(ProjectSettings.globalize_path("%s/%s" % [directory, files[column]]))
			if frame != null and not frame.is_empty():
				_blit_alpha(board, frame, Vector2i(column * 128, row * 128))
	board.save_png(ProjectSettings.globalize_path(OUTPUT + "/animation_structure_matrix.png"))


func _png_files(directory: String) -> PackedStringArray:
	var files: PackedStringArray = PackedStringArray()
	var access: DirAccess = DirAccess.open(directory)
	if access == null:
		return files
	for file_name: String in access.get_files():
		if file_name.ends_with(".png"):
			files.append(file_name)
	files.sort()
	return files


func _luminance_mask(source: Image, threshold: float) -> Image:
	var mask: Image = Image.create(source.get_width(), source.get_height(), false, Image.FORMAT_RGBA8)
	mask.fill(CLEAR)
	for y: int in range(source.get_height()):
		for x: int in range(source.get_width()):
			var color: Color = source.get_pixel(x, y)
			var luminance: float = color.r * 0.2126 + color.g * 0.7152 + color.b * 0.0722
			if luminance <= threshold:
				mask.set_pixel(x, y, Color.WHITE)
	return mask


func _alpha_mask(source: Image) -> Image:
	var mask: Image = Image.create(source.get_width(), source.get_height(), false, Image.FORMAT_RGBA8)
	mask.fill(CLEAR)
	for y: int in range(source.get_height()):
		for x: int in range(source.get_width()):
			if source.get_pixel(x, y).a > 0.05:
				mask.set_pixel(x, y, Color.WHITE)
	return mask


func _opaque_bounds(image: Image) -> Rect2i:
	var min_x: int = image.get_width()
	var min_y: int = image.get_height()
	var max_x: int = -1
	var max_y: int = -1
	for y: int in range(image.get_height()):
		for x: int in range(image.get_width()):
			if image.get_pixel(x, y).a <= 0.05:
				continue
			min_x = mini(min_x, x)
			min_y = mini(min_y, y)
			max_x = maxi(max_x, x)
			max_y = maxi(max_y, y)
	if max_x < min_x or max_y < min_y:
		return Rect2i(Vector2i.ZERO, image.get_size())
	return Rect2i(min_x, min_y, max_x - min_x + 1, max_y - min_y + 1)


func _draw_aligned_mask(
	board: Image,
	mask: Image,
	bounds: Rect2i,
	target_height: int,
	center_x: int,
	color: Color
) -> void:
	var crop: Image = mask.get_region(bounds)
	var scale: float = float(target_height) / float(maxi(1, crop.get_height()))
	var target_width: int = maxi(1, roundi(crop.get_width() * scale))
	crop.resize(target_width, target_height, Image.INTERPOLATE_NEAREST)
	var destination: Vector2i = Vector2i(center_x - target_width / 2, 544 - target_height)
	for y: int in range(crop.get_height()):
		for x: int in range(crop.get_width()):
			if crop.get_pixel(x, y).a > 0.05:
				var target: Vector2i = destination + Vector2i(x, y)
				if target.x >= 0 and target.x < board.get_width() and target.y >= 0 and target.y < board.get_height():
					var existing: Color = board.get_pixelv(target)
					board.set_pixelv(target, existing.blend(color))


func _blit_alpha(destination: Image, source: Image, offset: Vector2i) -> void:
	destination.blend_rect(source, Rect2i(Vector2i.ZERO, source.get_size()), offset)


func _draw_border(image: Image, rect: Rect2i, color: Color, thickness: int) -> void:
	image.fill_rect(Rect2i(rect.position, Vector2i(rect.size.x, thickness)), color)
	image.fill_rect(Rect2i(rect.position + Vector2i(0, rect.size.y - thickness), Vector2i(rect.size.x, thickness)), color)
	image.fill_rect(Rect2i(rect.position, Vector2i(thickness, rect.size.y)), color)
	image.fill_rect(Rect2i(rect.position + Vector2i(rect.size.x - thickness, 0), Vector2i(thickness, rect.size.y)), color)
