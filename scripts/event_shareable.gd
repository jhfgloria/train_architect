class_name EventShareable
extends Node2D

func register_signal(custom_signal: Signal) -> void:
	EventBus.register_signal(custom_signal)
