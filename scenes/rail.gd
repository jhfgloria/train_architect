class_name Rail
extends Node2D

@onready var schedule := $"Train Schedule" as TrainSchedule
@onready var spawn_position := $"Spawn Position" as Node2D

signal call_people(rail_position: Vector2, rail_id: int)
signal dispatch_train(spawn_position: Vector2, rail_id: int)

var id: int

func _ready() -> void:
	schedule.call_people_to_station.connect(_call_people)
	schedule.dispatch_train.connect(_dispatch_train)
	
func _call_people() -> void:
	call_people.emit(self.global_position, self.id)

func _dispatch_train() -> void:
	dispatch_train.emit(self.spawn_position.global_position, self.id)

func set_id(id: int) -> void:
	self.id = id
