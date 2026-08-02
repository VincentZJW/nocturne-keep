extends SceneTree

const ROOT: String = "res://chapters/chapter_04_drowned_underkeep"
const BACKDROP_PATH: String = ROOT + "/assets/environment/character_trial/drowned_cellblock_gallery.png"
const OUTPUT_PATH: String = ROOT + "/scenes/trials/chapter_04_character_trial.tscn"

const ENCOUNTERS: Array[Dictionary] = [
	{"name": "GaolerIntake", "x": 700.0, "enemies": [["drowned_gaoler", 620.0, 612.0], ["sewer_maw", 860.0, 612.0]]},
	{"name": "HarpoonGallery", "x": 2050.0, "enemies": [["mire_harpooner", 2110.0, 438.0]]},
	{"name": "PenitentFloodway", "x": 3400.0, "enemies": [["sunken_shield_penitent", 3300.0, 612.0], ["mirefin_raider", 3540.0, 612.0]]},
	{"name": "ConvictCistern", "x": 4750.0, "enemies": [["chainbound_convict", 4660.0, 612.0], ["bog_toad", 4930.0, 612.0]]},
	{"name": "ExecutionBlock", "x": 5900.0, "enemies": [["underkeep_executioner", 5980.0, 612.0]]},
]


func _initialize() -> void:
	var root_node: Node2D = Node2D.new()
	root_node.name = "Chapter04CharacterTrial"
	var backdrop: Texture2D = load(BACKDROP_PATH) as Texture2D
	if backdrop == null:
		push_error("Missing imported trial backdrop")
		quit(1)
		return
	for index: int in range(5):
		var sprite: Sprite2D = Sprite2D.new()
		sprite.name = "CellblockBackdrop%02d" % (index + 1)
		sprite.texture = backdrop
		sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		sprite.position = Vector2(800.0 + index * 1600.0, 360.0)
		sprite.z_index = -90
		root_node.add_child(sprite)
	var floor: StaticBody2D = StaticBody2D.new()
	floor.name = "TrialFloor"
	floor.collision_layer = 1
	floor.collision_mask = 0
	floor.add_child(_shape_node(Vector2(8000, 108), Vector2(4000, 666)))
	root_node.add_child(floor)
	_build_harpoon_platform(root_node)
	for definition: Dictionary in ENCOUNTERS:
		if not _add_encounter(root_node, definition):
			root_node.free()
			quit(1)
			return
	if not _add_boss_encounter(root_node):
		root_node.free()
		quit(1)
		return
	var labels: Node2D = Node2D.new()
	labels.name = "RoleLabels"
	root_node.add_child(labels)
	for entry: Array in [[700,"GAOLER + SEWER MAW"],[2050,"MIRE HARPOONER"],[3400,"SHIELD PENITENT + MIREFIN"],[4750,"CONVICT + BOG TOAD"],[5900,"UNDERKEEP EXECUTIONER"],[7300,"SOUL GAOLER ORMUND · TWO PHASES"]]:
		var label: Label = Label.new(); label.text = entry[1]; label.position = Vector2(float(entry[0])-150.0,530.0); label.z_index=20; label.add_theme_font_size_override("font_size",12); label.add_theme_color_override("font_color",Color("8bb8b6")); labels.add_child(label)
	_set_owner_recursive(root_node, root_node)
	var packed: PackedScene = PackedScene.new()
	if packed.pack(root_node) != OK:
		push_error("Unable to pack Chapter IV trial")
		root_node.free(); quit(1); return
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUTPUT_PATH.get_base_dir()))
	var error: Error = ResourceSaver.save(packed, OUTPUT_PATH)
	root_node.free()
	print("CH4 CHARACTER TRIAL BUILD | %s encounters=%d boss=1" % ["PASS" if error == OK else error_string(error), ENCOUNTERS.size()])
	quit(0 if error == OK else 1)


func _add_encounter(parent: Node2D, definition: Dictionary) -> bool:
	var encounter: EncounterGroup = EncounterGroup.new()
	encounter.name = String(definition["name"])
	encounter.encounter_name = StringName("CH4_%s" % definition["name"])
	encounter.region_name = &"DrownedCellblockTrial"
	encounter.simultaneous_attack_limit = 2
	parent.add_child(encounter)
	var activation: Area2D = Area2D.new(); activation.name="ActivationArea"; activation.collision_layer=0; activation.collision_mask=2; activation.monitorable=false; encounter.add_child(activation)
	var area_shape: CollisionShape2D=_shape_node(Vector2(620,220),Vector2(float(definition["x"]),500)); area_shape.name="CollisionShape2D"; activation.add_child(area_shape)
	var enemies_root: Node2D=Node2D.new(); enemies_root.name="Enemies"; encounter.add_child(enemies_root)
	for enemy_data: Array in definition["enemies"]:
		var role: String=String(enemy_data[0]); var scene: PackedScene=load("%s/scenes/enemies/%s.tscn" % [ROOT,role]) as PackedScene
		if scene==null: push_error("Missing trial enemy %s" % role); return false
		var enemy: Chapter04Enemy=scene.instantiate() as Chapter04Enemy; enemy.name=_pascal(role); enemy.position=Vector2(float(enemy_data[1]),float(enemy_data[2])); enemies_root.add_child(enemy)
	return true


func _add_boss_encounter(parent: Node2D) -> bool:
	var encounter: EncounterGroup = EncounterGroup.new()
	encounter.name="OrmundBossEncounter"
	encounter.encounter_name=&"CH4_SOUL_GAOLER_ORMUND"
	encounter.region_name=&"DrownedJudgmentVault"
	encounter.simultaneous_attack_limit=1
	parent.add_child(encounter)
	var activation:=Area2D.new(); activation.name="ActivationArea"; activation.collision_layer=0; activation.collision_mask=2; activation.monitorable=false; encounter.add_child(activation)
	var area_shape:=_shape_node(Vector2(850,300),Vector2(7200,480)); area_shape.name="CollisionShape2D"; activation.add_child(area_shape)
	var enemies_root:=Node2D.new(); enemies_root.name="Enemies"; encounter.add_child(enemies_root)
	var scene:=load("%s/scenes/bosses/soul_gaoler_ormund.tscn" % ROOT) as PackedScene
	if scene==null:
		push_error("Missing Soul Gaoler Ormund scene")
		return false
	var boss:=scene.instantiate() as SoulGaolerOrmund
	boss.name="SoulGaolerOrmund"
	boss.position=Vector2(7480,612)
	enemies_root.add_child(boss)
	return true


func _build_harpoon_platform(parent: Node2D) -> void:
	var platform: StaticBody2D=StaticBody2D.new(); platform.name="HarpoonPlatform"; platform.collision_layer=1; platform.collision_mask=0
	var visual: Polygon2D=Polygon2D.new(); visual.name="Visual"; visual.polygon=PackedVector2Array([Vector2(1820,438),Vector2(2290,438),Vector2(2290,462),Vector2(1820,462)]); visual.color=Color("354954"); platform.add_child(visual)
	platform.add_child(_shape_node(Vector2(470,24),Vector2(2055,450))); parent.add_child(platform)


func _shape_node(size: Vector2, position: Vector2) -> CollisionShape2D:
	var node: CollisionShape2D=CollisionShape2D.new(); node.name="CollisionShape2D"; var shape: RectangleShape2D=RectangleShape2D.new(); shape.size=size; node.shape=shape; node.position=position; return node


func _set_owner_recursive(node: Node, scene_owner: Node) -> void:
	for child: Node in node.get_children(): child.owner=scene_owner; _set_owner_recursive(child,scene_owner)


func _pascal(value: String) -> String:
	var result: String=""
	for word: String in value.split("_"): result+=word.capitalize().replace(" ","")
	return result
