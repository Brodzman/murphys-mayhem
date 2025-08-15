extends Control

@onready var water_can: Button = $WaterCan

var mouse_held = false
var location1_entered = false
var water_needed = 3

		
func _process(delta: float) -> void:
	if mouse_held == true:
		water_can.set_position(get_global_mouse_position())

func _on_water_can_button_down() -> void:
	mouse_held = true

func _on_water_can_button_up() -> void:
	mouse_held = false


func _on_location_1_mouse_entered() -> void:
	if mouse_held == true:
		location1_entered = true


func _on_location_2_mouse_entered() -> void:
	if mouse_held == true and location1_entered == true:
		print("water")
		water_needed -= 1
		if water_needed == 0:
			print("win")
		location1_entered = false
	else:
		location1_entered = false
		
