class_name Chapter04BossDamagePolicy
extends EnemyHitPolicyComponent

var damage_multiplier: float = 0.82


func resolve_damage(hitbox: HitboxComponent) -> int:
	if hitbox == null:
		return 0
	return maxi(1, roundi(float(hitbox.damage) * clampf(damage_multiplier, 0.1, 1.0)))
