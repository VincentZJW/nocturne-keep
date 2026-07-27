class_name HollowDuchessHitPolicy
extends EnemyHitPolicyComponent

## Applies only Seraphine's Phase 2 soul-armour mitigation. Player weapon data remains authoritative.

@export_node_path("HollowDuchess") var boss_path: NodePath = NodePath("..")

@onready var boss: HollowDuchess = get_node_or_null(boss_path) as HollowDuchess


func resolve_damage(hitbox: HitboxComponent) -> int:
	if hitbox == null:
		return 0
	if boss == null or boss.get_phase() < 2:
		return hitbox.damage
	return maxi(1, roundi(float(hitbox.damage) * boss.config.phase_2_incoming_damage_multiplier))
