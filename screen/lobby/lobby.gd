extends Control
class_name Lobby

@onready var player_list := $VBoxContainer/PlayerList
@onready var start_button := $VBoxContainer/Buttons/Start

# Runs on the server
@rpc("any_peer", "call_remote", "reliable")
func player_joined(peer_id: int):
	var player: PlayerName = preload("res://ui/PlayerName.tscn").instantiate()
	player.peer_id = peer_id
	player.text = "Player " + str(player_list.get_children().size() + 1)
	player_list.add_child(player, true)
	if player_list.get_child_count() > 1:
		set_start_button.rpc(false)
	multiplayer.peer_disconnected.connect(func(id: int):
		for player_name: PlayerName in player_list.get_children():
			if (player_name.peer_id == id):
				player_list.remove_child(player_name)
				player_name.queue_free()
				if player_list.get_child_count() == 0:
					queue_free()
				elif player_list.get_child_count() < 2:
					set_start_button.rpc(true)
	)

func set_id(id: String) -> void:
	$VBoxContainer/LobbyId.text = id

func _on_leave_button_up() -> void:
	player_left.rpc_id(1, multiplayer.get_unique_id())
	multiplayer.server_disconnected.connect(func():
		multiplayer.multiplayer_peer = null
		queue_free()
		get_tree().reload_current_scene()
	)
# RUNS ON SERVER
@rpc("any_peer", "call_remote", "reliable")
func player_left(peer_id):
	for player: PlayerName in player_list.get_children():
		if (player.peer_id == peer_id):
			multiplayer.disconnect_peer(peer_id)
			player_list.remove_child(player)
			player.queue_free()
			if player_list.get_child_count() == 0:
				queue_free()
			elif player_list.get_child_count() < 2:
				set_start_button.rpc(true)

@rpc("any_peer", "call_local", "reliable")
func set_start_button(value: bool) -> void:
	start_button.disabled = value
