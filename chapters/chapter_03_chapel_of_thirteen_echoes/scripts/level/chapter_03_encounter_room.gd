class_name Chapter03EncounterRoom
extends Chapter03Room

const PLATFORM_TEXTURES: Dictionary[int, Texture2D] = {
	96: preload("res://chapters/chapter_03_chapel_of_thirteen_echoes/assets/environment/structural_r2/platform_96.png"),
	144: preload("res://chapters/chapter_03_chapel_of_thirteen_echoes/assets/environment/structural_r2/platform_144.png"),
	160: preload("res://chapters/chapter_03_chapel_of_thirteen_echoes/assets/environment/structural_r2/platform_160.png"),
	192: preload("res://chapters/chapter_03_chapel_of_thirteen_echoes/assets/environment/structural_r2/platform_192.png"),
}

@export var definition: Chapter03RoomDefinition

var encounter_spawner: Chapter03EncounterSpawner


func _ready() -> void:
	if definition == null or not definition.is_valid():
		push_error("Chapter03EncounterRoom requires a valid saved definition")
		return
	room_id = definition.room_id
	bilingual_name = definition.bilingual_name
	room_size = definition.room_size
	_build_presentation()
	_build_geometry()
	_build_door()
	_build_spawn_points()
	_build_encounters()
	super._ready()


func get_manifest() -> Chapter03EncounterManifest:
	return definition.manifest if definition != null else null


func _build_presentation() -> void:
	var backdrop: Sprite2D = Sprite2D.new()
	backdrop.name = "Backdrop"
	backdrop.texture = definition.backdrop_texture
	backdrop.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	backdrop.position = Vector2(definition.room_size) * 0.5
	backdrop.z_index = Chapter03LayerContract.FAR_BACKGROUND
	add_child(backdrop)
	for index: int in range(definition.prop_textures.size()):
		var prop: Sprite2D = Sprite2D.new()
		prop.name = "StoryProp%02d" % (index + 1)
		prop.texture = definition.prop_textures[index]
		prop.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		prop.position = definition.prop_positions[index]
		prop.z_index = definition.prop_z_indices[index]
		add_child(prop)


func _build_geometry() -> void:
	var geometry: Node2D = Node2D.new()
	geometry.name = "Geometry"
	add_child(geometry)
	_add_static_rectangle(geometry, "Floor", Vector2(room_size.x * 0.5, 666.0), Vector2(room_size.x, 108.0))
	_add_static_rectangle(geometry, "LeftWall", Vector2(-24.0, 360.0), Vector2(48.0, 720.0))
	for index: int in range(definition.platform_positions.size()):
		var width: int = definition.platform_widths[index]
		if not PLATFORM_TEXTURES.has(width):
			push_error("Unsupported Chapter III formal platform width: %d" % width)
			continue
		var platform: StaticBody2D = StaticBody2D.new()
		platform.name = "CombatPlatform%02d" % (index + 1)
		platform.collision_layer = 1
		var visual: Sprite2D = Sprite2D.new()
		visual.name = "Visual"
		visual.texture = PLATFORM_TEXTURES[width]
		visual.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		visual.position = definition.platform_positions[index] + Vector2(0.0, 12.0)
		visual.z_index = Chapter03LayerContract.PLATFORMS
		platform.add_child(visual)
		var shape_node: CollisionShape2D = CollisionShape2D.new()
		shape_node.name = "CollisionShape2D"
		shape_node.position = definition.platform_positions[index]
		var shape: RectangleShape2D = RectangleShape2D.new()
		shape.size = Vector2(width, 24.0)
		shape_node.shape = shape
		platform.add_child(shape_node)
		geometry.add_child(platform)


func _build_door() -> void:
	var doors: Node2D = Node2D.new()
	doors.name = "Doors"
	add_child(doors)
	var door: Chapter03RoomDoor = Chapter03RoomDoor.new()
	door.name = "EastExitDoor"
	door.position = Vector2(room_size.x - 124, 380.0)
	door.collision_layer = 0
	door.collision_mask = 2
	door.destination_room_id = definition.next_room_id
	door.destination_spawn_id = definition.next_spawn_id
	var presentation: Node2D = Node2D.new()
	presentation.name = "Presentation"
	presentation.z_index = Chapter03LayerContract.PROPS_BEHIND_ACTORS
	var visual: Sprite2D = Sprite2D.new()
	visual.name = "DoorVisual"
	visual.texture = definition.door_texture
	visual.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	presentation.add_child(visual)
	door.add_child(presentation)
	var blocker: StaticBody2D = StaticBody2D.new()
	blocker.name = "Blocker"
	blocker.collision_layer = 1
	var blocker_shape: CollisionShape2D = CollisionShape2D.new()
	blocker_shape.name = "CollisionShape2D"
	blocker_shape.position = Vector2(0.0, 66.0)
	var blocker_rectangle: RectangleShape2D = RectangleShape2D.new()
	blocker_rectangle.size = Vector2(64.0, 340.0)
	blocker_shape.shape = blocker_rectangle
	blocker.add_child(blocker_shape)
	door.add_child(blocker)
	var interaction_shape: CollisionShape2D = CollisionShape2D.new()
	interaction_shape.name = "CollisionShape2D"
	interaction_shape.position = Vector2(-56.0, 66.0)
	var interaction_rectangle: RectangleShape2D = RectangleShape2D.new()
	interaction_rectangle.size = Vector2(220.0, 360.0)
	interaction_shape.shape = interaction_rectangle
	door.add_child(interaction_shape)
	var interaction: Node2D = Node2D.new()
	interaction.name = "Interaction"
	interaction.z_index = Chapter03LayerContract.INTERACTABLES
	var prompt: Label = Label.new()
	prompt.name = "Prompt"
	prompt.position = Vector2(-126.0, -118.0)
	prompt.text = definition.door_prompt
	prompt.add_theme_color_override("font_color", Color(0.82, 0.75, 0.55, 1.0))
	prompt.add_theme_font_size_override("font_size", 12)
	interaction.add_child(prompt)
	door.add_child(interaction)
	doors.add_child(door)


func _build_spawn_points() -> void:
	var points: Node2D = Node2D.new()
	points.name = "SpawnPoints"
	add_child(points)
	var entry: Marker2D = Marker2D.new()
	entry.name = "EntryWest"
	entry.position = Vector2(128.0, 584.0)
	points.add_child(entry)
	var inspection: Marker2D = Marker2D.new()
	inspection.name = "Inspection"
	inspection.position = Vector2(room_size.x * 0.46, 584.0)
	points.add_child(inspection)
	spawn_points = points


func _build_encounters() -> void:
	encounter_spawner = Chapter03EncounterSpawner.new()
	encounter_spawner.name = "EncounterSpawner"
	encounter_spawner.manifest = definition.manifest
	add_child(encounter_spawner)


func _add_static_rectangle(parent: Node2D, body_name: String, position: Vector2, size: Vector2) -> void:
	var body: StaticBody2D = StaticBody2D.new()
	body.name = body_name
	body.collision_layer = 1
	var collision: CollisionShape2D = CollisionShape2D.new()
	collision.name = "CollisionShape2D"
	collision.position = position
	var rectangle: RectangleShape2D = RectangleShape2D.new()
	rectangle.size = size
	collision.shape = rectangle
	body.add_child(collision)
	parent.add_child(body)
