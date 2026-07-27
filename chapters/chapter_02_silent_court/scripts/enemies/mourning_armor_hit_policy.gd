class_name MourningArmorHitPolicy
extends EnemyHitPolicyComponent

## Applies the approved 25% frontal Normal mitigation and reports Poise impact.

signal poise_impact(amount: int, attack_kind: StringName)

@export_node_path("SilentCourtGroundEnemy") var enemy_path: NodePath = NodePath("..")
@export_range(0.0, 1.0, 0.05) var frontal_normal_multiplier: float = 0.75

@onready var enemy: SilentCourtGroundEnemy = get_node_or_null(enemy_path) as SilentCourtGroundEnemy


func resolve_damage(hitbox: HitboxComponent) -> int:
	if hitbox == null:
		return 0
	var poise_amount: int = 2 if hitbox.attack_kind in [&"dash_attack", &"ground_dash_attack", &"air_dash_attack"] else 1
	poise_impact.emit(poise_amount, hitbox.attack_kind)
	if enemy == null or hitbox.attack_kind != &"normal_attack":
		return hitbox.damage
	var source_offset: float = hitbox.get_source_position().x - enemy.global_position.x
	var is_front: bool = not is_zero_approx(source_offset) and signf(source_offset) == enemy.facing_direction
	if not is_front:
		return hitbox.damage
	return maxi(1, floori(float(hitbox.damage) * frontal_normal_multiplier))
