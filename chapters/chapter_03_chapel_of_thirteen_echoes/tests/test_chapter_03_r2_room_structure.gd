extends SceneTree

const ROOT := "res://chapters/chapter_03_chapel_of_thirteen_echoes"
const ROOM_PATHS: Array[String] = [
	ROOT + "/scenes/rooms/ch3_chapel_vestibule.tscn",
	ROOT + "/scenes/rooms/ch3_nave_entry.tscn",
	ROOT + "/scenes/rooms/ch3_choir_gallery.tscn",
	ROOT + "/scenes/rooms/ch3_boss_checkpoint.tscn",
	ROOT + "/scenes/rooms/ch3_boss_ante_room.tscn",
	ROOT + "/scenes/rooms/ch3_boss_sanctum_room.tscn",
	ROOT + "/scenes/rooms/ch3_post_boss_room.tscn",
	ROOT + "/scenes/rooms/ch3_underkeep_room.tscn",
]


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	for path: String in ROOM_PATHS:
		var packed: PackedScene = load(path) as PackedScene
		_assert(packed != null, "room loads: %s" % path)
		var room: Chapter03Room = packed.instantiate() as Chapter03Room
		_assert(room != null, "room root is Chapter03Room: %s" % path)
		root.add_child(room)
		await process_frame
		_assert(not room.room_id.is_empty(), "room id is explicit: %s" % path)
		_assert(room.get_spawn(room.default_spawn_id) != null, "room has default spawn: %s" % path)
		room.queue_free()
		await process_frame

	var profile_text: String = FileAccess.get_file_as_string(
		ROOT + "/resources/chapter/chapter_03_start_profile.tres"
	)
	_assert(profile_text.contains("chapter_03_route.tscn"), "start profile targets the formal route")
	_assert(not profile_text.contains("chapter_03_entry_placeholder.tscn"), "start profile excludes legacy canvas")

	var route_packed: PackedScene = load(ROOT + "/scenes/level/chapter_03_route.tscn") as PackedScene
	var route: Chapter03Route = route_packed.instantiate() as Chapter03Route
	root.add_child(route)
	await process_frame
	await physics_frame
	var controller: Chapter03RoomTransitionController = route.get_node(
		"RoomTransitionController"
	) as Chapter03RoomTransitionController
	var player: Player = route.get_node("PersistentRuntime/ChapterRuntime/Player") as Player
	_assert(controller.active_room_id == &"CH3_CHAPEL_VESTIBULE", "route starts in formal vestibule")
	_assert(route.get_node("RoomHost").get_child_count() == 1, "only one room is active")
	var player_id: int = player.get_instance_id()
	for room_id: StringName in [
		&"CH3_NAVE_ENTRY", &"CH3_CHOIR_GALLERY", &"CH3_BOSS_CHECKPOINT", &"CH3_BOSS_ANTE"
	]:
		_assert(controller.request_room_change(room_id, &"EntryWest"), "transition accepted: %s" % room_id)
		await create_timer(0.55).timeout
		_assert(controller.active_room_id == room_id, "transition completed: %s" % room_id)
		_assert(route.get_node("RoomHost").get_child_count() == 1, "single RoomHost child: %s" % room_id)
		_assert(player.get_instance_id() == player_id, "Player persists: %s" % room_id)

	var nave: PackedScene = load(ROOT + "/scenes/rooms/ch3_nave_entry.tscn") as PackedScene
	var nave_room: Node = nave.instantiate()
	_assert(nave_room.has_node("Geometry/WestSideGallery"), "nave has west playable platform")
	_assert(nave_room.has_node("Geometry/EastAccessCorbel"), "nave has ordinary-jump access corbel")
	_assert(
		is_equal_approx(
			(nave_room.get_node("Geometry/WestSideGallery/CollisionShape2D") as CollisionShape2D).position.y,
			564.0
		),
		"nave first platform surface is 60 px above the 612 px floor"
	)
	var choir: PackedScene = load(ROOT + "/scenes/rooms/ch3_choir_gallery.tscn") as PackedScene
	var choir_room: Node = choir.instantiate()
	_assert(choir_room.has_node("OrganPipesFar"), "organ far layer is separate")
	_assert(choir_room.has_node("OrganCaseBehind"), "organ case layer is separate")
	_assert(choir_room.has_node("Geometry/OrganMaintenanceDeck"), "choir platform route exists")
	_assert(
		is_equal_approx(
			(choir_room.get_node("Geometry/OrganAccessCorbel/CollisionShape2D") as CollisionShape2D).position.y,
			504.0
		),
		"choir access corbel preserves the planned 60 px rise"
	)
	nave_room.free()
	choir_room.free()
	print("CH3_R2_ROOM_STRUCTURE PASS rooms=8 swaps=4 persistent_player=1")
	quit()


func _assert(condition: bool, message: String) -> void:
	if condition:
		return
	push_error("CH3_R2_ROOM_STRUCTURE FAIL: %s" % message)
	quit(1)
