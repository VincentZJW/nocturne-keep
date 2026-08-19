class_name DuchessEncounterPresentation
extends Node2D

## World-space entrance/phase presentation driven by one saved AnimationPlayer.

signal dialogue_requested(speaker: String, text: String, duration: float)
signal title_requested(title: String, subtitle: String)
signal phase_02_revealed

@export_node_path("AnimationPlayer") var animation_player_path: NodePath = NodePath("AnimationPlayer")
@onready var animation_player: AnimationPlayer = get_node_or_null(animation_player_path) as AnimationPlayer

var intro_progress: float = 0.0:
	set(value):
		intro_progress = clampf(value, 0.0, 1.0)
		queue_redraw()
var phase_progress: float = 0.0:
	set(value):
		phase_progress = clampf(value, 0.0, 1.0)
		queue_redraw()

var _intro_retry: bool = false
var _intro_marker: int = 0
var _phase_marker: int = 0


func _ready() -> void:
	if animation_player == null:
		push_error("DuchessEncounterPresentation requires AnimationPlayer")
		return
	_install_animation(&"intro_full", 6.8, &"intro_progress")
	_install_animation(&"intro_retry", 1.35, &"intro_progress")
	_install_animation(&"phase_transition_full", 4.4, &"phase_progress")
	set_process(false)


func play_intro(retry: bool) -> void:
	_intro_retry = retry
	_intro_marker = 0
	intro_progress = 0.0
	set_process(true)
	animation_player.play(&"intro_retry" if retry else &"intro_full")


func play_phase_transition() -> void:
	_phase_marker = 0
	phase_progress = 0.0
	set_process(true)
	animation_player.play(&"phase_transition_full")


func reset_presentation() -> void:
	animation_player.stop()
	intro_progress = 0.0
	phase_progress = 0.0
	set_process(false)


func _process(_delta: float) -> void:
	if animation_player.current_animation == &"intro_full":
		_process_full_intro_markers()
	elif animation_player.current_animation == &"intro_retry":
		if _intro_marker == 0 and intro_progress >= 0.12:
			_intro_marker = 1
			title_requested.emit("THE HOLLOW DUCHESS, SERAPHINE", "空心公爵夫人·瑟芙琳")
	elif animation_player.current_animation == &"phase_transition_full":
		_process_phase_markers()
	if not animation_player.is_playing():
		set_process(false)


func _process_full_intro_markers() -> void:
	var thresholds: Array[float] = [0.08, 0.20, 0.32, 0.44, 0.56, 0.80]
	while _intro_marker < thresholds.size() and intro_progress >= thresholds[_intro_marker]:
		match _intro_marker:
			0: dialogue_requested.emit("瑟芙琳", "七年了……这座舞厅仍记得你的脚步。", 0.72)
			1: dialogue_requested.emit("夜巡守卫", "你认识我？", 0.72)
			2: dialogue_requested.emit("瑟芙琳", "我只记得，殿下一直在等一个打开门的人。", 0.72)
			3: dialogue_requested.emit("夜巡守卫", "那个人是我？", 0.72)
			4: dialogue_requested.emit("瑟芙琳", "跳完这支舞，你自然会想起来。", 1.00)
			5: title_requested.emit("THE HOLLOW DUCHESS, SERAPHINE", "空心公爵夫人·瑟芙琳")
		_intro_marker += 1


func _process_phase_markers() -> void:
	if _phase_marker == 0 and phase_progress >= 0.12:
		_phase_marker = 1
		dialogue_requested.emit("瑟芙琳", "礼仪已经结束。", 0.85)
	if _phase_marker == 1 and phase_progress >= 0.68:
		_phase_marker = 2
		phase_02_revealed.emit()
		title_requested.emit("THE HOLLOW DUCHESS, UNMASKED", "无面公爵夫人")


func _install_animation(name: StringName, duration: float, property_name: StringName) -> void:
	var library: AnimationLibrary
	if animation_player.has_animation_library(&""):
		library = animation_player.get_animation_library(&"")
	else:
		library = AnimationLibrary.new()
		animation_player.add_animation_library(&"", library)
	if library.has_animation(name):
		return
	var animation := Animation.new()
	animation.length = duration
	animation.loop_mode = Animation.LOOP_NONE
	var track: int = animation.add_track(Animation.TYPE_VALUE)
	animation.track_set_path(track, NodePath(".:%s" % property_name))
	animation.track_set_interpolation_type(track, Animation.INTERPOLATION_LINEAR)
	animation.track_insert_key(track, 0.0, 0.0)
	animation.track_insert_key(track, duration, 1.0)
	library.add_animation(name, animation)


func _draw() -> void:
	# The presentation stays behind actors: sequential candles/phantom dancers for intro.
	var lit: int = floori(intro_progress * 10.0)
	for index: int in range(10):
		var x: float = -760.0 + float(index) * 170.0
		draw_line(Vector2(x, -50), Vector2(x, -86), Color("71604d"), 5.0)
		if index < lit:
			draw_circle(Vector2(x, -96), 9.0, Color(0.88, 0.52, 0.28, 0.82))
			draw_circle(Vector2(x, -96), 18.0, Color(0.65, 0.16, 0.20, 0.16))
	if intro_progress > 0.25 and intro_progress < 0.82:
		var ghost_alpha: float = sin(intro_progress * PI) * 0.24
		for index: int in range(5):
			var x: float = -560.0 + float(index) * 280.0
			draw_circle(Vector2(x, -160), 24.0, Color(0.72, 0.78, 0.86, ghost_alpha))
			draw_rect(Rect2(x - 20, -136, 40, 90), Color(0.36, 0.28, 0.46, ghost_alpha), true)
	# Phase presentation extinguishes candles, adds restrained crimson soul mist and shards.
	if phase_progress > 0.0:
		var fog_alpha: float = sin(phase_progress * PI) * 0.26
		draw_rect(Rect2(-1500, -720, 3000, 720), Color(0.20, 0.01, 0.05, fog_alpha), true)
		for shard: int in range(floori(phase_progress * 13.0)):
			var x: float = -44.0 + float((shard * 17) % 88)
			var y: float = -80.0 - float((shard * 23) % 120)
			draw_rect(Rect2(x, y, 4, 4), Color(0.84, 0.81, 0.80, 0.86), true)
