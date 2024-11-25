extends HBoxContainer
class_name LobbyPlayer

var text: String: set = set_text
var is_ready: bool: set = set_ready

func set_text(value: String) -> void:
	text = value
	$Label.text = value
	
func set_ready(value: bool) -> void:
	is_ready = value
	$Ready.visible = value
