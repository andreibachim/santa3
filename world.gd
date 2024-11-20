extends Node2D

const SERVER: String = "localhost"
const PORT: int = 7000

var avatar_template := preload("res://avatar/Avatar.tscn")
var player_template := preload("res://player/Player.tscn")
var controller_template :=  preload("res://controller/Controller.tscn")
@onready var players := $Players
@onready var avatars := $Avatars
@onready var controllers := $Controllers

func _ready() -> void:
	if OS.get_cmdline_args().has("server"):
		$ServerFlag.visible = true
		create_server()
	else:
		create_client()

func create_server() -> void:
	var peer = ENetMultiplayerPeer.new()
	peer.create_server(PORT)
	multiplayer.multiplayer_peer = peer
	multiplayer.peer_connected.connect(_player_joined)
	
func create_client() -> void:
	var peer = ENetMultiplayerPeer.new()
	peer.create_client(SERVER, PORT)
	multiplayer.multiplayer_peer = peer

func _player_joined(id: int) -> void:
	var player = player_template.instantiate()
	player.name = str(id)
	players.add_child(player)
	
	var avatar = avatar_template.instantiate()
	avatar.name = str(id)
	avatars.add_child(avatar, true)
	
	player.set_avatar(avatar.get_path())
	
	var controller = controller_template.instantiate()
	controller.name = str(id)
	controller.player_path = player.get_path()
	controllers.add_child(controller, true)
