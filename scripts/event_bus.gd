extends Node

signal set_build_platform_sig
func set_build_platform() -> void: set_build_platform_sig.emit()

signal set_build_rails_sig
func set_build_rails() -> void: set_build_rails_sig.emit()

signal person_board_train_sig
func person_board_train() -> void: person_board_train_sig.emit()

func register_signal(custom_signal: Signal) -> void:
	custom_signal.connect(Callable(self, custom_signal.get_name()))
