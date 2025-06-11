extends Node

#Tasks are displayed under TaskList node
@onready var task_list: VBoxContainer = %TaskList

#Individual task scene
var NewTask = preload("res://new_task.tscn")

var task_name = {}

func _ready():
	spawn_task()
	var task_manager = get_node("res://Scripts/TaskObjects/task_manager.gd")
	add_child(task_manager)
	

#Connect signals
	task_manager.phone.connect("spam_call_done", Callable(self, "_on_spam_call_done"))

#Spawns a new task
func spawn_task():
	var new_task = NewTask.instantiate()
	task_list.add_child(new_task)
	
