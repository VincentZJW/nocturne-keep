extends SceneTree

## Deterministic, original Image-API pixel source generator for Chapter II Phase 2.

const ROOT: String = "res://chapters/chapter_02_silent_court/assets/enemies"
const TRANSPARENT: Color = Color(0, 0, 0, 0)
const OUTLINE: Color = Color("11131c")
const IRON: Color = Color("34394a")
const SLATE: Color = Color("596277")
const STEEL: Color = Color("abb6c7")
const PALE: Color = Color("d5dee3")
const CLOTH: Color = Color("24233a")
const BLOOD: Color = Color("8f3040")
const EMBER: Color = Color("d18a50")
const VIOLET: Color = Color("75658d")

const ANIMATIONS: Dictionary = {
	"hollow_retainer": {"idle": 4, "walk": 6, "alert": 2, "attack_single_stab": 5, "attack_combo": 6, "hurt": 3, "death": 6},
	"court_halberdier": {"idle": 4, "walk": 6, "alert": 2, "turn": 3, "attack_thrust": 5, "attack_sweep": 6, "attack_shaft_push": 4, "hurt": 3, "death": 6},
	"mourning_armor": {"idle": 4, "walk": 6, "alert": 2, "turn": 3, "attack_overhead": 6, "attack_shoulder_bash": 5, "attack_heavy_sweep": 6, "stagger": 4, "hurt": 3, "death": 6},
	"blood_candle_acolyte": {"idle": 4, "walk": 6, "alert": 2, "attack_cast": 6, "buff_channel": 4, "hurt": 3, "death": 6},
	"hanging_stalker": {"hang": 4, "telegraph": 4, "drop": 4, "ground_recovery": 3, "claw": 5, "retreat": 4, "return_to_anchor": 4, "hurt": 3, "death": 6},
}


func _initialize() -> void:
	for enemy_name: String in ANIMATIONS:
		var animation_map: Dictionary = ANIMATIONS[enemy_name] as Dictionary
		for animation_name: String in animation_map:
			var frame_count: int = int(animation_map[animation_name])
			var directory: String = "%s/%s/sprites/%s" % [ROOT, enemy_name, animation_name]
			DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(directory))
			for frame_index: int in range(frame_count):
				var image: Image = _draw_frame(enemy_name, animation_name, frame_index, frame_count)
				var output: String = "%s/%s_%02d.png" % [directory, animation_name, frame_index + 1]
				var error: Error = image.save_png(ProjectSettings.globalize_path(output))
				if error != OK:
					push_error("Failed to save %s: %s" % [output, error_string(error)])
					quit(1)
	print("CH2_PHASE2_ASSET_GENERATOR: PASS enemies=5")
	quit(0)


func _draw_frame(enemy_name: String, animation_name: String, frame: int, count: int) -> Image:
	var image: Image = Image.create(64, 64, false, Image.FORMAT_RGBA8)
	image.fill(TRANSPARENT)
	var phase: float = float(frame) / float(maxi(1, count - 1))
	var bob: int = -1 if animation_name == "walk" and frame % 3 == 1 else 0
	if enemy_name == "hanging_stalker":
		_draw_stalker(image, animation_name, frame, phase)
		return image
	var lean: int = 0
	if animation_name.begins_with("attack_"):
		lean = mini(3, frame)
	if animation_name == "hurt" or animation_name == "stagger":
		lean = -2 - frame
	if animation_name == "death":
		_draw_death(image, enemy_name, frame, count)
		return image
	match enemy_name:
		"hollow_retainer":
			_draw_retainer(image, animation_name, frame, bob, lean)
		"court_halberdier":
			_draw_halberdier(image, animation_name, frame, bob, lean)
		"mourning_armor":
			_draw_armor(image, animation_name, frame, bob, lean)
		"blood_candle_acolyte":
			_draw_acolyte(image, animation_name, frame, bob, lean)
	return image


func _draw_retainer(image: Image, animation: String, frame: int, bob: int, lean: int) -> void:
	var x: int = 28 + lean
	var y: int = 16 + bob
	_rect(image, x - 5, y, 11, 10, OUTLINE)
	_rect(image, x - 3, y + 2, 7, 5, CLOTH)
	_rect(image, x + 2, y + 4, 2, 1, BLOOD)
	_rect(image, x - 6, y + 10, 13, 19, OUTLINE)
	_rect(image, x - 4, y + 11, 9, 16, Color("3b334d"))
	_rect(image, x - 8, y + 14, 3, 15, SLATE)
	var stride: int = _stride(frame) if animation == "walk" else 0
	_rect(image, x - 5 - stride, y + 29, 4, 15, OUTLINE)
	_rect(image, x + 2 + stride, y + 29, 4, 15, OUTLINE)
	_rect(image, x - 5 - stride, y + 31, 3, 12, SLATE)
	_rect(image, x + 2 + stride, y + 31, 3, 12, SLATE)
	var extension: int = 18 if animation == "attack_single_stab" and frame >= 2 else 11
	if animation == "attack_combo" and frame in [2, 4, 5]:
		extension = 17
	_draw_weapon(image, Vector2i(x + 5, y + 18), Vector2i(x + extension, y + 16), PALE, 1)


func _draw_halberdier(image: Image, animation: String, frame: int, bob: int, lean: int) -> void:
	var x: int = 26 + lean
	var y: int = 11 + bob
	_rect(image, x - 6, y, 13, 12, OUTLINE)
	_rect(image, x - 4, y + 2, 9, 8, IRON)
	_rect(image, x + 3, y + 5, 2, 1, BLOOD)
	_rect(image, x - 7, y + 12, 15, 24, OUTLINE)
	_rect(image, x - 5, y + 14, 11, 20, SLATE)
	var stride: int = _stride(frame) if animation == "walk" else 0
	_rect(image, x - 6 - stride, y + 36, 5, 14, OUTLINE)
	_rect(image, x + 2 + stride, y + 36, 5, 14, OUTLINE)
	var pole_start: Vector2i = Vector2i(x + 6, y + 7)
	var pole_end: Vector2i = Vector2i(57, y + 34)
	if animation == "attack_thrust" and frame >= 2:
		pole_start = Vector2i(x + 3, y + 20)
		pole_end = Vector2i(62, y + 19)
	elif animation == "attack_sweep":
		pole_start = Vector2i(x + 1, y + 18)
		pole_end = Vector2i(58, y + 8 + frame * 4)
	elif animation == "attack_shaft_push":
		pole_start = Vector2i(x + 4, y + 21)
		pole_end = Vector2i(49, y + 21)
	_draw_weapon(image, pole_start, pole_end, STEEL, 2)
	_rect(image, pole_end.x - 1, pole_end.y - 3, 5, 7, PALE)


func _draw_armor(image: Image, animation: String, frame: int, bob: int, lean: int) -> void:
	var x: int = 25 + lean
	var y: int = 12 + bob
	_rect(image, x - 8, y, 17, 13, OUTLINE)
	_rect(image, x - 6, y + 2, 13, 9, IRON)
	_rect(image, x + 3, y + 6, 3, 1, VIOLET)
	_rect(image, x - 11, y + 12, 23, 25, OUTLINE)
	_rect(image, x - 9, y + 14, 19, 21, Color("464a5a"))
	_rect(image, x - 13, y + 15, 5, 11, STEEL)
	_rect(image, x + 9, y + 15, 5, 11, STEEL)
	var stride: int = _stride(frame) if animation == "walk" else 0
	_rect(image, x - 8 - stride, y + 37, 7, 13, OUTLINE)
	_rect(image, x + 2 + stride, y + 37, 7, 13, OUTLINE)
	var weapon_start: Vector2i = Vector2i(x + 9, y + 19)
	var weapon_end: Vector2i = Vector2i(x + 23, y + 32)
	if animation == "attack_overhead":
		weapon_end = Vector2i(x + 13 + frame * 2, y - 7 + frame * 5)
	elif animation == "attack_heavy_sweep":
		weapon_end = Vector2i(x + 18 + frame * 3, y + 6 + frame * 3)
	elif animation == "attack_shoulder_bash":
		weapon_end = Vector2i(x + 15, y + 19)
	_draw_weapon(image, weapon_start, weapon_end, PALE, 3)


func _draw_acolyte(image: Image, animation: String, frame: int, bob: int, lean: int) -> void:
	var x: int = 27 + lean
	var y: int = 13 + bob
	_rect(image, x - 6, y, 13, 11, OUTLINE)
	_rect(image, x - 4, y + 2, 9, 7, Color("31253a"))
	_rect(image, x + 2, y + 5, 2, 1, BLOOD)
	_rect(image, x - 8, y + 11, 17, 28, OUTLINE)
	_rect(image, x - 6, y + 13, 13, 25, Color("4a2941"))
	_rect(image, x - 8, y + 39, 17, 8, OUTLINE)
	_rect(image, x - 4, y + 25, 2, 17, SLATE)
	_rect(image, x + 3, y + 25, 2, 17, SLATE)
	var candle_x: int = x + 10 + (frame * 2 if animation == "attack_cast" else 0)
	_rect(image, candle_x, y + 14, 3, 10, PALE)
	_rect(image, candle_x, y + 11 - (frame % 2), 3, 4, EMBER)
	if animation == "attack_cast" and frame >= 3:
		_rect(image, candle_x + 5, y + 11, 3, 3, BLOOD)
	if animation == "buff_channel":
		_rect(image, x - 10, y + 8 + frame, 2, 2, EMBER)
		_rect(image, x + 11, y + 5 + (3 - frame), 2, 2, EMBER)


func _draw_stalker(image: Image, animation: String, frame: int, phase: float) -> void:
	if animation == "death":
		_draw_death(image, "hanging_stalker", frame, 6)
		return
	var hanging: bool = animation in ["hang", "telegraph", "return_to_anchor"]
	var x: int = 28 + (frame % 2)
	var y: int = 7 if hanging else 14 + int(phase * 7.0 if animation == "drop" else 0.0)
	if hanging:
		_rect(image, x - 2, 2, 5, 7, OUTLINE)
	_rect(image, x - 5, y, 11, 9, OUTLINE)
	_rect(image, x - 3, y + 2, 7, 5, Color("2b293b"))
	_rect(image, x + 2, y + 4, 2, 1, PALE)
	_rect(image, x - 5, y + 9, 11, 23, OUTLINE)
	_rect(image, x - 3, y + 11, 7, 19, VIOLET)
	# Bat-membrane arms create a broad curse-beast silhouette, not insect wings.
	_rect(image, x - 14, y + 11, 9, 4, OUTLINE)
	_rect(image, x + 6, y + 11, 10, 4, OUTLINE)
	_rect(image, x - 11, y + 15, 6, 5, Color("4c405f"))
	_rect(image, x + 6, y + 15, 7, 5, Color("4c405f"))
	var leg_offset: int = 3 if animation == "claw" and frame >= 2 else 0
	_rect(image, x - 4, y + 32, 3, 17 - leg_offset, OUTLINE)
	_rect(image, x + 2, y + 32, 3, 17 + leg_offset, OUTLINE)
	if animation == "telegraph" and frame % 2 == 1:
		_rect(image, x - 15, y + 25, 2, 2, PALE)
		_rect(image, x + 16, y + 28, 2, 2, PALE)


func _draw_death(image: Image, enemy_name: String, frame: int, count: int) -> void:
	var fade_step: int = frame * 2
	var body_width: int = 18 if enemy_name != "mourning_armor" else 26
	var body_height: int = maxi(2, 24 - frame * 4)
	var x: int = 30 - body_width / 2
	var y: int = 56 - body_height
	_rect(image, x, y, body_width, body_height, OUTLINE)
	if frame < count - 2:
		_rect(image, x + 2, y + 2, maxi(1, body_width - 4), maxi(1, body_height - 4), IRON)
	for particle: int in range(frame):
		_rect(image, 22 + particle * 5, 46 - fade_step - particle * 2, 2, 2, VIOLET)


func _draw_weapon(image: Image, start: Vector2i, end: Vector2i, color: Color, thickness: int) -> void:
	var points: int = maxi(abs(end.x - start.x), abs(end.y - start.y))
	if points == 0:
		return
	for index: int in range(points + 1):
		var t: float = float(index) / float(points)
		var point: Vector2i = Vector2i(roundi(lerpf(start.x, end.x, t)), roundi(lerpf(start.y, end.y, t)))
		_rect(image, point.x, point.y, thickness, thickness, color)


func _rect(image: Image, x: int, y: int, width: int, height: int, color: Color) -> void:
	var clipped: Rect2i = Rect2i(x, y, width, height).intersection(Rect2i(0, 0, 64, 64))
	if clipped.size.x > 0 and clipped.size.y > 0:
		image.fill_rect(clipped, color)


func _stride(frame: int) -> int:
	return [-2, -1, 0, 2, 1, 0][frame % 6]
