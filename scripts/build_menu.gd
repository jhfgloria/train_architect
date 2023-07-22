class_name BuildMenu
extends Node2D

# Build menu components
@onready var rail_button: TextureButton = $rail_button
@onready var platform_button: TextureButton = $"Platform Button"
@onready var building_details: Sprite2D = $building_details
# Build menu signals
signal set_build_platform
signal set_build_rails
# Build menu preloads
@onready var rail_details: Texture2D = preload("res://sprites/building_details--rail.png")
@onready var platform_details: Texture2D = preload("res://sprites/building_details--platform.png")

func _init() -> void:
	EventBus.register_signal(self.set_build_platform)	
	EventBus.register_signal(self.set_build_rails)

func _on_platform_button_pressed():
	self.set_build_platform.emit()

func _on_rail_button_pressed():
	self.set_build_rails.emit()

func _on_rail_button_mouse_entered():
	self.building_details.set_texture(self.rail_details)
	self.building_details.position = self.rail_button.position + Vector2(24, -16)
	self.building_details.visible = true	

func _on_platform_button_mouse_entered():
	self.building_details.set_texture(self.platform_details)
	self.building_details.position = self.platform_button.position + Vector2(24, -16)
	self.building_details.visible = true

func _on_platform_button_mouse_exited():
	self.building_details.visible = false

func _on_rail_button_mouse_exited():
	self.building_details.visible = false
