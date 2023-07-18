extends Node2D

@onready var station = $Station as Station
@onready var rails_collection = $Rails as Node2D
@onready var terrain = $Tiles as TileMap

var person_model = preload("res://scenes/person.tscn") as PackedScene
var train_model = preload("res://scenes/train.tscn") as PackedScene
var rail_model = preload("res://scenes/rail.tscn") as PackedScene

var taken_positions: Array[Vector2] = []

func _ready():
	_build_rail(Vector2(240, 120))

func _dispatch_train(position: Vector2, rail_id: int):
	var new_train: Train = train_model.instantiate()
	new_train.position = position
	new_train.set_rail_id(rail_id) 
	add_child(new_train)

func _build_rail(position: Vector2) -> void:
	var next_id = rails_collection.get_children().size()
	var rail = rail_model.instantiate() as Rail
	rail.set_id(next_id)
	rail.position = position
	rails_collection.add_child(rail)
	rail.call_people.connect(_call_people)
	rail.dispatch_train.connect(_dispatch_train)

func _call_people(rail_position: Vector2, rail_id: int) -> void:
	var spawn_position = station.get_spawn_position()
	var farest_point = spawn_position

	for y in range(-16, 17, 32):
		for x in range(8, 480, 16):
			var tile_global_position = Vector2(x, rail_position.y - y)
			var tile_position = terrain.local_to_map(tile_global_position)
			var tile_data = terrain.get_cell_tile_data(0, tile_position)
			
			if tile_data == null: continue
			if tile_data.terrain != 1: continue
			
			var distance_to_spawn = spawn_position.distance_to(tile_global_position)
			var farest_distance = spawn_position.distance_to(farest_point)
			
			if distance_to_spawn > farest_distance and taken_positions.find(tile_global_position) == -1:
				farest_point = tile_global_position

	if farest_point != spawn_position:
		self._spawn_person(spawn_position, farest_point, rail_id)
		taken_positions.append(farest_point)
		self._wait_for_next_person(func x(): _call_people(rail_position, rail_id))

func _spawn_person(spawn_position: Vector2, target_position: Vector2, rail_id: int) -> void:
	var new_person: Person = person_model.instantiate()
	new_person.set_spawn_position(spawn_position)
	new_person.set_desired_train(rail_id)
	add_child(new_person)
	new_person.call_deferred("set_target", target_position)

func _wait_for_next_person(callback) -> void:
	var wait = Timer.new()
	wait.one_shot
	wait.wait_time = 0.5
	wait.timeout.connect(func x(): 
		callback.call()
		wait.queue_free()
	)
	add_child(wait)
	wait.start()
