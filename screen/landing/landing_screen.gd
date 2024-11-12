extends Control

@onready var lobby_id_input := $CenterContainer/VBoxContainer/LobbyIdInput
@onready var join_button := $CenterContainer/VBoxContainer/Join
@onready var create_button := $CenterContainer/VBoxContainer/Create

var lobby_template: PackedScene = preload("res://screen/lobby/Lobby.tscn")

func _ready() -> void:
	if (OS.get_cmdline_args().has("--server=true")):
		var mp = multiplayer
		mp.peer_connected.connect(func(id: int): print("Peer connected " + str(id)))
		var peer = ENetMultiplayerPeer.new()
		peer.create_server(7000)
		mp.multiplayer_peer = peer
		$CenterContainer.queue_free()
	else:
		var mp = multiplayer
		print(multiplayer)
		var peer = ENetMultiplayerPeer.new()
		mp.connected_to_server.connect(func(): print("connected to server"));
		peer.create_client("127.0.0.1", 7000)
		mp.multiplayer_peer = peer

func _on_join_button_up() -> void:
	var lobby_id = lobby_id_input.text
	load_lobby(int(lobby_id))

func _on_create_button_up() -> void:
	create_button.disabled = true
	create_lobby.rpc_id(1, multiplayer.get_unique_id())

# Context - runs on server
@rpc("any_peer", "call_remote", "reliable")
func create_lobby(peer_id: int):
	var lobby_id = randi_range(64435, 64535)
	var lobby_mp = SceneMultiplayer.new()
	get_tree().set_multiplayer(lobby_mp, str(get_path()) + "/" + str(lobby_id))
	var lobby_instance = lobby_template.instantiate()
	lobby_instance.name = str(lobby_id)
	lobby_instance.set_id(str(lobby_id))
	add_child(lobby_instance)
	var lobby_peer = ENetMultiplayerPeer.new()
	lobby_peer.create_server(lobby_id)
	lobby_mp.multiplayer_peer = lobby_peer
	print("Lobby is ready with ID: " + str(lobby_id))
	load_lobby.rpc_id(peer_id, lobby_id)

# Runs on clients
@rpc("authority", "call_remote", "reliable")
func load_lobby(lobby_id: int):
	$CenterContainer.queue_free()
	var lobby_instance := lobby_template.instantiate()
	lobby_instance.name = str(lobby_id)
	lobby_instance.set_id(str(lobby_id))
	add_child(lobby_instance)
	
	var lobby_mp = SceneMultiplayer.new()
	lobby_mp.connected_to_server.connect(func(): lobby_instance.player_joined.rpc_id(1))
	get_tree().set_multiplayer(lobby_mp, lobby_instance.get_path())
	var lobby_peer = ENetMultiplayerPeer.new()
	lobby_peer.create_client("127.0.0.1", lobby_id)
	lobby_mp.multiplayer_peer = lobby_peer
