extends Node2D
class_name Game

var avatar_template := preload("res://avatar/Avatar.tscn")
var player_template := preload("res://player/Player.tscn")
var controller_template :=  preload("res://controller/Controller.tscn")
@onready var players := $Players
@onready var avatars := $Avatars
@onready var controllers := $Controllers

@onready var lobby_players := $Control/Lobby/MarginContainer/VBoxContainer/LobbyPlayers
var lobby_player_template := preload("res://ui/lobby_player/LobbyPlayer.tscn")

@onready var lobby_id_value := $Control/Lobby/MarginContainer/VBoxContainer/LobbyId/LobbyIdValue

var player_name: String

func _ready() -> void:
	lobby_id_value.text = name
	if multiplayer.is_server():
		multiplayer.peer_connected.connect(func(id: int): print("Player %s connected" % id))
		multiplayer.peer_disconnected.connect(_player_left)
	else:
		multiplayer.connected_to_server.connect(
			func(): player_joined.rpc_id(1, player_name)
		)

@rpc("any_peer", "call_remote", "reliable")
func player_joined(nickname) -> void:
	print("Player %s joined" % nickname)
	var lobby_player_instance = lobby_player_template.instantiate()
	lobby_player_instance.name = nickname
	lobby_player_instance.text = nickname
	lobby_players.add_child(lobby_player_instance, true)
	#var player = player_template.instantiate()
	#player.name = str(id)
	#players.add_child(player)
	#
	#var avatar = avatar_template.instantiate()
	#avatar.name = str(id)
	#avatars.add_child(avatar, true)
	#
	#player.set_avatar(avatar.get_path())
	#
	#var controller = controller_template.instantiate()
	#controller.name = str(id)
	#controller.player_path = player.get_path()
	#controllers.add_child(controller, true)

func _player_left(id: int) -> void:
	print("Player %s left" % id)
