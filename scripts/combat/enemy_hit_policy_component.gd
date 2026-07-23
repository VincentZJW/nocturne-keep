class_name EnemyHitPolicyComponent
extends Node

## Optional Hurtbox policy. Returning zero consumes a blocked hit without Health loss.


func resolve_damage(hitbox: HitboxComponent) -> int:
	return hitbox.damage if hitbox != null else 0
