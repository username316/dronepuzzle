extends Control

var selected_level = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	$Label2.show()
	$Panel2.hide()
	$Panel3.hide()
	$Panel4.hide()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

#Hide all level previews before showing the selected one
func hide_all_previews() -> void:
	$Label2.hide()
	$Panel2.hide()
	$Panel3.hide()
	$Panel4.hide()

func reset_button_colors() -> void:
	$VBoxContainer/Button.modulate = Color.WHITE
	$VBoxContainer/Button2.modulate = Color.WHITE
	$VBoxContainer/Button3.modulate = Color.WHITE


func _on_level1_pressed() -> void:
	reset_button_colors()
	hide_all_previews()
	selected_level = 1
	$VBoxContainer/Button.modulate = Color.GREEN
	$Panel2.show()


func _on_level2_pressed() -> void:
	reset_button_colors()
	hide_all_previews()
	selected_level = 2
	$VBoxContainer/Button2.modulate = Color.GREEN
	$Panel3.show()


func _on_level3_pressed() -> void:
	reset_button_colors()
	hide_all_previews()
	selected_level = 3
	$VBoxContainer/Button3.modulate = Color.GREEN
	$Panel4.show()


func _on_exit_pressed() -> void:
	get_tree().quit()


func _on_start_pressed() -> void:
	if selected_level == 1 or selected_level == 2 or selected_level == 3:
		Global.selected_level = selected_level
		Global.change_scene_to_path("res://ui/PartsMenu.tscn")
