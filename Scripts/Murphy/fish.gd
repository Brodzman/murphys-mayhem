extends CharacterBody3D

# Save file variables
var save_file_path = "user://save/"
var save_file_name = "FishSave.tres"
var fish_data = FishData.new()

const MAX_HP = 100
const SPEED = 8.0
const HP_LOST_PER_SECOND = 1
const TIME_TO_ESCAPE = 1
const MAX_HUNGER = 100
const HUNGER_LOST_PER_HOUR = 15

var current_hp = MAX_HP
var hunger = 25
var is_held = false
var in_bowl = true
var on_screen
var has_food = false

var escape_roll
var has_rotated = false

signal holding
signal interacted(body)
signal hunger_label_update(hunger_level)
signal destory_food
signal tut_murphy_fed
signal tut_murphy_found

@export var prompt_message = "Interact"
@onready var restart_menu: Control = $"../../../restartmenu"
@onready var timer: Timer = $InBowlTimer
@onready var nav_agent: NavigationAgent3D = $NavigationAgent3D
@onready var region: NavigationRegion3D = $".."
@onready var hunger_label: Label = $"../../../PlaceholderHUD/ColorRect/Hunger"
@onready var game_over_label: Label = $"../../../PlaceholderHUD/ColorRect/GameOver"
@onready var hunger_bar: ProgressBar = $"../../../PlaceholderHUD/ColorRect/HungerBorder/HungerMask/HungerBar"
@onready var interact_ray: RayCast3D = $"../../../Player/Head/Camera3D/InteractRay"
@onready var node_3d: Node3D = $"../../.."
@onready var fish_bowl: StaticBody3D = $"../../FishBowl"

func _ready() -> void:
	verify_save_directory(save_file_path)
	current_hp = MAX_HP
	hunger = 25
	is_held = false
	in_bowl = true
	has_food = false
	has_rotated = false
	$"../../FishBowl".connect("bowl_place", Callable(self, "_on_bowl_place"))
	$"../../../TimeManager".connect("hunger_down", Callable(self, "_on_hunger_down"))
	$"../../Food".connect("food_in_hand", Callable(self, "_on_food_in_hand"))
	$"../../Food2".connect("food_in_hand", Callable(self, "_on_food_in_hand"))
	hunger_bar.value = hunger
	if ResourceLoader.exists(save_file_path + save_file_name) == true:
		load_data()
	if in_bowl == false:
		fish_move()

func interact(body):
	interacted.emit(body)

func feed_fish():
	has_food = false
	hunger = MAX_HUNGER
	hunger_bar.value = hunger
	emit_signal("destory_food")
	emit_signal("tut_murphy_fed")
	
func hold_fish():
	is_held = true
	get_tree().call_group("hand", "pickup")
	emit_signal("holding")
	prompt_message = ""
	visible = false
	
	
func _on_interacted(body: Variant) -> void:
	if has_food == true and in_bowl == true:
		feed_fish()	
	else:
		hold_fish()
	
func _on_bowl_place():
	is_held = false
	in_bowl = true
	visible = true
	get_tree().call_group("hand", "place")
	prompt_message = "·   E"
	velocity = Vector3(0, 0, 0)
	region.enabled = false
	rotation = Vector3(0, 0, 0)
	await get_tree().create_timer(0.1).timeout
	position = Vector3(11.189, 2.63, -4.352)
	$Murphy_Fish_IDLE.visible = true
	$Murphy_Fish_JUMP.visible = false
	emit_signal("tut_murphy_found")
	
func _on_visible_on_screen_notifier_3d_screen_entered() -> void:
	on_screen = true

func _on_visible_on_screen_notifier_3d_screen_exited() -> void:
	on_screen = false
	if on_screen == false:
		if in_bowl == true:
			# Change this to have the initial attempt delay different from the rest
			timer.start(TIME_TO_ESCAPE)
			
# When the player looks away, the fish will attempt to escape
# Change the value proceding escape roll < or > to determine escape chance
# Each attempt delay is set by the TIME_TO_ESCAPE variable
func _on_timer_timeout() -> void:
	attempt_escape()
	
func attempt_escape():
	if in_bowl == true:
		if on_screen == false:
			escape_roll = randi_range(1, 100)
			if escape_roll < 30:
				in_bowl = false
				region.enabled = true
				fish_move()
				lose_hp()
				$Murphy_Fish_JUMP.visible = true
				
				# Rotate only once
				if not has_rotated:
					rotate_fish()
					has_rotated = true
					
			elif escape_roll > 80:
				random_position()
			
			else:
				timer.start(TIME_TO_ESCAPE)
		else:
			timer.start(TIME_TO_ESCAPE)
			
	# If fish is out of bowl the same timer is used to degrade hp
	elif in_bowl == false:
		current_hp -= HP_LOST_PER_SECOND
		lose_hp()
		
func random_position():
	var random = randi_range(1, 3)
	# Oven
	if random == 1:
		position = Vector3(11.189, 1.823, 7.057)
		rotation = Vector3(0, -90, 0)
		get_tree().call_group("oven", "in_oven")
	if random == 2:
		position = Vector3(2.1, 2.273, 6.854)
		rotation = Vector3(0, -90, 0)
		get_tree().call_group("fridge", "in_fridge")
	if random == 3:
		position = Vector3(-6.928, 7.85, 5.281)
		rotation = Vector3(0, -90, -90)
		
func _physics_process(delta: float) -> void:
	var current_location = global_transform.origin
	var next_location = nav_agent.get_next_path_position()
	var new_velocity = (next_location - current_location).normalized() * SPEED
	var drop_offset
	#if new_velocity.y > velocity.y:
		#get_tree().call_group("murphy", "jump_anim")
	
	velocity = new_velocity
	#velocity = velocity.move_toward(new_velocity, .25)
	move_and_slide()
	update_forward(velocity)
	
func update_forward(new_forward: Vector3) -> void:
	var target_position = global_transform.origin - new_forward
	if target_position == global_transform.origin:
		return
	if target_position == Vector3.UP:
		return
	else:
		look_at(target_position, Vector3.UP)
		
func fish_move():
	var random_position := Vector3.ZERO
	random_position.x = randf_range(-10.0, 10.0)
	random_position.z = randf_range(-10.0, 10.0)
	nav_agent.set_target_position(random_position)
	

func _on_navigation_agent_3d_navigation_finished() -> void:
	fish_move()

func rotate_fish():
	pass
	#$Murphy_Fish_JUMP.rotation_degrees.z += 90

func lose_hp():
	if in_bowl == false:
		if current_hp <= 0:
			game_over_label.text = "Murphy drowned on air"
			await get_tree().create_timer(1).timeout
			node_3d.toggle_restartmenu()
			
		else:
			timer.start(1)
	
func _on_hunger_down():
	hunger -= HUNGER_LOST_PER_HOUR
	hunger_bar.value = hunger
	#hunger_label.text = "Murphy's Hunger: " + str(hunger)
	# dies if hunger reaches 0
	if hunger <= 0:
		game_over_label.text = "Murphy died of hunger"
		await get_tree().create_timer(1).timeout
		node_3d.toggle_restartmenu()
		
func _on_food_in_hand():
	has_food = true
	
func _process(delta: float) -> void:	
	if Input.is_action_just_pressed("drop"):
		if is_held:
			# ADD drop_label.text = ""
			is_held = false
			visible = true
			set_collision_layer_value(2, true)
			var drop_offset = Vector3(0, 0, 2)
			global_position = interact_ray.global_position - interact_ray.global_transform.basis.z
			region.enabled = true
			fish_move()
	
#######################
# Functions for saving
#######################
func verify_save_directory(path : String):
	DirAccess.make_dir_absolute(path)
	
func load_data():
	fish_data = ResourceLoader.load(save_file_path + save_file_name).duplicate(true)
	load_on_start()
	print("loaded")

func load_on_start():
	self.position = fish_data.fish_location
	current_hp = fish_data.fish_health
	hunger = fish_data.fish_hunger
	is_held = fish_data.fish_is_held
	in_bowl = fish_data.fish_in_bowl

func save_data():
	fish_data.update_position(self.position)
	fish_data.update_health(current_hp)
	fish_data.update_hunger(hunger)
	fish_data.update_in_bowl(in_bowl)
	fish_data.update_is_held(is_held)
	ResourceSaver.save(fish_data, save_file_path + save_file_name)
	print("saved")

func _on_save_all_data():
	save_data()
