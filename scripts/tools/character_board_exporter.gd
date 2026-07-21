class_name CharacterBoardExporter
extends RefCounted

## Builds the 1600x1000 concept board in an isolated SubViewport.

const BOARD_SIZE: Vector2i = Vector2i(1600, 1000)
const BOARD_PATH: String = "res://docs/design/hooded_assassin_character_board.png"
const BACKGROUND: Color = Color("090d14")
const PANEL: Color = Color("111b27")
const PANEL_ALT: Color = Color("162230")
const BORDER: Color = Color("34485b")
const TEXT: Color = Color("e6ebee")
const MUTED_TEXT: Color = Color("91a4b4")

static var _board_font: SystemFont


static func export_board(tree: SceneTree, assets: Dictionary[String, Image]) -> Error:
	var directory_error: Error = DirAccess.make_dir_recursive_absolute(
		ProjectSettings.globalize_path(BOARD_PATH.get_base_dir())
	)
	if directory_error != OK:
		return directory_error
	await tree.process_frame
	var viewport: SubViewport = SubViewport.new()
	viewport.name = "CharacterBoardViewport"
	viewport.size = BOARD_SIZE
	viewport.disable_3d = true
	viewport.transparent_bg = false
	viewport.render_target_clear_mode = SubViewport.CLEAR_MODE_ALWAYS
	viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	viewport.canvas_item_default_texture_filter = Viewport.DEFAULT_CANVAS_ITEM_TEXTURE_FILTER_NEAREST
	tree.root.add_child(viewport)
	var root: Control = Control.new()
	root.name = "CharacterBoard"
	root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	viewport.add_child(root)
	_add_rect(root, Vector2.ZERO, Vector2(BOARD_SIZE), BACKGROUND)
	_build_header(root)
	_build_primary_views(root, assets)
	_build_lower_sections(root, assets)
	await tree.process_frame
	await tree.process_frame
	await tree.process_frame
	var board: Image = viewport.get_texture().get_image()
	var save_error: Error = board.save_png(BOARD_PATH)
	viewport.queue_free()
	return save_error


static func _build_header(root: Control) -> void:
	_add_label(root, "CONCEPT C · PIXEL GOTHIC ASSASSIN", Vector2(60, 42), Vector2(1050, 56), 38, TEXT)
	_add_label(root, "方案C · 像素哥特暗杀者", Vector2(62, 98), Vector2(700, 38), 23, MUTED_TEXT)
	_add_label(root, "THE NIGHT WARDEN / 夜巡守卫", Vector2(60, 140), Vector2(650, 34), 18, Color("b7c7d2"))
	_add_rect(root, Vector2(1260, 54), Vector2(280, 58), Color("332719"), Color("b98243"))
	_add_label(root, "SELECTED DIRECTION", Vector2(1280, 68), Vector2(240, 30), 17, Color("d9b27a"), HORIZONTAL_ALIGNMENT_CENTER)


static func _build_primary_views(root: Control, assets: Dictionary[String, Image]) -> void:
	var panel_positions: Array[Vector2] = [Vector2(60, 200), Vector2(385, 200), Vector2(710, 200), Vector2(1035, 200)]
	var headings: Array[String] = ["FRONT VIEW / 正面", "GAMEPLAY SIDE VIEW / 横版侧视", "BLACK SILHOUETTE / 纯黑剪影", "DUAL DAGGER PROFILE / 双匕首轮廓"]
	for index: int in range(panel_positions.size()):
		_add_rect(root, panel_positions[index], Vector2(295, 350), PANEL if index % 2 == 0 else PANEL_ALT, BORDER)
		_add_label(root, headings[index], panel_positions[index] + Vector2(16, 14), Vector2(263, 28), 15, TEXT)
	_add_texture(root, assets["assassin_front_64.png"], Vector2(80, 260), 4)
	_add_texture(root, assets["assassin_side_64.png"], Vector2(405, 260), 4)
	_add_texture(root, assets["assassin_silhouette_64.png"], Vector2(730, 260), 4)
	_add_texture(root, assets["dagger_main.png"], Vector2(1080, 310), 5)
	_add_texture(root, assets["dagger_offhand.png"], Vector2(1100, 410), 5)
	_add_label(root, "MAIN · FORWARD GRIP", Vector2(1060, 270), Vector2(250, 24), 13, MUTED_TEXT)
	_add_label(root, "OFFHAND · REVERSE GRIP", Vector2(1060, 380), Vector2(250, 24), 13, MUTED_TEXT)


static func _build_lower_sections(root: Control, assets: Dictionary[String, Image]) -> void:
	_build_palette(root)
	_build_readability(root, assets)
	_build_advantages(root)
	_build_animation(root, assets)


static func _build_palette(root: Control) -> void:
	_add_rect(root, Vector2(60, 580), Vector2(520, 160), PANEL, BORDER)
	_add_label(root, "COLOR PALETTE / 配色", Vector2(80, 598), Vector2(300, 26), 16, TEXT)
	var colors: Array[Color] = [Color("08101a"), Color("172b3d"), Color("607a90"), Color("d5dee3"), Color("b98243")]
	var names: Array[String] = ["HOOD", "NAVY", "SLATE", "STEEL", "AMBER"]
	for index: int in range(colors.size()):
		_add_rect(root, Vector2(82 + index * 96, 638), Vector2(76, 54), colors[index], BORDER)
		_add_label(root, names[index], Vector2(78 + index * 96, 700), Vector2(84, 20), 11, MUTED_TEXT, HORIZONTAL_ALIGNMENT_CENTER)
	_add_label(root, "48PX / 64PX PIXEL PRODUCTION PALETTE", Vector2(80, 722), Vector2(450, 18), 11, Color("b5c3cc"))


static func _build_readability(root: Control, assets: Dictionary[String, Image]) -> void:
	_add_rect(root, Vector2(610, 580), Vector2(440, 260), PANEL_ALT, BORDER)
	_add_label(root, "48PX + 64PX READABILITY", Vector2(630, 598), Vector2(380, 26), 16, TEXT)
	_add_texture(root, assets["assassin_side_48.png"], Vector2(642, 650), 3)
	_add_texture(root, assets["assassin_side_64.png"], Vector2(820, 638), 3)
	_add_label(root, "48PX MIN", Vector2(650, 798), Vector2(130, 20), 12, MUTED_TEXT, HORIZONTAL_ALIGNMENT_CENTER)
	_add_label(root, "64PX TARGET", Vector2(850, 798), Vector2(150, 20), 12, MUTED_TEXT, HORIZONTAL_ALIGNMENT_CENTER)


static func _build_advantages(root: Control) -> void:
	_add_rect(root, Vector2(1080, 580), Vector2(460, 260), PANEL, BORDER)
	_add_label(root, "DESIGN ADVANTAGES / 设计优势", Vector2(1100, 598), Vector2(410, 26), 16, TEXT)
	_add_label(root, "• POINTED HOOD READS AT SMALL SIZE\n• COMPACT TORSO, SEPARATE LEGS\n• MAIN BLADE DEFINES FACING\n• SHORT MANTLE LIMITS ANIMATION COST\n• FIVE-COLOR VALUE SEPARATION", Vector2(1100, 642), Vector2(410, 148), 15, Color("c1ccd3"))
	_add_label(root, "ONE BASIC ATTACK · NO COMBO EXPANSION", Vector2(1100, 800), Vector2(410, 22), 12, Color("d0a96e"))


static func _build_animation(root: Control, assets: Dictionary[String, Image]) -> void:
	_add_rect(root, Vector2(60, 865), Vector2(1480, 105), PANEL_ALT, BORDER)
	_add_label(root, "ANIMATION REQUIREMENTS / 动画需求", Vector2(80, 880), Vector2(390, 24), 15, TEXT)
	_add_label(root, "IDLE 6-8 · RUN 8-10 · JUMP START 3-4 · JUMP LOOP 4-6 · FALL 3-5\nLAND 4-6 · ATTACK 8-10 · DASH 5-7 · HURT 3-5 · DEATH 10-14", Vector2(80, 910), Vector2(790, 48), 12, MUTED_TEXT)
	_add_texture(root, assets["assassin_idle_pose.png"], Vector2(930, 866), 1)
	_add_texture(root, assets["assassin_attack_anticipation.png"], Vector2(1085, 866), 1)
	_add_texture(root, assets["assassin_dash_pose.png"], Vector2(1240, 866), 1)
	_add_label(root, "IDLE", Vector2(930, 944), Vector2(64, 18), 10, MUTED_TEXT, HORIZONTAL_ALIGNMENT_CENTER)
	_add_label(root, "ANTICIPATION", Vector2(1068, 944), Vector2(100, 18), 10, MUTED_TEXT, HORIZONTAL_ALIGNMENT_CENTER)
	_add_label(root, "DASH", Vector2(1240, 944), Vector2(64, 18), 10, MUTED_TEXT, HORIZONTAL_ALIGNMENT_CENTER)
	_add_label(root, "KEY POSES FIRST · ASEPRITE OR EQUIVALENT FOR FINAL SPRITE PRODUCTION", Vector2(1320, 895), Vector2(200, 60), 11, Color("b5c3cc"), HORIZONTAL_ALIGNMENT_CENTER)


static func _add_rect(
		root: Control,
		position: Vector2,
		size: Vector2,
		color: Color,
		border_color: Color = Color.TRANSPARENT
	) -> ColorRect:
	var rectangle: ColorRect = ColorRect.new()
	rectangle.position = position
	rectangle.size = size
	rectangle.color = color
	rectangle.mouse_filter = Control.MOUSE_FILTER_IGNORE
	if border_color.a > 0.0:
		var style: StyleBoxFlat = StyleBoxFlat.new()
		style.bg_color = color
		style.border_color = border_color
		style.set_border_width_all(1)
		rectangle.add_theme_stylebox_override("panel", style)
	root.add_child(rectangle)
	return rectangle


static func _add_label(
		root: Control,
		text: String,
		position: Vector2,
		size: Vector2,
		font_size: int,
		color: Color,
		alignment: HorizontalAlignment = HORIZONTAL_ALIGNMENT_LEFT
	) -> Label:
	var label: Label = Label.new()
	label.position = position
	label.size = size
	label.text = text
	label.add_theme_font_override("font", _get_board_font())
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)
	label.horizontal_alignment = alignment
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	root.add_child(label)
	return label


static func _get_board_font() -> SystemFont:
	if _board_font == null:
		_board_font = SystemFont.new()
		_board_font.font_names = PackedStringArray(["Arial", "Songti SC", "Hiragino Sans GB"])
		_board_font.font_weight = 500
	return _board_font


static func _add_texture(root: Control, image: Image, position: Vector2, scale: int) -> TextureRect:
	var texture_rect: TextureRect = TextureRect.new()
	texture_rect.position = position
	texture_rect.size = Vector2(image.get_size() * scale)
	texture_rect.texture = ImageTexture.create_from_image(image)
	texture_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	texture_rect.stretch_mode = TextureRect.STRETCH_SCALE
	texture_rect.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	texture_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.add_child(texture_rect)
	return texture_rect
