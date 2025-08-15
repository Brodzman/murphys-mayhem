extends Control

@onready var mop: Button = $mop

var mouse_held = false

func _ready() -> void:
	pass


func _on_button_button_down() -> void:
	mouse_held = true

func _on_cloth_button_up() -> void:
	mouse_held = false
		
		
func _process(delta: float) -> void:
	if mouse_held == true:
		$mop.set_position(get_global_mouse_position())
		
		


func _on_puddle_mouse_entered() -> void:
	$Puddle.visible = false
