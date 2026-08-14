class_name SoulGaolerOrmundConfig
extends EnemyGroundConfig

@export_category("Shared encounter")
@export_range(1, 1000, 1) var total_health: int = 460
@export_range(0.1, 0.9, 0.01) var phase_two_threshold_ratio: float = 0.55
@export var phase_transition_duration: float = 2.0
@export var phase_two_opening_telegraph: float = 1.40
@export var phase_two_opening_active: float = 0.24
@export var phase_two_opening_recovery: float = 0.85
@export var phase_two_opening_damage: int = 40

@export_category("Phase I")
@export_range(0.1, 1.0, 0.01) var phase_one_damage_multiplier: float = 0.90
@export_range(1, 400, 1) var phase_one_poise: int = 130
@export var phase_one_stagger_duration: float = 0.82
@export var phase_one_stagger_protection: float = 3.4
@export var phase_one_player_turn_duration: float = 1.05
@export var phase_one_turn_duration: float = 0.50
@export_range(1, 4, 1) var phase_one_combo_budget: int = 2

@export_category("Phase II")
@export_range(0.1, 1.0, 0.01) var phase_two_damage_multiplier: float = 0.84
@export_range(1, 400, 1) var phase_two_poise: int = 158
@export var phase_two_stagger_duration: float = 0.65
@export var phase_two_stagger_protection: float = 3.8
@export var phase_two_player_turn_duration: float = 0.82
@export var phase_two_turn_duration: float = 0.40
@export_range(1, 4, 1) var phase_two_combo_budget: int = 2
@export_range(2, 4, 1) var phase_two_extended_combo_budget: int = 3
@export_range(2, 8, 1) var phase_two_extended_combo_period: int = 4

@export_category("P1 actions")
@export var halberd_sweep_damage: int = 18
@export var anchor_slam_damage: int = 22
@export var hook_drag_damage: int = 15
@export var floodgate_charge_damage: int = 19
@export var soul_cage_pulse_damage: int = 14

@export_category("P2 actions")
@export var chainstorm_cleave_damage: int = 21
@export var undertow_pull_damage: int = 17
@export var cell_rupture_damage: int = 23
@export var soul_shackle_damage: int = 16
@export var flooded_judgment_damage: int = 25
@export var judgment_cooldown: float = 10.0

@export_category("Action rhythm")
@export var soul_cage_pulse_cooldown: float = 7.5
@export var cell_rupture_cooldown: float = 5.0
@export var wall_pressure_margin: float = 170.0
@export var javelin_phase_one_cooldown: float = 6.0
@export var javelin_phase_two_cooldown: float = 5.0
@export var javelin_minimum_distance: float = 142.0
@export var javelin_speed: float = 520.0
@export var javelin_direction_lock: float = 0.25
@export var verdict_direction_lock: float = 0.28
@export var iron_grave_telegraph: float = 0.88
@export var iron_grave_second_wave_delay: float = 0.52
@export var iron_grave_second_wave_telegraph: float = 0.74

@export_group("Phase I timings", "phase_one_")
@export var phase_one_halberd_sweep_timing: Vector3 = Vector3(0.60, 0.15, 0.90)
@export var phase_one_anchor_slam_timing: Vector3 = Vector3(0.82, 0.17, 1.48)
@export var phase_one_hook_drag_timing: Vector3 = Vector3(0.70, 0.14, 1.12)
@export var phase_one_floodgate_charge_timing: Vector3 = Vector3(0.66, 0.24, 1.08)
@export var phase_one_soul_cage_pulse_timing: Vector3 = Vector3(0.78, 0.16, 1.18)
@export var phase_one_drowned_javelin_timing: Vector3 = Vector3(0.82, 0.12, 0.92)
@export var phase_one_gaolers_verdict_timing: Vector3 = Vector3(1.12, 0.22, 1.42)
@export var phase_one_iron_grave_timing: Vector3 = Vector3(0.88, 0.24, 1.00)

@export_group("Phase II timings", "phase_two_")
@export var phase_two_chainstorm_timing: Vector3 = Vector3(0.58, 0.22, 1.15)
@export var phase_two_undertow_timing: Vector3 = Vector3(0.72, 0.18, 0.74)
@export var phase_two_cell_rupture_timing: Vector3 = Vector3(0.88, 0.18, 1.32)
@export var phase_two_soul_shackle_timing: Vector3 = Vector3(0.64, 0.14, 0.76)
@export var phase_two_flooded_judgment_timing: Vector3 = Vector3(1.02, 0.24, 1.62)
@export var phase_two_drowned_javelin_timing: Vector3 = Vector3(0.72, 0.12, 0.82)
@export var phase_two_gaolers_verdict_timing: Vector3 = Vector3(0.94, 0.22, 1.22)
@export var phase_two_iron_grave_timing: Vector3 = Vector3(0.88, 1.50, 0.84)

@export_category("New attack damage")
@export var drowned_javelin_damage: int = 22
@export var gaolers_verdict_direct_damage: int = 28
@export var gaolers_verdict_shockwave_damage: int = 18
@export var iron_grave_damage: int = 22


func action_timing(action: StringName) -> Vector3:
	match action:
		&"halberd_sweep": return phase_one_halberd_sweep_timing
		&"chain_anchor_slam": return phase_one_anchor_slam_timing
		&"prison_hook_drag": return phase_one_hook_drag_timing
		&"floodgate_charge": return phase_one_floodgate_charge_timing
		&"soul_cage_pulse": return phase_one_soul_cage_pulse_timing
		&"drowned_javelin": return phase_one_drowned_javelin_timing if phase_one_drowned_javelin_timing.x > 0.0 else Vector3(0.82, 0.12, 0.92)
		&"gaolers_verdict": return phase_one_gaolers_verdict_timing
		&"iron_grave": return phase_one_iron_grave_timing
		&"chainstorm_cleave": return phase_two_chainstorm_timing
		&"undertow_pull": return phase_two_undertow_timing
		&"drowned_cell_rupture": return phase_two_cell_rupture_timing
		&"soul_shackle": return phase_two_soul_shackle_timing
		&"flooded_judgment": return phase_two_flooded_judgment_timing
	return Vector3(0.60, 0.15, 0.90)


func action_timing_for_phase(action: StringName, current_phase: int) -> Vector3:
	if current_phase == 2:
		match action:
			&"drowned_javelin": return phase_two_drowned_javelin_timing
			&"gaolers_verdict": return phase_two_gaolers_verdict_timing
			&"iron_grave": return phase_two_iron_grave_timing
	return action_timing(action)


func player_turn_duration(current_phase: int) -> float:
	return phase_one_player_turn_duration if current_phase == 1 else phase_two_player_turn_duration


func turn_duration(current_phase: int) -> float:
	return phase_one_turn_duration if current_phase == 1 else phase_two_turn_duration
