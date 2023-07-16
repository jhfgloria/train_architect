extends Node2D

@onready var rails_collection = $Rails as Node2D

var train_model = preload("res://scenes/train.tscn")
var rail_model = preload("res://scenes/rail.tscn")

func _ready():
	build_rail(Vector2(240, 120))
	dispatch_train()

func _process(delta):
	pass
	
func dispatch_train():
	var train = train_model.instantiate()
	var rail = rails_collection.get_children()[0]
	var spawn = rail.find_child('Spawn Position')
	train.position = spawn.global_position
	add_child(train)

func build_rail(position: Vector2) -> void:
	var rail = rail_model.instantiate()
	rail.position = position
	rails_collection.add_child(rail)
