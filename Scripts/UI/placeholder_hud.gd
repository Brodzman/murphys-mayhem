extends Node

#Tasks are displayed under TaskList node
@onready var task_list: VBoxContainer = %TaskList

#Individual task scene
var NewTask = preload("res://new_task.tscn")

func _ready():
	# Connect task starting signals
	$"../TaskManager".connect("task_call", Callable(self, "_on_phone_task"))
	$"../TaskManager".connect("task_plant", Callable(self, "_on_plant_task"))
	$"../TaskManager".connect("task_mop", Callable(self, "_on_mop_task"))
	$"../TaskManager".connect("task_tv", Callable(self, "_on_tv_task"))
	$"../TaskManager".connect("task_muffin", Callable(self, "_on_muffin_task"))
	
	# Connect task complete signals
	$"../Greybox/Phone".connect("spam_call_done", Callable(self, "_on_spam_call_done"))
	$"../Greybox/Phone".connect("friend_call_done", Callable(self, "_on_friend_call_done"))
	$"../Greybox/TV".connect("tv_done", Callable(self, "_on_watch_done"))
	$"../Greybox/PlantShape".connect("water_done", Callable(self, "_on_water_done"))
	$"../Greybox/Puddle".connect("mop_done", Callable(self, "_on_mop_done"))
	$"../Greybox/NavigationRegion3D/FINAL 3D ASSETS/MuffinManager".connect("muffin_done", Callable(self, "_on_muffin_done"))
	$"../Greybox/NavigationRegion3D/FINAL 3D ASSETS/MuffinManager".connect("all_muffins_done", Callable(self, "_all_muffins_done"))
	

#Spawns a new task
func spawn_task(description = ""):
	var new_task = NewTask.instantiate()
	task_list.add_child(new_task)
	var task_label = new_task.find_child("TaskLabel")
	task_label.text = description

func remove_task():
	queue_free()
	
	
# Functions for when recieving the task
func _on_phone_task(task, description):
	spawn_task(description)
	
func _on_plant_task(task, description):
	spawn_task(description)

func _on_mop_task(task, description):
	spawn_task(description)

func _on_tv_task(task, description):
	spawn_task(description)
	
func _on_muffin_task(task, description):
	spawn_task(description)





# Functions for when completing the task
func _on_spam_call_done():
	remove_task()
	
func _on_friend_call_done():
	remove_task()
	
func _on_watch_done():
	remove_task()
	
func _on_water_done():
	remove_task()
	
func _on_mop_done():
	remove_task()
	
func _on_muffin_done():
	remove_task()
	
func _all_muffins_done():
	remove_task()
