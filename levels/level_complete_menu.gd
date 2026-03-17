extends Control

@onready var time_label = $VBoxContainer/TimeLabel

func complete_level(time: float) -> void:
	visible = true
	time_label.text = "IN %.2fs" % time

func _on_main_menu_button_pressed() -> void:
	Global.change_scene_to_path(Global.start_menu_path)
