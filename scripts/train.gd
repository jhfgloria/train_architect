class_name Train
extends StaticBody2D

@onready var pickup_area = $"Pickup Area" as Area2D

var base_speed = 60
var pick_up = false
var speed = base_speed
var rail_id: int

func _ready() -> void:
	pickup_area.monitoring = false

func _physics_process(delta):
	var velocity = Vector2(speed, 0)
	
	if pick_up:
		move_toward(speed, 0, -1)
	else:
		move_and_collide(velocity * delta)


func _on_pickup_position_area_shape_entered(area_rid, area, area_shape_index, local_shape_index):
	pickup_area.monitoring = true
	pick_up = true
	$Timer.start()


func _on_timer_timeout():
	pickup_area.monitoring = false
	pick_up = false
	speed = base_speed * 2


func _on_exit_position_area_shape_entered(area_rid, area, area_shape_index, local_shape_index):
	self.queue_free()

func set_rail_id(rail_id: int) -> void:
	self.rail_id = rail_id 

func _on_pickup_area_body_entered(person: Person):
	if person.desired_train == self.rail_id:
		person.board_train()
	
