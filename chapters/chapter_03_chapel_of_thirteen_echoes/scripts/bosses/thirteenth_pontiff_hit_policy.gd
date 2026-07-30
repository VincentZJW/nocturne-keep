class_name ThirteenthPontiffHitPolicy
extends EnemyHitPolicyComponent

@export_node_path("ThirteenthPontiffEdran") var boss_path: NodePath = NodePath("..")

@onready var boss: ThirteenthPontiffEdran = get_node_or_null(boss_path) as ThirteenthPontiffEdran


func resolve_damage(hitbox: HitboxComponent) -> int:
	if hitbox == null or boss == null:
		return 0
	var multiplier: float = (
		boss.config.phase_02_incoming_damage_multiplier
		if boss.is_phase_02()
		else boss.config.incoming_damage_multiplier
	)
	return maxi(1, roundi(float(hitbox.damage) * multiplier))
