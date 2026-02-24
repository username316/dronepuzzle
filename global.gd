extends Node

var start_menu_path = "res://ui/StartMenu.tscn"

var current_scene = start_menu_path

func _ready() -> void:
	current_scene =  get_tree().root.get_child(-1)

func change_scene_to_path(path):
	current_scene.queue_free()
	current_scene = ResourceLoader.load(path).instantiate()
	get_tree().root.add_child(current_scene)
