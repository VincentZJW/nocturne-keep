class_name CharacterDesignLab
extends Control

## Internal-only preview and export scene for the Night Warden concept assets.

signal export_completed(output_paths: PackedStringArray)

const Generator: Script = preload("res://scripts/tools/pixel_character_generator.gd")
const BoardExporter: Script = preload("res://scripts/tools/character_board_exporter.gd")

@export var auto_export_on_ready: bool = true

@onready var preview_list: VBoxContainer = %PreviewList
@onready var status_label: Label = %Status
@onready var export_button: Button = %ExportButton

var _assets: Dictionary[String, Image] = {}


func _ready() -> void:
	export_button.pressed.connect(_on_export_pressed)
	if auto_export_on_ready:
		await _generate_and_export()
	if OS.get_cmdline_user_args().has("--generate-only"):
		get_tree().quit()


func _on_export_pressed() -> void:
	await _generate_and_export()


func _generate_and_export() -> void:
	status_label.text = "Generating original pixel assets…"
	export_button.disabled = true
	_assets = Generator.generate_all()
	var save_results: Dictionary[String, int] = Generator.save_all(_assets)
	var board_error: Error = OK
	if not OS.get_cmdline_user_args().has("--skip-board"):
		board_error = await BoardExporter.export_board(get_tree(), _assets)
	_rebuild_previews()
	var failed_paths: PackedStringArray = []
	for path: String in save_results:
		if save_results[path] != OK:
			failed_paths.append(path)
	if board_error != OK:
		failed_paths.append(BoardExporter.BOARD_PATH)
	if failed_paths.is_empty():
		status_label.text = "Export complete · 11 transparent PNGs + 1600×1000 design board"
	else:
		status_label.text = "Export failed: %s" % ", ".join(failed_paths)
	export_button.disabled = false
	var output_paths: PackedStringArray = PackedStringArray(save_results.keys())
	output_paths.append(BoardExporter.BOARD_PATH)
	export_completed.emit(output_paths)


func _rebuild_previews() -> void:
	for child: Node in preview_list.get_children():
		child.queue_free()
	var core_views: Array[String] = ["assassin_front_64.png", "assassin_side_64.png", "assassin_silhouette_64.png"]
	var daggers: Array[String] = ["dagger_main.png", "dagger_offhand.png", "palette_preview.png"]
	var readability: Array[String] = ["assassin_front_48.png", "assassin_side_48.png"]
	var key_poses: Array[String] = ["assassin_idle_pose.png", "assassin_attack_anticipation.png", "assassin_dash_pose.png"]
	_add_preview_group("CORE VIEWS", core_views)
	_add_preview_group("DUAL DAGGERS", daggers)
	_add_preview_group("READABILITY", readability)
	_add_preview_group("KEY POSES", key_poses)


func _add_preview_group(title: String, file_names: Array[String]) -> void:
	var heading: Label = Label.new()
	heading.text = title
	heading.add_theme_font_size_override("font_size", 20)
	heading.add_theme_color_override("font_color", Color("b98243"))
	preview_list.add_child(heading)
	var row: HBoxContainer = HBoxContainer.new()
	row.add_theme_constant_override("separation", 26)
	preview_list.add_child(row)
	for file_name: String in file_names:
		var card: VBoxContainer = VBoxContainer.new()
		var name_label: Label = Label.new()
		name_label.text = file_name.get_basename().to_upper()
		name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		name_label.add_theme_font_size_override("font_size", 12)
		name_label.add_theme_color_override("font_color", Color("aab9c4"))
		card.add_child(name_label)
		var texture_rect: TextureRect = TextureRect.new()
		var image: Image = _assets[file_name]
		var scale: int = 3 if image.get_width() >= 48 else 4
		texture_rect.custom_minimum_size = Vector2(image.get_size() * scale)
		texture_rect.texture = ImageTexture.create_from_image(image)
		texture_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		texture_rect.stretch_mode = TextureRect.STRETCH_SCALE
		texture_rect.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		card.add_child(texture_rect)
		row.add_child(card)
