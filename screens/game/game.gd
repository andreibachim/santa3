extends Node2D
class_name Game

var avatar_template := preload("res://avatar/Avatar.tscn")
var player_template := preload("res://player/Player.tscn")
var controller_template :=  preload("res://controller/Controller.tscn")
var lobby_player_template := preload("res://ui/lobby_player/LobbyPlayer.tscn")

@onready var players := $Players
@onready var avatars := $Avatars
@onready var controllers := $Controllers
@onready var lobby_players := $Control/Lobby/MarginContainer/VBoxContainer/LobbyPlayers
@onready var lobby_id_value := $Control/Lobby/MarginContainer/VBoxContainer/LobbyId/LobbyIdValue
@onready var lobby := $Control/Lobby
@onready var game_ui_layer := $Control/GameUILayer
@onready var countdown_label := $Control/GameUILayer/Countdown/Panel/CenterContainer/CountdownLabel
@onready var barrier := $Barrier
@onready var time_left_container := $Control/GameUILayer/TimeLeftContainer
@onready var time_left := $Control/GameUILayer/TimeLeftContainer/TimeLeft

@onready var first_place_marker := $Podium/FirstPlace/FirstPlaceMarker
@onready var second_place_marker := $Podium/SecondPlace/SecondPlaceMarker
@onready var third_place_marker := $Podium/ThirdPlace/ThirdPlaceMarker
@onready var losers_maker := $Podium/LosersMarker
@onready var podium_camera := $Podium/PodiumCamera
@onready var overlay := $Control/GameUILayer/Overlay

var player_name: String
var colors := [Color.RED, Color.BLUE, Color.GREEN, Color.REBECCA_PURPLE]
var active_players := {}
var result := []

func _ready() -> void:
	lobby.visible = true
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
	var player_details = {
		"id": multiplayer.get_remote_sender_id(),
		"nickname": nickname,
		"color": colors.pop_at(randi_range(0, colors.size() - 1)),
		"ready": false
	}
	active_players[multiplayer.get_remote_sender_id()] = player_details
	var lobby_player_instance: LobbyPlayer = lobby_player_template.instantiate()
	lobby_player_instance.name = str(player_details.id)
	lobby_player_instance.text = nickname
	lobby_player_instance.color = player_details.color
	lobby_player_instance.is_ready = false
	lobby_players.add_child(lobby_player_instance, true)

func _player_left(id: int) -> void:
	print("Player %s left" % id)

func player_ready(id: int) -> void:
	active_players[id].ready = true
	lobby_players.get_node(str(id)).is_ready = true
	if active_players.values().all(func(ap): return ap.ready):
		for ap in active_players.values():
			var player = player_template.instantiate()
			player.name = str(ap.id)
			players.add_child(player)
			
			var avatar = avatar_template.instantiate()
			avatar.name = str(ap.id)
			avatar.color = ap.color
			avatars.add_child(avatar, true)
			
			player.set_avatar(avatar.get_path())
			
			var controller = controller_template.instantiate()
			controller.name = str(ap.id)
			controller.player_path = player.get_path()
			controllers.add_child(controller, true)
		start_game.rpc()
		var tween = get_tree().create_tween().set_loops(6)
		tween.tween_interval(1)
		tween.tween_callback(_tick_countdown.bind(tween))

func _tick_countdown(tween: Tween) -> void:
	var value = tween.get_loops_left() - 1
	var text = "Go!" if value == 0 else str(value)
	countdown_label.text = text
	if value == 0:
		free_barrier.rpc()
	
@rpc("authority", "call_local", "reliable")
func start_game() -> void:
	get_tree().create_tween().tween_property(lobby, "modulate:a", 0, 0.2)
	game_ui_layer.visible = true

@rpc("authority", "call_local", "reliable")
func free_barrier() -> void:
	barrier.queue_free()
	await get_tree().create_tween().tween_property($Control/GameUILayer/Countdown, "modulate:a", 0, 1).finished
	$Control/GameUILayer/Countdown.queue_free()

func _on_finish_line_body_entered(body: Node2D) -> void:
	if result.is_empty():
		start_hurry_up_timer()
	var player: Player = body as Player
	player.finished = true
	result.push_back(active_players[player.name.to_int()])
	if result.size() == active_players.size():
		time_left_container.visible = false
		overlay.visible = true
		await get_tree().create_tween().tween_property(overlay, "modulate:a", 1, 0.1).finished
		podium_camera.enabled = true
		await get_tree().create_tween().tween_property(overlay, "modulate:a", 0, 0.1).finished
		# TODO move players on podium positions
		#for p: Player in players.get_children():
			#p.velocity.x = 0
		#players.get_node(str(result[0].id)).global_position = first_place_marker.global_position
		#players.get_node(str(result[1].id)).global_position = second_place_marker.global_position
		#players.get_node(str(result[2].id)).global_position = third_place_marker.global_position
		#for loser in result.slice(3):
			#players.get_node(str(loser.id)).global_position = losers_maker.global_position

func start_hurry_up_timer() -> void:
	var time := 6
	time_left.text = str(time - 1)
	time_left_container.visible = true
	var tween = get_tree().create_tween().set_loops(time)
	tween.tween_interval(1)
	tween.tween_callback((func(_tween: Tween): 
		var left: int = _tween.get_loops_left() - 1
		time_left.text = str(left)
	).bind(tween))
	await tween.finished
	time_left_container.visible = false
	var array_of_lost_players = []
	for ap in active_players.keys():
		if not result.any(func(r): return r.id == ap):
			array_of_lost_players.push_back(players.get_node(str(ap)))
	array_of_lost_players.sort_custom(func(a,b): return a.position.x > b.position.x)
	for p in array_of_lost_players:
		_on_finish_line_body_entered(p)
