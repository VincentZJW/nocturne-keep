extends SceneTree

## Deterministically creates the formal hard-edged environment art used by the
## Chapter III Boss route. Geometry in the area scenes is collision-only.

const PixelCanvas: Script = preload("res://scripts/tools/pixel_art_canvas.gd")

const ROOT: String = "res://chapters/chapter_03_chapel_of_thirteen_echoes/assets"
const CLEAR: Color = Color.TRANSPARENT
const VOID: Color = Color("080914")
const NIGHT: Color = Color("101321")
const STONE_DARK: Color = Color("1b2130")
const STONE: Color = Color("303a4a")
const STONE_MID: Color = Color("465466")
const STONE_LIGHT: Color = Color("6d7b88")
const OAK_DARK: Color = Color("241923")
const OAK: Color = Color("4d3034")
const OAK_LIGHT: Color = Color("79504a")
const BRASS_DARK: Color = Color("66512d")
const BRASS: Color = Color("a18143")
const BRASS_LIGHT: Color = Color("d0ad63")
const BLOOD_DARK: Color = Color("3b111d")
const BLOOD: Color = Color("722335")
const BLOOD_LIGHT: Color = Color("a84452")
const BONE: Color = Color("c9c1aa")
const MOON: Color = Color("b9d3df")
const SOUL: Color = Color("73a8c0")
const WATER_DARK: Color = Color("071827")
const WATER: Color = Color("16405a")
const WATER_LIGHT: Color = Color("3e7a8e")
const WAX: Color = Color("b69b78")
const FLAME: Color = Color("d9553f")
const FLAME_CORE: Color = Color("f2c36d")

var _saved_count: int = 0


func _init() -> void:
	var failures: int = 0
	failures += _save(_draw_antechamber_backdrop(), "environment/boss_antechamber/boss_antechamber_backdrop.png")
	failures += _save(_draw_sanctum_backdrop(), "environment/boss_sanctum/boss_apse.png")
	failures += _save(_draw_reliquary_backdrop(), "environment/boss_reliquary/reliquary_backdrop.png")
	failures += _save(_draw_descent_backdrop(), "environment/water_transition/underkeep_descent_backdrop.png")
	failures += _generate_gate()
	failures += _generate_sanctum_props()
	failures += _generate_antechamber_props()
	failures += _generate_transition_props()
	failures += _generate_effects()
	failures += _generate_audio()
	if failures > 0:
		push_error("CH3_BOSS_ENV_ASSETS: FAIL files=%d" % failures)
		quit(1)
		return
	print("CH3_BOSS_ENV_ASSETS: PASS files=%d original=true nearest_ready=true" % _saved_count)
	quit(0)


func _generate_gate() -> int:
	var failures: int = 0
	for state: int in range(3):
		var name: String = ["closed", "lit", "open"][state]
		failures += _save(_draw_gate(state), "doors/boss/gate_of_thirteenth_echo_%s.png" % name)
	return failures


func _generate_sanctum_props() -> int:
	var failures: int = 0
	failures += _save(_draw_stained_glass(), "environment/boss_sanctum/boss_stained_glass.png")
	failures += _save(_draw_altar(false), "environment/boss_sanctum/boss_altar.png")
	failures += _save(_draw_choir_stalls(), "environment/boss_sanctum/boss_choir_stalls.png")
	failures += _save(_draw_ritual_floor(), "environment/boss_sanctum/boss_ritual_floor.png")
	failures += _save(_draw_pipe_organ(), "environment/boss_sanctum/boss_pipe_organ.png")
	failures += _save(_draw_censer(), "props/boss/boss_censers.png")
	failures += _save(_draw_lectern(), "props/boss/confessor_lectern.png")
	failures += _save(_draw_registry(), "props/boss/ritual_registry.png")
	for frame: int in range(3):
		failures += _save(
			_draw_candle_array(frame),
			"props/boss/thirteen_blood_candle_array_%02d.png" % (frame + 1)
		)
	return failures


func _generate_antechamber_props() -> int:
	var failures: int = 0
	failures += _save(_draw_checkpoint_shrine(), "props/boss/chapter_03_boss_checkpoint.png")
	failures += _save(_draw_bell_saint(false), "props/boss/bell_saint_left.png")
	failures += _save(_draw_bell_saint(true), "props/boss/bell_saint_right.png")
	failures += _save(_draw_confession_tablets(), "props/boss/thirteen_confession_tablets.png")
	failures += _save(_draw_small_bell(), "props/boss/small_bell.png")
	failures += _save(_draw_single_candle(), "props/boss/single_blood_candle.png")
	failures += _save(_draw_seal_light(), "fx/boss/gate_seal_light.png")
	return failures


func _generate_transition_props() -> int:
	var failures: int = 0
	failures += _save(_draw_reliquary(), "props/boss/bell_reliquary.png")
	failures += _save(_draw_ossuary_stairs(), "environment/water_transition/ossuary_stairs.png")
	failures += _save(_draw_wet_arch(), "environment/water_transition/wet_arch.png")
	failures += _save(_draw_rusted_gate(), "environment/water_transition/rusted_gate.png")
	failures += _save(_draw_shallow_water(), "environment/water_transition/shallow_water_edge.png")
	failures += _save(_draw_submerged_statue(), "environment/water_transition/submerged_statue.png")
	return failures


func _generate_effects() -> int:
	var failures: int = 0
	for frame: int in range(3):
		failures += _save(_draw_incense(frame), "fx/boss/boss_incense_%02d.png" % (frame + 1))
	failures += _save(_draw_resonance(), "fx/boss/boss_resonance_fx.png")
	failures += _save(_draw_glass_crack(), "fx/boss/boss_stained_glass_crack.png")
	failures += _save(_draw_altar(true), "fx/boss/boss_altar_collapse.png")
	failures += _save(_draw_wax_crack(), "fx/boss/gate_wax_crack.png")
	return failures


func _generate_audio() -> int:
	var failures: int = 0
	failures += _save_synth_wav("audio/boss/gate_bell_sequence.wav", 1.10, 594.0, 0.18, true)
	failures += _save_synth_wav("audio/boss/gate_wax_break.wav", 0.24, 1480.0, 0.28, false)
	failures += _save_synth_wav("audio/boss/gate_stone_open.wav", 0.78, 82.0, 0.36, false)
	failures += _save_synth_wav("audio/boss/underkeep_water_drip.wav", 0.48, 920.0, 0.12, true)
	return failures


func _save_synth_wav(
	relative_path: String,
	duration: float,
	base_frequency: float,
	amplitude: float,
	bell_like: bool
) -> int:
	const SAMPLE_RATE: int = 22050
	const CHANNELS: int = 1
	const BITS_PER_SAMPLE: int = 16
	var sample_count: int = ceili(duration * float(SAMPLE_RATE))
	var data_size: int = sample_count * 2
	var path: String = ROOT.path_join(relative_path)
	var directory_error: Error = DirAccess.make_dir_recursive_absolute(
		ProjectSettings.globalize_path(path.get_base_dir())
	)
	if directory_error != OK:
		return 1
	var file: FileAccess = FileAccess.open(ProjectSettings.globalize_path(path), FileAccess.WRITE)
	if file == null:
		return 1
	file.store_buffer("RIFF".to_ascii_buffer())
	file.store_32(36 + data_size)
	file.store_buffer("WAVEfmt ".to_ascii_buffer())
	file.store_32(16)
	file.store_16(1)
	file.store_16(CHANNELS)
	file.store_32(SAMPLE_RATE)
	file.store_32(SAMPLE_RATE * CHANNELS * BITS_PER_SAMPLE / 8)
	file.store_16(CHANNELS * BITS_PER_SAMPLE / 8)
	file.store_16(BITS_PER_SAMPLE)
	file.store_buffer("data".to_ascii_buffer())
	file.store_32(data_size)
	for index: int in range(sample_count):
		var time: float = float(index) / float(SAMPLE_RATE)
		var normalized: float = time / duration
		var envelope: float = pow(1.0 - normalized, 2.4 if bell_like else 1.4)
		var wave: float = sin(TAU * base_frequency * time)
		if bell_like:
			wave += sin(TAU * base_frequency * 1.52 * time) * 0.38
			wave += sin(TAU * base_frequency * 2.07 * time) * 0.20
		else:
			var deterministic_grit: float = sin(float(index * 1973 % 8191)) * 0.22
			wave = wave * 0.62 + deterministic_grit
		var sample: int = clampi(roundi(wave * envelope * amplitude * 32767.0), -32768, 32767)
		file.store_16(sample & 0xffff)
	file.close()
	_saved_count += 1
	return 0


func _draw_antechamber_backdrop() -> Image:
	var image: Image = _new_image(Vector2i(1664, 720), NIGHT)
	_draw_brick_wall(image, Rect2i(0, 0, 1664, 640), 64, 38)
	_rect(image, Rect2i(0, 0, 1664, 70), VOID)
	for x: int in [84, 416, 748, 1080, 1412]:
		_draw_gothic_bay(image, x, 76, 248, 520)
	for x: int in [54, 358, 662, 966, 1270, 1574]:
		_draw_rib(image, Vector2i(x, 80), Vector2i(832, 18))
	_draw_carved_band(image, 0, 540, 1664)
	_rect(image, Rect2i(0, 608, 1664, 112), STONE_DARK)
	_rect(image, Rect2i(0, 608, 1664, 8), STONE_LIGHT)
	_rect(image, Rect2i(0, 616, 1664, 15), Color("242b3a"))
	for x: int in range(24, 1640, 96):
		_draw_floor_tile(image, x, 632, 88, 70, int(x / 96))
	_draw_erased_royal_crest(image, Vector2i(210, 224))
	_draw_confessor_relief(image, Vector2i(1454, 224))
	return image


func _draw_sanctum_backdrop() -> Image:
	var image: Image = _new_image(Vector2i(3200, 720), VOID)
	_draw_brick_wall(image, Rect2i(0, 0, 3200, 624), 72, 42)
	_rect(image, Rect2i(0, 0, 3200, 64), Color("070812"))
	for x: int in [120, 640, 1160, 1680, 2200, 2720]:
		_draw_gothic_bay(image, x, 58, 360, 548)
	for x: int in [0, 520, 1040, 1560, 2080, 2600, 3120]:
		_draw_rib(image, Vector2i(x, 64), Vector2i(1600, 4))
	# Apse depth, moon shafts and organ recesses.
	_rect(image, Rect2i(1120, 66, 960, 470), Color("0b0c17"))
	for x: int in [1232, 1456, 1680, 1904]:
		_draw_high_window(image, x, 96, 132, 352)
	for beam_x: int in [1280, 1560, 1840]:
		_fill_polygon(image, PackedVector2Array([
			Vector2(beam_x, 208), Vector2(beam_x + 58, 208),
			Vector2(beam_x + 196, 604), Vector2(beam_x + 34, 604),
		]), Color(0.28, 0.48, 0.61, 0.08))
	_draw_carved_band(image, 0, 520, 3200)
	_rect(image, Rect2i(0, 604, 3200, 116), STONE_DARK)
	_rect(image, Rect2i(0, 604, 3200, 8), STONE_LIGHT)
	for x: int in range(0, 3200, 96):
		_draw_floor_tile(image, x, 612, 96, 108, int(x / 96))
	return image


func _draw_reliquary_backdrop() -> Image:
	var image: Image = _new_image(Vector2i(1280, 720), NIGHT)
	_draw_brick_wall(image, Rect2i(0, 0, 1280, 620), 64, 40)
	_draw_gothic_bay(image, 130, 66, 440, 540)
	_draw_gothic_bay(image, 710, 66, 440, 540)
	_rect(image, Rect2i(0, 604, 1280, 116), STONE_DARK)
	_rect(image, Rect2i(0, 604, 1280, 8), STONE_LIGHT)
	for x: int in range(0, 1280, 80):
		_draw_floor_tile(image, x, 612, 80, 108, int(x / 80))
	_draw_carved_band(image, 0, 510, 1280)
	return image


func _draw_descent_backdrop() -> Image:
	var image: Image = _new_image(Vector2i(2304, 720), Color("07101a"))
	_draw_brick_wall(image, Rect2i(0, 0, 2304, 620), 72, 40)
	for x: int in [40, 544, 1048, 1552, 2056]:
		_draw_gothic_bay(image, x, 94, 360, 508)
	# Damp bands and water channels make the spatial descent unmistakable.
	for x: int in range(0, 2304, 72):
		var stain_height: int = 82 + ((x / 72) % 5) * 17
		_rect(image, Rect2i(x + 10, 540 - stain_height, 16, stain_height), Color(0.08, 0.22, 0.28, 0.55))
		_rect(image, Rect2i(x + 18, 548 - stain_height / 2, 5, stain_height / 2), Color(0.18, 0.39, 0.43, 0.42))
	_rect(image, Rect2i(0, 590, 2304, 130), WATER_DARK)
	for y: int in [594, 610, 638, 674]:
		for x: int in range((y / 2) % 41, 2304, 128):
			_rect(image, Rect2i(x, y, 72, 2), WATER if y > 610 else WATER_LIGHT)
	return image


func _draw_gate(state: int) -> Image:
	var image: Image = _new_image(Vector2i(384, 512))
	# Thick stepped pointed frame with visible masonry joints.
	for layer: int in range(5):
		var inset: int = layer * 8
		var frame_color: Color = STONE_LIGHT.darkened(float(layer) * 0.09)
		_rect(image, Rect2i(8 + inset, 138 + inset, 38, 374 - inset), frame_color)
		_rect(image, Rect2i(338 - inset, 138 + inset, 38, 374 - inset), frame_color)
		_line(image, Vector2i(27 + inset, 151 + inset), Vector2i(146, 30 + inset), frame_color, 23)
		_line(image, Vector2i(357 - inset, 151 + inset), Vector2i(238, 30 + inset), frame_color, 23)
		_rect(image, Rect2i(146, 18 + inset, 92, 26), frame_color)
	_rect(image, Rect2i(48, 150, 288, 362), Color("070812"))
	if state < 2:
		for side: int in range(2):
			var x: int = 52 + side * 142
			_rect(image, Rect2i(x, 152, 138, 356), OAK_DARK)
			_rect(image, Rect2i(x + 9, 162, 120, 336), OAK)
			for panel_y: int in [174, 272, 370]:
				_rect(image, Rect2i(x + 20, panel_y, 98, 78), Color("341f28"))
				_rect(image, Rect2i(x + 27, panel_y + 7, 84, 64), Color("1b1620"))
			for strap_y: int in [250, 348, 472]:
				_rect(image, Rect2i(x + 5, strap_y, 128, 9), BRASS_DARK)
				for rivet_x: int in range(x + 16, x + 126, 22):
					_rect(image, Rect2i(rivet_x, strap_y + 2, 4, 4), BRASS_LIGHT)
		# Thirteen inset seals and a deliberate empty fourteenth scar.
		for index: int in range(13):
			var col: int = index % 4
			var row: int = index / 4
			var seal_x: int = 78 + col * 66
			var seal_y: int = 190 + row * 72
			_draw_bell_glyph(image, Vector2i(seal_x, seal_y), state == 1)
		_rect(image, Rect2i(273, 405, 28, 36), BLOOD_DARK)
		_line(image, Vector2i(277, 410), Vector2i(297, 435), BLOOD_LIGHT, 2)
		_fill_circle(image, Vector2i(192, 324), 30, BLOOD)
		_draw_confessor_mark(image, Vector2i(192, 324), state == 1)
		_rect(image, Rect2i(187, 150, 10, 358), BRASS_DARK)
	else:
		# Open state retains visible inward door leaves and a deep cold void.
		_rect(image, Rect2i(50, 160, 42, 344), OAK)
		_rect(image, Rect2i(292, 160, 42, 344), OAK)
		_rect(image, Rect2i(94, 168, 196, 336), Color("05060c"))
		for y: int in range(190, 470, 44):
			_rect(image, Rect2i(112, y, 160, 2), Color(0.33, 0.57, 0.68, 0.18))
	return image


func _draw_stained_glass() -> Image:
	var image: Image = _new_image(Vector2i(640, 440))
	# Stone frame and lancet silhouette.
	_fill_polygon(image, PackedVector2Array([
		Vector2(18, 436), Vector2(18, 124), Vector2(320, 10),
		Vector2(622, 124), Vector2(622, 436),
	]), STONE_LIGHT)
	_fill_polygon(image, PackedVector2Array([
		Vector2(34, 424), Vector2(34, 136), Vector2(320, 28),
		Vector2(606, 136), Vector2(606, 424),
	]), BRASS_DARK)
	_fill_polygon(image, PackedVector2Array([
		Vector2(48, 412), Vector2(48, 148), Vector2(320, 46),
		Vector2(592, 148), Vector2(592, 412),
	]), Color("18213b"))
	# Black bell and central confessor.
	_fill_polygon(image, PackedVector2Array([
		Vector2(270, 76), Vector2(370, 76), Vector2(394, 150),
		Vector2(246, 150),
	]), Color("090b12"))
	_rect(image, Rect2i(236, 145, 168, 12), BRASS)
	_fill_circle(image, Vector2i(320, 170), 14, BRASS_DARK)
	_draw_kneeling_figure(image, Vector2i(320, 222), true)
	# Six figures per side, each with body/head/halo—not anonymous polygons.
	for side: int in [-1, 1]:
		for row: int in range(6):
			var figure_x: int = 320 + side * (72 + (row % 3) * 62)
			var figure_y: int = 214 + (row / 3) * 116 + (row % 3) * 18
			_draw_kneeling_figure(image, Vector2i(figure_x, figure_y), false)
	# The thirteenth victim and scraped fourteenth position.
	_draw_kneeling_figure(image, Vector2i(320, 356), false)
	_rect(image, Rect2i(286, 388, 68, 18), Color("6e625b"))
	for scratch: int in range(5):
		_line(image, Vector2i(292 + scratch * 11, 390), Vector2i(306 + scratch * 9, 404), Color("211c25"), 2)
	# Lead tracery.
	for x: int in [112, 208, 320, 432, 528]:
		_line(image, Vector2i(x, 138), Vector2i(x, 412), BRASS_DARK, 4)
	for y: int in [196, 288, 376]:
		_line(image, Vector2i(48, y), Vector2i(592, y), BRASS_DARK, 4)
	return image


func _draw_altar(collapsed: bool) -> Image:
	var image: Image = _new_image(Vector2i(480, 240))
	var fall: int = 24 if collapsed else 0
	_rect(image, Rect2i(18, 184 + fall, 444, 28), STONE_LIGHT)
	_rect(image, Rect2i(38, 132 + fall, 404, 55), STONE)
	_rect(image, Rect2i(68, 82 + fall, 344, 52), STONE_MID)
	_rect(image, Rect2i(98, 55 + fall, 284, 30), Color("242b37"))
	_rect(image, Rect2i(112, 62 + fall, 256, 14), BRASS_DARK)
	for index: int in range(13):
		var x: int = 78 + index * 27
		_rect(image, Rect2i(x, 145 + fall, 18, 24), BLOOD_DARK)
		_draw_bell_glyph(image, Vector2i(x + 9, 156 + fall), false)
	_draw_confessor_mark(image, Vector2i(240, 108 + fall), true)
	if collapsed:
		for crack: int in range(8):
			_line(image, Vector2i(38 + crack * 50, 148 + fall), Vector2i(62 + crack * 50, 210 + fall), VOID, 3)
		for shard: int in range(7):
			_rect(image, Rect2i(34 + shard * 62, 210, 18, 8), STONE_MID)
	return image


func _draw_choir_stalls() -> Image:
	var image: Image = _new_image(Vector2i(480, 180))
	_rect(image, Rect2i(8, 54, 464, 120), OAK_DARK)
	for index: int in range(7):
		var x: int = 18 + index * 65
		_rect(image, Rect2i(x, 66, 56, 88), OAK)
		_fill_polygon(image, PackedVector2Array([
			Vector2(x + 4, 65), Vector2(x + 28, 35), Vector2(x + 52, 65),
		]), OAK_LIGHT)
		_rect(image, Rect2i(x + 12, 88, 32, 50), Color("2b1c25"))
		_draw_bell_glyph(image, Vector2i(x + 28, 113), false)
	_rect(image, Rect2i(0, 154, 480, 20), OAK_LIGHT)
	return image


func _draw_ritual_floor() -> Image:
	var image: Image = _new_image(Vector2i(960, 128))
	_rect(image, Rect2i(0, 82, 960, 46), STONE_DARK)
	for index: int in range(13):
		var x: int = 52 + index * 67
		_fill_circle(image, Vector2i(x, 72), 21, BRASS_DARK)
		_fill_circle(image, Vector2i(x, 72), 14, Color("241a24"))
		_draw_bell_glyph(image, Vector2i(x, 72), index == 12)
	for x: int in range(0, 960, 64):
		_line(image, Vector2i(x, 96), Vector2i(x + 44, 128), STONE_MID, 2)
	return image


func _draw_pipe_organ() -> Image:
	var image: Image = _new_image(Vector2i(600, 440))
	_rect(image, Rect2i(18, 388, 564, 38), OAK_DARK)
	for index: int in range(15):
		var height: int = 156 + (7 - absi(index - 7)) * 28
		var x: int = 38 + index * 35
		_rect(image, Rect2i(x, 388 - height, 22, height), BRASS_DARK)
		_rect(image, Rect2i(x + 4, 388 - height + 8, 7, height - 16), STONE_LIGHT)
		_fill_polygon(image, PackedVector2Array([
			Vector2(x, 388 - height), Vector2(x + 11, 374 - height), Vector2(x + 22, 388 - height),
		]), BRASS)
	_rect(image, Rect2i(92, 326, 416, 70), OAK)
	for index: int in range(13):
		_draw_bell_glyph(image, Vector2i(116 + index * 31, 355), false)
	return image


func _draw_candle_array(frame: int) -> Image:
	var image: Image = _new_image(Vector2i(832, 144))
	_rect(image, Rect2i(10, 118, 812, 18), BRASS_DARK)
	for index: int in range(13):
		var x: int = 30 + index * 62
		var height: int = 45 + (index % 4) * 9
		_rect(image, Rect2i(x, 118 - height, 14, height), WAX)
		_rect(image, Rect2i(x + 3, 122 - height, 8, 5), BLOOD_LIGHT)
		var lean: int = ((index + frame) % 3) - 1
		_fill_polygon(image, PackedVector2Array([
			Vector2(x + 3 + lean, 113 - height), Vector2(x + 7 + lean, 101 - height),
			Vector2(x + 12 + lean, 113 - height), Vector2(x + 8, 120 - height),
		]), FLAME)
		_rect(image, Rect2i(x + 6 + lean, 109 - height, 3, 7), FLAME_CORE)
	# Empty fourteenth socket is a black burn scar, not a candle.
	_fill_circle(image, Vector2i(810, 119), 11, Color("09070b"))
	return image


func _draw_lectern() -> Image:
	var image: Image = _new_image(Vector2i(128, 160))
	_fill_polygon(image, PackedVector2Array([
		Vector2(12, 24), Vector2(116, 24), Vector2(103, 61), Vector2(25, 61),
	]), OAK_LIGHT)
	_rect(image, Rect2i(23, 61, 82, 12), OAK_DARK)
	_rect(image, Rect2i(57, 72, 14, 68), OAK)
	_rect(image, Rect2i(30, 140, 68, 12), OAK_DARK)
	_draw_confessor_mark(image, Vector2i(64, 47), false)
	return image


func _draw_registry() -> Image:
	var image: Image = _new_image(Vector2i(96, 64))
	_rect(image, Rect2i(6, 10, 40, 48), BONE)
	_rect(image, Rect2i(50, 10, 40, 48), Color("b7ad98"))
	_line(image, Vector2i(48, 9), Vector2i(48, 59), OAK_DARK, 3)
	for y: int in range(18, 54, 8):
		_line(image, Vector2i(12, y), Vector2i(39, y), BLOOD_DARK, 1)
		_line(image, Vector2i(56, y), Vector2i(83, y), BLOOD_DARK, 1)
	_draw_bell_glyph(image, Vector2i(48, 31), false)
	return image


func _draw_censer() -> Image:
	var image: Image = _new_image(Vector2i(128, 160))
	for anchor_x: int in [34, 94]:
		_line(image, Vector2i(anchor_x, 0), Vector2i(anchor_x - 11, 94), BRASS_DARK, 3)
		_line(image, Vector2i(anchor_x, 0), Vector2i(anchor_x + 11, 94), BRASS_DARK, 3)
		_fill_circle(image, Vector2i(anchor_x, 103), 17, BRASS)
		_rect(image, Rect2i(anchor_x - 18, 98, 36, 8), BRASS_LIGHT)
		for hole_x: int in [-8, 0, 8]:
			_rect(image, Rect2i(anchor_x + hole_x - 2, 99, 4, 4), VOID)
	return image


func _draw_checkpoint_shrine() -> Image:
	var image: Image = _new_image(Vector2i(160, 192))
	_rect(image, Rect2i(12, 165, 136, 20), STONE_LIGHT)
	_rect(image, Rect2i(26, 139, 108, 28), STONE)
	_fill_polygon(image, PackedVector2Array([
		Vector2(44, 139), Vector2(44, 68), Vector2(80, 25), Vector2(116, 68), Vector2(116, 139),
	]), STONE_MID)
	_fill_polygon(image, PackedVector2Array([
		Vector2(57, 132), Vector2(57, 76), Vector2(80, 47), Vector2(103, 76), Vector2(103, 132),
	]), VOID)
	_fill_circle(image, Vector2i(80, 96), 18, Color(0.33, 0.67, 0.82, 0.28))
	_fill_circle(image, Vector2i(80, 96), 8, SOUL)
	_draw_bell_glyph(image, Vector2i(80, 148), true)
	return image


func _draw_bell_saint(mirrored: bool) -> Image:
	var image: Image = _new_image(Vector2i(160, 320))
	var cx: int = 80
	_fill_polygon(image, PackedVector2Array([
		Vector2(30, 303), Vector2(45, 142), Vector2(cx, 93), Vector2(115, 142), Vector2(130, 303),
	]), STONE_MID)
	_fill_circle(image, Vector2i(cx, 70), 31, STONE_LIGHT)
	_rect(image, Rect2i(52, 65, 56, 15), VOID)
	_rect(image, Rect2i(63, 152, 34, 86), STONE_LIGHT)
	var hand_x: int = 41 if mirrored else 119
	_line(image, Vector2i(cx, 160), Vector2i(hand_x, 220), STONE_LIGHT, 13)
	_fill_circle(image, Vector2i(hand_x, 240), 24, BRASS_DARK)
	_rect(image, Rect2i(hand_x - 29, 236, 58, 8), BRASS)
	return image


func _draw_confession_tablets() -> Image:
	var image: Image = _new_image(Vector2i(832, 168))
	for index: int in range(13):
		var x: int = 8 + index * 63
		_fill_polygon(image, PackedVector2Array([
			Vector2(x, 160), Vector2(x, 37), Vector2(x + 29, 8),
			Vector2(x + 58, 37), Vector2(x + 58, 160),
		]), STONE_MID)
		_rect(image, Rect2i(x + 8, 46, 42, 104), Color("171925"))
		for y: int in [62, 82, 102, 122]:
			_rect(image, Rect2i(x + 13, y, 32, 2), BRASS_DARK)
		_draw_bell_glyph(image, Vector2i(x + 29, 29), index == 12)
	return image


func _draw_small_bell() -> Image:
	var image: Image = _new_image(Vector2i(32, 40))
	_draw_bell_glyph(image, Vector2i(16, 18), true)
	_rect(image, Rect2i(14, 0, 4, 9), BRASS_DARK)
	return image


func _draw_single_candle() -> Image:
	var image: Image = _new_image(Vector2i(32, 72))
	_rect(image, Rect2i(9, 30, 14, 38), WAX)
	_rect(image, Rect2i(12, 34, 8, 5), BLOOD_LIGHT)
	_fill_polygon(image, PackedVector2Array([
		Vector2(10, 30), Vector2(16, 5), Vector2(22, 30), Vector2(16, 36),
	]), FLAME)
	_rect(image, Rect2i(14, 20, 4, 11), FLAME_CORE)
	return image


func _draw_seal_light() -> Image:
	var image: Image = _new_image(Vector2i(40, 40))
	_fill_circle(image, Vector2i(20, 20), 18, Color(0.40, 0.72, 0.86, 0.18))
	_draw_bell_glyph(image, Vector2i(20, 18), true)
	return image


func _draw_reliquary() -> Image:
	var image: Image = _new_image(Vector2i(180, 220))
	_rect(image, Rect2i(12, 176, 156, 28), STONE_LIGHT)
	_rect(image, Rect2i(28, 126, 124, 52), STONE)
	_fill_polygon(image, PackedVector2Array([
		Vector2(38, 126), Vector2(38, 50), Vector2(90, 12), Vector2(142, 50), Vector2(142, 126),
	]), BRASS_DARK)
	_fill_polygon(image, PackedVector2Array([
		Vector2(50, 118), Vector2(50, 57), Vector2(90, 28), Vector2(130, 57), Vector2(130, 118),
	]), Color("16131d"))
	_fill_circle(image, Vector2i(90, 80), 24, Color(0.31, 0.58, 0.68, 0.22))
	_draw_bell_glyph(image, Vector2i(90, 80), true)
	return image


func _draw_ossuary_stairs() -> Image:
	var image: Image = _new_image(Vector2i(640, 256))
	for step: int in range(10):
		_rect(image, Rect2i(step * 54, step * 22, 640 - step * 54, 28), STONE_MID.darkened(float(step) * 0.035))
		_rect(image, Rect2i(step * 54, step * 22, 640 - step * 54, 4), STONE_LIGHT)
	return image


func _draw_wet_arch() -> Image:
	var image: Image = _new_image(Vector2i(320, 420))
	_fill_polygon(image, PackedVector2Array([
		Vector2(8, 420), Vector2(8, 140), Vector2(160, 12), Vector2(312, 140), Vector2(312, 420),
	]), STONE_MID)
	_fill_polygon(image, PackedVector2Array([
		Vector2(48, 420), Vector2(48, 162), Vector2(160, 64), Vector2(272, 162), Vector2(272, 420),
	]), Color("07101a"))
	for x: int in [24, 82, 240, 294]:
		_rect(image, Rect2i(x, 190, 11, 204), Color(0.10, 0.32, 0.36, 0.7))
	return image


func _draw_rusted_gate() -> Image:
	var image: Image = _new_image(Vector2i(320, 360))
	_rect(image, Rect2i(6, 10, 308, 14), Color("77513b"))
	_rect(image, Rect2i(6, 332, 308, 14), Color("77513b"))
	for x: int in range(22, 310, 34):
		_rect(image, Rect2i(x, 14, 10, 324), Color("59392f"))
		_fill_polygon(image, PackedVector2Array([
			Vector2(x - 4, 14), Vector2(x + 5, 0), Vector2(x + 14, 14),
		]), Color("8a5c43"))
	for y: int in [94, 182, 270]:
		_rect(image, Rect2i(6, y, 308, 9), Color("39262a"))
	return image


func _draw_shallow_water() -> Image:
	var image: Image = _new_image(Vector2i(768, 96))
	_rect(image, Rect2i(0, 26, 768, 70), Color(0.05, 0.24, 0.34, 0.75))
	for row: int in range(4):
		for x: int in range((row * 53) % 96, 760, 128):
			_rect(image, Rect2i(x, 22 + row * 17, 68, 3), WATER_LIGHT if row < 2 else WATER)
	return image


func _draw_submerged_statue() -> Image:
	var image: Image = _new_image(Vector2i(192, 260))
	_fill_circle(image, Vector2i(96, 42), 28, STONE_LIGHT)
	_fill_polygon(image, PackedVector2Array([
		Vector2(44, 218), Vector2(56, 76), Vector2(96, 60), Vector2(136, 76), Vector2(152, 218),
	]), STONE_MID)
	_rect(image, Rect2i(52, 105, 88, 14), STONE_LIGHT)
	_line(image, Vector2i(74, 92), Vector2i(112, 166), STONE_LIGHT, 10)
	_line(image, Vector2i(118, 92), Vector2i(80, 166), STONE_LIGHT, 10)
	_rect(image, Rect2i(20, 208, 152, 28), WATER)
	for x: int in range(24, 172, 44):
		_rect(image, Rect2i(x, 218 + (x % 3), 30, 3), WATER_LIGHT)
	return image


func _draw_incense(frame: int) -> Image:
	var image: Image = _new_image(Vector2i(256, 192))
	for strand: int in range(5):
		var x: int = 38 + strand * 45
		var drift: int = ((strand + frame) % 3 - 1) * 8
		_line(image, Vector2i(x, 186), Vector2i(x + drift, 128), Color(0.51, 0.66, 0.70, 0.24), 5)
		_line(image, Vector2i(x + drift, 128), Vector2i(128 + drift / 2, 72), Color(0.60, 0.75, 0.78, 0.18), 4)
		_fill_circle(image, Vector2i(128 + drift / 2, 64 - strand * 3), 13, Color(0.52, 0.68, 0.73, 0.12))
	return image


func _draw_resonance() -> Image:
	var image: Image = _new_image(Vector2i(256, 128))
	for ring: int in range(4):
		var radius: int = 22 + ring * 22
		_draw_circle_outline(image, Vector2i(128, 64), radius, Color(0.43, 0.70, 0.82, 0.32 - ring * 0.05), 2)
	return image


func _draw_glass_crack() -> Image:
	var image: Image = _new_image(Vector2i(640, 440))
	for start: Vector2i in [Vector2i(320, 108), Vector2i(214, 196), Vector2i(432, 224)]:
		for branch: int in range(4):
			var end: Vector2i = start + Vector2i((branch - 2) * 74, 86 + branch * 27)
			_line(image, start, end, Color(0.78, 0.90, 0.94, 0.62), 2)
	return image


func _draw_wax_crack() -> Image:
	var image: Image = _new_image(Vector2i(128, 128))
	_fill_circle(image, Vector2i(64, 64), 34, Color(0.60, 0.10, 0.17, 0.72))
	for end: Vector2i in [Vector2i(18, 32), Vector2i(111, 28), Vector2i(107, 101), Vector2i(22, 108)]:
		_line(image, Vector2i(64, 64), end, Color("e6b77a"), 3)
	return image


func _draw_brick_wall(image: Image, area: Rect2i, brick_width: int, brick_height: int) -> void:
	_rect(image, area, STONE_DARK)
	var row: int = 0
	for y: int in range(area.position.y, area.end.y, brick_height):
		var offset: int = -brick_width / 2 if row % 2 == 1 else 0
		for x: int in range(area.position.x + offset, area.end.x, brick_width):
			var tone: Color = STONE if (x / brick_width + row) % 4 != 0 else Color("293342")
			_rect(image, Rect2i(x + 2, y + 2, brick_width - 4, brick_height - 4), tone)
			_rect(image, Rect2i(x + 4, y + 4, brick_width - 8, 3), STONE_MID.darkened(0.15))
		row += 1


func _draw_gothic_bay(image: Image, x: int, y: int, width: int, height: int) -> void:
	var half: int = width / 2
	_rect(image, Rect2i(x, y + 118, 28, height - 118), STONE_MID)
	_rect(image, Rect2i(x + width - 28, y + 118, 28, height - 118), STONE_MID)
	_line(image, Vector2i(x + 14, y + 132), Vector2i(x + half, y), STONE_LIGHT, 18)
	_line(image, Vector2i(x + width - 14, y + 132), Vector2i(x + half, y), STONE_LIGHT, 18)
	_rect(image, Rect2i(x + 6, y + 182, 14, height - 190), Color("596778"))
	_rect(image, Rect2i(x + width - 20, y + 182, 14, height - 190), Color("202735"))
	for joint_y: int in range(y + 170, y + height, 64):
		_rect(image, Rect2i(x, joint_y, 28, 3), STONE_DARK)
		_rect(image, Rect2i(x + width - 28, joint_y, 28, 3), STONE_DARK)


func _draw_rib(image: Image, start: Vector2i, apex: Vector2i) -> void:
	_line(image, start, apex, STONE_MID, 8)
	_line(image, start + Vector2i(0, 3), apex + Vector2i(0, 3), STONE_LIGHT, 2)


func _draw_high_window(image: Image, x: int, y: int, width: int, height: int) -> void:
	_fill_polygon(image, PackedVector2Array([
		Vector2(x, y + height), Vector2(x, y + 78), Vector2(x + width / 2, y),
		Vector2(x + width, y + 78), Vector2(x + width, y + height),
	]), STONE_MID)
	_fill_polygon(image, PackedVector2Array([
		Vector2(x + 12, y + height - 12), Vector2(x + 12, y + 84), Vector2(x + width / 2, y + 18),
		Vector2(x + width - 12, y + 84), Vector2(x + width - 12, y + height - 12),
	]), Color("172d43"))
	_line(image, Vector2i(x + width / 2, y + 22), Vector2i(x + width / 2, y + height - 12), BRASS_DARK, 4)
	for cut_y: int in range(y + 126, y + height - 20, 62):
		_line(image, Vector2i(x + 12, cut_y), Vector2i(x + width - 12, cut_y), BRASS_DARK, 3)


func _draw_carved_band(image: Image, x: int, y: int, width: int) -> void:
	_rect(image, Rect2i(x, y, width, 34), STONE_MID)
	_rect(image, Rect2i(x, y, width, 5), STONE_LIGHT)
	_rect(image, Rect2i(x, y + 29, width, 5), STONE_DARK)
	for tile_x: int in range(x + 16, x + width - 16, 44):
		_fill_polygon(image, PackedVector2Array([
			Vector2(tile_x, y + 17), Vector2(tile_x + 10, y + 7),
			Vector2(tile_x + 20, y + 17), Vector2(tile_x + 10, y + 27),
		]), BRASS_DARK)


func _draw_floor_tile(image: Image, x: int, y: int, width: int, height: int, variant: int) -> void:
	var base: Color = Color("252c39") if variant % 3 else Color("2b3341")
	_rect(image, Rect2i(x + 2, y + 2, width - 4, height - 4), base)
	_line(image, Vector2i(x + 6, y + height - 8), Vector2i(x + width - 8, y + 8), STONE_MID, 2)
	if variant % 4 == 0:
		_line(image, Vector2i(x + width / 2, y + 8), Vector2i(x + width / 2 - 8, y + height - 8), BLOOD_DARK, 2)


func _draw_erased_royal_crest(image: Image, center: Vector2i) -> void:
	_fill_circle(image, center, 72, BRASS_DARK)
	_fill_circle(image, center, 60, OAK_DARK)
	for scratch: int in range(9):
		_line(image, center + Vector2i(-50 + scratch * 10, -44), center + Vector2i(-34 + scratch * 11, 48), STONE_LIGHT, 4)


func _draw_confessor_relief(image: Image, center: Vector2i) -> void:
	_fill_circle(image, center, 76, STONE_MID)
	_fill_circle(image, center + Vector2i(0, -26), 22, STONE_LIGHT)
	_fill_polygon(image, PackedVector2Array([
		Vector2(center.x - 43, center.y + 54), Vector2(center.x - 28, center.y - 2),
		Vector2(center.x, center.y - 10), Vector2(center.x + 28, center.y - 2),
		Vector2(center.x + 43, center.y + 54),
	]), STONE_LIGHT)
	_draw_confessor_mark(image, center + Vector2i(0, 18), false)


func _draw_kneeling_figure(image: Image, center: Vector2i, priest: bool) -> void:
	var robe: Color = BLOOD if priest else Color("485681")
	var halo: Color = BRASS_LIGHT if priest else BRASS_DARK
	_fill_circle(image, center + Vector2i(0, -28), 9, BONE)
	_draw_circle_outline(image, center + Vector2i(0, -28), 14, halo, 3)
	_fill_polygon(image, PackedVector2Array([
		Vector2(center.x - 15, center.y + 22), Vector2(center.x - 10, center.y - 16),
		Vector2(center.x + 10, center.y - 16), Vector2(center.x + 18, center.y + 22),
	]), robe)
	_line(image, center + Vector2i(-7, -3), center + Vector2i(-23, 19), BONE, 3)
	_line(image, center + Vector2i(7, -3), center + Vector2i(23, 19), BONE, 3)


func _draw_bell_glyph(image: Image, center: Vector2i, lit: bool) -> void:
	var color: Color = BRASS_LIGHT if lit else BRASS_DARK
	_fill_polygon(image, PackedVector2Array([
		Vector2(center.x - 8, center.y + 5), Vector2(center.x - 5, center.y - 7),
		Vector2(center.x, center.y - 11), Vector2(center.x + 5, center.y - 7),
		Vector2(center.x + 8, center.y + 5),
	]), color)
	_rect(image, Rect2i(center.x - 11, center.y + 4, 22, 4), color)
	_fill_circle(image, center + Vector2i(0, 9), 3, color)


func _draw_confessor_mark(image: Image, center: Vector2i, lit: bool) -> void:
	var color: Color = BRASS_LIGHT if lit else BRASS_DARK
	_draw_bell_glyph(image, center, lit)
	_line(image, center + Vector2i(-20, 18), center + Vector2i(20, 18), color, 4)
	_line(image, center + Vector2i(0, -24), center + Vector2i(0, 28), color, 3)


func _draw_circle_outline(image: Image, center: Vector2i, radius: int, color: Color, thickness: int) -> void:
	for y: int in range(center.y - radius - thickness, center.y + radius + thickness + 1):
		for x: int in range(center.x - radius - thickness, center.x + radius + thickness + 1):
			var distance_squared: int = (Vector2i(x, y) - center).length_squared()
			var outer: int = radius * radius
			var inner_radius: int = maxi(0, radius - thickness)
			if distance_squared <= outer and distance_squared >= inner_radius * inner_radius:
				_set_pixel_safe(image, x, y, color)


func _fill_circle(image: Image, center: Vector2i, radius: int, color: Color) -> void:
	for y: int in range(center.y - radius, center.y + radius + 1):
		for x: int in range(center.x - radius, center.x + radius + 1):
			if (Vector2i(x, y) - center).length_squared() <= radius * radius:
				_set_pixel_safe(image, x, y, color)


func _fill_polygon(image: Image, points: PackedVector2Array, color: Color) -> void:
	if points.size() < 3:
		return
	var min_x: int = image.get_width() - 1
	var max_x: int = 0
	var min_y: int = image.get_height() - 1
	var max_y: int = 0
	for point: Vector2 in points:
		min_x = mini(min_x, floori(point.x))
		max_x = maxi(max_x, ceili(point.x))
		min_y = mini(min_y, floori(point.y))
		max_y = maxi(max_y, ceili(point.y))
	for y: int in range(maxi(0, min_y), mini(image.get_height() - 1, max_y) + 1):
		for x: int in range(maxi(0, min_x), mini(image.get_width() - 1, max_x) + 1):
			if Geometry2D.is_point_in_polygon(Vector2(x + 0.5, y + 0.5), points):
				image.set_pixel(x, y, color)


func _new_image(size: Vector2i, background: Color = CLEAR) -> Image:
	var image: Image = Image.create(size.x, size.y, false, Image.FORMAT_RGBA8)
	image.fill(background)
	return image


func _save(image: Image, relative_path: String) -> int:
	var path: String = ROOT.path_join(relative_path)
	var directory_error: Error = DirAccess.make_dir_recursive_absolute(
		ProjectSettings.globalize_path(path.get_base_dir())
	)
	if directory_error != OK:
		return 1
	var save_error: Error = image.save_png(ProjectSettings.globalize_path(path))
	if save_error != OK:
		return 1
	_saved_count += 1
	return 0


func _set_pixel_safe(image: Image, x: int, y: int, color: Color) -> void:
	if x >= 0 and y >= 0 and x < image.get_width() and y < image.get_height():
		image.set_pixel(x, y, color)


func _rect(image: Image, rect: Rect2i, color: Color) -> void:
	PixelCanvas.fill_rect(image, rect, color)


func _line(image: Image, start: Vector2i, end: Vector2i, color: Color, thickness: int) -> void:
	PixelCanvas.draw_line(image, start, end, color, thickness)
