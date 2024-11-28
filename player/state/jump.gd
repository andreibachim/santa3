extends State

var airborne = false

func enter() -> void:
	player.velocity.y = -320
	airborne = true

func exit() -> void:
	airborne = false
	
func physics_update(delta: float) -> void:
	player.apply_gravity(delta)
	player.speed = max(player.MIN_SPEED, player.speed - player.drag * delta)
	if player.velocity.x >= player.MIN_SPEED:
		player.velocity.x = player.speed
	player.move_and_slide()
	if player.is_on_floor() and airborne:
		get_parent().revert_to_previous_state()
