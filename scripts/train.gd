class_name Train
extends StaticBody2D

# Train components
@onready var pickup_area = $"Pickup Area" as Area2D
@onready var door_one = $door_one as Node2D
@onready var door_two = $door_two as Node2D
# Trains privates
var base_speed = 60
var pick_up = false
var speed = base_speed
var rail_id: int
# Texture preloads
@onready var person_texture = preload("res://sprites/Person.png") 

func _ready() -> void:
	EventBus.person_board_train_sig.connect(self._show_people_aboard)
	pickup_area.monitoring = false

func _physics_process(delta):
	var velocity = Vector2(speed, 0)
	
	if pick_up:
		move_toward(speed, 0, -1)
	else:
		move_and_collide(velocity * delta)

func _process(_delta):
	self.z_index = self.position.y

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

func _show_people_aboard(_p, train_id: int) -> void:
	if train_id != self.rail_id: return
	
	var person_one = Sprite2D.new()
	var person_two = Sprite2D.new()
	person_one.set_texture(self.person_texture)
	person_two.set_texture(self.person_texture)
	person_one.position = self.door_one.position + Vector2(0, -8)
	person_two.position = self.door_two.position + Vector2(0, -8)
	self.add_child(person_one)
	self.add_child(person_two)
