extends Control

@onready var player_list := $VBoxContainer/PlayerList
@onready var start_button := $VBoxContainer/Buttons/Start

# Runs on the server
@rpc("any_peer", "call_remote", "reliable")
func player_joined():
	print(multiplayer)
	var player = preload("res://test/test.tscn").instantiate()
	player_list.add_child(player, true)
	player.text = "Player " + str(player_list.get_children().size())
	if player_list.get_children().size() > 1:
		start_button.disabled = false

func set_id(id: String) -> void:
	$VBoxContainer/LobbyId.text = id
