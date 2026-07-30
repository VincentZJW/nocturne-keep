class_name Chapter03RoomDefinition
extends Resource

## Formal visual, traversal and encounter configuration for one Chapter III combat room.

@export var room_id: StringName = &""
@export var bilingual_name: String = ""
@export var room_size: Vector2i = Vector2i(2304, 720)
@export var next_room_id: StringName = &""
@export var next_spawn_id: StringName = &"EntryWest"
@export var door_prompt: String = "E  CONTINUE / 继续"
@export var backdrop_texture: Texture2D
@export var door_texture: Texture2D
@export var prop_textures: Array[Texture2D] = []
@export var prop_positions: Array[Vector2] = []
@export var prop_z_indices: Array[int] = []
@export var platform_positions: Array[Vector2] = []
@export var platform_widths: Array[int] = []
@export var manifest: Chapter03EncounterManifest


func is_valid() -> bool:
	return (
		not room_id.is_empty()
		and not next_room_id.is_empty()
		and backdrop_texture != null
		and door_texture != null
		and manifest != null
		and prop_textures.size() == prop_positions.size()
		and prop_positions.size() == prop_z_indices.size()
		and platform_positions.size() == platform_widths.size()
	)
