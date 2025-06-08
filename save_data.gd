extends Resource

class_name SaveData

# General save data
@export var current_time : int
@export var current_tasks : Dictionary
@export var current_tasks_time_left : Dictionary # not sure what best type would be for performance
@export var muffins_eaten : int

# Fish save data
@export var fish_hunger : int
@export var fish_health : int
@export var is_held : bool
@export var in_bowl : bool
@export var fish_location : Vector3

# Player save data
@export var player_location : Vector3
