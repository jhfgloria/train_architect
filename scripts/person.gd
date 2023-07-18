class_name Person
extends CharacterBody2D

@onready var navigation_agent := $NavigationAgent2D as NavigationAgent2D
@onready var moving := true

var target_position: Vector2
var desired_train: int

func _physics_process(_delta):
	if target_position == null: return
	
	var move_direction = to_local(navigation_agent.get_next_path_position()).normalized()
	velocity = move_direction * 30
	
	if moving:
		move_and_slide()
		check_target()

func check_target():
	var diff: Vector2 = global_position - target_position
	
	if diff.abs().x < 2 and diff.abs().y < 2:
		moving = false

func set_target(position: Vector2) -> void:
	target_position = position
	navigation_agent.target_position = position
	
func set_spawn_position(position: Vector2) -> void:
	self.global_position = position

func set_desired_train(id: int) -> void:
	self.desired_train = id

func board_train() -> void:
	self.call_deferred('queue_free')
