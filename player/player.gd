extends CharacterBody2D
class_name Player 

@warning_ignore("unused_signal")
signal jump

@warning_ignore("unused_signal")
signal stop_jump

const ACC = 60.0
const DRAG = 60.0
const MAX_SPEED = 200.0
const MIN_SPEED = 160.0
const JUMP_VELOCITY = -200.0
var speed = MIN_SPEED
var direction = 1
var jump_force = 0.0

var jumping: bool = false

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		if jumping:
			jump_force = lerp(jump_force, 0.0, 0.05)
		else: 
			jump_force = 0.0
		velocity.y += (980 - jump_force) * delta
		
		#velocity.y += 980 * delta
		speed = max(MIN_SPEED, speed - DRAG * delta)
	else:
		speed = min(MAX_SPEED, speed + ACC * delta)
	velocity.x = direction * speed
	move_and_slide()

func set_avatar(avatar_path: NodePath) -> void:
	$RemoteTransform2D.remote_path = avatar_path

func _on_jump() -> void:
	if is_on_floor():
		velocity.y = JUMP_VELOCITY
		jump_force = 800.0
		jumping = true

func _on_stop_jump() -> void:
	jumping = false
