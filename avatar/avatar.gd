extends MeshInstance2D

func _ready() -> void:
	if multiplayer.get_unique_id() == name.to_int():
		var camera = Camera2D.new()
		camera.offset = Vector2(60, -30)
		add_child(camera)
		$Label.visible = true
