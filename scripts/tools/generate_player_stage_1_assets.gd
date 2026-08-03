extends SceneTree

## Deterministic Stage 1 exporter for the shared Night Warden presentation.

const ActionGenerator: Script = preload("res://scripts/tools/pixel_player_animation_generator.gd")
const M1Generator: Script = preload("res://scripts/tools/pixel_player_m1_animation_generator.gd")
const HurtGenerator: Script = preload("res://scripts/tools/pixel_player_hurt_generator.gd")
const DeathGenerator: Script = preload("res://scripts/tools/pixel_player_death_generator.gd")
const PixelCanvas: Script = preload("res://scripts/tools/pixel_art_canvas.gd")
const Renderer: Script = preload("res://scripts/tools/pixel_assassin_renderer.gd")

const CONCEPT_ROOT: String = "res://shared/assets/player/concept_art"
const ANIMATION_ROOT: String = "res://shared/assets/player/animations"
const EFFECT_ROOT: String = "res://shared/assets/player/effects"
const WEAPON_ROOT: String = "res://shared/assets/player/weapons"
const REVIVAL_ROOT: String = "res://shared/assets/player/revival"
const QA_ROOT: String = "res://docs/qa/core_character_art_rework/stage_1"
const STYLES: Array[StringName] = [&"veilbound", &"ravenfang", &"crimson_masque"]
const FORMAL_FRAME_SIZE: Vector2i = Vector2i(96, 96)


func _init() -> void:
	var failures: int = 0
	failures += _export_concept_deliverables()
	for style: StringName in STYLES:
		failures += _export_style(style)
	failures += _export_effects()
	failures += _export_weapon_references()
	failures += _export_revival_poses()
	failures += _export_qa_contact_sheet()
	if failures > 0:
		push_error("PLAYER_STAGE_1_ASSETS: FAIL failures=%d" % failures)
		quit(1)
		return
	print("PLAYER_STAGE_1_ASSETS: PASS styles=3 animations=30 concepts=10 revival=8")
	quit(0)


func _export_style(style: StringName) -> int:
	var root: String = ANIMATION_ROOT.path_join(str(style))
	var failures: int = 0
	failures += _save_sequences(root, ActionGenerator.generate_all(style), style)
	failures += _save_sequences(root, M1Generator.generate_all(style), style)
	failures += _save_sequence(root, &"hurt", HurtGenerator.generate_frames(style), style)
	failures += _save_sequence(root, &"hurt_light", HurtGenerator.generate_light_frames(style), style)
	failures += _save_sequence(root, &"hurt_heavy", HurtGenerator.generate_heavy_frames(style), style)
	failures += _save_sequence(root, &"death", DeathGenerator.generate_death_frames(style), style)
	return failures


func _save_sequences(
	root: String, sequences: Dictionary[String, Array], style: StringName
	) -> int:
	var failures: int = 0
	for animation_name: String in sequences:
		failures += _save_sequence(
			root, StringName(animation_name), sequences[animation_name], style
		)
	return failures


func _save_sequence(
	root: String, animation_name: StringName, frames: Array, style: StringName
	) -> int:
	var directory: String = root.path_join(str(animation_name))
	if DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(directory)) != OK:
		return frames.size()
	var failures: int = 0
	for frame_index: int in range(frames.size()):
		var source: Image = frames[frame_index] as Image
		var image: Image = _replicate_player_frame(
			source, style, animation_name, frame_index
		)
		var path: String = directory.path_join(
			"%s_%02d.png" % [animation_name, frame_index + 1]
		)
		if image == null or image.save_png(path) != OK:
			failures += 1
	return failures


func _replicate_player_frame(
	source: Image, style: StringName, animation_name: StringName, frame_index: int
	) -> Image:
	if source == null or source.is_empty():
		return Image.new()
	var formal: Image = PixelCanvas.create_transparent(FORMAL_FRAME_SIZE)
	var offset: Vector2i = (FORMAL_FRAME_SIZE - source.get_size()) / 2
	formal.blit_rect(source, Rect2i(Vector2i.ZERO, source.get_size()), offset)
	if animation_name == &"death" and frame_index >= 3:
		return formal

	# The approved action drawings remain the source of truth. These stable pixel
	# accents restore the concept sheet's hood seam, oath clasp and outfit identity
	# without altering the shared foot anchor or gameplay silhouette.
	var hood_seam: Color = Color("526f84")
	var steel: Color = Color("d5dee3")
	var accent: Color = Color("b98243")
	match style:
		&"ravenfang":
			hood_seam = Color("738b9b")
			accent = Color("8d3141")
		&"crimson_masque":
			hood_seam = Color("694857")
			accent = Color("b94c5f")
		_:
			pass

	var origin: Vector2i = offset
	PixelCanvas.draw_line(
		formal, origin + Vector2i(31, 8), origin + Vector2i(33, 11), hood_seam, 1
	)
	PixelCanvas.fill_rect(formal, Rect2i(origin + Vector2i(29, 15), Vector2i(2, 1)), steel)
	PixelCanvas.fill_rect(formal, Rect2i(origin + Vector2i(33, 15), Vector2i(2, 1)), steel)
	PixelCanvas.fill_rect(formal, Rect2i(origin + Vector2i(31, 26), Vector2i(3, 2)), accent)
	PixelCanvas.fill_rect(formal, Rect2i(origin + Vector2i(24, 32), Vector2i(2, 1)), hood_seam)
	PixelCanvas.fill_rect(formal, Rect2i(origin + Vector2i(38, 32), Vector2i(2, 1)), hood_seam)
	return formal


func _export_concept_deliverables() -> int:
	var turnaround_path: String = CONCEPT_ROOT.path_join("night_warden_turnaround_master.png")
	var action_path: String = CONCEPT_ROOT.path_join("night_warden_action_weapon_master.png")
	var turnaround: Image = Image.load_from_file(ProjectSettings.globalize_path(turnaround_path))
	var action: Image = Image.load_from_file(ProjectSettings.globalize_path(action_path))
	if turnaround == null or turnaround.is_empty() or action == null or action.is_empty():
		return 10
	var crops: Dictionary[String, Dictionary] = {
		"night_warden_front_concept.png": {"source": turnaround, "rect": Rect2i(0, 0, 265, 520)},
		"night_warden_combat_side_concept.png": {"source": turnaround, "rect": Rect2i(250, 0, 285, 520)},
		"night_warden_back_concept.png": {"source": turnaround, "rect": Rect2i(510, 0, 270, 520)},
		"night_warden_three_quarter_concept.png": {"source": turnaround, "rect": Rect2i(750, 0, 310, 520)},
		"night_warden_silhouette.png": {"source": turnaround, "rect": Rect2i(0, 510, 285, 514)},
		"night_warden_outfit_breakdown.png": {"source": turnaround, "rect": Rect2i(280, 510, 670, 514)},
		"night_warden_hood_detail.png": {"source": turnaround, "rect": Rect2i(1040, 0, 496, 520)},
		"night_warden_guard_scale_comparison.png": {"source": turnaround, "rect": Rect2i(930, 500, 606, 524)},
		"night_warden_dual_dagger_pose_sheet.png": {"source": action, "rect": Rect2i(1055, 0, 481, 1024)},
		"night_warden_animation_pose_sheet.png": {"source": action, "rect": Rect2i(0, 0, 1055, 1024)},
	}
	var failures: int = 0
	for file_name: String in crops:
		var data: Dictionary = crops[file_name]
		var source: Image = data["source"] as Image
		var region: Image = source.get_region(data["rect"] as Rect2i)
		if region.save_png(CONCEPT_ROOT.path_join(file_name)) != OK:
			failures += 1
	return failures


func _export_effects() -> int:
	if DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(EFFECT_ROOT)) != OK:
		return 3
	var failures: int = 0
	var ghost: Image = DeathGenerator.generate_ghost()
	if ghost.save_png(EFFECT_ROOT.path_join("night_warden_ghost_hooded_face.png")) != OK:
		failures += 1
	var dust: Image = PixelCanvas.create_transparent(Vector2i(32, 16))
	for rect: Rect2i in [
		Rect2i(2, 11, 7, 2), Rect2i(9, 8, 5, 2), Rect2i(16, 10, 8, 2), Rect2i(25, 6, 4, 2),
	]:
		PixelCanvas.fill_rect(dust, rect, Color(0.42, 0.49, 0.56, 0.42))
	if dust.save_png(EFFECT_ROOT.path_join("ground_dash_dust.png")) != OK:
		failures += 1
	var soul_crack: Image = PixelCanvas.create_transparent(Vector2i(32, 32))
	PixelCanvas.draw_line(soul_crack, Vector2i(4, 19), Vector2i(12, 16), Color(0.55, 0.78, 0.94, 0.58), 1)
	PixelCanvas.draw_line(soul_crack, Vector2i(12, 16), Vector2i(16, 8), Color(0.75, 0.90, 1.0, 0.86), 1)
	PixelCanvas.draw_line(soul_crack, Vector2i(16, 8), Vector2i(20, 17), Color(0.55, 0.78, 0.94, 0.62), 1)
	PixelCanvas.draw_line(soul_crack, Vector2i(20, 17), Vector2i(28, 20), Color(0.45, 0.68, 0.88, 0.40), 1)
	if soul_crack.save_png(EFFECT_ROOT.path_join("double_jump_soul_crack.png")) != OK:
		failures += 1
	return failures


func _export_weapon_references() -> int:
	if DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(WEAPON_ROOT)) != OK:
		return 3
	var failures: int = 0
	for style: StringName in STYLES:
		var image: Image = PixelCanvas.create_transparent(Vector2i(64, 48))
		if style == &"ravenfang":
			Renderer.draw_ravenfang_dagger(image, Vector2i(21, 17), Vector2i(56, 8), true)
			Renderer.draw_ravenfang_dagger(image, Vector2i(21, 31), Vector2i(53, 39), false)
		elif style == &"crimson_masque":
			Renderer.draw_crimson_masque_stiletto(image, Vector2i(21, 16), Vector2i(58, 8), true)
			Renderer.draw_crimson_masque_stiletto(image, Vector2i(21, 31), Vector2i(55, 39), false)
		else:
			_draw_veilbound_reference_dagger(image, Vector2i(21, 16), Vector2i(56, 8), true)
			_draw_veilbound_reference_dagger(image, Vector2i(21, 31), Vector2i(53, 39), false)
		if image.save_png(WEAPON_ROOT.path_join("%s_dual_daggers.png" % style)) != OK:
			failures += 1
	return failures


func _export_revival_poses() -> int:
	if DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(REVIVAL_ROOT)) != OK:
		return 8
	var deaths: Array[Image] = DeathGenerator.generate_death_frames(&"unarmed")
	var locomotion: Dictionary[String, Array] = M1Generator.generate_all(&"unarmed")
	var actions: Dictionary[String, Array] = ActionGenerator.generate_all(&"unarmed")
	var poses: Dictionary[String, Image] = {
		"revival_corpse.png": deaths[4],
		"revival_twitch.png": deaths[3],
		"revival_breath.png": deaths[4],
		"revival_sit_up.png": deaths[2],
		"revival_look_hands.png": (actions["ready_idle"] as Array)[1] as Image,
		"revival_kneel.png": (locomotion["land"] as Array)[0] as Image,
		"revival_stand.png": (actions["idle"] as Array)[0] as Image,
		"revival_unarmed.png": (actions["ready_idle"] as Array)[0] as Image,
	}
	var failures: int = 0
	for file_name: String in poses:
		if poses[file_name].save_png(REVIVAL_ROOT.path_join(file_name)) != OK:
			failures += 1
	return failures


func _draw_veilbound_reference_dagger(
		image: Image, hand: Vector2i, tip: Vector2i, is_main: bool
	) -> void:
	var direction: Vector2 = Vector2(tip - hand).normalized()
	var normal: Vector2 = Vector2(-direction.y, direction.x)
	var blade_start: Vector2i = hand + Vector2i(roundi(direction.x * 5.0), roundi(direction.y * 5.0))
	PixelCanvas.draw_line(image, blade_start, tip, Color("1f2f3a"), 5)
	PixelCanvas.draw_line(image, blade_start, tip, Color("6f8796"), 3)
	PixelCanvas.draw_line(image, blade_start, tip, Color("d5dee3"), 1)
	var guard_a: Vector2i = hand + Vector2i(roundi(normal.x * 4.0), roundi(normal.y * 4.0))
	var guard_b: Vector2i = hand - Vector2i(roundi(normal.x * 4.0), roundi(normal.y * 4.0))
	PixelCanvas.draw_line(image, guard_a, guard_b, Color("607a90"), 2)
	var grip_end: Vector2i = hand - Vector2i(roundi(direction.x * 7.0), roundi(direction.y * 7.0))
	PixelCanvas.draw_line(image, hand, grip_end, Color("08101a"), 4)
	PixelCanvas.fill_rect(image, Rect2i(grip_end.x - 1, grip_end.y - 1, 3, 3), Color("b98243") if is_main else Color("607a90"))


func _export_qa_contact_sheet() -> int:
	if DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(QA_ROOT)) != OK:
		return 1
	var sheet: Image = Image.create(1280, 720, false, Image.FORMAT_RGBA8)
	sheet.fill(Color("0b1018"))
	var panels: Array[Dictionary] = [
		{"style": &"veilbound", "animation": "idle", "frame": 0, "position": Vector2i(80, 90)},
		{"style": &"veilbound", "animation": "run", "frame": 1, "position": Vector2i(260, 90)},
		{"style": &"veilbound", "animation": "attack_1", "frame": 2, "position": Vector2i(440, 90)},
		{"style": &"veilbound", "animation": "attack_2", "frame": 2, "position": Vector2i(620, 90)},
		{"style": &"veilbound", "animation": "attack_3", "frame": 2, "position": Vector2i(800, 90)},
		{"style": &"veilbound", "animation": "dash_attack", "frame": 2, "position": Vector2i(980, 90)},
		{"style": &"ravenfang", "animation": "idle", "frame": 0, "position": Vector2i(170, 390)},
		{"style": &"ravenfang", "animation": "attack_3", "frame": 2, "position": Vector2i(410, 390)},
		{"style": &"crimson_masque", "animation": "idle", "frame": 0, "position": Vector2i(650, 390)},
		{"style": &"crimson_masque", "animation": "dash_attack", "frame": 2, "position": Vector2i(890, 390)},
	]
	for panel: Dictionary in panels:
		var style: StringName = panel["style"] as StringName
		var animation: String = panel["animation"] as String
		var frame_index: int = panel["frame"] as int
		var frames: Array[Image] = ActionGenerator.generate_all(style)[animation]
		var scaled: Image = PixelCanvas.resize_nearest(frames[frame_index], Vector2i(192, 192))
		sheet.blend_rect(scaled, Rect2i(Vector2i.ZERO, scaled.get_size()), panel["position"] as Vector2i)
	return sheet.save_png(QA_ROOT.path_join("night_warden_stage_1_contact_sheet.png"))
