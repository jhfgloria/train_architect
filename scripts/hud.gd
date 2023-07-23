extends Node2D

# Sprite preloads
@onready var train_balloon_texture = preload("res://sprites/TrainBallon.png") as Texture2D
@onready var ticket_balloon_texture = preload("res://sprites/TicketBallon.png") as Texture2D
@onready var no_path_balloon_texture = preload("res://sprites/no_path_balloon.png") as Texture2D
# HUD components
@onready var budget_variation_label = $"Budget Variation" as Label
@onready var budget_variation_timer = $budget_variation_timer as Timer
@onready var warning_timer = $warning_timer as Timer
@onready var warning_label: Sprite2D = $warning
# HUD privates
var _budget_variation = 0

func _ready() -> void:
	EventBus.rail_call_people_sig.connect(self._train_pop_up)
	EventBus.person_board_train_sig.connect(self._ticket_pop_up)
	EventBus.game_debit_broadcast.connect(self._update_budget_variation)
	EventBus.game_credit_broadcast.connect(self._update_budget_variation)
	EventBus.person_no_path_available_broadcast.connect(self._handle_no_path_available)

func _train_pop_up(position: Vector2, _t: int) -> void:
	var pop_up = self._create_pop_up(position - Vector2(230, 20), train_balloon_texture)
	self._remove_pop_up(pop_up)

func _ticket_pop_up(position: Vector2, _t: int) -> void:
	var pop_up = self._create_pop_up(position - Vector2(0, 28), ticket_balloon_texture)
	self._remove_pop_up(pop_up)

func _handle_no_path_available(position: Vector2) -> void:
	self.warning_label.visible = true
	self.warning_timer.start()
	var pop_up = self._create_pop_up(position - Vector2(0, 28), no_path_balloon_texture)
	self._remove_pop_up(pop_up, 4)

func _create_pop_up(position: Vector2, texture: Texture2D) -> Sprite2D:
	var pop_up = Sprite2D.new()
	pop_up.z_index = position.y + 28
	pop_up.set_texture(texture)
	pop_up.set_position(position)
	self.add_child(pop_up)
	return pop_up

func _remove_pop_up(pop_up: Sprite2D, timeout = 5) -> void:
	await get_tree().create_timer(timeout).timeout
	pop_up.queue_free()

func _update_budget_variation(delta: int) -> void:
	self._budget_variation += delta
	if self._budget_variation > 0: self.budget_variation_label.set_text("+" + String.num_int64(self._budget_variation))
	else: self.budget_variation_label.set_text(String.num_int64(self._budget_variation))
	
	self.budget_variation_label.set_visible(true)
	self.budget_variation_timer.start()

func _on_budget_variation_timer_timeout():
	self._budget_variation = 0
	self.budget_variation_label.set_visible(false)

func _on_warning_timer_timeout():
	self.warning_label.visible = false
