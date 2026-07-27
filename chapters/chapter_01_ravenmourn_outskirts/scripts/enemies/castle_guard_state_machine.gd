class_name CastleGuardStateMachine
extends Node

## Small typed state authority; CastleGuard owns decisions and presentation.

signal state_changed(previous_state: State, current_state: State, state_name: StringName)

enum State {
	IDLE,
	PATROL,
	CHASE,
	ATTACK,
	HURT,
	DEATH,
}

const STATE_NAMES: Dictionary[State, StringName] = {
	State.IDLE: &"Idle",
	State.PATROL: &"Patrol",
	State.CHASE: &"Chase",
	State.ATTACK: &"Attack",
	State.HURT: &"Hurt",
	State.DEATH: &"Death",
}

var current_state: State = State.IDLE


func transition(next_state: State) -> bool:
	if next_state == current_state or current_state == State.DEATH:
		return false
	var previous_state: State = current_state
	current_state = next_state
	state_changed.emit(previous_state, current_state, STATE_NAMES[current_state])
	return true


func get_state_name() -> StringName:
	return STATE_NAMES[current_state]


func is_state(state: State) -> bool:
	return current_state == state
