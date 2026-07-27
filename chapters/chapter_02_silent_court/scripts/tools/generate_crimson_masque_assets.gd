extends SceneTree

## Generates original low-resolution Crimson Masque weapon and Player art.

const ActionGenerator: Script = preload("res://scripts/tools/pixel_player_animation_generator.gd")
const M1Generator: Script = preload("res://scripts/tools/pixel_player_m1_animation_generator.gd")
const HurtGenerator: Script = preload("res://scripts/tools/pixel_player_hurt_generator.gd")
const DeathGenerator: Script = preload("res://scripts/tools/pixel_player_death_generator.gd")
const PixelCanvas: Script = preload("res://scripts/tools/pixel_art_canvas.gd")

const OUTPUT_ROOT: String = (
	"res://chapters/chapter_02_silent_court/assets/weapons/crimson_masque_stilettos"
)
const PLAYER_ROOT: String = OUTPUT_ROOT + "/sprites/player"
const ICON_ROOT: String = OUTPUT_ROOT + "/icons"
const WORLD_ROOT: String = OUTPUT_ROOT + "/sprites"


func _init() -> void:
	var failures: int = 0
	failures += _save_sequences(ActionGenerator.generate_all(&"crimson_masque"))
	failures += _save_sequences(M1Generator.generate_all(&"crimson_masque"))
	failures += _save_sequence(&"hurt", HurtGenerator.generate_frames(&"crimson_masque"))
	failures += _save_sequence(&"death", DeathGenerator.generate_death_frames(&"crimson_masque"))
	failures += _save_presentation_assets()
	if failures > 0:
		push_error("Crimson Masque generation failed for %d files" % failures)
		quit(1)
		return
	print("CRIMSON_MASQUE_ASSETS: PASS animations=16 frames=49 icons=2 pickup=1")
	quit(0)


func _save_sequences(sequences: Dictionary[String, Array]) -> int:
	var failures: int = 0
	for animation_name: String in sequences:
		failures += _save_sequence(StringName(animation_name), sequences[animation_name])
	return failures


func _save_sequence(animation_name: StringName, frames: Array) -> int:
	var directory: String = PLAYER_ROOT.path_join(str(animation_name))
	var directory_error: Error = DirAccess.make_dir_recursive_absolute(
		ProjectSettings.globalize_path(directory)
	)
	if directory_error != OK:
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
	var failures: int = 0
	for directory: String in [ICON_ROOT, WORLD_ROOT]:
		if DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(directory)) != OK:
			return 3
	var icon: Image = _draw_icon()
	for name: String in ["inventory_icon.png", "hud_icon.png"]:
		if icon.save_png(ICON_ROOT.path_join(name)) != OK:
			failures += 1
	if _draw_world_pickup().save_png(WORLD_ROOT.path_join("world_pickup.png")) != OK:
		failures += 1
	return failures


func _draw_icon() -> Image:
	var image: Image = PixelCanvas.create_transparent(Vector2i(32, 32))
	_draw_stiletto(image, Vector2i(25, 9), Vector2i(6, 14), true)
	_draw_stiletto(image, Vector2i(25, 23), Vector2i(8, 18), false)
	# Broken porcelain mask links the pair to Seraphine without hiding either blade.
	PixelCanvas.fill_rect(image, Rect2i(13, 12, 6, 2), Color("ded8cf"))
	PixelCanvas.fill_rect(image, Rect2i(12, 14, 7, 3), Color("c9c1b8"))
	PixelCanvas.fill_rect(image, Rect2i(15, 15, 2, 1), Color("7d2130"))
	return image


func _draw_world_pickup() -> Image:
	var image: Image = PixelCanvas.create_transparent(Vector2i(64, 64))
	# Two ceremonial stilettos rest beside the Duchess's broken mask.
	_draw_stiletto(image, Vector2i(52, 26), Vector2i(13, 40), true)
	_draw_stiletto(image, Vector2i(51, 43), Vector2i(17, 31), false)
	PixelCanvas.fill_rect(image, Rect2i(25, 27, 12, 3), Color("ded8cf"))
	PixelCanvas.fill_rect(image, Rect2i(22, 30, 15, 7), Color("c9c1b8"))
	PixelCanvas.fill_rect(image, Rect2i(22, 36, 7, 3), Color("c9c1b8"))
	PixelCanvas.fill_rect(image, Rect2i(29, 32, 2, 2), Color("10131b"))
	PixelCanvas.draw_line(image, Vector2i(29, 27), Vector2i(26, 37), Color("7d2130"), 1)
	PixelCanvas.fill_rect(image, Rect2i(12, 51, 42, 2), Color(0.48, 0.15, 0.21, 0.35))
	return image


func _draw_stiletto(image: Image, handle: Vector2i, tip: Vector2i, is_main: bool) -> void:
	var direction: Vector2 = Vector2(tip - handle).normalized()
	var normal: Vector2 = Vector2(-direction.y, direction.x)
	var start: Vector2i = handle + Vector2i(roundi(direction.x * 4.0), roundi(direction.y * 4.0))
	PixelCanvas.draw_line(image, start, tip, Color("59636e"), 3 if is_main else 4)
	PixelCanvas.draw_line(image, start, tip, Color("edf0ed"), 1)
	var groove_start: Vector2i = start + Vector2i(roundi(direction.x * 3.0), roundi(direction.y * 3.0))
	var groove_end: Vector2i = tip - Vector2i(roundi(direction.x * 3.0), roundi(direction.y * 3.0))
	PixelCanvas.draw_line(image, groove_start, groove_end, Color("7d2130"), 1)
	var guard_a: Vector2i = handle + Vector2i(roundi(normal.x * 4.0), roundi(normal.y * 4.0))
	var guard_b: Vector2i = handle - Vector2i(roundi(normal.x * 4.0), roundi(normal.y * 4.0))
	PixelCanvas.draw_line(image, guard_a, guard_b, Color("ded8cf"), 2)
	if not is_main:
		PixelCanvas.draw_line(image, handle, guard_a + Vector2i(roundi(direction.x * 2.0), roundi(direction.y * 2.0)), Color("7d2130"), 1)
	var pommel: Vector2i = handle - Vector2i(roundi(direction.x * 6.0), roundi(direction.y * 6.0))
	PixelCanvas.draw_line(image, handle, pommel, Color("07090e"), 3)
	PixelCanvas.fill_rect(image, Rect2i(pommel.x - 1, pommel.y - 1, 3, 3), Color("7d2130"))
