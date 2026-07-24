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
const STONE_DARK: Color = Color("242c30")
const STONE_MID: Color = Color("53615d")
const STONE_LIGHT: Color = Color("919b94")
const VERDIGRIS: Color = Color("405f59")
const STONE_CRACK: Color = Color("9bb4ad")

const GARGOYLE: Dictionary[String, int] = {
	"dormant": 4, "wake": 4, "hover": 4, "dive_windup": 4, "dive": 4,
	"ground_stun": 4, "return_to_air": 4, "hurt": 3,
	"death_fall": 5, "death_shatter": 5,
}
const BOSS: Dictionary[String, int] = {
	"idle_shielded": 4, "walk_shielded": 6, "shield_block": 4,
	"turn_shielded": 3,
	"shield_bash": 5, "sword_slash": 5, "heavy_overhead": 6,
	"hurt_shielded": 3, "shield_break": 5, "phase_transition": 5,
	"idle_unshielded": 4, "walk_unshielded": 6, "turn_unshielded": 3,
	"combo_slash_1": 5,
	"combo_slash_2": 5, "jump_smash": 6, "charge_thrust": 5,
	"shockwave_strike": 6, "hurt_unshielded": 3, "death": 7,
}
const BOSS_SHIELD_DAMAGE_STATES: Array[String] = [
	"intact", "damaged", "critical", "broken",
]


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
	for visual_state: String in BOSS_SHIELD_DAMAGE_STATES:
		var shield_path: String = ROOT.path_join("bosses/fallen_gate_knight/shield_damage").path_join(
			visual_state
		).path_join("%s_01.png" % visual_state)
		failures += 0 if _save_png(_draw_boss_shield_damage(visual_state), shield_path) == OK else 1
		total += 1
	print("FIRST_LEVEL_BOSS_PIXEL_BUILD: %s (%d files)" % ["OK" if failures == 0 else "FAIL", total])
	quit(0 if failures == 0 else 1)


func _draw_gargoyle(animation_name: String, frame: int) -> Image:
	var image: Image = PixelCanvas.create_transparent(Vector2i(64, 64))
	if animation_name == "death_shatter":
		_draw_gargoyle_shatter(image, frame)
		return image
	if animation_name == "dive":
		_draw_gargoyle_dive(image, frame)
		return image
	if animation_name == "ground_stun":
		_draw_gargoyle_ground_stun(image, frame)
		return image
	var bob: int = [0, -1, 0, 1][frame % 4] if animation_name == "hover" else 0
	var fall: int = frame * 5 if animation_name == "death_fall" else 0
	var center: Vector2i = Vector2i(32, 33 + bob + fall)
	var wing_lift: int = 0
	var wing_spread: int = 14
	var folded: bool = animation_name == "dormant"
	if animation_name == "wake":
		wing_lift = [0, 3, 7, 10][frame]
		wing_spread = [10, 13, 17, 20][frame]
	elif animation_name == "hover":
		wing_lift = [11, 5, -1, 5][frame]
		wing_spread = [20, 19, 17, 19][frame]
	elif animation_name == "dive_windup":
		wing_lift = [4, 8, 12, 14][frame]
		wing_spread = [17, 19, 21, 22][frame]
	elif animation_name == "return_to_air":
		wing_lift = [0, 7, 12, 6][frame]
		wing_spread = [15, 19, 21, 19][frame]
	elif animation_name == "hurt":
		wing_lift = [7, -2, 4][frame]
		wing_spread = [18, 15, 17][frame]
	elif animation_name == "death_fall":
		wing_lift = 2 - frame
		wing_spread = maxi(8, 16 - frame * 2)
	var body_color: Color = STONE_DARK
	if animation_name == "death_fall" and frame >= 3:
		body_color = Color(STONE_DARK.r, STONE_DARK.g, STONE_DARK.b, 0.72 - 0.12 * (frame - 3))
	_draw_gargoyle_wings(image, center, wing_spread, wing_lift, folded, body_color.a)
	_draw_gargoyle_tail(image, center, body_color)
	_draw_gargoyle_body(image, center, animation_name, frame, body_color)
	if animation_name == "hurt":
		PixelCanvas.draw_line(image, center + Vector2i(-10, -16), center + Vector2i(13, 10), STEEL, 2)
	return image


func _draw_gargoyle_shatter(image: Image, frame: int) -> void:
	var spread: int = frame * 3
	var alpha: float = maxf(0.18, 0.86 - frame * 0.16)
	var color: Color = Color(STONE_MID.r, STONE_MID.g, STONE_MID.b, alpha)
	PixelCanvas.fill_rect(image, Rect2i(25 - spread, 39 - spread, 8, 7), color)
	PixelCanvas.fill_rect(image, Rect2i(36 + spread, 38 - spread, 7, 9), color)
	PixelCanvas.draw_line(image, Vector2i(23 - spread, 43), Vector2i(15 - spread, 35), color, 3)
	PixelCanvas.draw_line(image, Vector2i(43 + spread, 44), Vector2i(52 + spread, 38), color, 3)
	PixelCanvas.fill_rect(image, Rect2i(19 - spread, 53, 6, 4), color)
	PixelCanvas.fill_rect(image, Rect2i(43 + spread, 54, 7, 4), color)
	PixelCanvas.fill_rect(image, Rect2i(31, 49 + spread, 4, 4), Color(VERDIGRIS.r, VERDIGRIS.g, VERDIGRIS.b, alpha))


func _draw_gargoyle_wings(
	image: Image,
	center: Vector2i,
	spread: int,
	lift: int,
	folded: bool,
	alpha: float
) -> void:
	var membrane: Color = Color(VERDIGRIS.r, VERDIGRIS.g, VERDIGRIS.b, alpha)
	var bone: Color = Color(STONE_MID.r, STONE_MID.g, STONE_MID.b, alpha)
	var rear_root: Vector2i = center + Vector2i(-5, -5)
	var rear_tip: Vector2i = center + Vector2i(-spread, -12 - lift)
	var rear_low: Vector2i = center + Vector2i(-spread + 4, 8)
	if folded:
		rear_tip = center + Vector2i(-12, -15)
		rear_low = center + Vector2i(-10, 13)
	_fill_triangle(image, rear_root, rear_tip, rear_low, membrane)
	PixelCanvas.draw_line(image, rear_root, rear_tip, bone, 3)
	PixelCanvas.draw_line(image, rear_tip, rear_low, bone, 2)
	PixelCanvas.draw_line(image, rear_root, rear_low, bone, 2)
	if folded:
		return
	var front_root: Vector2i = center + Vector2i(4, -5)
	var front_tip: Vector2i = center + Vector2i(spread, -11 - lift)
	var front_low: Vector2i = center + Vector2i(spread - 3, 7)
	_fill_triangle(image, front_root, front_tip, front_low, membrane)
	PixelCanvas.draw_line(image, front_root, front_tip, bone, 3)
	PixelCanvas.draw_line(image, front_tip, front_low, bone, 2)
	PixelCanvas.draw_line(image, front_root, front_low, bone, 2)


func _draw_gargoyle_tail(image: Image, center: Vector2i, color: Color) -> void:
	PixelCanvas.draw_line(image, center + Vector2i(-6, 7), center + Vector2i(-16, 14), color, 3)
	PixelCanvas.draw_line(image, center + Vector2i(-16, 14), center + Vector2i(-20, 9), STONE_MID, 2)
	PixelCanvas.fill_rect(image, Rect2i(center.x - 22, center.y + 6, 4, 4), STONE_LIGHT)


func _draw_gargoyle_body(
	image: Image,
	center: Vector2i,
	animation_name: String,
	frame: int,
	body_color: Color
) -> void:
	var crouch: int = 3 if animation_name in ["dormant", "dive_windup"] else 0
	var torso_top: int = center.y - 8 + crouch
	# Hunched masonry torso and layered shoulders replace the old rectangular flying-insect read.
	PixelCanvas.fill_rect(image, Rect2i(center.x - 9, torso_top, 18, 19 - crouch), VOID)
	PixelCanvas.fill_rect(image, Rect2i(center.x - 7, torso_top + 2, 14, 15 - crouch), body_color)
	PixelCanvas.fill_rect(image, Rect2i(center.x - 12, torso_top + 1, 6, 7), STONE_MID)
	PixelCanvas.fill_rect(image, Rect2i(center.x + 6, torso_top + 1, 6, 7), STONE_MID)
	var head: Vector2i = Vector2i(center.x + 3, torso_top - 11)
	PixelCanvas.fill_rect(image, Rect2i(head.x - 6, head.y - 2, 16, 13), VOID)
	PixelCanvas.fill_rect(image, Rect2i(head.x - 4, head.y, 13, 9), STONE_DARK)
	PixelCanvas.fill_rect(image, Rect2i(head.x + 7, head.y + 4, 7, 6), VOID)
	PixelCanvas.fill_rect(image, Rect2i(head.x + 7, head.y + 3, 5, 4), STONE_MID)
	# Back horn, pointed ear, heavy brow and one restrained cursed eye.
	PixelCanvas.draw_line(image, head + Vector2i(-3, 0), head + Vector2i(-8, -8), STONE_LIGHT, 3)
	PixelCanvas.draw_line(image, head + Vector2i(2, 0), head + Vector2i(5, -7), STONE_MID, 2)
	PixelCanvas.fill_rect(image, Rect2i(head.x + 2, head.y + 3, 8, 2), STONE_LIGHT)
	PixelCanvas.fill_rect(image, Rect2i(head.x + 6, head.y + 5, 3, 2), EYE)
	PixelCanvas.fill_rect(image, Rect2i(head.x + 8, head.y + 8, 4, 2), STONE_LIGHT)
	# Bent arms end in three-pixel claws; legs stay clearly separate under the body.
	PixelCanvas.draw_line(image, center + Vector2i(7, -2 + crouch), center + Vector2i(15, 6 + crouch), STONE_MID, 4)
	PixelCanvas.draw_line(image, center + Vector2i(15, 6 + crouch), center + Vector2i(19, 3 + crouch), STONE_LIGHT, 2)
	PixelCanvas.draw_line(image, center + Vector2i(-5, 7), center + Vector2i(-11, 17), body_color, 5)
	PixelCanvas.draw_line(image, center + Vector2i(5, 7), center + Vector2i(10, 17), body_color, 5)
	PixelCanvas.fill_rect(image, Rect2i(center.x - 16, center.y + 15, 9, 3), STONE_LIGHT)
	PixelCanvas.fill_rect(image, Rect2i(center.x + 7, center.y + 15, 9, 3), STONE_LIGHT)
	# Sparse authored cracks and verdigris separate stone planes without pixel noise.
	PixelCanvas.draw_line(image, center + Vector2i(-2, -4 + crouch), center + Vector2i(2, 2 + crouch), STONE_CRACK, 1)
	PixelCanvas.draw_line(image, center + Vector2i(2, 2 + crouch), center + Vector2i(0, 6 + crouch), VERDIGRIS, 1)
	if animation_name == "dormant" and frame in [1, 2]:
		PixelCanvas.fill_rect(image, Rect2i(head.x + 6, head.y + 5, 3, 1), Color(EYE.r, EYE.g, EYE.b, 0.45))


func _draw_gargoyle_dive(image: Image, frame: int) -> void:
	var center: Vector2i = Vector2i(31 + frame, 32)
	var body_shift: int = [0, 1, 2, 1][frame]
	# Horizontal hunched torso, swept bat wings, horned face and forward claws read as a stone predator.
	_fill_triangle(
		image,
		center + Vector2i(-3, -3),
		center + Vector2i(-25, -13 + body_shift),
		center + Vector2i(-22, 5),
		VERDIGRIS
	)
	PixelCanvas.draw_line(image, center + Vector2i(-3, -3), center + Vector2i(-25, -13 + body_shift), STONE_MID, 3)
	PixelCanvas.draw_line(image, center + Vector2i(-25, -13 + body_shift), center + Vector2i(-22, 5), STONE_MID, 2)
	PixelCanvas.fill_rect(image, Rect2i(center.x - 9, center.y - 7, 22, 14), VOID)
	PixelCanvas.fill_rect(image, Rect2i(center.x - 7, center.y - 5, 19, 10), STONE_DARK)
	PixelCanvas.fill_rect(image, Rect2i(center.x + 8, center.y - 9, 12, 11), VOID)
	PixelCanvas.fill_rect(image, Rect2i(center.x + 10, center.y - 7, 10, 7), STONE_MID)
	PixelCanvas.draw_line(image, center + Vector2i(11, -7), center + Vector2i(8, -14), STONE_LIGHT, 2)
	PixelCanvas.fill_rect(image, Rect2i(center.x + 16, center.y - 4, 3, 2), EYE)
	PixelCanvas.draw_line(image, center + Vector2i(5, 4), center + Vector2i(22, 8), STONE_MID, 3)
	PixelCanvas.draw_line(image, center + Vector2i(2, 6), center + Vector2i(19, 13), STONE_MID, 3)
	PixelCanvas.fill_rect(image, Rect2i(center.x + 21, center.y + 6, 5, 2), STONE_LIGHT)
	PixelCanvas.fill_rect(image, Rect2i(center.x + 18, center.y + 11, 5, 2), STONE_LIGHT)
	PixelCanvas.draw_line(image, center + Vector2i(-7, 3), center + Vector2i(-22, 11), STONE_DARK, 3)


func _draw_gargoyle_ground_stun(image: Image, frame: int) -> void:
	var drop: int = [0, 2, 1, 0][frame]
	var center: Vector2i = Vector2i(32, 45 + drop)
	_fill_triangle(image, center + Vector2i(-4, -3), center + Vector2i(-24, -8), center + Vector2i(-19, 7), VERDIGRIS)
	PixelCanvas.draw_line(image, center + Vector2i(-4, -3), center + Vector2i(-24, -8), STONE_MID, 3)
	PixelCanvas.fill_rect(image, Rect2i(center.x - 10, center.y - 7, 22, 12), VOID)
	PixelCanvas.fill_rect(image, Rect2i(center.x - 8, center.y - 5, 18, 8), STONE_DARK)
	PixelCanvas.fill_rect(image, Rect2i(center.x + 8, center.y - 10, 12, 10), VOID)
	PixelCanvas.fill_rect(image, Rect2i(center.x + 10, center.y - 8, 9, 6), STONE_MID)
	PixelCanvas.draw_line(image, center + Vector2i(11, -8), center + Vector2i(8, -14), STONE_LIGHT, 2)
	PixelCanvas.fill_rect(image, Rect2i(center.x + 16, center.y - 6, 3, 2), EYE)
	PixelCanvas.draw_line(image, center + Vector2i(-3, 3), center + Vector2i(-12, 11), STONE_MID, 4)
	PixelCanvas.draw_line(image, center + Vector2i(6, 2), center + Vector2i(14, 10), STONE_MID, 4)
	PixelCanvas.fill_rect(image, Rect2i(center.x - 16, center.y + 9, 8, 3), STONE_LIGHT)
	PixelCanvas.fill_rect(image, Rect2i(center.x + 11, center.y + 8, 8, 3), STONE_LIGHT)


func _fill_triangle(image: Image, a: Vector2i, b: Vector2i, c: Vector2i, color: Color) -> void:
	for step: int in range(13):
		var ratio: float = float(step) / 12.0
		var edge_b: Vector2i = Vector2i(
			roundi(lerpf(float(a.x), float(b.x), ratio)),
			roundi(lerpf(float(a.y), float(b.y), ratio))
		)
		var edge_c: Vector2i = Vector2i(
			roundi(lerpf(float(a.x), float(c.x), ratio)),
			roundi(lerpf(float(a.y), float(c.y), ratio))
		)
		PixelCanvas.draw_line(image, edge_b, edge_c, color, 1)


func _draw_boss(animation_name: String, frame: int) -> Image:
	var image: Image = PixelCanvas.create_transparent(Vector2i(96, 96))
	var unshielded: bool = animation_name in [
		"phase_transition", "idle_unshielded", "walk_unshielded", "combo_slash_1",
		"turn_unshielded", "combo_slash_2", "jump_smash", "charge_thrust", "shockwave_strike",
		"hurt_unshielded", "death",
	]
	var turn_inset: int = [0, 5, 2][frame] if animation_name.begins_with("turn") else 0
	var death_fall: int = mini(frame, 4) * 8 if animation_name == "death" else 0
	var bob: int = 1 if animation_name.begins_with("idle") and frame in [1, 2] else 0
	var walk: int = [-5, -2, 1, 5, 2, -1][frame] if animation_name.begins_with("walk") else 0
	var cx: int = 45 - death_fall
	var top: int = 20 + bob + mini(death_fall, 24)
	var armor: Color = FADE if animation_name == "death" and frame >= 5 else IRON
	# Heavy 1.6x body, closed helm, eye slit, broad shoulders.
	PixelCanvas.fill_rect(image, Rect2i(cx - 13 + turn_inset, top + 24, 27 - turn_inset * 2, 35), VOID)
	PixelCanvas.fill_rect(image, Rect2i(cx - 10 + turn_inset, top + 26, 21 - turn_inset * 2, 29), armor)
	PixelCanvas.fill_rect(image, Rect2i(cx - 17 + turn_inset, top + 24, 8, 13), MID)
	PixelCanvas.fill_rect(image, Rect2i(cx + 10 - turn_inset, top + 24, 8, 13), MID)
	PixelCanvas.fill_rect(image, Rect2i(cx - 11 + turn_inset, top, 23 - turn_inset * 2, 23), VOID)
	PixelCanvas.fill_rect(image, Rect2i(cx - 8 + turn_inset, top + 3, 17 - turn_inset * 2, 15), armor)
	PixelCanvas.fill_rect(image, Rect2i(cx - 9 + turn_inset, top + 12, 19 - turn_inset * 2, 4), MID)
	PixelCanvas.fill_rect(image, Rect2i(cx + 4, top + 13, 4, 2), EYE)
	PixelCanvas.draw_line(image, Vector2i(cx - 7, top + 55), Vector2i(cx - 12 - walk, 87), armor, 8)
	PixelCanvas.draw_line(image, Vector2i(cx + 7, top + 55), Vector2i(cx + 13 + walk, 87), armor, 8)
	PixelCanvas.fill_rect(image, Rect2i(cx - 21 - walk, 85, 17, 5), VOID)
	PixelCanvas.fill_rect(image, Rect2i(cx + 3 + walk, 85, 18, 5), VOID)
	if not unshielded:
		_draw_boss_shield(image, Vector2i(cx + 18 - turn_inset, top + 40), animation_name, frame)
	_draw_boss_sword(image, Vector2i(cx - 9 + turn_inset, top + 34), animation_name, frame)
	if animation_name in ["shield_break", "phase_transition"]:
		_draw_boss_fragments(image, Vector2i(cx + 21, top + 39), frame)
	if animation_name == "shockwave_strike" and frame in [3, 4]:
		PixelCanvas.draw_line(image, Vector2i(cx + 15, 88), Vector2i(92, 88), CURSE, 3)
	if animation_name == "death" and frame >= 5:
		PixelCanvas.fill_rect(image, Rect2i(15, 87, 7, 4), FADE)
		PixelCanvas.fill_rect(image, Rect2i(61, 84, 6, 5), FADE)
	return image


func _draw_boss_shield_damage(visual_state: String) -> Image:
	var image: Image = PixelCanvas.create_transparent(Vector2i(96, 96))
	if visual_state in ["intact", "broken"]:
		return image
	# Full-canvas overlays align to the baked shield and remain nearest-neighbor under flip_h.
	PixelCanvas.draw_line(image, Vector2i(62, 49), Vector2i(67, 57), VOID, 2)
	PixelCanvas.draw_line(image, Vector2i(67, 57), Vector2i(63, 65), STEEL, 1)
	if visual_state == "critical":
		PixelCanvas.draw_line(image, Vector2i(58, 54), Vector2i(64, 59), VOID, 2)
		PixelCanvas.draw_line(image, Vector2i(64, 59), Vector2i(70, 68), VOID, 2)
		PixelCanvas.fill_rect(image, Rect2i(71, 69, 5, 6), VOID)
		PixelCanvas.fill_rect(image, Rect2i(60, 46, 3, 3), GOLD)
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
