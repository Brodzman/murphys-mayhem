extends Node

var current_step = TutorialStep.INTRO_CUTSCENE
var tutorial_enabled = true

enum TutorialStep {INTRO_CUTSCENE, FEED_MURPHY, ANSWER_PHONE, FIND_MURPHY, WATCH_TV, CHASE_MURPHY, MOP, GOODLUCK_CUTSCENE}

@onready var fish: CharacterBody3D = $"../Greybox/NavigationRegion3D/Fish"
@onready var taskmanager: Node = $"../TaskManager"

signal intro_done

# Called when the node enters the scene tree for the fi"res://Scripts/TaskObjects/task_manager.gd"rst time.
func _ready() -> void:
	start_tutorial()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	match current_step: 
		TutorialStep.INTRO_CUTSCENE:
			#print("Step Intro")
			intro_cutscene()
			await intro_done
			current_step = TutorialStep.FEED_MURPHY
			
			
		TutorialStep.FEED_MURPHY:
			#print("Step Feed")
			await fish.tut_murphy_fed
			current_step = TutorialStep.ANSWER_PHONE
			
		TutorialStep.ANSWER_PHONE:
			#print("Step Answer Phone")
			await taskmanager.tut_friend_called
			current_step = TutorialStep.FIND_MURPHY
			
		TutorialStep.FIND_MURPHY:
			#print("Step Find")
			await fish.tut_murphy_found
			current_step = TutorialStep.WATCH_TV
			
		TutorialStep.WATCH_TV:
			#print("Step TV")
			await taskmanager.tut_watched
			current_step = TutorialStep.CHASE_MURPHY
			
		TutorialStep.CHASE_MURPHY:
			#print("Step Chase")
			await fish.tut_murphy_found
			current_step = TutorialStep.MOP
			
		TutorialStep.MOP:
			#print("Step Mop")
			await taskmanager.tut_mopped
			current_step = TutorialStep.GOODLUCK_CUTSCENE
			
		TutorialStep.GOODLUCK_CUTSCENE:
			#print("Step Goodluck")
			await InputEvent
			tutorial_enabled = false
			


func start_tutorial():
	tutorial_enabled = true
	#print("tutorial started")

func end_tutorial():
	tutorial_enabled = false
	#print("tutorial ended")

func intro_cutscene():
	emit_signal("intro_done")
