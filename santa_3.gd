extends Node

func _ready() -> void:
	var mp = SceneMultiplayer.new()
	get_tree().set_multiplayer(mp, "/root/LandingScreen")
	var landing_screen = preload("res://screen/landing/LandingScreen.tscn")
	add_child(landing_screen.instantiate())
