extends Node2D

var character: String: set = set_character
var player: Player

var santa_sprite_frame: SpriteFrames = preload("res://avatar/santa.tres")
var grinch_sprite_frame: SpriteFrames = preload("res://avatar/grinch.tres")
var elf_sprite_frame: SpriteFrames = preload("res://avatar/elf.tres")
var reindeer_sprite_frame: SpriteFrames = preload("res://avatar/reindeer.tres")

var sprite: AnimatedSprite2D

func _ready() -> void:
	if multiplayer.get_unique_id() == name.to_int():
		var camera = Camera2D.new()
		camera.offset = Vector2(60, -30)
		add_child(camera)
		$Label.visible = true
		z_index = 10
		
func _process(_delta: float) -> void:
	if not multiplayer.is_server(): return
	if player == null: return

@rpc("authority", "call_local", "reliable")
func set_character(value: String) -> void:
	match value:
		"santa":
			sprite = $SantaSprite
		"grinch":
			sprite = $GrinchSprite
		"elf":
			sprite = $ElfSprite
		"reindeer":
			sprite = $ReindeerSprite
	sprite.name = "Sprite"
	sprite.visible = true

@rpc("authority", "call_local", "reliable")
func set_player_path(path: NodePath) -> void:
	player = get_node(path)
	player.idle.connect(_idle)
	player.move.connect(_move)
	player.start_jump.connect(_jump)
	
func _jump() -> void:
	sprite.animation = "jump"
	#santa_sprite_frame.set_animation_loop("move", true)
	#santa_sprite_frame.set_animation_speed("move", 10)
func _move() -> void:
	sprite.animation = "move"
	var frames = sprite.sprite_frames
	frames.set_animation_loop("move", true)
	frames.set_animation_speed("move", 10)

func _idle() -> void:
	sprite.animation = "idle"
