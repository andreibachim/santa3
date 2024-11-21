extends Control
@onready var server_address = $CenterContainer/VBoxContainer/HBoxContainer/ServerAddress
@onready var lobby_form = $CenterContainer/VBoxContainer/MarginContainer/HBoxContainer
@onready var join = $CenterContainer/VBoxContainer/MarginContainer/HBoxContainer/Join
@onready var create = $CenterContainer/VBoxContainer/MarginContainer/HBoxContainer/Create
@onready var nickname = $CenterContainer/VBoxContainer/MarginContainer/HBoxContainer/Nickname
@onready var join_lobby_dialog := $CenterContainer/JoinLobbyDialog
@onready var lobby_id_edit := $CenterContainer/JoinLobbyDialog/LobbyId
var game_template := preload("res://screens/game/Game.tscn")

func _ready() -> void:
	if OS.get_cmdline_args().has("server"):
		create_lobby_server()
	else:
		nickname.editable = false
		join.disabled = true
		create.disabled = true
		join_lobby_dialog.register_text_enter(lobby_id_edit)
		join_lobby_dialog.confirmed.connect(func(): join_game(int(lobby_id_edit.text)))

func create_lobby_server() -> void:
	get_children().all(func(i): i.queue_free())
	var peer = WebSocketMultiplayerPeer.new()
	peer.create_server(7000)
	multiplayer.multiplayer_peer = peer

func _on_connect_button_up() -> void:
	var peer = WebSocketMultiplayerPeer.new()
	peer.create_client("ws://" + server_address.text + ":7000")
	multiplayer.multiplayer_peer = peer
	multiplayer.connected_to_server.connect(func():
		nickname.editable = true
		nickname.grab_focus()
		join.disabled = false
		create.disabled = false
		server_address.editable = false
	)
	
func _on_create_button_up() -> void:
	create_game.rpc_id(1)
	
@rpc("any_peer", "call_remote", "reliable")
func create_game() -> void:
	var lobby_id: int = randi_range(65000, 65100)
	var mp = SceneMultiplayer.new()
	get_tree().set_multiplayer(mp, "/root/" + str(lobby_id))
	var peer = WebSocketMultiplayerPeer.new()
	peer.create_server(lobby_id)
	mp.multiplayer_peer = peer
	var game = game_template.instantiate()
	game.name = str(lobby_id)
	get_tree().root.add_child(game)
	join_game.rpc_id(multiplayer.get_remote_sender_id(), lobby_id)
	
@rpc("authority", "call_remote", "reliable")
func join_game(id: int) -> void:
	var mp = SceneMultiplayer.new()
	get_tree().set_multiplayer(mp, "/root/" + str(id))
	var peer = WebSocketMultiplayerPeer.new()
	peer.create_client("ws://" + server_address.text + ":" + str(id))
	mp.multiplayer_peer = peer
	var game: Game = game_template.instantiate()
	game.name = str(id)
	game.player_name = nickname.text
	get_tree().root.add_child(game)
	queue_free()

func _on_join_pressed() -> void:
	join.release_focus()
	join_lobby_dialog.popup()
	lobby_id_edit.grab_focus()
