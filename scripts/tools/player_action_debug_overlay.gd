class_name PlayerActionDebugOverlay
extends Label

## Optional diagnostics for the internal Main action laboratory. It owns no gameplay state.

@export var debug_visible: bool = true
@export var compact_mode: bool = true
@export_node_path("Player") var player_path: NodePath = NodePath("../../../World/Player")

@onready var player: Player = get_node_or_null(player_path) as Player


func _ready() -> void:
	if player == null:
		push_error("PlayerActionDebugOverlay requires a Player target")
		set_process(false)
		return
	visible = debug_visible
	set_process(debug_visible)
	_refresh_text()


func _process(_delta: float) -> void:
	_refresh_text()


func set_debug_visible(enabled: bool) -> void:
	debug_visible = enabled
	visible = enabled
	set_process(enabled)
	if enabled:
		_refresh_text()


func set_compact_mode(enabled: bool) -> void:
	compact_mode = enabled
	_refresh_text()


func _refresh_text() -> void:
	if player == null:
		return
	var actions: PlayerActionController = player.action_controller
	var stamina: PlayerStaminaComponent = player.stamina_component
	var hurt: PlayerHurtController = player.hurt_controller
	var health: HealthComponent = player.health_component
	var wallet: CurrencyWallet = get_node_or_null("/root/CurrencyManager") as CurrencyWallet
	var equipment: PlayerEquipmentManager = get_node_or_null(
		"/root/EquipmentManager"
	) as PlayerEquipmentManager
	if wallet == null or equipment == null:
		return
	if compact_mode:
		var action_state: String = actions.get_action_state_name()
		var display_state: String = player.get_movement_state_name() if action_state == "None" else action_state
		text = (
			"PLAYER  STATE %s | HP %d/%d | STA %d/%d | COIN %d\n"
			+ "VX %.0f  VY %.0f | DASH %d | HURT %.2f | INV %.2f | WPN %s %d/%d"
		) % [
			display_state,
			health.current_health,
			health.max_health,
			roundi(stamina.current_stamina),
			roundi(stamina.max_stamina),
			wallet.current_coins,
			player.velocity.x,
			player.velocity.y,
			actions.get_current_dash_number(),
			hurt.get_hurt_stun_remaining(),
			hurt.get_invulnerability_remaining(),
			equipment.get_equipped_weapon().weapon_id,
			equipment.get_normal_attack_damage(),
			equipment.get_dash_attack_damage(),
		]
		return
	var response_time: float = actions.get_attack_input_to_hit_time()
	var response_text: String = "--" if response_time < 0.0 else "%.3fs" % response_time
	var regeneration_blocked: bool = actions.is_stamina_regeneration_blocked()
	var regeneration_rate: float = stamina.get_regeneration_rate(player.is_on_floor())
	var regeneration_state: String = "BLOCKED" if regeneration_blocked else (
		"GROUND %.1f/s" % regeneration_rate
		if player.is_on_floor()
		else "AIR %.1f/s" % regeneration_rate
	)
	text = (
		"FLOOR %s   STATE %s/%s   AIR DASH / GROUND DASH TYPE %s   DASH #%d   DIR %+.0f   VX %.1f   VY %.1f\n"
		+ "ANIM %s   STAMINA %.1f/%.1f   REGEN %s %.2fs   DASH BUFFER %s (%.2fs)\n"
		+ "COMBO WINDOW %s   USED %s   ATTACK FRAME %d/4   BUFFERED %s   TIMER %.3fs   CHAIN %s   INPUT→HIT %s\n"
		+ "HEALTH %d/%d   LIFE %s   INVULN %.3fs   HURT STUN %.3fs   LAST DAMAGE %d\n"
		+ "LAST SOURCE (%.1f, %.1f)   KNOCKBACK (%.1f, %.1f)\n"
		+ "COINS %d   WEAPON %s   DAMAGE %d/%d"
	) % [
		"true" if player.is_on_floor() else "false",
		actions.get_action_state_name(),
		player.get_movement_state_name(),
		actions.get_dash_type_name(),
		actions.get_current_dash_number(),
		actions.get_dash_direction(),
		player.velocity.x,
		player.velocity.y,
		player.animation_controller.animated_sprite.animation,
		stamina.current_stamina,
		stamina.max_stamina,
		regeneration_state,
		stamina.stamina_regen_timer,
		"true" if actions.is_dash_buffered() else "false",
		actions.get_dash_buffer_remaining(),
		"OPEN" if actions.is_dash_attack_input_window_open() else "closed",
		"true" if actions.is_dash_attack_used() else "false",
		actions.get_current_attack_frame(),
		"true" if actions.is_attack_buffered() else "false",
		actions.get_attack_buffer_remaining(),
		"OPEN" if actions.can_chain_attack() else "closed",
		response_text,
		health.current_health,
		health.max_health,
		player.get_life_state_name(),
		hurt.get_invulnerability_remaining(),
		hurt.get_hurt_stun_remaining(),
		hurt.get_last_damage(),
		hurt.get_last_source_position().x,
		hurt.get_last_source_position().y,
		hurt.get_last_knockback_velocity().x,
		hurt.get_last_knockback_velocity().y,
		wallet.current_coins,
		equipment.get_equipped_weapon().weapon_id,
		equipment.get_normal_attack_damage(),
		equipment.get_dash_attack_damage(),
	]
