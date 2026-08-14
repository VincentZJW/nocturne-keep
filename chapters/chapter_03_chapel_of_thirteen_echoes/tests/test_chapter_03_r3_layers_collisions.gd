extends SceneTree

const ROOT := "res://chapters/chapter_03_chapel_of_thirteen_echoes"
const GRID_ASSET_PATHS: Array[String] = [
	ROOT + "/assets/environment/r3_grid_aligned/boss_choir_stalls_304x112.png",
	ROOT + "/assets/environment/r3_grid_aligned/boss_pipe_organ_472x344.png",
	ROOT + "/assets/environment/r3_grid_aligned/rusted_gate_232x264.png",
	ROOT + "/assets/environment/r3_grid_aligned/rusted_gate_264x296.png",
	ROOT + "/assets/environment/r3_grid_aligned/wet_arch_232x304.png",
	ROOT + "/assets/environment/r3_grid_aligned/wet_arch_256x336.png",
	ROOT + "/assets/props/r3_grid_aligned/bell_saint_left_120x240.png",
]


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	for asset_path: String in GRID_ASSET_PATHS:
		_assert(ResourceLoader.exists(asset_path, "Texture2D"), "grid asset imports: %s" % asset_path)

	var route_packed: PackedScene = load(ROOT + "/scenes/level/chapter_03_route.tscn") as PackedScene
	var route: Chapter03Route = route_packed.instantiate() as Chapter03Route
	root.add_child(route)
	await process_frame
	await physics_frame
	var controller: Chapter03RoomTransitionController = route.get_node("RoomTransitionController")
	var player: Player = route.get_node("PersistentRuntime/ChapterRuntime/Player") as Player
	_assert(player.z_index == Chapter03LayerContract.PLAYER, "persistent Player uses actor z=12")
	_assert(route.has_node("PersistentRuntime/ChapterRuntime/HUD"), "HUD remains in runtime CanvasLayer")
	_assert(controller.active_room_id == &"CH3_CHAPEL_VESTIBULE", "Main route starts in formal vestibule")
	var vestibule: Chapter03Room = controller.active_room
	_assert((vestibule.get_node("Backdrop") as CanvasItem).z_index == -100, "vestibule far backdrop z=-100")
	_assert((vestibule.get_node("Doors/NaveDoor") as CanvasItem).z_index == 0, "door authority does not lift its complete presentation")
	_assert((vestibule.get_node("Doors/NaveDoor/Presentation") as CanvasItem).z_index == Chapter03LayerContract.PROPS_BEHIND_ACTORS, "door panel stays behind actors")
	_assert((vestibule.get_node("Doors/NaveDoor/Interaction") as CanvasItem).z_index == Chapter03LayerContract.INTERACTABLES, "door prompt retains interactable z=14")
	for index: int in range(8):
		var shape_path := "Geometry/Step%02d/CollisionShape2D" % (index + 1)
		var shape_node: CollisionShape2D = vestibule.get_node(shape_path) as CollisionShape2D
		var rectangle: RectangleShape2D = shape_node.shape as RectangleShape2D
		var expected_top: float = 612.0 + float(index * 10)
		var collision_top: float = shape_node.position.y - rectangle.size.y * 0.5
		_assert(is_equal_approx(collision_top, expected_top), "stair %02d visible/collision top aligns" % (index + 1))
	_assert((vestibule.get_node("Doors/NaveExit") as Area2D).position.y == 640.0, "stair exit spans final courses")
	var nave_door: Chapter03RoomDoor = vestibule.get_node("Doors/NaveDoor") as Chapter03RoomDoor
	nave_door._open()
	await create_timer(0.35).timeout
	await physics_frame
	_assert(nave_door.blocker_shape.disabled, "opened nave door disables its visible blocker")

	_assert(controller.request_room_change(&"CH3_NAVE_ENTRY", &"EntryWest"), "nave transition accepted")
	await create_timer(0.55).timeout
	var nave: Chapter03Room = controller.active_room
	_assert((nave.get_node("Backdrop") as CanvasItem).z_index == -100, "nave far backdrop z=-100")
	_assert_platform_alignment(nave, "Geometry/WestSideGallery")
	_assert_platform_alignment(nave, "Geometry/EastSideGallery")
	_assert_platform_alignment(nave, "Geometry/EastAccessCorbel")
	_assert_platform_alignment(nave, "Geometry/UpperArchiveLedge")
	_assert_enemy_layers(nave)
	_assert_integer_node2d_transforms(nave)

	_assert(controller.request_room_change(&"CH3_CHOIR_GALLERY", &"EntryWest"), "choir transition accepted")
	await create_timer(0.55).timeout
	var choir: Chapter03Room = controller.active_room
	_assert((choir.get_node("OrganPipesFar") as CanvasItem).z_index == -100, "organ pipes stay in far background")
	_assert((choir.get_node("OrganCaseBehind") as CanvasItem).z_index == -60, "organ case stays behind actors")
	_assert(not choir.get_node("OrganPipesFar").has_node("CollisionShape2D"), "organ pipes do not create an air wall")
	_assert(not choir.get_node("OrganCaseBehind").has_node("CollisionShape2D"), "organ case does not create an air wall")
	_assert_platform_alignment(choir, "Geometry/WestChoirSeatPlatform")
	_assert_platform_alignment(choir, "Geometry/EastChoirSeatPlatform")
	_assert_platform_alignment(choir, "Geometry/OrganAccessCorbel")
	_assert_platform_alignment(choir, "Geometry/OrganMaintenanceDeck")
	_assert_enemy_layers(choir)
	_assert_integer_node2d_transforms(choir)

	var gate_packed: PackedScene = load(ROOT + "/scenes/areas/ch3_boss_gate_transition.tscn") as PackedScene
	var gate: Chapter03BossGate = gate_packed.instantiate() as Chapter03BossGate
	root.add_child(gate)
	await process_frame
	gate.open_immediately()
	await physics_frame
	_assert(gate.blocker.disabled, "open Boss gate disables the matching blocker")
	gate.queue_free()

	var post_packed: PackedScene = load(ROOT + "/scenes/areas/ch3_post_boss_reliquary.tscn") as PackedScene
	var post: Chapter03PostBossReliquary = post_packed.instantiate() as Chapter03PostBossReliquary
	root.add_child(post)
	await process_frame
	post.notify_reward_collected()
	await physics_frame
	_assert(post.descent_blocker.disabled, "open reliquary descent disables the matching blocker")
	_assert_integer_node2d_transforms(post)
	post.queue_free()

	var sanctum_packed: PackedScene = load(ROOT + "/scenes/areas/ch3_boss_sanctum.tscn") as PackedScene
	var sanctum: Node2D = sanctum_packed.instantiate() as Node2D
	_assert_integer_node2d_transforms(sanctum)
	_assert((sanctum.get_node("Backdrop") as CanvasItem).z_index == -100, "Boss backdrop z=-100")
	_assert((sanctum.get_node("Presentation/RitualFloor") as CanvasItem).z_index == -10, "Boss ground art z=-10")
	sanctum.free()

	print("CH3_R3_LAYERS_COLLISIONS PASS stairs=8 platforms=8 doors=3 actor_z=10/12")
	quit()


func _assert_platform_alignment(room: Node, platform_path: String) -> void:
	var visual: Sprite2D = room.get_node(platform_path + "/Visual") as Sprite2D
	var collision: CollisionShape2D = room.get_node(platform_path + "/CollisionShape2D") as CollisionShape2D
	var rectangle: RectangleShape2D = collision.shape as RectangleShape2D
	var visual_top: float = visual.position.y - float(visual.texture.get_height()) * absf(visual.scale.y) * 0.5
	var collision_top: float = collision.position.y - rectangle.size.y * 0.5
	_assert(is_equal_approx(visual_top, collision_top), "%s visible/collision surface aligns" % platform_path)


func _assert_enemy_layers(room: Node) -> void:
	var enemies: Node = room.get_node_or_null("Enemies")
	if enemies == null:
		return
	for child: Node in enemies.get_children():
		var canvas: CanvasItem = child as CanvasItem
		_assert(canvas != null and canvas.z_index == Chapter03LayerContract.ENEMIES, "%s uses enemy z=10" % child.name)


func _assert_integer_node2d_transforms(node: Node) -> void:
	var node_2d: Node2D = node as Node2D
	if node_2d != null:
		if node_2d is CharacterBody2D:
			return
		var node_label: String = String(node_2d.name)
		_assert(is_equal_approx(node_2d.position.x, roundf(node_2d.position.x)), "%s x is pixel aligned" % node_label)
		_assert(is_equal_approx(node_2d.position.y, roundf(node_2d.position.y)), "%s y is pixel aligned" % node_label)
		_assert(is_equal_approx(absf(node_2d.scale.x), 1.0), "%s x scale is integer-grid safe" % node_label)
		_assert(is_equal_approx(absf(node_2d.scale.y), 1.0), "%s y scale is integer-grid safe" % node_label)
		_assert(is_zero_approx(node_2d.rotation), "%s rotation preserves pixel grid" % node_label)
	for child: Node in node.get_children():
		_assert_integer_node2d_transforms(child)


func _assert(condition: bool, message: String) -> void:
	if condition:
		return
	push_error("CH3_R3_LAYERS_COLLISIONS FAIL: %s" % message)
	quit(1)
