class_name PixelCastleGuardGenerator
extends RefCounted

## Deterministically draws the original Castle Guard at gameplay resolution.

const PixelCanvas: Script = preload("res://scripts/tools/pixel_art_canvas.gd")

const OUTPUT_ROOT: String = "res://assets/sprites/enemies/castle_guard"
const CONTACT_SHEET_PATH: String = "res://docs/qa/castle_guard_animation_sheet.png"
const FRAME_COUNTS: Dictionary[StringName, int] = {
	&"idle": 4,
	&"walk": 6,
	&"attack": 5,
	&"hurt": 3,
	&"death": 6,
}
const ANIMATION_ORDER: Array[StringName] = [&"idle", &"walk", &"attack", &"hurt", &"death"]

const OUTLINE: Color = Color("091018")
const ARMOR_DARK: Color = Color("182833")
const ARMOR_MID: Color = Color("435866")
const ARMOR_LIGHT: Color = Color("71828a")
const STEEL: Color = Color("bac4c5")
const RUST: Color = Color("8a5838")
const RUST_DARK: Color = Color("49332f")
const EYE_GLOW: Color = Color("a9434d")


static func generate_all() -> Dictionary[StringName, Array]:
	var sequences: Dictionary[StringName, Array] = {}
	for animation_name: StringName in ANIMATION_ORDER:
		var frames: Array[Image] = []
		for frame_index: int in range(FRAME_COUNTS[animation_name]):
			frames.append(_draw_frame(animation_name, frame_index))
		sequences[animation_name] = frames
	return sequences


static func save_all(sequences: Dictionary[StringName, Array]) -> Dictionary[String, int]:
	var results: Dictionary[String, int] = {}
	var output_error: Error = DirAccess.make_dir_recursive_absolute(
		ProjectSettings.globalize_path(OUTPUT_ROOT)
	)
	if output_error != OK:
		results[OUTPUT_ROOT] = output_error
		return results
	for animation_name: StringName in ANIMATION_ORDER:
		var animation_directory: String = OUTPUT_ROOT.path_join(str(animation_name))
		var directory_error: Error = DirAccess.make_dir_recursive_absolute(
			ProjectSettings.globalize_path(animation_directory)
		)
		if directory_error != OK:
			results[animation_directory] = directory_error
			continue
		var frames: Array = sequences[animation_name]
		for frame_index: int in range(frames.size()):
			var file_path: String = animation_directory.path_join(
				"%s_%02d.png" % [animation_name, frame_index + 1]
			)
			var image: Image = frames[frame_index] as Image
			results[file_path] = image.save_png(file_path)
	results[CONTACT_SHEET_PATH] = _save_contact_sheet(sequences)
	return results


static func _save_contact_sheet(sequences: Dictionary[StringName, Array]) -> Error:
	var directory_error: Error = DirAccess.make_dir_recursive_absolute(
		ProjectSettings.globalize_path(CONTACT_SHEET_PATH.get_base_dir())
	)
	if directory_error != OK:
		return directory_error
	var scale_factor: int = 3
	var cell_size: Vector2i = Vector2i(64, 64) * scale_factor
	var margin: int = 12
	var sheet_size: Vector2i = Vector2i(
		margin * 2 + cell_size.x * 6,
		margin * 2 + cell_size.y * ANIMATION_ORDER.size()
	)
	var sheet: Image = Image.create_empty(sheet_size.x, sheet_size.y, false, Image.FORMAT_RGBA8)
	sheet.fill(Color("0b1018"))
	for row_index: int in range(ANIMATION_ORDER.size()):
		var animation_name: StringName = ANIMATION_ORDER[row_index]
		var frames: Array = sequences[animation_name]
		for frame_index: int in range(frames.size()):
			var frame: Image = frames[frame_index] as Image
			var scaled: Image = PixelCanvas.resize_nearest(frame, cell_size)
			var destination: Vector2i = Vector2i(
				margin + frame_index * cell_size.x,
				margin + row_index * cell_size.y
			)
			sheet.blend_rect(scaled, Rect2i(Vector2i.ZERO, scaled.get_size()), destination)
		if row_index < ANIMATION_ORDER.size() - 1:
			PixelCanvas.fill_rect(
				sheet,
				Rect2i(0, margin + (row_index + 1) * cell_size.y - 1, sheet_size.x, 2),
				Color("243441")
			)
	return sheet.save_png(CONTACT_SHEET_PATH)


static func _draw_frame(animation_name: StringName, frame_index: int) -> Image:
	if animation_name == &"death":
		return _draw_death(frame_index)
	var image: Image = PixelCanvas.create_transparent(Vector2i(64, 64))
	match animation_name:
		&"idle":
			_draw_guard(image, Vector2i(0, [-1, 0, 0, -1][frame_index]), 0, 0, frame_index % 2, &"rest")
		&"walk":
			var leg_phase: Array[int] = [-4, -2, 2, 4, 2, -2]
			var body_bob: Array[int] = [0, -1, 0, 0, -1, 0]
			_draw_guard(image, Vector2i(0, body_bob[frame_index]), leg_phase[frame_index], -leg_phase[frame_index], frame_index, &"walk")
		&"attack":
			_draw_attack(image, frame_index)
		&"hurt":
			_draw_guard(image, Vector2i(-frame_index * 2, frame_index - 1), -2, 3, frame_index, &"hurt")
	return image


static func _draw_guard(
	image: Image,
	body_offset: Vector2i,
	front_leg_offset: int,
	back_leg_offset: int,
	frame_index: int,
	pose: StringName
) -> void:
	var center_x: int = 31 + body_offset.x
	var body_top: int = 28 + body_offset.y
	_draw_helmet(image, Vector2i(center_x, body_top - 7), pose == &"hurt")
	PixelCanvas.fill_rect(image, Rect2i(center_x - 10, body_top, 20, 5), OUTLINE)
	PixelCanvas.fill_rect(image, Rect2i(center_x - 8, body_top + 2, 17, 17), ARMOR_DARK)
	PixelCanvas.fill_rect(image, Rect2i(center_x - 6, body_top + 4, 12, 12), ARMOR_MID)
	PixelCanvas.fill_rect(image, Rect2i(center_x - 8, body_top + 5, 4, 9), RUST_DARK)
	PixelCanvas.fill_rect(image, Rect2i(center_x + 4, body_top + 3, 5, 8), ARMOR_LIGHT)
	PixelCanvas.fill_rect(image, Rect2i(center_x - 2, body_top + 10, 4, 3), RUST)
	_draw_legs(image, center_x, body_top + 18, front_leg_offset, back_leg_offset)
	var sword_tip: Vector2i = Vector2i(center_x + 19, body_top + 13 + (frame_index % 2))
	_draw_arm_and_sword(image, Vector2i(center_x + 6, body_top + 7), sword_tip, false)
	PixelCanvas.draw_line(image, Vector2i(center_x - 6, body_top + 7), Vector2i(center_x - 12, body_top + 14), ARMOR_MID, 5)
	PixelCanvas.fill_rect(image, Rect2i(center_x - 14, body_top + 12, 6, 8), OUTLINE)
	PixelCanvas.fill_rect(image, Rect2i(center_x - 13, body_top + 13, 4, 6), RUST_DARK)


static func _draw_attack(image: Image, frame_index: int) -> void:
	var body_offsets: Array[Vector2i] = [Vector2i.ZERO, Vector2i(0, 2), Vector2i(2, 1), Vector2i(3, 1), Vector2i(1, 0)]
	var offset: Vector2i = body_offsets[frame_index]
	var center_x: int = 31 + offset.x
	var body_top: int = 28 + offset.y
	_draw_helmet(image, Vector2i(center_x, body_top - 7), false)
	PixelCanvas.fill_rect(image, Rect2i(center_x - 10, body_top, 20, 5), OUTLINE)
	PixelCanvas.fill_rect(image, Rect2i(center_x - 8, body_top + 2, 17, 17), ARMOR_DARK)
	PixelCanvas.fill_rect(image, Rect2i(center_x - 6, body_top + 4, 12, 12), ARMOR_MID)
	PixelCanvas.fill_rect(image, Rect2i(center_x - 2, body_top + 10, 4, 3), RUST)
	_draw_legs(image, center_x, body_top + 18, -2 if frame_index >= 2 else 0, 4 if frame_index >= 2 else 0)
	var hand: Vector2i = Vector2i(center_x + 6, body_top + 8)
	var sword_tip: Vector2i
	match frame_index:
		0:
			sword_tip = Vector2i(center_x + 2, body_top - 15)
		1:
			sword_tip = Vector2i(center_x + 11, body_top - 17)
		2:
			hand = Vector2i(center_x + 11, body_top + 8)
			sword_tip = Vector2i(61, body_top + 9)
		3:
			hand = Vector2i(center_x + 12, body_top + 9)
			sword_tip = Vector2i(63, body_top + 12)
		_:
			sword_tip = Vector2i(center_x + 19, body_top + 17)
	_draw_arm_and_sword(image, hand, sword_tip, frame_index < 2)
	PixelCanvas.draw_line(image, Vector2i(center_x - 6, body_top + 8), Vector2i(center_x - 10, body_top + 14), ARMOR_MID, 5)


static func _draw_death(frame_index: int) -> Image:
	var image: Image = PixelCanvas.create_transparent(Vector2i(64, 64))
	if frame_index <= 1:
		_draw_guard(image, Vector2i(-frame_index * 2, frame_index * 5), -2, 3, frame_index, &"hurt")
		return image
	if frame_index == 2:
		_draw_fallen_guard(image, 44, 18, false)
		return image
	if frame_index == 3:
		_draw_fallen_guard(image, 50, 10, false)
		return image
	_draw_fallen_guard(image, 54 if frame_index == 4 else 55, 2, true)
	return image


static func _draw_fallen_guard(image: Image, body_y: int, slope: int, settled: bool) -> void:
	var head_center: Vector2i = Vector2i(19, body_y - slope / 2)
	_draw_helmet_horizontal(image, head_center)
	PixelCanvas.draw_line(image, Vector2i(27, body_y - slope), Vector2i(47, body_y), OUTLINE, 12)
	PixelCanvas.draw_line(image, Vector2i(28, body_y - slope), Vector2i(45, body_y), ARMOR_MID, 8)
	PixelCanvas.fill_rect(image, Rect2i(34, body_y - slope / 2 - 1, 4, 3), RUST)
	PixelCanvas.draw_line(image, Vector2i(43, body_y), Vector2i(59, body_y + 3), ARMOR_DARK, 7)
	PixelCanvas.draw_line(image, Vector2i(42, body_y + 2), Vector2i(56, body_y + 6), ARMOR_DARK, 6)
	PixelCanvas.fill_rect(image, Rect2i(54, body_y + 1, 9, 3), OUTLINE)
	PixelCanvas.fill_rect(image, Rect2i(52, body_y + 5, 10, 3), OUTLINE)
	PixelCanvas.draw_line(image, Vector2i(33, body_y - 2), Vector2i(51, body_y - 7), ARMOR_MID, 5)
	var sword_y: int = 59 if settled else mini(61, body_y + 9)
	PixelCanvas.draw_line(image, Vector2i(7, sword_y), Vector2i(29, sword_y - 2), STEEL, 2)
	PixelCanvas.fill_rect(image, Rect2i(27, sword_y - 4, 4, 6), RUST_DARK)


static func _draw_helmet(image: Image, center: Vector2i, recoiling: bool) -> void:
	var tilt: int = -2 if recoiling else 0
	PixelCanvas.fill_rect(image, Rect2i(center.x - 8 + tilt, center.y - 8, 16, 3), OUTLINE)
	PixelCanvas.fill_rect(image, Rect2i(center.x - 10 + tilt, center.y - 5, 20, 12), OUTLINE)
	PixelCanvas.fill_rect(image, Rect2i(center.x - 8 + tilt, center.y - 4, 16, 8), ARMOR_DARK)
	PixelCanvas.fill_rect(image, Rect2i(center.x - 6 + tilt, center.y - 3, 12, 3), ARMOR_LIGHT)
	PixelCanvas.fill_rect(image, Rect2i(center.x - 7 + tilt, center.y + 1, 15, 4), RUST_DARK)
	PixelCanvas.fill_rect(image, Rect2i(center.x + 3 + tilt, center.y + 2, 3, 1), EYE_GLOW)
	PixelCanvas.fill_rect(image, Rect2i(center.x - 10 + tilt, center.y - 1, 3, 9), RUST)


static func _draw_helmet_horizontal(image: Image, center: Vector2i) -> void:
	PixelCanvas.fill_rect(image, Rect2i(center.x - 9, center.y - 7, 18, 14), OUTLINE)
	PixelCanvas.fill_rect(image, Rect2i(center.x - 7, center.y - 5, 14, 10), ARMOR_DARK)
	PixelCanvas.fill_rect(image, Rect2i(center.x - 7, center.y - 2, 14, 3), RUST_DARK)
	PixelCanvas.fill_rect(image, Rect2i(center.x - 3, center.y - 1, 3, 1), EYE_GLOW)
	PixelCanvas.fill_rect(image, Rect2i(center.x - 10, center.y - 5, 3, 10), RUST)


static func _draw_legs(image: Image, center_x: int, hip_y: int, front_offset: int, back_offset: int) -> void:
	PixelCanvas.draw_line(image, Vector2i(center_x - 4, hip_y), Vector2i(center_x - 7 + back_offset, 57), ARMOR_DARK, 7)
	PixelCanvas.draw_line(image, Vector2i(center_x + 4, hip_y), Vector2i(center_x + 7 + front_offset, 57), ARMOR_MID, 7)
	PixelCanvas.fill_rect(image, Rect2i(center_x - 12 + back_offset, 57, 11, 4), OUTLINE)
	PixelCanvas.fill_rect(image, Rect2i(center_x + 2 + front_offset, 57, 12, 4), OUTLINE)


static func _draw_arm_and_sword(image: Image, shoulder: Vector2i, tip: Vector2i, raised: bool) -> void:
	var hand: Vector2i = shoulder + Vector2i(5, -3 if raised else 6)
	PixelCanvas.draw_line(image, shoulder, hand, ARMOR_MID, 6)
	var blade_start: Vector2i = hand + Vector2i(3, 0)
	PixelCanvas.fill_rect(image, Rect2i(hand.x - 2, hand.y - 2, 5, 5), RUST_DARK)
	PixelCanvas.draw_line(image, blade_start, tip, OUTLINE, 4)
	PixelCanvas.draw_line(image, blade_start, tip, STEEL, 2)
	PixelCanvas.fill_rect(image, Rect2i(hand.x, hand.y - 4, 3, 9), RUST)
