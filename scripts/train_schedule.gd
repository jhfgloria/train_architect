class_name TrainSchedule
extends Node2D

@onready var train_model = preload("res://scenes/train.tscn")
@onready var announcing_timer = $"Announcing Timer" as Timer
@onready var dispatch_timer = $"Dispatch Timer" as Timer
@onready var randomizer = RandomNumberGenerator.new()

signal call_people_to_station
signal dispatch_train

func _ready() -> void:
	EventBus.game_pause_broadcast.connect(self._pause_timers)
	EventBus.game_resume_broadcast.connect(self._resume_timers)
	self._announce_train()
	
func _announce_train() -> void:
	announcing_timer.wait_time = _next_train()
	announcing_timer.one_shot = true
	announcing_timer.start()
	
func _next_train() -> float:
	return randomizer.randf_range(2.0, 5.0)
	
func _call_people_to_station() -> void:
	call_people_to_station.emit()
	dispatch_timer.wait_time = 5.0
	dispatch_timer.one_shot = true
	dispatch_timer.start()

func _dispatch_train() -> void:
	dispatch_train.emit()
	await get_tree().create_timer(15.0).timeout
	self._announce_train()

func _pause_timers() -> void:
	self.announcing_timer.set_paused(true)
	self.dispatch_timer.set_paused(true)

func _resume_timers() -> void:
	self.announcing_timer.set_paused(false)
	self.dispatch_timer.set_paused(false)
