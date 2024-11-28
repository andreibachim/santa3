extends CharacterBody2D
class_name Player 

@warning_ignore("unused_signal")
signal move
@warning_ignore("unused_signal")
signal idle
@warning_ignore("unused_signal")
signal start_jump

const MAX_SPEED: float  = 200
const MIN_SPEED: float = 160

var speed: float = MIN_SPEED
var jump_velocity: float = -200
var drag: float = 60
var acc: float = 30

func set_avatar(avatar_path: NodePath) -> void:
	$RemoteTransform2D.remote_path = avatar_path

func _on_jump() -> void:
	pass
	
func _on_stop_jump() -> void:
	pass
	
func apply_gravity(delta: float) -> void:
	velocity.y += 980 * delta
	
func start_moving() -> void:
	$StateMachine.set_state(StateMachine.States.MOVING)
	
func start_idling() -> void:
	$StateMachine.set_state(StateMachine.States.IDLE)
	
func start_jumping() -> void:
	$StateMachine.set_state(StateMachine.States.JUMP)
