extends SceneTree

## Deterministic W1/W2 exporter for Soul-Lock Twin Keys and the Last Soul Lock reveal.

const ActionGenerator: Script = preload("res://scripts/tools/pixel_player_animation_generator.gd")
const M1Generator: Script = preload("res://scripts/tools/pixel_player_m1_animation_generator.gd")
const HurtGenerator: Script = preload("res://scripts/tools/pixel_player_hurt_generator.gd")
const DeathGenerator: Script = preload("res://scripts/tools/pixel_player_death_generator.gd")
const PixelCanvas: Script = preload("res://scripts/tools/pixel_art_canvas.gd")
const Renderer: Script = preload("res://scripts/tools/pixel_assassin_renderer.gd")

const ROOT: String = (
	"res://chapters/chapter_04_drowned_underkeep/assets/weapons/soul_lock_twin_keys"
)
const PLAYER_ROOT: String = ROOT + "/animations/player"
const SPRITE_ROOT: String = ROOT + "/sprites"
const EFFECT_ROOT: String = ROOT + "/effects"
const QA_ROOT: String = "res://docs/qa/chapter_04_soul_lock_twin_keys/w2"
const STYLE: StringName = &"soul_lock_twin_keys"


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
		push_error("SOUL_LOCK_W1_W2_GENERATOR: FAIL files=%d" % failures)
		quit(1)
		return
	print(
		"SOUL_LOCK_W1_W2_GENERATOR: PASS animations=30 frames=97 "
		+ "presentation=6 effects=8 contact_sheet=1"
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
		"weapon_pair_reference.png": _draw_weapon_pair(Vector2i(72, 52)),
		"world_pickup.png": _draw_world_pickup(),
		"reliquary_display.png": _draw_reliquary(false),
		"reliquary_empty.png": _draw_reliquary(true),
	}
	var failures: int = 0
	for file_name: String in assets:
		if assets[file_name].save_png(SPRITE_ROOT.path_join(file_name)) != OK:
			failures += 1
	return failures


func _save_effects() -> int:
	if DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(EFFECT_ROOT)) != OK:
		return 8
	var effects: Dictionary[String, Image] = {
		"soul_cage_break.png": _draw_soul_cage_break(),
		"soul_release.png": _draw_soul_release(),
		"chain_pull.png": _draw_chain_pull(),
		"reliquary_submerged.png": _draw_reliquary_stage(0),
		"reliquary_raised.png": _draw_reliquary_stage(1),
		"lockbreaker_formation.png": _draw_formation(true),
		"soulseal_formation.png": _draw_formation(false),
		"pickup_glow.png": _draw_pickup_glow(),
	}
	var failures: int = 0
	for file_name: String in effects:
		if effects[file_name].save_png(EFFECT_ROOT.path_join(file_name)) != OK:
			failures += 1
	return failures


func _save_contact_sheet() -> int:
	if DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(QA_ROOT)) != OK:
		return 1
	var paths: Array[String] = [
		PLAYER_ROOT + "/idle/idle_01.png",
		PLAYER_ROOT + "/run/run_02.png",
		PLAYER_ROOT + "/jump_loop/jump_loop_01.png",
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
	sheet.fill(Color("071116"))
	for index: int in range(paths.size()):
		var source: Image = Image.load_from_file(ProjectSettings.globalize_path(paths[index]))
		if source == null or source.is_empty():
			return 1
		var origin: Vector2i = Vector2i(20 + (index % 4) * 300, 20 + (index / 4) * 220)
		PixelCanvas.fill_rect(sheet, Rect2i(origin, Vector2i(280, 200)), Color("111b20"))
		PixelCanvas.fill_rect(sheet, Rect2i(origin + Vector2i(8, 8), Vector2i(264, 3)), Color("729da0"))
		var scale: int = maxi(1, mini(3, mini(192 / source.get_width(), 176 / source.get_height())))
		var scaled: Image = PixelCanvas.resize_nearest(source, source.get_size() * scale)
		var paste: Vector2i = origin + Vector2i((280 - scaled.get_width()) / 2, 16 + (176 - scaled.get_height()) / 2)
		sheet.blend_rect(scaled, Rect2i(Vector2i.ZERO, scaled.get_size()), paste)
	return int(sheet.save_png(QA_ROOT + "/pixel_contact_sheet.png"))


func _draw_inventory_icon(size: Vector2i) -> Image:
	var image: Image = PixelCanvas.create_transparent(size)
	var factor: float = float(size.x) / 32.0
	Renderer.draw_soul_lock_twin_key(
		image,
		Vector2i(roundi(9.0 * factor), roundi(21.0 * factor)),
		Vector2i(roundi(27.0 * factor), roundi(6.0 * factor)),
		true
	)
	Renderer.draw_soul_lock_twin_key(
		image,
		Vector2i(roundi(9.0 * factor), roundi(10.0 * factor)),
		Vector2i(roundi(27.0 * factor), roundi(23.0 * factor)),
		false
	)
	return image


func _draw_weapon_pair(size: Vector2i) -> Image:
	var image: Image = PixelCanvas.create_transparent(size)
	Renderer.draw_soul_lock_twin_key(image, Vector2i(17, 17), Vector2i(66, 6), true)
	Renderer.draw_soul_lock_twin_key(image, Vector2i(17, 35), Vector2i(59, 45), false)
	return image


func _draw_world_pickup() -> Image:
	var image: Image = PixelCanvas.create_transparent(Vector2i(72, 64))
	Renderer.draw_soul_lock_twin_key(image, Vector2i(21, 39), Vector2i(66, 14), true)
	Renderer.draw_soul_lock_twin_key(image, Vector2i(21, 24), Vector2i(60, 47), false)
	return image


func _draw_reliquary(empty: bool) -> Image:
	var image: Image = PixelCanvas.create_transparent(Vector2i(112, 80))
	PixelCanvas.fill_rect(image, Rect2i(8, 57, 96, 11), Color("152128"))
	PixelCanvas.fill_rect(image, Rect2i(12, 53, 88, 6), Color("48535a"))
	PixelCanvas.fill_rect(image, Rect2i(20, 49, 72, 5), Color("7c4b32"))
	PixelCanvas.fill_rect(image, Rect2i(29, 42, 54, 7), Color("0b151a"))
	if empty:
		PixelCanvas.fill_rect(image, Rect2i(39, 44, 34, 3), Color("26343a"))
		return image
	Renderer.draw_soul_lock_twin_key(image, Vector2i(39, 37), Vector2i(90, 14), true)
	Renderer.draw_soul_lock_twin_key(image, Vector2i(39, 22), Vector2i(82, 46), false)
	return image


func _draw_soul_cage_break() -> Image:
	var image: Image = PixelCanvas.create_transparent(Vector2i(96, 96))
	var iron: Color = Color("526064")
	for index: int in range(6):
		var x: int = 24 + index * 10
		PixelCanvas.draw_line(image, Vector2i(x, 18), Vector2i(x - 8 + index % 3, 76), iron, 2)
	PixelCanvas.draw_line(image, Vector2i(18, 32), Vector2i(77, 27), Color("7c4b32"), 3)
	PixelCanvas.draw_line(image, Vector2i(16, 64), Vector2i(80, 57), Color("7c4b32"), 3)
	return image


func _draw_soul_release() -> Image:
	var image: Image = PixelCanvas.create_transparent(Vector2i(64, 96))
	for index: int in range(9):
		var y: int = 82 - index * 8
		var width: int = 18 - index
		PixelCanvas.fill_rect(image, Rect2i(32 - width / 2, y, width, 3), Color(0.46, 0.74, 0.78, 0.16 + index * 0.035))
	return image


func _draw_chain_pull() -> Image:
	var image: Image = PixelCanvas.create_transparent(Vector2i(96, 64))
	for index: int in range(8):
		var center: Vector2i = Vector2i(10 + index * 11, 39 - (index % 2) * 5)
		PixelCanvas.fill_rect(image, Rect2i(center.x - 3, center.y - 2, 7, 5), Color("536164"))
		PixelCanvas.fill_rect(image, Rect2i(center.x - 1, center.y - 1, 3, 3), Color(0, 0, 0, 0))
	return image


func _draw_reliquary_stage(raised: int) -> Image:
	var image: Image = _draw_reliquary(false)
	if raised == 0:
		PixelCanvas.fill_rect(image, Rect2i(0, 51, 112, 29), Color(0.08, 0.25, 0.30, 0.76))
		for y: int in range(54, 80, 7):
			PixelCanvas.draw_line(image, Vector2i(0, y), Vector2i(111, y - 2), Color(0.30, 0.56, 0.61, 0.55), 1)
	return image


func _draw_formation(is_main: bool) -> Image:
	var image: Image = PixelCanvas.create_transparent(Vector2i(80, 64))
	Renderer.draw_soul_lock_twin_key(
		image,
		Vector2i(22, 42 if is_main else 22),
		Vector2i(72, 13 if is_main else 48),
		is_main
	)
	for radius: int in [9, 14, 20]:
		PixelCanvas.draw_line(image, Vector2i(19, 32 - radius / 3), Vector2i(19 + radius, 32), Color(0.43, 0.72, 0.75, 0.22), 1)
	return image


func _draw_pickup_glow() -> Image:
	var image: Image = PixelCanvas.create_transparent(Vector2i(80, 80))
	for inset: int in range(10):
		var color: Color = Color(0.42, 0.73, 0.76, 0.035 + float(9 - inset) * 0.012)
		PixelCanvas.draw_line(image, Vector2i(10 + inset, 25), Vector2i(40, 5 + inset), color, 1)
		PixelCanvas.draw_line(image, Vector2i(40, 5 + inset), Vector2i(70 - inset, 25), color, 1)
		PixelCanvas.draw_line(image, Vector2i(10 + inset, 55), Vector2i(40, 75 - inset), color, 1)
		PixelCanvas.draw_line(image, Vector2i(40, 75 - inset), Vector2i(70 - inset, 55), color, 1)
	return image
