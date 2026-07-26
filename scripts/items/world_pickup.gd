class_name WorldPickup
extends Area2D

@export_range(1.0, 120.0, 0.5) var lifetime: float = 20.0
@export_range(0.5, 10.0, 0.5) var blink_duration: float = 3.0

var _age: float = 0.0
var _consumed: bool = false


func _ready() -> void:
	body_entered.connect(_on_body_entered)
	call_deferred("_start_pop")


func _start_pop() -> void:
	if not is_inside_tree() or _consumed:
		return
	var start_position: Vector2 = position
	var tween: Tween = create_tween()
	tween.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "position:y", start_position.y - 14.0, 0.18)
	tween.set_ease(Tween.EASE_IN)
	tween.tween_property(self, "position:y", start_position.y, 0.28)


func _process(delta: float) -> void:
	if _consumed or lifetime <= 0.0:
		return
	_age += delta
	if _age >= lifetime:
		queue_free()
		return
	if _age >= lifetime - blink_duration:
		visible = int(_age * 8.0) % 2 == 0


func set_pickup_amount(_amount: int) -> void:
	pass


func _on_body_entered(_body: Node2D) -> void:
	pass


func _consume() -> void:
	if _consumed:
		return
	_consumed = true
	# Consumption can occur inside Area2D's body_entered dispatch.
	set_deferred("monitoring", false)
	queue_free()
