extends SceneTree

## Original-resolution evidence from the configured F5 Main geometry and shared scenes.

const MAIN_SCENE: PackedScene = preload("res://scenes/main/main.tscn")


func _initialize() -> void:
	call_deferred("_capture")


func _capture() -> void:
	var main: Node2D = MAIN_SCENE.instantiate() as Node2D
	root.add_child(main)
	for frame_index: int in range(8):
		await physics_frame
	var player: Player = main.get_node("World/Player") as Player
	var traversal: LevelTraversalDebugOverlay = main.get_node(
		"Interface/DebugHudRoot/LevelTraversalDebug"
	) as LevelTraversalDebugOverlay
	var debug_controller: MainDebugHudController = main.get_node("Interface") as MainDebugHudController
	debug_controller.set_debug_hud_visible(true)
	traversal.debug_visible = true
	traversal.visible = true
	await _capture_region(
		player, Vector2(2780.0, 472.0), "res://docs/qa/main_traversal_crossbow_platform_b.png"
	)
	await _capture_region(
		player, Vector2(3560.0, 464.0), "res://docs/qa/main_traversal_gargoyle_perch.png"
	)
	await _capture_region(
		player, Vector2(4860.0, 612.0), "res://docs/qa/main_traversal_platforms_c_d.png"
	)
	print("MAIN_TRAVERSAL_QA: PlatformB top=500 GargoylePerch top=492 PlatformC/D top=504/508")
	quit(0)


func _capture_region(player: Player, position: Vector2, path: String) -> void:
	player.global_position = position
	player.velocity = Vector2.ZERO
	player.player_camera.reset_smoothing()
	for frame_index: int in range(10):
		await process_frame
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(path.get_base_dir()))
	var image: Image = root.get_texture().get_image()
	var error: Error = image.save_png(ProjectSettings.globalize_path(path))
	if error != OK:
		push_error("Cannot save traversal QA image %s" % path)
