class_name Person
extends CharacterBody2D

@onready var navigation_agent := $NavigationAgent2D as NavigationAgent2D
@onready var moving := true
var target_position = null

func _ready():
	target_position = Vector2(264, 176)
	navigation_agent.target_position  = Vector2(264, 176)

func _physics_process(_delta):
	var move_direction = to_local(navigation_agent.get_next_path_position()).normalized()
	velocity = move_direction * 30
	
	if moving:
		move_and_slide()
		check_target()

func check_target():
	var diff: Vector2 = global_position - target_position
	
	if diff.abs().x < 0.5 and diff.abs().y < 0.5:
		moving = false
