extends Node

@onready var task_list: VBoxContainer = %TaskList
var NewTask = preload("res://new_task.tscn")


# Connect to timers
@onready var muffin_timer: Timer = $"../Greybox/NavigationRegion3D/FINAL 3D ASSETS/MuffinManager/MuffinTimer"
@onready var phone_timer: Timer = $"../Greybox/Phone/PhoneTimer"
@onready var plant_timer: Timer = $"../Greybox/PlantShape/PlantTimer"
@onready var puddle_timer: Timer = $"../Greybox/Puddle/PuddleTimer"
@onready var tv_timer: Timer = $"../Greybox/TV/TVTimer"

# Tracking active tasks
var active_tasks = []  

func _ready():
	# Connect task signals
	$"../TaskManager".connect("task_call", Callable(self, "_on_phone_task"))
	$"../TaskManager".connect("task_plant", Callable(self, "_on_plant_task"))
	$"../TaskManager".connect("task_mop", Callable(self, "_on_mop_task"))
	$"../TaskManager".connect("task_tv", Callable(self, "_on_tv_task"))
	$"../TaskManager".connect("task_muffin", Callable(self, "_on_muffin_task"))

	# Connect completion signals
	$"../Greybox/Phone".connect("spam_call_done", Callable(self, "_on_spam_call_done"))
	$"../Greybox/Phone".connect("friend_call_done", Callable(self, "_on_friend_call_done"))
	$"../Greybox/TV".connect("tv_done", Callable(self, "_on_watch_done"))
	$"../Greybox/PlantShape".connect("water_done", Callable(self, "_on_water_done"))
	$"../Greybox/Puddle".connect("mop_done", Callable(self, "_on_mop_done"))
	$"../Greybox/NavigationRegion3D/FINAL 3D ASSETS/MuffinManager".connect("muffin_done", Callable(self, "_on_muffin_done"))
	$"../Greybox/NavigationRegion3D/FINAL 3D ASSETS/MuffinManager".connect("all_muffins_done", Callable(self, "_all_muffins_done"))

#spawn task with its own label & meter
func spawn_task(description = "", timer: Timer = null):
	var task_instance = NewTask.instantiate()
	task_list.add_child(task_instance)

	var task_label = task_instance.find_child("TaskLabel")
	var task_meter = task_instance.find_child("TaskMeter")
	task_label.text = description
	
	#timer setup for each task
	var max_time = timer.wait_time
	active_tasks.append({
		"node": task_instance,
		"timer": timer,
		"max_time": max_time,
		"meter": task_meter
	})

#timer countdown
func _process(delta):
	var tasks_to_remove = []
	for task in active_tasks:
		var remaining = task["timer"].time_left
		var progress = clamp((remaining / task["max_time"]) * 100, 0, 100)
		task["meter"].value = progress
		if remaining <= 0:
			tasks_to_remove.append(task)

# Remove finished tasks
	for task in tasks_to_remove:
		task["node"].queue_free()
		active_tasks.erase(task)


# task spawners
func _on_phone_task(task, description):
	spawn_task(description, phone_timer)

func _on_plant_task(task, description):
	spawn_task(description, plant_timer)

func _on_mop_task(task, description):
	spawn_task(description, puddle_timer)

func _on_tv_task(task, description):
	spawn_task(description, tv_timer)

func _on_muffin_task(task, description):
	spawn_task(description, muffin_timer)
