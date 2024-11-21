extends MeshInstance2D

var color: Color: set = _set_color

func _ready() -> void:
	if multiplayer.get_unique_id() == name.to_int():
		var camera = Camera2D.new()
		camera.offset = Vector2(60, -30)
		add_child(camera)
		$Label.visible = true
		
func _set_color(value: Color) -> void:
	color = value
	self_modulate = value
