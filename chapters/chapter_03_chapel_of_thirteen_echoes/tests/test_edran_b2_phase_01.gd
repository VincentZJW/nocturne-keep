extends SceneTree

const BOSS_SCENE: String = "res://chapters/chapter_03_chapel_of_thirteen_echoes/scenes/bosses/thirteenth_pontiff_edran.tscn"
const ROOM_SCENE: String = "res://chapters/chapter_03_chapel_of_thirteen_echoes/scenes/rooms/ch3_boss_sanctum_room.tscn"
const ATTACKS: Array[StringName] = [
	&"pontifical_sweep",
	&"crozier_thrust",
	&"censer_procession",
	&"litany_of_ash",
	&"thirteenfold_sentence",
]

var _failures: Array[String] = []
var _transition_count: int = 0


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var boss_scene: PackedScene = load(BOSS_SCENE) as PackedScene
	var room_scene: PackedScene = load(ROOM_SCENE) as PackedScene
	_check(boss_scene != null, "Boss PackedScene loads")
	_check(room_scene != null, "Boss-sanctum room PackedScene loads")
	if boss_scene == null or room_scene == null:
		_finish()
		return

	var room: Chapter03BossSanctumRoom = room_scene.instantiate() as Chapter03BossSanctumRoom
	var saved_boss: Node2D = room.get_node("BossActors/ThirteenthPontiffEdran") as Node2D
	_check(saved_boss.position == Vector2(1680.0, 584.0), "formal Boss uses the sanctum integration anchor")
	root.add_child(room)
	await process_frame
	_check(room.boss != null, "saved Main room owns the formal Edran instance")
	room.queue_free()
	await process_frame

	var boss: ThirteenthPontiffEdran = boss_scene.instantiate() as ThirteenthPontiffEdran
	root.add_child(boss)
	await process_frame
	_check(boss.config.max_health == 360, "Phase 1 health is 360")
	_check(boss.config.phase_transition_health == 198, "transition boundary is 198 HP")
	_check(is_equal_approx(boss.config.incoming_damage_multiplier, 0.88), "Phase 1 mitigation is 0.88")
	_check(boss.config.max_poise == 110, "Phase 1 Poise is 110")
	_check(boss.current_state == ThirteenthPontiffEdran.State.DORMANT, "Boss starts dormant")
	boss.activate()
	await process_frame
	_check(boss.current_state == ThirteenthPontiffEdran.State.IDLE, "Boss activates into Phase 1 idle")

	for attack_name: StringName in ATTACKS:
		var accepted: bool = boss.debug_force_attack(attack_name)
		_check(accepted, "%s can be started" % attack_name)
		var timeout: float = 0.0
		while boss.current_state == ThirteenthPontiffEdran.State.ATTACK and timeout < 4.0:
			await physics_frame
			timeout += 1.0 / 60.0
		_check(timeout < 4.0, "%s resolves without an infinite lock" % attack_name)
		await process_frame

	var hitbox: HitboxComponent = HitboxComponent.new()
	hitbox.faction = &"player"
	hitbox.attack_kind = &"attack"
	root.add_child(hitbox)
	await process_frame
	hitbox.begin_attack(9001, 14, 1.0, hitbox)
	var health_before: int = boss.health_component.current_health
	var accepted_hit: bool = boss.hurtbox.receive_hit(hitbox)
	_check(accepted_hit, "Player attack is accepted by Boss Hurtbox")
	_check(boss.health_component.current_health == health_before - 12, "14 damage resolves through 0.88 mitigation to 12")
	_check(boss.current_poise == 96, "normal attack removes 14 Poise")
	hitbox.end_attack()

	boss.phase_transition_requested.connect(_on_transition_requested)
	boss.health_component.set_current_health(190)
	await process_frame
	_check(boss.health_component.current_health == 198, "B2 clamps at the B4 boundary")
	_check(_transition_count == 1, "transition request emits exactly once")
	_check(boss.current_state in [ThirteenthPontiffEdran.State.TRANSITION_PENDING,ThirteenthPontiffEdran.State.PHASE_TRANSITION], "B4 consumes the explicit transition boundary")
	await create_timer(boss.config.phase_transition_duration + boss.config.phase_02_ready_delay + 0.25).timeout
	_check(boss.is_phase_02(), "approved B4 transition reaches Phase 2")
	_check(not boss.hurtbox.is_invulnerable, "Boss is vulnerable after the protected transition")

	hitbox.queue_free()
	boss.queue_free()
	await process_frame
	_finish()


func _check(condition: bool, message: String) -> void:
	if not condition:
		_failures.append(message)


func _on_transition_requested(_health: int) -> void:
	_transition_count += 1


func _finish() -> void:
	if _failures.is_empty():
		print("EDRAN_B2_PHASE_01 | PASS attacks=5 health=360 poise=110 main_room=true transition=B4_complete")
		quit(0)
		return
	for failure: String in _failures:
		push_error(failure)
	print("EDRAN_B2_PHASE_01 | FAIL count=%d" % _failures.size())
	quit(1)
