extends Node
class_name StateMachine

var player: Player

var available_states: Dictionary = {}
var previous_state: State
var state: State

enum States {
	IDLE,
	MOVING,
	JUMP
}

func _ready() -> void:
	await owner.ready
	player = owner
	available_states[States.IDLE] = $Idle
	available_states[States.MOVING] = $Move
	available_states[States.JUMP] = $Jump
	set_state(States.IDLE)

func set_state(value: States) -> void:
	if state != null: state.exit()
	previous_state = state
	state = available_states[value]
	state.enter()
	
func revert_to_previous_state() -> void:
	if state != null: state.exit()
	state = previous_state
	state.enter()

func _physics_process(delta: float) -> void:
	state.physics_update(delta)
