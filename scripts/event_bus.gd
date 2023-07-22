extends Node

signal set_build_platform_sig
func set_build_platform() -> void: set_build_platform_sig.emit()

signal set_build_rails_sig
func set_build_rails() -> void: set_build_rails_sig.emit()

signal person_board_train_sig(position: Vector2, train_id: int)
func person_board_train(position: Vector2, train_id: int) -> void: person_board_train_sig.emit(position, train_id)

signal rail_call_people_sig(position: Vector2, train_id: int)
func rail_call_people(position: Vector2, train_id: int) -> void: rail_call_people_sig.emit(position, train_id)

signal person_reached_position_sig(position: Vector2)
func person_reached_position(position: Vector2) -> void: person_reached_position_sig.emit(position)

signal game_debit_broadcast(delta: int)
func game_debit(delta: int) -> void: game_debit_broadcast.emit(delta)

signal game_credit_broadcast(delta: int)
func game_credit(delta: int) -> void: game_credit_broadcast.emit(delta)

signal game_pause_broadcast()
func game_pause() -> void: game_pause_broadcast.emit()

signal game_resume_broadcast()
func game_resume() -> void: game_resume_broadcast.emit()

func register_signal(custom_signal: Signal) -> void:
	custom_signal.connect(Callable(self, custom_signal.get_name()))
