extends Control

var mouse_held = false

func _ready() -> void:
	$"..".connect("mop_held", Callable(self, "_on_mop_held_done"))

func _on_puddle_mouse_entered() -> void:
	if mouse_held == true:
		visible = false

func _on_mop_held_done(value):
	mouse_held = value
