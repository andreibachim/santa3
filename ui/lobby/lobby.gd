extends ColorRect

signal player_ready(id: int)

@onready var ready_button := $MarginContainer/VBoxContainer/LobbyControlls/Ready
@onready var leave_button := $MarginContainer/VBoxContainer/LobbyControlls/Leave

func _on_ready_pressed() -> void:
	ready_button.disabled = true
	#leave_button.disabled = true
	_player_ready.rpc_id(1)

@rpc("any_peer", "call_remote", "reliable")
func _player_ready() -> void:
	player_ready.emit(multiplayer.get_remote_sender_id())
