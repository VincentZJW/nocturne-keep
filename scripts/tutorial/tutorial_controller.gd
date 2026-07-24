class_name TutorialController
extends Node

## Event-driven, scene-local tutorial. Progress survives Player respawns because
## this controller belongs to Main rather than to the Player instance.

signal tutorial_step_changed(step_index: int, step_name: StringName)
signal tutorial_completed

enum Step {
	MOVE,
	JUMP,
	DOUBLE_JUMP,
	NORMAL_ATTACK,
	DODGE,
	TWO_ENEMIES,
	DASH,
	PLATFORM_COMBAT,
	SHIELD,
	DASH_ATTACK,
	AIR_DASH,
	COMPLETE,
}

const STEP_NAMES: Array[StringName] = [
	&"move", &"jump", &"double_jump", &"normal_attack", &"dodge",
	&"two_enemies", &"dash", &"platform_combat", &"shield",
	&"dash_attack", &"air_dash", &"complete",
]
const TITLES: Array[String] = [
	"MOVEMENT", "JUMP", "DOUBLE JUMP", "ATTACK", "EVADE", "TWO FOES",
	"DASH", "PLATFORM COMBAT", "SHIELD", "DASH ATTACK", "AIR DASH", "",
]
const ZH_TEXTS: Array[String] = [
	"使用 A / D 或方向键移动", "按 Space 跳跃", "在空中再次按 Space 二段跳",
	"按 J 使双匕首前刺", "观察前摇，后退或跳跃躲开攻击", "同时处理两名守卫",
	"按 Shift 冲刺", "利用平台高度攻击守卫", "正面攻击会被盾牌格挡，绕到背后",
	"冲刺中按 J 发动冲刺攻击", "在空中按 Shift 越过断台", "",
]
const EN_TEXTS: Array[String] = [
	"Move with A / D or the arrow keys", "Press Space to jump",
	"Press Space again in the air to double jump", "Press J to thrust both daggers",
	"Read the windup; step back or jump clear", "Handle two guards together",
	"Press Shift to dash", "Use the platform height to attack",
	"Front attacks are blocked; get behind the shield",
	"Press J during a dash to perform Dash Attack", "Press Shift in the air to cross the gap", "",
]

@export_node_path("Player") var player_path: NodePath = NodePath("../World/Player")
@export_node_path("TutorialPromptUI") var prompt_ui_path: NodePath = NodePath(
	"../HUD/TutorialPrompt"
)
@export_node_path("Node2D") var encounters_root_path: NodePath = NodePath(
	"../World/Encounters"
)
@export var movement_distance_required: float = 72.0
@export var air_dash_target_x: float = 2480.0

@onready var player: Player = get_node_or_null(player_path) as Player
@onready var prompt_ui: TutorialPromptUI = get_node_or_null(prompt_ui_path) as TutorialPromptUI
@onready var encounters_root: Node2D = get_node_or_null(encounters_root_path) as Node2D

var current_step: Step = Step.MOVE
var completed_steps: PackedByteArray = PackedByteArray()
var _start_x: float = 0.0
var _air_dash_seen: bool = false
var _shield_hit_seen: bool = false


func _ready() -> void:
	completed_steps.resize(Step.COMPLETE)
	if player == null or prompt_ui == null or encounters_root == null:
		push_error("TutorialController requires Player, TutorialPromptUI, and Encounters")
		return
	_start_x = player.global_position.x
	player.jump_performed.connect(_on_jump_performed)
	player.double_jump_performed.connect(_on_double_jump_performed)
	player.action_controller.action_started.connect(_on_action_started)
	for child: Node in encounters_root.get_children():
		var encounter: EncounterGroup = child as EncounterGroup
		if encounter == null:
			continue
		encounter.encounter_activated.connect(_on_encounter_activated)
		encounter.encounter_cleared.connect(_on_encounter_cleared)
	_connect_shield_feedback()
	prompt_ui.show_location("鸦泣城郊", "Ravenmourn Outskirts", 2.0)
	get_tree().create_timer(2.1).timeout.connect(_show_current_prompt)


func _process(_delta: float) -> void:
	if player == null or player.is_dead():
		return
	if current_step == Step.MOVE and absf(player.global_position.x - _start_x) >= movement_distance_required:
		_complete_current_step()
	elif current_step == Step.AIR_DASH and _air_dash_seen and player.global_position.x >= air_dash_target_x:
		_complete_current_step()


func reset_tutorial_progress() -> void:
	completed_steps.fill(0)
	current_step = Step.MOVE
	_air_dash_seen = false
	_shield_hit_seen = false
	_start_x = player.global_position.x if player != null else 0.0
	_show_current_prompt()


func replay_opening_cinematic() -> void:
	get_tree().change_scene_to_file("res://scenes/cinematics/opening_cinematic.tscn")


func _show_current_prompt() -> void:
	if current_step >= Step.COMPLETE:
		prompt_ui.hide_prompt()
		return
	prompt_ui.show_prompt(TITLES[current_step], ZH_TEXTS[current_step], EN_TEXTS[current_step])
	tutorial_step_changed.emit(current_step, STEP_NAMES[current_step])


func _complete_current_step() -> void:
	if current_step >= Step.COMPLETE:
		return
	completed_steps[current_step] = 1
	current_step = (current_step + 1) as Step
	if current_step == Step.COMPLETE:
		prompt_ui.hide_prompt()
		tutorial_completed.emit()
		return
	_show_current_prompt()


func _on_jump_performed(_from_coyote_time: bool) -> void:
	if current_step == Step.JUMP:
		_complete_current_step()


func _on_double_jump_performed(_remaining: int) -> void:
	if current_step == Step.DOUBLE_JUMP:
		_complete_current_step()


func _on_action_started(action_name: StringName) -> void:
	if current_step == Step.NORMAL_ATTACK and action_name == &"attack":
		_complete_current_step()
	elif current_step == Step.DASH and action_name in [&"ground_dash", &"air_dash"]:
		_complete_current_step()
	elif current_step == Step.DASH_ATTACK and action_name == &"dash_attack":
		_complete_current_step()
	elif current_step == Step.AIR_DASH and action_name == &"air_dash":
		_air_dash_seen = true


func _on_encounter_activated(encounter_name: StringName) -> void:
	if current_step == Step.SHIELD and encounter_name == &"TutorialEncounter05":
		_show_current_prompt()


func _on_encounter_cleared(encounter_name: StringName) -> void:
	if current_step == Step.DODGE and encounter_name == &"TutorialEncounter02":
		_complete_current_step()
	elif current_step == Step.TWO_ENEMIES and encounter_name == &"TutorialEncounter03":
		_complete_current_step()
	elif current_step == Step.PLATFORM_COMBAT and encounter_name == &"TutorialEncounter04":
		_complete_current_step()
	elif current_step == Step.SHIELD and encounter_name == &"TutorialEncounter05":
		_complete_current_step()


func _connect_shield_feedback() -> void:
	var shield_guard: CursedShieldGuard
	for child: Node in encounters_root.get_children():
		var encounter: EncounterGroup = child as EncounterGroup
		if encounter == null or encounter.encounter_name != &"TutorialEncounter05":
			continue
		for enemy: EnemyCombatant in encounter.get_enemies():
			shield_guard = enemy as CursedShieldGuard
			if shield_guard != null and shield_guard.shield_component != null:
				shield_guard.shield_component.shield_hit.connect(_on_tutorial_shield_hit)
				return


func _on_tutorial_shield_hit(
	_hitbox: HitboxComponent, _applied_damage: int, _remaining: int
) -> void:
	_shield_hit_seen = true
	if current_step == Step.SHIELD:
		_complete_current_step()
