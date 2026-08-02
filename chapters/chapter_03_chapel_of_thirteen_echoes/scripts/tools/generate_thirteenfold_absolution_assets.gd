extends SceneTree

## Deterministic W2 exporter for the accepted Thirteenfold Absolution design.

const ActionGenerator: Script = preload("res://scripts/tools/pixel_player_animation_generator.gd")
const M1Generator: Script = preload("res://scripts/tools/pixel_player_m1_animation_generator.gd")
const HurtGenerator: Script = preload("res://scripts/tools/pixel_player_hurt_generator.gd")
const DeathGenerator: Script = preload("res://scripts/tools/pixel_player_death_generator.gd")
const PixelCanvas: Script = preload("res://scripts/tools/pixel_art_canvas.gd")
const Renderer: Script = preload("res://scripts/tools/pixel_assassin_renderer.gd")

const ROOT: String = (
	"res://chapters/chapter_03_chapel_of_thirteen_echoes/assets/weapons/"
	+ "thirteenfold_absolution"
)
const PLAYER_ROOT: String = ROOT + "/animations/player"
const SPRITE_ROOT: String = ROOT + "/sprites"
const EFFECT_ROOT: String = ROOT + "/effects"
const QA_ROOT: String = "res://docs/qa/chapter_03_thirteenfold_absolution/w2"
const STYLE: StringName = &"thirteenfold_absolution"


func _init() -> void:
	var failures: int = 0
	failures += _save_sequences(ActionGenerator.generate_all(STYLE))
	failures += _save_sequences(M1Generator.generate_all(STYLE))
	failures += _save_sequence(&"hurt", HurtGenerator.generate_frames(STYLE))
	failures += _save_sequence(&"hurt_light", HurtGenerator.generate_light_frames(STYLE))
	failures += _save_sequence(&"hurt_heavy", HurtGenerator.generate_heavy_frames(STYLE))
	failures += _save_sequence(&"death", DeathGenerator.generate_death_frames(STYLE))
	failures += _save_presentation_assets()
	failures += _save_effects()
	failures += _save_contact_sheet()
	if failures > 0:
		push_error("THIRTEENFOLD_W2_GENERATOR: FAIL files=%d" % failures)
		quit(1)
		return
	print(
		"THIRTEENFOLD_W2_GENERATOR: PASS "
		+ "animations=30 frames=97 presentation=6 effects=5 contact_sheet=1"
	)
	quit(0)


func _save_sequences(sequences: Dictionary[String, Array]) -> int:
	var failures: int = 0
	for animation_name: String in sequences:
		failures += _save_sequence(StringName(animation_name), sequences[animation_name])
	return failures


func _save_sequence(animation_name: StringName, frames: Array) -> int:
	var directory: String = PLAYER_ROOT.path_join(str(animation_name))
	if DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(directory)) != OK:
		return frames.size()
	var failures: int = 0
	for frame_index: int in range(frames.size()):
		var image: Image = frames[frame_index] as Image
		var path: String = directory.path_join(
			"%s_%02d.png" % [animation_name, frame_index + 1]
		)
		if image == null or image.save_png(path) != OK:
			failures += 1
	return failures


func _save_presentation_assets() -> int:
	if DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(SPRITE_ROOT)) != OK:
		return 6
	var assets: Dictionary[String, Image] = {
		"inventory_icon.png": _draw_inventory_icon(Vector2i(32, 32)),
		"hud_icon.png": _draw_inventory_icon(Vector2i(24, 24)),
		"weapon_pair_reference.png": _draw_weapon_pair(Vector2i(64, 48)),
		"world_pickup.png": _draw_world_pickup(),
		"reliquary_display.png": _draw_reliquary_display(),
		"reliquary_empty.png": _draw_reliquary_empty(),
	}
	var failures: int = 0
	for file_name: String in assets:
		if assets[file_name].save_png(SPRITE_ROOT.path_join(file_name)) != OK:
			failures += 1
	return failures


func _save_effects() -> int:
	if DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(EFFECT_ROOT)) != OK:
		return 5
	var effects: Dictionary[String, Image] = {
		"bone_gold_thrust_trail.png": _draw_thrust_trail(),
		"hollow_bell_afterimage.png": _draw_bell_afterimage(),
		"reliquary_pickup_glow.png": _draw_pickup_glow(),
		"reforging_fragment.png": _draw_reforging_fragment(),
		"extinguished_seal_node.png": _draw_extinguished_seal_node(),
	}
	var failures: int = 0
	for file_name: String in effects:
		if effects[file_name].save_png(EFFECT_ROOT.path_join(file_name)) != OK:
			failures += 1
	return failures


func _save_contact_sheet() -> int:
	if DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(QA_ROOT)) != OK:
		return 1
	var source_paths: Array[String] = [
		PLAYER_ROOT + "/idle/idle_01.png",
		PLAYER_ROOT + "/run/run_02.png",
		PLAYER_ROOT + "/jump_start/jump_start_02.png",
		PLAYER_ROOT + "/attack_1/attack_1_02.png",
		PLAYER_ROOT + "/attack_2/attack_2_02.png",
		PLAYER_ROOT + "/attack_3/attack_3_02.png",
		PLAYER_ROOT + "/dash_attack/dash_attack_03.png",
		PLAYER_ROOT + "/hurt_heavy/hurt_heavy_01.png",
		PLAYER_ROOT + "/death/death_05.png",
		SPRITE_ROOT + "/world_pickup.png",
		SPRITE_ROOT + "/reliquary_display.png",
		SPRITE_ROOT + "/weapon_pair_reference.png",
	]
	var sheet: Image = Image.create(1240, 720, false, Image.FORMAT_RGBA8)
	sheet.fill(Color("090d14"))
	var cell_size: Vector2i = Vector2i(300, 220)
	var margin: Vector2i = Vector2i(20, 20)
	for source_index: int in range(source_paths.size()):
		var source: Image = Image.load_from_file(
			ProjectSettings.globalize_path(source_paths[source_index])
		)
		if source == null or source.is_empty():
			return 1
		var column: int = source_index % 4
		var row: int = source_index / 4
		var cell_origin: Vector2i = margin + Vector2i(column, row) * cell_size
		PixelCanvas.fill_rect(
			sheet,
			Rect2i(cell_origin, Vector2i(280, 200)),
			Color("131a25")
		)
		PixelCanvas.fill_rect(
			sheet,
			Rect2i(cell_origin + Vector2i(8, 8), Vector2i(264, 3)),
			Color("9c7d47") if source_index < 9 else Color("6a3150")
		)
		var scale: int = mini(3, mini(192 / source.get_width(), 176 / source.get_height()))
		scale = maxi(scale, 1)
		var scaled: Image = PixelCanvas.resize_nearest(source, source.get_size() * scale)
		var paste_origin: Vector2i = cell_origin + Vector2i(
			(280 - scaled.get_width()) / 2,
			16 + (176 - scaled.get_height()) / 2
		)
		sheet.blend_rect(scaled, Rect2i(Vector2i.ZERO, scaled.get_size()), paste_origin)
	return int(sheet.save_png(QA_ROOT + "/pixel_contact_sheet.png"))


func _draw_inventory_icon(size: Vector2i) -> Image:
	var image: Image = PixelCanvas.create_transparent(size)
	var scale: float = float(size.x) / 32.0
	var main_hand: Vector2i = Vector2i(roundi(9.0 * scale), roundi(20.0 * scale))
	var main_tip: Vector2i = Vector2i(roundi(27.0 * scale), roundi(7.0 * scale))
	var off_hand: Vector2i = Vector2i(roundi(10.0 * scale), roundi(11.0 * scale))
	var off_tip: Vector2i = Vector2i(roundi(26.0 * scale), roundi(22.0 * scale))
	Renderer.draw_thirteenfold_absolution_blade(image, main_hand, main_tip, true)
	Renderer.draw_thirteenfold_absolution_blade(image, off_hand, off_tip, false)
	return image


func _draw_weapon_pair(size: Vector2i) -> Image:
	var image: Image = PixelCanvas.create_transparent(size)
	Renderer.draw_thirteenfold_absolution_blade(
		image, Vector2i(17, 17), Vector2i(59, 7), true
	)
	Renderer.draw_thirteenfold_absolution_blade(
		image, Vector2i(18, 33), Vector2i(53, 41), false
	)
	return image


func _draw_world_pickup() -> Image:
	var image: Image = PixelCanvas.create_transparent(Vector2i(64, 64))
	Renderer.draw_thirteenfold_absolution_blade(
		image, Vector2i(20, 37), Vector2i(57, 19), true
	)
	Renderer.draw_thirteenfold_absolution_blade(
		image, Vector2i(21, 25), Vector2i(52, 44), false
	)
	# Thirteen extinguished seals rest below the pair; one empty seat stays dark.
	for index: int in range(13):
		var x: int = 7 + index * 4
		var y: int = 53 + (index % 2)
		PixelCanvas.fill_rect(image, Rect2i(x, y, 2, 2), Color("725b38"))
	PixelCanvas.fill_rect(image, Rect2i(59, 53, 2, 2), Color("171c21"))
	return image


func _draw_reliquary_display() -> Image:
	var image: Image = PixelCanvas.create_transparent(Vector2i(96, 64))
	PixelCanvas.fill_rect(image, Rect2i(8, 45, 80, 8), Color("252932"))
	PixelCanvas.fill_rect(image, Rect2i(12, 42, 72, 4), Color("775b35"))
	PixelCanvas.fill_rect(image, Rect2i(18, 39, 60, 3), Color("b08c4f"))
	Renderer.draw_thirteenfold_absolution_blade(
		image, Vector2i(37, 32), Vector2i(77, 11), true
	)
	Renderer.draw_thirteenfold_absolution_blade(
		image, Vector2i(38, 21), Vector2i(71, 38), false
	)
	for index: int in range(13):
		var x: int = 20 + index * 4
		PixelCanvas.fill_rect(image, Rect2i(x, 47, 2, 2), Color("6f5836"))
	PixelCanvas.fill_rect(image, Rect2i(74, 47, 3, 2), Color("11151a"))
	return image


func _draw_reliquary_empty() -> Image:
	var image: Image = PixelCanvas.create_transparent(Vector2i(96, 64))
	PixelCanvas.fill_rect(image, Rect2i(8, 45, 80, 8), Color("252932"))
	PixelCanvas.fill_rect(image, Rect2i(12, 42, 72, 4), Color("775b35"))
	PixelCanvas.fill_rect(image, Rect2i(18, 39, 60, 3), Color("b08c4f"))
	# A shallow bell-shaped recess keeps the empty state readable after collection.
	PixelCanvas.fill_rect(image, Rect2i(38, 31, 20, 8), Color("11151a"))
	PixelCanvas.fill_rect(image, Rect2i(41, 28, 14, 3), Color("252932"))
	PixelCanvas.fill_rect(image, Rect2i(45, 26, 6, 2), Color("775b35"))
	for index: int in range(13):
		var x: int = 20 + index * 4
		PixelCanvas.fill_rect(image, Rect2i(x, 47, 2, 2), Color("6f5836"))
	# The fourteenth seat remains deliberately unfilled and nearly black.
	PixelCanvas.fill_rect(image, Rect2i(74, 47, 3, 2), Color("11151a"))
	return image


func _draw_thrust_trail() -> Image:
	var image: Image = PixelCanvas.create_transparent(Vector2i(64, 32))
	PixelCanvas.draw_line(image, Vector2i(5, 18), Vector2i(57, 8), Color(0.91, 0.92, 0.86, 0.58), 2)
	PixelCanvas.draw_line(image, Vector2i(15, 22), Vector2i(52, 15), Color(0.70, 0.53, 0.28, 0.45), 1)
	PixelCanvas.draw_line(image, Vector2i(25, 24), Vector2i(48, 20), Color(0.44, 0.16, 0.20, 0.28), 1)
	return image


func _draw_bell_afterimage() -> Image:
	var image: Image = PixelCanvas.create_transparent(Vector2i(32, 32))
	var copper: Color = Color(0.69, 0.53, 0.29, 0.42)
	for point: Vector2i in [
		Vector2i(12, 6), Vector2i(13, 5), Vector2i(14, 5), Vector2i(15, 4),
		Vector2i(16, 4), Vector2i(17, 5), Vector2i(18, 5), Vector2i(19, 6),
		Vector2i(8, 11), Vector2i(7, 12), Vector2i(6, 13), Vector2i(6, 14),
		Vector2i(24, 11), Vector2i(25, 12), Vector2i(26, 13), Vector2i(26, 14),
		Vector2i(8, 21), Vector2i(9, 23), Vector2i(11, 25), Vector2i(13, 26),
		Vector2i(24, 21), Vector2i(23, 23), Vector2i(21, 25), Vector2i(19, 26),
	]:
		image.set_pixelv(point, copper)
	return image


func _draw_pickup_glow() -> Image:
	var image: Image = PixelCanvas.create_transparent(Vector2i(64, 64))
	for inset: int in range(8):
		var alpha: float = 0.05 + float(7 - inset) * 0.015
		var color: Color = Color(0.84, 0.78, 0.58, alpha)
		PixelCanvas.draw_line(image, Vector2i(12 + inset, 18), Vector2i(32, 6 + inset), color, 1)
		PixelCanvas.draw_line(image, Vector2i(32, 6 + inset), Vector2i(52 - inset, 18), color, 1)
		PixelCanvas.draw_line(image, Vector2i(12 + inset, 46), Vector2i(32, 58 - inset), color, 1)
		PixelCanvas.draw_line(image, Vector2i(32, 58 - inset), Vector2i(52 - inset, 46), color, 1)
	return image


func _draw_reforging_fragment() -> Image:
	var image: Image = PixelCanvas.create_transparent(Vector2i(16, 16))
	PixelCanvas.fill_rect(image, Rect2i(4, 6, 8, 4), Color("252932"))
	PixelCanvas.fill_rect(image, Rect2i(6, 4, 5, 3), Color("765b35"))
	PixelCanvas.fill_rect(image, Rect2i(8, 5, 3, 2), Color("b08c4f"))
	PixelCanvas.fill_rect(image, Rect2i(5, 10, 4, 2), Color("d6d8d2"))
	PixelCanvas.fill_rect(image, Rect2i(9, 10, 2, 1), Color("843743"))
	return image


func _draw_extinguished_seal_node() -> Image:
	var image: Image = PixelCanvas.create_transparent(Vector2i(12, 12))
	PixelCanvas.fill_rect(image, Rect2i(3, 2, 6, 8), Color("3b3028"))
	PixelCanvas.fill_rect(image, Rect2i(2, 4, 8, 4), Color("765b35"))
	PixelCanvas.fill_rect(image, Rect2i(4, 3, 4, 6), Color("16191f"))
	PixelCanvas.fill_rect(image, Rect2i(5, 4, 2, 3), Color("2c333d"))
	return image
