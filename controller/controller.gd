extends Node

var player_path: NodePath
var just_jumped: bool = false
var jumping: bool = false

func _enter_tree() -> void:
	set_multiplayer_authority(name.to_int())

func _ready() -> void:
	if not is_multiplayer_authority():
		set_physics_process(false)

func _physics_process(_delta: float) -> void:
	if Input.is_action_just_pressed("ui_accept"):
		jump.rpc_id(1)
	if Input.is_action_just_released("ui_accept"):
		stop_jump.rpc_id(1)

@rpc("authority", "call_remote", "reliable")
func jump() -> void:
	var player: Player = get_node(player_path)
	player.start_jump.emit()
	
@rpc("authority", "call_remote", "reliable")
func stop_jump() -> void:
	var _player: Player = get_node(player_path)
