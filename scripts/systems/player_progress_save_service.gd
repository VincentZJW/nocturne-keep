class_name PlayerProgressSaveServiceState
extends Node

## Disk authority for permanent Player weapon ownership/equipment and the
## minimum chapter recovery ledger. Runtime files live under user:// only.

## Emitted after an authoritative progress snapshot reaches disk.
signal progress_saved(save_path: String)
## Emitted after a validated snapshot has replaced runtime progress.
signal progress_loaded(save_path: String)
## Emitted after the configured save file is removed.
signal progress_cleared(save_path: String)
## Emitted for file-system or serialization failures.
signal progress_save_failed(message: String)

const SAVE_VERSION: int = 1
const DEFAULT_SAVE_PATH: String = "user://player_progress_v1.json"

var save_path: String = DEFAULT_SAVE_PATH
var _persistence_enabled: bool = false
var _suppress_autosave: bool = false
var _autosave_pending: bool = false


func _ready() -> void:
	_connect_runtime_signals()


func begin_new_game() -> Error:
	_persistence_enabled = false
	_autosave_pending = false
	return clear_progress()


func begin_debug_session() -> void:
	_persistence_enabled = false
	_autosave_pending = false


func enable_formal_persistence(write_initial_snapshot: bool = true) -> Error:
	var session: ChapterSessionState = _session()
	if session == null or session.is_debug_run:
		_persistence_enabled = false
		return ERR_UNAUTHORIZED
	_persistence_enabled = true
	if write_initial_snapshot:
		return save_progress()
	return OK


func is_persistence_enabled() -> bool:
	return _persistence_enabled


func has_saved_progress() -> bool:
	return FileAccess.file_exists(save_path)


func save_progress() -> Error:
	var session: ChapterSessionState = _session()
	var inventory: PlayerWeaponInventory = _inventory()
	var equipment: PlayerEquipmentManager = _equipment()
	if not _persistence_enabled or session == null or session.is_debug_run:
		return ERR_UNAUTHORIZED
	if inventory == null or equipment == null:
		return ERR_UNCONFIGURED
	var owned_ids: Array[String] = []
	for weapon_id: StringName in inventory.export_snapshot():
		owned_ids.append(String(weapon_id))
	var snapshot: Dictionary = {
		"version": SAVE_VERSION,
		"inventory": {"owned_weapon_ids": owned_ids},
		"equipment": {"equipped_weapon_id": String(equipment.equipped_weapon_id)},
		"chapter_session": session.export_progress_snapshot(),
	}
	var file: FileAccess = FileAccess.open(save_path, FileAccess.WRITE)
	if file == null:
		var open_error: Error = FileAccess.get_open_error()
		progress_save_failed.emit("Could not open progress save: %s" % error_string(open_error))
		return open_error
	file.store_string(JSON.stringify(snapshot, "\t", false, true))
	file.close()
	progress_saved.emit(save_path)
	return OK


func load_progress() -> Error:
	if not has_saved_progress():
		return ERR_DOES_NOT_EXIST
	var json: JSON = JSON.new()
	var parse_error: Error = json.parse(FileAccess.get_file_as_string(save_path))
	if parse_error != OK:
		progress_save_failed.emit("Invalid progress JSON at line %d" % json.get_error_line())
		return parse_error
	var raw_snapshot: Variant = json.data
	if not raw_snapshot is Dictionary:
		return ERR_PARSE_ERROR
	var snapshot: Dictionary = raw_snapshot
	if int(snapshot.get("version", -1)) != SAVE_VERSION:
		return ERR_FILE_UNRECOGNIZED
	var inventory_value: Variant = snapshot.get("inventory", {})
	var equipment_value: Variant = snapshot.get("equipment", {})
	var session_value: Variant = snapshot.get("chapter_session", {})
	if not inventory_value is Dictionary or not equipment_value is Dictionary or not session_value is Dictionary:
		return ERR_INVALID_DATA
	var inventory_snapshot: Dictionary = inventory_value
	var equipment_snapshot: Dictionary = equipment_value
	var session_snapshot: Dictionary = session_value
	var inventory: PlayerWeaponInventory = _inventory()
	var equipment: PlayerEquipmentManager = _equipment()
	var session: ChapterSessionState = _session()
	if inventory == null or equipment == null or session == null:
		return ERR_UNCONFIGURED
	if not session.can_import_progress_snapshot(session_snapshot):
		return ERR_INVALID_DATA
	var owned_value: Variant = inventory_snapshot.get("owned_weapon_ids", [])
	if not owned_value is Array:
		return ERR_INVALID_DATA
	var owned_ids: Array[StringName] = []
	for raw_weapon_id: Variant in owned_value:
		var weapon_id: StringName = StringName(String(raw_weapon_id))
		if weapon_id.is_empty() or equipment.get_weapon(weapon_id) == null:
			return ERR_INVALID_DATA
		if not owned_ids.has(weapon_id):
			owned_ids.append(weapon_id)
	var equipped_weapon_id: StringName = StringName(
		String(equipment_snapshot.get("equipped_weapon_id", ""))
	)
	if equipped_weapon_id.is_empty() or not owned_ids.has(equipped_weapon_id):
		return ERR_INVALID_DATA
	_suppress_autosave = true
	var inventory_restored: bool = inventory.import_snapshot(owned_ids)
	var equipment_restored: bool = inventory_restored and equipment.equip_weapon(equipped_weapon_id)
	var session_restored: bool = equipment_restored and session.import_progress_snapshot(session_snapshot)
	_suppress_autosave = false
	if not session_restored:
		return ERR_INVALID_DATA
	_persistence_enabled = not session.is_debug_run
	progress_loaded.emit(save_path)
	return OK


func clear_progress() -> Error:
	if not has_saved_progress():
		return OK
	var error: Error = DirAccess.remove_absolute(ProjectSettings.globalize_path(save_path))
	if error == OK:
		progress_cleared.emit(save_path)
	else:
		progress_save_failed.emit("Could not clear progress save: %s" % error_string(error))
	return error


func set_save_path_for_testing(test_save_path: String) -> bool:
	if not OS.is_debug_build() or not test_save_path.begins_with("user://"):
		return false
	save_path = test_save_path
	_persistence_enabled = false
	_autosave_pending = false
	return true


func _connect_runtime_signals() -> void:
	var inventory: PlayerWeaponInventory = _inventory()
	var equipment: PlayerEquipmentManager = _equipment()
	var session: ChapterSessionState = _session()
	if inventory != null:
		if not inventory.weapon_added.is_connected(_on_progress_changed):
			inventory.weapon_added.connect(_on_progress_changed)
		if not inventory.inventory_reset.is_connected(_on_progress_reset):
			inventory.inventory_reset.connect(_on_progress_reset)
	if equipment != null and not equipment.weapon_equipped.is_connected(_on_weapon_equipped):
		equipment.weapon_equipped.connect(_on_weapon_equipped)
	if session != null and not session.progress_state_changed.is_connected(_on_progress_reset):
		session.progress_state_changed.connect(_on_progress_reset)


func _on_progress_changed(_weapon_id: StringName) -> void:
	_request_autosave()


func _on_weapon_equipped(_weapon: WeaponData) -> void:
	_request_autosave()


func _on_progress_reset() -> void:
	_request_autosave()


func _request_autosave() -> void:
	if not _persistence_enabled or _suppress_autosave or _autosave_pending:
		return
	var session: ChapterSessionState = _session()
	if session == null or session.is_debug_run:
		return
	_autosave_pending = true
	call_deferred("_flush_autosave")


func _flush_autosave() -> void:
	_autosave_pending = false
	var error: Error = save_progress()
	if error != OK and error != ERR_UNAUTHORIZED:
		progress_save_failed.emit("Autosave failed: %s" % error_string(error))


func _session() -> ChapterSessionState:
	return get_node_or_null("/root/ChapterSession") as ChapterSessionState


func _inventory() -> PlayerWeaponInventory:
	return get_node_or_null("/root/WeaponInventory") as PlayerWeaponInventory


func _equipment() -> PlayerEquipmentManager:
	return get_node_or_null("/root/EquipmentManager") as PlayerEquipmentManager
