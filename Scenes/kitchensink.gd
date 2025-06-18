extends Interactable

var dishes
var description_text
var dishes_progress = 0
var dishes_complete = true

signal dishes_done

@onready var task_label: Label = $"../../../../PlaceholderHUD/ColorRect/Task"
@onready var game_over: Label = $"../../../../PlaceholderHUD/ColorRect/GameOver"
@onready var dishes_timer: Timer = $DishesTimer
@onready var node_3d: Node3D = $"../../../.."


func _ready() -> void:
	dishes_progress = 0
	dishes_complete = true
	$"../../TaskManager".connect("task_dishes", Callable(self, "_on_task"))
	visible = false

func _on_task(task, description):
	if task == "task_dishes":
		description_text = description
		dishes = task
		set_collision_layer_value(2, true)
	
	if dishes == "task_dishes":
		dishes_complete = false
		
	dishes_timer.start()
	await dishes_timer.timeout
	if dishes_complete == false:
		game_over.text = ("Toxic mould built from the dishes")
		await get_tree().create_timer(1).timeout
		node_3d.toggle_restartmenu()

func _on_interacted(body: Variant) -> void:
	var new_text
	if dishes == "task_dishes":
		if dishes_progress > 5:
			dishes_timer.stop()
			dishes_complete = true
			set_collision_layer_value(2, false)
			dishes_progress = 0
			new_text = task_label.text.replace(description_text, "")
			task_label.text = new_text
			emit_signal("dishes_done", task_label.text)
		else:
			dishes_progress += 1
