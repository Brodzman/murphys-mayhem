extends HBoxContainer

func _ready():
	var hud = get_node("../..")
	hud.connect("muffin_finished", Callable(self, "remove_task"))

func remove_task():
	queue_free()
