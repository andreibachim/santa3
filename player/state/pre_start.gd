extends State

func enter() -> void:
	pass

func exit() -> void:
	pass
	
func physics_update(delta: float) -> void:
	player.velocity.y += 980 * delta
	player.move_and_slide()
