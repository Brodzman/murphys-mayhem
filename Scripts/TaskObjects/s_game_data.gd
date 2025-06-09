extends Resource
class_name GameData

@export var current_hour : int
@export var current_minute : int
@export var current_tasks : Dictionary
@export var current_tasks_time_left : Dictionary
@export var muffins_eaten : int
@export var tutorial_complete : bool
@export var levels_complete : Dictionary

func update_hour(value):
	current_hour = value
	
func update_minute(value):
	current_minute = value
	
func update_tasks(value):
	current_tasks = value

func update_tasks_time_left(value):
	current_tasks_time_left = value
	
func update_muffins_eaten(value):
	muffins_eaten = value
	
func update_tutorial_complete(value):
	tutorial_complete = value
	
func update_levels_complete(value):
	levels_complete = value
	
