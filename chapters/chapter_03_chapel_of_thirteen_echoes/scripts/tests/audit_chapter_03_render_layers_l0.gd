extends SceneTree

const BOOTSTRAP_PATH: String = "res://scenes/bootstrap/main_bootstrap.tscn"
const CHAPTER_ROOT: String = "res://chapters/chapter_03_chapel_of_thirteen_echoes"
const QA_DIRECTORY: String = "res://docs/qa/chapter_03_render_layer_l0"
const AUDIT_PATH: String = QA_DIRECTORY + "/runtime_layer_audit.tsv"
const INVENTORY_PATH: String = QA_DIRECTORY + "/scene_inventory.tsv"
const ANOMALY_PATH: String = QA_DIRECTORY + "/anomaly_inventory.tsv"

const ROOM_IDS: Array[StringName] = [
	&"CH3_CHAPEL_VESTIBULE",
	&"CH3_NAVE_ENTRY",
	&"CH3_CHOIR_GALLERY",
	&"CH3_BOSS_CHECKPOINT",
	&"CH3_BOSS_ANTE",
	&"CH3_BOSS",
	&"CH3_POST_BOSS",
	&"CH3_UNDERKEEP_DESCENT",
]

const FORMAL_ROOM_PATHS: Dictionary[StringName, String] = {
	&"CH3_CHAPEL_VESTIBULE": CHAPTER_ROOT + "/scenes/rooms/ch3_chapel_vestibule.tscn",
	&"CH3_NAVE_ENTRY": CHAPTER_ROOT + "/scenes/rooms/ch3_nave_entry.tscn",
	&"CH3_CHOIR_GALLERY": CHAPTER_ROOT + "/scenes/rooms/ch3_choir_gallery.tscn",
	&"CH3_BOSS_CHECKPOINT": CHAPTER_ROOT + "/scenes/rooms/ch3_boss_checkpoint.tscn",
	&"CH3_BOSS_ANTE": CHAPTER_ROOT + "/scenes/rooms/ch3_boss_ante_room.tscn",
	&"CH3_BOSS": CHAPTER_ROOT + "/scenes/rooms/ch3_boss_sanctum_room.tscn",
	&"CH3_POST_BOSS": CHAPTER_ROOT + "/scenes/rooms/ch3_post_boss_room.tscn",
	&"CH3_UNDERKEEP_DESCENT": CHAPTER_ROOT + "/scenes/rooms/ch3_underkeep_room.tscn",
}

var _runtime_rows: PackedStringArray = PackedStringArray()
var _anomaly_rows: PackedStringArray = PackedStringArray()
var _canvas_item_count: int = 0
var _unknown_visible_count: int = 0
var _door_count: int = 0
var _foreground_count: int = 0
var _actor_container_count: int = 0
var _y_sort_count: int = 0
var _drawable_count: int = 0
var _persistent_audited: bool = false


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(QA_DIRECTORY))
	_write_scene_inventory()
	var config: DebugRunConfigState = root.get_node_or_null("DebugRunConfig") as DebugRunConfigState
	if config == null:
		push_error("Chapter III L0 audit requires DebugRunConfig")
		quit(1)
		return
	config.debug_chapter_start_enabled = true
	config.debug_start_chapter_id = ChapterRegistry.CHAPTER_03_CHAPEL_OF_THIRTEEN_ECHOES
	config.debug_start_spawn_id = &"chapter_03_start"
	var scene_error: Error = change_scene_to_file(BOOTSTRAP_PATH)
	if scene_error != OK:
		push_error("Unable to start MainBootstrap: %s" % error_string(scene_error))
		config.reset_to_defaults()
		quit(1)
		return
	var route: Chapter03Route = await _wait_for_route()
	if route == null:
		push_error("MainBootstrap did not resolve Chapter03Route")
		config.reset_to_defaults()
		quit(1)
		return
	var controller: Chapter03RoomTransitionController = route.transition_controller
	_runtime_rows.append(
		"room_id\tscene\tnode_path\ttype\tparent\tlocal_z\teffective_z\t"
		+ "z_as_relative\ty_sort_enabled\tcanvas_layer\tvisible\tdraws_content\tglobal_position\tclassification\tscript"
	)
	_anomaly_rows.append(
		"anomaly_id\troom_id\tscene\tnode_path\ttype\tlocal_z\teffective_z\t"
		+ "classification\truntime_result\tproposed_l1_repair"
	)
	for room_id: StringName in ROOM_IDS:
		if controller.active_room_id != room_id:
			var did_swap: bool = controller._swap_room(room_id, &"EntryWest")
			if not did_swap:
				push_error("Unable to load room for L0 audit: %s" % room_id)
				config.reset_to_defaults()
				quit(1)
				return
			await process_frame
			await physics_frame
		_audit_runtime_room(route, controller, room_id)
	_write_lines(AUDIT_PATH, _runtime_rows)
	_write_lines(ANOMALY_PATH, _anomaly_rows)
	config.reset_to_defaults()
	print(
		(
			"CH3_LAYER_L0_AUDIT PASS rooms=%d canvas_items=%d anomalies=%d unknown_visible=%d "
			+ "drawable=%d doors=%d foreground=%d actor_containers=%d y_sort=%d main_bootstrap=true"
		)
		% [
			ROOM_IDS.size(),
			_canvas_item_count,
			maxi(_anomaly_rows.size() - 1, 0),
			_unknown_visible_count,
			_drawable_count,
			_door_count,
			_foreground_count,
			_actor_container_count,
			_y_sort_count,
		]
	)
	quit(0)


func _wait_for_route() -> Chapter03Route:
	for _frame: int in range(360):
		await process_frame
		var route: Chapter03Route = current_scene as Chapter03Route
		if route != null:
			return route
	return null


func _audit_runtime_room(
	route: Chapter03Route,
	controller: Chapter03RoomTransitionController,
	room_id: StringName
) -> void:
	var room: Chapter03Room = controller.active_room
	var room_scene: String = FORMAL_ROOM_PATHS.get(room_id, room.scene_file_path)
	var player: Player = controller.player
	var player_effective_z: int = _effective_z(player)
	if not _persistent_audited:
		var persistent_runtime: Node = route.get_node_or_null("PersistentRuntime")
		if persistent_runtime != null:
			_audit_node_recursive(
				persistent_runtime,
				route,
				&"PERSISTENT_RUNTIME",
				"res://scenes/runtime/chapter_gameplay_runtime.tscn",
				player_effective_z
			)
		_persistent_audited = true
	_audit_node_recursive(room, route, room_id, room_scene, player_effective_z)


func _audit_node_recursive(
	node: Node,
	route: Chapter03Route,
	room_id: StringName,
	room_scene: String,
	player_effective_z: int
) -> void:
	if node is CanvasItem:
		var item: CanvasItem = node as CanvasItem
		var classification: String = _classify_item(item)
		var effective_z: int = _effective_z(item)
		var canvas_layer: int = _canvas_layer(item)
		var draws_content: bool = _draws_content(item)
		var script_path: String = _script_path(node)
		if script_path.is_empty():
			script_path = "-"
		var global_position: Vector2 = Vector2.ZERO
		if item is Node2D:
			global_position = (item as Node2D).global_position
		var is_visible: bool = item.is_visible_in_tree()
		_runtime_rows.append(
			"%s\t%s\t%s\t%s\t%s\t%d\t%d\t%s\t%s\t%d\t%s\t%s\t%s\t%s\t%s"
			% [
				String(room_id),
				room_scene,
				String(route.get_path_to(node)),
				node.get_class(),
				String(route.get_path_to(node.get_parent())) if node.get_parent() != null else "",
				item.z_index,
				effective_z,
				str(item.z_as_relative),
				str(item.y_sort_enabled),
				canvas_layer,
				str(is_visible),
				str(draws_content),
				"%.1f,%.1f" % [global_position.x, global_position.y],
				classification,
				script_path,
			]
		)
		_canvas_item_count += 1
		if draws_content:
			_drawable_count += 1
		if classification == "Unknown" and is_visible and draws_content:
			_unknown_visible_count += 1
		if classification == "Door":
			_door_count += 1
		if classification == "LimitedForeground":
			_foreground_count += 1
		if classification == "ActorContainer":
			_actor_container_count += 1
		if item.y_sort_enabled:
			_y_sort_count += 1
		_detect_anomaly(
			room_id,
			room_scene,
			item,
			classification,
			effective_z,
			player_effective_z,
			is_visible,
			draws_content
		)
	for child: Node in node.get_children():
		_audit_node_recursive(child, route, room_id, room_scene, player_effective_z)


func _detect_anomaly(
	room_id: StringName,
	room_scene: String,
	item: CanvasItem,
	classification: String,
	effective_z: int,
	player_effective_z: int,
	is_visible: bool,
	draws_content: bool
) -> void:
	if not is_visible or not draws_content or _canvas_layer(item) != 0:
		return
	var path_text: String = String(item.get_path())
	if classification in ["FarBackground", "BackgroundArchitecture", "PropsBehind", "Ground", "Platform"]:
		if effective_z >= player_effective_z:
			_append_anomaly(
				"BACKGROUND_OVER_ACTOR",
				room_id,
				room_scene,
				item,
				classification,
				effective_z,
				"visible background/ground content resolves at or above Player z=%d" % player_effective_z,
				"move the visual to the matching fixed contract layer; retain collision separately"
			)
	if classification == "Door" and effective_z >= player_effective_z:
		var door_visual_name: String = String(item.name).to_lower()
		if door_visual_name not in ["doorvisual", "gateclosed", "gateopen"]:
			return
		_append_anomaly(
			"DOOR_ROOT_OVER_ACTOR",
			room_id,
			room_scene,
			item,
			classification,
			effective_z,
			"door/gate content resolves above Player z=%d as one unsplit hierarchy" % player_effective_z,
			"split rear frame/panels/hardware/core/trim; keep large visuals behind actors"
		)
	if classification == "LimitedForeground" and effective_z > Chapter03LayerContract.LIMITED_FOREGROUND:
		_append_anomaly(
			"FOREGROUND_OUT_OF_CONTRACT",
			room_id,
			room_scene,
			item,
			classification,
			effective_z,
			"limited foreground exceeds the approved z band",
			"normalize to z=20 and verify only 0-4 px foot occlusion"
		)
	if classification == "UI" and _canvas_layer(item) == 0:
		_append_anomaly(
			"WORLD_SPACE_UI",
			room_id,
			room_scene,
			item,
			classification,
			effective_z,
			"visible label/panel participates in world z sorting instead of a CanvasLayer",
			"move persistent information to HUD CanvasLayer; keep intentionally world-bound prompts narrowly scoped"
		)
	if item.y_sort_enabled:
		_append_anomaly(
			"Y_SORT_ENABLED",
			room_id,
			room_scene,
			item,
			classification,
			effective_z,
			"runtime y_sort_enabled=true at %s" % path_text,
			"justify actor-only use or disable it for fixed architecture"
		)


func _append_anomaly(
	anomaly_id: String,
	room_id: StringName,
	room_scene: String,
	item: CanvasItem,
	classification: String,
	effective_z: int,
	runtime_result: String,
	proposed_repair: String
) -> void:
	_anomaly_rows.append(
		"%s\t%s\t%s\t%s\t%s\t%d\t%d\t%s\t%s\t%s"
		% [
			anomaly_id,
			String(room_id),
			room_scene,
			String(item.get_path()),
			item.get_class(),
			item.z_index,
			effective_z,
			classification,
			runtime_result,
			proposed_repair,
		]
	)


func _effective_z(item: CanvasItem) -> int:
	var result: int = item.z_index
	if not item.z_as_relative:
		return result
	var ancestor: Node = item.get_parent()
	while ancestor != null:
		if ancestor is CanvasLayer:
			break
		if ancestor is CanvasItem:
			var ancestor_item: CanvasItem = ancestor as CanvasItem
			result += ancestor_item.z_index
			if not ancestor_item.z_as_relative:
				break
		ancestor = ancestor.get_parent()
	return result


func _canvas_layer(item: CanvasItem) -> int:
	var ancestor: Node = item.get_parent()
	while ancestor != null:
		if ancestor is CanvasLayer:
			return (ancestor as CanvasLayer).layer
		ancestor = ancestor.get_parent()
	return 0


func _classify_item(item: CanvasItem) -> String:
	if _canvas_layer(item) != 0:
		return "UI"
	var path_text: String = String(item.get_path()).to_lower()
	if item is Player or "/player" in path_text:
		return "Player"
	if item is EnemyCombatant or "/enemies/" in path_text:
		return "Enemy"
	var text: String = String(item.name).to_lower()
	if text in ["enemies", "actors", "actorcontainer", "persistentruntime", "chapterruntime"]:
		return "ActorContainer"
	if _contains_any(
		path_text,
		["areatitle", "sanctumtitle", "gatename", "checkpointstatus", "interactionprompt"]
	):
		return "UI"
	if _contains_any(path_text, ["projectile", "attackhitbox", "dashattack", "hitfx", "effect", "resonance"]):
		return "CombatFX"
	if _contains_any(path_text, ["foreground", "shallowwater", "trim"]):
		return "LimitedForeground"
	if _contains_any(path_text, ["door", "gate", "blocker", "seal", "checkpointarea", "interact", "prompt", "exit"]):
		return "Door"
	if _contains_any(path_text, ["floor", "ground", "ritualfloor", "stair"]):
		return "Ground"
	if _contains_any(path_text, ["platform", "ledge", "corbel", "deck", "step"]):
		return "Platform"
	if "sidegallery" in path_text:
		return "Platform"
	if _contains_any(path_text, ["backdrop", "background", "deep", "wall", "arch", "organ", "window", "architecture"]):
		return "BackgroundArchitecture"
	if _contains_any(
		path_text,
		[
			"bench", "seat", "lectern", "altar", "statue", "saint", "tablet", "reliquary",
			"candle", "censer", "registry", "emblem", "font", "ossuary", "stall",
			"checkpointvisual", "incense",
		]
	):
		return "PropsBehind"
	if item.z_index <= Chapter03LayerContract.FAR_BACKGROUND:
		return "FarBackground"
	return "Unknown"


func _draws_content(item: CanvasItem) -> bool:
	return item is Sprite2D \
		or item is AnimatedSprite2D \
		or item is Polygon2D \
		or item is Line2D \
		or item is TileMapLayer \
		or item is Label \
		or item is RichTextLabel \
		or item is ColorRect \
		or item is TextureRect \
		or item is NinePatchRect \
		or item is Panel \
		or item is PanelContainer \
		or item is ProgressBar \
		or item is TextureProgressBar \
		or item is CPUParticles2D \
		or item is GPUParticles2D


func _contains_any(text: String, needles: Array[String]) -> bool:
	for needle: String in needles:
		if needle in text:
			return true
	return false


func _script_path(node: Node) -> String:
	var script: Script = node.get_script() as Script
	return script.resource_path if script != null else ""


func _write_scene_inventory() -> void:
	var rows: PackedStringArray = PackedStringArray([
		"scene_file\tcategory\tmain_reachable\troom_id\tspawn_ids\tcontains_actor\tcontains_door\tcontains_foreground\taudit_status"
	])
	var scene_paths: Array[String] = []
	_collect_scene_paths(CHAPTER_ROOT, scene_paths)
	scene_paths.sort()
	for path: String in scene_paths:
		var text: String = FileAccess.get_file_as_string(path)
		var category: String = _scene_category(path)
		var room_id: String = _room_id_for_path(path)
		var main_reachable: bool = (
			path in FORMAL_ROOM_PATHS.values()
			or category == "FormalDependency"
			or category == "FormalRoute"
		)
		var spawn_ids: String = _spawn_ids_for_text(text)
		var lower_text: String = text.to_lower()
		rows.append(
			"%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s"
			% [
				path,
				category,
				str(main_reachable),
				room_id,
				spawn_ids,
				str(_contains_any(lower_text, ["player", "enemy", "enemies", "npc", "actor", "combatant"])),
				str(_contains_any(lower_text, ["door", "gate", "seal"])),
				str(_contains_any(lower_text, ["foreground", "shallowwater"])),
				"AUDITED" if main_reachable else "CATALOGUED",
			]
		)
	_write_lines(INVENTORY_PATH, rows)


func _collect_scene_paths(directory_path: String, output: Array[String]) -> void:
	var directory: DirAccess = DirAccess.open(directory_path)
	if directory == null:
		return
	directory.list_dir_begin()
	var entry: String = directory.get_next()
	while not entry.is_empty():
		if entry != "." and entry != "..":
			var child_path: String = directory_path.path_join(entry)
			if directory.current_is_dir():
				_collect_scene_paths(child_path, output)
			elif entry.get_extension() in ["tscn", "scn"]:
				output.append(child_path)
		entry = directory.get_next()
	directory.list_dir_end()


func _scene_category(path: String) -> String:
	if "/scenes/tests/" in path:
		return "Debug"
	if path.ends_with("chapter_03_entry_placeholder.tscn"):
		return "Retired"
	if "/scenes/rooms/" in path:
		return "FormalRoom"
	if "/scenes/areas/" in path or "/scenes/enemies/" in path or "/scenes/projectiles/" in path:
		return "FormalDependency"
	if path.ends_with("chapter_03_route.tscn"):
		return "FormalRoute"
	return "Unclassified"


func _room_id_for_path(path: String) -> String:
	for room_id: StringName in FORMAL_ROOM_PATHS:
		if FORMAL_ROOM_PATHS[room_id] == path:
			return String(room_id)
	return ""


func _spawn_ids_for_text(text: String) -> String:
	var ids: PackedStringArray = PackedStringArray()
	for line: String in text.split("\n"):
		var stripped: String = line.strip_edges()
		if stripped.begins_with("[node name=\"") and "parent=\"SpawnPoints\"" in stripped:
			var node_parts: PackedStringArray = stripped.split("\"")
			if node_parts.size() >= 2 and not ids.has(node_parts[1]):
				ids.append(node_parts[1])
	return ",".join(ids)


func _write_lines(path: String, lines: PackedStringArray) -> void:
	var file: FileAccess = FileAccess.open(path, FileAccess.WRITE)
	assert(file != null, "Unable to write L0 audit evidence: %s" % path)
	file.store_string("\n".join(lines) + "\n")
