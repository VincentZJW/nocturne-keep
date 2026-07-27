class_name SilentCourtLevel
extends Node2D

const CHAPTER_WIDTH: int = 7168
const DEFAULT_SPAWN_ID: StringName = &"CH2_START"

@onready var player: Player = $GameplayWorld/PlayerAnchorOrRuntimeActors/ChapterRuntime/Player as Player
@onready var respawn_controller: PlayerRespawnController = (
	$GameplayWorld/PlayerAnchorOrRuntimeActors/ChapterRuntime/PlayerRespawnController as PlayerRespawnController
)
@onready var spawn_points: Node2D = $PlayerSpawnPoints as Node2D
@onready var room_name_label: Label = (
	$GameplayWorld/PlayerAnchorOrRuntimeActors/ChapterRuntime/HUD/RoomName as Label
)


func _ready() -> void:
	player.z_index = 12
	player.z_as_relative = false
	_connect_camera_bounds()
	_apply_debug_start_profile()


func get_spawn_marker(spawn_id: StringName) -> Marker2D:
	return spawn_points.get_node_or_null(NodePath(String(spawn_id))) as Marker2D


func _apply_debug_start_profile() -> void:
	var config: DebugRunConfigState = get_node_or_null("/root/DebugRunConfig") as DebugRunConfigState
	var spawn_id: StringName = DEFAULT_SPAWN_ID
	if (
		config != null and config.is_chapter_start_allowed()
		and config.debug_start_chapter_id == ChapterRegistry.CHAPTER_02_SILENT_COURT
	):
		spawn_id = config.debug_start_spawn_id
		if config.debug_reset_chapter_state_on_run:
			_reset_disposable_debug_state(config)
	var marker: Marker2D = get_spawn_marker(spawn_id)
	if marker == null:
		push_warning("Unknown Chapter II spawn '%s'; using CH2_START" % spawn_id)
		marker = get_spawn_marker(DEFAULT_SPAWN_ID)
	if marker == null:
		push_error("SilentCourt requires CH2_START")
		return
	player.global_position = marker.global_position
	player.velocity = Vector2.ZERO
	respawn_controller.set_spawn_point(marker)
	var floor_limits: Vector2i = _floor_limits_for_y(marker.global_position.y)
	_configure_camera_for_floor(marker.global_position.y, floor_limits)


func _reset_disposable_debug_state(config: DebugRunConfigState) -> void:
	var wallet: CurrencyWallet = get_node_or_null("/root/CurrencyManager") as CurrencyWallet
	var equipment: PlayerEquipmentManager = get_node_or_null("/root/EquipmentManager") as PlayerEquipmentManager
	if wallet != null:
		wallet.reset_for_new_run()
		if config.debug_use_test_currency:
			wallet.add_coins(config.debug_test_currency)
	if equipment != null:
		equipment.reset_for_new_run()
		equipment.acquire_and_equip(&"ravenfang_daggers")
	if config.debug_start_full_health:
		player.health_component.reset_to_full()
	player.stamina_component.reset_to_full()


func _connect_camera_bounds() -> void:
	for child: Node in $GameplayWorld/Geometry/Rooms.get_children():
		var bounds: Chapter02CameraBounds = child.get_node_or_null("CameraBounds") as Chapter02CameraBounds
		if bounds != null:
			bounds.player_entered.connect(_on_room_entered)


func _on_room_entered(room_id: StringName, limits: Vector2i) -> void:
	_configure_camera_for_floor(player.global_position.y, limits)
	room_name_label.text = "CHAPTER II  ·  %s" % String(room_id).replace("_", " ")


func _configure_camera(
	left_limit: int,
	right_limit: int,
	top_limit: int,
	bottom_limit: int
) -> void:
	if player.player_camera == null:
		return
	player.player_camera.limit_left = left_limit
	player.player_camera.limit_right = right_limit
	player.player_camera.limit_top = top_limit
	player.player_camera.limit_bottom = bottom_limit
	player.player_camera.reset_smoothing()


func configure_camera_for_world_y(world_y: float) -> void:
	var floor_limits: Vector2i = _floor_limits_for_y(world_y)
	_configure_camera_for_floor(world_y, floor_limits)


func _configure_camera_for_floor(world_y: float, vertical_limits: Vector2i) -> void:
	var horizontal_limits: Vector2i = _floor_horizontal_limits_for_y(world_y)
	_configure_camera(
		horizontal_limits.x,
		horizontal_limits.y,
		vertical_limits.x,
		vertical_limits.y
	)


func _floor_horizontal_limits_for_y(world_y: float) -> Vector2i:
	if world_y < -850.0:
		return Vector2i(0, CHAPTER_WIDTH)
	if world_y < 50.0:
		return Vector2i(64, CHAPTER_WIDTH)
	return Vector2i(0, 7040)


func _floor_limits_for_y(world_y: float) -> Vector2i:
	if world_y < -850.0:
		return Vector2i(-1800, -1080)
	if world_y < 50.0:
		return Vector2i(-900, -180)
	return Vector2i(0, 720)
