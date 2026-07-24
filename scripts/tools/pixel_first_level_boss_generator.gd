extends SceneTree

## Deterministic original pixel frames for Gargoyle Sentinel and Fallen Gate Knight.

const PixelCanvas: Script = preload("res://scripts/tools/pixel_art_canvas.gd")
const ROOT: String = "res://assets/sprites"
const VOID: Color = Color("0c1019")
const IRON: Color = Color("303846")
const MID: Color = Color("596776")
const STEEL: Color = Color("b6c2c9")
const RUST: Color = Color("7b4638")
const EYE: Color = Color("b34b58")
const CURSE: Color = Color("738fa3")
const GOLD: Color = Color("a17a45")
const FADE: Color = Color(0.34, 0.42, 0.49, 0.48)

const GARGOYLE: Dictionary[String, int] = {
	"dormant": 4, "wake": 4, "hover": 4, "dive_windup": 4, "dive": 4,
	"ground_stun": 4, "return_to_air": 4, "hurt": 3,
	"death_fall": 5, "death_shatter": 5,
}
const BOSS: Dictionary[String, int] = {
	"idle_shielded": 4, "walk_shielded": 6, "shield_block": 4,
	"shield_bash": 5, "sword_slash": 5, "heavy_overhead": 6,
	"hurt_shielded": 3, "shield_break": 5, "phase_transition": 5,
	"idle_unshielded": 4, "walk_unshielded": 6, "combo_slash_1": 5,
	"combo_slash_2": 5, "jump_smash": 6, "charge_thrust": 5,
	"shockwave_strike": 6, "hurt_unshielded": 3, "death": 7,
}


func _initialize() -> void:
	var failures: int = 0
	var total: int = 0
	for animation_name: String in GARGOYLE:
		for frame: int in range(GARGOYLE[animation_name]):
			var path: String = _frame_path("enemies/gargoyle_sentinel", animation_name, frame)
			failures += 0 if _save_png(_draw_gargoyle(animation_name, frame), path) == OK else 1
			total += 1
	for animation_name: String in BOSS:
		for frame: int in range(BOSS[animation_name]):
			var path: String = _frame_path("bosses/fallen_gate_knight", animation_name, frame)
			failures += 0 if _save_png(_draw_boss(animation_name, frame), path) == OK else 1
			total += 1
	print("FIRST_LEVEL_BOSS_PIXEL_BUILD: %s (%d files)" % ["OK" if failures == 0 else "FAIL", total])
	quit(0 if failures == 0 else 1)


func _draw_gargoyle(animation_name: String, frame: int) -> Image:
	var image: Image = PixelCanvas.create_transparent(Vector2i(64, 64))
	if animation_name == "death_shatter":
		_draw_gargoyle_shatter(image, frame)
		return image
	var hover_bob: int = [0, -1, 0, 1][frame % 4] if animation_name == "hover" else 0
	var center: Vector2i = Vector2i(31, 31 + hover_bob)
	var horizontal: bool = animation_name == "dive"
	var crouched: bool = animation_name in ["dive_windup", "ground_stun"]
	var fall: int = frame * 5 if animation_name == "death_fall" else 0
	center.y += fall
	var body_color: Color = FADE if animation_name == "death_fall" and frame >= 4 else IRON
	if horizontal:
		PixelCanvas.fill_rect(image, Rect2i(center.x - 12, center.y - 6, 25, 13), body_color)
		PixelCanvas.fill_rect(image, Rect2i(center.x + 9, center.y - 7, 10, 10), VOID)
		PixelCanvas.fill_rect(image, Rect2i(center.x + 14, center.y - 4, 3, 2), EYE)
		PixelCanvas.draw_line(image, center + Vector2i(-8, 5), center + Vector2i(-20, 13), MID, 4)
		PixelCanvas.draw_line(image, center + Vector2i(2, 5), center + Vector2i(-7, 16), MID, 4)
		PixelCanvas.draw_line(image, center + Vector2i(-7, -4), center + Vector2i(-22, -11), CURSE, 4)
		return image
	var body_top: int = center.y - (5 if crouched else 10)
	PixelCanvas.fill_rect(image, Rect2i(center.x - 8, body_top, 17, 20), body_color)
	PixelCanvas.fill_rect(image, Rect2i(center.x - 7, body_top - 11, 15, 12), VOID)
	PixelCanvas.fill_rect(image, Rect2i(center.x + 3, body_top - 5, 3, 2), EYE)
	# Angular stone wings keep the airborne silhouette separate from grounded soldiers.
	var wing_spread: int = 4 + (frame % 2) * 3 if animation_name in ["wake", "hover", "return_to_air"] else 2
	PixelCanvas.draw_line(image, Vector2i(center.x - 7, body_top + 4), Vector2i(center.x - 21 - wing_spread, body_top - 7), CURSE, 5)
	PixelCanvas.draw_line(image, Vector2i(center.x + 7, body_top + 4), Vector2i(center.x + 20 + wing_spread, body_top - 8), CURSE, 5)
	PixelCanvas.draw_line(image, Vector2i(center.x - 5, body_top + 18), Vector2i(center.x - 11, center.y + 17), MID, 5)
	PixelCanvas.draw_line(image, Vector2i(center.x + 5, body_top + 18), Vector2i(center.x + 10, center.y + 17), MID, 5)
	PixelCanvas.fill_rect(image, Rect2i(center.x - 15, center.y + 14, 9, 3), VOID)
	PixelCanvas.fill_rect(image, Rect2i(center.x + 5, center.y + 14, 10, 3), VOID)
	if animation_name == "hurt":
		PixelCanvas.draw_line(image, center + Vector2i(-15, -13), center + Vector2i(14, 13), STEEL, 2)
	return image


func _draw_gargoyle_shatter(image: Image, frame: int) -> void:
	var spread: int = frame * 3
	var color: Color = Color(FADE.r, FADE.g, FADE.b, 0.75 - frame * 0.12)
	PixelCanvas.fill_rect(image, Rect2i(26 - spread, 46 - spread, 7, 6), color)
	PixelCanvas.fill_rect(image, Rect2i(35 + spread, 43 - spread, 6, 8), color)
	PixelCanvas.fill_rect(image, Rect2i(22 - spread, 54, 5, 4), color)
	PixelCanvas.fill_rect(image, Rect2i(39 + spread, 55, 6, 4), color)


func _draw_boss(animation_name: String, frame: int) -> Image:
	var image: Image = PixelCanvas.create_transparent(Vector2i(96, 96))
	var unshielded: bool = animation_name in [
		"phase_transition", "idle_unshielded", "walk_unshielded", "combo_slash_1",
		"combo_slash_2", "jump_smash", "charge_thrust", "shockwave_strike",
		"hurt_unshielded", "death",
	]
	var death_fall: int = mini(frame, 4) * 8 if animation_name == "death" else 0
	var bob: int = 1 if animation_name.begins_with("idle") and frame in [1, 2] else 0
	var walk: int = [-5, -2, 1, 5, 2, -1][frame] if animation_name.begins_with("walk") else 0
	var cx: int = 45 - death_fall
	var top: int = 20 + bob + mini(death_fall, 24)
	var armor: Color = FADE if animation_name == "death" and frame >= 5 else IRON
	# Heavy 1.6x body, closed helm, eye slit, broad shoulders.
	PixelCanvas.fill_rect(image, Rect2i(cx - 13, top + 24, 27, 35), VOID)
	PixelCanvas.fill_rect(image, Rect2i(cx - 10, top + 26, 21, 29), armor)
	PixelCanvas.fill_rect(image, Rect2i(cx - 17, top + 24, 8, 13), MID)
	PixelCanvas.fill_rect(image, Rect2i(cx + 10, top + 24, 8, 13), MID)
	PixelCanvas.fill_rect(image, Rect2i(cx - 11, top, 23, 23), VOID)
	PixelCanvas.fill_rect(image, Rect2i(cx - 8, top + 3, 17, 15), armor)
	PixelCanvas.fill_rect(image, Rect2i(cx - 9, top + 12, 19, 4), MID)
	PixelCanvas.fill_rect(image, Rect2i(cx + 4, top + 13, 4, 2), EYE)
	PixelCanvas.draw_line(image, Vector2i(cx - 7, top + 55), Vector2i(cx - 12 - walk, 87), armor, 8)
	PixelCanvas.draw_line(image, Vector2i(cx + 7, top + 55), Vector2i(cx + 13 + walk, 87), armor, 8)
	PixelCanvas.fill_rect(image, Rect2i(cx - 21 - walk, 85, 17, 5), VOID)
	PixelCanvas.fill_rect(image, Rect2i(cx + 3 + walk, 85, 18, 5), VOID)
	if not unshielded:
		_draw_boss_shield(image, Vector2i(cx + 18, top + 40), animation_name, frame)
	_draw_boss_sword(image, Vector2i(cx - 9, top + 34), animation_name, frame)
	if animation_name in ["shield_break", "phase_transition"]:
		_draw_boss_fragments(image, Vector2i(cx + 21, top + 39), frame)
	if animation_name == "shockwave_strike" and frame in [3, 4]:
		PixelCanvas.draw_line(image, Vector2i(cx + 15, 88), Vector2i(92, 88), CURSE, 3)
	if animation_name == "death" and frame >= 5:
		PixelCanvas.fill_rect(image, Rect2i(15, 87, 7, 4), FADE)
		PixelCanvas.fill_rect(image, Rect2i(61, 84, 6, 5), FADE)
	return image


func _draw_boss_shield(image: Image, center: Vector2i, animation_name: String, frame: int) -> void:
	var x_shift: int = 5 if animation_name == "shield_bash" and frame in [2, 3] else 0
	var center_shifted: Vector2i = center + Vector2i(x_shift, 0)
	PixelCanvas.fill_rect(image, Rect2i(center_shifted.x - 12, center_shifted.y - 18, 24, 34), VOID)
	PixelCanvas.fill_rect(image, Rect2i(center_shifted.x - 9, center_shifted.y - 15, 18, 27), MID)
	PixelCanvas.fill_rect(image, Rect2i(center_shifted.x - 2, center_shifted.y - 12, 4, 22), GOLD)
	PixelCanvas.fill_rect(image, Rect2i(center_shifted.x - 7, center_shifted.y - 2, 14, 4), GOLD)


func _draw_boss_sword(image: Image, hand: Vector2i, animation_name: String, frame: int) -> void:
	var tip: Vector2i = hand + Vector2i(-18, 32)
	if animation_name in ["sword_slash", "combo_slash_1", "combo_slash_2"]:
		var tips: Array[Vector2i] = [Vector2i(-18, -27), Vector2i(-4, -35), Vector2i(35, -9), Vector2i(43, 15), Vector2i(17, 31)]
		tip = hand + tips[mini(frame, 4)]
	elif animation_name in ["heavy_overhead", "jump_smash", "shockwave_strike"]:
		var heavy_tips: Array[Vector2i] = [Vector2i(-8, -31), Vector2i(3, -42), Vector2i(16, -34), Vector2i(32, 24), Vector2i(38, 36), Vector2i(16, 34)]
		tip = hand + heavy_tips[mini(frame, 5)]
	elif animation_name == "charge_thrust":
		var thrust_tips: Array[Vector2i] = [Vector2i(-18, 15), Vector2i(2, 2), Vector2i(45, 1), Vector2i(53, 1), Vector2i(24, 18)]
		tip = hand + thrust_tips[mini(frame, 4)]
	elif animation_name == "death":
		tip = Vector2i(74, 88)
	PixelCanvas.draw_line(image, hand, tip, RUST, 6)
	PixelCanvas.draw_line(image, hand + (tip - hand) / 3, tip, STEEL, 4)


func _draw_boss_fragments(image: Image, center: Vector2i, frame: int) -> void:
	var spread: int = frame * 4
	PixelCanvas.fill_rect(image, Rect2i(center.x - 8 - spread, center.y - 9, 7, 6), MID)
	PixelCanvas.fill_rect(image, Rect2i(center.x + 2 + spread, center.y - 12, 6, 8), GOLD)
	PixelCanvas.fill_rect(image, Rect2i(center.x - 2, center.y + 8 + spread, 8, 5), STEEL)


func _frame_path(root_name: String, animation_name: String, frame: int) -> String:
	return ROOT.path_join(root_name).path_join(animation_name).path_join(
		"%s_%02d.png" % [animation_name, frame + 1]
	)


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
