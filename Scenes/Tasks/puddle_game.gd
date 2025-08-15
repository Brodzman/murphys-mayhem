extends Control

@onready var mop: Button = $mop

signal mop_held(value)

var mouse_held = false

func _ready() -> void:
	pass


func _on_button_button_down() -> void:
	mouse_held = true
	emit_signal("mop_held", mouse_held)

func _on_cloth_button_up() -> void:
	mouse_held = false
	emit_signal("mop_held", mouse_held)
		
		
func _process(delta: float) -> void:
	if mouse_held == true:
		$mop.set_position(get_global_mouse_position())
		
		
