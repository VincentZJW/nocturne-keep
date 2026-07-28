class_name Chapter03EnemyProjectile
extends Area2D

@export_node_path("HitboxComponent") var hitbox_path: NodePath = NodePath("Hitbox")
@onready var hitbox: HitboxComponent = get_node_or_null(hitbox_path) as HitboxComponent

var velocity: Vector2 = Vector2.ZERO
var lifetime: float = 2.0
var effect_kind: StringName = &"damage"
var slow_multiplier: float = 0.8
var slow_duration: float = 1.0
var _source_id: StringName = &""


func _ready() -> void:
	add_to_group("chapter_03_enemy_projectile")
	body_entered.connect(_on_body_entered)
	if hitbox != null:
		hitbox.hit_confirmed.connect(_on_hit_confirmed)


func launch(
	direction: Vector2,
	speed: float,
	damage: int,
	attack_id: int,
	owner_enemy: Node2D,
	kind: StringName,
	shared_ledger: Dictionary[int, bool] = {},
) -> void:
	velocity = direction.normalized() * speed
	effect_kind = kind
	_source_id = StringName("ch3_%s_%d" % [kind, attack_id])
	if hitbox != null:
		hitbox.attack_kind = kind
		hitbox.set_shared_target_ledger(shared_ledger)
		hitbox.begin_attack(attack_id, damage, signf(direction.x), owner_enemy)
	rotation = direction.angle()


func _physics_process(delta: float) -> void:
	global_position += velocity * delta
	lifetime -= delta
	if lifetime <= 0.0:
		queue_free()


func _on_body_entered(body: Node2D) -> void:
	if body is StaticBody2D or body is TileMapLayer:
		queue_free()


func _on_hit_confirmed(target_hurtbox: HurtboxComponent, _damage: int, _attack_id: int) -> void:
	var player: Player = target_hurtbox.get_parent() as Player
	if player != null and effect_kind == &"binding_script":
		var modifier_source: StringName = _source_id
		player.set_movement_speed_modifier(modifier_source, slow_multiplier)
		var timer: SceneTreeTimer = get_tree().create_timer(slow_duration)
		timer.timeout.connect(func() -> void:
			if is_instance_valid(player):
				player.clear_movement_speed_modifier(modifier_source)
		)
	queue_free()
