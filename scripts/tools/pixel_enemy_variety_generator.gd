extends SceneTree

## Deterministic original 64×64 pixel production frames for the first enemy variety batch.

const PixelCanvas: Script = preload("res://scripts/tools/pixel_art_canvas.gd")
const ROOT: String = "res://assets/sprites/enemies"
const DARK: Color = Color("10141d")
const IRON: Color = Color("303846")
const MID_IRON: Color = Color("566171")
const STEEL: Color = Color("a9b3bc")
const RUST: Color = Color("83513b")
const RED_EYE: Color = Color("b84d4d")
const BLUE_EYE: Color = Color("6f9eb0")
const LEATHER: Color = Color("49372f")
const BONE: Color = Color("c0b7a1")
const DISSOLVE: Color = Color(0.32, 0.37, 0.43, 0.55)
const PALE_FLASH: Color = Color("f2e6b8")
const FX_FADE: Color = Color(0.66, 0.71, 0.74, 0.55)
const GUARD_BREAK_LEAN: Array[int] = [0, -2, -4, -2]
const GUARD_BREAK_BOB: Array[int] = [0, 1, 2, 1]
const GUARD_BREAK_LEGS: Array[int] = [0, -2, 3, 1]

const DEFINITIONS: Dictionary[String, Dictionary] = {
	"cursed_shield_guard": {
		"idle": 4, "walk": 6, "block": 3, "attack": 5,
		"guard_break": 4, "hurt": 3, "death": 6,
		"idle_unshielded": 4, "walk_unshielded": 6, "attack_unshielded": 5,
		"hurt_unshielded": 3, "death_unshielded": 6,
	},
	"decayed_spearman": {
		"idle": 4, "walk": 6, "attack_thrust": 6, "hurt": 3, "death": 6,
	},
	"fallen_crossbowman": {
		"idle": 4, "walk": 6, "aim": 4, "shoot": 3,
		"reload": 4, "hurt": 3, "death": 6,
	},
}


func _initialize() -> void:
	var failures: int = 0
	var total: int = 0
	for enemy_name: String in DEFINITIONS:
		var animations: Dictionary = DEFINITIONS[enemy_name]
		for animation_name: String in animations:
			var count: int = animations[animation_name] as int
			for frame_index: int in range(count):
				var image: Image = _draw_frame(enemy_name, animation_name, frame_index, count)
				var output_path: String = ROOT.path_join(enemy_name).path_join(animation_name).path_join(
					"%s_%02d.png" % [animation_name, frame_index + 1]
				)
				failures += 0 if _save_png(image, output_path) == OK else 1
				total += 1
	for frame_index: int in range(4):
		var shield_fx: Image = _draw_shield_break_fx(frame_index)
		var shield_fx_path: String = ROOT.path_join("cursed_shield_guard").path_join(
			"shield_break_fx"
		).path_join("shield_break_fx_%02d.png" % (frame_index + 1))
		failures += 0 if _save_png(shield_fx, shield_fx_path) == OK else 1
		total += 1
	for shield_state: String in ["intact", "cracked", "critical"]:
		var shield_state_image: Image = _draw_shield_visual_state(shield_state)
		var shield_state_path: String = ROOT.path_join("cursed_shield_guard").path_join(
			"shield_visual"
		).path_join("%s.png" % shield_state)
		failures += 0 if _save_png(shield_state_image, shield_state_path) == OK else 1
		total += 1
	for frame_index: int in range(4):
		var shield_break_image: Image = _draw_shield_visual_break(frame_index)
		var shield_break_path: String = ROOT.path_join("cursed_shield_guard").path_join(
			"shield_visual"
		).path_join("shield_break_%02d.png" % (frame_index + 1))
		failures += 0 if _save_png(shield_break_image, shield_break_path) == OK else 1
		total += 1
	for frame_index: int in range(3):
		var shield_hit_image: Image = _draw_shield_hit_fx(frame_index)
		var shield_hit_path: String = ROOT.path_join("cursed_shield_guard").path_join(
			"shield_hit_fx"
		).path_join("shield_hit_fx_%02d.png" % (frame_index + 1))
		failures += 0 if _save_png(shield_hit_image, shield_hit_path) == OK else 1
		total += 1
	var broken_shield_marker: Image = _draw_broken_shield_marker()
	var marker_path: String = ROOT.path_join("cursed_shield_guard").path_join(
		"shield_break_fx"
	).path_join("broken_shield_marker.png")
	failures += 0 if _save_png(broken_shield_marker, marker_path) == OK else 1
	total += 1
	var bolt: Image = PixelCanvas.create_transparent(Vector2i(24, 8))
	PixelCanvas.draw_line(bolt, Vector2i(2, 4), Vector2i(20, 4), STEEL, 2)
	PixelCanvas.fill_rect(bolt, Rect2i(0, 2, 4, 5), RUST)
	PixelCanvas.fill_rect(bolt, Rect2i(20, 3, 4, 3), BONE)
	failures += 0 if _save_png(bolt, "res://assets/sprites/projectiles/crossbow_bolt.png") == OK else 1
	total += 1
	print("ENEMY_VARIETY_PIXEL_BUILD: %s (%d files)" % ["OK" if failures == 0 else "FAIL", total])
	quit(0 if failures == 0 else 1)


func _draw_frame(enemy_name: String, animation_name: String, frame: int, count: int) -> Image:
	match enemy_name:
		"cursed_shield_guard":
			return _draw_shield(animation_name, frame, count)
		"decayed_spearman":
			return _draw_spearman(animation_name, frame, count)
		_:
			return _draw_crossbowman(animation_name, frame, count)


func _draw_shield(animation_name: String, frame: int, count: int) -> Image:
	var image: Image = PixelCanvas.create_transparent(Vector2i(64, 64))
	var base_animation: String = animation_name.trim_suffix("_unshielded")
	if base_animation == "death":
		_draw_fallen_armored(image, frame, count, false)
		return image
	var bob: int = 1 if base_animation == "idle" and frame in [1, 2] else 0
	var lean: int = -frame * 2 if base_animation == "hurt" else 0
	if base_animation == "guard_break":
		lean = GUARD_BREAK_LEAN[frame]
		bob += GUARD_BREAK_BOB[frame]
	var cx: int = 29 + lean
	var top: int = 18 + bob
	var walk_phase: int = (
		[-3, -1, 1, 3, 1, -1][frame] if base_animation == "walk" else 0
	)
	if base_animation == "guard_break":
		walk_phase = GUARD_BREAK_LEGS[frame]
	PixelCanvas.fill_rect(image, Rect2i(cx - 9, top + 15, 19, 24), DARK)
	PixelCanvas.fill_rect(image, Rect2i(cx - 7, top + 17, 15, 18), IRON)
	PixelCanvas.fill_rect(image, Rect2i(cx - 11, top + 15, 5, 10), MID_IRON)
	PixelCanvas.fill_rect(image, Rect2i(cx + 7, top + 15, 5, 10), MID_IRON)
	PixelCanvas.fill_rect(image, Rect2i(cx - 8, top, 17, 15), DARK)
	PixelCanvas.fill_rect(image, Rect2i(cx - 6, top + 2, 13, 10), IRON)
	PixelCanvas.fill_rect(image, Rect2i(cx - 7, top + 7, 15, 3), MID_IRON)
	PixelCanvas.fill_rect(image, Rect2i(cx + 3, top + 8, 3, 2), RED_EYE)
	PixelCanvas.draw_line(image, Vector2i(cx - 5, top + 37), Vector2i(cx - 7 - walk_phase, 59), IRON, 6)
	PixelCanvas.draw_line(image, Vector2i(cx + 5, top + 37), Vector2i(cx + 8 + walk_phase, 59), IRON, 6)
	PixelCanvas.fill_rect(image, Rect2i(cx - 12 - walk_phase, 58, 11, 3), DARK)
	PixelCanvas.fill_rect(image, Rect2i(cx + 2 + walk_phase, 58, 12, 3), DARK)
	# Shield is intentionally absent from body art. FacingRoot/ShieldVisual owns it.
	PixelCanvas.draw_line(
		image, Vector2i(cx + 8, top + 21), Vector2i(cx + 12, top + 33), IRON, 4
	)
	var weapon_start: Vector2i = Vector2i(cx - 6, top + 24)
	var weapon_end: Vector2i = Vector2i(cx - 15, top + 38)
	if base_animation == "attack":
		var attack_tips: Array[Vector2i] = [
			Vector2i(cx - 7, top - 7), Vector2i(cx + 2, top - 11),
			Vector2i(55, top + 20), Vector2i(61, top + 24), Vector2i(cx + 12, top + 31),
		]
		weapon_end = attack_tips[frame]
	PixelCanvas.draw_line(image, weapon_start, weapon_end, RUST, 3)
	PixelCanvas.fill_rect(image, Rect2i(weapon_end.x - 2, weapon_end.y - 2, 5, 5), STEEL)
	return image


func _draw_shield_cracks(image: Image, center: Vector2i) -> void:
	PixelCanvas.draw_line(
		image, center + Vector2i(0, -8), center + Vector2i(-2, -1), PALE_FLASH, 1
	)
	PixelCanvas.draw_line(
		image, center + Vector2i(-2, -1), center + Vector2i(3, 4), PALE_FLASH, 1
	)
	PixelCanvas.draw_line(
		image, center + Vector2i(-2, -1), center + Vector2i(-5, 5), PALE_FLASH, 1
	)


func _draw_shield_fragments(image: Image, center: Vector2i, frame: int) -> void:
	var spread: int = frame * 4
	PixelCanvas.fill_rect(image, Rect2i(center.x - 6 - spread, center.y - 7, 5, 5), MID_IRON)
	PixelCanvas.fill_rect(image, Rect2i(center.x + 2 + spread, center.y - 9, 4, 7), RUST)
	PixelCanvas.fill_rect(image, Rect2i(center.x - 4, center.y + 4 + spread, 6, 4), STEEL)
	PixelCanvas.fill_rect(image, Rect2i(center.x + 5 + spread, center.y + 3, 3, 5), MID_IRON)


func _draw_shield_break_fx(frame: int) -> Image:
	var image: Image = PixelCanvas.create_transparent(Vector2i(64, 64))
	var center: Vector2i = Vector2i(39, 36)
	if frame == 0:
		PixelCanvas.draw_line(image, center + Vector2i(-15, 0), center + Vector2i(15, 0), PALE_FLASH, 3)
		PixelCanvas.draw_line(image, center + Vector2i(0, -16), center + Vector2i(0, 16), PALE_FLASH, 3)
		PixelCanvas.draw_line(image, center + Vector2i(-10, -10), center + Vector2i(10, 10), PALE_FLASH, 2)
		PixelCanvas.draw_line(image, center + Vector2i(-10, 10), center + Vector2i(10, -10), PALE_FLASH, 2)
		PixelCanvas.fill_rect(image, Rect2i(center.x - 4, center.y - 4, 9, 9), Color.WHITE)
	elif frame == 1:
		_draw_shield_fragments(image, center, 1)
		PixelCanvas.draw_line(image, center + Vector2i(-10, 0), center + Vector2i(10, 0), PALE_FLASH, 2)
		PixelCanvas.draw_line(image, center + Vector2i(0, -11), center + Vector2i(0, 11), PALE_FLASH, 2)
		PixelCanvas.fill_rect(image, Rect2i(center.x - 3, center.y - 3, 7, 7), PALE_FLASH)
	elif frame == 2:
		_draw_shield_fragments(image, center, 2)
		PixelCanvas.draw_line(image, center + Vector2i(-6, -5), center + Vector2i(6, 5), FX_FADE, 2)
	else:
		PixelCanvas.fill_rect(image, Rect2i(center.x - 19, center.y - 12, 4, 4), FX_FADE)
		PixelCanvas.fill_rect(image, Rect2i(center.x + 19, center.y - 8, 4, 5), FX_FADE)
		PixelCanvas.fill_rect(image, Rect2i(center.x - 7, center.y + 18, 5, 4), FX_FADE)
	return image


func _draw_shield_visual_state(state: String) -> Image:
	var image: Image = PixelCanvas.create_transparent(Vector2i(64, 64))
	var center: Vector2i = Vector2i(39, 36)
	_draw_shield_shape(image, center)
	if state == "cracked" or state == "critical":
		_draw_shield_cracks(image, center)
	if state == "critical":
		PixelCanvas.draw_line(
			image, center + Vector2i(3, -7), center + Vector2i(0, 1), PALE_FLASH, 2
		)
		PixelCanvas.draw_line(
			image, center + Vector2i(0, 1), center + Vector2i(6, 7), PALE_FLASH, 2
		)
		PixelCanvas.fill_rect(image, Rect2i(center.x + 7, center.y - 10, 4, 5), Color.TRANSPARENT)
		PixelCanvas.fill_rect(image, Rect2i(center.x - 10, center.y + 7, 4, 4), Color.TRANSPARENT)
	return image


func _draw_shield_visual_break(frame: int) -> Image:
	var image: Image = PixelCanvas.create_transparent(Vector2i(64, 64))
	var center: Vector2i = Vector2i(39, 36)
	if frame == 0:
		image = _draw_shield_visual_state("critical")
		PixelCanvas.draw_line(
			image, center + Vector2i(-12, 0), center + Vector2i(12, 0), PALE_FLASH, 2
		)
	elif frame < 3:
		_draw_shield_fragments(image, center, frame)
	else:
		PixelCanvas.fill_rect(image, Rect2i(center.x - 18, center.y - 10, 3, 3), FX_FADE)
		PixelCanvas.fill_rect(image, Rect2i(center.x + 17, center.y - 7, 3, 4), FX_FADE)
		PixelCanvas.fill_rect(image, Rect2i(center.x - 5, center.y + 17, 4, 3), FX_FADE)
	return image


func _draw_shield_hit_fx(frame: int) -> Image:
	var image: Image = PixelCanvas.create_transparent(Vector2i(64, 64))
	var center: Vector2i = Vector2i(39, 36)
	var spread: int = frame * 3
	PixelCanvas.fill_rect(
		image, Rect2i(center.x - 2 - spread, center.y - 12 - spread, 3, 3), PALE_FLASH
	)
	PixelCanvas.fill_rect(
		image, Rect2i(center.x + 7 + spread, center.y - 5, 3, 2), PALE_FLASH
	)
	PixelCanvas.fill_rect(
		image, Rect2i(center.x - 7 - spread, center.y + 7 + spread, 2, 3), RUST
	)
	if frame == 0:
		PixelCanvas.draw_line(
			image, center + Vector2i(-7, 0), center + Vector2i(7, 0), PALE_FLASH, 2
		)
	return image


func _draw_broken_shield_marker() -> Image:
	var image: Image = PixelCanvas.create_transparent(Vector2i(20, 20))
	# Two visibly separated metal halves and a bright lightning-shaped fracture.
	PixelCanvas.fill_rect(image, Rect2i(2, 2, 7, 12), DARK)
	PixelCanvas.fill_rect(image, Rect2i(11, 2, 7, 12), DARK)
	PixelCanvas.fill_rect(image, Rect2i(4, 4, 4, 9), MID_IRON)
	PixelCanvas.fill_rect(image, Rect2i(12, 4, 4, 9), MID_IRON)
	PixelCanvas.fill_rect(image, Rect2i(5, 13, 3, 3), DARK)
	PixelCanvas.fill_rect(image, Rect2i(12, 13, 3, 3), DARK)
	PixelCanvas.draw_line(image, Vector2i(9, 1), Vector2i(11, 6), PALE_FLASH, 2)
	PixelCanvas.draw_line(image, Vector2i(11, 6), Vector2i(8, 10), PALE_FLASH, 2)
	PixelCanvas.draw_line(image, Vector2i(8, 10), Vector2i(10, 17), PALE_FLASH, 2)
	PixelCanvas.fill_rect(image, Rect2i(1, 7, 2, 3), RUST)
	PixelCanvas.fill_rect(image, Rect2i(17, 6, 2, 3), RUST)
	return image


func _draw_spearman(animation_name: String, frame: int, count: int) -> Image:
	var image: Image = PixelCanvas.create_transparent(Vector2i(64, 64))
	if animation_name == "death":
		_draw_fallen_armored(image, frame, count, false)
		PixelCanvas.draw_line(image, Vector2i(4, 59), Vector2i(56, 57), BONE, 2)
		return image
	var bob: int = 1 if animation_name == "idle" and frame in [1, 2] else 0
	var lean: int = -frame * 2 if animation_name == "hurt" else 0
	var cx: int = 28 + lean
	var top: int = 13 + bob
	var walk_phase: int = [-4, -2, 0, 4, 2, 0][frame] if animation_name == "walk" else 0
	PixelCanvas.fill_rect(image, Rect2i(cx - 6, top + 17, 13, 25), LEATHER)
	PixelCanvas.fill_rect(image, Rect2i(cx - 5, top + 19, 11, 18), MID_IRON)
	for y: int in range(top + 21, top + 36, 4):
		PixelCanvas.fill_rect(image, Rect2i(cx - 4, y, 9, 1), STEEL)
	PixelCanvas.fill_rect(image, Rect2i(cx - 6, top + 2, 13, 14), DARK)
	PixelCanvas.fill_rect(image, Rect2i(cx - 4, top + 4, 9, 9), IRON)
	PixelCanvas.fill_rect(image, Rect2i(cx - 1, top - 2, 3, 7), STEEL)
	PixelCanvas.fill_rect(image, Rect2i(cx + 2, top + 9, 3, 2), BLUE_EYE)
	PixelCanvas.draw_line(image, Vector2i(cx - 3, top + 40), Vector2i(cx - 6 - walk_phase, 59), IRON, 5)
	PixelCanvas.draw_line(image, Vector2i(cx + 4, top + 40), Vector2i(cx + 7 + walk_phase, 59), IRON, 5)
	PixelCanvas.fill_rect(image, Rect2i(cx - 10 - walk_phase, 58, 9, 3), DARK)
	PixelCanvas.fill_rect(image, Rect2i(cx + 2 + walk_phase, 58, 10, 3), DARK)
	var hand: Vector2i = Vector2i(cx + 5, top + 26)
	var butt: Vector2i = Vector2i(cx - 16, top + 36)
	var tip: Vector2i = Vector2i(58, top + 20)
	if animation_name == "attack_thrust":
		var hand_offsets: Array[int] = [-4, -6, -2, 4, 7, 0]
		hand.x += hand_offsets[frame]
		var tips: Array[Vector2i] = [
			Vector2i(42, top + 27), Vector2i(37, top + 29), Vector2i(49, top + 25),
			Vector2i(63, top + 24), Vector2i(63, top + 24), Vector2i(52, top + 26),
		]
		tip = tips[frame]
	PixelCanvas.draw_line(image, butt, tip, BONE, 2)
	PixelCanvas.fill_rect(image, Rect2i(tip.x - 1, tip.y - 2, 4, 5), STEEL)
	PixelCanvas.fill_rect(image, Rect2i(hand.x - 2, hand.y - 2, 5, 5), LEATHER)
	return image


func _draw_crossbowman(animation_name: String, frame: int, count: int) -> Image:
	var image: Image = PixelCanvas.create_transparent(Vector2i(64, 64))
	if animation_name == "death":
		_draw_fallen_leather(image, frame, count)
		return image
	var bob: int = 1 if animation_name == "idle" and frame in [1, 2] else 0
	var lean: int = -frame * 2 if animation_name == "hurt" else 0
	var cx: int = 29 + lean
	var top: int = 18 + bob
	var walk_phase: int = [-3, -1, 1, 3, 1, -1][frame] if animation_name == "walk" else 0
	PixelCanvas.fill_rect(image, Rect2i(cx - 6, top + 15, 13, 23), LEATHER)
	PixelCanvas.fill_rect(image, Rect2i(cx - 4, top + 18, 9, 15), IRON)
	PixelCanvas.fill_rect(image, Rect2i(cx - 7, top + 2, 15, 13), DARK)
	PixelCanvas.fill_rect(image, Rect2i(cx - 5, top + 5, 11, 8), IRON)
	PixelCanvas.fill_rect(image, Rect2i(cx + 2, top + 9, 3, 2), RED_EYE)
	PixelCanvas.fill_rect(image, Rect2i(cx - 11, top + 17, 4, 19), RUST)
	PixelCanvas.draw_line(image, Vector2i(cx - 3, top + 37), Vector2i(cx - 6 - walk_phase, 59), LEATHER, 5)
	PixelCanvas.draw_line(image, Vector2i(cx + 4, top + 37), Vector2i(cx + 7 + walk_phase, 59), LEATHER, 5)
	PixelCanvas.fill_rect(image, Rect2i(cx - 10 - walk_phase, 58, 9, 3), DARK)
	PixelCanvas.fill_rect(image, Rect2i(cx + 2 + walk_phase, 58, 10, 3), DARK)
	var crossbow_y: int = top + 27
	var crossbow_x: int = cx + 3
	if animation_name == "aim":
		crossbow_x += 3
	elif animation_name == "shoot":
		crossbow_x += frame * 3
	elif animation_name == "reload":
		crossbow_y += 4 + frame
	_draw_crossbow(image, Vector2i(crossbow_x, crossbow_y))
	return image


func _draw_shield_shape(image: Image, center: Vector2i) -> void:
	PixelCanvas.fill_rect(image, Rect2i(center.x - 7, center.y - 10, 14, 22), DARK)
	PixelCanvas.fill_rect(image, Rect2i(center.x - 5, center.y - 8, 10, 18), MID_IRON)
	PixelCanvas.fill_rect(image, Rect2i(center.x - 1, center.y - 6, 3, 14), RUST)
	PixelCanvas.fill_rect(image, Rect2i(center.x - 3, center.y, 7, 3), STEEL)


func _draw_crossbow(image: Image, center: Vector2i) -> void:
	PixelCanvas.draw_line(image, Vector2i(center.x - 2, center.y), Vector2i(center.x + 22, center.y), RUST, 3)
	PixelCanvas.draw_line(image, Vector2i(center.x + 8, center.y - 7), Vector2i(center.x + 18, center.y), STEEL, 2)
	PixelCanvas.draw_line(image, Vector2i(center.x + 8, center.y + 7), Vector2i(center.x + 18, center.y), STEEL, 2)
	PixelCanvas.draw_line(image, Vector2i(center.x + 1, center.y), Vector2i(center.x + 22, center.y), BONE, 1)


func _draw_fallen_armored(image: Image, frame: int, count: int, with_shield: bool) -> void:
	var fall: int = mini(frame, 3)
	var alpha_color: Color = DISSOLVE if frame >= count - 2 else IRON
	var body_y: int = 36 + fall * 7
	PixelCanvas.draw_line(image, Vector2i(27 - fall * 4, 23 + fall * 7), Vector2i(36, body_y + 12), alpha_color, 10)
	PixelCanvas.fill_rect(image, Rect2i(17 - fall * 3, 18 + fall * 7, 14, 12), DARK if frame < count - 2 else DISSOLVE)
	PixelCanvas.fill_rect(image, Rect2i(21 - fall * 3, 24 + fall * 7, 5, 2), RED_EYE)
	PixelCanvas.draw_line(image, Vector2i(34, body_y + 8), Vector2i(53, 59), alpha_color, 5)
	if with_shield:
		_draw_shield_shape(image, Vector2i(45, 51 + mini(frame, 2) * 3))
	if frame == count - 1:
		PixelCanvas.fill_rect(image, Rect2i(12, 56, 4, 3), DISSOLVE)
		PixelCanvas.fill_rect(image, Rect2i(31, 53, 3, 3), DISSOLVE)
		PixelCanvas.fill_rect(image, Rect2i(54, 58, 5, 2), DISSOLVE)


func _draw_fallen_leather(image: Image, frame: int, count: int) -> void:
	var fall: int = mini(frame, 3)
	var color: Color = DISSOLVE if frame >= count - 2 else LEATHER
	PixelCanvas.draw_line(image, Vector2i(24 - fall * 4, 25 + fall * 7), Vector2i(42, 55), color, 8)
	PixelCanvas.fill_rect(image, Rect2i(17 - fall * 3, 19 + fall * 7, 14, 11), DARK if frame < count - 2 else DISSOLVE)
	_draw_crossbow(image, Vector2i(39, 54 + mini(frame, 2) * 2))
	if frame == count - 1:
		PixelCanvas.fill_rect(image, Rect2i(15, 57, 4, 2), DISSOLVE)
		PixelCanvas.fill_rect(image, Rect2i(48, 55, 4, 3), DISSOLVE)


func _save_png(image: Image, path: String) -> Error:
	var directory_error: Error = DirAccess.make_dir_recursive_absolute(
		ProjectSettings.globalize_path(path.get_base_dir())
	)
	if directory_error != OK:
		push_error("Cannot create %s" % path.get_base_dir())
		return directory_error
	var save_error: Error = image.save_png(ProjectSettings.globalize_path(path))
	if save_error != OK:
		push_error("Cannot save %s" % path)
	return save_error
