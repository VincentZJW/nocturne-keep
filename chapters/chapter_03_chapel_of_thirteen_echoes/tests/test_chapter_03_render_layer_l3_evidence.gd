extends SceneTree

const EVIDENCE_ROOT: String = "res://docs/qa/chapter_03_render_layer_l2"
const SCREENSHOT_INDEX_PATH: String = EVIDENCE_ROOT + "/screenshot_index.tsv"
const RUNTIME_INDEX_PATH: String = EVIDENCE_ROOT + "/runtime_layer_samples.tsv"
const EXPECTED_CAPTURE_COUNT: int = 79
const EXPECTED_RUNTIME_SAMPLE_COUNT: int = 530
const EXPECTED_IMAGE_SIZE: Vector2i = Vector2i(1280, 720)

const REQUIRED_ROOMS: Array[String] = [
	"CH3_CHAPEL_VESTIBULE",
	"CH3_NAVE_ENTRY",
	"CH3_CHOIR_GALLERY",
	"CH3_BOSS_CHECKPOINT",
	"CH3_BOSS_ANTE",
	"CH3_BOSS",
	"CH3_POST_BOSS",
	"CH3_UNDERKEEP_DESCENT",
]

const REQUIRED_ACTIONS: Array[String] = [
	"idle",
	"run",
	"jump",
	"jump_apex",
	"fall",
	"ground_dash",
	"air_dash",
	"normal_attack",
	"dash_attack",
	"hurt",
	"death",
	"ghost_release",
	"respawn",
	"interact",
]

const REQUIRED_DOOR_STATES: Array[String] = [
	"closed",
	"lit",
	"25%",
	"50%",
	"100%",
	"fade",
]

const REQUIRED_CAPTURES: Array[String] = [
	"00_vestibule_runtime_collisions.png",
	"02_vestibule_v02_door_center.png",
	"08_vestibule_v08_attack.png",
	"30_checkpoint_c02_front.png",
	"36_checkpoint_death_body.png",
	"37_checkpoint_ghost_release.png",
	"46_ante_t04_lectern_front.png",
	"55a_gate_b08_open_25.png",
	"55b_gate_b09_open_50.png",
	"56_gate_b10_open_pass.png",
	"56a_gate_b11_fade.png",
	"57_boss_room_entry.png",
	"66_underkeep_water_attack.png",
	"67_underkeep_chapter4_boundary.png",
	"drop_coin_runtime_z13.png",
	"combat_fx_runtime_z16.png",
	"enemy_nave_bellchain_penitent.png",
	"enemy_nave_confessional_wraith.png",
	"enemy_nave_thirteenth_scribe.png",
	"enemy_choir_censer_executioner.png",
	"enemy_choir_silent_chorister.png",
	"enemy_choir_stained_glass_seraph.png",
]

var _failures: Array[String] = []


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	_assert_main_contract()
	_assert_screenshot_evidence()
	_assert_runtime_evidence()
	_finish()


func _assert_main_contract() -> void:
	var project_text: String = FileAccess.get_file_as_string("res://project.godot")
	_expect(
		project_text.contains("run/main_scene=\"uid://b7olunr0nd51q\"")
		or project_text.contains("res://scenes/bootstrap/main_bootstrap.tscn"),
		"project run/main_scene must remain MainBootstrap"
	)
	_expect(
		ResourceLoader.exists("res://scenes/bootstrap/main_bootstrap.tscn", "PackedScene"),
		"MainBootstrap PackedScene must exist"
	)


func _assert_screenshot_evidence() -> void:
	_expect(FileAccess.file_exists(SCREENSHOT_INDEX_PATH), "missing screenshot index")
	if not FileAccess.file_exists(SCREENSHOT_INDEX_PATH):
		return
	var lines: PackedStringArray = FileAccess.get_file_as_string(SCREENSHOT_INDEX_PATH).split("\n", false)
	_expect(lines.size() == EXPECTED_CAPTURE_COUNT + 1, "screenshot index must contain 79 data rows")
	var rooms: Dictionary[String, bool] = {}
	var actions: Dictionary[String, bool] = {}
	var door_states: Dictionary[String, bool] = {}
	var captures: Dictionary[String, bool] = {}
	var hashes: Dictionary[String, bool] = {}
	for line_index: int in range(1, lines.size()):
		var columns: PackedStringArray = lines[line_index].split("\t")
		_expect(columns.size() == 11, "invalid screenshot index row %d" % (line_index + 1))
		if columns.size() != 11:
			continue
		var capture_name: String = columns[0]
		var image_path: String = EVIDENCE_ROOT + "/" + capture_name
		captures[capture_name] = true
		rooms[columns[1]] = true
		actions[columns[7]] = true
		door_states[columns[8]] = true
		_expect(columns[6] == "true", "%s did not record Player as visible" % capture_name)
		_expect(columns[10] == "CAPTURED", "%s is not marked CAPTURED" % capture_name)
		_expect(FileAccess.file_exists(image_path), "missing indexed PNG: %s" % capture_name)
		if not FileAccess.file_exists(image_path):
			continue
		var image: Image = Image.new()
		var load_result: Error = image.load(image_path)
		_expect(load_result == OK, "cannot load indexed PNG: %s" % capture_name)
		if load_result == OK:
			_expect(image.get_size() == EXPECTED_IMAGE_SIZE, "%s is not 1280x720" % capture_name)
		var digest: String = FileAccess.get_sha256(image_path)
		_expect(not digest.is_empty(), "cannot hash indexed PNG: %s" % capture_name)
		_expect(not hashes.has(digest), "duplicate/stale PNG content: %s" % capture_name)
		hashes[digest] = true
	for room_id: String in REQUIRED_ROOMS:
		_expect(rooms.has(room_id), "missing formal room evidence: %s" % room_id)
	for action: String in REQUIRED_ACTIONS:
		_expect(actions.has(action), "missing Player action evidence: %s" % action)
	for door_state: String in REQUIRED_DOOR_STATES:
		_expect(door_states.has(door_state), "missing door-state evidence: %s" % door_state)
	for capture_name: String in REQUIRED_CAPTURES:
		_expect(captures.has(capture_name), "missing required capture row: %s" % capture_name)
	_expect(hashes.size() == EXPECTED_CAPTURE_COUNT, "all 79 indexed PNGs must have unique contents")


func _assert_runtime_evidence() -> void:
	_expect(FileAccess.file_exists(RUNTIME_INDEX_PATH), "missing runtime layer index")
	if not FileAccess.file_exists(RUNTIME_INDEX_PATH):
		return
	var lines: PackedStringArray = FileAccess.get_file_as_string(RUNTIME_INDEX_PATH).split("\n", false)
	_expect(lines.size() == EXPECTED_RUNTIME_SAMPLE_COUNT + 1, "runtime layer index must contain 530 data rows")
	var player_rooms: Dictionary[String, bool] = {}
	var enemy_roots: Dictionary[String, bool] = {}
	var found_weapon: bool = false
	var found_ghost: bool = false
	var found_drop: bool = false
	var found_projectile: bool = false
	var found_field: bool = false
	var found_water_surface: bool = false
	for line_index: int in range(1, lines.size()):
		var columns: PackedStringArray = lines[line_index].split("\t")
		_expect(columns.size() == 11, "invalid runtime index row %d" % (line_index + 1))
		if columns.size() != 11:
			continue
		var room_id: String = columns[0]
		var node_path: String = columns[1]
		var node_type: String = columns[2]
		var effective_z: int = columns[5].to_int()
		_expect(columns[7] == "false", "Y-sort enabled at runtime: %s" % node_path)
		if node_type == "CharacterBody2D" and node_path.ends_with("/Player"):
			_expect(effective_z == 12, "Player root is not effective z=12 in %s" % room_id)
			player_rooms[room_id] = true
		if node_path.ends_with("/WeaponVisual"):
			found_weapon = true
			_expect(effective_z == 13, "Player WeaponVisual is not effective z=13")
		if node_path.ends_with("/GhostSprite"):
			found_ghost = true
			_expect(effective_z == 14, "Player GhostSprite is not effective z=14")
		if node_type == "CharacterBody2D" and node_path.contains("/Enemies/"):
			enemy_roots[node_path.get_file()] = true
			_expect(effective_z == 10, "enemy root is not effective z=10: %s" % node_path)
		if node_path.ends_with("/CoinPickup"):
			found_drop = true
			_expect(effective_z == 13, "runtime Drop is not effective z=13")
		if node_path.ends_with("/Chapter03EnemyProjectile"):
			found_projectile = true
			_expect(effective_z == 16, "runtime projectile is not effective z=16")
		if node_path.ends_with("/Chapter03TimedField"):
			found_field = true
			_expect(effective_z == 16, "runtime timed field is not effective z=16")
		if node_path.contains("WaterSurfaceForeground"):
			found_water_surface = true
			_expect(effective_z == 20, "limited water surface is not effective z=20")
	_expect(player_rooms.size() == REQUIRED_ROOMS.size(), "Player z=12 was not sampled in all eight formal rooms")
	_expect(enemy_roots.size() == 6, "all six formal enemy roots must be sampled")
	_expect(found_weapon, "runtime WeaponVisual sample missing")
	_expect(found_ghost, "runtime GhostSprite sample missing")
	_expect(found_drop, "runtime Drop sample missing")
	_expect(found_projectile, "runtime projectile sample missing")
	_expect(found_field, "runtime timed-field sample missing")
	_expect(found_water_surface, "runtime limited-foreground water sample missing")


func _expect(condition: bool, message: String) -> void:
	if not condition:
		_failures.append(message)


func _finish() -> void:
	if _failures.is_empty():
		print(
			"CH3_RENDER_LAYER_L3_EVIDENCE PASS captures=79 unique=79 rooms=8 "
			+ "runtime_samples=530 player_z=12 enemies=6 drop_z=13 fx_z=16 y_sort=0 "
			+ "npc=partial boss=partial reward=partial chapter4=partial remote_ui=partial"
		)
		quit(0)
		return
	for failure: String in _failures:
		push_error("CH3_RENDER_LAYER_L3_EVIDENCE FAIL: %s" % failure)
	quit(1)
