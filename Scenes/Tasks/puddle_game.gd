extends Control

@onready var cloth: Button = $cloth

var mouse_held = false

func _on_button_button_down() -> void:
	mouse_held = true

func _on_cloth_button_up() -> void:
	mouse_held = false
		
		
func _process(delta: float) -> void:
	if mouse_held == true:
		cloth.set_position(get_global_mouse_position())
	
