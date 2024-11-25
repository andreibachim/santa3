extends Node2D

var player_path: NodePath
var character: String: set = set_character

var santa_sprite_frame = preload("res://avatar/santa.tres")
var grinch_sprite_frame = preload("res://avatar/grinch.tres")
var elf_sprite_frame = preload("res://avatar/elf.tres")
var reindeer_sprite_frame = preload("res://avatar/reindeer.tres")

func _ready() -> void:
	if multiplayer.get_unique_id() == name.to_int():
		var camera = Camera2D.new()
		camera.offset = Vector2(60, -30)
		add_child(camera)
		$Label.visible = true
		z_index = 10
	if multiplayer.is_server():
		print("hello")
		print("Hello, %s" % player_path)
		#var player: Player = get_tree().root.get_node(player_path)
		#player.jump.connect(_jump)

@rpc("authority", "call_local", "reliable")
func set_character(value: String) -> void:
	$Sprite.sprite_frames = santa_sprite_frame
	return
	match value:
		"santa":
			$Sprite.sprite_frames = santa_sprite_frame
		"grinch":
			$Sprite.sprite_frames = grinch_sprite_frame
		"elf":
			$Sprite.sprite_frames = elf_sprite_frame
		"reindeer":
			$Sprite.sprite_frames = reindeer_sprite_frame

@rpc("authority", "call_local", "reliable")
func set_player_path(path: NodePath) -> void:
	player_path = path
	
func _jump() -> void:
	print("should print")
