extends Node2D

var train_model = preload("res://train.tscn")

func _ready():
	var train = train_model.instantiate()
	var rail = find_child('Rail')
	var spawn = rail.find_child('Spawn Position')
	train.position = spawn.global_position
	add_child(train)

func _process(delta):
	pass
