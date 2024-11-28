extends State

func enter() -> void:
	player.idle.emit()
	player.start_jump.connect(_jump)
	get_tree().create_tween().tween_property(
		player, "velocity:x", 
		0.0, 
		randf_range(0.5, 1)
	)

func exit() -> void:
	player.start_jump.disconnect(_jump)
	
func physics_update(delta: float) -> void:
	player.apply_gravity(delta)
	player.move_and_slide()
	
func _jump() -> void:
	player.start_jumping()
