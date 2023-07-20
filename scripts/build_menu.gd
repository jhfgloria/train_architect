class_name BuildMenu
extends EventShareable

@onready var platform_button: TextureButton = $"Platform Button"
@onready var rails_button: TextureButton = $"Rails Button"

signal set_build_platform
signal set_build_rails

func _init() -> void:
	self.register_signal(self.set_build_platform)	
	self.register_signal(self.set_build_rails)

func _on_platform_button_pressed():
	self.set_build_platform.emit()

func _on_rail_button_pressed():
	self.set_build_rails.emit()

