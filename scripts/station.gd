class_name Station
extends StaticBody2D

@onready var spawn_position = $"Spawn Position" as Node2D

func get_spawn_position() -> Vector2:
	return self.spawn_position.global_position
