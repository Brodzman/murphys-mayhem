extends Resource
class_name FishData

@export var fish_location : Vector3
@export var fish_health : int
@export var fish_hunger : int
@export var fish_is_held : bool
@export var fish_in_bowl : bool

func update_position(value):
	fish_location = value
	
func update_health(value):
	fish_health = value
	
func update_hunger(value):
	pass

func update_is_held(value):
	pass
	
func update_in_bowl(value):
	pass
