extends Node3D

@onready var pause_menu = $pausemenu
@onready var restart_menu = $restartmenu
var paused = false
var restartmenu = false 

func _ready() -> void:
	paused = false
	restartmenu = false 

func _process(delta):
	if Input.is_action_just_pressed("return-to-menu"):
		toggle_pause()
	if Input.is_action_just_pressed("restart"):
		toggle_restartmenu()


func toggle_restartmenu():
	restartmenu = !restartmenu
	
	if restartmenu:
		restart_menu.show()
		Engine.time_scale = 0.0000000001
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE) 
	else:
		pause_menu.hide()
		Engine.time_scale = 1
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)  

func toggle_pause():
	if paused: 
		pause_menu.hide()
		Engine.time_scale = 1
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)  
		
	else:
		pause_menu.show()
		Engine.time_scale = 0.0000000001
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE) 
		
		
	paused = !paused
	
	
	


func _on_food_food_in_hand() -> void:
	pass # Replace with function body.
