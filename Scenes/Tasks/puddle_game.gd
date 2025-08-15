extends Control

@onready var mop: Button = $mop

var puddle = load("res://Scenes/Tasks/puddle.tscn")
var puddle_amount = 3

signal mop_held(value)

var mouse_held = false

func _ready() -> void:
	var spawn_points = [
		$SpawnPoint1.position,
		$SpawnPoint2.position,
		$SpawnPoint3.position,
		$SpawnPoint4.position,
		$SpawnPoint5.position,
		$SpawnPoint6.position,
	]
	for amount in puddle_amount:
		var new_puddle = puddle.instantiate()
		add_child(new_puddle)
		new_puddle.connect("mopped", Callable(self, "_on_mopped"))
		spawn_points.shuffle()
		new_puddle.position = spawn_points[0]
		spawn_points.remove_at(0)

func _on_mopped():
	puddle_amount -= 1
	if puddle_amount == 0:
		print("win")

func _on_button_button_down() -> void:
	mouse_held = true
	emit_signal("mop_held", mouse_held)

func _on_cloth_button_up() -> void:
	mouse_held = false
	emit_signal("mop_held", mouse_held)
		
		
func _process(delta: float) -> void:
	if mouse_held == true:
		mop.set_position(get_global_mouse_position())
		
		
