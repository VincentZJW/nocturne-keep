class_name Chapter03ScribeWardPolicy
extends EnemyHitPolicyComponent

signal ward_changed(active: bool)

@export var cooldown: float = 4.0
var ward_active: bool = true
var cooldown_timer: float = 0.0


func advance(delta: float) -> void:
	if ward_active:
		return
	cooldown_timer = maxf(0.0, cooldown_timer - delta)
	if cooldown_timer <= 0.0:
		ward_active = true
		ward_changed.emit(true)


func resolve_damage(hitbox: HitboxComponent) -> int:
	if hitbox == null or not ward_active:
		return super.resolve_damage(hitbox)
	ward_active = false
	cooldown_timer = cooldown
	ward_changed.emit(false)
	if hitbox.attack_kind == &"dash_attack":
		return hitbox.damage
	return 0
