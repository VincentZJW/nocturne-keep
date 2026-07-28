extends SceneTree

## Deterministic Stage 3 exporter for the Prologue Candle Warden.

const PixelCanvas: Script = preload("res://scripts/tools/pixel_art_canvas.gd")

const ROOT: String = "res://chapters/prologue_veilbound_catacomb/assets/npcs/candle_warden"
const CONCEPT_ROOT: String = ROOT + "/concept_art"
const ANIMATION_ROOT: String = ROOT + "/animations"
const EFFECT_ROOT: String = ROOT + "/effects"
const QA_ROOT: String = "res://docs/qa/core_character_art_rework/stage_3"

const FRAME_COUNTS: Dictionary[StringName, int] = {
	&"seated": 2,
	&"rising": 5,
	&"idle": 4,
	&"lantern_idle": 6,
	&"look_at_player": 3,
	&"talk": 4,
	&"talk_emphasis": 4,
	&"gesture_point": 4,
	&"gesture_warn": 4,
	&"offer_key": 4,
	&"open_door": 5,
	&"slow_walk": 6,
	&"raise_lantern": 4,
	&"turn_away": 4,
	&"return_to_shadow": 6,
}

const OUTLINE: Color = Color("070b12")
const HOOD: Color = Color("0d131b")
const ROBE_DARK: Color = Color("151d27")
const ROBE: Color = Color("283440")
const ROBE_LIGHT: Color = Color("40505c")
const MASK_DARK: Color = Color("4c5357")
const MASK: Color = Color("9a9a91")
const MASK_LIGHT: Color = Color("c2c0b2")
const METAL_DARK: Color = Color("27333c")
const METAL: Color = Color("667985")
const METAL_LIGHT: Color = Color("9aabb3")
const LEATHER: Color = Color("49362d")
const WAX: Color = Color("7a4145")
const BONE: Color = Color("a89c82")
const GLASS: Color = Color("24475a")
const SOUL_BLUE: Color = Color("65b7d2")
const SOUL_PALE: Color = Color("bcecf5")


func _init() -> void:
	var failures: int = 0
	failures += _export_concepts()
	failures += _export_animation_frames()
	failures += _export_flame_frames()
	failures += _export_effects()
	failures += _export_contact_sheet()
	if failures > 0:
		push_error("CANDLE_WARDEN_STAGE_3_ASSETS: FAIL failures=%d" % failures)
		quit(1)
		return
	print("CANDLE_WARDEN_STAGE_3_ASSETS: PASS concepts=10 animations=15 frames=%d flame=6" % _total_frames())
	quit(0)


func _export_concepts() -> int:
	var turnaround: Image = Image.load_from_file(ProjectSettings.globalize_path(
		CONCEPT_ROOT + "/candle_warden_turnaround_master.png"
	))
	var gestures: Image = Image.load_from_file(ProjectSettings.globalize_path(
		CONCEPT_ROOT + "/candle_warden_gesture_cinematic_master.png"
	))
	if turnaround == null or turnaround.is_empty() or gestures == null or gestures.is_empty():
		return 10
	var crops: Dictionary[String, Dictionary] = {
		"candle_warden_front_concept.png": {"source": turnaround, "rect": Rect2i(0, 0, 300, 650)},
		"candle_warden_side_concept.png": {"source": turnaround, "rect": Rect2i(285, 0, 305, 650)},
		"candle_warden_back_concept.png": {"source": turnaround, "rect": Rect2i(570, 0, 325, 650)},
		"candle_warden_silhouette.png": {"source": turnaround, "rect": Rect2i(880, 0, 355, 650)},
		"candle_warden_mask_design.png": {"source": turnaround, "rect": Rect2i(1230, 0, 306, 325)},
		"candle_warden_lantern_design.png": {"source": turnaround, "rect": Rect2i(1230, 310, 306, 380)},
		"candle_warden_key_design.png": {"source": turnaround, "rect": Rect2i(1230, 675, 306, 349)},
		"candle_warden_scale_with_player.png": {"source": turnaround, "rect": Rect2i(0, 625, 430, 399)},
		"candle_warden_gesture_sheet.png": {"source": gestures, "rect": Rect2i(0, 0, 1000, 745)},
		"candle_warden_scene_composition.png": {"source": gestures, "rect": Rect2i(0, 735, 1536, 289)},
	}
	var failures: int = 0
	for file_name: String in crops:
		var data: Dictionary = crops[file_name]
		var source: Image = data["source"] as Image
		var region: Image = source.get_region(data["rect"] as Rect2i)
		if region.save_png(CONCEPT_ROOT.path_join(file_name)) != OK:
			failures += 1
	return failures


func _export_animation_frames() -> int:
	var failures: int = 0
	for animation_name: StringName in FRAME_COUNTS:
		var directory: String = ANIMATION_ROOT.path_join(str(animation_name))
		if DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(directory)) != OK:
			failures += FRAME_COUNTS[animation_name]
			continue
		for frame_index: int in range(FRAME_COUNTS[animation_name]):
			var image: Image = _render_frame(animation_name, frame_index)
			var file_name: String = "%s_%02d.png" % [animation_name, frame_index + 1]
			if image.save_png(directory.path_join(file_name)) != OK:
				failures += 1
	return failures


func _render_frame(animation_name: StringName, frame_index: int) -> Image:
	var image: Image = PixelCanvas.create_transparent(Vector2i(80, 80))
	var bob: int = 0
	var body_x: int = 40
	var robe_shift: int = 0
	var seated_offset: int = 0
	var lantern_raise: int = 0
	var lantern_swing: int = 0
	var gesture: StringName = &"rest"
	var back_view: bool = false

	match animation_name:
		&"seated":
			seated_offset = 17 + frame_index
			gesture = &"lantern_low"
		&"rising":
			seated_offset = [15, 12, 8, 4, 0][frame_index]
			gesture = &"lantern_low"
		&"idle":
			bob = [0, -1, -1, 0][frame_index]
		&"lantern_idle":
			bob = [0, -1, -1, 0, 0, 1][frame_index]
			lantern_swing = [-1, -1, 0, 1, 1, 0][frame_index]
		&"look_at_player":
			bob = [0, -1, 0][frame_index]
			gesture = &"look"
		&"talk":
			bob = [0, -1, 0, 0][frame_index]
			gesture = &"talk"
		&"talk_emphasis":
			bob = [0, -1, -1, 0][frame_index]
			gesture = &"emphasis"
			lantern_raise = [0, 2, 3, 2][frame_index]
		&"gesture_point":
			gesture = &"point"
			body_x = [40, 40, 41, 40][frame_index]
		&"gesture_warn":
			gesture = &"warn"
			lantern_raise = [1, 3, 4, 3][frame_index]
		&"offer_key":
			gesture = &"offer_key"
		&"open_door":
			gesture = &"open_door"
			lantern_raise = [0, 1, 2, 2, 1][frame_index]
		&"slow_walk":
			body_x += [0, 0, 1, 0, -1, 0][frame_index]
			bob = [0, -1, 0, 0, -1, 0][frame_index]
			robe_shift = [-2, -1, 0, 2, 1, 0][frame_index]
			lantern_swing = [-2, -1, 0, 2, 1, 0][frame_index]
		&"raise_lantern":
			gesture = &"raise_lantern"
			lantern_raise = [1, 4, 7, 6][frame_index]
		&"turn_away":
			back_view = frame_index >= 2
			gesture = &"turn"
			body_x += [0, 1, 1, 0][frame_index]
		&"return_to_shadow":
			back_view = frame_index >= 1
			gesture = &"shadow"

	_draw_body(image, body_x, bob + seated_offset, robe_shift, gesture, back_view)
	_draw_lantern(image, body_x, bob + seated_offset, lantern_raise, lantern_swing, animation_name)
	if animation_name == &"return_to_shadow":
		_fade_image(image, 1.0 - float(frame_index) * 0.13, 1.0 - float(frame_index) * 0.10)
	return image


func _draw_body(
		image: Image,
		center_x: int,
		y_offset: int,
		robe_shift: int,
		gesture: StringName,
		back_view: bool
	) -> void:
	var foot_y: int = 72
	var top_y: int = 7 + y_offset
	var shoulder_y: int = 29 + y_offset
	var waist_y: int = 45 + y_offset
	var hem_y: int = mini(72, 70 + y_offset)

	# Layered, tapered robe silhouette with explicit tattered hem clusters.
	for y: int in range(shoulder_y, hem_y):
		var progress: float = float(y - shoulder_y) / maxf(1.0, float(hem_y - shoulder_y))
		var half_width: int = roundi(13.0 + progress * 8.0)
		PixelCanvas.fill_rect(image, Rect2i(center_x - half_width + robe_shift, y, half_width * 2 + 1, 1), OUTLINE)
		if y > shoulder_y + 2:
			PixelCanvas.fill_rect(image, Rect2i(center_x - half_width + 2 + robe_shift, y, half_width * 2 - 3, 1), ROBE_DARK)
	for strip: Rect2i in [
		Rect2i(center_x - 18 + robe_shift, hem_y - 5, 6, mini(foot_y, hem_y + 4) - hem_y + 1),
		Rect2i(center_x - 9 + robe_shift, hem_y - 3, 5, mini(foot_y, hem_y + 2) - hem_y + 1),
		Rect2i(center_x + 3 + robe_shift, hem_y - 4, 6, mini(foot_y, hem_y + 3) - hem_y + 1),
		Rect2i(center_x + 13 + robe_shift, hem_y - 2, 4, mini(foot_y, hem_y + 1) - hem_y + 1),
	]:
		PixelCanvas.fill_rect(image, strip, OUTLINE)
		PixelCanvas.fill_rect(image, Rect2i(strip.position + Vector2i.ONE, strip.size - Vector2i(2, 1)), ROBE_DARK)

	# Boots and separated stance remain readable beneath the robe.
	PixelCanvas.fill_rect(image, Rect2i(center_x - 15, foot_y - 5, 10, 5), OUTLINE)
	PixelCanvas.fill_rect(image, Rect2i(center_x + 5, foot_y - 5, 11, 5), OUTLINE)
	PixelCanvas.fill_rect(image, Rect2i(center_x - 13, foot_y - 4, 8, 3), METAL_DARK)
	PixelCanvas.fill_rect(image, Rect2i(center_x + 6, foot_y - 4, 9, 3), METAL_DARK)
	PixelCanvas.fill_rect(image, Rect2i(center_x - 12, foot_y - 2, 8, 1), METAL)
	PixelCanvas.fill_rect(image, Rect2i(center_x + 6, foot_y - 2, 10, 1), METAL)

	# Inner robe panels, folds, ritual trim and wax seal.
	PixelCanvas.draw_line(image, Vector2i(center_x, waist_y), Vector2i(center_x - 4, hem_y - 2), ROBE_LIGHT, 2)
	PixelCanvas.draw_line(image, Vector2i(center_x + 5, waist_y + 2), Vector2i(center_x + 9, hem_y - 4), Color("202a35"), 2)
	PixelCanvas.draw_line(image, Vector2i(center_x - 7, waist_y + 1), Vector2i(center_x - 12, hem_y - 6), Color("35434f"), 1)
	PixelCanvas.fill_rect(image, Rect2i(center_x - 12, waist_y - 2, 24, 4), LEATHER)
	PixelCanvas.fill_rect(image, Rect2i(center_x - 10, waist_y - 1, 20, 1), Color("705142"))
	PixelCanvas.fill_rect(image, Rect2i(center_x + 8, waist_y - 3, 5, 5), OUTLINE)
	PixelCanvas.fill_rect(image, Rect2i(center_x + 9, waist_y - 2, 3, 3), WAX)

	# Mantle, shoulders and braided cords.
	PixelCanvas.draw_line(image, Vector2i(center_x - 16, shoulder_y + 2), Vector2i(center_x + 16, shoulder_y + 2), OUTLINE, 7)
	PixelCanvas.draw_line(image, Vector2i(center_x - 14, shoulder_y + 1), Vector2i(center_x + 14, shoulder_y + 1), ROBE, 4)
	PixelCanvas.fill_rect(image, Rect2i(center_x - 18, shoulder_y, 8, 5), METAL_DARK)
	PixelCanvas.fill_rect(image, Rect2i(center_x + 10, shoulder_y, 8, 5), METAL_DARK)
	PixelCanvas.fill_rect(image, Rect2i(center_x - 16, shoulder_y, 4, 2), METAL)
	PixelCanvas.fill_rect(image, Rect2i(center_x + 12, shoulder_y, 4, 2), METAL)
	PixelCanvas.draw_line(image, Vector2i(center_x - 8, shoulder_y + 5), Vector2i(center_x + 6, waist_y - 4), BONE, 1)
	PixelCanvas.draw_line(image, Vector2i(center_x + 7, shoulder_y + 5), Vector2i(center_x - 3, waist_y - 2), Color("74584a"), 1)

	_draw_hood_and_mask(image, center_x, top_y, back_view)
	_draw_lantern_arm(image, center_x, shoulder_y, y_offset)
	_draw_gesture_arm(image, center_x, shoulder_y, gesture)
	_draw_keys(image, center_x, waist_y, gesture)


func _draw_hood_and_mask(image: Image, center_x: int, top_y: int, back_view: bool) -> void:
	for y: int in range(top_y, top_y + 23):
		var local_y: int = y - top_y
		var half_width: int = mini(13, 4 + local_y / 2)
		PixelCanvas.fill_rect(image, Rect2i(center_x - half_width, y, half_width * 2 + 1, 1), OUTLINE)
		if local_y > 2:
			PixelCanvas.fill_rect(image, Rect2i(center_x - half_width + 2, y, half_width * 2 - 3, 1), HOOD)
	PixelCanvas.fill_rect(image, Rect2i(center_x - 14, top_y + 18, 28, 7), OUTLINE)
	PixelCanvas.fill_rect(image, Rect2i(center_x - 12, top_y + 18, 24, 5), ROBE_DARK)
	if back_view:
		PixelCanvas.draw_line(image, Vector2i(center_x, top_y + 7), Vector2i(center_x + 3, top_y + 19), ROBE_LIGHT, 1)
		return
	# Pointed asymmetrical funerary mask with narrow, dark eye slots.
	PixelCanvas.draw_line(image, Vector2i(center_x - 6, top_y + 7), Vector2i(center_x - 8, top_y + 19), MASK_DARK, 7)
	PixelCanvas.draw_line(image, Vector2i(center_x + 4, top_y + 7), Vector2i(center_x + 7, top_y + 19), MASK_DARK, 7)
	PixelCanvas.draw_line(image, Vector2i(center_x - 5, top_y + 8), Vector2i(center_x - 6, top_y + 18), MASK, 4)
	PixelCanvas.draw_line(image, Vector2i(center_x + 3, top_y + 8), Vector2i(center_x + 5, top_y + 18), MASK, 4)
	PixelCanvas.fill_rect(image, Rect2i(center_x - 4, top_y + 12, 3, 2), OUTLINE)
	PixelCanvas.fill_rect(image, Rect2i(center_x + 2, top_y + 12, 3, 2), OUTLINE)
	PixelCanvas.fill_rect(image, Rect2i(center_x - 5, top_y + 8, 2, 3), MASK_LIGHT)
	PixelCanvas.draw_line(image, Vector2i(center_x, top_y + 8), Vector2i(center_x, top_y + 19), METAL_DARK, 1)
	PixelCanvas.fill_rect(image, Rect2i(center_x - 1, top_y + 5, 2, 3), BONE)


func _draw_lantern_arm(image: Image, center_x: int, shoulder_y: int, y_offset: int) -> void:
	var shoulder: Vector2i = Vector2i(center_x - 13, shoulder_y + 3)
	var elbow: Vector2i = Vector2i(center_x - 19, shoulder_y + 11)
	var hand: Vector2i = Vector2i(center_x - 22, 42 + y_offset)
	PixelCanvas.draw_line(image, shoulder, elbow, OUTLINE, 7)
	PixelCanvas.draw_line(image, elbow, hand, OUTLINE, 6)
	PixelCanvas.draw_line(image, shoulder, elbow, ROBE, 4)
	PixelCanvas.draw_line(image, elbow, hand, ROBE_LIGHT, 3)
	PixelCanvas.fill_rect(image, Rect2i(hand.x - 2, hand.y - 1, 4, 4), MASK_DARK)


func _draw_gesture_arm(image: Image, center_x: int, shoulder_y: int, gesture: StringName) -> void:
	var shoulder: Vector2i = Vector2i(center_x + 13, shoulder_y + 3)
	var elbow: Vector2i = Vector2i(center_x + 18, shoulder_y + 12)
	var hand: Vector2i = Vector2i(center_x + 18, shoulder_y + 21)
	match gesture:
		&"talk", &"look":
			elbow = Vector2i(center_x + 20, shoulder_y + 9)
			hand = Vector2i(center_x + 26, shoulder_y + 8)
		&"emphasis", &"raise_lantern":
			elbow = Vector2i(center_x + 18, shoulder_y + 5)
			hand = Vector2i(center_x + 22, shoulder_y - 4)
		&"point":
			elbow = Vector2i(center_x + 23, shoulder_y + 4)
			hand = Vector2i(center_x + 34, shoulder_y + 1)
		&"warn":
			elbow = Vector2i(center_x + 18, shoulder_y + 5)
			hand = Vector2i(center_x + 25, shoulder_y + 1)
		&"offer_key", &"open_door":
			elbow = Vector2i(center_x + 21, shoulder_y + 5)
			hand = Vector2i(center_x + 27, shoulder_y - 2)
	PixelCanvas.draw_line(image, shoulder, elbow, OUTLINE, 7)
	PixelCanvas.draw_line(image, elbow, hand, OUTLINE, 6)
	PixelCanvas.draw_line(image, shoulder, elbow, ROBE, 4)
	PixelCanvas.draw_line(image, elbow, hand, ROBE_LIGHT, 3)
	PixelCanvas.fill_rect(image, Rect2i(hand.x - 2, hand.y - 2, 4, 4), MASK_DARK)
	if gesture == &"point":
		PixelCanvas.draw_line(image, hand, hand + Vector2i(7, -1), MASK_LIGHT, 2)
	elif gesture == &"warn":
		PixelCanvas.draw_line(image, hand + Vector2i(1, -3), hand + Vector2i(1, 4), MASK_LIGHT, 1)
		PixelCanvas.draw_line(image, hand + Vector2i(3, -2), hand + Vector2i(3, 3), MASK_LIGHT, 1)


func _draw_keys(image: Image, center_x: int, waist_y: int, gesture: StringName) -> void:
	var key_origin: Vector2i = Vector2i(center_x + 14, waist_y + 1)
	if gesture in [&"emphasis", &"offer_key", &"open_door"]:
		key_origin = Vector2i(center_x + 28, 27)
	PixelCanvas.fill_rect(image, Rect2i(key_origin.x - 2, key_origin.y - 2, 5, 5), METAL_DARK)
	PixelCanvas.fill_rect(image, Rect2i(key_origin.x - 1, key_origin.y - 1, 3, 3), Color.TRANSPARENT)
	PixelCanvas.draw_line(image, key_origin + Vector2i(2, 2), key_origin + Vector2i(2, 10), METAL_LIGHT, 2)
	PixelCanvas.fill_rect(image, Rect2i(key_origin.x + 2, key_origin.y + 8, 5, 2), METAL_LIGHT)
	PixelCanvas.draw_line(image, key_origin + Vector2i(-1, 3), key_origin + Vector2i(-3, 9), METAL, 1)
	PixelCanvas.fill_rect(image, Rect2i(key_origin.x - 3, key_origin.y + 8, 4, 2), METAL)


func _draw_lantern(
		image: Image,
		center_x: int,
		y_offset: int,
		raise_amount: int,
		swing: int,
		animation_name: StringName
	) -> void:
	var lantern_x: int = center_x - 28 + swing
	var lantern_y: int = 46 + y_offset - raise_amount * 2
	if animation_name == &"seated":
		lantern_y += 3
	PixelCanvas.draw_line(image, Vector2i(center_x - 22, 42 + y_offset), Vector2i(lantern_x, lantern_y - 9), METAL, 2)
	PixelCanvas.draw_line(image, Vector2i(lantern_x - 5, lantern_y - 8), Vector2i(lantern_x + 5, lantern_y - 8), METAL_LIGHT, 1)
	PixelCanvas.draw_line(image, Vector2i(lantern_x - 5, lantern_y - 8), Vector2i(lantern_x - 8, lantern_y - 2), METAL_DARK, 2)
	PixelCanvas.draw_line(image, Vector2i(lantern_x + 5, lantern_y - 8), Vector2i(lantern_x + 8, lantern_y - 2), METAL_DARK, 2)
	PixelCanvas.fill_rect(image, Rect2i(lantern_x - 9, lantern_y - 2, 19, 19), OUTLINE)
	PixelCanvas.fill_rect(image, Rect2i(lantern_x - 7, lantern_y, 15, 15), GLASS)
	PixelCanvas.fill_rect(image, Rect2i(lantern_x - 5, lantern_y + 1, 4, 13), Color("315d70"))
	PixelCanvas.fill_rect(image, Rect2i(lantern_x + 3, lantern_y + 1, 3, 13), Color("1a3545"))
	PixelCanvas.draw_line(image, Vector2i(lantern_x, lantern_y), Vector2i(lantern_x, lantern_y + 15), METAL, 1)
	PixelCanvas.draw_line(image, Vector2i(lantern_x - 8, lantern_y + 7), Vector2i(lantern_x + 9, lantern_y + 7), METAL, 1)
	PixelCanvas.draw_line(image, Vector2i(lantern_x - 9, lantern_y + 16), Vector2i(lantern_x + 10, lantern_y + 16), METAL_LIGHT, 2)
	PixelCanvas.fill_rect(image, Rect2i(lantern_x - 2, lantern_y + 18, 5, 3), METAL_DARK)


func _export_flame_frames() -> int:
	var directory: String = EFFECT_ROOT.path_join("soul_flame")
	if DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(directory)) != OK:
		return 6
	var failures: int = 0
	for frame_index: int in range(6):
		var image: Image = PixelCanvas.create_transparent(Vector2i(16, 20))
		var sway: int = [-1, 0, 1, 1, 0, -1][frame_index]
		var height: int = [13, 15, 17, 14, 16, 14][frame_index]
		for y: int in range(height):
			var width: int = maxi(1, 6 - y / 3)
			var center_x: int = 8 + sway * y / maxi(1, height)
			PixelCanvas.fill_rect(image, Rect2i(center_x - width / 2, 18 - y, width, 1), SOUL_BLUE)
		PixelCanvas.draw_line(image, Vector2i(8, 17), Vector2i(8 + sway, 18 - height + 4), SOUL_PALE, 2)
		PixelCanvas.fill_rect(image, Rect2i(7, 16, 3, 3), Color("e4fbff"))
		if image.save_png(directory.path_join("soul_flame_%02d.png" % (frame_index + 1))) != OK:
			failures += 1
	return failures


func _export_effects() -> int:
	if DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(EFFECT_ROOT)) != OK:
		return 2
	var light: Image = Image.create(64, 64, false, Image.FORMAT_RGBA8)
	for y: int in range(64):
		for x: int in range(64):
			var distance: float = Vector2(float(x - 32), float(y - 32)).length() / 32.0
			var alpha: float = pow(maxf(0.0, 1.0 - distance), 2.1)
			light.set_pixel(x, y, Color(0.50, 0.84, 1.0, alpha))
	var failures: int = 0
	if light.save_png(EFFECT_ROOT.path_join("candle_warden_soul_light.png")) != OK:
		failures += 1
	var mote: Image = PixelCanvas.create_transparent(Vector2i(3, 3))
	mote.set_pixel(1, 0, SOUL_BLUE * Color(1, 1, 1, 0.55))
	mote.set_pixel(0, 1, SOUL_BLUE * Color(1, 1, 1, 0.35))
	mote.set_pixel(1, 1, SOUL_PALE * Color(1, 1, 1, 0.80))
	mote.set_pixel(2, 1, SOUL_BLUE * Color(1, 1, 1, 0.35))
	mote.set_pixel(1, 2, SOUL_BLUE * Color(1, 1, 1, 0.35))
	if mote.save_png(EFFECT_ROOT.path_join("candle_warden_soul_mote.png")) != OK:
		failures += 1
	return failures


func _export_contact_sheet() -> int:
	if DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(QA_ROOT)) != OK:
		return 1
	var sheet: Image = Image.create(1280, 720, false, Image.FORMAT_RGBA8)
	sheet.fill(Color("080d15"))
	var poses: Array[Dictionary] = [
		{"animation": &"idle", "frame": 1, "position": Vector2i(45, 60)},
		{"animation": &"lantern_idle", "frame": 3, "position": Vector2i(275, 60)},
		{"animation": &"talk", "frame": 1, "position": Vector2i(505, 60)},
		{"animation": &"talk_emphasis", "frame": 2, "position": Vector2i(735, 60)},
		{"animation": &"gesture_point", "frame": 2, "position": Vector2i(965, 60)},
		{"animation": &"gesture_warn", "frame": 2, "position": Vector2i(100, 390)},
		{"animation": &"offer_key", "frame": 2, "position": Vector2i(350, 390)},
		{"animation": &"open_door", "frame": 3, "position": Vector2i(600, 390)},
		{"animation": &"slow_walk", "frame": 1, "position": Vector2i(850, 390)},
	]
	for pose: Dictionary in poses:
		var animation_name: StringName = pose["animation"] as StringName
		var frame_index: int = pose["frame"] as int
		var source: Image = _render_frame(animation_name, frame_index)
		var scaled: Image = PixelCanvas.resize_nearest(source, Vector2i(240, 240))
		sheet.blend_rect(scaled, Rect2i(Vector2i.ZERO, scaled.get_size()), pose["position"] as Vector2i)
	return sheet.save_png(QA_ROOT.path_join("candle_warden_stage_3_contact_sheet.png"))


func _fade_image(image: Image, alpha_scale: float, brightness: float) -> void:
	for y: int in range(image.get_height()):
		for x: int in range(image.get_width()):
			var color: Color = image.get_pixel(x, y)
			if color.a <= 0.0:
				continue
			image.set_pixel(x, y, Color(color.r * brightness, color.g * brightness, color.b * brightness, color.a * alpha_scale))


func _total_frames() -> int:
	var total: int = 0
	for count: int in FRAME_COUNTS.values():
		total += count
	return total
