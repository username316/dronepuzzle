extends Control

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		toggle_pause()

func toggle_pause():
	get_tree().paused = !get_tree().paused
	visible = !visible

func _on_continue_button_pressed() -> void:
	toggle_pause()

func _on_to_start_button_pressed() -> void:
	get_tree().paused = false
	Global.change_scene_to_path(Global.start_menu_path)
