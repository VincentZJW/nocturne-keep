class_name Chapter02GrayboxQaRunner
extends Node

const CAPTURE_ARGUMENT: String = "--capture-ch2-graybox"
const FAST_CAPTURE_ARGUMENT: String = "--recapture-ch2-graybox-fast"
const ROOM_TARGETS: Array[float] = [
	1152.0, 4608.0, 9216.0, 13568.0, 17536.0, 21120.0, 23808.0, 26176.0, 29824.0,
]
const ROOM_SLUGS: Array[String] = [
	"castle_gate_interior", "grey_banner_corridor", "last_banquet_hall",
	"royal_portrait_gallery", "blood_candle_chapel", "servant_passage",
	"old_armory_safe_room", "silent_ballroom_antechamber", "silent_ballroom",
]
const INSPECTION_SECONDS_PER_ROOM: float = 25.0
const MAX_TRAVERSAL_SECONDS_PER_ROOM: float = 40.0

@export_node_path("Player") var player_path: NodePath = NodePath("../../GameplayWorld/PlayerAnchorOrRuntimeActors/ChapterRuntime/Player")

@onready var player: Player = get_node(player_path) as Player

var _ground_dash_tested: bool = false
var _aerial_actions_tested: bool = false


func _ready() -> void:
	var arguments: PackedStringArray = OS.get_cmdline_user_args()
	if CAPTURE_ARGUMENT not in arguments and FAST_CAPTURE_ARGUMENT not in arguments:
		return
	call_deferred("_run_full_traversal")


func _run_full_traversal() -> void:
	var started_at: int = Time.get_ticks_msec()
	var fast_capture: bool = FAST_CAPTURE_ARGUMENT in OS.get_cmdline_user_args()
	var inspection_seconds: float = 1.0 if fast_capture else INSPECTION_SECONDS_PER_ROOM
	var output_directory: String = ProjectSettings.globalize_path("res://docs/qa/chapter_02_graybox")
	DirAccess.make_dir_recursive_absolute(output_directory)
	for room_index: int in range(ROOM_TARGETS.size()):
		var reached_target: bool = await _walk_to_x(ROOM_TARGETS[room_index])
		if not reached_target:
			Input.action_release("player_move_right")
			push_error("Chapter II traversal timed out before room %02d target %.1f" % [room_index + 1, ROOM_TARGETS[room_index]])
			get_tree().quit(1)
			return
		Input.action_release("player_move_right")
		await get_tree().create_timer(inspection_seconds).timeout
		await get_tree().process_frame
		RenderingServer.force_draw(true)
		await get_tree().process_frame
		var image: Image = get_viewport().get_texture().get_image()
		var file_name: String = "room_%02d_%s_f5.png" % [room_index + 1, ROOM_SLUGS[room_index]]
		var save_error: Error = image.save_png(output_directory.path_join(file_name))
		if save_error != OK:
			push_error("QA screenshot failed: %s" % error_string(save_error))
		print("CH2_GRAYBOX_CAPTURE room=%02d x=%.2f file=%s" % [room_index + 1, player.global_position.x, file_name])
	Input.action_release("player_move_right")
	var elapsed_seconds: float = float(Time.get_ticks_msec() - started_at) / 1000.0
	print("CH2_GRAYBOX_F5_TRAVERSAL: PASS duration=%.2fs screenshots=%d" % [elapsed_seconds, ROOM_TARGETS.size()])
	get_tree().quit(0)


func _walk_to_x(target_x: float) -> bool:
	Input.action_press("player_move_right")
	var previous_x: float = player.global_position.x
	var stalled_frames: int = 0
	var started_at: int = Time.get_ticks_msec()
	while player.global_position.x < target_x:
		await get_tree().physics_frame
		if float(Time.get_ticks_msec() - started_at) / 1000.0 > MAX_TRAVERSAL_SECONDS_PER_ROOM:
			return false
		await _run_planned_ability_tests()
		var progress: float = player.global_position.x - previous_x
		stalled_frames = stalled_frames + 1 if progress < 0.2 else 0
		if stalled_frames >= 10 and player.is_on_floor():
			await _tap_action(&"player_jump")
			print("CH2_GRAYBOX_ABILITY obstacle_jump x=%.2f" % player.global_position.x)
			stalled_frames = 0
		previous_x = player.global_position.x
	Input.action_release("player_move_right")
	return true


func _run_planned_ability_tests() -> void:
	if not _ground_dash_tested and player.global_position.x >= 1800.0 and player.is_on_floor():
		_ground_dash_tested = true
		await _tap_action(&"dash")
		print("CH2_GRAYBOX_ABILITY ground_dash x=%.2f" % player.global_position.x)
	if not _aerial_actions_tested and player.global_position.x >= 7200.0 and player.is_on_floor():
		_aerial_actions_tested = true
		await _tap_action(&"player_jump")
		for _frame_index: int in range(7):
			await get_tree().physics_frame
		await _tap_action(&"player_jump")
		for _frame_index: int in range(4):
			await get_tree().physics_frame
		await _tap_action(&"dash")
		print("CH2_GRAYBOX_ABILITY double_jump_air_dash x=%.2f y=%.2f" % [player.global_position.x, player.global_position.y])


func _tap_action(action: StringName) -> void:
	Input.action_press(action)
	await get_tree().physics_frame
	Input.action_release(action)
