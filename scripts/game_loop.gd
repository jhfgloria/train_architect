extends Node2D

# Game Loop Signals
signal game_debit(delta: int)
signal game_credit(delta: int)
signal game_pause()
signal game_resume()
# Game Loop Components
@onready var station = $Station as Station
@onready var rails_collection = $Rails as Node2D
@onready var terrain = $Tiles as TileMap
@onready var placeholder = $Placeholder as Node2D
@onready var selection_area = $"Selection Area" as ColorRect
@onready var budget_value = $"HUD/Budget Value" as Label
@onready var clock_timer = $"Clock Timer" as Timer
@onready var clock_label = $"HUD/Time Label" as Label
@onready var day_label = $HUD/day_label as Label
@onready var build_tool = BuildTool.new()
@onready var budget_warning = $budget_warning as Node2D
@onready var game_over = $game_over as Node2D
@onready var build_menu = $"Build Menu" as Node2D
# Scene preloads
var person_model = preload("res://scenes/person.tscn") as PackedScene
var train_model = preload("res://scenes/train.tscn") as PackedScene
var rail_model = preload("res://scenes/rail.tscn") as PackedScene

var taken_positions: Array[Vector2] = []
var build_path_start: Vector2
var build_path_end: Vector2

var area_selection_first_position = null
var area_selection_final_position = null

var budget: int = 0
var time: int = 2000
var day = 1
var is_game_over = false

func _ready():
	self._set_time()
	self._set_date()
	self._build_rail(120, 0, false)
	self._credit(800)
	EventBus.register_signal(self.game_debit)
	EventBus.register_signal(self.game_credit)
	EventBus.register_signal(self.game_pause)
	EventBus.register_signal(self.game_resume)
	EventBus.person_board_train_sig.connect(func c(_p, _t): _credit(25))
	EventBus.person_board_train_sig.connect(self._free_position)

func _input(event: InputEvent):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				if build_tool.building_unit == BuildTool.BuildingUnit.PLATFORM:
					self.build_path_start = terrain.local_to_map(self.placeholder.global_position)

				elif build_tool.building_unit == BuildTool.BuildingUnit.RAIL:
					if build_tool.can_build(BuildTool.BuildingUnit.RAIL, self.placeholder.global_position):
						self._build_rail(self.placeholder.global_position.y)
					
			if !event.pressed:
				if build_tool.building_unit == BuildTool.BuildingUnit.PLATFORM:
					if build_tool.can_build(BuildTool.BuildingUnit.RAIL, self.placeholder.global_position):
						self.build_path_end = terrain.local_to_map(self.placeholder.global_position)
						self._build_platform()

	if event is InputEventMouseButton:
		if event.pressed:
			if self.area_selection_first_position == null:
				self.area_selection_first_position = self.placeholder.global_position - Vector2(8, 8)

		if !event.pressed:
			self.area_selection_first_position = null
			self.area_selection_final_position = null
			self.selection_area.visible = false
			self.selection_area.size = Vector2.ZERO
			self.selection_area.position = Vector2.ZERO

	if event is InputEventMouseMotion:
		if self.area_selection_first_position != null:
			self.area_selection_final_position = self.placeholder.global_position - Vector2(8, 8)
			self._draw_selection_area()

func _physics_process(_delta):
	self._move_placeholder()

func _dispatch_train(position: Vector2, rail_id: int):
	var new_train: Train = train_model.instantiate()
	new_train.position = position
	new_train.set_rail_id(rail_id) 
	add_child(new_train)

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

func _move_placeholder() -> void:
	var global_position = get_viewport().get_mouse_position() 
	var placeholder_position_x = floorf(global_position.x / 16) * 16.0 + 8
	var placeholder_position_y = floorf(global_position.y / 16) * 16.0 + 8
	placeholder.global_position = Vector2(placeholder_position_x, placeholder_position_y)

func _build_platform() -> void:
	var min_x = minf(self.build_path_start.x, self.build_path_end.x)
	var max_x = maxf(self.build_path_start.x, self.build_path_end.x)
	var min_y = minf(self.build_path_start.y, build_path_end.y)
	var max_y = maxf(self.build_path_start.y, self.build_path_end.y)
	
	var connect = []
	for x in range(min_x, max_x + 1, 1):
		for y in range(min_y, max_y + 1, 1):
			connect.append(Vector2(x, y))
	
	self.terrain.set_cells_terrain_connect(0, connect, 0, 1)
	$platform_sfx.play()
	self._debit(50 * connect.size())

func _build_rail(position_y: float, cost = 250, sound = true) -> void:
	var next_id = rails_collection.get_children().size()
	var rail = rail_model.instantiate() as Rail
	rail.set_id(next_id)
	rail.set_play_sound(sound)
	rail.position = Vector2(240, position_y)
	rails_collection.add_child(rail)
	rail.rail_call_people.connect(_call_people)
	rail.dispatch_train.connect(_dispatch_train)
	self._debit(cost)

func _draw_selection_area() -> void:
	self.selection_area.visible = true
	var min = VectorUtils.min_axis(self.area_selection_first_position, self.area_selection_final_position)
	var max = VectorUtils.max_axis(self.area_selection_first_position, self.area_selection_final_position)
	self.selection_area.position = Vector2(min.x, min.y)
	self.selection_area.size = Vector2(max.x - min.x, max.y - min.y) + Vector2(16, 16)

func _debit(amount: int) -> void:
	self.game_debit.emit(-amount)
	self.budget -= amount
	self.budget_value.set_text("$" + String.num_int64(self.budget))

func _credit(amount: int) -> void:
	self.game_credit.emit(amount)
	self.budget += amount
	self.budget_value.set_text("$" + String.num_int64(self.budget))

func _on_clock_timer_timeout():
	self.time += 100
	if self.time == 2400:
		self.day += 1
		self.time = 0

	self._set_time()
	self._set_date()
	if (self.time == 0):
		self._process_costs()

func _set_time() -> void:
	var str_time = String.num_int64(self.time)

	if str_time.length() == 3:
		str_time = "0" + str_time
	
	if str_time.length() == 1:
		str_time = "0000"
	
	clock_label.set_text(str_time[0]+str_time[1]+":"+str_time[2]+str_time[3])

func _set_date() -> void:
	self.day_label.set_text("Day " + String.num_uint64(self.day))

func _free_position(position: Vector2, _t: int) -> void:
	self.taken_positions.erase(position)

func _on_back_music_finished():
	$"Back music".play()
	
func _process_costs() -> void:
	var rails_count: int = self.rails_collection.get_children().size()
	self._debit(rails_count * 1200)
	
	if self.budget < 0:
		self._pause_game()
		if not self.is_game_over:
			self.is_game_over = true
			self._warn_about_budget()
		else:
			self._game_over()
	else:
		self._is_game_over = false

func _pause_game() -> void:
	self.clock_timer.set_paused(true)
	self.game_pause.emit()

func _resume_game() -> void:
	self.clock_timer.set_paused(false)
	self.game_resume.emit()

func _on_button_button_down():
	self._pause_game()

func _on_button_2_button_down():
	self._resume_game()

func _on_texture_button_button_down():
	self._dismiss_budget_warning()
	self._resume_game()

func _warn_about_budget():
	self.budget_warning.visible = true
	self.build_tool.building_unit = BuildTool.BuildingUnit.NONE
	self.build_menu.visible = false

func _game_over():
	self.game_over.visible = true
	self.build_tool.building_unit = BuildTool.BuildingUnit.NONE
	self.build_menu.visible = false

func _dismiss_budget_warning():
	self.budget_warning.visible = false
	self.build_menu.visible = true
