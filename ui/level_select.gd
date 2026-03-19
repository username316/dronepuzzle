extends Node3D


func _on_level_one_pressed() -> void:
	Global.change_scene_to_path("res://levels/Level1.tscn")
	
func _on_level_two_pressed() -> void:
	Global.change_scene_to_path("res://levels/Level2.tscn")
	
func _on_level_three_pressed() -> void:
	Global.change_scene_to_path("res://levels/Level3.tscn")
