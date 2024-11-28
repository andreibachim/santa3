extends Node2D

var character: String: set = set_character
var player: Player

var santa_sprite_frame: SpriteFrames = preload("res://avatar/santa.tres")
var grinch_sprite_frame: SpriteFrames = preload("res://avatar/grinch.tres")
var elf_sprite_frame: SpriteFrames = preload("res://avatar/elf.tres")
var reindeer_sprite_frame: SpriteFrames = preload("res://avatar/reindeer.tres")

@onready var sprite := $Sprite

func _ready() -> void:
	if multiplayer.get_unique_id() == name.to_int():
		var camera = Camera2D.new()
		camera.offset = Vector2(60, -30)
		add_child(camera)
		$Label.visible = true
		z_index = 10
		santa_sprite_frame.set_animation_loop("move", true)
		santa_sprite_frame.set_animation_speed("move", 10)
		grinch_sprite_frame.set_animation_loop("move", true)
		grinch_sprite_frame.set_animation_speed("move", 10)
		elf_sprite_frame.set_animation_loop("move", true)
		elf_sprite_frame.set_animation_speed("move", 10)
		reindeer_sprite_frame.set_animation_loop("move", true)
		reindeer_sprite_frame.set_animation_speed("move", 10)
		
func _process(_delta: float) -> void:
	if not multiplayer.is_server(): return
	if player == null: return

@rpc("authority", "call_local", "reliable")
func set_character(value: String) -> void:
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
	player = get_node(path)
	player.idle.connect(_idle)
	player.move.connect(_move)
	player.start_jump.connect(_jump)
	
func _jump() -> void:
	sprite.animation = "jump"
	
func _move() -> void:
	sprite.animation = "move"

func _idle() -> void:
	sprite.animation = "idle"
