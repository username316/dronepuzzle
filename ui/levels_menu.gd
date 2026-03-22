extends Control

var selected_level = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func reset_button_colors() -> void:
	$VBoxContainer/Button.modulate = Color.WHITE
	$VBoxContainer/Button2.modulate = Color.WHITE
	$VBoxContainer/Button3.modulate = Color.WHITE


func _on_level1_pressed() -> void:
	reset_button_colors()
	selected_level = 1
	$VBoxContainer/Button.modulate = Color.GREEN


func _on_level2_pressed() -> void:
	reset_button_colors()
	selected_level = 2
	$VBoxContainer/Button2.modulate = Color.GREEN


func _on_level3_pressed() -> void:
	reset_button_colors()
	selected_level = 3
	$VBoxContainer/Button3.modulate = Color.GREEN


func _on_back_pressed() -> void:
	pass


func _on_exit_pressed() -> void:
	get_tree().quit()


func _on_start_pressed() -> void:
	if selected_level == 1:
		Global.change_scene_to_path("res://levels/Level1.tscn")

	elif selected_level == 2:
		Global.change_scene_to_path("res://levels/Level2.tscn")

	elif selected_level == 3:
		Global.change_scene_to_path("res://levels/Level3.tscn")

	else:
		print("Select a level first")
