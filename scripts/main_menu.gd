extends Node2D

func _on_start_game_btn_button_down():
	get_tree().change_scene_to_file("res://scenes/main_scene.tscn")


func _on_credits_btn_button_down():
	get_tree().change_scene_to_file("res://scenes/credits.tscn")
