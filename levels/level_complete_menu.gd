extends Control


func _on_level_complete(body: Node3D) -> void:
	visible = true

func _on_main_menu_button_pressed() -> void:
	Global.change_scene_to_path(Global.start_menu_path)
