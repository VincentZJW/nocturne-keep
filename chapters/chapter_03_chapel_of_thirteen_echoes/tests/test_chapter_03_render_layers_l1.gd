extends SceneTree

const CHAPTER_ROOT: String = "res://chapters/chapter_03_chapel_of_thirteen_echoes"

var _failures: Array[String] = []


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	_assert_contract()
	await _assert_room_door(
		"scenes/rooms/ch3_chapel_vestibule.tscn", "Doors/NaveDoor"
	)
	await _assert_room_door("scenes/rooms/ch3_nave_entry.tscn", "Doors/EastExitDoor")
	await _assert_room_door(
		"scenes/rooms/ch3_choir_gallery.tscn", "Doors/EastExitDoor"
	)
	await _assert_room_door(
		"scenes/rooms/ch3_boss_checkpoint.tscn", "Doors/ConfessionDoor"
	)
	await _assert_boss_region_layers()
	await _assert_underkeep_water_split()
	await _assert_dynamic_spawn_layers()
	_finish()


func _assert_contract() -> void:
	_expect(RenderLayerContract.ENEMIES == 10, "enemy contract changed")
	_expect(RenderLayerContract.NPCS == 11, "NPC contract must be z=11")
	_expect(RenderLayerContract.PLAYER == 12, "Player contract changed")
	_expect(RenderLayerContract.DROPS == 13, "Drop contract must be z=13")
	_expect(RenderLayerContract.INTERACTABLES == 14, "interactable contract changed")
	_expect(RenderLayerContract.COMBAT_FX == 16, "CombatFX contract must be z=16")
	_expect(RenderLayerContract.LIMITED_FOREGROUND == 20, "foreground contract changed")
	_expect(Chapter03LayerContract.DROPS == RenderLayerContract.DROPS, "Chapter III Drop alias drifted")
	_expect(Chapter03LayerContract.COMBAT_FX == RenderLayerContract.COMBAT_FX, "Chapter III CombatFX alias drifted")


func _assert_room_door(scene_suffix: String, door_path: String) -> void:
	var packed: PackedScene = load("%s/%s" % [CHAPTER_ROOT, scene_suffix]) as PackedScene
	_expect(packed != null, "missing room scene: %s" % scene_suffix)
	if packed == null:
		return
	var room: Node2D = packed.instantiate() as Node2D
	root.add_child(room)
	await process_frame
	var door: Chapter03RoomDoor = room.get_node_or_null(door_path) as Chapter03RoomDoor
	_expect(door != null, "missing door authority: %s/%s" % [scene_suffix, door_path])
	if door != null:
		var presentation: Node2D = door.get_node_or_null("Presentation") as Node2D
		var panel: Sprite2D = door.get_node_or_null("Presentation/DoorVisual") as Sprite2D
		var interaction: Node2D = door.get_node_or_null("Interaction") as Node2D
		var prompt: Label = door.get_node_or_null("Interaction/Prompt") as Label
		_expect(door.z_index == 0, "%s authority must not lift all children" % door_path)
		_expect(presentation != null and _effective_z(presentation) == RenderLayerContract.PROPS_BEHIND_ACTORS, "%s panel container must be behind actors" % door_path)
		_expect(panel != null and _effective_z(panel) == RenderLayerContract.PROPS_BEHIND_ACTORS, "%s panel must be behind actors" % door_path)
		_expect(interaction != null and _effective_z(interaction) == RenderLayerContract.INTERACTABLES, "%s interaction must be z=14" % door_path)
		_expect(prompt != null and _effective_z(prompt) == RenderLayerContract.INTERACTABLES, "%s prompt must be z=14" % door_path)
		_expect(door.blocker_shape != null and not door.blocker_shape.disabled, "%s blocker must remain active" % door_path)
	_assert_no_y_sort(room)
	room.queue_free()
	await process_frame


func _assert_boss_region_layers() -> void:
	var antechamber: Node2D = _instantiate_area("scenes/areas/ch3_boss_antechamber.tscn")
	if antechamber != null:
		var checkpoint: Sprite2D = antechamber.get_node("CheckpointVisual") as Sprite2D
		var title: Control = antechamber.get_node("AreaTitle") as Control
		_expect(_effective_z(checkpoint) == RenderLayerContract.PROPS_BEHIND_ACTORS, "antechamber checkpoint must be behind Player")
		_expect(not title.visible, "antechamber duplicate world title must stay hidden")
		_assert_no_y_sort(antechamber)
		antechamber.queue_free()
		await process_frame

	var gate: Chapter03BossGate = _instantiate_area(
		"scenes/areas/ch3_boss_gate_transition.tscn"
	) as Chapter03BossGate
	if gate != null:
		for panel_name: String in ["GateClosed", "GateLit", "GateOpen"]:
			var panel: Sprite2D = gate.get_node("Visuals/%s" % panel_name) as Sprite2D
			_expect(_effective_z(panel) == RenderLayerContract.PROPS_BEHIND_ACTORS, "%s must be behind Player" % panel_name)
		var wax: Sprite2D = gate.get_node("Visuals/WaxCrack") as Sprite2D
		var seal_lights: Node2D = gate.get_node("Visuals/SealLights") as Node2D
		var gate_name: Control = gate.get_node("GateName") as Control
		_expect(_effective_z(wax) == RenderLayerContract.COMBAT_FX, "wax crack must use CombatFX z=16")
		_expect(_effective_z(seal_lights) == RenderLayerContract.COMBAT_FX, "seal lights must use CombatFX z=16")
		_expect(not gate_name.visible, "duplicate gate title must stay hidden")
		gate.open_immediately()
		await physics_frame
		_expect(_effective_z(gate.open_sprite) == RenderLayerContract.PROPS_BEHIND_ACTORS, "open gate must not jump above Player")
		_expect(gate.blocker.disabled, "Boss gate blocker behavior changed")
		_assert_no_y_sort(gate)
		gate.queue_free()
		await process_frame

	await _assert_hidden_world_title("scenes/areas/ch3_boss_sanctum.tscn", "SanctumTitle")
	await _assert_hidden_world_title("scenes/areas/ch3_post_boss_reliquary.tscn", "AreaTitle")
	await _assert_hidden_world_title("scenes/areas/ch3_underkeep_descent.tscn", "AreaTitle")


func _assert_underkeep_water_split() -> void:
	var underkeep: Node2D = _instantiate_area(
		"scenes/areas/ch3_underkeep_descent.tscn"
	)
	if underkeep == null:
		return
	for index: int in range(1, 3):
		var body: Sprite2D = underkeep.get_node("WaterBodyBehind%02d" % index) as Sprite2D
		var surface: Sprite2D = underkeep.get_node(
			"WaterSurfaceForeground%02d" % index
		) as Sprite2D
		_expect(_effective_z(body) == RenderLayerContract.PROPS_BEHIND_ACTORS, "water body %d must stay behind actors" % index)
		_expect(_effective_z(surface) == RenderLayerContract.LIMITED_FOREGROUND, "water surface %d must use limited foreground" % index)
		_expect(surface.texture != null and surface.texture.get_height() <= 4, "water surface %d exceeds four-pixel occlusion budget" % index)
	_assert_no_y_sort(underkeep)
	underkeep.queue_free()
	await process_frame


func _assert_dynamic_spawn_layers() -> void:
	var world: Node2D = Node2D.new()
	world.name = "LayerSpawnTestWorld"
	root.add_child(world)
	current_scene = world

	var player_packed: PackedScene = load("res://scenes/player/player.tscn") as PackedScene
	var player: Player = player_packed.instantiate() as Player
	world.add_child(player)
	player.global_position = Vector2(180.0, 300.0)

	var enemy_packed: PackedScene = load(
		CHAPTER_ROOT + "/scenes/enemies/silent_chorister.tscn"
	) as PackedScene
	var enemy: Chapter03SpecialistEnemy = enemy_packed.instantiate() as Chapter03SpecialistEnemy
	world.add_child(enemy)
	enemy.global_position = Vector2(320.0, 300.0)
	await process_frame
	enemy.set_target(player)
	enemy.active_action = &"silent_wave"
	enemy.action_damage = 1
	enemy.current_attack_id = 7001
	var projectile_index: int = world.get_child_count()
	enemy._spawn_projectiles()
	var projectile: Chapter03EnemyProjectile = world.get_child(projectile_index) as Chapter03EnemyProjectile
	_expect(projectile != null and projectile.z_index == RenderLayerContract.COMBAT_FX, "spawned projectile must use CombatFX z=16")

	enemy.active_action = &"hush_field"
	var field_index: int = world.get_child_count()
	enemy._spawn_field()
	var field: Chapter03TimedField = world.get_child(field_index) as Chapter03TimedField
	_expect(field != null and field.z_index == RenderLayerContract.COMBAT_FX, "spawned field must use CombatFX z=16")

	var loot_enemy: Node2D = Node2D.new()
	loot_enemy.name = "LootEnemy"
	var health: HealthComponent = HealthComponent.new()
	health.name = "HealthComponent"
	var hurtbox: HurtboxComponent = HurtboxComponent.new()
	hurtbox.name = "Hurtbox"
	hurtbox.faction = &"enemy"
	var loot: LootDropComponent = LootDropComponent.new()
	loot.name = "LootDropComponent"
	loot.profile = load(CHAPTER_ROOT + "/resources/enemies/silent_chorister_loot.tres") as LootDropProfile
	loot.dynamic_profile = load("res://resources/items/loot/default_dynamic_loot_profile.tres") as DynamicLootProfile
	loot_enemy.add_child(health)
	loot_enemy.add_child(hurtbox)
	loot_enemy.add_child(loot)
	world.add_child(loot_enemy)
	await process_frame
	var pickup_index: int = world.get_child_count()
	loot._spawn_pickup(&"coin", 1)
	var pickup: Node2D = world.get_child(pickup_index) as Node2D
	_expect(pickup != null and pickup.z_index == RenderLayerContract.DROPS, "spawned pickup must use Drop z=13")

	world.queue_free()
	await process_frame
	current_scene = null


func _assert_hidden_world_title(scene_suffix: String, title_path: String) -> void:
	var area: Node2D = _instantiate_area(scene_suffix)
	if area == null:
		return
	var title: CanvasItem = area.get_node_or_null(title_path) as CanvasItem
	_expect(title != null and not title.visible, "%s duplicate world title must stay hidden" % title_path)
	area.queue_free()
	await process_frame


func _instantiate_area(scene_suffix: String) -> Node2D:
	var packed: PackedScene = load("%s/%s" % [CHAPTER_ROOT, scene_suffix]) as PackedScene
	_expect(packed != null, "missing area scene: %s" % scene_suffix)
	if packed == null:
		return null
	var area: Node2D = packed.instantiate() as Node2D
	root.add_child(area)
	return area


func _effective_z(item: CanvasItem) -> int:
	var result: int = item.z_index
	if not item.z_as_relative:
		return result
	var ancestor: Node = item.get_parent()
	while ancestor != null:
		var ancestor_item: CanvasItem = ancestor as CanvasItem
		if ancestor_item != null:
			result += ancestor_item.z_index
			if not ancestor_item.z_as_relative:
				break
		ancestor = ancestor.get_parent()
	return result


func _assert_no_y_sort(node: Node) -> void:
	var item: CanvasItem = node as CanvasItem
	if item != null:
		_expect(not item.y_sort_enabled, "%s must not enable Y-sort" % item.get_path())
	for child: Node in node.get_children():
		_assert_no_y_sort(child)


func _expect(condition: bool, message: String) -> void:
	if not condition:
		_failures.append(message)


func _finish() -> void:
	if _failures.is_empty():
		print("CH3_RENDER_LAYERS_L1 PASS doors=4 checkpoint=1 gate_states=3 titles=5 water_edges=2 drop=13 combat_fx=16 y_sort=0")
		quit(0)
		return
	for failure: String in _failures:
		push_error("CH3_RENDER_LAYERS_L1 FAIL: %s" % failure)
	quit(1)
