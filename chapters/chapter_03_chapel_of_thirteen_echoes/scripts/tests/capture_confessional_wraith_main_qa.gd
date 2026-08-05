extends SceneTree

## MainBootstrap evidence for the formal Confessionals encounter after the
## hidden-visual and permanent-reaction fixes.

const BOOTSTRAP_PATH: String = "res://scenes/bootstrap/main_bootstrap.tscn"
const ROUTE_PATH: String = (
	"res://chapters/chapter_03_chapel_of_thirteen_echoes/scenes/level/chapter_03_route.tscn"
)
const OUTPUT_DIR: String = "res://docs/qa/cross_chapter_critical_bugfix/chapter_03_main"


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	DisplayServer.window_set_size(Vector2i(1280, 720))
	var config: DebugRunConfigState = root.get_node_or_null("DebugRunConfig") as DebugRunConfigState
	if config == null:
		_fail("missing DebugRunConfig")
		return
	config.debug_chapter_start_enabled = true
	config.debug_start_chapter_id = ChapterRegistry.CHAPTER_03_CHAPEL_OF_THIRTEEN_ECHOES
	config.debug_start_spawn_id = &"CH3_CONFESSIONALS"
	config.debug_skip_chapter_intro = true
	if change_scene_to_file(BOOTSTRAP_PATH) != OK:
		_fail("could not launch MainBootstrap")
		return
	var route: Chapter03Route = await _wait_for_route()
	if route == null:
		_fail("Chapter III route did not load through MainBootstrap")
		return
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUTPUT_DIR))
	var player: Player = route.transition_controller.player
	player.hurtbox.set_invulnerable(true)
	player.global_position = Vector2(420.0, 584.0)
	player.velocity = Vector2.ZERO
	player.player_camera.reset_smoothing()
	var wraith: Chapter03SpecialistEnemy = await _wait_for_revealed_wraith(route, player)
	if wraith == null:
		_fail("formal Confessionals Wraith never became targetable and visible")
		return
	await _save("01_confessional_wraith_revealed_targetable_main.png")
	var before_health: int = wraith.health_component.current_health
	wraith.health_component.take_damage(14)
	for _frame: int in range(24):
		await physics_frame
	if wraith.health_component.current_health != before_health - 14:
		_fail("formal Wraith did not retain applied combat damage")
		return
	if wraith.get_state_name() in [Chapter03SpecialistEnemy.LIGHT_HIT, Chapter03SpecialistEnemy.STAGGER]:
		_fail("formal Wraith remained permanently stuck in reaction")
		return
	await _save("02_confessional_wraith_recovered_from_hit_main.png")
	config.reset_to_defaults()
	print("CH3 CONFESSIONAL WRAITH MAIN QA | PASS visible=true targetable=true reaction_exit=true")
	await _clean_exit(0)


func _wait_for_route() -> Chapter03Route:
	for _frame: int in range(480):
		await process_frame
		if current_scene != null and current_scene.scene_file_path == ROUTE_PATH:
			return current_scene as Chapter03Route
	return null


func _wait_for_revealed_wraith(
	route: Chapter03Route, player: Player
) -> Chapter03SpecialistEnemy:
	var selected: Chapter03SpecialistEnemy
	for _frame: int in range(360):
		await physics_frame
		var room: Chapter03Room = route.transition_controller.active_room
		if room == null:
			continue
		for node: Node in room.find_children("*", "", true, false):
			var enemy: Chapter03SpecialistEnemy = node as Chapter03SpecialistEnemy
			if enemy == null or enemy.get_enemy_type_name() != &"Confessional Wraith":
				continue
			selected = enemy
			if not enemy.is_ai_active():
				enemy.set_ai_active(true)
			if enemy.target == null:
				enemy.set_target(player)
			if enemy.animated_sprite.visible and enemy.hurtbox.is_enabled:
				return enemy
	if selected != null:
		push_error("Wraith final state=%s visible=%s hurtbox=%s" % [
			selected.get_state_name(), selected.animated_sprite.visible, selected.hurtbox.is_enabled,
		])
	return null


func _save(file_name: String) -> void:
	for _frame: int in range(4):
		await process_frame
	var path: String = OUTPUT_DIR.path_join(file_name)
	var error: Error = root.get_texture().get_image().save_png(ProjectSettings.globalize_path(path))
	if error != OK:
		_fail("could not save %s: %s" % [path, error_string(error)])


func _fail(message: String) -> void:
	push_error("CH3 CONFESSIONAL WRAITH MAIN QA | %s" % message)
	call_deferred("_clean_exit", 1)


func _clean_exit(code: int) -> void:
	if current_scene != null:
		current_scene.free()
		current_scene = null
	for _frame: int in range(30):
		await process_frame
	quit(code)
