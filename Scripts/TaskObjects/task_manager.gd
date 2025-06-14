extends Node

# Tasks are completed when the required actions are completed
# You can leave and come back to a task with the progress saved

# Currently coded so that you only need to interact with object to complete task

# Save file variables
var save_file_path = "user://save/"
var save_file_name = "GameSave.tres"
var game_data = GameData.new()

# Normal node variables
@onready var task_label: Label = $"../PlaceholderHUD/ColorRect/Task"
@onready var time_of_day: Node = $"../TimeManager"
@onready var puddle_collision: CollisionShape3D = $"../Greybox/Puddle/CollisionShape3D"
@onready var pause_menu: Control = $"../pausemenu"

# Task node variables
@onready var phone: StaticBody3D = $"../Greybox/Phone"
@onready var tv: StaticBody3D = $"../Greybox/TV"
@onready var plant_shape: StaticBody3D = $"../Greybox/PlantShape"
@onready var puddle: StaticBody3D = $"../Greybox/Puddle"
@onready var muffin: Node = $"../Greybox/NavigationRegion3D/FINAL 3D ASSETS/MuffinManager"
@onready var task_delay_timer: Timer = $TaskDelayTimer 
@onready var task_list: VBoxContainer = $PlaceholderHUD/TaskList

# Timers for each task
@onready var phone_timer: Timer = $"../Greybox/Phone/PhoneTimer"
@onready var plant_timer: Timer = $"../Greybox/PlantShape/PlantTimer"
@onready var puddle_timer: Timer = $"../Greybox/Puddle/PuddleTimer"
@onready var tv_timer: Timer = $"../Greybox/TV/TVTimer"
@onready var muffin_timer: Timer = $"../Greybox/NavigationRegion3D/FINAL 3D ASSETS/MuffinManager/MuffinTimer"

# How long you have to complete each task
var phone_task_time = 20
var plant_task_time = 40
var puddle_task_time = 20
var tv_task_time = 40
var muffin_task_time = 30

# How long until the next task is triggered
var friend_call_delay = 8
var spam_call_delay = 8
var water_delay = 15
var mop_delay = 5
var tv_delay
var muffin_delay

var avaliable_tasks = []
var text_track
var task_number
var can_eat_muffin = true
var can_call = true
var active_tasks = {
	"friend_call": false,
	"spam_call": false,
	"water_plant": false,
	"mop_floor": false,
	"watch_tv": false,
	"muffin_eat": false,
}

# TEMP to test difficulty
var difficulty = 1

signal task_call(task, description)
signal task_plant(task, description)
signal task_mop(task, description)
signal task_tv(task, description)
signal task_muffin(task, description)
signal tut_friend_called
signal tut_watched
signal tut_mopped



func _ready() -> void:
	
	populate_tasks(difficulty)
	print(avaliable_tasks)
	phone_timer.wait_time = phone_task_time
	plant_timer.wait_time = plant_task_time
	puddle_timer.wait_time = puddle_task_time
	tv_timer.wait_time = tv_task_time
	muffin_timer.wait_time = muffin_task_time
	
	can_eat_muffin = true
	can_call = true
	pause_menu.connect("save_all_data", Callable(self, "_on_save_all_data"))
	phone.connect("spam_call_done", Callable(self, "_on_spam_call_done"))
	phone.connect("friend_call_done", Callable(self, "_on_friend_call_done"))
	tv.connect("tv_done", Callable(self, "_on_watch_done"))
	plant_shape.connect("water_done", Callable(self, "_on_water_done"))
	puddle.connect("mop_done", Callable(self, "_on_mop_done"))
	muffin.connect("muffin_done", Callable(self, "_on_muffin_done"))
	muffin.connect("all_muffins_done", Callable(self, "_all_muffins_done"))
	
	verify_save_directory(save_file_path)
	if ResourceLoader.exists(save_file_path + save_file_name) == true:
		load_data()
	print(active_tasks)
	
	task_label.text = "Tasks"
	text_track = task_label.text
	task_delay_timer.wait_time = 10
	task_delay_timer.start()
	
	
func task_get_rng():
	task_number = avaliable_tasks.pick_random()
	#task_number = randi_range(1, 6) # Change value based on amount of tasks

func _on_timer_timeout() -> void:
	task_get_rng()
	task_roll(task_number)
		
func task_roll(task):
	var description
	# Friend calls
	# Wait for dialogue to end to finish (cant skip through)
	if task == 1:
		# Phone only rings if no other calls are happening
		if can_call == true:
			if phone.friend_call_complete == true and phone.spam_call_complete == true:
				can_call = false
				if task_delay_timer.wait_time > 0:
					task_delay_timer.wait_time = friend_call_delay
					task_delay_timer.start()
				task = "friend_call"
				description = " | Friend is calling"
				
				active_tasks["friend_call"] = true
				emit_signal("task_call", task, description)
				
			else:
				task_get_rng()
				task_delay_timer.wait_time = 0.1
				task_delay_timer.start()
		
	# Spam calls
	# Wait for dialogue to end to finish (can skip through?)
	elif task == 2:
		# Phone only rings if no other calls are happening
		if can_call == true:
			if phone.friend_call_complete == true and phone.spam_call_complete == true:
				can_call = false
				if task_delay_timer.wait_time > 0:
					task_delay_timer.wait_time = 8
					task_delay_timer.start()
				task = "spam_call"
				description = " | Spam call"
				task_label.text = text_track + " | Answer the phone"
				text_track = task_label.text
				active_tasks["spam_call"] = true
				emit_signal("task_call", task, description)
			else:
				task_get_rng()
				task_delay_timer.wait_time = 0.1
				task_delay_timer.start()
	
	# Water plant
	# Spam E a certain amount of times
	elif task == 3: 
		if plant_shape.can_start_watering == true:
			if task_delay_timer.wait_time > 0:
				task_delay_timer.wait_time = 15
				task_delay_timer.start()
			task = "water_plant"
			description = " | You need to water your plants"
			task_label.text = text_track + description
			text_track = task_label.text
			active_tasks["water_plant"] = true
			emit_signal("task_plant", task, description)
		else:
			task_get_rng()
			task_delay_timer.wait_time = 0.1
			task_delay_timer.start()
	
	# Mop the floor (if fish has been out enough)
	# Pick up mop and clean up water areas
	elif task == 4: 
		if puddle.mop_complete == true:
			if task_delay_timer.wait_time > 0:
				task_delay_timer.wait_time = 5
				task_delay_timer.start()
			puddle.visible = true
			puddle_collision.disabled = false
			task = "mop_floor"
			description = " | Clean up Murphy's mess"
			task_label.text = text_track + description
			text_track = task_label.text
			active_tasks["mop_floor"] = true
			emit_signal("task_mop", task, description)
		else:
			task_get_rng()
			task_delay_timer.wait_time = 0.1
			task_delay_timer.start()
		
	# Watch TV
	# Wait a period of time
	elif task == 5: 
		if tv.watch_tv_done == true:
			if task_delay_timer.wait_time > 0:
				task_delay_timer.wait_time = 10
				task_delay_timer.start()
			task = "watch_tv"
			description = " | Your favorite show is on"
			task_label.text = text_track + description
			text_track = task_label.text
			active_tasks["watch_tv"] = true
			emit_signal("task_tv", task, description)
		else:
			task_get_rng()
			task_delay_timer.wait_time = 0.1
			task_delay_timer.start()
	
	# Make your own food
	# Get all ingredients
	elif task == 6:
		if can_eat_muffin == true:
			if muffin.muffin_complete == true:
				if task_delay_timer.wait_time > 0:
					task_delay_timer.wait_time = 11
					task_delay_timer.start()
				task = "muffin_eat"
				description = " | Find a muffin to eat"
				task_label.text = text_track + description
				text_track = task_label.text
				active_tasks["muffin_eat"] = true
				emit_signal("task_muffin", task, description)
			else:
				task_get_rng()
				task_delay_timer.wait_time = 0.1
				task_delay_timer.start()
	else:
		task_get_rng()
		task_delay_timer.wait_time = 0.1
		task_delay_timer.start()
	print(active_tasks)
	
#######################
# Functions for adding what tasks are avaliable to be triggered
#######################
func populate_tasks(difficulty):
	match difficulty:
		0:
			pass # Tutorial 
		1:
			add_friend_call_task()
			add_muffin_task()
			if time_of_day.current_hour > 11:
				add_tv_task()
			if time_of_day.current_hour > 12:
				add_spam_call_task()
			if time_of_day.current_hour > 13:
				add_mop_task()
			if time_of_day.current_hour > 14:
				add_water_task()
		2:
			pass # Medium
		3:
			pass # Hard

func add_friend_call_task():
	avaliable_tasks.append(1)
	
func add_spam_call_task():
	avaliable_tasks.append(2)
	
func add_water_task():
	avaliable_tasks.append(3)
	
func add_mop_task():
	avaliable_tasks.append(4)
	
func add_tv_task():
	avaliable_tasks.append(5)
	
func add_muffin_task():
	avaliable_tasks.append(6)

func add_all_tasks():
	avaliable_tasks = [1, 2, 3, 4, 5, 6]


func _on_spam_call_done(new_text):
	text_track = new_text
	can_call = true
	active_tasks["spam_call"] = false
	
func _on_friend_call_done(new_text):
	text_track = new_text
	can_call = true
	active_tasks["friend_call"] = false
	emit_signal("tut_friend_called")
	
func _on_watch_done(new_text):
	text_track = new_text
	active_tasks["watch_tv"] = false
	emit_signal("tut_watched")

func _on_water_done(new_text):
	text_track = new_text
	active_tasks["water_plant"] = false
	
func _on_mop_done(new_text):
	puddle.visible = false
	puddle_collision.disabled = true
	text_track = new_text
	active_tasks["mop_floor"] = false
	emit_signal("tut_mopped")
	
func _on_muffin_done(new_text):
	text_track = new_text
	can_eat_muffin = true
	active_tasks["muffin_eat"] = false

func _all_muffins_done(new_text):
	text_track = new_text
	can_eat_muffin = false
	active_tasks["muffin_eat"] = false
	

		
#######################
# Functions for saving
#######################
func verify_save_directory(path : String):
	DirAccess.make_dir_absolute(path)
	
func load_data():
	game_data = ResourceLoader.load(save_file_path + save_file_name).duplicate(true)
	load_on_start()
	print("loaded")

func load_on_start():
	avaliable_tasks.append_array(game_data.saved_avaliable_tasks)
	active_tasks = game_data.current_tasks
	time_of_day.current_hour = game_data.current_hour
	time_of_day.minutes = game_data.current_minute
	

func save_data():
	game_data.update_hour(time_of_day.current_hour)
	game_data.update_minute(time_of_day.minutes)
	game_data.update_tasks(active_tasks)
	game_data.update_avaliable_tasks(avaliable_tasks)
	# TODO Add in muffins complete
	# TODO Add in tutorial complete
	# TODO Add in levels complete
	ResourceSaver.save(game_data, save_file_path + save_file_name)
	print("saved")

func _on_save_all_data():
	save_data()
	
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("save"):
		save_data()
	if Input.is_action_just_pressed("load"):
		load_data()
