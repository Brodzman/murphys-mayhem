extends Resource
class_name PlayerData

@export var player_location : Vector3

func update_position(value):
	player_location = value
