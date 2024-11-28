extends State

func enter() -> void:
	player.move.emit()
	player.start_jump.connect(_jump)
	
func exit() -> void:
	player.start_jump.disconnect(_jump)
	
func physics_update(delta: float) -> void:
	player.apply_gravity(delta)
	player.speed = min(player.MAX_SPEED, player.speed + player.acc * delta)
	player.velocity.x = player.speed
	player.move_and_slide()

func _jump() -> void:
	player.start_jumping()
